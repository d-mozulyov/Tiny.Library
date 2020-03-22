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
  {$ifdef MSWINDOWS}
    {$ifdef UNITSCOPENAMES}Winapi.Windows{$else}Windows{$endif},
  {$endif}
  Tiny.Rtti;


type

{ TRttiRegisters record
  List of used registers when calling functions }

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


{ TRttiInvokeDump record
  Dump of registers, stack and return address }

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


{ TRttiArgument object
  Signature argument description }

  PRttiArgumentQualifier = ^TRttiArgumentQualifier;
  TRttiArgumentQualifier = (
    // array
    rqArrayValue,
    rqArrayConst,
    rqArrayVar,
    rqArrayOut,
    // value
    rqValue,
    rqUnsafeValue,
    rqWeakValue,
    rqConstValue,
    // reference
    rqValueRef,
    rqUnsafeValueRef,
    rqWeakValueRef,
    rqConstRef,
    rqVar,
    rqUnsafeVar,
    rqWeakVar,
    rqOut,
    rqUnsafeOut,
    rqWeakOut
  );
  PRttiArgumentQualifiers = ^TRttiArgumentQualifiers;
  TRttiArgumentQualifiers = set of TRttiArgumentQualifier;

  PRttiArgument = ^TRttiArgument;
  {$A1}
  TRttiArgument = object(TRttiExType)
  protected
    function GetIsArray: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsValue: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsConst: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsVar: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsOut: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsUnsafe: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsWeak: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsReference: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTotalPointerDepth: Byte; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Name: PShortStringHelper;
    Offset: Integer;
    Qualifier: TRttiArgumentQualifier;
    GetterFunc: Byte;
    SetterFunc: Byte;
    HighOffset: ShortInt;

    procedure SetValue(const ADump: PRttiInvokeDump; const ASource: Pointer); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure GetValue(const ADump: PRttiInvokeDump; const ATarget: Pointer); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetValue(const ADump: PRttiInvokeDump): Pointer; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    property IsArray: Boolean read GetIsArray;
    property IsValue: Boolean read GetIsValue;
    property IsConst: Boolean read GetIsConst;
    property IsVar: Boolean read GetIsVar;
    property IsOut: Boolean read GetIsOut;
    property IsUnsafe: Boolean read GetIsUnsafe;
    property IsWeak: Boolean read GetIsWeak;
    property IsReference: Boolean read GetIsReference;
    property TotalPointerDepth: Byte read GetTotalPointerDepth;
  end;
  {$A4}


{ TRttiSignature object
  List of arguments, rules for their use, additional invoke/intercept parameters }

  PRttiReturnStrategy = ^TRttiReturnStrategy;
  TRttiReturnStrategy = (rsNone, rsGeneral, rsGeneralPair, rsSafeCall, rsFPUInt64, rsFPU,
    rsFloat1, rsDouble1, rsFloat2, rsDouble2, rsFloat3, rsDouble3, rsFloat4, rsDouble4);
  PRttiReturnStrategies = ^TRttiReturnStrategies;
  TRttiReturnStrategies = set of TRttiReturnStrategy;

  PRttiSignature = ^TRttiSignature;
  PRttiInvokeFunc = ^TRttiInvokeFunc;
  TRttiInvokeFunc = procedure(const ASignature: PRttiSignature; const ACodeAddress: Pointer; const ADump: PRttiInvokeDump);
  PRttiInterceptFunc = ^TRttiInterceptFunc;
  TRttiInterceptFunc = type Pointer;
  {$A1}
  TRttiSignature = object(TRttiCustomTypeData)
  protected
    function GetSize: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDumpSize: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
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

    procedure Invoke(var ADump: TRttiInvokeDump;
      const ACodeAddress, AInstance: Pointer; const AArgs: array of const;
      const AResult: Pointer = nil; const AInvokeFunc: TRttiInvokeFunc = nil); overload;
    function Invoke(var ADump: TRttiInvokeDump;
      const ACodeAddress, AInstance: Pointer; const AArgs: array of TValue;
      const AInvokeFunc: TRttiInvokeFunc = nil): TValue; overload;

    property Size: Integer read GetSize;
    property DumpSize: Integer read GetDumpSize;
    {$ifdef STATICSUPPORT}class{$endif} property UniversalInvokeFunc: TRttiInvokeFunc read GetUniversalInvokeFunc;
    property OptimalInvokeFunc: TRttiInvokeFunc read GetOptimalInvokeFunc;
    property InterceptJumps[const AIndex: Integer]: Pointer read GetInterceptJump;
    {$ifdef STATICSUPPORT}class{$endif} property UniversalInterceptFunc: TRttiInterceptFunc read GetUniversalInterceptFunc;
    property OptimalInterceptFunc: TRttiInterceptFunc read GetOptimalInterceptFunc;
  end;
  {$A4}


{ TRttiMethod object
  Universal method description }

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

  PRttiMethod = ^TRttiMethod;
  {$A1}
  TRttiMethod = object(TRttiCustomTypeData)
  protected
  public
    Name: PShortStringHelper;
    Kind: TRttiMethodKind;
    Address: Pointer;
    Signature: PRttiSignature;
  end;
  {$A4}


{ TRttiVirtualInterface class
  Implementation of a virtual interface allows you to intercept and process any interface method
  Unlike the System.Rtti implementation, in addition to the default callback,
  it is possible to specify the callback and context for any method (AInvokeConfigure closure) }

  PRttiVirtualMethod = ^TRttiVirtualMethod;
  {$A1}
  TRttiVirtualMethod = object
  public
    Name: PShortStringHelper;
    Index: NativeInt;
    Signature: PRttiSignature;
  protected
    FContext: Pointer;
  public
    property Context: Pointer read FContext write FContext;
  end;
  {$A4}

  PRttiVirtualMethodCallback = ^TRttiVirtualMethodCallback;
  TRttiVirtualMethodCallback = procedure(const AMethod: TRttiVirtualMethod; var ADump: TRttiInvokeDump) of object;

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
  TRttiVirtualMethodInvokeCallback = reference to procedure(const AMethod: TRttiVirtualMethod; var ADump: TRttiInvokeDump);
  TRttiVirtualMethodInvokeEvent = reference to function(const AMethod: TRttiVirtualMethod; const AArgs: TValueDynArray; const AReturnAddress: Pointer): TValue;
  TRttiVirtualInterfaceInvokeConfigure = reference to procedure(var AGuids: TGuidDynArray; var AMethods: TRttiVirtualMethodDataDynArray);
  {$else}
  TRttiVirtualMethodInvokeCallback = TRttiVirtualMethodCallback;
  TRttiVirtualMethodInvokeEvent = function(const AMethod: TRttiVirtualMethod; const AArgs: TValueDynArray; const AReturnAddress: Pointer): TValue of object;
  TRttiVirtualInterfaceInvokeConfigure = procedure(var AGuids: TGuidDynArray; var AMethods: TRttiVirtualMethodDataDynArray) of object;
  {$endif}

  PRttiVirtualInterfaceTable = ^TRttiVirtualInterfaceTable;
  TRttiVirtualInterfaceTable = packed record
    StdAddresses: array[0..2] of Pointer;
    Methods: TRttiVirtualMethodDataDynArray;
    Vmt: {$ifdef SYSARRAYSUPPORT}TArray<Pointer>{$else}array of Pointer{$endif};
  end;

  TRttiVirtualInterface = class(TInterfacedObject)
  protected
    FGuids: TGuidDynArray;
    FTable: TRttiVirtualInterfaceTable;
    FHeapItems: Pointer;
    {$ifdef WEAKINSTREF}[Unsafe]{$endif} FDefaultCallback: TRttiVirtualMethodCallback;
    FDefaultInvokeCallback: TRttiVirtualMethodInvokeCallback;
    FDefaultInvokeEvent: TRttiVirtualMethodInvokeEvent;

    procedure DoCallback(const AMethod: TRttiVirtualMethod; var ADump: TRttiInvokeDump); virtual;
    procedure DoErrorCallback(const AMethod: TRttiVirtualMethod; var ADump: TRttiInvokeDump); virtual;
    class procedure DoErrorMethodIndex; {static;} virtual;
    function InternalGetCallback(const AValue: TRttiVirtualMethodInvokeCallback): TRttiVirtualMethodCallback; {$ifdef WEAKINSTREF}unsafe;{$endif}
    function InternalHeapAlloc(const ASize: Integer): Pointer;
    function InternalCopySignature(const ASignature: TRttiSignature): PRttiSignature;
    procedure InternalEventCallback(const AMethod: TRttiVirtualMethod; var ADump: TRttiInvokeDump);
  protected
    function Std_AddRef: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
    function Std_Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
    function Std_QueryInterface({$ifdef FPC}constref{$else}const{$endif} IID: TGUID; out Obj): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult; stdcall{$else}Longint; cdecl{$ifend};
    function Vmt_AddRef: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
    function Vmt_Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
    function Vmt_QueryInterface({$ifdef FPC}constref{$else}const{$endif} IID: TGUID; out Obj): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult; stdcall{$else}Longint; cdecl{$ifend};
  public
    function _AddRef: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; virtual; stdcall{$else}Longint; virtual; cdecl{$ifend};
    function _Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; virtual; stdcall{$else}Longint; virtual; cdecl{$ifend};
    function QueryInterface({$ifdef FPC}constref{$else}const{$endif} IID: TGUID; out Obj): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult; virtual; stdcall{$else}Longint; virtual; cdecl{$ifend};
  public
    constructor CreateDirect(const AGuids: TGuidDynArray; const AMethods: TRttiVirtualMethodDataDynArray); overload; virtual;
    constructor CreateDirect(const AIntfType: PTypeInfo;
      const ADefaultCallback: TRttiVirtualMethodCallback;
      const ARttiContext: PRttiContext = nil;
      const AInvokeConfigure: TRttiVirtualInterfaceInvokeConfigure = nil); overload;
    {$ifdef EXTENDEDRTTI}
    constructor CreateDirect(const AIntfType: PTypeInfo;
      const ADefaultInvokeCallback: TRttiVirtualMethodInvokeCallback;
      const ARttiContext: PRttiContext = nil;
      const AInvokeConfigure: TRttiVirtualInterfaceInvokeConfigure = nil); overload;
    {$endif}
    constructor Create(const AIntfType: PTypeInfo;
      const ADefaultInvokeEvent: TRttiVirtualMethodInvokeEvent;
      const ARttiContext: PRttiContext = nil;
      const AInvokeConfigure: TRttiVirtualInterfaceInvokeConfigure = nil);
    destructor Destroy; override;

    function GetCallback(const AInvokeCallback: TRttiVirtualMethodInvokeCallback): TRttiVirtualMethodCallback; overload; {$ifdef WEAKINSTREF}unsafe;{$endif}
    function GetCallback(var AInvokeEvent: TRttiVirtualMethodInvokeEvent): TRttiVirtualMethodCallback; overload; {$ifdef WEAKINSTREF}unsafe;{$endif}

    property Guids: TGuidDynArray read FGuids write FGuids;
    property Methods: TRttiVirtualMethodDataDynArray read FTable.Methods;
    property DefaultCallback: TRttiVirtualMethodCallback read FDefaultCallback;
    property DefaultInvokeCallback: TRttiVirtualMethodInvokeCallback read FDefaultInvokeCallback;
    property DefaultInvokeEvent: TRttiVirtualMethodInvokeEvent read FDefaultInvokeEvent;
  end;


implementation


{ Link object files }

(* ToDo *)
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

{$if not Defined(FPC) and Defined(CPUX86) and (CompilerVersion <= 25)}
  {$define OLDDELPHILINKER}
{$ifend}

{$if Defined(OBJLINKSUPPORT)}
  {$if Defined(MSWINDOWS)}
    {$ifdef SMALLINT}
      {$L objs\win32\tiny.invoke.o}
      {$ifNdef OLDDELPHILINKER}
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
  {$ifdef OLDDELPHILINKER}
    forward;
    {$I c\tiny.invoke.intr.jumps.olddelphi.inc}
  {$else}
    external {$if not Defined(OBJLINKSUPPORT)}LIB_TINYINVOKEINTRJUMPS_PATH name 'get_intercept_jump'{$ifend};
  {$endif}


{ TRttiArgument }

function TRttiArgument.GetIsArray: Boolean;
begin
  Result := (Qualifier <= rqArrayOut);
end;

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
    rqConstValue,
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

function TRttiArgument.GetIsReference: Boolean;
begin
  Result := (Qualifier >= rqValueRef);
end;

function TRttiArgument.GetTotalPointerDepth: Byte;
begin
  Result := PointerDepth + Byte(Qualifier >= rqValueRef{IsReference});
end;

procedure TRttiArgument.SetValue(const ADump: PRttiInvokeDump; const ASource: Pointer);
var
  LSetter: NativeUInt;
  LTarget: Pointer;
begin
  LSetter := SetterFunc;
  LTarget := @ADump.Bytes[Offset];

  case LSetter of
    0: PPointer(LTarget)^ := ASource;
    1: PPointer(LTarget)^ := PPointer(ASource)^;
    2: PAlterNativeInt(LTarget)^ := PAlterNativeInt(ASource)^;
  else
    RTTI_COPY_FUNCS[LSetter](@Self, LTarget, ASource);
  end;
end;

procedure TRttiArgument.GetValue(const ADump: PRttiInvokeDump; const ATarget: Pointer);
var
  LGetter: NativeUInt;
  LSource: Pointer;
begin
  LGetter := GetterFunc;
  LSource := @ADump.Bytes[Offset];

  case LGetter of
    0: PPointer(ATarget)^ := LSource;
    1: PPointer(ATarget)^ := PPointer(LSource)^;
    2: PAlterNativeInt(ATarget)^ := PAlterNativeInt(LSource)^;
  else
    RTTI_COPY_FUNCS[LGetter](@Self, ATarget, LSource);
  end;
end;

function TRttiArgument.GetValue(const ADump: PRttiInvokeDump): Pointer;
begin
  Result := @ADump.Bytes[Offset];
  if (Qualifier >= rqValueRef{IsReference}) then
  begin
    Result := PPointer(Result)^;
  end;
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

var
  UniversalInvokeFuncCache: TRttiInvokeFunc;
  UniversalInterceptFuncCache: TRttiInterceptFunc;

function TRttiSignature.GetSize: Integer;
begin
  Result := (SizeOf(TRttiSignature) - (Integer(High(Byte)) + 1) * SizeOf(TRttiArgument)) +
    ArgumentCount * SizeOf(TRttiArgument);
end;

function TRttiSignature.GetDumpSize: Integer;
begin
  Result := (SizeOf(TRttiRegisters) + SizeOf(Pointer{ReturnAddress})) +
    DumpOptions.StackSize;
end;

{$ifdef STATICSUPPORT}class{$endif} function TRttiSignature.GetUniversalInvokeFunc: TRttiInvokeFunc;
begin
  Result := UniversalInvokeFuncCache;
  if (not Assigned(Result)) then
  begin
    Result := get_invoke_func(-1);
    UniversalInvokeFuncCache := Result;
  end;
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
  Result := UniversalInterceptFuncCache;
  if (not Assigned(Result)) then
  begin
    Result := get_intercept_func(-1);
    UniversalInterceptFuncCache := Result;
  end;
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
    end else
    begin
      for i := 0 to Integer(LUsage.ExtendedCount) - 1 do
      begin
        LSignature := (LSignature shl 2) + 2;
      end;

      for i := 0 to Integer(LUsage.GeneralCount) - 1 do
      begin
        LSignature := (LSignature shl 2) + 1;
      end;
    end;
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
    ATarget.Qualifier := rqConstValue;
  end else
  begin
    ATarget.Qualifier := rqValue;
  end;

  if (ATarget.Qualifier in [rqValue, rqValueRef, rqVar, rqOut]) then
  case ASource.Reference of
    rfUnsafe:
    begin
      if (tfUnsafable in ATarget.GetRules(LRulesBuffer).Flags) then
      begin
        Inc(Byte(ATarget.Qualifier), Byte(rqUnsafeValue) - Byte(rqValue));
      end;
    end;
    rfWeak:
    begin
      if (tfWeakable in ATarget.GetRules(LRulesBuffer).Flags) then
      begin
        Inc(Byte(ATarget.Qualifier), Byte(rqWeakValue) - Byte(rqValue));
      end;
    end;
  end;
end;

procedure TRttiSignature.InitDump(const AHasSelf, AConstructor: Boolean);
label
  reference_qualifier, invalid_qualifier, put_arg_stack;
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

    if (Return.IsArray) or (Byte(Return.Qualifier) > Byte(High(TRttiArgumentQualifier))) then
    begin
      System.Error(reInvalidCast);
      Exit;
    end;

    if (CallConv = rcSafeCall) then
    begin
      LReturnArgMode := ramRefLast;
      Return.Qualifier := rqVar;
      DumpOptions.ReturnStrategy := rsSafeCall;
    end else
    if (LRules.Return = trReference) then
    begin
      if (Return.Qualifier <> rqUnsafeValue) or (not (tfUnsafable in LRules.Flags)) then
      begin
        LReturnArgMode := {$ifdef CPUX86}ramRefLast{$else}ramRefFirst{$endif};
        Return.Qualifier := rqVar;
        DumpOptions.ReturnStrategy := rsNone;
      end;
    end else
    begin
      Return.Qualifier := rqValue;
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

    Return.GetterFunc := LRules.CopyFunc;
    Return.SetterFunc := Return.GetterFunc;
    case DumpOptions.ReturnStrategy of
      rsNone, rsSafeCall:
      begin
        Return.SetterFunc := RTTI_COPYREFERENCE_FUNC;
      end;
      {$ifdef HFASUPPORT}
      rsFloat2, rsFloat3, rsFloat4:
      begin
        LCount := Ord(DumpOptions.ReturnStrategy) - Ord(rsFloat2);
        Return.GetterFunc := RTTI_COPYHFAREAD_LOWFUNC + LCount;
        Return.SetterFunc := RTTI_COPYHFAWRITE_LOWFUNC + LCount;
      end;
      {$endif}
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
    // rules
    LArgument := @Arguments[i];
    LRules := LArgument.GetRules(LRulesBuffer);
    LArgument.GetterFunc := LRules.CopyFunc;
    LArgument.SetterFunc := LArgument.GetterFunc;
    LArgument.HighOffset := 0;
    case LArgument.Qualifier of
      rqArrayValue..rqArrayOut:
      begin
        if (LArgument.PointerDepth <> 0) then
        begin
          goto invalid_qualifier;
        end;

        LArgument.GetterFunc := RTTI_COPYARGARRAYREAD_FUNC;
        LArgument.SetterFunc := RTTI_COPYARGARRAYWRITE_FUNC;
      end;
      rqValue..rqConstValue:
      begin
        case LArgument.Qualifier of
          rqUnsafeValue:
          begin
            if (not (tfUnsafable in LRules.Flags)) then
            begin
              LArgument.Qualifier := rqValue;
            end;
          end;
          rqWeakValue:
          begin
            if (not (tfWeakable in LRules.Flags)) then
            begin
              LArgument.Qualifier := rqValue;
            end;
          end;
        end;

        if (LRules.Flags * [tfRegValueArg, tfGenUseArg] = RTTI_RULEFLAGS_REFERENCE{IsRefArg}) or
          {$ifdef CPUX86}
          ((CallConv = rcMWPascal) and (LArgument.BaseOptions = Ord(rtStructure))) or
          {$endif}
          (
            (tfOptionalRefArg in LRules.Flags) and
            {$ifdef CPUX86}
            ((CallConv in [rcRegister, rcPascal]) or (LArgument.Qualifier = rqConstValue))
            {$else}
            (CallConv in [rcRegister, rcPascal])
            {$endif}
          ) then
        begin
          Inc(Byte(LArgument.Qualifier), Byte(rqValueRef) - Byte(rqValue));
          goto reference_qualifier;
        end else
        case LRules.Size of
          0..3, 5..7, 9..RTTI_COPYBYTES_MAXCOUNT:
          begin
            LArgument.SetterFunc := RTTI_COPYBYTES_LOWFUNC + LRules.Size;
          end;
          4:
          begin
            LArgument.SetterFunc := RTTI_COPYBYTES_CARDINAL;
          end;
          8:
          begin
            LArgument.SetterFunc := RTTI_COPYBYTES_INT64;
          end;
        else
          if (RTTI_TYPE_GROUPS[LArgument.BaseType] = rgMetaType) then
          begin
            LArgument.SetterFunc := RTTI_COPYMETATYPEBYTES_FUNC;
          end else
          if (LArgument.BaseType = rtShortString) then
          begin
            LArgument.SetterFunc := RTTI_COPYSHORTSTRING_FUNC;
          end;
        end;
      end;
      rqValueRef..High(TRttiArgumentQualifier):
      begin
        case LArgument.Qualifier of
          rqUnsafeValueRef, rqUnsafeVar, rqUnsafeOut:
          begin
            if (not (tfUnsafable in LRules.Flags)) then
            begin
              Dec(Byte(LArgument.Qualifier), Byte(rqUnsafeValueRef) - Byte(rqValueRef));
            end;
          end;
          rqWeakValueRef, rqWeakVar, rqWeakOut:
          begin
            if (not (tfWeakable in LRules.Flags)) then
            begin
              Dec(Byte(LArgument.Qualifier), Byte(rqWeakValueRef) - Byte(rqValueRef));
            end;
          end;
        end;

      reference_qualifier:
        LArgument.SetterFunc := RTTI_COPYREFERENCE_FUNC;
        if (LArgument.PointerDepth = 0) and (tfVarHigh in LRules.Flags) and (LArgument.IsVar) then
        begin
          if (LArgument.BaseType = rtShortString) then
          begin
            LArgument.SetterFunc := RTTI_COPYVAROPENSTRINGWRITE_FUNC;
          end;
        end;
      end;
    else
    invalid_qualifier:
      System.Error(reInvalidCast);
      Exit;
    end;

    // offset
    if (LArgument.PointerDepth <> 0) or (not (LArgument.Qualifier in [rqValue..rqConstValue])) then
    begin
      LArgument.Offset := PutGen;
    end else
    {$if not Defined(CPUX86) and not Defined(ARM_NO_VFP_USE)}
    if (LRules.Flags * [tfRegValueArg, tfGenUseArg] = RTTI_RULEFLAGS_REGEXTENDED{IsExtendedArg})
      {$ifdef CPUARM32}and (CallConv <> rcSoftFloat){$endif} then
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
          if ((Ord(LRules.Return) - Ord(trFloat1)) and 1 = 0) then
          begin
            {$ifdef POSIXINTEL64}
              LCount := (LCount + 1) shr 1;
            {$else}
              if (LCount >= 2) and (LRegExt + LCount <= LRegExtCount) then
              begin
                LArgument.GetterFunc := RTTI_COPYHFAREAD_LOWFUNC + LCount - 2;
                LArgument.SetterFunc := RTTI_COPYHFAWRITE_LOWFUNC + LCount - 2;
              end;
            {$endif}
          end;

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
    if (LRules.Flags * [tfRegValueArg, tfGenUseArg] = RTTI_RULEFLAGS_REGGENERAL{IsGeneralArg}) then
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
      LArgument.Offset := PutStack(LRules.Size);
    end;

    if (LArgument.Qualifier <= rqArrayOut{IsArray}) or
      ((LArgument.PointerDepth = 0) and (tfVarHigh in LRules.Flags) and (LArgument.IsVar)) then
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

  // done
  Result := True;
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

type
  PRttiSignatureBufferItem = ^TRttiSignatureBufferItem;
  TRttiSignatureBufferItem = packed record
    Next: PRttiSignatureBufferItem;
    { managed value }
    FinalFunc: TRttiTypeFunc;
    {$ifdef LARGEINT}
    _Padding: Integer;
    {$endif}
    ExType: TRttiExType;
    Value: packed record end;
  end;

  TRttiSignatureBuffer = object
    Vmt: Pointer;
    HeapItems: PRttiSignatureBufferItem;
    ManagedItems: PRttiSignatureBufferItem;
    Current: PByte;
    Overflow: PByte;
    Bytes: array[0..31] of Byte;
    ExType: TRttiExType;

    procedure Init(var AEmptyInterface: IInterface); {$ifdef INLINESUPPORT}inline;{$endif}
    function Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
    function AllocHeapItem(const ASize: NativeUInt): Pointer;
    function GrowAlloc(const ASize: NativeUInt): Pointer;
    function Alloc(const ASize: NativeUInt): Pointer; overload;
    function Alloc(const AExType: TRttiExType): Pointer; overload;
    function Convert(const ATargetExType: TRttiExType; const ASource: Pointer): Pointer;
  end;

const
  TRttiSignatureBufferVmt: array[0..2] of Pointer =
  (
    nil{QueryInterface},
    nil{AddRef},
    @TRttiSignatureBuffer.Release
  );

procedure TRttiSignatureBuffer.Init(var AEmptyInterface: IInterface);
begin
  Vmt := @TRttiSignatureBufferVmt;
  HeapItems := nil;
  ManagedItems := nil;
  Current := Pointer(NativeInt(@Bytes[Low(Bytes) + 7]) and -8);
  Overflow := Pointer(PAnsiChar(@Bytes[High(Bytes)]) + 1);
  Pointer(AEmptyInterface) := @Self;
end;

function TRttiSignatureBuffer.Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer{$else}Longint{$ifend};
var
  LItem, LNext: PRttiSignatureBufferItem;
begin
  // managed values
  LItem := ManagedItems;
  ManagedItems := nil;
  while (Assigned(LItem)) do
  begin
    LItem.FinalFunc(@LItem.ExType, @LItem.Value);
    LItem := LItem.Next;
  end;

  // heap items
  LItem := HeapItems;
  HeapItems := nil;
  while (Assigned(LItem)) do
  begin
    LNext := LItem.Next;
    FreeMem(LItem);

    LItem := LNext;
  end;

  // result
  Result := -1;
end;

function TRttiSignatureBuffer.AllocHeapItem(const ASize: NativeUInt): Pointer;
var
  LItem: PRttiSignatureBufferItem;
begin
  GetMem(LItem, ASize + 8);

  LItem.Next := HeapItems;
  HeapItems := LItem;

  Result := Pointer(NativeUInt(LItem) + 8);
end;

function TRttiSignatureBuffer.GrowAlloc(const ASize: NativeUInt): Pointer;
const
  BLOCK_SIZE = 256;
var
  LPtr: PByte;
begin
  if (ASize >= BLOCK_SIZE) then
  begin
    Result := AllocHeapItem(ASize);
    Exit;
  end;

  LPtr := AllocHeapItem(BLOCK_SIZE);
  Overflow := Pointer(NativeUInt(LPtr) + BLOCK_SIZE);
  Inc(LPtr, ASize);
  Current := LPtr;
  Dec(LPtr, ASize);
  Result := LPtr;
end;

function TRttiSignatureBuffer.Alloc(const ASize: NativeUInt): Pointer;
var
  LSize: NativeUInt;
  LPtr: NativeUInt{PByte};
begin
  LSize := NativeUInt(NativeInt(ASize + 7) and -8);

  LPtr := NativeUInt(Current);
  Inc(LPtr, LSize);
  if (NativeUInt(LPtr) > NativeUInt(Overflow)) then
  begin
    Result := GrowAlloc(LSize);
  end else
  begin
    NativeUInt(Current) := LPtr;
    Dec(LPtr, LSize);
    Result := Pointer(LPtr);
  end;
end;

function TRttiSignatureBuffer.Alloc(const AExType: TRttiExType): Pointer;
var
  LRulesBuffer: TRttiTypeRules;
  LRules: PRttiTypeRules;
  LSize: NativeUInt;
  LPtr: NativeUInt{PByte};
  LItem: PRttiSignatureBufferItem;
  LFuncIndex: NativeUInt;
begin
  // rules
  LRules := AExType.GetRules(LRulesBuffer);
  LSize := LRules.Size;
  if (tfManaged in LRules.Flags) then
  begin
    Inc(LSize, SizeOf(TRttiSignatureBufferItem) + 7);
  end else
  begin
    Inc(LSize, 7);
  end;
  LSize := NativeUInt(NativeInt(LSize) and -8);

  // allocation
  LPtr := NativeUInt(Current);
  Inc(LPtr, LSize);
  if (NativeUInt(LPtr) > NativeUInt(Overflow)) then
  begin
    LItem := GrowAlloc(LSize);
  end else
  begin
    NativeUInt(Current) := LPtr;
    Dec(LPtr, LSize);
    LItem := Pointer(LPtr);
  end;

  // initialization
  if (tfManaged in LRules.Flags) then
  begin
    LItem.Next := ManagedItems;
    ManagedItems := LItem;

    LItem.FinalFunc := RTTI_FINAL_FUNCS[LRules.FinalFunc];
    LItem.ExType := AExType;
    Result := @LItem.Value;

    LFuncIndex := LRules.InitFunc;
    case LFuncIndex of
      RTTI_INITNONE_FUNC: ;
      RTTI_INITPOINTER_FUNC: PPointer(Result)^ := nil;
      RTTI_INITPOINTERPAIR_FUNC:
      begin
        PMethod(Result).Code := nil;
        PMethod(Result).Data := nil;
      end;
    else
      RTTI_INIT_FUNCS[LFuncIndex](@AExType, Result);
    end;
  end else
  begin
    Result := LItem;
  end;
end;

function TRttiSignatureBuffer.Convert(const ATargetExType: TRttiExType;
  const ASource: Pointer): Pointer;
label
  true_value, pchars_value, failure;
const
  CP_UTF8 = 65001;
  CP_UTF16 = 1200;
  CP_UTF32 = 12000;
var
  LValue: Pointer;
  LCodePage: Word;
  LCount: Integer;
  LTargetCodePage: Word;
begin
  case ATargetExType.BaseType of
    rtPointer:
    begin
      case (ExType.BaseType) of
        rtPointer,
        rtPSBCSChars,
        rtPUTF8Chars,
        rtPWideChars,
        rtPUCS4Chars,
        rtClassRef,
        rtObject,
        rtFunction,
        rtClosure,
        rtInterface: Result := ASource;
        rtMethod: Result := @PMethod(ASource).Code;
      else
        goto failure;
      end;
    end;
    rtBoolean8,
    rtBoolean16,
    rtBoolean32,
    rtBoolean64,
    rtBool8,
    rtBool16,
    rtBool32,
    rtBool64:
    begin
      Result := Alloc(SizeOf(Int64));
      PInt64(Result)^ := 0;

      case (ExType.BaseType) of
        rtBoolean8,
        rtBool8: if (PByte(ASource)^ <> 0) then goto true_value;
        rtBoolean16,
        rtBool16: if (PWord(ASource)^ <> 0) then goto true_value;
        rtBoolean32,
        rtBool32: if (PCardinal(ASource)^ <> 0) then goto true_value;
        rtBoolean64,
        rtBool64: if (PInt64(ASource)^ <> 0) then goto true_value;
      else
        goto failure;
      true_value:
        if (ATargetExType.BaseType in [rtBoolean8..rtBoolean64]) then
        begin
          PInt64(Result)^ := 1;
        end else
        begin
          PInt64(Result)^ := -1;
        end;
      end;
    end;
    rtInt8,
    rtUInt8,
    rtInt16,
    rtUInt16,
    rtInt32,
    rtUInt32,
    rtInt64,
    rtUInt64,
    rtComp,
    rtEnumeration8,
    rtEnumeration16,
    rtEnumeration32,
    rtEnumeration64:
    begin
      Result := Alloc(SizeOf(Int64));

      case (ExType.BaseType) of
        rtBoolean8,
        rtBool8,
        rtUInt8: PInt64(Result)^ := PByte(ASource)^;
        rtBoolean16,
        rtBool16,
        rtUInt16: PInt64(Result)^ := PWord(ASource)^;
        rtInt8,
        rtEnumeration8: PInt64(Result)^ := PShortInt(ASource)^;
        rtInt16,
        rtEnumeration16: PInt64(Result)^ := PSmallInt(ASource)^;
        rtBoolean32,
        rtBool32,
        rtUInt32: PInt64(Result)^ := PCardinal(ASource)^;
        rtInt32,
        rtEnumeration32: PInt64(Result)^ := PInteger(ASource)^;
        rtBoolean64,
        rtBool64,
        rtInt64,
        rtUInt64,
        rtEnumeration64,
        rtComp,
        rtTimeStamp: PInt64(Result)^ := PInt64(ASource)^;
        rtCurrency: PInt64(Result)^ := Round(PInt64(ASource)^ * (1 / 10000));
        rtFloat: PInt64(Result)^ := Round(PSingle(ASource)^);
        rtDouble: PInt64(Result)^ := Round(PDouble(ASource)^);
        {$ifdef EXTENDEDSUPPORT}
        rtLongDouble80,
        rtLongDouble96,
        rtLongDouble128: PInt64(Result)^ := Round(PExtended(ASource)^);
        {$endif}
      else
        goto failure;
      end;
    end;
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128,
    {$endif}
    rtCurrency,
    rtFloat,
    rtDouble:
    begin
      Result := Alloc(SizeOf(Extended));

      case (ExType.BaseType) of
        rtUInt8:
        begin
          PExtended(Result)^ := PByte(ASource)^;
        end;
        rtInt8,
        rtEnumeration8:
        begin
          PExtended(Result)^ := PShortInt(ASource)^;
        end;
        rtUInt16:
        begin
          PExtended(Result)^ := PWord(ASource)^;
        end;
        rtInt16,
        rtEnumeration16:
        begin
          PExtended(Result)^ := PSmallInt(ASource)^;
        end;
        rtUInt32: PExtended(Result)^ := Int64(PCardinal(ASource)^);
        rtInt32,
        rtEnumeration32: PExtended(Result)^ := PInteger(ASource)^;
        rtInt64,
        rtUInt64,
        rtEnumeration64,
        rtComp,
        rtTimeStamp: PExtended(Result)^ := PInt64(ASource)^;
        rtCurrency: PExtended(Result)^ := PInt64(ASource)^ * (1 / 10000);
        rtFloat: PExtended(Result)^ := PSingle(ASource)^;
        rtDouble,
        rtDate,
        rtTime,
        rtDateTime: PExtended(Result)^ := PDouble(ASource)^;
        {$ifdef EXTENDEDSUPPORT}
        rtLongDouble80,
        rtLongDouble96,
        rtLongDouble128: PExtended(Result)^ := PExtended(ASource)^;
        {$endif}
      else
        goto failure;
      end;

      case ATargetExType.BaseType of
        rtCurrency: PCurrency(Result)^ := PExtended(Result)^;
        rtFloat: PSingle(Result)^ := PExtended(Result)^;
        {$ifdef EXTENDEDSUPPORT}
        rtDouble: PDouble(Result)^ := PExtended(Result)^;
        {$endif}
      end;
    end;
    rtDate:
    begin
      Result := Alloc(SizeOf(TDate));

      case (ExType.BaseType) of
        rtDate: PDouble(Result)^ := PDouble(ASource)^;
        rtDateTime: PDouble(Result)^ := Trunc(PDouble(ASource)^);
        rtTimeStamp: PDouble(Result)^ := Trunc((PInt64(ASource)^ - TIMESTAMP_DELTA) * TIMESTAMP_UNDAY);
      else
        goto failure;
      end;
    end;
    rtTime:
    begin
      Result := Alloc(SizeOf(TTime));

      case (ExType.BaseType) of
        rtTime: PDouble(Result)^ := PDouble(ASource)^;
        rtDateTime: PDouble(Result)^ := Frac(PDouble(ASource)^);
        rtTimeStamp: PDouble(Result)^ := Frac((PInt64(ASource)^ - TIMESTAMP_DELTA) * TIMESTAMP_UNDAY);
      else
        goto failure;
      end;
    end;
    rtDateTime:
    begin
      Result := Alloc(SizeOf(TDateTime));

      case (ExType.BaseType) of
        rtDate,
        rtTime,
        rtDateTime: PDouble(Result)^ := PDouble(ASource)^;
        rtTimeStamp: PDouble(Result)^ := (PInt64(ASource)^ - TIMESTAMP_DELTA) * TIMESTAMP_UNDAY;
      else
        goto failure;
      end;
    end;
    rtTimeStamp:
    begin
      Result := Alloc(SizeOf(TimeStamp));

      case (ExType.BaseType) of
        rtTimeStamp: PInt64(Result)^ := PInt64(ASource)^;
        rtDate,
        rtTime,
        rtDateTime: PInt64(Result)^ := Round(PDouble(ASource)^ * TIMESTAMP_DAY + TIMESTAMP_DELTA);
      else
        goto failure;
      end;
    end;
    rtPSBCSChars,
    rtPUTF8Chars:
    begin
      case ExType.BaseType of
        rtPointer, rtPSBCSChars, rtPUTF8Chars:
        begin
          Result := ASource;
        end;
        rtSBCSString, rtUTF8String:
        begin
          Result := ASource;
          goto pchars_value;
        end;
      else
        goto failure;
      end;
    end;
    rtPWideChars:
    begin
      case ExType.BaseType of
        rtPointer, rtPWideChars:
        begin
          Result := ASource;
        end;
        rtWideString, rtUnicodeString:
        begin
          Result := ASource;
          goto pchars_value;
        end;
      else
        goto failure;
      end;
    end;
    rtPUCS4Chars:
    begin
      case ExType.BaseType of
        rtPointer, rtPUCS4Chars:
        begin
          Result := ASource;
        end;
        rtUCS4String:
        begin
          Result := ASource;
        pchars_value:
          if (not Assigned(PPointer(Result)^)) then
          begin
            Result := Alloc(SizeOf(Pointer));
            PPointer(Result)^ := Pointer(@RTTI_RULES_NONE);
          end;
        end;
      else
        goto failure;
      end;
    end;
    rtSBCSChar,
    rtUTF8Char,
    rtWideChar,
    rtUCS4Char,
    rtSBCSString,
    rtUTF8String,
    rtWideString,
    rtUnicodeString,
    rtUCS4String,
    rtShortString:
    begin
      if (ATargetExType.BaseType = ExType.BaseType) then
      begin
        Result := ASource;
        Exit;
      end;

      // characters, count and code page
      LValue := ASource;
      case (ExType.BaseType) of
        rtSBCSChar:
        begin
          LCount := 1;
          LCodePage := ExType.CodePage;
        end;
        rtUTF8Char:
        begin
          LCount := 1;
          LCodePage := CP_UTF8;
        end;
        rtWideChar:
        begin
          LCount := 1;
          LCodePage := CP_UTF16;
        end;
        rtUCS4Char:
        begin
          LCount := 1;
          LCodePage := CP_UTF32;
        end;
        rtPSBCSChars:
        begin
          LValue := PPointer(LValue)^;
          LCount := TCharacters.LStrLen(LValue);
          LCodePage := ExType.CodePage;
        end;
        rtPUTF8Chars:
        begin
          LValue := PPointer(LValue)^;
          LCount := TCharacters.LStrLen(LValue);
          LCodePage := CP_UTF8;
        end;
        rtPWideChars:
        begin
          LValue := PPointer(LValue)^;
          LCount := TCharacters.WStrLen(LValue);
          LCodePage := CP_UTF16;
        end;
        rtPUCS4Chars:
        begin
          LValue := PPointer(LValue)^;
          LCount := TCharacters.UStrLen(LValue);
          LCodePage := CP_UTF32;
        end;
        rtSBCSString, rtUTF8String:
        begin
          if (ExType.BaseType = rtUTF8String) then
          begin
            LCodePage := CP_UTF8;
          end else
          begin
            LCodePage := ExType.CodePage;
          end;

          LCount := Length(PAnsiString(LValue)^);
          LValue := PPointer(LValue)^;
        end;
        rtWideString:
        begin
          LCount := Length(PWideString(LValue)^);
          LValue := PPointer(LValue)^;
          LCodePage := CP_UTF16;
        end;
        rtUnicodeString:
        begin
          LCount := Length(PUnicodeString(LValue)^);
          LValue := PPointer(LValue)^;
          LCodePage := CP_UTF16;
        end;
        rtUCS4String:
        begin
          LCount := TCharacters.UCS4StringLen(PUCS4String(LValue)^);
          LValue := PPointer(LValue)^;
          LCodePage := CP_UTF32;
        end;
        rtShortString:
        begin
          LCount := PByte(LValue)^;
          Inc(NativeInt(LValue));
          LCodePage := CP_UTF8;
        end;
      else
        goto failure;
      end;

      // target is a character
      if (ATargetExType.BaseType in [rtSBCSChar..rtUCS4Char]) then
      begin
        Result := Alloc(SizeOf(UCS4Char));

        if (LCount = 0) then
        begin
          PCardinal(Result)^ := 0;
        end else
        case LCodePage of
          CP_UTF16:
          begin
            PUCS4Char(Result)^ := TCharacters.UCS4CharFromUnicode(LValue, LCount);
          end;
          CP_UTF32:
          begin
           PUCS4Char(Result)^ := PUCS4Char(LValue)^;
          end;
        else
          PUCS4Char(Result)^ := TCharacters.UCS4CharFromAnsi(LCodePage, LValue, LCount);
        end;

        if (ATargetExType.BaseType <> rtUCS4Char) and (PCardinal(Result)^ > $7f) then
        begin
          LCount := TCharacters.UnicodeFromUCS4(Result, Result, 1);

          case ATargetExType.BaseType of
            rtSBCSChar:
            begin
              {$ifNdef MSWINDOWS}TCharacters.{$endif}WideCharToMultiByte(ATargetExType.CodePage,
                0, Result, LCount, Result, 4, nil, nil);
            end;
            rtUTF8Char:
            begin
              {$ifNdef MSWINDOWS}TCharacters.{$endif}WideCharToMultiByte(CP_UTF8,
                0, Result, LCount, Result, 4, nil, nil);
            end;
           end;
        end;

        Exit;
      end;

      // string targets
      Result := Alloc(ATargetExType);
      if (LCount = 0) then
      begin
        if (ATargetExType.BaseType = rtShortString) then
        begin
          PByte(Result)^ := 0;
        end;
      end else
      case ATargetExType.BaseType of
        rtSBCSString,
        rtUTF8String:
        begin
          LTargetCodePage := CP_UTF8;
          if (ATargetExType.BaseType = rtSBCSString) then
          begin
            LTargetCodePage := ATargetExType.CodePage;
          end;

          case LCodePage of
            CP_UTF16:
            begin
              TCharacters.AnsiFromUnicode(LTargetCodePage, PAnsiString(Result)^,
                LValue, LCount);
            end;
            CP_UTF32:
            begin
              TCharacters.AnsiFromUCS4(LTargetCodePage, PAnsiString(Result)^,
                LValue, LCount);
            end;
          else
            TCharacters.AnsiFromAnsi(LTargetCodePage, PAnsiString(Result)^,
              LCodePage, LValue, LCount);
          end;
        end;
        rtWideString:
        begin
          case LCodePage of
            CP_UTF16:
            begin
              SetLength(PWideString(Result)^, LCount);
              System.Move(LValue^, PPointer(PWideString(Result)^)^, LCount * SizeOf(WideChar));
            end;
            CP_UTF32:
            begin
              TCharacters.UnicodeFromUCS4(PWideString(Result)^, LValue, LCount);
            end;
          else
            TCharacters.UnicodeFromAnsi(PWideString(Result)^, LCodePage, LValue, LCount);
          end;
        end;
        rtUnicodeString:
        begin
          case LCodePage of
            CP_UTF16:
            begin
              SetLength(PUnicodeString(Result)^, LCount);
              System.Move(LValue^, PPointer(PUnicodeString(Result)^)^, LCount * SizeOf(WideChar));
            end;
            CP_UTF32:
            begin
              TCharacters.UnicodeFromUCS4(PUnicodeString(Result)^, LValue, LCount);
            end;
          else
            TCharacters.UnicodeFromAnsi(PUnicodeString(Result)^, LCodePage, LValue, LCount);
          end;
        end;
        rtUCS4String:
        begin
          case LCodePage of
            CP_UTF16:
            begin
              TCharacters.UCS4FromUnicode(PUCS4String(Result)^, LValue, LCount);
            end;
            CP_UTF32:
            begin
              SetLength(PUCS4String(Result)^, LCount + 1);
              PUCS4String(Result)^[LCount] := 0;
              System.Move(LValue^, PPointer(PUCS4String(Result)^)^, LCount * SizeOf(UCS4Char));
            end;
          else
            TCharacters.UCS4FromAnsi(PUCS4String(Result)^, LCodePage, LValue, LCount);
          end;
        end;
      else
        // rtShortString:
        case LCodePage of
          CP_UTF16:
          begin
            TCharacters.ShortStringFromUnicode(PShortString(Result)^,
              ATargetExType.MaxLength, LValue, LCount);
          end;
          CP_UTF32:
          begin
            TCharacters.ShortStringFromUCS4(PShortString(Result)^,
              ATargetExType.MaxLength, LValue, LCount);
          end;
        else
          TCharacters.ShortStringFromAnsi(PShortString(Result)^,
            ATargetExType.MaxLength, LCodePage, LValue, LCount);
        end;
      end;
    end;
    rtSet,
    rtStaticArray,
    rtDynamicArray,
    rtStructure:
    begin
      Result := ASource;
      if (ATargetExType.Options <> ExType.Options) or
        (ATargetExType.CustomData <> ExType.CustomData) then
      begin
        goto failure;
      end;
    end;
    rtObject,
    rtInterface,
    rtClassRef,
    rtFunction,
    rtMethod,
    rtClosure,
    rtBytes,
    rtVarRec,
    rtValue:
    begin
      Result := ASource;
      if (ATargetExType.BaseType <> ExType.BaseType) then
      begin
        goto failure;
      end;
    end;
    rtOleVariant,
    rtVariant:
    begin
      case ExType.BaseType of
        rtOleVariant,
        rtVariant: Result := ASource;
      else
        goto failure;
      end;
    end;
  else
  failure:
    System.Error(reInvalidCast);
    Result := nil;
  end;
end;

type
  PRttiInvokeBuffer = ^TRttiInvokeBuffer;
  TRttiInvokeBuffer = object(TRttiSignatureBuffer)
    Result: Pointer;
    CodeAddress: Pointer;
    Instance: Pointer;
    InvokeFunc: TRttiInvokeFunc;
    Arguments: Pointer;
    ArgumentCount: Integer;
    ArgumentSize: NativeUInt;
    ArgumentMode: (amVarRec, amValue);

    procedure Invoke(var ADump: TRttiInvokeDump; const ASignature: TRttiSignature);
  end;

  PValueRec = ^TValueRec;
  TValueRec = packed record
    FExType: TRttiExType;
    FManagedData: IInterface;
    FBuffer: packed record end;
  end;

procedure TRttiInvokeBuffer.Invoke(var ADump: TRttiInvokeDump;
  const ASignature: TRttiSignature);
label
  invalid_cast, fill_simple_converted_value, fill_converted_value, fill_value,
  next_iteration;
var
  LOffset: NativeInt;
  LArgumentCount: NativeUInt;
  LArgument: Pointer;
  LSignatureArgument, LTopSignatureArgument: PRttiArgument;
  LTarget, LSource: Pointer;
  LCount: NativeUInt;
begin
  // dump/return preparation
  LOffset := ASignature.DumpOptions.ThisOffset;
  if (LOffset <> INVALID_INDEX) then
  begin
    PPointer(@ADump.Bytes[LOffset])^ := Instance;
  end;
  LOffset := ASignature.DumpOptions.ConstructorFlagOffset;
  if (LOffset <> INVALID_INDEX) then
  begin
    PByte(@ADump.Bytes[LOffset])^ := $01;
  end;
  if (ASignature.Return.Qualifier >= rqValueRef{IsReference}) then
  begin
    PPointer(@ADump.Bytes[ASignature.Return.Offset])^ := Result;
  end;

  // arguments
  LArgumentCount := ArgumentCount;
  if (ASignature.ArgumentCount <> Integer(LArgumentCount)) then
  begin
    System.Error(reRangeError);
    Exit;
  end else
  begin
    LSignatureArgument := @ASignature.Arguments[0];
    LTopSignatureArgument := @ASignature.Arguments[LArgumentCount];
  end;
  LArgument := Arguments;
  if (LSignatureArgument <> LTopSignatureArgument) then
  repeat
    if (ArgumentMode = amVarRec) then
    begin
      with TVarRec(LArgument^) do
      begin
        LSource := @VInteger;

        case Cardinal(VType) of
          vtBoolean:
          begin
            if (LSignatureArgument.BaseType = rtBoolean8) then goto fill_value;
            ExType.Options := Ord(rtBoolean8);
            goto fill_simple_converted_value;
          end;
          vtInteger:
          begin
            if (LSignatureArgument.BaseType in [rtInt8..rtUInt32]) then goto fill_value;
            ExType.Options := Ord(rtInt32);
            goto fill_simple_converted_value;
          end;
          vtInt64:
          begin
            LSource := PPointer(LSource)^;
            if (LSignatureArgument.BaseType in [rtInt8..rtComp, rtTimeStamp]) then goto fill_value;
            ExType.Options := Ord(rtInt64);
            goto fill_simple_converted_value;
          end;
          vtExtended:
          begin
            LSource := PPointer(LSource)^;
            if (LSignatureArgument.BaseType in
              [{$ifdef EXTENDEDSUPPORT}rtLongDouble80..rtLongDouble128{$else}rtDouble{$endif}]) then goto fill_value;

            case SizeOf(Extended) of
              10: ExType.Options := Ord(rtLongDouble80);
              12: ExType.Options := Ord(rtLongDouble96);
              16: ExType.Options := Ord(rtLongDouble128);
            else
              ExType.Options := Ord(rtDouble);
            end;
            goto fill_simple_converted_value;
          end;
          vtCurrency:
          begin
            LSource := PPointer(LSource)^;
            if (LSignatureArgument.BaseType in [rtCurrency]) then goto fill_value;
            ExType.Options := Ord(rtCurrency);
            goto fill_simple_converted_value;
          end;
          vtPointer:
          begin
            if (LSignatureArgument.PointerDepth <> 0) or
              (LSignatureArgument.BaseType in [rtPointer, rtObject]) then goto fill_value;
            ExType.Options := Ord(rtPointer);
            goto fill_simple_converted_value;
          end;
          vtObject:
          begin
            if (LSignatureArgument.BaseType in [rtObject]) then goto fill_value;
            ExType.Options := Ord(rtObject);
            goto fill_simple_converted_value;
          end;
          vtClass:
          begin
            if (LSignatureArgument.BaseType in [rtClassRef]) then goto fill_value;
            ExType.Options := Ord(rtClassRef);
            goto fill_simple_converted_value;
          end;
          vtInterface:
          begin
            if (LSignatureArgument.BaseType in [rtInterface, rtClosure]) then goto fill_value;
            ExType.Options := Ord(rtInterface);
            goto fill_simple_converted_value;
          end;
          vtVariant:
          begin
            if (LSignatureArgument.BaseType in [rtVariant, rtOleVariant]) then goto fill_value;
            ExType.Options := Ord(rtVariant);
            goto fill_simple_converted_value;
          end;
          vtString:
          begin
            LSource := PPointer(LSource)^;
            if (LSignatureArgument.BaseType in [rtShortString]) then goto fill_value;
            ExType.Options := Ord(rtShortString) + (255 shl 16) {$ifdef SHORTSTRSUPPORT}+ (Ord(True) shl 24){$endif};
            goto fill_simple_converted_value;
          end;
          vtAnsiString:
          begin
            if (LSignatureArgument.BaseType in [rtSBCSString, rtUTF8String]) then goto fill_value;
            ExType.Options := DefaultSBCSStringOptions;
            goto fill_simple_converted_value;
          end;
          {$ifdef UNICODE}
          vtUnicodeString:
          begin
            if (LSignatureArgument.BaseType in [rtUnicodeString]) then goto fill_value;
            ExType.Options := Ord(rtUnicodeString);
            goto fill_simple_converted_value;
          end;
          {$endif}
          vtWideString:
          begin
            if (LSignatureArgument.BaseType in [rtWideString]) then goto fill_value;
            ExType.Options := Ord(rtWideString);
            goto fill_simple_converted_value;
          end;
          vtChar:
          begin
            if (LSignatureArgument.BaseType in [rtSBCSChar, rtUTF8Char]) then goto fill_value;
            ExType.Options := Ord(rtSBCSChar);
            ExType.CodePage := DefaultCP;
            goto fill_simple_converted_value;
          end;
          vtWideChar:
          begin
            if (LSignatureArgument.BaseType in [rtSBCSChar, rtUTF8Char, rtWideChar]) then goto fill_value;
            ExType.Options := Ord(rtWideChar);
            goto fill_simple_converted_value;
          end;
          vtPChar:
          begin
            if (LSignatureArgument.BaseType in [rtPointer, rtPSBCSChars, rtPUTF8Chars]) then goto fill_value;
            ExType.Options := Ord(rtPSBCSChars);
            ExType.CodePage := DefaultCP;
            goto fill_simple_converted_value;
          end;
          vtPWideChar:
          begin
            if (LSignatureArgument.BaseType in [rtPointer, rtPWideChars]) then goto fill_value;
            ExType.Options := Ord(rtPWideChars);
            goto fill_simple_converted_value;
          end;
        else
        invalid_cast:
          System.Error(reInvalidCast);
          Exit;
        fill_simple_converted_value:
          ExType.CustomData := nil;
          goto fill_converted_value;
        end;
      end;
    end else
    // if (ArgumentMode = amValue) then
    begin
      LSource := PValue(LArgument)^.Data;

      with TValueRec(LArgument^) do
      begin
        if (FExType.Options = LSignatureArgument.Options) and
          (
            Assigned(RTTI_TYPE_RULES[FExType.BaseType]) or
            (FExType.CustomData = LSignatureArgument.CustomData)
          ) then
        begin
          goto fill_value;
        end else
        begin
          Self.ExType := FExType;
        fill_converted_value:
          LSource := Convert(LSignatureArgument^, LSource);
        end;
      end;
    end;

  fill_value:
    // pointer depth
    LCount := LSignatureArgument.PointerDepth;
    if (LCount > 1) then
    repeat
      LTarget := Alloc(SizeOf(Pointer));
      PPointer(LTarget)^ := LSource;
      LSource := LTarget;

      Dec(LCount);
    until (LCount = 1);

    // LSignatureArgument.SetValue(@ADump, LSource);
    LTarget := @ADump.Bytes[LSignatureArgument.Offset];
    case Cardinal(LSignatureArgument.SetterFunc) of
      0: PPointer(LTarget)^ := LSource;
      1: PPointer(LTarget)^ := PPointer(LSource)^;
      2: PAlterNativeInt(LTarget)^ := PAlterNativeInt(LSource)^;
    else
      RTTI_COPY_FUNCS[PByte(@LSignatureArgument.SetterFunc)^](LSignatureArgument, LTarget, LSource);
    end;

  next_iteration:
    Inc(LSignatureArgument);
    Inc(NativeUInt(LArgument), ArgumentSize);
  until (LSignatureArgument = LTopSignatureArgument);

  // invoke function
  if (not Assigned(InvokeFunc)) then
  begin
    InvokeFunc := ASignature.UniversalInvokeFunc;
  end;
  InvokeFunc(@ASignature, CodeAddress, @ADump);

  // optional result
  LTarget := Result;
  if (Assigned(LTarget)) and (not (ASignature.Return.Qualifier >= rqValueRef{IsReference})) then
  begin
    // ASignature.Return.GetValue(@ADump, LTarget);
    LSource := @ADump.Bytes[ASignature.Return.Offset];
    case Cardinal(ASignature.Return.SetterFunc) of
      0: PPointer(LTarget)^ := LSource;
      1: PPointer(LTarget)^ := PPointer(LSource)^;
      2: PAlterNativeInt(LTarget)^ := PAlterNativeInt(LSource)^;
    else
      RTTI_COPY_FUNCS[PByte(@ASignature.Return.SetterFunc)^](@ASignature.Return, LTarget, LSource);
    end;
  end;
end;

procedure TRttiSignature.Invoke(var ADump: TRttiInvokeDump;
  const ACodeAddress, AInstance: Pointer; const AArgs: array of const;
  const AResult: Pointer; const AInvokeFunc: TRttiInvokeFunc);
var
  LBuffer: TRttiInvokeBuffer;
  LBufferIntf: IInterface;
begin
  // interface
  LBuffer.Init(LBufferIntf);

  // return value
  LBuffer.Result := AResult;
  if (not Assigned(AResult)) and (Return.Qualifier >= rqValueRef{IsReference}) then
  begin
    LBuffer.Result := LBuffer.Alloc(Return);
  end;

  // invoke
  LBuffer.CodeAddress := ACodeAddress;
  LBuffer.Instance := AInstance;
  LBuffer.InvokeFunc := AInvokeFunc;
  LBuffer.Arguments := @AArgs[0];
  LBuffer.ArgumentCount := Length(AArgs);
  LBuffer.ArgumentSize := SizeOf(TVarRec);
  LBuffer.ArgumentMode := amVarRec;
  LBuffer.Invoke(ADump, Self);
end;

function TRttiSignature.Invoke(var ADump: TRttiInvokeDump;
  const ACodeAddress, AInstance: Pointer; const AArgs: array of TValue;
  const AInvokeFunc: TRttiInvokeFunc): TValue;
var
  LBuffer: TRttiInvokeBuffer;
  LBufferIntf: IInterface;
begin
  // interface
  LBuffer.Init(LBufferIntf);

  // return value
  if (Return.Offset <> INVALID_INDEX) then
  begin
    Result.Init(Return, nil);
    LBuffer.Result := Result.Data;
  end else
  begin
    Result.Clear;
    LBuffer.Result := nil;
  end;

  // invoke
  LBuffer.CodeAddress := ACodeAddress;
  LBuffer.Instance := AInstance;
  LBuffer.InvokeFunc := AInvokeFunc;
  LBuffer.Arguments := @AArgs[0];
  LBuffer.ArgumentCount := Length(AArgs);
  LBuffer.ArgumentSize := SizeOf(TValue);
  LBuffer.ArgumentMode := amValue;
  LBuffer.Invoke(ADump, Self);
end;


{ TRttiVirtualInterface }

type
  TGUIDRec = packed record
    Low, High: Int64;
  end;
  PGUIDRec = ^TGUIDRec;

var
  INTERFACED_OBJECT_INTF_OFFSET: NativeInt;

procedure TRttiVirtualInterface.DoCallback(const AMethod: TRttiVirtualMethod;
  var ADump: TRttiInvokeDump);
begin
  if (Assigned(FDefaultInvokeCallback)) then
    FDefaultInvokeCallback(AMethod, ADump);
end;

procedure TRttiVirtualInterface.DoErrorCallback(const AMethod: TRttiVirtualMethod;
  var ADump: TRttiInvokeDump);
begin
  {
    Note:
    Insufficient RTTI available to support this operation
  }

  if Assigned(ErrorProc) then
    ErrorProc(Ord(reInvalidCast), ADump.ReturnAddress {$ifdef FPC}, nil{$endif});

  System.ErrorAddr := ADump.ReturnAddress;
  System.ExitCode := 219{reInvalidCast};
  System.Halt;
end;

class procedure TRttiVirtualInterface.DoErrorMethodIndex; {static;}
begin
  {
    Note:
    The interception jump index must be in the range 0..1023
  }
  System.Error(reRangeError);
end;

function TRttiVirtualInterface.GetCallback(const AInvokeCallback: TRttiVirtualMethodInvokeCallback): TRttiVirtualMethodCallback;
begin
  {$ifdef EXTENDEDRTTI}
    TMethod(Result).Data := PPointer(@AInvokeCallback)^;
    TMethod(Result).Code := PPointer(PNativeUInt(TMethod(Result).Data)^ + 3 * SizeOf(Pointer))^;
  {$else}
    Result := AInvokeCallback;
  {$endif}
end;

function TRttiVirtualInterface.GetCallback(var AInvokeEvent: TRttiVirtualMethodInvokeEvent): TRttiVirtualMethodCallback;
begin
  TMethod(Result).Data := @AInvokeEvent;
  TMethod(Result).Code := @TRttiVirtualInterface.InternalEventCallback;
end;

function TRttiVirtualInterface.InternalGetCallback(const AValue: TRttiVirtualMethodInvokeCallback): TRttiVirtualMethodCallback;
begin
  Result := DoCallback;

  if (TMethod(Result).Code = @TRttiVirtualInterface.DoCallback) and Assigned(AValue) then
  begin
    Result := GetCallback(AValue);
  end;
end;

function TRttiVirtualInterface.InternalHeapAlloc(const ASize: Integer): Pointer;
var
  LHeapSize: Integer;
begin
  LHeapSize := ASize + 8;
  if (ASize <= 0) or (LHeapSize <= 0) then
  begin
    Result := nil;
    Exit;
  end;

  GetMem(Result, LHeapSize);
  PPointer(Result)^ := FHeapItems;
  FHeapItems := Result;

  Inc(NativeUInt(Result), 8);
end;

function TRttiVirtualInterface.InternalCopySignature(const ASignature: TRttiSignature): PRttiSignature;
var
  LSize: Integer;
begin
  LSize := ASignature.Size;
  Result := InternalHeapAlloc(LSize);
  System.Move(ASignature, Result^, LSize);
end;

procedure TRttiVirtualInterface.InternalEventCallback(const AMethod: TRttiVirtualMethod; var ADump: TRttiInvokeDump);
type
  {$if Defined(CPUARM64)}
    TEvent = TRttiVirtualMethodInvokeEvent;
  {$elseif Defined(EXTENDEDRTTI)}
    TEvent = reference to procedure(const AMethod: TRttiVirtualMethod; const AArgs: TValueDynArray; const AReturnAddress: Pointer; var AResult: TValue);
  {$else}
    TEvent = procedure(const AMethod: TRttiVirtualMethod; const AArgs: TValueDynArray; const AReturnAddress: Pointer; var AResult: TValue) of object;
  {$ifend}
  PEvent = ^TEvent;
var
  LResult: TValue;
  LArgs: TValueDynArray;
  LSignature: PRttiSignature;
  LArgument, LTopArgument: PRttiArgument;
  LValue: PValue;
  LValueRec: PValueRec;
  LSource, LTarget: Pointer;
  LBuffer: TRttiSignatureBuffer;
  LBufferIntf: IInterface;
begin
  LSignature := AMethod.Signature;

  // arguments
  SetLength(LArgs, LSignature.ArgumentCount + 1);
  LArgs[0].AsPointer := PPointer(@ADump.Bytes[LSignature.DumpOptions.ThisOffset])^;
  LArgument := @LSignature.Arguments[0];
  LTopArgument := @LSignature.Arguments[LSignature.ArgumentCount];
  LValue := @LArgs[1];
  if (LArgument <> LTopArgument) then
  repeat
    LSource := @ADump.Bytes[LArgument.Offset];
    if (LArgument.Qualifier >= rqValueRef{IsReference}) then
    begin
      LSource := PPointer(LSource)^;
    end;
    LValue.Init(LArgument^, LSource);

    Inc(LArgument);
    Inc(LValue);
  until (LArgument = LTopArgument);

  // event
  {$ifdef CPUARM64}
    if (LSignature.Return.Offset = INVALID_INDEX) then
    begin
      PEvent(Pointer(Self))^(AMethod, LArgs, ADump.ReturnAddress);
    end else
    begin
      LResult := PEvent(Pointer(Self))^(AMethod, LArgs, ADump.ReturnAddress);
    end;
  {$else}
    PEvent(Pointer(Self))^(AMethod, LArgs, ADump.ReturnAddress, LResult);
  {$endif}

  // result
  if (LSignature.Return.Offset <> INVALID_INDEX) then
  begin
    LSource := LResult.Data;
    LValueRec := Pointer(@LResult);
    if (LValueRec.FExType.Options = LSignature.Return.Options) and
      (
        Assigned(RTTI_TYPE_RULES[LValueRec.FExType.BaseType]) or
        (LValueRec.FExType.CustomData = LSignature.Return.CustomData)
      ) then
    begin
      // LSource := LSource;
    end else
    begin
      LBuffer.Init(LBufferIntf);
      LBuffer.ExType := LValueRec.FExType;
      LSource := LBuffer.Convert(LSignature.Return, LSource)
    end;

    LTarget := @ADump.Bytes[LSignature.Return.Offset];
    if (LSignature.Return.Qualifier >= rqValueRef{IsReference}) then
    begin
      LTarget := PPointer(LTarget)^;
    end;

    case Cardinal(LSignature.Return.SetterFunc) of
      0: PPointer(LTarget)^ := LSource;
      1: PPointer(LTarget)^ := PPointer(LSource)^;
      2: PAlterNativeInt(LTarget)^ := PAlterNativeInt(LSource)^;
    else
      RTTI_COPY_FUNCS[LSignature.Return.SetterFunc](@LSignature.Return, LTarget, LSource);
    end;
  end;
end;

function TRttiVirtualInterface.Std_AddRef: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer{$else}Longint{$ifend};
begin
  Result := TRttiVirtualInterface(NativeInt(Self) -
    INTERFACED_OBJECT_INTF_OFFSET)._AddRef;
end;

function TRttiVirtualInterface.Std_Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer{$else}Longint{$ifend};
begin
  Result := TRttiVirtualInterface(NativeInt(Self) -
    INTERFACED_OBJECT_INTF_OFFSET)._Release;
end;

function TRttiVirtualInterface.Std_QueryInterface({$ifdef FPC}constref{$else}const{$endif} IID: TGUID; out Obj): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult{$else}Longint{$ifend};
begin
  Result := TRttiVirtualInterface(NativeInt(Self) -
    INTERFACED_OBJECT_INTF_OFFSET).QueryInterface(IID, Obj);
end;

function TRttiVirtualInterface.Vmt_AddRef: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer{$else}Longint{$ifend};
begin
  Result := TRttiVirtualInterface(NativeInt(Self) -
    NativeInt(@TRttiVirtualInterface(nil).FTable.Vmt))._AddRef;
end;

function TRttiVirtualInterface.Vmt_Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer{$else}Longint{$ifend};
begin
  Result := TRttiVirtualInterface(NativeInt(Self) -
    NativeInt(@TRttiVirtualInterface(nil).FTable.Vmt))._Release;
end;

function TRttiVirtualInterface.Vmt_QueryInterface({$ifdef FPC}constref{$else}const{$endif} IID: TGUID; out Obj): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult{$else}Longint{$ifend};
begin
  Result := TRttiVirtualInterface(NativeInt(Self) -
    NativeInt(@TRttiVirtualInterface(nil).FTable.Vmt)).QueryInterface(IID, Obj);
end;

function TRttiVirtualInterface._AddRef: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer{$else}Longint{$ifend};
begin
  Result := inherited _AddRef;
end;

function TRttiVirtualInterface._Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer{$else}Longint{$ifend};
begin
  Result := inherited _Release;
end;

function TRttiVirtualInterface.QueryInterface({$ifdef FPC}constref{$else}const{$endif} IID: TGUID; out Obj): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult{$else}Longint{$ifend};
var
  i: Integer;
  LSource, LTarget: PGUIDRec;
begin
  LSource := Pointer(@IID);
  LTarget := Pointer(FGuids);
  for i := Low(FGuids) to High(FGuids) do
  begin
    if (LSource.Low = LTarget.Low) and (LSource.High = LTarget.High) then
    begin
      _AddRef;
      Pointer(Obj) := @FTable.Vmt;
      Result := S_OK;
      Exit;
    end;

    Inc(LTarget);
  end;

  Result := inherited QueryInterface(IID, Obj);
end;

constructor TRttiVirtualInterface.CreateDirect(const AGuids: TGuidDynArray;
  const AMethods: TRttiVirtualMethodDataDynArray);
var
  i, LCount: Integer;
  {$ifdef WEAKINSTREF}[Unsafe]{$endif} LErrorMethodIndex: procedure of object;
  LInterceptJump: Pointer;
  LDefaultCallConv: TRttiCallConv;
  LSignature: PRttiSignature;
begin
  inherited Create;

  if (INTERFACED_OBJECT_INTF_OFFSET = 0) then
  begin
    INTERFACED_OBJECT_INTF_OFFSET := PInterfaceTable(PPointer(NativeInt(TInterfacedObject) + vmtIntfTable)^).Entries[0].IOffset
  end;

  PPointer(NativeInt(Self) + INTERFACED_OBJECT_INTF_OFFSET)^ := @FTable;
  FTable.StdAddresses[0] := @TRttiVirtualInterface.Std_QueryInterface;
  FTable.StdAddresses[1] := @TRttiVirtualInterface.Std_AddRef;
  FTable.StdAddresses[2] := @TRttiVirtualInterface.Std_Release;

  FGuids := AGuids;
  FTable.Methods := AMethods;
  LCount := Length(AMethods);
  SetLength(FTable.Vmt, 3 + LCount);
  FTable.Vmt[0] := @TRttiVirtualInterface.Vmt_QueryInterface;
  FTable.Vmt[1] := @TRttiVirtualInterface.Vmt_AddRef;
  FTable.Vmt[2] := @TRttiVirtualInterface.Vmt_Release;
  LDefaultCallConv := Low(TRttiCallConv);
  LErrorMethodIndex := DoErrorMethodIndex;
  for i := 0 to LCount - 1 do
  begin
    if (i <= 1023) then
    begin
      LSignature := AMethods[i].Method.Signature;
      if (not Assigned(LSignature)) then
      begin
        LSignature := Pointer(@LDefaultCallConv);
      end;

      LInterceptJump := LSignature.InterceptJumps[i];
    end else
    begin
      LInterceptJump := TMethod(LErrorMethodIndex).Code;
    end;

    FTable.Vmt[3 + i] := LInterceptJump;
  end;
end;

constructor TRttiVirtualInterface.CreateDirect(const AIntfType: PTypeInfo;
  const ADefaultCallback: TRttiVirtualMethodCallback;
  const ARttiContext: PRttiContext;
  const AInvokeConfigure: TRttiVirtualInterfaceInvokeConfigure);
const
  METHOD_UNKNOWN: array[0..7] of Byte = (7, Ord('U'), Ord('N'), Ord('K'), Ord('N'),
    Ord('O'), Ord('W'), Ord('N'));
var
  i: Integer;
  LCount, LMethodCount: Integer;
  LGuids: TGuidDynArray;
  LMethods: TRttiVirtualMethodDataDynArray;
  LRttiContext: PRttiContext;
  LTypeInfo: PTypeInfo;
  LTypeData: PTypeData;
  LGuid: PGUIDRec;
  LMethodData, LStoredMethodData: PRttiVirtualMethodData;
  LIntfMethods: PIntfMethodTable;
  LIntfEntry: PIntfMethodEntry;
  LSignature: TRttiSignature;
  LUniversalInterceptFunc: TRttiInterceptFunc;
  {$ifdef WEAKINSTREF}[Unsafe]{$endif} LErrorCallback: TRttiVirtualMethodCallback;
begin
  if (NativeUInt(AIntfType) <= $ffff) then
  begin
    System.Error(reAccessViolation);
  end;

  if (AIntfType.Kind <> tkInterface) then
  begin
    System.Error(reInvalidPtr);
  end;

  LRttiContext := ARttiContext;
  if (not Assigned(ARttiContext)) then
  begin
    LRttiContext := @DefaultContext;
  end;

  {$ifdef EXTENDEDRTTI}
    FDefaultCallback := ADefaultCallback;
  {$else}
    FDefaultInvokeCallback := ADefaultCallback;
    FDefaultCallback := InternalGetCallback(ADefaultCallback);
  {$endif}

  // guids, method count
  LCount := 0;
  LMethodCount := 0;
  LTypeInfo := AIntfType;
  repeat
    LTypeData := LTypeInfo.TypeData;
    LGuid := Pointer(@LTypeData.InterfaceData.Guid);
    if (LGuid.Low <> 0) or
      (
        (LGuid.High <> 0) {00000000-0000-0000-0000-000000000000} and
        (LGuid.High <> $46000000000000C0) {00000000-0000-0000-C000-000000000046}
      ) then
    begin
      Inc(LCount);
      SetLength(LGuids, LCount);
      LGuids[LCount - 1] := PGUID(LGuid)^;
    end;

    LIntfMethods := LTypeData.InterfaceData.MethodTable;
    if (Assigned(LIntfMethods)) then
    begin
      Inc(LMethodCount, LIntfMethods.Count);
    end;

    LTypeInfo := LTypeData.InterfaceData.Parent.Value;
  until (not (Assigned(LTypeInfo)));

  // clear
  LCount := LMethodCount - 3;
  if (LCount < 0) then
  begin
    LCount := 0;
  end;
  SetLength(LMethods, LCount);
  LMethodData := Pointer(LMethods);
  for i := 0 to LCount - 1 do
  begin
    LMethodData.Method.Name := Pointer(@METHOD_UNKNOWN);
    LMethodData.Method.Signature := nil;
    Inc(LMethodData);
  end;

  // initialization
  LMethodData := Pointer(LMethods);
  Inc(LMethodData, LCount);
  LTypeInfo := AIntfType;
  repeat
    LTypeData := LTypeInfo.TypeData;
    LIntfMethods := LTypeData.InterfaceData.MethodTable;
    if (Assigned(LIntfMethods)) then
    begin
      Dec(LMethodData, LIntfMethods.Count);
      Dec(LCount, LIntfMethods.Count);
      LStoredMethodData := LMethodData;

      LIntfEntry := @LIntfMethods.Entries;
      if (LIntfMethods.RttiCount <> High(Word)) then
      for i := 0 to Integer(LIntfMethods.RttiCount) - 1 do
      begin
        LMethodData.Method.Name := @LIntfEntry.Name;
        if (LSignature.Init(LIntfEntry.Signature^, LRttiContext)) then
        begin
          LMethodData.Method.Signature := InternalCopySignature(LSignature);
        end;

        Inc(LMethodData);
        LIntfEntry := LIntfEntry.Tail;
      end;

      LMethodData := LStoredMethodData;
    end;

    LTypeInfo := LTypeData.InterfaceData.Parent.Value;
  until (not (Assigned(LTypeInfo)) or (LCount <= 0));

  // method options
  LMethodData := Pointer(LMethods);
  LUniversalInterceptFunc := TRttiSignature(nil^).UniversalInterceptFunc;
  LErrorCallback := DoErrorCallback;
  for i := Low(LMethods) to High(LMethods) do
  begin
    LMethodData.Method.Index := 3 + i;
    LMethodData.Method.Context := nil;
    if (Assigned(LMethodData.Method.Signature)) then
    begin
      LMethodData.InterceptFunc := LMethodData.Method.Signature.OptimalInterceptFunc;
      LMethodData.Callback := FDefaultCallback;
    end else
    begin
      LMethodData.InterceptFunc := LUniversalInterceptFunc;
      LMethodData.Callback := LErrorCallback;
    end;

    Inc(LMethodData);
  end;
  if (Assigned(AInvokeConfigure)) then
  begin
    AInvokeConfigure(LGuids, LMethods);
  end;

  // construction
  CreateDirect(LGuids, LMethods);
end;

{$ifdef EXTENDEDRTTI}
constructor TRttiVirtualInterface.CreateDirect(const AIntfType: PTypeInfo;
  const ADefaultInvokeCallback: TRttiVirtualMethodInvokeCallback;
  const ARttiContext: PRttiContext;
  const AInvokeConfigure: TRttiVirtualInterfaceInvokeConfigure);
begin
  FDefaultInvokeCallback := ADefaultInvokeCallback;
  CreateDirect(AIntfType, InternalGetCallback(ADefaultInvokeCallback),
    ARttiContext, AInvokeConfigure);
end;
{$endif}

constructor TRttiVirtualInterface.Create(const AIntfType: PTypeInfo;
  const ADefaultInvokeEvent: TRttiVirtualMethodInvokeEvent;
  const ARttiContext: PRttiContext;
  const AInvokeConfigure: TRttiVirtualInterfaceInvokeConfigure);
begin
  FDefaultInvokeEvent := ADefaultInvokeEvent;
  CreateDirect(AIntfType, GetCallback(FDefaultInvokeEvent),
    ARttiContext, AInvokeConfigure);
end;

destructor TRttiVirtualInterface.Destroy;
var
  LItem, LNext: Pointer;
begin
  LItem := FHeapItems;
  FHeapItems := nil;

  while (Assigned(LItem)) do
  begin
    LNext := PPointer(LItem)^;
    FreeMem(LItem);

    LItem := LNext;
  end;

  inherited;
end;

end.
