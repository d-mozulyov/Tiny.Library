unit Tiny.Cache.Text;

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
{ previous location: https://github.com/d-mozulyov/CachedTexts                 }
{******************************************************************************}

{$I TINY.DEFINES.inc}

interface
uses
  {$ifdef UNITSCOPENAMES}System.Types, System.SysConst{$else}Types, SysConst{$endif},
  {$ifdef MSWINDOWS}
    {$ifdef UNITSCOPENAMES}Winapi.Windows, Winapi.ActiveX{$else}Windows, ActiveX{$endif},
  {$else .POSIX}
    {$ifdef FPC}
      BaseUnix,
    {$else}
      Posix.String_, Posix.SysStat, Posix.Unistd,
    {$endif}
  {$endif}
  {$ifdef UNITSCOPENAMES}System.SysUtils{$else}SysUtils{$endif},
  Tiny.Types, Tiny.Cache.Buffers, Tiny.Text;


type

  ECachedText = class(Exception);

  PTinyStringKind = ^TTinyStringKind;
  TTinyStringKind = (csNone, csByte, csUTF16, csUTF32);

  PByteString = ^ByteString;
  PUTF16String = ^UTF16String;
  PUTF32String = ^UTF32String;

  ETinyString = class(EConvertError)
  public
    constructor Create(const ResStringRec: PResStringRec); overload;
    constructor Create(const ResStringRec: PResStringRec; const Value: PByteString); overload;
    constructor Create(const ResStringRec: PResStringRec; const Value: PUTF16String); overload;
    constructor Create(const ResStringRec: PResStringRec; const Value: PUTF32String); overload;
  end;

  PtrString = record
    Chars: Pointer;
    Length: NativeUInt;
  end;
  PPtrString = PtrString;

  TinyString = record
    Chars: Pointer;
    Length: NativeUInt;
    case Integer of
      0: (Flags: Cardinal);
      1: (Ascii, References: Boolean; Tag: Byte; SBCSIndex: ShortInt);
      2: (NativeFlags: NativeUInt);
  end;
  PTinyString = ^TinyString;

  TCachedEncoding = record
  case Integer of
    0: (Flags: Cardinal);
    1: (CodePage: Word; StringKind: TTinyStringKind; SBCSIndex: ShortInt);
    2: (NativeFlags: NativeUInt);
  end;
  PCachedEncoding = ^TCachedEncoding;

  TDigitsRec = packed record
    Ascii: array[0..31] of Byte;
    Buffer: array[0..15] of Byte;
    Quads: array[0..4] of Cardinal;
  end;
  PDigitsRec = ^TDigitsRec;


{ ByteString record }

  ByteString = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FChars: PAnsiChar;
    FLength: NativeUInt;
    F: packed record
    case Integer of
      0: (Flags: Cardinal);
      1: (Ascii, References: Boolean; Tag: Byte; SBCSIndex: ShortInt);
      2: (NativeFlags: NativeUInt);
    end;

    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEmpty(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetSBCS: PTextConvSBCS; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetSBCS(Value: PTextConvSBCS); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUTF8: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetUTF8(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetEncoding: Word; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEncoding(CodePage: Word);
    function _TrimLeft(S: PByte; L: NativeUInt): Boolean;
    function _TrimRight(S: PByte; H: NativeUInt): Boolean;
    function _Trim(S: PByte; H: NativeUInt): Boolean;
    function _HashIgnoreCaseAscii: Cardinal;
    function _HashIgnoreCaseUTF8: Cardinal;
    function _HashIgnoreCase(NF: NativeUInt): Cardinal;
    function _PosIgnoreCaseUTF8(const S: ByteString; const From: NativeUInt): NativeInt;
    function _PosIgnoreCase(const S: ByteString; const From: NativeUInt): NativeInt;
    function _GetBool(S: PByte; L: NativeUInt): Boolean;
    function _GetHex(S: PByte; L: NativeInt): Integer;
    function _GetInt(S: PByte; L: NativeInt): Integer;
    function _GetInt_19(S: PByte; L: NativeUInt): NativeInt;
    function _GetHex64(S: PByte; L: NativeInt): Int64;
    function _GetInt64(S: PByte; L: NativeInt): Int64;
    function _GetFloat(S: PByte; L: NativeUInt): Extended;
    function _GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
    function _GetDateTimeException(DT: NativeUInt): ETinyString;
    function _CompareByteString(const S: PByteString; const IgnoreCase: Boolean): NativeInt;
    function _CompareUTF16String(const S: PUTF16String; const IgnoreCase: Boolean): NativeInt;
  public
    property Chars: PAnsiChar read FChars write FChars;
    property Length: NativeUInt read FLength write FLength;
    property Empty: Boolean read GetEmpty write SetEmpty;
    property Ascii: Boolean read F.Ascii write F.Ascii;
    property References: Boolean read F.References write F.References;
    property Tag: Byte read F.Tag write F.Tag;
    property Flags: Cardinal read F.Flags write F.Flags;
    property SBCSIndex: ShortInt read F.SBCSIndex write F.SBCSIndex;
    property SBCS: PTextConvSBCS read GetSBCS write SetSBCS;
    property UTF8: Boolean read GetUTF8 write SetUTF8;
    property Encoding: Word read GetEncoding write SetEncoding;

    procedure Assign(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    procedure Assign(const S: UTF8String); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$else}
    procedure AssignUTF8(const S: UTF8String);
    {$endif}
    procedure Assign(const S: ShortString; const CodePage: Word = 0); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: TBytes; const CodePage: Word = 0); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Delete(const From, Count: NativeUInt); {$ifdef INLINESUPPORT}inline;{$endif}

    function DetermineAscii: Boolean;
    function TrimLeft: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TrimRight: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Trim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const From, Count: NativeUInt): ByteString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): ByteString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Skip(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifNdef CPUINTELASM}inline;{$endif}

    function CharPos(const C: AnsiChar; const From: NativeUInt = 0): NativeInt;
    function CharPosIgnoreCase(const C: AnsiChar; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: ByteString; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const AChars: PAnsiChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Pos(const S: AnsiString; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const S: ByteString; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const AChars: PAnsiChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const S: AnsiString; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    function ToBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToBooleanDef(const Default: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToBoolean(out Value: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHexDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToIntegerDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInteger(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinalDef(const Default: Cardinal): Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToCardinal(out Value: Cardinal): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInt64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64Def(const Default: UInt64): UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToUInt64(out Value: UInt64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloat: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloatDef(const Default: Extended): Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Single): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Double): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$if (not Defined(FPC)) or Defined(EXTENDEDSUPPORT)}
    function TryToFloat(out Value: Extended): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifend}
    function ToDate: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDate(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDateTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    procedure ToAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToLowerAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToUpperAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToLowerAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUpperAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUTF8String(var S: UTF8String); overload;
    procedure ToLowerUTF8String(var S: UTF8String); overload;
    procedure ToUpperUTF8String(var S: UTF8String); overload;
    procedure ToUTF8ShortString(var S: ShortString);
    procedure ToLowerUTF8ShortString(var S: ShortString);
    procedure ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString(var S: WideString); overload;
    procedure ToLowerWideString(var S: WideString); overload;
    procedure ToUpperWideString(var S: WideString); overload;
    procedure ToUnicodeString(var S: UnicodeString); overload;
    procedure ToLowerUnicodeString(var S: UnicodeString); overload;
    procedure ToUpperUnicodeString(var S: UnicodeString); overload;
    procedure ToString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToLowerString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToUpperString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function ToAnsiString: AnsiString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerAnsiString: AnsiString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperAnsiString: AnsiString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUTF8String: UTF8String; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerUTF8String: UTF8String; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperUTF8String: UTF8String; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToWideString: WideString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerWideString: WideString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperWideString: WideString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUnicodeString: UnicodeString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerUnicodeString: UnicodeString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperUnicodeString: UnicodeString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToString: string; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerString: string; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperString: string; overload; {$ifNdef CPUINTELASM}inline;{$endif}

    {$ifdef OPERATORSUPPORT}
    class operator Implicit(const a: ByteString): AnsiString; {$ifNdef CPUINTELASM}inline;{$endif}
    class operator Implicit(const a: ByteString): WideString; {$ifNdef CPUINTELASM}inline;{$endif}
    {$ifdef UNICODE}
    class operator Implicit(const a: ByteString): UTF8String; {$ifNdef CPUINTELASM}inline;{$endif}
    class operator Implicit(const a: ByteString): UnicodeString; {$ifNdef CPUINTELASM}inline;{$endif}
    {$endif}
    {$endif}
  public
    function Equal(const S: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: ByteString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: ByteString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function Equal(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    function Equal(const S: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Equal(const S: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: UnicodeString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: UnicodeString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$else .AmbiguousOverloadedFix}
    function EqualUTF8(const S: UTF8String): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualUTF8IgnoreCase(const S: UTF8String): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareUTF8(const S: UTF8String): NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareUTF8IgnoreCase(const S: UTF8String): NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function Equal(const S: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: WideString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: WideString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function Equal(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean; overload;
    function EqualIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean; overload;
    function Compare(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt; overload;
    function CompareIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt; overload;
    function Equal(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    {$ifdef OPERATORSUPPORT}
    class operator Equal(const a: ByteString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: ByteString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: ByteString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: ByteString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: ByteString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: ByteString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    class operator Equal(const a: ByteString; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: ByteString; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: ByteString; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: ByteString; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: ByteString; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: ByteString; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: ByteString; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: ByteString; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: ByteString; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: ByteString; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: ByteString; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: ByteString; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    class operator Equal(const a: ByteString; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: ByteString; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: ByteString; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: ByteString; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: ByteString; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: ByteString; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: ByteString; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: ByteString; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: ByteString; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: ByteString; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: ByteString; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: ByteString; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    class operator Equal(const a: AnsiString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: AnsiString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: AnsiString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: AnsiString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: AnsiString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: AnsiString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: WideString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: WideString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: WideString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: WideString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: WideString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: WideString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    class operator Equal(const a: UTF8String; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF8String; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF8String; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF8String; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF8String; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF8String; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: UnicodeString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UnicodeString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UnicodeString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UnicodeString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UnicodeString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UnicodeString; const b: ByteString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    {$endif}
  end;


{ UTF16String record }

  UTF16String = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FChars: PUnicodeChar;
    FLength: NativeUInt;
    F: packed record
    case Integer of
      0: (Flags: Cardinal);
      1: (Ascii, References: Boolean; Tag: Byte);
      2: (NativeFlags: NativeUInt);
    end;

    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEmpty(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function _TrimLeft(S: PWord; L: NativeUInt): Boolean;
    function _TrimRight(S: PWord; H: NativeUInt): Boolean;
    function _Trim(S: PWord; H: NativeUInt): Boolean;
    function _HashIgnoreCaseAscii: Cardinal;
    function _HashIgnoreCase: Cardinal;
    function _GetBool(S: PWord; L: NativeUInt): Boolean;
    function _GetHex(S: PWord; L: NativeInt): Integer;
    function _GetInt(S: PWord; L: NativeInt): Integer;
    function _GetInt_19(S: PWord; L: NativeUInt): NativeInt;
    function _GetHex64(S: PWord; L: NativeInt): Int64;
    function _GetInt64(S: PWord; L: NativeInt): Int64;
    function _GetFloat(S: PWord; L: NativeUInt): Extended;
    function _GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
    function _GetDateTimeException(DT: NativeUInt): ETinyString;
    function _CompareUTF16String(const S: PUTF16String; const IgnoreCase: Boolean): NativeInt;
  public
    property Chars: PUnicodeChar read FChars write FChars;
    property Length: NativeUInt read FLength write FLength;
    property Empty: Boolean read GetEmpty write SetEmpty;
    property Ascii: Boolean read F.Ascii write F.Ascii;
    property References: Boolean read F.References write F.References;
    property Tag: Byte read F.Tag write F.Tag;
    property Flags: Cardinal read F.Flags write F.Flags;

    procedure Assign(const AChars: PUnicodeChar; const ALength: NativeUInt); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef MSWINDOWS}
    procedure Assign(const S: WideString); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    {$ifdef UNICODE}
    procedure Assign(const S: UnicodeString); overload; inline;
    {$endif}
    procedure Delete(const From, Count: NativeUInt); {$ifdef INLINESUPPORT}inline;{$endif}

    function DetermineAscii: Boolean;
    function TrimLeft: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TrimRight: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Trim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const From, Count: NativeUInt): UTF16String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): UTF16String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Skip(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}

    function CharPos(const C: UnicodeChar; const From: NativeUInt = 0): NativeInt;
    function CharPosIgnoreCase(const C: UnicodeChar; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: UTF16String; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const AChars: PUnicodeChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Pos(const S: UnicodeString; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const S: UTF16String; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const S: UnicodeString; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    function ToBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToBooleanDef(const Default: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToBoolean(out Value: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHexDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToIntegerDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInteger(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinalDef(const Default: Cardinal): Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToCardinal(out Value: Cardinal): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInt64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64Def(const Default: UInt64): UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToUInt64(out Value: UInt64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloat: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloatDef(const Default: Extended): Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Single): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Double): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$if (not Defined(FPC)) or Defined(EXTENDEDSUPPORT)}
    function TryToFloat(out Value: Extended): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifend}
    function ToDate: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDate(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDateTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    procedure ToAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToLowerAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToUpperAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToLowerAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUpperAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUTF8String(var S: UTF8String); overload;
    procedure ToLowerUTF8String(var S: UTF8String); overload;
    procedure ToUpperUTF8String(var S: UTF8String); overload;
    procedure ToUTF8ShortString(var S: ShortString);
    procedure ToLowerUTF8ShortString(var S: ShortString);
    procedure ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString(var S: WideString); overload;
    procedure ToLowerWideString(var S: WideString); overload;
    procedure ToUpperWideString(var S: WideString); overload;
    procedure ToUnicodeString(var S: UnicodeString); overload;
    procedure ToLowerUnicodeString(var S: UnicodeString); overload;
    procedure ToUpperUnicodeString(var S: UnicodeString); overload;
    procedure ToString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToLowerString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToUpperString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function ToAnsiString: AnsiString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerAnsiString: AnsiString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperAnsiString: AnsiString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUTF8String: UTF8String; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerUTF8String: UTF8String; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperUTF8String: UTF8String; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToWideString: WideString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerWideString: WideString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperWideString: WideString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUnicodeString: UnicodeString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerUnicodeString: UnicodeString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperUnicodeString: UnicodeString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToString: string; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerString: string; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperString: string; overload; {$ifNdef CPUINTELASM}inline;{$endif}

    {$ifdef OPERATORSUPPORT}
    class operator Implicit(const a: UTF16String): AnsiString; {$ifNdef CPUINTELASM}inline;{$endif}
    class operator Implicit(const a: UTF16String): WideString; {$ifNdef CPUINTELASM}inline;{$endif}
    {$ifdef UNICODE}
    class operator Implicit(const a: UTF16String): UTF8String; {$ifNdef CPUINTELASM}inline;{$endif}
    class operator Implicit(const a: UTF16String): UnicodeString; {$ifNdef CPUINTELASM}inline;{$endif}
    {$endif}
    {$endif}
  public
    function Equal(const S: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: UTF16String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: UTF16String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function Equal(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    function Equal(const S: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Equal(const S: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: UnicodeString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: UnicodeString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$else .AmbiguousOverloadedFix}
    function EqualUTF8(const S: UTF8String): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualUTF8IgnoreCase(const S: UTF8String): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareUTF8(const S: UTF8String): NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareUTF8IgnoreCase(const S: UTF8String): NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function Equal(const S: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: WideString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: WideString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function Equal(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean; overload;
    function EqualIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean; overload;
    function Compare(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt; overload;
    function CompareIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt; overload;
    function Equal(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    {$ifdef OPERATORSUPPORT}
    class operator Equal(const a: UTF16String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF16String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF16String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF16String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF16String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF16String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    class operator Equal(const a: UTF16String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF16String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF16String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF16String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF16String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF16String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: UTF16String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF16String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF16String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF16String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF16String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF16String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    class operator Equal(const a: UTF16String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF16String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF16String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF16String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF16String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF16String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: UTF16String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF16String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF16String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF16String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF16String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF16String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    class operator Equal(const a: AnsiString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: AnsiString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: AnsiString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: AnsiString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: AnsiString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: AnsiString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: WideString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: WideString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: WideString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: WideString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: WideString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: WideString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    class operator Equal(const a: UTF8String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF8String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF8String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF8String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF8String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF8String; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: UnicodeString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UnicodeString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UnicodeString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UnicodeString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UnicodeString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UnicodeString; const b: UTF16String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    {$endif}
  end;


{ UTF32String record }

  UTF32String = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FChars: PUCS4Char;
    FLength: NativeUInt;
    F: packed record
    case Integer of
      0: (Flags: Cardinal);
      1: (Ascii, References: Boolean; Tag: Byte);
      2: (NativeFlags: NativeUInt);
    end;

    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEmpty(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function _TrimLeft(S: PCardinal; L: NativeUInt): Boolean;
    function _TrimRight(S: PCardinal; H: NativeUInt): Boolean;
    function _Trim(S: PCardinal; H: NativeUInt): Boolean;
    function _HashIgnoreCaseAscii: Cardinal;
    function _HashIgnoreCase: Cardinal;
    function _GetBool(S: PCardinal; L: NativeUInt): Boolean;
    function _GetHex(S: PCardinal; L: NativeInt): Integer;
    function _GetInt(S: PCardinal; L: NativeInt): Integer;
    function _GetInt_19(S: PCardinal; L: NativeUInt): NativeInt;
    function _GetHex64(S: PCardinal; L: NativeInt): Int64;
    function _GetInt64(S: PCardinal; L: NativeInt): Int64;
    function _GetFloat(S: PCardinal; L: NativeUInt): Extended;
    function _GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
    function _GetDateTimeException(DT: NativeUInt): ETinyString;
    function _CompareByteString(const S: PByteString; const IgnoreCase: Boolean): NativeInt;
    function _CompareUTF16String(const S: PUTF16String; const IgnoreCase: Boolean): NativeInt;
    function _CompareUTF32String(const S: PUTF32String; const IgnoreCase: Boolean): NativeInt;
  public
    property Chars: PUCS4Char read FChars write FChars;
    property Length: NativeUInt read FLength write FLength;
    property Empty: Boolean read GetEmpty write SetEmpty;
    property Ascii: Boolean read F.Ascii write F.Ascii;
    property References: Boolean read F.References write F.References;
    property Tag: Byte read F.Tag write F.Tag;
    property Flags: Cardinal read F.Flags write F.Flags;

    procedure Assign(const AChars: PUCS4Char; const ALength: NativeUInt); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: UCS4String; const NullTerminated: Boolean = False); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Delete(const From, Count: NativeUInt); {$ifdef INLINESUPPORT}inline;{$endif}

    function DetermineAscii: Boolean;
    function TrimLeft: Boolean;
    function TrimRight: Boolean;
    function Trim: Boolean;
    function SubString(const From, Count: NativeUInt): UTF32String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): UTF32String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Skip(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}

    function CharPos(const C: UCS4Char; const From: NativeUInt = 0): NativeInt;
    function CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: UTF32String; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const AChars: PUCS4Char; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Pos(const S: UCS4String; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const S: UTF32String; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const AChars: PUCS4Char; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const S: UCS4String; const From: NativeUInt = 0): NativeInt; overload;
  public
    function ToBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToBooleanDef(const Default: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToBoolean(out Value: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHexDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToIntegerDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInteger(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinalDef(const Default: Cardinal): Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToCardinal(out Value: Cardinal): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInt64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64Def(const Default: UInt64): UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToUInt64(out Value: UInt64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloat: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloatDef(const Default: Extended): Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Single): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Double): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$if (not Defined(FPC)) or Defined(EXTENDEDSUPPORT)}
    function TryToFloat(out Value: Extended): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifend}
    function ToDate: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDate(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDateTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    procedure ToAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToLowerAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToUpperAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToLowerAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUpperAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUTF8String(var S: UTF8String); overload;
    procedure ToLowerUTF8String(var S: UTF8String); overload;
    procedure ToUpperUTF8String(var S: UTF8String); overload;
    procedure ToUTF8ShortString(var S: ShortString);
    procedure ToLowerUTF8ShortString(var S: ShortString);
    procedure ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString(var S: WideString); overload;
    procedure ToLowerWideString(var S: WideString); overload;
    procedure ToUpperWideString(var S: WideString); overload;
    procedure ToUnicodeString(var S: UnicodeString); overload;
    procedure ToLowerUnicodeString(var S: UnicodeString); overload;
    procedure ToUpperUnicodeString(var S: UnicodeString); overload;
    procedure ToString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToLowerString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToUpperString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function ToAnsiString: AnsiString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerAnsiString: AnsiString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperAnsiString: AnsiString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUTF8String: UTF8String; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerUTF8String: UTF8String; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperUTF8String: UTF8String; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToWideString: WideString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerWideString: WideString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperWideString: WideString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUnicodeString: UnicodeString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerUnicodeString: UnicodeString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperUnicodeString: UnicodeString; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToString: string; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToLowerString: string; overload; {$ifNdef CPUINTELASM}inline;{$endif}
    function ToUpperString: string; overload; {$ifNdef CPUINTELASM}inline;{$endif}

    {$ifdef OPERATORSUPPORT}
    class operator Implicit(const a: UTF32String): AnsiString; {$ifNdef CPUINTELASM}inline;{$endif}
    class operator Implicit(const a: UTF32String): WideString; {$ifNdef CPUINTELASM}inline;{$endif}
    {$ifdef UNICODE}
    class operator Implicit(const a: UTF32String): UTF8String; {$ifNdef CPUINTELASM}inline;{$endif}
    class operator Implicit(const a: UTF32String): UnicodeString; {$ifNdef CPUINTELASM}inline;{$endif}
    {$endif}
    {$endif}
  public
    function Equal(const S: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: UTF32String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: UTF32String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function Equal(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    function Equal(const S: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Equal(const S: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: UnicodeString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: UnicodeString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$else .AmbiguousOverloadedFix}
    function EqualUTF8(const S: UTF8String): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualUTF8IgnoreCase(const S: UTF8String): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareUTF8(const S: UTF8String): NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareUTF8IgnoreCase(const S: UTF8String): NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function Equal(const S: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const S: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const S: WideString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const S: WideString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function Equal(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean; overload;
    function EqualIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean; overload;
    function Compare(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt; overload;
    function CompareIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt; overload;
    function Equal(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function EqualIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Compare(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function CompareIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    {$ifdef OPERATORSUPPORT}
    class operator Equal(const a: UTF32String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF32String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF32String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF32String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF32String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF32String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    class operator Equal(const a: UTF32String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF32String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF32String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF32String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF32String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF32String; const b: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: UTF32String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF32String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF32String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF32String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF32String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF32String; const b: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    class operator Equal(const a: UTF32String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF32String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF32String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF32String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF32String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF32String; const b: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: UTF32String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF32String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF32String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF32String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF32String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF32String; const b: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    class operator Equal(const a: AnsiString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: AnsiString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: AnsiString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: AnsiString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: AnsiString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: AnsiString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: WideString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: WideString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: WideString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: WideString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: WideString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: WideString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    class operator Equal(const a: UTF8String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UTF8String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UTF8String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UTF8String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UTF8String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UTF8String; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator Equal(const a: UnicodeString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator NotEqual(const a: UnicodeString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThan(const a: UnicodeString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator GreaterThanOrEqual(const a: UnicodeString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThan(const a: UnicodeString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    class operator LessThanOrEqual(const a: UnicodeString; const b: UTF32String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    {$endif}
  end;


{ TTextConvReReader class }

  TTextConvReReader = class(TCachedReReader)
  protected
    FGap: record
      Data: array[0..15] of Byte;
      Size: NativeUInt;
    end;
    FContext: PTextConvContext;
    function InternalCallback(const ASender: TCachedBuffer; AData: PByte; ASize: NativeUInt): NativeUInt;
  public
    constructor Create(const AContext: PTextConvContext; const ASource: TCachedReader; const AOwner: Boolean = False; const ABufferSize: NativeUInt = 0);
    property Context: PTextConvContext read FContext;
  end;


{ TTextConvReWriter class }

  TTextConvReWriter = class(TCachedReWriter)
  protected
    FGap: record
      Data: array[0..15] of Byte;
      Size: NativeUInt;
    end;
    FContext: PTextConvContext;
    function InternalCallback(const ASender: TCachedBuffer; AData: PByte; ASize: NativeUInt): NativeUInt;
  public
    constructor Create(const AContext: PTextConvContext; const ATarget: TCachedWriter; const AOwner: Boolean = False; const ABufferSize: NativeUInt = 0);
    property Context: PTextConvContext read FContext;
  end;


{ TCachedTextBuffer class }

  TCachedTextBuffer = class(TTinyObject)
  protected
    FInternalContext: TTextConvContext;
    FFileName: string;
    FKind: TCachedBufferKind;
    FFinishing: Boolean;
    FEOF: Boolean;
    FOwner: Boolean;
    FDataBuffer: TCachedBuffer;
    FTextConverter: TCachedBuffer;
    FCurrent: PByte;
    FOverflow: PByte;

    procedure Initialize(const AContext: PTextConvContext; const ADataBuffer: TCachedBuffer; const AOwner: Boolean);
    procedure Finalize;
    procedure FieldsCopy;
    function GetSource: TCachedReader;
    function GetTarget: TCachedWriter;
    function GetTextConvReReaderConverter: TTextConvReReader;
    function GetTextConvReWriterConverter: TTextConvReWriter;
    function GetMargin: NativeInt; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    function GetPosition: Int64; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure SetEOF(const AValue: Boolean); virtual;
    procedure OverflowReaderSkip(const ACount: NativeUInt);
    function Flush: NativeUInt;
  public
    destructor Destroy; override;
  end;


{ TCachedTextReader class }

  TCachedTextReader = class(TCachedTextBuffer)
  protected
    procedure OverflowReadData(var ABuffer; const ACount: NativeUInt);
    function FlushReadChar: UCS4Char;
  public
    constructor Create(const AContext: PTextConvContext; const ASource: TCachedReader; const AOwner: Boolean = False);
    procedure ReadData(var ABuffer; const ACount: NativeUInt); {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure Skip(const ACount: NativeUInt); {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    function Flush: NativeUInt;
    function Readln(var S: UnicodeString): Boolean; virtual; abstract;
    function ReadChar: UCS4Char; virtual; abstract;
    procedure Export(const AWriter: TCachedWriter); overload; virtual;
    procedure Export(const AFileName: string); overload;

    property Current: PByte read FCurrent write FCurrent;
    property Overflow: PByte read FOverflow;
    property Margin: NativeInt read GetMargin;
    property Finishing: Boolean read FFinishing;
    property EOF: Boolean read FEOF write SetEOF;
    property Converter: TTextConvReReader read GetTextConvReReaderConverter;
    property Source: TCachedReader read GetSource;
    property Owner: Boolean read FOwner write FOwner;
    property FileName: string read FFileName;
  end;


{ TByteTextReader class }

  TByteTextReader = class(TCachedTextReader)
  protected
    FSBCS: PTextConvSBCS;
    FEncoding: Word;
    FUCS2: PTextConvWB;
    FNativeFlags: NativeUInt;

    procedure SetSBCS(const AValue: PTextConvSBCS);
    function FlushReadln(var S: ByteString): Boolean;
  public
    constructor Create(const AEncoding: Word; const ASource: TCachedReader; const ADefaultByteEncoding: Word = 0; const AOwner: Boolean = False);
    constructor CreateFromFile(const AEncoding: Word; const AFileName: string; const ADefaultByteEncoding: Word = 0);
    constructor CreateDefault(const ASource: TCachedReader; const ADefaultByteEncoding: Word = 0; const AOwner: Boolean = False);
    constructor CreateDefaultFromFile(const AFileName: string; const ADefaultByteEncoding: Word = 0);
    constructor CreateDirect(const AContext: PTextConvContext; const ASource: TCachedReader; const AOwner: Boolean = False);

    function Readln(var S: ByteString): Boolean; reintroduce; overload;
    function Readln(var S: UnicodeString): Boolean; overload; override;
    function ReadChar: UCS4Char; override;
    procedure Export(const AWriter: TCachedWriter); override;

    property SBCS{nil for UTF8}: PTextConvSBCS read FSBCS;
    property Encoding: Word read FEncoding;
  end;


{ TUTF16TextReader class }

  TUTF16TextReader = class(TCachedTextReader)
  protected
    function FlushReadln(var S: UTF16String): Boolean;
  public
    constructor Create(const ASource: TCachedReader; const ADefaultByteEncoding: Word = 0; const AOwner: Boolean = False);
    constructor CreateFromFile(const AFileName: string; const ADefaultByteEncoding: Word = 0);
    constructor CreateDirect(const AContext: PTextConvContext; const ASource: TCachedReader; const AOwner: Boolean = False);

    function Readln(var S: UTF16String): Boolean; reintroduce; overload;
    function Readln(var S: UnicodeString): Boolean; overload; override;
    function ReadChar: UCS4Char; override;
    procedure Export(const AWriter: TCachedWriter); override;
  end;


{ TUTF32TextReader class }

  TUTF32TextReader = class(TCachedTextReader)
  protected
    function FlushReadln(var S: UTF32String): Boolean;
  public
    constructor Create(const ASource: TCachedReader; const ADefaultByteEncoding: Word = 0; const AOwner: Boolean = False);
    constructor CreateFromFile(const AFileName: string; const ADefaultByteEncoding: Word = 0);
    constructor CreateDirect(const AContext: PTextConvContext; const ASource: TCachedReader; const AOwner: Boolean = False);

    function Readln(var S: UTF32String): Boolean; reintroduce; overload;
    function Readln(var S: UnicodeString): Boolean; overload; override;
    function ReadChar: UCS4Char; override;
    procedure Export(const AWriter: TCachedWriter); override;
  end;


{ TFloatSettings object }

  PFloatSettings = ^TFloatSettings;
  {$A1}
  {$ifdef BCB}
  TFloatSettings = record
  {$else}
  TFloatSettings = object
  protected
  {$endif}
    F: packed record
    case Integer of
      0: (
           Format: TFloatFormat;
           GeneralCompact: Boolean;
           DecimalDot: Boolean;
           ThousandSpace: Boolean;
           Precision: SmallInt;
           Digits: SmallInt;
         );
      1: (Options, PrecisionWidth: Integer);
    end;
    property Width: SmallInt read F.Digits write F.Digits;
  public
    property Format: TFloatFormat read F.Format write F.Format;
    property GeneralCompact: Boolean read F.GeneralCompact write F.GeneralCompact;
    property DecimalDot: Boolean read F.DecimalDot write F.DecimalDot;
    property ThousandSpace: Boolean read F.ThousandSpace write F.ThousandSpace;
    property Precision: SmallInt read F.Precision write F.Precision;
    property Digits: SmallInt read F.Digits write F.Digits;
  end;
  {$A4}


{ TDateTimeSettings object }

  TDateFormat = (dateYYYYMMDD, dateDDMMYYYY, dateDDMMYY, dateMMDDYYYY, dateMMDDYY);
  TTimeFormat = (timeHHMM, timeHHMMSS, timeHHMMSSZZZ, timeHHMMSSZZZZZZ);
  TDateTimeSeparator = (sepNone, sepDot, sepDash, sepSlash, sepColon, sepSpace, sepT);

  PDateTimeSettings = ^TDateTimeSettings;
  {$A1}
  {$ifdef BCB}
  TDateTimeSettings = record
  {$else}
  TDateTimeSettings = object
  protected
  {$endif}
    F: packed record
    case Integer of
      0: (
            DateFormat: TDateFormat;
            DateSeparator: TDateTimeSeparator;
            TimeFormat: TTimeFormat;
            TimeSeparator: TDateTimeSeparator;
            MSecSeparator: TDateTimeSeparator;
            BetweenSeparator: TDateTimeSeparator;
         );
      1: (DateOptions, Align: Cardinal);
      2: (_: Word; TimeOptions: Cardinal);
    end;
  public
    property DateFormat: TDateFormat read F.DateFormat write F.DateFormat;
    property DateSeparator: TDateTimeSeparator read F.DateSeparator write F.DateSeparator;
    property TimeFormat: TTimeFormat read F.TimeFormat write F.TimeFormat;
    property TimeSeparator: TDateTimeSeparator read F.TimeSeparator write F.TimeSeparator;
    property MSecSeparator: TDateTimeSeparator read F.MSecSeparator write F.MSecSeparator;
    property BetweenSeparator: TDateTimeSeparator read F.BetweenSeparator write F.BetweenSeparator;
  end;
  {$A4}


{ TStringBuffer object }

  PStringBuffer = ^TStringBuffer;
  {$A1}
  TStringBuffer = {$ifdef BCB}record{$else}object protected{$endif}
    FData: TBytes;
    FSize: NativeUInt;
  public
    function Allocate(const ASize: NativeUInt): Pointer;
    function Resize(const ASize: NativeUInt; const AMemoryDelta: NativeUInt{Power of 2} = 1024): Pointer;
    procedure Clear;

    property Data: TBytes read FData;
    property Size: NativeUInt read FSize;
  {$ifdef BCB}
  public
  {$else}
  protected
  {$endif}
    FBuffer: packed record
    case TTinyStringKind of
      csByte: (CastByteString: ByteString);
     csUTF16: (CastUTF16String: UTF16String);
     csUTF32: (CastUTF32String: UTF32String);
      csNone: (Chars: Pointer; Length: NativeUInt;
          case Integer of
            0: (Flags: Cardinal);
            1: (Ascii, References: Boolean; Tag: Byte; SBCSIndex: ShortInt);
            2: (NativeFlags: NativeUInt);
            3: (_: packed record end);
         );
    end;
    FString: Pointer;
    FEncoding: TCachedEncoding;

    procedure InternalAppend(const AMaxAppendSize: NativeUInt; const ASource; const AFlags: NativeUInt; const AConversion: Pointer);
  public
    function InitByteString(const ACodePage: Word = 0; const ALength: NativeUInt = 0): PByteString;
    function InitUTF16String(const ALength: NativeUInt = 0): PUTF16String;
    function InitUTF32String(const ALength: NativeUInt = 0): PUTF32String;
    function InitString(const ALength: NativeUInt = 0): {$ifdef UNICODE}PUTF16String{$else}PByteString{$endif}; {$ifdef INLINESUPPORT}inline;{$endif}

    procedure Append(const S: ByteString; const ACharCase: TCharCase = ccOriginal); overload;
    procedure Append(const S: UTF16String; const ACharCase: TCharCase = ccOriginal); overload;
    procedure Append(const S: UTF32String; const ACharCase: TCharCase = ccOriginal); overload;
    procedure AppendAscii(const AChars: PAnsiChar; const ALength: NativeUInt);

    function EmulateShortString: PShortString;
    function EmulateAnsiString: PAnsiString;
    function EmulateUTF8String: PUTF8String;
    function EmulateWideString: PWideString;
    function EmulateUnicodeString: PUnicodeString;
    function EmulateUCS4String: PUCS4String;
    function EmulateString: PString; {$ifdef INLINESUPPORT}inline;{$endif}

    property Kind: TTinyStringKind read FEncoding.StringKind;
    property Encoding: Word read FEncoding.CodePage;
    property SBCSIndex: ShortInt read FEncoding.SBCSIndex;
    property CastByteString: ByteString read FBuffer.CastByteString;
    property CastUTF16String: UTF16String read FBuffer.CastUTF16String;
    property CastUTF32String: UTF32String read FBuffer.CastUTF32String;

    property Chars: Pointer read FBuffer.Chars write FBuffer.Chars;
    property Length: NativeUInt read FBuffer.Length write FBuffer.Length;
    property Ascii: Boolean read FBuffer.Ascii write FBuffer.Ascii;
    property References: Boolean read FBuffer.References write FBuffer.References;
    property Tag: Byte read FBuffer.Tag write FBuffer.Tag;
    property Flags: Cardinal read FEncoding.Flags write FEncoding.Flags;
  public
    // high level ByteString.Assign + Append
    procedure Append(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const ACodePage: Word; const CharCase: TCharCase = ccOriginal); overload;
    procedure Append(const S: AnsiString; const ACharCase: TCharCase = ccOriginal{$ifNdef INTERNALCODEPAGE}; const ACodePage: Word = 0{$endif}); overload;
    {$ifdef UNICODE}
    procedure Append(const S: UTF8String; const ACharCase: TCharCase = ccOriginal); overload;
    {$else}
    procedure AppendUTF8(const S: UTF8String; const ACharCase: TCharCase = ccOriginal);
    {$endif}
    procedure Append(const S: ShortString; const ACodePage: Word = 0; const ACharCase: TCharCase = ccOriginal); overload;
    procedure Append(const S: TBytes; const ACodePage: Word = 0; const ACharCase: TCharCase = ccOriginal); overload;

    // high level UTF16String.Assign + Append
    procedure Append(const AChars: PUnicodeChar; const ALength: NativeUInt; const ACharCase: TCharCase = ccOriginal); overload;
    {$ifdef MSWINDOWS}
    procedure Append(const S: WideString; const ACharCase: TCharCase = ccOriginal); overload;
    {$endif}
    {$ifdef UNICODE}
    procedure Append(const S: UnicodeString; const ACharCase: TCharCase = ccOriginal); overload;
    {$endif}

    // high level UTF32String.Assign + Append
    procedure Append(const AChars: PUCS4Char; const ALength: NativeUInt; const ACharCase: TCharCase = ccOriginal); overload;
    procedure Append(const S: UCS4String; const ANullTerminated: Boolean = True; const ACharCase: TCharCase = ccOriginal); overload;
  public
    // boolean, ordinal and float
    procedure AppendBoolean(const AValue: Boolean);
    procedure AppendInteger(const AValue: Integer; const ADigits: NativeUInt = 0);
    procedure AppendCardinal(const AValue: Cardinal; const ADigits: NativeUInt = 0);
    procedure AppendHex(const AValue: Integer; const ADigits: NativeUInt = 0);
    procedure AppendInt64(const AValue: Int64; const ADigits: NativeUInt = 0);
    procedure AppendUInt64(const AValue: UInt64; const ADigits: NativeUInt = 0);
    procedure AppendHex64(const AValue: Int64; const ADigits: NativeUInt = 0);
    procedure AppendFloat(const AValue: Extended; const ASettings: TFloatSettings); overload;
    procedure AppendFloat(const AValue: Extended); overload; {$ifNdef CPUINTELASM}inline;{$endif}
    procedure AppendDate(const AValue: TDateTime; const ASettings: TDateTimeSettings); overload;
    procedure AppendDate(const AValue: TDateTime); overload; {$ifNdef CPUINTELASM}inline;{$endif}
    procedure AppendTime(const AValue: TDateTime; const ASettings: TDateTimeSettings); overload;
    procedure AppendTime(const AValue: TDateTime); overload; {$ifNdef CPUINTELASM}inline;{$endif}
    procedure AppendDateTime(const AValue: TDateTime; const ASettings: TDateTimeSettings); overload;
    procedure AppendDateTime(const AValue: TDateTime); overload; {$ifNdef CPUINTELASM}inline;{$endif}
    procedure AppendVariant(const AValue: Variant; const AFloatSettings: TFloatSettings; const ADateTimeSettings: TDateTimeSettings); overload;
    procedure AppendVariant(const AValue: Variant); overload; {$ifNdef CPUINTELASM}inline;{$endif}
  end;
  {$A4}


{ TCachedTextWriter class }

  TCachedTextWriter = class(TCachedTextBuffer)
  protected
    FVirtuals: record
      WriteBufferedAscii: procedure(ASelf: Pointer; AFrom: PByte; ACount: NativeUInt);
      WriteAscii: procedure(ASelf: Pointer; const AChars: PAnsiChar; const ALength: NativeUInt);
      WriteUnicodeAscii: procedure(ASelf: Pointer; const AChars: PUnicodeChar; const ALength: NativeUInt);
      WriteUCS4Ascii: procedure(ASelf: Pointer; const AChars: PUCS4Char; const ALength: NativeUInt);
      WriteSBCSCharsInternal: procedure(ASelf: Pointer; const AChars: PAnsiChar; const ALength: NativeUInt);
      WriteUTF8Chars: procedure(ASelf: Pointer; const AChars: PUTF8Char; const ALength: NativeUInt);
      WriteUnicodeChars: procedure(ASelf: Pointer; const AChars: PUnicodeChar; const ALength: NativeUInt);
    end;
    FBuffer: record
      Booleans: array[0..1] of array[0..7] of Byte;
      Constants: array[0..7] of Byte;
      Digits: TDigitsRec;
      Cached: TinyString;
      UnicodeTemp: TStringBuffer;
    end;
    FSBCSLookup: record
      Default: TCachedEncoding;
      DefaultConverter: Pointer;
      Current: TCachedEncoding;
      CurrentConverter: Pointer;
    end;
    FHugeContext: TTextConvContext;
    FUTF32Context: TTextConvContext;
    FFormat: record
      Args: PVarRec;
      ArgsCount: NativeUInt;
      TopArg: PVarRec;
      FmtStr: TinyString;
      Settings: TFloatSettings;
    end;

    procedure OverflowWriteData(const ABuffer; const ACount: NativeUInt);
    procedure WriteContextData(var AContext: TTextConvContext);
    procedure WriteBufferedSBCSChars(const ACodePage: Word);
    function GetSBCSConverter(var AEncoding: TCachedEncoding; const ACodePage: Word): Pointer; virtual;
    procedure InitContexts; virtual; abstract;
    procedure WriteBufferedAscii(AFrom: PByte; ACount: NativeUInt); virtual; abstract;
    procedure WriteFormatString(const AArg: TVarRec);
    function WriteFormatArg(const AArgType: NativeUInt; const AArg: TVarRec): Boolean;
    procedure WriteFormatByte;
    procedure WriteFormatWord;
  public
    constructor Create(const AContext: PTextConvContext; const ATarget: TCachedWriter; const AOwner: Boolean = False);
    procedure WriteData(const ABuffer; const ACount: NativeUInt); {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    function Flush: NativeUInt;

    property Current: PByte read FCurrent write FCurrent;
    property Overflow: PByte read FOverflow;
    property Margin: NativeInt read GetMargin;
    property EOF: Boolean read FEOF write SetEOF;
    property Converter: TTextConvReWriter read GetTextConvReWriterConverter;
    property Target: TCachedWriter read GetTarget;
    property Owner: Boolean read FOwner write FOwner;
    property FileName: string read FFileName;
  public
    FloatSettings: TFloatSettings;
    DateTimeSettings: TDateTimeSettings;

    procedure WriteCRLF; virtual; abstract;
    procedure WriteAscii(const AChars: PAnsiChar; const ALength: NativeUInt); virtual; abstract;
    procedure WriteUnicodeAscii(const AChars: PUnicodeChar; const ALength: NativeUInt); virtual; abstract;
    procedure WriteUCS4Ascii(const AChars: PUCS4Char; const ALength: NativeUInt); virtual; abstract;
    procedure WriteAnsiChars(const AChars: PAnsiChar; const ALength: NativeUInt; const ACodePage: Word);
    procedure WriteUTF8Chars(const AChars: PUTF8Char; const ALength: NativeUInt); virtual; abstract;
    procedure WriteUnicodeChars(const AChars: PUnicodeChar; const ALength: NativeUInt); virtual; abstract;
    procedure WriteUCS4Chars(const AChars: PUCS4Char; const ALength: NativeUInt);

    procedure WriteByteString(const S: ByteString);
    procedure WriteUTF16String(const S: UTF16String); {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteUTF32String(const S: UTF32String);

    procedure WriteAnsiString(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const ACodePage: Word = 0{$endif});
    procedure WriteShortString(const S: ShortString; const ACodePage: Word = 0);
    procedure WriteUTF8String(const S: UTF8String); {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteWideString(const S: WideString); {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteUnicodeString(const S: UnicodeString); {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteUCS4String(const S: UCS4String; const ANullTerminated: Boolean = True);

    {$ifNdef NEXTGEN}
    procedure WriteFormat(const FmtStr: AnsiString; const Args: array of const{$ifNdef INTERNALCODEPAGE}; const ACodePage: Word = 0{$endif});
    procedure WriteFormatUTF8(const FmtStr: UTF8String; const Args: array of const);
    {$else .NEXTGEN}
    procedure WriteFormat(const FmtStr: AnsiString; const Args: array of const{$ifNdef INTERNALCODEPAGE}; const ACodePage: Word = 0{$endif}); overload;
    procedure WriteFormat(const FmtStr: UnicodeString; const Args: array of const); overload;
    procedure WriteFormatUTF8(const FmtStr: UTF8String; const Args: array of const); overload;
    procedure WriteFormatUTF8(const FmtStr: UnicodeString; const Args: array of const); overload;
    {$endif}
    procedure WriteFormatUnicode(const FmtStr: UnicodeString; const Args: array of const);
  public
    procedure WriteBoolean(const AValue: Boolean);
    procedure WriteBooleanOrdinal(const AValue: Boolean);
    procedure WriteInteger(const AValue: Integer; const ADigits: NativeUInt = 0);
    procedure WriteHex(const AValue: Integer; const ADigits: NativeUInt = 0);
    procedure WriteCardinal(const AValue: Cardinal; const ADigits: NativeUInt = 0);
    procedure WriteInt64(const AValue: Int64; const ADigits: NativeUInt = 0);
    procedure WriteHex64(const AValue: Int64; const ADigits: NativeUInt = 0);
    procedure WriteUInt64(const AValue: UInt64; const ADigits: NativeUInt = 0);
    procedure WriteFloat(const AValue: Extended; const ASettings: TFloatSettings); overload;
    procedure WriteFloat(const AValue: Extended); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteDate(const AValue: TDateTime; const ASettings: TDateTimeSettings); overload;
    procedure WriteDate(const AValue: TDateTime); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteTime(const AValue: TDateTime; const ASettings: TDateTimeSettings); overload;
    procedure WriteTime(const AValue: TDateTime); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteDateTime(const AValue: TDateTime; const ASettings: TDateTimeSettings); overload;
    procedure WriteDateTime(const AValue: TDateTime); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    procedure WriteVariant(const AValue: Variant; const AFloatSettings: TFloatSettings; const ADateTimeSettings: TDateTimeSettings); overload;
    procedure WriteVariant(const AValue: Variant); overload; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
  end;


{ TByteTextWriter class }

  TByteTextWriter = class(TCachedTextWriter)
  protected
    FSBCS: PTextConvSBCS;
    FSBCSValues: PTextConvSBCSValues;
    FEncoding: TCachedEncoding;

    procedure SetEncoding(const AValue: Word);
    function GetSBCSConverter(var AEncoding: TCachedEncoding; const ACodePage: Word): Pointer; override;
    procedure InitContexts; override;
    procedure WriteBufferedAscii(AFrom: PByte; ACount: NativeUInt); override;
    procedure WriteSBCSCharsToSBCS(const AChars: PAnsiChar; const ALength: NativeUInt);
    procedure WriteSBCSCharsToUTF8(const AChars: PAnsiChar; const ALength: NativeUInt);
  public
    constructor Create(const AEncoding: Word; const ATarget: TCachedWriter; const ABOM: TBOM = bomNone; const ADefaultByteEncoding: Word = 0; const AOwner: Boolean = False);
    constructor CreateFromFile(const AEncoding: Word; const AFileName: string; const ABOM: TBOM = bomNone; const ADefaultByteEncoding: Word = 0);
    constructor CreateDirect(const AContext: PTextConvContext; const ATarget: TCachedWriter; const AOwner: Boolean = False);

    property SBCS{nil for UTF8}: PTextConvSBCS read FSBCS;
    property SBCSIndex: ShortInt read FEncoding.SBCSIndex;
    property Encoding: Word read FEncoding.CodePage;
  public
    procedure WriteCRLF; override;
    procedure WriteAscii(const AChars: PAnsiChar; const ALength: NativeUInt); override;
    procedure WriteUnicodeAscii(const AChars: PUnicodeChar; const ALength: NativeUInt); override;
    procedure WriteUCS4Ascii(const AChars: PUCS4Char; const ALength: NativeUInt); override;
    procedure WriteUTF8Chars(const AChars: PUTF8Char; const ALength: NativeUInt); override;
    procedure WriteUnicodeChars(const AChars: PUnicodeChar; const ALength: NativeUInt); override;
  end;


{ TUTF16TextWriter class }

  TUTF16TextWriter = class(TCachedTextWriter)
  protected
    procedure InitContexts; override;
    procedure WriteBufferedAscii(AFrom: PByte; ACount: NativeUInt); override;
    procedure WriteSBCSCharsInternal(const AChars: PAnsiChar; const ALength: NativeUInt);
  public
    constructor Create(const ATarget: TCachedWriter; const ABOM: TBOM = bomUTF16; const ADefaultByteEncoding: Word = 0; const AOwner: Boolean = False);
    constructor CreateFromFile(const AFileName: string; const ABOM: TBOM = bomUTF16; const ADefaultByteEncoding: Word = 0);
    constructor CreateDirect(const AContext: PTextConvContext; const ATarget: TCachedWriter; const AOwner: Boolean = False);
  public
    procedure WriteCRLF; override;
    procedure WriteAscii(const AChars: PAnsiChar; const ALength: NativeUInt); override;
    procedure WriteUnicodeAscii(const AChars: PUnicodeChar; const ALength: NativeUInt); override;
    procedure WriteUCS4Ascii(const AChars: PUCS4Char; const ALength: NativeUInt); override;
    procedure WriteUTF8Chars(const AChars: PUTF8Char; const ALength: NativeUInt); override;
    procedure WriteUnicodeChars(const AChars: PUnicodeChar; const ALength: NativeUInt); override;
  end;


{ TUTF32TextWriter class }

  TUTF32TextWriter = class(TCachedTextWriter)
  protected
    procedure InitContexts; override;
    procedure WriteBufferedAscii(AFrom: PByte; ACount: NativeUInt); override;
    procedure WriteSBCSCharsInternal(const AChars: PAnsiChar; const ALength: NativeUInt);
  public
    constructor Create(const ATarget: TCachedWriter; const ABOM: TBOM = bomUTF32; const ADefaultByteEncoding: Word = 0; const AOwner: Boolean = False);
    constructor CreateFromFile(const AFileName: string; const ABOM: TBOM = bomUTF32; const ADefaultByteEncoding: Word = 0);
    constructor CreateDirect(const AContext: PTextConvContext; const ATarget: TCachedWriter; const AOwner: Boolean = False);
  public
    procedure WriteCRLF; override;
    procedure WriteAscii(const AChars: PAnsiChar; const ALength: NativeUInt); override;
    procedure WriteUnicodeAscii(const AChars: PUnicodeChar; const ALength: NativeUInt); override;
    procedure WriteUCS4Ascii(const AChars: PUCS4Char; const ALength: NativeUInt); override;
    procedure WriteUTF8Chars(const AChars: PUTF8Char; const ALength: NativeUInt); override;
    procedure WriteUnicodeChars(const AChars: PUnicodeChar; const ALength: NativeUInt); override;
  end;

{$ifdef FPC}
var
  DefaultFloatSettings: TFloatSettings;
  DefaultDateTimeSettings: TDateTimeSettings;
{$else}
const
  DefaultFloatSettings: TFloatSettings = (
    F: (
      Format: ffGeneral;
      GeneralCompact: False;
      DecimalDot: True;
      ThousandSpace: True;
      Precision: 15;
      Digits: 0;
    );
  );

  DefaultDateTimeSettings: TDateTimeSettings = (
    F: (
      DateFormat: dateYYYYMMDD;
      DateSeparator: sepDash;
      TimeFormat: timeHHMMSS;
      TimeSeparator: sepColon;
      MSecSeparator: sepDot;
      BetweenSeparator: sepSpace;
    );
  );
{$endif}

implementation

{$ifdef FPC}
resourcestring
  SInvalidDate = '''%s'' is not a valid date';
  SInvalidTime = '''%s'' is not a valid time';
  SInvalidDateTimeFloat = '''%g'' is not a valid date and time';
{$endif}

{$ifdef FPC}
procedure FillDefaultSettings;
begin
  with DefaultFloatSettings do
  begin
    Format := ffGeneral;
    DecimalDot := True;
    ThousandSpace := True;
    Precision := 15;
    Digits := 0;
  end;

  with DefaultDateTimeSettings do
  begin
    DateFormat := dateYYYYMMDD;
    DateSeparator := sepDash;
    TimeFormat := timeHHMMSS;
    TimeSeparator := sepColon;
    MSecSeparator := sepDot;
    BetweenSeparator := sepSpace;
  end;
end;
{$endif}


{ ECachedText }

const
  NULL_ANSICHAR = {$ifdef ANSISTRSUPPORT}#0{$else}0{$endif};
  NULL_WIDECHAR = #0;
  STR_REC_SIZE = {$if Defined(FPC) and Defined(LARGEINT)}SizeOf(TUnicodeStrRec){$else .DELPHI}16{$ifend};

type
  PStrRec = ^TStrRec;
  TStrRec = packed record
  case Integer of
    0: (Data: array[1..STR_REC_SIZE] of Byte);
    1: (  {$if SizeOf(Byte) <> STR_REC_SIZE}
          SAlign: array[1..STR_REC_SIZE-SizeOf(Byte)] of Byte;
          {$ifend}
          ShortLength: Byte;
       );
    2: (  {$if SizeOf(TAnsiStrRec) <> STR_REC_SIZE}
          AAlign: array[1..STR_REC_SIZE-SizeOf(TAnsiStrRec)] of Byte;
          {$ifend}
          Ansi: TAnsiStrRec;
       );
    3: (  {$if SizeOf(TWideStrRec) <> STR_REC_SIZE}
          WAlign: array[1..STR_REC_SIZE-SizeOf(TWideStrRec)] of Byte;
          {$ifend}
          Wide: TWideStrRec;
       );
    4: (  {$if SizeOf(TUnicodeStrRec) <> STR_REC_SIZE}
          UAlign: array[1..STR_REC_SIZE-SizeOf(TUnicodeStrRec)] of Byte;
          {$ifend}
          Unicode: TUnicodeStrRec;
       );
    5: (  {$if SizeOf(TDynArrayRec) <> STR_REC_SIZE}
          UCS4Align: array[1..STR_REC_SIZE-SizeOf(TDynArrayRec)] of Byte;
          {$ifend}
          UCS4: TDynArrayRec;
       );
  end;


function AStrLen(S: PByte): NativeUInt;
label
  found, _1, _2, _3;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  Store: PByte;
  X, V: NativeInt;
begin
  Store := S;
  if (S = nil) then goto found;

  if (NativeUInt(S) and (SizeOf(Cardinal) - 1) <> 0) then
  begin
    case (NativeUInt(S) and (SizeOf(Cardinal) - 1)) of
      1:
      begin
      _1:
        if (S^ = 0) then goto found;
        Inc(S);
        goto _2;
      end;
      2:
      begin
      _2:
        if (S^ = 0) then goto found;
        Inc(S);
        goto _3;
      end;
    else
    _3:
      if (S^ = 0) then goto found;
      Inc(S);
    end;
  end;

  repeat
    X := PCardinal(S)^;
    Inc(S, CHARS_IN_CARDINAL);

    V := X + SUB_MASK;
    X := not X;
    X := X and V;

    if (X and OVERFLOW_MASK = 0) then Continue;
    Dec(S, CHARS_IN_CARDINAL);
    Inc(S, Byte(X and $80 = 0));
    Inc(S, Byte(X and $8080 = 0));
    Inc(S, Byte(X and $808080 = 0));
    goto found;
  until (False);

found:
  Result := NativeUInt(S) - NativeUInt(Store);
end;

function WStrLen(S: PWord): NativeUInt;
label
  found;
var
  Store: PWord;
  X: Cardinal;
begin
  Store := S;
  if (S = nil) then goto found;

  if (NativeUInt(S) and (SizeOf(Cardinal) - 1) <> 0) then
  begin
    if (NativeUInt(S) and 1 <> 0) then
    begin
      repeat
        if (S^ = 0) then goto found;
        Inc(S);
      until (False);
    end else
    begin
      if (S^ = 0) then goto found;
      Inc(S);
    end;
  end;

  repeat
    X := PCardinal(S)^;
    if (X and $0000ffff = 0) then goto found;
    Inc(S);
    if (X and $ffff0000 = 0) then goto found;
    Inc(S);

    X := PCardinal(S)^;
    if (X and $0000ffff = 0) then goto found;
    Inc(S);
    if (X and $ffff0000 = 0) then goto found;
    Inc(S);
  until (False);

found:
  Result := (NativeUInt(S) - NativeUInt(Store)) shr 1;
end;


type
  T4Bytes = array[0..3] of Byte;
  P4Bytes = ^T4Bytes;

  T8Bytes = array[0..7] of Byte;
  P8Bytes = ^T8Bytes;

  TNativeIntArray = array[0..High(Integer) div SizeOf(NativeInt) - 1] of NativeInt;
  PNativeIntArray = ^TNativeIntArray;

  PExtendedBytes = ^TExtendedBytes;
  TExtendedBytes = array[0..{$ifdef EXTENDEDSUPPORT}10{$else}SizeOf(Extended){$endif} - 1] of Byte;

  PTextConvSBCSEx = ^TTextConvSBCSEx;
  TTextConvSBCSEx = {$ifdef BCB}TTextConvSBCS{$else}object(TTextConvSBCS) end{$endif};

  PTextConvContextEx = ^TTextConvContextEx;
  TTextConvContextEx = {$ifdef BCB}TTextConvContext{$else}object(TTextConvContext) end{$endif};

  {$ifNdef CPUX86}
    {$define CPUMANYREGS}
  {$endif}

const
  ENCODING_DESTINATION_OFFSET = 27;
  FLAG_MODE_FINALIZE = 1 shl 8;
  CHARCASE_MASK_ORIGINAL = $1 shl 24;
  CHARCASE_FLAGS: array[0..2{TCharCase}] of Cardinal =
  (
     CHARCASE_MASK_ORIGINAL or FLAG_MODE_FINALIZE,
     (Ord(ccLower) shl 16) or FLAG_MODE_FINALIZE,
     (Ord(ccUpper) shl 16) or FLAG_MODE_FINALIZE
  );

  UNDEFINED_WIDTH = 0;
  UNDEFINED_PRECISION = -1;
  UNDEFINED_PRECISIONWIDTH = Integer((UNDEFINED_WIDTH shl 16) + Word(UNDEFINED_PRECISION));

  BYTE_MASKS: array[0..SizeOf(NativeUInt)] of NativeUInt = (
    $00000000, $000000ff, $0000ffff, $00ffffff, $ffffffff
    {$ifdef LARGEINT}
    , $000000ffffffffff, $0000ffffffffffff, $00ffffffffffffff, $ffffffffffffffff
    {$endif}
  );
  BYTE_NOTMASKS: array[0..SizeOf(NativeUInt)] of NativeUInt = (
    not NativeUInt($00000000), not NativeUInt($000000ff),
    not NativeUInt($0000ffff), not NativeUInt($00ffffff), not NativeUInt($ffffffff)
    {$ifdef LARGEINT}
    , not NativeUInt($000000ffffffffff), not NativeUInt($0000ffffffffffff)
    , not NativeUInt($00ffffffffffffff), not NativeUInt($ffffffffffffffff)
    {$endif}
  );

  DBLROUND_CONST: Double = 6755399441055744.0;

var
  TEXTCONV_SUPPORTED_SBCS_HASH: array[0..High(Tiny.Text.TEXTCONV_SUPPORTED_SBCS_HASH)] of Integer;
  TEXTCONV_UTF8CHAR_SIZE: TTextConvBB;

procedure InternalLookupsInitialize;
begin
  CODEPAGE_DEFAULT := Tiny.Text.CODEPAGE_DEFAULT;
  DEFAULT_TEXTCONV_SBCS := Tiny.Text.DEFAULT_TEXTCONV_SBCS;
  DEFAULT_TEXTCONV_SBCS_INDEX := Tiny.Text.DEFAULT_TEXTCONV_SBCS_INDEX;

  TinyMove(Tiny.Text.TEXTCONV_SUPPORTED_SBCS_HASH, TEXTCONV_SUPPORTED_SBCS_HASH, SizeOf(TEXTCONV_SUPPORTED_SBCS_HASH));
  TinyMove(Tiny.Text.TEXTCONV_UTF8CHAR_SIZE, TEXTCONV_UTF8CHAR_SIZE, SizeOf(TEXTCONV_UTF8CHAR_SIZE));
end;


resourcestring
  SInvalidHex = '''%s'' is not a valid hex value';
  SIncompatibleStringType = 'Incompatible type of string';
  SStringNotInitialized = 'String not initialized';

const
  TEN = 10;
  HUNDRED = TEN * TEN;
  THOUSAND = TEN * TEN * TEN;
  MILLION = THOUSAND * THOUSAND;
  BILLION = THOUSAND * MILLION;
  NINE_BB = Int64(9) * BILLION * BILLION;
  TEN_BB = Int64(-8446744073709551616); //Int64(TEN)*BILLION*BILLION;
  _HIGHU64 = Int64({1}8446744073709551615);

  DIGITS_1 = 10;
  DIGITS_2 = 100;
  DIGITS_4 = 10000;
  DIGITS_8 = 100000000;
  DIGITS_12 = Int64(DIGITS_4) * Int64(DIGITS_8);
  DIGITS_16 = Int64(DIGITS_8) * Int64(DIGITS_8);


function Decimal64R21(R2, R1: Integer): Int64; {$ifNdef CPUX86} inline;
begin
  Result := Cardinal(R1) + (Int64(Cardinal(R2)) * BILLION);
end;
{$else .CPUX86} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  mov ecx, edx
  mov edx, BILLION
  mul edx
  add eax, ecx
  adc edx, 0
end;
{$endif}

{$ifNdef CPUX86}
function Decimal64VX(const V: Int64; const X: NativeUInt): Int64; inline;
begin
  Result := V * TEN;
  Inc(Result, X);
end;
{$else .CPUX86}
function Decimal64VX(var V: Int64; const X: NativeUInt): Int64; {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  push edx

  // Result := V;
  mov edx, [eax + 4]
  mov eax, [eax]

  // Result := Result*10 + [ESP]
  lea ecx, [edx*4 + edx]
  mov edx, 10
  mul edx
  lea edx, [edx + ecx*2]
  pop ecx
  add eax, ecx
  adc edx, 0
end;
{$endif}

type
  TTenPowers = array[0..9] of Double;
  PTenPowers = ^TTenPowers;

const
  TEN_POWERS: array[Boolean] of TTenPowers = (
    (1, 1/10, 1/100, 1/1000, 1/(10*1000), 1/(100*1000), 1/(1000*1000),
     1/(10*MILLION), 1/(100*MILLION), 1/(1000*MILLION)),
    (1, 10, 100, 1000, 10*1000, 100*1000, 1000*1000, 10*MILLION, 100*MILLION,
     1000*MILLION)
  );

function TenPower(TenPowers: PTenPowers; I: NativeUInt): Extended;
{$ifNdef CPUX86}
var
  C: NativeUInt;
  LBase: Extended;
begin
  if (I <= 9) then
  begin
    Result := TenPowers[I];
  end else
  begin
    Result := 1;

    while (True) do
    begin
      if (I <= 9) then
      begin
        Result := Result * TenPowers[I];
        Break;
      end else
      begin
        C := 9;
        Dec(I, 9);
        LBase := TenPowers[9];

        while (I >= C) do
        begin
          Dec(I, C);
          C := C + C;
          LBase := LBase * LBase;
        end;

        Result := Result * LBase;
        if (I = 0) then Break;
      end;
    end;
  end;
end;
{$else .CPUX86} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  cmp edx, 9
  ja @1

  // Result := TenPowers[I];
  fld qword ptr [EAX + EDX*8]
  ret

@1:
  // Result := 1;
  fld1

  // while (True) do
@loop:
  cmp edx, 9
  ja @2

  // Result := Result * TenPowers[I];
  fmul qword ptr [EAX + EDX*8]
  ret

@2:
  mov ecx, 9
  sub edx, 9
  // LBase := TenPowers[9];
  fld qword ptr [EAX + 9*8]

  // while (I >= C) do
  cmp edx, ecx
  jb @3
@loop_ic:
  sub edx, ecx
  add ecx, ecx
  // LBase := LBase * LBase;
  fmul st(0), st(0)

  cmp edx, ecx
  jae @loop_ic

@3:
  // Result := Result * LBase;
  fmulp
  // if (I = 0) then Break;
  test edx, edx
  jnz @loop
end;
{$endif}


const
  DT_LEN_MIN: array[1..3] of NativeUInt = (4, 4, 4+4+1);
  DT_LEN_MAX: array[1..3] of NativeUInt = (11, 15, 11+15+1);

type
  TDateTimeBuffer = record
    DT: NativeUInt;
    Bytes: array[1..11+15+1] of Byte;
    Length: NativeUInt;
    Value: PDateTime;
  end;

  TMonthInfo = packed record
    Days: Word;
    Before: Word;
  end;
  PMonthInfo = ^TMonthInfo;

  TMonthTable = array[1-1..12-1] of TMonthInfo;
  PMonthTable = ^TMonthTable;

const
  DTSP = $e0{\t, \r, \n, ' ', 'T'};
  DTS1 = $e1{-};
  DTS2 = $e2{.};
  DTS3 = $e3{/};
  DTS4 = $e4{:};

  DT_BYTES: array[0..$7f] of Byte = (
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff,DTSP,DTSP, $ff, $ff,DTSP, $ff, $ff, // 00-0f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 10-1f
    DTSP, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff,DTS1,DTS2,DTS3, // 20-2f
       0,   1,   2,   3,   4,   5,   6,   7,     8,   9,DTS4, $ff, $ff, $ff, $ff, $ff, // 30-3f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 40-4f
     $ff, $ff, $ff, $ff,DTSP, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 50-5f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 60-6f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  // 70-7f
  );

  STD_MONTH_TABLE: TMonthTable = (
    {01}(Days: 31; Before: 0),
    {02}(Days: 28; Before: 0+31),
    {03}(Days: 31; Before: 0+31+28),
    {04}(Days: 30; Before: 0+31+28+31),
    {05}(Days: 31; Before: 0+31+28+31+30),
    {06}(Days: 30; Before: 0+31+28+31+30+31),
    {07}(Days: 31; Before: 0+31+28+31+30+31+30),
    {08}(Days: 31; Before: 0+31+28+31+30+31+30+31),
    {09}(Days: 30; Before: 0+31+28+31+30+31+30+31+31),
    {10}(Days: 31; Before: 0+31+28+31+30+31+30+31+31+30),
    {11}(Days: 30; Before: 0+31+28+31+30+31+30+31+31+30+31),
    {12}(Days: 31; Before: 0+31+28+31+30+31+30+31+31+30+31+30)
  );

  LEAP_MONTH_TABLE: TMonthTable = (
    {01}(Days: 31; Before: 0),
    {02}(Days: 29; Before: 0+31),
    {03}(Days: 31; Before: 0+31+29),
    {04}(Days: 30; Before: 0+31+29+31),
    {05}(Days: 31; Before: 0+31+29+31+30),
    {06}(Days: 30; Before: 0+31+29+31+30+31),
    {07}(Days: 31; Before: 0+31+29+31+30+31+30),
    {08}(Days: 31; Before: 0+31+29+31+30+31+30+31),
    {09}(Days: 30; Before: 0+31+29+31+30+31+30+31+31),
    {10}(Days: 31; Before: 0+31+29+31+30+31+30+31+31+30),
    {11}(Days: 30; Before: 0+31+29+31+30+31+30+31+31+30+31),
    {12}(Days: 31; Before: 0+31+29+31+30+31+30+31+31+30+31+30)
  );


{
  Supported date formats:

  YYYYMMDD
  YYYY-MM-DD
  -YYYY-MM-DD
  DD.MM.YYYY
  DD-MM-YYYY
  DD/MM/YYYY
  DD.MM.YY
  DD-MM-YY
  DD/MM/YY

  YYYY    (YYYY-01-01)
  YYYY-MM (YYYY-MM-01)
  --MM-DD (2000-MM-DD)
  --MM--  (2000-MM-01)
  ---DD   (2000-01-DD)


  Supported time formats:

  hh:mm:ss.zzzzzz
  hh-mm-ss.zzzzzz
  hh:mm:ss.zzz
  hh-mm-ss.zzz
  hh:mm:ss
  hh-mm-ss
  hhmmss
  hh:mm
  hh-mm
  hhmm
}

function _GetDateTime(var Buffer: TDateTimeBuffer): Boolean;
label
  date, year_calculated, time, hhmmss_calculated, done, fail;
type
  TDTByteString = array[1..High(Integer)] of Byte;
const
  _2001: array[1..4] of Byte = (2, 0, 0, 1);

  DT_SPACE = DTSP;
  DT_MIN = DTS1;
  DT_CLN = DTS4;
  DT_POINT = DTS2;

  SECPERMINUTE = 60;
  SECPERHOUR = 60 * SECPERMINUTE;
  SECPERDAY = 24 * SECPERHOUR;
  MSECPERDAY = SECPERDAY * 1000 * 1.0;
  TIME_CONSTS: array[0..5] of Double = (1/SECPERDAY, 1/MSECPERDAY,
    1/(MSECPERDAY*1000), -1/SECPERDAY, -1/MSECPERDAY, -1/(MSECPERDAY*1000));
var
  S: ^TDTByteString;
  L: NativeUInt;

  B: Byte;
  pCC, pYY, pMM, pDD: ^TDTByteString;
  CC, YY, MM, DD: NativeInt;
  MonthInfo: PMonthInfo;
  MonthTable: PMonthTable;
  Days: NativeInt;

  pHH, pNN, pSS: ^TDTByteString;
  HH, NN, SS: NativeInt;

  F: record
    Value: PDateTime;
    DT: NativeInt;
  end;
  R: PDateTime;
  TimeConst: PDouble;
begin
  S := Pointer(@Buffer.Bytes);
  L := Buffer.Length;

  F.Value := Buffer.Value;
  F.Value^ := 0;
  F.DT := Buffer.DT;
  if (F.DT and 1 = 0) then goto time;

date:
  // YYYYMMDD
  // YYYY-MM-DD
  // -YYYY-MM-DD
  // DD.MM.YYYY
  // DD-MM-YYYY
  // DD/MM/YYYY
  // DD.MM.YY
  // DD-MM-YY
  // DD/MM/YY
  // YYYY    (YYYY-01-01)
  // YYYY-MM (YYYY-MM-01)
  // --MM-DD (2000-MM-DD)
  // --MM--  (2000-MM-01)
  // ---DD   (2000-01-DD)

  if (S[1] = DT_MIN) then
  begin
    // -YYYY-MM-DD
    // --MM-DD (2000-MM-DD)
    // --MM--  (2000-MM-01)
    // ---DD   (2000-01-DD)

    if (S[2] = DT_MIN) then
    begin
      // --MM-DD (2000-MM-DD)
      // --MM--  (2000-MM-01)
      // ---DD   (2000-01-DD)
      if (S[3] = DT_MIN) then
      begin
        // ---DD (2000-01-DD)
        if (L < 5) then goto fail;

        pMM := {01}Pointer(@_2001[3]);
        pDD := Pointer(@S[4]);

        Dec(L, 5);
        Inc(PByte(S), 5);
      end else
      begin
        // --MM-DD (2000-MM-DD)
        // --MM--  (2000-MM-01)
        if (L < 6) then goto fail;

        pMM := Pointer(@S[3]);

        if (S[6] = DT_MIN) then
        begin
          // --MM-- (2000-MM-01)
          pDD := {01}Pointer(@_2001[3]);
          Dec(L, 6);
          Inc(PByte(S), 6);
        end else
        begin
          // --MM-DD (2000-MM-DD)
          if (L < 7) then goto fail;
          pDD := Pointer(@S[6]);
          Dec(L, 7);
          Inc(PByte(S), 7);
        end;
      end;

      MonthTable := @LEAP_MONTH_TABLE;
      Days := 36526{01.01.2000}-1;
      goto year_calculated;
    end else
    begin
      // -YYYY-MM-DD
      if (L < 11) or (S[6] <> DT_MIN) or (S[9] <> DT_MIN) then goto fail;

      pCC := Pointer(@S[2]);
      pYY := Pointer(@S[4]);
      pMM := Pointer(@S[7]);
      pDD := Pointer(@S[10]);

      Dec(L, 11);
      Inc(PByte(S), 11);
    end;
  end else
  begin
    // YYYYMMDD
    // YYYY-MM-DD
    // DD.MM.YYYY
    // DD-MM-YYYY
    // DD/MM/YYYY
    // DD.MM.YY
    // DD-MM-YY
    // DD/MM/YY
    // YYYY (YYYY-01-01)
    // YYYY-MM (YYYY-MM-01)

    if (S[3] <= 9) then
    begin
      // YYYYMMDD
      // YYYY-MM-DD
      // YYYY (YYYY-01-01)
      // YYYY-MM (YYYY-MM-01)
      PCC := Pointer(@S[1]);
      pYY := Pointer(@S[3]);

      if (L < 5) or (S[5] = DT_SPACE) then
      begin
        // YYYY (YYYY-01-01)
        pMM := {01}Pointer(@_2001[3]);
        pDD := {01}Pointer(@_2001[3]);

        Dec(L, 4);
        Inc(PByte(S), 4);
      end else
      if (S[5] <= 9) then
      begin
        // YYYYMMDD
        if (L < 8) then goto fail;

        pMM := Pointer(@S[5]);
        pDD := Pointer(@S[7]);

        Dec(L, 8);
        Inc(PByte(S), 8);
      end else
      begin
        // YYYY-MM-DD
        // YYYY-MM (YYYY-MM-01)
        if (S[5] <> DT_MIN) then goto fail;

        pMM := Pointer(@S[6]);

        if (L < 8) or (S[8] = DT_SPACE) then
        begin
          // YYYY-MM (YYYY-MM-01)
          pDD := {01}Pointer(@_2001[3]);
          Dec(L, 7);
          Inc(PByte(S), 7);
        end else
        begin
          // YYYY-MM-DD
          if (L < 10) then goto fail;
          pDD := Pointer(@S[9]);
          Dec(L, 10);
          Inc(PByte(S), 10);
        end;
      end;
    end else
    begin
      // DD.MM.YYYY
      // DD-MM-YYYY
      // DD/MM/YYYY
      // DD.MM.YY
      // DD-MM-YY
      // DD/MM/YY

      B := S[3];
      if (L < 8) or (B <> S[6]) or (B < DTS1) or (B > DTS3) then goto fail;

      pDD := Pointer(@S[1]);
      pMM := Pointer(@S[4]);

      if (L < 9) or (S[9] = DT_SPACE) then
      begin
        // DD.MM.YY
        // DD-MM-YY
        // DD/MM/YY
        pCC := {20}Pointer(@_2001[1]);
        pYY := Pointer(@S[7]);
        Dec(L, 8);
        Inc(PByte(S), 8);
      end else
      begin
        // DD.MM.YYYY
        // DD-MM-YYYY
        // DD/MM/YYYY
        if (L < 10) then goto fail;

        pCC := Pointer(@S[7]);
        pYY := Pointer(@S[9]);
        Dec(L, 10);
        Inc(PByte(S), 10);
      end;
    end;
  end;

  CC := NativeInt(pCC[1])*10 + NativeInt(pCC[2]);
  YY := NativeInt(pYY[1])*10 + NativeInt(pYY[2]);
  if (CC > 99) or (YY > 99) or ((CC = 0) and (YY = 0)) then goto fail;

  // Year := CC*100 + YY;
  // I := Year - 1;
  // Days := (I * 365) - (I div 100) + (I div 400) + (I div 4);
  Days := CC*(100*365) - 365 + YY*365; // Days = I*365 = (CC*100 + YY - 1)*365;
  MonthTable := @STD_MONTH_TABLE;
  if (YY = 0) then
  begin
    if (CC and 3 = 0) then MonthTable := @LEAP_MONTH_TABLE;
    Dec(CC);
    YY := 99;
  end else
  begin
    if (YY and 3 = 0) then MonthTable := @LEAP_MONTH_TABLE;
    Dec(YY);
  end;
  Days := Days - {I div 100}CC + ({I div 400}CC shr 2);
  // Days := Days + {I div 4}((CC*25) + YY shr 2) - DateDelta;
  Days := Days + YY shr 2;
  Days := Days + CC*25;

year_calculated:
  // MM := NativeInt(pMM[1])*10 + NativeInt(pMM[2]) - 1;
  pCC := pMM;
  YY := NativeInt(pCC[1]);
  MM := NativeInt(pCC[2]) - 1;
  MM := YY*10 + MM;
  if (MM < 0) or (MM > 11)  then goto fail;

  // DD := NativeInt(pDD[1])*10 + NativeInt(pDD[2]);
  pYY := pDD;
  DD := NativeInt(pYY[2]) + NativeInt(pYY[1])*10;
  MonthInfo := @MonthTable[MM];
  if (DD = 0) or (DD > MonthInfo.Days) then goto fail;

  // Date value
  Days := (DD + Days) + MonthInfo.Before;
  F.Value^ := Days;

  if (F.DT and 2 = 0) then
  begin
    if (L <> 0) then goto fail;
    goto done;
  end;

  if (S[1] <> DT_SPACE) then goto fail;
  Dec(L);
  Inc(PByte(S));
  if (L < 4{MIN}) then goto fail;

time:
  // hh:mm:ss.zzzzzz
  // hh-mm-ss.zzzzzz
  // hh:mm:ss.zzz
  // hh-mm-ss.zzz
  // hh:mm:ss
  // hh-mm-ss
  // hhmmss
  // hh:mm
  // hh-mm
  // hhmm

  pHH := Pointer(@S[1]);
  pNN := Pointer(@S[4]);
  pSS := Pointer(@S[7]);

  if (S[3] <= 9) then
  begin
    // hhmmss
    // hhmm
    Dec(PByte(pNN));
    if (L = 4) then
    begin
      pSS := {00}Pointer(@_2001[2]);
      Dec(L, 4);
      Inc(PByte(S), 4);
    end else
    begin
      if (L <> 6) then goto fail;
      Dec(PByte(pSS), 2);
      Dec(L, 6);
      Inc(PByte(S), 6);
    end;
  end else
  begin
    // hh:mm:ss.zzzzzz
    // hh-mm-ss.zzzzzz
    // hh:mm:ss.zzz
    // hh-mm-ss.zzz
    // hh:mm:ss
    // hh-mm-ss
    // hh:mm
    // hh-mm

    case S[3] of
      DT_MIN: if (L > 5) then
              begin
                if (L < 8) or (S[6] <> DT_MIN) then goto fail;
                Dec(L, 8);
                Inc(PByte(S), 8);
                goto hhmmss_calculated;
              end;
      DT_CLN: if (L > 5) then
              begin
                if (L < 8) or (S[6] <> DT_CLN) then goto fail;
                Dec(L, 8);
                Inc(PByte(S), 8);
                goto hhmmss_calculated;
              end;
    else
      goto fail;
    end;

    // hh:mm
    // hh-mm
    pSS := {00}Pointer(@_2001[2]);
    Dec(L, 5);
    Inc(PByte(S), 5);
  end;

hhmmss_calculated:
  HH := NativeInt(pHH[1])*10 + NativeInt(pHH[2]);
  NN := NativeInt(pNN[1])*10 + NativeInt(pNN[2]);
  SS := NativeInt(pSS[1])*10 + NativeInt(pSS[2]);
  if (HH > 23) or (NN > 59) or (SS > 59) then goto fail;

  SS := SS + SECPERHOUR * HH;
  SS := SS + SECPERMINUTE * NN;

  // Time value
  R := F.Value;
  TimeConst := @TIME_CONSTS[0];
  if (TPoint(R^).Y < 0) then Inc(TimeConst, 3);
  R^ := R^ + TimeConst^ * SS;

  // Milliseconds
  if (L <> 0) then
  begin
    Inc(TimeConst);
    Dec(L);
    if (S[1] <> DT_POINT) then goto fail;
    Inc(PByte(S));

    if (L = 6) then Inc(TimeConst)
    else
    if (L <> 3) then goto fail;

    SS := 0;
    repeat
      HH := S[1];
      SS := SS * 10;
      if (HH >= 10) then goto fail;

      Dec(L);
      SS := SS + HH;
      Inc(PByte(S));
    until (L = 0);
    R^ := R^ + TimeConst^ * SS;
  end;

  goto done;
fail:
  Result := False;
  Exit;
done:
  Result := True;
end;


type
  TCardinalDivMod = packed record
    D: Cardinal;
    M: Cardinal;
  end;

// universal ccbbbbaaaa ==> cc bbbb aaaa
function SeparateCardinal(P: PCardinal; X: NativeUInt{Cardinal}): PCardinal;
label
  _58;
type
  PHugeCardinalArray = ^HugeCardinalArray;
var
  Y: NativeUInt;
  {$ifdef CPUX86}
    Param: NativeUInt;
  {$endif}
begin
  if (X >= DIGITS_4) then
  begin
    if (X >= DIGITS_8) then
    begin
      //_910:
      {$if Defined(LARGEINT)}
        Y := (NativeInt(X) * $55E63B89) shr 57;
      {$elseif Defined(CPUX86)}
      Param := X;
      asm
        mov eax, $55E63B89
        mul Param
        shr edx, (57 - 32)
        mov Param, edx
      end;
      Y := Param;
      {$else .CPUARM .SMALLINT}
        Y := X div DIGITS_8;
      {$ifend}

      P^ := Y;
      Inc(P);
      X := X - (Y * DIGITS_8);
      goto _58;
    end else
    begin
    _58:
      {$if Defined(LARGEINT)}
        Y := (NativeInt(X) * $68DB8BB) shr 40;
      {$elseif Defined(CPUX86)}
      Param := X;
      asm
        mov eax, $68DB8BB
        mul Param
        shr edx, (40 - 32)
        mov Param, edx
      end;
      Y := Param;
      {$else .CPUARM .SMALLINT}
        Y := X div DIGITS_4;
      {$ifend}
      P^ := Y;
      PHugeCardinalArray(P)^[1] := NativeInt(NativeInt(X) + (NativeInt(Y) * -DIGITS_4)); // X - (NativeInt(Y) * DIGITS_4);

      Result := @PHugeCardinalArray(P)^[2];
    end;
  end else
  begin
    P^ := X;
    Result := @PHugeCardinalArray(P)^[1];
  end;
end;


// DivMod.D := X64 div DIGITS_8;
// DivMod.M := X64 mod DIGITS_8;
procedure DivideUInt64_8({$ifdef SMALLINT}var{$endif} X64: Int64; var DivMod: TCardinalDivMod);
  {$ifdef CPUINTELASM}{$ifdef FPC}assembler; nostackframe;{$endif}{$endif}
const
  UN_DIGITS_8: Double = (1 / DIGITS_8);
{$if Defined(CPUX86ASM)}
asm
  { [X64]: eax, [DivMod]: edx }

  // DivMod.D := Round(X64 * UN_DIGITS_8)
  fild qword ptr [eax]
  fmul UN_DIGITS_8
  fistp dword ptr [edx]

  // M := X64 + (D * -DIGITS_8);
  mov ecx, [edx]
  imul ecx, -DIGITS_8
  add ecx, [eax]

  // if (M < 0) then
  jns @done
    add ecx, DIGITS_8
    sub [edx], 1

@done:
  mov [edx + 4], ecx
end;
{$elseif Defined(CPUX64ASM)}
asm
  { X64: rcx, [DivMod]: rdx }

  // D := Round(X64 * UN_DIGITS_8)
  cvtsi2sd xmm0, rcx
  {$ifdef FPC}
  mov rax, offset UN_DIGITS_8
  movsd xmm1, [rax]
  mulsd xmm0, xmm1
  {$else}
  mulsd xmm0, UN_DIGITS_8
  {$endif}
  cvtsd2si rax, xmm0

  // M := X64 - D * DIGITS_8;
  imul r8, rax, DIGITS_8
  sub rcx, r8

  // if (M < 0) then
  jge @done
    add rcx, DIGITS_8
    sub rax, 1

@done:
  // DivMod.D := D;
  // DivMod.M := M;
  shl rcx, 32
  add rax, rcx
  mov [rdx], rax
end;
{$else .POSIX}
var
  D, M: NativeInt;
begin
  PDouble(@DivMod)^ := (X64 * UN_DIGITS_8) + DBLROUND_CONST;

  D := DivMod.D;
  {$ifdef LARGEINT}
    M := X64 - (D * DIGITS_8);
  {$else .CPUARM .SMALLINT}
    M := PInteger(@X64)^ + (D * -DIGITS_8);
  {$endif}

  if (M < 0) then
  begin
    Inc(M, DIGITS_8);
    DivMod.D := D - 1;
  end;

  DivMod.M := M;
end;
{$ifend}


// universal UInt64 separate (20 digits maximum)
function SeparateUInt64(P: PCardinal; X64: {U}Int64): PCardinal;
label
  _1316, _58;
type
  PHugeCardinalArray = ^HugeCardinalArray;
var
  X, Y: NativeUInt;
  Buffer: TCardinalDivMod;
begin
  {$ifdef LARGEINT}
  if (NativeUInt(X64) > High(Cardinal)) then
  {$else .SMALLINT}
  Y := TPoint(X64).Y;
  X := TPoint(X64).X;
  if (Y <> 0) then
  {$endif}
  begin
    // 17..20
    {$ifdef LARGEINT}
    if (NativeUInt(X64) >= NativeUInt(DIGITS_16)) then
    {$else .SMALLINT}
    if (Y >= $002386f2) and
       ((Y > $002386f2) or (X >= $6fc10000)) then
    {$endif}
    begin
      {$ifdef SMALLINT}
      // if (UInt64(X64) >= NINE_BB) then
      if (Y >= $7ce66c50) and
         ((Y > $7ce66c50) or (X >= $e2840000)) then
      begin
        // if (UInt64(X64) >= TEN_BB) then
        if (Y >= $8ac72304) and
           ((Y > $8ac72304) or (X >= $89e80000)) then
        begin
          Y := ((X64 - TEN_BB) div DIGITS_16) + 1000;
        end else
        begin
          Y := ((X64 - NINE_BB) div DIGITS_16) + 900;
        end;
      end else
      {$endif}
      begin
        {$ifdef LARGEINT}
          Y := NativeUInt(X64) div NativeUInt(DIGITS_16);
        {$else .SMALLINT}
          Y := X64 div DIGITS_16;
        {$endif}
      end;

      P^ := Y;
      X64 := X64 - (Int64(Y) * DIGITS_16);
      Inc(P);
      goto _1316;
    end;

    // 9..16
    {$ifdef LARGEINT}
    if (NativeUInt(X64) >= NativeUInt(DIGITS_12)) then
    {$else .SMALLINT}
    if (Y >= $000000e8) and
       ((Y > $000000e8) or (X >= $d4a51000)) then
    {$endif}
    begin
      // 13..16
    _1316:
      DivideUInt64_8(X64, Buffer);
      X := Buffer.D;

      {$if Defined(LARGEINT)}
        Y := (NativeInt(X) * $68DB8BB) shr 40;
      {$elseif Defined(CPUX86)}
      asm
        mov eax, $68DB8BB
        mul Buffer.D
        shr edx, (40 - 32)
        mov Buffer.D, edx
      end;
      Y := Buffer.D;
      {$else .CPUARM .SMALLINT}
        Y := X div DIGITS_4;
      {$ifend}

      P^ := Y;
      PHugeCardinalArray(P)^[1] := NativeInt(NativeInt(X) + (NativeInt(Y) * -DIGITS_4)); // X - (NativeInt(Y) * DIGITS_4);
      Inc(P, 2);

      X := Buffer.M;
    end else
    begin
      // 9..12
      DivideUInt64_8(X64, Buffer);
      P^ := Buffer.D;
      Inc(P);
      X := Buffer.M;
    end;

    goto _58;
  end else
  begin
    {$ifdef LARGEINT}
    X := X64;
    {$endif}

    if (X >= DIGITS_4) then
    begin
      if (X >= DIGITS_8) then
      begin
        //_910:
        {$if Defined(LARGEINT)}
          Y := (NativeInt(X) * $55E63B89) shr 57;
        {$elseif Defined(CPUX86)}
        Buffer.D := X;
        asm
          mov eax, $55E63B89
          mul Buffer.D
          shr edx, (57 - 32)
          mov Buffer.D, edx
        end;
        Y := Buffer.D;
        {$else .CPUARM .SMALLINT}
          Y := X div DIGITS_8;
        {$ifend}

        P^ := Y;
        Inc(P);
        X := X - (Y * DIGITS_8);
        goto _58;
      end else
      begin
      _58:
        {$if Defined(LARGEINT)}
          Y := (NativeInt(X) * $68DB8BB) shr 40;
        {$elseif Defined(CPUX86)}
        Buffer.D := X;
        asm
          mov eax, $68DB8BB
          mul Buffer.D
          shr edx, (40 - 32)
          mov Buffer.D, edx
        end;
        Y := Buffer.D;
        {$else .CPUARM .SMALLINT}
          Y := X div DIGITS_4;
        {$ifend}

        P^ := Y;
        PHugeCardinalArray(P)^[1] := NativeInt(NativeInt(X) + (NativeInt(Y) * -DIGITS_4)); // X - (NativeInt(Y) * DIGITS_4);

        Result := @PHugeCardinalArray(P)^[2];
      end;
    end else
    begin
      P^ := X;
      Result := @PHugeCardinalArray(P)^[1];
    end;
  end;
end;


const
  DIGITS_LOOKUP_ASCII: array[0..99] of Word = (
    $3030, $3130, $3230, $3330, $3430, $3530, $3630, $3730, $3830, $3930,
    $3031, $3131, $3231, $3331, $3431, $3531, $3631, $3731, $3831, $3931,
    $3032, $3132, $3232, $3332, $3432, $3532, $3632, $3732, $3832, $3932,
    $3033, $3133, $3233, $3333, $3433, $3533, $3633, $3733, $3833, $3933,
    $3034, $3134, $3234, $3334, $3434, $3534, $3634, $3734, $3834, $3934,
    $3035, $3135, $3235, $3335, $3435, $3535, $3635, $3735, $3835, $3935,
    $3036, $3136, $3236, $3336, $3436, $3536, $3636, $3736, $3836, $3936,
    $3037, $3137, $3237, $3337, $3437, $3537, $3637, $3737, $3837, $3937,
    $3038, $3138, $3238, $3338, $3438, $3538, $3638, $3738, $3838, $3938,
    $3039, $3139, $3239, $3339, $3439, $3539, $3639, $3739, $3839, $3939);

  HEX_LOOKUP_ASCII: array[Byte] of Word = (
    $3030, $3130, $3230, $3330, $3430, $3530, $3630, $3730,
    $3830, $3930, $4130, $4230, $4330, $4430, $4530, $4630,
    $3031, $3131, $3231, $3331, $3431, $3531, $3631, $3731,
    $3831, $3931, $4131, $4231, $4331, $4431, $4531, $4631,
    $3032, $3132, $3232, $3332, $3432, $3532, $3632, $3732,
    $3832, $3932, $4132, $4232, $4332, $4432, $4532, $4632,
    $3033, $3133, $3233, $3333, $3433, $3533, $3633, $3733,
    $3833, $3933, $4133, $4233, $4333, $4433, $4533, $4633,
    $3034, $3134, $3234, $3334, $3434, $3534, $3634, $3734,
    $3834, $3934, $4134, $4234, $4334, $4434, $4534, $4634,
    $3035, $3135, $3235, $3335, $3435, $3535, $3635, $3735,
    $3835, $3935, $4135, $4235, $4335, $4435, $4535, $4635,
    $3036, $3136, $3236, $3336, $3436, $3536, $3636, $3736,
    $3836, $3936, $4136, $4236, $4336, $4436, $4536, $4636,
    $3037, $3137, $3237, $3337, $3437, $3537, $3637, $3737,
    $3837, $3937, $4137, $4237, $4337, $4437, $4537, $4637,
    $3038, $3138, $3238, $3338, $3438, $3538, $3638, $3738,
    $3838, $3938, $4138, $4238, $4338, $4438, $4538, $4638,
    $3039, $3139, $3239, $3339, $3439, $3539, $3639, $3739,
    $3839, $3939, $4139, $4239, $4339, $4439, $4539, $4639,
    $3041, $3141, $3241, $3341, $3441, $3541, $3641, $3741,
    $3841, $3941, $4141, $4241, $4341, $4441, $4541, $4641,
    $3042, $3142, $3242, $3342, $3442, $3542, $3642, $3742,
    $3842, $3942, $4142, $4242, $4342, $4442, $4542, $4642,
    $3043, $3143, $3243, $3343, $3443, $3543, $3643, $3743,
    $3843, $3943, $4143, $4243, $4343, $4443, $4543, $4643,
    $3044, $3144, $3244, $3344, $3444, $3544, $3644, $3744,
    $3844, $3944, $4144, $4244, $4344, $4444, $4544, $4644,
    $3045, $3145, $3245, $3345, $3445, $3545, $3645, $3745,
    $3845, $3945, $4145, $4245, $4345, $4445, $4545, $4645,
    $3046, $3146, $3246, $3346, $3446, $3546, $3646, $3746,
    $3846, $3946, $4146, $4246, $4346, $4446, $4546, $4646);

function WriteCardinalAscii(var DigitsRec: TDigitsRec; X{Cardinal},
  Digits: NativeUInt): PByte;
label
  write_quads, write_nulls;
const
  NATIVE_GAP = SizeOf(NativeUInt) - 1;
  NATIVE_SHIFT = {$ifdef LARGEINT}3{$else}2{$endif};
type
  PHugeCardinalArray = ^HugeCardinalArray;

{$ifdef CPUX86}
const
  ASCII_NULLS = $30303030;
{$else}
var
  ASCII_NULLS: NativeUInt;
{$endif}

var
  LowP, P: PByte;
  Count, i: NativeUInt;
  Quads, TopQuad: PCardinal;
  U, V: NativeInt;
begin
  if (NativeUInt(Digits - 1) <= 31) then
  begin
    LowP := Pointer(@DigitsRec.Ascii[31 - NativeUInt(Digits - 1)]);
  end else
  begin
    LowP := Pointer(@DigitsRec.Buffer[0]);
  end;
  P := Pointer(@DigitsRec.Buffer[0]);

  if (X < DIGITS_4) then
  begin
    if (X < DIGITS_2) then
    begin
      Dec(P, SizeOf(Word));
      PWord(P)^ := DIGITS_LOOKUP_ASCII[X];
      Inc(P, Byte(X < DIGITS_1));
      goto write_nulls;
    end else
    begin
      U := X;
      Pointer(TopQuad) := P;
      Pointer(Quads) := P;
      TopQuad^ := U;
      goto write_quads;
    end;
  end else
  begin
    TopQuad := SeparateCardinal(PCardinal(P), X);

    Quads := PCardinal(P);
    repeat
      Dec(TopQuad);

      // V := U div 100;
      // U := U mod 100;
      U := TopQuad^;
    write_quads:
      V := (U * $147B) shr 19;
      U := U - (V * 100);

      // values
      V := DIGITS_LOOKUP_ASCII[V];
      Dec(P, SizeOf(Cardinal));
      PCardinal(P)^ := (DIGITS_LOOKUP_ASCII[U] shl 16) + V;
    until (Quads = TopQuad);

    U := TopQuad^;
    Inc(P, SizeOf(Cardinal) - 1);
    Dec(P, Byte(Byte(U > 9) + Byte(U > 99) + Byte(U > 999)));
  end;

write_nulls:
  if (NativeUInt(LowP) < NativeUInt(P)) then
  begin
    Count := NativeUInt(P) - NativeUInt(LowP);
    {$ifNdef CPUX86}
    ASCII_NULLS := {$ifdef LARGEINT}$3030303030303030{$else}$30303030{$endif};
    {$endif}

    if (NativeInt(Count) and NATIVE_GAP <> 0) then
    begin
      Dec(P, SizeOf(NativeUInt));
      PNativeUInt(P)^ := ASCII_NULLS;
      Inc(P, SizeOf(NativeUInt));
      Dec(P, Count and NATIVE_GAP);
    end;

    for i := 1 to (Count shr NATIVE_SHIFT) do
    begin
      Dec(P, SizeOf(NativeUInt));
      PNativeUInt(P)^ := ASCII_NULLS;
    end;
  end;

  Result := P;
end;

function WriteUInt64Ascii(var DigitsRec: TDigitsRec;
  X64: {$ifdef SMALLINT}PInt64{$else}Int64{$endif}; Digits: NativeUInt): PByte;
label
  write_separated, write_quads, write_nulls;
const
  NATIVE_GAP = SizeOf(NativeUInt) - 1;
  NATIVE_SHIFT = {$ifdef LARGEINT}3{$else}2{$endif};
type
  PHugeCardinalArray = ^HugeCardinalArray;

{$ifdef CPUX86}
const
  ASCII_NULLS = $30303030;
{$else}
var
  ASCII_NULLS: NativeUInt;
{$endif}

var
  LowP, P: PByte;
  Count, i, X: NativeUInt;
  Quads, TopQuad: PCardinal;
  U, V: NativeInt;
begin
  if (NativeUInt(Digits - 1) <= 31) then
  begin
    LowP := Pointer(@DigitsRec.Ascii[31 - NativeUInt(Digits - 1)]);
  end else
  begin
    LowP := Pointer(@DigitsRec.Buffer[0]);
  end;
  P := Pointer(@DigitsRec.Buffer[0]);

  {$ifdef LARGEINT}
  if (NativeUInt(X64) <= High(Cardinal)) then
  {$else .SMALLINT}
  if (PPoint(X64).Y = 0) then
  {$endif}
  begin
    X := Cardinal(X64{$ifdef SMALLINT}^{$endif});
    if (X < DIGITS_4) then
    begin
      if (X < DIGITS_2) then
      begin
        Dec(P, SizeOf(Word));
        PWord(P)^ := DIGITS_LOOKUP_ASCII[X];
        Inc(P, Byte(X < DIGITS_1));
        goto write_nulls;
      end else
      begin
        U := X;
        Pointer(TopQuad) := P;
        Pointer(Quads) := P;
        TopQuad^ := U;
        goto write_quads;
      end;
    end else
    begin
      TopQuad := SeparateCardinal(PCardinal(P), X);
      goto write_separated;
    end;
  end else
  begin
    TopQuad := SeparateUInt64(PCardinal(P), X64{$ifdef SMALLINT}^{$endif});

  write_separated:
    Quads := PCardinal(P);
    repeat
      Dec(TopQuad);

      // V := U div 100;
      // U := U mod 100;
      U := TopQuad^;
    write_quads:
      V := (U * $147B) shr 19;
      U := U - (V * 100);

      // values
      V := DIGITS_LOOKUP_ASCII[V];
      Dec(P, SizeOf(Cardinal));
      PCardinal(P)^ := (DIGITS_LOOKUP_ASCII[U] shl 16) + V;
    until (Quads = TopQuad);

    U := TopQuad^;
    Inc(P, SizeOf(Cardinal) - 1);
    Dec(P, Byte(Byte(U > 9) + Byte(U > 99) + Byte(U > 999)));
  end;

write_nulls:
  if (NativeUInt(LowP) < NativeUInt(P)) then
  begin
    Count := NativeUInt(P) - NativeUInt(LowP);
    {$ifNdef CPUX86}
    ASCII_NULLS := {$ifdef LARGEINT}$3030303030303030{$else}$30303030{$endif};
    {$endif}

    if (NativeInt(Count) and NATIVE_GAP <> 0) then
    begin
      Dec(P, SizeOf(NativeUInt));
      PNativeUInt(P)^ := ASCII_NULLS;
      Inc(P, SizeOf(NativeUInt));
      Dec(P, Count and NATIVE_GAP);
    end;

    for i := 1 to (Count shr NATIVE_SHIFT) do
    begin
      Dec(P, SizeOf(NativeUInt));
      PNativeUInt(P)^ := ASCII_NULLS;
    end;
  end;

  Result := P;
end;

function WriteHexAscii(var DigitsRec: TDigitsRec; X{Cardinal}, Digits: NativeUInt): PByte;
label
  write_hex;
const
  NATIVE_GAP = SizeOf(NativeUInt) - 1;
  NATIVE_SHIFT = {$ifdef LARGEINT}3{$else}2{$endif};

{$ifdef CPUX86}
const
  ASCII_NULLS = $30303030;
{$else}
var
  ASCII_NULLS: NativeUInt;
{$endif}

var
  P: PByte;
  LowP, Count, i: NativeUInt;
begin
  P := Pointer(@DigitsRec.Buffer[0]);
  LowP := NativeUInt(P);
  if (Digits <= 32) then Dec(LowP, Digits);

  goto write_hex;
  repeat
    X := X shr 8;
  write_hex:
    Dec(P, 2);
    PWord(P)^ := HEX_LOOKUP_ASCII[Byte(X)];
    if (X <= High(Byte)) then
    begin
      Inc(P, Ord(X <= 15));
      Break;
    end;
  until (False);

  if (LowP < NativeUInt(P)) then
  begin
    Count := NativeUInt(P) - LowP;
    {$ifNdef CPUX86}
    ASCII_NULLS := {$ifdef LARGEINT}$3030303030303030{$else}$30303030{$endif};
    {$endif}

    if (NativeInt(Count) and NATIVE_GAP <> 0) then
    begin
      Dec(P, SizeOf(NativeUInt));
      PNativeUInt(P)^ := ASCII_NULLS;
      Inc(P, SizeOf(NativeUInt));
      Dec(P, Count and NATIVE_GAP);
    end;

    for i := 1 to (Count shr NATIVE_SHIFT) do
    begin
      Dec(P, SizeOf(NativeUInt));
      PNativeUInt(P)^ := ASCII_NULLS;
    end;
  end;

  Result := P;
end;

function WriteHex64Ascii(var DigitsRec: TDigitsRec;
  X64: {$ifdef SMALLINT}PInt64{$else}Int64{$endif}; Digits: NativeUInt): PByte;
label
  write_hex;
const
  NATIVE_GAP = SizeOf(NativeUInt) - 1;
  NATIVE_SHIFT = {$ifdef LARGEINT}3{$else}2{$endif};

{$ifdef CPUX86}
const
  ASCII_NULLS = $30303030;
{$else}
var
  ASCII_NULLS: NativeUInt;
{$endif}

var
  P: PByte;
  LowP, Count, i, X: NativeUInt;
begin
  P := Pointer(@DigitsRec.Buffer[0]);
  LowP := NativeUInt(P);
  if (Digits <= 32) then Dec(LowP, Digits);

  {$ifdef LARGEINT}
  if (NativeUInt(X64) > High(Cardinal)) then
  {$else .SMALLINT}
  if (PPoint(X64).Y <> 0) then
  {$endif}
  begin
    X := Cardinal(X64{$ifdef SMALLINT}^{$endif});
    Dec(P, 2);
    PWord(P)^ := HEX_LOOKUP_ASCII[Byte(X)];
    X := X shr 8;
    Dec(P, 2);
    PWord(P)^ := HEX_LOOKUP_ASCII[Byte(X)];
    X := X shr 8;
    Dec(P, 2);
    PWord(P)^ := HEX_LOOKUP_ASCII[Byte(X)];
    X := X shr 8;
    Dec(P, 2);
    PWord(P)^ := HEX_LOOKUP_ASCII[X];
    X := {$ifdef LARGEINT}X64 shr 32{$else}PPoint(X64).Y{$endif};
  end else
  begin
    X := Cardinal(X64{$ifdef SMALLINT}^{$endif});
  end;

  goto write_hex;
  repeat
    X := X shr 8;
  write_hex:
    Dec(P, 2);
    PWord(P)^ := HEX_LOOKUP_ASCII[Byte(X)];
    if (X <= High(Byte)) then
    begin
      Inc(P, Ord(X <= 15));
      Break;
    end;
  until (False);

  if (LowP < NativeUInt(P)) then
  begin
    Count := NativeUInt(P) - LowP;

    {$ifNdef CPUX86}
    ASCII_NULLS := {$ifdef LARGEINT}$3030303030303030{$else}$30303030{$endif};
    {$endif}

    if (NativeInt(Count) and NATIVE_GAP <> 0) then
    begin
      Dec(P, SizeOf(NativeUInt));
      PNativeUInt(P)^ := ASCII_NULLS;
      Inc(P, SizeOf(NativeUInt));
      Dec(P, Count and NATIVE_GAP);
    end;

    for i := 1 to (Count shr NATIVE_SHIFT) do
    begin
      Dec(P, SizeOf(NativeUInt));
      PNativeUInt(P)^ := ASCII_NULLS;
    end;
  end;

  Result := P;
end;


function FailureDateTime(const Value: {TDateTime}Double): ECachedText;
var
  ResStringRec: PResStringRec;
begin
  ResStringRec := Pointer(@SInvalidDateTimeFloat);
  Result := ECachedText.CreateResFmt(ResStringRec, [Value]);
end;

// out Quads: days, seconds, zzzzzz (microseconds)
procedure SeparateDateTime(var DigitsRec: TDigitsRec;
  {$ifdef CPUX86}var{$endif} X: {TDateTime}Double; const DateOnly: Boolean);
label
  fail;
type
  HugeIntegerArray = array[0..High(Integer) div SizeOf(Integer) - 1] of Integer;
  PHugeIntegerArray = ^HugeIntegerArray;
const
  SECPERMINUTE = 60;
  SECPERHOUR = 60 * SECPERMINUTE;
  SECPERDAY = 24 * SECPERHOUR;
  MICROSECPERSEC = 1000000;

  DATEDELTA = 693594;
var
  P: PInteger;
  Value: Integer;
  {$ifNdef CPUX86}
    DBLROUND_CONST: Double;
  {$endif}
begin
  P := Pointer(@DigitsRec.Quads[0]);
  {$ifNdef CPUX86}
    DBLROUND_CONST := Tiny.Cache.Text.DBLROUND_CONST;
  {$endif}

  // P^ := Trunc(X + DateDelta)
  // X := Frac(X + DateDelta)
  X := X + DATEDELTA;
  PDouble(P)^ := X + DBLROUND_CONST;
  Value := PHugeIntegerArray(P)[0];
  if ({$ifNdef CPUX86}Value{$else}P^{$endif} > X) then
  begin
    Dec(Value);
    P^ := Value;
  end;
  if (Cardinal(Value) > {31.12.9999}2958465 + DATEDELTA) then goto fail;
  X := X - {$ifNdef CPUX86}Value{$else}P^{$endif};
  Inc(P);
  if (DateOnly) then
  begin
    Exit;
  fail:
    raise FailureDateTime(X);
  end;

  // P^ := Trunc(X * SECPERDAY)
  // X := Frac(X * SECPERDAY)
  X := X * SECPERDAY;
  PDouble(P)^ := X + DBLROUND_CONST;
  Value := PHugeIntegerArray(P)[0];
  if ({$ifNdef CPUX86}Value{$else}P^{$endif} > X) then
  begin
    Dec(Value);
    P^ := Value;
  end;
  X := X - {$ifNdef CPUX86}Value{$else}P^{$endif};
  Inc(P);

  // P^ := Trunc(X * MICROSECPERSEC);
  PDouble(P)^ := X * MICROSECPERSEC + DBLROUND_CONST;
  if (P^ = MICROSECPERSEC) then P^ := MICROSECPERSEC - 1;
end;


const
  DATETIME_SEPARATORS: array[0..Ord(High(TDateTimeSeparator))] of Byte = (
    {sepNone} 0,
     {sepDot} Ord('.'),
    {sepDash} Ord('-'),
   {sepSlash} Ord('/'),
   {sepColon} Ord(':'),
   {sepSpace} Ord(' '),
       {sepT} Ord('T')
  );

function WriteDateAscii(var DigitsRec: TDigitsRec; P: PByte;
  const Settings: TDateTimeSettings): PByte;
type
  PHugeCardinalArray = ^HugeCardinalArray;
const
  D1 = 365;
  D4 = D1 * 4 + 1;
  D100 = D4 * 25 - 1;
  D400 = D100 * 4 + 1;

  // L:28, DD:24, MM:20, SEP2:16, SEP1:12, YYYY:8, SEPCHAR: 0
  FORMAT_SETTINGS: array[0..2*Ord(High(TDateFormat)) + 1] of Cardinal = (
    {Sep + dateYYYYMMDD} $a8574000,
    {Sep + dateDDMMYYYY} $a0352600,
      {Sep + dateDDMMYY} $80352400,
    {Sep + dateMMDDYYYY} $a3052600,
      {Sep + dateMMDDYY} $83052400,
          {dateYYYYMMDD} $864ff000,
          {dateDDMMYYYY} $802ff400,
            {dateDDMMYY} $602ff200,
          {dateMMDDYYYY} $820ff400,
            {dateMMDDYY} $620ff200
  );
  DAY_TABLE: array [0..11] of Integer = (31, 30, 31, 30, 31, 31, 30, 31, 30,
    31, 31, MaxInt);
  OFFSET_TABLE: array [0..11] of Integer =
  (
    0-1,
    0+31-1,
    0+31+30-1,
    0+31+30+31-1,
    0+31+30+31+30-1,
    0+31+30+31+30+31-1,
    0+31+30+31+30+31+31-1,
    0+31+30+31+30+31+31+30-1,
    0+31+30+31+30+31+31+30+31-1,
    0+31+30+31+30+31+31+30+31+30-1,
    0+31+30+31+30+31+31+30+31+30+31-1,
    0+31+30+31+30+31+31+30+31+30+31+31-1
  );
var
  Y, M, D: NativeInt;
  Fmt, X: NativeInt;

  Store: record
    Fmt: NativeInt;
  end;
begin
  // format settings
  Fmt := Settings.F.DateOptions;
  Store.Fmt := FORMAT_SETTINGS[Byte(Fmt) + Byte(Fmt and $ff00 = 0) * 5] + DATETIME_SEPARATORS[Byte(Fmt shr 8)];

  // four hundred years
  D := DigitsRec.Quads[0];
  Inc(D, D1 - 31 - 28 - 1);
  Y := 1;
  if (D >= 4*D400) then
  repeat
    Dec(D, 4*D400);
    Inc(Y, 4*400);
  until (D < 4*D400);
  if (D >= D400) then
  repeat
    Dec(D, D400);
    Inc(Y, 400);
  until (D < D400);

  // bounded Y := Y + 100 * (D div D100)
  // D := D mod D100
  if (D >= D100) then
  begin
    Dec(D, D100);
    Inc(Y, 100);
    if (D >= D100) then
    begin
      Dec(D, D100);
      Inc(Y, 100);
      if (D >= D100) then
      begin
        Dec(D, D100);
        Inc(Y, 100);
      end;
    end;
  end;

  // Y := Y + 4 * (D div D4)
  // D := D mod D4
  M := (D * $59B7) shr 25; // M := D div D4
  Inc(Y, M * 4);
  D := D - M * D4;

  // bounded Y := Y + (D div D1)
  // D := D mod D1
  if (D >= D1) then
  begin
    Dec(D, D1);
    Inc(Y, 1);
    if (D >= D1) then
    begin
      Dec(D, D1);
      Inc(Y, 1);
      if (D >= D1) then
      begin
        Dec(D, D1);
        Inc(Y, 1);
      end;
    end;
  end;

  // detect month/day, year correction
  M := D shr 5;
  D := D - OFFSET_TABLE[M];
  Fmt := DAY_TABLE[M];
  if (D > Fmt) then
  begin
    Inc(M);
    Dec(D, Fmt);
  end;
  Fmt := Byte(M <= (12-3));
  Dec(Y, Fmt);
  Inc(M, 3);
  Dec(M, (Fmt - 1) and 12);

  // MM, DD
  Fmt := Store.Fmt;
  PWord(@PByteCharArray(P)[(Fmt shr 20) and $f])^ := DIGITS_LOOKUP_ASCII[M];
  PWord(@PByteCharArray(P)[(Fmt shr 24) and $f])^ := DIGITS_LOOKUP_ASCII[D];

  // YYYY
  X := (Y * $147B) shr 19; // X := Y div 100
  Y := Y - (X * 100);      // Y := Y mod 100
  M := (Fmt shr 8) and $f;
  PWord(@PByteCharArray(P)[M])^ := DIGITS_LOOKUP_ASCII[X];
  Inc(M, 2);
  PWord(@PByteCharArray(P)[M])^ := DIGITS_LOOKUP_ASCII[Y];

  // separators
  M := Fmt and $7f;
  PByteCharArray(P)[(Fmt shr 12) and $f] := M;
  PByteCharArray(P)[(Fmt shr 16) and $f] := M;

  // Result
  Inc(P, Fmt shr 28);
  Result := P;
end;

function WriteTimeAscii(var DigitsRec: TDigitsRec; P: PByte;
  const Settings: TDateTimeSettings): PByte;
const
  SECPERMINUTE = 60;
  SECPERHOUR = 60 * SECPERMINUTE;
  SECPERDAY = 24 * SECPERHOUR;
  MICROSECPERSEC = 1000000;

  // L:28, ZZ: 24, SEPZZ: 20, SS:16, MM:12, USEZZ:8, SEPZZCHAR: 0
  FORMAT_SETTINGS: array[0..4*Ord(High(TTimeFormat)) + 3] of Cardinal = (
           // TimeSep: True, MicroSep: True
            {timeHHMM} $5fff3000,
          {timeHHMMSS} $8ff63000,
       {timeHHMMSSZZZ} $c9863100,
    {timeHHMMSSZZZZZZ} $f9863100,
           // TimeSep: False, MicroSep: True
            {timeHHMM} $4fff2000,
          {timeHHMMSS} $6ff42000,
       {timeHHMMSSZZZ} $a7642100,
    {timeHHMMSSZZZZZZ} $d7642100,
           // TimeSep: True, MicroSep: False
            {timeHHMM} $5fff3000,
          {timeHHMMSS} $8ff63000,
       {timeHHMMSSZZZ} $b8f63100,
    {timeHHMMSSZZZZZZ} $e8f63100,
           // TimeSep: False, MicroSep: False
            {timeHHMM} $4fff2000,
          {timeHHMMSS} $6ff42000,
       {timeHHMMSSZZZ} $96f42100,
    {timeHHMMSSZZZZZZ} $c6f42100
  );

var
  Fmt: NativeInt;
  H, M, S: NativeInt;
  PZZ: PWord;

  Store: record
  case Integer of
    0: (IntegerValue: Integer);
    1: (DoubleValue: Double; Microseconds: NativeInt);
  end;
begin
  // time separator
  Fmt := Settings.F.TimeOptions;
  S := $ff00;
  S := DATETIME_SEPARATORS[(S and Fmt) shr 8];
  Inc(P, 2);
  PNativeInt(P)^ := S + S shl 24;
  Dec(P, 2);

  // format settings
  S := Byte(Fmt shr 16);
  Fmt := FORMAT_SETTINGS[((S - 1) and 8) +
    (-NativeInt(Byte(Fmt and $ff00 = 0)) and 4) + Byte(Fmt)];
  Fmt := Fmt + DATETIME_SEPARATORS[S];
  Store.Microseconds := DigitsRec.Quads[2];

  // HH(ascii), MM, SS
  S := DigitsRec.Quads[1];
  H := (S * $91A3) shr 27; // H := S div SECPERHOUR
  S := S - H * SECPERHOUR; // S := S mod SECPERHOUR
  PWord(P)^ := DIGITS_LOOKUP_ASCII[H];
  M := (S * $889) shr 17;    // M := S div SECPERMINUTE
  S := S - M * SECPERMINUTE; // S := S mod SECPERMINUTE

  // MM(ascii), SS(ascii)
  PWord(@PByteCharArray(P)[(Fmt shr 12) and $f])^ := DIGITS_LOOKUP_ASCII[M];
  PWord(@PByteCharArray(P)[(Fmt shr 16) and $f])^ := DIGITS_LOOKUP_ASCII[S];

  // ZZ
  if (Fmt and 256 <> 0) then
  begin
    PByteCharArray(P)[(Fmt shr 20) and $f] := Fmt;

    Store.DoubleValue := Store.Microseconds * (1 / 10000) + DBLROUND_CONST;
    M := Store.IntegerValue;
    S := Store.Microseconds;
    S := S - M * 10000;
    if (S < 0) then // round fix
    begin
      Dec(M);
      Inc(S, 10000);
    end;
    PZZ := Pointer(@PByteCharArray(P)[(Fmt shr 24) and $f]);
    PZZ^ := DIGITS_LOOKUP_ASCII[M];

    M := (S * $147B) shr 19; // M := S div 100
    S := S - (M * 100);      // S := S mod 100
    Inc(PZZ);
    PZZ^ := DIGITS_LOOKUP_ASCII[M];
    Inc(PZZ);
    PZZ^ := DIGITS_LOOKUP_ASCII[S];
  end;

  // Result
  Inc(P, Fmt shr 28);
  Result := P;
end;


type
  TStoredFloatSettings = packed record
    Value: TFloatSettings;
    Exp: NativeInt;
  end;
  PStoredFloatSettings = ^TStoredFloatSettings;


function WriteNumberDigits(var DigitsRec: TDigitsRec; Src: PByte;
  const Settings: TStoredFloatSettings): PByte;
const
  THOUSAND_SEPARATORS: array[Boolean] of Byte = (Ord(','), Ord(#32));
var
  Separator: Cardinal;
  P: PByte;
  Aligned, N: NativeInt;
begin
  // first 1..3 digits
  N := Settings.Exp;
  Aligned := ((N * 11) shr 5) * 3;
  P := @DigitsRec.Ascii[0];
  Dec(Aligned, Byte(N = Aligned) * 3);
  PCardinal(P)^ := PCardinal(Src)^;
  Dec(N, Aligned);
  Inc(Src, N);
  Inc(P, N);

  // triples
  if (Aligned > 0) then
  begin
    Separator := THOUSAND_SEPARATORS[Settings.Value.ThousandSpace];
    repeat
      Dec(Aligned, 3);
      PCardinal(P)^ := (PCardinal(Src)^ shl 8) + Separator;
      Inc(Src, 3);
      Inc(P, 3 + 1);
    until (Aligned = 0);
  end;

  // result
  Result := P;
end;

function WriteExponent(P: PByte; const Settings: TStoredFloatSettings): PByte;
const
  SHIFTS: array[1..4] of Byte = (24, 16, 8, 0);
var
  Exp: NativeInt;
  Digits, V: NativeInt;
begin
  Exp := Settings.Exp - 1;

  P^ := Ord('E');
  Inc(P);
  if (Exp >= 0) then
  begin
    if (Settings.Value.Format = ffExponent) then
    begin
      P^ := Ord('+');
      Inc(P);
    end;
  end else
  begin
    Exp := -Exp;
    P^ := Ord('-');
    Inc(P);
  end;

  Digits := Settings.Value.Digits;
  Digits := Digits and (-NativeInt(Byte(NativeUInt(Digits) <= 4)));
  V := 1 + Byte(Byte(Exp > 9) + Byte(Exp > 99) + Byte(Exp > 999));
  if (Digits <= V) then Digits := V;

  V := (Exp * $147B) shr 19; // V := Exp div 100;
  V := (DIGITS_LOOKUP_ASCII[Exp - (V * 100){Exp mod 100}] shl 16) + DIGITS_LOOKUP_ASCII[V];
  PCardinal(P)^ := V shr SHIFTS[Digits];
  Inc(P, Digits);

  Result := P;
end;

function WriteFloatAscii(var DigitsRec: TDigitsRec;
  const Float: {$ifdef EXTENDEDSUPPORT}PExtended{$else}Extended{$endif};
  const Settings: TFloatSettings): NativeUInt;
type
  TFloatValue = packed record
  case Integer of
    0: (Value: Extended);
    1: (Cardinals: array[0..1] of Cardinal);
    2: (_: array[1..SizeOf(TExtendedBytes) - SizeOf(Word)] of Byte; HighWord: Word);
    3: (Int64Value: Int64);
  end;
label
  float_zero, float_zero_decimals, float_unsupported, exp_corrective,
  fixed_nullchars, precision_decimals,
  round_large_decimal, fixup_int64_overflow, stored_tenpower, check_int64_overflow,
  store_int64_digits, write_negative_exp, write_enotation, write_exponent,
  write_fully_float, write_separated_decimals, write_decimals, done;
const
  CMinExtPrecision = 2;
  CMaxExtPrecision = {$ifdef EXTENDEDSUPPORT}18{$else}17{$endif};
  DECIMAL_SEPARATORS: array[Boolean] of Byte = (Ord(','), Ord('.'));

  e3 = Int64(1000);
  e5 = e3 * 100;
  e10 = e5 * e5;
  e15 = e10 * e5;
  DECIMAL_OVERFLOWS: array[0..18] of Int64 = (
    0{1}, 10, 100, e3, e3 * 10, e5, e5 * 10, e5 * 100, e5 * e3, e5 * e3 * 10,
    e10, e10 * 10, e10 * 100, e10 * e3, e10 * e3 * 10, e15, e15 * 10,
    e15 * 100, e15 * e3
  );

var
  Exp: NativeInt;
  P, Src: PByte;
  {$ifNdef EXTENDEDSUPPORT}
  N: Int64;
  {$endif}
  Precision, Decimals: NativeInt;

  TenPowers: PTenPowers;
  TenPowerPtr: PDouble;
  Quad, TopQuad: PCardinal;
  U, V: NativeInt;

  Store: packed record
    Settings: TStoredFloatSettings;
    Float: TFloatValue;
    {$if SizeOf(Extended) = 10}Align: Word;{$ifend}
  case Integer of
    0: (DoubleValue: Double; Sign, ENotation, ENotationCompact: Boolean; NullChars: Byte);
    1: (Int64Value: Int64; SignENotationCompactNullChars: NativeInt);
    2: (Cardinals: array[0..1] of Cardinal);
  end;
begin
  // settings, precision, decimals
  Exp{Options} := Settings.F.Options;
  Precision := Settings.F.PrecisionWidth;
  Store.Settings.Value.F.Options := Exp{Options};
  Store.Settings.Value.F.PrecisionWidth := Precision;
  Decimals := SmallInt(Precision shr 16);
  Precision := SmallInt(Precision);

  // float, exp
  {$ifdef EXTENDEDSUPPORT}
    Store.Float.Int64Value := TFloatValue(Float^).Int64Value;
    Exp := TFloatValue(Float^).HighWord;
  {$else}
    Store.Float.Value := Float;
    Exp := Store.Float.HighWord;
  {$endif}

  // min/max precision bounds
  if (NativeUInt(Precision + (-CMinExtPrecision)) >
    NativeUInt(CMaxExtPrecision - CMinExtPrecision)) then
  begin
    if (Precision < CMinExtPrecision) then Precision := CMinExtPrecision
    else
    Precision := CMaxExtPrecision;

    Store.Settings.Value.F.Precision := Precision;
  end;

  // sign, 0, +-INF, NaN
  Store.SignENotationCompactNullChars := (Exp shr 15);
  Exp := Exp and $7fff;
  Store.Float.HighWord := Exp;
  {$ifNdef EXTENDEDSUPPORT}Exp := Exp shr 4;{$endif}
  if (NativeUInt(Exp + (-1)) >= {$ifdef EXTENDEDSUPPORT}$7fff{$else}$7ff{$endif} - 1) then
  begin
    if (Exp <> 0) then
    begin
      // +-INF/NaN
      P := @DigitsRec.Ascii[0];
      if (Store.Float.Cardinals[0] = 0) and
        (Store.Float.Cardinals[1]{$ifdef EXTENDEDSUPPORT} = $80000000{$else} and $000fffff = 0{$endif}) then
      begin
        PCardinal(P)^ := Ord('I') + (Ord('N') shl 8) + (Ord('F') shl 16);
      end else
      begin
        PCardinal(P)^ := Ord('N') + (Ord('A') shl 8) + (Ord('N') shl 16);
        Store.Sign := False;
      end;
      Inc(P, 3);
      goto done;
    end else
    if (Store.Float.Cardinals[0] = 0) and
      (Store.Float.Cardinals[1] {$ifNdef EXTENDEDSUPPORT}and $000fffff{$endif} = 0) then
    begin
      if (Byte(Store.Settings.Value.Format) >= Byte(ffCurrency)) then
      begin
      float_unsupported:
        raise ECachedText.Create('Unsupported float format');
      end;

    float_zero:
      P := @DigitsRec.Ascii[0];
      P^ := Ord('0');
      Inc(P);
      Store.Sign := False;

      case Store.Settings.Value.Format of
        // ffGeneral: ;
        ffCurrency{ENotation}:
        begin
          PWord(P)^ := Ord('E') + (Ord('0') shl 8);
          Inc(P, SizeOf(Word));
        end;
        ffNumber, ffFixed:
        begin
          Decimals := Store.Settings.Value.Digits;
          if (Decimals > 0) then
          begin
            if (Decimals > CMaxExtPrecision) then
              Decimals := CMaxExtPrecision;
            goto float_zero_decimals;
          end;
        end;
        ffExponent:
        begin
          Decimals := Store.Settings.Value.Precision;
          Dec(Decimals);

        float_zero_decimals:
          P^ := DECIMAL_SEPARATORS[Store.Settings.Value.DecimalDot];
          Inc(P);
          repeat
            Dec(Decimals, SizeOf(Cardinal));
            PCardinal(P)^ := $30303030;
            Inc(P, SizeOf(Cardinal));
          until (Decimals <= 0);
          Inc(P, Decimals);

          Store.Settings.Exp := 1;
          if (Store.Settings.Value.Format = ffExponent) then goto write_exponent;
        end;
      end;

      goto done;
    end;
  end;

  // decimal exponent
  {$ifNdef EXTENDEDSUPPORT}
  if (Exp = 0) then
  begin
    N := Store.Float.Int64Value;
    if (N and $0008000000000000 = 0) then
    repeat
      Dec(Exp);
      N := N + N;
    until (N and $0008000000000000 <> 0);
  end;
  {$endif}
  Exp := SmallInt(((Exp - {$ifdef EXTENDEDSUPPORT}$3fff{$else}$3ff{$endif}) * $4D10) shr 16) + 1;
  TenPowers := @TEN_POWERS[True];
  if (Exp >= 0) then
  begin
    if (Exp <= 9) then
    begin
      TenPowerPtr := @TenPowers[Exp];
      goto exp_corrective;
    end else
    begin
      Store.DoubleValue := Tiny.Cache.Text.TenPower(TenPowers, Exp);
      TenPowerPtr := @Store.DoubleValue;
      goto exp_corrective;
    end;
  end else
  begin
    Exp := -Exp;
    Dec(TenPowers);
    if (Exp <= 9) then
    begin
      TenPowerPtr := @TenPowers[Exp];
    end else
    begin
      Store.DoubleValue := Tiny.Cache.Text.TenPower(TenPowers, Exp);
      TenPowerPtr := @Store.DoubleValue;
    end;
    Exp := -Exp;

  exp_corrective:
    Inc(Exp, Byte(Store.Float.Value >= TenPowerPtr^));
  end;
  Store.Settings.Exp := Exp;

  // check float format, digits count
  case Store.Settings.Value.Format of
    ffExponent:
    begin
      goto precision_decimals;
    end;
    ffFixed, ffNumber:
    begin
      if (Exp > Precision) then
      begin
        Store.Settings.Value.Format := {ENotation}ffCurrency;
      end else
      begin
        if (Decimals > CMaxExtPrecision) then
          Decimals := CMaxExtPrecision;
      end;

      Decimals := Decimals + Exp;
      if (NativeUInt(Decimals) <= NativeUInt(Precision)) then
      begin
        if (Decimals <= Exp) then
        begin
          Exp := Exp - Decimals;
          goto fixed_nullchars;
        end;
      end else
      begin
        if (Decimals < 0) then
        begin
          Store.Settings.Value.Format := ffFixed{/ffNumber};
          goto float_zero;
        end;
        Exp := Decimals - Precision;
      fixed_nullchars:
        if (Store.Settings.Value.Format <> {ENotation}ffCurrency) then
        begin
          P := Pointer(@DigitsRec.Quads[0]);
          Store.NullChars := Exp;
          Dec(P, Exp);
          repeat
            Dec(Exp, SizeOf(Cardinal));
            PCardinal(P)^ := $30303030;
            Inc(P, SizeOf(Cardinal));
          until (Exp <= 0);
        end;

        Exp := Store.Settings.Exp;
        if (Decimals > Precision) then goto precision_decimals;
      end;
    end;
    ffGeneral:
    begin
      if (Exp > Precision) or (Exp < -3) then
        Store.Settings.Value.Format := {ENotation}ffCurrency;

    precision_decimals:
      Decimals := Precision;
    end;
  else
    goto float_unsupported;
  end;

  // multiplier, int64 digits
  Exp := -(Exp - Decimals);
  TenPowers := @TEN_POWERS[False];
  if (Exp >= 0) then
  begin
    Exp := -Exp;
    Inc(TenPowers);
  end;
  Exp := -Exp;
  if (Exp <= 18) then
  begin
    if (Exp > 9) then
    begin
      Store.DoubleValue := TenPowers[9] * TenPowers[Exp - 9];
      goto stored_tenpower;
    round_large_decimal:
      if (Decimals < 17) then
      begin
        Store.Int64Value := Trunc{Round}(Store.Float.Value * TenPowerPtr^ + 0.5);
     end else
      begin
        Store.Int64Value := Trunc(Store.Float.Value * TenPowerPtr^);
      end;
      goto check_int64_overflow;
    fixup_int64_overflow:
      if (Store.Int64Value <> 0) then
      begin
        Inc(Store.Settings.Exp);
        if (Store.Settings.Exp > Store.Settings.Value.Precision) and
          (Store.Settings.Value.Format <> ffExponent) then
        begin
          Store.Settings.Value.Format := {ENotation}ffCurrency;
          Store.NullChars := 0;
        end;
        if (Store.Settings.Value.Format = ffExponent) and (Store.Int64Value > 1) then
          Store.Int64Value := Round(Store.Int64Value * (1 / 10));
      end else
      begin
        Store.Sign := False;
      end;
      goto store_int64_digits;
    end else
    begin
      TenPowerPtr := @TenPowers[Exp];
    end;
  end else
  begin
    Store.DoubleValue := Tiny.Cache.Text.TenPower(TenPowers, Exp);
  stored_tenpower:
    TenPowerPtr := @Store.DoubleValue;
  end;
  if (Decimals > 15) then goto round_large_decimal;
  Store.DoubleValue := Store.Float.Value * TenPowerPtr^ + 0.01 + DBLROUND_CONST;
  Store.Cardinals[1] := Store.Cardinals[1] and ((1 shl (51 - 32)) - 1);
check_int64_overflow:
  if (Store.Int64Value >= DECIMAL_OVERFLOWS[Decimals]) then goto fixup_int64_overflow;

store_int64_digits:
  // store int64 digits
  TopQuad := @DigitsRec.Quads[0];
  Quad := SeparateUInt64(TopQuad, Store.Int64Value);
  Dec(Quad);
  if {ffGeneral, ENotation}(NativeUInt(Store.Settings.Value.Format) - 1 > 2) and (Quad^ = 0) then
  begin
    if (Quad = TopQuad) then goto float_zero;
    Dec(Quad);
    if (Quad^ = 0) then
    begin
      Dec(Quad);
      if (Quad^ = 0) then
      begin
        Dec(Quad);
        if (Quad^ = 0) then Dec(Quad);
      end;
    end;
  end;
  Src := Pointer(TopQuad);
  Inc(Quad);
  Dec(Src, Store.NullChars);
  repeat
    Dec(Quad);
    U := Quad^;
    V := (U * $147B) shr 19;
    U := U - (V * 100);
    V := DIGITS_LOOKUP_ASCII[V];
    Dec(Src, SizeOf(Cardinal));
    PCardinal(Src)^ := (DIGITS_LOOKUP_ASCII[U] shl 16) + V;
    if (Quad = TopQuad) then Break;

    Dec(Quad);
    U := Quad^;
    V := (U * $147B) shr 19;
    U := U - (V * 100);
    V := DIGITS_LOOKUP_ASCII[V];
    Dec(Src, SizeOf(Cardinal));
    PCardinal(Src)^ := (DIGITS_LOOKUP_ASCII[U] shl 16) + V;
  until (Quad = TopQuad);

  U := Quad^;
  Inc(Src, SizeOf(Cardinal) - 1);
  Inc(Src, Byte(U = 0));
  Dec(Src, Byte(Byte(U > 9) + Byte(U > 99) + Byte(U > 999)));
  Decimals := NativeUInt(TopQuad) - NativeUInt(Src);

  // format chars
  P := @DigitsRec.Ascii[0];
  case Cardinal(Store.Settings.Value.Format) of
    Ord(ffNumber), Ord(ffFixed):
    begin
      Exp := Store.Settings.Exp;
      if (Exp <= 0) then goto write_negative_exp;
      if (Store.Settings.Value.Format = ffFixed) then goto write_fully_float;

      Dec(Decimals, Exp);
      P := WriteNumberDigits(PDigitsRec(P)^, Src, Store.Settings);
      Inc(Src, Exp);
      if (Decimals > 0) then goto write_separated_decimals;
    end;
    Ord(ffExponent):
    begin
      goto write_enotation;
    end;
  else
    // ffGeneral, ENotation
    U := PCardinal(@DigitsRec.Buffer[12])^ xor $30303030;
    Dec(Decimals, Byte(Byte(U and $ff000000 = 0) +
      Byte(U and $ffff0000 = 0) + Byte(U and $ffffff00 = 0)));

    if (Store.Settings.Value.Format = ffGeneral) then
    begin
      Exp := Store.Settings.Exp;
      if (Exp > 0) then
      begin
        if (Decimals >= Exp) then goto write_fully_float;

        Dec(Exp, Decimals);
        repeat
          Dec(Decimals, SizeOf(Cardinal));
          PCardinal(P)^ := PCardinal(Src)^;
          Inc(Src, SizeOf(Cardinal));
          Inc(P, SizeOf(Cardinal));
        until (Decimals <= 0);
        Inc(P, Decimals);
        repeat
          Dec(Exp, SizeOf(Cardinal));
          PCardinal(P)^ := $30303030;
          Inc(P, SizeOf(Cardinal));
        until (Exp <= 0);
        Inc(P, Exp);
        goto done;
      end else
      begin
        if (not Store.Settings.Value.GeneralCompact) then
        begin
        write_negative_exp:
          P^ := Ord('0');
          Inc(P);
        end;
        Exp := -Exp;
        P^ := DECIMAL_SEPARATORS[Store.Settings.Value.DecimalDot];
        Inc(P);

        if (Exp <> 0) then
        repeat
          Dec(Exp, SizeOf(Cardinal));
          PCardinal(P)^ := $30303030;
          Inc(P, SizeOf(Cardinal));
        until (Exp <= 0);
        Inc(P, Exp);
        goto write_decimals;
      end;
    end else
    begin
      // ENotation
    write_enotation:
      Dec(Decimals);
      P^ := Src^;
      Inc(Src);
      Inc(P);
      Store.ENotation := True;
      if (Decimals <> 0) then goto write_separated_decimals;
    write_exponent:
      P := WriteExponent(P, Store.Settings);
      goto done;
    end;

  write_fully_float:
    Dec(Decimals, Exp);
    repeat
      Dec(Exp, SizeOf(Cardinal));
      PCardinal(P)^ := PCardinal(Src)^;
      Inc(Src, SizeOf(Cardinal));
      Inc(P, SizeOf(Cardinal));
    until (Exp <= 0);
    Inc(P, Exp);
    Inc(Src, Exp);
    if (Decimals = 0) then goto done;
  write_separated_decimals:
    P^ := DECIMAL_SEPARATORS[Store.Settings.Value.DecimalDot];
    Inc(P);
  write_decimals:
    repeat
      Dec(Decimals, SizeOf(Cardinal));
      PCardinal(P)^ := PCardinal(Src)^;
      Inc(Src, SizeOf(Cardinal));
      Inc(P, SizeOf(Cardinal));
    until (Decimals <= 0);
    Inc(P, Decimals);
    if (Store.ENotation) then goto write_exponent;
  end;

done:
  Result := (NativeUInt(P) - NativeUInt(@DigitsRec.Ascii[0])) shl 1 +
    3 * NativeUInt(Store.Sign);
end;



{ ETinyString }

const
  ETINYSTRING_LENGTH_LIMIT = 31;

constructor ETinyString.Create(const ResStringRec: PResStringRec);
begin
  inherited Create(LoadResString(ResStringRec));
end;

constructor ETinyString.Create(const ResStringRec: PResStringRec; const Value: PByteString);
var
  S: string;
  Buffer: ByteString;
begin
  Buffer := Value^;
  Buffer.Ascii := False;
  if (Buffer.Chars <> nil) and (Buffer.Length > 0) then
  begin
    if (Buffer.Length < ETINYSTRING_LENGTH_LIMIT) then
    begin
      Buffer.ToString(S);
    end else
    begin
      Buffer.Length := ETINYSTRING_LENGTH_LIMIT;
      Buffer.ToString(S);
      S := S + '...';
    end;
  end;

  inherited CreateFmt(LoadResString(ResStringRec), [S]);
end;

constructor ETinyString.Create(const ResStringRec: PResStringRec;
  const Value: PUTF16String);
var
  S: string;
  Buffer: UTF16String;
begin
  Buffer := Value^;
  Buffer.Ascii := False;
  if (Buffer.Chars <> nil) and (Buffer.Length > 0) then
  begin
    if (Buffer.Length < ETINYSTRING_LENGTH_LIMIT) then
    begin
      Buffer.ToString(S);
    end else
    begin
      Buffer.Length := ETINYSTRING_LENGTH_LIMIT;
      Buffer.ToString(S);
      S := S + '...';
    end;
  end;

  inherited CreateFmt(LoadResString(ResStringRec), [S]);
end;

constructor ETinyString.Create(const ResStringRec: PResStringRec;
  const Value: PUTF32String);
var
  S: string;
  Buffer: UTF32String;
begin
  Buffer := Value^;
  Buffer.Ascii := False;
  if (Buffer.Chars <> nil) and (Buffer.Length > 0) then
  begin
    if (Buffer.Length < ETINYSTRING_LENGTH_LIMIT) then
    begin
      Buffer.ToString(S);
    end else
    begin
      Buffer.Length := ETINYSTRING_LENGTH_LIMIT;
      Buffer.ToString(S);
      S := S + '...';
    end;
  end;

  inherited CreateFmt(LoadResString(ResStringRec), [S]);
end;


{ ByteString }

function ByteString.GetEmpty: Boolean;
begin
  Result := (Length <> 0);
end;

procedure ByteString.SetEmpty(Value: Boolean);
var
  V: NativeUInt;
begin
  if (Value) then
  begin
    V := 0;
    FLength := V;
    F.NativeFlags := V;
  end;
end;

function ByteString.GetSBCS: PTextConvSBCS;
var
  Index: NativeInt;
begin
  Index := SBCSIndex;

  if (Index < 0) then
  begin
    Inc(Index){Result := nil};
  end else
  begin
    Index := Index * SizeOf(TTextConvSBCS);
    Inc(Index, NativeInt(@TEXTCONV_SUPPORTED_SBCS));
  end;

  Result := Pointer(Index);
end;

procedure ByteString.SetSBCS(Value: PTextConvSBCS);
begin
  if (Value = nil) then
  begin
    SBCSIndex := -1;
  end else
  begin
    SBCSIndex := Value.Index;
  end;
end;

function ByteString.GetUTF8: Boolean;
begin
  Result := Boolean(Flags shr 31);
end;

procedure ByteString.SetUTF8(Value: Boolean);
begin
  if (Value) then
  begin
    SBCSIndex := -1;
  end else
  begin
    SBCSIndex := DEFAULT_TEXTCONV_SBCS_INDEX;
  end;
end;

function ByteString.GetEncoding: Word;
var
  Index: NativeInt;
begin
  Index := SBCSIndex;

  if (Index < 0) then
  begin
    Result := CODEPAGE_UTF8;
  end else
  begin
    Index := Index * SizeOf(TTextConvSBCS);
    Inc(Index, NativeInt(@TEXTCONV_SUPPORTED_SBCS));
    Result := PTextConvSBCS(Index).CodePage;
  end;
end;

procedure ByteString.SetEncoding(CodePage: Word);
var
  Index: NativeUInt;
  Value: Integer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    SBCSIndex := -1;
  end else
  begin
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);

    SBCSIndex := Byte(Value shr 16);
  end;
end;

procedure ByteString.Assign(const AChars: PAnsiChar{/PUTF8Char};
  const ALength: NativeUInt; const CodePage: Word);
{$ifdef CPUX86}
var
  CP: Word;
{$endif}
begin
  Self.FChars := AChars;
  Self.FLength := ALength;

  {$ifdef CPUX86}
  CP := CodePage;
  {$endif}
  if ({$ifdef CPUX86}CP{$else}CodePage{$endif} = 0) or
    ({$ifdef CPUX86}CP{$else}CodePage{$endif} = CODEPAGE_DEFAULT) then
  begin
    Self.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
  end else
  begin
    Self.Flags := $ff000000;
    if ({$ifdef CPUX86}CP{$else}CodePage{$endif} <> CODEPAGE_UTF8) then
      SetEncoding({$ifdef CPUX86}CP{$else}CodePage{$endif});
  end;
end;

procedure ByteString.Assign(const S: AnsiString
  {$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif});
var
  P: PInteger;
  {$ifdef INTERNALCODEPAGE}
  CodePage: Word;
  {$endif}
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  if (P = nil) then
  begin
    Pointer(Self.FLength) := P{0};
    Pointer(Self.F.NativeFlags) := P{0};
  end else
  begin
    Dec(NativeInt(P), ASTR_OFFSET_LENGTH);
    Self.FLength := P^;
    {$ifdef INTERNALCODEPAGE}
    Dec(NativeInt(P), (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    CodePage := PWord(P)^;
    {$endif}
    if (CodePage = 0) or (CodePage = CODEPAGE_DEFAULT) then
    begin
      Self.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
    end else
    begin
      Self.Flags := $ff000000;
      if (CodePage <> CODEPAGE_UTF8) then SetEncoding(CodePage);
    end;
  end;
end;

procedure ByteString.{$ifdef UNICODE}Assign{$else}AssignUTF8{$endif}(const S: UTF8String);
var
  P: PInteger;
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  if (P = nil) then
  begin
    Pointer(Self.FLength) := P{0};
    Pointer(Self.F.NativeFlags) := P{0};
  end else
  begin
    Dec(NativeInt(P), ASTR_OFFSET_LENGTH);
    Self.FLength := P^;
    Self.Flags := $ff000000;
  end;
end;

procedure ByteString.Assign(const S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
begin
  L := PByte(@S)^;
  Self.FLength := L;
  if (L = 0) then
  begin
    NativeUInt(Self.FChars) := L{nil};
    Self.F.NativeFlags := L{0};
  end else
  begin
    Self.FChars := Pointer(@S[1]);
    if (CodePage = 0) or (CodePage = CODEPAGE_DEFAULT) then
    begin
      Self.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
    end else
    begin
      Self.Flags := $ff000000;
      if (CodePage <> CODEPAGE_UTF8) then SetEncoding(CodePage);
    end;
  end;
end;

procedure ByteString.Assign(const S: TBytes; const CodePage: Word);
var
  P: PNativeInt;
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  if (P = nil) then
  begin
    Pointer(Self.FLength) := P{0};
    Pointer(Self.F.NativeFlags) := P{0};
  end else
  begin
    Dec(P);
    Self.FLength := P^ {$ifdef FPC}+ 1{$endif};
    if (CodePage = 0) or (CodePage = CODEPAGE_DEFAULT) then
    begin
      Self.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
    end else
    begin
      Self.Flags := $ff000000;
      if (CodePage <> CODEPAGE_UTF8) then SetEncoding(CodePage);
    end;
  end;
end;

procedure ByteString.Delete(const From, Count: NativeUInt);
var
  L: NativeUInt;
  S: PByteCharArray;
begin
  L := Length;
  if (From < L) and (Count <> 0) then
  begin
    Dec(L, From);
    if (L <= Count) then
    begin
      Length := From;
    end else
    begin
      Inc(L, From);
      Dec(L, Count);
      Length := L;
      Dec(L, From);

      S := Pointer(Self.FChars);
      TinyMove(S[From + Count], S[From], L);
    end;
  end;
end;

function ByteString.DetermineAscii: Boolean;
label
  fail;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(Byte);
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
var
  P: PByte;
  L: NativeUInt;
  {$ifdef CPUMANYREGS}
  MASK: NativeUInt;
  {$else}
const
  MASK = not NativeUInt($7f7f7f7f);
  {$endif}
begin
  P := Pointer(FChars);
  L := FLength;

  {$ifdef CPUMANYREGS}
  MASK := not NativeUInt({$ifdef LARGEINT}$7f7f7f7f7f7f7f7f{$else}$7f7f7f7f{$endif});
  {$endif}

  while (L >= CHARS_IN_NATIVE) do
  begin
    if (PNativeUInt(P)^ and MASK <> 0) then goto fail;
    Dec(L, CHARS_IN_NATIVE);
    Inc(P, CHARS_IN_NATIVE);
  end;
  {$ifdef LARGEINT}
  if (L >= CHARS_IN_CARDINAL) then
  begin
    if (PCardinal(P)^ and MASK <> 0) then goto fail;
    Dec(L, CHARS_IN_CARDINAL);
    Inc(P, CHARS_IN_CARDINAL);
  end;
  {$endif}
  if (L >= 2) then
  begin
    if (PWord(P)^ and Word(not $7f7f) <> 0) then goto fail;
    // Dec(L, 2);
    Inc(P, 2);
  end;
  if (L and 1 <> 0) and (P^ > $7f) then goto fail;

  Ascii := True;
  Result := True;
  Exit;
fail:
  Ascii := False;
  Result := False;
end;

function ByteString.TrimLeft: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PByte;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  if (S^ > 32) then
  begin
    Result := True;
    Exit;
  end else
  begin
    Result := _TrimLeft(S, L);
  end;
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  test ecx, ecx
  jnz @1
  xor eax, eax
  ret
@1:
  cmp byte ptr [edx], 32
  jbe _TrimLeft
  mov al, 1
end;
{$ifend}

function ByteString._TrimLeft(S: PByte; L: NativeUInt): Boolean;
label
  fail;
var
  TopS: PByte;
begin
  TopS := @PByteCharArray(S)[L];

  repeat
    Inc(S);
    if (S = TopS) then goto fail;
  until (S^ > 32);

  FChars := Pointer(S);
  Dec(NativeUInt(TopS), NativeUInt(S));
  FLength := NativeUInt(TopS);
  Result := True;
  Exit;
fail:
  L := 0;
  FLength := L{0};
  Result := False;
end;

function ByteString.TrimRight: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PByte;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PByteCharArray(S)[L] > 32) then
    begin
      Result := True;
      Exit;
    end else
    begin
      Result := _TrimRight(S, L);
    end;
  end;
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:
  cmp byte ptr [edx + ecx], 32
  jbe _TrimRight
  mov al, 1
end;
{$ifend}

function ByteString._TrimRight(S: PByte; H: NativeUInt): Boolean;
label
  fail;
var
  TopS: PByte;
begin
  TopS := @PByteCharArray(S)[H];

  Dec(S);
  repeat
    Dec(TopS);
    if (S = TopS) then goto fail;
  until (TopS^ > 32);

  Dec(NativeUInt(TopS), NativeUInt(S));
  FLength := NativeUInt(TopS);
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};
  Result := False;
end;

function ByteString.Trim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PByte;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PByteCharArray(S)[L] > 32) then
    begin
      // TrimLeft or True
      if (S^ > 32) then
      begin
        Result := True;
        Exit;
      end else
      begin
        Result := _TrimLeft(S, L+1);
        Exit;
      end;
    end else
    begin
      // TrimRight or Trim
      if (S^ > 32) then
      begin
        Result := _TrimRight(S, L);
        Exit;
      end else
      begin
        Result := _Trim(S, L);
      end;
    end;
  end;
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:
  cmp byte ptr [edx + ecx], 32
  jbe @2
  // TrimLeft or True
  inc ecx
  cmp byte ptr [edx], 32
  jbe _TrimLeft
  mov al, 1
  ret
@2:
  // TrimRight or Trim
  cmp byte ptr [edx], 32
  ja _TrimRight
  jmp _Trim
end;
{$ifend}

function ByteString._Trim(S: PByte; H: NativeUInt): Boolean;
label
  fail;
var
  TopS: PByte;
begin
  if (H = 0) then goto fail;
  TopS := @PByteCharArray(S)[H];

  // TrimLeft
  repeat
    Inc(S);
    if (S = TopS) then goto fail;
  until (S^ > 32);
  FChars := Pointer(S);

  // TrimRight
  Dec(S);
  repeat
    Dec(TopS);
  until (TopS^ > 32);

  // Result
  Dec(NativeUInt(TopS), NativeUInt(S));
  FLength := NativeUInt(TopS);
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};
  Result := False;
end;

function ByteString.SubString(const From, Count: NativeUInt): ByteString;
var
  L: NativeUInt;
begin
  Result.F.NativeFlags := Self.F.NativeFlags;
  Result.FChars := Pointer(@PByteCharArray(Self.FChars)[From]);

  L := Self.FLength;
  Dec(L, From);
  if (NativeInt(L) <= 0) then
  begin
    Result.FLength := 0;
    Exit;
  end;

  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function ByteString.SubString(const Count: NativeUInt): ByteString;
var
  L: NativeUInt;
begin
  Result.FChars := Self.FChars;
  Result.F.NativeFlags := Self.F.NativeFlags;
  L := Self.FLength;
  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function ByteString.Skip(const Count: NativeUInt): Boolean;
var
  L: NativeUInt;
begin
  L := FLength;
  if (L <= Count) then
  begin
    FChars := Pointer(@PByteCharArray(FChars)[L]);
    FLength := 0;
    Result := False;
  end else
  begin
    Dec(L, Count);
    FLength := L;
    FChars := Pointer(@PByteCharArray(FChars)[Count]);
    Result := True;
  end;
end;

function ByteString.Hash: Cardinal;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
var
  L, L_High: NativeUInt;
  P: PByte;
  V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := (L shl (32-9));
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (P^ + Result);
    // Dec(L);/Inc(P);
    V := Result shr 5;
    Dec(L, CHARS_IN_CARDINAL);
    Inc(Result, PCardinal(P)^);
    Inc(P, CHARS_IN_CARDINAL);
    Result := Result xor V;
  until (L < CHARS_IN_CARDINAL);

  if (L and 2 <> 0) then
  begin
    Inc(Result, PWord(P)^);
    V := Result shr 5;
    Inc(P, 2);
    Result := Result xor V;
  end;

  if (L and 1 <> 0) then
  begin
    V := Result shr 5;
    Inc(Result, P^);
    Result := Result xor V;
  end;

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function ByteString.HashIgnoreCase: Cardinal;
{$ifNdef CPUINTELASM}
var
  NF: NativeUInt;
begin
  NF := F.NativeFlags;

  if (NF and 1 <> 0) then Result := _HashIgnoreCaseAscii
  else
  if (NF >= NativeUInt($ff) shl 24) then Result := _HashIgnoreCaseUTF8
  else
  Result := _HashIgnoreCase(NF);
end;
{$else .CPUINTELASM}
asm
  {$ifdef CPUX86}
  mov edx, [EAX].ByteString.F.Flags
  {$else .CPUX64}
  mov edx, [RCX].ByteString.F.Flags
  {$endif}
  test edx, 1
  jnz _HashIgnoreCaseAscii
  cmp edx, $ff000000
  jae _HashIgnoreCaseUTF8
  jmp _HashIgnoreCase
end;
{$endif}

function ByteString._HashIgnoreCaseAscii: Cardinal;
label
  include_x;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
var
  L, L_High: NativeUInt;
  P: PByte;
  X, V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := (L shl (32-9));
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := PCardinal(P)^;
  include_x:
    X := X or ((X and $40404040) shr 1);
    Dec(L, CHARS_IN_CARDINAL);
    V := Result shr 5;
    Inc(Result, X);
    Inc(P, CHARS_IN_CARDINAL);
    Result := Result xor V;
  until (L < CHARS_IN_CARDINAL);

  if (L <> 0) then
  begin
    case L of
      1:
      begin
        X := P^;
        Inc(L, 3);
        goto include_x;
      end;
      2:
      begin
        X := PWord(P)^;
        Inc(L, 2);
        goto include_x;
      end;
    else
      X := PWord(P)^;
      Inc(P, 2);
      X := X or P^;
      Inc(L);
      goto include_x;
    end;
  end;

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function ByteString._HashIgnoreCaseUTF8: Cardinal;
label
  include_x;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  MASKS: array[1..3] of Cardinal = ($ffffff, $ffff, $ff);
var
  L: NativeUInt;
  P: PByte;
  X, V: Cardinal;
  N: NativeUInt;
  {$ifdef CPUX86}
  S: record
    L_High: NativeUInt;
  end;
  {$else}
  L_High: NativeUInt;
  {$endif}
  lookup_utf16_lower: PTextConvWW;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  lookup_utf16_lower := Pointer(@TEXTCONV_CHARCASE.LOWER);
  Result := L;
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := PCardinal(P)^;
  include_x:
    Dec(L, CHARS_IN_CARDINAL);
    Inc(P, CHARS_IN_CARDINAL);
    if (X and $80 <> 0) then
    begin
      case TEXTCONV_UTF8CHAR_SIZE[Byte(X)] of
        2: begin
             // X := ((X and $1F) shl 6) or ((X shr 8) and $3F);
             V := X;
             X := X and $1F;
             V := V shr 8;
             X := X shl 6;
             V := V and $3F;
             Inc(L, 2);
             Inc(X, V);
             Dec(P, 2);
             X := lookup_utf16_lower[X];
           end;
        3: begin
             // X := ((X & 0x0f) << 12) | ((X & 0x3f00) >> 2) | ((X >> 16) & 0x3f);
             V := (X and $0F) shl 12;
             V := V + (X shr 16) and $3F;
             X := (X and $3F00) shr 2;
             Inc(L);
             Inc(X, V);
             Dec(P);
             X := lookup_utf16_lower[X];
           end;
        4: begin
             // X := (X&07)<<18 | (X&3f00)<<4 | (X>>10)&0fc0 | (X>>24)&3f;
             V := (X and $07) shl 18;
             V := V + (X and $3f00) shl 4;
             V := V + (X shr 10) and $0fc0;
             X := (X shr 24) and $3f;
             Inc(X, V);
           end;
      else
        // fail UTF8 character
        Inc(L, 3);
        Dec(P, 3);
        X := Byte(X);
      end;
    end else
    begin
      if (X and Integer($80808080) <> 0) then
      begin
        N := (4-1) - (Byte(X and $8000 = 0) + Byte(X and $808000 = 0));

        X := X and MASKS[N];
        Inc(L, N);
        Dec(P, N);
      end;

      X := X or ((X and $40404040) shr 1);
    end;

    V := Result shr 5;
    Inc(Result, X);
    Result := Result xor V;
  until (NativeInt(L) < CHARS_IN_CARDINAL);

  if (NativeInt(L) > 0) then
  begin
    case L of
      1:
      begin
        X := P^;
        goto include_x;
      end;
      2:
      begin
        X := PWord(P)^;
        goto include_x;
      end;
    else
      X := PWord(P)^;
      Inc(P, 2);
      X := X or P^;
      goto include_x;
    end;
  end;

  Result := (Result and (-1 shr 9)) + {$ifdef CPUX86}S.{$endif}L_High;
end;


function ByteString._HashIgnoreCase(NF: NativeUInt): Cardinal;
label
  include_x;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  MASKS: array[1..3] of Cardinal = ($ffffff, $ffff, $ff);
var
  L: NativeUInt;
  P: PByte;
  X, V: Cardinal;
  N: NativeUInt;
  {$ifdef CPUX86}
  S: record
    L_High: NativeUInt;
  end;
  {$else}
  L_High: NativeUInt;
  {$endif}
  SBCSLookup: PTextConvSBCSEx;
  Lower: PTextConvWB;
begin
  L := FLength;
  P := Pointer(FChars);
  NF := NF shr 24;

  if (L = 0) then
  begin
    Result := 0;
    Exit;
  end;

  // Lower := inline TEXTCONV_SUPPORTED_SBCS[SBCSIndex].GetLowerCaseUCS2;
  SBCSLookup := Pointer(NF * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
  Lower := Pointer(SBCSLookup.FUCS2.Lower);
  if (Lower = nil) then Lower := Pointer(SBCSLookup.AllocFillUCS2(SBCSLookup.FUCS2.Lower, ccLower));

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  Result := L;
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := PCardinal(P)^;
  include_x:
    Dec(L, CHARS_IN_CARDINAL);
    Inc(P, CHARS_IN_CARDINAL);
    if (X and $80 <> 0) then
    begin
      X := Lower[X];
      Inc(L, CHARS_IN_CARDINAL-1);
      Dec(P, CHARS_IN_CARDINAL-1);
    end else
    begin
      if (X and Integer($80808080) <> 0) then
      begin
        N := (4-1) - (Byte(X and $8000 = 0) + Byte(X and $808000 = 0));

        X := X and MASKS[N];
        Inc(L, N);
        Dec(P, N);
      end;

      X := X or ((X and $40404040) shr 1);
    end;

    V := Result shr 5;
    Inc(Result, X);
    Result := Result xor V;
  until (NativeInt(L) < CHARS_IN_CARDINAL);

  if (NativeInt(L) > 0) then
  begin
    case L of
      1:
      begin
        X := P^;
        goto include_x;
      end;
      2:
      begin
        X := PWord(P)^;
        goto include_x;
      end;
    else
      X := PWord(P)^;
      Inc(P, 2);
      X := X or P^;
      goto include_x;
    end;
  end;

  Result := (Result and (-1 shr 9)) + {$ifdef CPUX86}S.{$endif}L_High;
end;

function ByteString.CharPos(const C: AnsiChar; const From: NativeUInt): NativeInt;
label
  failure, found;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  X, V, CharMask: NativeInt;
  P, TopCardinal, Top: PByte;
  StoredChars: PByte;
begin
  P := Pointer(FChars);
  TopCardinal := Pointer(@PByteCharArray(P)[FLength - CHARS_IN_CARDINAL]);
  StoredChars := P;
  Inc(P, From);
  if (Self.Ascii > (Byte(C) <= $7f)) then goto failure;
  CharMask := Ord(C) * $01010101;

  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    X := X xor CharMask;
    V := X + SUB_MASK;
    X := not X;
    X := X and V;

    if (X and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(Byte(X and $80 = 0) + Byte(X and $8080 = 0) + Byte(X and $808080 = 0)));
    goto found;
  until (False);

  CharMask := CharMask and $ff;
  Top := Pointer(@PByteCharArray(TopCardinal)[CHARS_IN_CARDINAL]);
  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = CharMask) then goto found;
    Inc(P);
  end;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
end;

function DetectSBCSLowerUpperChars(const C: NativeInt; const SBCS: PTextConvSBCS): NativeInt;
begin
  Result := PTextConvBB(SBCS.LowerCase)[C];
  Result := (Result shl 8) + PTextConvBB(SBCS.UpperCase)[C];
end;

function ByteString.CharPosIgnoreCase(const C: AnsiChar;
  const From: NativeUInt): NativeInt;
label
  sbcs_lookup_chars, failure, found;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  X, T, V, U, LowerCharMask, UpperCharMask: NativeInt;
  P, TopCardinal, Top: PByte;
  StoredChars: PByte;
  Lookup: PTextConvBB;
begin
  P := Pointer(FChars);
  TopCardinal := Pointer(@PByteCharArray(P)[FLength - CHARS_IN_CARDINAL]);
  StoredChars := P;
  Inc(P, From);

  U := Ord(C);
  UpperCharMask := Self.F.Flags;
  if (U <= $7f) then
  begin
    UpperCharMask := TEXTCONV_CHARCASE.VALUES[$10000 + U];
    LowerCharMask := TEXTCONV_CHARCASE.VALUES[U];
  end else
  begin
    if (UpperCharMask and 1 <> 0{Ascii}) then goto failure;
    if (Integer(UpperCharMask) < 0) then
    begin
      // UTF-8 (case sensitive)
      LowerCharMask := U;
      UpperCharMask := U;
    end else
    begin
      // SBCS
      UpperCharMask := UpperCharMask shr 24;
      UpperCharMask := UpperCharMask * SizeOf(TTextConvSBCS);
      Inc(UpperCharMask, NativeInt(@TEXTCONV_SUPPORTED_SBCS));
      Lookup := Pointer(PTextConvSBCSEx(UpperCharMask).FLowerCase);
      if (Lookup <> nil) then
      begin
        LowerCharMask := Lookup[U];
        Lookup := Pointer(PTextConvSBCSEx(UpperCharMask).FUpperCase);
        if (Lookup = nil) then goto sbcs_lookup_chars;
        UpperCharMask := Lookup[U];
      end else
      begin
      sbcs_lookup_chars:
        LowerCharMask := DetectSBCSLowerUpperChars(U, PTextConvSBCS(UpperCharMask));
        UpperCharMask := LowerCharMask shr 8;
        LowerCharMask := Byte(LowerCharMask);
      end;
    end;
  end;

  LowerCharMask := LowerCharMask * $01010101;
  UpperCharMask := UpperCharMask * $01010101;
  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    T := (X xor LowerCharMask);
    U := (X xor UpperCharMask);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(Byte(T and $80 = 0) + Byte(T and $8080 = 0) + Byte(T and $808080 = 0)));
    goto found;
  until (False);

  LowerCharMask := Byte(LowerCharMask);
  UpperCharMask := Byte(UpperCharMask);
  Top := Pointer(@PByteCharArray(TopCardinal)[CHARS_IN_CARDINAL]);
  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = LowerCharMask) then goto found;
    if (X = UpperCharMask) then goto found;
    Inc(P);
  end;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
end;

function ByteString.Pos(const S: ByteString; const From: NativeUInt): NativeInt;
label
  next_iteration, failure, char_found;
type
  TChar = Byte;
  PChar = ^TChar;
  TCharArray = TByteCharArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(TChar);
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(TChar);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  L: NativeUInt;
  X, V, CharMask: NativeInt;
  P, Top, TopCardinal: PChar;
  P1, P2: PChar;
  Store: record
    StrLength: NativeUInt;
    StrChars: Pointer;
    SelfChars: Pointer;
    CharMask: NativeInt;
  end;
begin
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPos(PAnsiChar(Store.StrChars)^, From);
    Exit;
  end;
  Store.StrLength := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  TopCardinal := Pointer(@PCharArray(P)[Self.FLength -L - (CHARS_IN_CARDINAL - 1)]);
  Inc(P, From);

  CharMask := PChar(Store.StrChars)^;
  if (Self.Ascii > (CharMask <= $7f)) then goto failure;
  CharMask := CharMask * $01010101;

  Store.CharMask := CharMask;
  next_iteration:
    CharMask := Store.CharMask;
  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    X := X xor CharMask;
    V := X + SUB_MASK;
    X := not X;
    X := X and V;

    if (X and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(Byte(X and $80 = 0) + Byte(X and $8080 = 0) + Byte(X and $808080 = 0)));
  char_found:
    Inc(P);
    L := Store.StrLength - 1;
    P2 := Store.StrChars;
    P1 := P;
    Inc(P2);
    if (L >= CHARS_IN_NATIVE) then
    repeat
      if (PNativeUInt(P1)^ <> PNativeUInt(P2)^) then goto next_iteration;
      Dec(L, CHARS_IN_NATIVE);
      Inc(P1, CHARS_IN_NATIVE);
      Inc(P2, CHARS_IN_NATIVE);
    until (L < CHARS_IN_NATIVE);
    {$ifdef LARGEINT}
    if (L >= CHARS_IN_CARDINAL{4}) then
    begin
      if (PCardinal(P1)^ <> PCardinal(P2)^) then goto next_iteration;
      Dec(L, CHARS_IN_CARDINAL);
      Inc(P1, CHARS_IN_CARDINAL);
      Inc(P2, CHARS_IN_CARDINAL);
    end;
    {$endif}
    if (L <> 0) then
    repeat
      if (P1^ <> P2^) then goto next_iteration;
      Dec(L);
      Inc(P1);
      Inc(P2);
    until (L = 0);

    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Exit;
  until (False);

  CharMask := CharMask and $ff;
  Top := Pointer(@PByteCharArray(TopCardinal)[CHARS_IN_CARDINAL]);
  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = CharMask) then goto char_found;
    Inc(P);
  end;

failure:
  Result := -1;
end;

function ByteString.Pos(const AChars: PAnsiChar; const ALength: NativeUInt;
  const From: NativeUInt = 0): NativeInt;
var
  Buffer: PtrString;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  Result := Self.Pos(PByteString(@Buffer)^, From);
end;

function ByteString.Pos(const S: AnsiString; const From: NativeUInt): NativeInt;
var
  P: PCardinal;
  Buffer: PtrString;
begin
  P := Pointer(S);
  Buffer.Chars := P;
  if (P = nil) then
  begin
    Result := -1;
  end else
  begin
    Dec(NativeInt(P), ASTR_OFFSET_LENGTH);
    Buffer.Length := P^;
    Result := Self.Pos(PByteString(@Buffer)^, From);
  end;
end;

function DetectUTF8LowerUpperChars(S: PByte; L: NativeUInt): NativeInt;
label
  done;
var
  V1, V2: NativeUInt;
  X, Y: NativeUInt;
begin
  V1 := S^;
  V2 := V1;

  X := TEXTCONV_UTF8CHAR_SIZE[V1];
  if (X > L) then goto done;
  case X of
    2:
    begin
      X := PWord(S)^;
      if (X and $C0E0 <> $80C0) then goto done;
      Y := X;
      X := X and $1F;
      Y := Y shr 8;
      X := X shl 6;
      Y := Y and $3F;
      Inc(X, Y);
    end;
    3:
    begin
      Inc(S);
      X := PWord(S)^;
      X := (X shl 8) + V1;
      if (X and $C0C000 <> $808000) then goto done;
      Y := (X and $0F) shl 12;
      Y := Y + (X shr 16) and $3F;
      X := (X and $3F00) shr 2;
      Inc(X, Y);
    end;
  else
    goto done;
  end;

  V1 := TEXTCONV_CHARCASE.VALUES[X];
  V2 := TEXTCONV_CHARCASE.VALUES[$10000 + X];
  begin
    if (V1 <= $7ff) then
    begin
      V1 := (V1 shr 6) + $C0;
    end else
    begin
      V1 := (V1 shr 12) + $E0;
    end;

    if (V2 <= $7ff) then
    begin
      V2 := (V2 shr 6) + $C0;
    end else
    begin
      V2 := (V2 shr 12) + $E0;
    end;
  end;
done:
  Result := (Byte(V1) shl 8) + Byte(V2);
end;

function ByteString._PosIgnoreCaseUTF8(const S: ByteString;
  const From: NativeUInt): NativeInt;
label
  failure, char_found;
type
  TChar = Byte;
  PChar = ^TChar;
  TCharArray = TByteCharArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(TChar);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  L: NativeUInt;
  X, T, V, U, LowerCharMask, UpperCharMask: NativeInt;
  P, Top{$ifNdef CPUX86},TopCardinal{$endif}: PChar;
  Store: record
    Comp: TTextConvCompareOptions;
    StrChars: Pointer;
    SelfChars: Pointer;
    SelfCharsTop: Pointer;
    {$ifdef CPUX86}TopCardinal: Pointer;{$endif}
    UpperCharMask: NativeInt;
    case Boolean of
      False: (D: Double);
       True: (I: Integer);
  end;
begin
  Store.Comp.Length := From{store};
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPosIgnoreCase(PAnsiChar(Store.StrChars)^, Store.Comp.Length);
    Exit;
  end;
  Store.Comp.Length_2 := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  L := Self.FLength;
  Store.SelfCharsTop := Pointer(@PCharArray(P)[L]);
  Store.D := (Store.Comp.Length_2 * (2/3)) + DBLROUND_CONST;
  {$ifdef CPUX86}Store.{$endif}TopCardinal := Pointer(@PCharArray(Store.SelfCharsTop)[-Store.I - (CHARS_IN_CARDINAL - 1)]);
  Inc(P, Store.Comp.Length{From});

  LowerCharMask := PChar(Store.StrChars)^;
  if (LowerCharMask <= $7f) then
  begin
    UpperCharMask := TEXTCONV_CHARCASE.VALUES[$10000 + LowerCharMask];
    LowerCharMask := TEXTCONV_CHARCASE.VALUES[LowerCharMask];
  end else
  begin
    if (Self.Ascii) then goto failure;
    LowerCharMask := DetectUTF8LowerUpperChars(Store.StrChars, Store.Comp.Length_2);
    UpperCharMask := LowerCharMask shr 8;
    LowerCharMask := TChar(LowerCharMask);
  end;

  LowerCharMask := LowerCharMask * $01010101;
  UpperCharMask := UpperCharMask * $01010101;
  repeat
    if (NativeUInt(P) > NativeUInt({$ifdef CPUX86}Store.{$endif}TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    T := (X xor LowerCharMask);
    U := (X xor UpperCharMask);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(Byte(T and $80 = 0) + Byte(T and $8080 = 0) + Byte(T and $808080 = 0)));
  char_found:
    Store.UpperCharMask := UpperCharMask;
      Store.Comp.Length := (NativeUInt(Store.SelfCharsTop) - NativeUInt(P)) or {compare flag}NativeUInt(1 shl {$ifdef LARGEINT}63{$else}31{$endif});
      U := __textconv_utf8_compare_utf8(Pointer(P), Store.StrChars, Store.Comp);
    UpperCharMask := Store.UpperCharMask;
    Inc(P);
    if (U <> 0) then Continue;
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Exit;
  until (False);

  LowerCharMask := TChar(LowerCharMask);
  UpperCharMask := TChar(UpperCharMask);
  Top := Pointer(@PCharArray({$ifdef CPUX86}Store.{$endif}TopCardinal)[CHARS_IN_CARDINAL]);
  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = LowerCharMask) then goto char_found;
    if (X = UpperCharMask) then goto char_found;
    Inc(P);
  end;

failure:
  Result := -1;
end;

procedure UpdateSBCSLowerUpperLookups(var Comp: TTextConvCompareOptions; const SBCS: PTextConvSBCS);
begin
  Comp.Lookup := SBCS.LowerCase;
  Comp.Lookup_2 := SBCS.UpperCase;
end;

function ByteString._PosIgnoreCase(const S: ByteString; const From: NativeUInt): NativeInt;
label
  failure, char_found;
type
  TChar = Byte;
  PChar = ^TChar;
  TCharArray = TByteCharArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(TChar);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  L: NativeUInt;
  X, T, V, U, LowerCharMask, UpperCharMask: NativeInt;
  P, Top{$ifNdef CPUX86},TopCardinal{$endif}: PChar;
  Store: record
    Comp: TTextConvCompareOptions;
    StrChars: Pointer;
    SelfChars: Pointer;
    SelfCharsTop: Pointer;
    {$ifdef CPUX86}TopCardinal: Pointer;{$endif}
    UpperCharMask: NativeInt;
  end;
begin
  Store.Comp.Length_2 := From{store};
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPosIgnoreCase(PAnsiChar(Store.StrChars)^, Store.Comp.Length_2);
    Exit;
  end;
  Store.Comp.Length := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  Store.SelfCharsTop := Pointer(@PCharArray(P)[Self.FLength]);
  {$ifdef CPUX86}Store.{$endif}TopCardinal := Pointer(@PCharArray(Store.SelfCharsTop)[-L - (CHARS_IN_CARDINAL - 1)]);
  Inc(P, Store.Comp.Length_2{From});

  UpperCharMask := Self.F.Flags;
  LowerCharMask := UpperCharMask;
  UpperCharMask := UpperCharMask shr 24;
  UpperCharMask := UpperCharMask * SizeOf(TTextConvSBCS);
  Inc(UpperCharMask, NativeInt(@TEXTCONV_SUPPORTED_SBCS));
  Store.Comp.Lookup := PTextConvSBCSEx(UpperCharMask).FLowerCase;
  Store.Comp.Lookup_2 := PTextConvSBCSEx(UpperCharMask).FUpperCase;
  if (Store.Comp.Lookup = nil) or (Store.Comp.Lookup_2 = nil) then
    UpdateSBCSLowerUpperLookups(Store.Comp, PTextConvSBCS(UpperCharMask));

  U := PChar(Store.StrChars)^;
  if (U <= $7f) then
  begin
    UpperCharMask := TEXTCONV_CHARCASE.VALUES[$10000 + U];
    LowerCharMask := TEXTCONV_CHARCASE.VALUES[U];
  end else
  begin
    if (LowerCharMask and 1 <> 0{Ascii}) then goto failure;
    UpperCharMask := PTextConvBB(Store.Comp.Lookup_2)[U];
    LowerCharMask := PTextConvBB(Store.Comp.Lookup)[U];
  end;

  LowerCharMask := LowerCharMask * $01010101;
  UpperCharMask := UpperCharMask * $01010101;
  repeat
    if (NativeUInt(P) > NativeUInt({$ifdef CPUX86}Store.{$endif}TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    T := (X xor LowerCharMask);
    U := (X xor UpperCharMask);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(Byte(T and $80 = 0) + Byte(T and $8080 = 0) + Byte(T and $808080 = 0)));
  char_found:
    Store.UpperCharMask := UpperCharMask;
      U := __textconv_sbcs_compare_sbcs_1(Pointer(P), Store.StrChars, Store.Comp);
    UpperCharMask := Store.UpperCharMask;
    Inc(P);
    if (U <> 0) then Continue;
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Exit;
  until (False);

  LowerCharMask := TChar(LowerCharMask);
  UpperCharMask := TChar(UpperCharMask);
  Top := Pointer(@PByteCharArray({$ifdef CPUX86}Store.{$endif}TopCardinal)[CHARS_IN_CARDINAL]);
  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = LowerCharMask) then goto char_found;
    if (X = UpperCharMask) then goto char_found;
    Inc(P);
  end;

failure:
  Result := -1;
end;

function ByteString.PosIgnoreCase(const S: ByteString;
  const From: NativeUInt): NativeInt;
begin
  if (Integer(Self.Flags) < 0) then
  begin
    Result := Self._PosIgnoreCaseUTF8(S, From);
  end else
  begin
    Result := Self._PosIgnoreCase(S, From);
  end;
end;

function ByteString.PosIgnoreCase(const AChars: PAnsiChar;
  const ALength: NativeUInt; const From: NativeUInt): NativeInt;
var
  Buffer: PtrString;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  if (Integer(Self.Flags) < 0) then
  begin
    Result := Self._PosIgnoreCaseUTF8(PByteString(@Buffer)^, From);
  end else
  begin
    Result := Self._PosIgnoreCase(PByteString(@Buffer)^, From);
  end;
end;

function ByteString.PosIgnoreCase(const S: AnsiString;
  const From: NativeUInt): NativeInt;
var
  P: PCardinal;
  Buffer: PtrString;
begin
  P := Pointer(S);
  Buffer.Chars := P;
  if (P = nil) then
  begin
    Result := -1;
  end else
  begin
    Dec(NativeInt(P), ASTR_OFFSET_LENGTH);
    Buffer.Length := P^;
    if (Integer(Self.Flags) < 0) then
    begin
      Result := Self._PosIgnoreCaseUTF8(PByteString(@Buffer)^, From);
    end else
    begin
      Result := Self._PosIgnoreCase(PByteString(@Buffer)^, From);
    end;
  end;
end;

function ByteString.TryToBoolean(out Value: Boolean): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetBool
  pop edx
  pop ecx
  mov [ecx], al
  xchg eax, edx
end;
{$ifend}

function ByteString.ToBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PByteString(@Default)._GetBool(Pointer(Chars), Length);
end;

function ByteString.ToBoolean: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetBool
end;
{$ifend}

function ByteString._GetBool(S: PByte; L: NativeUInt): Boolean;
label
  fail;
var
  Marker: NativeInt;
  Buffer: ByteString;
begin
  Buffer.Chars := Pointer(S);
  Buffer.Length := L;

  // byte ascii, ignore case
  with PMemoryItems(Buffer.Chars)^ do
  case L of
    1: case (Bytes[0]) of // "0", "1"
         $30:
         begin
           // "0"
           Result := False;
           Exit;
         end;
         $31:
         begin
           // "1"
           Result := True;
           Exit;
         end;
       end;
    2: if (Words[0] or $2020 = $6F6E) then
    begin
      // "no"
      Result := False;
      Exit;
    end;
    3: if (Words[0] + Bytes[2] shl 16 or $202020 = $736579) then
    begin
      // "yes"
      Result := True;
      Exit;
    end;
    4: if (Cardinals[0] or $20202020 = $65757274) then
    begin
      // "true"
      Result := True;
      Exit;
    end;
    5: if (Cardinals[0] or $20202020 = $736C6166) and (Bytes[4] or $20 = $65) then
    begin
      // "false"
      Result := False;
      Exit;
    end;
  end;

fail:
  Marker := NativeInt(@Self);
  if (Marker = 0) then
  begin
    Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidBoolean), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PBoolean(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
    Result := False;
  end;
end;

function ByteString.TryToHex(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function ByteString.ToHexDef(const Default: Integer): Integer;
begin
  Result := PByteString(@Default)._GetHex(Pointer(Chars), Length);
end;

function ByteString.ToHex: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex
end;
{$ifend}

function ByteString._GetHex(S: PByte; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: ByteString;
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;
  Result := 0;

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      Result := Result shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      Result := Result shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(Result, X);
  until (L = 0);

  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function ByteString.TryToCardinal(out Value: Cardinal): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function ByteString.ToCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PByteString(@Default)._GetInt(Pointer(Chars), Length);
end;

function ByteString.ToCardinal: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function ByteString.TryToInteger(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function ByteString.ToIntegerDef(const Default: Integer): Integer;
begin
  Result := PByteString(@Default)._GetInt(Pointer(Chars), -Length);
end;

function ByteString.ToInteger: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function ByteString._GetInt(S: PByte; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: ByteString;
  HexRet: record
    Value: Integer;
  end;
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PByteString(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PByteString(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L >= 10{high(Result)}) then
  begin
    Dec(L);
    Marker := Marker or 2;
    if (L > 10-1) then goto fail;
  end;
  Result := 0;

  repeat
    X := NativeUInt(S^) - Ord('0');
    Result := Result * 10;
    Dec(L);
    Inc(Result, X);
    Inc(S);
    if (X >= 10) then goto fail;
  until (L = 0);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        case Cardinal(Result) of
          0..High(Cardinal) div 10 - 1: ;
          High(Cardinal) div 10:
          begin
            if (X > High(Cardinal) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end else
      begin
        case Cardinal(Result) of
          0..High(Integer) div 10 - 1: ;
          High(Integer) div 10:
          begin
            if (X > (NativeUInt(Marker) shr 2) + High(Integer) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end;

      Result := Result * 10;
      Inc(Result, X);
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function ByteString.TryToHex64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function ByteString.ToHex64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(@Default)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetHex64
end;
{$ifend}

function ByteString.ToHex64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex64
end;
{$ifend}

function ByteString._GetHex64(S: PByte; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: ByteString;
  X: NativeUInt;
  R1, R2: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;

  R1 := 0;
  R2 := 0;

  if (L > 8) then
  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R2 := R2 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R2 := R2 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R2, X);
  until (L = 8);

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R1 := R1 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R1 := R1 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R1, X);
  until (L = 0);

  {$ifdef SMALLINT}
  with PPoint(@Result)^ do
  begin
    X := R1;
    Y := R2;
  end;
  {$else .LARGEINT}
  Result := (R2 shl 32) + R1;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function ByteString.TryToUInt64(out Value: UInt64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function ByteString.ToUInt64Def(const Default: UInt64): UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(@Default)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function ByteString.ToUInt64: UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function ByteString.TryToInt64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function ByteString.ToInt64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(@Default)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function ByteString.ToInt64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function ByteString._GetInt64(S: PByte; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: ByteString;
  HexRet: record
    Value: Integer;
  end;
  X: NativeUInt;
  Marker: NativeInt;
  R1, R2: Integer;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PByteString(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PByteString(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L <= 9) then
  begin
    R1 := PByteString(nil)._GetInt_19(S, L);
    if (R1 < 0) then goto fail;

    if (Marker and 4 <> 0) then R1 := -R1;
    Result := R1;
    Exit;
  end else
  if (L >= 19) then
  begin
    if (L = 19) then
    begin
      Marker := Marker or 2;
      Dec(L);
    end else
    if (L = 20) and (Marker and 1 = 0) then
    begin
      Marker := Marker or (2 or 4{TEN_BB});
      if (S^ <> $31{Ord('1')}) then goto fail;
      Dec(L, 2);
      Inc(S);
    end else
    goto fail;
  end;

  Dec(L, 9);
  R2 := PByteString(nil)._GetInt_19(S, L);
  Inc(S, L);
  if (R2 < 0) then goto fail;

  R1 := PByteString(nil)._GetInt_19(S, 9);
  Inc(S, 9);
  if (R1 < 0) then goto fail;

  Result := Decimal64R21(R2, R1);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        // UInt64
        if (Marker and 4 = 0) then
        begin
          Result := Decimal64VX(Result, X);
        end else
        begin
          if (Result >= _HIGHU64 div 10) then
          begin
            if (Result = _HIGHU64 div 10) then
            begin
              if (X > NativeUInt(_HIGHU64 mod 10)) then goto fail;
            end else
            begin
              goto fail;
            end;
          end;

          Result := Decimal64VX(Result, X);
          Inc(Result, TEN_BB);
        end;

        Exit;
      end else
      begin
        // Int64
        if (Result >= High(Int64) div 10) then
        begin
          if (Result = High(Int64) div 10) then
          begin
            if (X > (NativeUInt(Marker) shr 2) + NativeUInt(High(Int64) mod 10)) then goto fail;
          end else
          begin
            goto fail;
          end;
        end;

        Result := Decimal64VX(Result, X);
      end;
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function ByteString._GetInt_19(S: PByte; L: NativeUInt): NativeInt;
label
  fail, _1, _2, _3, _4, _5, _6, _7, _8, _9;
var
  {$ifdef CPUX86}
  Store: record
    _R: PNativeInt;
    _S: PByte;
  end;
  {$else}
  _S: PByte;
  {$endif}
  _R: PNativeInt;
begin
  {$ifdef CPUX86}Store.{$endif}_R := Pointer(@Self);
  {$ifdef CPUX86}Store.{$endif}_S := S;

  Result := 0;
  case L of
    9:
    begin
    _9:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      if (L >= 10) then goto fail;
      Inc(Result, L);
      goto _8;
    end;
    8:
    begin
    _8:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _7;
    end;
    7:
    begin
    _7:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _6;
    end;
    6:
    begin
    _6:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _5;
    end;
    5:
    begin
    _5:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _4;
    end;
    4:
    begin
    _4:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _3;
    end;
    3:
    begin
    _3:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _2;
    end;
    2:
    begin
    _2:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _1;
    end
  else
  _1:
    L := NativeUInt(S^) - Ord('0');
    Inc(S);
    Result := Result * 2;
    if (L >= 10) then goto fail;
    Result := Result * 5;
    Inc(Result, L);
    Exit;
  end;

fail:
  {$ifdef CPUX86}
  _R := Store._R;
  {$endif}
  Result := Result shr 1;
  if (_R <> nil) then _R^ := Result;

  Result := NativeInt({$ifdef CPUX86}Store.{$endif}_S);
  Dec(Result, NativeInt(S));
end;

function ByteString.TryToFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function ByteString.TryToFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

{$if (not Defined(FPC)) or Defined(EXTENDEDSUPPORT)}
function ByteString.TryToFloat(out Value: Extended): Boolean;
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;
{$ifend}

function ByteString.ToFloatDef(const Default: Extended): Extended;
begin
  Result := PByteString(@Default)._GetFloat(Pointer(Chars), Length);
end;

function ByteString.ToFloat: Extended;
begin
  Result := PByteString(0)._GetFloat(Pointer(Chars), Length);
end;

function ByteString._GetFloat(S: PByte; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: ByteString;
  Store: record
    V: NativeInt;
    Sign: Byte;
  end;
  X: NativeUInt;
  Marker: NativeInt;

  V: NativeInt;
  Base: Double;
  TenPowers: PTenPowers;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  if (L = 0) then goto fail;

  X := S^;
  Buffer.Length := L;
  Store.Sign := 0;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Store.Sign := $80;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  // integer part
  begin
    if (L > 9) then
    begin
      V := PByteString(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PByteString(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      V := not V;
      Result := Integer(Store.V);
      Dec(L, V);
      Inc(S, V);
    end else
    begin
      Result := Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      repeat
        if (L > 9) then
        begin
          V := PByteString(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PByteString(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result * TEN_POWERS[True][X] + Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          Break;
        end else
        begin
          Result := Result * TEN_POWERS[True][X] + Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  case S^ of
    Ord('.'), Ord(','): goto frac;
    Ord('e'), Ord('E'):
    begin
      if (S <> Pointer(Buffer.Chars)) then goto exp;
      goto fail;
    end
  else
    goto fail;
  end;

frac:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // frac part
  begin
    if (L > 9) then
    begin
      V := PByteString(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PByteString(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      X := not V;
      Result := Result + TEN_POWERS[False][X] * Integer(Store.V);
      Dec(L, X);
      Inc(S, X);
    end else
    begin
      Result := Result + TEN_POWERS[False][X] * Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      Base := TEN_POWERS[False][9];
      repeat
        if (L > 9) then
        begin
          V := PByteString(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PByteString(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result + Base * TEN_POWERS[False][X] * Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          Break;
        end else
        begin
          Base := Base * TEN_POWERS[False][X];
          Result := Result + Base * Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  if (S^ or $20 <> $65{Ord('e')}) then goto fail;
exp:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // exponent part
  X := S^;
  TenPowers := @TEN_POWERS[True];

  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      TenPowers := @TEN_POWERS[False];
      goto skipexpsign;
    end;
    Ord('+'):
    begin
    skipexpsign:
      Inc(S);
      if (L = 1) then goto done;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto done;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 3) then goto fail;
  if (L = 1) then
  begin
    X := NativeUInt(S^) - Ord('0');
    if (X >= 10) then goto fail;
    Result := Result * TenPowers[X];
  end else
  begin
    V := PByteString(nil)._GetInt_19(S, L);
    if (V < 0) or (V > 300) then goto fail;
    Result := Result * TenPower(TenPowers, V);
  end;
done:
  {$ifdef EXTENDEDSUPPORT}
    Inc(PExtendedBytes(@Result)[High(TExtendedBytes)], Store.Sign);
  {$else}
    if (Store.Sign <> 0) then Result := -Result;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidFloat), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PExtended(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function ByteString.ToDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function ByteString.ToDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise _GetDateTimeException(1{Date});
end;

function ByteString.TryToDate(out Value: TDateTime): Boolean;
const
  DT = 1{Date};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function ByteString.ToTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    Result := Default;
end;

function ByteString.ToTime: TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    raise _GetDateTimeException(2{Time});
end;

function ByteString.TryToTime(out Value: TDateTime): Boolean;
const
  DT = 2{Time};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function ByteString.ToDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function ByteString.ToDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise _GetDateTimeException(3{DateTime});
end;

function ByteString.TryToDateTime(out Value: TDateTime): Boolean;
const
  DT = 3{DateTime};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function ByteString._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
label
  fail;
var
  L, X: NativeUInt;
  Dest: PByte;
  Src: PByte;
  Buffer: TDateTimeBuffer;
begin
  Buffer.Value := @Value;
  L := Self.Length;
  Buffer.Length := L;
  Buffer.DT := DT;
  if (L < DT_LEN_MIN[DT]) or (L > DT_LEN_MAX[DT]) then
  begin
  fail:
    Result := False;
    Exit;
  end;

  Src := Pointer(FChars);
  Dest := Pointer(@Buffer.Bytes);
  repeat
    X := Src^;
    Inc(Src);
    if (X > High(DT_BYTES)) then goto fail;
    Dest^ := DT_BYTES[X];
    Dec(L);
    Inc(Dest);
  until (L = 0);

  Result := Tiny.Cache.Text._GetDateTime(Buffer);
end;

function ByteString._GetDateTimeException(DT: NativeUInt): ETinyString;
var
  ResStringRec: PResStringRec;
begin
  case DT of
    1{Date}: ResStringRec := Pointer(@SInvalidDate);
    2{Time}: ResStringRec := Pointer(@SInvalidTime);
  else
    {3: DateTime}
    ResStringRec := Pointer(@SInvalidDateTime);
  end;

  Result := ETinyString.Create(ResStringRec, @Self);
end;

procedure ByteString.ToAnsiString(var S: AnsiString; const CodePage: Word);
label
  copy_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(Pointer(S)));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then goto copy_characters;

      Index := NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS);
      Converter := DestSBCS.FromSBCS(Pointer(Index));
      Dest := AStrInit(S, nil, L, DestSBCS.CodePage);
      sbcs_from_sbcs(Dest, Src, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

      Dest := AStrReserve(S, L);
      AStrSetLength(S, Tiny.Text.sbcs_from_utf8(Dest, Pointer(Src), L, Converter), DestSBCS.CodePage);
    end;
  end else
  begin
    // Ascii chars
  copy_characters:
    Dest := AStrInit(S, nil, L, DestSBCS.CodePage);
    TinyMove(Src^, Dest^, L);
  end;
end;

procedure ByteString.ToLowerAnsiString(var S: AnsiString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8String(UTF8String(Pointer(S)));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then
      begin
        Converter := DestSBCS.FLowerCase;
        if (Converter = nil) then Converter := DestSBCS.FromSBCS(DestSBCS, ccLower);
      end else
      begin
        Index := NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS);
        Converter := DestSBCS.FromSBCS(Pointer(Index), ccLower);
      end;

      Dest := AStrInit(S, nil, L, DestSBCS.CodePage);
      sbcs_from_sbcs_lower(Dest, Src, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

      Dest := AStrReserve(S, L);
      AStrSetLength(S, Tiny.Text.sbcs_from_utf8_lower(Dest, Pointer(Src), L, Converter), DestSBCS.CodePage);
    end;
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, DestSBCS.CodePage);
    {ascii}Tiny.Text.utf8_from_utf8_lower(Dest, Src, L);
  end;
end;

procedure ByteString.ToUpperAnsiString(var S: AnsiString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8String(UTF8String(Pointer(S)));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then
      begin
        Converter := DestSBCS.FUpperCase;
        if (Converter = nil) then Converter := DestSBCS.FromSBCS(DestSBCS, ccUpper);
      end else
      begin
        Index := NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS);
        Converter := DestSBCS.FromSBCS(Pointer(Index), ccUpper);
      end;

      Dest := AStrInit(S, nil, L, DestSBCS.CodePage);
      sbcs_from_sbcs_upper(Dest, Src, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

      Dest := AStrReserve(S, L);
      AStrSetLength(S, Tiny.Text.sbcs_from_utf8_upper(Dest, Pointer(Src), L, Converter), DestSBCS.CodePage);
    end;
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, DestSBCS.CodePage);
    {ascii}Tiny.Text.utf8_from_utf8_upper(Dest, Src, L);
  end;
end;

procedure ByteString.ToAnsiShortString(var S: ShortString; const CodePage: Word);
label
  copy_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TTextConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  Index := Self.Flags;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then goto copy_characters;

      Index := NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS);
      Converter := DestSBCS.FromSBCS(Pointer(Index));

      Dest := Context.Destination;
      if (L > Context.DestinationSize) then L := Context.DestinationSize;
      Dec(Dest);
      Dest^ := L;
      Inc(Dest);
      sbcs_from_sbcs(Pointer(Dest), Context.Source, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      // converter
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
      Context.FCallbacks.Converter := Converter;

      // conversion
      Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf8;
      if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
      begin
        Inc(Context.FDestinationWritten);
        PByteCharArray(Context.Destination)[Context.DestinationWritten] := UNKNOWN_CHARACTER;
      end;
      Dest := Context.Destination;
      Dec(Dest);
      Dest^ := Context.DestinationWritten;
    end;
  end else
  begin
    // Ascii chars
  copy_characters:
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    TinyMove(Context.Source^, Dest^, L);
  end;
end;

procedure ByteString.ToLowerAnsiShortString(var S: ShortString;
  const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TTextConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  Index := Self.Flags;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then
      begin
        Converter := DestSBCS.FLowerCase;
        if (Converter = nil) then Converter := DestSBCS.FromSBCS(DestSBCS, ccLower);
      end else
      begin
        Index := NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS);
        Converter := DestSBCS.FromSBCS(Pointer(Index), ccLower);
      end;

      Dest := Context.Destination;
      if (L > Context.DestinationSize) then L := Context.DestinationSize;
      Dec(Dest);
      Dest^ := L;
      Inc(Dest);
      sbcs_from_sbcs_lower(Pointer(Dest), Context.Source, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      // converter
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
      Context.FCallbacks.Converter := Converter;

      // conversion
      Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf8_lower;
      if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
      begin
        Inc(Context.FDestinationWritten);
        PByteCharArray(Context.Destination)[Context.DestinationWritten] := UNKNOWN_CHARACTER;
      end;
      Dest := Context.Destination;
      Dec(Dest);
      Dest^ := Context.DestinationWritten;
    end;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii}utf8_from_utf8_lower(Pointer(Dest), Context.Source, L);
  end;
end;

procedure ByteString.ToUpperAnsiShortString(var S: ShortString;
  const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TTextConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  Index := Self.Flags;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then
      begin
        Converter := DestSBCS.FLowerCase;
        if (Converter = nil) then Converter := DestSBCS.FromSBCS(DestSBCS, ccUpper);
      end else
      begin
        Index := NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS);
        Converter := DestSBCS.FromSBCS(Pointer(Index), ccUpper);
      end;

      Dest := Context.Destination;
      if (L > Context.DestinationSize) then L := Context.DestinationSize;
      Dec(Dest);
      Dest^ := L;
      Inc(Dest);
      sbcs_from_sbcs_upper(Pointer(Dest), Context.Source, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      // converter
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
      Context.FCallbacks.Converter := Converter;

      // conversion
      Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf8_upper;
      if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
      begin
        Inc(Context.FDestinationWritten);
        PByteCharArray(Context.Destination)[Context.DestinationWritten] := UNKNOWN_CHARACTER;
      end;
      Dest := Context.Destination;
      Dec(Dest);
      Dest^ := Context.DestinationWritten;
    end;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii}utf8_from_utf8_upper(Pointer(Dest), Context.Source, L);
  end;
end;

procedure ByteString.ToUTF8String(var S: UTF8String);
label
  copy_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then goto copy_characters;

    // converter
    Index := Index shr 24;
    SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Converter := SrcSBCS.FUTF8.Original;
    if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Original, ccOriginal);

    // conversion
    Dest := AStrReserve(S, L * 3);
    AStrSetLength(S, Tiny.Text.utf8_from_sbcs(Dest, Pointer(Src), L, Converter), CODEPAGE_UTF8);
  end else
  begin
    // Ascii chars
  copy_characters:
    Dest := AStrInit(S, nil, L, CODEPAGE_UTF8);
    TinyMove(Src^, Dest^, L);
  end;
end;

procedure ByteString.ToLowerUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then
    begin
      // UTF8 --> UTF8
      Dest := AStrReserve(S, (L * 3) shr 1);
      AStrSetLength(S, Tiny.Text.utf8_from_utf8_lower(Dest, Pointer(Src), L), CODEPAGE_UTF8);
    end else
    begin
      // SBCS --> UTF8
      // converter
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUTF8.Lower;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Lower, ccLower);

      // conversion
      Dest := AStrReserve(S, L * 3);
      AStrSetLength(S, Tiny.Text.utf8_from_sbcs_lower(Dest, Pointer(Src), L, Converter), CODEPAGE_UTF8);
    end;
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, CODEPAGE_UTF8);
    {ascii}Tiny.Text.utf8_from_utf8_lower(Dest, Src, L);
  end;
end;

procedure ByteString.ToUpperUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then
    begin
      // UTF8 --> UTF8
      Dest := AStrReserve(S, (L * 3) shr 1);
      AStrSetLength(S, Tiny.Text.utf8_from_utf8_upper(Dest, Pointer(Src), L), CODEPAGE_UTF8);
    end else
    begin
      // SBCS --> UTF8
      // converter
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUTF8.Upper;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Upper, ccUpper);

      // conversion
      Dest := AStrReserve(S, L * 3);
      AStrSetLength(S, Tiny.Text.utf8_from_sbcs_upper(Dest, Pointer(Src), L, Converter), CODEPAGE_UTF8);
    end;
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, CODEPAGE_UTF8);
    {ascii}Tiny.Text.utf8_from_utf8_upper(Dest, Src, L);
  end;
end;

procedure ByteString.ToUTF8ShortString(var S: ShortString);
label
  copy_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TTextConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Index := Self.Flags;
  Context.Source := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then goto copy_characters;

    // converter
    Index := Index shr 24;
    SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Converter := SrcSBCS.FUTF8.Original;
    if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Original, ccOriginal);
    Context.FCallbacks.Converter := Converter;

    // conversion
    Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_sbcs;
    Context.convert_utf8_from_sbcs;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
  copy_characters:
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    TinyMove(Context.Source^, Dest^, L);
  end;
end;

procedure ByteString.ToLowerUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TTextConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Index := Self.Flags;
  Context.Source := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then
    begin
      // UTF8 --> UTF8
      Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf8_lower;
      Context.convert_utf8_from_utf8;
    end else
    begin
      // SBCS --> UTF8
      // converter
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUTF8.Lower;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Lower, ccLower);
      Context.FCallbacks.Converter := Converter;

      // conversion
      Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_sbcs_lower;
      Context.convert_utf8_from_sbcs;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii}utf8_from_utf8_lower(Pointer(Dest), Context.Source, L);
  end;
end;

procedure ByteString.ToUpperUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TTextConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Index := Self.Flags;
  Context.Source := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then
    begin
      // UTF8 --> UTF8
      Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf8_upper;
      Context.convert_utf8_from_utf8;
    end else
    begin
      // SBCS --> UTF8
      // converter
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUTF8.Upper;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Upper, ccUpper);
      Context.FCallbacks.Converter := Converter;

      // conversion
      Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_sbcs_upper;
      Context.convert_utf8_from_sbcs;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii}utf8_from_utf8_upper(Pointer(Dest), Context.Source, L);
  end;
end;

procedure ByteString.ToWideString(var S: WideString);
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WStrClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Original;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Original, ccOriginal);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := WStrReserve(S, L);
    WStrSetLength(S, Tiny.Text.utf16_from_utf8(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := WStrInit(S, nil, L);
    if (Converter = nil) then
    begin
      utf16_from_utf8(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs(Dest, Src, L, Converter);
    end
  end;
end;

procedure ByteString.ToLowerWideString(var S: WideString);
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WStrClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Lower;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Lower, ccLower);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := WStrReserve(S, L);
    WStrSetLength(S, Tiny.Text.utf16_from_utf8_lower(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := WStrInit(S, nil, L);
    if (Converter = nil) then
    begin
      utf16_from_utf8_lower(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs_lower(Dest, Src, L, Converter);
    end;
  end;
end;

procedure ByteString.ToUpperWideString(var S: WideString);
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WStrClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Upper;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Upper, ccUpper);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := WStrReserve(S, L);
    WStrSetLength(S, Tiny.Text.utf16_from_utf8_upper(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := WStrInit(S, nil, L);
    if (Converter = nil) then
    begin
      utf16_from_utf8_upper(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs_upper(Dest, Src, L, Converter);
    end;
  end;
end;

procedure ByteString.ToUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    UStrClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Original;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Original, ccOriginal);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := UStrReserve(S, L);
    UStrSetLength(S, Tiny.Text.utf16_from_utf8(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := UStrInit(S, nil, L);
    if (Converter = nil) then
    begin
      utf16_from_utf8(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs(Dest, Src, L, Converter);
    end;
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToWideString
end;
{$endif}

procedure ByteString.ToLowerUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    UStrClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Lower;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Lower, ccLower);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := UStrReserve(S, L);
    UStrSetLength(S, Tiny.Text.utf16_from_utf8_lower(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := UStrInit(S, nil, L);
    if (Converter = nil) then
    begin
      utf16_from_utf8_lower(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs_lower(Dest, Src, L, Converter);
    end;
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToLowerWideString
end;
{$endif}

procedure ByteString.ToUpperUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    UStrClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Upper;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Upper, ccUpper);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := UStrReserve(S, L);
    UStrSetLength(S, Tiny.Text.utf16_from_utf8_upper(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := UStrInit(S, nil, L);
    if (Converter = nil) then
    begin
      utf16_from_utf8_upper(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs_upper(Dest, Src, L, Converter);
    end;
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToUpperWideString
end;
{$endif}

procedure ByteString.ToString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUnicodeString(S);
  {$else}
     ToAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToAnsiString
end;
{$ifend}

procedure ByteString.ToLowerString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToLowerUnicodeString(S);
  {$else}
     ToLowerAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToLowerAnsiString
end;
{$ifend}

procedure ByteString.ToUpperString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUpperUnicodeString(S);
  {$else}
     ToUpperAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToUpperAnsiString
end;
{$ifend}

function ByteString.ToAnsiString: AnsiString;
{$ifNdef CPUINTELASM}
begin
  ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

function ByteString.ToLowerAnsiString: AnsiString;
{$ifNdef CPUINTELASM}
begin
  ToLowerAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToLowerAnsiString
end;
{$endif}

function ByteString.ToUpperAnsiString: AnsiString;
{$ifNdef CPUINTELASM}
begin
  ToUpperAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToUpperAnsiString
end;
{$endif}

function ByteString.ToUTF8String: UTF8String;
{$ifNdef CPUINTELASM}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUTF8String
end;
{$endif}

function ByteString.ToLowerUTF8String: UTF8String;
{$ifNdef CPUINTELASM}
begin
  ToLowerUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToLowerUTF8String
end;
{$endif}

function ByteString.ToUpperUTF8String: UTF8String;
{$ifNdef CPUINTELASM}
begin
  ToUpperUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUpperUTF8String
end;
{$endif}

function ByteString.ToWideString: WideString;
{$ifNdef CPUINTELASM}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToWideString
end;
{$endif}

function ByteString.ToLowerWideString: WideString;
{$ifNdef CPUINTELASM}
begin
  ToLowerWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToLowerWideString
end;
{$endif}

function ByteString.ToUpperWideString: WideString;
{$ifNdef CPUINTELASM}
begin
  ToUpperWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUpperWideString
end;
{$endif}

function ByteString.ToUnicodeString: UnicodeString;
{$ifNdef CPUINTELASM}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    jmp ToWideString
  {$endif}
end;
{$endif}

function ByteString.ToLowerUnicodeString: UnicodeString;
{$ifNdef CPUINTELASM}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    jmp ToLowerWideString
  {$endif}
end;
{$endif}

function ByteString.ToUpperUnicodeString: UnicodeString;
{$ifNdef CPUINTELASM}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    jmp ToUpperWideString
  {$endif}
end;
{$endif}

function ByteString.ToString: string;
{$ifNdef CPUINTELASM}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToAnsiString
  {$endif}
end;
{$endif}

function ByteString.ToLowerString: string;
{$ifNdef CPUINTELASM}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToLowerAnsiString
  {$endif}
end;
{$endif}

function ByteString.ToUpperString: string;
{$ifNdef CPUINTELASM}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToUpperAnsiString
  {$endif}
end;
{$endif}

{$ifdef OPERATORSUPPORT}
class operator ByteString.Implicit(const a: ByteString): AnsiString;
{$ifNdef CPUINTELASM}
begin
  a.ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

class operator ByteString.Implicit(const a: ByteString): WideString;
{$ifNdef CPUINTELASM}
begin
  a.ToWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToWideString
end;
{$endif}

{$ifdef UNICODE}
class operator ByteString.Implicit(const a: ByteString): UTF8String;
{$ifNdef CPUINTELASM}
begin
  a.ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUTF8String
end;
{$endif}

class operator ByteString.Implicit(const a: ByteString): UnicodeString;
{$ifNdef CPUINTELASM}
begin
  a.ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUnicodeString
end;
{$endif}
{$endif}
{$endif}

function ByteString._CompareByteString(const S: PByteString;
  const IgnoreCase: Boolean): NativeInt;
label
  diffsbcs_compare, binary_compare, same_modify;
const
  CASE_LOOKUPS: array[Boolean] of Pointer = (nil, @TEXTCONV_CHARCASE);
var
  Kind, F1, F2: NativeUInt;
  CharCase: NativeUInt;
  Comp: TTextConvCompareOptions;
  Store: record
    SelfChars: Pointer;
    SChars: Pointer;
    SameLength: NativeUInt;
    SameModifier: NativeUInt;
  end;
begin
  Comp.Lookup := CASE_LOOKUPS[IgnoreCase];
  Store.SelfChars := Self.FChars;
  Store.SChars := S.FChars;

  // lengths
  F1 := Self.Length;
  F2 := S.Length;
  Comp.Length := F1;
  Comp.Length_2 := F2;
  if (F1 <= F2) then
  begin
    Store.SameLength := F1;
    Store.SameModifier := (-NativeInt(F2 - F1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
  end else
  begin
    Store.SameLength := F2;
    Store.SameModifier := NativeUInt(-1);
  end;

  // flags, SBCS
  F1 := Self.Flags;
  F2 := S.Flags;
  Kind := ((F1 shr 29) and 4) + ((F2 shr 30) and 2) + NativeUInt(Comp.Lookup <> nil);
  F1 := F1 shr 24;
  F2 := F2 shr 24;
  F1 := F1 * SizeOf(TTextConvSBCS);
  F2 := F2 * SizeOf(TTextConvSBCS);
  Inc(F1, NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
  Inc(F2, NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
  case Kind of
    6:
    begin
      // utf8-utf8 sensitive
      goto binary_compare;
    end;
    7:
    begin
      // utf8-utf8 insensitive
      Result := __textconv_utf8_compare_utf8(Store.SelfChars, Store.SChars, Comp);
    end;
    4, 5:
    begin
      // utf8-sbcs sensitive/insensitive
      CharCase := NativeUInt(Comp.Lookup <> nil);
      Comp.Lookup_2 := PTextConvSBCSEx(F2).FUCS2.NumericItems[CharCase];
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := PTextConvSBCSEx(F2).AllocFillUCS2(PTextConvSBCSEx(F2).FUCS2.NumericItems[CharCase], TCharCase(CharCase));
      Result := __textconv_utf8_compare_sbcs(Store.SelfChars, Store.SChars, Comp);
    end;
    2, 3:
    begin
      // sbcs-utf8 sensitive/insensitive
      CharCase := NativeUInt(Comp.Lookup <> nil);
      Comp.Lookup_2 := PTextConvSBCSEx(F1).FUCS2.NumericItems[CharCase];
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := PTextConvSBCSEx(F1).AllocFillUCS2(PTextConvSBCSEx(F1).FUCS2.NumericItems[CharCase], TCharCase(CharCase));
      F1 := Comp.Length;
      F2 := Comp.Length_2;
      Comp.Length := F2;
      Comp.Length_2 := F1;
      Result := __textconv_utf8_compare_sbcs(Store.SChars, Store.SelfChars, Comp);
      Result := -Result;
    end;
    0:
    begin
      // sbcs-sbcs sensitive
      if (F1 = F2) then goto binary_compare;
      goto diffsbcs_compare;
    end;
    1:
    begin
      // sbcs-sbcs insensitive
      if (F1 = F2) then
      begin
        Comp.Lookup := PTextConvSBCSEx(F1).FLowerCase;
        if (Comp.Lookup = nil) then Comp.Lookup := PTextConvSBCS(F1).FromSBCS(PTextConvSBCS(F1), ccLower);
        Comp.Length := Store.SameLength;
        Result := __textconv_sbcs_compare_sbcs_1(Store.SelfChars, Store.SChars, Comp);
      end else
      begin
      diffsbcs_compare:
        CharCase := NativeUInt(Comp.Lookup <> nil);
        Comp.Lookup := PTextConvSBCSEx(F1).FUCS2.NumericItems[CharCase];
        if (Comp.Lookup = nil) then Comp.Lookup := PTextConvSBCSEx(F1).AllocFillUCS2(PTextConvSBCSEx(F1).FUCS2.NumericItems[CharCase], TCharCase(CharCase));
        Comp.Lookup_2 := PTextConvSBCSEx(F2).FUCS2.NumericItems[CharCase];
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := PTextConvSBCSEx(F2).AllocFillUCS2(PTextConvSBCSEx(F2).FUCS2.NumericItems[CharCase], TCharCase(CharCase));
        Comp.Length := Store.SameLength;
        Result := __textconv_sbcs_compare_sbcs_2(Store.SelfChars, Store.SChars, Comp);
      end;
      goto same_modify;
    end;
  else
  binary_compare:
    Result := __textconv_compare_bytes(Store.SelfChars, Store.SChars, Store.SameLength);
  same_modify:
    Inc(Result, Result);
    Dec(Result, Store.SameModifier);
  end;
end;

function ByteString._CompareUTF16String(const S: PUTF16String;
  const IgnoreCase: Boolean): NativeInt;
const
  CASE_LOOKUPS: array[Boolean] of Pointer = (nil, @TEXTCONV_CHARCASE);
var
  Kind, CharCase: NativeUInt;
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  Comp.Lookup := CASE_LOOKUPS[IgnoreCase];
  Kind := Self.Flags;
  if (Integer(Kind) < 0) then
  begin
    // utf8-utf16
    Comp.Length := Self.Length;
    Comp.Length_2 := S.Length;
    Result := __textconv_utf8_compare_utf16(Pointer(Self.FChars), Pointer(S.FChars), Comp);
  end else
  begin
    // sbcs-utf16
    Kind := Kind shr 24;
    Kind := Kind * SizeOf(TTextConvSBCS);
    Inc(Kind, NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

    CharCase := NativeUInt(Comp.Lookup <> nil);
    Comp.Lookup_2 := PTextConvSBCSEx(Kind).FUCS2.NumericItems[CharCase];
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := PTextConvSBCSEx(Kind).AllocFillUCS2(PTextConvSBCSEx(Kind).FUCS2.NumericItems[CharCase], TCharCase(CharCase));

    L1 := Self.Length;
    L2 := S.Length;
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    Result := __textconv_utf16_compare_sbcs(Pointer(S.FChars), Pointer(Self.FChars), Comp);
    Result := -Result;
    Inc(Result, Result);
    Dec(Result, Comp.Length_2);
  end;
end;

{inline} function ByteString.Equal(const S: ByteString): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (Self.Length <> 0) and (S.Length <> 0) then
  begin
    Y := PByte(Self.Chars)^;
    X := PByte(S.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      X := Self.Length;
      Y := S.Length;
      if (Integer(Self.Flags) >= 0) then
      begin
        if (Integer(S.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end;
      end else
      begin
        if (Integer(S.Flags) >= 0) then
        begin
          if (X < Y) then goto ret_non_equal;
          Y := Y * 3;
          if (X > Y) then goto ret_non_equal;
        end else
        begin
          if (X <> Y) then goto ret_non_equal;
        end;
      end;
      Ret := Self._CompareByteString(@S, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = S.Length);
end;

{inline} function ByteString.EqualIgnoreCase(const S: ByteString): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (Self.Length <> 0) and (S.Length <> 0) then
  begin
    Y := PByte(Self.Chars)^;
    X := PByte(S.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      X := Self.Length;
      Y := S.Length;
      if (Integer(Self.Flags) >= 0) then
      begin
        if (Integer(S.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end;
      end else
      begin
        if (Integer(S.Flags) >= 0) then
        begin
          if (X < Y) then goto ret_non_equal;
          Y := Y * 3;
          if (X > Y) then goto ret_non_equal;
        end else
        begin
          if (X >= Y) then
          begin
            Y := Y * 3;
            Y := Y shr 1;
            if (X > Y) then goto ret_non_equal;
          end else
          begin
            X := X * 3;
            X := X shr 1;
            if (Y > X) then goto ret_non_equal;
          end;
        end;
      end;
      Ret := Self._CompareByteString(@S, True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = S.Length);
end;

{inline} function ByteString.Compare(const S: ByteString): NativeInt;
var
  X, Y: NativeUInt;
begin
  if (Self.Length <> 0) and (S.Length <> 0) then
  begin
    Y := PByte(Self.Chars)^;
    X := PByte(S.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Result := Self._CompareByteString(@S, False);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      X := PByte(S.Chars)^;
      {$endif}
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(S.Length));
end;

{inline} function ByteString.CompareIgnoreCase(const S: ByteString): NativeInt;
var
  X, Y: NativeUInt;
begin
  if (Self.Length <> 0) and (S.Length <> 0) then
  begin
    Y := PByte(Self.Chars)^;
    X := PByte(S.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      Result := Self._CompareByteString(@S, True);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(S.Length));
end;

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.Equal(const a: ByteString; const b: ByteString): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PByte(a.Chars)^;
    X := PByte(b.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      X := a.Length;
      Y := b.Length;
      if (Integer(a.Flags) >= 0) then
      begin
        if (Integer(b.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end;
      end else
      begin
        if (Integer(b.Flags) >= 0) then
        begin
          if (X < Y) then goto ret_non_equal;
          Y := Y * 3;
          if (X > Y) then goto ret_non_equal;
        end else
        begin
          if (X <> Y) then goto ret_non_equal;
        end;
      end;
      Ret := a._CompareByteString(@b, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (a.Length = b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.NotEqual(const a: ByteString; const b: ByteString): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PByte(a.Chars)^;
    X := PByte(b.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      X := a.Length;
      Y := b.Length;
      if (Integer(a.Flags) >= 0) then
      begin
        if (Integer(b.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end;
      end else
      begin
        if (Integer(b.Flags) >= 0) then
        begin
          if (X < Y) then goto ret_non_equal;
          Y := Y * 3;
          if (X > Y) then goto ret_non_equal;
        end else
        begin
          if (X <> Y) then goto ret_non_equal;
        end;
      end;
      Ret := a._CompareByteString(@b, False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := True;
      Exit;
    end;
  end;

  Result := (a.Length <> b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.GreaterThan(const a: ByteString; const b: ByteString): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PByte(a.Chars)^;
    X := PByte(b.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := a._CompareByteString(@b, False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      X := PByte(b.Chars)^;
      {$endif}
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.GreaterThanOrEqual(const a: ByteString; const b: ByteString): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PByte(a.Chars)^;
    X := PByte(b.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := a._CompareByteString(@b, False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      X := PByte(b.Chars)^;
      {$endif}
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.LessThan(const a: ByteString; const b: ByteString): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PByte(a.Chars)^;
    X := PByte(b.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := a._CompareByteString(@b, False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      X := PByte(b.Chars)^;
      {$endif}
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.LessThanOrEqual(const a: ByteString; const b: ByteString): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PByte(a.Chars)^;
    X := PByte(b.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := a._CompareByteString(@b, False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      X := PByte(b.Chars)^;
      {$endif}
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= b.Length);
end;
{$endif}

{inline} function ByteString.Equal(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;

      X := Self.Length;
      Y := Buffer.Length;
      if (Integer(Self.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X < Y) then goto ret_non_equal;
        Y := Y * 3;
        if (X > Y) then goto ret_non_equal;
      end;
      Ret := Self._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function ByteString.EqualIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PByte(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;

      X := Self.Length;
      Y := Buffer.Length;
      if (Integer(Self.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X < Y) then goto ret_non_equal;
        Y := Y * 3;
        if (X > Y) then goto ret_non_equal;
      end;
      Ret := Self._CompareByteString(PByteString(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function ByteString.Compare(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Result := Self._CompareByteString(PByteString(@Buffer), False);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{inline} function ByteString.CompareIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PByte(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Result := Self._CompareByteString(PByteString(@Buffer), True);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.Equal(const a: ByteString; const b: AnsiString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;

      X := a.Length;
      Y := Buffer.Length;
      if (Integer(a.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X < Y) then goto ret_non_equal;
        Y := Y * 3;
        if (X > Y) then goto ret_non_equal;
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.Equal(const a: AnsiString; const b: ByteString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;

      X := b.Length;
      Y := Buffer.Length;
      if (Integer(b.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X < Y) then goto ret_non_equal;
        Y := Y * 3;
        if (X > Y) then goto ret_non_equal;
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.NotEqual(const a: ByteString; const b: AnsiString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;

      X := a.Length;
      Y := Buffer.Length;
      if (Integer(a.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X < Y) then goto ret_non_equal;
        Y := Y * 3;
        if (X > Y) then goto ret_non_equal;
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.NotEqual(const a: AnsiString; const b: ByteString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;

      X := b.Length;
      Y := Buffer.Length;
      if (Integer(b.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X < Y) then goto ret_non_equal;
        Y := Y * 3;
        if (X > Y) then goto ret_non_equal;
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.GreaterThan(const a: ByteString; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.GreaterThan(const a: AnsiString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      Result := (X > Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.GreaterThanOrEqual(const a: ByteString; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.GreaterThanOrEqual(const a: AnsiString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      Result := (X >= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.LessThan(const a: ByteString; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.LessThan(const a: AnsiString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      Result := (X < Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.LessThanOrEqual(const a: ByteString; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.LessThanOrEqual(const a: AnsiString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      Result := (X <= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

{inline} function ByteString.{$ifdef UNICODE}Equal{$else}EqualUTF8{$endif}(const S: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := Self.Length;
      Y := Buffer.Length;
      if (Integer(Self.Flags) >= 0) then
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end else
      begin
        if (X <> Y) then goto ret_non_equal;
      end;
      Ret := Self._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function ByteString.{$ifdef UNICODE}EqualIgnoreCase{$else}EqualUTF8IgnoreCase{$endif}(const S: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PByte(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := Self.Length;
      Y := Buffer.Length;
      if (Integer(Self.Flags) >= 0) then
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end else
      begin
        if (X >= Y) then
        begin
          Y := Y * 3;
          Y := Y shr 1;
          if (X > Y) then goto ret_non_equal;
        end else
        begin
          X := X * 3;
          X := X shr 1;
          if (Y > X) then goto ret_non_equal;
        end;
      end;
      Ret := Self._CompareByteString(PByteString(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function ByteString.{$ifdef UNICODE}Compare{$else}CompareUTF8{$endif}(const S: UTF8String): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Result := Self._CompareByteString(PByteString(@Buffer), False);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(Self.Chars)^;
      {$endif}
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{inline} function ByteString.{$ifdef UNICODE}CompareIgnoreCase{$else}CompareUTF8IgnoreCase{$endif}(const S: UTF8String): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PByte(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Result := Self._CompareByteString(PByteString(@Buffer), True);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{$ifdef UNICODE}
{inline} class operator ByteString.Equal(const a: ByteString; const b: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := a.Length;
      Y := Buffer.Length;
      if (Integer(a.Flags) >= 0) then
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end else
      begin
        if (X <> Y) then goto ret_non_equal;
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.Equal(const a: UTF8String; const b: ByteString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := b.Length;
      Y := Buffer.Length;
      if (Integer(b.Flags) >= 0) then
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end else
      begin
        if (X <> Y) then goto ret_non_equal;
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.NotEqual(const a: ByteString; const b: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := a.Length;
      Y := Buffer.Length;
      if (Integer(a.Flags) >= 0) then
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end else
      begin
        if (X <> Y) then goto ret_non_equal;
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.NotEqual(const a: UTF8String; const b: ByteString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := b.Length;
      Y := Buffer.Length;
      if (Integer(b.Flags) >= 0) then
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end else
      begin
        if (X <> Y) then goto ret_non_equal;
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.GreaterThan(const a: ByteString; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(a.Chars)^;
      {$endif}
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.GreaterThan(const a: UTF8String; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(b.Chars)^;
      {$endif}
      Result := (X > Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.GreaterThanOrEqual(const a: ByteString; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(a.Chars)^;
      {$endif}
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.GreaterThanOrEqual(const a: UTF8String; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(b.Chars)^;
      {$endif}
      Result := (X >= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.LessThan(const a: ByteString; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(a.Chars)^;
      {$endif}
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.LessThan(const a: UTF8String; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(b.Chars)^;
      {$endif}
      Result := (X < Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.LessThanOrEqual(const a: ByteString; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(a.Chars)^;
      {$endif}
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.LessThanOrEqual(const a: UTF8String; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(b.Chars)^;
      {$endif}
      Result := (X <= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

{inline} function ByteString.Equal(const S: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Self.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(Self.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        X := Buffer.Length;
        Y := Self.Length;
        if (Integer(Self.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end;
        Ret := Self._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function ByteString.EqualIgnoreCase(const S: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Self.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(Self.Chars)^;
      X := PWord(P)^;
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
      if (X = Y) or (X or Y > $7f) then
      begin
        X := Buffer.Length;
        Y := Self.Length;
        if (Integer(Self.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end;
        Ret := Self._CompareUTF16String(PUTF16String(@Buffer), True);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function ByteString.Compare(const S: WideString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Self.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := L + 1;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(Self.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        Result := Self._CompareUTF16String(PUTF16String(@Buffer), False);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PByte(Self.Chars)^;
        {$endif}
        Result := (NativeInt(Y) - NativeInt(X));
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{inline} function ByteString.CompareIgnoreCase(const S: WideString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Self.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := L + 1;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(Self.Chars)^;
      X := PWord(P)^;
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
      if (X = Y) or (X or Y > $7f) then
      begin
        Result := Self._CompareUTF16String(PUTF16String(@Buffer), True);
        Exit;
      end else
      begin
        Result := (NativeInt(Y) - NativeInt(X));
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.Equal(const a: ByteString; const b: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        X := Buffer.Length;
        Y := a.Length;
        if (Integer(a.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end;
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.Equal(const a: WideString; const b: ByteString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        X := Buffer.Length;
        Y := b.Length;
        if (Integer(b.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end;
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.NotEqual(const a: ByteString; const b: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        X := Buffer.Length;
        Y := a.Length;
        if (Integer(a.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end;
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <> 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := True;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.NotEqual(const a: WideString; const b: ByteString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        X := Buffer.Length;
        Y := b.Length;
        if (Integer(b.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end;
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <> 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := True;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.GreaterThan(const a: ByteString; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret > 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PByte(a.Chars)^;
        {$endif}
        Result := (Y > X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.GreaterThan(const a: WideString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret < 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PByte(b.Chars)^;
        {$endif}
        Result := (X > Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.GreaterThanOrEqual(const a: ByteString; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret >= 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PByte(a.Chars)^;
        {$endif}
        Result := (Y >= X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.GreaterThanOrEqual(const a: WideString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <= 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PByte(b.Chars)^;
        {$endif}
        Result := (X >= Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.LessThan(const a: ByteString; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret < 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PByte(a.Chars)^;
        {$endif}
        Result := (Y < X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.LessThan(const a: WideString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret > 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PByte(b.Chars)^;
        {$endif}
        Result := (X < Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.LessThanOrEqual(const a: ByteString; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <= 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PByte(a.Chars)^;
        {$endif}
        Result := (Y <= X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator ByteString.LessThanOrEqual(const a: WideString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PByte(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y > $7f) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret >= 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PByte(b.Chars)^;
        {$endif}
        Result := (X <= Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} function ByteString.Equal(const S: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      X := Buffer.Length;
      Y := Self.Length;
      if (Integer(Self.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end;
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} function ByteString.EqualIgnoreCase(const S: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PWord(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      X := Buffer.Length;
      Y := Self.Length;
      if (Integer(Self.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end;
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} function ByteString.Compare(const S: UnicodeString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(Self.Chars)^;
      {$endif}
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} function ByteString.CompareIgnoreCase(const S: UnicodeString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(Self.Chars)^;
    X := PWord(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.Equal(const a: ByteString; const b: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      X := Buffer.Length;
      Y := a.Length;
      if (Integer(a.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end;
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.Equal(const a: UnicodeString; const b: ByteString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      X := Buffer.Length;
      Y := b.Length;
      if (Integer(b.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end;
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.NotEqual(const a: ByteString; const b: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      X := Buffer.Length;
      Y := a.Length;
      if (Integer(a.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end;
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.NotEqual(const a: UnicodeString; const b: ByteString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      X := Buffer.Length;
      Y := b.Length;
      if (Integer(b.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end;
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.GreaterThan(const a: ByteString; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(a.Chars)^;
      {$endif}
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.GreaterThan(const a: UnicodeString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(b.Chars)^;
      {$endif}
      Result := (X > Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.GreaterThanOrEqual(const a: ByteString; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(a.Chars)^;
      {$endif}
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.GreaterThanOrEqual(const a: UnicodeString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(b.Chars)^;
      {$endif}
      Result := (X >= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.LessThan(const a: ByteString; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(a.Chars)^;
      {$endif}
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.LessThan(const a: UnicodeString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(b.Chars)^;
      {$endif}
      Result := (X < Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.LessThanOrEqual(const a: ByteString; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(a.Chars)^;
      {$endif}
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator ByteString.LessThanOrEqual(const a: UnicodeString; const b: ByteString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PByte(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(b.Chars)^;
      {$endif}
      Result := (X <= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

function ByteString.Equal(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PByte(Self.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;

        X := Self.Length;
        Y := Buffer.Length;
        if (Integer(Self.Flags) >= 0) then
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end else
        begin
          if (X <> Y) then goto ret_non_equal;
        end;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;

        X := Self.Length;
        Y := Buffer.Length;
        if (Integer(Self.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X < Y) then goto ret_non_equal;
          Y := Y * 3;
          if (X > Y) then goto ret_non_equal;
        end;
      end;
      Ret := Self._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

function ByteString.EqualIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PByte(Self.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;

        X := Self.Length;
        Y := Buffer.Length;
        if (Integer(Self.Flags) >= 0) then
        begin
          if (X > Y) then goto ret_non_equal;
          X := X * 3;
          if (X < Y) then goto ret_non_equal;
        end else
        begin
          if (X >= Y) then
          begin
            Y := Y * 3;
            Y := Y shr 1;
            if (X > Y) then goto ret_non_equal;
          end else
          begin
            X := X * 3;
            X := X shr 1;
            if (Y > X) then goto ret_non_equal;
          end;
        end;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;

        X := Self.Length;
        Y := Buffer.Length;
        if (Integer(Self.Flags) >= 0) then
        begin
          if (X <> Y) then goto ret_non_equal;
        end else
        begin
          if (X < Y) then goto ret_non_equal;
          Y := Y * 3;
          if (X > Y) then goto ret_non_equal;
        end;
      end;
      Ret := Self._CompareByteString(PByteString(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

function ByteString.Compare(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt;
var
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PByte(Self.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;
      end;
      Result := Self._CompareByteString(PByteString(@Buffer), False);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;

function ByteString.CompareIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt;
var
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PByte(Self.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;
      end;
      Result := Self._CompareByteString(PByteString(@Buffer), True);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;

{inline} function ByteString.Equal(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PByte(Self.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      X := Buffer.Length;
      Y := Self.Length;
      if (Integer(Self.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end;
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

{inline} function ByteString.EqualIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PByte(Self.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      X := Buffer.Length;
      Y := Self.Length;
      if (Integer(Self.Flags) >= 0) then
      begin
        if (X <> Y) then goto ret_non_equal;
      end else
      begin
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end;
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

{inline} function ByteString.Compare(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt;
var
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PByte(Self.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PByte(Self.Chars)^;
      {$endif}
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;

{inline} function ByteString.CompareIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt;
var
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PByte(Self.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;


{ UTF16String }

function UTF16String.GetEmpty: Boolean;
begin
  Result := (Length <> 0);
end;

procedure UTF16String.SetEmpty(Value: Boolean);
var
  V: NativeUInt;
begin
  if (Value) then
  begin
    V := 0;
    FLength := V;
    F.NativeFlags := V;
  end;
end;

procedure UTF16String.Assign(const AChars: PUnicodeChar; const ALength: NativeUInt);
begin
  Self.FChars := AChars;
  Self.FLength := ALength;
  Self.F.NativeFlags := 0;
end;

{$ifdef MSWINDOWS}
procedure UTF16String.Assign(const S: WideString);
var
  P: PInteger;
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  Self.F.NativeFlags := 0;
  if (P = nil) then
  begin
    Self.FLength := NativeUInt(P){0};
  end else
  begin
    Dec(NativeInt(P), WSTR_OFFSET_LENGTH);
    Self.FLength := P^{$ifdef WIDESTRLENSHIFT} shr 1{$endif};
  end;
end;
{$endif}

{$ifdef UNICODE}
procedure UTF16String.Assign(const S: UnicodeString);
var
  P: PInteger;
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  Self.F.NativeFlags := 0;
  if (P = nil) then
  begin
    Self.FLength := NativeUInt(P){0};
  end else
  begin
    Dec(NativeInt(P), USTR_OFFSET_LENGTH);
    Self.FLength := P^;
  end;
end;
{$endif}

procedure UTF16String.Delete(const From, Count: NativeUInt);
var
  L: NativeUInt;
  S: PUTF16CharArray;
begin
  L := Length;
  if (From < L) and (Count <> 0) then
  begin
    Dec(L, From);
    if (L <= Count) then
    begin
      Length := From;
    end else
    begin
      Inc(L, From);
      Dec(L, Count);
      Length := L;
      Dec(L, From);

      S := Pointer(Self.FChars);
      Inc(L, L);
      TinyMove(S[From + Count], S[From], L);
    end;
  end;
end;

function UTF16String.DetermineAscii: Boolean;
label
  fail;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(Word);
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
var
  P: PWord;
  L: NativeUInt;
  {$ifdef CPUMANYREGS}
  MASK: NativeUInt;
  {$else}
const
  MASK = not NativeUInt($007f007f);
  {$endif}
begin
  P := Pointer(FChars);
  L := FLength;

  {$ifdef CPUMANYREGS}
  MASK := not NativeUInt({$ifdef LARGEINT}$007f007f007f007f{$else}$007f007f{$endif});
  {$endif}

  while (L >= CHARS_IN_NATIVE) do
  begin
    if (PNativeUInt(P)^ and MASK <> 0) then goto fail;
    Dec(L, CHARS_IN_NATIVE);
    Inc(P, CHARS_IN_NATIVE);
  end;
  {$ifdef LARGEINT}
  if (L >= CHARS_IN_CARDINAL) then
  begin
    if (PCardinal(P)^ and MASK <> 0) then goto fail;
    // Dec(L, CHARS_IN_CARDINAL);
    Inc(P, CHARS_IN_CARDINAL);
  end;
  {$endif}
  if (L and 1 <> 0) and (P^ > $7f) then goto fail;

  Ascii := True;
  Result := True;
  Exit;
fail:
  Ascii := False;
  Result := False;
end;

function UTF16String.TrimLeft: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PWord;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  if (S^ > 32) then
  begin
    Result := True;
    Exit;
  end else
  begin
    Result := _TrimLeft(S, L);
  end;
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  test ecx, ecx
  jnz @1
  xor eax, eax
  ret
@1:
  cmp word ptr [edx], 32
  jbe _TrimLeft
  mov al, 1
end;
{$ifend}

function UTF16String._TrimLeft(S: PWord; L: NativeUInt): Boolean;
label
  fail;
var
  TopS: PWord;
begin
  TopS := @PUTF16CharArray(S)[L];

  repeat
    Inc(S);
    if (S = TopS) then goto fail;
  until (S^ > 32);

  FChars := Pointer(S);
  Dec(NativeUInt(TopS), NativeUInt(S));
  FLength := NativeUInt(TopS) shr 1;
  Result := True;
  Exit;
fail:
  L := 0;
  FLength := L{0};
  Result := False;
end;

function UTF16String.TrimRight: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PWord;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PUTF16CharArray(S)[L] > 32) then
    begin
      Result := True;
      Exit;
    end else
    begin
      Result := _TrimRight(S, L);
    end;
  end;
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:
  cmp word ptr [edx + ecx*2], 32
  jbe _TrimRight
  mov al, 1
end;
{$ifend}

function UTF16String._TrimRight(S: PWord; H: NativeUInt): Boolean;
label
  fail;
var
  TopS: PWord;
begin
  TopS := @PUTF16CharArray(S)[H];

  Dec(S);
  repeat
    Dec(TopS);
    if (S = TopS) then goto fail;
  until (TopS^ > 32);

  Dec(NativeUInt(TopS), NativeUInt(S));
  FLength := NativeUInt(TopS) shr 1;
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};
  Result := False;
end;

function UTF16String.Trim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PWord;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PUTF16CharArray(S)[L] > 32) then
    begin
      // TrimLeft or True
      if (S^ > 32) then
      begin
        Result := True;
        Exit;
      end else
      begin
        Result := _TrimLeft(S, L+1);
        Exit;
      end;
    end else
    begin
      // TrimRight or Trim
      if (S^ > 32) then
      begin
        Result := _TrimRight(S, L);
        Exit;
      end else
      begin
        Result := _Trim(S, L);
      end;
    end;
  end;
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:
  cmp word ptr [edx + ecx*2], 32
  jbe @2
  // TrimLeft or True
  inc ecx
  cmp word ptr [edx], 32
  jbe _TrimLeft
  mov al, 1
  ret
@2:
  // TrimRight or Trim
  cmp word ptr [edx], 32
  ja _TrimRight
  jmp _Trim
end;
{$ifend}

function UTF16String._Trim(S: PWord; H: NativeUInt): Boolean;
label
  fail;
var
  TopS: PWord;
begin
  if (H = 0) then goto fail;
  TopS := @PUTF16CharArray(S)[H];

  // TrimLeft
  repeat
    Inc(S);
    if (S = TopS) then goto fail;
  until (S^ > 32);
  FChars := Pointer(S);

  // TrimRight
  Dec(S);
  repeat
    Dec(TopS);
  until (TopS^ > 32);

  // Result
  Dec(NativeUInt(TopS), NativeUInt(S));
  FLength := NativeUInt(TopS) shr 1;
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};
  Result := False;
end;

function UTF16String.SubString(const From, Count: NativeUInt): UTF16String;
var
  L: NativeUInt;
begin
  Result.F.NativeFlags := Self.F.NativeFlags;
  Result.FChars := Pointer(@PUTF16CharArray(Self.FChars)[From]);

  L := Self.FLength;
  Dec(L, From);
  if (NativeInt(L) <= 0) then
  begin
    Result.FLength := 0;
    Exit;
  end;

  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function UTF16String.SubString(const Count: NativeUInt): UTF16String;
var
  L: NativeUInt;
begin
  Result.FChars := Self.FChars;
  Result.F.NativeFlags := Self.F.NativeFlags;
  L := Self.FLength;
  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function UTF16String.Skip(const Count: NativeUInt): Boolean;
var
  L: NativeUInt;
begin
  L := FLength;
  if (L <= Count) then
  begin
    FChars := Pointer(@PUTF16CharArray(FChars)[L]);
    FLength := 0;
    Result := False;
  end else
  begin
    Dec(L, Count);
    FLength := L;
    FChars := Pointer(@PUTF16CharArray(FChars)[Count]);
    Result := True;
  end;
end;

function UTF16String.Hash: Cardinal;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
var
  L, L_High: NativeUInt;
  P: PWord;
  V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := L shl (32-9);
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (P^ + Result);
    // Dec(L);/Inc(P);
    V := Result shr 5;
    Dec(L, CHARS_IN_CARDINAL);
    Inc(Result, PCardinal(P)^);
    Inc(P, CHARS_IN_CARDINAL);
    Result := Result xor V;
  until (L < CHARS_IN_CARDINAL);

  if (L and 1 <> 0) then
  begin
    V := Result shr 5;
    Inc(Result, P^);
    Result := Result xor V;
  end;

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function UTF16String.HashIgnoreCase: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  if (Self.Ascii) then Result := _HashIgnoreCaseAscii
  else Result := _HashIgnoreCase;
end;
{$else .CPUX86.DELPHI}
asm
  cmp byte ptr [EAX].F.Ascii, 0
  jnz _HashIgnoreCaseAscii
  jmp _HashIgnoreCase
end;
{$ifend}

function UTF16String._HashIgnoreCaseAscii: Cardinal;
label
  include_x;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
var
  L, L_High: NativeUInt;
  P: PWord;
  X, V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := L shl (32-9);
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := PCardinal(P)^;
  include_x:
    X := X or ((X and $00400040) shr 1);
    Dec(L, CHARS_IN_CARDINAL);
    V := Result shr 5;
    Inc(Result, X);
    Inc(P, CHARS_IN_CARDINAL);
    Result := Result xor V;
  until (L < CHARS_IN_CARDINAL);

  if (L and 1 <> 0) then
  begin
    X := P^;
    Inc(L);
    goto include_x;
  end;

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function UTF16String._HashIgnoreCase: Cardinal;
label
  include_ascii, x_calculated;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
  MASK = not Cardinal($007f007f);
  MASK_FIRST = not Cardinal($ffff007f);
var
  L: NativeUInt;
  P: PWord;
  X, V: Cardinal;
  {$ifdef CPUX86}
  S: record
    L_High: NativeUInt;
  end;
  {$else}
  L_High: NativeUInt;
  {$endif}
  lookup_utf16_lower: PTextConvWW;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  lookup_utf16_lower := Pointer(@TEXTCONV_CHARCASE.LOWER);
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := PCardinal(P)^;
    Dec(L);
    Inc(P);
    if (X and MASK <> 0) then
    begin
      if (X and MASK_FIRST = 0) then
      begin
        X := Word(X);
        goto include_ascii;
      end else
      begin
        X := Word(X);
        if (X >= $d800) and (X < $dc00) then
        begin
          Dec(L);
          Inc(P);
          goto x_calculated;
        end;

        X := lookup_utf16_lower[X];
        goto x_calculated;
      end;
    end else
    begin
      Dec(L);
      Inc(P);
    include_ascii:
      X := X or ((X and $00400040) shr 1);
    end;

  x_calculated:
    V := Result shr 5;
    Inc(Result, X);

    Result := Result xor V;
  until (NativeInt(L) < CHARS_IN_CARDINAL);

  if (NativeInt(L) > 0) then
  begin
    X := P^;
    if (X > $7f) then
    begin
      X := lookup_utf16_lower[X];
    end else
    begin
      X := X or ((X and $0040) shr 1);
    end;
    V := Result shr 5;
    Inc(Result, X);
    Result := Result xor V;
  end;

  Result := (Result and (-1 shr 9)) + ({$ifdef CPUX86}S.{$endif}L_High);
end;

function UTF16String.CharPos(const C: UnicodeChar;
  const From: NativeUInt): NativeInt;
label
  failure, found;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
var
  X: Cardinal;
  CValue: Word;
  P, TopCardinal, Top: PWord;
  StoredChars: PWord;
begin
  P := Pointer(FChars);
  TopCardinal := Pointer(@PWordArray(P)[FLength - CHARS_IN_CARDINAL]);
  StoredChars := P;
  Inc(P, From);
  if (Self.Ascii > (Ord(C) <= $7f)) then goto failure;
  CValue := Ord(C);

  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    if (Word(X) = CValue) then goto found;
    Inc(P);
    X := X shr 16;
    if (Word(X) = CValue) then goto found;
    Inc(P);
  until (False);

  Top := Pointer(@PWordArray(TopCardinal)[CHARS_IN_CARDINAL]);
  if (NativeUInt(P) < NativeUInt(Top)) and (P^ = CValue) then goto found;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
  Result := Result shr 1;
end;

function UTF16String.CharPosIgnoreCase(const C: UnicodeChar;
  const From: NativeUInt): NativeInt;
label
  failure, found;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
  SUB_MASK  = Integer(-$00010001);
  OVERFLOW_MASK = Integer($80008000);
var
  X, T, V, U, LowerCharMask, UpperCharMask: NativeInt;
  P, TopCardinal, Top: PWord;
  StoredChars: PWord;
begin
  P := Pointer(FChars);
  TopCardinal := Pointer(@PWordArray(P)[FLength - CHARS_IN_CARDINAL]);
  StoredChars := P;
  Inc(P, From);
  if (Self.Ascii > (Ord(C) <= $7f)) then goto failure;

  LowerCharMask := Ord(TEXTCONV_CHARCASE.LOWER[C]);
  UpperCharMask := Ord(TEXTCONV_CHARCASE.UPPER[C]);
  LowerCharMask := LowerCharMask + LowerCharMask shl 16;
  UpperCharMask := UpperCharMask + UpperCharMask shl 16;

  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    T := (X xor LowerCharMask);
    U := (X xor UpperCharMask);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(T and $8000 = 0));
    goto found;
  until (False);

  LowerCharMask := Word(LowerCharMask);
  UpperCharMask := Word(UpperCharMask);
  Top := Pointer(@PWordArray(TopCardinal)[CHARS_IN_CARDINAL]);
  if (NativeUInt(P) < NativeUInt(Top)) then
  begin
    X := P^;
    if (X = LowerCharMask) then goto found;
    if (X = UpperCharMask) then goto found;
  end;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
  Result := Result shr 1;
end;

function UTF16String.Pos(const S: UTF16String; const From: NativeUInt): NativeInt;
label
  next_iteration, failure, char_found;
type
  TChar = Word;
  PChar = ^TChar;
  TCharArray = TUTF16CharArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(TChar);
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(TChar);
var
  L, X: NativeUInt;
  CValue: Word;
  P, Top, TopCardinal: PChar;
  P1, P2: PChar;
  Store: record
    StrLength: NativeUInt;
    StrChars: Pointer;
    SelfChars: Pointer;
    CValue: Word;
  end;
begin
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPos(PUnicodeChar(Store.StrChars)^, From);
    Exit;
  end;
  Store.StrLength := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  TopCardinal := Pointer(@PCharArray(P)[Self.FLength -L - (CHARS_IN_CARDINAL - 1)]);
  Inc(P, From);

  CValue := PChar(Store.StrChars)^;
  if (Self.Ascii > (CValue <= $7f)) then goto failure;
  Store.CValue := CValue;

  next_iteration:
    CValue := Store.CValue;
  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    if (Word(X) = CValue) then goto char_found;
    Inc(P);
    X := X shr 16;
    Inc(P);
    if (Word(X) <> CValue) then Continue;
    Dec(P);
  char_found:
    Inc(P);
    L := Store.StrLength - 1;
    P2 := Store.StrChars;
    P1 := P;
    Inc(P2);
    if (L >= CHARS_IN_NATIVE) then
    repeat
      if (PNativeUInt(P1)^ <> PNativeUInt(P2)^) then goto next_iteration;
      Dec(L, CHARS_IN_NATIVE);
      Inc(P1, CHARS_IN_NATIVE);
      Inc(P2, CHARS_IN_NATIVE);
    until (L < CHARS_IN_NATIVE);
    {$ifdef LARGEINT}
    if (L >= CHARS_IN_CARDINAL{2}) then
    begin
      if (PCardinal(P1)^ <> PCardinal(P2)^) then goto next_iteration;
      Dec(L, CHARS_IN_CARDINAL);
      Inc(P1, CHARS_IN_CARDINAL);
      Inc(P2, CHARS_IN_CARDINAL);
    end;
    {$endif}
    if (L <> 0) then
    begin
      if (P1^ <> P2^) then goto next_iteration;
    end;

    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Result := Result shr 1;
    Exit;
  until (False);

  Top := Pointer(@PWordArray(TopCardinal)[CHARS_IN_CARDINAL]);
  if (NativeUInt(P) < NativeUInt(Top)) and (P^ = CValue) then goto char_found;

failure:
  Result := -1;
end;

function UTF16String.Pos(const AChars: PUnicodeChar; const ALength: NativeUInt;
  const From: NativeUInt): NativeInt;
var
  Buffer: PtrString;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  Result := Self.Pos(PUTF16String(@Buffer)^, From);
end;

function UTF16String.Pos(const S: UnicodeString; const From: NativeUInt): NativeInt;
var
  P: PInteger;
  Buffer: PtrString;
begin
  P := Pointer(S);
  Buffer.Chars := P;
  if (P = nil) then
  begin
    Result := -1;
  end else
  begin
    Dec(NativeInt(P), USTR_OFFSET_LENGTH);
    Buffer.Length := P^{$if Defined(WIDESTRLENSHIFT) and not Defined(UNICODE)} shr 1{$ifend};
    Result := Self.Pos(PUTF16String(@Buffer)^, From);
  end;
end;

function UTF16String.PosIgnoreCase(const S: UTF16String;
  const From: NativeUInt): NativeInt;
label
  failure, char_found;
type
  TChar = Word;
  PChar = ^TChar;
  TCharArray = TUTF16CharArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(TChar);
  SUB_MASK  = Integer(-$00010001);
  OVERFLOW_MASK = Integer($80008000);
var
  L: NativeUInt;
  X, T, V, U, LowerCharMask, UpperCharMask: NativeInt;
  P, Top{$ifNdef CPUX86},TopCardinal{$endif}: PChar;
  Store: record
    StrLength: NativeUInt;
    StrChars: Pointer;
    SelfChars: Pointer;
    SelfCharsTop: Pointer;
    {$ifdef CPUX86}TopCardinal: Pointer;{$endif}
    UpperCharMask: NativeInt;
  end;
begin
  UpperCharMask := From{store};
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPosIgnoreCase(PUnicodeChar(Store.StrChars)^, UpperCharMask);
    Exit;
  end;
  Store.StrLength := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  Store.SelfCharsTop := Pointer(@PCharArray(P)[Self.FLength]);
  {$ifdef CPUX86}Store.{$endif}TopCardinal := Pointer(@PCharArray(Store.SelfCharsTop)[-L - (CHARS_IN_CARDINAL - 1)]);
  Inc(P, UpperCharMask{From});

  U := PChar(Store.StrChars)^;
  if (Self.Ascii > (U <= $7f)) then goto failure;
  LowerCharMask := TEXTCONV_CHARCASE.VALUES[U];
  UpperCharMask := TEXTCONV_CHARCASE.VALUES[$10000 + U];
  LowerCharMask := LowerCharMask + LowerCharMask shl 16;
  UpperCharMask := UpperCharMask + UpperCharMask shl 16;

  repeat
    if (NativeUInt(P) > NativeUInt({$ifdef CPUX86}Store.{$endif}TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    T := (X xor LowerCharMask);
    U := (X xor UpperCharMask);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(T and $8000 = 0));
  char_found:
    Store.UpperCharMask := UpperCharMask;
      U := __textconv_utf16_compare_utf16(Pointer(P), Store.StrChars, Store.StrLength);
    UpperCharMask := Store.UpperCharMask;
    Inc(P);
    if (U <> 0) then Continue;
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Result := Result shr 1;
    Exit;
  until (False);

  LowerCharMask := TChar(LowerCharMask);
  UpperCharMask := TChar(UpperCharMask);
  Top := Pointer(@PCharArray({$ifdef CPUX86}Store.{$endif}TopCardinal)[CHARS_IN_CARDINAL]);
  if (NativeUInt(P) < NativeUInt(Top)) then
  begin
    X := P^;
    if (X = LowerCharMask) then goto char_found;
    if (X = UpperCharMask) then goto char_found;
  end;

failure:
  Result := -1;
end;

function UTF16String.PosIgnoreCase(const AChars: PUnicodeChar;
  const ALength: NativeUInt; const From: NativeUInt): NativeInt;
var
  Buffer: PtrString;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  Result := Self.PosIgnoreCase(PUTF16String(@Buffer)^, From);
end;

function UTF16String.PosIgnoreCase(const S: UnicodeString;
  const From: NativeUInt): NativeInt;
var
  P: PInteger;
  Buffer: PtrString;
begin
  P := Pointer(S);
  Buffer.Chars := P;
  Dec(NativeInt(P), USTR_OFFSET_LENGTH);
  Buffer.Length := P^{$if Defined(WIDESTRLENSHIFT) and not Defined(UNICODE)} shr 1{$ifend};
  Result := Self.PosIgnoreCase(PUTF16String(@Buffer)^, From);
end;

function UTF16String.TryToBoolean(out Value: Boolean): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetBool
  pop edx
  pop ecx
  mov [ecx], al
  xchg eax, edx
end;
{$ifend}

function UTF16String.ToBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PUTF16String(@Default)._GetBool(Pointer(Chars), Length);
end;

function UTF16String.ToBoolean: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetBool
end;
{$ifend}

function UTF16String._GetBool(S: PWord; L: NativeUInt): Boolean;
label
  fail;
var
  Marker: NativeInt;
  Buffer: ByteString;
begin
  Buffer.Chars := Pointer(S);
  Buffer.Length := L;

  // utf16 ascii, ignore case
  with PMemoryItems(Buffer.Chars)^ do
  case L of
    1: case (Words[0]) of // "0", "1"
         $0030:
         begin
           // "0"
           Result := False;
           Exit;
         end;
         $0031:
         begin
           // "1"
           Result := True;
           Exit;
         end;
       end;
    2: if (Cardinals[0] or $00200020 = $006F006E) then
    begin
      // "no"
      Result := False;
      Exit;
    end;
    3: if (Cardinals[0] or $00200020 = $00650079) and (Words[2] or $0020 = $0073) then
    begin
      // "yes"
      Result := True;
      Exit;
    end;
    4: if (Cardinals[0] or $00200020 = $00720074) and
       (Cardinals[1] or $00200020 = $00650075) then
    begin
      // "true"
      Result := True;
      Exit;
    end;
    5: if (Cardinals[0] or $00200020 = $00610066) and
       (Cardinals[1] or $00200020 = $0073006C) and (Words[4] or $0020 = $0065) then
    begin
      // "false"
      Result := False;
      Exit;
    end;
  end;

fail:
  Marker := NativeInt(@Self);
  if (Marker = 0) then
  begin
    Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidBoolean), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PBoolean(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
    Result := False;
  end;
end;

function UTF16String.TryToHex(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function UTF16String.ToHexDef(const Default: Integer): Integer;
begin
  Result := PUTF16String(@Default)._GetHex(Pointer(Chars), Length);
end;

function UTF16String.ToHex: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex
end;
{$ifend}

function UTF16String._GetHex(S: PWord; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: UTF16String;
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;
  Result := 0;

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      Result := Result shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      Result := Result shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(Result, X);
  until (L = 0);

  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function UTF16String.TryToCardinal(out Value: Cardinal): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function UTF16String.ToCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PUTF16String(@Default)._GetInt(Pointer(Chars), Length);
end;

function UTF16String.ToCardinal: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function UTF16String.TryToInteger(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function UTF16String.ToIntegerDef(const Default: Integer): Integer;
begin
  Result := PUTF16String(@Default)._GetInt(Pointer(Chars), -Length);
end;

function UTF16String.ToInteger: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function UTF16String._GetInt(S: PWord; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: UTF16String;
  HexRet: record
    Value: Integer;
  end;
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PUTF16String(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PUTF16String(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L >= 10{high(Result)}) then
  begin
    Dec(L);
    Marker := Marker or 2;
    if (L > 10-1) then goto fail;
  end;
  Result := 0;

  repeat
    X := NativeUInt(S^) - Ord('0');
    Result := Result * 10;
    Dec(L);
    Inc(Result, X);
    Inc(S);
    if (X >= 10) then goto fail;
  until (L = 0);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        case Cardinal(Result) of
          0..High(Cardinal) div 10 - 1: ;
          High(Cardinal) div 10:
          begin
            if (X > High(Cardinal) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end else
      begin
        case Cardinal(Result) of
          0..High(Integer) div 10 - 1: ;
          High(Integer) div 10:
          begin
            if (X > (NativeUInt(Marker) shr 2) + High(Integer) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end;

      Result := Result * 10;
      Inc(Result, X);
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function UTF16String.TryToHex64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function UTF16String.ToHex64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(@Default)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetHex64
end;
{$ifend}

function UTF16String.ToHex64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex64
end;
{$ifend}

function UTF16String._GetHex64(S: PWord; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: UTF16String;
  X: NativeUInt;
  R1, R2: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;

  R1 := 0;
  R2 := 0;

  if (L > 8) then
  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R2 := R2 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R2 := R2 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R2, X);
  until (L = 8);

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R1 := R1 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R1 := R1 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R1, X);
  until (L = 0);

  {$ifdef SMALLINT}
  with PPoint(@Result)^ do
  begin
    X := R1;
    Y := R2;
  end;
  {$else .LARGEINT}
  Result := (R2 shl 32) + R1;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function UTF16String.TryToUInt64(out Value: UInt64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function UTF16String.ToUInt64Def(const Default: UInt64): UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(@Default)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function UTF16String.ToUInt64: UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function UTF16String.TryToInt64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function UTF16String.ToInt64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(@Default)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function UTF16String.ToInt64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function UTF16String._GetInt64(S: PWord; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: UTF16String;
  HexRet: record
    Value: Integer;
  end;
  X: NativeUInt;
  Marker: NativeInt;
  R1, R2: Integer;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PUTF16String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PUTF16String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L <= 9) then
  begin
    R1 := PUTF16String(nil)._GetInt_19(S, L);
    if (R1 < 0) then goto fail;

    if (Marker and 4 <> 0) then R1 := -R1;
    Result := R1;
    Exit;
  end else
  if (L >= 19) then
  begin
    if (L = 19) then
    begin
      Marker := Marker or 2;
      Dec(L);
    end else
    if (L = 20) and (Marker and 1 = 0) then
    begin
      Marker := Marker or (2 or 4{TEN_BB});
      if (S^ <> $31{Ord('1')}) then goto fail;
      Dec(L, 2);
      Inc(S);
    end else
    goto fail;
  end;

  Dec(L, 9);
  R2 := PUTF16String(nil)._GetInt_19(S, L);
  Inc(S, L);
  if (R2 < 0) then goto fail;

  R1 := PUTF16String(nil)._GetInt_19(S, 9);
  Inc(S, 9);
  if (R1 < 0) then goto fail;

  Result := Decimal64R21(R2, R1);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        // UInt64
        if (Marker and 4 = 0) then
        begin
          Result := Decimal64VX(Result, X);
        end else
        begin
          if (Result >= _HIGHU64 div 10) then
          begin
            if (Result = _HIGHU64 div 10) then
            begin
              if (X > NativeUInt(_HIGHU64 mod 10)) then goto fail;
            end else
            begin
              goto fail;
            end;
          end;

          Result := Decimal64VX(Result, X);
          Inc(Result, TEN_BB);
        end;

        Exit;
      end else
      begin
        // Int64
        if (Result >= High(Int64) div 10) then
        begin
          if (Result = High(Int64) div 10) then
          begin
            if (X > (NativeUInt(Marker) shr 2) + NativeUInt(High(Int64) mod 10)) then goto fail;
          end else
          begin
            goto fail;
          end;
        end;

        Result := Decimal64VX(Result, X);
      end;
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function UTF16String._GetInt_19(S: PWord; L: NativeUInt): NativeInt;
label
  fail, _1, _2, _3, _4, _5, _6, _7, _8, _9;
var
  {$ifdef CPUX86}
  Store: record
    _R: PNativeInt;
    _S: PWord;
  end;
  {$else}
  _S: PWord;
  {$endif}
  _R: PNativeInt;
begin
  {$ifdef CPUX86}Store.{$endif}_R := Pointer(@Self);
  {$ifdef CPUX86}Store.{$endif}_S := S;

  Result := 0;
  case L of
    9:
    begin
    _9:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      if (L >= 10) then goto fail;
      Inc(Result, L);
      goto _8;
    end;
    8:
    begin
    _8:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _7;
    end;
    7:
    begin
    _7:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _6;
    end;
    6:
    begin
    _6:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _5;
    end;
    5:
    begin
    _5:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _4;
    end;
    4:
    begin
    _4:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _3;
    end;
    3:
    begin
    _3:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _2;
    end;
    2:
    begin
    _2:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _1;
    end
  else
  _1:
    L := NativeUInt(S^) - Ord('0');
    Inc(S);
    Result := Result * 2;
    if (L >= 10) then goto fail;
    Result := Result * 5;
    Inc(Result, L);
    Exit;
  end;

fail:
  {$ifdef CPUX86}
  _R := Store._R;
  {$endif}
  Result := Result shr 1;
  if (_R <> nil) then _R^ := Result;

  Result := NativeInt({$ifdef CPUX86}Store.{$endif}_S);
  Dec(Result, NativeInt(S));
  Result := (Result shr 1) or Low(NativeInt);
end;

function UTF16String.TryToFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function UTF16String.TryToFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

{$if (not Defined(FPC)) or Defined(EXTENDEDSUPPORT)}
function UTF16String.TryToFloat(out Value: Extended): Boolean;
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;
{$ifend}

function UTF16String.ToFloatDef(const Default: Extended): Extended;
begin
  Result := PUTF16String(@Default)._GetFloat(Pointer(Chars), Length);
end;

function UTF16String.ToFloat: Extended;
begin
  Result := PUTF16String(0)._GetFloat(Pointer(Chars), Length);
end;

function UTF16String._GetFloat(S: PWord; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: UTF16String;
  Store: record
    V: NativeInt;
    Sign: Byte;
  end;
  X: NativeUInt;
  Marker: NativeInt;

  V: NativeInt;
  Base: Double;
  TenPowers: PTenPowers;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  if (L = 0) then goto fail;

  X := S^;
  Buffer.Length := L;
  Store.Sign := 0;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Store.Sign := $80;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  // integer part
  begin
    if (L > 9) then
    begin
      V := PUTF16String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PUTF16String(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      V := not V;
      Result := Integer(Store.V);
      Dec(L, V);
      Inc(S, V);
    end else
    begin
      Result := Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      repeat
        if (L > 9) then
        begin
          V := PUTF16String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PUTF16String(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result * TEN_POWERS[True][X] + Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          Break;
        end else
        begin
          Result := Result * TEN_POWERS[True][X] + Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  case S^ of
    Ord('.'), Ord(','): goto frac;
    Ord('e'), Ord('E'):
    begin
      if (S <> Pointer(Buffer.Chars)) then goto exp;
      goto fail;
    end
  else
    goto fail;
  end;

frac:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // frac part
  begin
    if (L > 9) then
    begin
      V := PUTF16String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PUTF16String(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      X := not V;
      Result := Result + TEN_POWERS[False][X] * Integer(Store.V);
      Dec(L, X);
      Inc(S, X);
    end else
    begin
      Result := Result + TEN_POWERS[False][X] * Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      Base := TEN_POWERS[False][9];
      repeat
        if (L > 9) then
        begin
          V := PUTF16String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PUTF16String(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result + Base * TEN_POWERS[False][X] * Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          Break;
        end else
        begin
          Base := Base * TEN_POWERS[False][X];
          Result := Result + Base * Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  if (S^ or $20 <> $65{Ord('e')}) then goto fail;
exp:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // exponent part
  X := S^;
  TenPowers := @TEN_POWERS[True];

  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      TenPowers := @TEN_POWERS[False];
      goto skipexpsign;
    end;
    Ord('+'):
    begin
    skipexpsign:
      Inc(S);
      if (L = 1) then goto done;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto done;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 3) then goto fail;
  if (L = 1) then
  begin
    X := NativeUInt(S^) - Ord('0');
    if (X >= 10) then goto fail;
    Result := Result * TenPowers[X];
  end else
  begin
    V := PUTF16String(nil)._GetInt_19(S, L);
    if (V < 0) or (V > 300) then goto fail;
    Result := Result * TenPower(TenPowers, V);
  end;
done:
  {$ifdef EXTENDEDSUPPORT}
    Inc(PExtendedBytes(@Result)[High(TExtendedBytes)], Store.Sign);
  {$else}
    if (Store.Sign <> 0) then Result := -Result;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidFloat), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PExtended(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function UTF16String.ToDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function UTF16String.ToDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise _GetDateTimeException(1{Date});
end;

function UTF16String.TryToDate(out Value: TDateTime): Boolean;
const
  DT = 1{Date};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function UTF16String.ToTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    Result := Default;
end;

function UTF16String.ToTime: TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    raise _GetDateTimeException(2{Time});
end;

function UTF16String.TryToTime(out Value: TDateTime): Boolean;
const
  DT = 2{Time};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function UTF16String.ToDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function UTF16String.ToDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise _GetDateTimeException(3{DateTime});
end;

function UTF16String.TryToDateTime(out Value: TDateTime): Boolean;
const
  DT = 3{DateTime};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function UTF16String._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
label
  fail;
var
  L, X: NativeUInt;
  Dest: PByte;
  Src: PWord;
  Buffer: TDateTimeBuffer;
begin
  Buffer.Value := @Value;
  L := Self.Length;
  Buffer.Length := L;
  Buffer.DT := DT;
  if (L < DT_LEN_MIN[DT]) or (L > DT_LEN_MAX[DT]) then
  begin
  fail:
    Result := False;
    Exit;
  end;

  Src := Pointer(FChars);
  Dest := Pointer(@Buffer.Bytes);
  repeat
    X := Src^;
    Inc(Src);
    if (X > High(DT_BYTES)) then goto fail;
    Dest^ := DT_BYTES[X];
    Dec(L);
    Inc(Dest);
  until (L = 0);

  Result := Tiny.Cache.Text._GetDateTime(Buffer);
end;

function UTF16String._GetDateTimeException(DT: NativeUInt): ETinyString;
var
  ResStringRec: PResStringRec;
begin
  case DT of
    1{Date}: ResStringRec := Pointer(@SInvalidDate);
    2{Time}: ResStringRec := Pointer(@SInvalidTime);
  else
    {3: DateTime}
    ResStringRec := Pointer(@SInvalidDateTime);
  end;

  Result := ETinyString.Create(ResStringRec, @Self);
end;

procedure UTF16String.ToAnsiString(var S: AnsiString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(Pointer(S)));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

    Dest := AStrReserve(S, L);
    Pointer(S) := Dest;
    AStrSetLength(S, Tiny.Text.sbcs_from_utf16(Dest, Src, L, Converter), DestSBCS.CodePage);
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, DestSBCS.CodePage);
    {ascii}utf8_from_utf16(Dest, Src, L)
  end;
end;

procedure UTF16String.ToLowerAnsiString(var S: AnsiString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8String(UTF8String(Pointer(S)));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

    Dest := AStrReserve(S, L);
    Pointer(S) := Dest;
    AStrSetLength(S, Tiny.Text.sbcs_from_utf16_lower(Dest, Src, L, Converter), DestSBCS.CodePage);
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, DestSBCS.CodePage);
    {ascii}utf8_from_utf16_lower(Dest, Src, L)
  end;
end;

procedure UTF16String.ToUpperAnsiString(var S: AnsiString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8String(UTF8String(Pointer(S)));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

    Dest := AStrReserve(S, L);
    Pointer(S) := Dest;
    AStrSetLength(S, Tiny.Text.sbcs_from_utf16_upper(Dest, Src, L, Converter), DestSBCS.CodePage);
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, DestSBCS.CodePage);
    {ascii}utf8_from_utf16_upper(Dest, Src, L)
  end;
end;

procedure UTF16String.ToAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TTextConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  if (not Self.Ascii) then
  begin
    // converter
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
    Context.FCallbacks.Converter := Converter;

    // conversion
    Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf16;
    if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      PByteCharArray(Context.Destination)[Context.DestinationWritten] := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii} utf8_from_utf16(Pointer(Dest), Context.Source, L);
  end;
end;

procedure UTF16String.ToLowerAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TTextConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  if (not Self.Ascii) then
  begin
    // converter
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
    Context.FCallbacks.Converter := Converter;

    // conversion
    Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf16_lower;
    if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      PByteCharArray(Context.Destination)[Context.DestinationWritten] := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii} utf8_from_utf16_lower(Pointer(Dest), Context.Source, L);
  end;
end;

procedure UTF16String.ToUpperAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PTextConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TTextConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  if (not Self.Ascii) then
  begin
    // converter
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
    Context.FCallbacks.Converter := Converter;

    // conversion
    Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf16_upper;
    if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      PByteCharArray(Context.Destination)[Context.DestinationWritten] := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii} utf8_from_utf16_upper(Pointer(Dest), Context.Source, L);
  end;
end;

procedure UTF16String.ToUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Dest := AStrReserve(S, L * 3);
    Pointer(S) := Dest;
    AStrSetLength(S, Tiny.Text.utf8_from_utf16(Dest, Src, L), CODEPAGE_UTF8);
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, CODEPAGE_UTF8);
    utf8_from_utf16(Dest, Src, L)
  end;
end;

procedure UTF16String.ToLowerUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Dest := AStrReserve(S, L * 3);
    Pointer(S) := Dest;
    AStrSetLength(S, Tiny.Text.utf8_from_utf16_lower(Dest, Src, L), CODEPAGE_UTF8);
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, CODEPAGE_UTF8);
    utf8_from_utf16_lower(Dest, Src, L)
  end;
end;

procedure UTF16String.ToUpperUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Dest := AStrReserve(S, L * 3);
    Pointer(S) := Dest;
    AStrSetLength(S, Tiny.Text.utf8_from_utf16_upper(Dest, Src, L), CODEPAGE_UTF8);
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, CODEPAGE_UTF8);
    utf8_from_utf16_upper(Dest, Src, L)
  end;
end;

procedure UTF16String.ToUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest, Src: PByte;
  Context: TTextConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    Context.Source := Src;
    Context.SourceSize := L + L;

    // conversion
    Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf16;
    if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      PByteCharArray(Context.Destination)[Context.DestinationWritten] := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    utf8_from_utf16(Pointer(Dest), Pointer(Src), L)
  end;
end;

procedure UTF16String.ToLowerUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest, Src: PByte;
  Context: TTextConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    Context.Source := Src;
    Context.SourceSize := L + L;

    // conversion
    Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf16_lower;
    if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      PByteCharArray(Context.Destination)[Context.DestinationWritten] := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    utf8_from_utf16_lower(Pointer(Dest), Pointer(Src), L)
  end;
end;

procedure UTF16String.ToUpperUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest, Src: PByte;
  Context: TTextConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    Context.Source := Src;
    Context.SourceSize := L + L;

    // conversion
    Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf16_upper;
    if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      PByteCharArray(Context.Destination)[Context.DestinationWritten] := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    utf8_from_utf16_upper(Pointer(Dest), Pointer(Src), L)
  end;
end;

procedure UTF16String.ToWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WStrClear(S);
    Exit;
  end;

  Src := Self.Chars;
  Dest := WStrInit(S, nil, L);
  TinyMove(Src^, Dest^, L + L);
end;

procedure UTF16String.ToLowerWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WStrClear(S);
    Exit;
  end;

  Src := Self.Chars;
  Dest := WStrInit(S, nil, L);
  utf16_from_utf16_lower(Dest, Src, L);
end;

procedure UTF16String.ToUpperWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WStrClear(S);
    Exit;
  end;

  Src := Self.Chars;
  Dest := WStrInit(S, nil, L);
  utf16_from_utf16_upper(Dest, Src, L);
end;

procedure UTF16String.ToUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    UStrClear(S);
    Exit;
  end;

  Src := Self.Chars;
  Dest := UStrInit(S, nil, L);
  TinyMove(Src^, Dest^, L + L);
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToWideString
end;
{$endif}

procedure UTF16String.ToLowerUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    UStrClear(S);
    Exit;
  end;

  Src := Self.Chars;
  Dest := UStrInit(S, nil, L);
  utf16_from_utf16_lower(Dest, Src, L);
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToLowerWideString
end;
{$endif}

procedure UTF16String.ToUpperUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    UStrClear(S);
    Exit;
  end;

  Src := Self.Chars;
  Dest := UStrInit(S, nil, L);
  utf16_from_utf16_upper(Dest, Src, L);
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToUpperWideString
end;
{$endif}

procedure UTF16String.ToString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUnicodeString(S);
  {$else}
     ToAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToAnsiString
end;
{$ifend}

procedure UTF16String.ToLowerString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToLowerUnicodeString(S);
  {$else}
     ToLowerAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToLowerAnsiString
end;
{$ifend}

procedure UTF16String.ToUpperString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUpperUnicodeString(S);
  {$else}
     ToUpperAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToUpperAnsiString
end;
{$ifend}

function UTF16String.ToAnsiString: AnsiString;
{$ifNdef CPUINTELASM}
begin
  ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

function UTF16String.ToLowerAnsiString: AnsiString;
{$ifNdef CPUINTELASM}
begin
  ToLowerAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToLowerAnsiString
end;
{$endif}

function UTF16String.ToUpperAnsiString: AnsiString;
{$ifNdef CPUINTELASM}
begin
  ToUpperAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToUpperAnsiString
end;
{$endif}

function UTF16String.ToUTF8String: UTF8String;
{$ifNdef CPUINTELASM}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUTF8String
end;
{$endif}

function UTF16String.ToLowerUTF8String: UTF8String;
{$ifNdef CPUINTELASM}
begin
  ToLowerUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToLowerUTF8String
end;
{$endif}

function UTF16String.ToUpperUTF8String: UTF8String;
{$ifNdef CPUINTELASM}
begin
  ToUpperUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUpperUTF8String
end;
{$endif}

function UTF16String.ToWideString: WideString;
{$ifNdef CPUINTELASM}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToWideString
end;
{$endif}

function UTF16String.ToLowerWideString: WideString;
{$ifNdef CPUINTELASM}
begin
  ToLowerWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToLowerWideString
end;
{$endif}

function UTF16String.ToUpperWideString: WideString;
{$ifNdef CPUINTELASM}
begin
  ToUpperWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUpperWideString
end;
{$endif}

function UTF16String.ToUnicodeString: UnicodeString;
{$ifNdef CPUINTELASM}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    jmp ToWideString
  {$endif}
end;
{$endif}

function UTF16String.ToLowerUnicodeString: UnicodeString;
{$ifNdef CPUINTELASM}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    jmp ToLowerWideString
  {$endif}
end;
{$endif}

function UTF16String.ToUpperUnicodeString: UnicodeString;
{$ifNdef CPUINTELASM}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    jmp ToUpperWideString
  {$endif}
end;
{$endif}

function UTF16String.ToString: string;
{$ifNdef CPUINTELASM}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToAnsiString
  {$endif}
end;
{$endif}

function UTF16String.ToLowerString: string;
{$ifNdef CPUINTELASM}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToLowerAnsiString
  {$endif}
end;
{$endif}

function UTF16String.ToUpperString: string;
{$ifNdef CPUINTELASM}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToUpperAnsiString
  {$endif}
end;
{$endif}

{$ifdef OPERATORSUPPORT}
class operator UTF16String.Implicit(const a: UTF16String): AnsiString;
{$ifNdef CPUINTELASM}
begin
  a.ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

class operator UTF16String.Implicit(const a: UTF16String): WideString;
{$ifNdef CPUINTELASM}
begin
  a.ToWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToWideString
end;
{$endif}

{$ifdef UNICODE}
class operator UTF16String.Implicit(const a: UTF16String): UTF8String;
{$ifNdef CPUINTELASM}
begin
  a.ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUTF8String
end;
{$endif}

class operator UTF16String.Implicit(const a: UTF16String): UnicodeString;
{$ifNdef CPUINTELASM}
begin
  a.ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUnicodeString
end;
{$endif}
{$endif}
{$endif}

function UTF16String._CompareUTF16String(const S: PUTF16String; const IgnoreCase: Boolean): NativeInt;
var
  L1, L2: NativeUInt;
begin
  L1 := Self.FLength;
  L2 := S.FLength;

  if (L1 <= L2) then
  begin
    L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
  end else
  begin
    L1 := L2;
    L2 := NativeUInt(-1);
  end;

  if (not IgnoreCase) then
  begin
    L1 := __textconv_compare_words(Pointer(Self.FChars), Pointer(S.FChars), L1);
  end else
  begin
    L1 := __textconv_utf16_compare_utf16(Pointer(Self.FChars), Pointer(S.FChars), L1);
  end;

  Result := L1 * 2 - L2;
end;

{inline} function UTF16String.Equal(const S: UTF16String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (S.Length <> 0) and (Self.Length = S.Length) then
  begin
    Y := PWord(Self.Chars)^;
    X := PWord(S.Chars)^;
    if (X = Y) then
    begin
      Ret := Self._CompareUTF16String(@S, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = S.Length);
end;

{inline} function UTF16String.EqualIgnoreCase(const S: UTF16String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (S.Length <> 0) and (Self.Length = S.Length) then
  begin
    Y := PWord(Self.Chars)^;
    X := PWord(S.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) then
    begin
      Ret := Self._CompareUTF16String(@S, True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = S.Length);
end;

{inline} function UTF16String.Compare(const S: UTF16String): NativeInt;
var
  X, Y: NativeUInt;
begin
  if (Self.Length <> 0) and (S.Length <> 0) then
  begin
    Y := PWord(Self.Chars)^;
    X := PWord(S.Chars)^;
    if (X = Y) then
    begin
      Result := Self._CompareUTF16String(@S, False);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(S.Length));
end;

{inline} function UTF16String.CompareIgnoreCase(const S: UTF16String): NativeInt;
var
  X, Y: NativeUInt;
begin
  if (Self.Length <> 0) and (S.Length <> 0) then
  begin
    Y := PWord(Self.Chars)^;
    X := PWord(S.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) then
    begin
      Result := Self._CompareUTF16String(@S, True);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(S.Length));
end;

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.Equal(const a: UTF16String; const b: UTF16String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (b.Length <> 0) and (a.Length = b.Length) then
  begin
    Y := PWord(a.Chars)^;
    X := PWord(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(@b, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := (a.Length = b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.NotEqual(const a: UTF16String; const b: UTF16String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (b.Length <> 0) and (a.Length = b.Length) then
  begin
    Y := PWord(a.Chars)^;
    X := PWord(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(@b, False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := (a.Length <> b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.GreaterThan(const a: UTF16String; const b: UTF16String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PWord(a.Chars)^;
    X := PWord(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(@b, False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.GreaterThanOrEqual(const a: UTF16String; const b: UTF16String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PWord(a.Chars)^;
    X := PWord(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(@b, False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.LessThan(const a: UTF16String; const b: UTF16String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PWord(a.Chars)^;
    X := PWord(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(@b, False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.LessThanOrEqual(const a: UTF16String; const b: UTF16String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PWord(a.Chars)^;
    X := PWord(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(@b, False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= b.Length);
end;
{$endif}

{inline} function UTF16String.Equal(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Pointer(Self.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (Self.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@Self, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF16String.EqualIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Pointer(Self.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (Self.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PByte(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@Self, True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF16String.Compare(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Result := PByteString(@Buffer)._CompareUTF16String(@Self, False);
      Result := -Result;
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{inline} function UTF16String.CompareIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PByte(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Result := PByteString(@Buffer)._CompareUTF16String(@Self, True);
      Result := -Result;
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.Equal(const a: UTF16String; const b: AnsiString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (Pointer(a.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (a.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.Equal(const a: AnsiString; const b: UTF16String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (Pointer(b.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (b.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.NotEqual(const a: UTF16String; const b: AnsiString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (Pointer(a.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (a.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.NotEqual(const a: AnsiString; const b: UTF16String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (Pointer(b.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (b.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.GreaterThan(const a: UTF16String; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.GreaterThan(const a: AnsiString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      Result := (X > Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.GreaterThanOrEqual(const a: UTF16String; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.GreaterThanOrEqual(const a: AnsiString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      Result := (X >= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.LessThan(const a: UTF16String; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.LessThan(const a: AnsiString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      Result := (X < Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.LessThanOrEqual(const a: UTF16String; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.LessThanOrEqual(const a: AnsiString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      Result := (X <= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

{inline} function UTF16String.{$ifdef UNICODE}Equal{$else}EqualUTF8{$endif}(const S: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := Self.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 3;
      if (X < Y) then goto ret_non_equal;
      Ret := PByteString(@Buffer)._CompareUTF16String(@Self, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF16String.{$ifdef UNICODE}EqualIgnoreCase{$else}EqualUTF8IgnoreCase{$endif}(const S: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PByte(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := Self.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 3;
      if (X < Y) then goto ret_non_equal;
      Ret := PByteString(@Buffer)._CompareUTF16String(@Self, True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF16String.{$ifdef UNICODE}Compare{$else}CompareUTF8{$endif}(const S: UTF8String): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Result := PByteString(@Buffer)._CompareUTF16String(@Self, False);
      Result := -Result;
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PWord(Self.Chars)^;
      {$endif}
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{inline} function UTF16String.{$ifdef UNICODE}CompareIgnoreCase{$else}CompareUTF8IgnoreCase{$endif}(const S: UTF8String): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PByte(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Result := PByteString(@Buffer)._CompareUTF16String(@Self, True);
      Result := -Result;
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{$ifdef UNICODE}
{inline} class operator UTF16String.Equal(const a: UTF16String; const b: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := a.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 3;
      if (X < Y) then goto ret_non_equal;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.Equal(const a: UTF8String; const b: UTF16String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := b.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 3;
      if (X < Y) then goto ret_non_equal;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.NotEqual(const a: UTF16String; const b: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := a.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 3;
      if (X < Y) then goto ret_non_equal;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.NotEqual(const a: UTF8String; const b: UTF16String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := b.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 3;
      if (X < Y) then goto ret_non_equal;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.GreaterThan(const a: UTF16String; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PWord(a.Chars)^;
      {$endif}
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.GreaterThan(const a: UTF8String; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PWord(b.Chars)^;
      {$endif}
      Result := (X > Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.GreaterThanOrEqual(const a: UTF16String; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PWord(a.Chars)^;
      {$endif}
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.GreaterThanOrEqual(const a: UTF8String; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PWord(b.Chars)^;
      {$endif}
      Result := (X >= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.LessThan(const a: UTF16String; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PWord(a.Chars)^;
      {$endif}
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.LessThan(const a: UTF8String; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PWord(b.Chars)^;
      {$endif}
      Result := (X < Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.LessThanOrEqual(const a: UTF16String; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := PByteString(@Buffer)._CompareUTF16String(@a, False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PWord(a.Chars)^;
      {$endif}
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.LessThanOrEqual(const a: UTF8String; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := PByteString(@Buffer)._CompareUTF16String(@b, False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PWord(b.Chars)^;
      {$endif}
      Result := (X <= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

{inline} function UTF16String.Equal(const S: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Pointer(Self.Length) <> nil) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      if (Self.Length <> L) then goto ret_non_equal;
      Buffer.Length := L;

      Y := PWord(Self.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := Self._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF16String.EqualIgnoreCase(const S: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Pointer(Self.Length) <> nil) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      if (Self.Length <> L) then goto ret_non_equal;
      Buffer.Length := L;

      Y := PWord(Self.Chars)^;
      X := PWord(P)^;
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
      if (X = Y) then
      begin
        Ret := Self._CompareUTF16String(PUTF16String(@Buffer), True);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF16String.Compare(const S: WideString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Self.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := L + 1;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PWord(Self.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Result := Self._CompareUTF16String(PUTF16String(@Buffer), False);
        Exit;
      end else
      begin
        Result := (NativeInt(Y) - NativeInt(X));
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{inline} function UTF16String.CompareIgnoreCase(const S: WideString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Self.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := L + 1;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PWord(Self.Chars)^;
      X := PWord(P)^;
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
      if (X = Y) then
      begin
        Result := Self._CompareUTF16String(PUTF16String(@Buffer), True);
        Exit;
      end else
      begin
        Result := (NativeInt(Y) - NativeInt(X));
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.Equal(const a: UTF16String; const b: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (Pointer(a.Length) <> nil) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      if (a.Length <> L) then goto ret_non_equal;
      Buffer.Length := L;

      Y := PWord(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.Equal(const a: WideString; const b: UTF16String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (Pointer(b.Length) <> nil) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      if (b.Length <> L) then goto ret_non_equal;
      Buffer.Length := L;

      Y := PWord(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.NotEqual(const a: UTF16String; const b: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (Pointer(a.Length) <> nil) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      if (a.Length <> L) then goto ret_non_equal;
      Buffer.Length := L;

      Y := PWord(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <> 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := True;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.NotEqual(const a: WideString; const b: UTF16String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (Pointer(b.Length) <> nil) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      if (b.Length <> L) then goto ret_non_equal;
      Buffer.Length := L;

      Y := PWord(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <> 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := True;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.GreaterThan(const a: UTF16String; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PWord(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret > 0);
        Exit;
      end else
      begin
        Result := (Y > X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.GreaterThan(const a: WideString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PWord(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret < 0);
        Exit;
      end else
      begin
        Result := (X > Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.GreaterThanOrEqual(const a: UTF16String; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PWord(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret >= 0);
        Exit;
      end else
      begin
        Result := (Y >= X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.GreaterThanOrEqual(const a: WideString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PWord(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <= 0);
        Exit;
      end else
      begin
        Result := (X >= Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.LessThan(const a: UTF16String; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PWord(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret < 0);
        Exit;
      end else
      begin
        Result := (Y < X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.LessThan(const a: WideString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PWord(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret > 0);
        Exit;
      end else
      begin
        Result := (X < Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.LessThanOrEqual(const a: UTF16String; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PWord(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <= 0);
        Exit;
      end else
      begin
        Result := (Y <= X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF16String.LessThanOrEqual(const a: WideString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PWord(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret >= 0);
        Exit;
      end else
      begin
        Result := (X <= Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} function UTF16String.Equal(const S: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Pointer(Self.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    if (Self.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} function UTF16String.EqualIgnoreCase(const S: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Pointer(Self.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    if (Self.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PWord(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) then
    begin
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} function UTF16String.Compare(const S: UnicodeString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} function UTF16String.CompareIgnoreCase(const S: UnicodeString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(Self.Chars)^;
    X := PWord(P)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.Equal(const a: UTF16String; const b: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (Pointer(a.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    if (a.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.Equal(const a: UnicodeString; const b: UTF16String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (Pointer(b.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    if (b.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.NotEqual(const a: UTF16String; const b: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (Pointer(a.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    if (a.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.NotEqual(const a: UnicodeString; const b: UTF16String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (Pointer(b.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    if (b.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.GreaterThan(const a: UTF16String; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.GreaterThan(const a: UnicodeString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      Result := (X > Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.GreaterThanOrEqual(const a: UTF16String; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.GreaterThanOrEqual(const a: UnicodeString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      Result := (X >= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.LessThan(const a: UTF16String; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.LessThan(const a: UnicodeString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      Result := (X < Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.LessThanOrEqual(const a: UTF16String; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF16String.LessThanOrEqual(const a: UnicodeString; const b: UTF16String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PWord(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      Result := (X <= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

function UTF16String.Equal(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PWord(Self.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;
        X := Self.Length;
        Y := Buffer.Length;
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;
        if (Self.Length <> Buffer.Length) then goto ret_non_equal;
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@Self, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

function UTF16String.EqualIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PWord(Self.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;
        X := Self.Length;
        Y := Buffer.Length;
        if (X > Y) then goto ret_non_equal;
        X := X * 3;
        if (X < Y) then goto ret_non_equal;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;
        if (Self.Length <> Buffer.Length) then goto ret_non_equal;
      end;
      Ret := PByteString(@Buffer)._CompareUTF16String(@Self, True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

function UTF16String.Compare(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt;
var
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PWord(Self.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;
      end;
      Result := PByteString(@Buffer)._CompareUTF16String(@Self, False);
      Result := -Result;
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;

function UTF16String.CompareIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt;
var
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PWord(Self.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;
      end;
      Result := PByteString(@Buffer)._CompareUTF16String(@Self, True);
      Result := -Result;
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;

{inline} function UTF16String.Equal(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  if (ALength <> 0) and (Self.Length = ALength) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PWord(Self.Chars)^;
    if (X = Y) then
    begin
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

{inline} function UTF16String.EqualIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  if (ALength <> 0) and (Self.Length = ALength) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PWord(Self.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) then
    begin
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

{inline} function UTF16String.Compare(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt;
var
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PWord(Self.Chars)^;
    if (X = Y) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;

{inline} function UTF16String.CompareIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt;
var
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PWord(Self.Chars)^;
    X := TEXTCONV_CHARCASE.VALUES[X];
    Y := TEXTCONV_CHARCASE.VALUES[Y];
    if (X = Y) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Exit;
    end else
    begin
      Result := (NativeInt(Y) - NativeInt(X));
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;

{ UTF32String }

function UTF32String.GetEmpty: Boolean;
begin
  Result := (Length <> 0);
end;

procedure UTF32String.SetEmpty(Value: Boolean);
var
  V: NativeUInt;
begin
  if (Value) then
  begin
    V := 0;
    FLength := V;
    F.NativeFlags := V;
  end;
end;

procedure UTF32String.Assign(const AChars: PUCS4Char; const ALength: NativeUInt);
begin
  Self.FChars := AChars;
  Self.FLength := ALength;
  Self.F.NativeFlags := 0;
end;

procedure UTF32String.Assign(const S: UCS4String; const NullTerminated: Boolean);
var
  P: PNativeInt;
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  if (P = nil) then
  begin
    Pointer(Self.FLength) := P{0};
    Pointer(Self.F.NativeFlags) := P{0};
  end else
  begin
    Dec(P);
    Self.FLength := P^ - Ord(NullTerminated) {$ifdef FPC}+ 1{$endif};
    Self.F.NativeFlags := 0;
  end;
end;

procedure UTF32String.Delete(const From, Count: NativeUInt);
var
  L: NativeUInt;
  S: PUTF32CharArray;
begin
  L := Length;
  if (From < L) and (Count <> 0) then
  begin
    Dec(L, From);
    if (L <= Count) then
    begin
      Length := From;
    end else
    begin
      Inc(L, From);
      Dec(L, Count);
      Length := L;
      Dec(L, From);

      S := Pointer(Self.FChars);
      L := L shl 2;
      TinyMove(S[From + Count], S[From], L);
    end;
  end;
end;

function UTF32String.DetermineAscii: Boolean;
label
  fail;
var
  P: PCardinal;
  L: NativeUInt;
  {$ifdef LARGEINT}
  MASK: NativeUInt;
  {$endif}
begin
  P := Pointer(FChars);

  {$ifdef LARGEINT}
  MASK := not NativeUInt($7f0000007f);
  L := FLength;
  while (L > 1) do
  begin
    if (PNativeUInt(P)^ and MASK <> 0) then goto fail;
    Dec(L, 2);
    Inc(P, 2);
  end;
  if (L and 1 <> 0) and (P^ > $7f) then goto fail;
  {$else}
  for L := 1 to FLength do
  begin
    if (P^ > $7f) then goto fail;
    Inc(P);
  end;
  {$endif}

  Ascii := True;
  Result := True;
  Exit;
fail:
  Ascii := False;
  Result := False;
end;

function UTF32String.TrimLeft: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PCardinal;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  if (S^ > 32) then
  begin
    Result := True;
    Exit;
  end else
  begin
    Result := _TrimLeft(S, L);
  end;
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  test ecx, ecx
  jnz @1
  xor eax, eax
  ret
@1:
  cmp dword ptr [edx], 32
  jbe _TrimLeft
  mov al, 1
end;
{$ifend}

function UTF32String._TrimLeft(S: PCardinal; L: NativeUInt): Boolean;
label
  fail;
var
  TopS: PCardinal;
begin
  TopS := @PUTF32CharArray(S)[L];

  repeat
    Inc(S);
    if (S = TopS) then goto fail;
  until (S^ > 32);

  FChars := Pointer(S);
  Dec(NativeUInt(TopS), NativeUInt(S));
  FLength := NativeUInt(TopS) shr 2;
  Result := True;
  Exit;
fail:
  L := 0;
  FLength := L{0};
  Result := False;
end;

function UTF32String.TrimRight: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PCardinal;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PUTF32CharArray(S)[L] > 32) then
    begin
      Result := True;
      Exit;
    end else
    begin
      Result := _TrimRight(S, L);
    end;
  end;
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:
  cmp dword ptr [edx + ecx*4], 32
  jbe _TrimRight
  mov al, 1
end;
{$ifend}

function UTF32String._TrimRight(S: PCardinal; H: NativeUInt): Boolean;
label
  fail;
var
  TopS: PCardinal;
begin
  TopS := @PUTF32CharArray(S)[H];

  Dec(S);
  repeat
    Dec(TopS);
    if (S = TopS) then goto fail;
  until (TopS^ > 32);

  Dec(NativeUInt(TopS), NativeUInt(S));
  FLength := NativeUInt(TopS) shr 2;
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};
  Result := False;
end;

function UTF32String.Trim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PCardinal;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PUTF32CharArray(S)[L] > 32) then
    begin
      // TrimLeft or True
      if (S^ > 32) then
      begin
        Result := True;
        Exit;
      end else
      begin
        Result := _TrimLeft(S, L+1);
        Exit;
      end;
    end else
    begin
      // TrimRight or Trim
      if (S^ > 32) then
      begin
        Result := _TrimRight(S, L);
        Exit;
      end else
      begin
        Result := _Trim(S, L);
      end;
    end;
  end;
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:
  cmp dword ptr [edx + ecx*4], 32
  jbe @2
  // TrimLeft or True
  inc ecx
  cmp dword ptr [edx], 32
  jbe _TrimLeft
  mov al, 1
  ret
@2:
  // TrimRight or Trim
  cmp dword ptr [edx], 32
  ja _TrimRight
  jmp _Trim
end;
{$ifend}

function UTF32String._Trim(S: PCardinal; H: NativeUInt): Boolean;
label
  fail;
var
  TopS: PCardinal;
begin
  if (H = 0) then goto fail;
  TopS := @PUTF32CharArray(S)[H];

  // TrimLeft
  repeat
    Inc(S);
    if (S = TopS) then goto fail;
  until (S^ > 32);
  FChars := Pointer(S);

  // TrimRight
  Dec(S);
  repeat
    Dec(TopS);
  until (TopS^ > 32);

  // Result
  Dec(NativeUInt(TopS), NativeUInt(S));
  FLength := NativeUInt(TopS) shr 2;
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};
  Result := False;
end;

function UTF32String.SubString(const From, Count: NativeUInt): UTF32String;
var
  L: NativeUInt;
begin
  Result.F.NativeFlags := Self.F.NativeFlags;
  Result.FChars := Pointer(@PUTF32CharArray(Self.FChars)[From]);

  L := Self.FLength;
  Dec(L, From);
  if (NativeInt(L) <= 0) then
  begin
    Result.FLength := 0;
    Exit;
  end;

  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function UTF32String.SubString(const Count: NativeUInt): UTF32String;
var
  L: NativeUInt;
begin
  Result.FChars := Self.FChars;
  Result.F.NativeFlags := Self.F.NativeFlags;
  L := Self.FLength;
  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function UTF32String.Skip(const Count: NativeUInt): Boolean;
var
  L: NativeUInt;
begin
  L := FLength;
  if (L <= Count) then
  begin
    FChars := Pointer(@PUTF32CharArray(FChars)[L]);
    FLength := 0;
    Result := False;
  end else
  begin
    Dec(L, Count);
    FLength := L;
    FChars := Pointer(@PUTF32CharArray(FChars)[Count]);
    Result := True;
  end;
end;

function UTF32String.Hash: Cardinal;
var
  L, L_High: NativeUInt;
  P: PCardinal;
  V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := L shl (32-9);
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  repeat
    // Result := (Result shr 5) xor (P^ + Result);
    // Dec(L);/Inc(P);
    V := Result shr 5;
    Dec(L);
    Inc(Result, P^);
    Inc(P);
    Result := Result xor V;
  until (L = 0);

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function UTF32String.HashIgnoreCase: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  if (Self.Ascii) then Result := _HashIgnoreCaseAscii
  else Result := _HashIgnoreCase;
end;
{$else .CPUX86.DELPHI}
asm
  cmp byte ptr [EAX].F.Ascii, 0
  jnz _HashIgnoreCaseAscii
  jmp _HashIgnoreCase
end;
{$ifend}

function UTF32String._HashIgnoreCaseAscii: Cardinal;
var
  L, L_High: NativeUInt;
  P: PCardinal;
  X, V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := L shl (32-9);
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := P^;
    X := X or ((X and $40) shr 1);
    Dec(L);
    V := Result shr 5;
    Inc(Result, X);
    Inc(P);
    Result := Result xor V;
  until (L = 0);

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function UTF32String._HashIgnoreCase: Cardinal;
var
  L: NativeUInt;
  P: PCardinal;
  X, V: Cardinal;
  {$ifdef CPUX86}
  S: record
    L_High: NativeUInt;
  end;
  {$else}
  L_High: NativeUInt;
  {$endif}
  lookup_utf16_lower: PTextConvWW;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  lookup_utf16_lower := Pointer(@TEXTCONV_CHARCASE.LOWER);
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := P^;
    Dec(L);
    if (X > $7f) then
    begin
      if (X <= High(Word)) then
        X := lookup_utf16_lower[X];
    end else
    begin
      X := X or ((X and $40) shr 1);
    end;

    V := Result shr 5;
    Inc(Result, X);
    Inc(P);
    Result := Result xor V;
  until (L = 0);

  Result := (Result and (-1 shr 9)) + ({$ifdef CPUX86}S.{$endif}L_High);
end;

function UTF32String.CharPos(const C: UCS4Char; const From: NativeUInt): NativeInt;
label
  failure, found;
var
  P, Top: PCardinal;
  StoredChars: PCardinal;
begin
  P := Pointer(FChars);
  Top := Pointer(@PUTF32CharArray(P)[FLength]);
  StoredChars := P;
  Inc(P, From);
  if (Self.Ascii > (Ord(C) <= $7f)) then goto failure;

  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    if (P^ = C) then goto found;
    Inc(P);
  end;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
  Result := Result shr 2;
end;

function UTF32String.CharPosIgnoreCase(const C: UCS4Char;
  const From: NativeUInt): NativeInt;
label
  failure, found;
var
  X, LowerChar, UpperChar: NativeInt;
  P, Top: PCardinal;
  StoredChars: PCardinal;
begin
  P := Pointer(FChars);
  Top := Pointer(@PUTF32CharArray(P)[FLength]);
  StoredChars := P;
  Inc(P, From);
  if (Self.Ascii > (Ord(C) <= $7f)) then goto failure;

  LowerChar := Ord(C);
  UpperChar := LowerChar;
  if (LowerChar <= $ffff) then
  begin
    LowerChar := TEXTCONV_CHARCASE.VALUES[LowerChar];
    UpperChar := TEXTCONV_CHARCASE.VALUES[UpperChar + $10000];
  end;

  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = LowerChar) then goto found;
    if (X = UpperChar) then goto found;
    Inc(P);
  end;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
  Result := Result shr 2;
end;

function utf32_compare_utf32(S1, S2: PCardinal; L: NativeUInt): NativeInt;
label
  make_result;
var
  X, Y, i: NativeUInt;
begin
  for i := 1 to L do
  begin
    X := S1^;
    Y := S2^;
    Inc(S1);
    Inc(S2);
    if (X <> Y) then goto make_result;
  end;

  Result := 0;
  Exit;

  // warnings off
  X := 0;
  Y := 0;

make_result:
  Result := Ord(X > Y)*2 - 1;
end;

function UTF32String.Pos(const S: UTF32String; const From: NativeUInt): NativeInt;
label
  next_iteration, failure, char_found;
type
  TChar = Cardinal;
  PChar = ^TChar;
  TCharArray = TUTF32CharArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(TChar);
  CHARS_IN_CARDINAL = SizeOf(CARDINAL) div SizeOf(TChar);
var
  L, X: NativeUInt;
  P, Top: PChar;
  P1, P2: PChar;
  Store: record
    StrLength: NativeUInt;
    StrChars: Pointer;
    SelfChars: Pointer;
    X: NativeUInt;
  end;
begin
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPos(PUCS4Char(Store.StrChars)^, From);
    Exit;
  end;
  Store.StrLength := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  Top := Pointer(@PCharArray(P)[Self.FLength -L + 1]);
  Inc(P, From);

  X := PChar(Store.StrChars)^;
  if (Self.Ascii > (X <= $7f)) then goto failure;
  Store.X := X;

  repeat
  next_iteration:
    X := Store.X;
    if (NativeUInt(P) < NativeUInt(Top)) then
    repeat
      if (P^ = TChar(X)) then goto char_found;
      Inc(P);
    until (NativeUInt(P) = NativeUInt(Top));
    Break;

  char_found:
    Inc(P);
    L := Store.StrLength - 1;
    P2 := Store.StrChars;
    P1 := P;
    Inc(P2);
    if (L >= CHARS_IN_NATIVE) then
    repeat
      if (PNativeUInt(P1)^ <> PNativeUInt(P2)^) then goto next_iteration;
      Dec(L, CHARS_IN_NATIVE);
      Inc(P1, CHARS_IN_NATIVE);
      Inc(P2, CHARS_IN_NATIVE);
    until (L < CHARS_IN_NATIVE);
    {$ifdef LARGEINT}
    if (L >= CHARS_IN_CARDINAL{1}) then
    begin
      if (PCardinal(P1)^ <> PCardinal(P2)^) then goto next_iteration;
    end;
    {$endif}

    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Result := Result shr 2;
    Exit;
  until (False);

failure:
  Result := -1;
end;

function UTF32String.Pos(const AChars: PUCS4Char; const ALength: NativeUInt;
  const From: NativeUInt): NativeInt;
var
  Buffer: PtrString;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  Result := Self.Pos(PUTF32String(@Buffer)^, From);
end;

function UTF32String.Pos(const S: UCS4String; const From: NativeUInt): NativeInt;
var
  L: NativeUInt;
  Buffer: PtrString;
begin
  L := NativeUInt(Pointer(S));
  if (L = 0{nil}) then
  begin
    Result := -1;
  end else
  begin
    Buffer.Chars := Pointer(S);
    Dec(L, SizeOf(NativeUInt));
    L := PNativeUInt(L)^;
    {$ifNdef FPC}Dec(L);{$endif}
    Inc(L, Byte(S[L] <> 0));
    Buffer.Length := L;
    Result := Self.Pos(PUTF32String(@Buffer)^, From);
  end;
end;

function utf32_compare_utf32_ignorecase(S1, S2: PCardinal; L: NativeUInt): NativeInt;
label
  make_result;
var
  X, Y: NativeUInt;
  CaseLookup: PTextConvWW;
begin
  CaseLookup := Pointer(@TEXTCONV_CHARCASE.LOWER);

  repeat
    if (L = 0) then Break;
    X := S1^;
    Y := S2^;
    Dec(L);
    Inc(S1);
    Inc(S2);

    if (X = Y) then Continue;
    if (X or Y > $ffff) then goto make_result;
    X := CaseLookup[X];
    Y := CaseLookup[Y];
    if (X <> Y) then goto make_result;
  until (False);

  Result := 0;
  Exit;

  // warnings off
  X := 0;
  Y := 0;

make_result:
  Result := Ord(X > Y)*2 - 1;
end;

function UTF32String.PosIgnoreCase(const S: UTF32String;
  const From: NativeUInt): NativeInt;
label
  failure, char_found;
type
  TChar = Cardinal;
  PChar = ^TChar;
  TCharArray = TUTF32CharArray;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
  X, LowerChar, UpperChar: NativeInt;
  P, Top: PChar;
  Store: record
    StrLength: NativeUInt;
    StrChars: Pointer;
    SelfChars: Pointer;
    SelfCharsTop: Pointer;
    Top: Pointer;
    UpperChar: NativeInt;
  end;
begin
  UpperChar := From{store};
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPosIgnoreCase(PUCS4Char(Store.StrChars)^, UpperChar{From});
    Exit;
  end;
  Store.StrLength := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  Store.SelfCharsTop := Pointer(@PCharArray(P)[Self.FLength]);
  Top := Pointer(@PCharArray(Store.SelfCharsTop)[-L + 1]);
  Inc(P, UpperChar{From});

  LowerChar := PChar(Store.StrChars)^;
  if (Self.Ascii > (LowerChar <= $7f)) then goto failure;
  UpperChar := LowerChar;
  if (LowerChar <= $ffff) then
  begin
    LowerChar := TEXTCONV_CHARCASE.VALUES[LowerChar];
    UpperChar := TEXTCONV_CHARCASE.VALUES[UpperChar + $10000];
  end;

  repeat
    while (NativeUInt(P) < NativeUInt(Top)) do
    begin
      X := P^;
      if (X = LowerChar) then goto char_found;
      if (X = UpperChar) then goto char_found;
      Inc(P);
    end;
    Break;

  char_found:
    Store.Top := Top;
    Store.UpperChar := UpperChar;
      X := utf32_compare_utf32_ignorecase(Pointer(P), Store.StrChars, Store.StrLength);
    UpperChar := Store.UpperChar;
    Top := Store.Top;
    Inc(P);
    if (X <> 0) then Continue;
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Result := Result shr 2;
    Exit;
  until (False);

failure:
  Result := -1;
end;

function UTF32String.PosIgnoreCase(const AChars: PUCS4Char;
  const ALength: NativeUInt; const From: NativeUInt): NativeInt;
var
  Buffer: PtrString;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  Result := Self.PosIgnoreCase(PUTF32String(@Buffer)^, From);
end;

function UTF32String.PosIgnoreCase(const S: UCS4String;
  const From: NativeUInt): NativeInt;
var
  L: NativeUInt;
  Buffer: PtrString;
begin
  L := NativeUInt(Pointer(S));
  if (L = 0{nil}) then
  begin
    Result := -1;
  end else
  begin
    Buffer.Chars := Pointer(S);
    Dec(L, SizeOf(NativeUInt));
    L := PNativeUInt(L)^;
    {$ifNdef FPC}Dec(L);{$endif}
    Inc(L, Byte(S[L] <> 0));
    Buffer.Length := L;
    Result := Self.PosIgnoreCase(PUTF32String(@Buffer)^, From);
  end;
end;

function UTF32String.TryToBoolean(out Value: Boolean): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetBool
  pop edx
  pop ecx
  mov [ecx], al
  xchg eax, edx
end;
{$ifend}

function UTF32String.ToBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PUTF32String(@Default)._GetBool(Pointer(Chars), Length);
end;

function UTF32String.ToBoolean: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetBool
end;
{$ifend}

function UTF32String._GetBool(S: PCardinal; L: NativeUInt): Boolean;
label
  fail;
var
  Marker: NativeInt;
  Buffer: ByteString;
begin
  Buffer.Chars := Pointer(S);
  Buffer.Length := L;

  // utf32 ascii, ignore case
  with PMemoryItems(Buffer.Chars)^ do
  case L of
    1: case (Cardinals[0]) of // "0", "1"
         $00000030:
         begin
           // "0"
           Result := False;
           Exit;
         end;
         $00000031:
         begin
           // "1"
           Result := True;
           Exit;
         end;
       end;
    2: if (Cardinals[0] or $00000020 = $0000006E) and
       (Cardinals[1] or $00000020 = $0000006F) then
    begin
      // "no"
      Result := False;
      Exit;
    end;
    3: if (Cardinals[0] or $00000020 = $00000079) and
       (Cardinals[1] or $00000020 = $00000065) and
       (Cardinals[2] or $00000020 = $00000073) then
    begin
      // "yes"
      Result := True;
      Exit;
    end;
    4: if (Cardinals[0] or $00000020 = $00000074) and
       (Cardinals[1] or $00000020 = $00000072) and
       (Cardinals[2] or $00000020 = $00000075) and
       (Cardinals[3] or $00000020 = $00000065) then
    begin
      // "true"
      Result := True;
      Exit;
    end;
    5: if (Cardinals[0] or $00000020 = $00000066) and
       (Cardinals[1] or $00000020 = $00000061) and
       (Cardinals[2] or $00000020 = $0000006C) and
       (Cardinals[3] or $00000020 = $00000073) and
       (Cardinals[4] or $00000020 = $00000065) then
    begin
      // "false"
      Result := False;
      Exit;
    end;
  end;

fail:
  Marker := NativeInt(@Self);
  if (Marker = 0) then
  begin
    Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidBoolean), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PBoolean(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
    Result := False;
  end;
end;

function UTF32String.TryToHex(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function UTF32String.ToHexDef(const Default: Integer): Integer;
begin
  Result := PUTF32String(@Default)._GetHex(Pointer(Chars), Length);
end;

function UTF32String.ToHex: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex
end;
{$ifend}

function UTF32String._GetHex(S: PCardinal; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: UTF32String;
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;
  Result := 0;

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      Result := Result shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      Result := Result shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(Result, X);
  until (L = 0);

  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function UTF32String.TryToCardinal(out Value: Cardinal): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function UTF32String.ToCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PUTF32String(@Default)._GetInt(Pointer(Chars), Length);
end;

function UTF32String.ToCardinal: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function UTF32String.TryToInteger(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function UTF32String.ToIntegerDef(const Default: Integer): Integer;
begin
  Result := PUTF32String(@Default)._GetInt(Pointer(Chars), -Length);
end;

function UTF32String.ToInteger: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function UTF32String._GetInt(S: PCardinal; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: UTF32String;
  HexRet: record
    Value: Integer;
  end;
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PUTF32String(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PUTF32String(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L >= 10{high(Result)}) then
  begin
    Dec(L);
    Marker := Marker or 2;
    if (L > 10-1) then goto fail;
  end;
  Result := 0;

  repeat
    X := NativeUInt(S^) - Ord('0');
    Result := Result * 10;
    Dec(L);
    Inc(Result, X);
    Inc(S);
    if (X >= 10) then goto fail;
  until (L = 0);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        case Cardinal(Result) of
          0..High(Cardinal) div 10 - 1: ;
          High(Cardinal) div 10:
          begin
            if (X > High(Cardinal) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end else
      begin
        case Cardinal(Result) of
          0..High(Integer) div 10 - 1: ;
          High(Integer) div 10:
          begin
            if (X > (NativeUInt(Marker) shr 2) + High(Integer) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end;

      Result := Result * 10;
      Inc(Result, X);
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function UTF32String.TryToHex64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function UTF32String.ToHex64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(@Default)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetHex64
end;
{$ifend}

function UTF32String.ToHex64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex64
end;
{$ifend}

function UTF32String._GetHex64(S: PCardinal; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: UTF32String;
  X: NativeUInt;
  R1, R2: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;

  R1 := 0;
  R2 := 0;

  if (L > 8) then
  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R2 := R2 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R2 := R2 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R2, X);
  until (L = 8);

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R1 := R1 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R1 := R1 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R1, X);
  until (L = 0);

  {$ifdef SMALLINT}
  with PPoint(@Result)^ do
  begin
    X := R1;
    Y := R2;
  end;
  {$else .LARGEINT}
  Result := (R2 shl 32) + R1;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function UTF32String.TryToUInt64(out Value: UInt64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function UTF32String.ToUInt64Def(const Default: UInt64): UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(@Default)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function UTF32String.ToUInt64: UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function UTF32String.TryToInt64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function UTF32String.ToInt64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(@Default)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function UTF32String.ToInt64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function UTF32String._GetInt64(S: PCardinal; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: UTF32String;
  HexRet: record
    Value: Integer;
  end;
  X: NativeUInt;
  Marker: NativeInt;
  R1, R2: Integer;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PUTF32String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PUTF32String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L <= 9) then
  begin
    R1 := PUTF32String(nil)._GetInt_19(S, L);
    if (R1 < 0) then goto fail;

    if (Marker and 4 <> 0) then R1 := -R1;
    Result := R1;
    Exit;
  end else
  if (L >= 19) then
  begin
    if (L = 19) then
    begin
      Marker := Marker or 2;
      Dec(L);
    end else
    if (L = 20) and (Marker and 1 = 0) then
    begin
      Marker := Marker or (2 or 4{TEN_BB});
      if (S^ <> $31{Ord('1')}) then goto fail;
      Dec(L, 2);
      Inc(S);
    end else
    goto fail;
  end;

  Dec(L, 9);
  R2 := PUTF32String(nil)._GetInt_19(S, L);
  Inc(S, L);
  if (R2 < 0) then goto fail;

  R1 := PUTF32String(nil)._GetInt_19(S, 9);
  Inc(S, 9);
  if (R1 < 0) then goto fail;

  Result := Decimal64R21(R2, R1);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        // UInt64
        if (Marker and 4 = 0) then
        begin
          Result := Decimal64VX(Result, X);
        end else
        begin
          if (Result >= _HIGHU64 div 10) then
          begin
            if (Result = _HIGHU64 div 10) then
            begin
              if (X > NativeUInt(_HIGHU64 mod 10)) then goto fail;
            end else
            begin
              goto fail;
            end;
          end;

          Result := Decimal64VX(Result, X);
          Inc(Result, TEN_BB);
        end;

        Exit;
      end else
      begin
        // Int64
        if (Result >= High(Int64) div 10) then
        begin
          if (Result = High(Int64) div 10) then
          begin
            if (X > (NativeUInt(Marker) shr 2) + NativeUInt(High(Int64) mod 10)) then goto fail;
          end else
          begin
            goto fail;
          end;
        end;

        Result := Decimal64VX(Result, X);
      end;
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function UTF32String._GetInt_19(S: PCardinal; L: NativeUInt): NativeInt;
label
  fail, _1, _2, _3, _4, _5, _6, _7, _8, _9;
var
  {$ifdef CPUX86}
  Store: record
    _R: PNativeInt;
    _S: PCardinal;
  end;
  {$else}
  _S: PCardinal;
  {$endif}
  _R: PNativeInt;
begin
  {$ifdef CPUX86}Store.{$endif}_R := Pointer(@Self);
  {$ifdef CPUX86}Store.{$endif}_S := S;

  Result := 0;
  case L of
    9:
    begin
    _9:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      if (L >= 10) then goto fail;
      Inc(Result, L);
      goto _8;
    end;
    8:
    begin
    _8:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _7;
    end;
    7:
    begin
    _7:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _6;
    end;
    6:
    begin
    _6:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _5;
    end;
    5:
    begin
    _5:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _4;
    end;
    4:
    begin
    _4:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _3;
    end;
    3:
    begin
    _3:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _2;
    end;
    2:
    begin
    _2:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _1;
    end
  else
  _1:
    L := NativeUInt(S^) - Ord('0');
    Inc(S);
    Result := Result * 2;
    if (L >= 10) then goto fail;
    Result := Result * 5;
    Inc(Result, L);
    Exit;
  end;

fail:
  {$ifdef CPUX86}
  _R := Store._R;
  {$endif}
  Result := Result shr 1;
  if (_R <> nil) then _R^ := Result;

  Result := NativeInt({$ifdef CPUX86}Store.{$endif}_S);
  Dec(Result, NativeInt(S));
  Result := (Result shr 2) or (Low(NativeInt) or (Low(NativeInt) shr 1));
end;

function UTF32String.TryToFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function UTF32String.TryToFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

{$if (not Defined(FPC)) or Defined(EXTENDEDSUPPORT)}
function UTF32String.TryToFloat(out Value: Extended): Boolean;
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;
{$ifend}

function UTF32String.ToFloatDef(const Default: Extended): Extended;
begin
  Result := PUTF32String(@Default)._GetFloat(Pointer(Chars), Length);
end;

function UTF32String.ToFloat: Extended;
begin
  Result := PUTF32String(0)._GetFloat(Pointer(Chars), Length);
end;

function UTF32String._GetFloat(S: PCardinal; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: UTF32String;
  Store: record
    V: NativeInt;
    Sign: Byte;
  end;
  X: NativeUInt;
  Marker: NativeInt;

  V: NativeInt;
  Base: Double;
  TenPowers: PTenPowers;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  if (L = 0) then goto fail;

  X := S^;
  Buffer.Length := L;
  Store.Sign := 0;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Store.Sign := $80;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  // integer part
  begin
    if (L > 9) then
    begin
      V := PUTF32String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PUTF32String(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      V := not V;
      Result := Integer(Store.V);
      Dec(L, V);
      Inc(S, V);
    end else
    begin
      Result := Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      repeat
        if (L > 9) then
        begin
          V := PUTF32String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PUTF32String(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result * TEN_POWERS[True][X] + Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          Break;
        end else
        begin
          Result := Result * TEN_POWERS[True][X] + Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  case S^ of
    Ord('.'), Ord(','): goto frac;
    Ord('e'), Ord('E'):
    begin
      if (S <> Pointer(Buffer.Chars)) then goto exp;
      goto fail;
    end
  else
    goto fail;
  end;

frac:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // frac part
  begin
    if (L > 9) then
    begin
      V := PUTF32String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PUTF32String(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      X := not V;
      Result := Result + TEN_POWERS[False][X] * Integer(Store.V);
      Dec(L, X);
      Inc(S, X);
    end else
    begin
      Result := Result + TEN_POWERS[False][X] * Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      Base := TEN_POWERS[False][9];
      repeat
        if (L > 9) then
        begin
          V := PUTF32String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PUTF32String(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result + Base * TEN_POWERS[False][X] * Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          Break;
        end else
        begin
          Base := Base * TEN_POWERS[False][X];
          Result := Result + Base * Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  if (S^ or $20 <> $65{Ord('e')}) then goto fail;
exp:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // exponent part
  X := S^;
  TenPowers := @TEN_POWERS[True];

  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      TenPowers := @TEN_POWERS[False];
      goto skipexpsign;
    end;
    Ord('+'):
    begin
    skipexpsign:
      Inc(S);
      if (L = 1) then goto done;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto done;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 3) then goto fail;
  if (L = 1) then
  begin
    X := NativeUInt(S^) - Ord('0');
    if (X >= 10) then goto fail;
    Result := Result * TenPowers[X];
  end else
  begin
    V := PUTF32String(nil)._GetInt_19(S, L);
    if (V < 0) or (V > 300) then goto fail;
    Result := Result * TenPower(TenPowers, V);
  end;
done:
  {$ifdef EXTENDEDSUPPORT}
    Inc(PExtendedBytes(@Result)[High(TExtendedBytes)], Store.Sign);
  {$else}
    if (Store.Sign <> 0) then Result := -Result;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ETinyString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidFloat), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PExtended(Marker)^;
  end else
  begin
    {$ifdef FPC}
      Marker := -Marker;
      PBoolean(Marker)^ := False;
    {$else}
      PBoolean(-Marker)^ := False;
    {$endif}
  zero:
    Result := 0;
  end;
end;

function UTF32String.ToDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function UTF32String.ToDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise _GetDateTimeException(1{Date});
end;

function UTF32String.TryToDate(out Value: TDateTime): Boolean;
const
  DT = 1{Date};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function UTF32String.ToTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Time})) then
    Result := Default;
end;

function UTF32String.ToTime: TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    raise _GetDateTimeException(2{Time});
end;

function UTF32String.TryToTime(out Value: TDateTime): Boolean;
const
  DT = 2{Time};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function UTF32String.ToDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function UTF32String.ToDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise _GetDateTimeException(3{DateTime});
end;

function UTF32String.TryToDateTime(out Value: TDateTime): Boolean;
const
  DT = 3{DateTime};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86.DELPHI}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function UTF32String._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
label
  fail;
var
  L, X: NativeUInt;
  Dest: PByte;
  Src: PCardinal;
  Buffer: TDateTimeBuffer;
begin
  Buffer.Value := @Value;
  L := Self.Length;
  Buffer.Length := L;
  Buffer.DT := DT;
  if (L < DT_LEN_MIN[DT]) or (L > DT_LEN_MAX[DT]) then
  begin
  fail:
    Result := False;
    Exit;
  end;

  Src := Pointer(FChars);
  Dest := Pointer(@Buffer.Bytes);
  repeat
    X := Src^;
    Inc(Src);
    if (X > High(DT_BYTES)) then goto fail;
    Dest^ := DT_BYTES[X];
    Dec(L);
    Inc(Dest);
  until (L = 0);

  Result := Tiny.Cache.Text._GetDateTime(Buffer);
end;

function UTF32String._GetDateTimeException(DT: NativeUInt): ETinyString;
var
  ResStringRec: PResStringRec;
begin
  case DT of
    1{Date}: ResStringRec := Pointer(@SInvalidDate);
    2{Time}: ResStringRec := Pointer(@SInvalidTime);
  else
    {3: DateTime}
    ResStringRec := Pointer(@SInvalidDateTime);
  end;

  Result := ETinyString.Create(ResStringRec, @Self);
end;

procedure ascii_from_utf32(Dest: Pointer; Src: PCardinal; Count: NativeInt);
var
  i: NativeInt;
begin
  if (Count < 0) then
  begin
    Count := -Count;
    for i := 0 to Count - 1 do
    begin
      PWord(Dest)^ := Src^;
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Word));
    end;
  end else
  begin
    for i := 0 to Count - 1 do
    begin
      PByte(Dest)^ := Src^;
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Byte));
    end;
  end;
end;

procedure ascii_from_utf32_lower(Dest: Pointer; Src: PCardinal; Count: NativeInt);
var
  i: NativeInt;
  Converter: PTextConvWW;
begin
  Converter := Pointer(@TEXTCONV_CHARCASE.LOWER);

  if (Count < 0) then
  begin
    Count := -Count;
    for i := 0 to Count - 1 do
    begin
      PWord(Dest)^ := Converter[Src^];
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Word));
    end;
  end else
  begin
    for i := 0 to Count - 1 do
    begin
      PByte(Dest)^ := Converter[Src^];
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Byte));
    end;
  end;
end;

procedure ascii_from_utf32_upper(Dest: Pointer; Src: PCardinal; Count: NativeInt);
var
  i: NativeInt;
  Converter: PTextConvWW;
begin
  Converter := Pointer(@TEXTCONV_CHARCASE.UPPER);

  if (Count < 0) then
  begin
    Count := -Count;
    for i := 0 to Count - 1 do
    begin
      PWord(Dest)^ := Converter[Src^];
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Word));
    end;
  end else
  begin
    for i := 0 to Count - 1 do
    begin
      PByte(Dest)^ := Converter[Src^];
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Byte));
    end;
  end;
end;

procedure UTF32String.ToAnsiString(var S: AnsiString; const CodePage: Word);
var
  L, X: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS, StoredDestSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(Pointer(S)));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
  StoredDestSBCS := DestSBCS;
  Dest := AStrInit(S, nil, L, DestSBCS.CodePage);

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := StoredDestSBCS.FVALUES;
    if (Converter = nil) then Converter := StoredDestSBCS.AllocFillVALUES(StoredDestSBCS.FVALUES);

    {$ifdef CPUX86}
    Dest := Pointer(S);
    {$endif}

    repeat
      X := PCardinal(Src)^;
      if (X > $7f) then
      begin
        if (X > $ffff) then X := UNKNOWN_CHARACTER;
        X := PTextConvBW(Converter)[X];
      end;

      Dec(L);
      PByte(Dest)^ := X;
      Inc(NativeUInt(Src), SizeOf(Cardinal));
      Inc(NativeUInt(Dest), SizeOf(Byte));
    until (L = 0)
  end else
  begin
    ascii_from_utf32(Dest, Src, L)
  end;
end;

procedure UTF32String.ToLowerAnsiString(var S: AnsiString; const CodePage: Word);
var
  L, X: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS, StoredDestSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(Pointer(S)));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
  StoredDestSBCS := DestSBCS;
  Dest := AStrInit(S, nil, L, DestSBCS.CodePage);

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := StoredDestSBCS.FVALUES;
    if (Converter = nil) then Converter := StoredDestSBCS.AllocFillVALUES(StoredDestSBCS.FVALUES);

    {$ifdef CPUX86}
    Dest := Pointer(S);
    {$endif}

    repeat
      X := PCardinal(Src)^;

      if (X <= $ffff) then
      begin
        X := TEXTCONV_CHARCASE.VALUES[X];
        if (X > $7f) then X := PTextConvBW(Converter)[X];
      end else
      begin
        X := UNKNOWN_CHARACTER;
      end;

      Dec(L);
      PByte(Dest)^ := X;
      Inc(NativeUInt(Src), SizeOf(Cardinal));
      Inc(NativeUInt(Dest), SizeOf(Byte));
    until (L = 0)
  end else
  begin
    ascii_from_utf32_lower(Dest, Src, L)
  end;
end;

procedure UTF32String.ToUpperAnsiString(var S: AnsiString; const CodePage: Word);
var
  L, X: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS, StoredDestSBCS: PTextConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(Pointer(S)));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
  StoredDestSBCS := DestSBCS;
  Dest := AStrInit(S, nil, L, DestSBCS.CodePage);

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := StoredDestSBCS.FVALUES;
    if (Converter = nil) then Converter := StoredDestSBCS.AllocFillVALUES(StoredDestSBCS.FVALUES);

    {$ifdef CPUX86}
    Dest := Pointer(S);
    {$endif}

    repeat
      X := PCardinal(Src)^;

      if (X <= $ffff) then
      begin
        X := TEXTCONV_CHARCASE.VALUES[$10000 + X];
        if (X > $7f) then X := PTextConvBW(Converter)[X];
      end else
      begin
        X := UNKNOWN_CHARACTER;
      end;

      Dec(L);
      PByte(Dest)^ := X;
      Inc(NativeUInt(Src), SizeOf(Cardinal));
      Inc(NativeUInt(Dest), SizeOf(Byte));
    until (L = 0)
  end else
  begin
    ascii_from_utf32_upper(Dest, Src, L)
  end;
end;

type
  TSBCSConv = record
  case Integer of
    0: (
          CodePageIndex: NativeUInt;
          Length: NativeInt;
          CaseLookup: PTextConvWW;
       );
    1: (CP: Word);
  end;

procedure sbcs_from_utf32(Dest: PByte; Src: PCardinal; const SBCSConv: TSBCSConv);
var
  i, X: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  CaseLookup: PTextConvWW;
begin
  // DestSBCS
  Index := SBCSConv.CodePageIndex;
  if (Index > $ffff) then
  begin
    Index := Index shr 24;
  end else
  begin
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = SBCSConv.CP) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    Index := Byte(Value shr 16);
  end;
  Index := Index * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS);

  // converter (Index)
  if (PTextConvSBCSEx(Index).FVALUES <> nil) then
  begin
    Index := NativeUInt(PTextConvSBCSEx(Index).FVALUES);
  end else
  begin
    Index := NativeUInt(PTextConvSBCSEx(Index).AllocFillVALUES(PTextConvSBCSEx(Index).FVALUES));
  end;

  CaseLookup := Pointer(SBCSConv.CaseLookup);
  if (CaseLookup <> nil) then
  begin
    for i := 1 to SBCSConv.Length do
    begin
      X := PCardinal(Src)^;

      if (X <= $ffff) then
      begin
        X := CaseLookup[X];
        if (X > $7f) then X := PTextConvBW(Index){Converter}[X];
      end else
      begin
        X := UNKNOWN_CHARACTER;
      end;

      Dest^ := X;
      Inc(Src);
      Inc(Dest);
    end;
  end else
  begin
    for i := 1 to SBCSConv.Length do
    begin
      X := PCardinal(Src)^;

      if (X > $7f) then
      begin
        if (X > $ffff) then X := UNKNOWN_CHARACTER;
        X := PTextConvBW(Index){Converter}[X];
      end;

      Dest^ := X;
      Inc(Src);
      Inc(Dest);
    end;
  end;
end;

procedure UTF32String.ToAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Src: Pointer;
  SBCSConv: TSBCSConv;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8ShortString(S);
    Exit;
  end;
  SBCSConv.CodePageIndex := CodePage;

  L := Self.Length;
  if (L > NativeUInt(High(S))) then L := High(S);
  PByte(@S)^ := L;
  if (L = 0) then Exit;

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    SBCSConv.Length := L;
    SBCSConv.CaseLookup := nil;
    sbcs_from_utf32(Pointer(@S[1]), Src, SBCSConv);
  end else
  begin
    ascii_from_utf32(Pointer(@S[1]), Src, L)
  end;
end;

procedure UTF32String.ToLowerAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Src: Pointer;
  SBCSConv: TSBCSConv;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8ShortString(S);
    Exit;
  end;
  SBCSConv.CodePageIndex := CodePage;

  L := Self.Length;
  if (L > NativeUInt(High(S))) then L := High(S);
  PByte(@S)^ := L;
  if (L = 0) then Exit;

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    SBCSConv.Length := L;
    SBCSConv.CaseLookup := Pointer(@TEXTCONV_CHARCASE.LOWER);
    sbcs_from_utf32(Pointer(@S[1]), Src, SBCSConv);
  end else
  begin
    ascii_from_utf32_lower(Pointer(@S[1]), Src, L)
  end;
end;

procedure UTF32String.ToUpperAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Src: Pointer;
  SBCSConv: TSBCSConv;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8ShortString(S);
    Exit;
  end;
  SBCSConv.CodePageIndex := CodePage;

  L := Self.Length;
  if (L > NativeUInt(High(S))) then L := High(S);
  PByte(@S)^ := L;
  if (L = 0) then Exit;

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    SBCSConv.Length := L;
    SBCSConv.CaseLookup := Pointer(@TEXTCONV_CHARCASE.UPPER);
    sbcs_from_utf32(Pointer(@S[1]), Src, SBCSConv);
  end else
  begin
    ascii_from_utf32_upper(Pointer(@S[1]), Src, L)
  end;
end;

function utf8_from_utf32(Dest: PByte; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PByte;
begin
  StoredDest := Dest;

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X > $7f) then
    begin
      case X of
        $80..$7ff:
        begin
          // X := (X shr 6) + ((X and $3f) shl 8) + $80C0;
          Y := X;
          X := (X shr 6) + $80C0;
          Y := (Y and $3f) shl 8;
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
        end;
        $800..$ffff:
        begin
          // X := (X shr 12) + ((X and $0fc0) shl 2) + ((X and $3f) shl 16) + $8080E0;
          Y := X;
          X := (X and $0fc0) shl 2;
          Inc(X, (Y and $3f) shl 16);
          Y := (Y shr 12);
          Inc(X, $8080E0);
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
        $10000..MAXIMUM_CHARACTER:
        begin
          //X := (X shr 18) + ((X and $3f) shl 24) + ((X and $0fc0) shl 10) +
          //     ((X shr 4) and $3f00) + Integer($808080F0);
          Y := (X and $3f) shl 24;
          Y := Y + ((X and $0fc0) shl 10);
          Y := Y + (X shr 18);
          X := (X shr 4) and $3f00;
          Inc(Y, Integer($808080F0));
          Inc(X, Y);

          PCardinal(Dest)^ := X;
          Inc(Dest, 4);
        end;
      else
        PByte(Dest)^ := UNKNOWN_CHARACTER;
        Inc(Dest);
      end;
    end else
    begin
      PByte(Dest)^ := X;
      Inc(Dest);
    end;
  end;

  Result := NativeUInt(Dest) - NativeUInt(StoredDest);
end;

function utf8_from_utf32_lower(Dest: PByte; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PByte;
  Converter: PTextConvWW;
begin
  StoredDest := Dest;
  Converter := Pointer(@TEXTCONV_CHARCASE.LOWER);

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X > $7f) then
    begin
      case X of
        $80..$7ff:
        begin
          X := Converter[X];
          // X := (X shr 6) + ((X and $3f) shl 8) + $80C0;
          Y := X;
          X := (X shr 6) + $80C0;
          Y := (Y and $3f) shl 8;
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
        end;
        $800..$ffff:
        begin
          X := Converter[X];
          // X := (X shr 12) + ((X and $0fc0) shl 2) + ((X and $3f) shl 16) + $8080E0;
          Y := X;
          X := (X and $0fc0) shl 2;
          Inc(X, (Y and $3f) shl 16);
          Y := (Y shr 12);
          Inc(X, $8080E0);
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
        $10000..MAXIMUM_CHARACTER:
        begin
          //X := (X shr 18) + ((X and $3f) shl 24) + ((X and $0fc0) shl 10) +
          //     ((X shr 4) and $3f00) + Integer($808080F0);
          Y := (X and $3f) shl 24;
          Y := Y + ((X and $0fc0) shl 10);
          Y := Y + (X shr 18);
          X := (X shr 4) and $3f00;
          Inc(Y, Integer($808080F0));
          Inc(X, Y);

          PCardinal(Dest)^ := X;
          Inc(Dest, 4);
        end;
      else
        PByte(Dest)^ := UNKNOWN_CHARACTER;
        Inc(Dest);
      end;
    end else
    begin
      X := Converter[X];
      PByte(Dest)^ := X;
      Inc(Dest);
    end;
  end;

  Result := NativeUInt(Dest) - NativeUInt(StoredDest);
end;

function utf8_from_utf32_upper(Dest: PByte; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PByte;
  Converter: PTextConvWW;
begin
  StoredDest := Dest;
  Converter := Pointer(@TEXTCONV_CHARCASE.UPPER);

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X > $7f) then
    begin
      case X of
        $80..$7ff:
        begin
          X := Converter[X];
          // X := (X shr 6) + ((X and $3f) shl 8) + $80C0;
          Y := X;
          X := (X shr 6) + $80C0;
          Y := (Y and $3f) shl 8;
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
        end;
        $800..$ffff:
        begin
          X := Converter[X];
          // X := (X shr 12) + ((X and $0fc0) shl 2) + ((X and $3f) shl 16) + $8080E0;
          Y := X;
          X := (X and $0fc0) shl 2;
          Inc(X, (Y and $3f) shl 16);
          Y := (Y shr 12);
          Inc(X, $8080E0);
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
        $10000..MAXIMUM_CHARACTER:
        begin
          //X := (X shr 18) + ((X and $3f) shl 24) + ((X and $0fc0) shl 10) +
          //     ((X shr 4) and $3f00) + Integer($808080F0);
          Y := (X and $3f) shl 24;
          Y := Y + ((X and $0fc0) shl 10);
          Y := Y + (X shr 18);
          X := (X shr 4) and $3f00;
          Inc(Y, Integer($808080F0));
          Inc(X, Y);

          PCardinal(Dest)^ := X;
          Inc(Dest, 4);
        end;
      else
        PByte(Dest)^ := UNKNOWN_CHARACTER;
        Inc(Dest);
      end;
    end else
    begin
      X := Converter[X];
      PByte(Dest)^ := X;
      Inc(Dest);
    end;
  end;

  Result := NativeUInt(Dest) - NativeUInt(StoredDest);
end;

procedure UTF32String.ToUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := AStrReserve(S, L shl 2);
    Src := Self.Chars;
    AStrSetLength(S, utf8_from_utf32(Dest, Src, L), CODEPAGE_UTF8);
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, CODEPAGE_UTF8);
    Src := Self.Chars;
    ascii_from_utf32(Dest, Src, L);
  end;
end;

procedure UTF32String.ToLowerUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := AStrReserve(S, L shl 2);
    Src := Self.Chars;
    AStrSetLength(S, utf8_from_utf32_lower(Dest, Src, L), CODEPAGE_UTF8);
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, CODEPAGE_UTF8);
    Src := Self.Chars;
    ascii_from_utf32_lower(Dest, Src, L);
  end;
end;

procedure UTF32String.ToUpperUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AStrClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := AStrReserve(S, L shl 2);
    Src := Self.Chars;
    AStrSetLength(S, utf8_from_utf32_upper(Dest, Src, L), CODEPAGE_UTF8);
  end else
  begin
    // Ascii chars
    Dest := AStrInit(S, nil, L, CODEPAGE_UTF8);
    Src := Self.Chars;
    ascii_from_utf32_upper(Dest, Src, L);
  end;
end;

procedure UTF32String.ToUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest: PByte;
  Context: TTextConvContextEx;
begin
  Dest := Pointer(@S);
  L := Self.Length;
  if (L = 0) then
  begin
    Dest^ := L;
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Inc(Dest);
    Context.Destination := Dest;
    Context.DestinationSize := NativeUInt(High(S));
    Context.SourceSize := L shl 2;
    Context.Source := Self.Chars;

    // conversion
    Context.F.Flags := Ord(bomUTF32) + Ord(bomUTF8) shl (32 - 5) + (1 shl 24);
    Context.convert_universal;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    if (L > NativeUInt(High(S))) then L := NativeUInt(High(S));
    Dest^ := L;
    Inc(Dest);
    ascii_from_utf32(Dest, Pointer(Self.Chars), L);
  end;
end;

procedure UTF32String.ToLowerUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest: PByte;
  Context: TTextConvContextEx;
begin
  Dest := Pointer(@S);
  L := Self.Length;
  if (L = 0) then
  begin
    Dest^ := L;
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Inc(Dest);
    Context.Destination := Dest;
    Context.DestinationSize := NativeUInt(High(S));
    Context.SourceSize := L shl 2;
    Context.Source := Self.Chars;

    // conversion
    Context.F.Flags := Ord(bomUTF32) + Ord(bomUTF8) shl (32 - 5) + Ord(ccLower) shl 16;
    Context.convert_universal;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    if (L > NativeUInt(High(S))) then L := NativeUInt(High(S));
    Dest^ := L;
    Inc(Dest);
    ascii_from_utf32_lower(Dest, Pointer(Self.Chars), L);
  end;
end;

procedure UTF32String.ToUpperUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest: PByte;
  Context: TTextConvContextEx;
begin
  Dest := Pointer(@S);
  L := Self.Length;
  if (L = 0) then
  begin
    Dest^ := L;
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Inc(Dest);
    Context.Destination := Dest;
    Context.DestinationSize := NativeUInt(High(S));
    Context.SourceSize := L shl 2;
    Context.Source := Self.Chars;

    // conversion
    Context.F.Flags := Ord(bomUTF32) + Ord(bomUTF8) shl (32 - 5) + Ord(ccUpper) shl 16;
    Context.convert_universal;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    if (L > NativeUInt(High(S))) then L := NativeUInt(High(S));
    Dest^ := L;
    Inc(Dest);
    ascii_from_utf32_upper(Dest, Pointer(Self.Chars), L);
  end;
end;

function utf16_from_utf32(Dest: PWord; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PWord;
begin
  StoredDest := Dest;

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X <= $ffff) then
    begin
      if (X shr 11 = $1B) then Dest^ := $fffd
      else Dest^ := X;

      Inc(Dest);
    end else
    begin
      Y := (X - $10000) shr 10 + $d800;
      X := (X - $10000) and $3ff + $dc00;
      X := (X shl 16) + Y;

      PCardinal(Dest)^ := X;
      Inc(Dest, 2);
    end;
  end;

  Result := (NativeUInt(Dest) - NativeUInt(StoredDest)) shr 1;
end;

function utf16_from_utf32_lower(Dest: PWord; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PWord;
  Converter: PTextConvWW;
begin
  StoredDest := Dest;
  Converter := Pointer(@TEXTCONV_CHARCASE.LOWER);

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X <= $ffff) then
    begin
      if (X shr 11 = $1B) then Dest^ := $fffd
      else Dest^ := Converter[X];

      Inc(Dest);
    end else
    begin
      Y := (X - $10000) shr 10 + $d800;
      X := (X - $10000) and $3ff + $dc00;
      X := (X shl 16) + Y;

      PCardinal(Dest)^ := X;
      Inc(Dest, 2);

      {$ifdef CPUX86}
      Converter := Pointer(@TEXTCONV_CHARCASE.LOWER);
      {$endif}
    end;
  end;

  Result := (NativeUInt(Dest) - NativeUInt(StoredDest)) shr 1;
end;

function utf16_from_utf32_upper(Dest: PWord; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PWord;
  Converter: PTextConvWW;
begin
  StoredDest := Dest;
  Converter := Pointer(@TEXTCONV_CHARCASE.UPPER);

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X <= $ffff) then
    begin
      if (X shr 11 = $1B) then Dest^ := $fffd
      else Dest^ := Converter[X];

      Inc(Dest);
    end else
    begin
      Y := (X - $10000) shr 10 + $d800;
      X := (X - $10000) and $3ff + $dc00;
      X := (X shl 16) + Y;

      PCardinal(Dest)^ := X;
      Inc(Dest, 2);

      {$ifdef CPUX86}
      Converter := Pointer(@TEXTCONV_CHARCASE.UPPER);
      {$endif}
    end;
  end;

  Result := (NativeUInt(Dest) - NativeUInt(StoredDest)) shr 1;
end;

procedure UTF32String.ToWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WStrClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := WStrReserve(S, L shl 1);
    Src := Self.Chars;
    WStrSetLength(S, utf16_from_utf32(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := WStrInit(S, nil, L);
    Src := Self.Chars;
    ascii_from_utf32(Dest, Src, -L)
  end;
end;

procedure UTF32String.ToLowerWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WStrClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := WStrReserve(S, L shl 1);
    Src := Self.Chars;
    WStrSetLength(S, utf16_from_utf32_lower(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := WStrInit(S, nil, L);
    Src := Self.Chars;
    ascii_from_utf32_lower(Dest, Src, -L)
  end;
end;

procedure UTF32String.ToUpperWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WStrClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := WStrReserve(S, L shl 1);
    Src := Self.Chars;
    WStrSetLength(S, utf16_from_utf32_upper(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := WStrInit(S, nil, L);
    Src := Self.Chars;
    ascii_from_utf32_upper(Dest, Src, -L)
  end;
end;

procedure UTF32String.ToUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    UStrClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := UStrReserve(S, L shl 1);
    Src := Self.Chars;
    UStrSetLength(S, utf16_from_utf32(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := UStrInit(S, nil, L);
    Src := Self.Chars;
    ascii_from_utf32(Dest, Src, -L)
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToWideString
end;
{$endif}

procedure UTF32String.ToLowerUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    UStrClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := UStrReserve(S, L shl 1);
    Src := Self.Chars;
    UStrSetLength(S, utf16_from_utf32_lower(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := UStrInit(S, nil, L);
    Src := Self.Chars;
    ascii_from_utf32_lower(Dest, Src, -L)
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToLowerWideString
end;
{$endif}

procedure UTF32String.ToUpperUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    UStrClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := UStrReserve(S, L shl 1);
    Src := Self.Chars;
    UStrSetLength(S, utf16_from_utf32_upper(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := UStrInit(S, nil, L);
    Src := Self.Chars;
    ascii_from_utf32_upper(Dest, Src, -L)
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToUpperWideString
end;
{$endif}

procedure UTF32String.ToString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUnicodeString(S);
  {$else}
     ToAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToAnsiString
end;
{$ifend}

procedure UTF32String.ToLowerString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToLowerUnicodeString(S);
  {$else}
     ToLowerAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToLowerAnsiString
end;
{$ifend}

procedure UTF32String.ToUpperString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUpperUnicodeString(S);
  {$else}
     ToUpperAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToUpperAnsiString
end;
{$ifend}

function UTF32String.ToAnsiString: AnsiString;
{$ifNdef CPUINTELASM}
begin
  ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

function UTF32String.ToLowerAnsiString: AnsiString;
{$ifNdef CPUINTELASM}
begin
  ToLowerAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToLowerAnsiString
end;
{$endif}

function UTF32String.ToUpperAnsiString: AnsiString;
{$ifNdef CPUINTELASM}
begin
  ToUpperAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToUpperAnsiString
end;
{$endif}

function UTF32String.ToUTF8String: UTF8String;
{$ifNdef CPUINTELASM}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUTF8String
end;
{$endif}

function UTF32String.ToLowerUTF8String: UTF8String;
{$ifNdef CPUINTELASM}
begin
  ToLowerUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToLowerUTF8String
end;
{$endif}

function UTF32String.ToUpperUTF8String: UTF8String;
{$ifNdef CPUINTELASM}
begin
  ToUpperUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUpperUTF8String
end;
{$endif}

function UTF32String.ToWideString: WideString;
{$ifNdef CPUINTELASM}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToWideString
end;
{$endif}

function UTF32String.ToLowerWideString: WideString;
{$ifNdef CPUINTELASM}
begin
  ToLowerWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToLowerWideString
end;
{$endif}

function UTF32String.ToUpperWideString: WideString;
{$ifNdef CPUINTELASM}
begin
  ToUpperWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUpperWideString
end;
{$endif}

function UTF32String.ToUnicodeString: UnicodeString;
{$ifNdef CPUINTELASM}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    jmp ToWideString
  {$endif}
end;
{$endif}

function UTF32String.ToLowerUnicodeString: UnicodeString;
{$ifNdef CPUINTELASM}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    jmp ToLowerWideString
  {$endif}
end;
{$endif}

function UTF32String.ToUpperUnicodeString: UnicodeString;
{$ifNdef CPUINTELASM}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    jmp ToUpperWideString
  {$endif}
end;
{$endif}

function UTF32String.ToString: string;
{$ifNdef CPUINTELASM}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToAnsiString
  {$endif}
end;
{$endif}

function UTF32String.ToLowerString: string;
{$ifNdef CPUINTELASM}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToLowerAnsiString
  {$endif}
end;
{$endif}

function UTF32String.ToUpperString: string;
{$ifNdef CPUINTELASM}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToUpperAnsiString
  {$endif}
end;
{$endif}

{$ifdef OPERATORSUPPORT}
class operator UTF32String.Implicit(const a: UTF32String): AnsiString;
{$ifNdef CPUINTELASM}
begin
  a.ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

class operator UTF32String.Implicit(const a: UTF32String): WideString;
{$ifNdef CPUINTELASM}
begin
  a.ToWideString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToWideString
end;
{$endif}

{$ifdef UNICODE}
class operator UTF32String.Implicit(const a: UTF32String): UTF8String;
{$ifNdef CPUINTELASM}
begin
  a.ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUTF8String
end;
{$endif}

class operator UTF32String.Implicit(const a: UTF32String): UnicodeString;
{$ifNdef CPUINTELASM}
begin
  a.ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ToUnicodeString
end;
{$endif}
{$endif}
{$endif}

function UTF32String._CompareByteString(const S: PByteString; const IgnoreCase: Boolean): NativeInt;
label
  ret_default;
const
  CASE_LOOKUPS: array[Boolean] of Pointer = (nil, @TEXTCONV_CHARCASE);
var
  CaseLookup: PTextConvWW;
  P1: PCardinal;
  P2: PByte;
  P1Length, P2Length: NativeUInt;
  i, X, Y: NativeUInt;
  UCS2Chars: PTextConvWB;
  Store: record
    Modifier: NativeUInt;
  end;
begin
  CaseLookup := CASE_LOOKUPS[IgnoreCase];
  P1 := Pointer(Self.FChars);
  P1Length := Self.FLength;
  P2 := Pointer(S.FChars);
  P2Length := S.Length;

  if (Integer(S.Flags) < 0) then
  begin
    // utf8
    Store.Modifier := NativeUInt(-1);
    for i := P1Length downto 1 do
    begin
      X := TEXTCONV_UTF8CHAR_SIZE[P2^];
      Dec(P2Length, X);
      if (NativeInt(P2Length) < 0) then goto ret_default{greather};

      case X of
        0: goto ret_default{greather};
        1:
        begin
          X := P2^;
          Inc(P2, 1);
        end;
        2:
        begin
          X := PWord(P2)^;
          Inc(P2, 2);
          if (X and $C0E0 = $80C0) then
          begin
            Y := X;
            X := X and $1F;
            Y := Y shr 8;
            X := X shl 6;
            Y := Y and $3F;
            Inc(X, Y);
          end else
          begin
            goto ret_default{greather};
          end;
        end;
        3:
        begin
          X := P4Bytes(P2)[2];
          Y := PWord(P2)^;
          X := (X shl 16) or Y;
          Inc(P2, 3);

          if (X and $C0C000 = $808000) then
          begin
            Y := (X and $0F) shl 12;
            Y := Y + (X shr 16) and $3F;
            X := (X and $3F00) shr 2;
            Inc(X, Y);
          end else
          begin
            goto ret_default{greather};
          end;
        end;
        4:
        begin
          X := PCardinal(P2)^;
          Inc(P2, 4);
          if (X and $C0C0C000 = $80808000) then
          begin
            Y := (X and $07) shl 18;
            Y := Y + (X and $3f00) shl 4;
            Y := Y + (X shr 10) and $0fc0;
            X := (X shr 24) and $3f;
            Inc(X, Y);
          end else
          begin
            goto ret_default{greather};
          end;
        end;
      else
        // 5, 6 (less)
        Break;
      end;

      Y := P1^;
      Inc(P1);
      if (X = Y) then Continue;
      if (X or Y <= $ffff) and (CaseLookup <> nil) then
      begin
        X := CaseLookup[X];
        Y := CaseLookup[Y];
        if (X = Y) then Continue;
      end;

      Result := Ord(Y > X)*2 - 1;
      Exit;
    end;

    Result := -Ord(P2Length <> 0);
    Exit;
  end else
  begin
    // sbcs
    if (P1Length <= P2Length) then
    begin
      Store.Modifier := (-NativeInt(P2Length - P1Length)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      P1Length := P2Length;
      Store.Modifier := NativeUInt(-1);
    end;

    P2Length := S.Flags;
    P2Length := P2Length shr 24;
    P2Length := P2Length * SizeOf(TTextConvSBCS);
    Inc(P2Length, NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    UCS2Chars := Pointer(PTextConvSBCSEx(P2Length).FUCS2.Original);
    if (UCS2Chars = nil) then UCS2Chars := Pointer(PTextConvSBCSEx(P2Length).AllocFillUCS2(PTextConvSBCSEx(P2Length).FUCS2.Original, ccOriginal));

    for i := P1Length downto 1 do
    begin
      X := P1^;
      Y := UCS2Chars[P2^];
      Inc(P1);
      Inc(P2);

      if (X = Y) then Continue;
      if (X <= $ffff) and (CaseLookup <> nil) then
      begin
        X := CaseLookup[X];
        Y := CaseLookup[Y];
        if (X = Y) then Continue;
      end;

      Result := Ord(X > Y)*2 - 1;
      Exit;
    end;
  end;

ret_default:
  Result := Store.Modifier;
  Result := -Result;
end;

function UTF32String._CompareUTF16String(const S: PUTF16String; const IgnoreCase: Boolean): NativeInt;
label
  ret_greather;
const
  CASE_LOOKUPS: array[Boolean] of Pointer = (nil, @TEXTCONV_CHARCASE);
var
  P1: PCardinal;
  P2: PWord;
  P1Length, P2Length: NativeUInt;
  i, X, Y: NativeUInt;
  {$ifdef CPUX86}
  Store: record
    CaseLookup: PTextConvWW;
  end;
  {$else}
    CaseLookup: PTextConvWW;
  {$endif}
begin
  {$ifdef CPUX86}Store.{$endif}CaseLookup := CASE_LOOKUPS[IgnoreCase];
  P1 := Pointer(Self.FChars);
  P1Length := Self.FLength;
  P2 := Pointer(S.FChars);
  P2Length := S.Length;

  for i := P1Length downto 1 do
  begin
    X := P2^;
    Inc(P2);
    if (P2Length = 0) then goto ret_greather;
    Dec(P2Length);

    if (X >= $d800) and (X < $e000) then
    begin
      if (P2Length = 0) then goto ret_greather;
      if (X >= $dc00) then goto ret_greather;

      Y := P2^;
      Inc(P2);
      Dec(P2Length);
      if (Y < $dc00) then goto ret_greather;
      if (Y >= $e000) then goto ret_greather;

      Dec(X, $d800);
      Dec(Y, $dc00);
      X := X shl 10;
      Inc(Y, $10000);
      Inc(X, Y);
    end;

    Y := P1^;
    Inc(P1);
    if (X = Y) then Continue;
    if (X or Y <= $ffff) and ({$ifdef CPUX86}Store.{$endif}CaseLookup <> nil) then
    begin
      X := {$ifdef CPUX86}Store.{$endif}CaseLookup[X];
      Y := {$ifdef CPUX86}Store.{$endif}CaseLookup[Y];
      if (X = Y) then Continue;
    end;

    Result := Ord(Y > X)*2 - 1;
    Exit;
  end;

  Result := -Ord(P2Length <> 0);
  Exit;
ret_greather:
  Result := 1;
end;

function UTF32String._CompareUTF32String(const S: PUTF32String; const IgnoreCase: Boolean): NativeInt;
var
  L1, L2: NativeUInt;
begin
  L1 := Self.FLength;
  L2 := S.FLength;

  if (L1 <= L2) then
  begin
    L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
  end else
  begin
    L1 := L2;
    L2 := NativeUInt(-1);
  end;

  if (not IgnoreCase) then
  begin
    L1 := utf32_compare_utf32(Pointer(Self.FChars), Pointer(S.FChars), L1);
  end else
  begin
    L1 := utf32_compare_utf32_ignorecase(Pointer(Self.FChars), Pointer(S.FChars), L1);
  end;

  Result := L1 * 2 - L2;
end;

{inline} function UTF32String.Equal(const S: UTF32String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (S.Length <> 0) and (Self.Length = S.Length) then
  begin
    Y := PCardinal(Self.Chars)^;
    X := PCardinal(S.Chars)^;
    if (X = Y) then
    begin
      Ret := Self._CompareUTF32String(@S, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = S.Length);
end;

{inline} function UTF32String.EqualIgnoreCase(const S: UTF32String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (S.Length <> 0) and (Self.Length = S.Length) then
  begin
    Y := PCardinal(Self.Chars)^;
    X := PCardinal(S.Chars)^;
    if (X or Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) then
    begin
      Ret := Self._CompareUTF32String(@S, True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = S.Length);
end;

{inline} function UTF32String.Compare(const S: UTF32String): NativeInt;
var
  X, Y: NativeUInt;
begin
  if (Self.Length <> 0) and (S.Length <> 0) then
  begin
    Y := PCardinal(Self.Chars)^;
    X := PCardinal(S.Chars)^;
    if (X = Y) then
    begin
      Result := Self._CompareUTF32String(@S, False);
      Exit;
    end else
    begin
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(S.Length));
end;

{inline} function UTF32String.CompareIgnoreCase(const S: UTF32String): NativeInt;
var
  X, Y: NativeUInt;
begin
  if (Self.Length <> 0) and (S.Length <> 0) then
  begin
    Y := PCardinal(Self.Chars)^;
    X := PCardinal(S.Chars)^;
    if (X or Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) then
    begin
      Result := Self._CompareUTF32String(@S, True);
      Exit;
    end else
    begin
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(S.Length));
end;

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.Equal(const a: UTF32String; const b: UTF32String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (b.Length <> 0) and (a.Length = b.Length) then
  begin
    Y := PCardinal(a.Chars)^;
    X := PCardinal(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF32String(@b, False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := (a.Length = b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.NotEqual(const a: UTF32String; const b: UTF32String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (b.Length <> 0) and (a.Length = b.Length) then
  begin
    Y := PCardinal(a.Chars)^;
    X := PCardinal(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF32String(@b, False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := (a.Length <> b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.GreaterThan(const a: UTF32String; const b: UTF32String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PCardinal(a.Chars)^;
    X := PCardinal(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF32String(@b, False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.GreaterThanOrEqual(const a: UTF32String; const b: UTF32String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PCardinal(a.Chars)^;
    X := PCardinal(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF32String(@b, False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.LessThan(const a: UTF32String; const b: UTF32String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PCardinal(a.Chars)^;
    X := PCardinal(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF32String(@b, False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.LessThanOrEqual(const a: UTF32String; const b: UTF32String): Boolean;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
begin
  if (a.Length <> 0) and (b.Length <> 0) then
  begin
    Y := PCardinal(a.Chars)^;
    X := PCardinal(b.Chars)^;
    if (X = Y) then
    begin
      Ret := a._CompareUTF32String(@b, False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= b.Length);
end;
{$endif}

{inline} function UTF32String.Equal(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Pointer(Self.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (Self.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := Self._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF32String.EqualIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Pointer(Self.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (Self.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PByte(P)^;
    if (Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := Self._CompareByteString(PByteString(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF32String.Compare(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Result := Self._CompareByteString(PByteString(@Buffer), False);
      Exit;
    end else
    begin
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{inline} function UTF32String.CompareIgnoreCase(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif}): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  P := Pointer(S);
  {$ifNdef INTERNALCODEPAGE}Buffer.Flags := CodePage;{$endif}
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PByte(P)^;
    if (Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := Buffer.Flags;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Result := Self._CompareByteString(PByteString(@Buffer), True);
      Exit;
    end else
    begin
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.Equal(const a: UTF32String; const b: AnsiString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (Pointer(a.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (a.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.Equal(const a: AnsiString; const b: UTF32String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (Pointer(b.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (b.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.NotEqual(const a: UTF32String; const b: AnsiString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (Pointer(a.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (a.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.NotEqual(const a: AnsiString; const b: UTF32String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (Pointer(b.Length) <> nil) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    if (b.Length <> L) then goto ret_non_equal;
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.GreaterThan(const a: UTF32String; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.GreaterThan(const a: AnsiString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      Result := (X > Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.GreaterThanOrEqual(const a: UTF32String; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.GreaterThanOrEqual(const a: AnsiString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      Result := (X >= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.LessThan(const a: UTF32String; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.LessThan(const a: AnsiString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      Result := (X < Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.LessThanOrEqual(const a: UTF32String; const b: AnsiString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.LessThanOrEqual(const a: AnsiString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      {$ifdef INTERNALCODEPAGE}
      CP := PWord(PAnsiChar(Buffer.Chars) - ASTR_OFFSET_CODEPAGE)^;
      {$else}
      CP := 0;
      {$endif}
      if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
      begin
        Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      end else
      begin
        Buffer.Flags := 0;
        PByteString(@Buffer).SetEncoding(CP);
      end;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      Result := (X <= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

{inline} function UTF32String.{$ifdef UNICODE}Equal{$else}EqualUTF8{$endif}(const S: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := Self.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 4;
      if (X < Y) then goto ret_non_equal;
      Ret := Self._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF32String.{$ifdef UNICODE}EqualIgnoreCase{$else}EqualUTF8IgnoreCase{$endif}(const S: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PByte(P)^;
    if (Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := Self.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 4;
      if (X < Y) then goto ret_non_equal;
      Ret := Self._CompareByteString(PByteString(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF32String.{$ifdef UNICODE}Compare{$else}CompareUTF8{$endif}(const S: UTF8String): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Result := Self._CompareByteString(PByteString(@Buffer), False);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(Self.Chars)^;
      {$endif}
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{inline} function UTF32String.{$ifdef UNICODE}CompareIgnoreCase{$else}CompareUTF8IgnoreCase{$endif}(const S: UTF8String): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: TinyString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PByte(P)^;
    if (Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Result := Self._CompareByteString(PByteString(@Buffer), True);
      Exit;
    end else
    begin
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{$ifdef UNICODE}
{inline} class operator UTF32String.Equal(const a: UTF32String; const b: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := a.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 4;
      if (X < Y) then goto ret_non_equal;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.Equal(const a: UTF8String; const b: UTF32String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := b.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 4;
      if (X < Y) then goto ret_non_equal;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.NotEqual(const a: UTF32String; const b: UTF8String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := a.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 4;
      if (X < Y) then goto ret_non_equal;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.NotEqual(const a: UTF8String; const b: UTF32String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      X := b.Length;
      Y := Buffer.Length;
      if (X > Y) then goto ret_non_equal;
      X := X * 4;
      if (X < Y) then goto ret_non_equal;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.GreaterThan(const a: UTF32String; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(a.Chars)^;
      {$endif}
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.GreaterThan(const a: UTF8String; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(b.Chars)^;
      {$endif}
      Result := (X > Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.GreaterThanOrEqual(const a: UTF32String; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(a.Chars)^;
      {$endif}
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.GreaterThanOrEqual(const a: UTF8String; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(b.Chars)^;
      {$endif}
      Result := (X >= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.LessThan(const a: UTF32String; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(a.Chars)^;
      {$endif}
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.LessThan(const a: UTF8String; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(b.Chars)^;
      {$endif}
      Result := (X < Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.LessThanOrEqual(const a: UTF32String; const b: UTF8String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := a._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(a.Chars)^;
      {$endif}
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.LessThanOrEqual(const a: UTF8String; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, ASTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, ASTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PByte(P)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      Buffer.Flags := $ff000000;
      Ret := b._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(b.Chars)^;
      {$endif}
      Result := (X <= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

{inline} function UTF32String.Equal(const S: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Self.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(Self.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := Self._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF32String.EqualIgnoreCase(const S: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Self.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(Self.Chars)^;
      X := PWord(P)^;
      if (Y <= $ffff) then
      begin
        X := TEXTCONV_CHARCASE.VALUES[X];
        Y := TEXTCONV_CHARCASE.VALUES[Y];
      end;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := Self._CompareUTF16String(PUTF16String(@Buffer), True);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;

{inline} function UTF32String.Compare(const S: WideString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Self.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := L + 1;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(Self.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Result := Self._CompareUTF16String(PUTF16String(@Buffer), False);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PCardinal(Self.Chars)^;
        {$endif}
        Result := Ord(Y > X) * 2 - 1;
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{inline} function UTF32String.CompareIgnoreCase(const S: WideString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    if (Self.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := L + 1;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(Self.Chars)^;
      X := PWord(P)^;
      if (Y <= $ffff) then
      begin
        X := TEXTCONV_CHARCASE.VALUES[X];
        Y := TEXTCONV_CHARCASE.VALUES[Y];
      end;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Result := Self._CompareUTF16String(PUTF16String(@Buffer), True);
        Exit;
      end else
      begin
        Result := Ord(Y > X) * 2 - 1;
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.Equal(const a: UTF32String; const b: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.Equal(const a: WideString; const b: UTF32String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := False;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.NotEqual(const a: UTF32String; const b: WideString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <> 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := True;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.NotEqual(const a: WideString; const b: UTF32String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then goto ret_non_equal;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <> 0);
        Exit;
      end else
      begin
      ret_non_equal:
      {$ifdef MSWINDOWS}
        Result := True;
        Exit;
      {$else}
        P := nil;
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.GreaterThan(const a: UTF32String; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret > 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PCardinal(a.Chars)^;
        {$endif}
        Result := (Y > X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.GreaterThan(const a: WideString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret < 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PCardinal(b.Chars)^;
        {$endif}
        Result := (X > Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.GreaterThanOrEqual(const a: UTF32String; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret >= 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PCardinal(a.Chars)^;
        {$endif}
        Result := (Y >= X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.GreaterThanOrEqual(const a: WideString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <= 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PCardinal(b.Chars)^;
        {$endif}
        Result := (X >= Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.LessThan(const a: UTF32String; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret < 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PCardinal(a.Chars)^;
        {$endif}
        Result := (Y < X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.LessThan(const a: WideString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret > 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PCardinal(b.Chars)^;
        {$endif}
        Result := (X < Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.LessThanOrEqual(const a: UTF32String; const b: WideString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (P <> nil) then
  begin
    if (a.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := False;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(a.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret <= 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PCardinal(a.Chars)^;
        {$endif}
        Result := (Y <= X);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef OPERATORSUPPORT}
{inline} class operator UTF32String.LessThanOrEqual(const a: WideString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (P <> nil) then
  begin
    if (b.Length <> 0) then
    begin
      Buffer.Chars := P;
      Dec(P, WSTR_OFFSET_LENGTH);
      L := PCardinal(P)^;
      Inc(P, WSTR_OFFSET_LENGTH);
      {$ifdef MSWINDOWS}
      if (L = 0) then
      begin
        Result := True;
        Exit;
      end;
      {$endif}
      {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}
      Buffer.Length := L;

      Y := PCardinal(b.Chars)^;
      X := PWord(P)^;
      if (X = Y) or (X or Y >= $d800) then
      begin
        Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
        Result := (Ret >= 0);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        Y := PCardinal(b.Chars)^;
        {$endif}
        Result := (X <= Y);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P := Pointer(PCardinal(PAnsiChar(P) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} function UTF32String.Equal(const S: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} function UTF32String.EqualIgnoreCase(const S: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PWord(P)^;
    if (Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (Self.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} function UTF32String.Compare(const S: UnicodeString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(Self.Chars)^;
      {$endif}
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} function UTF32String.CompareIgnoreCase(const S: UnicodeString): NativeInt;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  P := Pointer(S);
  if (Self.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(Self.Chars)^;
    X := PWord(P)^;
    if (Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Exit;
    end else
    begin
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.Equal(const a: UTF32String; const b: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length = NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.Equal(const a: UnicodeString; const b: UTF32String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) = b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.NotEqual(const a: UTF32String; const b: UnicodeString): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (a.Length <> NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.NotEqual(const a: UnicodeString; const b: UTF32String): Boolean;
label
  ret_non_equal;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <> 0);
      Exit;
    end else
    begin
    ret_non_equal:
      P := nil;
    end;
  end;

  Result := (NativeUInt(P) <> b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.GreaterThan(const a: UTF32String; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(a.Chars)^;
      {$endif}
      Result := (Y > X);
      Exit;
    end;
  end;

  Result := (a.Length > NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.GreaterThan(const a: UnicodeString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(b.Chars)^;
      {$endif}
      Result := (X > Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) > b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.GreaterThanOrEqual(const a: UTF32String; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(a.Chars)^;
      {$endif}
      Result := (Y >= X);
      Exit;
    end;
  end;

  Result := (a.Length >= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.GreaterThanOrEqual(const a: UnicodeString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(b.Chars)^;
      {$endif}
      Result := (X >= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) >= b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.LessThan(const a: UTF32String; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret < 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(a.Chars)^;
      {$endif}
      Result := (Y < X);
      Exit;
    end;
  end;

  Result := (a.Length < NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.LessThan(const a: UnicodeString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret > 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(b.Chars)^;
      {$endif}
      Result := (X < Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) < b.Length);
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.LessThanOrEqual(const a: UTF32String; const b: UnicodeString): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(b);
  if (a.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(a.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := a._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret <= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(a.Chars)^;
      {$endif}
      Result := (Y <= X);
      Exit;
    end;
  end;

  Result := (a.Length <= NativeUInt(P));
end;
{$endif}

{$ifdef UNICODE}
{inline} class operator UTF32String.LessThanOrEqual(const a: UnicodeString; const b: UTF32String): Boolean;
var
  P: PByte;
  L: NativeUInt;
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  P := Pointer(a);
  if (b.Length <> 0) and (P <> nil) then
  begin
    Buffer.Chars := P;
    Dec(P, USTR_OFFSET_LENGTH);
    L := PCardinal(P)^;
    Inc(P, USTR_OFFSET_LENGTH);
    Buffer.Length := L;

    Y := PCardinal(b.Chars)^;
    X := PWord(P)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := b._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret >= 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(b.Chars)^;
      {$endif}
      Result := (X <= Y);
      Exit;
    end;
  end;

  Result := (NativeUInt(P) <= b.Length);
end;
{$endif}

function UTF32String.Equal(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PCardinal(Self.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;
        X := Self.Length;
        Y := Buffer.Length;
        if (X > Y) then goto ret_non_equal;
        X := X * 4;
        if (X < Y) then goto ret_non_equal;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;
        if (Self.Length <> Buffer.Length) then goto ret_non_equal;
      end;
      Ret := Self._CompareByteString(PByteString(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

function UTF32String.EqualIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  CP: Word;
  Ret: NativeInt;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PCardinal(Self.Chars)^;
    if (Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;
        X := Self.Length;
        Y := Buffer.Length;
        if (X > Y) then goto ret_non_equal;
        X := X * 4;
        if (X < Y) then goto ret_non_equal;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;
        if (Self.Length <> Buffer.Length) then goto ret_non_equal;
      end;
      Ret := Self._CompareByteString(PByteString(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

function UTF32String.Compare(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt;
var
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PCardinal(Self.Chars)^;
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;
      end;
      Result := Self._CompareByteString(PByteString(@Buffer), False);
      Exit;
    end else
    begin
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;

function UTF32String.CompareIgnoreCase(const AChars: PAnsiChar{/PUTF8Char}; const ALength: NativeUInt; const CodePage: Word): NativeInt;
var
  X, Y: NativeUInt;
  CP: Word;
  Buffer: TinyString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PByte(Buffer.Chars)^;
    Y := PCardinal(Self.Chars)^;
    if (Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) or (X or Y > $7f) then
    begin
      CP := CodePage;
      if (CP = CODEPAGE_UTF8) then
      begin
        Buffer.Flags := $ff000000;
      end else
      begin
        if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
        begin
          Buffer.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
        end else
        begin
          Buffer.Flags := 0;
          PByteString(@Buffer).SetEncoding(CP);
        end;
      end;
      Result := Self._CompareByteString(PByteString(@Buffer), True);
      Exit;
    end else
    begin
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;

{inline} function UTF32String.Equal(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PCardinal(Self.Chars)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

{inline} function UTF32String.EqualIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): Boolean;
label
  ret_non_equal;
var
  X, Y: NativeUInt;
  Ret: NativeInt;
  Buffer: PtrString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PCardinal(Self.Chars)^;
    if (Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Ret := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    ret_non_equal:
      Result := False;
      Exit;
    end;
  end;

  Result := (Self.Length = ALength);
end;

{inline} function UTF32String.Compare(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt;
var
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PCardinal(Self.Chars)^;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), False);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      Y := PCardinal(Self.Chars)^;
      {$endif}
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;

{inline} function UTF32String.CompareIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt): NativeInt;
var
  X, Y: NativeUInt;
  Buffer: PtrString;
begin
  if (Self.Length <> 0) and (ALength <> 0) then
  begin
    Buffer.Length := ALength;
    Buffer.Chars := AChars;
    X := PWord(AChars)^;
    Y := PCardinal(Self.Chars)^;
    if (Y <= $ffff) then
    begin
      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
    end;
    if (X = Y) or (X or Y >= $d800) then
    begin
      Result := Self._CompareUTF16String(PUTF16String(@Buffer), True);
      Exit;
    end else
    begin
      Result := Ord(Y > X) * 2 - 1;
      Exit;
    end;
  end;

  Result := (NativeInt(Self.Length) - NativeInt(ALength));
end;


type
  TGap16 = record
    Data: array[0..15] of Byte;
    Size: NativeUInt;
  end;
  PGap16 = ^TGap16;

function Gap16Clear(Data: PByte; Size: NativeUInt; Gap: PGap16): NativeUInt;
begin
  if (Size >= Gap.Size) then
  begin
    Result := Gap.Size;
    TinyMove(Gap.Data, Data^, Result);
    Gap.Size := 0;
  end else
  // Size < Gap.Size
  begin
    Result := Size;
    TinyMove(Gap.Data, Data^, Result);

    TinyMove(Gap.Data[Result], Gap.Data, Gap.Size - Result);
    Dec(Gap.Size, Result);
  end;
end;


{ TTextConvReReader }

constructor TTextConvReReader.Create(const AContext: PTextConvContext;
  const ASource: TCachedReader; const AOwner: Boolean;
  const ABufferSize: NativeUInt);
begin
  FContext := AContext;
  inherited Create(InternalCallback, ASource, AOwner, ABufferSize);
end;

function TTextConvReReader.InternalCallback(const ASender: TCachedBuffer; AData: PByte;
  ASize: NativeUInt): NativeUInt;
var
  LContext: PTextConvContext;
  LReader: TCachedReader;
  LGap: PGap16;
  R: NativeInt;
begin
  LContext := Self.Context;
  LReader := Self.Source;
  LGap := PGap16(@Self.FGap);

  Result := Gap16Clear(AData, ASize, LGap);
  Inc(AData, Result);
  Dec(ASize, Result);

  if (ASize <> 0) and (not LReader.EOF) then
  repeat
    // conversion
    LContext.Destination := AData;
    LContext.DestinationSize := ASize;
    LContext.ModeFinalize := LReader.Finishing;
    LContext.Source := LReader.Current;
    LContext.SourceSize := LReader.Margin;
    R := LContext.Convert;

    // increment
    Inc(AData, LContext.DestinationWritten);
    Dec(ASize, LContext.DestinationWritten);
    Inc(Result, LContext.DestinationWritten);
    Inc(LReader.Current, LContext.SourceRead);

    // next iteration
    if (R <= 0) then
    begin
      // reader buffer fully read
      if (LReader.Finishing) then
      begin
        LReader.EOF := True;
        Exit;
      end else
      begin
        LReader.Flush;
      end;
    end else
    // if (R > 0) then
    begin
      // destination too small
      // convert to Gap
      LContext.Destination := @LGap.Data;
      LContext.DestinationSize := SizeOf(LGap.Data);
      LContext.Source := LReader.Current;
      LContext.SourceSize := LReader.Margin;
      LContext.Convert;

      // converted sizes
      LGap.Size := LContext.DestinationWritten;
      Inc(LReader.Current, LContext.SourceRead);

      // copy Gap bytes
      Inc(Result, Gap16Clear(AData, ASize, LGap));
      Exit;
    end;
  until (False);
end;


{ TTextConvReWriter }

constructor TTextConvReWriter.Create(const AContext: PTextConvContext;
  const ATarget: TCachedWriter; const AOwner: Boolean;
  const ABufferSize: NativeUInt);
begin
  FContext := AContext;
  inherited Create(InternalCallback, ATarget, AOwner, ABufferSize);
end;

function TTextConvReWriter.InternalCallback(const ASender: TCachedBuffer; AData: PByte;
  ASize: NativeUInt): NativeUInt;
var
  LContext: PTextConvContext;
  LWriter: TCachedWriter;
  LGap: PGap16;
  R: NativeInt;
begin
  LContext := Self.Context;
  LWriter := Self.Target;
  LGap := PGap16(@Self.FGap);
  Result := 0;
  if (LWriter.EOF) then Exit;

  LContext.ModeFinalize := (ASize < Self.Memory.Size);
  Inc(LWriter.Current, Gap16Clear(LWriter.Current, LGap.Size, LGap));
  if (NativeUInt(LWriter.Current) >= NativeUInt(LWriter.Overflow)) then LWriter.Flush;

  repeat
    // conversion
    LContext.Source := AData;
    LContext.SourceSize := ASize;
    LContext.Destination := LWriter.Current;
    LContext.DestinationSize := LWriter.Margin + 16;
    R := LContext.Convert;

    // increment
    Inc(AData, LContext.SourceRead);
    Dec(ASize, LContext.SourceRead);
    Inc(Result, LContext.SourceRead);
    Inc(LWriter.Current, LContext.DestinationWritten);

    // next iteration
    if (R > 0) then
    begin
      // writer buffer fully written
      LWriter.Flush;
    end else
    // if (R <= 0) then
    begin
      // data buffer fully read
      TinyMove(AData^, LGap.Data, ASize);
      LGap.Size := ASize;
      Inc(Result, ASize);
      if (NativeUInt(LWriter.Current) >= NativeUInt(LWriter.Overflow)) then LWriter.Flush;
      Exit;
    end;
  until (False);
end;


{ TCachedTextBuffer }

procedure TCachedTextBuffer.Initialize(const AContext: PTextConvContext;
  const ADataBuffer: TCachedBuffer; const AOwner: Boolean);
begin
  Finalize;

  FKind := ADataBuffer.Kind;
  FOwner := AOwner;
  if (AContext <> nil) and
    (@PTextConvContextEx(AContext).FConvertProc <> @TTextConvContextEx.convert_copy) then
  begin
    if (FKind = cbReader) then
    begin
      FTextConverter := TTextConvReReader.Create(AContext, ADataBuffer as TCachedReader);
    end else
    begin
      FTextConverter := TTextConvReWriter.Create(AContext, ADataBuffer as TCachedWriter);
    end;
    FDataBuffer := FTextConverter;
  end else
  begin
    FDataBuffer := ADataBuffer;
  end;

  FieldsCopy;
end;

procedure TCachedTextBuffer.FieldsCopy;
begin
  FCurrent := FDataBuffer.Current;
  FOverflow := FDataBuffer.Overflow;
  FFinishing := TCachedReader(FDataBuffer).Finishing;
  FEOF := FDataBuffer.EOF;
end;

procedure TCachedTextBuffer.Finalize;
begin
  try
    if (FDataBuffer <> nil) then
    try
      try
        FDataBuffer.Current := FCurrent;

        if (FTextConverter <> nil) then
        begin
          if (FKind = cbReader) then
          begin
            FOwner := FOwner or TTextConvReReader(FDataBuffer).Owner;
            TTextConvReReader(FDataBuffer).Owner := False;
            FDataBuffer := TTextConvReReader(FDataBuffer).Source;
          end else
          begin
            FOwner := FOwner or TTextConvReWriter(FDataBuffer).Owner;
            TTextConvReWriter(FDataBuffer).Owner := False;
            FDataBuffer := TTextConvReWriter(FDataBuffer).Target;
          end;

          FreeAndNil(FTextConverter);
        end;
      finally
        if (FOwner) then
        begin
          FDataBuffer.Free;
        end;
      end;
    finally
      FDataBuffer := nil;
      FCurrent := nil;
      FOverflow := nil;
      FFinishing := False;
      FEOF := False;
      FOwner := False;
    end;

  finally
    if (FFileName <> '') then
    begin
      FFileName := '';
    end;
  end;
end;

destructor TCachedTextBuffer.Destroy;
begin
  Finalize;
  inherited;
end;

function TCachedTextBuffer.GetSource: TCachedReader;
begin
  Result := TCachedReader(FDataBuffer);
  if (FTextConverter <> nil) then
    Result := TTextConvReReader(Result).Source;
end;

function TCachedTextBuffer.GetTarget: TCachedWriter;
begin
  Result := TCachedWriter(FDataBuffer);
  if (FTextConverter <> nil) then
    Result := TTextConvReWriter(Result).Target;
end;

function TCachedTextBuffer.GetTextConvReReaderConverter: TTextConvReReader;
begin
  Result := TTextConvReReader(FTextConverter);
end;

function TCachedTextBuffer.GetTextConvReWriterConverter: TTextConvReWriter;
begin
  Result := TTextConvReWriter(FTextConverter);
end;

function TCachedTextBuffer.GetMargin: NativeInt;
var
  P: NativeInt;
begin
  P := NativeInt(FCurrent);
  Result := NativeInt(FOverflow);
  Dec(Result, P);
end;

function TCachedTextBuffer.GetPosition: Int64;
begin
  Result := FDataBuffer.Position;
end;

procedure TCachedTextBuffer.SetEOF(const AValue: Boolean);
begin
  if (AValue) and (FEOF <> AValue) then
  begin
    FDataBuffer.EOF := True;
    FieldsCopy;
  end;
end;

procedure TCachedTextBuffer.OverflowReaderSkip(const ACount: NativeUInt);
begin
  Dec(FCurrent, ACount);
  FDataBuffer.Current := FCurrent;
  try
    (FDataBuffer as TCachedReader).Skip(ACount);
  finally
    FieldsCopy;
  end;
end;

function TCachedTextBuffer.Flush: NativeUInt;
begin
  FDataBuffer.Current := FCurrent;
  try
    Result := FDataBuffer.Flush;
  finally
    FieldsCopy;
  end;
end;


{ TCachedTextReader }

function DetectSBCS(const ACodePage: Word; const AUTF8Compatible: Boolean = True): PTextConvSBCS;
begin
  if (ACodePage = CODEPAGE_UTF8) and (AUTF8Compatible) then
  begin
    Result := nil;
  end else
  begin
    Result := TextConvSBCS(ACodePage);
    if (ACodePage <> 0) and (Result.CodePage <> ACodePage) then
      raise ECachedText.CreateFmt('CP%d is not byte encoding', [ACodePage]);
  end;
end;

function DetectBOM(const ASource: TCachedReader): TBOM;
begin
  if (ASource.Margin < 4) and (not ASource.EOF) then ASource.Flush;

  Result := Tiny.Text.DetectBOM(ASource.Current, ASource.Margin);
  if (Result <> bomNone) then
    Inc(ASource.Current, BOM_INFO[Result].Size);
end;

constructor TCachedTextReader.Create(const AContext: PTextConvContext;
  const ASource: TCachedReader; const AOwner: Boolean);
begin
  inherited Create;
  Initialize(AContext, ASource, AOwner);
end;

function TCachedTextReader.Flush: NativeUInt;
begin
  Result := inherited Flush;
end;

procedure TCachedTextReader.OverflowReadData(var ABuffer; const ACount: NativeUInt);
begin
  FDataBuffer.Current := FCurrent;
  TCachedReader(FDataBuffer).Read(ABuffer, ACount);
  FieldsCopy;
end;

procedure TCachedTextReader.ReadData(var ABuffer; const ACount: NativeUInt);
var
  P: PByte;
begin
  P := FCurrent;
  Inc(P, ACount);

  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowReadData(ABuffer, ACount);
  end else
  begin
    FCurrent := P;
    Dec(P, ACount);
    TinyMove(P^, ABuffer, ACount);
  end;
end;

procedure TCachedTextReader.Skip(const ACount: NativeUInt);
var
  P: PByte;
begin
  P := FCurrent;
  Inc(P, ACount);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowReaderSkip(ACount);
  end else
  begin
    FCurrent := P;
  end;
end;

function TCachedTextReader.FlushReadChar: UCS4Char;
begin
  if (Self.Finishing) then Self.EOF := True
  else Self.Flush;

  Result := Self.ReadChar;
end;

procedure TCachedTextReader.Export(const AWriter: TCachedWriter);
var
  Count: NativeInt;
begin
  while (not Self.EOF) do
  begin
    Count := Self.Margin;
    if (Count > 0) then
    begin
      AWriter.Write(Self.FCurrent^, Count);
      Self.FCurrent := Self.FOverflow;
    end;

    if (Finishing) then
    begin
      SetEOF(True);
    end else
    begin
      Flush;
    end;
  end;
end;

type
  PInternalExportParam = ^TInternalExportParam;
  TInternalExportParam = packed record
    Preallocated: TCachedBufferPreallocatedParam;
    {$ifdef AUTOREFCOUNT}[Unsafe]{$endif} Reader: TCachedTextReader;
    FileName: PString;
  end;

  TInternalFileWriter = class(TCachedFileWriter)
  protected
    constructor PreallocatedCreate(const AParam: Pointer; const ABuffer: Pointer; const ASize: NativeUInt); override;
  end;

constructor TInternalFileWriter.PreallocatedCreate(const AParam: Pointer;
  const ABuffer: Pointer; const ASize: NativeUInt);
var
  LParam: PInternalExportParam;
begin
  LParam := AParam;
  inherited PreallocatedCreate(@LParam.Preallocated, ABuffer, ASize);
  inherited Create(LParam.FileName^);
  LParam.Reader.Export(Self);
end;

procedure TCachedTextReader.Export(const AFileName: string);
var
  LParam: TInternalExportParam;
  LLimit: Int64;
begin
  LParam.Preallocated.PreviousSize := 128;
  LParam.Preallocated.DataAlign := 1024;
  LParam.Preallocated.DataSize := 16 * 1024;
  if (FDataBuffer.Limited) then
  begin
    LLimit := FDataBuffer.Limit shr 1;
    if (LLimit <= 32 * 1024) then
    begin
      LParam.Preallocated.DataSize := NativeUInt((NativeInt(LLimit) + 1023) and - 1024);
    end else
    begin
      LParam.Preallocated.DataSize := 32 * 1024;
    end;
  end;
  LParam.Preallocated.AdditionalSize := 128;

  LParam.Reader := Self;
  LParam.FileName := @AFileName;
  TInternalFileWriter.PreallocatedExecute(@LParam);
end;


{ TByteTextReader }

procedure TByteTextReader.SetSBCS(const AValue: PTextConvSBCS);
begin
  FSBCS := AValue;

  if (AValue = nil) then
  begin
    FEncoding := CODEPAGE_UTF8;
    FNativeFlags := $ff000000;
  end else
  begin
    FEncoding := AValue.CodePage;
    FUCS2 := Pointer(AValue.UCS2);
    FNativeFlags := NativeUInt(AValue.Index) shl 24;
  end;
end;

constructor TByteTextReader.Create(const AEncoding: Word;
  const ASource: TCachedReader; const ADefaultByteEncoding: Word;
  const AOwner: Boolean);
var
  LBOM: TBOM;
  LSBCS, LDefaultSBCS: PTextConvSBCS;
  LContext: PTextConvContext;
begin
  LBOM := DetectBOM(ASource);
  LSBCS := DetectSBCS(AEncoding);
  LDefaultSBCS := DetectSBCS(ADefaultByteEncoding);
  LContext := @Self.FInternalContext;

  if (LBOM = bomNone) and (ADefaultByteEncoding = CODEPAGE_UTF8) then
    LBOM := bomUTF8;

  if (LSBCS = nil) then
  begin
    if (LBOM = bomUTF8) then
    begin
      LContext := nil;
    end else
    begin
      LContext.Init(bomUTF8, LBOM, ADefaultByteEncoding);
    end;
  end else
  if (LBOM = bomNone) then
  begin
    if (LSBCS = LDefaultSBCS) then
    begin
      LContext := nil;
    end else
    begin
      LContext.InitSBCSFromSBCS(LSBCS.CodePage, LDefaultSBCS.CodePage);
    end;
  end else
  begin
    LContext.Init(bomNone, LBOM, AEncoding);
  end;

  SetSBCS(LSBCS);
  inherited Create(LContext, ASource, AOwner);
end;

constructor TByteTextReader.CreateFromFile(const AEncoding: Word;
  const AFileName: string; const ADefaultByteEncoding: Word);
begin
  FFileName := AFileName;
  Create(AEncoding, TCachedFileReader.Create(AFileName), ADefaultByteEncoding, True);
end;

constructor TByteTextReader.CreateDefault(const ASource: TCachedReader;
  const ADefaultByteEncoding: Word; const AOwner: Boolean);
var
  LBOM: TBOM;
  LSBCS: PTextConvSBCS;
  LContext: PTextConvContext;
begin
  LBOM := DetectBOM(ASource);
  LSBCS := DetectSBCS(ADefaultByteEncoding);
  LContext := @Self.FInternalContext;

  if (LBOM = bomNone) then
  begin
    LContext := nil;
  end else
  if (LBOM = bomUTF8) then
  begin
    LSBCS := nil;
    LContext := nil;
  end else
  begin
    if (LSBCS = nil) then
    begin
      LContext.Init(bomUTF8, LBOM);
    end else
    begin
      LContext.Init(bomNone, LBOM, ADefaultByteEncoding);
    end;
  end;

  SetSBCS(LSBCS);
  inherited Create(LContext, ASource, AOwner);
end;

constructor TByteTextReader.CreateDefaultFromFile(const AFileName: string;
  const ADefaultByteEncoding: Word);
begin
  FFileName := AFileName;
  CreateDefault(TCachedFileReader.Create(AFileName), ADefaultByteEncoding, True);
end;

constructor TByteTextReader.CreateDirect(const AContext: PTextConvContext;
  const ASource: TCachedReader; const AOwner: Boolean);
var
  LSBCS: PTextConvSBCS;
begin
  LSBCS := nil{UTF-8};
  if (AContext <> nil) then LSBCS := DetectSBCS(AContext.DestinationCodePage);

  SetSBCS(LSBCS);
  inherited Create(AContext, ASource, AOwner);
end;

function TByteTextReader.ReadChar: UCS4Char;
label
  buffer_too_small;
var
  P: PByte;
  X, Y: NativeUInt;
  LUCS2: PTextConvWB;
begin
  P := Self.FCurrent;

  X := P^;
  Inc(P);
  if (NativeUInt(P) <= NativeUInt(FOverflow)) then
  begin
    if (X <= $7f) then
    begin
      Self.FCurrent := P;
      Result := X;
      Exit;
    end;

    LUCS2 := Self.FUCS2;
    if (LUCS2 <> nil) then
    begin
      X := LUCS2[X];
      Self.FCurrent := P;
      Result := X;
      Exit;
    end;

    X := TEXTCONV_UTF8CHAR_SIZE[X];
    Inc(P, X);
    Dec(P, Byte(X <> 0));
    if (NativeUInt(P) > NativeUInt(FOverflow)) then goto buffer_too_small;
    Self.FCurrent := P;

    Dec(P, X);
    Y := X;
    X := PCardinal(P)^;
    case Y of
      2: if (X and $C0E0 = $80C0) then
         begin
           // X := ((X and $1F) shl 6) or ((X shr 8) and $3F);
           Y := X;
           X := X and $1F;
           Y := Y shr 8;
           X := X shl 6;
           Y := Y and $3F;
           Result := X + Y;
           Exit;
         end;
      3: if (X and $C0C000 = $808000) then
         begin
            // X := ((X & 0x0f) << 12) | ((X & 0x3f00) >> 2) | ((X >> 16) & 0x3f);
           Y := (X and $0F) shl 12;
           Y := Y + (X shr 16) and $3F;
           X := (X and $3F00) shr 2;
           Result := X + Y;
           Exit;
         end;
      4: if (X and $C0C0C000 = $80808000) then
         begin
           // X := (X&07)<<18 | (X&3f00)<<4 | (X>>10)&0fc0 | (X>>24)&3f;
           Y := (X and $07) shl 18;
           Y := Y + (X and $3f00) shl 4;
           Y := Y + (X shr 10) and $0fc0;
           X := (X shr 24) and $3f;
           Result := X + Y;
           Exit;
         end;
    end;

    // unknown:
    Result := UNKNOWN_CHARACTER;
    Exit;
  end else
  begin
  buffer_too_small:
    if (Self.EOF) then Result := 0
    else
    Result := FlushReadChar;
  end;
end;

function TByteTextReader.FlushReadln(var S: ByteString): Boolean;
begin
  if (Self.Finishing) then
  begin
    Self.EOF := True;
  end else
  begin
    Self.Flush;
  end;

  Result := Self.Readln(S);
end;

function TByteTextReader.Readln(var S: ByteString): Boolean;
type
  TSelf = TByteTextReader;
label
  next_char, done, done_one, flush_recall;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  CR_XOR_MASK = $0d0d0d0d; // \r
  LF_XOR_MASK = $0a0a0a0a; // \n
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
  ASCII_MASK = Integer($80808080);
var
  P, Top: PByte;
  X, T, V, Flags: NativeInt;

  {$ifdef CPUX86}
  Store: record
    Self: Pointer;
    S: PByteString;
  end;
  _S: PByteString;
  {$endif}
begin
  S.F.NativeFlags := Self.FNativeFlags;
  P := Pointer(Self.FCurrent);
  PByte(S.FChars) := P;
  Flags := NativeUInt(Self.Overflow);
  Dec(Flags, NativeUInt(P));

  {$ifdef CPUX86}
    Store.Self := Pointer(Self);
    Store.S := @S;
  {$endif}

  if (NativeInt(Flags) >= SizeOf(AnsiChar)) then
  begin
    Top := P;
    Inc(Top, Flags);

    // ascii, \r, \n
    Flags := -1;
    X := -1;
    Dec(Top, CHARS_IN_CARDINAL);
    repeat
      Flags := Flags and X;
      if (NativeUInt(P) > NativeUInt(Top)) then Break;
      X := PCardinal(P)^;
      Inc(P, CHARS_IN_CARDINAL);

      T := (X xor CR_XOR_MASK);
      X := (X xor LF_XOR_MASK);
      V := T + SUB_MASK;
      T := not T;
      T := T and V;
      V := X + SUB_MASK;
      X := (not X);
      V := V and X;

      T := T or V;
      if (T and OVERFLOW_MASK = 0) then Continue;
      Dec(P, CHARS_IN_CARDINAL);
      T := Byte(Byte(T and $80 = 0) + Byte(T and $8080 = 0) + Byte(T and $808080 = 0));
      Flags := Flags and (X or NativeInt(BYTE_NOTMASKS[T]));
      Inc(P, T);
      Break;
    until (False);
    Inc(Top, CHARS_IN_CARDINAL);
    Flags := not Flags;
    if (P = Top) then goto done;

  next_char:
    X := P^;
    Flags := Flags or X;
    Inc(P);
    if (X <> $0a) then
    begin
      if (X <> $0d) then
      begin
        if (P <> Top) then goto next_char;
      done:
        if (not {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Finishing) then goto flush_recall;
        {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.FCurrent := Pointer(P);
        Inc(P);
      end else
      begin
        // #13
        if (P = Top) then
        begin
          if (not {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Finishing) then goto flush_recall;
          goto done_one;
        end else
        begin
          if (P^ <> $0a) then goto done_one;
          Inc(P);
          {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.FCurrent := Pointer(P);
          Dec(P);
        end;
      end;
    end else
    begin
      // #10
    done_one:
      {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.FCurrent := Pointer(P);
    end;

    Dec(P);
    {$ifdef CPUX86}_S := Store.S;{$endif}
    {$ifdef CPUX86}_S{$else}S{$endif}.F.Ascii := (Flags and ASCII_MASK = 0);
    Flags{BytesCount} := NativeUInt(P) - NativeUInt({$ifdef CPUX86}_S{$else}S{$endif}.FChars);
    {$ifdef CPUX86}_S{$else}S{$endif}.Length := Flags{BytesCount};
    Result := True;
    Exit;
  end else
  begin
    if ({$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.EOF) then
    begin
      Result := False;
    end else
    begin
    flush_recall:
      Result := {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.FlushReadln(
        {$ifdef CPUX86}Store.S^{$else}S{$endif});
    end;
  end;
end;

function TByteTextReader.Readln(var S: UnicodeString): Boolean;
var
  Str: ByteString;
begin
  if (not Self.Readln(Str)) then
  begin
    {$ifdef UNICODE}
      UStrClear(S);
    {$else}
      WStrClear(S);
    {$endif}
    Result := False;
  end else
  begin
    {$ifdef UNICODE}
      Str.ToUnicodeString(S);
    {$else}
      Str.ToWideString(S);
    {$endif}
    Result := True;
  end;
end;

procedure TByteTextReader.Export(const AWriter: TCachedWriter);
begin
  if (Encoding = CODEPAGE_UTF8) then
  begin
    AWriter.Write(BOM_INFO[bomUTF8].Data, BOM_INFO[bomUTF8].Size);
  end;

  inherited Export(AWriter);
end;


{ TUTF16TextReader }

constructor TUTF16TextReader.Create(const ASource: TCachedReader;
  const ADefaultByteEncoding: Word; const AOwner: Boolean);
var
  LBOM: TBOM;
  LContext: PTextConvContext;
begin
  LBOM := DetectBOM(ASource);
  {Check}DetectSBCS(ADefaultByteEncoding);
  LContext := @Self.FInternalContext;

  if (LBOM = bomUTF16) then
  begin
    LContext := nil;
  end else
  begin
    if (LBOM = bomNone) and (ADefaultByteEncoding = CODEPAGE_UTF8) then
      LBOM := bomUTF8;

    LContext.Init(bomUTF16, LBOM, ADefaultByteEncoding);
  end;

  inherited Create(LContext, ASource, AOwner);
end;

constructor TUTF16TextReader.CreateFromFile(const AFileName: string;
  const ADefaultByteEncoding: Word);
begin
  FFileName := AFileName;
  Create(TCachedFileReader.Create(AFileName), ADefaultByteEncoding, True);
end;

constructor TUTF16TextReader.CreateDirect(const AContext: PTextConvContext;
  const ASource: TCachedReader; const AOwner: Boolean);
begin
  inherited Create(AContext, ASource, AOwner);
end;

function TUTF16TextReader.ReadChar: UCS4Char;
label
  buffer_too_small, unknown, done;
var
  X, Y: NativeUInt;
begin
  Y{P} := NativeUInt(Self.FCurrent);

  X := PWord(Y{P})^;
  Inc(Y{P}, SizeOf(UnicodeChar));
  if (Y{P} <= NativeUInt(FOverflow)) then
  begin
    if (X < $d800) then
    begin
    done:
      Self.FCurrent := Pointer(Y{P});
      Result := X;
      Exit;
    end;
    if (X >= $e000) then goto done;
    if (X >= $dc00) then goto unknown;

    Inc(Y{P}, SizeOf(UnicodeChar));
    if (Y{P} > NativeUInt(FOverflow)) then goto buffer_too_small;
    Self.FCurrent := Pointer(Y{P});

    Dec(Y{P}, SizeOf(UnicodeChar));
    Y := PWord(Y{P})^;
    Dec(Y, $dc00);
    Dec(X, $d800);
    if (Y >= ($e000-$dc00)) then goto unknown;
    X := X shl 10;
    Inc(Y, $10000);
    Inc(X, Y);
    Result := X;
    Exit;

  unknown:
    X := UNKNOWN_CHARACTER;
    goto done;
  end else
  begin
  buffer_too_small:
    if (Self.EOF) then Result := 0
    else
    Result := FlushReadChar;
  end;
end;

function TUTF16TextReader.FlushReadln(var S: UTF16String): Boolean;
begin
  if (Self.Finishing) then
  begin
    Self.EOF := True;
  end else
  begin
    Self.Flush;
  end;

  Result := Self.Readln(S);
end;

function TUTF16TextReader.Readln(var S: UTF16String): Boolean;
type
  TSelf = TUTF16TextReader;
label
  next_char, done, done_one, flush_recall;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
  CR_XOR_MASK = $000d000d; // \r
  LF_XOR_MASK = $000a000a; // \n
  SUB_MASK  = Integer(-$00010001);
  OVERFLOW_MASK = Integer($80008000);
  ASCII_MASK = Integer($ff80ff80);
var
  P, Top: PWord;
  X, T, V, Flags: NativeInt;

  {$ifdef CPUX86}
  Store: record
    Self: Pointer;
    S: PUTF16String;
  end;
  _S: PUTF16String;
  {$endif}
begin
  P := Pointer(Self.FCurrent);
  PWord(S.FChars) := P;
  Flags := NativeUInt(Self.Overflow);
  Dec(Flags, NativeUInt(P));

  {$ifdef CPUX86}
    Store.Self := Pointer(Self);
    Store.S := @S;
  {$endif}

  if (NativeInt(Flags) >= SizeOf(UnicodeChar)) then
  begin
    Flags := Flags shr 1;
    Top := @PWordArray(P)[Flags];

    // ascii, \r, \n
    Flags := -1;
    X := -1;
    Dec(Top, CHARS_IN_CARDINAL);
    repeat
      Flags := Flags and X;
      if (NativeUInt(P) > NativeUInt(Top)) then Break;
      X := PCardinal(P)^;
      Inc(P, CHARS_IN_CARDINAL);

      T := (X xor CR_XOR_MASK);
      X := (X xor LF_XOR_MASK);
      V := T + SUB_MASK;
      T := not T;
      T := T and V;
      V := X + SUB_MASK;
      X := (not X);
      V := V and X;

      T := T or V;
      if (T and OVERFLOW_MASK = 0) then Continue;
      Dec(P, CHARS_IN_CARDINAL);
      T := {0/2}Byte(T and $8000 = 0) * 2;
      Flags := Flags and (X or NativeInt(BYTE_NOTMASKS[T]));
      Inc(NativeUInt(P), T);
      Break;
    until (False);
    Inc(Top, CHARS_IN_CARDINAL);
    Flags := not Flags;
    if (P = Top) then goto done;

  next_char:
    X := P^;
    Flags := Flags or X;
    Inc(P);
    if (X <> $0a) then
    begin
      if (X <> $0d) then
      begin
        if (P <> Top) then goto next_char;
      done:
        if (not {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Finishing) then goto flush_recall;
        {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.FCurrent := Pointer(P);
        Inc(P);
      end else
      begin
        // #13
        if (P = Top) then
        begin
          if (not {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Finishing) then goto flush_recall;
          goto done_one;
        end else
        begin
          if (P^ <> $0a) then goto done_one;
          Inc(P);
          {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.FCurrent := Pointer(P);
          Dec(P);
        end;
      end;
    end else
    begin
      // #10
    done_one:
      {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.FCurrent := Pointer(P);
    end;

    Dec(P);
    {$ifdef CPUX86}_S := Store.S;{$endif}
    {$ifdef CPUX86}_S{$else}S{$endif}.F.NativeFlags := Byte(Flags and ASCII_MASK = 0);
    Flags{BytesCount} := NativeUInt(P) - NativeUInt({$ifdef CPUX86}_S{$else}S{$endif}.FChars);
    {$ifdef CPUX86}_S{$else}S{$endif}.Length := Flags{BytesCount} shr 1;
    Result := True;
    Exit;
  end else
  begin
    if ({$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.EOF) then
    begin
      Result := False;
    end else
    begin
    flush_recall:
      Result := {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.FlushReadln(
        {$ifdef CPUX86}Store.S^{$else}S{$endif});
    end;
  end;
end;

function TUTF16TextReader.Readln(var S: UnicodeString): Boolean;
var
  Str: UTF16String;
begin
  if (not Self.Readln(Str)) then
  begin
    {$ifdef UNICODE}
      UStrClear(S);
    {$else}
      WStrClear(S);
    {$endif}
    Result := False;
  end else
  begin
    {$ifdef UNICODE}
      Str.ToUnicodeString(S);
    {$else}
      Str.ToWideString(S);
    {$endif}
    Result := True;
  end;
end;

procedure TUTF16TextReader.Export(const AWriter: TCachedWriter);
begin
  AWriter.Write(BOM_INFO[bomUTF16].Data, BOM_INFO[bomUTF16].Size);
  inherited Export(AWriter);
end;


{ TUTF32TextReader }

constructor TUTF32TextReader.Create(const ASource: TCachedReader;
  const ADefaultByteEncoding: Word; const AOwner: Boolean);
var
  LBOM: TBOM;
  LContext: PTextConvContext;
begin
  LBOM := DetectBOM(ASource);
  {Check}DetectSBCS(ADefaultByteEncoding);
  LContext := @Self.FInternalContext;

  if (LBOM = bomUTF32) then
  begin
    LContext := nil;
  end else
  begin
    if (LBOM = bomNone) and (ADefaultByteEncoding = CODEPAGE_UTF8) then
      LBOM := bomUTF8;

    LContext.Init(bomUTF32, LBOM, ADefaultByteEncoding);
  end;

  inherited Create(LContext, ASource, AOwner);
end;

constructor TUTF32TextReader.CreateFromFile(const AFileName: string;
  const ADefaultByteEncoding: Word);
begin
  FFileName := AFileName;
  Create(TCachedFileReader.Create(AFileName), ADefaultByteEncoding, True);
end;

constructor TUTF32TextReader.CreateDirect(const AContext: PTextConvContext;
  const ASource: TCachedReader; const AOwner: Boolean);
begin
  inherited Create(AContext, ASource, AOwner);
end;

function TUTF32TextReader.ReadChar: UCS4Char;
var
  P: PCardinal;
  X: NativeUInt;
begin
  P := Pointer(Self.FCurrent);

  X := P^;
  Inc(P);
  if (NativeUInt(P) <= NativeUInt(FOverflow)) then
  begin
    Self.FCurrent := Pointer(P);
    Result := X;
    Exit;
  end else
  begin
    if (Self.EOF) then Result := 0
    else
    Result := FlushReadChar;
  end;
end;

function TUTF32TextReader.FlushReadln(var S: UTF32String): Boolean;
begin
  if (Self.Finishing) then
  begin
    Self.EOF := True;
  end else
  begin
    Self.Flush;
  end;

  Result := Self.Readln(S);
end;

function TUTF32TextReader.Readln(var S: UTF32String): Boolean;
label
  done_one, flush_recall;
var
  P, Top: PCardinal;
  X, Flags: NativeUInt;
begin
  P := Pointer(Self.FCurrent);
  S.Chars := Pointer(P);
  Flags := NativeUInt(Self.Overflow);
  Dec(Flags, NativeUInt(P));

  if (NativeInt(Flags) >= SizeOf(UCS4Char)) then
  begin
    Flags := Flags shr 2;
    Top := @PUTF32CharArray(P)[Flags];
    Flags := 0;

    repeat
      X := P^;
      Inc(P);
      Flags := Flags or X;

      if (X <> $0a) then
      begin
        if (X <> $0d) then
        begin
          if (P <> Top) then Continue;
          if (not Self.Finishing) then goto flush_recall;
          Self.FCurrent := Pointer(P);
          Inc(P);
        end else
        begin
          // #13
          if (P = Top) then
          begin
            if (not Self.Finishing) then goto flush_recall;
            goto done_one;
          end else
          begin
            if (P^ <> $0a) then goto done_one;
            Inc(P);
            Self.FCurrent := Pointer(P);
            Dec(P);
          end;
        end;
      end else
      begin
        // #10
      done_one:
        Self.FCurrent := Pointer(P);
      end;

      Dec(P);
      S.F.NativeFlags := Byte(Flags <= $7f);
      Flags{BytesCount} := NativeUInt(P) - NativeUInt(S.FChars);
      S.Length := Flags{BytesCount} shr 2;
      Result := True;
      Exit;
    until (False);
  end else
  begin
    if (Self.EOF) then
    begin
      Result := False;
    end else
    begin
    flush_recall:
      Result := FlushReadln(S);
    end;
  end;
end;

function TUTF32TextReader.Readln(var S: UnicodeString): Boolean;
var
  Str: UTF32String;
begin
  if (not Self.Readln(Str)) then
  begin
    {$ifdef UNICODE}
      UStrClear(S);
    {$else}
      WStrClear(S);
    {$endif}
    Result := False;
  end else
  begin
    {$ifdef UNICODE}
      Str.ToUnicodeString(S);
    {$else}
      Str.ToWideString(S);
    {$endif}
    Result := True;
  end;
end;

procedure TUTF32TextReader.Export(const AWriter: TCachedWriter);
begin
  AWriter.Write(BOM_INFO[bomUTF32].Data, BOM_INFO[bomUTF32].Size);
  inherited Export(AWriter);
end;


{ TStringBuffer }

function TStringBuffer.Resize(const ASize, AMemoryDelta: NativeUInt): Pointer;
begin
  FSize := (ASize + AMemoryDelta - 1) and (-AMemoryDelta);
  SetLength(FData, FSize);
  Result := Pointer(FData);
end;

function TStringBuffer.Allocate(const ASize: NativeUInt): Pointer;
begin
  Result := Pointer(FData);

  if (Result = nil) or (ASize > Self.FSize) then
    Result := Self.Resize(ASize);
end;

procedure TStringBuffer.Clear;
var
  V: NativeUInt;
begin
  V := 0;
  FEncoding.NativeFlags := V;
  FBuffer.Chars := Pointer(V);
  FBuffer.Length := V;
  FBuffer.NativeFlags := V;

  // inherited Clear;
  FSize := V;
  if (Pointer(FData) <> nil) then
    FData := nil;
end;

function TStringBuffer.InitByteString(const ACodePage: Word; const ALength: NativeUInt): PByteString;
var
  LIndex: NativeUInt;
  LValue: Integer;
  LSBCS: PTextConvSBCS;

  P: PStrRec;
  LSize: NativeUInt;
begin
  Self.FBuffer.Length := ALength;

  if (ACodePage = CODEPAGE_UTF8) then
  begin
    Self.FEncoding.Flags := $ff000000 or CODEPAGE_UTF8 or (Ord(csByte) shl 16);
    Self.FBuffer.Flags := $ff000000 + ((ALength - 1) shr 31){ALength = 0};
    LSize := ALength;
  end else
  begin
    LIndex := NativeUInt(ACodePage);
    LValue := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[LIndex and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(LValue) = ACodePage) or (LValue < 0) then Break;
      LValue := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(LValue) shr 24]);
    until (False);

    LIndex := Byte(LValue shr 16);
    LSBCS := Pointer(LIndex * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    LIndex := LIndex shl 24;
    Inc(LIndex, LSBCS.CodePage);
    Inc(LIndex, Ord(csByte) shl 16);

    LSize := Self.FBuffer.Length;
    Self.FEncoding.NativeFlags := LIndex;
    Self.FBuffer.NativeFlags := (LIndex and $ff000000) + Byte(LSize = 0);
  end;

  if (LSize <> 0) then
  begin
    P := Pointer(Self.FData);
    LSize := LSize + (SizeOf(TStrRec) + SizeOf(UCS4Char));
    if (P = nil) or (LSize > Self.FSize) then P := Self.Resize(LSize);

    Inc(P);
    Self.FBuffer.Chars := P;
  end;

  Result := @Self.FBuffer.CastByteString;
end;

function TStringBuffer.InitUTF16String(const ALength: NativeUInt): PUTF16String;
var
  P: PStrRec;
  LSize: NativeUInt;
begin
  Self.FBuffer.Length := ALength;
  Self.FEncoding.Flags := $ff000000 or CODEPAGE_UTF16 or (Ord(csUTF16) shl 16);
  Self.FBuffer.NativeFlags := Byte(ALength = 0);

  if (ALength <> 0) then
  begin
    P := Pointer(Self.FData);
    LSize := ALength + ALength + (SizeOf(TStrRec) + SizeOf(UCS4Char));
    if (P = nil) or (LSize > Self.FSize) then P := Self.Resize(LSize);

    Inc(P);
    Self.FBuffer.Chars := P;
  end;

  Result := @Self.FBuffer.CastUTF16String;
end;

function TStringBuffer.InitUTF32String(const ALength: NativeUInt): PUTF32String;
var
  P: PStrRec;
  ASize: NativeUInt;
begin
  Self.FBuffer.Length := ALength;
  Self.FEncoding.Flags := $ff000000 or CODEPAGE_UTF32 or (Ord(csUTF32) shl 16);
  Self.FBuffer.NativeFlags := Byte(ALength = 0);

  if (ALength <> 0) then
  begin
    P := Pointer(Self.FData);
    ASize := (ALength shl 2) + (SizeOf(TStrRec) + SizeOf(UCS4Char));
    if (P = nil) or (ASize > Self.FSize) then P := Self.Resize(ASize);

    Inc(P);
    Self.FBuffer.Chars := P;
  end;

  Result := @Self.FBuffer.CastUTF32String;
end;

function TStringBuffer.InitString(const ALength: NativeUInt = 0):
  {$ifdef UNICODE}PUTF16String{$else}PByteString{$endif};
begin
  {$ifdef UNICODE}
    Result := InitUTF16String(ALength);
  {$else}
    Result := InitByteString(0, ALength);
  {$endif};
end;


type
  TTinyStringConversion = function(ADest: Pointer; const ASource{TinyString}; AFlags: NativeUInt): {ResultLength}NativeUInt;
  TCharactersConversion = function(ADest, ASrc: Pointer; ALength: NativeUInt): {ResultLength}NativeUInt;
  TCharactersConversionEx = function(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): {ResultLength}NativeUInt;

function MoveBytes(ADest, ASrc: Pointer; ALength: NativeUInt): NativeUInt;
begin
  TinyMove(ASrc^, ADest^, ALength);
  Result := ALength;
end;

function MoveWords(ADest, ASrc: Pointer; ALength: NativeUInt): NativeUInt;
begin
  TinyMove(ASrc^, ADest^, ALength shl 1);
  Result := ALength shl 1;
end;

procedure utf32_from_ascii(ADest: PCardinal; ASrc: PByte; ALength: NativeUInt);
var
  i: NativeUInt;
begin
  if (ALength <> 0) then
  for i := 0 to NativeInt(ALength) - 1 do
    PUTF32CharArray(ADest)[i] := PByteCharArray(ASrc)[i];
end;

procedure TStringBuffer.InternalAppend(const AMaxAppendSize: NativeUInt;
  const ASource; const AFlags: NativeUInt; const AConversion: Pointer);
const
  SHIFT_VALUES: array[TTinyStringKind] of Byte = (0, 0, 1, 2);
var
  P: PByte;
  LSize, LOffset: NativeUInt;
begin
  LSize := SizeOf(UCS4Char) + AMaxAppendSize;
  LOffset := SizeOf(TStrRec) + (Self.FBuffer.Length shl SHIFT_VALUES[Self.FEncoding.StringKind]);
  LSize := LSize + LOffset;

  P := Pointer(Self.FData);
  if (P = nil) or (LSize > Self.FSize) then
  begin
    NativeUInt(Self.FString) := LOffset;
      P := Self.Resize(LSize);
    LOffset := NativeUInt(Self.FString);
  end;

  Inc(P, SizeOf(TStrRec));
  Dec(LOffset, SizeOf(TStrRec));
  Self.FBuffer.Chars := P;

  Inc(P, LOffset);
  Inc(Self.FBuffer.Length, TTinyStringConversion(AConversion)(P, ASource, AFlags));
end;

{$ifdef FPC}
function TextConv_utf16_from_utf8(ADest, ASrc: Pointer; ALength: NativeUInt): NativeUInt; forward;
{$endif}

procedure TStringBuffer.AppendAscii(const AChars: PAnsiChar; const ALength: NativeUInt);
const
  SHIFT_VALUES: array[0..2] of Byte = (0, 1, 2);
  CALLBACKS: array[0..2] of {TCharactersConversion} Pointer =
  (
     @Tiny.Cache.Text.MoveBytes,
     @{$ifdef FPC}TextConv_utf16_from_utf8{$else}Tiny.Text.utf16_from_utf8{$endif},
     @Tiny.Cache.Text.utf32_from_ascii
  );
var
  P: PByte;
  LKind, LSize, LOffset: NativeUInt;
  Store: record
    AChars: PAnsiChar;
    ALength: NativeUInt;
  end;
begin
  if (ALength = 0) then Exit;
  Store.AChars := AChars;
  Store.ALength := ALength;

  LSize := ALength;
  LOffset := Self.FBuffer.Length;
  Inc(LOffset, LSize{ALength});
  Self.FBuffer.Length := LOffset;
  Dec(LOffset, LSize{ALength});

  LKind := Byte(Self.FEncoding.StringKind);
  Dec(LKind);

  if (LKind > High(SHIFT_VALUES)) then
    raise ETinyString.Create(Pointer(@SStringNotInitialized));

  LOffset := LOffset shl SHIFT_VALUES[LKind];
  LSize := LSize{ALength} shl SHIFT_VALUES[LKind];
  Inc(LOffset, SizeOf(TStrRec));
  Inc(LSize, SizeOf(UCS4Char));
  Inc(LSize, LOffset);

  P := Pointer(Self.FData);
  if (P = nil) or (LSize > Self.FSize) then P := Self.Resize(LSize);

  Inc(P, SizeOf(TStrRec));
  Dec(LOffset, SizeOf(TStrRec));
  Self.FBuffer.Chars := P;

  Inc(P, LOffset);
  TCharactersConversion(CALLBACKS[LKind])(P, Store.AChars, Store.ALength);
end;

{$ifdef FPC}
function TextConv_sbcs_from_sbcs(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Tiny.Text.sbcs_from_sbcs(ADest, ASrc, ALength, AConverter);
  Result := 0;
end;

function TextConv_sbcs_from_sbcs_lower(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Tiny.Text.sbcs_from_sbcs_lower(ADest, ASrc, ALength, AConverter);
  Result := 0;
end;

function TextConv_sbcs_from_sbcs_upper(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Tiny.Text.sbcs_from_sbcs_upper(ADest, ASrc, ALength, AConverter);
  Result := 0
end;

function TextConv_utf8_from_sbcs(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.utf8_from_sbcs(ADest, ASrc, ALength, AConverter);
end;

function TextConv_utf8_from_sbcs_lower(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.utf8_from_sbcs_lower(ADest, ASrc, ALength, AConverter);
end;

function TextConv_utf8_from_sbcs_upper(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.utf8_from_sbcs_upper(ADest, ASrc, ALength, AConverter);
end;

function TextConv_sbcs_from_utf8(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.sbcs_from_utf8(ADest, ASrc, ALength, AConverter);
end;

function TextConv_sbcs_from_utf8_lower(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.sbcs_from_utf8_lower(ADest, ASrc, ALength, AConverter);
end;

function TextConv_sbcs_from_utf8_upper(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.sbcs_from_utf8_upper(ADest, ASrc, ALength, AConverter);
end;

function TextConv_utf8_from_utf8_lower(ADest, ASrc: Pointer; ALength: NativeUInt): NativeUInt;
begin
  Result := Tiny.Text.utf8_from_utf8_lower(ADest, ASrc, ALength);
end;

function TextConv_utf8_from_utf8_upper(ADest, ASrc: Pointer; ALength: NativeUInt): NativeUInt;
begin
  Result := Tiny.Text.utf8_from_utf8_upper(ADest, ASrc, ALength);
end;
{$endif}

function ConvertByteFromByte(ADest: PByte; const ASource: ByteString;
  AFlags{
         CharCase: TCharCase;
         Align: Word;
         DestSBCSIndex: ShortInt;
       }: NativeUInt): NativeUInt;
label
  universal_sbcs_converter, utf8_converter;
const
  SBCS_FROM_SBCS: array[0..2{CharCase}] of {TCharactersConversionEx} Pointer =
  (
     @{$ifdef FPC}TextConv_sbcs_from_sbcs{$else}Tiny.Text.sbcs_from_sbcs{$endif},
     @{$ifdef FPC}TextConv_sbcs_from_sbcs_lower{$else}Tiny.Text.sbcs_from_sbcs_lower{$endif},
     @{$ifdef FPC}TextConv_sbcs_from_sbcs_upper{$else}Tiny.Text.sbcs_from_sbcs_upper{$endif}
  );
  UTF8_FROM_SBCS: array[0..2{CharCase}] of {TCharactersConversionEx} Pointer =
  (
     @{$ifdef FPC}TextConv_utf8_from_sbcs{$else}Tiny.Text.utf8_from_sbcs{$endif},
     @{$ifdef FPC}TextConv_utf8_from_sbcs_lower{$else}Tiny.Text.utf8_from_sbcs_lower{$endif},
     @{$ifdef FPC}TextConv_utf8_from_sbcs_upper{$else}Tiny.Text.utf8_from_sbcs_upper{$endif}
  );
  SBCS_FROM_UTF8: array[0..2{CharCase}] of {TCharactersConversionEx} Pointer =
  (
     @{$ifdef FPC}TextConv_sbcs_from_utf8{$else}Tiny.Text.sbcs_from_utf8{$endif},
     @{$ifdef FPC}TextConv_sbcs_from_utf8_lower{$else}Tiny.Text.sbcs_from_utf8_lower{$endif},
     @{$ifdef FPC}TextConv_sbcs_from_utf8_upper{$else}Tiny.Text.sbcs_from_utf8_upper{$endif}
  );
  UTF8_FROM_UTF8: array[0..2{CharCase}] of {TCharactersConversion} Pointer =
  (
     @MoveBytes,
     @{$ifdef FPC}TextConv_utf8_from_utf8_lower{$else}Tiny.Text.utf8_from_utf8_lower{$endif},
     @{$ifdef FPC}TextConv_utf8_from_utf8_upper{$else}Tiny.Text.utf8_from_utf8_upper{$endif}
  );
var
  LSrcSBCSIndex, LDestSBCSIndex: NativeInt;
  LConverter: Pointer;
begin
  LDestSBCSIndex := AFlags shr 24;
  AFlags := Byte(AFlags);
  LSrcSBCSIndex := ASource.SBCSIndex;

  if (ASource.Ascii) then
    goto utf8_converter;

  if (LSrcSBCSIndex >= 0) then
  begin
    LSrcSBCSIndex := LSrcSBCSIndex * SizeOf(TTextConvSBCS);
    Inc(LSrcSBCSIndex, NativeInt(@TEXTCONV_SUPPORTED_SBCS));

    if (LDestSBCSIndex <= $7f) then
    begin
      // SBCS <-- SBCS
      LDestSBCSIndex := LDestSBCSIndex * SizeOf(TTextConvSBCS);
      Inc(LDestSBCSIndex, NativeInt(@TEXTCONV_SUPPORTED_SBCS));

      if (LSrcSBCSIndex = LDestSBCSIndex) then
      begin
        case AFlags of
          Ord(ccLower):
          begin
            LConverter := PTextConvSBCSEx(LDestSBCSIndex).FLowerCase;
            if (LConverter = nil) then goto universal_sbcs_converter;
          end;
          Ord(ccUpper):
          begin
            LConverter := PTextConvSBCSEx(LDestSBCSIndex).FUpperCase;
            if (LConverter = nil) then goto universal_sbcs_converter;
          end;
        else
          // Ord(ccOriginal):
          Result := MoveBytes(ADest, ASource.Chars, ASource.Length);
          Exit;
        end;
      end else
      begin
      universal_sbcs_converter:
        LConverter := PTextConvSBCS(LDestSBCSIndex).FromSBCS(PTextConvSBCS(LSrcSBCSIndex), TCharCase(AFlags));
      end;

      TCharactersConversionEx{procedure}(SBCS_FROM_SBCS[AFlags])(ADest, ASource.Chars,
        ASource.Length, LConverter);
      Result := ASource.Length;
    end else
    begin
      // UTF8 <-- SBCS
      LConverter := PTextConvSBCSEx(LSrcSBCSIndex).FUTF8.NumericItems[AFlags];
      if (LConverter = nil) then LConverter := PTextConvSBCSEx(LSrcSBCSIndex).AllocFillUTF8(PTextConvSBCSEx(LSrcSBCSIndex).FUTF8.NumericItems[AFlags], TCharCase(AFlags));
      Result := TCharactersConversionEx(UTF8_FROM_SBCS[AFlags])(ADest, ASource.Chars,
        ASource.Length, LConverter);
    end;
  end else
  begin
    if (LDestSBCSIndex <= $7f) then
    begin
      // SBCS <-- UTF8
      LDestSBCSIndex := LDestSBCSIndex * SizeOf(TTextConvSBCS);
      Inc(LDestSBCSIndex, NativeInt(@TEXTCONV_SUPPORTED_SBCS));
      LConverter := PTextConvSBCSEx(LDestSBCSIndex).FVALUES;
      if (LConverter = nil) then LConverter := PTextConvSBCSEx(LDestSBCSIndex).AllocFillVALUES(PTextConvSBCSEx(LDestSBCSIndex).FVALUES);
      Result := TCharactersConversionEx(SBCS_FROM_UTF8[AFlags])(ADest, ASource.Chars,
        ASource.Length, LConverter);
    end else
    begin
      // UTF8 <-- UTF8
    utf8_converter:
      Result := TCharactersConversion(UTF8_FROM_UTF8[AFlags])(ADest, ASource.Chars, ASource.Length);
    end;
  end;
end;

{$ifdef FPC}
function TextConv_sbcs_from_utf16(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.sbcs_from_utf16(ADest, ASrc, ALength, AConverter);
end;

function TextConv_sbcs_from_utf16_lower(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.sbcs_from_utf16_lower(ADest, ASrc, ALength, AConverter);
end;

function TextConv_sbcs_from_utf16_upper(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.sbcs_from_utf16_upper(ADest, ASrc, ALength, AConverter);
end;

function TextConv_utf8_from_utf16(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.utf8_from_utf16(ADest, ASrc, ALength);
end;

function TextConv_utf8_from_utf16_lower(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.utf8_from_utf16_lower(ADest, ASrc, ALength);
end;

function TextConv_utf8_from_utf16_upper(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Result := Tiny.Text.utf8_from_utf16_upper(ADest, ASrc, ALength);
end;
{$endif}

function ConvertByteFromUTF16(LDest: PByte; const LSource: UTF16String;
  AFlags{
         CharCase: TCharCase;
         Align: Word;
         DestSBCSIndex: ShortInt;
       }: NativeUInt): NativeUInt;
const
  SBCS_FROM_UTF16: array[0..2{CharCase}] of {TCharactersConversionEx} Pointer =
  (
     @{$ifdef FPC}TextConv_sbcs_from_utf16{$else}Tiny.Text.sbcs_from_utf16{$endif},
     @{$ifdef FPC}TextConv_sbcs_from_utf16_lower{$else}Tiny.Text.sbcs_from_utf16_lower{$endif},
     @{$ifdef FPC}TextConv_sbcs_from_utf16_upper{$else}Tiny.Text.sbcs_from_utf16_upper{$endif}
  );
  UTF8_FROM_UTF16: array[0..2{CharCase}] of {TCharactersConversion} Pointer =
  (
     @{$ifdef FPC}TextConv_utf8_from_utf16{$else}Tiny.Text.utf8_from_utf16{$endif},
     @{$ifdef FPC}TextConv_utf8_from_utf16_lower{$else}Tiny.Text.utf8_from_utf16_lower{$endif},
     @{$ifdef FPC}TextConv_utf8_from_utf16_upper{$else}Tiny.Text.utf8_from_utf16_upper{$endif}
  );
var
  LDestSBCSIndex: NativeInt;
  LConverter: Pointer;
begin
  LDestSBCSIndex := AFlags shr 24;
  AFlags := Byte(AFlags);

  if (not LSource.Ascii) and (LDestSBCSIndex <= $7f) then
  begin
    // SBCS <-- UTF16
    LDestSBCSIndex := LDestSBCSIndex * SizeOf(TTextConvSBCS);
    Inc(LDestSBCSIndex, NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    LConverter := PTextConvSBCSEx(LDestSBCSIndex).FVALUES;
    if (LConverter = nil) then LConverter := PTextConvSBCSEx(LDestSBCSIndex).AllocFillVALUES(PTextConvSBCSEx(LDestSBCSIndex).FVALUES);
    Result := TCharactersConversionEx(SBCS_FROM_UTF16[AFlags])(LDest, LSource.Chars,
      LSource.Length, LConverter);
  end else
  begin
    // UTF8 <-- UTF16
    Result := TCharactersConversion(UTF8_FROM_UTF16[AFlags])(LDest, LSource.Chars, LSource.Length);
  end;
end;

function ConvertByteFromUTF32(ADest: PByte; const ASource: UTF32String;
  AFlags{
         CharCase: TCharCase;
         Align: Word;
         DestSBCSIndex: ShortInt;
       }: NativeUInt): NativeUInt;
const
  ASCII_FROM_UTF32: array[0..2{CharCase}] of {TCharactersConversion} Pointer =
  (
     @Tiny.Cache.Text.ascii_from_utf32,
     @Tiny.Cache.Text.ascii_from_utf32_lower,
     @Tiny.Cache.Text.ascii_from_utf32_upper
  );
  UTF8_FROM_UTF32: array[0..2{CharCase}] of {TCharactersConversion} Pointer =
  (
     @Tiny.Cache.Text.utf8_from_utf32,
     @Tiny.Cache.Text.utf8_from_utf32_lower,
     @Tiny.Cache.Text.utf8_from_utf32_upper
  );
var
  LSBCSConv: TSBCSConv;
begin
  if (ASource.Ascii) then
  begin
    TCharactersConversion{procedure}(ASCII_FROM_UTF32[Byte(AFlags)])(ADest, ASource.Chars, ASource.Length);
  end else
  if (Integer(AFlags) < 0) then
  begin
    Result := TCharactersConversion(UTF8_FROM_UTF32[Byte(AFlags)])(ADest, ASource.Chars, ASource.Length);
    Exit;
  end else
  begin
    if (AFlags and 3 <> 0) then
    begin
      if (AFlags and 1 <> 0) then
      begin
        LSBCSConv.CaseLookup := Pointer(@TEXTCONV_CHARCASE.LOWER);
      end else
      begin
        LSBCSConv.CaseLookup := Pointer(@TEXTCONV_CHARCASE.UPPER);
      end;
    end else
    begin
      LSBCSConv.CaseLookup := nil;
    end;

    LSBCSConv.CodePageIndex := AFlags or $10000;
    LSBCSConv.Length := ASource.Length;
    sbcs_from_utf32(ADest, Pointer(ASource.Chars), LSBCSConv);
  end;

  Result := ASource.Length;
end;

{$ifdef FPC}
function TextConv_utf16_from_sbcs(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Tiny.Text.utf16_from_sbcs(ADest, ASrc, ALength, AConverter);
  Result := 0;
end;

function TextConv_utf16_from_sbcs_lower(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Tiny.Text.utf16_from_sbcs_lower(ADest, ASrc, ALength, AConverter);
  Result := 0;
end;

function TextConv_utf16_from_sbcs_upper(ADest, ASrc: Pointer; ALength: NativeUInt; AConverter: Pointer): NativeUInt;
begin
  Tiny.Text.utf16_from_sbcs_upper(ADest, ASrc, ALength, AConverter);
  Result := 0;
end;

function TextConv_utf16_from_utf8(ADest, ASrc: Pointer; ALength: NativeUInt): NativeUInt;
begin
  Result := Tiny.Text.utf16_from_utf8(ADest, ASrc, ALength);
end;

function TextConv_utf16_from_utf8_lower(ADest, ASrc: Pointer; ALength: NativeUInt): NativeUInt;
begin
  Result := Tiny.Text.utf16_from_utf8_lower(ADest, ASrc, ALength);
end;

function TextConv_utf16_from_utf8_upper(ADest, ASrc: Pointer; ALength: NativeUInt): NativeUInt;
begin
  Result := Tiny.Text.utf16_from_utf8_upper(ADest, ASrc, ALength);
end;
{$endif}

function ConvertUTF16FromByte(ADest: PWord; const ASource: ByteString;
  ACharCase: NativeUInt): NativeUInt;
const
  UTF16_FROM_SBCS: array[0..2{CharCase}] of {TCharactersConversionEx} Pointer =
  (
     @{$ifdef FPC}TextConv_utf16_from_sbcs{$else}Tiny.Text.utf16_from_sbcs{$endif},
     @{$ifdef FPC}TextConv_utf16_from_sbcs_lower{$else}Tiny.Text.utf16_from_sbcs_lower{$endif},
     @{$ifdef FPC}TextConv_utf16_from_sbcs_upper{$else}Tiny.Text.utf16_from_sbcs_upper{$endif}
  );
  UTF16_FROM_UTF8: array[0..2{CharCase}] of {TCharactersConversion} Pointer =
  (
     @{$ifdef FPC}TextConv_utf16_from_utf8{$else}Tiny.Text.utf16_from_utf8{$endif},
     @{$ifdef FPC}TextConv_utf16_from_utf8_lower{$else}Tiny.Text.utf16_from_utf8_lower{$endif},
     @{$ifdef FPC}TextConv_utf16_from_utf8_upper{$else}Tiny.Text.utf16_from_utf8_upper{$endif}
  );
var
  LIndex: NativeInt;
  LConverter: Pointer;
begin
  LIndex := ASource.Flags;
  if (LIndex and 1 = 0{not Ascii}) and (Integer(LIndex) >= 0) then
  begin
    // UTF16 <-- SBCS
    LIndex := LIndex shr 24;
    LIndex := LIndex * SizeOf(TTextConvSBCS);
    Inc(LIndex, NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

    LConverter := PTextConvSBCSEx(LIndex).FUCS2.NumericItems[ACharCase];
    if (LConverter = nil) then LConverter := PTextConvSBCSEx(LIndex).AllocFillUCS2(PTextConvSBCSEx(LIndex).FUCS2.NumericItems[ACharCase], TCharCase(ACharCase));

    TCharactersConversionEx{procedure}(UTF16_FROM_SBCS[ACharCase])(ADest, ASource.Chars, ASource.Length, LConverter);
    Result := ASource.Length;
  end else
  begin
    // UTF16 <-- UTF8/Ascii
    Result := TCharactersConversion(UTF16_FROM_UTF8[ACharCase])(ADest, ASource.Chars, ASource.Length);
  end;
end;

{$ifdef FPC}
function TextConv_utf16_from_utf16_lower(ADest, ASrc: Pointer; ALength: NativeUInt): NativeUInt;
begin
  Tiny.Text.utf16_from_utf16_lower(ADest, ASrc, ALength);
  Result := 0;
end;

function TextConv_utf16_from_utf16_upper(ADest, ASrc: Pointer; ALength: NativeUInt): NativeUInt;
begin
  Tiny.Text.utf16_from_utf16_upper(ADest, ASrc, ALength);
  Result := 0;
end;
{$endif}

function ConvertUTF16FromUTF16(ADest: PWord; const ASource: UTF16String;
  ACharCase: NativeUInt): NativeUInt;
const
  UTF16_FROM_UTF16: array[0..2{CharCase}] of {TCharactersConversion} Pointer =
  (
     @Tiny.Cache.Text.MoveWords,
     @{$ifdef FPC}TextConv_utf16_from_utf16_lower{$else}Tiny.Text.utf16_from_utf16_lower{$endif},
     @{$ifdef FPC}TextConv_utf16_from_utf16_upper{$else}Tiny.Text.utf16_from_utf16_upper{$endif}
  );
begin
  TCharactersConversion{procedure}(UTF16_FROM_UTF16[ACharCase])(ADest, ASource.Chars, ASource.Length);
  Result := ASource.Length;
end;

function ConvertUTF16FromUTF32(ADest: PWord; const ASource: UTF32String;
  ACharCase: NativeUInt): NativeUInt;
const
  UTF16_FROM_UTF32: array[0..2{CharCase}] of {TCharactersConversion} Pointer =
  (
     @Tiny.Cache.Text.utf16_from_utf32,
     @Tiny.Cache.Text.utf16_from_utf32_lower,
     @Tiny.Cache.Text.utf16_from_utf32_upper
  );
begin
  TCharactersConversion{procedure}(UTF16_FROM_UTF32[ACharCase])(ADest, ASource.Chars, ASource.Length);
  Result := ASource.Length;
end;

function ConvertUTF32FromByte(ADest: PCardinal; const ASource: ByteString;
  ACharCase: NativeUInt): NativeUInt;
var
  LIndex: NativeInt;
  LContext: TTextConvContextEx;
begin
  LContext.Destination := ADest;
  LContext.DestinationSize := NativeUInt(High(NativeInt));
  LContext.F.Flags := CHARCASE_FLAGS[ACharCase] + (Ord(bomUTF32) shl ENCODING_DESTINATION_OFFSET);
  LContext.Source := ASource.Chars;
  LContext.SourceSize := ASource.Length;

  LIndex := ASource.Flags;
  if (LIndex and 1 = 0{not Ascii}) and (Integer(LIndex) >= 0) then
  begin
    // UTF32 <-- SBCS
    LIndex := LIndex shr 24;
    LIndex := LIndex * SizeOf(TTextConvSBCS);
    Inc(LIndex, NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

    LContext.FCallbacks.Reader := PTextConvSBCSEx(LIndex).FUCS2.NumericItems[ACharCase];
    if (LContext.FCallbacks.Reader = nil) then
      LContext.FCallbacks.Reader := PTextConvSBCSEx(LIndex).AllocFillUCS2(PTextConvSBCSEx(LIndex).FUCS2.NumericItems[ACharCase], TCharCase(ACharCase));
  end else
  begin
    // UTF32 <-- UTF8/Ascii
    Inc(LContext.F.Flags, Ord(bomUTF8));
  end;

  LIndex := LContext.convert_universal;
  Result := LContext.DestinationWritten shr 2;
  if (LIndex < 0) then
  begin
    ADest := LContext.Destination;
    Inc(ADest, Result);
    ADest^ := UNKNOWN_CHARACTER;
    Inc(Result);
  end;
end;

function ConvertUTF32FromUTF16(ADest: PCardinal; const ASource: UTF16String;
  ACharCase: NativeUInt): NativeUInt;
var
  LIndex: NativeInt;
  LContext: TTextConvContextEx;
begin
  LContext.Destination := ADest;
  LContext.DestinationSize := NativeUInt(High(NativeInt));
  LContext.F.Flags := CHARCASE_FLAGS[ACharCase] + (Ord(bomUTF32) shl ENCODING_DESTINATION_OFFSET + Ord(bomUTF16));
  LContext.Source := ASource.Chars;
  LContext.SourceSize := ASource.Length shl 1;

  LIndex := LContext.convert_universal;
  Result := LContext.DestinationWritten shr 2;
  if (LIndex < 0) then
  begin
    ADest := LContext.Destination;
    Inc(ADest, Result);
    ADest^ := UNKNOWN_CHARACTER;
    Inc(Result);
  end;
end;

function ConvertUTF32FromUTF32(ADest: PCardinal; const ASource: UTF32String;
  ACharCase: NativeUInt): NativeUInt;
var
  i, X: NativeUInt;
  LSrc: PCardinal;
  LCaseLookup: PTextConvWW;
begin
  Result := ASource.Length;

  if (ACharCase = 0) then
  begin
    TinyMove(ASource.Chars^, ADest^, Result shl 2);
    Exit;
  end else
  begin
    LCaseLookup := Pointer(@TEXTCONV_CHARCASE);
    Dec(ACharCase);
    ACharCase := ACharCase shl (16+1);
    Inc(NativeUInt(LCaseLookup), ACharCase);
  end;

  LSrc := Pointer(ASource.Chars);
  for i := 1 to Result do
  begin
    X := LSrc^;

    if (X <= $ffff) then
      X := LCaseLookup[X];

    ADest^ := X;
    Inc(LSrc);
    Inc(ADest);
  end;
end;

procedure TStringBuffer.Append(const S: ByteString; const ACharCase: TCharCase);
const
  CONVERSIONS: array[0..3{TTinyStringKind}] of {TTinyStringConversion} Pointer =
  (
     nil,
     @Tiny.Cache.Text.ConvertByteFromByte,
     @Tiny.Cache.Text.ConvertUTF16FromByte,
     @Tiny.Cache.Text.ConvertUTF32FromByte
  );
var
  LMaxAppendSize: NativeUInt;
  LFlags, LSourceFlags, LKind: NativeUInt;
begin
  LMaxAppendSize := S.Length;
  LSourceFlags := S.Flags;
  LFlags := Self.FBuffer.NativeFlags;
  if (LMaxAppendSize = 0) then Exit;

  LFlags := LFlags and (LSourceFlags or NativeUInt(-2));
  Self.FBuffer.NativeFlags := LFlags;
  LFlags := LFlags and NativeUInt($ff000000);
  Inc(LFlags, Byte(ACharCase));

  LKind := Byte(Self.Kind);
  if (LKind = NativeUInt(csByte)) then
  begin
    // csByte
    if (Integer(LFlags) < 0) then
    begin
      if (NativeInt(LSourceFlags) and 1 = 0{not Ascii}) then
      begin
        if (Integer(LSourceFlags) >= 0) then
        begin
          // UTF8 <-- SBCS
          LMaxAppendSize := LMaxAppendSize * 3;
        end else
        begin
          // UTF8 <-- UTF8
          if (LFlags and 3 <> 0) then
          begin
            LMaxAppendSize := LMaxAppendSize * 3;
            LMaxAppendSize := LMaxAppendSize shr 1;
          end;
        end;
      end;
    end;
  end else
  begin
    if (LKind + NativeUInt(-1) <= Ord(csUTF32) - 1) then
    begin
      // csUTF16, csUTF32
      LFlags := LFlags and $7f;
      LMaxAppendSize := LMaxAppendSize shl 1;
      Inc(LMaxAppendSize, NativeUInt(-(NativeInt(LKind) and 1)) and LMaxAppendSize);
    end else
    begin
      raise ETinyString.Create(Pointer(@SStringNotInitialized));
    end;
  end;

  Self.InternalAppend(LMaxAppendSize, S, LFlags, CONVERSIONS[LKind]);
end;

procedure TStringBuffer.Append(const S: UTF16String; const ACharCase: TCharCase);
const
  CONVERSIONS: array[0..3{TTinyStringKind}] of {TTinyStringConversion} Pointer =
  (
     nil,
     @Tiny.Cache.Text.ConvertByteFromUTF16,
     @Tiny.Cache.Text.ConvertUTF16FromUTF16,
     @Tiny.Cache.Text.ConvertUTF32FromUTF16
  );
var
  LMaxAppendSize: NativeUInt;
  LFlags, LSourceFlags, LKind: NativeUInt;
begin
  LMaxAppendSize := S.Length;
  LSourceFlags := S.F.NativeFlags or NativeUInt(-2);
  LFlags := Self.FBuffer.NativeFlags;
  if (LMaxAppendSize = 0) then Exit;

  LFlags := LFlags and LSourceFlags;
  Self.FBuffer.NativeFlags := LFlags;
  LFlags := LFlags and NativeUInt($ff000000);
  Inc(LFlags, Byte(ACharCase));

  LKind := Byte(Self.Kind);
  LSourceFlags := {not Ascii}not LSourceFlags;
  if (LKind = NativeUInt(csByte)) then
  begin
    if ((LFlags shr 31) and LSourceFlags <> 0) then
      LMaxAppendSize := LMaxAppendSize * 3;
  end else
  begin
    if (LKind + NativeUInt(-1) <= Ord(csUTF32) - 1) then
    begin
      // csUTF16, csUTF32
      LFlags := LFlags and $7f;
      LMaxAppendSize := LMaxAppendSize shl 1;
      Inc(LMaxAppendSize, NativeUInt(-(NativeInt(LKind) and 1)) and LMaxAppendSize);
    end else
    begin
      raise ETinyString.Create(Pointer(@SStringNotInitialized));
    end;
  end;

  Self.InternalAppend(LMaxAppendSize, S, LFlags, CONVERSIONS[LKind]);
end;

procedure TStringBuffer.Append(const S: UTF32String; const ACharCase: TCharCase);
label
  done;
const
  CONVERSIONS: array[0..3{TTinyStringKind}] of {TTinyStringConversion} Pointer =
  (
     nil,
     @Tiny.Cache.Text.ConvertByteFromUTF32,
     @Tiny.Cache.Text.ConvertUTF16FromUTF32,
     @Tiny.Cache.Text.ConvertUTF32FromUTF32
  );
var
  LMaxAppendSize: NativeUInt;
  LFlags, LSourceFlags, LKind: NativeUInt;
begin
  LMaxAppendSize := S.Length;
  LSourceFlags := S.F.NativeFlags or NativeUInt(-2);
  LFlags := Self.FBuffer.NativeFlags;
  if (LMaxAppendSize = 0) then Exit;

  LFlags := LFlags and LSourceFlags;
  Self.FBuffer.NativeFlags := LFlags;
  LFlags := LFlags and NativeUInt($ff000000);
  Inc(LFlags, Byte(ACharCase));

  LKind := Byte(Self.Kind);
  LSourceFlags := {not Ascii}not LSourceFlags;
  if (LKind = NativeUInt(csByte)) then
  begin
    if ((LFlags shr 31) and LSourceFlags = 0) then goto done;
  end else
  begin
    if (LKind + NativeUInt(-1) <= Ord(csUTF32) - 1) then
    begin
      // csUTF16, csUTF32
      LFlags := LFlags and $7f;
      LSourceFlags := {not Ascii}LSourceFlags or {AKind = csUTF32}(LKind and 1);
    end else
    begin
      raise ETinyString.Create(Pointer(@SStringNotInitialized));
    end;
  end;

  LMaxAppendSize := LMaxAppendSize shl 1;
  Inc(LMaxAppendSize, NativeUInt(-NativeInt(LSourceFlags)) and LMaxAppendSize);
done:
  Self.InternalAppend(LMaxAppendSize, S, LFlags, CONVERSIONS[LKind]);
end;

function TStringBuffer.EmulateShortString: PShortString;
var
  P: PStrRec;
  L: NativeUInt;
begin
  P := Pointer(Self.FData);
  if (P <> nil) then
  begin
    if (Kind = csByte) then
    begin
      L := Self.FBuffer.Length;
      P.ShortLength := L;
      if (L > High(Byte)) then P.ShortLength := High(Byte);

      Inc(NativeUInt(P), SizeOf(TStrRec) - SizeOf(Byte));
      Result := PShortString(P);
      Exit;
    end else
    begin
      raise ETinyString.Create(Pointer(@SIncompatibleStringType));
    end;
  end else
  begin
    Self.FString := nil;
    Result := Pointer(@Self.FString);
  end;
end;

function TStringBuffer.EmulateAnsiString: PAnsiString;
var
  P: PStrRec;
  L: NativeUInt;
begin
  P := Pointer(Self.FData);
  L := Self.FBuffer.Length;
  if (P <> nil) then
  begin
    if (Kind = csByte) then
    begin
      if (L <> 0) then
      begin
        P.Ansi.RefCount := ASTR_REFCOUNT_LITERAL;
        P.Ansi.Length := L;

        {$ifdef UNICODE}
        P.Ansi.CodePageElemSize := Integer(Self.Encoding) or $00010000;
        {$endif}

        Inc(P);
        {$ifdef ANSISTRSUPPORT}
        PAnsiChar(P)[L] := NULL_ANSICHAR;
        {$endif}
      end else
      begin
        P := nil;
      end;
    end else
    begin
      raise ETinyString.Create(Pointer(@SIncompatibleStringType));
    end;
  end;

  Self.FString := P;
  Result := Pointer(@Self.FString);
end;

function TStringBuffer.EmulateUTF8String: PUTF8String;
var
  P: PStrRec;
  L, LFlags: NativeUInt;
begin
  P := Pointer(Self.FData);
  LFlags := Self.FEncoding.Flags;
  if (P <> nil) then
  begin
    if (LFlags and (3 shl 16) = (1 shl 16){csByte}) and
      ((Integer(LFlags) < 0) or (Self.CastByteString.Ascii)) then
    begin
      L := Self.FBuffer.Length;
      if (L <> 0) then
      begin
        P.Ansi.RefCount := ASTR_REFCOUNT_LITERAL;
        P.Ansi.Length := L;

        {$ifdef UNICODE}
        P.Ansi.CodePageElemSize := CODEPAGE_UTF8 or $00010000;
        {$endif}

        Inc(P);
        {$ifdef ANSISTRSUPPORT}
        PAnsiChar(P)[L] := NULL_ANSICHAR;
        {$endif}
      end else
      begin
        P := nil;
      end;
    end else
    begin
      raise ETinyString.Create(Pointer(@SIncompatibleStringType));
    end;
  end;

  Self.FString := P;
  Result := Pointer(@Self.FString);
end;

function TStringBuffer.EmulateWideString: PWideString;
var
  P: PStrRec;
  L: NativeUInt;
begin
  P := Pointer(Self.FData);
  L := Self.FBuffer.Length;
  if (P <> nil) then
  begin
    if (Kind = csUTF16) then
    begin
      if (L <> 0) then
      begin
        {$ifNdef MSWINDOWS}
        P.Wide.RefCount := WSTR_REFCOUNT_LITERAL;
        {$endif}

        {$ifdef WIDESTRLENSHIFT}L := L shl 1;{$endif}
        P.Wide.Length := L;
        {$ifdef WIDESTRLENSHIFT}L := L shr 1;{$endif}

        {$if Defined(WIDESTRSUPPORT) and (not Defined(MSWINDOWS))}
          {$if Defined(FPC) or (CompilerVersion >= 22)}
            // FPC or Delphi >= XE (WideString = UnicodeString)
            P.Wide.CodePageElemSize := CODEPAGE_UTF16 or $00020000;
          {$else}
            // Delphi < XE (WideString = double AnsiString, CodePage default)
            P.Wide.CodePageElemSize := DefaultSystemCodePage or $00010000;
          {$ifend}
        {$ifend}

        Inc(P);
        {$ifdef WIDESTRSUPPORT}
        PWideChar(P)[L] := NULL_WIDECHAR;
        {$endif}
      end else
      begin
        P := nil;
      end;
    end else
    begin
      raise ETinyString.Create(Pointer(@SIncompatibleStringType));
    end;
  end;

  Self.FString := P;
  Result := Pointer(@Self.FString);
end;

function TStringBuffer.EmulateUnicodeString: PUnicodeString;
var
  P: PStrRec;
  L: NativeUInt;
begin
  P := Pointer(Self.FData);
  L := Self.FBuffer.Length;
  if (P <> nil) then
  begin
    if (Kind = csUTF16) then
    begin
      if (L <> 0) then
      begin
        {$ifdef UNICODE}
        P.Unicode.RefCount := USTR_REFCOUNT_LITERAL;
        P.Unicode.CodePageElemSize := CODEPAGE_UTF16 or $00020000;
        {$endif}

        {$ifNdef UNICODE}L := L shl 1;{$endif}
        P.Unicode.Length := L;
        {$ifNdef UNICODE}L := L shr 1;{$endif}

        Inc(P);
        PWideChar(P)[L] := NULL_WIDECHAR;
      end else
      begin
        P := nil;
      end;
    end else
    begin
      raise ETinyString.Create(Pointer(@SIncompatibleStringType));
    end;
  end;

  Self.FString := P;
  Result := Pointer(@Self.FString);
end;

function TStringBuffer.EmulateUCS4String: PUCS4String;
var
  P: PStrRec;
  L: NativeUInt;
begin
  P := Pointer(Self.FData);
  L := Self.FBuffer.Length;
  if (P <> nil) then
  begin
    if (Kind = csUTF32) then
    begin
      if (L <> 0) then
      begin
        P.UCS4.RefCount := UCS4STR_REFCOUNT_LITERAL;

        {$ifdef FPC}
        Dec(L);
        P.UCS4.High := L;
        Inc(L);
        {$else}
        P.UCS4.Length := L;
        {$endif}

        Inc(P);
        PUTF32CharArray(P)[L] := 0;
      end else
      begin
        P := nil;
      end;
    end else
    begin
      raise ETinyString.Create(Pointer(@SIncompatibleStringType));
    end;
  end;

  Self.FString := P;
  Result := Pointer(@Self.FString);
end;

function TStringBuffer.EmulateString: PString;
begin
  {$ifdef UNICODE}
    Result := EmulateUnicodeString;
  {$else}
    Result := EmulateAnsiString;
  {$endif};
end;

procedure TStringBuffer.Append(const AChars: PAnsiChar;
  const ALength: NativeUInt; const ACodePage: Word; const CharCase: TCharCase);
var
  LBuffer: ByteString;
begin
  if (ALength <> 0) then
  begin
    LBuffer.Assign(AChars, ALength, ACodePage);
    Self.Append(LBuffer, CharCase);
  end;
end;

procedure TStringBuffer.Append(const S: AnsiString;
  const ACharCase: TCharCase{$ifNdef INTERNALCODEPAGE}; const ACodePage: Word{$endif});
var
  LBuffer: ByteString;
begin
  if (Pointer(S) <> nil) then
  begin
    LBuffer.Assign(S{$ifNdef INTERNALCODEPAGE}, ACodePage{$endif});
    Self.Append(LBuffer, ACharCase);
  end;
end;

procedure TStringBuffer.{$ifdef UNICODE}Append{$else}AppendUTF8{$endif}(
  const S: UTF8String; const ACharCase: TCharCase);
var
  LBuffer: ByteString;
begin
  if (Pointer(S) <> nil) then
  begin
    LBuffer.{$ifdef UNICODE}Assign{$else}AssignUTF8{$endif}(S);
    Self.Append(LBuffer, ACharCase);
  end;
end;

procedure TStringBuffer.Append(const S: ShortString; const ACodePage: Word;
  const ACharCase: TCharCase);
var
  LBuffer: ByteString;
begin
  if (PByte(@S)^ <> 0) then
  begin
    LBuffer.Assign(S, ACodePage);
    Self.Append(LBuffer, ACharCase);
  end;
end;

procedure TStringBuffer.Append(const S: TBytes; const ACodePage: Word;
  const ACharCase: TCharCase);
var
  LBuffer: ByteString;
begin
  if (Pointer(S) <> nil) then
  begin
    LBuffer.Assign(S, ACodePage);
    Self.Append(LBuffer, ACharCase);
  end;
end;

procedure TStringBuffer.Append(const AChars: PUnicodeChar;
  const ALength: NativeUInt; const ACharCase: TCharCase);
var
  LBuffer: UTF16String;
begin
  if (ALength <> 0) then
  begin
    LBuffer.Assign(AChars, ALength);
    Self.Append(LBuffer, ACharCase);
  end;
end;

{$ifdef MSWINDOWS}
procedure TStringBuffer.Append(const S: WideString; const ACharCase: TCharCase);
var
  LBuffer: UTF16String;
begin
  if (Pointer(S) <> nil) then
  begin
    LBuffer.Assign(S);
    Self.Append(LBuffer, ACharCase);
  end;
end;
{$endif}

{$ifdef UNICODE}
procedure TStringBuffer.Append(const S: UnicodeString; const ACharCase: TCharCase);
var
  LBuffer: UTF16String;
begin
  if (Pointer(S) <> nil) then
  begin
    LBuffer.Assign(S);
    Self.Append(LBuffer, ACharCase);
  end;
end;
{$endif}

procedure TStringBuffer.Append(const AChars: PUCS4Char;
  const ALength: NativeUInt; const ACharCase: TCharCase);
var
  LBuffer: UTF32String;
begin
  if (ALength <> 0) then
  begin
    LBuffer.Assign(AChars, ALength);
    Self.Append(LBuffer, ACharCase);
  end;
end;

procedure TStringBuffer.Append(const S: UCS4String;
  const ANullTerminated: Boolean; const ACharCase: TCharCase);
var
  LBuffer: UTF32String;
begin
  if (Pointer(S) <> nil) then
  begin
    LBuffer.Assign(S, ANullTerminated);
    Self.Append(LBuffer, ACharCase);
  end;
end;

procedure TStringBuffer.AppendBoolean(const AValue: Boolean);
type
  TBooleanChars = array[0..7] of Byte;
const
  BOOLEANS: array[0..1] of TBooleanChars = (
    (Ord('F'), Ord('a'), Ord('l'), Ord('s'), Ord('e'), 0, 0, 0),
    (Ord('T'), Ord('r'), Ord('u'), Ord('e'), 0, 0, 0, 0)
  );
var
  LCount: NativeUInt;
begin
  LCount := Byte(AValue);
  Self.AppendAscii(Pointer(@BOOLEANS[LCount]), LCount xor 5);
end;

procedure TStringBuffer.AppendInteger(const AValue: Integer;
  const ADigits: NativeUInt);
var
  Store: record
    Prev: array[1..SizeOf(NativeUInt)] of Byte;
    DigitsRec: TDigitsRec;
  end;
  P: PByte;
begin
  if (AValue < 0) then
  begin
    P := WriteCardinalAscii(Store.DigitsRec, Cardinal(-AValue), ADigits);
    Dec(P);
    P^ := Ord('-');
  end else
  begin
    P := WriteCardinalAscii(Store.DigitsRec, Cardinal(AValue), ADigits);
  end;

  Self.AppendAscii(Pointer(P), NativeUInt(@Store.DigitsRec.Buffer[0]) - NativeUInt(P));
end;

procedure TStringBuffer.AppendCardinal(const AValue: Cardinal;
  const ADigits: NativeUInt);
var
  LDigitsRec: TDigitsRec;
  P: PByte;
begin
  P := WriteCardinalAscii(LDigitsRec, Cardinal(AValue), ADigits);
  Self.AppendAscii(Pointer(P), NativeUInt(@LDigitsRec.Buffer[0]) - NativeUInt(P));
end;

procedure TStringBuffer.AppendHex(const AValue: Integer;
  const ADigits: NativeUInt);
var
  LDigitsRec: TDigitsRec;
  P: PByte;
begin
  P := WriteHexAscii(LDigitsRec, Cardinal(AValue), ADigits);
  Self.AppendAscii(Pointer(P), NativeUInt(@LDigitsRec.Buffer[0]) - NativeUInt(P));
end;

procedure TStringBuffer.AppendInt64(const AValue: Int64;
  const ADigits: NativeUInt);
var
  Store: record
    Prev: array[1..SizeOf(NativeUInt)] of Byte;
    DigitsRec: TDigitsRec;
  end;
  P: PByte;
begin
  {$ifdef SMALLINT}
  if (TPoint(AValue).Y < 0) then
  begin
    Store.DigitsRec.Quads[0] := ADigits;
    PInt64(@Store.DigitsRec.Ascii)^ := -AValue;
    P := WriteUInt64Ascii(Store.DigitsRec, PInt64(@Store.DigitsRec.Ascii), {Digits}Store.DigitsRec.Quads[0]);
  {$else}
  if (AValue < 0) then
  begin
    P := WriteUInt64Ascii(Store.DigitsRec, -AValue, ADigits);
  {$endif}
    Dec(P);
    P^ := Ord('-');
  end else
  begin
    P := WriteUInt64Ascii(Store.DigitsRec, {$ifdef SMALLINT}@{$endif}AValue, ADigits);
  end;

  Self.AppendAscii(Pointer(P), NativeUInt(@Store.DigitsRec.Buffer[0]) - NativeUInt(P));
end;

procedure TStringBuffer.AppendUInt64(const AValue: UInt64; const ADigits: NativeUInt);
var
  LDigitsRec: TDigitsRec;
  P: PByte;
begin
  P := WriteUInt64Ascii(LDigitsRec, {$ifdef SMALLINT}@{$endif}Int64(AValue), ADigits);
  Self.AppendAscii(Pointer(P), NativeUInt(@LDigitsRec.Buffer[0]) - NativeUInt(P));
end;

procedure TStringBuffer.AppendHex64(const AValue: Int64; const ADigits: NativeUInt);
var
  LDigitsRec: TDigitsRec;
  P: PByte;
begin
  P := WriteHex64Ascii(LDigitsRec, {$ifdef SMALLINT}@{$endif}AValue, ADigits);
  Self.AppendAscii(Pointer(P), NativeUInt(@LDigitsRec.Buffer[0]) - NativeUInt(P));
end;

procedure TStringBuffer.AppendFloat(const AValue: Extended);
{$ifNdef CPUINTELASM}
begin
  AppendFloat(AValue, DefaultFloatSettings);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  pop ebp
  lea edx, DefaultFloatSettings
  {$else .CPUX64}
  lea rdx, DefaultFloatSettings
  {$endif}
  jmp TStringBuffer.AppendFloat
end;
{$endif}

procedure TStringBuffer.AppendFloat(const AValue: Extended; const ASettings: TFloatSettings);
var
  Store: record
    Prev: array[1..SizeOf(NativeUInt)] of Byte;
    DigitsRec: TDigitsRec;
  end;
  P: PByte;
  LCount: NativeUInt;
begin
  LCount := Tiny.Cache.Text.WriteFloatAscii(Store.DigitsRec, {$ifdef EXTENDEDSUPPORT}@{$endif}AValue, ASettings);
  Store.Prev[High(Store.Prev)] := Ord('-');
  P := @Store.DigitsRec.Ascii[0];
  Dec(P, LCount and 1);
  LCount := LCount shr 1;
  Self.AppendAscii(Pointer(P), LCount);
end;

procedure TStringBuffer.AppendDate(const AValue: TDateTime);
{$ifNdef CPUINTELASM}
begin
  AppendDate(AValue, DefaultDateTimeSettings);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  pop ebp
  lea edx, DefaultDateTimeSettings
  {$else .CPUX64}
  mov r8, DefaultDateTimeSettings
  {$endif}
  jmp TStringBuffer.AppendDate
end;
{$endif}

procedure TStringBuffer.AppendDate(const AValue: TDateTime; const ASettings: TDateTimeSettings);
var
  LDigitsRec: TDigitsRec;
  P: PByte;
begin
  SeparateDateTime(LDigitsRec, {$ifNdef CPUX86}AValue{$else}PDouble(@AValue)^{$endif}, True);
  P := WriteDateAscii(LDigitsRec, @LDigitsRec.Ascii[0], ASettings);
  Self.AppendAscii(Pointer(@LDigitsRec.Ascii[0]), NativeUInt(P) - NativeUInt(@LDigitsRec.Ascii[0]));
end;

procedure TStringBuffer.AppendTime(const AValue: TDateTime);
{$ifNdef CPUINTELASM}
begin
  AppendTime(AValue, DefaultDateTimeSettings);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  pop ebp
  lea edx, DefaultDateTimeSettings
  {$else .CPUX64}
  mov r8, DefaultDateTimeSettings
  {$endif}
  jmp TStringBuffer.AppendTime
end;
{$endif}

procedure TStringBuffer.AppendTime(const AValue: TDateTime; const ASettings: TDateTimeSettings);
var
  LDigitsRec: TDigitsRec;
  P: PByte;
begin
  SeparateDateTime(LDigitsRec, {$ifNdef CPUX86}AValue{$else}PDouble(@AValue)^{$endif}, False);
  P := WriteTimeAscii(LDigitsRec, @LDigitsRec.Ascii[0], ASettings);
  Self.AppendAscii(Pointer(@LDigitsRec.Ascii[0]), NativeUInt(P) - NativeUInt(@LDigitsRec.Ascii[0]));
end;

procedure TStringBuffer.AppendDateTime(const AValue: TDateTime);
{$ifNdef CPUINTELASM}
begin
  AppendDateTime(AValue, DefaultDateTimeSettings);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
  pop ebp
  lea edx, DefaultDateTimeSettings
  {$else .CPUX64}
  mov r8, DefaultDateTimeSettings
  {$endif}
  jmp TStringBuffer.AppendDateTime
end;
{$endif}

procedure TStringBuffer.AppendDateTime(const AValue: TDateTime; const ASettings: TDateTimeSettings);
var
  P: PByte;
  Sep: NativeUInt;
  LDigitsRec: TDigitsRec;
begin
  SeparateDateTime(LDigitsRec, {$ifNdef CPUX86}AValue{$else}PDouble(@AValue)^{$endif}, False);
  P := WriteDateAscii(LDigitsRec, @LDigitsRec.Ascii[0], ASettings);
  Sep := Byte(ASettings.BetweenSeparator);
  if (Sep <> NativeUInt(sepNone)) then
  begin
    P^ := DATETIME_SEPARATORS[Sep];
    Inc(P);
  end;
  P := WriteTimeAscii(LDigitsRec, P, ASettings);
  Self.AppendAscii(Pointer(@LDigitsRec.Ascii[0]), NativeUInt(P) - NativeUInt(@LDigitsRec.Ascii[0]));
end;

procedure TStringBuffer.AppendVariant(const AValue: Variant);
{$ifNdef CPUINTELASM}
begin
  AppendVariant(AValue, DefaultFloatSettings, DefaultDateTimeSettings);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
    push [esp]
    lea ecx, DefaultDateTimeSettings
    mov [esp + 4], ecx
    lea ecx, DefaultFloatSettings
  {$else .CPUX64}
    mov r8, DefaultFloatSettings
    mov r9, DefaultDateTimeSettings
  {$endif}
  jmp TStringBuffer.AppendVariant
end;
{$endif}

procedure TStringBuffer.AppendVariant(const AValue: Variant;
  const AFloatSettings: TFloatSettings; const ADateTimeSettings: TDateTimeSettings);
label
  check_byref, signed_value, unsigned_value, uint64_value, float_value;
var
  VType: Integer;
  PValue: Pointer;
  Store: record
    FloatValue: Extended;
    Date: Int64;
  end;
begin
  VType := TVarData(AValue).VType;
  PValue := @TVarData(AValue).VWords[3];
check_byref:
  if (VType and varByRef <> 0) then
  begin
    VType := VType and (not varByRef);
    PValue := PPointer(PValue)^;
  end;

  case (VType) of
    varVariant: begin
                  VType := TVarData(PValue^).VType;
                  PValue := @TVarData(PValue^).VWords[3];
                  goto check_byref;
                end;
    varBoolean: begin
                  Self.AppendBoolean(PBoolean(PValue)^);
                end;
   varSmallint: begin
                  VType := PSmallInt(PValue)^;
                  if (VType >= 0) then goto unsigned_value;
                  goto signed_value;
                end;
   varShortInt: begin
                  VType := PShortInt(PValue)^;
                  if (VType >= 0) then goto unsigned_value;
                  goto signed_value;
                end;
    varInteger: begin
                  VType := PInteger(PValue)^;
                  if (VType >= 0) then goto unsigned_value;
                signed_value:
                  Self.AppendInteger(VType);
                end;
       varByte: begin
                  VType := PByte(PValue)^;
                  goto unsigned_value;
                end;
       varWord: begin
                  VType := PWord(PValue)^;
                  goto unsigned_value;
                end;
   varLongWord: begin
                  VType := PInteger(PValue)^;
                unsigned_value:
                  Self.AppendCardinal(Cardinal(VType));
                end;
      varInt64: begin
                  {$ifdef SMALLINT}
                  if (TPoint(PValue^).Y >= 0) then goto uint64_value;
                  {$else}
                  if (Int64(PValue^) >= 0) then goto uint64_value;
                  {$endif}
                  Self.AppendInt64(PInt64(PValue)^);
                end;
$15{varUInt64}: begin
                uint64_value:
                  Self.AppendUInt64(PUInt64(PValue)^);
                end;
   varCurrency: begin
                  Store.FloatValue := PInt64(PValue)^ * (1 / 10000);
                  goto float_value;
                end;
     varSingle: begin
                  Store.FloatValue := PSingle(PValue)^;
                  goto float_value;
                end;
     varDouble: begin
                  Store.FloatValue := PDouble(PValue)^;
                float_value:
                  Self.AppendFloat(Store.FloatValue, AFloatSettings);
                end;
       varDate: begin
                  Store.Date := Trunc(PDouble(PValue)^);
                  if (PDouble(PValue)^ - Store.Date < 1 / (24 * 60 * 60 * 1000)) then
                  begin
                    Self.AppendDate(PDateTime(PValue)^, ADateTimeSettings);
                  end else
                  if (Store.Date <> 0) then
                  begin
                    Self.AppendDateTime(PDateTime(PValue)^, ADateTimeSettings);
                  end else
                  begin
                    Self.AppendTime(PDateTime(PValue)^, ADateTimeSettings);
                  end;
                end;
     {$ifdef ANSISTRSUPPORT}
     varString: begin
                  Self.Append(PAnsiString(PValue)^);
                end;
     {$endif}
    {$ifdef UNICODE}
    varUString: begin
                  Self.Append(PUnicodeString(PValue)^);
                end;
    {$endif}
     {$ifdef WIDESTRSUPPORT}
     varOleStr: begin
                  Self.Append(PWideString(PValue)^);
                end;
     {$endif}
   end;
end;


{ TCachedTextWriter }

const
  WRITER_OVERFLOW_LIMIT = 128;

constructor TCachedTextWriter.Create(const AContext: PTextConvContext;
  const ATarget: TCachedWriter; const AOwner: Boolean);
const
  CHARS_FALSE: array[0..4] of Byte = (Ord('F'), Ord('a'), Ord('l'), Ord('s'), Ord('e'));
  CHARS_TRUE: array[0..3] of Byte = (Ord('T'), Ord('r'), Ord('u'), Ord('e'));
var
  VWBufferedAscii: procedure(AFrom: PByte; ACount: NativeUInt) of object;
  VWAscii: procedure(const AChars: PAnsiChar; const ALength: NativeUInt) of object;
  VWUnicodeAscii: procedure(const AChars: PUnicodeChar; const ALength: NativeUInt) of object;
  VWUCS4Ascii: procedure(const AChars: PUCS4Char; const ALength: NativeUInt) of object;
  VWUTF8Chars: procedure(const AChars: PUTF8Char; const ALength: NativeUInt) of object;
  VWUnicodeChars: procedure(const AChars: PUnicodeChar; const ALength: NativeUInt) of object;
begin
  inherited Create;
  Initialize(AContext, ATarget, AOwner);

  // SBCS
  FSBCSLookup.DefaultConverter := Self.GetSBCSConverter(FSBCSLookup.Default, CODEPAGE_DEFAULT);
  FSBCSLookup.CurrentConverter := Self.GetSBCSConverter(FSBCSLookup.Current, CODEPAGE_DEFAULT);
  InitContexts;

  // unicode temporary
  FBuffer.UnicodeTemp.InitUTF16String;

  // virtual methods
  VWBufferedAscii := Self.WriteBufferedAscii;
  VWAscii := Self.WriteAscii;
  VWUnicodeAscii := Self.WriteUnicodeAscii;
  VWUCS4Ascii := Self.WriteUCS4Ascii;
  VWUTF8Chars := Self.WriteUTF8Chars;
  VWUnicodeChars := Self.WriteUnicodeChars;
  Self.FVirtuals.WriteBufferedAscii := TMethod(VWBufferedAscii).Code;
  Self.FVirtuals.WriteAscii := TMethod(VWAscii).Code;
  Self.FVirtuals.WriteUnicodeAscii := TMethod(VWUnicodeAscii).Code;
  Self.FVirtuals.WriteUCS4Ascii := TMethod(VWUCS4Ascii).Code;
  { heir contructor assign Self.FVirtuals.WriteSBCSCharsInternal }
  Self.FVirtuals.WriteUTF8Chars := TMethod(VWUTF8Chars).Code;
  Self.FVirtuals.WriteUnicodeChars := TMethod(VWUnicodeChars).Code;

  // boolean constants
  TinyMove(CHARS_FALSE, FBuffer.Booleans[Ord(False)], SizeOf(CHARS_FALSE));
  TinyMove(CHARS_TRUE, FBuffer.Booleans[Ord(True)], SizeOf(CHARS_TRUE));

  // constants
  FBuffer.Constants[0] := Ord('0');
  FBuffer.Constants[1] := Ord('1');
  FBuffer.Constants[2] := Ord('%');
  FBuffer.Constants[High(FBuffer.Constants)] := Ord('-');

  // settigns
  Self.FloatSettings := DefaultFloatSettings;
  Self.DateTimeSettings := DefaultDateTimeSettings;
end;

function TCachedTextWriter.Flush: NativeUInt;
begin
  Result := inherited Flush;
end;

procedure TCachedTextWriter.OverflowWriteData(const ABuffer; const ACount: NativeUInt);
begin
  FDataBuffer.Current := FCurrent;
  TCachedWriter(FDataBuffer).Write(ABuffer, ACount);
  FieldsCopy;
end;

procedure TCachedTextWriter.WriteData(const ABuffer; const ACount: NativeUInt);
var
  P: PByte;
begin
  P := FCurrent;
  Inc(P, ACount);

  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowWriteData(ABuffer, ACount);
  end else
  begin
    FCurrent := P;
    Dec(P, ACount);
    TinyMove(ABuffer, P^, ACount);
  end;
end;

procedure TCachedTextWriter.WriteContextData(var AContext: TTextConvContext);
label
  flush;
var
  P: PByte;
  R: NativeInt;
  LCount: NativeUInt;
begin
  P := FCurrent;

  // write data
  if (@PTextConvContextEx(@AContext).FConvertProc = @TTextConvContextEx.convert_copy) then
  begin
    LCount := AContext.SourceSize;
    Inc(P, LCount);

    if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    begin
      OverflowWriteData(AContext.Source^, LCount);
    end else
    begin
      FCurrent := P;
      Dec(P, LCount);
      TinyMove(AContext.Source^, P^, LCount);
    end;
    Exit;
  end;

  // conversion loop
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then goto flush;
  repeat
    AContext.Destination := P;
    AContext.DestinationSize := NativeUInt(Self.FOverflow) - NativeUInt(P) + WRITER_OVERFLOW_LIMIT;

    R := TTextConvContextEx(AContext).FConvertProc(@AContext);
    P := AContext.Destination;
    Inc(P, AContext.DestinationWritten);
    if (R <= 0) then Break;
    Inc(NativeUInt(TTextConvContextEx(AContext).FSource), AContext.SourceRead);
    Dec(TTextConvContextEx(AContext).FSourceSize, AContext.SourceRead);
    if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
    begin
    flush:
      Self.FCurrent := P;
      Self.Flush;
      P := Self.FCurrent;
    end;
  until (False);

  Self.FCurrent := P;
  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
    Self.Flush;
end;

function TCachedTextWriter.GetSBCSConverter(var AEncoding: TCachedEncoding;
  const ACodePage: Word): Pointer;
var
  LIndex: NativeUInt;
  LSBCS: PTextConvSBCSEx;
  LValue: Integer;
begin
  // SBCS
  LIndex := NativeUInt(ACodePage);
  LValue := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[LIndex and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(LValue) = ACodePage) or (LValue < 0) then Break;
    LValue := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(LValue) shr 24]);
  until (False);
  LSBCS := Pointer(NativeUInt(Byte(LValue shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // Encoding fields
  LIndex := Cardinal(LSBCS.F);
  LIndex := {Index}(LIndex shl 24) + (Ord(csByte) shl 16) + {CodePage}(LIndex shr 16);
  AEncoding.Flags := LIndex;

  // UCS2 converter
  Result := LSBCS.FUCS2.Original;
  if (Result = nil) then Result := LSBCS.AllocFillUCS2(LSBCS.FUCS2.Original, ccOriginal);
end;

procedure TCachedTextWriter.WriteBufferedSBCSChars(const ACodePage: Word);
begin
  Self.FSBCSLookup.CurrentConverter := Self.GetSBCSConverter(Self.FSBCSLookup.Current, ACodePage);
  Self.FVirtuals.WriteSBCSCharsInternal(Self, FBuffer.Cached.Chars, FBuffer.Cached.Length);
end;

procedure TCachedTextWriter.WriteByteString(const S: ByteString);
var
  {$ifNdef CPUX86}
  LLength: NativeUInt;
  {$endif}
  LIndex: NativeUInt;
begin
  {$ifNdef CPUX86}
  LLength := S.Length;
  {$endif}
  LIndex := S.Flags;
  if ({$ifdef CPUX86}S.Length{$else}LLength{$endif} <> 0) then
  begin
    if (LIndex and 1 = 0) then
    begin
      if (Integer(LIndex) >= 0) then
      begin
        LIndex := LIndex shr 24;
        FBuffer.Cached.Length := {$ifdef CPUX86}S.Length{$else}LLength{$endif};

        if (LIndex <> Byte(FSBCSLookup.Current.SBCSIndex)) then
        begin
          if (LIndex <> DEFAULT_TEXTCONV_SBCS_INDEX) then
          begin
            FBuffer.Cached.Chars := S.Chars;
            LIndex := LIndex * SizeOf(TTextConvSBCS);
            Inc(LIndex, NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
            Self.WriteBufferedSBCSChars(PTextConvSBCS(LIndex).CodePage);
            Exit;
          end else
          begin
            Self.FSBCSLookup.Current.NativeFlags := Self.FSBCSLookup.Default.NativeFlags;
            Self.FSBCSLookup.CurrentConverter := Self.FSBCSLookup.DefaultConverter;
          end;
        end;

        Self.FVirtuals.WriteSBCSCharsInternal(Self, S.Chars, {S.Length}FBuffer.Cached.Length);
        Exit;
      end else
      begin
        LIndex := {$ifdef CPUX86}S.Length{$else}LLength{$endif};
        Self.FVirtuals.WriteUTF8Chars(Self, Pointer(S.Chars), LIndex);
        Exit;
      end;
    end else
    begin
      LIndex := {$ifdef CPUX86}S.Length{$else}LLength{$endif};
      Self.FVirtuals.WriteAscii(Self, S.Chars, LIndex);
    end;
  end;
end;

procedure TCachedTextWriter.WriteUTF16String(const S: UTF16String);
var
  LLength: NativeUInt;
begin
  LLength := S.Length;
  if (LLength <> 0) then
  begin
    if (not S.Ascii) then
    begin
      Self.FVirtuals.WriteUnicodeChars(Self, S.Chars, LLength);
    end else
    begin
      Self.FVirtuals.WriteUnicodeAscii(Self, S.Chars, LLength);
    end;
  end;
end;

procedure TCachedTextWriter.WriteUTF32String(const S: UTF32String);
var
  LLength: NativeUInt;
begin
  LLength := S.Length;
  if (LLength <> 0) then
  begin
    if (not S.Ascii) then
    begin
      FUTF32Context.Source := S.Chars;
      FUTF32Context.SourceSize := LLength shl 2;
      Self.WriteContextData(FUTF32Context);
    end else
    begin
      Self.FVirtuals.WriteUCS4Ascii(Self, S.Chars, LLength);
    end;
  end;
end;

procedure TCachedTextWriter.WriteAnsiString(const S: AnsiString
  {$ifNdef INTERNALCODEPAGE}; const ACodePage: Word{$endif});
var
  P: PInteger;
  {$ifdef INTERNALCODEPAGE}
  ACodePage: Word;
  {$endif}
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    FBuffer.Cached.Chars := P;
    Dec(NativeInt(P), ASTR_OFFSET_LENGTH);
    FBuffer.Cached.Length := P^;
    {$ifdef INTERNALCODEPAGE}
    Dec(NativeInt(P), (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    ACodePage := PWord(P)^;
    {$endif}

    if (ACodePage = CODEPAGE_UTF8) then
    begin
      Self.FVirtuals.WriteUTF8Chars(Self, FBuffer.Cached.Chars, FBuffer.Cached.Length);
      Exit;
    end else
    begin
      if (ACodePage <> Self.FSBCSLookup.Current.CodePage) then
      begin
        if (ACodePage <> 0) and (ACodePage <> CODEPAGE_DEFAULT) then
        begin
          Self.WriteBufferedSBCSChars(ACodePage);
          Exit;
        end else
        begin
          Self.FSBCSLookup.Current.NativeFlags := Self.FSBCSLookup.Default.NativeFlags;
          Self.FSBCSLookup.CurrentConverter := Self.FSBCSLookup.DefaultConverter;
        end;
      end;

      Self.FVirtuals.WriteSBCSCharsInternal(Self, FBuffer.Cached.Chars, FBuffer.Cached.Length);
    end;
  end;
end;

procedure TCachedTextWriter.WriteShortString(const S: ShortString; const ACodePage: Word);
var
  LLength: NativeUInt;
begin
  LLength := PByte(@S)^;
  if (LLength <> 0) then
  begin
    FBuffer.Cached.Length := LLength;
    NativeUInt(FBuffer.Cached.Chars) := NativeUInt(@S[1]);

    if (ACodePage = CODEPAGE_UTF8) then
    begin
      Self.FVirtuals.WriteUTF8Chars(Self, FBuffer.Cached.Chars, FBuffer.Cached.Length);
      Exit;
    end else
    begin
      if (ACodePage <> Self.FSBCSLookup.Current.CodePage) then
      begin
        if (ACodePage <> 0) and (ACodePage <> CODEPAGE_DEFAULT) then
        begin
          Self.WriteBufferedSBCSChars(ACodePage);
          Exit;
        end else
        begin
          Self.FSBCSLookup.Current.NativeFlags := Self.FSBCSLookup.Default.NativeFlags;
          Self.FSBCSLookup.CurrentConverter := Self.FSBCSLookup.DefaultConverter;
        end;
      end;

      Self.FVirtuals.WriteSBCSCharsInternal(Self, FBuffer.Cached.Chars, FBuffer.Cached.Length);
    end;
  end;
end;

procedure TCachedTextWriter.WriteUTF8String(const S: UTF8String);
var
  P: PInteger;
  LLength: NativeUInt;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    Dec(NativeInt(P), ASTR_OFFSET_LENGTH);
    LLength := P^;
    Inc(NativeInt(P), ASTR_OFFSET_LENGTH);
    Self.FVirtuals.WriteUTF8Chars(Self, Pointer(P), LLength);
  end;
end;

procedure TCachedTextWriter.WriteWideString(const S: WideString);
var
  P: PInteger;
  LLength: NativeUInt;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    Dec(NativeInt(P), WSTR_OFFSET_LENGTH);
    LLength := P^;
    Inc(NativeInt(P), WSTR_OFFSET_LENGTH);
    {$ifdef MSWINDOWS}
    if (LLength <> 0) then
    {$endif}
    Self.FVirtuals.WriteUnicodeChars(Self, Pointer(P), LLength {$ifdef WIDESTRLENSHIFT} shr 1{$endif});
  end;
end;

procedure TCachedTextWriter.WriteUnicodeString(const S: UnicodeString);
var
  P: PInteger;
  LLength: NativeUInt;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    Dec(NativeInt(P), USTR_OFFSET_LENGTH);
    LLength := P^;
    Inc(NativeInt(P), USTR_OFFSET_LENGTH);
    {$if not Defined(UNICODE) and Defined(WIDESTRLENSHIFT)}
    if (LLength = 0) then Exit;
    LLength := LLength shr 1;
    {$ifend}
    Self.FVirtuals.WriteUnicodeChars(Self, Pointer(P), LLength);
  end;
end;

procedure TCachedTextWriter.WriteUCS4String(const S: UCS4String;
  const ANullTerminated: Boolean);
var
  P: PNativeInt;
  LLength: NativeUInt;
begin
  P := Pointer(S);
  if (P <> nil) then
  begin
    Dec(P);
    LLength := P^ - Ord(ANullTerminated) {$ifdef FPC}+ 1{$endif};
    Inc(P);
    if (LLength <> 0) then
    begin
      FUTF32Context.Source := P;
      FUTF32Context.SourceSize := LLength shl 2;
      Self.WriteContextData(FUTF32Context);
    end;
  end;
end;

procedure TCachedTextWriter.WriteAnsiChars(const AChars: PAnsiChar;
  const ALength: NativeUInt; const ACodePage: Word);
var
  CP: Word;
begin
  if (ALength <> 0) then
  begin
    CP := ACodePage;
    if (CP = CODEPAGE_UTF8) then
    begin
      Self.FVirtuals.WriteUTF8Chars(Self, Pointer(AChars), ALength);
      Exit;
    end else
    begin
      if (CP <> Self.FSBCSLookup.Current.CodePage) then
      begin
        if (CP <> 0) and (CP <> CODEPAGE_DEFAULT) then
        begin
          FBuffer.Cached.Chars := AChars;
          FBuffer.Cached.Length := ALength;
          Self.WriteBufferedSBCSChars(CP);
          Exit;
        end else
        begin
          Self.FSBCSLookup.Current.NativeFlags := Self.FSBCSLookup.Default.NativeFlags;
          Self.FSBCSLookup.CurrentConverter := Self.FSBCSLookup.DefaultConverter;
        end;
      end;

      Self.FVirtuals.WriteSBCSCharsInternal(Self, Pointer(AChars), ALength);
    end;
  end;
end;

procedure TCachedTextWriter.WriteUCS4Chars(const AChars: PUCS4Char; const ALength: NativeUInt);
begin
  if (ALength <> 0) then
  begin
    FUTF32Context.Source := AChars;
    FUTF32Context.SourceSize := ALength shl 2;
    Self.WriteContextData(FUTF32Context);
  end;
end;

procedure TCachedTextWriter.WriteFormat(const FmtStr: AnsiString;
  const Args: array of const {$ifNdef INTERNALCODEPAGE}; const ACodePage: Word{$endif});
var
  P: PInteger;
  {$ifdef INTERNALCODEPAGE}
  ACodePage: Word;
  {$endif}
  LIndex: NativeUInt;
  LValue: Integer;
begin
  P := Pointer(FmtStr);
  if (P = nil) then Exit;

  Self.FFormat.Args := @Args[0];
  Self.FFormat.TopArg := @Args[Length(Args)];
  Self.FFormat.ArgsCount := Length(Args);

  Self.FFormat.FmtStr.Chars := P;
  Dec(NativeInt(P), ASTR_OFFSET_LENGTH);
  Self.FFormat.FmtStr.Length := P^;

  {$ifdef INTERNALCODEPAGE}
  Dec(NativeInt(P), (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
  ACodePage := PWord(P)^;
  {$endif}
  if (ACodePage = 0) or (ACodePage = CODEPAGE_DEFAULT) then
  begin
    Self.FFormat.FmtStr.Flags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
  end else
  begin
    LValue := Integer($ff000000);
    if (ACodePage <> CODEPAGE_UTF8) then
    begin
      LIndex := NativeUInt(ACodePage);
      LValue := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[LIndex and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(LValue) = ACodePage) or (LValue < 0) then Break;
        LValue := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(LValue) shr 24]);
      until (False);

      LValue := LValue shl 8;
      LValue := LValue and $ff000000;
    end;

    Self.FFormat.FmtStr.Flags := LValue;
  end;

  Self.WriteFormatByte;
end;

procedure TCachedTextWriter.WriteFormatUTF8(const FmtStr: UTF8String;
  const Args: array of const);
var
  P: PInteger;
begin
  P := Pointer(FmtStr);
  if (P = nil) then Exit;

  Self.FFormat.Args := @Args[0];
  Self.FFormat.TopArg := @Args[Length(Args)];
  Self.FFormat.ArgsCount := Length(Args);

  Self.FFormat.FmtStr.Chars := P;
  Dec(NativeInt(P), ASTR_OFFSET_LENGTH);
  Self.FFormat.FmtStr.Length := P^;
  Self.FFormat.FmtStr.Flags := $ff000000;

  Self.WriteFormatByte;
end;

procedure TCachedTextWriter.WriteFormatUnicode(const FmtStr: UnicodeString;
  const Args: array of const);
var
  P: PInteger;
begin
  P := Pointer(FmtStr);
  if (P = nil) then Exit;

  Self.FFormat.Args := @Args[0];
  Self.FFormat.TopArg := @Args[Length(Args)];
  Self.FFormat.ArgsCount := Length(Args);

  Self.FFormat.FmtStr.Chars := P;
  Dec(NativeInt(P), USTR_OFFSET_LENGTH);
  Self.FFormat.FmtStr.Length := P^{$if not Defined(UNICODE) and Defined(WIDESTRLENSHIFT)} shr 1{$ifend};
  Self.FFormat.FmtStr.Flags := 0;

  Self.WriteFormatWord;
end;

{$ifdef NEXTGEN}
procedure TCachedTextWriter.WriteFormat(const FmtStr: UnicodeString; const Args: array of const);
begin
  WriteFormatUnicode(FmtStr, Args);
end;

procedure TCachedTextWriter.WriteFormatUTF8(const FmtStr: UnicodeString;
  const Args: array of const);
begin
  WriteFormatUnicode(FmtStr, Args);
end;
{$endif}

const
  FMT_MIN_WIDTH = -99;
  FMT_MAX_WIDTH =  99;
  FMT_MAX_PRECISION = 99;

  FMT_CHAR_TYPE     = 0; // 'd', 'u', 'e', 'f', 'g', 'n', 'm', 'p', 's', 'x'
  FMT_CHAR_POINT    = 1; // '.'
  FMT_CHAR_ASTERISK = 2; // '*'
  FMT_CHAR_MINUS    = 3; // '-'
  FMT_CHAR_DIGIT    = 4; // '0'..'9'
  FMT_CHAR_PERSENT  = 5; // '%'
  FMT_CHAR_COLON    = 6; // ':'

  FCTP = FMT_CHAR_TYPE;
  FC09 = FMT_CHAR_DIGIT;

  FMT_CHARS: array[Byte] of Byte = (
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, {} $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 00-0f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, {} $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 10-1f
     $ff, $ff, $ff, $ff, $ff, FMT_CHAR_PERSENT, $ff, $ff, {} $ff, $ff, FMT_CHAR_ASTERISK, $ff, $ff, FMT_CHAR_MINUS, FMT_CHAR_POINT, $ff, // 20-2f
    FC09,FC09,FC09,FC09,FC09,FC09,FC09,FC09, {}FC09,FC09, FMT_CHAR_COLON, $ff, $ff, $ff, $ff, $ff, // 30-3f
     $ff, $ff, $ff, $ff,FCTP,FCTP,FCTP,FCTP, {} $ff, $ff, $ff, $ff, $ff,FCTP,FCTP, $ff, // 40-4f
    FCTP, $ff, $ff,FCTP, $ff,FCTP, $ff, $ff, {} FCTP, $ff, $ff, $ff, $ff, $ff, $ff, $ff,// 50-5f
     $ff, $ff, $ff, $ff,FCTP,FCTP,FCTP,FCTP, {} $ff, $ff, $ff, $ff, $ff,FCTP,FCTP, $ff, // 60-6f
    FCTP, $ff, $ff,FCTP, $ff,FCTP, $ff, $ff, {} FCTP, $ff, $ff, $ff, $ff, $ff, $ff, $ff,// 70-7f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, {} $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 80-8f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, {} $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 90-9f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, {} $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // a0-af
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, {} $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // b0-bf
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, {} $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // c0-cf
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, {} $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // d0-df
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, {} $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // e0-ef
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, {} $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  // f0-ff
  );


procedure WriteDefaultSBCSChar(var ADigitsRec: TDigitsRec; const C: AnsiChar);
begin
  with TTextConvSBCSEx(DEFAULT_TEXTCONV_SBCS^) do
  PWideChar(@ADigitsRec.Ascii)^ := AllocFillUCS2(FUCS2.Original, ccOriginal)[C];
end;

procedure TCachedTextWriter.WriteFormatString(const AArg: TVarRec);
label
  {$if Defined(ANSISTRSUPPORT) or Defined(SHORTSTRSUPPORT)}
  ansi_assign_default, ansi_convert_utf16,
  {$ifend}
  ascii_align;
var
  S: Pointer;
  LCount: NativeUInt;
  {$ifdef ANSISTRSUPPORT}
  LLookup: PTextConvWB;
  {$endif}
  LWidth: NativeInt;
begin
  S := AArg.VPointer;
  case AArg.VType of
    {$ifdef ANSISTRSUPPORT}
    vtChar:
    begin
      LLookup := Pointer(PTextConvSBCSEx(DEFAULT_TEXTCONV_SBCS).FUCS2.Original);
      if (LLookup = nil) then
      begin
        WriteDefaultSBCSChar(FBuffer.Digits, AnsiChar(Byte(S)));
      end else
      begin
        PWord(@FBuffer.Digits.Ascii)^ := LLookup[Byte(S)];
      end;
      S := Pointer(@FBuffer.Digits.Ascii);
      LCount := Byte(PWord(@FBuffer.Digits.Ascii)^ <> 0);
    end;
    vtPChar:
    begin
      LCount := AStrLen(S);
      goto ansi_assign_default;
    end;
    vtAnsiString:
    begin
      with ByteString(FBuffer.Cached) do Assign(AnsiString(AArg.VPointer{S}));
      if (Self.FFormat.Settings.F.PrecisionWidth <> UNDEFINED_PRECISIONWIDTH) then
        goto ansi_convert_utf16;

      Self.WriteByteString(ByteString(FBuffer.Cached));
      Exit;
    {$ifNdef SHORTSTRSUPPORT}
      LCount := 0;
    {$else}
    end;
    vtString:
    begin
      LCount := PByte(AArg.VPointer)^;
      Inc(NativeUInt(S));
    {$endif}

    ansi_assign_default:
      FBuffer.Cached.Length := LCount;
      FBuffer.Cached.Chars := S;
      FBuffer.Cached.NativeFlags := DEFAULT_TEXTCONV_SBCS_INDEX shl 24;
      if (Self.FFormat.Settings.F.PrecisionWidth = UNDEFINED_PRECISIONWIDTH) then
      begin
        Self.WriteByteString(ByteString(FBuffer.Cached));
        Exit;
      end else
      begin
      ansi_convert_utf16:
        FBuffer.UnicodeTemp.Length := 0;
        FBuffer.UnicodeTemp.Append(ByteString(FBuffer.Cached));
        S := FBuffer.UnicodeTemp.Chars;
        LCount := FBuffer.UnicodeTemp.Length;
      end;
    end;
    {$endif}
    {$ifdef WIDESTRSUPPORT}
    vtWideString:
    begin
      if (S <> nil) then
      begin
        LCount := PInteger(PAnsiChar(S) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT} shr 1{$endif};
      end else
      begin
        LCount := 0;
      end;
    end;
    {$endif}
    vtPWideChar:
    begin
      LCount := WStrLen(S);
    end;
    vtVariant:
    begin
      FBuffer.UnicodeTemp.Length := 0;
      FBuffer.UnicodeTemp.AppendVariant(AArg.VVariant^, Self.FloatSettings, Self.DateTimeSettings);
      S := FBuffer.UnicodeTemp.Chars;
      LCount := FBuffer.UnicodeTemp.Length;
    end;
    {$ifdef UNICODE}
    vtUnicodeString:
    begin
      if (S <> nil) then
      begin
        LCount := PInteger(PAnsiChar(S) - USTR_OFFSET_LENGTH)^;
      end else
      begin
        LCount := 0;
      end;
    end;
    {$endif}
  else
    // vtWideChar
    S := Pointer(@AArg.VWideChar);
    LCount := Byte(AArg.VWideChar <> #0);
  end;

  LWidth := Self.FFormat.Settings.Precision;
  if (NativeUInt(LWidth) < LCount) then
    LCount := NativeUInt(LWidth);

  LWidth := Self.FFormat.Settings.Width;
  if (LWidth < 0) then
  begin
    LWidth := -LWidth;
    FVirtuals.WriteUnicodeChars(Self, S, LCount);
    FBuffer.Cached.Chars{S} := nil;
    if (NativeUInt(LWidth) > LCount) then goto ascii_align;
  end else
  begin
    FBuffer.Cached.Chars := S;

    if (NativeUInt(LWidth) > LCount) then
    begin
    ascii_align:
      Dec(LWidth, LCount);
      FBuffer.Digits.Quads[0] := $20202020;
      FBuffer.Digits.Quads[1] := $20202020;
      if (LWidth > 8) then
      repeat
        Dec(LWidth, 8);
        FVirtuals.WriteBufferedAscii(Self, Pointer(@FBuffer.Digits.Quads[0]), 8);
      until (LWidth <= 8);
      FVirtuals.WriteBufferedAscii(Self, Pointer(@FBuffer.Digits.Quads[0]), LWidth);
    end;

    S := FBuffer.Cached.Chars;
    if (S <> nil) then
      FVirtuals.WriteUnicodeChars(Self, S, LCount);
  end;
end;

function TCachedTextWriter.WriteFormatArg(const AArgType: NativeUInt; const AArg: TVarRec): Boolean;
label
  cardinal_value, uint64_value, float_value,
  write_difficult_string, fail,
  count_calculated, ascii_align, done;
type
  TIntegerProc = procedure(const Self: TCachedTextWriter; const Value: Integer; const Digits: NativeUInt);
  TInt64Proc = procedure(const Self: TCachedTextWriter; const Value: Int64; const Digits: NativeUInt);
const
  CHD = 0; // 'd'
  CHU = 1; // 'u'
  CHX = 2; // 'x'
  CHP = 3; // 'p'
  CHG = 4; // 'g'
  CHE = 5; // 'e'
  CHF = 6; // 'f'
  CHN = 7; // 'n'
  CHM = 8; // 'm'
  CHS = 9; // 's'

  CHAR_LOOKUP: array[0..31] of Byte = (
     $ff, $ff, $ff, $ff, CHD, CHE, CHF, CHG, $ff, $ff, $ff, $ff, $ff, CHM, CHN, $ff,
     CHP, $ff, $ff, CHS, $ff, CHU, $ff, $ff, CHX, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  );

const
  INTEGER_PROCS: array[CHD..CHX] of Pointer = (
    @TCachedTextWriter.WriteInteger,
    @TCachedTextWriter.WriteCardinal,
    @TCachedTextWriter.WriteHex
  );
  INT64_PROCS: array[CHD..CHX] of Pointer = (
    @TCachedTextWriter.WriteInt64,
    @TCachedTextWriter.WriteUInt64,
    @TCachedTextWriter.WriteHex64
  );
var
  X: NativeUInt;
  LWidth, LPrecision: NativeInt;
  VExtended: PExtended;
  VInteger: Integer;
  VInt64: PInt64;
  P: PByte;
  LCount: NativeUInt;
begin
  X := (AArgType or $20) - $60;
  LPrecision := Self.FFormat.Settings.F.PrecisionWidth;
  if (X >= NativeUInt(Length(CHAR_LOOKUP))) then goto fail;
  X := CHAR_LOOKUP[X];
  LWidth := SmallInt(LPrecision shr 16);
  LPrecision := SmallInt(LPrecision);

  case AArg.VType of
    vtInteger:
    begin
      LPrecision := LPrecision and -NativeInt(NativeUInt(LPrecision) <= 16);
      if (X > CHX) then goto fail;
      if (LWidth = UNDEFINED_WIDTH) then
      begin
        TIntegerProc(INTEGER_PROCS[X])(Self, AArg.VInteger, LPrecision);
        goto done;
      end else
      begin
        VInteger := AArg.VInteger;
        case X of
          CHX{'x'}:
          begin
            P := WriteHexAscii(FBuffer.Digits, Cardinal(VInteger), LPrecision);
          end;
          CHU{'u'}: goto cardinal_value;
        else
          // CHD{'d'}:
          if (VInteger >= 0) then
          begin
          cardinal_value:
            P := WriteCardinalAscii(FBuffer.Digits, Cardinal(VInteger), LPrecision);
          end else
          begin
            VInteger := -VInteger;
            P := WriteCardinalAscii(FBuffer.Digits, Cardinal(VInteger), LPrecision);
            Dec(P);
            P^ := Ord('-');
          end;
        end;
      end;
    end;
    vtInt64:
    begin
      LPrecision := LPrecision and -NativeInt(NativeUInt(LPrecision) <= 32);
      if (X > CHX) then goto fail;
      if (LWidth = UNDEFINED_WIDTH) then
      begin
        TInt64Proc(INT64_PROCS[X])(Self, AArg.VInt64^, LPrecision);
        goto done;
      end else
      begin
        VInt64 := AArg.VInt64;
        case X of
          CHX{'x'}:
          begin
            P := WriteHex64Ascii(FBuffer.Digits, VInt64{$ifdef LARGEINT}^{$endif}, LPrecision);
          end;
          CHU{'u'}: goto uint64_value;
        else
          // CHD{'d'}:
          if ({$ifdef SMALLINT}TPoint(Pointer(VInt64)^).Y{$else}VInt64^{$endif} >= 0) then
          begin
          uint64_value:
            P := WriteUInt64Ascii(FBuffer.Digits, VInt64{$ifdef LARGEINT}^{$endif}, LPrecision);
          end else
          begin
            PInt64(@FBuffer.Digits.Ascii)^ := -VInt64^;
            P := WriteUInt64Ascii(FBuffer.Digits, PInt64(@FBuffer.Digits.Ascii){$ifdef LARGEINT}^{$endif}, LPrecision);
            Dec(P);
            P^ := Ord('-');
          end;
        end;
      end;
    end;
    vtPointer:
    begin
      Dec(LPrecision, SizeOf(Pointer) * 2);
      LPrecision := LPrecision and -NativeInt(NativeUInt(LPrecision) <= (32 - SizeOf(Pointer) * 2));
      if (X <> CHP) then goto fail;
      Inc(LPrecision, SizeOf(Pointer) * 2);

      {$ifdef SMALLINT}
         P := WriteHexAscii(FBuffer.Digits, Cardinal(AArg.VPointer), LPrecision);
      {$else .LARGEINT}
         P := WriteHex64Ascii(FBuffer.Digits, Int64(AArg.VPointer), LPrecision);
      {$endif}
    end;
    vtCurrency:
    begin
      PExtended(@Self.FBuffer.Digits.Ascii[0])^ := AArg.VInt64^ * (1 / 10000);
      VExtended := Pointer(@Self.FBuffer.Digits.Ascii[0]);
      goto float_value;
    end;
    vtExtended:
    begin
      VExtended := AArg.VExtended;

    float_value:
      Self.FFormat.Settings.F.Options := Self.FloatSettings.F.Options;
      case X of
        CHG{'g'}:
        begin
          Self.FFormat.Settings.Format := ffGeneral;
          Self.FFormat.Settings.Precision := LPrecision;
          Self.FFormat.Settings.Digits := 3;
          if (NativeUInt(LPrecision) > 18) then
            Self.FFormat.Settings.Precision := 15;
        end;
        CHE{'e'}:
        begin
          Self.FFormat.Settings.Format := ffExponent;
          Self.FFormat.Settings.Precision := LPrecision;
          Self.FFormat.Settings.Digits := 3;
          if (NativeUInt(LPrecision) > 18) then
            Self.FFormat.Settings.Precision := 15;
        end;
        CHF{'f'}:
        begin
          Self.FFormat.Settings.Format := ffFixed;
          Self.FFormat.Settings.Precision := 18;
          Self.FFormat.Settings.Digits := LPrecision;
          if (NativeUInt(LPrecision) > 18) then
            Self.FFormat.Settings.Digits := 2;
        end;
        CHN{'n'}:
        begin
          Self.FFormat.Settings.Format := ffNumber;
          Self.FFormat.Settings.Precision := 18;
          Self.FFormat.Settings.Digits := LPrecision;
          if (NativeUInt(LPrecision) > 18) then
            Self.FFormat.Settings.Digits := 2;
        end;
        // CHM{'m'}: goto fail;
      else
        goto fail;
      end;

      LCount := Tiny.Cache.Text.WriteFloatAscii(FBuffer.Digits, VExtended{$ifNdef EXTENDEDSUPPORT}^{$endif}, Self.FFormat.Settings);
      P := @FBuffer.Digits.Ascii[0];
      Dec(P, LCount and 1);
      LCount := LCount shr 1;
      if (LWidth <> UNDEFINED_WIDTH) then goto count_calculated;
      FVirtuals.WriteBufferedAscii(Self, P, LCount);
      goto done;
    end;
    {$ifdef UNICODE}
      {$ifdef ANSISTRSUPPORT}
      vtAnsiString,
      {$endif}
      {$ifdef WIDESTRSUPPORT}
      vtWideString,
      {$endif}
      vtUnicodeString:
    {$else}
      vtAnsiString, vtWideString:
    {$endif}
    begin
      if (X <> CHS) then goto fail;
      if (Self.FFormat.Settings.F.PrecisionWidth <> UNDEFINED_PRECISIONWIDTH) then
        goto write_difficult_string;

      P := AArg.VPointer;
      if (P <> nil) then
      case AArg.VType of
        {$ifdef ANSISTRSUPPORT}
        vtAnsiString:
        begin
          with ByteString(FBuffer.Cached) do Assign(AnsiString(Pointer(P)));
          Self.WriteByteString(ByteString(FBuffer.Cached));
        end;
        {$endif}
        {$ifdef WIDESTRSUPPORT}
        vtWideString:
        begin
          FVirtuals.WriteUnicodeChars(Self, Pointer(P),
            PInteger(NativeUInt(P) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT} shr 1{$endif});
        end;
        {$endif}
        {$ifdef UNICODE}
        vtUnicodeString:
        begin
          FVirtuals.WriteUnicodeChars(Self, Pointer(P),
            PInteger(NativeUInt(P) - USTR_OFFSET_LENGTH)^);
        end;
        {$endif}
      end;
      goto done;
    end;
  else
    case AArg.VType of
      vtChar, vtPChar, {$ifNdef NEXTGEN}vtString,{$endif} vtWideChar, vtPWideChar, vtVariant:
      begin
        if (X <> CHS) then goto fail;
      write_difficult_string:
        Self.WriteFormatString(AArg);
        goto done;
      end;
    end;
  fail:
    Result := False;
    Exit;
  end;

  // default (integer/hex) count case
  LCount := NativeUInt(@FBuffer.Digits.Buffer[0]) - NativeUInt(P);

count_calculated:
  // ascii spaces align
  if (LWidth < 0) then
  begin
    LWidth := -LWidth;
    FVirtuals.WriteBufferedAscii(Self, P, LCount);
    PPointer(@FBuffer.Digits.Quads[2])^{P} := nil;
    if (NativeUInt(LWidth) > LCount) then goto ascii_align;
  end else
  begin
    PPointer(@FBuffer.Digits.Quads[2])^ := P;

    if (NativeUInt(LWidth) > LCount) then
    begin
    ascii_align:
      Dec(LWidth, LCount);
      FBuffer.Digits.Quads[0] := $20202020;
      FBuffer.Digits.Quads[1] := $20202020;
      if (LWidth > 8) then
      repeat
        Dec(LWidth, 8);
        FVirtuals.WriteBufferedAscii(Self, Pointer(@FBuffer.Digits.Quads[0]), 8);
      until (LWidth <= 8);
      FVirtuals.WriteBufferedAscii(Self, Pointer(@FBuffer.Digits.Quads[0]), LWidth);
    end;

    P := PPointer(@FBuffer.Digits.Quads[2])^;
    if (P <> nil) then
      FVirtuals.WriteBufferedAscii(Self, P, LCount);
  end;

done:
  Result := True;
end;

procedure TCachedTextWriter.WriteFormatByte;
label
  einvalid_format, eargument_missing, next_iteration,
  _1, _2, _3, write_substring,
  unspecified_ordinal_found, leftjustification_found, prec_found, type_found,
  fill_width, fill_precision;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  PERSENT_XOR_MASK = $25252525;
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
  ASCII_MASK = Integer($80808080);
var
  S, TopS: PByte;
  Arg: PVarRec;
  Flags, X, V: NativeInt;
  TopSCardinal: PByte;

  Store: packed record
    TopS: PByte;
    TopSCardinal: PByte;
    Arg: PVarRec;
  end;
begin
  // store parameters
  S := Self.FFormat.FmtStr.Chars;
  X := Self.FFormat.FmtStr.Length;
  Store.TopS := Pointer(@PByteCharArray(S)[X]);
  Store.TopSCardinal := Pointer(@PByteCharArray(S)[X - CHARS_IN_CARDINAL]);
  if (X = 0) then
  begin
    Exit;

  einvalid_format:
    raise ETinyString.Create(
      Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidFormat),
      PByteString(@Self.FFormat.FmtStr));

  eargument_missing:
    raise ETinyString.Create(
      Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SArgumentMissing),
      PByteString(@Self.FFormat.FmtStr));
  end;
  Store.Arg := Self.FFormat.Args;

  repeat
    // unformatted substring
    Self.FBuffer.Cached.Chars := S;
    TopSCardinal := Store.TopSCardinal;
    Flags := -1;
    X := -1;
    repeat
      Flags := Flags and X;
      if (NativeUInt(S) > NativeUInt(TopSCardinal)) then Break;
      X := PCardinal(S)^;
      Inc(S, CHARS_IN_CARDINAL);

      X := X xor PERSENT_XOR_MASK;
      V := X + SUB_MASK;
      X := not X;

      if (V and OVERFLOW_MASK and X = 0) then Continue;
      Dec(S, CHARS_IN_CARDINAL);
      X := ((not X) + SUB_MASK) and X;
      X := Byte(Byte(X and $80 = 0) + Byte(X and $8080 = 0) + Byte(X and $808080 = 0));
      Flags := Flags and (not NativeInt(PCardinal(S)^ and BYTE_MASKS[X]));
      Inc(S, X);
      goto write_substring;
    until (False);

    case (NativeUInt(TopSCardinal) + SizeOf(Cardinal) - NativeUInt(S)) of
      3:
      begin
      _3:
        X := S^;
        if (X = Ord('%')) then goto write_substring;
        Flags := Flags and (not X);
        Inc(S);
        goto _2;
      end;
      2:
      begin
      _2:
        X := S^;
        if (X = Ord('%')) then goto write_substring;
        Flags := Flags and (not X);
        Inc(S);
        goto _1;
      end;
      1:
      begin
      _1:
        X := S^;
        if (X = Ord('%')) then goto write_substring;
        Flags := Flags and (not X);
        Inc(S);
      end;
    end;

  write_substring:
    X := NativeUInt(S) - NativeUInt(Self.FBuffer.Cached.Chars);
    if ((not Flags) and ASCII_MASK = 0) and (X <> 0) then
    begin
      Self.FVirtuals.WriteAscii(Self, Self.FBuffer.Cached.Chars, X);
    end else
    begin
      Self.FBuffer.Cached.Length := X;
      Self.FBuffer.Cached.Flags := Self.FFormat.FmtStr.Flags;
      if (Self.FBuffer.Cached.Length <> 0) then
        Self.WriteByteString(ByteString(Self.FBuffer.Cached));
    end;
    Inc(S);
    TopS := Store.TopS;
    if (NativeUInt(S) >= NativeUInt(TopS)) then Exit;

    // "%"  [index ":"] ["-"] [width] ["." prec] type
    // "%%"
    Arg := Store.Arg;
    Self.FFormat.Settings.F.PrecisionWidth := UNDEFINED_PRECISIONWIDTH;
    X := S^;
    Inc(S);
    X := FMT_CHARS[X];
    case NativeUInt(X) of
      FMT_CHAR_TYPE: goto type_found;
      FMT_CHAR_POINT: goto prec_found;
      FMT_CHAR_ASTERISK:
      begin
        if (Arg = Self.FFormat.TopArg) then goto eargument_missing;
        if (Arg.VType <> vtInteger) then goto einvalid_format;
        V := Arg.VInteger;
        Inc(Arg);

        goto unspecified_ordinal_found;
      end;
      FMT_CHAR_MINUS: goto leftjustification_found;
      FMT_CHAR_DIGIT:
      begin
        // unspecified digits (0..999) --> ordinal
        Dec(S);
        V := S^;
        Inc(S);
        Dec(V, Ord('0'));

        if (S = TopS) then goto einvalid_format;
        X := S^;
        Inc(S);
        Dec(X, Ord('0'));
        if (NativeUInt(X) < 10) then
        begin
          V := V * 10;
          V := V + X;
          if (S = TopS) then goto einvalid_format;
          X := S^;
          Inc(S);
          Dec(X, Ord('0'));
          if (NativeUInt(X) < 10) then
          begin
            V := V * 10;
            V := V + X;
          unspecified_ordinal_found:
            if (S = TopS) then goto einvalid_format;
            X := S^;
            Inc(S);
            Dec(X, Ord('0'));
          end;
        end;

        X := FMT_CHARS[X + Ord('0')];
        case NativeUInt(X) of
          FMT_CHAR_TYPE:
          begin
            Self.FFormat.Settings.Width := V;
            if (V < FMT_MIN_WIDTH) then goto einvalid_format;
            if (V > FMT_MAX_WIDTH) then goto einvalid_format;
            goto type_found;
          end;
          FMT_CHAR_POINT:
          begin
            Self.FFormat.Settings.Width := V;
            if (V < FMT_MIN_WIDTH) then goto einvalid_format;
            if (V > FMT_MAX_WIDTH) then goto einvalid_format;
            goto prec_found;
          end;
          FMT_CHAR_COLON:
          begin
            if (NativeUInt(V) >= Self.FFormat.ArgsCount) then goto eargument_missing;
            Arg := Self.FFormat.Args;
            Inc(Arg, V);
          end;
        else
          goto einvalid_format;
        end;
      end;
      FMT_CHAR_PERSENT:
      begin
        Self.FVirtuals.WriteBufferedAscii(Self, @FBuffer.Constants[{'%'}2], 1);
        goto next_iteration;
      end;
    else
      goto einvalid_format;
    end;

    (*
        FMT_CHAR_TYPE     = 0; // 'd', 'u', 'e', 'f', 'g', 'n', 'm', 'p', 's', 'x'
        FMT_CHAR_POINT    = 1; // '.'
        FMT_CHAR_ASTERISK = 2; // '*'
        FMT_CHAR_MINUS    = 3; // '-'
        FMT_CHAR_DIGIT    = 4; // '0'..'9'
        FMT_CHAR_PERSENT  = 5; // '%'
        FMT_CHAR_COLON    = 6; // ':'
    *)

    // width (precision/type)
    if (S = TopS) then goto einvalid_format;
    X := S^;
    Inc(S);
    X := FMT_CHARS[X];
    case NativeUInt(X) of
      FMT_CHAR_TYPE: goto type_found;
      FMT_CHAR_POINT: goto prec_found;
      FMT_CHAR_ASTERISK:
      begin
        // width argument
        if (Arg = Self.FFormat.TopArg) then goto eargument_missing;
        if (Arg.VType <> vtInteger) then goto einvalid_format;
        V := Arg.VInteger;
        Inc(Arg);

        if (V < FMT_MIN_WIDTH) then goto einvalid_format;
        if (V > FMT_MAX_WIDTH) then goto einvalid_format;
        if (S = TopS) then goto einvalid_format;
        X := S^;
        Inc(S);
        Dec(X, Ord('0'));
        goto fill_width;
      end;
      FMT_CHAR_MINUS:
      begin
      leftjustification_found:
        // negative width digits
        V := 0;
        if (S = TopS) then goto einvalid_format;
        X := S^;
        Inc(S);
        Dec(X, Ord('0'));
        if (NativeUInt(X) < 10) then
        begin
          V := V - X;
          if (S = TopS) then goto einvalid_format;
          X := S^;
          Inc(S);
          Dec(X, Ord('0'));
          if (NativeUInt(X) < 10) then
          begin
            V := V * 10;
            V := V - X;
            if (S = TopS) then goto einvalid_format;
            X := S^;
            Inc(S);
            Dec(X, Ord('0'));
          end;
        end;
        goto fill_width;
      end;
      FMT_CHAR_DIGIT:
      begin
        // width digits
        Dec(S);
        V := S^;
        Inc(S);
        Dec(V, Ord('0'));

        if (S = TopS) then goto einvalid_format;
        X := S^;
        Inc(S);
        Dec(X, Ord('0'));
        if (NativeUInt(X) < 10) then
        begin
          V := V * 10;
          V := V + X;
          if (S = TopS) then goto einvalid_format;
          X := S^;
          Inc(S);
          Dec(X, Ord('0'));
        end;

      fill_width:
        Self.FFormat.Settings.Width := V;
        X := FMT_CHARS[X + Ord('0')];
      end;
    else
      goto einvalid_format;
    end;

    // precision
    if (X = FMT_CHAR_POINT) then
    begin
    prec_found:
      TopS := Store.TopS;
      if (S = TopS) then goto einvalid_format;
      X := S^;
      Inc(S);
      if (X = Ord('*')) then
      begin
        // precision argument
        if (Arg = Self.FFormat.TopArg) then goto eargument_missing;
        if (Arg.VType <> vtInteger) then goto einvalid_format;
        V := Arg.VInteger;
        Inc(Arg);

        if (NativeUInt(V) > FMT_MAX_PRECISION) then goto einvalid_format;
        if (S = TopS) then goto einvalid_format;
        Inc(S);
        goto fill_precision;
      end else
      begin
        // precision digits
        Dec(X, Ord('0'));
        if (NativeUInt(X) < 10) then
        begin
          V := X;
          if (S = TopS) then goto einvalid_format;
          X := S^;
          Inc(S);
          Dec(X, Ord('0'));
          if (NativeUInt(X) < 10) then
          begin
            V := V * 10;
            V := V + X;
            if (S = TopS) then goto einvalid_format;
            Inc(S);
          end;

        fill_precision:
          Self.FFormat.Settings.F.Precision := V;
        end;
      end;
    end;

  type_found:
    if (Arg = Self.FFormat.TopArg) then goto eargument_missing;
    Inc(Arg);
    Store.Arg := Arg;
    Dec(Arg);
    Dec(S);
    if (not Self.WriteFormatArg(S^, Arg^)) then goto einvalid_format;
    Inc(S);

  next_iteration:
  until (S = Store.TopS);
end;

// WriteFormatByte copy + modified
procedure TCachedTextWriter.WriteFormatWord;
label
  einvalid_format, eargument_missing, next_iteration,
  write_substring,
  unspecified_ordinal_found, leftjustification_found, prec_found, type_found,
  fill_width, fill_precision;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
  PERSENT_XOR_MASK = $00250025;
  SUB_MASK  = Integer(-$00010001);
  OVERFLOW_MASK = Integer($80008000);
  ASCII_MASK = Integer($ff80ff80);
var
  S, TopS: PWord;
  Arg: PVarRec;
  Flags, X, V: NativeInt;
  TopSCardinal: PWord;

  Store: packed record
    TopS: PWord;
    TopSCardinal: PWord;
    Arg: PVarRec;
  end;
begin
  // store parameters
  S := Self.FFormat.FmtStr.Chars;
  X := Self.FFormat.FmtStr.Length;
  Store.TopS := Pointer(@PUTF16CharArray(S)[X]);
  Store.TopSCardinal := Pointer(@PUTF16CharArray(S)[X - CHARS_IN_CARDINAL]);
  if (X = 0) then
  begin
    Exit;

  einvalid_format:
    raise ETinyString.Create(
      Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidFormat),
      PUTF16String(@Self.FFormat.FmtStr));

  eargument_missing:
    raise ETinyString.Create(
      Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SArgumentMissing),
      PUTF16String(@Self.FFormat.FmtStr));
  end;
  Store.Arg := Self.FFormat.Args;

  repeat
    // unformatted substring
    Self.FBuffer.Cached.Chars := S;
    TopSCardinal := Store.TopSCardinal;
    Flags := -1;
    X := -1;
    repeat
      Flags := Flags and X;
      if (NativeUInt(S) > NativeUInt(TopSCardinal)) then Break;
      X := PCardinal(S)^;
      Inc(S, CHARS_IN_CARDINAL);

      X := X xor PERSENT_XOR_MASK;
      V := X + SUB_MASK;
      X := not X;

      if (V and OVERFLOW_MASK and X = 0) then Continue;
      Dec(S, CHARS_IN_CARDINAL);
      X := ((not X) + SUB_MASK) and X;
      X := {0/2}Byte(X and $8000 = 0) * 2;
      Flags := Flags and (not NativeInt(PCardinal(S)^ and BYTE_MASKS[X]));
      Inc(NativeUInt(S), X);
      goto write_substring;
    until (False);

    if (NativeUInt(TopSCardinal) + SizeOf(Cardinal) <> NativeUInt(S)) then
    begin
      X := S^;
      if (X = Ord('%')) then goto write_substring;
      Flags := Flags and (not X);
      Inc(S);
    end;

  write_substring:
    X := NativeUInt(S) - NativeUInt(Self.FBuffer.Cached.Chars);
    if ((not Flags) and ASCII_MASK = 0) and (X <> 0) then
    begin
      Self.FVirtuals.WriteUnicodeAscii(Self, Self.FBuffer.Cached.Chars, X shr 1);
    end else
    begin
      Self.FBuffer.Cached.Length := X;
      Self.FBuffer.Cached.Flags := Self.FFormat.FmtStr.Flags;
      {<--compiler optimizer fix}
      if (X <> 0) then
        Self.FVirtuals.WriteUnicodeChars(Self, Self.FBuffer.Cached.Chars, X shr 1);
    end;
    Inc(S);
    TopS := Store.TopS;
    if (NativeUInt(S) >= NativeUInt(TopS)) then Exit;

    // "%"  [index ":"] ["-"] [width] ["." prec] type
    // "%%"
    Arg := Store.Arg;
    Self.FFormat.Settings.F.PrecisionWidth := UNDEFINED_PRECISIONWIDTH;
    X := S^;
    Inc(S);
    if (X > High(FMT_CHARS)) then goto einvalid_format;
    X := FMT_CHARS[X];
    case NativeUInt(X) of
      FMT_CHAR_TYPE: goto type_found;
      FMT_CHAR_POINT: goto prec_found;
      FMT_CHAR_ASTERISK:
      begin
        if (Arg = Self.FFormat.TopArg) then goto eargument_missing;
        if (Arg.VType <> vtInteger) then goto einvalid_format;
        V := Arg.VInteger;
        Inc(Arg);

        goto unspecified_ordinal_found;
      end;
      FMT_CHAR_MINUS: goto leftjustification_found;
      FMT_CHAR_DIGIT:
      begin
        // unspecified digits (0..999) --> ordinal
        Dec(S);
        V := S^;
        Inc(S);
        Dec(V, Ord('0'));

        if (S = TopS) then goto einvalid_format;
        X := S^;
        Inc(S);
        Dec(X, Ord('0'));
        if (NativeUInt(X) < 10) then
        begin
          V := V * 10;
          V := V + X;
          if (S = TopS) then goto einvalid_format;
          X := S^;
          Inc(S);
          Dec(X, Ord('0'));
          if (NativeUInt(X) < 10) then
          begin
            V := V * 10;
            V := V + X;
          unspecified_ordinal_found:
            if (S = TopS) then goto einvalid_format;
            X := S^;
            Inc(S);
            Dec(X, Ord('0'));
          end;
        end;

        if (X > High(FMT_CHARS) - Ord('0')) then goto einvalid_format;
        X := FMT_CHARS[X + Ord('0')];
        case NativeUInt(X) of
          FMT_CHAR_TYPE:
          begin
            Self.FFormat.Settings.Width := V;
            if (V < FMT_MIN_WIDTH) then goto einvalid_format;
            if (V > FMT_MAX_WIDTH) then goto einvalid_format;
            goto type_found;
          end;
          FMT_CHAR_POINT:
          begin
            Self.FFormat.Settings.Width := V;
            if (V < FMT_MIN_WIDTH) then goto einvalid_format;
            if (V > FMT_MAX_WIDTH) then goto einvalid_format;
            goto prec_found;
          end;
          FMT_CHAR_COLON:
          begin
            if (NativeUInt(V) >= Self.FFormat.ArgsCount) then goto eargument_missing;
            Arg := Self.FFormat.Args;
            Inc(Arg, V);
          end;
        else
          goto einvalid_format;
        end;
      end;
      FMT_CHAR_PERSENT:
      begin
        Self.FVirtuals.WriteBufferedAscii(Self, @FBuffer.Constants[{'%'}2], 1);
        goto next_iteration;
      end;
    else
      goto einvalid_format;
    end;

    (*
        FMT_CHAR_TYPE     = 0; // 'd', 'u', 'e', 'f', 'g', 'n', 'm', 'p', 's', 'x'
        FMT_CHAR_POINT    = 1; // '.'
        FMT_CHAR_ASTERISK = 2; // '*'
        FMT_CHAR_MINUS    = 3; // '-'
        FMT_CHAR_DIGIT    = 4; // '0'..'9'
        FMT_CHAR_PERSENT  = 5; // '%'
        FMT_CHAR_COLON    = 6; // ':'
    *)

    // width (precision/type)
    if (S = TopS) then goto einvalid_format;
    X := S^;
    Inc(S);
    if (X > High(FMT_CHARS)) then goto einvalid_format;
    X := FMT_CHARS[X];
    case NativeUInt(X) of
      FMT_CHAR_TYPE: goto type_found;
      FMT_CHAR_POINT: goto prec_found;
      FMT_CHAR_ASTERISK:
      begin
        // width argument
        if (Arg = Self.FFormat.TopArg) then goto eargument_missing;
        if (Arg.VType <> vtInteger) then goto einvalid_format;
        V := Arg.VInteger;
        Inc(Arg);

        if (V < FMT_MIN_WIDTH) then goto einvalid_format;
        if (V > FMT_MAX_WIDTH) then goto einvalid_format;
        if (S = TopS) then goto einvalid_format;
        X := S^;
        Inc(S);
        Dec(X, Ord('0'));
        goto fill_width;
      end;
      FMT_CHAR_MINUS:
      begin
      leftjustification_found:
        // negative width digits
        V := 0;
        if (S = TopS) then goto einvalid_format;
        X := S^;
        Inc(S);
        Dec(X, Ord('0'));
        if (NativeUInt(X) < 10) then
        begin
          V := V - X;
          if (S = TopS) then goto einvalid_format;
          X := S^;
          Inc(S);
          Dec(X, Ord('0'));
          if (NativeUInt(X) < 10) then
          begin
            V := V * 10;
            V := V - X;
            if (S = TopS) then goto einvalid_format;
            X := S^;
            Inc(S);
            Dec(X, Ord('0'));
          end;
        end;
        goto fill_width;
      end;
      FMT_CHAR_DIGIT:
      begin
        // width digits
        Dec(S);
        V := S^;
        Inc(S);
        Dec(V, Ord('0'));

        if (S = TopS) then goto einvalid_format;
        X := S^;
        Inc(S);
        Dec(X, Ord('0'));
        if (NativeUInt(X) < 10) then
        begin
          V := V * 10;
          V := V + X;
          if (S = TopS) then goto einvalid_format;
          X := S^;
          Inc(S);
          Dec(X, Ord('0'));
        end;

      fill_width:
        Self.FFormat.Settings.Width := V;
        if (X > High(FMT_CHARS) - Ord('0')) then goto einvalid_format;
        X := FMT_CHARS[X + Ord('0')];
      end;
    else
      goto einvalid_format;
    end;

    // precision
    if (X = FMT_CHAR_POINT) then
    begin
    prec_found:
      TopS := Store.TopS;
      if (S = TopS) then goto einvalid_format;
      X := S^;
      Inc(S);
      if (X = Ord('*')) then
      begin
        // precision argument
        if (Arg = Self.FFormat.TopArg) then goto eargument_missing;
        if (Arg.VType <> vtInteger) then goto einvalid_format;
        V := Arg.VInteger;
        Inc(Arg);

        if (NativeUInt(V) > FMT_MAX_PRECISION) then goto einvalid_format;
        if (S = TopS) then goto einvalid_format;
        Inc(S);
        goto fill_precision;
      end else
      begin
        // precision digits
        Dec(X, Ord('0'));
        if (NativeUInt(X) < 10) then
        begin
          V := X;
          if (S = TopS) then goto einvalid_format;
          X := S^;
          Inc(S);
          Dec(X, Ord('0'));
          if (NativeUInt(X) < 10) then
          begin
            V := V * 10;
            V := V + X;
            if (S = TopS) then goto einvalid_format;
            Inc(S);
          end;

        fill_precision:
          Self.FFormat.Settings.F.Precision := V;
        end;
      end;
    end;

  type_found:
    if (Arg = Self.FFormat.TopArg) then goto eargument_missing;
    Inc(Arg);
    Store.Arg := Arg;
    Dec(Arg);
    Dec(S);
    if (not Self.WriteFormatArg(S^, Arg^)) then goto einvalid_format;
    Inc(S);

  next_iteration:
  until (S = Store.TopS);
end;

procedure TCachedTextWriter.WriteBoolean(const AValue: Boolean);
{$ifNdef CPUINTELASM}
var
  P: PByte;
  LCount: NativeUInt;
begin
  LCount := Byte(AValue);
  with Self.FBuffer do P := Pointer(@Booleans[LCount]);
  FVirtuals.WriteBufferedAscii(Self, P, LCount xor 5);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    lea ecx, [EAX].TCachedTextWriter.FBuffer.Booleans
    lea ecx, [ecx + 8 * edx]
    xor edx, 5
    xchg ecx, edx
    jmp [EAX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  {$else .CPUX64}
    lea r8, [RCX].TCachedTextWriter.FBuffer.Booleans
    lea r8, [r8 + 8 * rdx]
    xor rdx, 5
    xchg r8, rdx
    jmp [RCX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  {$endif}
end;
{$endif}

procedure TCachedTextWriter.WriteBooleanOrdinal(const AValue: Boolean);
{$ifNdef CPUINTELASM}
var
  P: PByte;
begin
  with Self.FBuffer do P := Pointer(@Constants[Byte(AValue)]);
  FVirtuals.WriteBufferedAscii(Self, P, 1);
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  movzx edx, dl
  add edx, offset TCachedTextWriter.FBuffer.Constants
  {$ifdef CPUX86}
    mov ecx, 1
    add edx, eax
    jmp [EAX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  {$else .CPUX64}
    mov r8d, 1
    add rdx, rcx
    jmp [RCX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  {$endif}
end;
{$endif}

procedure TCachedTextWriter.WriteInteger(const AValue: Integer; const ADigits: NativeUInt);
{$ifNdef CPUINTELASM}
var
  P: PByte;
  X: NativeUInt;
begin
  if (AValue >= 0) then
  begin
    if (ADigits <= 1) and (AValue < DIGITS_2) then
    begin
      PWord(@FBuffer.Digits.Ascii[30])^ := DIGITS_LOOKUP_ASCII[AValue];
      X := Byte(AValue >= DIGITS_1);
      FVirtuals.WriteBufferedAscii(Self, @FBuffer.Digits.Ascii[31 - X], 1 + X);
      Exit;
    end;

    P := WriteCardinalAscii(FBuffer.Digits, Cardinal(AValue), ADigits);
  end else
  begin
    P := WriteCardinalAscii(FBuffer.Digits, Cardinal(-AValue), ADigits);
    Dec(P);
    P^ := Ord('-');
  end;

  FVirtuals.WriteBufferedAscii(Self, P, NativeUInt(@FBuffer.Digits.Buffer[0]) - NativeUInt(P));
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  test edx, edx
  jl @negative
  {$ifdef CPUX86}
     cmp ecx, 1
     ja @positive
     cmp edx, DIGITS_2
     jae @positive

     mov ecx, [offset DIGITS_LOOKUP_ASCII + edx * 2 - 2]
     mov dword ptr [EAX].TCachedTextWriter.FBuffer.Digits.Ascii + 28, ecx
     cmp edx, DIGITS_1
     setae dl
     movzx edx, dl

     lea ecx, [EAX].TCachedTextWriter.FBuffer.Digits.Ascii + 31
     sub ecx, edx
     inc edx
     xchg ecx, edx
     jmp [EAX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  @positive:
     push eax
     push offset @write
     add eax, offset TCachedTextWriter.FBuffer.Digits
     jmp WriteCardinalAscii
  @negative:
     push eax
     neg edx
     add eax, offset TCachedTextWriter.FBuffer.Digits
     call WriteCardinalAscii
     mov byte ptr [eax - 1], '-'
     dec eax
  @write:
     pop edx
     lea ecx, [EDX].TCachedTextWriter.FBuffer.Digits.Buffer
     sub ecx, eax
     xchg edx, eax
     jmp [EAX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  {$else .CPUX64}
     cmp r8, 1
     ja @positive
     cmp edx, DIGITS_2
     jae @positive

     mov edx, edx
     mov r8, offset DIGITS_LOOKUP_ASCII - 2
     mov r8d, [r8 + rdx * 2]
     mov dword ptr [RCX].TCachedTextWriter.FBuffer.Digits.Ascii + 28, r8d
     cmp rdx, DIGITS_1
     setae dl
     movzx rdx, dl

     lea r8, [RCX].TCachedTextWriter.FBuffer.Digits.Ascii + 31
     sub r8, rdx
     inc rdx
     xchg r8, rdx
     jmp [RCX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  @positive:
     push rcx
     mov r9, offset @write
     push r9
     add rcx, offset TCachedTextWriter.FBuffer.Digits
     jmp WriteCardinalAscii
  @negative:
     push rcx
     neg edx
     add rcx, offset TCachedTextWriter.FBuffer.Digits
     call WriteCardinalAscii
     mov byte ptr [rax - 1], '-'
     dec rax
  @write:
     pop rcx
     lea r8, [RCX].TCachedTextWriter.FBuffer.Digits.Buffer
     sub r8, rax
     xchg rdx, rax
     jmp [RCX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  {$endif}
end;
{$endif}

procedure TCachedTextWriter.WriteHex(const AValue: Integer; const ADigits: NativeUInt);
{$ifNdef CPUINTELASM}
var
  P: PByte;
begin
  P := WriteHexAscii(FBuffer.Digits, Cardinal(AValue), ADigits);
  FVirtuals.WriteBufferedAscii(Self, P, NativeUInt(@FBuffer.Digits.Buffer[0]) - NativeUInt(P));
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
    push eax
    add eax, offset TCachedTextWriter.FBuffer.Digits
    call WriteHexAscii
    pop edx
    lea ecx, [EDX].TCachedTextWriter.FBuffer.Digits.Buffer
    sub ecx, eax
    xchg edx, eax
    jmp [EAX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  {$else .CPUX64}
    push rcx
    add rcx, offset TCachedTextWriter.FBuffer.Digits
    call WriteHexAscii
    pop rcx
    lea r8, [RCX].TCachedTextWriter.FBuffer.Digits.Buffer
    sub r8, rax
    xchg rdx, rax
    jmp [RCX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  {$endif}
end;
{$endif}

procedure TCachedTextWriter.WriteCardinal(const AValue: Cardinal; const ADigits: NativeUInt);
{$ifNdef CPUINTELASM}
var
  P: PByte;
  X: NativeUInt;
begin
  if (ADigits <= 1) and (AValue < DIGITS_2) then
  begin
    PWord(@FBuffer.Digits.Ascii[30])^ := DIGITS_LOOKUP_ASCII[AValue];
    X := Byte(AValue >= DIGITS_1);
    FVirtuals.WriteBufferedAscii(Self, @FBuffer.Digits.Ascii[31 - X], 1 + X);
    Exit;
  end;

  P := WriteCardinalAscii(FBuffer.Digits, Cardinal(AValue), ADigits);
  FVirtuals.WriteBufferedAscii(Self, P, NativeUInt(@FBuffer.Digits.Buffer[0]) - NativeUInt(P));
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
     cmp ecx, 1
     ja @standard
     cmp edx, DIGITS_2
     jae @standard

     mov ecx, [offset DIGITS_LOOKUP_ASCII + edx * 2 - 2]
     mov dword ptr [EAX].TCachedTextWriter.FBuffer.Digits.Ascii + 28, ecx
     cmp edx, DIGITS_1
     setae dl
     movzx edx, dl

     lea ecx, [EAX].TCachedTextWriter.FBuffer.Digits.Ascii + 31
     sub ecx, edx
     inc edx
     xchg ecx, edx
     jmp [EAX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  @standard:
     push eax
     add eax, offset TCachedTextWriter.FBuffer.Digits
     call WriteCardinalAscii
     pop edx
     lea ecx, [EDX].TCachedTextWriter.FBuffer.Digits.Buffer
     sub ecx, eax
     xchg edx, eax
     jmp [EAX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  {$else .CPUX64}
     cmp r8, 1
     ja @standard
     cmp edx, DIGITS_2
     jae @standard

     mov edx, edx
     mov r8, offset DIGITS_LOOKUP_ASCII - 2
     mov r8d, [r8 + rdx * 2]
     mov dword ptr [RCX].TCachedTextWriter.FBuffer.Digits.Ascii + 28, r8d
     cmp rdx, DIGITS_1
     setae dl
     movzx rdx, dl

     lea r8, [RCX].TCachedTextWriter.FBuffer.Digits.Ascii + 31
     sub r8, rdx
     inc rdx
     xchg r8, rdx
     jmp [RCX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  @standard:
     push rcx
     add rcx, offset TCachedTextWriter.FBuffer.Digits
     call WriteCardinalAscii
     pop rcx
     lea r8, [RCX].TCachedTextWriter.FBuffer.Digits.Buffer
     sub r8, rax
     xchg rdx, rax
     jmp [RCX].TCachedTextWriter.FVirtuals.WriteBufferedAscii
  {$endif}
end;
{$endif}

procedure TCachedTextWriter.WriteInt64(const AValue: Int64; const ADigits: NativeUInt);
var
  P: PByte;
begin
  {$ifdef SMALLINT}
  if (TPoint(AValue).Y < 0) then
  begin
    FBuffer.Digits.Quads[0] := ADigits;
    PInt64(@FBuffer.Digits.Ascii)^ := -AValue;
    P := WriteUInt64Ascii(FBuffer.Digits, PInt64(@FBuffer.Digits.Ascii), {Digits}FBuffer.Digits.Quads[0]);
  {$else}
  if (AValue < 0) then
  begin
    P := WriteUInt64Ascii(FBuffer.Digits, -AValue, ADigits);
  {$endif}
    Dec(P);
    P^ := Ord('-');
  end else
  begin
    P := WriteUInt64Ascii(FBuffer.Digits, {$ifdef SMALLINT}@{$endif}AValue, ADigits);
  end;

  FVirtuals.WriteBufferedAscii(Self, P, NativeUInt(@FBuffer.Digits.Buffer[0]) - NativeUInt(P));
end;

procedure TCachedTextWriter.WriteHex64(const AValue: Int64; const ADigits: NativeUInt);
var
  P: PByte;
begin
  P := WriteHex64Ascii(FBuffer.Digits, {$ifdef SMALLINT}@{$endif}AValue, ADigits);
  FVirtuals.WriteBufferedAscii(Self, P, NativeUInt(@FBuffer.Digits.Buffer[0]) - NativeUInt(P));
end;

procedure TCachedTextWriter.WriteUInt64(const AValue: UInt64; const ADigits: NativeUInt);
var
  P: PByte;
begin
  P := WriteUInt64Ascii(FBuffer.Digits, {$ifdef SMALLINT}@{$endif}Int64(AValue), ADigits);
  FVirtuals.WriteBufferedAscii(Self, P, NativeUInt(@FBuffer.Digits.Buffer[0]) - NativeUInt(P));
end;

procedure TCachedTextWriter.WriteFloat(const AValue: Extended);
{$if Defined(INLINESUPPORTSIMPLE) or not Defined(CPUX86)}
begin
  WriteFloat(AValue, Self.FloatSettings);
end;
{$else .CPUX86.DELPHI}
asm
  pop ebp
  lea edx, [EAX].TCachedTextWriter.FloatSettings
  jmp WriteFloat
end;
{$ifend}

procedure TCachedTextWriter.WriteFloat(const AValue: Extended; const ASettings: TFloatSettings);
var
  P: PByte;
  LCount: NativeUInt;
begin
  LCount := Tiny.Cache.Text.WriteFloatAscii(FBuffer.Digits, {$ifdef EXTENDEDSUPPORT}@{$endif}AValue, ASettings);
  P := @FBuffer.Digits.Ascii[0];
  Dec(P, LCount and 1);
  LCount := LCount shr 1;
  FVirtuals.WriteBufferedAscii(Self, P, LCount);
end;

procedure TCachedTextWriter.WriteDate(const AValue: TDateTime);
{$if Defined(INLINESUPPORTSIMPLE) or not Defined(CPUX86)}
begin
  WriteDate(AValue, Self.DateTimeSettings);
end;
{$else .CPUX86.DELPHI}
asm
  pop ebp
  lea edx, [EAX].TCachedTextWriter.DateTimeSettings
  jmp WriteDate
end;
{$ifend}

procedure TCachedTextWriter.WriteDate(const AValue: TDateTime; const ASettings: TDateTimeSettings);
var
  P: PByte;
begin
  SeparateDateTime(FBuffer.Digits, {$ifNdef CPUX86}AValue{$else}PDouble(@AValue)^{$endif}, True);
  P := WriteDateAscii(FBuffer.Digits, @FBuffer.Digits.Ascii[0], ASettings);
  FVirtuals.WriteBufferedAscii(Self, Pointer(@FBuffer.Digits.Ascii[0]), NativeUInt(P) - NativeUInt(@FBuffer.Digits.Ascii[0]));
end;

procedure TCachedTextWriter.WriteTime(const AValue: TDateTime);
{$if Defined(INLINESUPPORTSIMPLE) or not Defined(CPUX86)}
begin
  WriteTime(AValue, Self.DateTimeSettings);
end;
{$else .CPUX86.DELPHI}
asm
  pop ebp
  lea edx, [EAX].TCachedTextWriter.DateTimeSettings
  jmp WriteTime
end;
{$ifend}

procedure TCachedTextWriter.WriteTime(const AValue: TDateTime; const ASettings: TDateTimeSettings);
var
  P: PByte;
begin
  SeparateDateTime(FBuffer.Digits, {$ifNdef CPUX86}AValue{$else}PDouble(@AValue)^{$endif}, False);
  P := WriteTimeAscii(FBuffer.Digits, @FBuffer.Digits.Ascii[0], ASettings);
  FVirtuals.WriteBufferedAscii(Self, Pointer(@FBuffer.Digits.Ascii[0]), NativeUInt(P) - NativeUInt(@FBuffer.Digits.Ascii[0]));
end;

procedure TCachedTextWriter.WriteDateTime(const AValue: TDateTime);
{$if Defined(INLINESUPPORTSIMPLE) or not Defined(CPUX86)}
begin
  WriteDateTime(AValue, Self.DateTimeSettings);
end;
{$else .CPUX86.DELPHI}
asm
  pop ebp
  lea edx, [EAX].TCachedTextWriter.DateTimeSettings
  jmp WriteDateTime
end;
{$ifend}

procedure TCachedTextWriter.WriteDateTime(const AValue: TDateTime; const ASettings: TDateTimeSettings);
var
  P: PByte;
  Sep: NativeUInt;
begin
  SeparateDateTime(FBuffer.Digits, {$ifNdef CPUX86}AValue{$else}PDouble(@AValue)^{$endif}, False);
  P := WriteDateAscii(FBuffer.Digits, @FBuffer.Digits.Ascii[0], ASettings);
  Sep := Byte(ASettings.BetweenSeparator);
  if (Sep <> NativeUInt(sepNone)) then
  begin
    P^ := DATETIME_SEPARATORS[Sep];
    Inc(P);
  end;
  P := WriteTimeAscii(FBuffer.Digits, P, ASettings);
  FVirtuals.WriteBufferedAscii(Self, Pointer(@FBuffer.Digits.Ascii[0]), NativeUInt(P) - NativeUInt(@FBuffer.Digits.Ascii[0]));
end;

procedure TCachedTextWriter.WriteVariant(const AValue: Variant);
{$if Defined(INLINESUPPORTSIMPLE) or not Defined(CPUX86)}
begin
  WriteVariant(AValue, Self.FloatSettings, Self.DateTimeSettings);
end;
{$else .CPUX86.DELPHI}
asm
  push [esp]
  lea ecx, [EAX].TCachedTextWriter.DateTimeSettings
  mov [esp + 4], ecx
  lea ecx, [EAX].TCachedTextWriter.FloatSettings
  jmp WriteVariant
end;
{$ifend}

procedure TCachedTextWriter.WriteVariant(const AValue: Variant;
  const AFloatSettings: TFloatSettings; const ADateTimeSettings: TDateTimeSettings);
label
  check_byref, signed_value, unsigned_value, uint64_value, float_value;
var
  VType: Integer;
  PValue: Pointer;
  Store: record
    FloatValue: Extended;
    Date: Int64;
  end;
begin
  VType := TVarData(AValue).VType;
  PValue := @TVarData(AValue).VWords[3];
check_byref:
  if (VType and varByRef <> 0) then
  begin
    VType := VType and (not varByRef);
    PValue := PPointer(PValue)^;
  end;

  case (VType) of
    varVariant: begin
                  VType := TVarData(PValue^).VType;
                  PValue := @TVarData(PValue^).VWords[3];
                  goto check_byref;
                end;
    varBoolean: begin
                  Self.WriteBoolean(PBoolean(PValue)^);
                end;
   varSmallint: begin
                  VType := PSmallInt(PValue)^;
                  if (VType >= 0) then goto unsigned_value;
                  goto signed_value;
                end;
   varShortInt: begin
                  VType := PShortInt(PValue)^;
                  if (VType >= 0) then goto unsigned_value;
                  goto signed_value;
                end;
    varInteger: begin
                  VType := PInteger(PValue)^;
                  if (VType >= 0) then goto unsigned_value;
                signed_value:
                  Self.WriteInteger(VType);
                end;
       varByte: begin
                  VType := PByte(PValue)^;
                  goto unsigned_value;
                end;
       varWord: begin
                  VType := PWord(PValue)^;
                  goto unsigned_value;
                end;
   varLongWord: begin
                  VType := PInteger(PValue)^;
                unsigned_value:
                  Self.WriteCardinal(Cardinal(VType));
                end;
      varInt64: begin
                  {$ifdef SMALLINT}
                  if (TPoint(PValue^).Y >= 0) then goto uint64_value;
                  {$else}
                  if (Int64(PValue^) >= 0) then goto uint64_value;
                  {$endif}
                  Self.WriteInt64(PInt64(PValue)^);
                end;
$15{varUInt64}: begin
                uint64_value:
                  Self.WriteUInt64(PUInt64(PValue)^);
                end;
   varCurrency: begin
                  Store.FloatValue := PInt64(PValue)^ * (1 / 10000);
                  goto float_value;
                end;
     varSingle: begin
                  Store.FloatValue := PSingle(PValue)^;
                  goto float_value;
                end;
     varDouble: begin
                  Store.FloatValue := PDouble(PValue)^;
                float_value:
                  Self.WriteFloat(Store.FloatValue, AFloatSettings);
                end;
       varDate: begin
                  Store.Date := Trunc(PDouble(PValue)^);
                  if (PDouble(PValue)^ - Store.Date < 1 / (24 * 60 * 60 * 1000)) then
                  begin
                    Self.WriteDate(PDateTime(PValue)^, ADateTimeSettings);
                  end else
                  if (Store.Date <> 0) then
                  begin
                    Self.WriteDateTime(PDateTime(PValue)^, ADateTimeSettings);
                  end else
                  begin
                    Self.WriteTime(PDateTime(PValue)^, ADateTimeSettings);
                  end;
                end;
     {$ifdef ANSISTRSUPPORT}
     varString: begin
                  Self.WriteAnsiString(PAnsiString(PValue)^);
                end;
     {$endif}
    {$ifdef UNICODE}
    varUString: begin
                  PValue := PPointer(PValue)^;
                  if (PValue <> nil) then
                  begin
                    VType := {Length}PInteger(NativeUInt(PValue) - USTR_OFFSET_LENGTH)^;
                    Self.FVirtuals.WriteUnicodeChars(Self, Pointer(PValue), VType);
                  end;
                end;
    {$endif}
     {$ifdef WIDESTRSUPPORT}
     varOleStr: begin
                  PValue := PPointer(PValue)^;
                  if (PValue <> nil) then
                  begin
                    VType := {Length}PInteger(PAnsiChar(PValue) - WSTR_OFFSET_LENGTH)^;
                    {$ifdef MSWINDOWS}
                    if (VType <> 0) then
                    {$endif}
                    Self.FVirtuals.WriteUnicodeChars(Self, Pointer(PValue), VType {$ifdef WIDESTRLENSHIFT} shr 1{$endif});
                  end;
                end;
     {$endif}
   end;
end;


{ TByteTextWriter }

procedure TByteTextWriter.SetEncoding(const AValue: Word);
begin
  FEncoding.StringKind := csByte;

  FSBCS := DetectSBCS(AValue);
  if (FSBCS = nil) then
  begin
    FEncoding.CodePage := CODEPAGE_UTF8;
    FEncoding.SBCSIndex := -1;
    FSBCSValues := nil;
    FVirtuals.WriteSBCSCharsInternal := Pointer(@TByteTextWriter.WriteSBCSCharsToUTF8);
  end else
  begin
    FEncoding.CodePage := FSBCS.CodePage;
    FEncoding.SBCSIndex := FSBCS.Index;
    FSBCSValues := FSBCS.VALUES;
    FVirtuals.WriteSBCSCharsInternal := Pointer(@TByteTextWriter.WriteSBCSCharsToSBCS);
  end;
end;

constructor TByteTextWriter.Create(const AEncoding: Word;
  const ATarget: TCachedWriter; const ABOM: TBOM; const ADefaultByteEncoding: Word;
  const AOwner: Boolean);
var
  LContext: PTextConvContext;
  LDestSBCS: PTextConvSBCS;
  LSrcBOM, LDestBOM: TBOM;
begin
  Self.SetEncoding(AEncoding);
  LContext := @Self.FInternalContext;
  ATarget.Write(BOM_INFO[ABOM].Data, BOM_INFO[ABOM].Size);

  LSrcBOM := bomNone;
  if (FSBCS = nil) then LSrcBOM := bomUTF8;
  LDestSBCS := DetectSBCS(ADefaultByteEncoding);
  LDestBOM := ABOM;
  if (LDestBOM = bomNone) then
  begin
    if (ADefaultByteEncoding = CODEPAGE_UTF8) then LDestBOM := bomUTF8;
  end else
  begin
    LDestSBCS := nil;
  end;

  if (LSrcBOM = LDestBOM) then
  begin
    if (FSBCS = LDestSBCS) then
    begin
      LContext := nil;
    end else
    begin
      LContext.InitSBCSFromSBCS(FSBCS.CodePage, LDestSBCS.CodePage);
    end;
  end else
  if (LSrcBOM = bomNone) then
  begin
    LContext.Init(LDestBOM, bomNone, AEncoding);
  end else
  begin
    LContext.Init(LDestBOM, bomUTF8, ADefaultByteEncoding);
  end;

  inherited Create(LContext, ATarget, AOwner);
end;

constructor TByteTextWriter.CreateFromFile(const AEncoding: Word;
  const AFileName: string; const ABOM: TBOM; const ADefaultByteEncoding: Word);
begin
  FFileName := AFileName;
  Create(AEncoding, TCachedFileWriter.Create(AFileName), ABOM, ADefaultByteEncoding, True);
end;

constructor TByteTextWriter.CreateDirect(const AContext: PTextConvContext;
  const ATarget: TCachedWriter; const AOwner: Boolean);
begin
  if (AContext = nil) then
  begin
    Self.SetEncoding(CODEPAGE_UTF8);
  end else
  begin
    Self.SetEncoding(AContext.SourceCodePage);
  end;

  inherited Create(AContext, ATarget, AOwner);
end;

function TByteTextWriter.GetSBCSConverter(var AEncoding: TCachedEncoding;
  const ACodePage: Word): Pointer;
var
  LIndex: NativeUInt;
  LSBCS: PTextConvSBCSEx;
  LValue: Integer;
begin
  // SBCS
  LIndex := NativeUInt(ACodePage);
  LValue := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[LIndex and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(LValue) = ACodePage) or (LValue < 0) then Break;
    LValue := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(LValue) shr 24]);
  until (False);
  LSBCS := Pointer(NativeUInt(Byte(LValue shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // Encoding fields
  LIndex := Cardinal(LSBCS.F);
  LIndex := {Index}(LIndex shl 24) + (Ord(csByte) shl 16) + {CodePage}(LIndex shr 16);
  AEncoding.Flags := LIndex;

  // FromSBCS/UTF8 converter
  if (FSBCS <> nil) then
  begin
    if (Pointer(FSBCS) = Pointer(LSBCS)) then
    begin
      Result := nil;
      Exit;
    end else
    begin
      Result := FSBCS.FromSBCS(LSBCS);
      Exit;
    end;
  end else
  begin
    Result := LSBCS.FUTF8.Original;
    if (Result = nil) then Result := LSBCS.AllocFillUTF8(LSBCS.FUTF8.Original, ccOriginal);
  end;
end;

procedure TByteTextWriter.InitContexts;
var
  LFlags: Cardinal;
begin
  LFlags := CHARCASE_FLAGS[0];
  if (FSBCS = nil) then
  begin
    LFlags := LFlags + (Cardinal(bomUTF8) shl ENCODING_DESTINATION_OFFSET);
  end else
  begin
    TTextConvContextEx(FHugeContext).FCallbacks.Writer := FSBCSValues;
    TTextConvContextEx(FUTF32Context).FCallbacks.Writer := FSBCSValues;
  end;

  TTextConvContextEx(FHugeContext).F.Flags := LFlags;
  TTextConvContextEx(FUTF32Context).F.Flags := LFlags + Cardinal(bomUTF32);
  @TTextConvContextEx(FUTF32Context).FConvertProc := @TTextConvContextEx.convert_universal;
end;

procedure TByteTextWriter.WriteCRLF;
var
  P: PWord;
begin
  P := Pointer(FCurrent);

  P^ := (10 shl 8) + 13;
  Inc(P);
  FCurrent := Pointer(P);

  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
    Self.Flush;
end;

procedure TByteTextWriter.WriteBufferedAscii(AFrom: PByte; ACount: NativeUInt);
{$ifNdef CPUINTELASM}
type
  TDefaultCaller = procedure(ASelf: Pointer; const AChars: PAnsiChar; const ALength: NativeUInt);
var
  P: NativeUInt{PByte};
  i: NativeUInt;
begin
  P := NativeUInt(FCurrent);
  Inc(P, ACount);

  if (P <= NativeUInt(Self.FOverflow)) then
  begin
    Self.FCurrent := Pointer(P);
    Dec(P, ACount);

    for i := 1 to (ACount + (SizeOf(NativeUInt) - 1)) shr {$ifdef LARGEINT}3{$else}2{$endif} do
    begin
      PNativeUInt(P)^ := PNativeUInt(AFrom)^;
      Inc(AFrom, SizeOf(NativeUInt));
      Inc(P, SizeOf(NativeUInt));
    end;
    Exit;
  end else
  begin
    P := NativeUInt(@TByteTextWriter.WriteAscii);
    TDefaultCaller(P)(Self, Pointer(AFrom), ACount);
  end;
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
     push ebx
     mov ebx, [EAX].TCachedTextWriter.FCurrent
     add ebx, ecx
     cmp ebx, [EAX].TCachedTextWriter.FOverflow
     ja @overflow

     mov [EAX].TCachedTextWriter.FCurrent, ebx
     sub ebx, ecx
     cmp ecx, 32
     ja @nc_move

     add ecx, 7
     pop eax
     shr ecx, 3
     xchg eax, ebx
     jmp [offset @QWORDS + ecx * 4]
  @QWORDS: DD @q0, @q1, @q2, @q3, @q4
  @q4:
     fild qword ptr [edx]
     fistp qword ptr [eax]
     add edx, 8
     add eax, 8
  @q3:
     fild qword ptr [edx]
     fistp qword ptr [eax]
     add edx, 8
     add eax, 8
  @q2:
     fild qword ptr [edx]
     fistp qword ptr [eax]
     add edx, 8
     add eax, 8
  @q1:
     fild qword ptr [edx]
     fistp qword ptr [eax]
  @q0:
     ret
  @nc_move:
     add ecx, 15
     mov eax, edx
     mov edx, ebx
     pop ebx
     and ecx, -16
     jmp TinyMove
  @overflow:
     pop ebx
     jmp OverflowWriteData
  {$else .CPUX64}
     mov rax, [RCX].TCachedTextWriter.FCurrent
     add rax, r8
     cmp rax, [RCX].TCachedTextWriter.FOverflow
     ja OverflowWriteData

     mov [RCX].TCachedTextWriter.FCurrent, rax
     sub rax, r8
     cmp r8, 32
     ja @nc_move

     add r8, 7
     mov r10, offset @QWORDS
     shr r8, 3
     jmp [r10 + r8 * 8]
  @QWORDS: DQ @q0, @q1, @q2, @q3, @q4
  @q4:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q3:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q2:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q1:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q0:
     ret
  @nc_move:
     add r8, 15
     mov rcx, rdx
     mov rdx, rax
     and r8, -16
     jmp TinyMove
  {$endif}
end;
{$endif}

procedure TByteTextWriter.WriteAscii(const AChars: PAnsiChar; const ALength: NativeUInt);
{$ifNdef CPUINTELASM}
var
  P: PByte;
begin
  P := FCurrent;
  Inc(P, ALength);

  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowWriteData(AChars^, ALength);
  end else
  begin
    FCurrent := P;
    Dec(P, ALength);
    TinyMove(AChars^, P^, ALength);
  end;
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
     push ebx
     mov ebx, [EAX].TCachedTextWriter.FCurrent
     add ebx, ecx
     cmp ebx, [EAX].TCachedTextWriter.FOverflow
     ja @overflow

     mov [EAX].TCachedTextWriter.FCurrent, ebx
     sub ebx, ecx
     cmp ecx, 32
     ja @nc_move

     mov eax, ecx
     shr ecx, 3
     jmp [offset @QWORDS + ecx * 4]
  @QWORDS: DD @q0, @q1, @q2, @q3, @q4
  @q4:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q3:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q2:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q1:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q0:

     and eax, 7
     jmp [offset @BYTES + eax * 4]
  @BYTES: DD @b0, @b1, @b2, @b3, @b4_7, @b4_7, @b4_7, @b4_7
  @b4_7:
     mov ecx, [edx]
     mov [ebx], ecx
     add edx, 4
     add ebx, 4
     jmp [offset @BYTES + eax * 4 - 4 * 4]
  @b2:
     mov cx, [edx]
     mov [ebx], cx
     pop ebx
     ret
  @b3:
     mov cx, [edx]
     mov [ebx], cx
     add edx, 2
     add ebx, 2
  @b1:
     mov cl, [edx]
     mov [ebx], cl
  @b0:
     pop ebx
     ret
  @nc_move:
     mov eax, edx
     mov edx, ebx
     pop ebx
     jmp TinyMove
  @overflow:
     pop ebx
     jmp OverflowWriteData
  {$else .CPUX64}
     mov rax, [RCX].TCachedTextWriter.FCurrent
     add rax, r8
     cmp rax, [RCX].TCachedTextWriter.FOverflow
     ja OverflowWriteData

     mov [RCX].TCachedTextWriter.FCurrent, rax
     sub rax, r8
     cmp r8, 32
     ja @nc_move

     mov r9, r8
     mov r10, offset @QWORDS
     shr r8, 3
     jmp [r10 + r8 * 8]
  @QWORDS: DQ @q0, @q1, @q2, @q3, @q4
  @q4:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q3:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q2:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q1:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q0:
     mov r10, offset @BYTES
     and r9, 7
     jmp [r10 + r9 * 8]
  @BYTES: DQ @b0, @b1, @b2, @b3, @b4_7, @b4_7, @b4_7, @b4_7
  @b4_7:
     mov ecx, [rdx]
     mov [rax], ecx
     add rdx, 4
     add rax, 4
     sub r10, 4 * 8
     jmp [r10 + r9 * 8]
  @b2:
     mov cx, [rdx]
     mov [rax], cx
     ret
  @b3:
     mov cx, [rdx]
     mov [rax], cx
     add rdx, 2
     add rax, 2
  @b1:
     mov cl, [rdx]
     mov [rax], cl
  @b0:
     ret
  @nc_move:
     mov rcx, rdx
     mov rdx, rax
     jmp TinyMove
  {$endif}
end;
{$endif}

procedure TByteTextWriter.WriteUnicodeAscii(const AChars: PUnicodeChar; const ALength: NativeUInt);
label
  _1, _2, _3;
const
  CHARS_IN_ITERATION = 4;
var
  i, j: NativeUInt;
  P: PByte;
  LSrc: PWord;
  X, U: NativeUInt;
begin
  LSrc := Pointer(AChars);
  P := Pointer(Self.FCurrent);

  for i := 1 to (ALength {$ifdef CPUX86}div 32{$else}shr 5{$endif}) do
  begin
    for j := 1 to (32 div CHARS_IN_ITERATION) do
    begin
      {$ifdef LARGEINT}
      X := PNativeUInt(LSrc)^;
      Inc(LSrc, CHARS_IN_ITERATION);
      {$else .SMALLINT}
      X := PCardinal(LSrc)^;
      Inc(LSrc, CHARS_IN_ITERATION shr 1);
      U := PCardinal(LSrc)^;
      Inc(LSrc, CHARS_IN_ITERATION shr 1);
      {$endif}

      {$ifdef LARGEINT}
      U := X shr 32;
      {$endif}
      X := X + (X shr 8);
      U := U + (U shr 8);
      X := Word(X);
      {$ifdef LARGEINT}
      U := Word(U);
      {$endif}
      U := U shl 16;
      Inc(X, U);

      PCardinal(P)^ := X;
      Inc(P, CHARS_IN_ITERATION);
    end;

    if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    begin
      Self.FCurrent := Pointer(P);
      Self.Flush;
      P := Pointer(Self.FCurrent);
    end;
  end;

  for i := 1 to ((ALength and 31) shr 2) do
  begin
    {$ifdef LARGEINT}
    X := PNativeUInt(LSrc)^;
    Inc(LSrc, CHARS_IN_ITERATION);
    {$else .SMALLINT}
    X := PCardinal(LSrc)^;
    Inc(LSrc, CHARS_IN_ITERATION shr 1);
    U := PCardinal(LSrc)^;
    Inc(LSrc, CHARS_IN_ITERATION shr 1);
    {$endif}

    {$ifdef LARGEINT}
    U := X shr 32;
    {$endif}
    X := X + (X shr 8);
    U := U + (U shr 8);
    X := Word(X);
    {$ifdef LARGEINT}
    U := Word(U);
    {$endif}
    U := U shl 16;
    Inc(X, U);

    PCardinal(P)^ := X;
    Inc(P, CHARS_IN_ITERATION);
  end;

  case ALength and (CHARS_IN_ITERATION - 1) of
    3:
    begin
    _3:
      P^ := LSrc^;
      Inc(LSrc);
      Inc(P);
      goto _2;
    end;
    2:
    begin
    _2:
      P^ := LSrc^;
      Inc(LSrc);
      Inc(P);
      goto _1;
    end;
    1:
    begin
    _1:
      P^ := LSrc^;
      // Inc(LSrc);
      Inc(P);
    end;
  end;

  Self.FCurrent := Pointer(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    Self.Flush;
end;

procedure TByteTextWriter.WriteUCS4Ascii(const AChars: PUCS4Char; const ALength: NativeUInt);
var
  i, j: NativeUInt;
  P: PByte;
  LSrc: PCardinal;
begin
  LSrc := Pointer(AChars);
  P := Pointer(Self.FCurrent);

  for i := 1 to (ALength {$ifdef CPUX86}div 32{$else}shr 5{$endif}) do
  begin
    for j := 1 to 32 do
    begin
      P^ := LSrc^;
      Inc(LSrc);
      Inc(P);
    end;

    if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    begin
      Self.FCurrent := Pointer(P);
      Self.Flush;
      P := Pointer(Self.FCurrent);
    end;
  end;

  for j := 1 to (ALength and 31) do
  begin
    P^ := LSrc^;
    Inc(LSrc);
    Inc(P);
  end;

  Self.FCurrent := Pointer(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    Self.Flush;
end;

// result = length
procedure TByteTextWriter.WriteSBCSCharsToSBCS(const AChars: PAnsiChar; const ALength: NativeUInt);
var
  P: PByte;
  LConverter: Pointer;
begin
  P := Self.FCurrent;
  LConverter := Self.FSBCSLookup.CurrentConverter;
  Inc(P, ALength);
  if (LConverter = nil) then
  begin
    // write data
    if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    begin
      Self.OverflowWriteData(AChars^, ALength);
    end else
    begin
      Self.FCurrent := P;
      Dec(P, ALength);
      TinyMove(AChars^, P^, ALength);
    end;
  end else
  begin
    // sbcs_from_sbcs
    if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    begin
      FHugeContext.Source := AChars;
      FHugeContext.SourceSize := ALength;
      TTextConvContextEx(FHugeContext).FCallbacks.Converter := LConverter;
      TTextConvContextEx(FHugeContext).FConvertProc := Pointer(@TTextConvContextEx.convert_sbcs_from_sbcs);
      TTextConvContextEx(FHugeContext).FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_sbcs;
      Self.WriteContextData(FHugeContext);
    end else
    begin
      Self.FCurrent := P;
      Dec(P, ALength);
      Tiny.Text.sbcs_from_sbcs(Pointer(P), AChars, ALength, LConverter);
    end;
  end;
end;

// result = min: length; max: length*3
procedure TByteTextWriter.WriteSBCSCharsToUTF8(const AChars: PAnsiChar; const ALength: NativeUInt);
var
  P: PByte;
  LLimit, LCount: NativeUInt;
begin
  P := Self.FCurrent;
  LLimit := (ALength * 3) + NativeUInt(P) - WRITER_OVERFLOW_LIMIT;

  if (LLimit > NativeUInt(Self.FOverflow)) then
  begin
    FHugeContext.Source := AChars;
    FHugeContext.SourceSize := ALength;
    TTextConvContextEx(FHugeContext).FCallbacks.Converter := Self.FSBCSLookup.CurrentConverter;
    TTextConvContextEx(FHugeContext).FConvertProc := Pointer(@TTextConvContextEx.convert_utf8_from_sbcs);
    TTextConvContextEx(FHugeContext).FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_sbcs;
    Self.WriteContextData(FHugeContext);
  end else
  begin
    LCount := Tiny.Text.utf8_from_sbcs(PUTF8Char(P), AChars, ALength, Self.FSBCSLookup.CurrentConverter);
    Inc(P, LCount);

    Self.FCurrent := P;
    if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
      Self.Flush;
  end;
end;

// result = min: length/6; max: length
procedure TByteTextWriter.WriteUTF8Chars(const AChars: PUTF8Char; const ALength: NativeUInt);
var
  P: PByte;
  LConverter: Pointer;
  LLimit, LCount: NativeUInt;
begin
  P := Self.FCurrent;
  LConverter := Self.FSBCSValues;
  if (LConverter = nil) then
  begin
    // write data
    Inc(P, ALength);
    if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    begin
      Self.OverflowWriteData(AChars^, ALength);
    end else
    begin
      Self.FCurrent := P;
      Dec(P, ALength);
      TinyMove(AChars^, P^, ALength);
    end;
  end else
  begin
    // sbcs_from_utf8
    LLimit := ALength + NativeUInt(P) - WRITER_OVERFLOW_LIMIT;
    if (LLimit > NativeUInt(Self.FOverflow)) then
    begin
      FHugeContext.Source := AChars;
      FHugeContext.SourceSize := {ALength}(LLimit + WRITER_OVERFLOW_LIMIT) - NativeUInt(P);
      TTextConvContextEx(FHugeContext).FCallbacks.Converter := LConverter;
      TTextConvContextEx(FHugeContext).FConvertProc := Pointer(@TTextConvContextEx.convert_sbcs_from_utf8);
      TTextConvContextEx(FHugeContext).FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf8;
      Self.WriteContextData(FHugeContext);
    end else
    begin
      LCount := Tiny.Text.sbcs_from_utf8(Pointer(P), AChars,
        {ALength}(LLimit + WRITER_OVERFLOW_LIMIT) - NativeUInt(P), LConverter);
      Inc(P, LCount);

      Self.FCurrent := P;
      if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
        Self.Flush;
    end;
  end;
end;

// result = min: length/2; max: length*3
procedure TByteTextWriter.WriteUnicodeChars(const AChars: PUnicodeChar; const ALength: NativeUInt);
var
  P: PByte;
  LConverter: Pointer;
  LLimit, LCount: NativeUInt;
begin
  FHugeContext.Source := AChars;
  FHugeContext.SourceSize := ALength;
  P := Self.FCurrent;
  LConverter := Self.FSBCSValues;
  if (LConverter = nil) then
  begin
    // result = min: length; max: length*3
    // utf8_from_utf16
    LLimit := (ALength * 3) + NativeUInt(P) - WRITER_OVERFLOW_LIMIT;
    if (LLimit > NativeUInt(Self.FOverflow)) then
    begin
      TTextConvContextEx(FHugeContext).SourceSize := TTextConvContextEx(FHugeContext).SourceSize * 2;
      TTextConvContextEx(FHugeContext).FConvertProc := Pointer(@TTextConvContextEx.convert_utf8_from_utf16);
      TTextConvContextEx(FHugeContext).FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf16;
      Self.WriteContextData(FHugeContext);
    end else
    begin
      LCount := Tiny.Text.utf8_from_utf16(PUTF8Char(P), FHugeContext.Source, FHugeContext.SourceSize);
      Inc(P, LCount);

      Self.FCurrent := P;
      if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
        Self.Flush;
    end;
  end else
  begin
    // result = min: length/2; max: length
    // sbcs_from_utf16
    LLimit := ALength + NativeUInt(P) - WRITER_OVERFLOW_LIMIT;
    if (LLimit > NativeUInt(Self.FOverflow)) then
    begin
      TTextConvContextEx(FHugeContext).SourceSize := TTextConvContextEx(FHugeContext).SourceSize * 2;
      TTextConvContextEx(FHugeContext).FCallbacks.Converter := LConverter;
      TTextConvContextEx(FHugeContext).FConvertProc := Pointer(@TTextConvContextEx.convert_sbcs_from_utf16);
      TTextConvContextEx(FHugeContext).FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf16;
      Self.WriteContextData(FHugeContext);
    end else
    begin
      LCount := Tiny.Text.sbcs_from_utf16(Pointer(P), FHugeContext.Source, FHugeContext.SourceSize, LConverter);
      Inc(P, LCount);

      Self.FCurrent := P;
      if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
        Self.Flush;
    end;
  end;
end;


{ TUTF16TextWriter }

constructor TUTF16TextWriter.Create(const ATarget: TCachedWriter;
  const ABOM: TBOM; const ADefaultByteEncoding: Word; const AOwner: Boolean);
var
  LContext: PTextConvContext;
begin
  {Check}DetectSBCS(ADefaultByteEncoding);
  LContext := @Self.FInternalContext;
  ATarget.Write(BOM_INFO[ABOM].Data, BOM_INFO[ABOM].Size);

  if (ABOM = bomUTF16) then
  begin
    LContext := nil;
  end else
  begin
    LContext.Init(ABOM, bomUTF16, ADefaultByteEncoding);
  end;

  FVirtuals.WriteSBCSCharsInternal := Pointer(@TUTF16TextWriter.WriteSBCSCharsInternal);
  inherited Create(LContext, ATarget, AOwner);
end;

constructor TUTF16TextWriter.CreateFromFile(const AFileName: string;
  const ABOM: TBOM; const ADefaultByteEncoding: Word);
begin
  FFileName := AFileName;
  Create(TCachedFileWriter.Create(AFileName), ABOM, ADefaultByteEncoding, True);
end;

constructor TUTF16TextWriter.CreateDirect(const AContext: PTextConvContext;
  const ATarget: TCachedWriter; const AOwner: Boolean);
begin
  FVirtuals.WriteSBCSCharsInternal := Pointer(@TUTF16TextWriter.WriteSBCSCharsInternal);
  inherited Create(AContext, ATarget, AOwner);
end;

procedure TUTF16TextWriter.InitContexts;
var
  LFlags: Cardinal;
begin
  LFlags := CHARCASE_FLAGS[0] + (Cardinal(bomUTF16) shl ENCODING_DESTINATION_OFFSET);
  TTextConvContextEx(FHugeContext).F.Flags := LFlags;
  TTextConvContextEx(FUTF32Context).F.Flags := LFlags + Cardinal(bomUTF32);
  @TTextConvContextEx(FUTF32Context).FConvertProc := @TTextConvContextEx.convert_universal;
end;

procedure TUTF16TextWriter.WriteCRLF;
var
  P: PCardinal;
begin
  P := Pointer(FCurrent);

  P^ := (10 shl 16) + 13;
  Inc(P);
  FCurrent := Pointer(P);

  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
    Self.Flush;
end;

procedure TUTF16TextWriter.WriteBufferedAscii(AFrom: PByte; ACount: NativeUInt);
type
  TDefaultCaller = procedure(ASelf: Pointer; const AChars: PAnsiChar; const ALength: NativeUInt);
const
  CHARS_IN_ITERATION = 4;
var
  P: NativeUInt{PByte};
  LSize, X, i: NativeUInt;
begin
  P := NativeUInt(FCurrent);
  LSize := ACount shl 1;
  Inc(P, LSize);

  if (P <= NativeUInt(Self.FOverflow)) then
  begin
    Self.FCurrent := Pointer(P);
    Dec(P, LSize);

    for i := 0 to LSize shr (2 + 1) do
    begin
      X := PCardinal(AFrom)^;
      Inc(AFrom, CHARS_IN_ITERATION);

      {$ifNdef LARGEINT}
        PCardinal(P)^ := (X and $7f) + ((X and $7f00) shl 8);
        X := X shr 16;
        Inc(P, CHARS_IN_ITERATION);
        PCardinal(P)^ := (X and $7f) + ((X and $7f00) shl 8);
        Inc(P, CHARS_IN_ITERATION);
      {$else}
        PNativeUInt(P)^ := (X and $7f) + ((X and $7f00) shl 8) +
          ((X and $7f0000) shl 16) + ((X and $7f000000) shl 24);
        Inc(NativeUInt(P), SizeOf(NativeUInt));
      {$endif}
    end;
    Exit;
  end else
  begin
    P := NativeUInt(@TUTF16TextWriter.WriteAscii);
    TDefaultCaller(P)(Self, Pointer(AFrom), LSize shr 1);
  end;
end;

procedure TUTF16TextWriter.WriteAscii(const AChars: PAnsiChar; const ALength: NativeUInt);
label
  _1, _2, _3;
const
  CHARS_IN_ITERATION = 4;
var
  i, j: NativeUInt;
  P: PWord;
  LSrc: PByte;
  X: NativeUInt;
begin
  LSrc := Pointer(AChars);
  P := Pointer(Self.FCurrent);

  for i := 1 to (ALength {$ifdef CPUX86}div 32{$else}shr 5{$endif}) do
  begin
    for j := 1 to (32 div CHARS_IN_ITERATION) do
    begin
      X := PCardinal(LSrc)^;
      Inc(LSrc, CHARS_IN_ITERATION);

      {$ifNdef LARGEINT}
        PCardinal(P)^ := (X and $7f) + ((X and $7f00) shl 8);
        X := X shr 16;
        Inc(P, 2);
        PCardinal(P)^ := (X and $7f) + ((X and $7f00) shl 8);
        Inc(P, 2);
      {$else}
        PNativeUInt(P)^ := (X and $7f) + ((X and $7f00) shl 8) +
          ((X and $7f0000) shl 16) + ((X and $7f000000) shl 24);
        Inc(NativeUInt(P), SizeOf(NativeUInt));
      {$endif}
    end;

    if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    begin
      Self.FCurrent := Pointer(P);
      Self.Flush;
      P := Pointer(Self.FCurrent);
    end;
  end;

  for i := 1 to ((ALength and 31) shr 2) do
  begin
    X := PCardinal(LSrc)^;
    Inc(LSrc, CHARS_IN_ITERATION);

    {$ifNdef LARGEINT}
      PCardinal(P)^ := (X and $7f) + ((X and $7f00) shl 8);
      X := X shr 16;
      Inc(P, 2);
      PCardinal(P)^ := (X and $7f) + ((X and $7f00) shl 8);
      Inc(P, 2);
    {$else}
      PNativeUInt(P)^ := (X and $7f) + ((X and $7f00) shl 8) +
        ((X and $7f0000) shl 16) + ((X and $7f000000) shl 24);
      Inc(NativeUInt(P), SizeOf(NativeUInt));
    {$endif}
  end;

  case ALength and (CHARS_IN_ITERATION - 1) of
    3:
    begin
    _3:
      P^ := LSrc^;
      Inc(LSrc);
      Inc(P);
      goto _2;
    end;
    2:
    begin
    _2:
      P^ := LSrc^;
      Inc(LSrc);
      Inc(P);
      goto _1;
    end;
    1:
    begin
    _1:
      P^ := LSrc^;
      // Inc(LSrc);
      Inc(P);
    end;
  end;

  Self.FCurrent := Pointer(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    Self.Flush;
end;

procedure TUTF16TextWriter.WriteUnicodeAscii(const AChars: PUnicodeChar;
  const ALength: NativeUInt);
{$ifNdef CPUINTELASM}
var
  P: PByte;
  LSize: NativeUInt;
begin
  P := FCurrent;
  LSize := ALength shl 1;
  Inc(P, LSize);

  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowWriteData(AChars^, LSize);
  end else
  begin
    FCurrent := P;
    Dec(P, LSize);
    TinyMove(AChars^, P^, LSize);
  end;
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
     lea ecx, [ecx + ecx]

     push ebx
     mov ebx, [EAX].TCachedTextWriter.FCurrent
     add ebx, ecx
     cmp ebx, [EAX].TCachedTextWriter.FOverflow
     ja @overflow

     mov [EAX].TCachedTextWriter.FCurrent, ebx
     sub ebx, ecx
     cmp ecx, 32
     ja @nc_move

     mov eax, ecx
     shr ecx, 3
     jmp [offset @QWORDS + ecx * 4]
  @QWORDS: DD @q0, @q1, @q2, @q3, @q4
  @q4:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q3:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q2:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q1:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q0:

     and eax, 7
     jmp [offset @BYTES + eax * 4]
  @BYTES: DD @b0, @b1, @b2, @b3, @b4_7, @b4_7, @b4_7, @b4_7
  @b4_7:
     mov ecx, [edx]
     mov [ebx], ecx
     add edx, 4
     add ebx, 4
     jmp [offset @BYTES + eax * 4 - 4 * 4]
  @b2:
     mov cx, [edx]
     mov [ebx], cx
     pop ebx
     ret
  @b3:
     mov cx, [edx]
     mov [ebx], cx
     add edx, 2
     add ebx, 2
  @b1:
     mov cl, [edx]
     mov [ebx], cl
  @b0:
     pop ebx
     ret
  @nc_move:
     mov eax, edx
     mov edx, ebx
     pop ebx
     jmp TinyMove
  @overflow:
     pop ebx
     jmp OverflowWriteData
  {$else .CPUX64}
     lea r8, [r8 + r8]

     mov rax, [RCX].TCachedTextWriter.FCurrent
     add rax, r8
     cmp rax, [RCX].TCachedTextWriter.FOverflow
     ja OverflowWriteData

     mov [RCX].TCachedTextWriter.FCurrent, rax
     sub rax, r8
     cmp r8, 32
     ja @nc_move

     mov r9, r8
     mov r10, offset @QWORDS
     shr r8, 3
     jmp [r10 + r8 * 8]
  @QWORDS: DQ @q0, @q1, @q2, @q3, @q4
  @q4:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q3:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q2:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q1:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q0:
     mov r10, offset @BYTES
     and r9, 7
     jmp [r10 + r9 * 8]
  @BYTES: DQ @b0, @b1, @b2, @b3, @b4_7, @b4_7, @b4_7, @b4_7
  @b4_7:
     mov ecx, [rdx]
     mov [rax], ecx
     add rdx, 4
     add rax, 4
     sub r10, 4 * 8
     jmp [r10 + r9 * 8]
  @b2:
     mov cx, [rdx]
     mov [rax], cx
     ret
  @b3:
     mov cx, [rdx]
     mov [rax], cx
     add rdx, 2
     add rax, 2
  @b1:
     mov cl, [rdx]
     mov [rax], cl
  @b0:
     ret
  @nc_move:
     mov rcx, rdx
     mov rdx, rax
     jmp TinyMove
  {$endif}
end;
{$endif}

procedure TUTF16TextWriter.WriteUCS4Ascii(const AChars: PUCS4Char; const ALength: NativeUInt);
var
  i, j: NativeUInt;
  P: PWord;
  LSrc: PCardinal;
begin
  LSrc := Pointer(AChars);
  P := Pointer(Self.FCurrent);

  for i := 1 to (ALength {$ifdef CPUX86}div 32{$else}shr 5{$endif}) do
  begin
    for j := 1 to 32 do
    begin
      P^ := LSrc^;
      Inc(LSrc);
      Inc(P);
    end;

    if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    begin
      Self.FCurrent := Pointer(P);
      Self.Flush;
      P := Pointer(Self.FCurrent);
    end;
  end;

  for j := 1 to (ALength and 31) do
  begin
    P^ := LSrc^;
    Inc(LSrc);
    Inc(P);
  end;

  Self.FCurrent := Pointer(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    Self.Flush;
end;

// result = length * SizeOf(WideChar)
procedure TUTF16TextWriter.WriteSBCSCharsInternal(const AChars: PAnsiChar; const ALength: NativeUInt);
var
  P: PByte;
  LLimit: NativeUInt;
begin
  P := Self.FCurrent;
  LLimit := (ALength + ALength) + NativeUInt(P) - WRITER_OVERFLOW_LIMIT;

  if (LLimit > NativeUInt(Self.FOverflow)) then
  begin
    FHugeContext.Source := AChars;
    FHugeContext.SourceSize := ALength;
    TTextConvContextEx(FHugeContext).FCallbacks.Converter := Self.FSBCSLookup.CurrentConverter;
    TTextConvContextEx(FHugeContext).FConvertProc := Pointer(@TTextConvContextEx.convert_utf16_from_sbcs);
    TTextConvContextEx(FHugeContext).FCallbacks.ReaderWriter := @Tiny.Text.utf16_from_sbcs;
    Self.WriteContextData(FHugeContext);
  end else
  begin
    Tiny.Text.utf16_from_sbcs(Pointer(P), AChars, ALength, Self.FSBCSLookup.CurrentConverter);
    Inc(P, ALength + ALength);

    Self.FCurrent := P;
    if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
      Self.Flush;
  end;
end;

// result = (min: length/3; max: length) * SizeOf(WideChar)
procedure TUTF16TextWriter.WriteUTF8Chars(const AChars: PUTF8Char; const ALength: NativeUInt);
var
  P: PByte;
  LLimit, LCount: NativeUInt;
begin
  P := Self.FCurrent;
  LLimit := (ALength + ALength) + NativeUInt(P) - WRITER_OVERFLOW_LIMIT;

  if (LLimit > NativeUInt(Self.FOverflow)) then
  begin
    FHugeContext.Source := AChars;
    FHugeContext.SourceSize := ALength;
    TTextConvContextEx(FHugeContext).FConvertProc := Pointer(@TTextConvContextEx.convert_utf16_from_utf8);
    TTextConvContextEx(FHugeContext).FCallbacks.ReaderWriter := @Tiny.Text.utf16_from_utf8;
    Self.WriteContextData(FHugeContext);
  end else
  begin
    LCount := Tiny.Text.utf16_from_utf8(Pointer(P), AChars, ALength);
    Inc(P, LCount + LCount);

    Self.FCurrent := P;
    if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
      Self.Flush;
  end;
end;

procedure TUTF16TextWriter.WriteUnicodeChars(const AChars: PUnicodeChar; const ALength: NativeUInt);
{$ifNdef CPUINTELASM}
var
  P: PByte;
  LSize: NativeUInt;
begin
  P := FCurrent;
  LSize := ALength + ALength;
  Inc(P, LSize);

  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowWriteData(AChars^, LSize);
  end else
  begin
    FCurrent := P;
    Dec(P, LSize);
    TinyMove(AChars^, P^, LSize);
  end;
end;
{$else .CPUX86/CPUX64} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef CPUX86}
     lea ecx, [ecx + ecx]

     push ebx
     mov ebx, [EAX].TCachedTextWriter.FCurrent
     add ebx, ecx
     cmp ebx, [EAX].TCachedTextWriter.FOverflow
     ja @overflow

     mov [EAX].TCachedTextWriter.FCurrent, ebx
     sub ebx, ecx
     cmp ecx, 32
     ja @nc_move

     mov eax, ecx
     shr ecx, 3
     jmp [offset @QWORDS + ecx * 4]
  @QWORDS: DD @q0, @q1, @q2, @q3, @q4
  @q4:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q3:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q2:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q1:
     fild qword ptr [edx]
     fistp qword ptr [ebx]
     add edx, 8
     add ebx, 8
  @q0:

     and eax, 7
     jmp [offset @BYTES + eax * 4]
  @BYTES: DD @b0, @b1, @b2, @b3, @b4_7, @b4_7, @b4_7, @b4_7
  @b4_7:
     mov ecx, [edx]
     mov [ebx], ecx
     add edx, 4
     add ebx, 4
     jmp [offset @BYTES + eax * 4 - 4 * 4]
  @b2:
     mov cx, [edx]
     mov [ebx], cx
     pop ebx
     ret
  @b3:
     mov cx, [edx]
     mov [ebx], cx
     add edx, 2
     add ebx, 2
  @b1:
     mov cl, [edx]
     mov [ebx], cl
  @b0:
     pop ebx
     ret
  @nc_move:
     mov eax, edx
     mov edx, ebx
     pop ebx
     jmp TinyMove
  @overflow:
     pop ebx
     jmp OverflowWriteData
  {$else .CPUX64}
     lea r8, [r8 + r8]

     mov rax, [RCX].TCachedTextWriter.FCurrent
     add rax, r8
     cmp rax, [RCX].TCachedTextWriter.FOverflow
     ja OverflowWriteData

     mov [RCX].TCachedTextWriter.FCurrent, rax
     sub rax, r8
     cmp r8, 32
     ja @nc_move

     mov r9, r8
     mov r10, offset @QWORDS
     shr r8, 3
     jmp [r10 + r8 * 8]
  @QWORDS: DQ @q0, @q1, @q2, @q3, @q4
  @q4:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q3:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q2:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q1:
     mov rcx, [rdx]
     mov [rax], rcx
     add rdx, 8
     add rax, 8
  @q0:
     mov r10, offset @BYTES
     and r9, 7
     jmp [r10 + r9 * 8]
  @BYTES: DQ @b0, @b1, @b2, @b3, @b4_7, @b4_7, @b4_7, @b4_7
  @b4_7:
     mov ecx, [rdx]
     mov [rax], ecx
     add rdx, 4
     add rax, 4
     sub r10, 4 * 8
     jmp [r10 + r9 * 8]
  @b2:
     mov cx, [rdx]
     mov [rax], cx
     ret
  @b3:
     mov cx, [rdx]
     mov [rax], cx
     add rdx, 2
     add rax, 2
  @b1:
     mov cl, [rdx]
     mov [rax], cl
  @b0:
     ret
  @nc_move:
     mov rcx, rdx
     mov rdx, rax
     jmp TinyMove
  {$endif}
end;
{$endif}


{ TUTF32TextWriter }

constructor TUTF32TextWriter.Create(const ATarget: TCachedWriter;
  const ABOM: TBOM; const ADefaultByteEncoding: Word; const AOwner: Boolean);
var
  LContext: PTextConvContext;
begin
  {Check}DetectSBCS(ADefaultByteEncoding);
  LContext := @Self.FInternalContext;
  ATarget.Write(BOM_INFO[ABOM].Data, BOM_INFO[ABOM].Size);

  if (ABOM = bomUTF32) then
  begin
    LContext := nil;
  end else
  begin
    LContext.Init(ABOM, bomUTF32, ADefaultByteEncoding);
  end;

  FVirtuals.WriteSBCSCharsInternal := Pointer(@TUTF32TextWriter.WriteSBCSCharsInternal);
  inherited Create(LContext, ATarget, AOwner);
end;

constructor TUTF32TextWriter.CreateFromFile(const AFileName: string;
  const ABOM: TBOM; const ADefaultByteEncoding: Word);
begin
  FFileName := AFileName;
  Create(TCachedFileWriter.Create(AFileName), ABOM, ADefaultByteEncoding, True);
end;

constructor TUTF32TextWriter.CreateDirect(const AContext: PTextConvContext;
  const ATarget: TCachedWriter; const AOwner: Boolean);
begin
  FVirtuals.WriteSBCSCharsInternal := Pointer(@TUTF32TextWriter.WriteSBCSCharsInternal);
  inherited Create(AContext, ATarget, AOwner);
end;

procedure TUTF32TextWriter.InitContexts;
var
  LFlags: Cardinal;
begin
  LFlags := CHARCASE_FLAGS[0] + (Cardinal(bomUTF32) shl ENCODING_DESTINATION_OFFSET);
  TTextConvContextEx(FHugeContext).F.Flags := LFlags;
  @TTextConvContextEx(FHugeContext).FConvertProc := @TTextConvContextEx.convert_universal;
  @TTextConvContextEx(FUTF32Context).FConvertProc := @TTextConvContextEx.convert_copy;
end;

procedure TUTF32TextWriter.WriteCRLF;
var
  P: PCardinal;
begin
  P := Pointer(FCurrent);

  P^ := 13;
  Inc(P);
  P^ := 10;
  Inc(P);
  FCurrent := Pointer(P);

  if (NativeUInt(P) >= NativeUInt(Self.FOverflow)) then
    Self.Flush;
end;

procedure TUTF32TextWriter.WriteBufferedAscii(AFrom: PByte; ACount: NativeUInt);
type
  TDefaultCaller = procedure(ASelf: Pointer; const AChars: PAnsiChar; const ALength: NativeUInt);
const
  CHARS_IN_ITERATION = 4;
var
  P: NativeUInt{PByte};
  LSize, X, i: NativeUInt;
begin
  P := NativeUInt(FCurrent);
  LSize := ACount shl 2;
  Inc(P, LSize);

  if (P <= NativeUInt(Self.FOverflow)) then
  begin
    Self.FCurrent := Pointer(P);
    Dec(P, LSize);

    for i := 0 to LSize shr (2 + 2) do
    begin
      X := PCardinal(AFrom)^;
      Inc(AFrom, CHARS_IN_ITERATION);

      PCardinal(P)^ := Byte(X);
      Inc(P, SizeOf(Cardinal));
      X := X shr 8;
      PCardinal(P)^ := Byte(X);
      Inc(P, SizeOf(Cardinal));
      X := X shr 8;
      PCardinal(P)^ := Byte(X);
      Inc(P, SizeOf(Cardinal));
      X := X shr 8;
      PCardinal(P)^ := X;
      Inc(P, SizeOf(Cardinal));
    end;
    Exit;
  end else
  begin
    P := NativeUInt(@TUTF32TextWriter.WriteAscii);
    TDefaultCaller(P)(Self, Pointer(AFrom), LSize shr 2);
  end;
end;

procedure TUTF32TextWriter.WriteAscii(const AChars: PAnsiChar; const ALength: NativeUInt);
label
  _1, _2, _3;
const
  CHARS_IN_ITERATION = 4;
var
  i, j: NativeUInt;
  P: PCardinal;
  LSrc: PByte;
  X: NativeUInt;
begin
  LSrc := Pointer(AChars);
  P := Pointer(Self.FCurrent);

  for i := 1 to (ALength {$ifdef CPUX86}div 32{$else}shr 5{$endif}) do
  begin
    for j := 1 to (32 div CHARS_IN_ITERATION) do
    begin
      X := PCardinal(LSrc)^;
      Inc(LSrc, CHARS_IN_ITERATION);

      P^ := Byte(X);
      Inc(P);
      X := X shr 8;
      P^ := Byte(X);
      Inc(P);
      X := X shr 8;
      P^ := Byte(X);
      Inc(P);
      X := X shr 8;
      P^ := X;
      Inc(P);
    end;

    if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    begin
      Self.FCurrent := Pointer(P);
      Self.Flush;
      P := Pointer(Self.FCurrent);
    end;
  end;

  for i := 1 to ((ALength and 31) shr 2) do
  begin
    X := PCardinal(LSrc)^;
    Inc(LSrc, CHARS_IN_ITERATION);

    P^ := Byte(X);
    Inc(P);
    X := X shr 8;
    P^ := Byte(X);
    Inc(P);
    X := X shr 8;
    P^ := Byte(X);
    Inc(P);
    X := X shr 8;
    P^ := X;
    Inc(P);
  end;

  case ALength and (CHARS_IN_ITERATION - 1) of
    3:
    begin
    _3:
      P^ := LSrc^;
      Inc(LSrc);
      Inc(P);
      goto _2;
    end;
    2:
    begin
    _2:
      P^ := LSrc^;
      Inc(LSrc);
      Inc(P);
      goto _1;
    end;
    1:
    begin
    _1:
      P^ := LSrc^;
      // Inc(LSrc);
      Inc(P);
    end;
  end;

  Self.FCurrent := Pointer(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    Self.Flush;
end;

procedure TUTF32TextWriter.WriteUnicodeAscii(const AChars: PUnicodeChar; const ALength: NativeUInt);
label
  _1, _2, _3;
const
  CHARS_IN_ITERATION = 4;
var
  i, j: NativeUInt;
  P: PCardinal;
  LSrc: PWord;
  X: NativeUInt;
begin
  LSrc := Pointer(AChars);
  P := Pointer(Self.FCurrent);

  for i := 1 to (ALength {$ifdef CPUX86}div 32{$else}shr 5{$endif}) do
  begin
    for j := 1 to (32 div CHARS_IN_ITERATION) do
    begin
      X := PNativeUInt(LSrc)^;

      P^ := Word(X);
      Inc(P);
      X := X shr 16;
      {$ifdef LARGEINT}
      Inc(LSrc, CHARS_IN_ITERATION);
      P^ := Word(X);
      X := X shr 16;
      {$else}
      Inc(LSrc, CHARS_IN_ITERATION shr 1);
      P^ := X;
      X := PCardinal(LSrc)^;
      Inc(LSrc, CHARS_IN_ITERATION shr 1);
      {$endif}
      Inc(P);
      P^ := Word(X);
      Inc(P);
      X := X shr 16;
      P^ := X;
      Inc(P);
    end;

    if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    begin
      Self.FCurrent := Pointer(P);
      Self.Flush;
      P := Pointer(Self.FCurrent);
    end;
  end;

  for i := 1 to ((ALength and 31) shr 2) do
  begin
    X := PNativeUInt(LSrc)^;

    P^ := Word(X);
    Inc(P);
    X := X shr 16;
    {$ifdef LARGEINT}
    Inc(LSrc, CHARS_IN_ITERATION);
    P^ := Word(X);
    X := X shr 16;
    {$else}
    Inc(LSrc, CHARS_IN_ITERATION shr 1);
    P^ := X;
    X := PCardinal(LSrc)^;
    Inc(LSrc, CHARS_IN_ITERATION shr 1);
    {$endif}
    Inc(P);
    P^ := Word(X);
    Inc(P);
    X := X shr 16;
    P^ := X;
    Inc(P);
  end;

  case ALength and (CHARS_IN_ITERATION - 1) of
    3:
    begin
    _3:
      P^ := LSrc^;
      Inc(LSrc);
      Inc(P);
      goto _2;
    end;
    2:
    begin
    _2:
      P^ := LSrc^;
      Inc(LSrc);
      Inc(P);
      goto _1;
    end;
    1:
    begin
    _1:
      P^ := LSrc^;
      // Inc(Src);
      Inc(P);
    end;
  end;

  Self.FCurrent := Pointer(P);
  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
    Self.Flush;
end;

procedure TUTF32TextWriter.WriteUCS4Ascii(const AChars: PUCS4Char; const ALength: NativeUInt);
var
  P: PByte;
  LSize: NativeUInt;
begin
  P := FCurrent;
  LSize := ALength shl 2;
  Inc(P, LSize);

  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowWriteData(AChars^, LSize);
  end else
  begin
    FCurrent := P;
    Dec(P, LSize);
    TinyMove(AChars^, P^, LSize);
  end;
end;

procedure TUTF32TextWriter.WriteSBCSCharsInternal(const AChars: PAnsiChar; const ALength: NativeUInt);
begin
  with TTextConvContextEx(FHugeContext) do
  begin
    Source := AChars;
    SourceSize := ALength;
    F.Flags := (F.Flags and -32);
    FCallbacks.Reader := Self.FSBCSLookup.CurrentConverter;
  end;

  Self.WriteContextData(FHugeContext);
end;

procedure TUTF32TextWriter.WriteUTF8Chars(const AChars: PUTF8Char; const ALength: NativeUInt);
begin
  with TTextConvContextEx(FHugeContext) do
  begin
    Source := AChars;
    SourceSize := ALength;
    F.Flags := (F.Flags and -32) + Cardinal(bomUTF8);
  end;

  Self.WriteContextData(FHugeContext);
end;

procedure TUTF32TextWriter.WriteUnicodeChars(const AChars: PUnicodeChar;
  const ALength: NativeUInt);
begin
  with TTextConvContextEx(FHugeContext) do
  begin
    Source := AChars;
    SourceSize := ALength + ALength;
    F.Flags := (F.Flags and -32) + Cardinal(bomUTF16);
  end;

  Self.WriteContextData(FHugeContext);
end;

initialization
  {$ifdef FPC}
  FillDefaultSettings;
  {$endif}
  InternalLookupsInitialize;

end.
