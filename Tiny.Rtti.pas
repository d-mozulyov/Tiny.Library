unit Tiny.Rtti;

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
{ repository: https://github.com/d-mozulyov/Tiny.Library                       }
{******************************************************************************}

{$I TINY.DEFINES.inc}
{$if not Defined(FPC) and (CompilerVersion < 20)}
  {$undef OPERATORSUPPORT}
{$ifend}
{$if Defined(OPERATORSUPPORT) and not Defined(BCB)}
  {$define VALUEOPERATORSUPPORT}
{$ifend}

interface
uses
  {$if Defined(MSWINDOWS)}
    {$ifdef UNITSCOPENAMES}Winapi.Windows{$else}Windows{$endif},
  {$elseif Defined(FPC)}
    //BaseUnix,
  {$else .POSIX}
    Posix.Sched, Posix.Unistd, Posix.Pthread,
  {$ifend}
  Tiny.Types;


type

{ TCharacters class
  Low level string convertion singleton }

  TCharacters = class
  public
    class function LStrLen(const S: PAnsiChar): NativeUInt; {$ifdef STATICSUPPORT}static;{$endif}
    class function WStrLen(const S: PWideChar): NativeUInt; {$ifdef STATICSUPPORT}static;{$endif}
    class function UStrLen(const S: PUCS4Char): NativeUInt; {$ifdef STATICSUPPORT}static;{$endif}
    class function UCS4StringLen(const S: UCS4String): NativeUInt; {$ifdef STATICSUPPORT}static;{$endif}

    class function PSBCSChars(const S: AnsiString): PAnsiChar; {$ifdef STATICSUPPORT}static;{$endif} {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    class function PUTF8Chars(const S: UTF8String): PUTF8Char; {$ifdef STATICSUPPORT}static;{$endif} {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    class function PWideChars(const S: UnicodeString): PWideChar; {$ifdef STATICSUPPORT}static;{$endif} {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    class function PUCS4Chars(const S: UCS4String): PUCS4Char; {$ifdef STATICSUPPORT}static;{$endif} {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}

    {$ifNdef MSWINDOWS}
    class function MultiByteToWideChar(CodePage, Flags: Cardinal; LocaleStr: PAnsiChar;
      LocaleStrLen: Integer; UnicodeStr: PWideChar; UnicodeStrLen: Integer): Integer; static; inline;
    class function WideCharToMultiByte(CodePage, Flags: Cardinal;
      UnicodeStr: PWideChar; UnicodeStrLen: Integer; LocaleStr: PAnsiChar;
      LocaleStrLen: Integer; DefaultChar: PAnsiChar; UsedDefaultChar: Pointer): Integer; static; inline;
    {$endif}

    class function UCS4CharFromUnicode(
      const ASource: PWideChar; const ASourceCount: NativeUInt): UCS4Char; {$ifdef STATICSUPPORT}static;{$endif}
    class function UCS4CharFromAnsi(const ASourceCP: Word;
      const ASource: PAnsiChar; const ASourceCount: NativeUInt): UCS4Char; {$ifdef STATICSUPPORT}static;{$endif}

    class function UCS4FromUnicode(const ATarget: PUCS4Char;
      const ASource: PWideChar; const ASourceCount: NativeUInt): NativeUInt; overload; {$ifdef STATICSUPPORT}static;{$endif}
    class procedure UCS4FromUnicode(var ATarget: UCS4String;
      const ASource: PWideChar; const ASourceCount: NativeUInt); overload; {$ifdef STATICSUPPORT}static;{$endif}
    class procedure UCS4FromAnsi(var ATarget: UCS4String; const ASourceCP: Word;
      const ASource: PAnsiChar; const ASourceCount: NativeUInt); {$ifdef STATICSUPPORT}static;{$endif}

    class function UnicodeFromUCS4(const ATarget: PWideChar;
      const ASource: PUCS4Char; const ASourceCount: NativeUInt): NativeUInt; overload; {$ifdef STATICSUPPORT}static;{$endif}
    class procedure UnicodeFromUCS4(var ATarget: WideString;
      const ASource: PUCS4Char; const ASourceCount: NativeUInt); overload; {$ifdef STATICSUPPORT}static;{$endif}
    {$ifdef UNICODE}
    class procedure UnicodeFromUCS4(var ATarget: UnicodeString;
      const ASource: PUCS4Char; const ASourceCount: NativeUInt); overload; {$ifdef STATICSUPPORT}static;{$endif}
    {$endif}
    class procedure UnicodeFromAnsi(var ATarget: WideString;
      const ASourceCP: Word; const ASource: PAnsiChar; const ASourceCount: NativeUInt);
    {$ifdef UNICODE} overload; {$ifdef STATICSUPPORT}static;{$endif}
    class procedure UnicodeFromAnsi(var ATarget: UnicodeString;
      const ASourceCP: Word; const ASource: PAnsiChar; const ASourceCount: NativeUInt); overload; {$ifdef STATICSUPPORT}static;{$endif}
    {$endif}

    class procedure AnsiFromUnicode(const ATargetCP: Word; var ATarget: AnsiString;
      const ASource: PWideChar; const ASourceCount: NativeUInt); {$ifdef STATICSUPPORT}static;{$endif}
    class procedure AnsiFromAnsi(const ATargetCP: Word; var ATarget: AnsiString;
      const ASourceCP: Word; const ASource: PAnsiChar; const ASourceCount: NativeUInt); {$ifdef STATICSUPPORT}static;{$endif}
    class procedure AnsiFromUCS4(const ATargetCP: Word; var ATarget: AnsiString;
      const ASource: PUCS4Char; const ASourceCount: NativeUInt); {$ifdef STATICSUPPORT}static;{$endif}

    class procedure ShortStringFromUnicode(var ATarget: ShortString; const AMaxLength: Byte;
      const ASource: PWideChar; const ASourceCount: NativeUInt); {$ifdef STATICSUPPORT}static;{$endif}
    class procedure ShortStringFromAnsi(var ATarget: ShortString; const AMaxLength: Byte;
      const ASourceCP: Word; const ASource: PAnsiChar; const ASourceCount: NativeUInt); {$ifdef STATICSUPPORT}static;{$endif}
    class procedure ShortStringFromUCS4(var ATarget: ShortString; const AMaxLength: Byte;
      const ASource: PUCS4Char; const ASourceCount: NativeUInt); {$ifdef STATICSUPPORT}static;{$endif}
  end;


type

{ ShortStringHelper object
  High-level helper over standard ShortString type }

  PShortStringHelper = ^ShortStringHelper;
  {$A1}
  {$ifdef BCB}
  ShortStringHelper = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  ShortStringHelper = object protected
  {$endif}
    function GetValue: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetValue(const AValue: Integer); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure InternalGetAnsiString(var Result: AnsiString);
    procedure InternalGetUTF8String(var Result: UTF8String);
    procedure InternalGetUnicodeString(var Result: UnicodeString);
    function GetAnsiString: AnsiString; {$ifNdef CPUINTELASM}inline;{$endif}
    function GetUTF8String: UTF8String; {$ifNdef CPUINTELASM}inline;{$endif}
    function GetUnicodeString: UnicodeString; {$ifNdef CPUINTELASM}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Value: ShortString;

    property Length: Integer read GetValue write SetValue;
    property AsAnsiString: AnsiString read GetAnsiString;
    property AsUTF8String: UTF8String read GetUTF8String;
    property AsUnicodeString: UnicodeString read GetUnicodeString;
    property AsString: string read {$ifdef UNICODE}GetUnicodeString{$else .ANSI}GetAnsiString{$endif};
    property Tail: Pointer read GetTail;
  end;
  {$A4}


type

{ Internal RTTI enumerations }

  PTypeKind = ^TTypeKind;
  {$if Defined(FPC)}
    TTypeKind = (tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat,
      tkSet, tkMethod, tkSString, tkLString, tkAString, tkWString, tkVariant,
      tkArray, tkRecord, tkInterface, tkClass, tkObject, tkWChar, tkBool, tkInt64,
      tkQWord, tkDynArray, tkInterfaceRaw, tkProcVar, tkUString, tkUChar, tkHelper,
      tkFile, tkClassRef, tkPointer);
  {$elseif (CompilerVersion >= 28)}
    TTypeKind = System.TTypeKind;
  {$else}
    TTypeKind = (tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat,
      tkString, tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString,
      tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
      {$ifdef UNICODE}
      , tkUString
      {$endif}
      {$ifdef EXTENDEDRTTI}
      , tkClassRef, tkPointer, tkProcedure
      {$endif}
      {$ifdef MANAGEDRECORDS}
      , tkMRecord
      {$endif});
  {$ifend}
  PTypeKinds = ^TTypeKinds;
  TTypeKinds = set of TTypeKind;

  POrdType = ^TOrdType;
  TOrdType = (otSByte, otUByte, otSWord, otUWord, otSLong, otULong);

  PFloatType = ^TFloatType;
  TFloatType = (ftSingle, ftDouble, ftExtended, ftComp, ftCurr);
  PFloatTypes = ^TFloatTypes;
  TFloatTypes = set of TFloatType;

  PMethodKind = ^TMethodKind;
  TMethodKind = (mkProcedure, mkFunction, mkConstructor, mkDestructor,
    mkClassProcedure, mkClassFunction
    {$if Defined(FPC) or (CompilerVersion >= 21)}
    , mkClassConstructor, mkClassDestructor, mkOperatorOverload
    {$ifend}
    {$ifNdef FPC}
    , mkSafeProcedure, mkSafeFunction
    {$endif}
    );
  PMethodKinds = ^TMethodKinds;
  TMethodKinds = set of TMethodKind;

  PParamFlag = ^TParamFlag;
  TParamFlag = (pfVar, pfConst, pfArray, pfAddress, pfReference, pfOut, pfResult);
  PParamFlags = ^TParamFlags;
  TParamFlags = set of TParamFlag;

  PIntfFlag = ^TIntfFlag;
  TIntfFlag = (ifHasGuid, ifDispInterface, ifDispatch{$ifdef FPC}, ifHasStrGUID{$endif});

  PIntfFlags = ^TIntfFlags;
  TIntfFlags = set of TIntfFlag;

  PDispatchKind = ^TDispatchKind;
  TDispatchKind = (dkStatic, dkVtable, dkDynamic, dkMessage, dkInterface);
  PDispatchKinds = ^TDispatchKinds;
  TDispatchKinds = set of TDispatchKind;

  PMemberVisibility = ^TMemberVisibility;
  TMemberVisibility = (mvPrivate, mvProtected, mvPublic, mvPublished);
  PMemberVisibilities = ^TMemberVisibilities;
  TMemberVisibilities = set of TMemberVisibility;

  PCallConv = ^TCallConv;
  TCallConv = (ccReg, ccCdecl, ccPascal, ccStdCall, ccSafeCall
    {$ifdef FPC}
    , ccCppdecl, ccFar16, ccOldFPCCall, ccInternProc, ccSysCall, ccSoftFloat, ccMWPascal
    {$endif}
  );
  PCallConvs = ^TCallConvs;
  TCallConvs = set of TCallConv;

  PReference = ^TReference;
  TReference = (rfDefault, rfUnsafe, rfWeak);
  PReferences = ^TReferences;
  TReferences = set of TReference;

  PArgumentQualifier = ^TArgumentQualifier;
  TArgumentQualifier = (aqValue, aqConst, aqConstRef{FreePascal}, aqVar, aqOut,
    aqArrayValue, aqArrayConst, aqArrayVar, aqArrayOut);
  PArgumentQualifiers = ^TArgumentQualifiers;
  TArgumentQualifiers = set of TArgumentQualifier;

{$ifdef FPC}
const
  tkString = tkSString;
  tkProcedure = tkProcVar;
{$endif}


{ Internal RTTI attribute routine }

type
  {$ifdef EXTENDEDRTTI}
  PAttrData = ^TAttrData;
  PVmtMethodSignature = ^TVmtMethodSignature;

  PAttrEntryReader = ^TAttrEntryReader;
  {$A1}
  {$ifdef BCB}
  TAttrEntryReader = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TAttrEntryReader = object protected
  {$endif}
    function RangeError: Pointer;
    function GetEOF: Boolean;
    function GetMargin: NativeUInt;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Current: PByte;
    Overflow: PByte;

    procedure ReadData(var ABuffer; const ASize: NativeUInt); {$ifdef INLINESUPPORT}inline;{$endif}
    function Reserve(const ASize: NativeUInt): Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadAnsiChar: AnsiChar; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadWideChar: WideChar; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadUCS4Char: UCS4Char; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadShortInt: ShortInt; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadByte: Byte; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadSmallInt: SmallInt; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadWord: Word; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadSingle: Single; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadDouble: Double; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadExtended: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadComp: Comp; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadCurrency: Currency; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadPointer: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadTypeInfo: Pointer{PTypeInfo}; {$ifdef INLINESUPPORT}inline;{$endif}
    function ReadClass: TClass;
    function ReadShortString: ShortString;
    function ReadUTF8String: UTF8String;
    function ReadString: string;

    property EOF: Boolean read GetEOF;
    property Margin: NativeUInt read GetMargin;
  end;
  {$A4}

  PAttrEntry = ^TAttrEntry;
  {$A1}
  {$ifdef BCB}
  TAttrEntry = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TAttrEntry = object protected
  {$endif}
    function GetClassType: TClass; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetConstructorSignature: PVmtMethodSignature;
    function GetReader: TAttrEntryReader; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    AttrType: Pointer{PTypeInfoRef};
    AttrCtor: Pointer;
    ArgLen: Word;
    ArgData: array[1..65536 {ArgLen - 2}] of Byte;
    property Size: Word read ArgLen;
    property ClassType: TClass read GetClassType;
    property ConstructorAddress: Pointer read AttrCtor;
    property ConstructorSignature: PVmtMethodSignature read GetConstructorSignature;
    property Reader: TAttrEntryReader read GetReader;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  {$A1}
  {$ifdef BCB}
  TAttrData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TAttrData = object protected
  {$endif}
    function GetValue: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCount: Integer;
    function GetReference: TReference; {$if Defined(INLINESUPPORT) and not Defined(WEAKREF)}inline;{$ifend}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Len: Word;
    Entries: TAttrEntry;
    {Entries: array[] of TAttrEntry;}
    property Value: PAttrData read GetValue;
    property Tail: Pointer read GetTail;
    property Count: Integer read GetCount;
    property Reference: TReference read GetReference;
  end;
  {$A4}
  {$endif .EXTENDEDRTTI}


{ Internal RTTI structures }

  PTypeData = ^TTypeData;
  PPTypeInfo = ^PTypeInfo;
  PTypeInfo = ^TTypeInfo;
  {$A1}
  {$ifdef BCB}
  TTypeInfo = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TTypeInfo = object protected
  {$endif}
    function GetTypeData: PTypeData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrData: PAttrData;
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Kind: TTypeKind;
    Name: ShortStringHelper;

    property TypeData: PTypeData read GetTypeData;
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;
  {$A4}

  PPTypeInfoRef = ^PTypeInfoRef;
  {$A1}
  {$ifdef BCB}
  PTypeInfoRef = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  PTypeInfoRef = {$ifdef SMALLOBJECTSUPPORT}object{$else}class{$endif} protected
  {$endif}
    {$ifdef SMALLOBJECTSUPPORT}
    F: packed record
    case Integer of
      0: (Value: {$ifdef FPC}PTypeInfo{$else .DELPHI}PPTypeInfo{$endif});
      1: (Address: Pointer);
    end;
    {$else}
    function GetAddress: Pointer;
    {$endif}
    function GetAssigned: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef FPC}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    property Value: PTypeInfo read F.Value;
  {$else .DELPHI}
    function GetValue: PTypeInfo; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    property Value: PTypeInfo read GetValue;
  {$endif}
    property Address: Pointer read {$ifdef SMALLOBJECTSUPPORT}F.Address{$else}GetAddress{$endif};
    property Assigned: Boolean read GetAssigned;
  end;
  {$A4}

  PParamData = ^TParamData;
  {$A1}
  {$ifdef BCB}
  TParamData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TParamData = object protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Name: PShortStringHelper;
    Reference: TReference;
    TypeInfo: PTypeInfo;
    TypeName: PShortStringHelper;
  end;
  {$A4}

  PResultData = ^TResultData;
  {$A1}
  {$ifdef BCB}
  TResultData__ = record [HPPGEN(HPP_INHERIT + '(TResultData, TParamData)'#13#10)] _: Byte; end;
  TResultData = record public
    [HPPGEN(HPP_RETRIEVE + '(TParamData)'#13#10)] This: TParamData;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TResultData = object(TParamData) protected
  {$endif}
    {$ifdef WEAKREF}
    procedure InitReference(const AAttrData: PAttrData);
    {$endif}
    function GetAssigned: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    property Assigned: Boolean read GetAssigned;
  end;
  {$A4}

  PAttributedParamData = ^TAttributedParamData;
  {$A1}
  {$ifdef BCB}
  TAttributedParamData__ = record [HPPGEN(HPP_INHERIT + '(TAttributedParamData, TParamData)'#13#10)] _: Byte; end;
  TAttributedParamData = record public
    [HPPGEN(HPP_RETRIEVE + '(TParamData)'#13#10)] This: TParamData;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TAttributedParamData = object(TParamData) protected
  {$endif}
    {$ifdef WEAKREF}
    procedure InitReference;
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    {$ifdef EXTENDEDRTTI}
    AttrData: PAttrData;
    {$endif}
  end;
  {$A4}

  PArgumentData = ^TArgumentData;
  {$A1}
  {$ifdef BCB}
  TArgumentData__ = record [HPPGEN(HPP_INHERIT + '(TArgumentData, TAttributedParamData)'#13#10)] _: Byte; end;
  TArgumentData = record public
    [HPPGEN(HPP_RETRIEVE + '(TAttributedParamData)'#13#10)] This: TAttributedParamData;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TArgumentData = object(TAttributedParamData) protected
  {$endif}
    {$ifdef WEAKREF}
    procedure InitReference; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Flags: TParamFlags;
  end;
  {$A4}

  PFieldData = ^TFieldData;
  {$A1}
  {$ifdef BCB}
  TFieldData__ = record [HPPGEN(HPP_INHERIT + '(TFieldData, TAttributedParamData)'#13#10)] _: Byte; end;
  TFieldData = record public
    [HPPGEN(HPP_RETRIEVE + '(TAttributedParamData)'#13#10)] This: TAttributedParamData;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TFieldData = object(TAttributedParamData) protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Visibility: TMemberVisibility;
    Offset: Cardinal;
  end;
  {$A4}

  PSignatureData = ^TSignatureData;
  TSignatureData = packed record
    MethodKind: TMethodKind;
    HasSelf: Boolean;
    CallConv: TCallConv;
    Result: TResultData;
    ArgumentCount: Integer;
    Arguments: array[Byte] of TArgumentData;
  end;

  PPropInfo = ^TPropInfo;
  {$A1}
  {$ifdef BCB}
  TPropInfo = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TPropInfo = object protected
  {$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    PropType: PTypeInfoRef;
    GetProc: Pointer;
    SetProc: Pointer;
    StoredProc: Pointer;
    Index: Integer;
    Default: Integer;
    NameIndex: SmallInt;
    {$ifdef FPC}
    PropProcs: Byte;
    {$endif}
    Name: ShortStringHelper;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PPropData = ^TPropData;
  {$A1}
  {$ifdef BCB}
  TPropData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TPropData = object protected
  {$endif}
    function GetTail: Pointer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    PropCount: Word;
    PropList: TPropInfo;
    {PropList: array[1..PropCount] of TPropInfo;}
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  TPropInfoProc = procedure(PropInfo: PPropInfo) of object;
  PPropList = ^TPropList;
  TPropList = array[0..16379] of PPropInfo;

  PManagedField = ^TManagedField;
  {$A1}
  {$ifdef BCB}
  TManagedField = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TManagedField = object protected
  {$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    TypeRef: PTypeInfoRef;
    FldOffset: NativeInt;
    property Tail:Pointer read GetTail;
  end;
  {$A4}

  PVmtFieldClassTab = ^TVmtFieldClassTab;
  {$A1}
  {$ifdef BCB}
  TVmtFieldClassTab = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtFieldClassTab = object protected
  {$endif}
    {$ifNdef FPC}
    function GetClass(const AIndex: Word): TClass; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Count: Word;
    {$ifdef FPC}
    Classes: array[Word] of TClass;
    {$else .DELPHI}
    ClassRef: array[Word] of ^TClass;
    property Classes[const AIndex: Word]: TClass read GetClass;
    {$endif}
  end;
  {$A4}

  PVmtFieldEntry = ^TVmtFieldEntry;
  {$A1}
  {$ifdef BCB}
  TVmtFieldEntry = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtFieldEntry = object protected
  {$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    FieldOffset: InternalUInt;
    TypeIndex: Word; // index into ClassTab
    Name: ShortStringHelper;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PVmtFieldTable = ^TVmtFieldTable;
  {$A1}
  {$ifdef BCB}
  TVmtFieldTable = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtFieldTable = object protected
  {$endif}
    function GetTail: Pointer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Count: Word; // Published fields
    ClassTab: PVmtFieldClassTab;
    Entries: TVmtFieldEntry;
    {Entries: array[1..Count] of TVmtFieldEntry;
    Tail: TVmtFieldTableEx;}
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PVmtMethodEntry = ^TVmtMethodEntry;
  {$A1}
  {$ifdef BCB}
  TVmtMethodEntry = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtMethodEntry = object protected
  {$endif}
    {$ifdef EXTENDEDRTTI}
    function GetSignature: PVmtMethodSignature; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Len: Word;
    CodeAddress: Pointer;
    Name: ShortStringHelper;
    {Signature: TVmtMethodSignature;} // only exists if Len indicates data here
    {$ifdef EXTENDEDRTTI}
    property Signature: PVmtMethodSignature read GetSignature;
    {$endif}
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PVmtMethodTable = ^TVmtMethodTable;
  {$A1}
  {$ifdef BCB}
  TVmtMethodTable = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtMethodTable = object protected
  {$endif}
    function GetTail: Pointer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Count: Word;
    Entries: TVmtMethodEntry;
    {Entries: array[1..Count] of TVmtMethodEntry;
    Tail: TVmtMethodTableEx;}
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PIntfMethodParamTail = ^TIntfMethodParamTail;
  {$A1}
  {$ifdef BCB}
  TIntfMethodParamTail = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TIntfMethodParamTail = object protected
  {$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    ParamType: PTypeInfoRef;
    {$ifdef EXTENDEDRTTI}
    AttrDataRec: TAttrData; // not currently entered
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;
  {$A4}

  PIntfMethodParam = ^TIntfMethodParam;
  {$A1}
  {$ifdef BCB}
  TIntfMethodParam = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TIntfMethodParam = object protected
  {$endif}
    function GetTypeName: PShortStringHelper; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetParamTail: PIntfMethodParamTail; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetParamType: PTypeInfo; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function GetData: TArgumentData;
    function GetTail: Pointer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Flags: TParamFlags;
    ParamName: ShortStringHelper;
    {TypeName: ShortStringHelper;
    ParamTail: TIntfMethodParamTail;}
    property TypeName: PShortStringHelper read GetTypeName;
    property ParamType: PTypeInfo read GetParamType;
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
    property Data: TArgumentData read GetData;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PIntfMethodSignature = ^TIntfMethodSignature;
  {$A1}
  {$ifdef BCB}
  TIntfMethodSignature = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TIntfMethodSignature = object protected
  {$endif}
    function GetParamsTail: PByte;
    function GetResultData: TResultData;
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData;
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Kind: Byte; // 0=proc or 1=func
    CC: TCallConv;
    ParamCount: Byte;
    Params: TIntfMethodParam;
    {Params: array[1..ParamCount] of TIntfMethodParam;
    ResultTypeName: ShortStringHelper; // only if func
    ResultType: PTypeInfoRef; // only if Len(Name) > 0
    AttrData: TAttrData;}
    function GetData(var AData: TSignatureData): Integer;
    property ResultData: TResultData read GetResultData;
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PIntfMethodEntryTail = ^TIntfMethodEntryTail;
  TIntfMethodEntryTail = {$ifdef BCB}TIntfMethodSignature{$else}object(TIntfMethodSignature) end{$endif};

  PIntfMethodEntry = ^TIntfMethodEntry;
  {$A1}
  {$ifdef BCB}
  TIntfMethodEntry = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TIntfMethodEntry = object protected
  {$endif}
    function GetSignature: PIntfMethodSignature; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Name: ShortStringHelper;
    {Signature: TIntfMethodSignature;}
    property Signature: PIntfMethodSignature read GetSignature;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PIntfMethodTable = ^TIntfMethodTable;
  {$A1}
  {$ifdef BCB}
  TIntfMethodTable = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TIntfMethodTable = object protected
  {$endif}
    function GetHasEntries: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData;
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Count: Word; // methods in this interface
    RttiCount: Word; // = Count, or $FFFF if no further data
    Entries: TIntfMethodEntry;
    {Entries: array[1..Count] of TIntfMethodEntry;
    AttrData: TAttrData;}
    property HasEntries: Boolean read GetHasEntries;
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;
  {$A4}

  {$if Defined(FPC) or Defined(EXTENDEDRTTI)}
  PProcedureParam = ^TProcedureParam;
  {$A1}
  {$ifdef BCB}
  TProcedureParam = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TProcedureParam = object protected
  {$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function GetData: TArgumentData;
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Flags: TParamFlags;
    ParamType: PTypeInfoRef;
    Name: ShortStringHelper;
    {AttrData: TAttrData;}
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
    property Data: TArgumentData read GetData;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PProcedureSignature = ^TProcedureSignature;
  {$A1}
  {$ifdef BCB}
  TProcedureSignature = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TProcedureSignature = object protected
  {$endif}
    function GetIsValid: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetResultData: TResultData;
    function GetTail: Pointer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Flags: Byte; // if 255 then record stops here, with Flags
    CC: TCallConv;
    ResultType: PTypeInfoRef;
    ParamCount: Byte;
    Params: TProcedureParam;
    {Params: array[1..ParamCount] of TProcedureParam;}
    function GetData(var AData: TSignatureData; const AAttrData: Pointer = nil): Integer;
    property IsValid: Boolean read GetIsValid;
    property ResultData: TResultData read GetResultData;
    property Tail: Pointer read GetTail;
  end;
  {$A4}
  {$ifend .FPC.EXTENDEDRTTI}

  {$ifdef EXTENDEDRTTI}
  PPropInfoEx = ^TPropInfoEx;
  {$A1}
  {$ifdef BCB}
  TPropInfoEx = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TPropInfoEx = object protected
  {$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Flags: Byte;
    Info: PPropInfo;
    AttrDataRec: TAttrData;
    property AttrData: PAttrData read GetAttrData;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PPropDataEx = ^TPropDataEx;
  {$A1}
  {$ifdef BCB}
  TPropDataEx = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TPropDataEx = object protected
  {$endif}
    function GetTail: Pointer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    PropCount: Word;
    PropList: TPropInfoEx;
    {PropList: array[1..PropCount] of TPropInfoEx;}
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PArrayPropInfo = ^TArrayPropInfo;
  {$A1}
  {$ifdef BCB}
  TArrayPropInfo = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TArrayPropInfo = object protected
  {$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Flags: Byte;
    ReadIndex: Word;
    WriteIndex: Word;
    Name: ShortStringHelper;
    {AttrData: TAttrData;}
    property AttrData: PAttrData read GetAttrData;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PArrayPropData = ^TArrayPropData;
  {$A1}
  {$ifdef BCB}
  TArrayPropData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TArrayPropData = object protected
  {$endif}
    function GetTail: Pointer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Count: Word;
    PropData: TArrayPropInfo;
    {PropData: array[1..Count] of TArrayPropInfo;}
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PVmtFieldExEntry = ^TVmtFieldExEntry;
  {$A1}
  {$ifdef BCB}
  TVmtFieldExEntry = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtFieldExEntry = object protected
  {$endif}
    function GetVisibility: TMemberVisibility; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetValue: TFieldData;
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Flags: Byte;
    TypeRef: PTypeInfoRef;
    Offset: Cardinal;
    Name: ShortStringHelper;
    {AttrData: TAttrData}
    property Visibility: TMemberVisibility read GetVisibility;
    property AttrData: PAttrData read GetAttrData;
    property Value: TFieldData read GetValue;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PFieldExEntry = ^TFieldExEntry;
  TFieldExEntry = {$ifdef BCB}TVmtFieldExEntry{$else}object(TVmtFieldExEntry) end{$endif};

  PVmtFieldTableEx = ^TVmtFieldTableEx;
  {$A1}
  {$ifdef BCB}
  TVmtFieldTableEx = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtFieldTableEx = object protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Count: Word;
    Entries: TVmtFieldExEntry;
    {Entries: array[1..Count] of TVmtFieldExEntry;}
  end;
  {$A4}

  PVmtMethodParam = ^TVmtMethodParam;
  {$A1}
  {$ifdef BCB}
  TVmtMethodParam = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtMethodParam = object protected
  {$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetData: TArgumentData;
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Flags: TParamFlags;
    ParamType: PTypeInfoRef;
    ParOff: Byte; // Parameter location: 0..2 for reg, >=8 for stack
    LocationHigh: Byte;
    Name: ShortStringHelper;
    {AttrData: TAttrData;}
    property AttrData: PAttrData read GetAttrData;
    property Data: TArgumentData read GetData;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  {$A1}
  {$ifdef BCB}
  TVmtMethodSignature = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtMethodSignature = object protected
  {$endif}
    function GetAttrDataRec: PAttrData;
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure InternalGetResultData(var AResult: TResultData; const AHasResultParam: Integer);
    function GetResultData: TResultData;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Version: Byte; // =3
    CC: TCallConv;
    ResultType: PTypeInfoRef; // nil for procedures
    ParOff: Word; // total size of data needed for stack parameters + 8 (ret-addr + pushed EBP)
    ParamCount: Byte;
    Params: TVmtMethodParam;
    {Params: array[1..ParamCount] of TVmtMethodParam;
    AttrData: TAttrData;}
    function GetData(var AData: TSignatureData; const AMethodKind: TMethodKind; const AHasSelf: Boolean): Integer; overload;
    function GetData(var AData: TSignatureData): Integer; overload;
    property AttrData: PAttrData read GetAttrData;
    property ResultData: TResultData read GetResultData;
  end;
  {$A4}

  PVmtMethodEntryTail = ^TVmtMethodEntryTail;
  TVmtMethodEntryTail = {$ifdef BCB}TVmtMethodSignature{$else}object(TVmtMethodSignature) end{$endif};

  PVmtMethodExEntry = ^TVmtMethodExEntry;
  {$A1}
  {$ifdef BCB}
  TVmtMethodExEntry = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtMethodExEntry = object protected
  {$endif}
    function GetName: PShortStringHelper; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCodeAddress: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsSpecial: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsAbstract: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsStatic: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsConstructor: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsDestructor: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsOperator: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsClassMethod: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetHasSelf: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDispatchKind: TDispatchKind; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetMemberVisibility: TMemberVisibility; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetMethodKind: TMethodKind;
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    property IsSpecial: Boolean read GetIsSpecial;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Entry: PVmtMethodEntry;
    Flags: Word;
    VirtualIndex: SmallInt; // signed word
    function GetData(var AData: TSignatureData): Integer;
    property CodeAddress: Pointer read GetCodeAddress;
    property Name: PShortStringHelper read GetName;
    property IsAbstract: Boolean read GetIsAbstract;
    property IsStatic: Boolean read GetIsStatic;
    property IsConstructor: Boolean read GetIsConstructor;
    property IsDestructor: Boolean read GetIsDestructor;
    property IsOperator: Boolean read GetIsOperator;
    property IsClassMethod: Boolean read GetIsClassMethod;
    property HasSelf: Boolean read GetHasSelf;
    property DispatchKind: TDispatchKind read GetDispatchKind;
    property MemberVisibility: TMemberVisibility read GetMemberVisibility;
    property MethodKind: TMethodKind read GetMethodKind;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PVmtMethodTableEx = ^TVmtMethodTableEx;
  {$A1}
  {$ifdef BCB}
  TVmtMethodTableEx = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TVmtMethodTableEx = object protected
  {$endif}
    function GetVirtualCount: Word; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Count: Word;
    Entries: array[Word] of TVmtMethodExEntry;
    {VirtualCount: Word;}
    function Find(const AName: PShortStringHelper): PVmtMethodExEntry; overload;
    function Find(const AName: string): PVmtMethodExEntry; overload;
    property VirtualCount: Word read GetVirtualCount;
  end;
  {$A4}

  PRecordTypeOptions = ^TRecordTypeOptions;
  {$A1}
  {$ifdef BCB}
  TRecordTypeOptions = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRecordTypeOptions = object protected
  {$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Count: Byte;
    Values: array[Byte] of Pointer;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PRecordTypeField = ^TRecordTypeField;
  {$A1}
  {$ifdef BCB}
  TRecordTypeField = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRecordTypeField = object protected
  {$endif}
    function GetVisibility: TMemberVisibility; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetFieldData: TFieldData;
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Field: TManagedField;
    Flags: Byte;
    Name: ShortStringHelper;
    {AttrData: TAttrData;}
    property Visibility: TMemberVisibility read GetVisibility;
    property AttrData: PAttrData read GetAttrData;
    property FieldData: TFieldData read GetFieldData;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PRecordTypeFields = ^TRecordTypeFields;
  {$A1}
  {$ifdef BCB}
  TRecordTypeFields = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRecordTypeFields = object protected
  {$endif}
    function GetTail: Pointer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Count: Integer;
    Fields: TRecordTypeField;
    {Fields: array[1..Count] of TRecordTypeField;}
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PRecordTypeMethod = ^TRecordTypeMethod;
  {$A1}
  {$ifdef BCB}
  TRecordTypeMethod = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRecordTypeMethod = object protected
  {$endif}
    function GetMemberVisibility: TMemberVisibility; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetMethodKind: TMethodKind; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetSignatureData: PProcedureSignature; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetSignature: PProcedureSignature; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Flags: Byte;
    Code: Pointer;
    Name: ShortStringHelper;
    {Signature: TProcedureSignature;
    AttrData: TAttrData;}
    function GetData(var AData: TSignatureData): Integer;
    property MemberVisibility: TMemberVisibility read GetMemberVisibility;
    property MethodKind: TMethodKind read GetMethodKind;
    property Signature: PProcedureSignature read GetSignature;
    property AttrData: PAttrData read GetAttrData;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PRecordTypeMethods = ^TRecordTypeMethods;
  {$A1}
  {$ifdef BCB}
  TRecordTypeMethods = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRecordTypeMethods = object protected
  {$endif}
    function GetTail: Pointer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Count: Word;
    Methods: TRecordTypeMethod;
    {Methods: array[1..Count] of TRecordTypeMethod;}
    property Tail: Pointer read GetTail;
  end;
  {$A4}
  {$endif .EXTENDEDRTTI}

  PEnumerationTypeData = ^TEnumerationTypeData;
  {$A1}
  {$ifdef BCB}
  TEnumerationTypeData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TEnumerationTypeData = object protected
  {$endif}
    function GetCount: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetEnumName(const AValue: Integer): PShortStringHelper;
    function GetEnumValue(const AName: ShortString): Integer;
    function GetUnitName: PShortStringHelper;
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    OrdType: TOrdType;
    MinValue: Integer;
    MaxValue: Integer;
    BaseType: PTypeInfoRef;
    {$ifdef BCB}[HPPGEN('/*ShortStringHelper*/ unsigned char NameList')]{$endif}
    NameList: ShortStringHelper;
    {EnumUnitName: ShortStringHelper;
    EnumAttrData: TAttrData;}
    property Count: Integer read GetCount;
    property EnumNames[const AValue: Integer]: PShortStringHelper read GetEnumName;
    property EnumValues[const AName: ShortString]: Integer read GetEnumValue;
    property UnitName: PShortStringHelper read GetUnitName;
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;
  {$A4}

  PSetTypeData = ^TSetTypeData;
  {$A1}
  {$ifdef BCB}
  TSetTypeData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TSetTypeData = object protected
  {$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function GetSize: Integer;
    function GetAdjustment: Integer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    SetTypeOrSize: Byte;
    CompType: PTypeInfoRef;
    {$ifdef EXTENDEDRTTI}
    AttrDataRec: TAttrData;
    {// Tokyo +
     SetLoByte: Byte;
     SetSize: Byte;}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
    property Size: Integer{Byte or INVALID_COUNT} read GetSize;
    property Adjustment: Integer{Byte or INVALID_COUNT} read GetAdjustment;
  end;
  {$A4}

  PMethodParam = ^TMethodParam;
  {$A1}
  {$ifdef BCB}
  TMethodParam = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TMethodParam = object protected
  {$endif}
    function GetTypeName: PShortStringHelper; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    {$ifdef BCB}[HPPGEN('/*TParamFlags*/ unsigned char Flags')]{$endif}
    Flags: TParamFlags;
    {$ifdef BCB}[HPPGEN('/*ShortStringHelper*/ unsigned char ParamName')]{$endif}
    ParamName: ShortStringHelper;
    {TypeName: ShortStringHelper;}
    property TypeName: PShortStringHelper read GetTypeName;
    property Tail: Pointer read GetTail;
  end;
  {$A4}

  PMethodSignature = ^TMethodSignature;
  {$A1}
  {$ifdef BCB}
  TMethodSignature = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TMethodSignature = object protected
  {$endif}
    function GetParamsTail: Pointer;
    function InternalGetResultData(const APtr: PByte; var AResult: TResultData): PByte;
    function GetResultData: TResultData;
    function GetResultTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCallConv: TCallConv; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetParamTypes: PPTypeInfoRef; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    MethodKind: TMethodKind; // only mkFunction or mkProcedure
    ParamCount: Byte;
    ParamList: TMethodParam;
    {ParamList: array[1..ParamCount] of TMethodParam;
    ResultType: ShortStringHelper; // only if MethodKind = mkFunction
    ResultTypeRef: PTypeInfoRef; // only if MethodKind = mkFunction
    CC: TCallConv;
    ParamTypeRefs: array[1..ParamCount] of PTypeInfoRef;
    // extended rtti
    MethSig: PProcedureSignature;
    MethAttrData: TAttrData;}
    function GetData(var AData: TSignatureData): Integer;
    property ResultData: TResultData read GetResultData;
    property CallConv: TCallConv read GetCallConv;
    property ParamTypes: PPTypeInfoRef read GetParamTypes;
  end;
  {$A4}

  PMethodTypeData = ^TMethodTypeData;
  {$A1}
  {$ifdef BCB}
  TMethodTypeData__ = record [HPPGEN(HPP_INHERIT + '(TMethodTypeData, TMethodSignature)'#13#10)] _: Byte; end;
  TMethodTypeData = record public
    [HPPGEN(HPP_RETRIEVE + '(TMethodSignature)'#13#10)] This: TMethodSignature;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TMethodTypeData = object(TMethodSignature) protected
  {$endif}
  {$ifdef EXTENDEDRTTI}
    function GetSignature: PProcedureSignature; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    property Signature: PProcedureSignature read GetSignature;
    property AttrData: PAttrData read GetAttrData;
  {$endif}
  end;
  {$A4}

  PClassTypeData = ^TClassTypeData;
  {$A1}
  {$ifdef BCB}
  TClassTypeData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TClassTypeData = object protected
  {$endif}
    function GetFieldTable: PVmtFieldTable; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetMethodTable: PVmtMethodTable; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetPropData: PPropData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef EXTENDEDRTTI}
    function GetFieldTableEx: PVmtFieldTableEx; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetMethodTableEx: PVmtMethodTableEx; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetPropDataEx: PPropDataEx; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetArrayPropData: PArrayPropData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    ClassType: TClass;
    ParentInfo: PTypeInfoRef;
    PropCount: SmallInt;
    {$ifdef BCB}[HPPGEN('/*ShortStringHelper*/ unsigned char UnitName')]{$endif}
    UnitName: ShortStringHelper;
    {PropData: TPropData;
    // extended rtti
    PropDataEx: TPropDataEx;
    ClassAttrData: TAttrData;
    ArrayPropCount: Word;
    ArrayPropData: array[1..ArrayPropCount] of TArrayPropInfo;}
    function VmtFunctionOffset(const AAddress: Pointer; const AStandardFunctions: Boolean = True): NativeInt{INVALID_INDEX means fail};
    property FieldTable: PVmtFieldTable read GetFieldTable;
    property MethodTable: PVmtMethodTable read GetMethodTable;
    property PropData: PPropData read GetPropData;
    {$ifdef EXTENDEDRTTI}
    property FieldTableEx: PVmtFieldTableEx read GetFieldTableEx;
    property MethodTableEx: PVmtMethodTableEx read GetMethodTableEx;
    property PropDataEx: PPropDataEx read GetPropDataEx;
    property AttrData: PAttrData read GetAttrData;
    property ArrayPropData: PArrayPropData read GetArrayPropData;
    {$endif}
  end;
  {$A4}

  PInterfaceTypeData = ^TInterfaceTypeData;
  {$A1}
  {$ifdef BCB}
  TInterfaceTypeData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TInterfaceTypeData = object protected
  {$endif}
    function GetMethodTable: PIntfMethodTable; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Parent: PTypeInfoRef; { ancestor }
    {$ifdef BCB}[HPPGEN('/*TIntfFlags*/ unsigned char Flags')]{$endif}
    Flags: TIntfFlags;
    Guid: TGUID;
    {$ifdef BCB}[HPPGEN('/*ShortStringHelper*/ unsigned char UnitName')]{$endif}
    UnitName: ShortStringHelper;
    {IntfMethods: TIntfMethodTable;
    IntfAttrData: TAttrData;}
    property MethodTable: PIntfMethodTable read GetMethodTable;
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;
  {$A4}

  PDynArrayTypeData = ^TDynArrayTypeData;
  {$A1}
  {$ifdef BCB}
  TDynArrayTypeData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TDynArrayTypeData = object protected
  {$endif}
    function GetArrElType: PTypeInfo; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    {$ifdef FPC}
      elSize: NativeUInt;
      elType2: PTypeInfoRef;
      varType: Integer;
      elType: PTypeInfoRef;
    {$else .DELPHI}
      elSize: Integer;
      elType: PTypeInfoRef;  // nil if type does not require cleanup
      varType: Integer;    // Ole Automation varType equivalent
      elType2: PTypeInfoRef; // independent of cleanup
    {$endif}
    {$ifdef BCB}[HPPGEN('/*ShortStringHelper*/ unsigned char UnitName')]{$endif}
    UnitName: ShortStringHelper;
    {DynArrElType: PTypeInfoRef; // actual element type, even if dynamic array
    DynArrAttrData: TAttrData;}
    property ArrElType: PTypeInfo read GetArrElType;
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;
  {$A4}

  PArrayTypeData = ^TArrayTypeData;
  {$A1}
  {$ifdef BCB}
  TArrayTypeData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TArrayTypeData = object protected
  {$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Size: InternalInt;
    ElCount: InternalInt; // product of lengths of all dimensions
    ElType: PTypeInfoRef;
    DimCount: Byte;
    Dims: array[0..255 {DimCount-1}] of PTypeInfoRef;
    {AttrData: TAttrData;}
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;
  {$A4}

  PRecordTypeData = ^TRecordTypeData;
  {$A1}
  {$ifdef BCB}
  TRecordTypeData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRecordTypeData = object protected
  {$endif}
    {$ifdef EXTENDEDRTTI}
    function GetOptions: PRecordTypeOptions; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetFields: PRecordTypeFields; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetMethods: PRecordTypeMethods; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Size: Integer;
    ManagedFieldCount: Integer;
    ManagedFields: TManagedField;
    {ManagedFields: array[0..ManagedFldCnt - 1] of TManagedField;
    NumOps: Byte;
    RecOps: array[1..NumOps] of Pointer;
    RecFldCnt: Integer;
    RecFields: array[1..RecFldCnt] of TRecordTypeField;
    RecAttrData: TAttrData;
    RecMethCnt: Word;
    RecMeths: array[1..RecMethCnt] of TRecordTypeMethod;}
    {$ifdef EXTENDEDRTTI}
    property Options: PRecordTypeOptions read GetOptions;
    property Fields: PRecordTypeFields read GetFields;
    property AttrData: PAttrData read GetAttrData;
    property Methods: PRecordTypeMethods read GetMethods;
    {$endif}
  end;
  {$A4}

  PRangeTypeData = ^TRangeTypeData;
  {$A1}
  {$ifdef BCB}
  TRangeTypeData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRangeTypeData = object protected
  {$endif}
    F: packed record
    case Integer of
      0: (
        OrdType: TOrdType;
        case Integer of
          0: (ILow, IHigh: Integer);
          1: (ULow, UHigh: Cardinal);
          High(Integer): (_: packed record end;);
        );
      1: (I64Low, I64High: Int64);
      2: (U64Low, U64High: UInt64);
    end;
    function GetCount: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCount64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    property ILow: Integer read F.ILow;
    property IHigh: Integer read F.IHigh;
    property ULow: Cardinal read F.ULow;
    property UHigh: Cardinal read F.UHigh;
    property I64Low: Int64 read F.I64Low;
    property I64High: Int64 read F.I64High;
    property U64Low: UInt64 read F.U64Low;
    property U64High: UInt64 read F.U64High;
    property Count: Cardinal read GetCount;
    property Count64: UInt64 read GetCount64;
  end;
  {$A4}

  TTypeData = packed record
    case TTypeKind of
      tkUnknown: (
        case TTypeKind of
          tkEnumeration: (EnumerationData: TEnumerationTypeData);
          tkSet: (SetData: TSetTypeData);
          tkMethod: (
            case Integer of
              0: (MethodSignature: TMethodSignature);
              1: (MethodData: TMethodTypeData);
              High(Integer): (_: packed record end);
          );
          tkClass: (ClassData: TClassTypeData);
          tkInterface: (InterfaceData: TInterfaceTypeData);
          tkDynArray: (DynArrayData: TDynArrayTypeData);
          tkRecord{, tkMRecord}: (RecordData: TRecordTypeData);
          tkInteger{, ...}: (RangeData: TRangeTypeData);
          tkUnknown: (__: packed record end);
      );
      {$ifdef UNICODE}
      tkUString,
      {$endif}
      {.$ifdef WIDESTRSUPPORT}
      tkWString,
      {.$endif}
      tkVariant: ({$ifdef EXTENDEDRTTI}AttrData: TAttrData{$endif});
      {.$ifdef ANSISTRSUPPORT}
      tkLString: (
        {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
        {$ifdef EXTENDEDRTTI}LStrAttrData: TAttrData{$endif});
      {.$endif}
      tkInteger,
      {.$ifdef ANSISTRSUPPORT}
      tkChar,
      {.$endif}
      tkEnumeration, {EnumerationData: TEnumerationTypeData;}
      tkWChar: (
        OrdType: TOrdType;
        case TTypeKind of
          tkInteger, tkChar, tkEnumeration, tkWChar: (
            MinValue: Integer;
            MaxValue: Integer;
            case TTypeKind of
              tkInteger, tkChar, tkWChar: (
                {$ifdef EXTENDEDRTTI}OrdAttrData: TAttrData;{$endif});
              tkEnumeration: (
                BaseType: PTypeInfoRef;
                NameList: {$ifdef BCB}Byte{$else}ShortStringHelper{$endif};
                {EnumUnitName: ShortStringHelper;
                EnumAttrData: TAttrData;}
                ___: packed record end;)
              );
          tkSet: (
           ____: packed record end;));
      tkSet: (
        SetTypeOrSize: Byte;
        CompType: PTypeInfoRef;
        {$ifdef EXTENDEDRTTI}SetAttrData: TAttrData;{$endif}
        {// Tokyo +
         SetLoByte: Byte;
         SetSize: Byte;});
      tkFloat: (
        FloatType: TFloatType;
        {$ifdef EXTENDEDRTTI}FloatAttrData: TAttrData;{$endif});
      {.$ifdef SHORTSTRSUPPORT}
      tkString: (
        MaxLength: Byte;
        {$ifdef EXTENDEDRTTI}StrAttrData: TAttrData{$endif});
      {.$endif}
      tkClass: ( {ClassData: TClassTypeData;}
        ClassType: TClass; // most data for instance types is in VMT offsets
        ParentInfo: PTypeInfoRef;
        PropCount: SmallInt; // total properties inc. ancestors
        UnitName: {$ifdef BCB}Byte{$else}ShortStringHelper{$endif};
        {PropData: TPropData;
        // extended rtti
        PropDataEx: TPropDataEx;
        ClassAttrData: TAttrData;
        ArrayPropCount: Word;
        ArrayPropData: array[1..ArrayPropCount] of TArrayPropInfo;});
      tkMethod: ( {MethodData: TMethodTypeData;}
        MethodKind: TMethodKind; // only mkFunction or mkProcedure
        ParamCount: Byte;
        ParamList: TMethodParam;
        {ParamList: array[1..ParamCount] of TMethodParam;
        ResultType: ShortStringHelper; // only if MethodKind = mkFunction
        ResultTypeRef: PTypeInfoRef; // only if MethodKind = mkFunction
        CC: TCallConv;
        ParamTypeRefs: array[1..ParamCount] of PTypeInfoRef;
        // extended rtti
        MethSig: PProcedureSignature;
        MethAttrData: TAttrData;});
      tkInterface: ( {InterfaceData: TInterfaceTypeData;}
        IntfParent: PTypeInfoRef; { ancestor }
        IntfFlags: {$ifdef BCB}Byte{$else}TIntfFlags{$endif};
        Guid: TGUID;
        IntfUnit: {$ifdef BCB}Byte{$else}ShortStringHelper{$endif};
        {IntfMethods: TIntfMethodTable;
        IntfAttrData: TAttrData;});
      tkInt64: (
        MinInt64Value, MaxInt64Value: Int64;
        {$ifdef EXTENDEDRTTI}Int64AttrData: TAttrData;{$endif});
      tkDynArray: ( {DynArrayData: TDynArrayTypeData;}
        {$ifdef FPC}
          elSize: NativeUInt;
          elType2: PTypeInfoRef;
          varType: Integer;
          elType: PTypeInfoRef;
        {$else .DELPHI}
          elSize: Integer;
          elType: PTypeInfoRef;  // nil if type does not require cleanup
          varType: Integer;    // Ole Automation varType equivalent
          elType2: PTypeInfoRef; // independent of cleanup
        {$endif}
        DynUnitName: {$ifdef BCB}Byte{$else}ShortStringHelper{$endif};
        {DynArrElType: PTypeInfoRef; // actual element type, even if dynamic array
        DynArrAttrData: TAttrData;});
      tkArray: (
        ArrayData: TArrayTypeData;
        {ArrAttrData: TAttrData;});
      tkRecord{, tkMRecord}: ( {RecordData: TRecordTypeData;}
        RecSize: Integer;
        ManagedFldCount: Integer;
        ManagedFields: TManagedField;
        {ManagedField: array[0..ManagedFldCnt - 1] of TManagedField;
        NumOps: Byte;
        RecOps: array[1..NumOps] of Pointer;
        RecFldCnt: Integer;
        RecFields: array[1..RecFldCnt] of TRecordTypeField;
        RecAttrData: TAttrData;
        RecMethCnt: Word;
        RecMeths: array[1..RecMethCnt] of TRecordTypeMethod;});
      {$if Defined(FPC) or Defined(EXTENDEDRTTI)}
      tkClassRef: (
        InstanceType: PTypeInfoRef;
        {$ifdef EXTENDEDRTTI}ClassRefAttrData: TAttrData;{$endif});
      tkPointer: (
        RefType: PTypeInfoRef;
        {$ifdef EXTENDEDRTTI}PtrAttrData: TAttrData;{$endif});
      tkProcedure{/tkProcVar}: (
        ProcSig: {$ifdef FPC}TProcedureSignature{$else .DELPHI}PProcedureSignature{$endif};
        {$ifdef EXTENDEDRTTI}ProcAttrData: TAttrData;{$endif});
      {$ifend}
      {$ifdef FPC}
      tkHelper: (
        HelperParent: PTypeInfo;
        ExtendedInfo: PTypeInfo;
        HelperProps: SmallInt;
        HelperUnit: {$ifdef BCB}Byte{$else}ShortStringHelper{$endif};
        {here the properties follow as array of TPropInfo});
      tkQWord: (
        MinQWordValue, MaxQWordValue: QWord);
      tkInterfaceRaw: (
        RawIntfParent: PTypeInfoRef;
        RawIntfFlags: TIntfFlags;
        IID: TGUID;
        RawIntfUnit: {$ifdef BCB}Byte{$else}ShortStringHelper{$endif};
        {IIDStr: ShortStringHelper;});
      {$endif}
  end;


{ Universal RTTI types }

type
  PRttiHFA = ^TRttiHFA;
  TRttiHFA = (hfaNone, hfaFloat1, hfaDouble1, hfaFloat2, hfaDouble2,
    hfaFloat3, hfaDouble3, hfaFloat4, hfaDouble4);
  PRttiHFAs = ^TRttiHFAs;
  TRttiHFAs = set of TRttiHFA;

  PRttiCallConv = ^TRttiCallConv;
  TRttiCallConv = (
    // General
    rcRegister, rcCdecl, rcPascal, rcStdCall, rcSafeCall,
    // FreePascal
    rcMWPascal, rcSoftFloat,
    // C/C++
    rcFastCall, rcThisCall, rcMicrosoft,
    rcRegParm1, rcRegParm2, rcRegParm3, rcStdCallRegParm1, rcStdCallRegParm2, rcStdCallRegParm3
  );
  PRttiCallConvs = ^TRttiCallConvs;
  TRttiCallConvs = set of TRttiCallConv;

  PRttiTypeGroup = ^TRttiTypeGroup;
  TRttiTypeGroup = (
    {000} rgUnknown,
    {001} rgPointer,
    {002} rgBoolean,
    {003} rgOrdinal,
    {004} rgFloat,
    {005} rgDateTime,
    {006} rgString,
    {007} rgEnumeration,
    {008} rgMetaType,
    {009} rgMetaTypeRef,
    {010} rgFunction,
    {011} rgVariant,
    // Reserved
    {012} rg012, {013} rg013, {014} rg014, {015} rg015,
    {016} rg016, {017} rg017, {018} rg018, {019} rg019, {020} rg020, {021} rg021, {022} rg022, {023} rg023,
    {024} rg024, {025} rg025, {026} rg026, {027} rg027, {028} rg028, {029} rg029, {030} rg030, {031} rg031,
    {032} rg032, {033} rg033, {034} rg034, {035} rg035, {036} rg036, {037} rg037, {038} rg038, {039} rg039,
    {040} rg040, {041} rg041, {042} rg042, {043} rg043, {044} rg044, {045} rg045, {046} rg046, {047} rg047,
    {048} rg048, {049} rg049, {050} rg050, {051} rg051, {052} rg052, {053} rg053, {054} rg054, {055} rg055,
    {056} rg056, {057} rg057, {058} rg058, {059} rg059, {060} rg060, {061} rg061, {062} rg062, {063} rg063,
    {064} rg064, {065} rg065, {066} rg066, {067} rg067, {068} rg068, {069} rg069, {070} rg070, {071} rg071,
    {072} rg072, {073} rg073, {074} rg074, {075} rg075, {076} rg076, {077} rg077, {078} rg078, {079} rg079,
    {080} rg080, {081} rg081, {082} rg082, {083} rg083, {084} rg084, {085} rg085, {086} rg086, {087} rg087,
    {088} rg088, {089} rg089, {090} rg090, {091} rg091, {092} rg092, {093} rg093, {094} rg094, {095} rg095,
    {096} rg096, {097} rg097, {098} rg098, {099} rg099, {100} rg100, {101} rg101, {102} rg102, {103} rg103,
    {104} rg104, {105} rg105, {106} rg106, {107} rg107, {108} rg108, {109} rg109, {110} rg110, {111} rg111,
    {112} rg112, {113} rg113, {114} rg114, {115} rg115, {116} rg116, {117} rg117, {118} rg118, {119} rg119,
    {120} rg120, {121} rg121, {122} rg122, {123} rg123, {124} rg124, {125} rg125, {126} rg126, {127} rg127,
    {128} rg128, {129} rg129, {130} rg130, {131} rg131, {132} rg132, {133} rg133, {134} rg134, {135} rg135,
    {136} rg136, {137} rg137, {138} rg138, {139} rg139, {140} rg140, {141} rg141, {142} rg142, {143} rg143,
    {144} rg144, {145} rg145, {146} rg146, {147} rg147, {148} rg148, {149} rg149, {150} rg150, {151} rg151,
    {152} rg152, {153} rg153, {154} rg154, {155} rg155, {156} rg156, {157} rg157, {158} rg158, {159} rg159,
    {160} rg160, {161} rg161, {162} rg162, {163} rg163, {164} rg164, {165} rg165, {166} rg166, {167} rg167,
    {168} rg168, {169} rg169, {170} rg170, {171} rg171, {172} rg172, {173} rg173, {174} rg174, {175} rg175,
    {176} rg176, {177} rg177, {178} rg178, {179} rg179, {180} rg180, {181} rg181, {182} rg182, {183} rg183,
    {184} rg184, {185} rg185, {186} rg186, {187} rg187, {188} rg188, {189} rg189, {190} rg190, {191} rg191,
    {192} rg192, {193} rg193, {194} rg194, {195} rg195, {196} rg196, {197} rg197, {198} rg198, {199} rg199,
    {200} rg200, {201} rg201, {202} rg202, {203} rg203, {204} rg204, {205} rg205, {206} rg206, {207} rg207,
    {208} rg208, {209} rg209, {210} rg210, {211} rg211, {212} rg212, {213} rg213, {214} rg214, {215} rg215,
    {216} rg216, {217} rg217, {218} rg218, {219} rg219, {220} rg220, {221} rg221, {222} rg222, {223} rg223,
    {224} rg224, {225} rg225, {226} rg226, {227} rg227, {228} rg228, {229} rg229, {230} rg230, {231} rg231,
    {232} rg232, {233} rg233, {234} rg234, {235} rg235, {236} rg236, {237} rg237, {238} rg238, {239} rg239,
    {240} rg240, {241} rg241, {242} rg242, {243} rg243, {244} rg244, {245} rg245, {246} rg246, {247} rg247,
    {248} rg248, {249} rg249, {250} rg250, {251} rg251, {252} rg252, {253} rg253, {254} rg254, {255} rg255);
  PRttiTypeGroups = ^TRttiTypeGroups;
  TRttiTypeGroups = set of TRttiTypeGroup;

  PRttiType = ^TRttiType;
  TRttiType = (
    // rgUnknown
    {000} rtUnknown,
    // rgPointer
    {001} rtPointer,
    // rgBoolean
    {002} rtBoolean8,
    {003} rtBoolean16,
    {004} rtBoolean32,
    {005} rtBoolean64,
    {006} rtBool8,
    {007} rtBool16,
    {008} rtBool32,
    {009} rtBool64,
    // rgOrdinal
    {010} rtInt8,
    {011} rtUInt8,
    {012} rtInt16,
    {013} rtUInt16,
    {014} rtInt32,
    {015} rtUInt32,
    {016} rtInt64,
    {017} rtUInt64,
    // rgFloat
    {018} rtComp,
    {019} rtCurrency,
    {020} rtFloat,
    {021} rtDouble,
    {022} rtLongDouble80,
    {023} rtLongDouble96,
    {024} rtLongDouble128,
    // rgDateTime
    {025} rtDate,
    {026} rtTime,
    {027} rtDateTime,
    {028} rtTimeStamp,
    // rgString
    {029} rtSBCSChar,
    {030} rtUTF8Char,
    {031} rtWideChar,
    {032} rtUCS4Char,
    {033} rtPSBCSChars,
    {034} rtPUTF8Chars,
    {035} rtPWideChars,
    {036} rtPUCS4Chars,
    {037} rtSBCSString,
    {038} rtUTF8String,
    {039} rtWideString,
    {040} rtUnicodeString,
    {041} rtUCS4String,
    {042} rtShortString,
    // rgEnumeration
    {043} rtEnumeration8,
    {044} rtEnumeration16,
    {045} rtEnumeration32,
    {046} rtEnumeration64,
    // rgMetaType
    {047} rtSet,
    {048} rtStaticArray,
    {049} rtDynamicArray,
    {050} rtStructure,
    {051} rtObject,
    {052} rtInterface,
    // rgMetaTypeRef
    {053} rtClassRef,
    // rgFunction
    {054} rtFunction,
    {055} rtMethod,
    {056} rtClosure,
    // rgVariant
    {057} rtBytes,
    {058} rtOleVariant,
    {059} rtVariant,
    {060} rtVarRec,
    {061} rtValue,
    // Reserved
    {062} rt062, {063} rt063,
    {064} rt064, {065} rt065, {066} rt066, {067} rt067, {068} rt068, {069} rt069, {070} rt070, {071} rt071,
    {072} rt072, {073} rt073, {074} rt074, {075} rt075, {076} rt076, {077} rt077, {078} rt078, {079} rt079,
    {080} rt080, {081} rt081, {082} rt082, {083} rt083, {084} rt084, {085} rt085, {086} rt086, {087} rt087,
    {088} rt088, {089} rt089, {090} rt090, {091} rt091, {092} rt092, {093} rt093, {094} rt094, {095} rt095,
    {096} rt096, {097} rt097, {098} rt098, {099} rt099, {100} rt100, {101} rt101, {102} rt102, {103} rt103,
    {104} rt104, {105} rt105, {106} rt106, {107} rt107, {108} rt108, {109} rt109, {110} rt110, {111} rt111,
    {112} rt112, {113} rt113, {114} rt114, {115} rt115, {116} rt116, {117} rt117, {118} rt118, {119} rt119,
    {120} rt120, {121} rt121, {122} rt122, {123} rt123, {124} rt124, {125} rt125, {126} rt126, {127} rt127,
    {128} rt128, {129} rt129, {130} rt130, {131} rt131, {132} rt132, {133} rt133, {134} rt134, {135} rt135,
    {136} rt136, {137} rt137, {138} rt138, {139} rt139, {140} rt140, {141} rt141, {142} rt142, {143} rt143,
    {144} rt144, {145} rt145, {146} rt146, {147} rt147, {148} rt148, {149} rt149, {150} rt150, {151} rt151,
    {152} rt152, {153} rt153, {154} rt154, {155} rt155, {156} rt156, {157} rt157, {158} rt158, {159} rt159,
    {160} rt160, {161} rt161, {162} rt162, {163} rt163, {164} rt164, {165} rt165, {166} rt166, {167} rt167,
    {168} rt168, {169} rt169, {170} rt170, {171} rt171, {172} rt172, {173} rt173, {174} rt174, {175} rt175,
    {176} rt176, {177} rt177, {178} rt178, {179} rt179, {180} rt180, {181} rt181, {182} rt182, {183} rt183,
    {184} rt184, {185} rt185, {186} rt186, {187} rt187, {188} rt188, {189} rt189, {190} rt190, {191} rt191,
    {192} rt192, {193} rt193, {194} rt194, {195} rt195, {196} rt196, {197} rt197, {198} rt198, {199} rt199,
    {200} rt200, {201} rt201, {202} rt202, {203} rt203, {204} rt204, {205} rt205, {206} rt206, {207} rt207,
    {208} rt208, {209} rt209, {210} rt210, {211} rt211, {212} rt212, {213} rt213, {214} rt214, {215} rt215,
    {216} rt216, {217} rt217, {218} rt218, {219} rt219, {220} rt220, {221} rt221, {222} rt222, {223} rt223,
    {224} rt224, {225} rt225, {226} rt226, {227} rt227, {228} rt228, {229} rt229, {230} rt230, {231} rt231,
    {232} rt232, {233} rt233, {234} rt234, {235} rt235, {236} rt236, {237} rt237, {238} rt238, {239} rt239,
    {240} rt240, {241} rt241, {242} rt242, {243} rt243, {244} rt244, {245} rt245, {246} rt246, {247} rt247,
    {248} rt248, {249} rt249, {250} rt250, {251} rt251, {252} rt252, {253} rt253, {254} rt254, {255} rt255);
  PRttiTypes = ^TRttiTypes;
  TRttiTypes = set of TRttiType;


{ TRttiTypeRules object
  General set of rules for interacting with a type }

  PRttiTypeReturn = ^TRttiTypeReturn;
  TRttiTypeReturn = (trReference, trGeneral, trGeneralPair, trFPUInt64, trFPU,
    trFloat1, trDouble1, trFloat2, trDouble2, trFloat3, trDouble3, trFloat4, trDouble4);
  PRttiTypeReturns = ^TRttiTypeReturns;
  TRttiTypeReturns = set of TRttiTypeReturn;

  PRttiTypeFlag = ^TRttiTypeFlag;
  TRttiTypeFlag = (tfRegValueArg, tfGenUseArg {stack 0/0, ref 0/1, ext 1/0, gen 1/1},
    tfOptionalRefArg, tfManaged, tfUnsafable, tfWeakable, tfHasWeakRef, tfVarHigh);
  PRttiTypeFlags = ^TRttiTypeFlags;
  TRttiTypeFlags = set of TRttiTypeFlag;

  PRttiTypeRules = ^TRttiTypeRules;
  {$A1}
  {$ifdef BCB}
  TRttiTypeRules = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiTypeRules = object protected
  {$endif}
    function GetIsRefArg: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsStackArg: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsGeneralArg: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsExtendedArg: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetHFA: TRttiHFA; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Size: Cardinal;
    Return: TRttiTypeReturn;
    Flags: TRttiTypeFlags;
    Reserved: Byte;
    InitFunc: Byte;
    FinalFunc: Byte;
    WeakFinalFunc: Byte;
    CopyFunc: Byte;
    WeakCopyFunc: Byte;

    property IsRefArg: Boolean read GetIsRefArg;
    property IsStackArg: Boolean read GetIsStackArg;
    property IsGeneralArg: Boolean read GetIsGeneralArg;
    property IsExtendedArg: Boolean read GetIsExtendedArg;
    property HFA: TRttiHFA read GetHFA;
  end;
  {$A4}


{ TRttiBound/TRttiBound64/TRttiCustomTypeData objects
  Structures involved in describing additional type information }

  PRttiBound = ^TRttiBound;
  {$A1}
  {$ifdef BCB}
  TRttiBound = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiBound = object protected
  {$endif}
    function GetCount: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Low: Integer;
    High: Integer;
    property Count: Integer read GetCount;
  end;
  {$A4}
  PRttiBoundList = ^TRttiBoundList;
  TRttiBoundList = array[0..High(Integer) div SizeOf(TRttiBound) - 1] of TRttiBound;

  PRttiBound64 = ^TRttiBound64;
  {$A1}
  {$ifdef BCB}
  TRttiBound64 = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiBound64 = object protected
  {$endif}
    function GetCount: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetBound: TRttiBound; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetBound(const AValue: TRttiBound); {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Low: Int64;
    High: Int64;
    property Count: Int64 read GetCount;
    property Bound: TRttiBound read GetBound write SetBound;
  end;
  {$A4}

  PRttiCustomTypeData = ^TRttiCustomTypeData;
  {$A1}
  {$ifdef BCB}
  TRttiCustomTypeData = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiCustomTypeData = object protected
  {$endif}
    function GetBacket(const AIndex: NativeInt): Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetBacket(const AIndex: NativeInt; const AValue: Pointer); {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    property Backets[const AIndex: NativeInt]: Pointer read GetBacket write SetBacket;
  end;
  {$A4}


{ TRttiTypeData object
  Basic structure for storing additional type information }

const
  RTTI_TYPEDATA_MASK = Cardinal($00ffffff);
  RTTI_TYPEDATA_MARKER = Cardinal(Ord('R') + (Ord('M') shl 8) + (Ord('T') shl 16));

type
  PRttiContext = ^TRttiContext;
  PRttiTypeData = ^TRttiTypeData;
  {$A1}
  {$ifdef BCB}
  TRttiTypeData___ = packed record
  case Integer of
    0: (Marker: Cardinal);
    1:
    (
      MarkerBytes: array[0..2] of Byte;
      BaseType: TRttiType;
    );
  end;
  TRttiTypeData__ = record [HPPGEN(HPP_INHERIT + '(TRttiTypeData, TRttiCustomTypeData)'#13#10)] _: Byte; end;
  TRttiTypeData = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiCustomTypeData)'#13#10)] This: TRttiCustomTypeData;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
    F: TRttiTypeData___;
  {$else .DELPHI.FPC}
  TRttiTypeData = object(TRttiCustomTypeData) protected
    F: packed record
    case Integer of
      0: (Marker: Cardinal);
      1:
      (
        MarkerBytes: array[0..2] of Byte;
        BaseType: TRttiType;
      );
    end;
  {$endif}
    FContext: PRttiContext;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Name: PShortStringHelper;
    property Marker: Cardinal read F.Marker;
    property BaseType: TRttiType read F.BaseType;
    property Context: PRttiContext read FContext;
  end;
  {$A4}


{ TRttiEnumerationType object
  Universal structure describing enumerated type (consisting of items) }

  PRttiEnumerationItem = ^TRttiEnumerationItem;
  {$A1}
  {$ifdef BCB}
  TRttiEnumerationItem___ = packed record
  case Integer of
    0: (Value: Integer);
    1: (Value64: Int64);
  end;
  TRttiEnumerationItem = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
    F: TRttiEnumerationItem___;
  {$else .DELPHI.FPC}
  TRttiEnumerationItem = object protected
    F: packed record
    case Integer of
      0: (Value: Integer);
      1: (Value64: Int64);
    end;
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Name: PShortStringHelper;
    property Value: Integer read F.Value write F.Value;
    property Value64: Int64 read F.Value64 write F.Value64;
  end;
  {$A4}
  PRttiEnumerationItemList = ^TRttiEnumerationItemList;
  TRttiEnumerationItemList = array[0..High(Integer) div SizeOf(TRttiEnumerationItem) - 1] of TRttiEnumerationItem;

  PRttiEnumerationType = ^TRttiEnumerationType;
  TRttiEnumerationFindFunc = function(const AEnumeration: PRttiEnumerationType; const AName: PShortStringHelper): PRttiEnumerationItem of object;
  {$A1}
  {$ifdef BCB}
  TRttiEnumerationType___ = packed record
  case Integer of
    0: (Bound64: TRttiBound64);
    1: (Low, _: Integer; High: Integer);
  end;
  TRttiEnumerationType__ = record [HPPGEN(HPP_INHERIT + '(TRttiEnumerationType, TRttiTypeData)'#13#10)] _: Byte; end;
  TRttiEnumerationType = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiTypeData)'#13#10)] This: TRttiTypeData;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
    FB: TRttiEnumerationType___;
  {$else .DELPHI.FPC}
  TRttiEnumerationType = object(TRttiTypeData) protected
    FB: packed record
    case Integer of
      0: (Bound64: TRttiBound64);
      1: (Low, _: Integer; High: Integer);
    end;
  {$endif}
    procedure SetLow(const AValue: Integer); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetHigh(const AValue: Integer); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetBound: TRttiBound; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetBound(const AValue: TRttiBound); {$ifdef INLINESUPPORT}inline;{$endif}
    function DefaultFind(const AName: PShortStringHelper): PRttiEnumerationItem;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    ItemCount: Integer;
    Items: PRttiEnumerationItemList;
    FindFunc: TRttiEnumerationFindFunc;

    function Find(const AName: PShortStringHelper): PRttiEnumerationItem; {$ifdef INLINESUPPORT}inline;{$endif}

    property Low: Integer read FB.Low write SetLow;
    property High: Integer read FB.High write SetHigh;
    property Low64: Int64 read FB.Bound64.Low write FB.Bound64.Low;
    property High64: Int64 read FB.Bound64.High write FB.Bound64.High;
    property Bound: TRttiBound read GetBound write SetBound;
    property Bound64: TRttiBound64 read FB.Bound64 write FB.Bound64;
  end;
  {$A4}


{ TRttiMetaType object
  Universal structure that describes meta types -
  types whose rules of behavior are determined by content }

  PRttiMetaType = ^TRttiMetaType;
  PRttiMetaTypeFunc = ^TRttiMetaTypeFunc;
  TRttiMetaTypeFunc = procedure(const AMetaType: PRttiMetaType; const AValue: Pointer);
  PRttiMetaTypeCopyFunc = ^TRttiMetaTypeCopyFunc;
  TRttiMetaTypeCopyFunc = procedure(const AMetaType: PRttiMetaType; const ATarget, ASource: Pointer);
  {$A1}
  {$ifdef BCB}
  TRttiMetaType__ = record [HPPGEN(HPP_INHERIT + '(TRttiMetaType, TRttiTypeData)'#13#10)] _: Byte; end;
  TRttiMetaType = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiTypeData)'#13#10)] This: TRttiTypeData;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiMetaType = object(TRttiTypeData) protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Rules: TRttiTypeRules;
    InitFunc: TRttiMetaTypeFunc;
    FinalFunc: TRttiMetaTypeFunc;
    WeakFinalFunc: TRttiMetaTypeFunc;
    CopyFunc: TRttiMetaTypeCopyFunc;
    WeakCopyFunc: TRttiMetaTypeCopyFunc;

    procedure Init(const AValue: Pointer); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Final(const AValue: Pointer); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure WeakFinal(const AValue: Pointer); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Copy(const ATarget, ASource: Pointer); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure WeakCopy(const ATarget, ASource: Pointer); {$ifdef INLINESUPPORT}inline;{$endif}
  end;
  {$A4}


{ TRttiHeritableMetaType object
  Universal structure describing meta types that a parent can have }

  PRttiHeritableMetaType = ^TRttiHeritableMetaType;
  {$A1}
  {$ifdef BCB}
  TRttiHeritableMetaType__ = record [HPPGEN(HPP_INHERIT + '(TRttiHeritableMetaType, TRttiMetaType)'#13#10)] _: Byte; end;
  TRttiHeritableMetaType = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiMetaType)'#13#10)] This: TRttiMetaType;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiHeritableMetaType = object(TRttiMetaType) protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Parent: PRttiHeritableMetaType;
  end;
  {$A4}


{ TRttiExType object
  Universal structure describing any type,
  including pointer depth and additional information }

  PRttiExType = ^TRttiExType;
  PRttiTypeFunc = ^TRttiTypeFunc;
  TRttiTypeFunc = procedure(const AType: PRttiExType; const AValue: Pointer);
  PRttiCopyFunc = ^TRttiCopyFunc;
  TRttiCopyFunc = procedure(const AType: PRttiExType; const ATarget, ASource: Pointer);
  {$A1}
  {$ifdef BCB}
  TRttiExType = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiExType = object protected
  {$endif}
    F: packed record
    case Integer of
      0: (
        BaseType: TRttiType;
        PointerDepth: Byte;
        case Integer of
          0: (Id: Word);
          1: (CodePage: Word);
          2: (MaxLength: Byte; OpenString: Boolean);
          3: (ExFlags: Word);
          High(Integer): (_: packed record end;));
      1: (BaseOptions: Word);
      2: (
        Options: Cardinal;
        case Integer of
          0: (CustomData: Pointer);
          1: (TypeData: PTypeData);
          2: (RangeData: PRangeTypeData);
          3: (RttiTypeData: PRttiTypeData);
          4: (EnumerationType: PRttiEnumerationType);
          5: (MetaType: PRttiMetaType);
          High(Integer): (__: packed record end;));
    end;

    {$ifdef HFASUPPORT}
    function GetCalculatedHFA(var AValue: TRttiTypeReturn; const AHFA: TRttiHFA{hfaFloat1/hfaDouble1}; const AHFACount, ASize: Integer): Boolean;
    function GetCalculatedRecordHFA(var AValue: TRttiTypeReturn; const ATypeData: PTypeData): Boolean;
    function GetCalculatedArrayHFA(var AValue: TRttiTypeReturn; const ATypeData: PTypeData): Boolean;
    {$endif}
    function GetCalculatedRules(var ABuffer: TRttiTypeRules): PRttiTypeRules;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    property BaseType: TRttiType read F.BaseType write F.BaseType;
    property PointerDepth: Byte read F.PointerDepth write F.PointerDepth;
    property Id: Word read F.Id write F.Id;
    property CodePage: Word read F.CodePage write F.CodePage;
    property MaxLength: Byte read F.MaxLength write F.MaxLength;
    property OpenString: Boolean read F.OpenString write F.OpenString;
    property ExFlags: Word read F.ExFlags write F.ExFlags;
    property BaseOptions: Word read F.BaseOptions write F.BaseOptions;
    property Options: Cardinal read F.Options write F.Options;

    function GetRules(var ABuffer: TRttiTypeRules): PRttiTypeRules; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetRules: PRttiTypeRules; overload;

    property CustomData: Pointer read F.CustomData write F.CustomData;
    property TypeData: PTypeData read F.TypeData write F.TypeData;
    property RangeData: PRangeTypeData read F.RangeData write F.RangeData;
    property RttiTypeData: PRttiTypeData read F.RttiTypeData write F.RttiTypeData;
    property EnumerationType: PRttiEnumerationType read F.EnumerationType write F.EnumerationType;
    property MetaType: PRttiMetaType read F.MetaType write F.MetaType;
  end;
  {$A4}

  {$ifdef GENERICSUPPORT}
  TRttiExType<T> = record
  private
    {$ifdef BCB}[HPPGEN('/* class constructor ClassCreate */')]{$endif}
    class constructor ClassCreate;
  public
    class var
      Default: TRttiExType;
      DefaultSimplified: TRttiExType;
      DefaultRules: TRttiTypeRules;
  end;
  {$endif}


{ TRttiSetType object
  Universal structure describing set types }

  PRttiSetType = ^TRttiSetType;
  {$A1}
  {$ifdef BCB}
  TRttiSetType__ = record [HPPGEN(HPP_INHERIT + '(TRttiSetType, TRttiMetaType)'#13#10)] _: Byte; end;
  TRttiSetType = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiMetaType)'#13#10)] This: TRttiMetaType;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiSetType = object(TRttiMetaType) protected
  {$endif}
    FBound: TRttiBound;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Enumeration: PRttiEnumerationType;
    Adjustment: Integer;
    BitMask: Integer;

    // Funcs

    property Bound: TRttiBound read FBound write FBound;
    property Low: Integer read FBound.Low write FBound.Low;
    property High: Integer read FBound.High write FBound.High;
  end;
  {$A4}


{ TRttiArrayType object
  Basic structure describing array types }

  PRttiArrayType = ^TRttiArrayType;
  {$ifdef BCB}
  TRttiArrayType__ = record [HPPGEN(HPP_INHERIT + '(TRttiArrayType, TRttiMetaType)'#13#10)] _: Byte; end;
  TRttiArrayType = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiMetaType)'#13#10)] This: TRttiMetaType;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiArrayType = object(TRttiMetaType) protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    ItemType: TRttiExType;
    ItemRules: TRttiTypeRules;
    ItemInfo: Pointer{only for initialization and finalization};
    Dimention: Integer;
  end;


{ TRttiStaticArrayType object
  Universal structure describing static array types }

  PRttiMultiplies = ^TRttiMultiplies;
  TRttiMultiplies = array[0..High(Integer) div SizeOf(NativeInt) - 1] of NativeInt;

  PRttiStaticArrayType = ^TRttiStaticArrayType;
  {$A1}
  {$ifdef BCB}
  TRttiStaticArrayType__ = record [HPPGEN(HPP_INHERIT + '(TRttiStaticArrayType, TRttiArrayType)'#13#10)] _: Byte; end;
  TRttiStaticArrayType = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiArrayType)'#13#10)] This: TRttiArrayType;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiStaticArrayType = object(TRttiArrayType) protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    ItemCount: Integer;
    Bounds: PRttiBoundList{0..Dimention - 1};
    Multiplies: PRttiMultiplies{0..Dimention - 1};
  end;
  {$A4}


{ TRttiDynamicArrayType object
  Universal structure describing dynamic array types }

  PRttiItemInfoList = ^TRttiItemInfoList;
  TRttiItemInfoList = array[0..High(Integer) div SizeOf(Pointer) - 1] of Pointer;

  PRttiDynamicArrayType = ^TRttiDynamicArrayType;
  {$A1}
  {$ifdef BCB}
  TRttiDynamicArrayType__ = record [HPPGEN(HPP_INHERIT + '(TRttiDynamicArrayType, TRttiArrayType)'#13#10)] _: Byte; end;
  TRttiDynamicArrayType = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiArrayType)'#13#10)] This: TRttiArrayType;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiDynamicArrayType = object(TRttiArrayType) protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    ItemInfoList: PRttiItemInfoList{0..Dimention - 1};
  end;
  {$A4}


{ TRttiStructureType object
  Universal structure describing structure (record) types }

  PRttiStructureType = ^TRttiStructureType;
  {$A1}
  {$ifdef BCB}
  TRttiStructureType__ = record [HPPGEN(HPP_INHERIT + '(TRttiStructureType, TRttiHeritableMetaType)'#13#10)] _: Byte; end;
  TRttiStructureType = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiHeritableMetaType)'#13#10)] This: TRttiHeritableMetaType;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiStructureType = object(TRttiHeritableMetaType) protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
  end;
  {$A4}


{ TRttiClassType object
  Universal structure describing class types }

  PRttiClassType = ^TRttiClassType;
  {$A1}
  {$ifdef BCB}
  TRttiClassType__ = record [HPPGEN(HPP_INHERIT + '(TRttiClassType, TRttiHeritableMetaType)'#13#10)] _: Byte; end;
  TRttiClassType = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiHeritableMetaType)'#13#10)] This: TRttiHeritableMetaType;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiClassType = object(TRttiHeritableMetaType) protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    ClassType: TClass;
  end;
  {$A4}


{ TRttiInterfaceType object
  Universal structure describing interface types }

  PRttiInterfaceType = ^TRttiInterfaceType;
  {$A1}
  {$ifdef BCB}
  TRttiInterfaceType__ = record [HPPGEN(HPP_INHERIT + '(TRttiInterfaceType, TRttiHeritableMetaType)'#13#10)] _: Byte; end;
  TRttiInterfaceType = record public
    [HPPGEN(HPP_RETRIEVE + '(TRttiHeritableMetaType)'#13#10)] This: TRttiHeritableMetaType;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiInterfaceType = object(TRttiHeritableMetaType) protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
  end;
  {$A4}


{ TRttiContext object
  Container that allows you to convert the internal representation of type
  information into a universal one }

  TRttiContextVmt = class
    class procedure Init(const AContext: PRttiContext); virtual;
    class procedure Finalize(const AContext: PRttiContext); virtual;
    class function Alloc(const AContext: PRttiContext; const ASize: Integer): Pointer; virtual;
    class function AllocPacked(const AContext: PRttiContext; const ASize: Integer): Pointer; virtual;
  end;
  TRttiContextVmtClass = class of TRttiContextVmt;

  {$A1}
  {$ifdef BCB}
  TRttiContext = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiContext = object protected
  {$endif}
    FVmt: TRttiContextVmtClass;
    FAlignedData: array[0..SizeOf(NativeInt) * 3 - 1 - 1] of Byte;
    FThreadSync: Boolean;
    FHeapAllocation: Boolean;
    FExpandReturnFPU: Boolean;
    FReserved: array[1..2] of Byte;

    procedure EnterRead;
    procedure EnterExclusive;
    procedure LeaveRead;
    procedure LeaveExclusive;
    function GetBaseTypeInfo(const ATypeInfo: PTypeInfo; const ATypeInfoList: array of PTypeInfo): Integer;
    function GetBooleanType(const ATypeInfo: PTypeInfo): TRttiType;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    procedure Init(const AVmt: TRttiContextVmtClass = nil; const AThreadSync: Boolean = True);
    procedure Finalize;

    function Alloc(const ASize: Integer): Pointer;
    function AllocPacked(const ASize: Integer): Pointer;
    function HeapAlloc(const ASize: Integer): Pointer;

    function AllocCustomTypeData(const ASize: Integer; const ABacketCount: Integer = 0): PRttiCustomTypeData;
    function AllocTypeData(const ABaseType: TRttiType; const ASize: Integer;
      const AName: PShortStringHelper = nil; const ABacketCount: Integer = 0): PRttiTypeData;
    function AllocMetaType(const ABaseType: TRttiType; const AName: PShortStringHelper = nil): PRttiMetaType;

    function GetType(const ATypeInfo: Pointer): TRttiType;
    function GetExType(const ATypeInfo: Pointer; var AResult: TRttiExType): Boolean; overload;
    function GetExType(const ATypeInfo: Pointer; const ATypeName: PShortStringHelper; var AResult: TRttiExType): Boolean; overload;

    property Vmt: TRttiContextVmtClass read FVmt;
    property ThreadSync: Boolean read FThreadSync write FThreadSync;
    property HeapAllocation: Boolean read FHeapAllocation write FHeapAllocation;
    property ExpandReturnFPU: Boolean read FExpandReturnFPU write FExpandReturnFPU;
  end;
  {$A4}


{ TRttiBuffer object
  Buffer that also allows you to select managed objects
  Uses heap memory and/or pre-allocated fragment }

  TRttiBufferVmt = class(TTinyBufferVmt)
    class procedure Init(const ABuffer: PTinyBuffer; const AResetMode: Boolean); override;
    class procedure Clear(const ABuffer: PTinyBuffer); override;
    class function Grow(const ABuffer: PTinyBuffer; const ASize: NativeUInt; const AAlign: NativeUInt): Pointer; override;
  end;

  PRttiBuffer = ^TRttiBuffer;
  {$A1}
  {$ifdef BCB}
  TRttiBuffer__ = record [HPPGEN(HPP_INHERIT + '(TRttiBuffer, TTinyBuffer)'#13#10)] _: Byte; end;
  TRttiBuffer = record public
    [HPPGEN(HPP_RETRIEVE + '(TTinyBuffer)'#13#10)] This: TTinyBuffer;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiBuffer = object(TTinyBuffer) protected
  {$endif}
    FHeapBlocks: Pointer;
    FManagedItems: Pointer;
    procedure InternalClear;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    procedure Init(const AFragmentMemory: Pointer = nil; const AFragmentSize: NativeUInt = 0); reintroduce; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Clear; reintroduce; {$ifdef INLINESUPPORT}inline;{$endif}
    function Alloc(const AExType: TRttiExType): Pointer; overload;
  public
    SourceExType: TRttiExType;
    function Convert(const ATargetExType: TRttiExType; const ASource: Pointer): Pointer;
  end;
  {$A4}


{ TValue object
  Any type value container (lightweight Variant) }

  PValue = ^TValue;
  {$A1}
  {$ifdef OPERATORSUPPORT}
  TValue = record
  private
  {$else}
  TValue = object
  protected
  {$endif}
    FExType: TRttiExType;
    FManagedData: IInterface;
    FBuffer: packed record
    case Integer of
      0: (VPointer: Pointer);
      1: (VBoolean: Boolean);
      2: (VInt8: ShortInt);
      3: (VUInt8: Byte);
      4: (VInt16: SmallInt);
      5: (VUInt16: Word);
      6: (VInt32: Integer);
      7: (VUInt32: Cardinal);
      8: (VInt64: Int64);
      9: (VUInt64: UInt64);
      10: (VComp: Comp);
      11: (VCurrency: Currency);
      12: (VSingle: Single);
      13: (VDouble: Double);
      14: (VLongDouble: Extended);
      15: (VClass: TClass);
      16: (VMethod: TMethod);
      17: (VBytes: array[0..15] of Byte);
    end;

    function GetExType: PRttiExType; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetBaseType: TRttiType; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetData: Pointer;
    function GetDataSize: Integer;
    function GetIsEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsObject: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsClass: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsOrdinal: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetIsFloat: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef STATICSUPPORT}class{$endif} procedure InternalReleaseInterface(AInterface: Pointer); {$ifdef STATICSUPPORT}static;{$endif}
    procedure InternalInitData(const ARules: PRttiTypeRules; const AValue: Pointer);

    procedure SetPointer(const AValue: Pointer); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetBoolean(const AValue: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetInteger(const AValue: Integer); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetCardinal(const AValue: Cardinal); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetInt64(const AValue: Int64); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetUInt64(const AValue: UInt64); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetCurrency(const AValue: Currency); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetSingle(const AValue: Single); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetDouble(const AValue: Double); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetExtended(const AValue: Extended); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetDate(const AValue: TDate); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetTime(const AValue: TTime); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetDateTime(const AValue: TDateTime); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetTimeStamp(const AValue: TimeStamp); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetAnsiString(const AValue: AnsiString); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetUnicodeString(const AValue: UnicodeString); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetObject(const AValue: TObject); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetInterface(const AValue: IInterface); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetClass(const AValue: TClass); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetBytes(const AValue: TBytes); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetMethod(const AValue: TMethod);
    procedure SetVarData(const AValue: TVarData);
    procedure SetVarRec(const AValue: TVarRec);

    function InternalGetPointer: Pointer;
    function InternalGetBoolean: Boolean;
    function InternalGetInteger: Integer;
    function InternalGetCardinal: Cardinal;
    function InternalGetInt64: Int64;
    function InternalGetUInt64: UInt64;
    function InternalGetCurrency: Currency;
    function InternalGetSingle: Single;
    function InternalGetDouble: Double;
    function InternalGetExtended: Extended;
    function InternalGetDate: TDate;
    function InternalGetTime: TTime;
    function InternalGetDateTime: TDateTime;
    function InternalGetTimeStamp: TimeStamp;
    procedure InternalGetAnsiString(var Result: AnsiString);
    procedure InternalGetUnicodeString(var Result: UnicodeString);
    function InternalGetObject: TObject; {$ifdef WEAKINSTREF}unsafe;{$endif}
    procedure InternalGetInterface(var Result{: unsafe IInterface});
    function InternalGetClass: TClass;
    procedure InternalGetBytes(var Result: TBytes);

    function GetPointer: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCurrency: Currency; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetSingle: Single; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDouble: Double; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetExtended: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDate: TDate; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTime: TTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTimeStamp: TimeStamp; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAnsiString: AnsiString; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUnicodeString: UnicodeString; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetObject: TObject; {$ifdef WEAKINSTREF}unsafe;{$endif} {$ifdef INLINESUPPORT}inline;{$endif}
    function GetInterface: IInterface; {$ifdef WEAKINTFREF}unsafe;{$endif} {Note: inline directive throws exception}
    function GetClass: TClass; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetBytes: TBytes; {$ifdef INLINESUPPORT}inline;{$endif}

    function GetMethod: TMethod;
    function GetVarData: TVarData;
    function GetVarRec: TVarRec;
  public
    {$ifdef STATICSUPPORT}class{$endif} function Empty: TValue; {$ifdef STATICSUPPORT}static;{$endif} {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Init(const AExType: TRttiExType; const AValue: Pointer); overload;
    procedure Init(const ATypeInfo: PTypeInfo; const AValue: Pointer); overload;
    {$ifdef GENERICMETHODSUPPORT}
    procedure Init<T>(const AValue: T); overload; inline;
    class function From<T>(const AValue: T): TValue; static; inline;
    function TryGet<T>(var AValue: T): Boolean;
    function Get<T>: T; inline;
    {$endif}
    procedure Clear; {$ifdef INLINESUPPORT}inline;{$endif}

    property ExType: PRttiExType read GetExType;
    property BaseType: TRttiType read GetBaseType;
    property Data: Pointer read GetData;
    property DataSize: Integer read GetDataSize;
    property IsEmpty: Boolean read GetIsEmpty;
    property IsObject: Boolean read GetIsObject;
    property IsClass: Boolean read GetIsClass;
    property IsOrdinal: Boolean read GetIsOrdinal;
    property IsFloat: Boolean read GetIsFloat;
    function IsInstanceOf(const AClass: TClass): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}

    property AsPointer: Pointer read GetPointer write SetPointer;
    property AsBoolean: Boolean read GetBoolean write SetBoolean;
    property AsInteger: Integer read GetInteger write SetInteger;
    property AsCardinal: Cardinal read GetCardinal write SetCardinal;
    property AsInt64: Int64 read GetInt64 write SetInt64;
    property AsUInt64: UInt64 read GetUInt64 write SetUInt64;
    property AsCurrency: Currency read GetCurrency write SetCurrency;
    property AsSingle: Single read GetSingle write SetSingle;
    property AsDouble: Double read GetDouble write SetDouble;
    property AsExtended: Extended read GetExtended write SetExtended;
    property AsDate: TDate read GetDate write SetDate;
    property AsTime: TTime read GetTime write SetTime;
    property AsDateTime: TDateTime read GetDateTime write SetDateTime;
    property AsTimeStamp: TimeStamp read GetTimeStamp write SetTimeStamp;
    property AsAnsiString: AnsiString read GetAnsiString write SetAnsiString;
    property AsUnicodeString: UnicodeString read GetUnicodeString write SetUnicodeString;
    property AsString: string
      {$ifdef UNICODE}
        read GetUnicodeString write SetUnicodeString
      {$else .ANSI}
        read GetAnsiString write SetAnsiString
      {$endif};
    {$ifdef WEAKINSTREF}[Unsafe]{$endif}
    property AsObject: TObject read GetObject write SetObject;
    {$ifdef WEAKINTFREF}[Unsafe]{$endif}
    property AsInterface: IInterface read GetInterface write SetInterface;
    property AsClass: TClass read GetClass write SetClass;
    property AsBytes: TBytes read GetBytes write SetBytes;

    property AsMethod: TMethod read GetMethod write SetMethod;
    property AsVarData: TVarData read GetVarData write SetVarData;
    property AsVarRec: TVarRec read GetVarRec write SetVarRec;
  public
  {$ifdef VALUEOPERATORSUPPORT}
    class operator Implicit(const AValue: Pointer): TValue; inline;
    class operator Implicit(const AValue: Boolean): TValue; inline;
    class operator Implicit(const AValue: Integer): TValue; inline;
    class operator Implicit(const AValue: Cardinal): TValue; inline;
    class operator Implicit(const AValue: Int64): TValue; inline;
    class operator Implicit(const AValue: UInt64): TValue; inline;
    class operator Implicit(const AValue: Currency): TValue; inline;
    class operator Implicit(const AValue: Single): TValue; inline;
    class operator Implicit(const AValue: Double): TValue; inline;
    {$ifdef EXTENDEDSUPPORT}
    class operator Implicit(const AValue: Extended): TValue; inline;
    {$endif}
    class operator Implicit(const AValue: TDate): TValue; inline;
    class operator Implicit(const AValue: TTime): TValue; inline;
    class operator Implicit(const AValue: TDateTime): TValue; inline;
    class operator Implicit(const AValue: TimeStamp): TValue; inline;
    class operator Implicit(const AValue: AnsiString): TValue; inline;
    class operator Implicit(const AValue: UnicodeString): TValue; inline;
    class operator Implicit(const AValue: TObject): TValue; inline;
    class operator Implicit(const AValue: IInterface): TValue; inline;
    class operator Implicit(const AValue: TClass): TValue; inline;
    class operator Implicit(const AValue: TBytes): TValue; inline;
  {$endif}

  {$ifdef VALUEOPERATORSUPPORT}
    class operator Implicit(const AValue: TValue): Pointer; inline;
    class operator Implicit(const AValue: TValue): Boolean; inline;
    class operator Implicit(const AValue: TValue): Integer; inline;
    class operator Implicit(const AValue: TValue): Cardinal; inline;
    class operator Implicit(const AValue: TValue): Int64; inline;
    class operator Implicit(const AValue: TValue): UInt64; inline;
    class operator Implicit(const AValue: TValue): Currency; inline;
    class operator Implicit(const AValue: TValue): Single; inline;
    class operator Implicit(const AValue: TValue): Double; inline;
    {$ifdef EXTENDEDSUPPORT}
    class operator Implicit(const AValue: TValue): Extended; inline;
    {$endif}
    class operator Implicit(const AValue: TValue): TDate; inline;
    class operator Implicit(const AValue: TValue): TTime; inline;
    class operator Implicit(const AValue: TValue): TDateTime; inline;
    class operator Implicit(const AValue: TValue): TimeStamp; inline;
    class operator Implicit(const AValue: TValue): AnsiString; inline;
    class operator Implicit(const AValue: TValue): UnicodeString; inline;
    class operator Implicit(const AValue: TValue): TObject; {$ifdef WEAKINSTREF}unsafe;{$endif} inline;
    class operator Implicit(const AValue: TValue): IInterface; {$ifdef WEAKINTFREF}unsafe;{$endif} {Note: inline directive throws exception}
    class operator Implicit(const AValue: TValue): TClass; inline;
    class operator Implicit(const AValue: TValue): TBytes; inline;
  {$endif}
  end;
  {$A4}
  PValueDynArray = ^TValueDynArray;
  TValueDynArray = {$ifdef SYSARRAYSUPPORT}TArray<TValue>{$else}array of TValue{$endif};


var
  {$ifdef EXTERNALLINKER}
  RTTI_TYPE_GROUPS: array[TRttiType] of TRttiTypeGroup;
  __RTTI_TYPE_GROUPS: array[TRttiType] of TRttiTypeGroup  = (
  {$else}
  RTTI_TYPE_GROUPS: array[TRttiType] of TRttiTypeGroup = (
  {$endif}
    // rgUnknown
    {000} rgUnknown, // rtUnknown,
    // rgPointer
    {001} rgPointer, // rtPointer,
    // rgBoolean
    {002} rgBoolean, // rtBoolean8,
    {003} rgBoolean, // rtBoolean16,
    {004} rgBoolean, // rtBoolean32,
    {005} rgBoolean, // rtBoolean64,
    {006} rgBoolean, // rtBool8,
    {007} rgBoolean, // rtBool16,
    {008} rgBoolean, // rtBool32,
    {009} rgBoolean, // rtBool64,
    // rgOrdinal
    {010} rgOrdinal, // rtInt8,
    {011} rgOrdinal, // rtUInt8,
    {012} rgOrdinal, // rtInt16,
    {013} rgOrdinal, // rtUInt16,
    {014} rgOrdinal, // rtInt32,
    {015} rgOrdinal, // rtUInt32,
    {016} rgOrdinal, // rtInt64,
    {017} rgOrdinal, // rtUInt64,
    // rgFloat
    {018} rgFloat, // rtComp,
    {019} rgFloat, // rtCurrency,
    {020} rgFloat, // rtFloat,
    {021} rgFloat, // rtDouble,
    {022} rgFloat, // rtLongDouble80,
    {023} rgFloat, // rtLongDouble96,
    {024} rgFloat, // rtLongDouble128,
    // rgDateTime
    {025} rgDateTime, // rtDate,
    {026} rgDateTime, // rtTime,
    {027} rgDateTime, // rtDateTime,
    {028} rgDateTime, // rtTimeStamp,
    // rgString
    {029} rgString, // rtSBCSChar,
    {030} rgString, // rtUTF8Char,
    {031} rgString, // rtWideChar,
    {032} rgString, // rtUCS4Char,
    {033} rgString, // rtPSBCSChars,
    {034} rgString, // rtPUTF8Chars,
    {035} rgString, // rtPWideChars,
    {036} rgString, // rtPUCS4Chars,
    {037} rgString, // rtSBCSString,
    {038} rgString, // rtUTF8String,
    {039} rgString, // rtWideString,
    {040} rgString, // rtUnicodeString,
    {041} rgString, // rtUCS4String,
    {042} rgString, // rtShortString,
    // rgEnumeration
    {043} rgEnumeration, // rtEnumeration8,
    {044} rgEnumeration, // rtEnumeration16,
    {045} rgEnumeration, // rtEnumeration32,
    {046} rgEnumeration, // rtEnumeration64,
    // rgMetaType
    {047} rgMetaType, // rtSet,
    {048} rgMetaType, // rtStaticArray,
    {049} rgMetaType, // rtDynamicArray,
    {050} rgMetaType, // rtStructure,
    {051} rgMetaType, // rtObject,
    {052} rgMetaType, // rtInterface,
    // rgMetaTypeRef
    {053} rgMetaTypeRef, // rtClassRef,
    // rgFunction
    {054} rgFunction, // rtFunction,
    {055} rgFunction, // rtMethod,
    {056} rgFunction, // rtClosure,
    // rgVariant
    {057} rgVariant, // rtBytes,
    {058} rgVariant, // rtOleVariant,
    {059} rgVariant, // rtVariant,
    {060} rgVariant, // rtVarRec,
    {061} rgVariant, // rtValue,
    // Reserved
    {062} rgUnknown, {063} rgUnknown,
    {064} rgUnknown, {065} rgUnknown, {066} rgUnknown, {067} rgUnknown, {068} rgUnknown, {069} rgUnknown,
    {070} rgUnknown, {071} rgUnknown, {072} rgUnknown, {073} rgUnknown, {074} rgUnknown, {075} rgUnknown,
    {076} rgUnknown, {077} rgUnknown, {078} rgUnknown, {079} rgUnknown, {080} rgUnknown, {081} rgUnknown,
    {082} rgUnknown, {083} rgUnknown, {084} rgUnknown, {085} rgUnknown, {086} rgUnknown, {087} rgUnknown,
    {088} rgUnknown, {089} rgUnknown, {090} rgUnknown, {091} rgUnknown, {092} rgUnknown, {093} rgUnknown,
    {094} rgUnknown, {095} rgUnknown, {096} rgUnknown, {097} rgUnknown, {098} rgUnknown, {099} rgUnknown,
    {100} rgUnknown, {101} rgUnknown, {102} rgUnknown, {103} rgUnknown, {104} rgUnknown, {105} rgUnknown,
    {106} rgUnknown, {107} rgUnknown, {108} rgUnknown, {109} rgUnknown, {110} rgUnknown, {111} rgUnknown,
    {112} rgUnknown, {113} rgUnknown, {114} rgUnknown, {115} rgUnknown, {116} rgUnknown, {117} rgUnknown,
    {118} rgUnknown, {119} rgUnknown, {120} rgUnknown, {121} rgUnknown, {122} rgUnknown, {123} rgUnknown,
    {124} rgUnknown, {125} rgUnknown, {126} rgUnknown, {127} rgUnknown, {128} rgUnknown, {129} rgUnknown,
    {130} rgUnknown, {131} rgUnknown, {132} rgUnknown, {133} rgUnknown, {134} rgUnknown, {135} rgUnknown,
    {136} rgUnknown, {137} rgUnknown, {138} rgUnknown, {139} rgUnknown, {140} rgUnknown, {141} rgUnknown,
    {142} rgUnknown, {143} rgUnknown, {144} rgUnknown, {145} rgUnknown, {146} rgUnknown, {147} rgUnknown,
    {148} rgUnknown, {149} rgUnknown, {150} rgUnknown, {151} rgUnknown, {152} rgUnknown, {153} rgUnknown,
    {154} rgUnknown, {155} rgUnknown, {156} rgUnknown, {157} rgUnknown, {158} rgUnknown, {159} rgUnknown,
    {160} rgUnknown, {161} rgUnknown, {162} rgUnknown, {163} rgUnknown, {164} rgUnknown, {165} rgUnknown,
    {166} rgUnknown, {167} rgUnknown, {168} rgUnknown, {169} rgUnknown, {170} rgUnknown, {171} rgUnknown,
    {172} rgUnknown, {173} rgUnknown, {174} rgUnknown, {175} rgUnknown, {176} rgUnknown, {177} rgUnknown,
    {178} rgUnknown, {179} rgUnknown, {180} rgUnknown, {181} rgUnknown, {182} rgUnknown, {183} rgUnknown,
    {184} rgUnknown, {185} rgUnknown, {186} rgUnknown, {187} rgUnknown, {188} rgUnknown, {189} rgUnknown,
    {190} rgUnknown, {191} rgUnknown, {192} rgUnknown, {193} rgUnknown, {194} rgUnknown, {195} rgUnknown,
    {196} rgUnknown, {197} rgUnknown, {198} rgUnknown, {199} rgUnknown, {200} rgUnknown, {201} rgUnknown,
    {202} rgUnknown, {203} rgUnknown, {204} rgUnknown, {205} rgUnknown, {206} rgUnknown, {207} rgUnknown,
    {208} rgUnknown, {209} rgUnknown, {210} rgUnknown, {211} rgUnknown, {212} rgUnknown, {213} rgUnknown,
    {214} rgUnknown, {215} rgUnknown, {216} rgUnknown, {217} rgUnknown, {218} rgUnknown, {219} rgUnknown,
    {220} rgUnknown, {221} rgUnknown, {222} rgUnknown, {223} rgUnknown, {224} rgUnknown, {225} rgUnknown,
    {226} rgUnknown, {227} rgUnknown, {228} rgUnknown, {229} rgUnknown, {230} rgUnknown, {231} rgUnknown,
    {232} rgUnknown, {233} rgUnknown, {234} rgUnknown, {235} rgUnknown, {236} rgUnknown, {237} rgUnknown,
    {238} rgUnknown, {239} rgUnknown, {240} rgUnknown, {241} rgUnknown, {242} rgUnknown, {243} rgUnknown,
    {244} rgUnknown, {245} rgUnknown, {246} rgUnknown, {247} rgUnknown, {248} rgUnknown, {249} rgUnknown,
    {250} rgUnknown, {251} rgUnknown, {252} rgUnknown, {253} rgUnknown, {254} rgUnknown, {255} rgUnknown);
    {$ifdef FPC}public name 'RTTI_TYPE_GROUPS';{$endif}


const

  RTTI_INITNONE_FUNC = 0;
  RTTI_INITPOINTER_FUNC = 1;
  RTTI_INITPOINTERPAIR_FUNC = 2;
  RTTI_INITMETATYPE_FUNC = 3;
  RTTI_INITVALUE_FUNC = 4;
  RTTI_INITBYTES_LOWFUNC = 5;
  RTTI_INITBYTES_MAXCOUNT = 32;
  RTTI_INITBYTES_HIGHFUNC = RTTI_INITBYTES_LOWFUNC + RTTI_INITBYTES_MAXCOUNT;
  RTTI_INITRTL_LOWFUNC = 38;
  RTTI_INITFULLSTATICARRAY_FUNC = RTTI_INITRTL_LOWFUNC + 0;
  RTTI_INITFULLSTRUCTURE_FUNC = RTTI_INITRTL_LOWFUNC + 1;

  RTTI_FINALNONE_FUNC = 0;
  RTTI_FINALMETATYPE_FUNC = 1;
  RTTI_FINALWEAKMETATYPE_FUNC = 2;
  RTTI_FINALINTERFACE_FUNC = 3;
  RTTI_FINALVALUE_FUNC = 4;
  RTTI_FINALRTL_LOWFUNC = 5;
  RTTI_FINALSTRING_FUNC = RTTI_FINALRTL_LOWFUNC + 0;
  RTTI_FINALWIDESTRING_FUNC = RTTI_FINALRTL_LOWFUNC + 1;
  RTTI_FINALWEAKINTERFACE_FUNC = RTTI_FINALRTL_LOWFUNC + 2;
  RTTI_FINALREFOBJECT_FUNC = RTTI_FINALRTL_LOWFUNC + 3;
  RTTI_FINALWEAKREFOBJECT_FUNC = RTTI_FINALRTL_LOWFUNC + 4;
  RTTI_FINALVARIANT_FUNC = RTTI_FINALRTL_LOWFUNC + 5;
  RTTI_FINALWEAKMETHOD_FUNC = RTTI_FINALRTL_LOWFUNC + 6;
  RTTI_FINALDYNARRAY_FUNC = RTTI_FINALRTL_LOWFUNC + 7;
  RTTI_FINALFULLDYNARRAY_FUNC = RTTI_FINALRTL_LOWFUNC + 8;
  RTTI_FINALFULLSTATICARRAY_FUNC = RTTI_FINALRTL_LOWFUNC + 9;
  RTTI_FINALFULLSTRUCTURE_FUNC = RTTI_FINALRTL_LOWFUNC + 10;

  RTTI_COPYREFERENCE_FUNC = 0;
  RTTI_COPYNATIVE_FUNC = 1;
  RTTI_COPYALTERNATIVE_FUNC = 2;
  RTTI_COPYMETATYPE_FUNC = 3;
  RTTI_COPYWEAKMETATYPE_FUNC = 4;
  RTTI_COPYMETATYPEBYTES_FUNC = 5;
  RTTI_COPYINTERFACE_FUNC = 6;
  RTTI_COPYVALUE_FUNC = 7;
  RTTI_COPYBYTES_CARDINAL = RTTI_COPYNATIVE_FUNC {$ifdef LARGEINT} + 1{$endif};
  RTTI_COPYBYTES_INT64 = RTTI_COPYNATIVE_FUNC {$ifdef SMALLINT} + 1{$endif};
  RTTI_COPYBYTES_LOWFUNC = 8;
  RTTI_COPYBYTES_MAXCOUNT = 64;
  RTTI_COPYBYTES_HIGHFUNC = RTTI_COPYBYTES_LOWFUNC + RTTI_COPYBYTES_MAXCOUNT;
  RTTI_COPYHFAREAD_LOWFUNC = 73;
  RTTI_COPYHFAWRITE_LOWFUNC = 76;
  RTTI_COPYSHORTSTRING_FUNC = 79;
  RTTI_COPYRTL_LOWFUNC = 80;
  RTTI_COPYSTRING_FUNC = RTTI_COPYRTL_LOWFUNC + 0;
  RTTI_COPYWIDESTRING_FUNC = RTTI_COPYRTL_LOWFUNC + 1;
  RTTI_COPYWEAKINTERFACE_FUNC = RTTI_COPYRTL_LOWFUNC + 2;
  RTTI_COPYREFOBJECT_FUNC = RTTI_COPYRTL_LOWFUNC + 3;
  RTTI_COPYWEAKREFOBJECT_FUNC = RTTI_COPYRTL_LOWFUNC + 4;
  RTTI_COPYVARIANT_FUNC = RTTI_COPYRTL_LOWFUNC + 5;
  RTTI_COPYWEAKMETHOD_FUNC = RTTI_COPYRTL_LOWFUNC + 6;
  RTTI_COPYDYNARRAY_FUNC = RTTI_COPYRTL_LOWFUNC + 7;
  RTTI_COPYFULLDYNARRAY_FUNC = RTTI_COPYRTL_LOWFUNC + 8;
  RTTI_COPYSTATICARRAY_FUNC = RTTI_COPYRTL_LOWFUNC + 9;
  RTTI_COPYFULLSTATICARRAY_FUNC = RTTI_COPYRTL_LOWFUNC + 10;
  RTTI_COPYSTRUCTURE_FUNC = RTTI_COPYRTL_LOWFUNC + 11;
  RTTI_COPYFULLSTRUCTURE_FUNC = RTTI_COPYRTL_LOWFUNC + 12;
  RTTI_COPYVAROPENSTRINGWRITE_FUNC = RTTI_COPYRTL_LOWFUNC + 13;
  RTTI_COPYARGARRAYREAD_FUNC = RTTI_COPYRTL_LOWFUNC + 14;
  RTTI_COPYARGARRAYWRITE_FUNC = RTTI_COPYRTL_LOWFUNC + 15;

var

{ Initialization functions:
    0: none
    1: pointer
    2: pointer pair
    3: metatype function
    4: value
    5..37: N bytes
    - RTL -
    38: static array (type information)
    39: structure (type information) }

  RTTI_INIT_FUNCS: array[Byte] of TRttiTypeFunc {$ifdef FPC}public name 'RTTI_INIT_FUNCS'{$endif};

{ Finalization functions:
    0: none
    1: metatype function
    2: metatype weak function
    3: interface
    4: value
    - RTL -
    5: string
    6: wide string
    7: weak interface
    8: referenced object
    9: weak referenced object
    10: variant
    11: weak method
    12: dynamic array (simple)
    13: dynamic array (type information)
    14: static array (type information)
    15: structure (type information) }

  RTTI_FINAL_FUNCS: array[Byte] of TRttiTypeFunc {$ifdef FPC}public name 'RTTI_FINAL_FUNCS'{$endif};

{ Copy functions:
    0: reference pointer
    1: pointer (native int)
    2: alternative int (8/4 bytes)
    3: metatype function
    4: metatype weak function
    5: metatype bytes
    6: interface
    7: value
    8..72: N bytes
    73,74,75: hfaread_f2..4
    76,77,76: hfawrite_f2..4
    79: short string
    - RTL -
    80: string
    81: wide string
    82: weak interface
    83: referenced object
    84: weak referenced object
    85: variant
    86: weak method
    87: dynamic array (simple)
    88: dynamic array (type information)
    89: static array (simple)
    90: static array (type information)
    91: structure (simple)
    92: structure (type information)
    93: variable open(short) string write
    94: argument array (read to dynamic array)
    95: argument array (write from dynamic array) }

  RTTI_COPY_FUNCS: array[Byte] of TRttiCopyFunc {$ifdef FPC}public name 'RTTI_COPY_FUNCS'{$endif};


const

  RTTI_RULEFLAGS_STACKDATA = [];
  RTTI_RULEFLAGS_REFERENCE = [tfGenUseArg];
  RTTI_RULEFLAGS_REGGENERAL = [tfRegValueArg, tfGenUseArg];
  RTTI_RULEFLAGS_REGEXTENDED = [tfRegValueArg];

  RTTI_RULES_NONE: TRttiTypeRules = (Size: 0;
    Return: Low(TRttiTypeReturn); Flags: []; Reserved: 0;
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYBYTES_LOWFUNC + 0; WeakCopyFunc: RTTI_COPYBYTES_LOWFUNC + 0;);
  RTTI_RULES_BYTE: TRttiTypeRules = (Size: SizeOf(Byte);
    Return: trGeneral; Flags: RTTI_RULEFLAGS_REGGENERAL;
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYBYTES_LOWFUNC + 1; WeakCopyFunc: RTTI_COPYBYTES_LOWFUNC + 1;);
  RTTI_RULES_WORD: TRttiTypeRules = (Size: SizeOf(Word);
    Return: trGeneral; Flags: RTTI_RULEFLAGS_REGGENERAL;
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYBYTES_LOWFUNC + 2; WeakCopyFunc: RTTI_COPYBYTES_LOWFUNC + 2;);
  RTTI_RULES_CARDINAL: TRttiTypeRules = (Size: SizeOf(Cardinal);
    Return: trGeneral; Flags: RTTI_RULEFLAGS_REGGENERAL;
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYBYTES_CARDINAL; WeakCopyFunc: RTTI_COPYBYTES_CARDINAL;);
  RTTI_RULES_NATIVE: TRttiTypeRules = (Size: SizeOf(NativeUInt);
    Return: trGeneral; Flags: RTTI_RULEFLAGS_REGGENERAL;
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYNATIVE_FUNC; WeakCopyFunc: RTTI_COPYNATIVE_FUNC;);
  RTTI_RULES_INT64: TRttiTypeRules = (Size: SizeOf(Int64);
    Return: {$ifdef LARGEINT}trGeneral{$else}trGeneralPair{$endif};
    Flags: {$ifdef CPUX86}RTTI_RULEFLAGS_STACKDATA{$else}RTTI_RULEFLAGS_REGGENERAL{$endif};
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYBYTES_INT64; WeakCopyFunc: RTTI_COPYBYTES_INT64;);
  RTTI_RULES_FLOAT: TRttiTypeRules = (Size: SizeOf(Single);
    {$if Defined(CPUX86)}
      Return: trFPU; Flags: RTTI_RULEFLAGS_STACKDATA;
    {$elseif not Defined(ARM_NO_VFP_USE)}
      Return: trFloat1; Flags: RTTI_RULEFLAGS_REGEXTENDED;
    {$else}
      Return: trGeneral; Flags: RTTI_RULEFLAGS_REGGENERAL;
    {$ifend}
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYBYTES_CARDINAL; WeakCopyFunc: RTTI_COPYBYTES_CARDINAL;);
  RTTI_RULES_DOUBLE: TRttiTypeRules = (Size: SizeOf(Double);
    {$if Defined(CPUX86)}
      Return: trFPU; Flags: RTTI_RULEFLAGS_STACKDATA;
    {$elseif not Defined(ARM_NO_VFP_USE)}
      Return: trDouble1; Flags: RTTI_RULEFLAGS_REGEXTENDED;
    {$else}
      Return: trGeneralPair; Flags: RTTI_RULEFLAGS_REGGENERAL;
    {$ifend}
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYBYTES_INT64; WeakCopyFunc: RTTI_COPYBYTES_INT64;);
  RTTI_RULES_LONGDOUBLE80: TRttiTypeRules = (Size: 10;
    Return: trGeneral; Flags: RTTI_RULEFLAGS_STACKDATA;
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYBYTES_LOWFUNC + 10; WeakCopyFunc: RTTI_COPYBYTES_LOWFUNC + 10;);
  RTTI_RULES_LONGDOUBLE96: TRttiTypeRules = (Size: 12;
    Return: trGeneral; Flags: RTTI_RULEFLAGS_STACKDATA;
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYBYTES_LOWFUNC + 12; WeakCopyFunc: RTTI_COPYBYTES_LOWFUNC + 12;);
  RTTI_RULES_LONGDOUBLE128: TRttiTypeRules = (Size: 16;
    Return: trGeneral; Flags: RTTI_RULEFLAGS_STACKDATA;
     InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
     CopyFunc: RTTI_COPYBYTES_LOWFUNC + 16; WeakCopyFunc: RTTI_COPYBYTES_LOWFUNC + 16;);
  {$ifdef CPUX86}
  RTTI_RULES_COMPCURRENCYX86: TRttiTypeRules = (Size: SizeOf(Comp);
    Return: trFPUInt64; Flags: RTTI_RULEFLAGS_STACKDATA;
    InitFunc: 0; FinalFunc: 0; WeakFinalFunc: 0;
    CopyFunc: RTTI_COPYBYTES_INT64; WeakCopyFunc: RTTI_COPYBYTES_INT64;);
  {$endif}
  RTTI_RULES_STRING: TRttiTypeRules = (Size: SizeOf(NativeUInt);
    Return: trReference; Flags: RTTI_RULEFLAGS_REGGENERAL + [tfManaged];
    InitFunc: RTTI_INITPOINTER_FUNC; FinalFunc: RTTI_FINALSTRING_FUNC; WeakFinalFunc: RTTI_FINALSTRING_FUNC;
    CopyFunc: RTTI_COPYSTRING_FUNC; WeakCopyFunc: RTTI_COPYSTRING_FUNC;);
  {$ifdef MSWINDOWS}
  RTTI_RULES_BSTR: TRttiTypeRules = (Size: SizeOf(NativeUInt);
    Return: trReference; Flags: RTTI_RULEFLAGS_REGGENERAL + [tfManaged];
    InitFunc: RTTI_INITPOINTER_FUNC; FinalFunc: RTTI_FINALWIDESTRING_FUNC; WeakFinalFunc: RTTI_FINALWIDESTRING_FUNC;
    CopyFunc: RTTI_COPYWIDESTRING_FUNC; WeakCopyFunc: RTTI_COPYWIDESTRING_FUNC;);
  {$endif}
  RTTI_RULES_DYNARRAYSIMPLE: TRttiTypeRules = (Size: SizeOf(NativeUInt);
    Return: trReference; Flags: RTTI_RULEFLAGS_REGGENERAL + [tfManaged];
    InitFunc: RTTI_INITPOINTER_FUNC; FinalFunc: RTTI_FINALDYNARRAY_FUNC; WeakFinalFunc: RTTI_FINALDYNARRAY_FUNC;
    CopyFunc: RTTI_COPYDYNARRAY_FUNC; WeakCopyFunc: RTTI_COPYDYNARRAY_FUNC;);
  {$ifdef WEAKINSTREF}
  RTTI_RULES_REFOBJECT: TRttiTypeRules = (Size: SizeOf(NativeUInt);
    Return: trReference; Flags: RTTI_RULEFLAGS_REGGENERAL + [tfManaged, tfUnsafable, tfWeakable, tfHasWeakRef];
    InitFunc: RTTI_INITPOINTER_FUNC; FinalFunc: RTTI_FINALREFOBJECT_FUNC; WeakFinalFunc: RTTI_FINALWEAKREFOBJECT_FUNC;
    CopyFunc: RTTI_COPYREFOBJECT_FUNC; WeakCopyFunc: RTTI_COPYWEAKREFOBJECT_FUNC;);
  {$endif}
  RTTI_RULES_INTERFACE: TRttiTypeRules = (Size: SizeOf(NativeUInt);
    Return: trReference; Flags: RTTI_RULEFLAGS_REGGENERAL + [tfManaged{$ifdef WEAKINTFREF}, tfUnsafable, tfWeakable, tfHasWeakRef{$endif}];
    InitFunc: RTTI_INITPOINTER_FUNC; FinalFunc: RTTI_FINALINTERFACE_FUNC; WeakFinalFunc: {$ifdef WEAKINTFREF}RTTI_FINALWEAKINTERFACE_FUNC{$else}RTTI_FINALINTERFACE_FUNC{$endif};
    CopyFunc: RTTI_COPYINTERFACE_FUNC; WeakCopyFunc: {$ifdef WEAKINTFREF}RTTI_COPYWEAKINTERFACE_FUNC{$else}RTTI_COPYINTERFACE_FUNC{$endif};);
  {$if Defined(WEAKINTFREF)}
  RTTI_RULES_METHOD_COPYFUNC = RTTI_COPYWEAKMETHOD_FUNC;
  {$elseif Defined(SMALLINT)}
  RTTI_RULES_METHOD_COPYFUNC = RTTI_COPYALTERNATIVE_FUNC;
  {$else}
  RTTI_RULES_METHOD_COPYFUNC = RTTI_COPYBYTES_LOWFUNC + SizeOf(TMethod);
  {$ifend}
  RTTI_RULES_METHOD: TRttiTypeRules = (Size: SizeOf(TMethod);
    Return: trReference;
    Flags: {$ifdef CPUX86}RTTI_RULEFLAGS_STACKDATA{$else}RTTI_RULEFLAGS_REFERENCE{$endif} {$ifdef WEAKINTFREF} + [tfManaged, tfUnsafable, tfWeakable, tfHasWeakRef]{$endif};
    InitFunc: {$ifdef SMALLINT}RTTI_INITPOINTERPAIR_FUNC{$else}RTTI_INITBYTES_LOWFUNC + SizeOf(TMethod){$endif};
    FinalFunc: {$ifdef WEAKINTFREF}RTTI_FINALWEAKMETHOD_FUNC{$else}RTTI_FINALNONE_FUNC{$endif};
    WeakFinalFunc: {$ifdef WEAKINTFREF}RTTI_FINALWEAKMETHOD_FUNC{$else}RTTI_FINALNONE_FUNC{$endif};
    CopyFunc: RTTI_RULES_METHOD_COPYFUNC; WeakCopyFunc: RTTI_RULES_METHOD_COPYFUNC;);
  RTTI_RULES_VARIANT: TRttiTypeRules = (Size: SizeOf(TVarData);
    Return: trReference; Flags: RTTI_RULEFLAGS_REFERENCE + [{$ifdef CPUX86}tfOptionalRefArg,{$endif} tfManaged];
    InitFunc: RTTI_INITPOINTER_FUNC; FinalFunc: RTTI_FINALVARIANT_FUNC; WeakFinalFunc: RTTI_FINALVARIANT_FUNC;
    CopyFunc: RTTI_COPYVARIANT_FUNC; WeakCopyFunc: RTTI_COPYVARIANT_FUNC;);
  RTTI_RULES_VARREC: TRttiTypeRules = (Size: SizeOf(TVarRec);
    Return: trReference; Flags: RTTI_RULEFLAGS_REFERENCE;
    InitFunc: RTTI_INITNONE_FUNC; FinalFunc: RTTI_FINALNONE_FUNC; WeakFinalFunc: RTTI_FINALNONE_FUNC;
    CopyFunc: RTTI_COPYBYTES_LOWFUNC + SizeOf(TVarRec); WeakCopyFunc: RTTI_COPYBYTES_LOWFUNC + SizeOf(TVarRec););
  RTTI_RULES_VALUE: TRttiTypeRules = (Size: SizeOf(TValue);
    Return: trReference; Flags: RTTI_RULEFLAGS_REFERENCE + [tfManaged];
    InitFunc: RTTI_INITVALUE_FUNC; FinalFunc: RTTI_FINALVALUE_FUNC; WeakFinalFunc: RTTI_FINALVALUE_FUNC;
    CopyFunc: RTTI_COPYVALUE_FUNC; WeakCopyFunc: RTTI_COPYVALUE_FUNC;);

var
  {$ifdef EXTERNALLINKER}
  RTTI_TYPE_RULES: array[TRttiType] of PRttiTypeRules;
  __RTTI_TYPE_RULES: array[TRttiType] of PRttiTypeRules = (
  {$else}
  RTTI_TYPE_RULES: array[TRttiType] of PRttiTypeRules = (
  {$endif}
    // rgUnknown
    {000} @RTTI_RULES_NONE, // rtUnknown,
    // rgPointer
    {001} @RTTI_RULES_NATIVE, // rtPointer,
    // rgBoolean
    {002} @RTTI_RULES_BYTE, // rtBoolean8,
    {003} @RTTI_RULES_WORD, // rtBoolean16,
    {004} @RTTI_RULES_CARDINAL, // rtBoolean32,
    {005} @RTTI_RULES_INT64, // rtBoolean64,
    {006} @RTTI_RULES_BYTE, // rtBool8,
    {007} @RTTI_RULES_WORD, // rtBool16,
    {008} @RTTI_RULES_CARDINAL, // rtBool32,
    {009} @RTTI_RULES_INT64, // rtBool64,
    // rgOrdinal
    {010} @RTTI_RULES_BYTE, // rtInt8,
    {011} @RTTI_RULES_BYTE, // rtUInt8,
    {012} @RTTI_RULES_WORD, // rtInt16,
    {013} @RTTI_RULES_WORD, // rtUInt16,
    {014} @RTTI_RULES_CARDINAL, // rtInt32,
    {015} @RTTI_RULES_CARDINAL, // rtUInt32,
    {016} @RTTI_RULES_INT64, // rtInt64,
    {017} @RTTI_RULES_INT64, // rtUInt64,
    // rgFloat
    {018} @{$ifdef CPUX86}RTTI_RULES_COMPCURRENCYX86{$else}RTTI_RULES_INT64{$endif}, // rtComp,
    {019} @{$ifdef CPUX86}RTTI_RULES_COMPCURRENCYX86{$else}RTTI_RULES_INT64{$endif}, // rtCurrency,
    {020} @RTTI_RULES_FLOAT, // rtFloat,
    {021} @RTTI_RULES_DOUBLE, // rtDouble,
    {022} @RTTI_RULES_LONGDOUBLE80, // rtLongDouble80,
    {023} @RTTI_RULES_LONGDOUBLE96, // rtLongDouble96,
    {024} @RTTI_RULES_LONGDOUBLE128, // rtLongDouble128,
    // rgDateTime
    {025} @RTTI_RULES_DOUBLE, // rtDate,
    {026} @RTTI_RULES_DOUBLE, // rtTime,
    {027} @RTTI_RULES_DOUBLE, // rtDateTime,
    {028} @RTTI_RULES_INT64, // rtTimeStamp,
    // rgString
    {029} @RTTI_RULES_BYTE, // rtSBCSChar,
    {030} @RTTI_RULES_BYTE, // rtUTF8Char,
    {031} @RTTI_RULES_WORD, // rtWideChar,
    {032} @RTTI_RULES_WORD, // rtUCS4Char,
    {033} @RTTI_RULES_NATIVE, // rtPSBCSChars,
    {034} @RTTI_RULES_NATIVE, // rtPUTF8Chars,
    {035} @RTTI_RULES_NATIVE, // rtPWideChars,
    {036} @RTTI_RULES_NATIVE, // rtPUCS4Chars,
    {037} @RTTI_RULES_STRING, // rtSBCSString,
    {038} @RTTI_RULES_STRING, // rtUTF8String,
    {039} // rtWideString,
      {$if Defined(MSWINDOWS)}
        @RTTI_RULES_BSTR
      {$elseif Defined(FPC)}
        @RTTI_RULES_STRING
      {$else}
        @RTTI_RULES_DYNARRAYSIMPLE
      {$ifend},
    {040} @{$ifdef UNICODE}RTTI_RULES_STRING{$else}RTTI_RULES_BSTR{$endif}, // rtUnicodeString,
    {041} @RTTI_RULES_DYNARRAYSIMPLE, // rtUCS4String,
    {042} nil, // rtShortString,
    // rgEnumeration
    {043} @RTTI_RULES_BYTE, // rtEnumeration8,
    {044} @RTTI_RULES_WORD, // rtEnumeration16,
    {045} @RTTI_RULES_CARDINAL, // rtEnumeration32,
    {046} @RTTI_RULES_INT64, // rtEnumeration64,
    // rgMetaType
    {047} nil, // rtSet,
    {048} nil, // rtStaticArray,
    {049} nil, // rtDynamicArray,
    {050} nil, // rtStructure,
    {051} @{$ifdef WEAKINSTREF}RTTI_RULES_REFOBJECT{$else}RTTI_RULES_NATIVE{$endif}, // rtObject,
    {052} @RTTI_RULES_INTERFACE, // rtInterface,
    // rgMetaTypeRef
    {053} @RTTI_RULES_NATIVE, // rtClassRef,
    // rgFunction
    {054} @RTTI_RULES_NATIVE, // rtFunction,
    {055} @RTTI_RULES_METHOD, // rtMethod,
    {056} @RTTI_RULES_INTERFACE, // rtClosure,
    // rgVariant
    {057} @RTTI_RULES_DYNARRAYSIMPLE, // rtBytes,
    {058} @RTTI_RULES_VARIANT, // rtOleVariant,
    {059} @RTTI_RULES_VARIANT, // rtVariant,
    {060} @RTTI_RULES_VARREC, // rtVarRec,
    {061} @RTTI_RULES_VALUE, // rtValue,
    // Reserved
    {062} nil, {063} nil,
    {064} nil, {065} nil, {066} nil, {067} nil, {068} nil, {069} nil, {070} nil, {071} nil,
    {072} nil, {073} nil, {074} nil, {075} nil, {076} nil, {077} nil, {078} nil, {079} nil,
    {080} nil, {081} nil, {082} nil, {083} nil, {084} nil, {085} nil, {086} nil, {087} nil,
    {088} nil, {089} nil, {090} nil, {091} nil, {092} nil, {093} nil, {094} nil, {095} nil,
    {096} nil, {097} nil, {098} nil, {099} nil, {100} nil, {101} nil, {102} nil, {103} nil,
    {104} nil, {105} nil, {106} nil, {107} nil, {108} nil, {109} nil, {110} nil, {111} nil,
    {112} nil, {113} nil, {114} nil, {115} nil, {116} nil, {117} nil, {118} nil, {119} nil,
    {120} nil, {121} nil, {122} nil, {123} nil, {124} nil, {125} nil, {126} nil, {127} nil,
    {128} nil, {129} nil, {130} nil, {131} nil, {132} nil, {133} nil, {134} nil, {135} nil,
    {136} nil, {137} nil, {138} nil, {139} nil, {140} nil, {141} nil, {142} nil, {143} nil,
    {144} nil, {145} nil, {146} nil, {147} nil, {148} nil, {149} nil, {150} nil, {151} nil,
    {152} nil, {153} nil, {154} nil, {155} nil, {156} nil, {157} nil, {158} nil, {159} nil,
    {160} nil, {161} nil, {162} nil, {163} nil, {164} nil, {165} nil, {166} nil, {167} nil,
    {168} nil, {169} nil, {170} nil, {171} nil, {172} nil, {173} nil, {174} nil, {175} nil,
    {176} nil, {177} nil, {178} nil, {179} nil, {180} nil, {181} nil, {182} nil, {183} nil,
    {184} nil, {185} nil, {186} nil, {187} nil, {188} nil, {189} nil, {190} nil, {191} nil,
    {192} nil, {193} nil, {194} nil, {195} nil, {196} nil, {197} nil, {198} nil, {199} nil,
    {200} nil, {201} nil, {202} nil, {203} nil, {204} nil, {205} nil, {206} nil, {207} nil,
    {208} nil, {209} nil, {210} nil, {211} nil, {212} nil, {213} nil, {214} nil, {215} nil,
    {216} nil, {217} nil, {218} nil, {219} nil, {220} nil, {221} nil, {222} nil, {223} nil,
    {224} nil, {225} nil, {226} nil, {227} nil, {228} nil, {229} nil, {230} nil, {231} nil,
    {232} nil, {233} nil, {234} nil, {235} nil, {236} nil, {237} nil, {238} nil, {239} nil,
    {240} nil, {241} nil, {242} nil, {243} nil, {244} nil, {245} nil, {246} nil, {247} nil,
    {248} nil, {249} nil, {250} nil, {251} nil, {252} nil, {253} nil, {254} nil, {255} nil);
    {$ifdef FPC}public name 'RTTI_TYPE_RULES';{$endif}

{$ifdef EXTERNALLINKER}
exports RTTI_TYPE_GROUPS, RTTI_TYPE_RULES, RTTI_INIT_FUNCS, RTTI_FINAL_FUNCS, RTTI_COPY_FUNCS;
{$endif}


const

{ Dummy type information
  "TypeInfo" equivalents that can be used within the rtti context to define TRttiType and TRttiExType
  First of all, for FreePascal and old Delphi versions, where, for example, there is no TypeInfo for TClass, Pointer, procedures
  Consists of (can be created using the DummyTypeInfo function):
    DUMMY_TYPEINFO_BASE
    PointerDepth: 0..15
    RttiType: TRttiType
    Id/CodePage: Word}

  DUMMY_TYPEINFO_BASE = NativeUInt(NativeInt(Integer($f0000000)));
  DUMMY_TYPEINFO_PTR = NativeUInt(1) shl 24;

  TYPEINFO_UNKNOWN = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtUnknown) shl 16);
  TYPEINFO_POINTER = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtPointer) shl 16);
  TYPEINFO_UINT64 = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtUInt64) shl 16);
  TYPEINFO_DATE = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtDate) shl 16);
  TYPEINFO_TIME = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtTime) shl 16);
  TYPEINFO_DATETIME = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtDateTime) shl 16);
  TYPEINFO_TIMESTAMP = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtTimeStamp) shl 16);
  TYPEINFO_PUINT64 = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtUInt64) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_PDATE = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtDate) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_PTIME = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtTime) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_PDATETIME = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtDateTime) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_PTIMESTAMP = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtTimeStamp) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_ANSICHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtSBCSChar) shl 16);
  TYPEINFO_UTF8CHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtUTF8Char) shl 16);
  TYPEINFO_WIDECHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtWideChar) shl 16);
  TYPEINFO_UCS4CHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtUCS4Char) shl 16);
  TYPEINFO_PANSICHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtPSBCSChars) shl 16);
  TYPEINFO_PUTF8CHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtPUTF8Chars) shl 16);
  TYPEINFO_PWIDECHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtPWideChars) shl 16);
  TYPEINFO_PUCS4CHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtPUCS4Chars) shl 16);
  TYPEINFO_ANSISTRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtSBCSString) shl 16);
  TYPEINFO_UTF8STRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtUTF8String) shl 16);
  TYPEINFO_SHORTSTRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtShortString) shl 16 + 255);
  TYPEINFO_PANSISTRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtSBCSString) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_PUTF8STRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtUTF8String) shl 16 + DUMMY_TYPEINFO_PTR + 65001);
  TYPEINFO_PSHORTSTRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtShortString) shl 16 + DUMMY_TYPEINFO_PTR + 255);
  TYPEINFO_ENUMERATION8 = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtEnumeration8) shl 16);
  TYPEINFO_PENUMERATION8 = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtEnumeration8) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_ENUMERATION16 = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtEnumeration16) shl 16);
  TYPEINFO_PENUMERATION16 = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtEnumeration16) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_ENUMERATION32 = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtEnumeration32) shl 16);
  TYPEINFO_PENUMERATION32 = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtEnumeration32) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_ENUMERATION64 = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtEnumeration64) shl 16);
  TYPEINFO_PENUMERATION64 = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtEnumeration64) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_SET = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtSet) shl 16);
  TYPEINFO_PSET = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtSet) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_STATICARRAY = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtStaticArray) shl 16);
  TYPEINFO_PSTATICARRAY = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtStaticArray) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_DYNAMICARRAY = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtDynamicArray) shl 16);
  TYPEINFO_PDYNAMICARRAY = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtDynamicArray) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_STRUCTURE = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtStructure) shl 16);
  TYPEINFO_PSTRUCTURE = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtStructure) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_OBJECT = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtObject) shl 16);
  TYPEINFO_POBJECT = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtObject) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_INTERFACE = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtInterface) shl 16);
  TYPEINFO_PINTERFACE = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtInterface) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_CLASSREF = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtClassRef) shl 16);
  TYPEINFO_PCLASSREF = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtClassRef) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_VARREC = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtVarRec) shl 16);
  TYPEINFO_PVARREC = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtVarRec) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_FUNCTION = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtFunction) shl 16);
  TYPEINFO_PFUNCTION = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtFunction) shl 16 + DUMMY_TYPEINFO_PTR);


type

{ TRttiContainerInterface object
  Managed data containter interface }

  PRttiContainerInterface = ^TRttiContainerInterface;
  {$A1}
  {$ifdef BCB}
  TRttiContainerInterface = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TRttiContainerInterface = object protected
  {$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Vmt: Pointer;
    RefCount: Integer;
    FinalFunc: TRttiTypeFunc;
    ExType: TRttiExType;
    Value: packed record end;

    function _AddRef: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
    function _Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
  end;
  {$A4}

const
  RTTI_CONTAINER_INTERFACE_VMT: array[0..2] of Pointer = (
    @TDummyInterface.QueryInterface,
    @TRttiContainerInterface._AddRef,
    @TRttiContainerInterface._Release
  );


{ Standard ordinal types range data }

  INT8_TYPE_DATA: TRangeTypeData = (F: (OrdType: otSByte; ILow: Low(ShortInt); IHigh: High(ShortInt)));
  UINT8_TYPE_DATA: TRangeTypeData = (F: (OrdType: otUByte; ILow: Low(Byte); IHigh: High(Byte)));
  INT16_TYPE_DATA: TRangeTypeData= (F: (OrdType: otSWord; ILow: Low(SmallInt); IHigh: High(SmallInt)));
  UINT16_TYPE_DATA: TRangeTypeData = (F: (OrdType: otUWord; ILow: Low(Word); IHigh: High(Word)));
  INT32_TYPE_DATA: TRangeTypeData = (F: (OrdType: otSLong; ILow: Low(Integer); IHigh: High(Integer)));
  UINT32_TYPE_DATA: TRangeTypeData = (F: (OrdType: otULong; ILow: 0; IHigh: -1));
  INT64_TYPE_DATA: TRangeTypeData = (F: (I64Low: Low(Int64); I64High: High(Int64)));
  UINT64_TYPE_DATA: TRangeTypeData = (F: (I64Low: 0; I64High: -1));


{ Tiny.Rtti helpers }

function DummyTypeInfo(const ARttiType: TRttiType;
  const APointerDepth: Byte = 0; const AId: Word = 0): Pointer;

function RttiTypeCurrentGroup: TRttiTypeGroup;
function RttiTypeIncreaseGroup: TRttiTypeGroup;
function RttiTypeCurrent: TRttiType;
function RttiTypeIncrease(const AGroup: TRttiTypeGroup; const ARules: PRttiTypeRules): TRttiType;


{ System.TypInfo/System.Rtti helpers }

function EqualNames(const AName1, AName2: PAnsiChar; const ACount: NativeUInt): Boolean; overload;
function EqualNames(const AName1, AName2: PShortStringHelper): Boolean; overload;
function ConvertName(var ABuffer: ShortString; const AValue: string): PShortStringHelper;

function GetTypeName(const ATypeInfo: PTypeInfo): PShortStringHelper; {$ifdef INLINESUPPORT}inline;{$endif}
function GetTypeData(const ATypeInfo: PTypeInfo): PTypeData; {$ifdef INLINESUPPORT}inline;{$endif}
function GetEnumName(const ATypeInfo: PTypeInfo; const AValue: Integer): PShortStringHelper;
function GetEnumValue(const ATypeInfo: PTypeInfo; const AName: ShortString): Integer;
function IsClosureTypeData(const ATypeData: PTypeData): Boolean; {$if Defined(INLINESUPPORT) and not Defined(EXTENDEDRTTI)}inline;{$ifend}
function IsClosureType(const ATypeInfo: PTypeInfo): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
function IsManaged(const ATypeInfo: PTypeInfo): Boolean;
function HasWeakRef(const ATypeInfo: PTypeInfo): Boolean; {$if Defined(INLINESUPPORT) and not Defined(WEAKREF)}inline;{$ifend}


const
  DefaultExType: TRttiExType = (F: (Options: 0; CustomData: nil));

var
  DefaultSBCSStringOptions: Cardinal;
  DefaultContext: TRttiContext;
  RttiCalculatedRules: function(const AType: PRttiExType; var ABuffer: TRttiTypeRules): PRttiTypeRules {$ifdef FPC}public name 'RttiCalculatedRules'{$endif};

{$ifdef EXTERNALLINKER}
exports RttiCalculatedRules;
{$endif}

implementation


{ Internal constants }

const
  CP_UTF8 = 65001;
  CP_UTF16 = 1200;
  CP_UTF32 = 12000;
  SHORTSTR_RESULT: array[0..6] of Byte = (6, Ord('R'), Ord('e'), Ord('s'), Ord('u'), Ord('l'), Ord('t'));
  REFERENCED_TYPE_KINDS = [{$ifdef WEAKINSTREF}tkClass, tkMethod,{$endif} {$ifdef WEAKREF}tkInterface{$endif}];


{ Library initialization }

{$if Defined(EXTERNALLINKER)}
const
  LIB_TINY_RTTI = PLATFORM_OBJ_PATH + 'tiny.rtti.o';
{$else}
  {$if Defined(MSWINDOWS)}
    {$ifdef SMALLINT}
      {$L objs\win32\tiny.rtti.o}
    {$else}
      {$L objs\win64\tiny.rtti.o}
    {$endif}
  {$elseif Defined(ANDROID)}
    {$ifdef SMALLINT}
      {$L objs\android32\tiny.rtti.o}
    {$else}
      {$L objs\android64\tiny.rtti.o}
    {$endif}
  {$elseif Defined(IOS)}
    {$ifdef SMALLINT}
      {$L objs\ios32\tiny.rtti.o}
    {$else}
      {$L objs\ios64\tiny.rtti.o}
    {$endif}
  {$elseif Defined(MACOS)}
    {$ifdef SMALLINT}
      {$L objs\mac32\tiny.rtti.o}
    {$else}
      {$L objs\mac64\tiny.rtti.o}
    {$endif}
  {$else .LINUX}
    {$ifdef SMALLINT}
      {$L objs\linux32\tiny.rtti.o}
    {$else}
      {$L objs\linux64\tiny.rtti.o}
    {$endif}
  {$ifend}
{$ifend}

var
  LibraryInitialized: LongBool{4 bytes aligning} = False;

procedure init_library; external
  {$ifdef EXTERNALLINKER}LIB_TINY_RTTI{$endif}
  {$ifdef OBJLINKNAME}name 'init_library'{$endif};

procedure InitLibrary;
begin
  if (not LibraryInitialized) then
  try
    {$ifdef EXTERNALLINKER}
    TinyMove(__RTTI_TYPE_GROUPS, RTTI_TYPE_GROUPS, SizeOf(__RTTI_TYPE_GROUPS));
    TinyMove(__RTTI_TYPE_RULES, RTTI_TYPE_RULES, SizeOf(__RTTI_TYPE_RULES));
    {$endif}

    DefaultSBCSStringOptions := Ord(rtSBCSString) + Cardinal(DefaultCP) shl 16;
    Pointer(@RttiCalculatedRules) := @TRttiExType.GetCalculatedRules;

    init_library;
  finally
    LibraryInitialized := False;
  end;
end;


{ TRttiContainerInterface }

function TRttiContainerInterface._AddRef:
  {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
begin
  Result := RefCount;

  if (Cardinal(Result) <= 1) then
  begin
    Inc(Result);
    RefCount := Result;
  end else
  begin
    Result := AtomicIncrement(RefCount);
  end;
end;

function TRttiContainerInterface._Release:
  {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
var
  LSelf: Pointer;
  LFinalFunc: TRttiTypeFunc;
begin
  if (RefCount <> 1) then
  begin
    Result := AtomicIncrement(RefCount, -1);
    if (Result <> 0) then
    begin
      Exit;
    end;
  end else
  begin
    RefCount := 0;
  end;

  LSelf := @Self;
  try
    LFinalFunc := FinalFunc;
    if (Assigned(LFinalFunc)) then
    begin
      LFinalFunc(@ExType, @Value);
    end;
  finally
    FreeMem(LSelf);
  end;

  Result := 0;
end;


{ Tiny.Rtti helpers }

var
  InternalRttiTypeCurrentGroup: Integer{TRttiTypeGroup} = Ord(rgVariant);
  InternalRttiTypeCurrent: Integer{TRttiType} = Ord(rtValue);

function DummyTypeInfo(const ARttiType: TRttiType;
  const APointerDepth: Byte = 0; const AId: Word = 0): Pointer;
begin
  if (APointerDepth > $0f) then
  begin
    TinyError(teRangeError);
    Result := nil;
    Exit;
  end ;

  Result := Pointer(
     DUMMY_TYPEINFO_BASE +
     NativeUInt(APointerDepth) shl 24 +
     NativeUInt(ARttiType) shl 24 +
     NativeUInt(AId)
   );
end;

function RttiTypeCurrentGroup: TRttiTypeGroup;
begin
  Result := TRttiTypeGroup(InternalRttiTypeCurrentGroup);
end;

function RttiTypeIncreaseGroup: TRttiTypeGroup;
var
  LValue: Integer;
begin
  repeat
    LValue := InternalRttiTypeCurrentGroup;
    if (LValue >= Ord(High(TRttiTypeGroup))) then
    begin
      TinyError(teIntOverflow);
    end;
  until (LValue = AtomicCmpExchange(InternalRttiTypeCurrentGroup, LValue + 1, LValue));

  Result := TRttiTypeGroup(LValue + 1);
end;

function RttiTypeCurrent: TRttiType;
begin
  Result := TRttiType(InternalRttiTypeCurrent);
end;

function RttiTypeIncrease(const AGroup: TRttiTypeGroup; const ARules: PRttiTypeRules): TRttiType;
var
  LValue: Integer;
begin
  if (Byte(AGroup) > Byte(InternalRttiTypeCurrentGroup)) then
  begin
    TinyError(teInvalidCast);
  end;

  repeat
    LValue := InternalRttiTypeCurrent;
    if (LValue >= Ord(High(TRttiType))) then
    begin
      TinyError(teIntOverflow);
    end;
  until (LValue = AtomicCmpExchange(InternalRttiTypeCurrent, LValue + 1, LValue));

  Result := TRttiType(LValue + 1);
  RTTI_TYPE_GROUPS[Result] := AGroup;
  RTTI_TYPE_RULES[Result] := ARules;
end;


{ System.TypInfo/System.Rtti helpers }

{$ifdef UNICODE}
function InternalUTF8CharsCompare(const AStr1, AStr2: PAnsiChar; const ACount: NativeUInt): Boolean;
label
  failure;
{$ifdef MSWINDOWS}
var
  i, LCount1, LCount2: Integer;
  LBuffer1, LBuffer2: array[0..255] of WideChar;
{$endif}
begin
  {$ifdef MSWINDOWS}
  LCount1 := MultiByteToWideChar(CP_UTF8, 0, AStr1, ACount, nil, 0);
  LCount2 := MultiByteToWideChar(CP_UTF8, 0, AStr2, ACount, nil, 0);
  if (LCount1 = LCount2) then
  begin
    MultiByteToWideChar(CP_UTF8, 0, AStr1, ACount, @LBuffer1[0], High(LBuffer1));
    MultiByteToWideChar(CP_UTF8, 0, AStr2, ACount, @LBuffer2[0], High(LBuffer2));
    CharLowerBuffW(@LBuffer1[0], LCount1);
    CharLowerBuffW(@LBuffer2[0], LCount1);
    for i := 0 to LCount1 - 1 do
    begin
      if (LBuffer1[i] <> LBuffer2[i]) then
        goto failure;
    end;

    Result := True;
    Exit;
  end;
  {$endif}

failure:
  Result := False;
end;
{$endif}

function EqualNames(const AName1, AName2: PAnsiChar; const ACount: NativeUInt): Boolean;
label
  ret_false, ret_true;
var
  LCount: NativeUInt;
  {$ifdef UNICODE}
  LTempCount: NativeUInt;
  {$endif}
  LSource, LTarget: PAnsiChar;
  LSourceChar, LTargetChar: Cardinal;
begin
  if (AName1 <> AName2) then
  begin
    LSource := AName1 - 1;
    LTarget := AName2 - 1;
    LCount := ACount;

    repeat
      Inc(LSource);
      Inc(LTarget);
      if (LCount = 0) then goto ret_true;

      LSourceChar := PByte(LSource)^;
      LTargetChar := PByte(LTarget)^;
      Dec(LCount);
      {$ifdef UNICODE}
      if (LSourceChar or LTargetChar <= $7f) then
      {$endif}
      begin
        if (LSourceChar <> LTargetChar) then
        begin
          case (LSourceChar) of
            Ord('A')..Ord('Z'): LSourceChar := LSourceChar or $20;
          end;

          case (LTargetChar) of
            Ord('A')..Ord('Z'): LTargetChar := LTargetChar or $20;
          end;

          if (LSourceChar <> LTargetChar) then
            goto ret_false;
        end;
      end
      {$ifdef UNICODE}
      else
      if (LSourceChar xor LTargetChar > $7f) then
      begin
        goto ret_false;
      end else
      begin
        Inc(LCount);
        LTempCount := LCount;
        Dec(LSource);
        Dec(LTarget);
        repeat
          Inc(LSource);
          Inc(LTarget);
          if (LCount = 0) then goto ret_true;

          Dec(LCount);
          if (LSource^ <> LTarget^) then
            Break;
        until (False);

        Inc(LCount);
        Dec(NativeInt(LCount), NativeInt(LTempCount));
        Inc(LSource, NativeInt(LCount));
        Inc(LTarget, NativeInt(LCount));
        LCount := LTempCount;
        Result := InternalUTF8CharsCompare(LSource, LTarget, LCount);
        Exit;
      end
      {$endif}
      ;
    until (False);

  ret_false:
    Result := False;
    Exit;
  end;

ret_true:
  Result := True;
end;

function EqualNames(const AName1, AName2: PShortStringHelper): Boolean;
var
  LCount: NativeUInt;
begin
  if (AName1 <> AName2) and (Assigned(AName1)) and (Assigned(AName1)) then
  begin
    LCount := PByte(AName1)^;
    Result := (LCount = PByte(AName2)^) and
      EqualNames(Pointer(@AName1.Value[1]), Pointer(@AName2.Value[1]), LCount);
  end else
  begin
    Result := (AName1 = AName2);
  end;
end;

function ConvertName(var ABuffer: ShortString; const AValue: string): PShortStringHelper;
{$ifNdef UNICODE}
var
  LSource: PAnsiChar;
  LTarget: PAnsiChar;
  LTargetCount: Integer;
begin
  LSource := Pointer(AValue);
  LTarget := Pointer(@ABuffer[1]);
  LTargetCount := Length(AValue);

  if (LTargetCount > High(ABuffer)) then
  begin
    LTargetCount := High(ABuffer);
  end;
  TinyMove(LSource^, LTarget^, LTargetCount);

  Result := Pointer(@ABuffer);
  PByte(Result)^ := LTargetCount;
end;
{$else .UNICODE}
label
  ascii, unknown;
var
  LSource: PWideChar;
  LTarget: PAnsiChar;
  LSourceCount: Integer;
  LTargetCount: Integer;
  X, U: NativeUInt;
begin
  LSource := Pointer(AValue);
  LTarget := Pointer(@ABuffer[1]);
  LSourceCount := Length(AValue);
  LTargetCount := 0;

  repeat
    if (LSourceCount = 0) then
      Break;

    X := PWord(LSource)^;
    Dec(LSourceCount);
    Inc(LSource);
    case X of
      0..$7f:
      begin
      ascii:
        Inc(LTargetCount);
        if (LTargetCount <= High(ABuffer)) then
        begin
          PByte(LTarget)^ := X;
          Inc(LTarget);
        end else
        begin
          Dec(LTargetCount);
          Break;
        end;
      end;
      $80..$7ff:
      begin
        Inc(LTargetCount, 2);
        if (LTargetCount <= High(ABuffer)) then
        begin
          U := (X shr 6) + $80C0;
          X := (X and $3f) shl 8;
          Inc(X, U);
          PWord(LTarget)^ := X;
          Inc(LTarget, 2);
        end else
        begin
          Dec(LTargetCount, 2);
          Break;
        end;
      end;
      $800..$d7ff, $e000..$ffff:
      begin
        Inc(LTargetCount, 3);
        if (LTargetCount <= High(ABuffer)) then
        begin
          U := X;
          X := (X and $0fc0) shl 2;
          Inc(X, (U and $3f) shl 16);
          U := (U shr 12);
          Inc(X, $8080E0);
          Inc(X, U);

          PWord(LTarget)^ := X;
          X := X shr 16;
          PByte(LTarget + 2)^ := X;
          Inc(LTarget, 3);
        end else
        begin
          Dec(LTargetCount, 3);
          Break;
        end;
      end;
    else
      if (LSourceCount <> 0) then
      begin
        U := X;
        X := PWord(LSource)^;
        Dec(LSourceCount);
        Inc(LSource);
        Dec(U, $d800);
        Dec(X, $dc00);
        if (X >= ($e000-$dc00)) then goto unknown;

        Inc(LTargetCount, 4);
        if (LTargetCount <= High(ABuffer)) then
        begin
          U := U shl 10;
          Inc(X, $10000);
          Inc(X, U);

          U := (X and $3f) shl 24;
          U := U + ((X and $0fc0) shl 10);
          U := U + (X shr 18);
          X := (X shr 4) and $3f00;
          Inc(U, Integer($808080F0));
          Inc(X, U);

          PCardinal(LTarget)^ := X;
          Inc(LTarget, 4);
        end else
        begin
          Dec(LTargetCount, 4);
          Break;
        end;
      end else
      begin
      unknown:
        X := Ord('?');
        goto ascii;
      end;
    end;
  until (False);

  Result := Pointer(@ABuffer);
  PByte(Result)^ := LTargetCount;
end;
{$endif}

function GetTypeName(const ATypeInfo: PTypeInfo): PShortStringHelper;
begin
  Result := @ATypeInfo.Name;
end;

function GetTypeData(const ATypeInfo: PTypeInfo): PTypeData;
var
  LCount: NativeUInt;
begin
  LCount := NativeUInt(ATypeInfo.Name.Value[0]);
  Result := Pointer(@ATypeInfo.Name.Value[LCount + 1]);
end;

function GetEnumName(const ATypeInfo: PTypeInfo; const AValue: Integer): PShortStringHelper;
begin
  if (Assigned(ATypeInfo)) and (ATypeInfo.Kind = tkEnumeration) then
  begin
    Result := ATypeInfo.TypeData.EnumerationData.EnumNames[AValue];
  end else
  begin
    Result := nil;
  end;
end;

function GetEnumValue(const ATypeInfo: PTypeInfo; const AName: ShortString): Integer;
begin
  if (Assigned(ATypeInfo)) and (ATypeInfo.Kind = tkEnumeration) then
  begin
    Result := ATypeInfo.TypeData.EnumerationData.EnumValues[AName];
  end else
  begin
    Result := INVALID_INDEX;
  end;
end;

function IsClosureTypeData(const ATypeData: PTypeData): Boolean;
{$ifdef EXTENDEDRTTI}
var
  LMethodTable: PIntfMethodTable;
  LName: PByte;
begin
  Result := False;
  if (not (ATypeData.IntfParent.Assigned)) or (ATypeData.IntfParent.Value <> TypeInfo(IInterface)) then
    Exit;

  LMethodTable := ATypeData.InterfaceData.MethodTable;
  if (not Assigned(LMethodTable)) or (LMethodTable.Count <> 1) then
    Exit;

  LName := Pointer(@LMethodTable.Entries.Name);
  case LMethodTable.RttiCount of
    $ffff: Result := (LName^ = 2){no RTTI reference};
    1:
    begin
      if (LName^ <> 6) then Exit;
      Inc(LName);
      if (LName^ <> Ord('I')) then Exit;
      Inc(LName);
      if (LName^ <> Ord('n')) then Exit;
      Inc(LName);
      if (LName^ <> Ord('v')) then Exit;
      Inc(LName);
      if (LName^ <> Ord('o')) then Exit;
      Inc(LName);
      if (LName^ <> Ord('k')) then Exit;
      Inc(LName);
      if (LName^ <> Ord('e')) then Exit;
      Result := True;
    end;
  end;
end;
{$else}
begin
  Result := False;
end;
{$endif}

function IsClosureType(const ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (Assigned(ATypeInfo)) and (ATypeInfo.Kind = tkInterface) and
    (IsClosureTypeData(ATypeInfo.TypeData));
end;

function IsManaged(const ATypeInfo: PTypeInfo): Boolean;
var
  LTypeData: PTypeData;
begin
  Result := False;

  if Assigned(ATypeInfo) then
  case ATypeInfo.Kind of
    tkVariant,
    {$ifdef AUTOREFCOUNT}
    tkClass,
    {$endif}
    {$ifdef WEAKINSTREF}
    tkMethod,
    {$endif}
    {$ifdef FPC}
    tkAString,
    {$endif}
    {$ifdef MANAGEDRECORDS}
    tkMRecord,
    {$endif}
    tkWString, tkLString, {$ifdef UNICODE}tkUString,{$endif} tkInterface, tkDynArray:
    begin
      Result := True;
      Exit;
    end;
    tkArray{static array}:
    begin
      LTypeData := PTypeData(NativeUInt(ATypeInfo) + PByte(@ATypeInfo.Name)^);
      if (LTypeData.ArrayData.ElType.Assigned) then
        Result := IsManaged(LTypeData.ArrayData.ElType.Value);
    end;
    tkRecord{$ifdef FPC}, tkObject{$endif}:
    begin
      LTypeData := PTypeData(NativeUInt(ATypeInfo) + PByte(@ATypeInfo.Name)^);
      Result := (LTypeData.ManagedFldCount <> 0);
    end;
  end;
end;

function HasWeakRef(const ATypeInfo: PTypeInfo): Boolean;
{$ifdef WEAKREF}
var
  i: Integer;
  LTypeData: PTypeData;
  LField: PManagedField;
begin
  Result := False;

  if Assigned(ATypeInfo) then
  case ATypeInfo.Kind of
    {$ifdef WEAKINSTREF}
    tkMethod:
    begin
      Result := True;
    end;
    {$endif}
    tkArray{static array}:
    begin
      LTypeData := PTypeData(NativeUInt(ATypeInfo) + PByte(@ATypeInfo.Name)^);
      if (LTypeData.ArrayData.ElType.Assigned) then
        Result := HasWeakRef(LTypeData.ArrayData.ElType.Value);
    end;
    tkRecord{$ifdef FPC}, tkObject{$endif}{$ifdef MANAGEDRECORDS}, tkMRecord{$endif}:
    begin
      LTypeData := PTypeData(NativeUInt(ATypeInfo) + PByte(@ATypeInfo.Name)^);
      LField := @LTypeData.ManagedFields;
      for i := 0 to LTypeData.ManagedFldCount - 1 do
      begin
        if (not LField.TypeRef.Assigned) or (HasWeakRef(LField.TypeRef.Value)) then
        begin
          Result := True;
          Exit;
        end;

        Inc(LField);
      end;
    end;
  end;
end;
{$else}
begin
  Result := False;
end;
{$endif}

{$ifdef WEAKREF}
function RecordHasWeakRef(const ATypeData: PTypeData): Boolean;
var
  i: Integer;
  LField: PManagedField;
begin
  LField := @ATypeData.ManagedFields;
  for i := 0 to ATypeData.ManagedFldCount - 1 do
  begin
    if (not LField.TypeRef.Assigned) or (HasWeakRef(LField.TypeRef.Value)) then
    begin
      Result := True;
      Exit;
    end;

    Inc(LField);
  end;

  Result := False;
end;
{$endif}


{ TCharacters }

class function TCharacters.LStrLen(const S: PAnsiChar): NativeUInt;
var
  LPtr: PByte;
begin
  LPtr := Pointer(S);

  if (Assigned(LPtr)) and (LPtr^ <> 0) then
  repeat
    Inc(LPtr);
  until (LPtr^ = 0);

  Result := (NativeUInt(LPtr) - NativeUInt(S));
end;

class function TCharacters.WStrLen(const S: PWideChar): NativeUInt;
var
  LPtr: PWord;
begin
  LPtr := Pointer(S);

  if (Assigned(LPtr)) and (LPtr^ <> 0) then
  repeat
    Inc(LPtr);
  until (LPtr^ = 0);

  Result := (NativeUInt(LPtr) - NativeUInt(S)) shr 1;
end;

class function TCharacters.UStrLen(const S: PUCS4Char): NativeUInt;
var
  LPtr: PCardinal;
begin
  LPtr := Pointer(S);

  if (Assigned(LPtr)) and (LPtr^ <> 0) then
  repeat
    Inc(LPtr);
  until (LPtr^ = 0);

  Result := (NativeUInt(LPtr) - NativeUInt(S)) shr 2;
end;

class function TCharacters.UCS4StringLen(const S: UCS4String): NativeUInt;
begin
  if (Pointer(S) <> nil) then
  begin
    Result := NativeUInt(PUCS4StrRec(NativeInt(Pointer(S)) - SizeOf(TUCS4StrRec)).High);
    if (NativeInt(Result) >= 0) then
    begin
      Inc(Result, Byte(S[Result] <> 0));
      Exit;
    end;
  end;

  Result := 0;
end;

class function TCharacters.PSBCSChars(const S: AnsiString): PAnsiChar;
begin
  Result := Pointer(S);
  if (not Assigned(Result)) then
  begin
    Result := Pointer(@RTTI_RULES_NONE);
  end;
end;

class function TCharacters.PUTF8Chars(const S: UTF8String): PUTF8Char;
begin
  Result := Pointer(S);
  if (not Assigned(Result)) then
  begin
    Result := Pointer(@RTTI_RULES_NONE);
  end;
end;

class function TCharacters.PWideChars(const S: UnicodeString): PWideChar;
begin
  Result := Pointer(S);
  if (not Assigned(Result)) then
  begin
    Result := Pointer(@RTTI_RULES_NONE);
  end;
end;

class function TCharacters.PUCS4Chars(const S: UCS4String): PUCS4Char;
begin
  Result := Pointer(S);
  if (not Assigned(Result)) then
  begin
    Result := Pointer(@RTTI_RULES_NONE);
  end;
end;

{$ifNdef MSWINDOWS}
class function TCharacters.MultiByteToWideChar(CodePage, Flags: Cardinal; LocaleStr: PAnsiChar;
  LocaleStrLen: Integer; UnicodeStr: PWideChar; UnicodeStrLen: Integer): Integer;
begin
  Result := UnicodeFromLocaleChars(CodePage, Flags, Pointer(LocaleStr),
    LocaleStrLen, UnicodeStr, UnicodeStrLen);
end;

class function TCharacters.WideCharToMultiByte(CodePage, Flags: Cardinal;
  UnicodeStr: PWideChar; UnicodeStrLen: Integer; LocaleStr: PAnsiChar;
  LocaleStrLen: Integer; DefaultChar: PAnsiChar; UsedDefaultChar: Pointer): Integer;
begin
  Result := LocaleCharsFromUnicode(CodePage, Flags, UnicodeStr, UnicodeStrLen,
    Pointer(LocaleStr), LocaleStrLen, Pointer(DefaultChar), UsedDefaultChar);
end;
{$endif}

class function TCharacters.UCS4CharFromUnicode(
  const ASource: PWideChar; const ASourceCount: NativeUInt): UCS4Char;
var
  LValue: Cardinal;
begin
  Result := 0;

  if (ASourceCount <> 0) then
  begin
    Result := PWord(ASource)^;

    if (Result >= $d800) and (Result < $dc00) then
    begin
      if (ASourceCount > 1) then
      begin
        LValue := PWord(ASource + 1)^;

        if (LValue >= $dc00) and (LValue < $e000) then
        begin
          Result := $10000 + ((Result - $d800) shl 10) + (LValue - $dc00);
          Exit;
        end;
      end;

      Result := Ord('?');
    end;
  end;
end;

class function TCharacters.UCS4CharFromAnsi(const ASourceCP: Word;
  const ASource: PAnsiChar; const ASourceCount: NativeUInt): UCS4Char;
begin
  Result := 0;

  if (ASourceCount <> 0) then
  begin
    if (PByte(ASource)^ <= $7f) then
    begin
      Result := PByte(ASource)^;
    end else
    begin
      MultiByteToWideChar(ASourceCP, 0, ASource, 1, Pointer(@Result), 1);
    end;
  end;
end;

class function TCharacters.UCS4FromUnicode(const ATarget: PUCS4Char;
  const ASource: PWideChar; const ASourceCount: NativeUInt): NativeUInt;
var
  LPtr: PCardinal;
  LSource, LTopSource: PWord;
  X, Y: NativeUInt;
begin
  LPtr := Pointer(ATarget);

  if (ASourceCount <> 0) then
  begin
    LSource := Pointer(ASource);
    LTopSource := Pointer(ASource);
    Inc(LTopSource, ASourceCount);

    if (Assigned(ATarget)) then
    begin
      repeat
        X := LSource^;
        Inc(LSource);

        if (X >= $d800) and (X < $dc00) then
        begin
          if (LSource <> LTopSource) then
          begin
            Y := LSource^;
            if (Y >= $dc00) and (Y < $e000) then
            begin
              Inc(LSource);
              X := $10000 + ((X - $d800) shl 10) + (Y - $dc00);
            end else
            begin
              X := Ord('?');
            end;
          end else
          begin
            X := Ord('?');
          end;
        end;

        LPtr^ := X;
        Inc(LPtr);
      until (LSource = LTopSource);
    end else
    begin
      repeat
        X := LSource^;
        Inc(LSource);

        if (X >= $d800) and (X < $dc00) then
        begin
          if (LSource <> LTopSource) then
          begin
            Y := LSource^;
            if (Y >= $dc00) and (Y < $e000) then
            begin
              Inc(LSource);
            end;
          end;
        end;

        Inc(LPtr);
      until (LSource = LTopSource);
    end;
  end;

  Result := (NativeUInt(LPtr) - NativeUInt(ATarget)) shr 2;
end;

class procedure TCharacters.UCS4FromUnicode(var ATarget: UCS4String;
  const ASource: PWideChar; const ASourceCount: NativeUInt);
var
  LCount: NativeUInt;
begin
  if (ASourceCount = 0) then
  begin
    ATarget := nil;
  end else
  begin
    LCount := UCS4FromUnicode(nil, ASource, ASourceCount);
    SetLength(ATarget, LCount + 1);
    ATarget[LCount] := 0;
    UCS4FromUnicode(Pointer(ATarget), ASource, ASourceCount);
  end;
end;

class procedure TCharacters.UCS4FromAnsi(var ATarget: UCS4String; const ASourceCP: Word;
  const ASource: PAnsiChar; const ASourceCount: NativeUInt);
var
  LCount, LUnicodeCount: Integer;
  LBuffer: array of WideChar;
  LUnicodeBuffer: array[0..255] of WideChar;
  LUnicodeChars: PWideChar;
begin
  if (ASourceCount = 0) then
  begin
    ATarget := nil;
  end else
  begin
    LUnicodeCount := MultiByteToWideChar(ASourceCP, 0, ASource, ASourceCount, nil, 0);
    if (LUnicodeCount <= SizeOf(LUnicodeBuffer) div SizeOf(WideChar)) then
    begin
      LUnicodeChars := @LUnicodeBuffer[0];
    end else
    begin
      SetLength(LBuffer, LUnicodeCount);
      LUnicodeChars := Pointer(LBuffer);
    end;
    MultiByteToWideChar(ASourceCP, 0, ASource, ASourceCount, LUnicodeChars, LUnicodeCount);

    LCount := UCS4FromUnicode(nil, LUnicodeChars, LUnicodeCount);
    SetLength(ATarget, LCount + 1);
    ATarget[LCount] := 0;
    UCS4FromUnicode(Pointer(ATarget), LUnicodeChars, LUnicodeCount);
  end;
end;

class function TCharacters.UnicodeFromUCS4(const ATarget: PWideChar;
  const ASource: PUCS4Char; const ASourceCount: NativeUInt): NativeUInt;
var
  LPtr: PWord;
  LSource, LTopSource: PCardinal;
  X: NativeUInt;
begin
  LPtr := Pointer(ATarget);

  if (ASourceCount <> 0) then
  begin
    LSource := Pointer(ASource);
    LTopSource := Pointer(ASource);
    Inc(LTopSource, ASourceCount);

    if (Assigned(ATarget)) then
    begin
      repeat
        X := LSource^;
        Inc(LSource);

        if (X >= $10000) then
        begin
          LPtr^ := (((X - $00010000) shr 10) and $000003ff) or $d800;
          Inc(LPtr);
          LPtr^ := ((X - $00010000) and $000003ff) or $dc00;
        end else
        begin
          LPtr^ := X;
        end;
        Inc(LPtr);
      until (LSource = LTopSource);
    end else
    begin
      repeat
        X := LSource^;
        Inc(LSource);

        if (X >= $10000) then
        begin
          Inc(LPtr, 2);
        end else
        begin
          Inc(LPtr);
        end;
      until (LSource = LTopSource);
    end;
  end;

  Result := (NativeUInt(LPtr) - NativeUInt(ATarget)) shr 1;
end;

class procedure TCharacters.UnicodeFromUCS4(var ATarget: WideString;
  const ASource: PUCS4Char; const ASourceCount: NativeUInt);
var
  LCount: NativeUInt;
begin
  if (ASourceCount = 0) then
  begin
    ATarget := '';
  end else
  begin
    LCount := UnicodeFromUCS4(nil, ASource, ASourceCount);
    SetLength(ATarget, LCount);
    UnicodeFromUCS4(Pointer(ATarget), ASource, ASourceCount);
  end;
end;

{$ifdef UNICODE}
class procedure TCharacters.UnicodeFromUCS4(var ATarget: UnicodeString;
  const ASource: PUCS4Char; const ASourceCount: NativeUInt);
var
  LCount: NativeUInt;
begin
  if (ASourceCount = 0) then
  begin
    ATarget := '';
  end else
  begin
    LCount := UnicodeFromUCS4(nil, ASource, ASourceCount);
    SetLength(ATarget, LCount);
    UnicodeFromUCS4(Pointer(ATarget), ASource, ASourceCount);
  end;
end;
{$endif}

class procedure TCharacters.UnicodeFromAnsi(var ATarget: WideString;
  const ASourceCP: Word; const ASource: PAnsiChar; const ASourceCount: NativeUInt);
var
  LCount: NativeUInt;
begin
  if (ASourceCount = 0) then
  begin
    ATarget := '';
  end else
  begin
    LCount := MultiByteToWideChar(ASourceCP, 0, ASource, ASourceCount, nil, 0);
    SetLength(ATarget, LCount);
    MultiByteToWideChar(ASourceCP, 0, ASource, ASourceCount, Pointer(ATarget), LCount);
  end;
end;

{$ifdef UNICODE}
class procedure TCharacters.UnicodeFromAnsi(var ATarget: UnicodeString;
  const ASourceCP: Word; const ASource: PAnsiChar; const ASourceCount: NativeUInt);
var
  LCount: NativeUInt;
begin
  if (ASourceCount = 0) then
  begin
    ATarget := '';
  end else
  begin
    LCount := MultiByteToWideChar(ASourceCP, 0, ASource, ASourceCount, nil, 0);
    SetLength(ATarget, LCount);
    MultiByteToWideChar(ASourceCP, 0, ASource, ASourceCount, Pointer(ATarget), LCount);
  end;
end;
{$endif}

class procedure TCharacters.AnsiFromUnicode(const ATargetCP: Word; var ATarget: AnsiString;
  const ASource: PWideChar; const ASourceCount: NativeUInt);
var
  LCount: NativeUInt;
begin
  if (ASourceCount = 0) then
  begin
    ATarget := {$ifdef ANSISTRSUPPORT}''{$else}nil{$endif};
  end else
  begin
    LCount := WideCharToMultiByte(ATargetCP, 0, ASource, ASourceCount, nil, 0, nil, nil);
    SetLength(ATarget, LCount);
    {$ifdef INTERNALCODEPAGE}
    PAnsiStrRec(NativeInt(Pointer(ATarget)) - SizeOf(TAnsiStrRec)).CodePage := ATargetCP;
    {$endif}
    WideCharToMultiByte(ATargetCP, 0, ASource, ASourceCount,
      Pointer(ATarget), LCount, nil, nil);
  end;
end;

class procedure TCharacters.AnsiFromAnsi(const ATargetCP: Word; var ATarget: AnsiString;
  const ASourceCP: Word; const ASource: PAnsiChar; const ASourceCount: NativeUInt);
var
  LCount: Integer;
  LBuffer: array of WideChar;
  LUnicodeBuffer: array[0..255] of WideChar;
  LUnicodeChars: PWideChar;
begin
  if (ASourceCount = 0) then
  begin
    ATarget := {$ifdef ANSISTRSUPPORT}''{$else}nil{$endif};
  end else
  if (ATargetCP = ASourceCP) then
  begin
    SetLength(ATarget, ASourceCount);
    {$ifdef INTERNALCODEPAGE}
    PAnsiStrRec(NativeInt(Pointer(ATarget)) - SizeOf(TAnsiStrRec)).CodePage := ATargetCP;
    {$endif}
    TinyMove(ASource^, Pointer(ATarget)^, ASourceCount);
  end else
  begin
    LCount := MultiByteToWideChar(ASourceCP, 0, ASource, ASourceCount, nil, 0);
    if (LCount <= SizeOf(LUnicodeBuffer) div SizeOf(WideChar)) then
    begin
      LUnicodeChars := @LUnicodeBuffer[0];
    end else
    begin
      SetLength(LBuffer, LCount);
      LUnicodeChars := Pointer(LBuffer);
    end;
    MultiByteToWideChar(ASourceCP, 0, ASource, ASourceCount, LUnicodeChars, LCount);

    AnsiFromUnicode(ATargetCP, ATarget, LUnicodeChars, LCount);
  end;
end;

class procedure TCharacters.AnsiFromUCS4(const ATargetCP: Word; var ATarget: AnsiString;
  const ASource: PUCS4Char; const ASourceCount: NativeUInt);
var
  LCount: Integer;
  LBuffer: array of WideChar;
  LUnicodeBuffer: array[0..255] of WideChar;
  LUnicodeChars: PWideChar;
begin
  if (ASourceCount = 0) then
  begin
    ATarget := {$ifdef ANSISTRSUPPORT}''{$else}nil{$endif};
  end else
  begin
    LCount := UnicodeFromUCS4(nil, ASource, ASourceCount);
    if (LCount <= SizeOf(LUnicodeBuffer) div SizeOf(WideChar)) then
    begin
      LUnicodeChars := @LUnicodeBuffer[0];
    end else
    begin
      SetLength(LBuffer, LCount);
      LUnicodeChars := Pointer(LBuffer);
    end;
    UnicodeFromUCS4(LUnicodeChars, ASource, ASourceCount);

    AnsiFromUnicode(ATargetCP, ATarget, LUnicodeChars, LCount);
  end;
end;

class procedure TCharacters.ShortStringFromUnicode(var ATarget: ShortString; const AMaxLength: Byte;
  const ASource: PWideChar; const ASourceCount: NativeUInt);
var
  LCount: NativeUInt;
begin
  if (ASourceCount = 0) then
  begin
    PByte(@ATarget)^ := 0;
  end else
  begin
    LCount := WideCharToMultiByte(CP_UTF8, 0, ASource, ASourceCount,
      Pointer(@ATarget[1]), AMaxLength, nil, nil);
    PByte(@ATarget)^ := LCount;
  end;
end;

class procedure TCharacters.ShortStringFromAnsi(var ATarget: ShortString; const AMaxLength: Byte;
  const ASourceCP: Word; const ASource: PAnsiChar; const ASourceCount: NativeUInt);
var
  LCount: NativeUInt;
  LUnicodeBuffer: array[0..255] of WideChar;
begin
  if (ASourceCount = 0) then
  begin
    PByte(@ATarget)^ := 0;
    Exit;
  end else
  if (ASourceCP <> CP_UTF8) then
  begin
    LCount := MultiByteToWideChar(ASourceCP, 0, ASource, ASourceCount,
      @LUnicodeBuffer[0], SizeOf(LUnicodeBuffer) div SizeOf(WideChar));

    LCount := WideCharToMultiByte(CP_UTF8, 0, @LUnicodeBuffer[0], LCount,
      Pointer(@ATarget[1]), AMaxLength, nil, nil);
    PByte(@ATarget)^ := LCount;
    Exit;
  end else
  begin
    LCount := ASourceCount;
  end;

  if (LCount > AMaxLength) then
  begin
    LCount := AMaxLength;
  end;
  PByte(@ATarget)^ := LCount;
  TinyMove(ASource^, PByte(@ATarget[1])^, LCount);
end;

class procedure TCharacters.ShortStringFromUCS4(var ATarget: ShortString; const AMaxLength: Byte;
  const ASource: PUCS4Char; const ASourceCount: NativeUInt);
var
  LCount: Integer;
  LBuffer: array of WideChar;
  LUnicodeBuffer: array[0..255] of WideChar;
  LUnicodeChars: PWideChar;
begin
  if (ASourceCount = 0) then
  begin
    PByte(@ATarget)^ := 0;
  end else
  begin
    LCount := UnicodeFromUCS4(nil, ASource, ASourceCount);
    if (LCount <= SizeOf(LUnicodeBuffer) div SizeOf(WideChar)) then
    begin
      LUnicodeChars := @LUnicodeBuffer[0];
    end else
    begin
      SetLength(LBuffer, LCount);
      LUnicodeChars := Pointer(LBuffer);
    end;
    UnicodeFromUCS4(LUnicodeChars, ASource, ASourceCount);

    ShortStringFromUnicode(ATarget, AMaxLength, LUnicodeChars, LCount);
  end;
end;


{ ShortStringHelper }

function ShortStringHelper.GetValue: Integer;
begin
  Result := Byte(Pointer(@Value)^);
end;

procedure ShortStringHelper.SetValue(const AValue: Integer);
begin
  Byte(Pointer(@Value)^) := AValue;
end;

procedure ShortStringHelper.InternalGetAnsiString(var Result: AnsiString);
var
  LCount: Integer;
  LUnicodeBuffer: array[0..255] of WideChar;
begin
  LCount := Byte(Pointer(@Value)^);

  if (LCount = 0) then
  begin
    Result := {$ifdef ANSISTRSUPPORT}''{$else}nil{$endif};
  end else
  begin
    LCount := {$ifNdef MSWINDOWS}TCharacters.{$endif}MultiByteToWideChar(CP_UTF8, 0, Pointer(@Value[1]),
      LCount, @LUnicodeBuffer[0], SizeOf(LUnicodeBuffer) div SizeOf(WideChar));
    TCharacters.AnsiFromUnicode(DefaultCP, Result, @LUnicodeBuffer[0], LCount);
  end;
end;

procedure ShortStringHelper.InternalGetUTF8String(var Result: UTF8String);
var
  LCount: Integer;
begin
  LCount := Byte(Pointer(@Value)^);
  SetLength(Result, LCount);
  TinyMove(Value[1], Pointer(Result)^, LCount);
end;

procedure ShortStringHelper.InternalGetUnicodeString(var Result: UnicodeString);
var
  LCount: Integer;
begin
  if (Byte(Pointer(@Value)^) = 0) then
  begin
    Result := '';
  end else
  begin
    LCount := {$ifNdef MSWINDOWS}TCharacters.{$endif}MultiByteToWideChar(CP_UTF8, 0, Pointer(@Value[1]), Byte(Pointer(@Value)^), nil, 0);
    SetLength(Result, LCount);
    {$ifNdef MSWINDOWS}TCharacters.{$endif}MultiByteToWideChar(CP_UTF8, 0, Pointer(@Value[1]), Byte(Pointer(@Value)^), Pointer(Result), LCount);
  end;
end;

function ShortStringHelper.GetAnsiString: AnsiString;
{$ifdef CPUINTELASM} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp InternalGetAnsiString
end;
{$else}
begin
  InternalGetAnsiString(Result);
end;
{$endif}

function ShortStringHelper.GetUTF8String: UTF8String;
{$ifdef CPUINTELASM} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp InternalGetUTF8String
end;
{$else}
begin
  InternalGetUTF8String(Result);
end;
{$endif}

function ShortStringHelper.GetUnicodeString: UnicodeString;
{$ifdef CPUINTELASM} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp InternalGetUnicodeString
end;
{$else}
begin
  InternalGetUnicodeString(Result);
end;
{$endif}

function ShortStringHelper.GetTail: Pointer;
var
  LCount: NativeUInt;
begin
  LCount := NativeUInt(Value[0]);
  Result := Pointer(@Value[LCount + 1]);
end;


{$ifdef EXTENDEDRTTI}
{ TAttrEntryReader }

function TAttrEntryReader.RangeError: Pointer;
begin
  TinyError(teRangeError);
  Result := nil;
end;

function TAttrEntryReader.GetEOF: Boolean;
begin
  Result := (Current = Overflow);
end;

function TAttrEntryReader.GetMargin: NativeUInt;
begin
  Result := NativeUInt(Overflow) - NativeUInt(Current);
end;

procedure TAttrEntryReader.ReadData(var ABuffer; const ASize: NativeUInt);
var
  LCurrent: PByte;
begin
  LCurrent := Current;
  Inc(LCurrent, ASize);
  if (NativeUInt(LCurrent) > NativeUInt(Overflow)) then
  begin
    RangeError;
    Exit;
  end;

  Current := LCurrent;
  Dec(LCurrent, ASize);
  TinyMove(LCurrent^, ABuffer, ASize);
end;

function TAttrEntryReader.Reserve(const ASize: NativeUInt): Pointer;
var
  LCurrent: PByte;
begin
  LCurrent := Current;
  Inc(LCurrent, ASize);
  if (NativeUInt(LCurrent) > NativeUInt(Overflow)) then
  begin
    Result := RangeError;
    Exit;
  end;

  Current := LCurrent;
  Dec(LCurrent, ASize);
  Result := LCurrent;
end;

function TAttrEntryReader.ReadBoolean: Boolean;
begin
  Result := Boolean(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadAnsiChar: AnsiChar;
begin
  Result := AnsiChar(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadWideChar: WideChar;
begin
  Result := WideChar(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadUCS4Char: UCS4Char;
begin
  Result := UCS4Char(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadShortInt: ShortInt;
begin
  Result := ShortInt(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadByte: Byte;
begin
  Result := Byte(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadSmallInt: SmallInt;
begin
  Result := SmallInt(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadWord: Word;
begin
  Result := Word(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadInteger: Integer;
begin
  Result := Integer(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadCardinal: Cardinal;
begin
  Result := Cardinal(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadInt64: Int64;
begin
  Result := Int64(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadUInt64: UInt64;
begin
  Result := UInt64(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadSingle: Single;
begin
  Result := Single(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadDouble: Double;
begin
  Result := Double(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadExtended: Extended;
begin
  Result := Extended(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadComp: Comp;
begin
  Result := Comp(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadCurrency: Currency;
begin
  Result := Currency(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadDateTime: TDateTime;
begin
  Result := TDateTime(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadPointer: Pointer;
begin
  Result := Pointer(Reserve(SizeOf(Result))^);
end;

function TAttrEntryReader.ReadTypeInfo: Pointer{PTypeInfo};
begin
  Result := Pointer{PPTypeInfo}(Reserve(SizeOf(Result))^);
  if (Assigned(Result)) then
  begin
    Result := PPointer(Result)^;
  end;
end;

function TAttrEntryReader.ReadClass: TClass;
var
  LTypeInfo: PTypeInfo;
begin
  LTypeInfo := ReadTypeInfo;
  if (Assigned(LTypeInfo)) then
  begin
    if (LTypeInfo.Kind = tkClass) then
    begin
      Result := LTypeInfo.TypeData.ClassType;
      Exit;
    end else
    begin
      TinyError(teInvalidCast);
    end;
  end;

  Result := nil;
end;

function TAttrEntryReader.ReadShortString: ShortString;
var
  LCount: NativeUInt;
  LPtr: PByte;
begin
  LCount := ReadWord;
  if (LCount = 0) then
  begin
    PByte(@Result)^ := 0;
    Exit;
  end;

  LPtr := Reserve(LCount);
  if (LCount > 255) then
  begin
    LCount := 255;
  end;

  PByte(@Result)^ := LCount;
  TinyMove(LPtr^, Result[1], LCount);
end;

function TAttrEntryReader.ReadUTF8String: UTF8String;
var
  LCount: NativeUInt;
  LPtr: PByte;
begin
  LCount := ReadWord;
  if (LCount = 0) then
  begin
    Result := {$ifdef ANSISTRSUPPORT}''{$else}nil{$endif};
    Exit;
  end;

  LPtr := Reserve(LCount);
  SetLength(Result, LCount);
  TinyMove(LPtr^, Pointer(Result)^, LCount);
end;

function TAttrEntryReader.ReadString: string;
var
  LCount, LTargetCount: NativeUInt;
  LPtr: PByte;
begin
  LCount := ReadWord;
  LPtr := Reserve(LCount);
  if (LCount = 0) then
  begin
    Result := '';
    Exit;
  end;

  LTargetCount := {$ifNdef MSWINDOWS}TCharacters.{$endif}MultiByteToWideChar(CP_UTF8, 0, Pointer(LPtr), LCount, nil, 0);
  SetLength(Result, LTargetCount);
  {$ifNdef MSWINDOWS}TCharacters.{$endif}MultiByteToWideChar(CP_UTF8, 0, Pointer(LPtr), LCount, Pointer(Result), LTargetCount);
end;


{ TAttrEntry }

function TAttrEntry.GetClassType: TClass;
var
  LTypeInfo: PTypeInfo;
begin
  LTypeInfo := PTypeInfoRef(AttrType).Value;
  if (Assigned(LTypeInfo)) then
  begin
    Result := LTypeInfo.TypeData.ClassType;
    Exit;
  end;

  Result := nil;
end;

function TAttrEntry.GetConstructorSignature: PVmtMethodSignature;
var
  i: Integer;
  LTypeInfo: PTypeInfo;
  LAddress, LImplAddress: Pointer;
  {$ifdef MSWINDOWS}
  LPtr: PByte;
  {$endif}
  LTypeData: PTypeData;
  LMethodTable: PVmtMethodTableEx;
  LEntry: PVmtMethodEntry;
  LEntryAddress: Pointer;
begin
  LTypeInfo := PTypeInfoRef(AttrType).Value;
  LAddress := ConstructorAddress;
  Result := nil;
  if (not Assigned(LTypeInfo)) or (not Assigned(LAddress)) then
    Exit;

  LImplAddress := nil;
  {$ifdef MSWINDOWS}
  LPtr := LAddress;
  if (LPtr^ = $FF) then
  begin
    Inc(LPtr);
    if (LPtr^ = $25) then
    begin
      Inc(LPtr);
      {$ifdef CPUX86}
        LImplAddress := PPointer((NativeInt(LPtr) + 4) + PInteger(LPtr)^)^;
      {$else .CPUX64}
        LImplAddress := PPointer(PPointer(LPtr)^)^;
      {$endif}
    end;
  end;
  {$endif}

  repeat
    LTypeData := LTypeInfo.TypeData;
    LMethodTable := LTypeData.ClassData.MethodTableEx;

    if (Assigned(LMethodTable)) then
    begin
      for i := 0 to Integer(LMethodTable.Count) - 1 do
      begin
        LEntry := LMethodTable.Entries[i].Entry;

        if (Assigned(LEntry)) then
        begin
          LEntryAddress := LEntry.CodeAddress;
          if (Assigned(LEntryAddress)) then
          begin
            if (LEntryAddress = LAddress) or (LEntryAddress = LImplAddress) then
            begin
              Result := LEntry.Signature;
              Exit;
            end;
          end;
        end;
      end;
    end;

    LTypeInfo := LTypeData.ClassData.ParentInfo.Value;
  until (not Assigned(LTypeInfo));

  Result := nil;
end;

function TAttrEntry.GetReader: TAttrEntryReader;
begin
  Result.Current := Pointer(@ArgData);
  Result.Overflow := Pointer(@ArgData[ArgLen + Low(ArgData)]);
end;

function TAttrEntry.GetTail: Pointer;
begin
  Result := @ArgData[ArgLen + Low(ArgData)];
end;


{ TAttrData }

function TAttrData.GetValue: PAttrData;
begin
  Result := @Self;
  if (Result.Len = SizeOf(Word)) then
  begin
    Result := nil;
  end;
end;

function TAttrData.GetTail: Pointer;
begin
  Result := Pointer(PAnsiChar(@Len) + Len);
end;

function TAttrData.GetCount: Integer;
var
  LEntry, LTail: PAttrEntry;
begin
  LEntry := @Entries;
  LTail := Tail;

  Result := 0;
  repeat
    if (LEntry = LTail) then
      Break;

    Inc(Result);
    LEntry := LEntry.Tail;
    if (NativeUInt(LEntry) > NativeUInt(LTail)) then
    begin
      TinyError(teInvalidPtr);
      Exit;
    end;
  until (False);
end;

function TAttrData.GetReference: TReference;
{$ifdef WEAKREF}
var
  LEntry, LTail: PAttrEntry;
  LClassType: TClass;
begin
  LEntry := @Entries;
  LTail := Tail;

  Result := rfDefault;
  repeat
    if (LEntry = LTail) then
      Break;

    LClassType := LEntry.ClassType;
    if (Assigned(LClassType)) then
    begin
      if (LClassType.InheritsFrom(UnsafeAttribute)) then
      begin
        Result := rfUnsafe;
        Exit;
      end else
      if (LClassType.InheritsFrom(WeakAttribute)) then
      begin
        Result := rfWeak;
      end;
    end;

    LEntry := LEntry.Tail;
    if (NativeUInt(LEntry) > NativeUInt(LTail)) then
    begin
      TinyError(teInvalidPtr);
      Exit;
    end;
  until (False);
end;
{$else}
begin
  Result := rfDefault;
end;
{$endif}
{$endif .EXTENDEDRTTI}


{ TTypeInfo }

function TTypeInfo.GetTypeData: PTypeData;
var
  LCount: NativeUInt;
begin
  LCount := NativeUInt(Name.Value[0]);
  Result := Pointer(@Name.Value[LCount + 1]);
end;

{$ifdef EXTENDEDRTTI}
function TTypeInfo.GetAttrData: PAttrData;
var
  LTypeData: PTypeData;
begin
  LTypeData := GetTypeData;

  case Kind of
    {$ifdef UNICODE}
    tkUString,
    {$endif}
    {$ifdef WIDESTRSUPPORT}
    tkWString,
    {$endif}
    tkVariant: Result := @LTypeData.AttrData;
    {$ifdef ANSISTRSUPPORT}
    tkLString: Result := @LTypeData.LStrAttrData;
    {$endif}
    {$ifdef SHORTSTRSUPPORT}
    tkString: Result := @LTypeData.StrAttrData;
    {$endif}
    tkSet: Result := @LTypeData.SetAttrData;
    {$ifdef ANSISTRSUPPORT}
    tkChar,
    {$endif}
    tkWChar,
    tkInteger: Result := @LTypeData.OrdAttrData;
    tkFloat: Result := @LTypeData.FloatAttrData;
    tkInt64: Result := @LTypeData.Int64AttrData;
    tkClassRef: Result := @LTypeData.ClassRefAttrData;
    tkPointer: Result := @LTypeData.PtrAttrData;
    tkProcedure: Result := @LTypeData.ProcAttrData;
    tkEnumeration: Result := LTypeData.EnumerationData.GetAttrDataRec;
    tkClass: Result := LTypeData.ClassData.GetAttrDataRec;
    tkMethod: Result := LTypeData.MethodData.GetAttrDataRec;
    tkInterface: Result := LTypeData.InterfaceData.GetAttrDataRec;
    tkDynArray: Result := LTypeData.DynArrayData.GetAttrDataRec;
    tkArray: Result := LTypeData.ArrayData.GetAttrDataRec;
    tkRecord{$ifdef MANAGEDRECORDS}, tkMRecord{$endif}: Result := LTypeData.RecordData.GetAttrDataRec;
  else
    Result := nil;
  end;

  if (Assigned(Result)) then
  begin
    case Result.Len of
      0, 1: TinyError(teInvalidPtr);
      2: Result := nil;
    end;
  end;
end;
{$endif}


{ PTypeInfoRef }

{$ifNdef SMALLOBJECTSUPPORT}
function PTypeInfoRef.GetAddress: Pointer;
begin
  Result := Self;
end;
{$endif}

function PTypeInfoRef.GetAssigned: Boolean;
begin
  Result := System.Assigned({$ifdef SMALLOBJECTSUPPORT}F.Address{$else}Self{$endif});
end;

{$ifNdef FPC}
function PTypeInfoRef.GetValue: PTypeInfo;
begin
  Result := Pointer({$ifdef SMALLOBJECTSUPPORT}F.Value{$else}Self{$endif});
  if (System.Assigned(Result)) then
  begin
    Result := PPointer(Result)^;
  end;
end;
{$endif}


{ TResultData }

{$ifdef WEAKREF}
procedure TResultData.InitReference(const AAttrData: PAttrData);
begin
  {$ifdef BCB}This.{$endif}Reference := rfDefault;

  if (System.Assigned(AAttrData)) and (System.Assigned({$ifdef BCB}This.{$endif}TypeInfo)) and
    ({$ifdef BCB}This.{$endif}TypeInfo.Kind in REFERENCED_TYPE_KINDS) then
  begin
    if (AAttrData.Reference = rfUnsafe) then
    begin
      {$ifdef BCB}This.{$endif}Reference := rfUnsafe;
    end;
  end;
end;
{$endif}

function TResultData.GetAssigned: Boolean;
begin
  Result := System.Assigned({$ifdef BCB}This.{$endif}Name);
end;


{ TAttributedParamData }

{$ifdef WEAKREF}
procedure TAttributedParamData.InitReference;
begin
  {$ifdef BCB}This.{$endif}Reference := rfDefault;

  if (System.Assigned(AttrData)) and (Assigned({$ifdef BCB}This.{$endif}TypeInfo)) and
    ({$ifdef BCB}This.{$endif}TypeInfo.Kind in REFERENCED_TYPE_KINDS) then
  begin
    {$ifdef BCB}This.{$endif}Reference := AttrData.Reference;
  end;
end;
{$endif}


{ TArgumentData }

{$ifdef WEAKREF}
procedure TArgumentData.InitReference;
begin
  if (pfConst in Flags) then
  begin
    {$ifdef BCB}This.This.{$endif}Reference := rfDefault;
  end else
  begin
    inherited;
  end;
end;
{$endif}


{ TPropInfo }

function TPropInfo.GetTail: Pointer;
begin
  Result := @Name;
  Inc(NativeUInt(Result), NativeUInt(Byte(Result^)) + SizeOf(Byte));
end;


{ TPropData}

function TPropData.GetTail: Pointer;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@PropList);
  for i := 0 to PropCount - 1 do
  begin
    LPtr := PPropInfo(LPtr).Tail;
  end;

  Result := LPtr;
end;


{ TManagedField }

function TManagedField.GetTail: Pointer;
begin
  Result := @Self;
  Inc(NativeUInt(Result), SizeOf(Self));
end;


{ TVmtFieldClassTab }

{$ifNdef FPC}
function TVmtFieldClassTab.GetClass(const AIndex: Word): TClass;
var
  LPtr: PByte;
begin
  LPtr := Pointer(ClassRef[AIndex]);
  if (Assigned(LPtr)) then
  begin
    LPtr := PPointer(LPtr)^;
  end;

  Result := TClass(LPtr);
end;
{$endif}


{ TVmtFieldEntry }

function TVmtFieldEntry.GetTail: Pointer;
begin
  Result := Name.Tail;
end;


{ TVmtFieldTable }

function TVmtFieldTable.GetTail: Pointer;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@Entries);
  for i := 0 to Integer(Count) - 1 do
  begin
    LPtr := PVmtFieldEntry(LPtr).Tail;
  end;

  Result := Pointer(LPtr);
end;


{ TVmtMethodEntry }

function TVmtMethodEntry.GetTail: Pointer;
begin
  Result := @Len;
  Inc(NativeUInt(Result), Len);
end;

{$ifdef EXTENDEDRTTI}
function TVmtMethodEntry.GetSignature: PVmtMethodSignature;
begin
  Result := Name.Tail;
  if (Result = Tail) then
  begin
    Result := nil;
  end;
end;
{$endif}


{ TVmtMethodTable }

function TVmtMethodTable.GetTail: Pointer;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@Entries);
  for i := 0 to Integer(Count) - 1 do
  begin
    LPtr := PVmtMethodEntry(LPtr).Tail;
  end;

  Result := Pointer(LPtr);
end;


{ TIntfMethodParamTail }

{$ifdef EXTENDEDRTTI}
function TIntfMethodParamTail.GetAttrData: PAttrData;
begin
  Result := AttrDataRec.Value;
end;
{$endif}


{ TIntfMethodParam }

function TIntfMethodParam.GetTypeName: PShortStringHelper;
begin
  Result := ParamName.Tail;
end;

function TIntfMethodParam.GetParamTail: PIntfMethodParamTail;
begin
  Result := TypeName.Tail;
end;

function TIntfMethodParam.GetParamType: PTypeInfo;
begin
  Result := GetParamTail.ParamType.Value;
end;

{$ifdef EXTENDEDRTTI}
function TIntfMethodParam.GetAttrDataRec: PAttrData;
begin
  Result := @GetParamTail.AttrDataRec;
end;

function TIntfMethodParam.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;
{$endif}

function TIntfMethodParam.GetData: TArgumentData;
begin
  Result.{$ifdef BCB}This.This.{$endif}Name := @ParamName;
  Result.{$ifdef BCB}This.This.{$endif}TypeInfo := ParamType;
  Result.{$ifdef BCB}This.This.{$endif}TypeName := TypeName;
  Result.Flags := Flags;
  {$ifdef EXTENDEDRTTI}
  Result.{$ifdef BCB}This.{$endif}AttrData := AttrData;
  {$endif}
  {$ifdef WEAKREF}
  Result.InitReference;
  {$else}
  Result.Reference := rfDefault;
  {$endif}
end;

function TIntfMethodParam.GetTail: Pointer;
begin
  {$ifdef EXTENDEDRTTI}
    Result := GetParamTail.AttrDataRec.Tail;
  {$else}
    Result := GetParamTail;
    Inc(NativeUInt(Result), SizeOf(PTypeInfoRef));
  {$endif}
end;


{ TIntfMethodSignature }

function TIntfMethodSignature.GetParamsTail: PByte;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@Params);
  for i := 0 to Integer(ParamCount) - 1 do
  begin
    LPtr := PIntfMethodParam(LPtr).Tail;
  end;

  Result := LPtr;
end;

function TIntfMethodSignature.GetResultData: TResultData;
var
  LPtr: PByte;
begin
  Result.{$ifdef BCB}This.{$endif}Reference := rfDefault;
  if (Kind = 1) then
  begin
    LPtr := GetParamsTail;
    Result.{$ifdef BCB}This.{$endif}TypeName := PShortStringHelper(LPtr);
    if (Result.{$ifdef BCB}This.{$endif}TypeName.Length <> 0) then
    begin
      LPtr := PShortStringHelper(LPtr).Tail;
      Result.{$ifdef BCB}This.{$endif}TypeInfo := PTypeInfoRef(PPointer(LPtr)^).Value;
      Result.{$ifdef BCB}This.{$endif}Name := PShortStringHelper(@SHORTSTR_RESULT);

      {$ifdef WEAKREF}
      {
        Attention!
        RTTI does not contain Result reference
        Therefore, the only correct way to specify unsafe result is this:
        [Result: Unsafe] function ...
      }
      if (Assigned(Result.{$ifdef BCB}This.{$endif}TypeInfo)) and
        (Result.{$ifdef BCB}This.{$endif}TypeInfo.Kind in REFERENCED_TYPE_KINDS) then
      begin
        Result.InitReference(AttrData);
      end;
      {$endif}

      Exit;
    end;
  end;

  Result.{$ifdef BCB}This.{$endif}Name := nil;
  Result.{$ifdef BCB}This.{$endif}TypeInfo := nil;
  Result.{$ifdef BCB}This.{$endif}TypeName := nil;
end;

{$ifdef EXTENDEDRTTI}
function TIntfMethodSignature.GetAttrDataRec: PAttrData;
var
  LPtr: PByte;
  LCount: NativeUInt;
begin
  LPtr := GetParamsTail;
  if (Kind = 1) then
  begin
    LCount := LPtr^;
    if (LCount = 0) then
    begin
      Inc(LPtr);
    end else
    begin
      Inc(LPtr, LCount);
      Inc(LPtr, SizeOf(Byte) + SizeOf(Pointer));
    end;
  end;

  Result := Pointer(LPtr);
end;

function TIntfMethodSignature.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;
{$endif .EXTENDEDRTTI}

function TIntfMethodSignature.GetTail: Pointer;
{$ifdef EXTENDEDRTTI}
begin
  Result := GetAttrDataRec.Tail;
end;
{$else}
var
  LPtr: PByte;
  LCount: NativeUInt;
begin
  LPtr := GetParamsTail;
  if (Kind = 1) then
  begin
    LCount := LPtr^;
    if (LCount = 0) then
    begin
      Inc(LPtr);
    end else
    begin
      Inc(LPtr, LCount);
      Inc(LPtr, SizeOf(Byte) + SizeOf(Pointer));
    end;
  end;

  Result := Pointer(LPtr);
end;
{$endif}

function TIntfMethodSignature.GetData(var AData: TSignatureData): Integer;
var
  i: Integer;
  LParam: PIntfMethodParam;
begin
  AData.MethodKind := TMethodKind(Kind);
  AData.HasSelf := True;
  AData.CallConv := CC;
  AData.Result := ResultData;

  Result := 0;
  LParam := Params.Tail;
  for i := 1 to Integer(ParamCount) - 1 do
  begin
    if (not (pfResult in LParam.Flags)) then
    begin
      AData.Arguments[Result] := LParam.Data;
      Inc(Result);
    end;

    LParam := LParam.Tail;
  end;

  AData.ArgumentCount := Result;
end;


{ TIntfMethodEntry }

function TIntfMethodEntry.GetSignature: PIntfMethodSignature;
begin
  Result := Name.Tail;
end;

function TIntfMethodEntry.GetTail: Pointer;
begin
  Result := Signature.Tail;
end;


{ TIntfMethodTable }

function TIntfMethodTable.GetHasEntries: Boolean;
begin
  case RttiCount of
    0, $ffff: Result := False;
  else
    Result := True;
  end;
end;

{$ifdef EXTENDEDRTTI}
function TIntfMethodTable.GetAttrDataRec: PAttrData;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@Entries);
  if (RttiCount <> $ffff) then
  for i := 0 to Integer(RttiCount) - 1 do
  begin
    LPtr := PIntfMethodEntry(LPtr).Tail;
  end;

  Result := Pointer(LPtr);
end;

function TIntfMethodTable.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;
{$endif}


{$if Defined(FPC) or Defined(EXTENDEDRTTI)}
{ TProcedureParam }

{$ifdef EXTENDEDRTTI}
function TProcedureParam.GetAttrDataRec: PAttrData;
begin
  Result := Name.Tail;
end;

function TProcedureParam.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;
{$endif}

function TProcedureParam.GetData: TArgumentData;
begin
  Result.{$ifdef BCB}This.This.{$endif}Name := @Name;
  Result.{$ifdef BCB}This.This.{$endif}TypeInfo := ParamType.Value;
  Result.{$ifdef BCB}This.This.{$endif}TypeName := nil;
  Result.Flags := Flags;
  {$ifdef EXTENDEDRTTI}
  Result.{$ifdef BCB}This.{$endif}AttrData := AttrData;
  {$endif}
  {$ifdef WEAKREF}
  Result.InitReference;
  {$else}
  Result.Reference := rfDefault;
  {$endif}
end;

function TProcedureParam.GetTail: Pointer;
begin
  {$ifdef EXTENDEDRTTI}
    Result := GetAttrDataRec.Tail;
  {$else}
    Result := Name.Tail;
  {$endif}
end;


{ TProcedureSignature }

function TProcedureSignature.GetIsValid: Boolean;
begin
  Result := (Flags <> 255);
end;

function TProcedureSignature.GetResultData: TResultData;
begin
  Result.{$ifdef BCB}This.{$endif}Reference := rfDefault;
  Result.{$ifdef BCB}This.{$endif}TypeName := nil;
  Result.{$ifdef BCB}This.{$endif}Name := nil;
  if (IsValid) then
  begin
    Result.{$ifdef BCB}This.{$endif}TypeInfo := ResultType.Value;
    if (Assigned(Result.{$ifdef BCB}This.{$endif}TypeInfo)) then
    begin
      Result.{$ifdef BCB}This.{$endif}Name := PShortStringHelper(@SHORTSTR_RESULT);

      {$ifdef WEAKREF}
      {
        Attention!
        RTTI does not contain Result reference
        Therefore, the only correct way to specify unsafe result is this:
        [Unsafe] TProcedureType = function ... unsafe;
        (!) Remember to pass AttrData to the GetData method
      }
      {$endif}
    end;
  end else
  begin
    Result.{$ifdef BCB}This.{$endif}TypeInfo := nil;
  end;
end;

function TProcedureSignature.GetTail: Pointer;
var
  i: Integer;
begin
  if (IsValid) then
  begin
    Result := @Params;
    for i := 0 to Integer(ParamCount) - 1 do
    begin
      Result := TProcedureParam(Result^).Tail;
    end;
  end else
  begin
    Result := @CC;
  end;
end;

function TProcedureSignature.GetData(var AData: TSignatureData;
  const AAttrData: Pointer): Integer;
var
  i: Integer;
  LParam: PProcedureParam;
begin
  if (not IsValid) then
  begin
    AData.ArgumentCount := INVALID_COUNT;
    Result := INVALID_COUNT;
    Exit;
  end;

  AData.MethodKind := TMethodKind(ResultType.Assigned);
  AData.HasSelf := False;
  AData.CallConv := CC;
  Result := 0;
  LParam := @Params;
  for i := 0 to Integer(ParamCount) - 1 do
  begin
    if (not (pfResult in LParam.Flags)) then
    begin
      AData.Arguments[Result] := LParam.Data;
      Inc(Result);
    end;

    LParam := LParam.Tail;
  end;
  AData.ArgumentCount := Result;

  // ResultData
  AData.Result := ResultData;
  {$ifdef WEAKREF}
  {
    Attention!
    RTTI does not contain Result reference
    Therefore, the only correct way to specify unsafe result is this:
    [Unsafe] TProcedureType = function ... unsafe;
  }
  AData.Result.InitReference(AAttrData);
  {$endif}
end;
{$ifend .FPC.EXTENDEDRTTI}


{$ifdef EXTENDEDRTTI}
{ TPropInfoEx }

function TPropInfoEx.GetAttrData: PAttrData;
begin
  Result := AttrDataRec.Value;
end;

function TPropInfoEx.GetTail: Pointer;
begin
  Result := AttrDataRec.Tail;
end;


{ TPropDataEx }

function TPropDataEx.GetTail: Pointer;
var
  i: Integer;
  LPtr: Pointer;
begin
  LPtr := Pointer(@PropList);
  for i := 0 to Integer(PropCount) - 1 do
  begin
    LPtr := PPropInfoEx(LPtr).Tail;
  end;

  Result := LPtr;
end;


{ TArrayPropInfo }

function TArrayPropInfo.GetAttrDataRec: PAttrData;
begin
  Result := Name.Tail;
end;

function TArrayPropInfo.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;

function TArrayPropInfo.GetTail: Pointer;
begin
  Result := GetAttrDataRec.Tail;
end;


{ TArrayPropData }

function TArrayPropData.GetTail: Pointer;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@PropData);
  for i := 0 to Integer(Count) - 1 do
  begin
    LPtr := PArrayPropInfo(LPtr).Tail;
  end;

  Result := LPtr;
end;


{ TVmtFieldExEntry }

function TVmtFieldExEntry.GetVisibility: TMemberVisibility;
begin
  Result := TMemberVisibility(Flags and 3);
end;

function TVmtFieldExEntry.GetAttrDataRec: PAttrData;
begin
  Result := Name.Tail;
end;

function TVmtFieldExEntry.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;

function TVmtFieldExEntry.GetValue: TFieldData;
begin
  Result.{$ifdef BCB}This.This.{$endif}Name := @Name;
  Result.{$ifdef BCB}This.This.{$endif}TypeInfo := TypeRef.Value;
  Result.{$ifdef BCB}This.This.{$endif}TypeName := nil;
  Result.Visibility := Visibility;
  Result.{$ifdef BCB}This.{$endif}AttrData := AttrData;
  {$ifdef WEAKREF}
  Result.{$ifdef BCB}This.{$endif}InitReference;
  {$else}
  Result.Reference := rfDefault;
  {$endif}
end;

function TVmtFieldExEntry.GetTail: Pointer;
begin
  Result := GetAttrDataRec.Tail;
end;


{ TVmtMethodParam }

function TVmtMethodParam.GetAttrDataRec: PAttrData;
begin
  Result := Name.Tail;
end;

function TVmtMethodParam.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;

function TVmtMethodParam.GetData: TArgumentData;
begin
  Result.{$ifdef BCB}This.This.{$endif}Name := @Name;
  Result.{$ifdef BCB}This.This.{$endif}TypeInfo := ParamType.Value;
  Result.{$ifdef BCB}This.This.{$endif}TypeName := nil;
  Result.Flags := Flags;
  {$ifdef EXTENDEDRTTI}
  Result.{$ifdef BCB}This.{$endif}AttrData := AttrData;
  {$endif}
  {$ifdef WEAKREF}
  Result.InitReference;
  {$else}
  Result.Reference := rfDefault;
  {$endif}
end;

function TVmtMethodParam.GetTail: Pointer;
begin
  Result := GetAttrDataRec.Tail;
end;


{ TVmtMethodSignature }

function TVmtMethodSignature.GetAttrDataRec: PAttrData;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@Params);
  for i := 0 to Integer(ParamCount) - 1 do
  begin
    LPtr := PVmtMethodParam(LPtr).Tail;
  end;

  Result := Pointer(LPtr);
end;

function TVmtMethodSignature.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;

procedure TVmtMethodSignature.InternalGetResultData(var AResult: TResultData;
  const AHasResultParam: Integer);
{$ifdef WEAKREF}
var
  i: Integer;
  LParam: PVmtMethodParam;
{$endif}
begin
  AResult.{$ifdef BCB}This.{$endif}Reference := rfDefault;
  AResult.{$ifdef BCB}This.{$endif}TypeInfo := ResultType.Value;
  AResult.{$ifdef BCB}This.{$endif}TypeName := nil;
  if (Assigned(AResult.{$ifdef BCB}This.{$endif}TypeInfo)) then
  begin
    AResult.{$ifdef BCB}This.{$endif}Name := PShortStringHelper(@SHORTSTR_RESULT);

    {$ifdef WEAKREF}
    if (AResult.{$ifdef BCB}This.{$endif}TypeInfo.Kind in REFERENCED_TYPE_KINDS) then
    begin
      if (AHasResultParam <> INVALID_INDEX) then
      begin
        if (AHasResultParam = 0) then
        begin
          AResult.{$ifdef BCB}This.{$endif}Reference := rfUnsafe;
        end;
      end else
      begin
        AResult.{$ifdef BCB}This.{$endif}Reference := rfUnsafe;
        LParam := @Params;
        for i := 0 to Integer(ParamCount) - 1 do
        begin
          if (pfResult in LParam.Flags) then
          begin
            AResult.{$ifdef BCB}This.{$endif}Reference := rfDefault;
            Break;
          end;

          LParam := LParam.Tail;
        end;
      end;
    end;
    {$endif}
  end else
  begin
    AResult.{$ifdef BCB}This.{$endif}Name := nil;
  end;
end;

function TVmtMethodSignature.GetResultData: TResultData;
begin
  InternalGetResultData(Result, INVALID_INDEX);
end;

function TVmtMethodSignature.GetData(var AData: TSignatureData; const AMethodKind: TMethodKind;
  const AHasSelf: Boolean): Integer;
var
  i, LCount: Integer;
  LParam: PVmtMethodParam;
  LHasResultParam: Boolean;
begin
  AData.MethodKind := AMethodKind;
  AData.HasSelf := AHasSelf;
  AData.CallConv := CC;

  // arguments
  Result := 0;
  LParam := @Params;
  LCount := ParamCount;
  if (AHasSelf) then
  begin
    LParam := LParam.Tail;
    Dec(LCount);
  end;
  LHasResultParam := False;
  for i := 0 to LCount - 1 do
  begin
    if (pfResult in LParam.Flags) then
    begin
      LHasResultParam := True;
    end else
    begin
      AData.Arguments[Result] := LParam.Data;
      Inc(Result);
    end;

    LParam := LParam.Tail;
  end;
  AData.ArgumentCount := Result;

  // ResultData
  InternalGetResultData(AData.Result, Ord(LHasResultParam));
end;

function TVmtMethodSignature.GetData(var AData: TSignatureData): Integer;
begin
  Result := GetData(AData, TMethodKind(ResultType.Assigned), True);
end;


{ TVmtMethodExEntry }

function TVmtMethodExEntry.GetName: PShortStringHelper;
var
  LPtr: PByte;
begin
  LPtr := Pointer(Entry);
  if (Assigned(LPtr)) then
  begin
    LPtr := Pointer(@PVmtMethodEntry(LPtr).Name);
  end;

  Result := Pointer(LPtr);
end;

function TVmtMethodExEntry.GetCodeAddress: Pointer;
var
  LPtr: PByte;
begin
  LPtr := Pointer(Entry);
  if (Assigned(LPtr)) then
  begin
    LPtr := PVmtMethodEntry(LPtr).CodeAddress;
  end;

  Result := Pointer(LPtr);
end;

function TVmtMethodExEntry.GetIsSpecial: Boolean;
begin
  Result := (Flags and 4{mfSpecial} <> 0);
end;

function TVmtMethodExEntry.GetIsAbstract: Boolean;
begin
  Result := (Flags and (1 shl 7) <> 0);
end;

function TVmtMethodExEntry.GetIsStatic: Boolean;
begin
  if (IsSpecial) then
  begin
    Result := (Flags and 3 = 2{smOperatorOverload});
  end else
  begin
    Result := (Flags and 2{mfHasSelf} = 0);
  end;
end;

function TVmtMethodExEntry.GetIsConstructor: Boolean;
begin
  Result := (IsSpecial) and (Flags and 3 = 0{smConstructor});
end;

function TVmtMethodExEntry.GetIsDestructor: Boolean;
begin
  Result := (IsSpecial) and (Flags and 3 = 1{smDestructor});
end;

function TVmtMethodExEntry.GetIsOperator: Boolean;
begin
  Result := (IsSpecial) and (Flags and 3 = 2{smOperatorOverload});
end;

function TVmtMethodExEntry.GetIsClassMethod: Boolean;
begin
  Result := IsStatic or (Flags and (4{mfSpecial} or 1{mfClassMethod}) = 1{mfClassMethod});
 end;

function TVmtMethodExEntry.GetHasSelf: Boolean;
begin
  if (IsSpecial) then
  begin
    Result := (Flags and 3 <= 1{[smConstructor, smDestructor]});
  end else
  begin
    Result := (Flags and 2{mfHasSelf} <> 0);
  end;
end;

function TVmtMethodExEntry.GetDispatchKind: TDispatchKind;
begin
  Result := TDispatchKind((Flags shr 3) and 3);
end;

function TVmtMethodExEntry.GetMemberVisibility: TMemberVisibility;
begin
  Result := TMemberVisibility((Flags shr 5) and 3);
end;

function TVmtMethodExEntry.GetMethodKind: TMethodKind;
var
  LSignature: PVmtMethodSignature;
begin
  if (IsSpecial) then
  begin
    case Flags and 3 of
      0{smConstructor}: Result := mkConstructor;
      1{smDestructor}: Result := mkDestructor;
      2{smOperatorOverload}: Result := mkOperatorOverload;
    else
      Result := mkProcedure;
    end;
  end else
  begin
    Result := mkProcedure;
    if (IsClassMethod) then
    begin
      Result := mkClassProcedure;
    end;

    if (Assigned(Entry)) and (Assigned(Entry)) then
    begin
      LSignature := Self.Entry.Signature;
      if (Assigned(LSignature)) and (LSignature.ResultType.Assigned) then
        Inc(Result);
    end;
  end;
end;

function TVmtMethodExEntry.GetTail: Pointer;
begin
  Result := @Self;
  Inc(NativeUInt(Result), SizeOf(Self));
end;

function TVmtMethodExEntry.GetData(var AData: TSignatureData): Integer;
var
  LEntry: PVmtMethodEntry;
  LSignature: PVmtMethodSignature;
begin
  LEntry := Entry;
  if (Assigned(LEntry)) then
  begin
    LSignature := LEntry.Signature;
    if (Assigned(LSignature)) then
    begin
      Result := LSignature.GetData(AData, MethodKind, HasSelf);
      Exit;
    end;
  end;

  AData.ArgumentCount := INVALID_COUNT;
  Result := INVALID_COUNT;
end;


{ TVmtMethodTableEx }

function TVmtMethodTableEx.GetVirtualCount: Word;
begin
  Result := PWord(@Entries[Count])^;
end;

function TVmtMethodTableEx.Find(const AName: PShortStringHelper): PVmtMethodExEntry;
var
  i: Integer;
  LCount: NativeUInt;
  LName: PShortStringHelper;
begin
  if (Assigned(AName)) then
  begin
    LCount := PByte(AName)^;

    Result := @Entries[0];
    for i := 0 to Integer(Self.Count) - 1 do
    begin
      if (Assigned(Result.Entry)) then
      begin
        LName := @Result.Entry.Name;
        if (PByte(LName)^ = LCount) and
          (EqualNames(Pointer(@AName.Value[1]), Pointer(@LName.Value[1]), LCount)) then
          Exit;
      end;

      // Result := Result.Tail;
      Inc(NativeUInt(Result), SizeOf(TVmtMethodExEntry));
    end;
  end;

  Result := nil;
end;

function TVmtMethodTableEx.Find(const AName: string): PVmtMethodExEntry;
var
  LBuffer: ShortString;
begin
  Result := Find(ConvertName(LBuffer, AName));
end;


{ TRecordTypeOptions }

function TRecordTypeOptions.GetTail: Pointer;
begin
  Result := @Values[Count];
end;


{ TRecordTypeField }

function TRecordTypeField.GetVisibility: TMemberVisibility;
begin
  Result := TMemberVisibility(Flags and 3);
end;

function TRecordTypeField.GetAttrDataRec: PAttrData;
begin
  Result := Name.Tail;
end;

function TRecordTypeField.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;

function TRecordTypeField.GetFieldData: TFieldData;
begin
  Result.{$ifdef BCB}This.This.{$endif}Name := @Name;
  Result.{$ifdef BCB}This.This.{$endif}TypeInfo := Field.TypeRef.Value;
  Result.{$ifdef BCB}This.This.{$endif}TypeName := nil;
  Result.Visibility := Visibility;
  Result.Offset := Cardinal(Field.FldOffset);
  Result.{$ifdef BCB}This.{$endif}AttrData := AttrData;
  {$ifdef WEAKREF}
  Result.{$ifdef BCB}This.{$endif}InitReference;
  {$else}
  Result.{$ifdef BCB}This.{$endif}Reference := rfDefault;
  {$endif}
end;

function TRecordTypeField.GetTail: Pointer;
begin
  Result := GetAttrDataRec.Tail;
end;


{ TRecordTypeFields }

function TRecordTypeFields.GetTail: Pointer;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@Fields);
  for i := 0 to Count - 1 do
  begin
    LPtr := PRecordTypeField(LPtr).Tail;
  end;

  Result := LPtr;
end;


{ TRecordTypeMethod }

function TRecordTypeMethod.GetMemberVisibility: TMemberVisibility;
begin
  Result := TMemberVisibility((Flags shr 2) and 3);
end;

function TRecordTypeMethod.GetMethodKind: TMethodKind;
label
  check_result;
var
  LSignature: PProcedureSignature;
begin
  case (Cardinal(Flags) and 3) of
    0:
    begin
      Result := mkProcedure;
      goto check_result;
    end;
    1:
    begin
      Result := mkClassProcedure;
    check_result:
      LSignature := Signature;
      if (Assigned(LSignature)) and (LSignature.ResultType.Assigned) then
      begin
        Inc(Result);
      end;
    end;
    2:
    begin
      Result := mkConstructor;
    end;
  else
    Result := mkOperatorOverload;
  end;
end;

function TRecordTypeMethod.GetSignatureData: PProcedureSignature;
begin
  Result := Name.Tail;
end;

function TRecordTypeMethod.GetSignature: PProcedureSignature;
begin
  Result := GetSignatureData;
  if (not Result.IsValid) then
  begin
    Result := nil;
  end;
end;

function TRecordTypeMethod.GetAttrDataRec: PAttrData;
begin
  Result := GetSignatureData.Tail;
end;

function TRecordTypeMethod.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;

function TRecordTypeMethod.GetTail: Pointer;
begin
  Result := GetAttrDataRec.Tail;
end;

function TRecordTypeMethod.GetData(var AData: TSignatureData): Integer;
var
  LSignature: PProcedureSignature;
  LAttrData: PAttrData;
  {$ifdef WEAKREF}
  LTypeInfo: PTypeInfo;
  {$endif}
begin
  LSignature := Signature;
  if (Assigned(LSignature)) then
  begin
    LAttrData := nil;
    {$ifdef WEAKREF}
    {
      Attention!
      RTTI does not contain Result reference
      Therefore, the only correct way to specify unsafe result is this:
      [Result: Unsafe] function ...
    }
    LTypeInfo := LSignature.ResultType.Value;
    if (Assigned(LTypeInfo)) and
      (LTypeInfo.Kind in REFERENCED_TYPE_KINDS) then
    begin
      LAttrData := AttrData;
    end;
    {$endif}

    Result := LSignature.GetData(AData, LAttrData);
    if (Result >= 0) then
    begin
      AData.MethodKind := MethodKind;
      AData.HasSelf := (AData.MethodKind in [mkProcedure, mkFunction]);
    end;

    Exit;
  end;

  AData.ArgumentCount := INVALID_COUNT;
  Result := INVALID_COUNT;
end;


{ TRecordTypeMethods }

function TRecordTypeMethods.GetTail: Pointer;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@Methods);
  for i := 0 to Integer(Count) - 1 do
  begin
    LPtr := PRecordTypeMethod(LPtr).Tail;
  end;

  Result := LPtr;
end;
{$endif .EXTENDEDRTTI}


{ TEnumerationTypeData }

function TEnumerationTypeData.GetCount: Integer;
begin
  Result := (MaxValue - MinValue) + 1;
end;

function TEnumerationTypeData.GetEnumName(const AValue: Integer): PShortStringHelper;
var
  i: Integer;
begin
  Result := nil;
  if (AValue < 0) or (AValue > MaxValue) or (MinValue <> 0) then
    Exit;

  Result := @NameList;
  for i := MinValue to AValue - 1 do
  begin
    Result := Pointer(@Result.Value[Byte(Result.Value[0]) + 1]){Result.Tail};
  end;
end;

function TEnumerationTypeData.GetEnumValue(const AName: ShortString): Integer;
label
  failure;
var
  LCount: NativeUInt;
  LMaxResult: Integer;
  LSource, LTarget: PAnsiChar;
begin
  LSource := Pointer(@AName);
  LCount := PByte(LSource)^;
  if (MinValue <> 0) or (LCount = 0) then
    goto failure;

  LMaxResult := MaxValue;
  Inc(LSource);
  LTarget := Pointer(@NameList);
  Result := INVALID_INDEX;
  repeat
    Inc(Result);
    if (PByte(LTarget)^ = LCount) then
    begin
      if (EqualNames(LSource, LTarget + 1, LCount)) then
        Exit;

      LCount := PByte(LTarget)^;
    end;

    LTarget := LTarget + PByte(LTarget)^ + 1;
  until (Result = LMaxResult);

failure:
  Result := INVALID_INDEX;
end;

function TEnumerationTypeData.GetUnitName: PShortStringHelper;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@NameList);
  for i := 0 to Count - 1 do
  begin
    LPtr := PShortStringHelper(LPtr).Tail;
  end;

  Result := Pointer(LPtr);
end;

{$ifdef EXTENDEDRTTI}
function TEnumerationTypeData.GetAttrDataRec: PAttrData;
begin
  Result := UnitName.Tail;
end;

function TEnumerationTypeData.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;
{$endif}


{ TSetTypeData }

{$ifdef EXTENDEDRTTI}
function TSetTypeData.GetAttrData: PAttrData;
begin
  Result := AttrDataRec.Value;
end;
{$endif}

function TSetTypeData.GetSize: Integer;
{$if not Defined(FPC) and (CompilerVersion >= 32)}
var
  LValue: Integer;
begin
  LValue := SetTypeOrSize;
  if (LValue > $7f) then
  begin
    LValue := LValue and $7f;
  end else
  begin
    LValue := LValue shr 1;
    LValue := (LValue shl 1) + Byte(LValue = 0);
  end;

  Result := LValue;
end;
{$else}
const
  BYTE_MASK = $ff shl 3;
var
  LTypeInfo: PTypeInfo;
  LTypeData: PTypeData;
  LLow, LHigh: Integer;
begin
  LTypeInfo := CompType.Value;
  if (not Assigned(LTypeInfo)) then
  begin
    Result := INVALID_COUNT;
    Exit;
  end;

  LTypeData := LTypeInfo.TypeData;
  LLow := LTypeData.MinValue;
  LHigh := LTypeData.MaxValue;
  Result := (((LHigh + 7 + 1) and BYTE_MASK) - (LLow and BYTE_MASK)) shr 3;
  Inc(Result, Byte(Result = 3));
end;
{$ifend}

function TSetTypeData.GetAdjustment: Integer;
{$if not Defined(FPC) and (CompilerVersion >= 32)}
begin
  Result := Integer(PByte(AttrDataRec.Tail)^ shl 3);
end;
{$else}
const
  BYTE_MASK = $ff shl 3;
var
  LTypeInfo: PTypeInfo;
  LTypeData: PTypeData;
begin
  LTypeInfo := CompType.Value;
  if (not Assigned(LTypeInfo)) then
  begin
    Result := INVALID_COUNT;
    Exit;
  end;

  LTypeData := LTypeInfo.TypeData;
  Result := LTypeData.MinValue and BYTE_MASK;
end;
{$ifend}


{ TMethodParam }

function TMethodParam.GetTypeName: PShortStringHelper;
begin
  Result := ParamName.Tail;
end;

function TMethodParam.GetTail: Pointer;
begin
  Result := TypeName.Tail;
end;


{ TMethodSignature }

function TMethodSignature.GetParamsTail: Pointer;
var
  i: Integer;
  LPtr: PByte;
begin
  LPtr := Pointer(@ParamList);
  for i := 0 to Integer(ParamCount) - 1 do
  begin
    LPtr := PMethodParam(LPtr).Tail;
  end;

  Result := LPtr;
end;

function TMethodSignature.InternalGetResultData(const APtr: PByte; var AResult: TResultData): PByte;
var
  LPtr: PByte;
begin
  AResult.{$ifdef BCB}This.{$endif}Reference := rfDefault;
  if (MethodKind <> mkFunction) then
  begin
    AResult.{$ifdef BCB}This.{$endif}Name := nil;
    AResult.{$ifdef BCB}This.{$endif}Reference := rfDefault;
    AResult.{$ifdef BCB}This.{$endif}TypeInfo := nil;
    AResult.{$ifdef BCB}This.{$endif}TypeName := nil;
    Result := APtr;
    Exit;
  end;

  LPtr := APtr;
  if (not Assigned(LPtr)) then
  begin
    LPtr := GetParamsTail;
  end;

  AResult.{$ifdef BCB}This.{$endif}Name := PShortStringHelper(@SHORTSTR_RESULT);
  AResult.{$ifdef BCB}This.{$endif}TypeName := Pointer(LPtr);
  LPtr := PShortStringHelper(LPtr).Tail;
  AResult.{$ifdef BCB}This.{$endif}TypeInfo := PTypeInfoRef(PPointer(LPtr)^).Value;
  Inc(LPtr, SizeOf(Pointer));
  Result := LPtr;

  AResult.{$ifdef BCB}This.{$endif}Reference := rfDefault;
  {$ifdef WEAKREF}
  {
    Attention!
    RTTI does not contain Result reference
    Therefore, the only correct way to specify unsafe result is this:
    [Unsafe] TMethodType = function ... unsafe of object;
  }
  if (Assigned(AResult.{$ifdef BCB}This.{$endif}TypeInfo)) and
    (AResult.{$ifdef BCB}This.{$endif}TypeInfo.Kind in REFERENCED_TYPE_KINDS) then
  begin
    AResult.InitReference(PMethodTypeData(@Self).AttrData);
  end;
  {$endif}
end;

function TMethodSignature.GetResultData: TResultData;
begin
  InternalGetResultData(nil, Result);
end;

function TMethodSignature.GetResultTail: Pointer;
var
  LPtr: PByte;
begin
  LPtr := GetParamsTail;
  if (MethodKind = mkFunction) then
  begin
    LPtr := PShortStringHelper(LPtr).Tail;
    Inc(LPtr, SizeOf(Pointer));
  end;

  Result := LPtr;
end;

function TMethodSignature.GetCallConv: TCallConv;
begin
  Result := PCallConv(GetResultTail)^;
end;

function TMethodSignature.GetParamTypes: PPTypeInfoRef;
var
  LPtr: PByte;
begin
  LPtr := GetResultTail;
  Inc(LPtr, SizeOf(TCallConv));
  Result := Pointer(LPtr);
end;

function TMethodSignature.GetData(var AData: TSignatureData): Integer;
{$ifdef EXTENDEDRTTI}
var
  LAttrDataRec: PAttrData;
  LSignature: PProcedureSignature;
begin
  LAttrDataRec := PMethodTypeData(@Self).GetAttrDataRec;
  LSignature := PPointer(NativeUInt(LAttrDataRec) - SizeOf(Pointer))^;
  if (not Assigned(LSignature)) then
  begin
    Result := INVALID_COUNT;
    AData.ArgumentCount := INVALID_COUNT;
    Exit;
  end;

  Result := LSignature.GetData(AData, LAttrDataRec.Value);
  AData.HasSelf := True;
end;
{$else}
var
  i: Integer;
  LPtr: PByte;
  LParam: PMethodParam;
  LArgument: PArgumentData;
begin
  // mkProcedure/mkFunction
  AData.MethodKind := MethodKind;
  AData.HasSelf := True;

  // arguments
  Result := 0;
  LParam := @ParamList;
  for i := 0 to Integer(ParamCount) - 1 do
  begin
    if (not (pfResult in LParam.Flags)) then
    begin
      LArgument := @AData.Arguments[Result];
      LArgument.Name := @LParam.ParamName;
      LArgument.Reference := rfDefault;
      LArgument.TypeInfo := nil;
      LArgument.TypeName := LParam.TypeName;
      if (Assigned(LArgument.TypeName)) and (LArgument.TypeName.Length = 0) then
      begin
        LArgument.TypeName := nil;
      end;
      LArgument.Flags := LParam.Flags;

      Inc(Result);
    end;

    LParam := LParam.Tail;
  end;
  AData.ArgumentCount := Result;

  // ResultData
  LPtr := InternalGetResultData(Pointer(LParam), AData.Result);

  // CallConv
  AData.CallConv := PCallConv(LPtr)^;
  Inc(LPtr, SizeOf(TCallConv));

  // TypeInfo
  for i := 0 to Result - 1 do
  begin
    AData.Arguments[i].TypeInfo := PTypeInfoRef(PPointer(LPtr)^).Value;
    Inc(LPtr, SizeOf(Pointer));
  end;
end;
{$endif}


{ TMethodTypeData}

{$ifdef EXTENDEDRTTI}
function TMethodTypeData.GetSignature: PProcedureSignature;
var
  LPtr: PByte;
begin
  LPtr := {$ifdef BCB}This.{$endif}GetResultTail;
  Inc(LPtr, SizeOf(TCallConv));
  Inc(LPtr, NativeUInt(ParamCount) * SizeOf(PTypeInfoRef));
  Result := PPointer(LPtr)^;
end;

function TMethodTypeData.GetAttrDataRec: PAttrData;
var
  LPtr: PByte;
begin
  LPtr := {$ifdef BCB}This.{$endif}GetResultTail;
  Inc(LPtr, SizeOf(TCallConv));
  Inc(LPtr, NativeUInt(ParamCount) * SizeOf(Pointer));
  Inc(LPtr, SizeOf(PProcedureSignature));
  Result := Pointer(LPtr);
end;

function TMethodTypeData.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;
{$endif .EXTENDEDRTTI}


{ TClassTypeData }

function TClassTypeData.GetFieldTable: PVmtFieldTable;
begin
  Result := PPointer(NativeInt(ClassType) + vmtFieldTable)^;
end;

function TClassTypeData.GetMethodTable: PVmtMethodTable;
begin
  Result := PPointer(NativeInt(ClassType) + vmtMethodTable)^;
end;

function TClassTypeData.GetPropData: PPropData;
begin
  Result := UnitName.Tail;
end;

{$ifdef EXTENDEDRTTI}
function TClassTypeData.GetFieldTableEx: PVmtFieldTableEx;
var
  LPtr: PByte;
begin
  LPtr := Pointer(FieldTable);
  if (Assigned(LPtr)) then
  begin
    LPtr := PVmtFieldTable(LPtr).Tail;
  end;

  Result := Pointer(LPtr);
end;

function TClassTypeData.GetMethodTableEx: PVmtMethodTableEx;
var
  LPtr: PByte;
begin
  LPtr := Pointer(MethodTable);
  if (Assigned(LPtr)) then
  begin
    LPtr := PVmtMethodTable(LPtr).Tail;
  end;

  Result := Pointer(LPtr);
end;

function TClassTypeData.GetPropDataEx: PPropDataEx;
begin
  Result := PropData.Tail;
end;

function TClassTypeData.GetAttrDataRec: PAttrData;
begin
  Result := PropDataEx.Tail;
end;

function TClassTypeData.GetArrayPropData: PArrayPropData;
begin
  Result := GetAttrDataRec.Tail;
end;

function TClassTypeData.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;
{$endif .EXTENDEDRTTI}

function TClassTypeData.VmtFunctionOffset(const AAddress: Pointer; const AStandardFunctions: Boolean): NativeInt;
const
  VMT_START: array[Boolean] of NativeInt = (
    {$ifdef FPC}vmtToString + SizeOf(Pointer){$else .DELPHI}0{$endif},
    {$ifdef FPC}vmtMethodStart{$else .DELPHI}vmtParent + SizeOf(Pointer){$endif});
var
  LVmtTable, LVmtTop: NativeUInt;
  LStart, LFinish, LValue: NativeUInt;
begin
  if (Assigned(AAddress)) then
  begin
    LVmtTable := NativeUInt(ClassType);
    LStart := LVmtTable;
    LFinish := LVmtTable;
    Inc(LStart, {$ifdef FPC}vmtClassName{$else .DELPHI}(vmtSelfPtr + SizeOf(Pointer)){$endif});
    Inc(LFinish, {$ifdef FPC}vmtMsgStrPtr{$else .DELPHI}vmtClassName{$endif});

    LVmtTop := High(NativeUInt);
    repeat
      LValue := PNativeUInt(LStart)^;
      Inc(LStart, SizeOf(Pointer));
      if (LValue >= LVmtTable) and (LValue < LVmtTop) then LVmtTop := LValue;
    until (LStart > LFinish);

    LVmtTop := NativeUInt(NativeInt(LVmtTop) and -SizeOf(Pointer));
    LStart := LVmtTable;
    Inc(NativeInt(LVmtTable), VMT_START[AStandardFunctions]);
    Dec(LVmtTable, SizeOf(Pointer));
    repeat
      Inc(LVmtTable, SizeOf(Pointer));
      if (LVmtTable = LVmtTop) then Break;
      if (PPointer(LVmtTable)^ = AAddress) then
      begin
        Result := NativeInt(LVmtTable) - NativeInt(LStart);
        Exit;
      end;
    until (False);
  end;

  Result := INVALID_INDEX;
end;


{ TInterfaceTypeData }

function TInterfaceTypeData.GetMethodTable: PIntfMethodTable;
begin
  Result := UnitName.Tail;
end;

{$ifdef EXTENDEDRTTI}
function TInterfaceTypeData.GetAttrDataRec: PAttrData;
begin
  Result := MethodTable.GetAttrDataRec;
end;

function TInterfaceTypeData.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;
{$endif}


{ TDynArrayTypeData }

function TDynArrayTypeData.GetArrElType: PTypeInfo;
begin
  Result := PTypeInfoRef(UnitName.Tail^).Value;
end;

{$ifdef EXTENDEDRTTI}
function TDynArrayTypeData.GetAttrDataRec: PAttrData;
var
  LPtr: PByte;
begin
  LPtr := UnitName.Tail;
  Inc(LPtr, SizeOf(PTypeInfoRef));

  Result := Pointer(LPtr);
end;

function TDynArrayTypeData.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;
{$endif}


{ TArrayTypeData }

{$ifdef EXTENDEDRTTI}
function TArrayTypeData.GetAttrDataRec: PAttrData;
var
  LPtr: PByte;
begin
  LPtr := Pointer(@Dims);
  Inc(LPtr, NativeUInt(DimCount) * SizeOf(Pointer));

  Result := Pointer(LPtr);
end;

function TArrayTypeData.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;
{$endif}


{ TRecordTypeData }

{$ifdef EXTENDEDRTTI}
function TRecordTypeData.GetOptions: PRecordTypeOptions;
var
  LPtr: PByte;
begin
  LPtr := Pointer(@ManagedFields);
  Inc(LPtr, NativeUInt(ManagedFieldCount) * SizeOf(TManagedField));

  Result := Pointer(LPtr);
end;

function TRecordTypeData.GetFields: PRecordTypeFields;
begin
  Result := Options.Tail;
end;

function TRecordTypeData.GetAttrDataRec: PAttrData;
begin
  Result := Fields.Tail;
end;

function TRecordTypeData.GetAttrData: PAttrData;
begin
  Result := GetAttrDataRec.Value;
end;

function TRecordTypeData.GetMethods: PRecordTypeMethods;
begin
  Result := GetAttrDataRec.Tail;
end;
{$endif .EXTENDEDRTTI}


{ TRangeTypeData }

function TRangeTypeData.GetCount: Cardinal;
begin
  Result := F.UHigh - F.ULow + 1;
end;

function TRangeTypeData.GetCount64: UInt64;
begin
  Result := F.U64High - F.U64Low + 1;
end;


{ TRttiTypeRules }

function TRttiTypeRules.GetIsRefArg: Boolean;
begin
  Result := (Flags * [tfRegValueArg, tfGenUseArg] = RTTI_RULEFLAGS_REFERENCE);
end;

function TRttiTypeRules.GetIsStackArg: Boolean;
begin
  Result := (Flags * [tfRegValueArg, tfGenUseArg] = RTTI_RULEFLAGS_STACKDATA);
end;

function TRttiTypeRules.GetIsGeneralArg: Boolean;
begin
  Result := (Flags * [tfRegValueArg, tfGenUseArg] = RTTI_RULEFLAGS_REGGENERAL);
end;

function TRttiTypeRules.GetIsExtendedArg: Boolean;
begin
  Result := (Flags * [tfRegValueArg, tfGenUseArg] = RTTI_RULEFLAGS_REGEXTENDED);
end;

function TRttiTypeRules.GetHFA: TRttiHFA;
begin
  {$ifdef HFASUPPORT}
  if (Return >= trFloat1) then
  begin
    Result := TRttiHFA(Ord(Return) - Ord(trFloat1) + Ord(hfaFloat1));
  end else
  {$endif}
  begin
    Result := hfaNone;
  end;
end;


{ TRttiBound }

function TRttiBound.GetCount: Integer;
begin
  Result := High - Low + 1;
end;


{ TRttiBound64 }

function TRttiBound64.GetCount: Int64;
begin
  Result := High - Low + 1;
end;

function TRttiBound64.GetBound: TRttiBound;
begin
  Result.Low := Low;
  Result.High := High;
end;

procedure TRttiBound64.SetBound(const AValue: TRttiBound);
begin
  Low := AValue.Low;
  High := AValue.High;
end;


{ TRttiCustomTypeData }

function TRttiCustomTypeData.GetBacket(const AIndex: NativeInt): Pointer;
type
  TPointerList = array[0..High(Integer) div SizeOf(Pointer) - 1] of Pointer;
begin
  Result := TPointerList(Pointer(@Self)^)[not AIndex];
end;

procedure TRttiCustomTypeData.SetBacket(const AIndex: NativeInt; const AValue: Pointer);
type
  TPointerList = array[0..High(Integer) div SizeOf(Pointer) - 1] of Pointer;
begin
  TPointerList(Pointer(@Self)^)[not AIndex] := AValue;
end;


{ TRttiEnumerationType }

procedure TRttiEnumerationType.SetLow(const AValue: Integer);
begin
  FB.Bound64.Low := AValue;
end;

procedure TRttiEnumerationType.SetHigh(const AValue: Integer);
begin
  FB.Bound64.High := AValue;
end;

function TRttiEnumerationType.GetBound: TRttiBound;
begin
  Result.Low := FB.Low;
  Result.High := FB.High;
end;

procedure TRttiEnumerationType.SetBound(const AValue: TRttiBound);
begin
  FB.Bound64.Low := AValue.Low;
  FB.Bound64.High := AValue.High;
end;

function TRttiEnumerationType.DefaultFind(const AName: PShortStringHelper): PRttiEnumerationItem;
label
  failure;
var
  LCount: NativeUInt;
  LOverflowItem: PRttiEnumerationItem;
  LTarget: PAnsiChar;
begin
  LCount := NativeUInt(NativeInt(ItemCount));
  Result := Pointer(Items);
  if (not (Assigned(AName))) or (NativeInt(LCount) <= 0) then
    goto failure;

  LOverflowItem := @PRttiEnumerationItemList(Result)[LCount];
  LCount := PByte(AName)^;
  if (LCount = 0) then
    goto failure;

  repeat
    LTarget := Pointer(Result.Name);
    if (PByte(LTarget)^ = LCount) then
    begin
      if (EqualNames(Pointer(@AName.Value[1]), LTarget + 1, LCount)) then
        Exit;

      LCount := PByte(AName)^;
    end;

    Inc(Result);
  until (Result = LOverflowItem);

failure:
  Result := nil;
end;

function TRttiEnumerationType.Find(const AName: PShortStringHelper): PRttiEnumerationItem;
begin
  if (Assigned(FindFunc)) then
  begin
    Result := FindFunc(@Self, AName);
  end else
  begin
    Result := DefaultFind(AName);
  end;
end;


{ TRttiMetaType }

procedure TRttiMetaType.Init(const AValue: Pointer);
begin
  InitFunc(@Self, AValue);
end;

procedure TRttiMetaType.Final(const AValue: Pointer);
begin
  FinalFunc(@Self, AValue);
end;

procedure TRttiMetaType.WeakFinal(const AValue: Pointer);
begin
  WeakFinalFunc(@Self, AValue);
end;

procedure TRttiMetaType.Copy(const ATarget, ASource: Pointer);
begin
  CopyFunc(@Self, ATarget, ASource);
end;

procedure TRttiMetaType.WeakCopy(const ATarget, ASource: Pointer);
begin
  WeakCopyFunc(@Self, ATarget, ASource);
end;


{ TRttiExType }

{$ifdef HFASUPPORT}
function TRttiExType.GetCalculatedHFA(var AValue: TRttiTypeReturn;
  const AHFA: TRttiHFA{hfaFloat1/hfaDouble1}; const AHFACount, ASize: Integer): Boolean;
begin
  Result := False;

  if (AHFACount >= 1) and (Ord(AHFA){1/2} * SizeOf(Single) * AHFACount = ASize) then
  case AHFA of
    hfaFloat1:
    begin
      Result := (AHFACount <= 4);
    end;
    hfaDouble1:
    begin
      Result := (AHFACount <= {$ifdef CPUARM64}4{$else}2{$endif});
    end;
  end;

  if (Result) then
  begin
    AValue := TRttiTypeReturn(Ord(trFloat1) + (Ord(AHFA) - Ord(hfaFloat1)) + (AHFACount - 1) * 2);
  end;
end;

function TRttiExType.GetCalculatedRecordHFA(var AValue: TRttiTypeReturn;
  const ATypeData: PTypeData): Boolean;
{$ifdef EXTENDEDRTTI}
var
  i: Integer;
  LHFA, LItemHFA: TRttiHFA;
  LHFACount: Integer;
  LAttrData: PAttrData;
  LAttrEntry, LAttrTail: PAttrEntry;
  LAttrSignature: PVmtMethodSignature;
  LAttrFound: Boolean;
  LAttrParam: PVmtMethodParam;
  LAttrReader: TAttrEntryReader;
  LAttrTypeInfo: PTypeInfo;
  LField: PRecordTypeField;
  LRecordFields: PRecordTypeFields;
  LExType: TRttiExType;
  LRulesBuffer: TRttiTypeRules;
{$endif}
begin
  Result := False;

  // attributes
  {$ifdef EXTENDEDRTTI}
  LAttrData := ATypeData.RecordData.GetAttrDataRec;
  LAttrEntry := @LAttrData.Entries;
  LAttrTail := LAttrData.Tail;
  while (LAttrEntry <> LAttrTail) do
  begin
    if (LAttrEntry.ClassType.InheritsFrom(HFAAttribute)) then
    begin
      LAttrSignature := LAttrEntry.ConstructorSignature;
      if (not Assigned(LAttrSignature)) then
      begin
        LAttrFound := True;
      end else
      if (LAttrSignature.ParamCount <> 3) then
      begin
        LAttrFound := False;
      end else
      begin
        LAttrParam := LAttrSignature.Params.Tail;
        LAttrFound := (LAttrParam.ParamType.Value = TypeInfo(Pointer)) and
          (PVmtMethodParam(LAttrParam.Tail).ParamType.Value = TypeInfo(Integer));
      end;

      if (LAttrFound) then
      begin
        LAttrReader := LAttrEntry.Reader;
        LAttrTypeInfo := LAttrReader.ReadPointer;
        if (Assigned(LAttrTypeInfo)) then
        begin
          LAttrTypeInfo := PPointer(LAttrTypeInfo)^;
        end;
        LHFACount := LAttrReader.ReadInteger;
        if (Assigned(LAttrTypeInfo)) and (LAttrTypeInfo.Kind = tkFloat) then
        begin
          case LAttrTypeInfo.TypeData.FloatType of
            ftSingle:
            begin
              Result := GetCalculatedHFA(AValue, hfaFloat1, LHFACount, ATypeData.RecordData.Size);
            end;
            ftDouble:
            begin
              Result := GetCalculatedHFA(AValue, hfaDouble1, LHFACount, ATypeData.RecordData.Size);
            end;
          end;

          if (Result) then
          begin
            Exit;
          end;
        end;
      end;
    end;

    LAttrEntry := LAttrEntry.Tail;
  end;

  // fields
  LRecordFields := ATypeData.RecordData.Fields;
  if (LRecordFields.Count >= 1) and (LRecordFields.Count <= 4) then
  begin
    LField := @LRecordFields.Fields;
    if (not DefaultContext.GetExType(LField.Field.TypeRef.Value, LExType)) then
    begin
      Exit;
    end;
    LHFA := LExType.GetRules(LRulesBuffer).HFA;
    if (LHFA = hfaNone) then
    begin
      Exit;
    end;
    LHFACount := (Ord(LHFA) - Ord(hfaFloat1)) shr 1 + 1;
    LHFA := TRttiHFA(((Ord(LHFA) - Ord(hfaFloat1)) and 1) + 1);

    LField := LField.Tail;
    for i := 0 + 1 to LRecordFields.Count - 1 do
    begin
      if (not DefaultContext.GetExType(LField.Field.TypeRef.Value, LExType)) then
      begin
        Exit;
      end;
      LItemHFA := LExType.GetRules(LRulesBuffer).HFA;
      if (LItemHFA = hfaNone) or (Ord(LItemHFA) and 1 <> Ord(LHFA) and 1) then
      begin
        Exit;
      end;

      Inc(LHFACount, (Ord(LItemHFA) - Ord(hfaFloat1)) shr 1 + 1);
      LField := LField.Tail;
    end;

    Result := GetCalculatedHFA(AValue, LHFA, LHFACount, ATypeData.RecordData.Size);
  end;
  {$endif}
end;

function TRttiExType.GetCalculatedArrayHFA(var AValue: TRttiTypeReturn;
  const ATypeData: PTypeData): Boolean;
var
  LTypeInfo: PTypeInfo;
  LExType: TRttiExType;
  LRulesBuffer: TRttiTypeRules;
  LHFA: TRttiHFA;
  LHFACount: Integer;
begin
  LTypeInfo := ATypeData.ArrayData.ElType.Value;

  if (Assigned(LTypeInfo)) and (DefaultContext.GetExType(LTypeInfo, LExType)) then
  begin
    LHFA := LExType.GetRules(LRulesBuffer).HFA;
    if (LHFA <> hfaNone) then
    begin
      LHFACount := ((Ord(LHFA) - Ord(hfaFloat1)) shr 1 + 1) * ATypeData.ArrayData.ElCount;
      LHFA := TRttiHFA(((Ord(LHFA) - Ord(hfaFloat1)) and 1) + 1);
      Result := GetCalculatedHFA(AValue, LHFA, LHFACount, ATypeData.ArrayData.Size);
      Exit;
    end;
  end;

  Result := False;
end;
{$endif}

function TRttiExType.GetCalculatedRules(var ABuffer: TRttiTypeRules): PRttiTypeRules;
label
  argument_flags;
var
  LTypeData: PTypeData;
  LTypeInfo: PTypeInfo;
  LNullValue: NativeInt;
  LSize: Integer;
begin
  // initialization
  Result := @ABuffer;
  LNullValue := 0;
  PNativeInt(Result)^ := LNullValue;
  {$ifdef SMALLINT}
  PInteger(@Result.Return)^ := LNullValue;
  {$endif}
  PInteger(@Result.FinalFunc)^ := LNullValue;

  // size and flags
  LTypeData := F.TypeData;
  case Self.BaseType of
    rtShortString:
    begin
      LSize := Integer(F.MaxLength) + 1;
      if (F.OpenString) then
      begin
        Result.Flags := RTTI_RULEFLAGS_REFERENCE + [tfVarHigh];
      end else
      begin
        Result.Flags := RTTI_RULEFLAGS_REFERENCE;
      end;
      Result.Size := LSize;
      Result.CopyFunc := RTTI_COPYSHORTSTRING_FUNC;
      Result.WeakCopyFunc := RTTI_COPYSHORTSTRING_FUNC;
      Exit;
    end;
    rtSet:
    begin
      LSize := LTypeData.SetData.Size;
      if (LSize <> INVALID_COUNT) then
      begin
        if (LSize <= SizeOf(NativeInt)) then
        begin
          Result.Return := trGeneral;
        end;

        {$if Defined(MSWINDOWS) and Defined(CPUX64)}
        if (LSize > 4) and (LSize <= 8) then
        begin
          Result.Flags := RTTI_RULEFLAGS_REGGENERAL + [tfOptionalRefArg];
        end else
        {$ifend}
        if (LSize > {$ifdef EXTERNALLINKER}4{$else}SizeOf(NativeInt){$endif}) then
        begin
          Result.Flags := RTTI_RULEFLAGS_REFERENCE;
        end else
        begin
          Result.Flags := RTTI_RULEFLAGS_REGGENERAL;
        end;
      end else
      begin
        LSize := 0;
      end;
    end;
    rtStaticArray:
    begin
      LSize := LTypeData.ArrayData.Size;

      LTypeInfo := LTypeData.ArrayData.ElType.Value;
      if (Assigned(LTypeInfo)) and (IsManaged(LTypeInfo)) then
      begin
        {$ifdef WEAKREF}
        if (HasWeakRef(LTypeInfo)) then
        begin
          Result.Flags := RTTI_RULEFLAGS_REFERENCE + [tfManaged, tfHasWeakRef];
        end else
        {$endif}
        begin
          Result.Flags := RTTI_RULEFLAGS_REFERENCE + [tfManaged];
        end;
      end else
      {$ifdef HFASUPPORT}
      if (GetCalculatedArrayHFA(Result.Return, LTypeData)) then
      begin
        Result.Flags := RTTI_RULEFLAGS_REGEXTENDED {$ifNdef CPUARM64}+ [tfOptionalRefArg]{$endif};
      end else
      {$endif}
      begin
        // return
        case LSize of
          {$if Defined(CPUX86) or Defined(CPUARM32)}
          1, 2, 4
          {$elseif Defined(CPUX64) and Defined(MSWINDOWS)}
          1, 2, 4, 8
          {$else}
          1..8
          {$ifend}
          :
          begin
            Result.Return := trGeneral;
          end;
          {$if Defined(POSIX) and Defined(LARGEINT)}
          9..16:
          begin
            Result.Return := trGeneralPair;
          end;
          {$ifend}
        end;

        goto argument_flags;
      end;
    end;
    rtDynamicArray:
    begin
      LSize := SizeOf(Pointer);
      Result.Flags := RTTI_RULEFLAGS_REGGENERAL + [tfManaged];
    end;
    rtStructure:
    begin
      LSize := LTypeData.RecordData.Size;

      if (LTypeData.RecordData.ManagedFieldCount <> 0) then
      begin
        {$ifdef WEAKREF}
        if (RecordHasWeakRef(LTypeData)) then
        begin
          Result.Flags := RTTI_RULEFLAGS_REFERENCE + [tfManaged, tfHasWeakRef];
        end else
        {$endif}
        begin
          Result.Flags := RTTI_RULEFLAGS_REFERENCE + [tfManaged];
        end;
      end else
      {$ifdef HFASUPPORT}
      if (GetCalculatedRecordHFA(Result.Return, LTypeData)) then
      begin
        Result.Flags := RTTI_RULEFLAGS_REGEXTENDED {$ifNdef CPUARM64}+ [tfOptionalRefArg]{$endif};
      end else
      {$endif}
      begin
        // return
        case LSize of
          {$if Defined(CPUX86)}
          1, 2, 4
          {$elseif Defined(CPUX64) and Defined(MSWINDOWS)}
          1, 2, 4, 8
          {$elseif Defined(ANDROID32)}
          1..4
          {$elseif Defined(IOS32)}
          1
          {$else}
          1..8
          {$ifend}
          :
          begin
            Result.Return := trGeneral;
          end;
          {$if Defined(POSIX) and Defined(LARGEINT)}
          9..16:
          begin
            Result.Return := trGeneralPair;
          end;
          {$ifend}
        end;

      argument_flags:
        // flags
        {$ifdef CPUARM32}
        Result.Flags := RTTI_RULEFLAGS_REGGENERAL + [tfOptionalRefArg];
        {$else}
        case LSize of
          0: {empty stack value};
          {$if Defined(CPUX86)}
          1..SizeOf(Pointer)
          {$elseif Defined(CPUX64) and Defined(MSWINDOWS)}
          1, 2, 4, 8
          {$else}
          1..16
          {$ifend}
          :
          begin
            {$ifdef CPUX64}
            if (LSize > 4) then
            begin
              Result.Flags := RTTI_RULEFLAGS_REGGENERAL + [tfOptionalRefArg];
            end else
            {$endif}
            begin
              Result.Flags := RTTI_RULEFLAGS_REGGENERAL;
            end;
          end;
        else
          Result.Flags := RTTI_RULEFLAGS_REFERENCE;
        end;
        {$endif}
      end;
    end;
  else
    TinyError(teAccessViolation);
    Exit;
  end;

  // options
  Result.Size := LSize;
  if (tfManaged in Result.Flags) then
  begin
    // initialization
    if (LSize > RTTI_INITBYTES_MAXCOUNT) then
    begin
      if (Self.BaseType = rtStaticArray) then
      begin
        Result.InitFunc := RTTI_INITFULLSTATICARRAY_FUNC;
      end else
      begin
        Result.InitFunc := RTTI_INITFULLSTRUCTURE_FUNC;
      end;
    end else
    case LSize of
      SizeOf(NativeInt):
      begin
        Result.InitFunc := RTTI_INITPOINTER_FUNC;
      end;
      SizeOf(NativeInt) * 2:
      begin
        Result.InitFunc := RTTI_INITPOINTERPAIR_FUNC
      end;
    else
      Result.InitFunc := RTTI_INITBYTES_LOWFUNC + LSize;
    end;

    // finalization/coping
    case Self.BaseType of
      rtStaticArray:
      begin
        Result.FinalFunc := RTTI_FINALFULLSTATICARRAY_FUNC;
        Result.CopyFunc := RTTI_COPYFULLSTATICARRAY_FUNC;
      end;
      rtDynamicArray:
      begin
        if (LTypeData.DynArrayData.elType.Assigned) then
        begin
          Result.FinalFunc := RTTI_FINALFULLDYNARRAY_FUNC;
          Result.CopyFunc := RTTI_COPYFULLDYNARRAY_FUNC;
        end else
        begin
          Result.FinalFunc := RTTI_FINALDYNARRAY_FUNC;
          Result.CopyFunc := RTTI_COPYDYNARRAY_FUNC;
        end;
      end;
    else
      // rtStructure
      Result.FinalFunc := RTTI_FINALFULLSTRUCTURE_FUNC;
      Result.CopyFunc := RTTI_COPYFULLSTRUCTURE_FUNC;
    end;
    Result.WeakFinalFunc := Result.FinalFunc;
    Result.WeakCopyFunc := Result.CopyFunc;
  end else
  case LSize of
    0..3, 5..7, 9..RTTI_COPYBYTES_MAXCOUNT:
    begin
      Result.CopyFunc := RTTI_COPYBYTES_LOWFUNC + LSize;
    end;
    4:
    begin
      Result.CopyFunc := RTTI_COPYBYTES_CARDINAL;
    end;
    8:
    begin
      Result.CopyFunc := RTTI_COPYBYTES_INT64;
    end;
  else
    if (Self.BaseType = rtStaticArray) then
    begin
      Result.CopyFunc := RTTI_COPYSTATICARRAY_FUNC;
    end else
    begin
      Result.CopyFunc := RTTI_COPYSTRUCTURE_FUNC;
    end;
  end;
  Result.WeakCopyFunc := Result.CopyFunc;
end;

function TRttiExType.GetRules(var ABuffer: TRttiTypeRules): PRttiTypeRules;
var
  LOptions: NativeUInt;
begin
  LOptions := F.Options;
  if (LOptions and $ff00{PointerDepth} = 0) then
  begin
    Result := RTTI_TYPE_RULES[TRttiType(LOptions)];
    if (not Assigned(Result)) then
    begin
      Result := F.CustomData;
      if (Assigned(Result)) and
        (PCardinal(Result)^ and RTTI_TYPEDATA_MASK = RTTI_TYPEDATA_MARKER) then
      begin
        // @PRttiMetaType(Result).Rules
        Inc(NativeUInt(Result), SizeOf(TRttiTypeData));
      end else
      begin
        Result := GetCalculatedRules(ABuffer);
      end;
    end;
  end else
  begin
    // rtPointer
    Result := @RTTI_RULES_NATIVE;
  end;
end;

function TRttiExType.GetRules: PRttiTypeRules;
var
  LOptions: NativeUInt;
begin
  LOptions := F.Options;
  if (LOptions and $ff00{PointerDepth} = 0) then
  begin
    Result := RTTI_TYPE_RULES[TRttiType(LOptions)];
    if (not Assigned(Result)) then
    begin
      Result := F.CustomData;
      if (Assigned(Result)) and
        (PCardinal(Result)^ and RTTI_TYPEDATA_MASK = RTTI_TYPEDATA_MARKER) then
      begin
        // @PRttiMetaType(Result).Rules
        Inc(NativeUInt(Result), SizeOf(TRttiTypeData));
      end else
      begin
        Result := nil;
      end;
    end;
  end else
  begin
    // rtPointer
    Result := @RTTI_RULES_NATIVE;
  end;
end;


{ TRttiExType<T> }

{$ifdef GENERICSUPPORT}
class constructor TRttiExType<T>.ClassCreate;
begin
  if (not Assigned(DefaultContext.Vmt)) then
  begin
    DefaultContext.Init;
  end;

  if Assigned(TypeInfo(T)) and (DefaultContext.GetExType(TypeInfo(T), Default)) then
  begin
    if (Default.PointerDepth = 0) then
    begin
      DefaultSimplified := Default;
    end else
    begin
      DefaultSimplified.Options := Ord(rtPointer);
      DefaultSimplified.CustomData := nil;
    end;

    DefaultRules := Default.GetRules(DefaultRules)^;
  end;
end;
{$endif}


{ TRttiContextVmt }

class procedure TRttiContextVmt.Init(const AContext: PRttiContext);
begin
end;

class procedure  TRttiContextVmt.Finalize(const AContext: PRttiContext);
begin
end;

class function TRttiContextVmt.Alloc(const AContext: PRttiContext; const ASize: Integer): Pointer;
begin
  if (GetCurrentThreadId = MainThreadID) then
  begin
    Result := TinyAllocAligned(ASize);
  end else
  begin
    Result := AContext.HeapAlloc(ASize);
  end;
end;

class function TRttiContextVmt.AllocPacked(const AContext: PRttiContext; const ASize: Integer): Pointer;
begin
  if (GetCurrentThreadId = MainThreadID) then
  begin
    Result := TinyAllocPacked(ASize);
  end else
  begin
    Result := AContext.HeapAlloc(ASize);
  end;
end;


{ TRttiContext }

procedure TRttiContext.EnterRead;
var
  LLocker: PSyncLocker;
begin
  if (FThreadSync) then
  begin
    LLocker := Pointer(NativeInt(@FAlignedData[SizeOf(NativeInt) * 2 - 1]) and -SizeOf(NativeInt));
    LLocker.EnterRead;
  end;
end;

procedure TRttiContext.EnterExclusive;
var
  LLocker: PSyncLocker;
begin
  if (FThreadSync) then
  begin
    LLocker := Pointer(NativeInt(@FAlignedData[SizeOf(NativeInt) * 2 - 1]) and -SizeOf(NativeInt));
    LLocker.EnterExclusive;
  end;
end;

procedure TRttiContext.LeaveRead;
var
  LLocker: PSyncLocker;
begin
  if (FThreadSync) then
  begin
    LLocker := Pointer(NativeInt(@FAlignedData[SizeOf(NativeInt) * 2 - 1]) and -SizeOf(NativeInt));
    LLocker.LeaveRead;
  end;
end;

procedure TRttiContext.LeaveExclusive;
var
  LLocker: PSyncLocker;
begin
  if (FThreadSync) then
  begin
    LLocker := Pointer(NativeInt(@FAlignedData[SizeOf(NativeInt) * 2 - 1]) and -SizeOf(NativeInt));
    LLocker.LeaveExclusive;
  end;
end;

procedure TRttiContext.Init(const AVmt: TRttiContextVmtClass; const AThreadSync: Boolean);
begin
  // class constructor usage case
  if (not LibraryInitialized) then
  begin
    InitLibrary;
  end;

  // clearing
  FillChar(Self, SizeOf(Self), #0);
  Self.ThreadSync := AThreadSync;

  // Vmt
  FVmt := AVmt;
  if (not Assigned(AVmt)) then
  begin
    FVmt := TRttiContextVmt;
  end;
  FVmt.Init(@Self);
end;

procedure TRttiContext.Finalize;
var
  LHeapItemsPtr: PPointer;
  LItem, LNext: Pointer;
begin
  try
    FVmt.Finalize(@Self);
  finally
    LHeapItemsPtr := Pointer(NativeInt(@FAlignedData[SizeOf(NativeInt) - 1]) and -SizeOf(NativeInt));
    LItem := LHeapItemsPtr^;
    LHeapItemsPtr^ := nil;

    while (Assigned(LItem)) do
    begin
      LNext := PPointer(LItem)^;
      FreeMem(LItem);

      LItem := LNext;
    end;
  end;
end;

function TRttiContext.Alloc(const ASize: Integer): Pointer;
begin
  if (FHeapAllocation) then
  begin
    Result := HeapAlloc(ASize);
  end else
  begin
    Result := FVmt.Alloc(@Self, ASize);
  end;
end;

function TRttiContext.AllocPacked(const ASize: Integer): Pointer;
begin
  if (FHeapAllocation) then
  begin
    Result := HeapAlloc(ASize);
  end else
  begin
    Result := FVmt.AllocPacked(@Self, ASize);
  end;
end;

function TRttiContext.HeapAlloc(const ASize: Integer): Pointer;
const
  OVERHEAD_SIZE = 8;
var
  LHeapSize: Integer;
  LHeapItemsPtr: PPointer;
  LHeapItems: Pointer;
begin
  LHeapSize := ASize + OVERHEAD_SIZE;
  if (ASize <= 0) or (LHeapSize <= 0) then
  begin
    Result := nil;
    Exit;
  end;

  GetMem(Result, LHeapSize);
  LHeapItemsPtr := Pointer(NativeInt(@FAlignedData[SizeOf(NativeInt) - 1]) and -SizeOf(NativeInt));
  if (FThreadSync) then
  begin
    repeat
      LHeapItems := LHeapItemsPtr^;
      PPointer(Result)^ := LHeapItems;
    until (AtomicCmpExchange(LHeapItemsPtr^, Result, LHeapItems) = LHeapItems);
  end else
  begin
    PPointer(Result)^ := LHeapItemsPtr^;
    LHeapItemsPtr^ := Result;
  end;

  Inc(NativeUInt(Result), OVERHEAD_SIZE);
end;

function TRttiContext.AllocCustomTypeData(const ASize: Integer; const ABacketCount: Integer): PRttiCustomTypeData;
var
  LSize: Integer;
  LBacketSize: Integer;
begin
  LBacketSize := ABacketCount * SizeOf(Pointer);
  LSize := ASize + LBacketSize;

  Result := Alloc(LSize);
  FillChar(Result^, LSize, #0);

  Inc(NativeInt(Result), LBacketSize);
end;

function TRttiContext.AllocTypeData(const ABaseType: TRttiType; const ASize: Integer;
  const AName: PShortStringHelper; const ABacketCount: Integer): PRttiTypeData;
begin
  Result := Pointer(AllocCustomTypeData(ASize, ABacketCount));
  Result.F.Marker := RTTI_TYPEDATA_MARKER;
  Result.F.BaseType := ABaseType;
  Result.FContext := @Self;
  Result.Name := AName;
end;

function TRttiContext.AllocMetaType(const ABaseType: TRttiType;
  const AName: PShortStringHelper): PRttiMetaType;
const
  NULL_BACKET: Integer = 0;
var
  LSize: Integer;
  LBacketPtr: PInteger;
  LBacketCount: Integer;
begin
  case ABaseType of
    rtSet: LSize := SizeOf(TRttiSetType);
    rtStaticArray: LSize := SizeOf(TRttiStaticArrayType);
    rtDynamicArray: LSize := SizeOf(TRttiDynamicArrayType);
    rtStructure: LSize := SizeOf(TRttiStructureType);
    rtObject: LSize := SizeOf(TRttiClassType);
    rtInterface: LSize := SizeOf(TRttiInterfaceType);
  else
    TinyError(teInvalidCast);
    Result := nil;
    Exit;
  end;

  LBacketPtr := @NULL_BACKET{ToDo};
  LBacketCount := LBacketPtr^;

  Result := Pointer(AllocTypeData(ABaseType, LSize, AName, LBacketCount));
end;

function TRttiContext.GetBaseTypeInfo(const ATypeInfo: PTypeInfo;
  const ATypeInfoList: array of PTypeInfo): Integer;
var
  LCount: NativeUInt;
  LSource, LTarget: PByte;
  LTypeInfo, LValue: PTypeInfo;
  LTypeData: PTypeData;
  LBase: PTypeInfo;
begin
  LTypeInfo := ATypeInfo;

  repeat
    for Result := Low(ATypeInfoList) to High(ATypeInfoList) do
    begin
      LValue := ATypeInfoList[Result];
      if (LTypeInfo = LValue) then
        Exit;

      LSource := Pointer(@LTypeInfo.Name);
      LTarget := Pointer(@LValue.Name);
      if (LSource^ = LTarget^) then
      begin
        LCount := LSource^;
        Inc(LSource);
        Inc(LTarget);
        repeat
          if (LCount = 0) then
            Exit;
          Dec(LCount);
        until (LSource^ or $20 <> LTarget^ or $20);
      end;
    end;

    case LTypeInfo.Kind of
      tkInteger,
      tkChar,
      tkEnumeration,
      tkWChar: ;
    else
      Break;
    end;

    LTypeData := LTypeInfo.TypeData;
    LBase := LTypeData.BaseType.Value;
    if (LTypeInfo = LBase) or (not Assigned(LBase)) then
    begin
      Break;
    end;

    LTypeInfo := LBase;
  until (False);

  Result := INVALID_INDEX;
end;

function TRttiContext.GetBooleanType(const ATypeInfo: PTypeInfo): TRttiType;
const
  _bool = Cardinal(Ord('b') + Ord('o') shl 8 + Ord('o') shl 16 + Ord('l') shl 24);
var
  LTypeInfo: PTypeInfo;
  LTypeData: PTypeData;
  LBase: PTypeInfo;
  LPtr: PByte;
begin
  Result := rtUnknown;
  if (not Assigned(ATypeInfo)) or (ATypeInfo.Kind <> {$ifdef FPC}tkInteger{$else}tkEnumeration{$endif}) then
  begin
    {$ifdef FPC}
    if (Assigned(ATypeInfo)) and (ATypeInfo.Kind = tkBool) then
    begin
      Result := rtBoolean8;
    end;
    {$endif}
    Exit;
  end;

  LTypeInfo := ATypeInfo;
  repeat
    LTypeData := LTypeInfo.TypeData;
    LBase := LTypeData.BaseType.Value;
    if (LTypeInfo = LBase) or (not Assigned(LBase)) then
    begin
      Break;
    end;

    LTypeInfo := LBase;
  until (False);

  if (LTypeInfo = System.TypeInfo(Boolean)) then
  begin
    Result := rtBoolean8;
  end else
  if (LTypeInfo = System.TypeInfo(ByteBool)) then
  begin
    Result := rtBool8;
  end else
  if (LTypeInfo = System.TypeInfo(WordBool)) then
  begin
    Result := rtBool16;
  end else
  if (LTypeInfo = System.TypeInfo(LongBool)) then
  begin
    Result := rtBool32;
  end else
  {$ifdef FPC}
  if (LTypeInfo = System.TypeInfo(Boolean16)) then
  begin
    Result := rtBoolean16;
  end else
  if (LTypeInfo = System.TypeInfo(Boolean32)) then
  begin
    Result := rtBoolean32;
  end else
  if (LTypeInfo = System.TypeInfo(Boolean64)) then
  begin
    Result := rtBoolean64;
  end else
  if (LTypeInfo = System.TypeInfo(QWordBool)) then
  begin
    Result := rtBool64;
  end else
  {$endif}
  begin
    LTypeData := GetTypeData(LTypeInfo);
    if (LTypeData.MinValue = 0) and (LTypeData.MaxValue = 1) then
    begin
      LPtr := Pointer(@LTypeInfo.Name);
      if (LPtr^ <> 4) then Exit;
      Inc(LPtr);
      if (PCardinal(LPtr)^ <> _bool) then Exit;

      Result := rtBoolean8;
    end;
  end;
end;

function TRttiContext.GetType(const ATypeInfo: Pointer): TRttiType;
var
  LExType: TRttiExType;
begin
  if (not GetExType(ATypeInfo, LExType)) then
  begin
    Result := rtUnknown;
  end else
  if (LExType.PointerDepth <> 0) then
  begin
    Result := rtPointer;
  end else
  begin
    Result := LExType.BaseType;
  end;
end;

function TRttiContext.GetExType(const ATypeInfo: Pointer; var AResult: TRttiExType): Boolean;
label
  detect_base_type, fix_pchars, fix_ansi_codepage, fix_chars_range,
  copy_type_data, post_processing;
const
  _OleV = Cardinal(Ord('O') + Ord('l') shl 8 + Ord('e') shl 16 + Ord('V') shl 24);
  _aria = Cardinal(Ord('a') + Ord('r') shl 8 + Ord('i') shl 16 + Ord('a') shl 24);
  _nt = Word(Ord('n') + Ord('t') shl 8);
  _stri = Cardinal(Ord('s') + Ord('t') shl 8 + Ord('r') shl 16 + Ord('i') shl 24);
  _ng = Word(Ord('n') + Ord('g') shl 8);
var
  LTypeInfo: PTypeInfo;
  LTypeData: PTypeData;
  LRttiTypeData: PRttiTypeData;
  LPtr: PByte;
  {$ifNdef SHORTSTRSUPPORT}
  LCount: NativeUInt;
  {$endif}
begin
  AResult.Options := 0;
  AResult.CustomData := nil;

  if (NativeUInt(ATypeInfo) <= High(Word)) then
  begin
    TinyError(teInvalidPtr);
    Result := False;
    Exit;
  end;

  if (NativeUInt(ATypeInfo) >= DUMMY_TYPEINFO_BASE) then
  begin
    AResult.PointerDepth := (NativeUInt(ATypeInfo) shr 24) and $0f;
    AResult.BaseType := TRttiType(Byte(NativeUInt(ATypeInfo) shr 16));
    AResult.Id := Word(NativeUInt(ATypeInfo));

    case AResult.BaseType of
      rtInt8: AResult.RangeData := @INT8_TYPE_DATA;
      rtUInt8: AResult.RangeData := @UINT8_TYPE_DATA;
      rtInt16: AResult.RangeData := @INT16_TYPE_DATA;
      rtUInt16: AResult.RangeData := @UINT16_TYPE_DATA;
      rtInt32: AResult.RangeData := @INT32_TYPE_DATA;
      rtUInt32: AResult.RangeData := @UINT32_TYPE_DATA;
      rtInt64: AResult.RangeData := @INT64_TYPE_DATA;
      rtUInt64: AResult.RangeData := @UINT64_TYPE_DATA;
      rtSBCSChar,
      rtUTF8Char,
      rtPSBCSChars,
      rtPUTF8Chars,
      rtSBCSString,
      rtUTF8String,
      rtWideChar,
      rtPWideChars,
      rtWideString,
      rtUnicodeString,
      rtUCS4Char,
      rtPUCS4Chars,
      rtUCS4String:
      begin
        LTypeData := nil;
        goto fix_ansi_codepage;
      end;
    end;
  end else
  if (PCardinal(ATypeInfo)^ and RTTI_TYPEDATA_MASK = RTTI_TYPEDATA_MARKER) then
  begin
    LRttiTypeData := PRttiTypeData(ATypeInfo);
    if (LRttiTypeData.Context <> @Self) then
    begin
      {
        Note:
        Type data created in another context
      }
      TinyError(teInvalidCast);
      Result := False;
      Exit;
    end;

    AResult.BaseType := LRttiTypeData.BaseType;
    AResult.RttiTypeData := LRttiTypeData;
  end else
  begin
    LTypeInfo := ATypeInfo;
  detect_base_type:
    if (LTypeInfo.Kind in [{$ifdef FPC}tkInteger, tkBool{$else}tkEnumeration{$endif}]) then
    begin
      AResult.BaseType := GetBooleanType(LTypeInfo);
    end;
    if (AResult.BaseType = rtUnknown) then
    begin
      LTypeData := LTypeInfo.GetTypeData;

      case LTypeInfo.Kind of
        tkInteger:
        begin
          case LTypeData.OrdType of
            otSByte: AResult.BaseType := rtInt8;
            otSWord: AResult.BaseType := rtInt16;
            otUWord: AResult.BaseType := rtUInt16;
            otSLong: AResult.BaseType := rtInt32;
            otULong:
            begin
              if (GetBaseTypeInfo(LTypeInfo, [TypeInfo(UCS4Char)]) = 0) then
              begin
                AResult.BaseType := rtUCS4Char;
                goto fix_pchars;
              end else
              begin
                AResult.BaseType := rtUInt32;
              end;
            end;
          else
            // otUByte
            AResult.BaseType := rtUInt8;
            {$ifNdef ANSISTRSUPPORT}
            case GetBaseTypeInfo(LTypeInfo, [TypeInfo(AnsiChar), TypeInfo(UTF8Char)]) of
              0:
              begin
                AResult.BaseType := rtSBCSChar;
                goto fix_pchars;
              end;
              1:
              begin
                AResult.BaseType := rtUTF8Char;
                goto fix_pchars;
              end;
            end;
            {$endif}
          end;
          goto copy_type_data;
        end;
        {$ifdef FPC}
        tkQWord:
        begin
          AResult.BaseType := rtUInt64;
          goto copy_type_data;
        end;
        {$endif}
        tkInt64:
        begin
          if (GetBaseTypeInfo(LTypeInfo, [TypeInfo(TimeStamp)]) = 0) then
          begin
            AResult.BaseType := rtTimeStamp;
          end else
          if LTypeData.MinInt64Value > LTypeData.MaxInt64Value then
          begin
            AResult.BaseType := rtUInt64;
            goto copy_type_data;
          end else
          begin
            AResult.BaseType := rtInt64;
            goto copy_type_data;
          end;
        end;
        tkEnumeration:
        begin
          case LTypeData.OrdType of
            otSByte, otUByte: AResult.BaseType := rtEnumeration8;
            otSWord, otUWord: AResult.BaseType := rtEnumeration16;
          else
            // otSLong, otULong:
            AResult.BaseType := rtEnumeration32;
          end;
          goto copy_type_data;
        end;
        tkFloat:
        begin
          case LTypeData.FloatType of
            ftSingle: AResult.BaseType := rtFloat;
            ftComp: AResult.BaseType := rtComp;
            ftCurr: AResult.BaseType := rtCurrency;
            ftExtended:
            begin
              case SizeOf(Extended) of
                10: AResult.BaseType := rtLongDouble80;
                12: AResult.BaseType := rtLongDouble96;
                16: AResult.BaseType := rtLongDouble128;
              else
                AResult.BaseType := rtDouble;
              end;
            end;
          else
            // ftDouble
            AResult.BaseType := rtDouble;
            case GetBaseTypeInfo(LTypeInfo, [TypeInfo(TDate), TypeInfo(TTime), TypeInfo(TDateTime)]) of
              0: AResult.BaseType := rtDate;
              1: AResult.BaseType := rtTime;
              2: AResult.BaseType := rtDateTime;
            end;
          end;
        end;
        tkChar:
        begin
          AResult.BaseType := rtSBCSChar;
          goto fix_pchars;
        end;
        tkWChar:
        begin
          AResult.BaseType := rtWideChar;
          goto fix_pchars;
        end;
        tkString:
        begin
          AResult.BaseType := rtShortString;
          AResult.MaxLength := LTypeData.MaxLength;
          {$ifdef SHORTSTRSUPPORT}
          AResult.OpenString := (LTypeInfo = TypeInfo(ShortString));
          {$endif}
        end;
        {$ifdef FPC}tkAString,{$endif}
        tkLString:
        begin
          AResult.BaseType := rtSBCSString;
          {$ifdef INTERNALCODEPAGE}
            AResult.CodePage := LTypeData.CodePage;
          {$else}
            case GetBaseTypeInfo(LTypeInfo, [TypeInfo(UTF8String), TypeInfo(RawByteString)]) of
              0:
              begin
                AResult.BaseType := rtUTF8String;
              end;
              1:
              begin
                AResult.BaseType := rtSBCSString;
                AResult.CodePage := $ffff;
              end;
            end;
          {$endif}
          LTypeData := nil;
          goto fix_ansi_codepage;
        end;
        {$ifdef UNICODE}
        tkUString:
        begin
          AResult.BaseType := rtUnicodeString;
          LTypeData := nil;
          goto fix_chars_range;
        end;
        {$endif}
        tkWString:
        begin
          AResult.BaseType := rtWideString;
          LTypeData := nil;
          goto fix_chars_range;
        end;
        tkClass:
        begin
          AResult.BaseType := rtObject;
          goto copy_type_data;
        end;
        tkVariant:
        begin
          AResult.BaseType := rtVariant;

          LPtr := Pointer(@LTypeInfo.Name);
          if (LPtr^ <> 10) then goto post_processing;
          Inc(LPtr);
          if (PCardinal(LPtr)^ <> _OleV) then goto post_processing;
          Inc(LPtr, SizeOf(Cardinal));
          if (PCardinal(LPtr)^ <> _aria) then goto post_processing;
          Inc(LPtr, SizeOf(Cardinal));
          if (PWord(LPtr)^ <> _nt) then goto post_processing;

          AResult.BaseType := rtOleVariant;
          goto post_processing;
        end;
        {$if Defined(FPC) or Defined(EXTENDEDRTTI)}
        tkPointer:
        begin
          repeat
            AResult.PointerDepth := AResult.PointerDepth + 1;
            LTypeInfo := LTypeInfo.TypeData.RefType.Value;
            if (not Assigned(LTypeInfo)) or (LTypeInfo.Kind <> tkPointer) then
              Break;
          until (False);

          if (not Assigned(LTypeInfo)) then
          begin
            AResult.PointerDepth := AResult.PointerDepth - 1;
            AResult.BaseType := rtPointer;
          end else
          begin
            goto detect_base_type;
          end;
        end;
        tkClassRef:
        begin
          AResult.BaseType := rtClassRef;
          goto copy_type_data;
        end;
        tkProcedure{/tkProcVar}:
        begin
          AResult.BaseType := rtFunction;
          goto copy_type_data;
        end;
        {$ifend}
        tkSet:
        begin
          AResult.BaseType := rtSet;
          {$if not Defined(FPC) and (CompilerVersion >= 32)}
            // internal size and adjustment
          {$else}
            // dynamically calculated size and adjustment
            if (not LTypeData.SetData.CompType.Assigned) then
            begin
              LTypeData := nil;
            end;
          {$ifend}
          goto copy_type_data;
        end;
        tkRecord{$ifdef FPC}, tkObject{$endif}{$ifdef MANAGEDRECORDS}, tkMRecord{$endif}:
        begin
          if (LTypeInfo = TypeInfo(TValue)) then
          begin
            AResult.BaseType := rtValue;
            goto post_processing;
          end;

          AResult.BaseType := rtStructure;
          goto copy_type_data;
        end;
        tkArray:
        begin
          AResult.BaseType := rtStaticArray;

          {$ifNdef SHORTSTRSUPPORT}
          if (LTypeData.ArrayData.Size = LTypeData.ArrayData.ElCount) then
          case LTypeData.ArrayData.Size of
            1..256:
            begin
              if (LTypeData.ArrayData.ElType.Assigned) and
                (GetBaseTypeInfo(LTypeData.ArrayData.ElType.Value, [TypeInfo(AnsiChar), TypeInfo(UTF8Char)]) >= 0) then
              begin
                LCount := NativeUInt(LTypeData.ArrayData.Size - 1);

                if (LCount <> 255) or (GetBaseTypeInfo(LTypeInfo, [TypeInfo(ShortString)]) < 0) then
                begin
                  // check stringN case
                  LPtr := Pointer(@LTypeInfo.Name);
                  case LCount of
                    0..9:
                    begin
                      if (LPtr^ <> 6 + 1) then goto copy_type_data;
                    end;
                    10..99:
                    begin
                      if (LPtr^ <> 6 + 2) then goto copy_type_data;
                    end;
                  else
                    if (LPtr^ <> 6 + 3) then goto copy_type_data;
                  end;

                  Inc(LPtr);
                  if (PCardinal(LPtr)^ or $20202020 <> _stri) then goto copy_type_data;
                  Inc(LPtr, SizeOf(Cardinal));
                  if (PWord(LPtr)^ or $2020 <> _ng) then goto copy_type_data;
                  Inc(LPtr, SizeOf(Word));

                  if (LCount > 9) then
                  begin
                    if (LCount > 99) then
                    begin
                      if (LPtr^ <> (LCount div 100) + Ord('0')) then goto copy_type_data;
                      Inc(LPtr);
                    end;

                    if (LPtr^ <> ((LCount div 10) mod 10) + Ord('0')) then goto copy_type_data;
                    Inc(LPtr);
                  end;

                  if (LPtr^ <> (LCount mod 10) + Ord('0')) then goto copy_type_data;
                end;

                // ShortString
                AResult.BaseType := rtShortString;
                AResult.MaxLength := LCount;
                LTypeData := nil;
              end;
            end;
          end;
          {$endif}

          goto copy_type_data;
        end;
        tkDynArray:
        begin
          case GetBaseTypeInfo(LTypeInfo, [TypeInfo(TBytes), TypeInfo(UCS4String)
            {$ifNdef WIDESTRSUPPORT}
            , TypeInfo(WideString)
            {$endif}
            {$ifNdef ANSISTRSUPPORT}
            , TypeInfo(AnsiString), TypeInfo(UTF8String), TypeInfo(RawByteString)
            {$endif}
            ]) of
            0: AResult.BaseType := rtBytes;
            1:
            begin
              AResult.BaseType := rtUCS4String;
              LTypeData := nil;
              goto fix_chars_range;
            end;
            {$ifNdef WIDESTRSUPPORT}
            2:
            begin
              AResult.BaseType := rtWideString;
              LTypeData := nil;
              goto fix_chars_range;
            end;
            {$endif !WIDESTRSUPPORT}
            {$ifNdef ANSISTRSUPPORT}
            {$ifNdef WIDESTRSUPPORT}2{$else}1{$endif} + 1:
            begin
              AResult.BaseType := rtSBCSString;
              LTypeData := nil;
              goto fix_ansi_codepage;
            end;
            {$ifNdef WIDESTRSUPPORT}2{$else}1{$endif} + 2:
            begin
              AResult.BaseType := rtUTF8String;
              LTypeData := nil;
              goto fix_ansi_codepage;
            end;
            {$ifNdef WIDESTRSUPPORT}2{$else}1{$endif} + 3:
            begin
              AResult.BaseType := rtSBCSString;
              AResult.CodePage := $ffff;
              LTypeData := nil;
              goto fix_ansi_codepage;
            end;
            {$endif !ANSISTRSUPPORT}
          else
            AResult.BaseType := rtDynamicArray;
            goto copy_type_data;
          end;
        end;
        tkInterface:
        begin
          {$ifdef EXTENDEDRTTI}
          if (IsClosureTypeData(LTypeData)) then
          begin
            AResult.BaseType := rtClosure;
          end else
          {$endif}
          begin
            AResult.BaseType := rtInterface;
          end;
          goto copy_type_data;
        end;
        tkMethod:
        begin
          AResult.BaseType := rtMethod;
          goto copy_type_data;
        end;
      else
        Result := False;
        Exit;

      fix_pchars:
        if (AResult.BaseType in [rtSBCSChar..rtUCS4Char]) and (AResult.PointerDepth <> 0) then
        begin
          Inc(Byte(AResult.F.BaseType), Ord(rtPSBCSChars) - Ord(rtSBCSChar));
          AResult.PointerDepth := AResult.PointerDepth - 1;
        end;

      fix_ansi_codepage:
        case AResult.BaseType of
          rtSBCSChar, rtPSBCSChars, rtSBCSString:
          begin
            case AResult.CodePage of
              0:
              begin
                AResult.CodePage := DefaultCP;
              end;
              CP_UTF8:
              begin
                AResult.BaseType := Succ(AResult.BaseType);
                AResult.CodePage := 0;
              end;
            end;
          end;
          rtUTF8Char, rtPUTF8Chars, rtUTF8String:
          begin
            AResult.CodePage := 0;
          end;
        end;

      fix_chars_range:
        if (not Assigned(LTypeData)) then
        case AResult.BaseType of
          rtSBCSChar,
          rtUTF8Char,
          rtPSBCSChars,
          rtPUTF8Chars,
          rtSBCSString,
          rtUTF8String:
          begin
            LTypeData := Pointer(@UINT8_TYPE_DATA);
          end;
          rtWideChar,
          rtPWideChars,
          rtWideString,
          rtUnicodeString:
          begin
            LTypeData := Pointer(@UINT16_TYPE_DATA);
          end;
          rtUCS4Char,
          rtPUCS4Chars,
          rtUCS4String:
          begin
            LTypeData := Pointer(@UINT32_TYPE_DATA);
          end;
        end;

      copy_type_data:
        AResult.TypeData := LTypeData;
      end;
    end;
  end;


post_processing:
  // post processing
  // ToDo

  Result := True;
end;

function TRttiContext.GetExType(const ATypeInfo: Pointer;
  const ATypeName: PShortStringHelper; var AResult: TRttiExType): Boolean;
begin
  Result := Assigned(ATypeInfo) and (GetExType(ATypeInfo, AResult));

  if (not Result) and (Assigned(ATypeName)) then
  begin
    // ToDo
  end;
end;


{ TRttiBufferVmt }

class procedure TRttiBufferVmt.Init(const ABuffer: PTinyBuffer; const AResetMode: Boolean);
var
  LBuffer: PRttiBuffer;
  LNull: Pointer;
begin
  LBuffer := Pointer(ABuffer);

  LNull := nil;
  LBuffer.{$ifdef BCB}This.{$endif}Current := LNull;
  LBuffer.{$ifdef BCB}This.{$endif}Overflow := LNull;
  if (not AResetMode) then
  begin
    LBuffer.FHeapBlocks := LNull;
    LBuffer.FManagedItems := LNull;
    LBuffer.{$ifdef BCB}This.{$endif}FVmt := Self;
  end else
  if (Assigned(LBuffer.FHeapBlocks)) then
  begin
    LBuffer.InternalClear;
  end;
end;

class procedure TRttiBufferVmt.Clear(const ABuffer: PTinyBuffer);
var
  LBuffer: PRttiBuffer;
  LNull: Pointer;
begin
  LBuffer := Pointer(ABuffer);

  LNull := nil;
  LBuffer.{$ifdef BCB}This.{$endif}Current := LNull;
  LBuffer.{$ifdef BCB}This.{$endif}Overflow := LNull;
  if (Assigned(LBuffer.FHeapBlocks)) then
  begin
    LBuffer.InternalClear;
  end else
  begin
    LBuffer.FHeapBlocks := LNull;
    LBuffer.FManagedItems := LNull;
  end;
end;

class function TRttiBufferVmt.Grow(const ABuffer: PTinyBuffer; const ASize: NativeUInt;
  const AAlign: NativeUInt): Pointer;
const
  BLOCK_SIZE = 256;
var
  LBuffer: PRttiBuffer;
  LAlign: NativeInt;
  LReserveSize: NativeUInt;
  P: PByte;
begin
  LBuffer := Pointer(ABuffer);
  LAlign := NativeInt(AAlign) - 1;
  LReserveSize := ASize + NativeUInt(LAlign);

  if (LReserveSize < BLOCK_SIZE) then
  begin
    LReserveSize := BLOCK_SIZE;
  end;

  GetMem(P, SizeOf(Pointer) + LReserveSize);
  PPointer(P)^ := LBuffer.FHeapBlocks;
  LBuffer.FHeapBlocks := P;
  Inc(P, SizeOf(Pointer));

  LBuffer.{$ifdef BCB}This.{$endif}Overflow := Pointer(NativeUInt(P) + LReserveSize);
  P := Pointer((NativeInt(P) + LAlign) and (not LAlign) + NativeInt(ASize));
  LBuffer.{$ifdef BCB}This.{$endif}Current := P;

  Dec(P, ASize);
  Result := P;
end;

{ TRttiBuffer }

type
  PRttiBufferItem = ^TRttiBufferItem;
  TRttiBufferItem = packed record
    Next: PRttiBufferItem;
    { managed value }
    FinalFunc: TRttiTypeFunc;
    {$ifdef LARGEINT}
    _Padding: Integer;
    {$endif}
    ExType: TRttiExType;
    Value: packed record end;
  end;

procedure TRttiBuffer.InternalClear;
var
  LItem, LNext: PRttiBufferItem;
begin
  // managed values
  LItem := FManagedItems;
  FManagedItems := nil;
  while (Assigned(LItem)) do
  begin
    LItem.FinalFunc(@LItem.ExType, @LItem.Value);
    LItem := LItem.Next;
  end;

  // heap items
  LItem := FHeapBlocks;
  FHeapBlocks := nil;
  while (Assigned(LItem)) do
  begin
    LNext := LItem.Next;
    FreeMem(LItem);

    LItem := LNext;
  end;
end;

procedure TRttiBuffer.Init(const AFragmentMemory: Pointer; const AFragmentSize: NativeUInt);
var
  LNull: Pointer;
begin
  with PRttiBuffer(@Self)^ do
  begin
    {$ifdef BCB}This.{$endif}Current := AFragmentMemory;
    {$ifdef BCB}This.{$endif}Overflow := Pointer(NativeUInt(AFragmentMemory) + AFragmentSize);
    LNull := nil;
    FHeapBlocks := LNull;
    FManagedItems := LNull;
    {$ifdef BCB}This.{$endif}FVmt := TRttiBufferVmt;
  end;
end;

procedure TRttiBuffer.Clear;
var
  LNull: Pointer;
begin
  with PRttiBuffer(@Self)^ do
  begin
    LNull := nil;
    {$ifdef BCB}This.{$endif}Current := LNull;
    {$ifdef BCB}This.{$endif}Overflow := LNull;
    if (Assigned(FHeapBlocks)) then
    begin
      InternalClear;
    end else
    begin
      FHeapBlocks := LNull;
      FManagedItems := LNull;
    end;
  end;
end;

function TRttiBuffer.Alloc(const AExType: TRttiExType): Pointer;
var
  LRulesBuffer: TRttiTypeRules;
  LRules: PRttiTypeRules;
  LSize: NativeUInt;
  LItem: PRttiBufferItem;
  LFuncIndex: NativeUInt;
begin
  // allocation
  LRules := AExType.GetRules(LRulesBuffer);
  LSize := LRules.Size;
  if (tfManaged in LRules.Flags) then
  begin
    Inc(LSize, SizeOf(TRttiBufferItem));
  end;
  LItem := {$ifdef BCB}This.{$endif}AllocAligned8(LSize);

  // initialization
  if (tfManaged in LRules.Flags) then
  begin
    LItem.Next := FManagedItems;
    FManagedItems := LItem;

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

function TRttiBuffer.Convert(const ATargetExType: TRttiExType; const ASource: Pointer): Pointer;
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
      case (SourceExType.BaseType) of
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
      Result := {$ifdef BCB}This.{$endif}AllocAligned8(SizeOf(Int64));
      PInt64(Result)^ := 0;

      case (SourceExType.BaseType) of
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
      Result := {$ifdef BCB}This.{$endif}AllocAligned8(SizeOf(Int64));

      case (SourceExType.BaseType) of
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
      Result := {$ifdef BCB}This.{$endif}AllocAligned8(SizeOf(Extended));

      case (SourceExType.BaseType) of
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
      Result := {$ifdef BCB}This.{$endif}AllocAligned8(SizeOf(TDate));

      case (SourceExType.BaseType) of
        rtDate: PDouble(Result)^ := PDouble(ASource)^;
        rtDateTime: PDouble(Result)^ := Trunc(PDouble(ASource)^);
        rtTimeStamp: PDouble(Result)^ := Trunc((PInt64(ASource)^ - TIMESTAMP_DELTA) * TIMESTAMP_UNDAY);
      else
        goto failure;
      end;
    end;
    rtTime:
    begin
      Result := {$ifdef BCB}This.{$endif}AllocAligned8(SizeOf(TTime));

      case (SourceExType.BaseType) of
        rtTime: PDouble(Result)^ := PDouble(ASource)^;
        rtDateTime: PDouble(Result)^ := Frac(PDouble(ASource)^);
        rtTimeStamp: PDouble(Result)^ := Frac((PInt64(ASource)^ - TIMESTAMP_DELTA) * TIMESTAMP_UNDAY);
      else
        goto failure;
      end;
    end;
    rtDateTime:
    begin
      Result := {$ifdef BCB}This.{$endif}AllocAligned8(SizeOf(TDateTime));

      case (SourceExType.BaseType) of
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
      Result := {$ifdef BCB}This.{$endif}AllocAligned8(SizeOf(TimeStamp));

      case (SourceExType.BaseType) of
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
      case SourceExType.BaseType of
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
      case SourceExType.BaseType of
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
      case SourceExType.BaseType of
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
            Result := {$ifdef BCB}This.{$endif}{$ifdef SMALLINT}AllocAligned4{$else}AllocAligned8{$endif}(SizeOf(Pointer));
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
      if (ATargetExType.BaseType = SourceExType.BaseType) then
      begin
        Result := ASource;
        Exit;
      end;

      // characters, count and code page
      LValue := ASource;
      case (SourceExType.BaseType) of
        rtSBCSChar:
        begin
          LCount := 1;
          LCodePage := SourceExType.CodePage;
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
          LCodePage := SourceExType.CodePage;
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
          if (SourceExType.BaseType = rtUTF8String) then
          begin
            LCodePage := CP_UTF8;
          end else
          begin
            LCodePage := SourceExType.CodePage;
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
        Result := {$ifdef BCB}This.{$endif}AllocAligned4(SizeOf(UCS4Char));

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
              TinyMove(LValue^, PPointer(PWideString(Result)^)^, LCount * SizeOf(WideChar));
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
              TinyMove(LValue^, PPointer(PUnicodeString(Result)^)^, LCount * SizeOf(WideChar));
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
              TinyMove(LValue^, PPointer(PUCS4String(Result)^)^, LCount * SizeOf(UCS4Char));
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
      if (ATargetExType.Options <> SourceExType.Options) or
        (ATargetExType.CustomData <> SourceExType.CustomData) then
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
      if (ATargetExType.BaseType <> SourceExType.BaseType) then
      begin
        goto failure;
      end;
    end;
    rtOleVariant,
    rtVariant:
    begin
      case SourceExType.BaseType of
        rtOleVariant,
        rtVariant: Result := ASource;
      else
        goto failure;
      end;
    end;
  else
  failure:
    TinyError(teInvalidCast);
    Result := nil;
  end;
end;


{ TValue }

function TValue.GetExType: PRttiExType;
begin
  Result := @FExType;
  if (not Assigned(FManagedData)) then
  begin
    Result := nil;
  end;
end;

function TValue.GetBaseType: TRttiType;
begin
  Result := FExType.BaseType;
  if (not Assigned(FManagedData)) then
  begin
    Result := rtUnknown;
  end;
end;

function TValue.GetData: Pointer;
var
  LManagedData: Pointer;
begin
  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    if (Assigned(LManagedData)) then
    begin
      if (not (FExType.BaseType in [rtInterface, rtClosure])) then
      begin
        Result := @PRttiContainerInterface(LManagedData).Value;
      end else
      begin
        Result := @FManagedData;
      end;
    end else
    begin
      TinyError(teInvalidCast);
      Result := nil;
    end;
  end else
  begin
    Result := @FBuffer;
  end;
end;

function TValue.GetDataSize: Integer;
var
  LRulesBuffer: TRttiTypeRules;
begin
  if (Assigned(FManagedData)) then
  begin
    Result := FExType.GetRules(LRulesBuffer).Size;
  end else
  begin
    Result := 0;
  end;
end;

function TValue.GetIsEmpty: Boolean;
begin
  Result := not Assigned(FManagedData);
end;

function TValue.GetIsObject: Boolean;
begin
  Result := Assigned(FManagedData) and (FExType.BaseType = rtObject);
end;

function TValue.GetIsClass: Boolean;
begin
  Result := Assigned(FManagedData) and (FExType.BaseType = rtClassRef);
end;

function TValue.GetIsOrdinal: Boolean;
begin
  Result := Assigned(FManagedData) and
    (FExType.BaseType in [rtInt8, rtUInt8,
    rtInt16, rtUInt16, rtInt32, rtUInt32, rtInt64, rtUInt64,
    rtBoolean8, rtBoolean16, rtBoolean32, rtBoolean64, rtBool8, rtBool16, rtBool32, rtBool64,
    rtEnumeration8, rtEnumeration16, rtEnumeration32, rtEnumeration64, rtSBCSChar,
    rtUTF8Char, rtWideChar,
    rtTimeStamp]);
end;

function TValue.GetIsFloat: Boolean;
begin
  Result := Assigned(FManagedData) and
    (FExType.BaseType in [rtComp, rtCurrency,
    rtFloat, rtDouble, rtLongDouble80, rtLongDouble96, rtLongDouble128,
    rtDate, rtTime, rtDateTime]);
end;

function TValue.IsInstanceOf(const AClass: TClass): Boolean;
begin
  if (Pointer(FManagedData) = @DUMMY_INTERFACE_DATA) then
  case FExType.BaseType of
    rtObject:
    begin
      Result := TObject(FBuffer.VPointer).InheritsFrom(AClass);
      Exit;
    end;
    rtClassRef:
    begin
      Result := FBuffer.VClass.InheritsFrom(AClass);
      Exit;
    end;
  end;

  Result := False;
end;

{$ifdef STATICSUPPORT}class{$endif} procedure TValue.InternalReleaseInterface(AInterface: Pointer);
type
  TInterfaceVmt = packed record
    QueryInterface: Pointer;
    _AddRef: Pointer;
    _Release: function(const AInterface: Pointer): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
  end;
  TInterfaceData = packed record
    Vmt: ^TInterfaceVmt;
  end;
begin
  TInterfaceData(AInterface^).Vmt._Release(AInterface);
end;

procedure TValue.InternalInitData(const ARules: PRttiTypeRules; const AValue: Pointer);
label
  buffered_target, copy_value;
var
  LManagedData: PRttiContainerInterface;
  LTarget, LSource: Pointer;
  LFuncIndex: NativeUInt;
begin
  LManagedData := Pointer(FManagedData);

  if (ARules.Size > SizeOf(FBuffer)) or (tfManaged in ARules.Flags) then
  begin
    case FExType.BaseType of
      rtInterface, rtClosure:
      begin
        LTarget := AValue;
        if (not Assigned(LTarget{AValue})) then
        begin
          LTarget{AValue} := @RTTI_RULES_NONE{nil};
        end;
        // SetInterface(IInterface(LTarget{AValue}^));
        if (LManagedData <> PPointer(LTarget{AValue})^) then
        begin
          Pointer(FManagedData) := PPointer(LTarget{AValue})^;
          if (Assigned(FManagedData)) then
          begin
            FManagedData._AddRef;
          end;
          if (Assigned(LManagedData)) and (Pointer(LManagedData) <> @DUMMY_INTERFACE_DATA) then
          begin
            InternalReleaseInterface(LManagedData);
          end;
        end;
        Exit;
      end;
      rtValue:
      begin
        LTarget := AValue;
        if (not Assigned(LTarget{AValue})) then
        begin
          // Clear;
          FExType.Options := 0;
          FExType.CustomData := nil;
          if (Assigned(LManagedData)) then
          begin
            Pointer(FManagedData) := nil;
            if (Pointer(LManagedData) <> @DUMMY_INTERFACE_DATA) then
            begin
              InternalReleaseInterface(LManagedData);
            end;
          end;
        end else
        begin
          FManagedData := PValue(LTarget{AValue}).FManagedData;
          FExType := PValue(LTarget{AValue}).FExType;
          FBuffer := PValue(LTarget{AValue}).FBuffer;
        end;
        Exit;
      end;
      {$ifdef WEAKINSTREF}
      rtObject,
      rtMethod:
      begin
        goto buffered_target;
      end;
      {$endif}
    else
      // optional clear current data
      if (Assigned(LManagedData)) and (Pointer(LManagedData) <> @DUMMY_INTERFACE_DATA) then
      begin
        if (PPointer(LManagedData.Vmt)^ = @TDummyInterface.QueryInterface) and
          (LManagedData.RefCount = 1) and (LManagedData.ExType.Options = FExType.Options) and
          (LManagedData.ExType.CustomData = FExType.CustomData) then
        begin
          LTarget := @LManagedData.Value;
          goto copy_value;
        end;

        FManagedData := nil;
      end;

      // value data initializaion
      GetMem(LManagedData, SizeOf(TRttiContainerInterface) + ARules.Size);
      LManagedData.Vmt := @RTTI_CONTAINER_INTERFACE_VMT;
      LManagedData.RefCount := 1;
      LManagedData.ExType := FExType;
      LManagedData.FinalFunc := nil;
      LFuncIndex := ARules.FinalFunc;
      if (LFuncIndex <> RTTI_FINALNONE_FUNC) then
      begin
        LManagedData.FinalFunc := RTTI_FINAL_FUNCS[LFuncIndex];
      end;
      LFuncIndex := ARules.InitFunc;
      case LFuncIndex of
        RTTI_INITNONE_FUNC: ;
        RTTI_INITPOINTER_FUNC: PPointer(@LManagedData.Value)^ := nil;
        RTTI_INITPOINTERPAIR_FUNC:
        begin
          PMethod(@LManagedData.Value).Code := nil;
          PMethod(@LManagedData.Value).Data := nil;
        end;
      else
        RTTI_INIT_FUNCS[LFuncIndex](@FExType, @LManagedData.Value);
      end;

      // target
      Pointer(FManagedData) := LManagedData;
      LTarget := @LManagedData.Value;
    end;
  end else
  begin
  buffered_target:
    // internal storage
    if (Pointer(LManagedData) <> @DUMMY_INTERFACE_DATA) then
    begin
      if (Assigned(LManagedData)) then
      begin
        FManagedData := nil;
      end;
      Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    end;
    LTarget := @FBuffer;
  end;

copy_value:
  // copying
  LSource := AValue;
  if (Assigned(LSource)) then
  begin
    case NativeUInt(ARules.CopyFunc) of
      RTTI_COPYNATIVE_FUNC: PPointer(LTarget)^ := PPointer(LSource)^;
      RTTI_COPYALTERNATIVE_FUNC: PAlterNativeInt(LTarget)^ := PAlterNativeInt(LSource)^;
      {$ifdef LARGEINT}
      RTTI_COPYBYTES_LOWFUNC + SizeOf(TMethod): PMethod(LTarget)^ := PMethod(LSource)^;
      {$endif}
    else
      RTTI_COPY_FUNCS[NativeUInt(ARules.CopyFunc)](@FExType, LTarget, LSource);
    end;
  end;
end;

{$ifdef STATICSUPPORT}class{$endif} function TValue.Empty: TValue;
var
  LManagedData: Pointer;
begin
  Result.FExType.Options := 0;
  Result.FExType.CustomData := nil;
  LManagedData := Pointer(Result.FManagedData);
  if (Assigned(LManagedData)) then
  begin
    Pointer(Result.FManagedData) := nil;
    if (LManagedData <> @DUMMY_INTERFACE_DATA) then
    begin
      Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
      if (Assigned(LManagedData)) then
      begin
        Result.InternalReleaseInterface(LManagedData);
      end;
    end;
  end;
end;

procedure TValue.Init(const AExType: TRttiExType; const AValue: Pointer);
var
  LRulesBuffer: TRttiTypeRules;
begin
  if (AExType.PointerDepth <> 0) then
  begin
    FExType.Options := Ord(rtPointer);
    FExType.CustomData := nil;
  end else
  begin
    FExType := AExType;
  end;

  InternalInitData(FExType.GetRules(LRulesBuffer), AValue);
end;

procedure TValue.Init(const ATypeInfo: PTypeInfo; const AValue: Pointer);
var
  LRulesBuffer: TRttiTypeRules;
begin
  if (not DefaultContext.GetExType(ATypeInfo, FExType)) or (FExType.PointerDepth <> 0) then
  begin
    FExType.Options := Ord(rtPointer);
    FExType.CustomData := nil;
  end;

  InternalInitData(FExType.GetRules(LRulesBuffer), AValue);
end;

{$ifdef GENERICMETHODSUPPORT}
procedure TValue.Init<T>(const AValue: T);
begin
  FExType := TRttiExType<T>.DefaultSimplified;
  InternalInitData(@TRttiExType<T>.DefaultRules, @AValue);
end;

class function TValue.From<T>(const AValue: T): TValue;
begin
  Result.FExType := TRttiExType<T>.DefaultSimplified;
  Result.InternalInitData(@TRttiExType<T>.DefaultRules, @AValue);
end;

function TValue.TryGet<T>(var AValue: T): Boolean;
var
  LManagedData: Pointer;
  LData: Pointer;
begin
  LManagedData := Pointer(FManagedData);
  if (Assigned(LManagedData)) and
    (TRttiExType<T>.DefaultSimplified.Options = FExType.Options) and
    (TRttiExType<T>.DefaultSimplified.CustomData = FExType.CustomData) then
  begin
    if (LManagedData = @DUMMY_INTERFACE_DATA) then
    begin
      LData := @FBuffer;
    end else
    begin
      LData := GetData;
    end;

    AValue := T(LData^);
    Result := True;
  end else
  begin
    Result := False;
  end;
end;

function TValue.Get<T>: T;
begin
  if (not TryGet<T>(Result)) then
  begin
    TinyError(teInvalidCast);
  end;
end;
{$endif}

procedure TValue.Clear;
var
  LManagedData: Pointer;
begin
  FExType.Options := 0;
  FExType.CustomData := nil;
  LManagedData := Pointer(FManagedData);
  if (Assigned(LManagedData)) then
  begin
    Pointer(FManagedData) := nil;
    if (LManagedData <> @DUMMY_INTERFACE_DATA) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetPointer(const AValue: Pointer);
var
  LManagedData: Pointer;
begin
  FBuffer.VPointer := AValue;
  FExType.Options := Ord(rtPointer);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetBoolean(const AValue: Boolean);
var
  LManagedData: Pointer;
begin
  FBuffer.VBoolean := AValue;
  FExType.Options := Ord(rtBoolean8);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetInteger(const AValue: Integer);
var
  LManagedData: Pointer;
begin
  FBuffer.VInt32 := AValue;
  FExType.Options := Ord(rtInt32);
  FExType.RangeData := @INT32_TYPE_DATA;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetCardinal(const AValue: Cardinal);
var
  LManagedData: Pointer;
begin
  FBuffer.VUInt32 := AValue;
  FExType.Options := Ord(rtUInt32);
  FExType.RangeData := @UINT32_TYPE_DATA;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetInt64(const AValue: Int64);
var
  LManagedData: Pointer;
begin
  FBuffer.VInt64 := AValue;
  FExType.Options := Ord(rtInt64);
  FExType.RangeData := @INT64_TYPE_DATA;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetUInt64(const AValue: UInt64);
var
  LManagedData: Pointer;
begin
  FBuffer.VUInt64 := AValue;
  FExType.Options := Ord(rtUInt64);
  FExType.RangeData := @UINT64_TYPE_DATA;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetCurrency(const AValue: Currency);
var
  LManagedData: Pointer;
begin
  FBuffer.VCurrency := AValue;
  FExType.Options := Ord(rtCurrency);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetSingle(const AValue: Single);
var
  LManagedData: Pointer;
begin
  FBuffer.VSingle := AValue;
  FExType.Options := Ord(rtFloat);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetDouble(const AValue: Double);
var
  LManagedData: Pointer;
begin
  FBuffer.VDouble := AValue;
  FExType.Options := Ord(rtDouble);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetExtended(const AValue: Extended);
var
  LManagedData: Pointer;
begin
  FBuffer.VLongDouble := AValue;
  FExType.Options := Ord(rtLongDouble80);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetDate(const AValue: TDate);
var
  LManagedData: Pointer;
begin
  FBuffer.VDouble := AValue;
  FExType.Options := Ord(rtDate);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetTime(const AValue: TTime);
var
  LManagedData: Pointer;
begin
  FBuffer.VDouble := AValue;
  FExType.Options := Ord(rtTime);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetDateTime(const AValue: TDateTime);
var
  LManagedData: Pointer;
begin
  FBuffer.VDouble := AValue;
  FExType.Options := Ord(rtDateTime);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetTimeStamp(const AValue: TimeStamp);
var
  LManagedData: Pointer;
begin
  FBuffer.VInt64 := AValue;
  FExType.Options := Ord(rtTimeStamp);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetAnsiString(const AValue: AnsiString);
var
  LManagedData: Pointer;
  LTarget: Pointer;
  LStored: record
    Source: NativeUInt;
  end;
begin
  LStored.Source := NativeUInt(Pointer(AValue));

  if (FExType.Options = DefaultSBCSStringOptions) then
  begin
    LManagedData := Pointer(FManagedData);
    if (Assigned(LManagedData)) then
    begin
      LTarget := @PRttiContainerInterface(LManagedData).Value;
      if (PPointer(LTarget)^ <> Pointer(AValue)) then
      begin
        RTTI_COPY_FUNCS[RTTI_COPYSTRING_FUNC](nil, LTarget, @LStored.Source);
      end;
      Exit;
    end;
  end else
  begin
    FExType.Options := DefaultSBCSStringOptions;
  end;

  FExType.CustomData := nil;
  InternalInitData(RTTI_TYPE_RULES[rtSBCSString], @LStored.Source);
end;

procedure TValue.SetUnicodeString(const AValue: UnicodeString);
var
  LManagedData: Pointer;
  LTarget: Pointer;
  LStored: record
    Source: NativeUInt;
  end;
begin
  LStored.Source := NativeUInt(Pointer(AValue));

  if (FExType.Options = Ord(rtUnicodeString)) then
  begin
    LManagedData := Pointer(FManagedData);
    if (Assigned(LManagedData)) then
    begin
      LTarget := @PRttiContainerInterface(LManagedData).Value;
      if (PPointer(LTarget)^ <> Pointer(AValue)) then
      begin
        RTTI_COPY_FUNCS[{$ifdef UNICODE}RTTI_COPYSTRING_FUNC{$else}RTTI_COPYWIDESTRING_FUNC{$endif}](nil, LTarget, @LStored.Source);
      end;
      Exit;
    end;
  end else
  begin
    FExType.Options := Ord(rtUnicodeString);
  end;

  FExType.CustomData := nil;
  InternalInitData(RTTI_TYPE_RULES[rtUnicodeString], @LStored.Source);
end;

procedure TValue.SetObject(const AValue: TObject);
var
  LManagedData: Pointer;
begin
  FBuffer.VPointer := AValue;
  FExType.Options := Ord(rtObject);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetInterface(const AValue: IInterface);
var
  LStored: record
    Source: NativeUInt;
  end;
begin
  FExType.Options := Ord(rtInterface);
  FExType.CustomData := nil;
  if (Pointer(FManagedData) <> Pointer(AValue)) then
  begin
    LStored.Source := NativeUInt(Pointer(AValue));
    RTTI_COPY_FUNCS[RTTI_COPYINTERFACE_FUNC](nil, @FManagedData, @LStored.Source);
  end;
end;

procedure TValue.SetClass(const AValue: TClass);
var
  LManagedData: Pointer;
begin
  FBuffer.VClass := AValue;
  FExType.Options := Ord(rtClassRef);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetBytes(const AValue: TBytes);
var
  LManagedData: Pointer;
  LTarget: Pointer;
  LStored: record
    Source: NativeUInt;
  end;
begin
  LStored.Source := NativeUInt(Pointer(AValue));

  if (FExType.Options = Ord(rtBytes)) then
  begin
    LManagedData := Pointer(FManagedData);
    if (Assigned(LManagedData)) then
    begin
      LTarget := @PRttiContainerInterface(LManagedData).Value;
      if (PPointer(LTarget)^ <> Pointer(AValue)) then
      begin
        RTTI_COPY_FUNCS[RTTI_COPYDYNARRAY_FUNC](nil, LTarget, @LStored.Source);
      end;
      Exit;
    end;
  end else
  begin
    FExType.Options := Ord(rtBytes);
  end;

  FExType.CustomData := nil;
  InternalInitData(RTTI_TYPE_RULES[rtBytes], @LStored.Source);
end;

procedure TValue.SetMethod(const AValue: TMethod);
var
  LManagedData: Pointer;
begin
  FBuffer.VMethod := AValue;
  FExType.Options := Ord(rtMethod);
  FExType.CustomData := nil;

  LManagedData := Pointer(FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      InternalReleaseInterface(LManagedData);
    end;
  end;
end;

procedure TValue.SetVarData(const AValue: TVarData);
label
  type_string, invalid, type_8, type_16, type_32, type_64, no_type_data;
var
  LType: Integer;
  LSource, LManagedData: Pointer;
begin
  // variant type
  LType := AValue.VType;
  LSource := @AValue.VWords[3];
  if (LType and varByRef <> 0) then
  begin
    LType := LType and (not varByRef);
    LSource := PPointer(LSource)^;
  end;

  // initialization
  case LType of
    varBoolean:
    begin
      FExType.Options := Ord(rtBoolean8);
      goto type_8;
    end;
    varShortInt:
    begin
      FExType.Options := Ord(rtInt8);
      FExType.RangeData := @INT8_TYPE_DATA;
      goto type_8;
    end;
    varByte:
    begin
      FExType.Options := Ord(rtUInt8);
      FExType.RangeData := @UINT8_TYPE_DATA;
      goto type_8;
    end;
    varSmallInt:
    begin
      FExType.Options := Ord(rtInt16);
      FExType.RangeData := @INT16_TYPE_DATA;
      goto type_16;
    end;
    varWord:
    begin
      FExType.Options := Ord(rtUInt16);
      FExType.RangeData := @UINT16_TYPE_DATA;
      goto type_16;
    end;
    varInteger:
    begin
      FExType.Options := Ord(rtInt32);
      FExType.RangeData := @INT32_TYPE_DATA;
      goto type_32;
    end;
    varLongWord:
    begin
      FExType.Options := Ord(rtUInt32);
      FExType.RangeData := @UINT32_TYPE_DATA;
      goto type_32;
    end;
    varInt64:
    begin
      FExType.Options := Ord(rtInt64);
      FExType.RangeData := @INT64_TYPE_DATA;
      goto type_64;
    end;
    varUInt64:
    begin
      FExType.Options := Ord(rtUInt64);
      FExType.RangeData := @UINT64_TYPE_DATA;
      goto type_64;
    end;
    varSingle:
    begin
      FExType.Options := Ord(rtFloat);
      goto type_32;
    end;
    varDouble:
    begin
      FExType.Options := Ord(rtDouble);
      goto type_64;
    end;
    varCurrency:
    begin
      FExType.Options := Ord(rtCurrency);
      goto type_64;
    end;
    varDate:
    begin
      FExType.Options := Ord(rtDateTime);
      goto type_64;
    end;
    varString:
    begin
      FExType.Options := DefaultSBCSStringOptions;
      goto type_string;
    end;
    {$ifdef UNICODE}
    varUString:
    begin
      FExType.Options := Ord(rtUnicodeString);
      goto type_string;
    end;
    {$endif}
    varOleStr:
    begin
      FExType.Options := Ord(rtWideString);
    type_string:
      FExType.CustomData := nil;
      InternalInitData(RTTI_TYPE_RULES[FExType.BaseType], LSource);
      Exit;
    end;
    varDispatch:
    begin
      SetInterface(IInterface(LSource^));
      Exit;
    end;
  else
  invalid:
    TinyError(teVarTypeCast);
  type_8:
    FBuffer.VUInt8 := PByte(LSource)^;
    goto no_type_data;
  type_16:
    FBuffer.VUInt16 := PWord(LSource)^;
    goto no_type_data;
  type_32:
    FBuffer.VUInt32 := PCardinal(LSource)^;
    goto no_type_data;
  type_64:
    FBuffer.VUInt64 := PUInt64(LSource)^;
  no_type_data:
    FExType.CustomData := nil;
  end;

  // interface initialization
  LManagedData := Pointer(FManagedData);
  if (Pointer(LManagedData) <> @DUMMY_INTERFACE_DATA) then
  begin
    if (Assigned(LManagedData)) then
    begin
      FManagedData := nil;
    end;
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
  end;
end;

procedure TValue.SetVarRec(const AValue: TVarRec);
label
  type_string;
var
  LRulesBuffer: TRttiTypeRules;
  LSource, LManagedData: Pointer;
begin
  case Cardinal(AValue.VType) of
    vtBoolean:
    begin
      FExType.Options := Ord(rtBoolean8);
      FBuffer.VBoolean := AValue.VBoolean;
    end;
    vtInteger:
    begin
      FExType.Options := Ord(rtInt32);
      FExType.RangeData := @INT32_TYPE_DATA;
      FBuffer.VInt32 := AValue.VInteger;
    end;
    vtInt64:
    begin
      FExType.Options := Ord(rtInt64);
      FExType.RangeData := @INT64_TYPE_DATA;
      FBuffer.VInt64 := AValue.VInt64^;
    end;
    vtExtended:
    begin
      case SizeOf(Extended) of
        10: FExType.Options := Ord(rtLongDouble80);
        12: FExType.Options := Ord(rtLongDouble96);
        16: FExType.Options := Ord(rtLongDouble128);
      else
        FExType.Options := Ord(rtDouble);
      end;
      FExType.RangeData := nil;
      FBuffer.VLongDouble := AValue.VExtended^;
    end;
    vtCurrency:
    begin
      FExType.Options := Ord(rtCurrency);
      FExType.RangeData := nil;
      FBuffer.VCurrency := AValue.VCurrency^;
    end;
    vtPointer:
    begin
      FExType.Options := Ord(rtPointer);
      FExType.CustomData := nil;
      FBuffer.VPointer := AValue.VPointer;
    end;
    vtObject:
    begin
      FExType.Options := Ord(rtObject);
      FExType.CustomData := nil;
      FBuffer.VPointer := Pointer(AValue.VObject);
    end;
    vtClass:
    begin
      FExType.Options := Ord(rtClassRef);
      FExType.CustomData := nil;
      FBuffer.VPointer := Pointer(AValue.VClass);
    end;
    vtInterface:
    begin
      SetInterface(IInterface(AValue.VInterface));
      Exit;
    end;
    vtVariant:
    begin
      SetVarData(PVarData(AValue.VPointer)^);
      Exit;
    end;
    vtString:
    begin
      LSource := AValue.VPointer;
      FExType.Options := Ord(rtShortString) + (255 shl 16) {$ifdef SHORTSTRSUPPORT}+ (Ord(True) shl 24){$endif};
      FExType.CustomData := nil;
      LRulesBuffer.Size := PByte(LSource)^ + 1;
      PNativeInt(@LRulesBuffer.Return)^ := 0;
      {$ifdef SMALLINT}
      PInteger(@LRulesBuffer.FinalFunc)^ := 0;
      {$endif}
      {$ifdef SHORTSTRSUPPORT}
      LRulesBuffer.Flags := RTTI_RULEFLAGS_REFERENCE + [tfVarHigh];
      {$endif}
      LRulesBuffer.CopyFunc := RTTI_COPYSHORTSTRING_FUNC;
      LRulesBuffer.WeakCopyFunc := RTTI_COPYSHORTSTRING_FUNC;
      InternalInitData(@LRulesBuffer, LSource);
      Exit;
    end;
    vtAnsiString:
    begin
      FExType.Options := DefaultSBCSStringOptions;
      goto type_string;
    end;
    {$ifdef UNICODE}
    vtUnicodeString:
    begin
      FExType.Options := Ord(rtUnicodeString);
      goto type_string;
    end;
    {$endif}
    vtWideString:
    begin
      FExType.Options := Ord(rtWideString);
    type_string:
      FExType.CustomData := nil;
      InternalInitData(RTTI_TYPE_RULES[FExType.BaseType], @AValue.VPointer);
      Exit;
    end;
    vtChar:
    begin
      FExType.Options := Ord(rtSBCSChar);
      FExType.RangeData := nil;
      FBuffer.VUInt8 := Byte(AValue.VInteger{VChar});
    end;
    vtWideChar:
    begin
      FExType.Options := Ord(rtWideChar);
      FExType.RangeData := nil;
      FBuffer.VUInt16 := Word(AValue.VWideChar);
    end;
    vtPChar:
    begin
      FExType.Options := Ord(rtPointer);
      FExType.RangeData := nil;
      FBuffer.VPointer := AValue.VPointer{VPChar};
    end;
    vtPWideChar:
    begin
      FExType.Options := Ord(rtPointer);
      FExType.RangeData := nil;
      FBuffer.VPointer := AValue.VPWideChar;
    end;
  end;

  // interface initialization
  LManagedData := Pointer(FManagedData);
  if (Pointer(LManagedData) <> @DUMMY_INTERFACE_DATA) then
  begin
    if (Assigned(LManagedData)) then
    begin
      FManagedData := nil;
    end;
    Pointer(FManagedData) := @DUMMY_INTERFACE_DATA;
  end;
end;

function TValue.InternalGetPointer: Pointer;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtPointer,
    rtPSBCSChars,
    rtPUTF8Chars,
    rtPWideChars,
    rtPUCS4Chars,
    rtClassRef,
    rtObject,
    rtFunction: Result := FBuffer.VPointer;
    rtClosure,
    rtInterface: Result := Pointer(FManagedData);
    rtMethod: Result := FBuffer.VMethod.Code;
  else
  failure:
    TinyError(teInvalidCast);
    Result := nil;
  end;
end;

function TValue.InternalGetBoolean: Boolean;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtBoolean8: Result := FBuffer.VBoolean;
    rtBool8: Result := (FBuffer.VUInt8 <> 0);
    rtBoolean16,
    rtBool16: Result := (FBuffer.VUInt16 <> 0);
    rtBoolean32,
    rtBool32: Result := (FBuffer.VUInt32 <> 0);
    rtBoolean64,
    rtBool64: Result := (FBuffer.VUInt64 <> 0);
  else
  failure:
    TinyError(teInvalidCast);
    Result := False;
  end;
end;

function TValue.InternalGetInteger: Integer;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtBoolean8,
    rtBool8,
    rtUInt8: Result := FBuffer.VUInt8;
    rtBoolean16,
    rtBool16,
    rtUInt16: Result := FBuffer.VUInt16;
    rtInt8,
    rtEnumeration8: Result := FBuffer.VInt8;
    rtInt16,
    rtEnumeration16: Result := FBuffer.VInt16;
    rtBoolean32,
    rtBoolean64,
    rtBool32,
    rtBool64,
    rtInt32,
    rtUInt32,
    rtInt64,
    rtUInt64,
    rtEnumeration32,
    rtEnumeration64,
    rtComp,
    rtTimeStamp: Result := FBuffer.VInt32;
    rtCurrency: Result := Round(FBuffer.VInt64 * (1 / 10000));
    rtFloat: Result := Round(FBuffer.VSingle);
    rtDouble: Result := Round(FBuffer.VDouble);
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128: Result := Round(FBuffer.VLongDouble);
    {$endif}
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetCardinal: Cardinal;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtBoolean8,
    rtBool8,
    rtUInt8: Result := FBuffer.VUInt8;
    rtBoolean16,
    rtBool16,
    rtUInt16: Result := FBuffer.VUInt16;
    rtInt8,
    rtEnumeration8: Result := Cardinal(Integer(FBuffer.VInt8));
    rtInt16,
    rtEnumeration16: Result := Cardinal(Integer(FBuffer.VInt16));
    rtBoolean32,
    rtBoolean64,
    rtBool32,
    rtBool64,
    rtInt32,
    rtUInt32,
    rtInt64,
    rtUInt64,
    rtEnumeration32,
    rtEnumeration64,
    rtComp,
    rtTimeStamp: Result := FBuffer.VUInt32;
    rtCurrency: Result := Round(FBuffer.VInt64 * (1 / 10000));
    rtFloat: Result := Round(FBuffer.VSingle);
    rtDouble: Result := Round(FBuffer.VDouble);
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128: Result := Round(FBuffer.VLongDouble);
    {$endif}
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetInt64: Int64;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtBoolean8,
    rtBool8,
    rtUInt8: Result := FBuffer.VUInt8;
    rtBoolean16,
    rtBool16,
    rtUInt16: Result := FBuffer.VUInt16;
    rtInt8,
    rtEnumeration8: Result := FBuffer.VInt8;
    rtInt16,
    rtEnumeration16: Result := FBuffer.VInt16;
    rtBoolean32,
    rtBool32,
    rtUInt32: Result := FBuffer.VUInt32;
    rtInt32,
    rtEnumeration32:  Result := FBuffer.VInt32;
    rtBoolean64,
    rtBool64,
    rtInt64,
    rtUInt64,
    rtEnumeration64,
    rtComp,
    rtTimeStamp: Result := FBuffer.VInt64;
    rtCurrency: Result := Round(FBuffer.VInt64 * (1 / 10000));
    rtFloat: Result := Round(FBuffer.VSingle);
    rtDouble: Result := Round(FBuffer.VDouble);
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128: Result := Round(FBuffer.VLongDouble);
    {$endif}
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetUInt64: UInt64;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtBoolean8,
    rtBool8,
    rtUInt8: Result := FBuffer.VUInt8;
    rtBoolean16,
    rtBool16,
    rtUInt16: Result := FBuffer.VUInt16;
    rtInt8,
    rtEnumeration8: Result := UInt64(Int64(FBuffer.VInt8));
    rtInt16,
    rtEnumeration16: Result := UInt64(Int64(FBuffer.VInt16));
    rtBoolean32,
    rtBool32,
    rtUInt32: Result := FBuffer.VUInt32;
    rtInt32,
    rtEnumeration32:  Result := UInt64(Int64(FBuffer.VInt32));
    rtBoolean64,
    rtBool64,
    rtInt64,
    rtUInt64,
    rtEnumeration64,
    rtComp,
    rtTimeStamp: Result := FBuffer.VUInt64;
    rtCurrency: Result := Round(FBuffer.VInt64 * (1 / 10000));
    rtFloat: Result := Round(FBuffer.VSingle);
    rtDouble: Result := Round(FBuffer.VDouble);
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128: Result := Round(FBuffer.VLongDouble);
    {$endif}
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetCurrency: Currency;
label
  from_int64, failure;
var
  LInt64Value: Int64;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtUInt8:
    begin
      LInt64Value := FBuffer.VUInt8;
      goto from_int64;
    end;
    rtInt8,
    rtEnumeration8:
    begin
      LInt64Value := FBuffer.VInt8;
      goto from_int64;
    end;
    rtUInt16:
    begin
      LInt64Value := FBuffer.VUInt16;
      goto from_int64;
    end;
    rtInt16,
    rtEnumeration16:
    begin
      LInt64Value := FBuffer.VInt16;
      goto from_int64;
    end;
    rtUInt32:
    begin
      LInt64Value := FBuffer.VUInt32;
      goto from_int64;
    end;
    rtInt32,
    rtEnumeration32:
    begin
      LInt64Value := FBuffer.VInt32;
      goto from_int64;
    end;
    rtInt64,
    rtUInt64,
    rtEnumeration64,
    rtComp:
    begin
      LInt64Value := FBuffer.VInt64;
    from_int64:
      Result := LInt64Value;
    end;
    rtCurrency: Result := FBuffer.VCurrency;
    rtFloat: Result := FBuffer.VSingle;
    rtDouble: Result := FBuffer.VDouble;
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128: Result := FBuffer.VLongDouble;
    {$endif}
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetSingle: Single;
label
  from_int32, failure;
var
  LInt32Value: Integer;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtUInt8:
    begin
      LInt32Value := FBuffer.VUInt8;
      goto from_int32;
    end;
    rtInt8,
    rtEnumeration8:
    begin
      LInt32Value := FBuffer.VInt8;
      goto from_int32;
    end;
    rtUInt16:
    begin
      LInt32Value := FBuffer.VUInt16;
      goto from_int32;
    end;
    rtInt16,
    rtEnumeration16:
    begin
      LInt32Value := FBuffer.VInt16;
    from_int32:
      Result := LInt32Value;
    end;
    rtUInt32: Result := Int64(FBuffer.VUInt32);
    rtInt32,
    rtEnumeration32: Result := FBuffer.VInt32;
    rtInt64,
    rtUInt64,
    rtEnumeration64,
    rtComp,
    rtTimeStamp: Result := FBuffer.VInt64;
    rtCurrency: Result := FBuffer.VInt64 * (1 / 10000);
    rtFloat: Result := FBuffer.VSingle;
    rtDouble,
    rtDate,
    rtTime,
    rtDateTime: Result := FBuffer.VDouble;
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128: Result := FBuffer.VLongDouble;
    {$endif}
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetDouble: Double;
label
  from_int32, failure;
var
  LInt32Value: Integer;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtUInt8:
    begin
      LInt32Value := FBuffer.VUInt8;
      goto from_int32;
    end;
    rtInt8,
    rtEnumeration8:
    begin
      LInt32Value := FBuffer.VInt8;
      goto from_int32;
    end;
    rtUInt16:
    begin
      LInt32Value := FBuffer.VUInt16;
      goto from_int32;
    end;
    rtInt16,
    rtEnumeration16:
    begin
      LInt32Value := FBuffer.VInt16;
    from_int32:
      Result := LInt32Value;
    end;
    rtUInt32: Result := Int64(FBuffer.VUInt32);
    rtInt32,
    rtEnumeration32: Result := FBuffer.VInt32;
    rtInt64,
    rtUInt64,
    rtEnumeration64,
    rtComp,
    rtTimeStamp: Result := FBuffer.VInt64;
    rtCurrency: Result := FBuffer.VInt64 * (1 / 10000);
    rtFloat: Result := FBuffer.VSingle;
    rtDouble,
    rtDate,
    rtTime,
    rtDateTime: Result := FBuffer.VDouble;
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128: Result := FBuffer.VLongDouble;
    {$endif}
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetExtended: Extended;
label
  from_int32, failure;
var
  LInt32Value: Integer;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtUInt8:
    begin
      LInt32Value := FBuffer.VUInt8;
      goto from_int32;
    end;
    rtInt8,
    rtEnumeration8:
    begin
      LInt32Value := FBuffer.VInt8;
      goto from_int32;
    end;
    rtUInt16:
    begin
      LInt32Value := FBuffer.VUInt16;
      goto from_int32;
    end;
    rtInt16,
    rtEnumeration16:
    begin
      LInt32Value := FBuffer.VInt16;
    from_int32:
      Result := LInt32Value;
    end;
    rtUInt32: Result := Int64(FBuffer.VUInt32);
    rtInt32,
    rtEnumeration32: Result := FBuffer.VInt32;
    rtInt64,
    rtUInt64,
    rtEnumeration64,
    rtComp,
    rtTimeStamp: Result := FBuffer.VInt64;
    rtCurrency: Result := FBuffer.VInt64 * (1 / 10000);
    rtFloat: Result := FBuffer.VSingle;
    rtDouble,
    rtDate,
    rtTime,
    rtDateTime: Result := FBuffer.VDouble;
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128: Result := FBuffer.VLongDouble;
    {$endif}
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetDate: TDate;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtDate: Result := FBuffer.VDouble;
    rtDateTime: Result := Trunc(FBuffer.VDouble);
    rtTimeStamp: Result := Trunc((FBuffer.VInt64 - TIMESTAMP_DELTA) * TIMESTAMP_UNDAY);
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetTime: TTime;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtTime: Result := FBuffer.VDouble;
    rtDateTime: Result := Frac(FBuffer.VDouble);
    rtTimeStamp: Result := Frac((FBuffer.VInt64 - TIMESTAMP_DELTA) * TIMESTAMP_UNDAY);
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetDateTime: TDateTime;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtDate,
    rtTime,
    rtDateTime: Result := FBuffer.VDouble;
    rtTimeStamp: Result := (FBuffer.VInt64 - TIMESTAMP_DELTA) * TIMESTAMP_UNDAY;
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

function TValue.InternalGetTimeStamp: TimeStamp;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtTimeStamp: Result := FBuffer.VInt64;
    rtDate,
    rtTime,
    rtDateTime: Result := Round(FBuffer.VDouble * TIMESTAMP_DAY + TIMESTAMP_DELTA);
  else
  failure:
    TinyError(teInvalidCast);
    Result := 0;
  end;
end;

procedure TValue.InternalGetAnsiString(var Result: AnsiString);
label
  failure;
var
  LValue: Pointer;
  LCodePage: Word;
  LCount: Integer;
begin
  if (not Assigned(FManagedData)) then goto failure;

  LValue := GetData;
  case (FExType.BaseType) of
    rtSBCSChar:
    begin
      LCount := 1;
      LCodePage := FExType.CodePage;
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
      LCount := TCharacters.LStrLen(PPointer(LValue)^);
      LCodePage := FExType.CodePage;
    end;
    rtPUTF8Chars:
    begin
      LCount := TCharacters.LStrLen(PPointer(LValue)^);;
      LCodePage := CP_UTF8;
    end;
    rtPWideChars:
    begin
      LCount := TCharacters.WStrLen(PPointer(LValue)^);;
      LCodePage := CP_UTF16;
    end;
    rtPUCS4Chars:
    begin
      LCount := TCharacters.UStrLen(PPointer(LValue)^);;
      LCodePage := CP_UTF32;
    end;
    rtSBCSString, rtUTF8String:
    begin
      if (FExType.BaseType = rtUTF8String) then
      begin
        LCodePage := CP_UTF8;
      end else
      begin
        LCodePage := FExType.CodePage;
      end;

      if (LCodePage = DefaultCP) then
      begin
        Result := PAnsiString(LValue)^;
        Exit;
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
  failure:
    TinyError(teInvalidCast);
    Exit;
  end;

  if (LCount <= 0) then
  begin
    Result := {$ifdef ANSISTRSUPPORT}''{$else}nil{$endif};
  end else
  case LCodePage of
    CP_UTF16:
    begin
      TCharacters.AnsiFromUnicode(DefaultCP, Result, LValue, LCount);
    end;
    CP_UTF32:
    begin
      TCharacters.AnsiFromUCS4(DefaultCP, Result, LValue, LCount);
    end;
  else
    if (LCodePage = DefaultCP) then
    begin
      SetLength(Result, LCount);
      TinyMove(LValue^, Pointer(Result)^, LCount);
    end else
    begin
      TCharacters.AnsiFromAnsi(DefaultCP, Result, LCodePage, LValue, LCount);
    end;
  end;
end;

procedure TValue.InternalGetUnicodeString(var Result: UnicodeString);
label
  failure;
var
  LValue: Pointer;
  LCodePage: Word;
  LCount: Integer;
begin
  if (not Assigned(FManagedData)) then goto failure;

  LValue := GetData;
  case (FExType.BaseType) of
    rtSBCSChar:
    begin
      LCount := 1;
      LCodePage := FExType.CodePage;
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
      LCount := TCharacters.LStrLen(PPointer(LValue)^);
      LCodePage := FExType.CodePage;
    end;
    rtPUTF8Chars:
    begin
      LCount := TCharacters.LStrLen(PPointer(LValue)^);;
      LCodePage := CP_UTF8;
    end;
    rtPWideChars:
    begin
      LCount := TCharacters.WStrLen(PPointer(LValue)^);;
      LCodePage := CP_UTF16;
    end;
    rtPUCS4Chars:
    begin
      LCount := TCharacters.UStrLen(PPointer(LValue)^);;
      LCodePage := CP_UTF32;
    end;
    rtSBCSString, rtUTF8String:
    begin
      if (FExType.BaseType = rtUTF8String) then
      begin
        LCodePage := CP_UTF8;
      end else
      begin
        LCodePage := FExType.CodePage;
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
      Result := PUnicodeString(LValue)^;
      Exit;
    end;
    rtUCS4String:
    begin
      LCount := Length(PUCS4String(LValue)^);
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
  failure:
    TinyError(teInvalidCast);
    Exit;
  end;

  if (LCount <= 0) then
  begin
    Result := '';
  end else
  case LCodePage of
    CP_UTF16:
    begin
      SetLength(Result, LCount);
      TinyMove(LValue^, Pointer(Result)^, LCount * SizeOf(WideChar));
    end;
    CP_UTF32:
    begin
      TCharacters.UnicodeFromUCS4(Result, LValue, LCount);
    end;
  else
    TCharacters.UnicodeFromAnsi(Result, LCodePage, LValue, LCount);
  end;
end;

function TValue.InternalGetObject: TObject;
label
  failure;
const
  ObjCastGUID: TGUID = '{CEDF24DE-80A4-447D-8C75-EB871DC121FD}';
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtObject: Result := TObject(FBuffer.VPointer);
    rtInterface:
    begin
      if (FManagedData.QueryInterface(ObjCastGUID, Pointer(Result)) <> S_OK) then
      begin
        Result := nil;
      end;
    end
  else
  failure:
    TinyError(teInvalidCast);
    Result := nil;
  end;
end;

procedure TValue.InternalGetInterface(var Result{: unsafe IInterface});
label
  failure;
var
  LObject: Pointer;
  LClass: TClass;
  LInterfaceTable: PInterfaceTable;
begin
  if (not Assigned(FManagedData)) then
  begin
    {$ifdef WEAKINTFREF}
      Pointer(Result) := nil;
    {$else}
      IInterface(Result) := nil;
    {$endif}
    Exit;
  end;

  case (FExType.BaseType) of
    rtObject:
    begin
      LObject := FBuffer.VPointer;

      if (Assigned(LObject)) then
      begin
        LClass := TClass(PPointer(LObject)^);

        repeat
          LInterfaceTable := PPointer(NativeInt(LClass) + vmtIntfTable)^;
          if (Assigned(LInterfaceTable)) then
          begin
            {$ifdef WEAKINTFREF}
              Pointer(Result) := Pointer(NativeInt(LObject) + LInterfaceTable.Entries[0].IOffset);
            {$else}
              IInterface(Result) := IInterface(Pointer(NativeInt(LObject) + LInterfaceTable.Entries[0].IOffset));
            {$endif}
            Exit;
          end;

          LClass := LClass.ClassParent;
        until (not Assigned(LClass));
      end;

      goto failure;
    end;
    rtInterface,
    rtClosure:
    begin
      {$ifdef WEAKINTFREF}
        Pointer(Result) := Pointer(FManagedData);
      {$else}
        IInterface(Result) := FManagedData;
      {$endif}
    end
  else
  failure:
    TinyError(teInvalidCast);
  end;
end;

function TValue.InternalGetClass: TClass;
label
  failure;
var
  LObject: Pointer;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtClassRef: Result := TClass(FBuffer.VPointer);
    rtObject:
    begin
      LObject := FBuffer.VPointer;
      if (Assigned(LObject)) then
      begin
        Result := PPointer(LObject)^;
      end else
      begin
        Result := nil;
      end;
    end;
  else
  failure:
    TinyError(teInvalidCast);
    Result := nil;
  end;
end;

procedure TValue.InternalGetBytes(var Result: TBytes);
label
  failure;
var
  LValue: Pointer;
begin
  if (not Assigned(FManagedData)) then goto failure;

  LValue := GetData;
  case (FExType.BaseType) of
    rtBytes: Result := PBytes(LValue)^;
  else
  failure:
    TinyError(teInvalidCast);
    Result := nil;
  end;
end;

function TValue.GetPointer: Pointer;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtPointer) then
  begin
    Result := FBuffer.VPointer;
  end else
  begin
    Result := InternalGetPointer;
  end;
end;

function TValue.GetBoolean: Boolean;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtBoolean8) then
  begin
    Result := FBuffer.VBoolean;
  end else
  begin
    Result := InternalGetBoolean;
  end;
end;

function TValue.GetInteger: Integer;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtInt32) then
  begin
    Result := FBuffer.VInt32;
  end else
  begin
    Result := InternalGetInteger;
  end;
end;

function TValue.GetCardinal: Cardinal;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtUInt32) then
  begin
    Result := FBuffer.VUInt32;
  end else
  begin
    Result := InternalGetCardinal;
  end;
end;

function TValue.GetInt64: Int64;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtInt64) then
  begin
    Result := FBuffer.VInt64;
  end else
  begin
    Result := InternalGetInt64;
  end;
end;

function TValue.GetUInt64: UInt64;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtUInt64) then
  begin
    Result := FBuffer.VUInt64;
  end else
  begin
    Result := InternalGetUInt64;
  end;
end;

function TValue.GetCurrency: Currency;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtCurrency) then
  begin
    Result := FBuffer.VCurrency;
  end else
  begin
    Result := InternalGetCurrency;
  end;
end;

function TValue.GetSingle: Single;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtFloat) then
  begin
    Result := FBuffer.VSingle;
  end else
  begin
    Result := InternalGetSingle;
  end;
end;

function TValue.GetDouble: Double;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtDouble) then
  begin
    Result := FBuffer.VDouble;
  end else
  begin
    Result := InternalGetDouble;
  end;
end;

function TValue.GetExtended: Extended;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType in [rtLongDouble80, rtLongDouble96, rtLongDouble128]) then
  begin
    Result := FBuffer.VLongDouble;
  end else
  begin
    Result := InternalGetExtended;
  end;
end;

function TValue.GetDate: TDate;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtDate) then
  begin
    Result := FBuffer.VDouble;
  end else
  begin
    Result := InternalGetDate;
  end;
end;

function TValue.GetTime: TTime;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtTime) then
  begin
    Result := FBuffer.VDouble;
  end else
  begin
    Result := InternalGetTime;
  end;
end;

function TValue.GetDateTime: TDateTime;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtDateTime) then
  begin
    Result := FBuffer.VDouble;
  end else
  begin
    Result := InternalGetDateTime;
  end;
end;

function TValue.GetTimeStamp: TimeStamp;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtTimeStamp) then
  begin
    Result := FBuffer.VInt64;
  end else
  begin
    Result := InternalGetTimeStamp;
  end;
end;

function TValue.GetAnsiString: AnsiString;
var
  LManagedData: Pointer;
  LSource: Pointer;
begin
  LManagedData := Pointer(FManagedData);
  if (Assigned(LManagedData)) and (FExType.BaseType = rtSBCSString) then
  begin
    LSource := @PRttiContainerInterface(LManagedData).Value;
    if (PPointer(LSource)^ <> Pointer(Result)) then
    begin
      RTTI_COPY_FUNCS[RTTI_COPYSTRING_FUNC](nil, @Result, LSource);
    end;
  end else
  begin
    InternalGetAnsiString(Result);
  end;
end;

function TValue.GetUnicodeString: UnicodeString;
var
  LManagedData: Pointer;
  LSource: Pointer;
begin
  LManagedData := Pointer(FManagedData);
  if (Assigned(LManagedData)) and (FExType.BaseType = rtUnicodeString) then
  begin
    LSource := @PRttiContainerInterface(LManagedData).Value;
    if (PPointer(LSource)^ <> Pointer(Result)) then
    begin
      RTTI_COPY_FUNCS[{$ifdef UNICODE}RTTI_COPYSTRING_FUNC{$else}RTTI_COPYWIDESTRING_FUNC{$endif}](nil, @Result, LSource);
    end;
  end else
  begin
    InternalGetUnicodeString(Result);
  end;
end;

function TValue.GetObject: TObject;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtObject) then
  begin
    Result := FBuffer.VPointer;
  end else
  begin
    Result := InternalGetObject;
  end;
end;

function TValue.GetInterface: IInterface;
var
  LManagedData: Pointer;
begin
  LManagedData := Pointer(FManagedData);
  if (not Assigned(LManagedData)) or (FExType.BaseType in [rtInterface, rtClosure]) then
  begin
    {$ifdef WEAKINTFREF}
      Pointer(Result) := LManagedData;
    {$else}
      if (LManagedData <> Pointer(Result)) then
      begin
        RTTI_COPY_FUNCS[RTTI_COPYINTERFACE_FUNC](nil, @Result, @FManagedData);
      end;
    {$endif}
  end else
  begin
    InternalGetInterface(Result);
  end;
end;

function TValue.GetClass: TClass;
begin
  if (Assigned(FManagedData)) and (FExType.BaseType = rtClassRef) then
  begin
    Result := FBuffer.VClass;
  end else
  begin
    Result := InternalGetClass;
  end;
end;

function TValue.GetBytes: TBytes;
var
  LManagedData: Pointer;
  LSource: Pointer;
begin
  LManagedData := Pointer(FManagedData);
  if (Assigned(LManagedData)) and (FExType.BaseType = rtBytes) then
  begin
    LSource := @PRttiContainerInterface(LManagedData).Value;
    if (PPointer(LSource)^ <> Pointer(Result)) then
    begin
      RTTI_COPY_FUNCS[RTTI_COPYDYNARRAY_FUNC](nil, @Result, LSource);
    end;
  end else
  begin
    InternalGetBytes(Result);
  end;
end;

function TValue.GetMethod: TMethod;
label
  failure;
begin
  if (not Assigned(FManagedData)) then goto failure;

  case (FExType.BaseType) of
    rtMethod: Result := FBuffer.VMethod;
  else
  failure:
    TinyError(teInvalidCast);
  end;
end;

function TValue.GetVarData: TVarData;
label
  get_pointer_value, failure;
begin
  Result.VType := varEmpty;
  if (not Assigned(FManagedData)) then goto failure;

  with Result do
  case (FExType.BaseType) of
    rtBoolean8,
    rtBool8:
    begin
      VType := varBoolean;
      VBoolean := (FBuffer.VUInt8 <> 0);
    end;
    rtBoolean16,
    rtBool16:
    begin
      VType := varBoolean;
      VBoolean := (FBuffer.VUInt16 <> 0);
    end;
    rtBoolean32,
    rtBool32:
    begin
      VType := varBoolean;
      VBoolean := (FBuffer.VUInt32 <> 0);
    end;
    rtBoolean64,
    rtBool64:
    begin
      VType := varBoolean;
      VBoolean := (FBuffer.VUInt64 <> 0);
    end;
    rtInt8,
    rtEnumeration8:
    begin
      VType := varShortInt;
      VShortInt := FBuffer.VInt8;
    end;
    rtUInt8:
    begin
      VType := varByte;
      VByte := FBuffer.VUInt8;
    end;
    rtInt16,
    rtEnumeration16:
    begin
      VType := varSmallInt;
      VSmallInt := FBuffer.VInt16;
    end;
    rtUInt16:
    begin
      VType := varWord;
      VWord := FBuffer.VUInt16;
    end;
    rtInt32,
    rtEnumeration32:
    begin
      VType := varInteger;
      VInteger := FBuffer.VInt32;
    end;
    rtUInt32:
    begin
      VType := varLongWord;
      VLongWord := FBuffer.VUInt32;
    end;
    rtInt64,
    rtComp,
    rtEnumeration64:
    begin
      VType := varInt64;
      VInt64 := FBuffer.VInt64;
    end;
    rtUInt64:
    begin
      VType := varUInt64;
      VInt64 := FBuffer.VInt64;
    end;
    rtCurrency:
    begin
      VType := varCurrency;
      VCurrency := FBuffer.VCurrency;
    end;
    rtFloat:
    begin
      VType := varSingle;
      VSingle := FBuffer.VSingle;
    end;
    rtDouble:
    begin
      VType := varDouble;
      VDouble := FBuffer.VDouble;
    end;
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128:
    begin
      VType := varDouble;
      VDouble := FBuffer.VLongDouble;
    end;
    {$endif}
    rtDate,
    rtTime,
    rtDateTime:
    begin
      VType := varDate;
      VDate := FBuffer.VDouble;
    end;
    rtTimeStamp:
    begin
      VType := varDate;
      VDate := (FBuffer.VInt64 - TIMESTAMP_DELTA) * TIMESTAMP_UNDAY;
    end;
    {$ifdef SHORTSTRSUPPORT}
    rtSBCSString:
    begin
      VType := varString;
      goto get_pointer_value;
    end;
    {$endif}
    {$ifdef UNICODE}
    rtUnicodeString:
    begin
      VType := varUString;
      goto get_pointer_value;
    end;
    {$endif}
    rtWideString:
    begin
      VType := varOleStr;
    get_pointer_value:
      VPointer := PPointer(GetData)^;
    end;
    rtInterface:
    begin
      VType := varDispatch;
      VDispatch := Pointer(FManagedData);
    end;
  else
  failure:
    TinyError(teInvalidCast);
  end;
end;

function TValue.GetVarRec: TVarRec;
label
  get_pointer_value, get_pointer, failure;
var
  LInt64Value: PInt64;
begin
  Result.VType := 0;
  if (not Assigned(FManagedData)) then goto failure;

  with Result do
  case (FExType.BaseType) of
    rtPointer:
    begin
      VType := vtPointer;
      VPointer := FBuffer.VPointer;
    end;
    rtBoolean8,
    rtBool8:
    begin
      VType := vtBoolean;
      VBoolean := (FBuffer.VUInt8 <> 0);
    end;
    rtBoolean16,
    rtBool16:
    begin
      VType := vtBoolean;
      VBoolean := (FBuffer.VUInt16 <> 0);
    end;
    rtBoolean32,
    rtBool32:
    begin
      VType := vtBoolean;
      VBoolean := (FBuffer.VUInt32 <> 0);
    end;
    rtBoolean64,
    rtBool64:
    begin
      VType := vtBoolean;
      VBoolean := (FBuffer.VUInt64 <> 0);
    end;
    rtInt8:
    begin
      VType := vtInteger;
      VInteger := FBuffer.VInt8;
    end;
    rtUInt8:
    begin
      VType := vtInteger;
      VInteger := FBuffer.VUInt8;
    end;
    rtInt16:
    begin
      VType := vtInteger;
      VInteger := FBuffer.VInt16;
    end;
    rtUInt16:
    begin
      VType := vtInteger;
      VInteger := FBuffer.VUInt16;
    end;
    rtInt32:
    begin
      VType := vtInteger;
      VInteger := FBuffer.VInt32;
    end;
    rtUInt32:
    begin
      if (FBuffer.VInt32 >= 0) then
      begin
        VType := vtInteger;
        VInteger := FBuffer.VInt32;
      end else
      begin
        LInt64Value := Pointer(@FBuffer.VBytes[SizeOf(Integer)]);
        LInt64Value^ := FBuffer.VInt32;
        VType := vtInt64;
        VInt64 := LInt64Value;
      end;
    end;
    rtInt64, rtUInt64:
    begin
      VType := vtInt64;
      VInt64 := @FBuffer.VInt64;
    end;
    {$ifdef EXTENDEDSUPPORT}
    rtLongDouble80,
    rtLongDouble96,
    rtLongDouble128:
    begin
      VType := vtExtended;
      VExtended := @FBuffer.VLongDouble;
    end;
    {$endif}
    rtCurrency:
    begin
      VType := vtCurrency;
      VCurrency := @FBuffer.VCurrency;
    end;
    rtSBCSChar,
    rtUTF8Char:
    begin
      VType := vtChar;
      VChar := AnsiChar(FBuffer.VUInt8);
    end;
    rtWideChar:
    begin
      VType := vtWideChar;
      VWideChar := WideChar(FBuffer.VUInt16);
    end;
    rtShortString:
    begin
      VType := vtString;
      goto get_pointer;
    end;
    rtSBCSString:
    begin
      VType := vtAnsiString;
      goto get_pointer_value;
    end;
    rtWideString:
    begin
      VType := vtWideString;
      goto get_pointer_value;
    end;
    {$ifdef UNICODE}
    rtUnicodeString:
    begin
      VType := vtUnicodeString;
      goto get_pointer_value;
    end;
    {$endif}
    rtObject:
    begin
      VType := vtObject;
      VPointer := FBuffer.VPointer;
    end;
    rtInterface:
    begin
      VType := vtInterface;
    get_pointer_value:
      VInterface := PPointer(GetData)^;
    end;
    rtClassRef:
    begin
      VType := vtClass;
      VClass := FBuffer.VClass;
    end;
    rtOleVariant, rtVariant:
    begin
      VType := vtVariant;
    get_pointer:
      VPointer := GetData;
    end;
  else
  failure:
    TinyError(teInvalidCast);
  end;
end;

{$ifdef VALUEOPERATORSUPPORT}
class operator TValue.Implicit(const AValue: Pointer): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VPointer := AValue;
  Result.FExType.Options := Ord(rtPointer);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: Boolean): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VBoolean := AValue;
  Result.FExType.Options := Ord(rtBoolean8);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: Integer): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VInt32 := AValue;
  Result.FExType.Options := Ord(rtInt32);
  Result.FExType.RangeData := @INT32_TYPE_DATA;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: Cardinal): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VUInt32 := AValue;
  Result.FExType.Options := Ord(rtUInt32);
  Result.FExType.RangeData := @UINT32_TYPE_DATA;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: Int64): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VInt64 := AValue;
  Result.FExType.Options := Ord(rtInt64);
  Result.FExType.RangeData := @INT64_TYPE_DATA;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: UInt64): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VUInt64 := AValue;
  Result.FExType.Options := Ord(rtUInt64);
  Result.FExType.RangeData := @UINT64_TYPE_DATA;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: Currency): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VCurrency := AValue;
  Result.FExType.Options := Ord(rtCurrency);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: Single): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VSingle := AValue;
  Result.FExType.Options := Ord(rtFloat);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: Double): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VDouble := AValue;
  Result.FExType.Options := Ord(rtDouble);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

{$ifdef EXTENDEDSUPPORT}
class operator TValue.Implicit(const AValue: Extended): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VLongDouble := AValue;
  Result.FExType.Options := Ord(rtLongDouble80);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;
{$endif}

class operator TValue.Implicit(const AValue: TDate): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VDouble := AValue;
  Result.FExType.Options := Ord(rtDate);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: TTime): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VDouble := AValue;
  Result.FExType.Options := Ord(rtTime);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: TDateTime): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VDouble := AValue;
  Result.FExType.Options := Ord(rtDateTime);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: TimeStamp): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VInt64 := AValue;
  Result.FExType.Options := Ord(rtTimeStamp);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: AnsiString): TValue;
var
  LManagedData: Pointer;
  LTarget: Pointer;
  LStored: record
    Source: NativeUInt;
  end;
begin
  LStored.Source := NativeUInt(Pointer(AValue));

  if (Result.FExType.Options = DefaultSBCSStringOptions) then
  begin
    LManagedData := Pointer(Result.FManagedData);
    if (Assigned(LManagedData)) then
    begin
      LTarget := @PRttiContainerInterface(LManagedData).Value;
      if (PPointer(LTarget)^ <> Pointer(AValue)) then
      begin
        RTTI_COPY_FUNCS[RTTI_COPYSTRING_FUNC](nil, LTarget, @LStored.Source);
      end;
      Exit;
    end;
  end else
  begin
    Result.FExType.Options := DefaultSBCSStringOptions;
  end;

  Result.FExType.CustomData := nil;
  Result.InternalInitData(RTTI_TYPE_RULES[rtSBCSString], @LStored.Source);
end;

class operator TValue.Implicit(const AValue: UnicodeString): TValue;
var
  LManagedData: Pointer;
  LTarget: Pointer;
  LStored: record
    Source: NativeUInt;
  end;
begin
  LStored.Source := NativeUInt(Pointer(AValue));

  if (Result.FExType.Options = Ord(rtUnicodeString)) then
  begin
    LManagedData := Pointer(Result.FManagedData);
    if (Assigned(LManagedData)) then
    begin
      LTarget := @PRttiContainerInterface(LManagedData).Value;
      if (PPointer(LTarget)^ <> Pointer(AValue)) then
      begin
        RTTI_COPY_FUNCS[{$ifdef UNICODE}RTTI_COPYSTRING_FUNC{$else}RTTI_COPYWIDESTRING_FUNC{$endif}](nil, LTarget, @LStored.Source);
      end;
      Exit;
    end;
  end else
  begin
    Result.FExType.Options := Ord(rtUnicodeString);
  end;

  Result.FExType.CustomData := nil;
  Result.InternalInitData(RTTI_TYPE_RULES[rtUnicodeString], @LStored.Source);
end;

class operator TValue.Implicit(const AValue: TObject): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VPointer := AValue;
  Result.FExType.Options := Ord(rtObject);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: IInterface): TValue;
var
  LStored: record
    Source: NativeUInt;
  end;
begin
  Result.FExType.Options := Ord(rtInterface);
  Result.FExType.CustomData := nil;
  if (Pointer(Result.FManagedData) <> Pointer(AValue)) then
  begin
    LStored.Source := NativeUInt(Pointer(AValue));
    RTTI_COPY_FUNCS[RTTI_COPYINTERFACE_FUNC](nil, @Result.FManagedData, @LStored.Source);
  end;
end;

class operator TValue.Implicit(const AValue: TClass): TValue;
var
  LManagedData: Pointer;
begin
  Result.FBuffer.VClass := AValue;
  Result.FExType.Options := Ord(rtClassRef);
  Result.FExType.CustomData := nil;

  LManagedData := Pointer(Result.FManagedData);
  if (LManagedData <> @DUMMY_INTERFACE_DATA) then
  begin
    Pointer(Result.FManagedData) := @DUMMY_INTERFACE_DATA;
    if (Assigned(LManagedData)) then
    begin
      Result.InternalReleaseInterface(LManagedData);
    end;
  end;
end;

class operator TValue.Implicit(const AValue: TBytes): TValue;
var
  LManagedData: Pointer;
  LTarget: Pointer;
  LStored: record
    Source: NativeUInt;
  end;
begin
  LStored.Source := NativeUInt(Pointer(AValue));

  if (Result.FExType.Options = Ord(rtBytes)) then
  begin
    LManagedData := Pointer(Result.FManagedData);
    if (Assigned(LManagedData)) then
    begin
      LTarget := @PRttiContainerInterface(LManagedData).Value;
      if (PPointer(LTarget)^ <> Pointer(AValue)) then
      begin
        RTTI_COPY_FUNCS[RTTI_COPYDYNARRAY_FUNC](nil, LTarget, @LStored.Source);
      end;
      Exit;
    end;
  end else
  begin
    Result.FExType.Options := Ord(rtBytes);
  end;

  Result.FExType.CustomData := nil;
  Result.InternalInitData(RTTI_TYPE_RULES[rtBytes], @LStored.Source);
end;

class operator TValue.Implicit(const AValue: TValue): Pointer;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtPointer) then
  begin
    Result := AValue.FBuffer.VPointer;
  end else
  begin
    Result := AValue.InternalGetPointer;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): Boolean;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtBoolean8) then
  begin
    Result := AValue.FBuffer.VBoolean;
  end else
  begin
    Result := AValue.InternalGetBoolean;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): Integer;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtInt32) then
  begin
    Result := AValue.FBuffer.VInt32;
  end else
  begin
    Result := AValue.InternalGetInteger;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): Cardinal;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtUInt32) then
  begin
    Result := AValue.FBuffer.VUInt32;
  end else
  begin
    Result := AValue.InternalGetCardinal;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): Int64;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtInt64) then
  begin
    Result := AValue.FBuffer.VInt64;
  end else
  begin
    Result := AValue.InternalGetInt64;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): UInt64;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtUInt64) then
  begin
    Result := AValue.FBuffer.VUInt64;
  end else
  begin
    Result := AValue.InternalGetUInt64;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): Currency;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtCurrency) then
  begin
    Result := AValue.FBuffer.VCurrency;
  end else
  begin
    Result := AValue.InternalGetCurrency;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): Single;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtFloat) then
  begin
    Result := AValue.FBuffer.VSingle;
  end else
  begin
    Result := AValue.InternalGetSingle;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): Double;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtDouble) then
  begin
    Result := AValue.FBuffer.VDouble;
  end else
  begin
    Result := AValue.InternalGetDouble;
  end;
end;

{$ifdef EXTENDEDSUPPORT}
class operator TValue.Implicit(const AValue: TValue): Extended;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType in [rtLongDouble80, rtLongDouble96, rtLongDouble128]) then
  begin
    Result := AValue.FBuffer.VLongDouble;
  end else
  begin
    Result := AValue.InternalGetExtended;
  end;
end;
{$endif}

class operator TValue.Implicit(const AValue: TValue): TDate;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtDate) then
  begin
    Result := AValue.FBuffer.VDouble;
  end else
  begin
    Result := AValue.InternalGetDate;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): TTime;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtTime) then
  begin
    Result := AValue.FBuffer.VDouble;
  end else
  begin
    Result := AValue.InternalGetTime;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): TDateTime;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtDateTime) then
  begin
    Result := AValue.FBuffer.VDouble;
  end else
  begin
    Result := AValue.InternalGetDateTime;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): TimeStamp;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtTimeStamp) then
  begin
    Result := AValue.FBuffer.VInt64;
  end else
  begin
    Result := AValue.InternalGetTimeStamp;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): AnsiString;
var
  LManagedData: Pointer;
  LSource: Pointer;
begin
  LManagedData := Pointer(AValue.FManagedData);
  if (Assigned(LManagedData)) and (AValue.FExType.BaseType = rtSBCSString) then
  begin
    LSource := @PRttiContainerInterface(LManagedData).Value;
    if (PPointer(LSource)^ <> Pointer(Result)) then
    begin
      RTTI_COPY_FUNCS[RTTI_COPYSTRING_FUNC](nil, @Result, LSource);
    end;
  end else
  begin
    AValue.InternalGetAnsiString(Result);
  end;
end;

class operator TValue.Implicit(const AValue: TValue): UnicodeString;
var
  LManagedData: Pointer;
  LSource: Pointer;
begin
  LManagedData := Pointer(AValue.FManagedData);
  if (Assigned(LManagedData)) and (AValue.FExType.BaseType = rtUnicodeString) then
  begin
    LSource := @PRttiContainerInterface(LManagedData).Value;
    if (PPointer(LSource)^ <> Pointer(Result)) then
    begin
      RTTI_COPY_FUNCS[{$ifdef UNICODE}RTTI_COPYSTRING_FUNC{$else}RTTI_COPYWIDESTRING_FUNC{$endif}](nil, @Result, LSource);
    end;
  end else
  begin
    AValue.InternalGetUnicodeString(Result);
  end;
end;

class operator TValue.Implicit(const AValue: TValue): TObject;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtObject) then
  begin
    Result := AValue.FBuffer.VPointer;
  end else
  begin
    Result := AValue.InternalGetObject;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): IInterface;
var
  LManagedData: Pointer;
begin
  LManagedData := Pointer(AValue.FManagedData);
  if (not Assigned(LManagedData)) or (AValue.FExType.BaseType in [rtInterface, rtClosure]) then
  begin
    {$ifdef WEAKINTFREF}
      Pointer(Result) := LManagedData;
    {$else}
      if (LManagedData <> Pointer(Result)) then
      begin
        RTTI_COPY_FUNCS[RTTI_COPYINTERFACE_FUNC](nil, @Result, @AValue.FManagedData);
      end;
    {$endif}
  end else
  begin
    AValue.InternalGetInterface(Result);
  end;
end;

class operator TValue.Implicit(const AValue: TValue): TClass;
begin
  if (Assigned(AValue.FManagedData)) and (AValue.FExType.BaseType = rtClassRef) then
  begin
    Result := AValue.FBuffer.VClass;
  end else
  begin
    Result := AValue.InternalGetClass;
  end;
end;

class operator TValue.Implicit(const AValue: TValue): TBytes;
var
  LManagedData: Pointer;
  LSource: Pointer;
begin
  LManagedData := Pointer(AValue.FManagedData);
  if (Assigned(LManagedData)) and (AValue.FExType.BaseType = rtBytes) then
  begin
    LSource := @PRttiContainerInterface(LManagedData).Value;
    if (PPointer(LSource)^ <> Pointer(Result)) then
    begin
      RTTI_COPY_FUNCS[RTTI_COPYDYNARRAY_FUNC](nil, @Result, LSource);
    end;
  end else
  begin
    AValue.InternalGetBytes(Result);
  end;
end;
{$endif}

initialization
  if (NativeInt(@InternalRttiTypeCurrentGroup) and 3 <> 0) or (NativeInt(@InternalRttiTypeCurrent) and 3 <> 0) then
  begin
    TinyError(teInvalidPtr);
  end;

  if (not Assigned(DefaultContext.Vmt)) then
  begin
    DefaultContext.Init; // + InitLibray
  end;

finalization
  DefaultContext.Finalize;

end.
