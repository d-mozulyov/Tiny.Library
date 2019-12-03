unit Tiny.Invoke;

{******************************************************************************}
{ Copyright (c) Dmitry Mozulyov                                                }
{                                                                              }
{ Permission is hereby granted, free of charge, to any person obtaining a copy }
{ of this software and associated documentation files (the "Software"), to deal}
{ in the Software without restriction, including without limitation the rights }
{ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    }
{ copies of the Software, and to permit persons to whom the Software is        }
{ furnished to do so, subject to the following conditions:                     }
{                                                                              }
{ The above copyright notice and this permission notice shall be included in   }
{ all copies or substantial portions of the Software.                          }
{                                                                              }
{ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   }
{ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     }
{ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  }
{ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       }
{ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,}
{ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN    }
{ THE SOFTWARE.                                                                }
{                                                                              }
{ email: softforyou@inbox.ru                                                   }
{ skype: dimandevil                                                            }
{ repository: https://github.com/d-mozulyov/Tiny.Rtti                          }
{******************************************************************************}

{$I TINY.DEFINES.inc}


interface
uses
  Tiny.Rtti;


type
  {$if Defined(CPUX86) or Defined(CPUARM32) or (Defined(CPUX64) and Defined(MSWINDOWS))}
    TRttiOutGeneral = Int64;
  {$else .CPUARM64}
    TRttiOutGeneral = packed record
      Low: Int64;
      High: Int64;
    end;
  {$ifend}
  PRttiOutGeneral = ^TRttiOutGeneral;

  TRttiHFAStruct = packed record
  {$if Defined(CPUARM) or Defined(POSIXINTEL64)}
  case Integer of
    0:
    (
      D0: Double;
      D1: Double;
      {$ifdef CPUARM}
      D2: Double;
      D3: Double;
      {$endif}
    );
    1:
    (
      {$if Defined(CPUARM32) or Defined(POSIXINTEL64)}
      S0: Single;
      S1: Single;
      S2: Single;
      S3: Single;
      {$else .CPUARM64}
      S0: Single;
      _0: Integer;
      S1: Single;
      _1: Integer;
      S2: Single;
      _2: Integer;
      S3: Single;
      _3: Integer;
      {$ifend}
    );
    2:
    (
      Extendeds: array[0..{$ifdef CPUARM}3{$else}1{$endif}] of Double;
    );
  {$ifend}
  end;
  PRttiHFAStruct = ^TRttiHFAStruct;

  PRttiGeneralRegisters = ^TRttiGeneralRegisters;
  PRttiExtendedRegisters = ^TRttiExtendedRegisters;
  {$if Defined(CPUX86)}
    TRttiGeneralRegisters = array[0..2] of NativeInt;
    TRttiExtendedRegisters = packed record end;
    TRttiRegisters = packed record
    case Integer of
      0:
      (
        RegEAX: Integer;
        RegEDX: Integer;
        RegECX: Integer;
        case Integer of
          0: (OutEAX, OutEDX: Integer);
          1: (OutGeneral: TRttiOutGeneral);
          2: (OutInt32: Integer);
          3: (OutInt64: Int64);
          4: (OutFloat: Single);
          5: (OutDouble: Double);
          6: (OutLongDouble: Extended);
          7: (OutSafeCall: HRESULT);
          8: (OutBytes: array[0..15] of Byte);
          9: (_: packed record end);
      );
      1: (Generals: TRttiGeneralRegisters);
      2: (Extendeds: TRttiExtendedRegisters{none});
    end;
  {$elseif Defined(CPUX64) and Defined(MSWINDOWS)}
    TRttiGeneralRegisters = array[0..3] of NativeInt;
    TRttiExtendedRegisters = array[0..3] of Double;
    TRttiRegisters = packed record
    case Integer of
      0:
      (
        RegRCX: Int64;
        RegRDX: Int64;
        RegR8: Int64;
        RegR9: Int64;
        RegXMM0: Double;
        RegXMM1: Double;
        RegXMM2: Double;
        RegXMM3: Double;
        case Integer of
          0: (OutRAX: Int64);
          1: (OutGeneral: TRttiOutGeneral);
          2: (OutXMM0: Double);
          3: (OutInt32: Integer);
          4: (OutInt64: Int64);
          5: (OutFloat: Single);
          6: (OutDouble: Double);
          7: (OutSafeCall: HRESULT);
          8: (OutBytes: array[0..7] of Byte);
          9: (_: packed record end);
      );
      1:
      (
        Generals: TRttiGeneralRegisters;
        Extendeds: TRttiExtendedRegisters;
      );
    end;
  {$elseif Defined(POSIXINTEL64)}
    TRttiGeneralRegisters = array[0..5] of NativeInt;
    TRttiExtendedRegisters = array[0..7] of Double;
    TRttiRegisters = packed record
    case Integer of
      0:
      (
        RegRDI: Int64;
        RegRSI: Int64;
        RegRDX: Int64;
        RegRCX: Int64;
        RegR8: Int64;
        RegR9: Int64;
        RegXMM0: Double;
        RegXMM1: Double;
        RegXMM2: Double;
        RegXMM3: Double;
        RegXMM4: Double;
        RegXMM5: Double;
        RegXMM6: Double;
        RegXMM7: Double;
        case Integer of
          0: (OutRAX, OutRDX: Int64);
          1: (OutGeneral: TRttiOutGeneral);
          2: (OutXMM0, OutXMM1: Double);
          3: (OutHFA: TRttiHFAStruct);
          4: (OutInt32: Integer);
          5: (OutInt64: Int64);
          6: (OutFloat: Single);
          7: (OutDouble: Double);
          8: (OutLongDouble: Extended);
          9: (OutSafeCall: HRESULT);
          10: (OutBytes: array[0..15] of Byte);
          11: (_: packed record end);
      );
      1:
      (
        Generals: TRttiGeneralRegisters;
        Extendeds: TRttiExtendedRegisters;
      );
    end;
  {$elseif Defined(CPUARM32)}
    TRttiGeneralRegisters = array[0..3] of NativeInt;
    TRttiExtendedRegisters = array[0..7] of Double;
    PRttiHalfExtendedRegisters = ^TRttiHalfExtendedRegisters;
    TRttiHalfExtendedRegisters = array[0..15] of Single;
    TRttiRegisters = packed record
    case Integer of
      0:
      (
        RegR0: Integer;
        RegR1: Integer;
        RegR2: Integer;
        RegR3: Integer;
        case Integer of
          0:
          (
            RegD0: Double;
            RegD1: Double;
            RegD2: Double;
            RegD3: Double;
            RegD4: Double;
            RegD5: Double;
            RegD6: Double;
            RegD7: Double;
          );
          1:
          (
            RegS0: Single;
            RegS1: Single;
            RegS2: Single;
            RegS3: Single;
            RegS4: Single;
            RegS5: Single;
            RegS6: Single;
            RegS7: Single;
            RegS8: Single;
            RegS9: Single;
            RegS10: Single;
            RegS11: Single;
            RegS12: Single;
            RegS13: Single;
            RegS14: Single;
            RegS15: Single;
          );
          2:
          (
            _: packed record Bytes: array[0..63] of Byte; end;
            case Integer of
              0: (OutR0, OutR1: Integer);
              1: (OutGeneral: TRttiOutGeneral);
              2: (OutD0, OutD1: Double);
              3: (OutHFA: TRttiHFAStruct);
              4: (OutInt32: Integer);
              5: (OutInt64: Int64);
              6: (OutFloat: Single);
              7: (OutDouble: Double);
              8: (OutSafeCall: HRESULT);
              9: (OutBytes: array[0..31] of Byte);
              10: (__: packed record end);
          );
      );
      1:
      (
        Generals: TRttiGeneralRegisters;
        case Integer of
          0: (Extendeds: TRttiExtendedRegisters);
          1: (HalfExtendeds: TRttiHalfExtendedRegisters);
          2: (___: packed record end;)
      );
    end;
  {$elseif Defined(CPUARM64)}
    TRttiGeneralRegisters = array[0..7 + 1] of NativeInt;
    TRttiExtendedRegisters = array[0..7] of Double;
    TRttiRegisters = packed record
    case Integer of
      0:
      (
        RegX0: Int64;
        RegX1: Int64;
        RegX2: Int64;
        RegX3: Int64;
        RegX4: Int64;
        RegX5: Int64;
        RegX6: Int64;
        RegX7: Int64;
        RegX8: Int64{Result address};
        case Integer of
          0:
          (
            RegD0: Double;
            RegD1: Double;
            RegD2: Double;
            RegD3: Double;
            RegD4: Double;
            RegD5: Double;
            RegD6: Double;
            RegD7: Double;
          );
          1:
          (
            RegS0: Single;
            _0: Integer;
            RegS1: Single;
            _1: Integer;
            RegS2: Single;
            _2: Integer;
            RegS3: Single;
            _3: Integer;
            RegS4: Single;
            _4: Integer;
            RegS5: Single;
            _5: Integer;
            RegS6: Single;
            _6: Integer;
            RegS7: Single;
            _7: Integer;
          );
          2:
          (
            _: packed record Bytes: array[0..63] of Byte; end;
            case Integer of
              0: (OutX0, OutX1: Int64);
              1: (OutGeneral: TRttiOutGeneral);
              2: (OutD0, OutD1: Double);
              3: (OutHFA: TRttiHFAStruct);
              4: (OutInt32: Integer);
              5: (OutInt64: Int64);
              6: (OutFloat: Single);
              7: (OutDouble: Double);
              8: (OutSafeCall: HRESULT);
              9: (OutBytes: array[0..31] of Byte);
              10: (__: packed record end);
          );
      );
      1:
      (
        Generals: TRttiGeneralRegisters;
        Extendeds: TRttiExtendedRegisters;
      );
    end;
  {$else}
    {$MESSAGE ERROR 'Unknown compiler'}
  {$ifend}
  PRttiRegisters = ^TRttiRegisters;


type

  PRttiInvokeDump = ^TRttiInvokeDump;
  TRttiInvokeDump = packed record
  case Integer of
    0:
    (
      Registers: TRttiRegisters;
      ReturnAddress: Pointer;
      Stack: array[0..(16 div SizeOf(NativeInt)) * 255 + 1 + 1 - 1] of NativeInt;
    );
    1:
    (
      Generals: TRttiGeneralRegisters;
      Extendeds: TRttiExtendedRegisters;
      case Integer of
        0: (OutGeneral: TRttiOutGeneral);
        1: (OutHFA: TRttiHFAStruct);
        2: (OutInt32: Integer);
        3: (OutInt64: Int64);
        4: (OutFloat: Single);
        5: (OutDouble: Double);
        6: (OutLongDouble: Extended);
        7: (OutSafeCall: HRESULT);
        8: (OutBytes: array[0..
          {$if Defined(CPUX64) and Defined(MSWINDOWS)} 7
          {$elseif Defined(CPUARM)} 31
          {$else} 15 {$ifend}] of Byte);
        9: (_: packed record end);
    );
    2:
    (
      Bytes: array[0..SizeOf(TRttiRegisters) + SizeOf(Pointer) + 16 * 255 + 2 * SizeOf(NativeInt) - 1] of Byte;
    );
  end;


type

  PRttiArgumentQualifier = ^TRttiArgumentQualifier;
  TRttiArgumentQualifier = (
    rqValue,
    rqUnsafeValue,
    rqWeakValue,
    rqValueRef,
    rqUnsafeValueRef,
    rqWeakValueRef,
    rqConst,
    rqConstRef,
    rqVar,
    rqUnsafeVar,
    rqWeakVar,
    rqOut,
    rqUnsafeOut,
    rqWeakOut,
    rqArrayValue,
    rqArrayConst,
    rqArrayVar,
    rqArrayOut
  );
  PRttiArgumentQualifiers = ^TRttiArgumentQualifiers;
  TRttiArgumentQualifiers = set of TRttiArgumentQualifier;


  PRttiArgument = ^TRttiArgument;
  {$A1}
  TRttiArgument = object(TRttiExType)
  protected
    function GetIsValue: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsConst: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsVar: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsOut: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsUnsafe: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsWeak: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsArray: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsReference: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTotalPointerDepth: Byte; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Name: PShortStringHelper;
    Offset: Integer;
    Qualifier: TRttiArgumentQualifier;
    GetterFunc: Byte;
    SetterFunc: Byte;
    HighOffset: ShortInt;

    property IsValue: Boolean read GetIsValue;
    property IsConst: Boolean read GetIsConst;
    property IsVar: Boolean read GetIsVar;
    property IsOut: Boolean read GetIsOut;
    property IsUnsafe: Boolean read GetIsUnsafe;
    property IsWeak: Boolean read GetIsWeak;
    property IsArray: Boolean read GetIsArray;
    property IsReference: Boolean read GetIsReference;
    property TotalPointerDepth: Byte read GetTotalPointerDepth;
  end;
  {$A4}

  PRttiReturnStrategy = ^TRttiReturnStrategy;
  TRttiReturnStrategy = (rsNone, rsGeneral, rsGeneralPair, rsSafeCall, rsFPUInt64, rsFPU,
    rsFloat1, rsDouble1, rsFloat2, rsDouble2, rsFloat3, rsDouble3, rsFloat4, rsDouble4);
  PRttiReturnStrategies = ^TRttiReturnStrategies;
  TRttiReturnStrategies = set of TRttiReturnStrategy;

  PRttiSignature = ^TRttiSignature;
  PRttiInvokeFunc = ^TRttiInvokeFunc;
  TRttiInvokeFunc = procedure(const ASignature: PRttiSignature; const AAddress: Pointer; const ADump: PRttiInvokeDump);
  PRttiInterceptFunc = ^TRttiInterceptFunc;
  TRttiInterceptFunc = type Pointer;
  {$A1}
  TRttiSignature = object(TRttiCustomTypeData)
  private
    {$ifdef STATICSUPPORT}class{$endif}function GetUniversalInvokeFunc: TRttiInvokeFunc; {$ifdef STATICSUPPORT}static;{$endif}
    function GetOptimalInvokeFunc: TRttiInvokeFunc;
    function GetInterceptJump(const AIndex: Integer): Pointer;
    {$ifdef STATICSUPPORT}class{$endif}function GetUniversalInterceptFunc: TRttiInterceptFunc; {$ifdef STATICSUPPORT}static;{$endif}
    function GetOptimalInterceptFunc: TRttiInterceptFunc;
    {$ifdef STATICSUPPORT}class{$endif} function InitArgument(var ATarget: TRttiArgument;
      const ASource: TParamData; const AFlags: TParamFlags; const AContext: PRttiContext): Boolean; {$ifdef STATICSUPPORT}static;{$endif}
  public
    CallConv: TRttiCallConv;
    DumpOptions: packed record
      ReturnStrategy: TRttiReturnStrategy;
      Reserved: Word;
      StackSize: Integer;
      {$ifdef CPUX86}
      StackPopSize: Integer;
      {$endif}
      ThisOffset: Integer;
      ConstructorFlagOffset: Integer;
    end;
    Return: TRttiArgument;
    ArgumentCount: Integer;
    Arguments: array[Byte] of TRttiArgument;

    procedure InitDump(const AHasSelf, AConstructor: Boolean);
    function Init(const ASignatureData: TSignatureData; const AContext: PRttiContext = nil): Boolean; overload;
    function Init(const AMethodSignature: TMethodSignature; const AContext: PRttiContext = nil): Boolean; overload;
    function Init(const AIntfMethodSignature: TIntfMethodSignature; const AContext: PRttiContext = nil): Boolean; overload;
    {$if Defined(FPC) or Defined(EXTENDEDRTTI)}
    function Init(const AProcedureSignature: TProcedureSignature; const AContext: PRttiContext = nil; const AAttrData: Pointer = nil): Boolean; overload;
    {$ifend}
    {$if Defined(EXTENDEDRTTI)}
    function Init(const AMethodExEntry: TVmtMethodExEntry; const AContext: PRttiContext = nil): Boolean; overload;
    function Init(const ARecordTypeMethod: TRecordTypeMethod; const AContext: PRttiContext = nil): Boolean; overload;
    {$ifend}
    function Init(const ATypeInfo: PTypeInfo; const AContext: PRttiContext = nil): Boolean; overload;

    {$ifdef STATICSUPPORT}class{$endif} property UniversalInvokeFunc: TRttiInvokeFunc read GetUniversalInvokeFunc;
    property OptimalInvokeFunc: TRttiInvokeFunc read GetOptimalInvokeFunc;
    property InterceptJumps[const AIndex: Integer]: Pointer read GetInterceptJump;
    {$ifdef STATICSUPPORT}class{$endif} property UniversalInterceptFunc: TRttiInterceptFunc read GetUniversalInterceptFunc;
    property OptimalInterceptFunc: TRttiInterceptFunc read GetOptimalInterceptFunc;
  end;
  {$A4}


  PRttiMethodKind = ^TRttiMethodKind;
  TRttiMethodKind = (
    rmGlobal,
    rmInstantiated,
    rmClass,
    rmClassConstructor,
    rmClassDestructor,
    rmClassStatic,
    rmRecordConstructor,
    rmOperator
  );
  PRttiMethodKinds = ^TRttiMethodKinds;
  TRttiMethodKinds = set of TRttiMethodKind;

//   TLuaMethodKind = (mkStatic, mkInstance, mkClass, mkConstructor, mkDestructor, {ToDo}mkOperator);

(*
  TMethodKind = (mkProcedure, mkFunction, mkConstructor, mkDestructor,
    mkClassProcedure, mkClassFunction
    {$if Defined(FPC) or (CompilerVersion >= 21)}
    , mkClassConstructor, mkClassDestructor, mkOperatorOverload
    {$ifend}
    {$ifNdef FPC}
    , mkSafeProcedure, mkSafeFunction
    {$endif}
    );
*)

  //TMethodKind;

  PRttiMethod = ^TRttiMethod;
  {$A1}
  TRttiMethod = object
  protected

  public
    Name: PShortStringHelper;
    Kind: TRttiMethodKind;
    Address: Pointer;
    Signature: PRttiSignature;
  end;
  {$A4}


{ TRttiVirtualInterface class

}

  PRttiVirtualMethod = ^TRttiVirtualMethod;
  {$A1}
  TRttiVirtualMethod = object
  public
    Name: PShortStringHelper;
    Index: NativeInt;
    Context: Pointer;
    Signature: PRttiSignature;
  end;
  {$A4}

  TRttiVirtualMethodCallback = procedure(const AMethod: TRttiVirtualMethod; var ADump: TRttiInvokeDump) of object;
  {$ifdef EXTENDEDRTTI}
  TRttiVirtualMethodDefaultCallback = reference to procedure(const AMethod: TRttiVirtualMethod; var ADump: TRttiInvokeDump);
  {$else}
  TRttiVirtualMethodDefaultCallback = TRttiVirtualMethodCallback;
  {$endif}

  PRttiVirtualMethodData = ^TRttiVirtualMethodData;
  {$A1}
  TRttiVirtualMethodData = object
    InterceptFunc: TRttiInterceptFunc;
    Method: TRttiVirtualMethod;
    {$ifdef WEAKINSTREF}[Unsafe]{$endif}
    Callback: TRttiVirtualMethodCallback;
  end;
  {$A4}
  PRttiVirtualMethodDataDynArray = ^TRttiVirtualMethodDataDynArray;
  TRttiVirtualMethodDataDynArray = {$ifdef SYSARRAYSUPPORT}TArray<TRttiVirtualMethodData>{$else}array of TRttiVirtualMethodData{$endif};

  PGuidDynArray = ^TGuidDynArray;
  TGuidDynArray = {$ifdef SYSARRAYSUPPORT}TArray<TGUID>{$else}array of TGUID{$endif};
  {$ifdef EXTENDEDRTTI}
  TRttiVirtualInterfaceConfigureProc = reference to procedure(var AGuids: TGuidDynArray; var AMethods: TRttiVirtualMethodDataDynArray);
  {$else}
  TRttiVirtualInterfaceConfigureProc = procedure(var AGuids: TGuidDynArray; var AMethods: TRttiVirtualMethodDataDynArray) of object;
  {$endif}

  PRttiVirtualInterfaceTable = ^TRttiVirtualInterfaceTable;
  TRttiVirtualInterfaceTable = packed record
    Methods: TRttiVirtualMethodDataDynArray;
    VMT: {$ifdef SYSARRAYSUPPORT}TArray<Pointer>{$else}array of Pointer{$endif};
  end;

  TRttiVirtualInterface = class(TInterfacedObject)
  protected
    FGuids: TGuidDynArray;
    FTable: TRttiVirtualInterfaceTable;
    FDefaultCallback: TRttiVirtualMethodDefaultCallback;
    {$ifdef WEAKINSTREF}[Unsafe]{$endif} FInternalDefaultCallback: TRttiVirtualMethodCallback;

    procedure DoCallback(const AMethod: TRttiVirtualMethod; var ADump: TRttiInvokeDump); virtual;
    procedure SetDefaultCallback(const AValue: TRttiVirtualMethodDefaultCallback);
  public
    constructor CreateDirect(const AGuids: TGuidDynArray; const AMethods: TRttiVirtualMethodDataDynArray); virtual;
    constructor Create(const AIntfType: PTypeInfo;
      const ADefaultCallback: TRttiVirtualMethodDefaultCallback;
      const AContext: PRttiContext = nil;
      const AConfigureProc: TRttiVirtualInterfaceConfigureProc = nil);

    property Guids: TGuidDynArray read FGuids;
    property Methods: TRttiVirtualMethodDataDynArray read FTable.Methods;
    property DefaultCallback: TRttiVirtualMethodDefaultCallback read FDefaultCallback;
  end;


implementation


procedure TinyThrowSafeCall(const ACode: Integer; const AReturnAddress: Pointer);
begin
  if Assigned(SafeCallErrorProc) then
    SafeCallErrorProc(ACode, AReturnAddress);

  if Assigned(ErrorProc) then
    ErrorProc(Ord(reSafeCallError), AReturnAddress {$ifdef FPC}, nil{$endif});

  System.ErrorAddr := AReturnAddress;
  System.ExitCode := 229{reSafeCallError};
  System.Halt;
end;
{$if not Defined(OBJLINKSUPPORT)}
exports TinyThrowSafeCall;
{$ifend}

{$if not Defined(FPC) and (CompilerVersion <= 22)}
  {$define OLDDELPHI}
{$ifend}

{$if Defined(OBJLINKSUPPORT)}
  {$if Defined(MSWINDOWS)}
    {$ifdef SMALLINT}
      {$L objs\win32\tiny.invoke.o}
      {$ifNdef OLDDELPHI}
        {$L objs\win32\tiny.invoke.intrjumps.o}
      {$endif}
    {$else}
      {$L objs\win64\tiny.invoke.o}
      {$L objs\win64\tiny.invoke.intrjumps.o}
    {$endif}
  {$elseif Defined(ANDROID)}
    {$ifdef SMALLINT}
      {$L objs\android32\tiny.invoke.o}
      {$L objs\android32\tiny.invoke.intrjumps.o}
    {$else}
      {$L objs\android64\tiny.invoke.o}
      {$L objs\android64\tiny.invoke.intrjumps.o}
    {$endif}
  {$elseif Defined(IOS)}
    {$ifdef SMALLINT}
      {$L objs\ios32\tiny.invoke.o}
      {$L objs\ios32\tiny.invoke.intrjumps.o}
    {$else}
      {$L objs\ios64\tiny.invoke.o}
      {$L objs\ios64\tiny.invoke.intrjumps.o}
    {$endif}
  {$elseif Defined(MACOS)}
    {$ifdef SMALLINT}
      {$L objs\mac32\tiny.invoke.o}
      {$L objs\mac32\tiny.invoke.intrjumps.o}
    {$else}
      {$L objs\mac64\tiny.invoke.o}
      {$L objs\mac64\tiny.invoke.intrjumps.o}
    {$endif}
  {$else .LINUX}
    {$ifdef SMALLINT}
      {$L objs\linux32\tiny.invoke.o}
      {$L objs\linux32\tiny.invoke.intrjumps.o}
    {$else}
      {$L objs\linux64\tiny.invoke.o}
      {$L objs\linux64\tiny.invoke.intrjumps.o}
    {$endif}
  {$ifend}
{$else}
const
  PLATFORM_NAME =
    {$if Defined(ANDROID)}
      'android'
    {$elseif Defined(IOS)}
      'ios'
    {$elseif Defined(MACOS)}
      'macos'
    {$elseif Defined(LINUX)}
      'linux'
    {$else}
      {$MESSAGE ERROR 'Unknown platform'}
    {$ifend}
     + {$ifdef SMALLINT}'32'{$else .LARGEINT}'64'{$endif};

  OBJ_PATH = 'objs\' + PLATFORM_NAME + '\';

  LIB_TINYINVOKE_PATH = OBJ_PATH + 'tiny.invoke.o';
  LIB_TINYINVOKEINTRJUMPS_PATH = OBJ_PATH + 'tiny.invoke.intrjumps.o';
{$ifend}

function get_invoke_func(const ACode: Integer{const ASignature: PRttiSignature}): TRttiInvokeFunc;
  external {$if not Defined(OBJLINKSUPPORT)}LIB_TINYINVOKE_PATH name 'get_invoke_func'{$ifend};
function get_intercept_func(const ACode: Integer{const ASignature: PRttiSignature}): TRttiInterceptFunc;
  external {$if not Defined(OBJLINKSUPPORT)}LIB_TINYINVOKE_PATH name 'get_intercept_func'{$ifend};
function get_intercept_jump(const AIndex, AMode: Integer): Pointer;
  {$ifdef OLDDELPHI}
    forward;
    {$I c\tiny.invoke.intr.jumps.olddelphi.inc}
  {$else}
    external {$if not Defined(OBJLINKSUPPORT)}LIB_TINYINVOKEINTRJUMPS_PATH name 'get_intercept_jump'{$ifend};
  {$endif}


{ TRttiArgument }

function TRttiArgument.GetIsValue: Boolean;
begin
  Result := Qualifier in [
    rqValue,
    rqUnsafeValue,
    rqWeakValue,
    rqValueRef,
    rqUnsafeValueRef,
    rqWeakValueRef,
    rqArrayValue];
end;

function TRttiArgument.GetIsConst: Boolean;
begin
  Result := Qualifier in [
    rqConst,
    rqConstRef,
    rqArrayConst];
end;

function TRttiArgument.GetIsVar: Boolean;
begin
  Result := Qualifier in [
    rqVar,
    rqUnsafeVar,
    rqWeakVar,
    rqArrayVar];
end;

function TRttiArgument.GetIsOut: Boolean;
begin
  Result := Qualifier in [
    rqOut,
    rqUnsafeOut,
    rqWeakOut,
    rqArrayOut];
end;

function TRttiArgument.GetIsUnsafe: Boolean;
begin
  Result := Qualifier in [
    rqUnsafeValue,
    rqUnsafeValueRef,
    rqUnsafeVar,
    rqUnsafeOut,
    rqArrayValue,
    rqArrayConst,
    rqArrayVar,
    rqArrayOut];
end;

function TRttiArgument.GetIsWeak: Boolean;
begin
  Result := Qualifier in [
    rqWeakValue,
    rqWeakValueRef,
    rqWeakVar,
    rqWeakOut];
end;

function TRttiArgument.GetIsArray: Boolean;
begin
  Result := Qualifier in [
    rqArrayValue,
    rqArrayConst,
    rqArrayVar,
    rqArrayOut];
end;

function TRttiArgument.GetIsReference: Boolean;
begin
  Result := Qualifier in [
    rqValueRef,
    rqUnsafeValueRef,
    rqWeakValueRef,
    rqConstRef,
    rqVar,
    rqUnsafeVar,
    rqWeakVar,
    rqOut,
    rqUnsafeOut,
    rqWeakOut,
    rqArrayValue,
    rqArrayConst,
    rqArrayVar,
    rqArrayOut];
end;

function TRttiArgument.GetTotalPointerDepth: Byte;
begin
  Result := PointerDepth + Byte(IsReference);
end;


{ TRttiSignatureUsage }

type
  TRttiSignatureUsage = object
    GeneralCount: Cardinal;
    Generals: array[0..High(TRttiGeneralRegisters)] of Boolean;
    ExtendedCount: Cardinal;
    Extendeds: array[0..{$ifdef CPUX86}0{$else}High(TRttiExtendedRegisters){$endif}] of Boolean;

    procedure InspectArgument(const AOffset: NativeInt; const AType: TRttiType; const ATotalPointerDepth: Integer); overload;
    procedure InspectArgument(const AArgument: PRttiArgument); overload;
    procedure Init(const ASignature: TRttiSignature);
  end;

procedure TRttiSignatureUsage.InspectArgument(const AOffset: NativeInt;
  const AType: TRttiType; const ATotalPointerDepth: Integer);
const
  GENERALS_LOW = 0{offset of TRttiRegisters.Generals};
  GENERALS_OVERFLOW = GENERALS_LOW + SizeOf(TRttiGeneralRegisters);
  {$ifNdef CPUX86}
  EXTENDEDS_LOW = GENERALS_OVERFLOW{offset of TRttiRegisters.Extendeds};
  EXTENDEDS_OVERFLOW = EXTENDEDS_LOW + SizeOf(TRttiExtendedRegisters);
  {$endif}
begin
  {$ifNdef CPUX86}
  if (ATotalPointerDepth = 0) then
  begin
    if (AOffset >= EXTENDEDS_LOW) and (AOffset < EXTENDEDS_OVERFLOW) then
    begin
      Extendeds[(AOffset - EXTENDEDS_LOW) div SizeOf(PRttiExtendedRegisters(nil)^[0])] := True;
      Inc(ExtendedCount);
      Exit;
    end;
  end;
  {$endif}

  if (AOffset >= GENERALS_LOW) and (AOffset < GENERALS_OVERFLOW) then
  begin
    Generals[(AOffset - GENERALS_LOW) div SizeOf(PRttiGeneralRegisters(nil)^[0])] := True;
    Inc(GeneralCount);
  end;
end;

procedure TRttiSignatureUsage.InspectArgument(const AArgument: PRttiArgument);
begin
  InspectArgument(AArgument.Offset, AArgument.BaseType, AArgument.PointerDepth{+ reference?});
end;

procedure TRttiSignatureUsage.Init(const ASignature: TRttiSignature);
var
  i: Integer;
begin
  FillChar(Self, SizeOf(Self), #0);

  InspectArgument(ASignature.DumpOptions.ThisOffset, rtPointer, 0);
  InspectArgument(ASignature.DumpOptions.ConstructorFlagOffset, rtBoolean8, 0);
  InspectArgument(@ASignature.Return);
  for i := 0 to ASignature.ArgumentCount - 1 do
  begin
    InspectArgument(@ASignature.Arguments[i]);
  end;
end;


{ TRttiSignature }

{$ifdef STATICSUPPORT}class{$endif} function TRttiSignature.GetUniversalInvokeFunc: TRttiInvokeFunc;
begin
  Result := get_invoke_func(-1);
end;

function TRttiSignature.GetOptimalInvokeFunc: TRttiInvokeFunc;
label
  code, done;
type
  TInternalResult = (
    {0}irNone,
    {1}irGeneral,
    {2}irSafeCall,
    {3}irFloat,
    {4}irDouble,
    {5}irFPU,
    {6}irFPUInt64,
    {7}irHFA,
    {8}irRetPtr
  );
  TInternalDecl = (
    {0}idGeneral,
    {1}idAlternative{CdeclX86/idMicrosoftX64}
  );
var
  {$ifdef CPUX64}
  i: Integer;
  {$endif}
  LCode: Integer;
  LStackCount: Cardinal;
  LUsage: TRttiSignatureUsage;
  LResult: TInternalResult;
  LDecl: TInternalDecl;
  LSignature: Integer;
begin
  LCode := -1;
  LStackCount := Cardinal(Self.DumpOptions.StackSize) shr {$ifdef SMALLINT}2{$else .LARGEINT}3{$endif};
  if (LStackCount > {$ifdef CPUX86}4{$else}0{$endif}) then
    goto done;

  // register usage
  LUsage.Init(Self);

  // result
  case Self.DumpOptions.ReturnStrategy of
    rsNone:
    begin
      LResult := irNone;
      {$ifdef CPUARM64}
      if (LGenerals[High(LGenerals)]) then
      begin
        LResult := irRetPtr;
        LGenerals[High(LGenerals)] := False;
        Dec(LGeneralCount);
      end;
      {$endif}
    end;
    rsGeneral, rsGeneralPair: LResult := irGeneral;
    rsSafeCall:
    begin
      LResult := irSafeCall;

      {$ifdef CPUX86}
      if (LStackCount <> 0) then
      begin
        LDecl := idGeneral;
        LSignature := 0;
        while (LStackCount <> 0) do
        begin
          LSignature := LSignature shl 2 + 1;
          Dec(LStackCount);
        end;
        goto code;
      end;
      {$endif}
    end;
    rsFPUInt64: LResult := irFPUInt64;
    rsFPU: LResult := irFPU;
    rsFloat1: LResult := irFloat;
    rsDouble1: LResult := irDouble;
  else
    LResult := irHFA;
  end;

  if (LUsage.GeneralCount + LUsage.ExtendedCount > 4) then
    goto done;

  // declaration
  LDecl := idGeneral;
  {$ifdef CPUX86}
  if (LStackCount <> 0) and
    (Self.CallConv in [rcCdecl, rcFastCall, rcThisCall, rcRegParm1, rcRegParm2, rcRegParm3]) then
  begin
    LDecl := idAlternative{idCdeclX86};
  end;
  {$endif}
  {$if Defined(CPUX64) and Defined(MSWINDOWS)}
  if (LUsage.GeneralCount <> 0) and (LUsage.ExtendedCount <> 0) then
  begin
    LDecl := idAlternative{idMicrosoftX64};
  end;
  {$ifend}
  {$if Defined(CPUX64) and Defined(POSIX)}
  if (Self.CallConv = rcMicrosoft) and (LUsage.GeneralCount <> 0) and (LUsage.ExtendedCount <> 0) then
  begin
    LDecl := idAlternative{idMicrosoftX64};
  end;
  {$ifend}

  // signature
  LSignature := 0;
  {$ifdef CPUX86}
    if (LStackCount = 0) then
    begin
      if (LUsage.Generals[0]) then LSignature := 1;
      if (LUsage.Generals[1]) then LSignature := 1 + (1 shl 2);
      if (LUsage.Generals[2]) then LSignature := 1 + (1 shl 2) + (1 shl 4);
    end else
    begin
      LSignature := 1 + (1 shl 2) + (1 shl 4);
    end;
  {$endif}
  {$ifdef CPUX64}
    {$ifdef POSIX}
    if (LDecl = idAlternative{idMicrosoftX64}) then
    {$endif}
    begin
      for i := 0 to Integer(LUsage.GeneralCount + LUsage.ExtendedCount) - 1 do
      begin
        LSignature := (LSignature shl 2) + 1;
      end;

      for i := Low(LUsage.Extendeds) to High(LUsage.Extendeds) do
      if (LUsage.Extendeds[i]) then
      begin
        LSignature := (LSignature and (not (3 shl (i * 2)))) + (2 shl (i * 2));
      end;
    end
    {$ifdef POSIX}
    else
    begin
      for i := 0 to Integer(LUsage.ExtendedCount) - 1 do
      begin
        LSignature := (LSignature shl 2) + 2;
      end;

      for i := 0 to Integer(LUsage.GeneralCount) - 1 do
      begin
        LSignature := (LSignature shl 2) + 1;
      end;
    end
    {$endif}
    ;
  {$endif}

  // code
code:
  LCode := LSignature + (Ord(LResult) shl 8) + (Ord(LDecl) shl 12) + (Integer(LStackCount) shl 16);

done:
  Result := get_invoke_func(LCode);
end;

procedure InterceptJumpOutOfRange;
begin
  {
    Note:
    The interception jump index must be in the range 0..1023
  }
  System.Error(reRangeError);
end;

function TRttiSignature.GetInterceptJump(const AIndex: Integer): Pointer;
var
  LMode: Integer;
begin
  LMode := 0;

  {$ifdef CPUX86}
  case CallConv of
    rcCdecl, rcPascal, rcStdCall, rcSafeCall, rcMWPascal:
    begin
      LMode := 1;
    end;
    rcFastCall, rcThisCall:
    begin
      LMode := 2;
    end;
  end;
  {$endif}

  {$if Defined(CPUX64) and not Defined(MSWINDOWS)}
  if (CallConv = rcMicrosoft) then
  begin
    LMode := 1;
  end;
  {$ifend}

  Result := get_intercept_jump(AIndex, LMode);
  if (not Assigned(Result)) then
  begin
    Result := @InterceptJumpOutOfRange;
  end;
end;

{$ifdef STATICSUPPORT}class{$endif} function TRttiSignature.GetUniversalInterceptFunc: TRttiInterceptFunc;
begin
  Result := get_intercept_func(-1);
end;

function TRttiSignature.GetOptimalInterceptFunc: TRttiInterceptFunc;
label
  code, done;
type
  TInternalResult = (
    {0}irNone,
    {1}irGeneral,
    {2}irDouble,
    {3}irFPU,
    {4}irFloat,
    {5}irFPUInt64,
    {6}irHFA,
    {7}irRetPtr
  );
var
  {$ifdef CPUX64}
  i: Integer;
  {$endif}
  LCode: Integer;
  LAdvancedCount: Cardinal;
  LUsage: TRttiSignatureUsage;
  LResult: TInternalResult;
  LSignature: Integer;
begin
  LCode := -1;
  {$ifdef CPUX86}
    LAdvancedCount := Self.DumpOptions.StackPopSize shr 2;
    if (LAdvancedCount > 8) then
      goto done;
  {$else}
    LAdvancedCount := 0;
  {$endif}

  // register usage
  LUsage.Init(Self);

  // result
  case Self.DumpOptions.ReturnStrategy of
    rsNone:
    begin
      LResult := irNone;
      {$ifdef CPUARM64}
      if (LGenerals[High(LGenerals)]) then
      begin
        LResult := irRetPtr;
        LGenerals[High(LGenerals)] := False;
        Dec(LGeneralCount);
      end;
      {$endif}
    end;
    rsGeneral, rsGeneralPair, rsSafeCall: LResult := irGeneral;
    rsFPUInt64: LResult := irFPUInt64;
    rsFPU: LResult := irFPU;
    rsFloat1: LResult := irFloat;
    rsDouble1: LResult := irDouble;
  else
    LResult := irHFA;
  end;

  if (LUsage.GeneralCount > 4) or (LUsage.ExtendedCount > 4) then
    goto done;

  // signature
  LSignature := 0;
  {$ifdef CPUX86}
    if (LUsage.Generals[0]) then LSignature := 1;
    if (LUsage.Generals[1]) then LSignature := 1 + (1 shl 2);
    if (LUsage.Generals[2]) or (LAdvancedCount <> 0) then LSignature := 1 + (1 shl 2) + (1 shl 4);
    if (LSignature = 1 + (1 shl 2)) then
    begin
      LSignature := 1;
    end;
  {$endif}
  {$ifdef CPUX64}
    if (LUsage.GeneralCount <> 0) and (LUsage.ExtendedCount <> 0) and
      (LUsage.GeneralCount + LUsage.ExtendedCount <= 4) {$ifdef POSIX}and (CallConv = rcMicrosoft){$endif} then
    begin
      for i := 0 to Integer(LUsage.GeneralCount + LUsage.ExtendedCount) - 1 do
      begin
        LSignature := (LSignature shl 2) + 1;
      end;

      for i := Low(LUsage.Extendeds) to High(LUsage.Extendeds) do
      if (LUsage.Extendeds[i]) then
      begin
        LSignature := (LSignature and (not (3 shl (i * 2)))) + (2 shl (i * 2));
      end;

      LAdvancedCount := 1;
    end
    {$ifdef POSIX}
    else
    begin
      for i := 0 to Integer(LUsage.ExtendedCount) - 1 do
      begin
        LSignature := (LSignature shl 2) + 2;
      end;

      for i := 0 to Integer(LUsage.GeneralCount) - 1 do
      begin
        LSignature := (LSignature shl 2) + 1;
      end;
    end
    {$endif}
    ;
  {$endif}

  // code
code:
  LCode := LSignature + (Integer(LAdvancedCount) shl 16) + (Ord(LResult) shl 20);

done:
  Result := get_intercept_func(LCode);
end;

{$ifdef STATICSUPPORT}class{$endif} function TRttiSignature.InitArgument(
  var ATarget: TRttiArgument; const ASource: TParamData;
  const AFlags: TParamFlags; const AContext: PRttiContext): Boolean;
type
  TInternalQualifier = (iqValue, iqConst, iqVar, iqOut);
var
  LQualifier: TInternalQualifier;
  LRulesBuffer: TRttiTypeRules;
begin
  Result := AContext.GetExType(ASource.TypeInfo, ASource.TypeName,
    PRttiExType(@ATarget)^);
  if (not Result) then
    Exit;

  ATarget.Name := ASource.Name;
  {$ifdef CPUX86}
  if (pfResult in AFlags) and Assigned(AContext) and (AContext.ExpandReturnFPU) and
    (ATarget.PointerDepth = 0) and (ATarget.BaseType in [rtFloat, rtDouble]) then
  begin
    ATarget.BaseType := rtLongDouble80;
  end;
  {$endif}

  if (pfConst in AFlags) then
  begin
    LQualifier := iqConst;
  end else
  if (pfVar in AFlags) then
  begin
    LQualifier := iqVar;
  end else
  if (pfOut in AFlags) then
  begin
    LQualifier := iqOut;
  end else
  begin
    LQualifier := iqValue;
  end;

  if (pfArray in AFlags) then
  begin
    ATarget.Qualifier := TRttiArgumentQualifier(Ord(rqArrayValue) + Ord(LQualifier));
  end else
  if (pfReference in AFlags) then
  begin
    case LQualifier of
      iqConst:
      begin
        ATarget.Qualifier := rqConstRef;
      end;
      iqVar:
      begin
        ATarget.Qualifier := rqVar;
      end;
      iqOut:
      begin
        ATarget.Qualifier := rqOut;
      end
    else
      // iqValue
      ATarget.Qualifier := rqValueRef;
    end;
  end else
  if (pfConst in AFlags) then
  begin
    ATarget.Qualifier := rqConst;
  end else
  begin
    ATarget.Qualifier := rqValue;
  end;

  if (ASource.Reference <> rfDefault) and
    (ATarget.Qualifier in [rqValue, rqValueRef, rqVar, rqOut]) and
    (tfWeak in ATarget.GetRules(LRulesBuffer).Flags) then
  begin
    Inc(Byte(ATarget.Qualifier), Byte(ASource.Reference));
  end;
end;

procedure TRttiSignature.InitDump(const AHasSelf, AConstructor: Boolean);
label
  put_arg_stack;
type
  TReturnArgMode = (ramNone, ramRegister, ramRefFirst, ramRefLast);
  TThisArgMode = (tamNone, tamFirst, tamSecond, tamLast);
var
  i: Integer;
  LNullDump: PRttiInvokeDump;
  LIsBackwardArg: Boolean;
  LReturnArgMode: TReturnArgMode;
  LThisArgMode: TThisArgMode;
  LRulesBuffer: TRttiTypeRules;
  LRules: PRttiTypeRules;
  LRegGen, LRegGenCount: Integer;
  {$ifNdef CPUX86}
  LRegExt, LRegExtCount: Integer;
  {$endif}
  {$ifdef CPUARM32}
  LRegHalfExt, LRegHalfExtCount: Integer;
  {$endif}
  LArgument: PRttiArgument;
  LCount: Integer;

  function AllocRegGen(const ACount: Integer = 1): Integer;
  var
    LIndex: Integer;
  begin
    Result := INVALID_INDEX;
    if (LRegGen + ACount <= LRegGenCount) then
    begin
      LIndex := LRegGen;
      Inc(LRegGen, ACount);
      {$ifdef CPUX64}
        {$ifdef POSIX}
        if (CallConv = rcMicrosoft) then
        {$endif}
          LRegExt := LRegGen;
      {$endif}

      {$ifdef CPUX86}
      if (CallConv in [rcFastCall, rcThisCall]) then
      case LIndex of
        0{ecx}: LIndex := 2;
        1{edx}: LIndex := 1;
      end;
      {$endif}
      {$ifdef POSIXINTEL64}
      if (CallConv = rcMicrosoft) then
      case LIndex of
        0{rcx}: LIndex := 3;
        1{rdx}: LIndex := 2;
        2{r8}: LIndex := 4;
        3{r9}: LIndex := 5;
      end;
      {$endif}

      Result := NativeInt(@LNullDump.Generals[LIndex]);
    end;
  end;

  {$ifdef CPUARM32}
  function AllocRegHalfExt: Integer;
  var
    LIndex: Integer;
  begin
    Result := INVALID_INDEX;
    if (LRegHalfExt + 1 <= LRegHalfExtCount) then
    begin
      LIndex := LRegHalfExt;

      if (LIndex and 1 = 0) then
      begin
        Inc(LRegHalfExt);
        LRegExt := (LRegHalfExt + 1) shr 1;
      end else
      begin
        LRegHalfExt := LRegExt * 2;
      end;

      Result := NativeInt(@LNullDump.Registers.HalfExtendeds[LIndex]);
    end;
  end;
  {$endif}

  {$ifNdef CPUX86}
  function AllocRegExt(const ACount: Integer = 1): Integer;
  var
    LIndex: Integer;
  begin
    Result := INVALID_INDEX;
    if (LRegExt + ACount <= LRegExtCount) then
    begin
      LIndex := LRegExt;
      Inc(LRegExt, ACount);
      {$ifdef CPUX64}
        {$ifdef POSIX}
        if (CallConv = rcMicrosoft) then
        {$endif}
          LRegGen := LRegExt;
      {$endif}
      {$ifdef CPUARM32}
      if (LRegHalfExt and 1 = 0) then
      begin
        LRegHalfExt := LRegExt * 2;
      end;
      {$endif}

      Result := NativeInt(@LNullDump.Extendeds[LIndex]);
    end;
  end;
  {$endif}

  function PutStack(const ASize: Integer): Integer;
  var
    LSize: Integer;
  begin
    LSize := (ASize + SizeOf(Pointer) - 1) and (-SizeOf(Pointer));

    if (LIsBackwardArg) then
    begin
      Result := NativeInt(@LNullDump.Stack) + DumpOptions.StackSize;
      Inc(DumpOptions.StackSize, LSize);
    end else
    begin
      Inc(DumpOptions.StackSize, LSize);
      Result := -DumpOptions.StackSize;
    end;
  end;

  function PutGen: Integer;
  begin
    if (LRegGen < LRegGenCount) then
    begin
      Result := AllocRegGen;
    end else
    begin
      Result := PutStack(SizeOf(NativeInt));
    end;
  end;

  function PutHigh(const AArgOffset: Integer): ShortInt;
  var
    LOffset: Integer;
  begin
    LOffset := PutGen;

    if (AArgOffset >= 0) and (LOffset < 0) then
    begin
      Result := LOffset div SizeOf(NativeInt);
    end else
    begin
      Result := (LOffset - AArgOffset) div SizeOf(NativeInt);
    end;
  end;

  procedure FillThis;
  begin
    DumpOptions.ThisOffset := PutGen;
  end;

  procedure FillReturn;
  begin
    if (LReturnArgMode = ramRegister) then
    begin
      Return.Offset := NativeInt(@LNullDump.OutBytes);
    end else
    {$ifdef CPUARM64}
    if (LReturnArgMode = ramRefFirst) then
    begin
      Return.Offset := NativeInt(@LNullDump.Registers.RegX8);
    end else
    {$endif}
    begin
      Return.Offset := PutGen;
    end;
  end;

  function ApplyOffset(var AValue: Integer): Integer;
  begin
    Result := AValue;
    if (Result < 0) and (Result <> INVALID_INDEX) then
    begin
      Inc(Result, NativeInt(@LNullDump.Stack) + DumpOptions.StackSize);
      AValue := Result;
    end;
  end;

  procedure ApplyArgumentOffsets(var AArgument: TRttiArgument);
  var
    LOffset: Integer;
  begin
    if (AArgument.Offset >= 0) and (AArgument.HighOffset < 0) then
    begin
      LOffset := AArgument.HighOffset * SizeOf(NativeInt);
      ApplyOffset(LOffset);
      AArgument.HighOffset := (LOffset - AArgument.Offset) div SizeOf(NativeInt);
    end else
    if (AArgument.Offset < 0) then
    begin
      ApplyOffset(AArgument.Offset);
    end;
  end;
begin
  // initialization
  PCardinal(@DumpOptions.ReturnStrategy)^ := 0;
  DumpOptions.ThisOffset := INVALID_INDEX;
  DumpOptions.ConstructorFlagOffset := INVALID_INDEX;
  DumpOptions.StackSize := 0;

  // options
  LNullDump := nil;
  LIsBackwardArg := {$ifdef CPUX86}False{$else}True{$endif};
  {$ifdef CPUX86}
  case CallConv of
    rcCdecl,
    rcStdCall,
    rcSafeCall,
    rcFastCall,
    rcThisCall,
    rcRegParm1,
    rcRegParm2,
    rcRegParm3,
    rcStdCallRegParm1,
    rcStdCallRegParm2,
    rcStdCallRegParm3: LIsBackwardArg := True;
  end;
  {$endif}

  // return argument, return strategy
  if (Return.BaseType = rtUnknown) then
  begin
    LReturnArgMode := ramNone;
    Return.Offset := INVALID_INDEX;
    PCardinal(@Return.Qualifier)^ := 0;
  end else
  begin
    LReturnArgMode := ramRegister;
    DumpOptions.ReturnStrategy := rsGeneral;
    LRules := Return.GetRules(LRulesBuffer);

    if (CallConv = rcSafeCall) then
    begin
      LReturnArgMode := ramRefLast;
      DumpOptions.ReturnStrategy := rsSafeCall;
    end else
    if (LRules.Return = trReference) then
    begin
      if (Return.Qualifier <> rqUnsafeValue) then
      begin
        LReturnArgMode := {$ifdef CPUX86}ramRefLast{$else}ramRefFirst{$endif};
        DumpOptions.ReturnStrategy := rsNone;
      end;
    end else
    case (LRules.Return) of
      trGeneralPair: DumpOptions.ReturnStrategy := rsGeneralPair;
      trFPUInt64: DumpOptions.ReturnStrategy := rsFPUInt64;
      trFPU: DumpOptions.ReturnStrategy := rsFPU;
      trFloat1, trDouble1, trFloat2, trDouble2, trFloat3, trDouble3, trFloat4, trDouble4:
      begin
        DumpOptions.ReturnStrategy := TRttiReturnStrategy(Ord(LRules.Return) - Ord(trFloat1) + Ord(rsFloat1));
      end;
    end;
  end;

  // this argument mode
  LThisArgMode := tamNone;
  if (AHasSelf) then
  begin
    {$ifdef CPUX86}
    if (CallConv = rcPascal) then
    begin
      LThisArgMode := tamLast;
    end else
    {$endif}
    begin
      LThisArgMode := tamFirst;

      {$if Defined(CPUARM)}
      if (LReturnArgMode = ramRefFirst) then
      begin
        LThisArgMode := tamSecond;
      end;
      {$ifend}
    end;
  end;

  // registers
  LRegGen := 0;
  LRegGenCount := High(TRttiGeneralRegisters) + 1 {$ifdef CPUARM64}- 1{$endif};
  {$ifNdef CPUX86}
  LRegExt := 0;
  LRegExtCount := {$ifdef ARM_NO_VFP_USE}0{$else}High(TRttiExtendedRegisters) + 1{$endif};
  {$endif}
  {$ifdef CPUARM32}
  LRegHalfExt := 0;
  LRegHalfExtCount := LRegExtCount * 2;
  {$endif}
  {$ifdef CPUX86}
  case CallConv of
    rcCdecl, rcPascal, rcStdCall, rcSafeCall: LRegGenCount := 0;
    rcFastCall: LRegGenCount := 2{ecx/edx};
    rcThisCall: LRegGenCount := 1{ecx};
    rcRegParm1, rcStdCallRegParm1: LRegGenCount := 1{eax};
    rcRegParm2, rcStdCallRegParm2: LRegGenCount := 2{eax/edx};
    rcRegParm3, rcStdCallRegParm3: LRegGenCount := 3{default eax/edx/ecx};
  end;
  {$endif}
  {$ifdef POSIXINTEL64}
  if (CallConv = rcMicrosoft) then
  begin
    LRegGenCount := 4;
    LRegExtCount := 4;
  end;
  {$endif}
  {$ifdef CPUARM32}
  if (CallConv = rcSoftFloat) then
  begin
    LRegExtCount := 0;
  end;
  {$endif}

  // this, first return
  if (LThisArgMode = tamFirst) then FillThis;
  if (LReturnArgMode = ramRefFirst) then FillReturn;
  if (LThisArgMode = tamSecond) then FillThis;

  // constructor flag
  if (AConstructor) and (Return.BaseType = rtObject) and (Return.PointerDepth = 0) then
  begin
    DumpOptions.ConstructorFlagOffset := PutGen;
  end;

  // arguments
  for i := 0 to ArgumentCount - 1 do
  begin
    LArgument := @Arguments[i];
    LRules := LArgument.GetRules(LRulesBuffer);

    if (LArgument.TotalPointerDepth <> 0) then
    begin
      LArgument.Offset := PutGen;
    end else
    {$if not Defined(CPUX86) and not Defined(ARM_NO_VFP_USE)}
    if (LRules.IsExtendedArg) {$ifdef CPUARM32}and (CallConv <> rcSoftFloat){$endif} then
    begin
      case LRules.Return of
        trFloat1:
        begin
          LArgument.Offset := {$ifdef CPUARM32}AllocRegHalfExt{$else}AllocRegExt{$endif};
        end;
        trDouble1:
        begin
          LArgument.Offset := AllocRegExt;
        end;
        {$ifdef HFASUPPORT}
        trFloat2, trDouble2, trFloat3, trDouble3, trFloat4, trDouble4:
        begin
          LCount := (Ord(LRules.Return) - Ord(trFloat1)) shr 1 + 1;
          {$ifdef POSIXINTEL64}
          if ((Ord(LRules.Return) - Ord(trFloat1)) and 1 = 0) then
          begin
            LCount := (LCount + 1) shr 1;
          end;
          {$endif}

          if (LRegExt + LCount <= LRegExtCount) then
          begin
            LArgument.Offset := AllocRegExt(LCount);
          end else
          begin
            {$ifdef CPUARM}
            LRegExt := LRegExtCount;
            {$endif}

            goto put_arg_stack;
          end;
        end;
        {$endif}
      else
        goto put_arg_stack;
      end;

      if (LArgument.Offset = INVALID_INDEX) then
        goto put_arg_stack;
    end else
    {$ifend}
    if (LRules.IsGeneralArg) then
    begin
      LCount := (LRules.Size + (SizeOf(NativeInt) - 1)) shr {$ifdef LARGEINT}3{$else}2{$endif};

      {$ifdef CPUARM32}
      if (LCount = 2) and (LRegGen and 1 <> 0) then
      begin
        Inc(LRegGen);
      end;
      {$endif}

      if (LRegGen + LCount <= LRegGenCount) then
      begin
        LArgument.Offset := AllocRegGen(LCount);
      end else
      begin
        {$ifdef CPUARM}
        LRegGen := LRegGenCount;
        {$endif}

        goto put_arg_stack;
      end;
    end else
    begin
    put_arg_stack:
      LArgument.Offset := PutStack(LRules.StackSize);
    end;

    if (LArgument.IsArray) or
     ((LArgument.IsVar) and (tfVarHigh in LRules.Flags)) then
    begin
      LArgument.HighOffset := PutHigh(LArgument.Offset);
    end;
  end;

  // last return/this
  if (LReturnArgMode = ramRefLast) then FillReturn;
  if (LThisArgMode = tamLast) then FillThis;
  if (LReturnArgMode = ramRegister) then FillReturn;

  // stack offsets
  if (not LIsBackwardArg) and (DumpOptions.StackSize <> 0) then
  begin
    ApplyOffset(DumpOptions.ThisOffset);
    ApplyOffset(DumpOptions.ConstructorFlagOffset);

    if (LReturnArgMode <> ramNone) then
    begin
      ApplyArgumentOffsets(Return);
    end;

    for i := 0 to ArgumentCount - 1 do
    begin
      ApplyArgumentOffsets(Arguments[i]);
    end;
  end;

  // stack pop size
  {$ifdef CPUX86}
  case CallConv of
    rcCdecl, rcFastCall, rcThisCall, rcRegParm1, rcRegParm2, rcRegParm3:
    begin
      DumpOptions.StackPopSize := 0;
    end;
  else
    DumpOptions.StackPopSize := DumpOptions.StackSize;
  end;
  {$endif}
end;

function TRttiSignature.Init(const ASignatureData: TSignatureData; const AContext: PRttiContext): Boolean;
var
  i: Integer;
  LContext: PRttiContext;
  LTarget: PRttiArgument;
  LSource: PArgumentData;
begin
  // context
  LContext := AContext;
  if (not Assigned(LContext)) then
  begin
    LContext := @DefaultContext;
  end;

  // calling convension
  CallConv := rcRegister;
  case ASignatureData.CallConv of
    ccReg: ;
    ccCdecl: {$ifdef CPUX86}CallConv := rcCdecl{$endif};
    ccPascal: {$ifdef CPUX86}CallConv := rcPascal{$endif};
    ccStdCall: {$ifdef CPUX86}CallConv := rcStdCall{$endif};
    ccSafeCall: CallConv := rcSafeCall;
    {$ifdef FPC}
    ccCppdecl: {$ifdef CPUX86}CallConv := rcThisCall{$endif};
    ccMWPascal: {$ifdef CPUX86}CallConv := rcMWPascal{$endif};
    ccSoftFloat: {$ifdef CPUARM32}CallConv := rcSoftFloat{$endif};
    ccFar16,
    ccOldFPCCall,
    ccInternProc,
    ccSysCall: ;
    {$endif}
  else
    System.Error(reInvalidCast);
  end;

  // arguments
  Result := False;
  begin
    ArgumentCount := ASignatureData.ArgumentCount;
    if (ArgumentCount < Low(Byte)) or (ArgumentCount > High(Byte)) then
    begin
      System.Error(reRangeError);
    end;

    if (ASignatureData.Result.Assigned) then
    begin
      if (not InitArgument(Return, ASignatureData.Result, [pfResult], LContext)) then
        Exit;
    end else
    begin
      FillChar(Return, SizeOf(Return), #0);
    end;

    LTarget := @Arguments[0];
    LSource := @ASignatureData.Arguments[0];
    for i := 0 to ArgumentCount - 1 do
    begin
      if (not InitArgument(LTarget^, LSource^, LSource.Flags, LContext)) then
        Exit;

      Inc(LTarget);
      Inc(LSource);
    end;
  end;

  // dump
  InitDump(ASignatureData.HasSelf, ASignatureData.MethodKind = mkConstructor);
end;

function TRttiSignature.Init(const AMethodSignature: TMethodSignature; const AContext: PRttiContext): Boolean;
var
  LSignatureData: TSignatureData;
begin
  Result := (AMethodSignature.GetData(LSignatureData) >= 0) and
    Init(LSignatureData, AContext);
end;

function TRttiSignature.Init(const AIntfMethodSignature: TIntfMethodSignature; const AContext: PRttiContext): Boolean;
var
  LSignatureData: TSignatureData;
begin
  Result := (AIntfMethodSignature.GetData(LSignatureData) >= 0) and
    Init(LSignatureData, AContext);
end;

{$if Defined(FPC) or Defined(EXTENDEDRTTI)}
function TRttiSignature.Init(const AProcedureSignature: TProcedureSignature; const AContext: PRttiContext; const AAttrData: Pointer): Boolean;
var
  LSignatureData: TSignatureData;
begin
  Result := (AProcedureSignature.GetData(LSignatureData, AAttrData) >= 0) and
    Init(LSignatureData, AContext);
end;
{$ifend}

{$if Defined(EXTENDEDRTTI)}
function TRttiSignature.Init(const AMethodExEntry: TVmtMethodExEntry; const AContext: PRttiContext): Boolean;
var
  LSignatureData: TSignatureData;
begin
  Result := (AMethodExEntry.GetData(LSignatureData) >= 0) and
    Init(LSignatureData, AContext);
end;

function TRttiSignature.Init(const ARecordTypeMethod: TRecordTypeMethod; const AContext: PRttiContext): Boolean;
var
  LSignatureData: TSignatureData;
begin
  Result := (ARecordTypeMethod.GetData(LSignatureData) >= 0) and
    Init(LSignatureData, AContext);
end;
{$ifend}

function TRttiSignature.Init(const ATypeInfo: PTypeInfo; const AContext: PRttiContext): Boolean;
var
  LTypeData: PTypeData;
  {$ifdef EXTENDEDRTTI}
  LMethodTable: PIntfMethodTable;
  {$endif}
begin
  LTypeData := ATypeInfo.TypeData;
  case ATypeInfo.Kind of
    tkMethod:
    begin
      Result := Init(LTypeData.MethodSignature, AContext);
    end;
    {$if Defined(FPC) or Defined(EXTENDEDRTTI)}
    tkProcedure:
    begin
      Result := Init(LTypeData.ProcSig{$ifNdef FPC}^{$endif}, AContext
        {$ifNdef FPC}, @LTypeData.ProcAttrData{$endif});
    end;
    {$ifend}
    {$if Defined(EXTENDEDRTTI)}
    tkInterface:
    begin
      Result := IsClosureTypeData(LTypeData);
      if (Result) then
      begin
        LMethodTable := LTypeData.InterfaceData.MethodTable;
        Result := (LMethodTable.RttiCount <> $ffff) and
          (Init(LMethodTable.Entries.Signature^, AContext));
      end;
    end;
    {$ifend}
  else
    Result := False;
  end;
end;


{ TRttiVirtualInterface }

procedure TRttiVirtualInterface.DoCallback(const AMethod: TRttiVirtualMethod;
  var ADump: TRttiInvokeDump);
begin
  if (Assigned(FDefaultCallback)) then
    FDefaultCallback(AMethod, ADump);
end;

procedure TRttiVirtualInterface.SetDefaultCallback(const AValue: TRttiVirtualMethodDefaultCallback);
begin
  FDefaultCallback := AValue;
  FInternalDefaultCallback := DoCallback;

  if (TMethod(FInternalDefaultCallback).Code = @TRttiVirtualInterface.DoCallback) and
    Assigned(AValue) then
  begin
    {$ifdef EXTENDEDRTTI}
      TMethod(FInternalDefaultCallback).Data := Pointer(@AValue);
      TMethod(FInternalDefaultCallback).Code := PPointer(PNativeUInt(TMethod(FInternalDefaultCallback).Data)^ + 3 * SizeOf(Pointer))^;
    {$else}
      FInternalDefaultCallback := AValue;
    {$endif}
  end;
end;

constructor TRttiVirtualInterface.CreateDirect(const AGuids: TGuidDynArray;
  const AMethods: TRttiVirtualMethodDataDynArray);
var
  i, LCount: Integer;
begin
  inherited Create;

  FGuids := AGuids;
  FTable.Methods := AMethods;
  LCount := Length(AMethods);
  SetLength(FTable.VMT, 3 + LCount);
  for i := 0 to LCount - 1 do
  begin
    FTable.VMT[3 + i] := TRttiSignature(nil^).InterceptJumps[i];
  end;


end;

constructor TRttiVirtualInterface.Create(const AIntfType: PTypeInfo;
  const ADefaultCallback: TRttiVirtualMethodDefaultCallback;
  const AContext: PRttiContext;
  const AConfigureProc: TRttiVirtualInterfaceConfigureProc);
var
  LGuids: TGuidDynArray;
  LMethods: TRttiVirtualMethodDataDynArray;
 // LContext: PRttiContext;
 // LTypeData: PTypeData;
begin
  if (NativeUInt(AIntfType) <= $ffff) then
  begin
    System.Error(reAccessViolation);
  end;

 // LContext := AContext;
  if (not Assigned(AContext)) then
  begin
 //   LContext := @DefaultContext;
  end;
  SetDefaultCallback(ADefaultCallback);

  case AIntfType.Kind of
    tkInterface:
    begin
    //  LTypeData := AIntfType.TypeData;
  //    LTypeData.InterfaceData.
    end;
    tkMethod:
    begin
  //    LTypeData := AIntfType.TypeData;
    end;
  else
    // ToDo?
  end;

  if (Assigned(AConfigureProc)) then
  begin
    AConfigureProc(LGuids, LMethods);
  end;

  CreateDirect(LGuids, LMethods);
end;




end.
