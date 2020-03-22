### Concept

The project has the following conceptual features:
* Standard types, including FreePascal, old and new versions of Delphi, convenient functions for managing them.
* Universal data representation, regardless of programming language and compiler version.
* Convert standard RTTI to universal data representation.
* Minimizing dependencies on heavy units like Classes, Variants, Generics, etc.
* Cross-platform functions invoke, including FreePascal and old versions of Delphi, creation of function and interface interpreters.
* Marshalling (serialization and deserialization of data) through different formatters: JSON, XML, [FlexBin](FlexBin.RUS.md) and others.
* Easy to use unit testing library that does not access the memory manager.

The following sections deserve special attention:
* [Compatibility](#compatibility)
* [Universal data representation](#universal-data-representation)
* [Context](#context)
* [TValue benchmark](#tvalue-benchmark)
* [Invoke benchmark](#invoke-benchmark)
* [Virtual interface benchmark](#virtual-interface-benchmark)

### Compatibility

The library is created with the prospect of using in different programming languages, but primarily for Delphi and FreePascal. The main unit is _Tiny.Rtti.pas_, it contains the main types and functions of the library. One of the key ideas of the unit is to ensure code compatibility on different versions of Delphi or FreePascal. For example, on older versions of Delphi there are no `NativeInt` or `UnicodeString` types, and on NEXTGEN compilers there are no `WideString` or `ShortString` types - in this case they are emulated. On older versions of Delphi and FreePascal, there are no familiar `Atomic-`functions or TypeInfo initialization/copy/finalization functions (`InitializeArray`, `CopyRecord`, etc.) - all of them are also emulated.

Another feature of the library is that the internal types and functions match the units of _System.TypInfo.pas_ and _System.Rtti.pas_ as closely as possible. For example, there are the usual types `TTypeKind`, `TTypeInfo`, `TTypeData`, the `GetEnumName` and `HasWeakRef` functions, there is a [TValue](#tvalue-benchmark) type, including for old Delphi and FreePascal. There are structures that describe arrays, classes, interfaces and other RTTI.

### Universal data representation

Despite the fact that a significant part of the library works with RTTI, its essence boils down to the universal representation of data: types and information about them. To store the base type, the `TRttiType` enumeration is used. To classify the types, the `TRttiTypeGroup` enumeration is used. There is a standard set of types and groups, but you can always extend this set with the `RttiTypeIncrease` and `RttiTypeIncreaseGroup` functions. For a detailed description of the type, the `TRttiExType` structure is used - it stores the base type, pointer depth, options and additional meta information.

### Context

Typically, context is used to convert TypeInfo into the [universal data representation](#universal-data-representation). You can use the `DefaultContext` variable for these purposes. The context functionality can be expanded, for example, to store information about classes, interfaces, properties and methods. For storing and caching a namespace, there is a type `TRttiNamespace` (_Tiny.Namespaces.pas_).

On older versions of Delphi, RTTI is not generated for some types, for example, `PAnsiChar`. Therefore, the library supports the concept of PTypeInfo equivalents that will be correctly converted by the context. Use dummy constants (`TYPEINFO_PANSICHAR`, `TYPEINFO_UINT64`, etc.) or the `DummyTypeInfo` function for such cases.

### TValue benchmark

`TValue` is a lightweight analogue of the Variant type. This type supports almost all types available in Tiny.Rtti, an exception is made only by all pointer types, they are all cast to `Pointer`. The functional largely repeats the System.Rtti implementation, the difference is only in increasing the number of `As`-properties and reducing the functions of the casts. In addition, much attention was paid to optimizations, you can see this on the benchmark below. Type `TValue` and the benchmark were created with the participation of [Alexander Zhirov](mailto:suprito2012@gmail.com).

![](data/ValueBenchmark.png)

### Invoke benchmark

In some cases, for example, when binding code with scripts, or when performing automatic tests, there is a need to invoke your native functions. In older versions of Delphi, this functionality was not available, but in newer versions, the call occurs with low performance. The _Tiny.Invoke.pas_ unit allows you to invoke functions at 3 levels of abstraction ([values](#tvalue-benchmark), arguments, direct), the benchmark below shows how to do this and measures performance.

`TRttiSignature` structure stores service information about the function signature: calling convention, argument description, register and stack information. The `TRttiInvokeDump` structure is used to store arguments in memory.

![](data/InvokeBenchmark.png)
```pascal
procedure TForm1.SomeMethod(const X, Y, Z: Integer);
begin
  Tag := X + Y + Z;
end;

procedure TForm1.Button1Click(Sender: TObject);
const
  COUNT = 1000000;
var
  i: Integer;
  LStopwatch: TStopwatch;
  LContext: System.Rtti.TRttiContext;
  LMethod: System.Rtti.TRttiMethod;
  LMethodEntry: Tiny.Rtti.PVmtMethodExEntry;
  LSignature: Tiny.Invoke.TRttiSignature;
  LInvokeFunc: Tiny.Invoke.TRttiInvokeFunc;
  LDump: Tiny.Invoke.TRttiInvokeDump;
  T1, T2, T3, T4: Int64;
begin
  // initialization
  LContext := System.Rtti.TRttiContext.Create;
  LMethod := LContext.GetType(TForm1).GetMethod('SomeMethod');
  LMethodEntry := Tiny.Rtti.PTypeInfo(TypeInfo(TForm1)).TypeData.ClassData.MethodTableEx.Find('SomeMethod');
  LSignature.Init(LMethodEntry^);
  LInvokeFunc := LSignature.OptimalInvokeFunc;

  // System.Rtti
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LMethod.Invoke(Form1, [1, 2, 3]);
  end;
  T1 := LStopwatch.ElapsedMilliseconds;

  // Tiny.Rtti(Invoke) values
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LSignature.Invoke(LDump, LMethodEntry.CodeAddress, Form1, {TValue}[1, 2, 3], LInvokeFunc);
  end;
  T2 := LStopwatch.ElapsedMilliseconds;

  // Tiny.Rtti(Invoke) arguments
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LSignature.Invoke(LDump, LMethodEntry.CodeAddress, Form1, {array of}[1, 2, 3], nil, LInvokeFunc);
  end;
  T3 := LStopwatch.ElapsedMilliseconds;

  // Tiny.Rtti(Invoke) direct
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    PPointer(@LDump.Bytes[LSignature.DumpOptions.ThisOffset])^ := Form1;
    PInteger(@LDump.Bytes[LSignature.Arguments[0].Offset])^ := 1;
    PInteger(@LDump.Bytes[LSignature.Arguments[1].Offset])^ := 2;
    PInteger(@LDump.Bytes[LSignature.Arguments[2].Offset])^ := 3;
    LInvokeFunc(@LSignature, LMethodEntry.CodeAddress, @LDump);
  end;
  T4 := LStopwatch.ElapsedMilliseconds;

  // result
  Caption := Format('System.Rtti: %dms, Tiny.Rtti (values): %dms, ' +
    'Tiny.Rtti (args): %dms, Tiny.Rtti (direct): %dms', [T1, T2, T3, T4]);
end;
```
### Virtual interface benchmark

Virtual interfaces can be used, for example, for high-level marshalling, when a native function call leads to the conversion of the arguments into binary form and sending them to server. The idea of a virtual interface is that you intercept the methods you call and process the arguments as you like. The _Tiny.Invoke.pas_ unit allows you to intercept interface methods at 2 levels of abstraction: [values](#tvalue-benchmark) and direct. At the direct level, the structures `TRttiSignature` and `TRttiInvokeDump`, which are described [above](#invoke-benchmark), are important.

Unlike the implementation of _System.Rtti.pas_, the library allows you to redefine the method context (**not** [TRttiContext](#context)) and the callback for each method. The benchmark below demonstrates the functionality of a virtual interface and compares performance.

![](data/VirtualInterfaceBenchmark.png)
```pascal
type
  IMyInterface = interface(IInvokable)
    ['{89EDBA5C-DFBA-48FA-889C-FC857B0ED609}']
    function Func(const X, Y, Z: Integer): Integer;
  end;

procedure TForm1.Button1Click(Sender: TObject);
const
  COUNT = 1000000;
var
  i: Integer;
  LStopwatch: TStopwatch;
  LInterface: IMyInterface;
  LValue: Integer;
  T1, T2, T3: Int64;
begin
  // System.Rtti virtual interface
  LInterface := System.Rtti.TVirtualInterface.Create(TypeInfo(IMyInterface),
    procedure(Method: System.Rtti.TRttiMethod;
      const Args: TArray<System.Rtti.TValue>; out Result: System.Rtti.TValue)
    begin
      Result := Args[1].AsInteger + Args[2].AsInteger + Args[3].AsInteger;
    end) as IMyInterface;
  LValue := LInterface.Func(1, 2, 3);
  Assert(LValue = (1 + 2 + 3), 'System.Rtti virtual interface');
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LInterface.Func(1, 2, 3);
  end;
  T1 := LStopwatch.ElapsedMilliseconds;

  // Tiny.Rtti(Invoke) virtual interface
  LInterface := Tiny.Invoke.TRttiVirtualInterface.Create(TypeInfo(IMyInterface),
    function(const AMethod: Tiny.Invoke.TRttiVirtualMethod;
      const AArgs: TArray<Tiny.Rtti.TValue>; const AReturnAddress: Pointer): TValue
    begin
      Result := AArgs[1].AsInteger + AArgs[2].AsInteger + AArgs[3].AsInteger;
    end) as IMyInterface;
  LValue := LInterface.Func(1, 2, 3);
  Assert(LValue = (1 + 2 + 3), 'Tiny.Rtti(Invoke) virtual interface');
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LInterface.Func(1, 2, 3);
  end;
  T2 := LStopwatch.ElapsedMilliseconds;

  // Tiny.Rtti(Invoke) direct virtual interface
  LInterface := Tiny.Invoke.TRttiVirtualInterface.CreateDirect(TypeInfo(IMyInterface),
     procedure(const AMethod: Tiny.Invoke.TRttiVirtualMethod; var ADump: Tiny.Invoke.TRttiInvokeDump)
     var
       LSignature: Tiny.Invoke.PRttiSignature;
     begin
       LSignature := AMethod.Signature;
       ADump.OutInt32 := PInteger(@ADump.Bytes[LSignature.Arguments[0].Offset])^ +
         PInteger(@ADump.Bytes[LSignature.Arguments[1].Offset])^ +
         PInteger(@ADump.Bytes[LSignature.Arguments[2].Offset])^;
     end) as IMyInterface;
  LValue := LInterface.Func(1, 2, 3);
  Assert(LValue = (1 + 2 + 3), 'Tiny.Rtti(Invoke) direct virtual interface');
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LInterface.Func(1, 2, 3);
  end;
  T3 := LStopwatch.ElapsedMilliseconds;

  // result
  Caption := Format('System.Rtti: %dms, Tiny.Rtti: %dms, Tiny.Rtti (direct): %dms', [T1, T2, T3]);
end;
```