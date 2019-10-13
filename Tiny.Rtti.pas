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
{ repository: https://github.com/d-mozulyov/Tiny.Rtti                          }
{******************************************************************************}

{$I TINY.DEFINES.inc}

interface
{$ifdef MSWINDOWS}
uses
  {$ifdef UNITSCOPENAMES}Winapi.Windows{$else}Windows{$endif};
{$endif}


type

{ RTL types }

  {$ifdef FPC}
    PUInt64 = ^UInt64;
    PBoolean = ^Boolean;
    PString = ^string;
  {$else}
    {$if CompilerVersion < 16}
      UInt64 = Int64;
      PUInt64 = ^UInt64;
    {$ifend}
    {$if CompilerVersion < 21}
      NativeInt = Integer;
      NativeUInt = Cardinal;
    {$ifend}
    {$if CompilerVersion < 22}
      PNativeInt = ^NativeInt;
      PNativeUInt = ^NativeUInt;
    {$ifend}
    PWord = ^Word;
  {$endif}
  {$if not Defined(FPC) and (CompilerVersion < 21)}
  TDate = type TDateTime;
  TTime = type TDateTime;
  {$ifend}
  PDate = ^TDate;
  PTime = ^TTime;
  {$if SizeOf(Extended) >= 10}
    {$define EXTENDEDSUPPORT}
  {$ifend}
  TBytes = {$if (not Defined(FPC)) and (CompilerVersion >= 23)}TArray<Byte>{$else}array of Byte{$ifend};
  PBytes = ^TBytes;

  {$ifdef ANSISTRSUPPORT}
    {$if Defined(NEXTGEN) and (CompilerVersion >= 31)}
      AnsiChar = type System.UTF8Char;
      PAnsiChar = ^AnsiChar;
      AnsiString = type System.RawByteString;
      PAnsiString = ^AnsiString;
      UTF8Char = System.UTF8Char;
      PUTF8Char = System.PUTF8Char;
      {$POINTERMATH ON}
    {$else}
      AnsiChar = System.AnsiChar;
      PAnsiChar = System.PAnsiChar;
      AnsiString = System.AnsiString;
      PAnsiString = System.PAnsiString;
      UTF8Char = type System.AnsiChar;
      PUTF8Char = ^UTF8Char;
    {$ifend}
    UTF8String = System.UTF8String;
    PUTF8String = System.PUTF8String;
    {$ifdef UNICODE}
      RawByteString = System.RawByteString;
      {$ifdef FPC}
      PRawByteString = ^RawByteString;
      {$else}
      PRawByteString = System.PRawByteString;
      {$endif}
    {$else}
      RawByteString = type AnsiString;
      PRawByteString = ^RawByteString;
    {$endif}
  {$else}
    AnsiChar = type Byte;
    PAnsiChar = ^AnsiChar;
    UTF8Char = type AnsiChar;
    PUTF8Char = ^UTF8Char;
    AnsiString = array of AnsiChar;
    PAnsiString = ^AnsiString;
    UTF8String = type AnsiString;
    PUTF8String = ^UTF8String;
    RawByteString = type AnsiString;
    PRawByteString = ^RawByteString;
  {$endif}
  {$ifdef SHORTSTRSUPPORT}
    ShortString = System.ShortString;
    PShortString = System.PShortString;
  {$else}
    ShortString = array[0{length}..255] of AnsiChar{/UTF8Char};
    PShortString = ^ShortString;
  {$endif}
  {$ifdef WIDESTRSUPPORT}
    WideString = System.WideString;
    PWideString = System.PWideString;
  {$else}
    WideString = array of WideChar;
    PWideString = ^WideString;
  {$endif}
  {$ifdef UNICODE}
    {$ifdef FPC}
    UnicodeChar = System.WideChar;
    PUnicodeChar = System.PWideChar;
    {$else}
    UnicodeChar = System.Char;
    PUnicodeChar = System.PChar;
    {$endif}
    UnicodeString = System.UnicodeString;
    PUnicodeString = System.PUnicodeString;
  {$else}
    UnicodeChar = System.WideChar;
    PUnicodeChar = System.PWideChar;
    UnicodeString = System.WideString;
    PUnicodeString = System.PWideString;
  {$endif}
  WideChar = System.WideChar;
  PWideChar = System.PWideChar;
  UCS4Char = System.UCS4Char;
  PUCS4Char = System.PUCS4Char;
  UCS4String = System.UCS4String;
  PUCS4String = ^UCS4String;

  PInternalInt = ^InternalInt;
  InternalInt = {$ifdef FPC}NativeInt{$else .DELPHI}Integer{$endif};
  PInternalUInt = ^InternalUInt;
  InternalUInt = {$ifdef FPC}NativeUInt{$else .DELPHI}Cardinal{$endif};

type
  PDynArrayRec = ^TDynArrayRec;
  TDynArrayRec = packed object
  protected
  {$ifdef FPC}
    function GetLength: NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetLength(const AValue: NativeInt); {$ifdef INLINESUPPORT}inline;{$endif}
  {$else .DELPHI}
    function GetHigh: NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetHigh(const AValue: NativeInt); {$ifdef INLINESUPPORT}inline;{$endif}
  {$endif}
  public
  {$ifdef FPC}
    property Length: NativeInt read GetLength write SetLength;
  {$else .DELPHI}
    property High: NativeInt read GetHigh write SetHigh;
  {$endif}
  public
  {$ifdef FPC}
    RefCount: InternalInt;
    High: NativeInt;
  {$else .DELPHI}
    {$ifdef LARGEINT}_Padding: Integer;{$endif}
    RefCount: InternalInt;
    Length: NativeInt;
  {$endif}
  end;

  {$ifdef UNICODE}
    PUnicodeStrRec = ^TUnicodeStrRec;
    TUnicodeStrRec = packed record
    case Integer of
      0:
      (
      {$ifdef FPC}
        CodePageElemSize: Integer;
        {$ifdef LARGEINT}_Padding: Integer;{$endif}
        RefCount: InternalInt;
        Length: InternalInt;
      {$else .DELPHI}
        {$ifdef LARGEINT}_Padding: Integer;{$endif}
        CodePageElemSize: Integer;
        RefCount: InternalInt;
        Length: InternalInt;
      {$endif}
      );
      1:
      (
        {$if (not Defined(FPC)) and Defined(LARGEINT)}_: Integer;{$ifend}
        CodePage: Word;
        ElementSize: Word;
      );
    end;
  const
    {$ifdef FPC}
      USTR_OFFSET_LENGTH = SizeOf(NativeInt);
      USTR_OFFSET_REFCOUNT = USTR_OFFSET_LENGTH + SizeOf(NativeInt);
      USTR_OFFSET_CODEPAGE = SizeOf(TUnicodeStrRec);
    {$else .DELPHI}
      USTR_OFFSET_LENGTH = 4{SizeOf(Integer)};
      USTR_OFFSET_REFCOUNT = USTR_OFFSET_LENGTH + SizeOf(Integer);
      USTR_OFFSET_CODEPAGE = USTR_OFFSET_REFCOUNT + {ElemSize}SizeOf(Word) + {CodePage}SizeOf(Word);
    {$endif}
  {$endif}

type
  PAnsiStrRec = ^TAnsiStrRec;
  {$if not Defined(ANSISTRSUPPORT)}
    TAnsiStrRec = TDynArrayRec;
  const
    {$ifdef FPC}
      // None
    {$else .DELPHI}
      ASTR_OFFSET_LENGTH = {$ifdef SMALLINT}4{$else}8{$endif}{SizeOf(NativeInt)};
      ASTR_OFFSET_REFCOUNT = ASTR_OFFSET_LENGTH + SizeOf(Integer);
    {$endif}
  {$elseif not Defined(INTERNALCODEPAGE)}
    TAnsiStrRec = packed record
      RefCount: Integer;
      Length: Integer;
    end;
  const
    {$ifdef FPC}
      // None
    {$else .DELPHI}
      ASTR_OFFSET_LENGTH = 4{SizeOf(Integer)};
      ASTR_OFFSET_REFCOUNT = ASTR_OFFSET_LENGTH + SizeOf(Integer);
    {$endif}
  {$else .INTERNALCODEPAGE}
    TAnsiStrRec = TUnicodeStrRec;
  const
    ASTR_OFFSET_LENGTH = USTR_OFFSET_LENGTH;
    ASTR_OFFSET_REFCOUNT = USTR_OFFSET_REFCOUNT;
    ASTR_OFFSET_CODEPAGE = USTR_OFFSET_CODEPAGE;
  {$ifend}

type
  PWideStrRec = ^TWideStrRec;
  {$if not Defined(WIDESTRSUPPORT)}
    TWideStrRec = TDynArrayRec;
  const
    WSTR_OFFSET_LENGTH = {$ifdef SMALLINT}4{$else}8{$endif}{SizeOf(NativeInt)};
  {$elseif Defined(MSWINDOWS)}
    TWideStrRec = packed object
    protected
      function GetLength: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
      procedure SetLength(const AValue: Integer); {$ifdef INLINESUPPORT}inline;{$endif}
    public
      property Length: Integer read GetLength write SetLength;
    public
      Size: Integer;
    end;
  const
    WSTR_OFFSET_SIZE = 4{SizeOf(Integer)};
  {$else .INTERNALCODEPAGE}
    TWideStrRec = TUnicodeStrRec;
  const
    WSTR_OFFSET_LENGTH = USTR_OFFSET_LENGTH;
  {$ifend}

  {$ifNdef UNICODE}
type
    PUnicodeStrRec = PWideStrRec;
    TUnicodeStrRec = TWideStrRec;
  const
    USTR_OFFSET_SIZE = WSTR_OFFSET_SIZE;
  {$endif}

type
  PUCS4StrRec = ^TUCS4StrRec;
  TUCS4StrRec = TDynArrayRec;

type
  PShortStringHelper = ^ShortStringHelper;
  ShortStringHelper = packed object
  protected
    function GetValue: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetValue(const AValue: Integer); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAnsiValue: AnsiString;
    function GetUTF8Value: UTF8String;
    function GetUnicodeValue: UnicodeString;
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Value: ShortString;

    property Length: Integer read GetValue write SetValue;
    property AnsiValue: AnsiString read GetAnsiValue;
    property UTF8Value: UTF8String read GetUTF8Value;
    property UnicodeValue: UnicodeString read GetUnicodeValue;
    property StringValue: string read {$ifdef UNICODE}GetUnicodeValue{$else .ANSI}GetAnsiValue{$endif};
    property Tail: Pointer read GetTail;
  end;

  string0 = {$ifdef SHORTSTRSUPPORT}string[0]{$else}array[0..0] of AnsiChar{$endif};
  string1 = {$ifdef SHORTSTRSUPPORT}string[1]{$else}array[0..1] of AnsiChar{$endif};
  string2 = {$ifdef SHORTSTRSUPPORT}string[2]{$else}array[0..2] of AnsiChar{$endif};
  string3 = {$ifdef SHORTSTRSUPPORT}string[3]{$else}array[0..3] of AnsiChar{$endif};
  string4 = {$ifdef SHORTSTRSUPPORT}string[4]{$else}array[0..4] of AnsiChar{$endif};
  string5 = {$ifdef SHORTSTRSUPPORT}string[5]{$else}array[0..5] of AnsiChar{$endif};
  string6 = {$ifdef SHORTSTRSUPPORT}string[6]{$else}array[0..6] of AnsiChar{$endif};
  string7 = {$ifdef SHORTSTRSUPPORT}string[7]{$else}array[0..7] of AnsiChar{$endif};
  string8 = {$ifdef SHORTSTRSUPPORT}string[8]{$else}array[0..8] of AnsiChar{$endif};
  string9 = {$ifdef SHORTSTRSUPPORT}string[9]{$else}array[0..9] of AnsiChar{$endif};
  string10 = {$ifdef SHORTSTRSUPPORT}string[10]{$else}array[0..10] of AnsiChar{$endif};
  string11 = {$ifdef SHORTSTRSUPPORT}string[11]{$else}array[0..11] of AnsiChar{$endif};
  string12 = {$ifdef SHORTSTRSUPPORT}string[12]{$else}array[0..12] of AnsiChar{$endif};
  string13 = {$ifdef SHORTSTRSUPPORT}string[13]{$else}array[0..13] of AnsiChar{$endif};
  string14 = {$ifdef SHORTSTRSUPPORT}string[14]{$else}array[0..14] of AnsiChar{$endif};
  string15 = {$ifdef SHORTSTRSUPPORT}string[15]{$else}array[0..15] of AnsiChar{$endif};
  string16 = {$ifdef SHORTSTRSUPPORT}string[16]{$else}array[0..16] of AnsiChar{$endif};
  string17 = {$ifdef SHORTSTRSUPPORT}string[17]{$else}array[0..17] of AnsiChar{$endif};
  string18 = {$ifdef SHORTSTRSUPPORT}string[18]{$else}array[0..18] of AnsiChar{$endif};
  string19 = {$ifdef SHORTSTRSUPPORT}string[19]{$else}array[0..19] of AnsiChar{$endif};
  string20 = {$ifdef SHORTSTRSUPPORT}string[20]{$else}array[0..20] of AnsiChar{$endif};
  string21 = {$ifdef SHORTSTRSUPPORT}string[21]{$else}array[0..21] of AnsiChar{$endif};
  string22 = {$ifdef SHORTSTRSUPPORT}string[22]{$else}array[0..22] of AnsiChar{$endif};
  string23 = {$ifdef SHORTSTRSUPPORT}string[23]{$else}array[0..23] of AnsiChar{$endif};
  string24 = {$ifdef SHORTSTRSUPPORT}string[24]{$else}array[0..24] of AnsiChar{$endif};
  string25 = {$ifdef SHORTSTRSUPPORT}string[25]{$else}array[0..25] of AnsiChar{$endif};
  string26 = {$ifdef SHORTSTRSUPPORT}string[26]{$else}array[0..26] of AnsiChar{$endif};
  string27 = {$ifdef SHORTSTRSUPPORT}string[27]{$else}array[0..27] of AnsiChar{$endif};
  string28 = {$ifdef SHORTSTRSUPPORT}string[28]{$else}array[0..28] of AnsiChar{$endif};
  string29 = {$ifdef SHORTSTRSUPPORT}string[29]{$else}array[0..29] of AnsiChar{$endif};
  string30 = {$ifdef SHORTSTRSUPPORT}string[30]{$else}array[0..30] of AnsiChar{$endif};
  string31 = {$ifdef SHORTSTRSUPPORT}string[31]{$else}array[0..31] of AnsiChar{$endif};
  string32 = {$ifdef SHORTSTRSUPPORT}string[32]{$else}array[0..32] of AnsiChar{$endif};
  string33 = {$ifdef SHORTSTRSUPPORT}string[33]{$else}array[0..33] of AnsiChar{$endif};
  string34 = {$ifdef SHORTSTRSUPPORT}string[34]{$else}array[0..34] of AnsiChar{$endif};
  string35 = {$ifdef SHORTSTRSUPPORT}string[35]{$else}array[0..35] of AnsiChar{$endif};
  string36 = {$ifdef SHORTSTRSUPPORT}string[36]{$else}array[0..36] of AnsiChar{$endif};
  string37 = {$ifdef SHORTSTRSUPPORT}string[37]{$else}array[0..37] of AnsiChar{$endif};
  string38 = {$ifdef SHORTSTRSUPPORT}string[38]{$else}array[0..38] of AnsiChar{$endif};
  string39 = {$ifdef SHORTSTRSUPPORT}string[39]{$else}array[0..39] of AnsiChar{$endif};
  string40 = {$ifdef SHORTSTRSUPPORT}string[40]{$else}array[0..40] of AnsiChar{$endif};
  string41 = {$ifdef SHORTSTRSUPPORT}string[41]{$else}array[0..41] of AnsiChar{$endif};
  string42 = {$ifdef SHORTSTRSUPPORT}string[42]{$else}array[0..42] of AnsiChar{$endif};
  string43 = {$ifdef SHORTSTRSUPPORT}string[43]{$else}array[0..43] of AnsiChar{$endif};
  string44 = {$ifdef SHORTSTRSUPPORT}string[44]{$else}array[0..44] of AnsiChar{$endif};
  string45 = {$ifdef SHORTSTRSUPPORT}string[45]{$else}array[0..45] of AnsiChar{$endif};
  string46 = {$ifdef SHORTSTRSUPPORT}string[46]{$else}array[0..46] of AnsiChar{$endif};
  string47 = {$ifdef SHORTSTRSUPPORT}string[47]{$else}array[0..47] of AnsiChar{$endif};
  string48 = {$ifdef SHORTSTRSUPPORT}string[48]{$else}array[0..48] of AnsiChar{$endif};
  string49 = {$ifdef SHORTSTRSUPPORT}string[49]{$else}array[0..49] of AnsiChar{$endif};
  string50 = {$ifdef SHORTSTRSUPPORT}string[50]{$else}array[0..50] of AnsiChar{$endif};
  string51 = {$ifdef SHORTSTRSUPPORT}string[51]{$else}array[0..51] of AnsiChar{$endif};
  string52 = {$ifdef SHORTSTRSUPPORT}string[52]{$else}array[0..52] of AnsiChar{$endif};
  string53 = {$ifdef SHORTSTRSUPPORT}string[53]{$else}array[0..53] of AnsiChar{$endif};
  string54 = {$ifdef SHORTSTRSUPPORT}string[54]{$else}array[0..54] of AnsiChar{$endif};
  string55 = {$ifdef SHORTSTRSUPPORT}string[55]{$else}array[0..55] of AnsiChar{$endif};
  string56 = {$ifdef SHORTSTRSUPPORT}string[56]{$else}array[0..56] of AnsiChar{$endif};
  string57 = {$ifdef SHORTSTRSUPPORT}string[57]{$else}array[0..57] of AnsiChar{$endif};
  string58 = {$ifdef SHORTSTRSUPPORT}string[58]{$else}array[0..58] of AnsiChar{$endif};
  string59 = {$ifdef SHORTSTRSUPPORT}string[59]{$else}array[0..59] of AnsiChar{$endif};
  string60 = {$ifdef SHORTSTRSUPPORT}string[60]{$else}array[0..60] of AnsiChar{$endif};
  string61 = {$ifdef SHORTSTRSUPPORT}string[61]{$else}array[0..61] of AnsiChar{$endif};
  string62 = {$ifdef SHORTSTRSUPPORT}string[62]{$else}array[0..62] of AnsiChar{$endif};
  string63 = {$ifdef SHORTSTRSUPPORT}string[63]{$else}array[0..63] of AnsiChar{$endif};
  string64 = {$ifdef SHORTSTRSUPPORT}string[64]{$else}array[0..64] of AnsiChar{$endif};
  string65 = {$ifdef SHORTSTRSUPPORT}string[65]{$else}array[0..65] of AnsiChar{$endif};
  string66 = {$ifdef SHORTSTRSUPPORT}string[66]{$else}array[0..66] of AnsiChar{$endif};
  string67 = {$ifdef SHORTSTRSUPPORT}string[67]{$else}array[0..67] of AnsiChar{$endif};
  string68 = {$ifdef SHORTSTRSUPPORT}string[68]{$else}array[0..68] of AnsiChar{$endif};
  string69 = {$ifdef SHORTSTRSUPPORT}string[69]{$else}array[0..69] of AnsiChar{$endif};
  string70 = {$ifdef SHORTSTRSUPPORT}string[70]{$else}array[0..70] of AnsiChar{$endif};
  string71 = {$ifdef SHORTSTRSUPPORT}string[71]{$else}array[0..71] of AnsiChar{$endif};
  string72 = {$ifdef SHORTSTRSUPPORT}string[72]{$else}array[0..72] of AnsiChar{$endif};
  string73 = {$ifdef SHORTSTRSUPPORT}string[73]{$else}array[0..73] of AnsiChar{$endif};
  string74 = {$ifdef SHORTSTRSUPPORT}string[74]{$else}array[0..74] of AnsiChar{$endif};
  string75 = {$ifdef SHORTSTRSUPPORT}string[75]{$else}array[0..75] of AnsiChar{$endif};
  string76 = {$ifdef SHORTSTRSUPPORT}string[76]{$else}array[0..76] of AnsiChar{$endif};
  string77 = {$ifdef SHORTSTRSUPPORT}string[77]{$else}array[0..77] of AnsiChar{$endif};
  string78 = {$ifdef SHORTSTRSUPPORT}string[78]{$else}array[0..78] of AnsiChar{$endif};
  string79 = {$ifdef SHORTSTRSUPPORT}string[79]{$else}array[0..79] of AnsiChar{$endif};
  string80 = {$ifdef SHORTSTRSUPPORT}string[80]{$else}array[0..80] of AnsiChar{$endif};
  string81 = {$ifdef SHORTSTRSUPPORT}string[81]{$else}array[0..81] of AnsiChar{$endif};
  string82 = {$ifdef SHORTSTRSUPPORT}string[82]{$else}array[0..82] of AnsiChar{$endif};
  string83 = {$ifdef SHORTSTRSUPPORT}string[83]{$else}array[0..83] of AnsiChar{$endif};
  string84 = {$ifdef SHORTSTRSUPPORT}string[84]{$else}array[0..84] of AnsiChar{$endif};
  string85 = {$ifdef SHORTSTRSUPPORT}string[85]{$else}array[0..85] of AnsiChar{$endif};
  string86 = {$ifdef SHORTSTRSUPPORT}string[86]{$else}array[0..86] of AnsiChar{$endif};
  string87 = {$ifdef SHORTSTRSUPPORT}string[87]{$else}array[0..87] of AnsiChar{$endif};
  string88 = {$ifdef SHORTSTRSUPPORT}string[88]{$else}array[0..88] of AnsiChar{$endif};
  string89 = {$ifdef SHORTSTRSUPPORT}string[89]{$else}array[0..89] of AnsiChar{$endif};
  string90 = {$ifdef SHORTSTRSUPPORT}string[90]{$else}array[0..90] of AnsiChar{$endif};
  string91 = {$ifdef SHORTSTRSUPPORT}string[91]{$else}array[0..91] of AnsiChar{$endif};
  string92 = {$ifdef SHORTSTRSUPPORT}string[92]{$else}array[0..92] of AnsiChar{$endif};
  string93 = {$ifdef SHORTSTRSUPPORT}string[93]{$else}array[0..93] of AnsiChar{$endif};
  string94 = {$ifdef SHORTSTRSUPPORT}string[94]{$else}array[0..94] of AnsiChar{$endif};
  string95 = {$ifdef SHORTSTRSUPPORT}string[95]{$else}array[0..95] of AnsiChar{$endif};
  string96 = {$ifdef SHORTSTRSUPPORT}string[96]{$else}array[0..96] of AnsiChar{$endif};
  string97 = {$ifdef SHORTSTRSUPPORT}string[97]{$else}array[0..97] of AnsiChar{$endif};
  string98 = {$ifdef SHORTSTRSUPPORT}string[98]{$else}array[0..98] of AnsiChar{$endif};
  string99 = {$ifdef SHORTSTRSUPPORT}string[99]{$else}array[0..99] of AnsiChar{$endif};
  string100 = {$ifdef SHORTSTRSUPPORT}string[100]{$else}array[0..100] of AnsiChar{$endif};
  string101 = {$ifdef SHORTSTRSUPPORT}string[101]{$else}array[0..101] of AnsiChar{$endif};
  string102 = {$ifdef SHORTSTRSUPPORT}string[102]{$else}array[0..102] of AnsiChar{$endif};
  string103 = {$ifdef SHORTSTRSUPPORT}string[103]{$else}array[0..103] of AnsiChar{$endif};
  string104 = {$ifdef SHORTSTRSUPPORT}string[104]{$else}array[0..104] of AnsiChar{$endif};
  string105 = {$ifdef SHORTSTRSUPPORT}string[105]{$else}array[0..105] of AnsiChar{$endif};
  string106 = {$ifdef SHORTSTRSUPPORT}string[106]{$else}array[0..106] of AnsiChar{$endif};
  string107 = {$ifdef SHORTSTRSUPPORT}string[107]{$else}array[0..107] of AnsiChar{$endif};
  string108 = {$ifdef SHORTSTRSUPPORT}string[108]{$else}array[0..108] of AnsiChar{$endif};
  string109 = {$ifdef SHORTSTRSUPPORT}string[109]{$else}array[0..109] of AnsiChar{$endif};
  string110 = {$ifdef SHORTSTRSUPPORT}string[110]{$else}array[0..110] of AnsiChar{$endif};
  string111 = {$ifdef SHORTSTRSUPPORT}string[111]{$else}array[0..111] of AnsiChar{$endif};
  string112 = {$ifdef SHORTSTRSUPPORT}string[112]{$else}array[0..112] of AnsiChar{$endif};
  string113 = {$ifdef SHORTSTRSUPPORT}string[113]{$else}array[0..113] of AnsiChar{$endif};
  string114 = {$ifdef SHORTSTRSUPPORT}string[114]{$else}array[0..114] of AnsiChar{$endif};
  string115 = {$ifdef SHORTSTRSUPPORT}string[115]{$else}array[0..115] of AnsiChar{$endif};
  string116 = {$ifdef SHORTSTRSUPPORT}string[116]{$else}array[0..116] of AnsiChar{$endif};
  string117 = {$ifdef SHORTSTRSUPPORT}string[117]{$else}array[0..117] of AnsiChar{$endif};
  string118 = {$ifdef SHORTSTRSUPPORT}string[118]{$else}array[0..118] of AnsiChar{$endif};
  string119 = {$ifdef SHORTSTRSUPPORT}string[119]{$else}array[0..119] of AnsiChar{$endif};
  string120 = {$ifdef SHORTSTRSUPPORT}string[120]{$else}array[0..120] of AnsiChar{$endif};
  string121 = {$ifdef SHORTSTRSUPPORT}string[121]{$else}array[0..121] of AnsiChar{$endif};
  string122 = {$ifdef SHORTSTRSUPPORT}string[122]{$else}array[0..122] of AnsiChar{$endif};
  string123 = {$ifdef SHORTSTRSUPPORT}string[123]{$else}array[0..123] of AnsiChar{$endif};
  string124 = {$ifdef SHORTSTRSUPPORT}string[124]{$else}array[0..124] of AnsiChar{$endif};
  string125 = {$ifdef SHORTSTRSUPPORT}string[125]{$else}array[0..125] of AnsiChar{$endif};
  string126 = {$ifdef SHORTSTRSUPPORT}string[126]{$else}array[0..126] of AnsiChar{$endif};
  string127 = {$ifdef SHORTSTRSUPPORT}string[127]{$else}array[0..127] of AnsiChar{$endif};
  string128 = {$ifdef SHORTSTRSUPPORT}string[128]{$else}array[0..128] of AnsiChar{$endif};
  string129 = {$ifdef SHORTSTRSUPPORT}string[129]{$else}array[0..129] of AnsiChar{$endif};
  string130 = {$ifdef SHORTSTRSUPPORT}string[130]{$else}array[0..130] of AnsiChar{$endif};
  string131 = {$ifdef SHORTSTRSUPPORT}string[131]{$else}array[0..131] of AnsiChar{$endif};
  string132 = {$ifdef SHORTSTRSUPPORT}string[132]{$else}array[0..132] of AnsiChar{$endif};
  string133 = {$ifdef SHORTSTRSUPPORT}string[133]{$else}array[0..133] of AnsiChar{$endif};
  string134 = {$ifdef SHORTSTRSUPPORT}string[134]{$else}array[0..134] of AnsiChar{$endif};
  string135 = {$ifdef SHORTSTRSUPPORT}string[135]{$else}array[0..135] of AnsiChar{$endif};
  string136 = {$ifdef SHORTSTRSUPPORT}string[136]{$else}array[0..136] of AnsiChar{$endif};
  string137 = {$ifdef SHORTSTRSUPPORT}string[137]{$else}array[0..137] of AnsiChar{$endif};
  string138 = {$ifdef SHORTSTRSUPPORT}string[138]{$else}array[0..138] of AnsiChar{$endif};
  string139 = {$ifdef SHORTSTRSUPPORT}string[139]{$else}array[0..139] of AnsiChar{$endif};
  string140 = {$ifdef SHORTSTRSUPPORT}string[140]{$else}array[0..140] of AnsiChar{$endif};
  string141 = {$ifdef SHORTSTRSUPPORT}string[141]{$else}array[0..141] of AnsiChar{$endif};
  string142 = {$ifdef SHORTSTRSUPPORT}string[142]{$else}array[0..142] of AnsiChar{$endif};
  string143 = {$ifdef SHORTSTRSUPPORT}string[143]{$else}array[0..143] of AnsiChar{$endif};
  string144 = {$ifdef SHORTSTRSUPPORT}string[144]{$else}array[0..144] of AnsiChar{$endif};
  string145 = {$ifdef SHORTSTRSUPPORT}string[145]{$else}array[0..145] of AnsiChar{$endif};
  string146 = {$ifdef SHORTSTRSUPPORT}string[146]{$else}array[0..146] of AnsiChar{$endif};
  string147 = {$ifdef SHORTSTRSUPPORT}string[147]{$else}array[0..147] of AnsiChar{$endif};
  string148 = {$ifdef SHORTSTRSUPPORT}string[148]{$else}array[0..148] of AnsiChar{$endif};
  string149 = {$ifdef SHORTSTRSUPPORT}string[149]{$else}array[0..149] of AnsiChar{$endif};
  string150 = {$ifdef SHORTSTRSUPPORT}string[150]{$else}array[0..150] of AnsiChar{$endif};
  string151 = {$ifdef SHORTSTRSUPPORT}string[151]{$else}array[0..151] of AnsiChar{$endif};
  string152 = {$ifdef SHORTSTRSUPPORT}string[152]{$else}array[0..152] of AnsiChar{$endif};
  string153 = {$ifdef SHORTSTRSUPPORT}string[153]{$else}array[0..153] of AnsiChar{$endif};
  string154 = {$ifdef SHORTSTRSUPPORT}string[154]{$else}array[0..154] of AnsiChar{$endif};
  string155 = {$ifdef SHORTSTRSUPPORT}string[155]{$else}array[0..155] of AnsiChar{$endif};
  string156 = {$ifdef SHORTSTRSUPPORT}string[156]{$else}array[0..156] of AnsiChar{$endif};
  string157 = {$ifdef SHORTSTRSUPPORT}string[157]{$else}array[0..157] of AnsiChar{$endif};
  string158 = {$ifdef SHORTSTRSUPPORT}string[158]{$else}array[0..158] of AnsiChar{$endif};
  string159 = {$ifdef SHORTSTRSUPPORT}string[159]{$else}array[0..159] of AnsiChar{$endif};
  string160 = {$ifdef SHORTSTRSUPPORT}string[160]{$else}array[0..160] of AnsiChar{$endif};
  string161 = {$ifdef SHORTSTRSUPPORT}string[161]{$else}array[0..161] of AnsiChar{$endif};
  string162 = {$ifdef SHORTSTRSUPPORT}string[162]{$else}array[0..162] of AnsiChar{$endif};
  string163 = {$ifdef SHORTSTRSUPPORT}string[163]{$else}array[0..163] of AnsiChar{$endif};
  string164 = {$ifdef SHORTSTRSUPPORT}string[164]{$else}array[0..164] of AnsiChar{$endif};
  string165 = {$ifdef SHORTSTRSUPPORT}string[165]{$else}array[0..165] of AnsiChar{$endif};
  string166 = {$ifdef SHORTSTRSUPPORT}string[166]{$else}array[0..166] of AnsiChar{$endif};
  string167 = {$ifdef SHORTSTRSUPPORT}string[167]{$else}array[0..167] of AnsiChar{$endif};
  string168 = {$ifdef SHORTSTRSUPPORT}string[168]{$else}array[0..168] of AnsiChar{$endif};
  string169 = {$ifdef SHORTSTRSUPPORT}string[169]{$else}array[0..169] of AnsiChar{$endif};
  string170 = {$ifdef SHORTSTRSUPPORT}string[170]{$else}array[0..170] of AnsiChar{$endif};
  string171 = {$ifdef SHORTSTRSUPPORT}string[171]{$else}array[0..171] of AnsiChar{$endif};
  string172 = {$ifdef SHORTSTRSUPPORT}string[172]{$else}array[0..172] of AnsiChar{$endif};
  string173 = {$ifdef SHORTSTRSUPPORT}string[173]{$else}array[0..173] of AnsiChar{$endif};
  string174 = {$ifdef SHORTSTRSUPPORT}string[174]{$else}array[0..174] of AnsiChar{$endif};
  string175 = {$ifdef SHORTSTRSUPPORT}string[175]{$else}array[0..175] of AnsiChar{$endif};
  string176 = {$ifdef SHORTSTRSUPPORT}string[176]{$else}array[0..176] of AnsiChar{$endif};
  string177 = {$ifdef SHORTSTRSUPPORT}string[177]{$else}array[0..177] of AnsiChar{$endif};
  string178 = {$ifdef SHORTSTRSUPPORT}string[178]{$else}array[0..178] of AnsiChar{$endif};
  string179 = {$ifdef SHORTSTRSUPPORT}string[179]{$else}array[0..179] of AnsiChar{$endif};
  string180 = {$ifdef SHORTSTRSUPPORT}string[180]{$else}array[0..180] of AnsiChar{$endif};
  string181 = {$ifdef SHORTSTRSUPPORT}string[181]{$else}array[0..181] of AnsiChar{$endif};
  string182 = {$ifdef SHORTSTRSUPPORT}string[182]{$else}array[0..182] of AnsiChar{$endif};
  string183 = {$ifdef SHORTSTRSUPPORT}string[183]{$else}array[0..183] of AnsiChar{$endif};
  string184 = {$ifdef SHORTSTRSUPPORT}string[184]{$else}array[0..184] of AnsiChar{$endif};
  string185 = {$ifdef SHORTSTRSUPPORT}string[185]{$else}array[0..185] of AnsiChar{$endif};
  string186 = {$ifdef SHORTSTRSUPPORT}string[186]{$else}array[0..186] of AnsiChar{$endif};
  string187 = {$ifdef SHORTSTRSUPPORT}string[187]{$else}array[0..187] of AnsiChar{$endif};
  string188 = {$ifdef SHORTSTRSUPPORT}string[188]{$else}array[0..188] of AnsiChar{$endif};
  string189 = {$ifdef SHORTSTRSUPPORT}string[189]{$else}array[0..189] of AnsiChar{$endif};
  string190 = {$ifdef SHORTSTRSUPPORT}string[190]{$else}array[0..190] of AnsiChar{$endif};
  string191 = {$ifdef SHORTSTRSUPPORT}string[191]{$else}array[0..191] of AnsiChar{$endif};
  string192 = {$ifdef SHORTSTRSUPPORT}string[192]{$else}array[0..192] of AnsiChar{$endif};
  string193 = {$ifdef SHORTSTRSUPPORT}string[193]{$else}array[0..193] of AnsiChar{$endif};
  string194 = {$ifdef SHORTSTRSUPPORT}string[194]{$else}array[0..194] of AnsiChar{$endif};
  string195 = {$ifdef SHORTSTRSUPPORT}string[195]{$else}array[0..195] of AnsiChar{$endif};
  string196 = {$ifdef SHORTSTRSUPPORT}string[196]{$else}array[0..196] of AnsiChar{$endif};
  string197 = {$ifdef SHORTSTRSUPPORT}string[197]{$else}array[0..197] of AnsiChar{$endif};
  string198 = {$ifdef SHORTSTRSUPPORT}string[198]{$else}array[0..198] of AnsiChar{$endif};
  string199 = {$ifdef SHORTSTRSUPPORT}string[199]{$else}array[0..199] of AnsiChar{$endif};
  string200 = {$ifdef SHORTSTRSUPPORT}string[200]{$else}array[0..200] of AnsiChar{$endif};
  string201 = {$ifdef SHORTSTRSUPPORT}string[201]{$else}array[0..201] of AnsiChar{$endif};
  string202 = {$ifdef SHORTSTRSUPPORT}string[202]{$else}array[0..202] of AnsiChar{$endif};
  string203 = {$ifdef SHORTSTRSUPPORT}string[203]{$else}array[0..203] of AnsiChar{$endif};
  string204 = {$ifdef SHORTSTRSUPPORT}string[204]{$else}array[0..204] of AnsiChar{$endif};
  string205 = {$ifdef SHORTSTRSUPPORT}string[205]{$else}array[0..205] of AnsiChar{$endif};
  string206 = {$ifdef SHORTSTRSUPPORT}string[206]{$else}array[0..206] of AnsiChar{$endif};
  string207 = {$ifdef SHORTSTRSUPPORT}string[207]{$else}array[0..207] of AnsiChar{$endif};
  string208 = {$ifdef SHORTSTRSUPPORT}string[208]{$else}array[0..208] of AnsiChar{$endif};
  string209 = {$ifdef SHORTSTRSUPPORT}string[209]{$else}array[0..209] of AnsiChar{$endif};
  string210 = {$ifdef SHORTSTRSUPPORT}string[210]{$else}array[0..210] of AnsiChar{$endif};
  string211 = {$ifdef SHORTSTRSUPPORT}string[211]{$else}array[0..211] of AnsiChar{$endif};
  string212 = {$ifdef SHORTSTRSUPPORT}string[212]{$else}array[0..212] of AnsiChar{$endif};
  string213 = {$ifdef SHORTSTRSUPPORT}string[213]{$else}array[0..213] of AnsiChar{$endif};
  string214 = {$ifdef SHORTSTRSUPPORT}string[214]{$else}array[0..214] of AnsiChar{$endif};
  string215 = {$ifdef SHORTSTRSUPPORT}string[215]{$else}array[0..215] of AnsiChar{$endif};
  string216 = {$ifdef SHORTSTRSUPPORT}string[216]{$else}array[0..216] of AnsiChar{$endif};
  string217 = {$ifdef SHORTSTRSUPPORT}string[217]{$else}array[0..217] of AnsiChar{$endif};
  string218 = {$ifdef SHORTSTRSUPPORT}string[218]{$else}array[0..218] of AnsiChar{$endif};
  string219 = {$ifdef SHORTSTRSUPPORT}string[219]{$else}array[0..219] of AnsiChar{$endif};
  string220 = {$ifdef SHORTSTRSUPPORT}string[220]{$else}array[0..220] of AnsiChar{$endif};
  string221 = {$ifdef SHORTSTRSUPPORT}string[221]{$else}array[0..221] of AnsiChar{$endif};
  string222 = {$ifdef SHORTSTRSUPPORT}string[222]{$else}array[0..222] of AnsiChar{$endif};
  string223 = {$ifdef SHORTSTRSUPPORT}string[223]{$else}array[0..223] of AnsiChar{$endif};
  string224 = {$ifdef SHORTSTRSUPPORT}string[224]{$else}array[0..224] of AnsiChar{$endif};
  string225 = {$ifdef SHORTSTRSUPPORT}string[225]{$else}array[0..225] of AnsiChar{$endif};
  string226 = {$ifdef SHORTSTRSUPPORT}string[226]{$else}array[0..226] of AnsiChar{$endif};
  string227 = {$ifdef SHORTSTRSUPPORT}string[227]{$else}array[0..227] of AnsiChar{$endif};
  string228 = {$ifdef SHORTSTRSUPPORT}string[228]{$else}array[0..228] of AnsiChar{$endif};
  string229 = {$ifdef SHORTSTRSUPPORT}string[229]{$else}array[0..229] of AnsiChar{$endif};
  string230 = {$ifdef SHORTSTRSUPPORT}string[230]{$else}array[0..230] of AnsiChar{$endif};
  string231 = {$ifdef SHORTSTRSUPPORT}string[231]{$else}array[0..231] of AnsiChar{$endif};
  string232 = {$ifdef SHORTSTRSUPPORT}string[232]{$else}array[0..232] of AnsiChar{$endif};
  string233 = {$ifdef SHORTSTRSUPPORT}string[233]{$else}array[0..233] of AnsiChar{$endif};
  string234 = {$ifdef SHORTSTRSUPPORT}string[234]{$else}array[0..234] of AnsiChar{$endif};
  string235 = {$ifdef SHORTSTRSUPPORT}string[235]{$else}array[0..235] of AnsiChar{$endif};
  string236 = {$ifdef SHORTSTRSUPPORT}string[236]{$else}array[0..236] of AnsiChar{$endif};
  string237 = {$ifdef SHORTSTRSUPPORT}string[237]{$else}array[0..237] of AnsiChar{$endif};
  string238 = {$ifdef SHORTSTRSUPPORT}string[238]{$else}array[0..238] of AnsiChar{$endif};
  string239 = {$ifdef SHORTSTRSUPPORT}string[239]{$else}array[0..239] of AnsiChar{$endif};
  string240 = {$ifdef SHORTSTRSUPPORT}string[240]{$else}array[0..240] of AnsiChar{$endif};
  string241 = {$ifdef SHORTSTRSUPPORT}string[241]{$else}array[0..241] of AnsiChar{$endif};
  string242 = {$ifdef SHORTSTRSUPPORT}string[242]{$else}array[0..242] of AnsiChar{$endif};
  string243 = {$ifdef SHORTSTRSUPPORT}string[243]{$else}array[0..243] of AnsiChar{$endif};
  string244 = {$ifdef SHORTSTRSUPPORT}string[244]{$else}array[0..244] of AnsiChar{$endif};
  string245 = {$ifdef SHORTSTRSUPPORT}string[245]{$else}array[0..245] of AnsiChar{$endif};
  string246 = {$ifdef SHORTSTRSUPPORT}string[246]{$else}array[0..246] of AnsiChar{$endif};
  string247 = {$ifdef SHORTSTRSUPPORT}string[247]{$else}array[0..247] of AnsiChar{$endif};
  string248 = {$ifdef SHORTSTRSUPPORT}string[248]{$else}array[0..248] of AnsiChar{$endif};
  string249 = {$ifdef SHORTSTRSUPPORT}string[249]{$else}array[0..249] of AnsiChar{$endif};
  string250 = {$ifdef SHORTSTRSUPPORT}string[250]{$else}array[0..250] of AnsiChar{$endif};
  string251 = {$ifdef SHORTSTRSUPPORT}string[251]{$else}array[0..251] of AnsiChar{$endif};
  string252 = {$ifdef SHORTSTRSUPPORT}string[252]{$else}array[0..252] of AnsiChar{$endif};
  string253 = {$ifdef SHORTSTRSUPPORT}string[253]{$else}array[0..253] of AnsiChar{$endif};
  string254 = {$ifdef SHORTSTRSUPPORT}string[254]{$else}array[0..254] of AnsiChar{$endif};
  string255 = {$ifdef SHORTSTRSUPPORT}string[255]{$else}array[0..255] of AnsiChar{$endif};


{ Universal timestamp format
  Recommendation:
    The number of 100-nanosecond intervals since January 1, 1601 UTC (Windows FILETIME format) }

  TimeStamp = type Int64;
  PTimeStamp = ^TimeStamp;


{ References (interfaces, objects, methods) }

  PReference = ^TReference;
  TReference = (rfDefault, rfWeak, rfUnsafe);
  PReferences = ^TReferences;
  TReferences = set of TReference;


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
  TAttrEntryReader = packed object
  protected
    function RangeError: Pointer;
    function GetEOF: Boolean;
    function GetMargin: NativeUInt;
  public
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

  PAttrEntry = ^TAttrEntry;
  TAttrEntry = packed object
  protected
    function GetClassType: TClass; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetConstructorSignature: PVmtMethodSignature;
    function GetReader: TAttrEntryReader; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
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

  TAttrData = packed object
  protected
    function GetValue: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCount: Integer;
    function GetReference: TReference; {$if Defined(INLINESUPPORT) and not Defined(WEAKREF)}inline;{$ifend}
  public
    Len: Word;
    Entries: TAttrEntry;
    {Entries: array[] of TAttrEntry;}
    property Value: PAttrData read GetValue;
    property Tail: Pointer read GetTail;
    property Count: Integer read GetCount;
    property Reference: TReference read GetReference;
  end;
 {$endif .EXTENDEDRTTI}


{ Internal RTTI structures }

  PTypeData = ^TTypeData;
  PPTypeInfo = ^PTypeInfo;
  PTypeInfo = ^TTypeInfo;
  TTypeInfo = packed object
  protected
    function GetTypeData: PTypeData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrData: PAttrData;
    {$endif}
  public
    Kind: TTypeKind;
    Name: ShortStringHelper;

    property TypeData: PTypeData read GetTypeData;
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;

  PPTypeInfoRef = ^PTypeInfoRef;
  PTypeInfoRef = {$ifdef INLINESUPPORT}packed object{$else}class{$endif}
  protected
    {$ifdef INLINESUPPORT}
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
    property Value: PTypeInfo read F.Value;
  {$else .DELPHI}
    function GetValue: PTypeInfo; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    property Value: PTypeInfo read GetValue;
  {$endif}
    property Address: Pointer read {$ifdef INLINESUPPORT}F.Address{$else}GetAddress{$endif};
    property Assigned: Boolean read GetAssigned;
  end;

  PParamData = ^TParamData;
  TParamData = packed object
    Name: PShortStringHelper;
    Reference: TReference;
    TypeInfo: PTypeInfo;
    TypeName: PShortStringHelper;
  end;

  PResultData = ^TResultData;
  TResultData = packed object(TParamData)
  protected
    {$ifdef WEAKREF}
    procedure InitReference(const AAttrData: PAttrData);
    {$endif}
    function GetAssigned: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    property Assigned: Boolean read GetAssigned;
  end;

  PAttributedParamData = ^TAttributedParamData;
  TAttributedParamData = packed object(TParamData)
  protected
    {$ifdef WEAKREF}
    procedure InitReference;
    {$endif}
  public
    {$ifdef EXTENDEDRTTI}
    AttrData: PAttrData;
    {$endif}
  end;

  PArgumentData = ^TArgumentData;
  TArgumentData = packed object(TAttributedParamData)
  protected
    {$ifdef WEAKREF}
    procedure InitReference; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    Flags: TParamFlags;
  end;

  PFieldData = ^TFieldData;
  TFieldData = packed object(TAttributedParamData)
    Visibility: TMemberVisibility;
    Offset: Cardinal;
  end;

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
  TPropInfo = packed object
  protected
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
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

  PPropData = ^TPropData;
  TPropData = packed object
  protected
    function GetTail: Pointer;
  public
    PropCount: Word;
    PropList: TPropInfo;
    {PropList: array[1..PropCount] of TPropInfo;}
    property Tail: Pointer read GetTail;
  end;

  TPropInfoProc = procedure(PropInfo: PPropInfo) of object;
  PPropList = ^TPropList;
  TPropList = array[0..16379] of PPropInfo;

  PManagedField = ^TManagedField;
  TManagedField = packed object
  protected
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    TypeRef: PTypeInfoRef;
    FldOffset: NativeInt;
    property Tail:Pointer read GetTail;
  end;

  PVmtFieldClassTab = ^TVmtFieldClassTab;
  TVmtFieldClassTab = packed object
  protected
    {$ifNdef FPC}
    function GetClass(const AIndex: Word): TClass; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    Count: Word;
    {$ifdef FPC}
    Classes: array[Word] of TClass;
    {$else .DELPHI}
    ClassRef: array[Word] of ^TClass;
    property Classes[const AIndex: Word]: TClass read GetClass;
    {$endif}
  end;

  PVmtFieldEntry = ^TVmtFieldEntry;
  TVmtFieldEntry = packed object
  protected
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    FieldOffset: InternalUInt;
    TypeIndex: Word; // index into ClassTab
    Name: ShortStringHelper;
    property Tail: Pointer read GetTail;
  end;

  PVmtFieldTable = ^TVmtFieldTable;
  TVmtFieldTable = packed object
  protected
    function GetTail: Pointer;
  public
    Count: Word; // Published fields
    ClassTab: PVmtFieldClassTab;
    Entries: TVmtFieldEntry;
    {Entries: array[1..Count] of TVmtFieldEntry;
    Tail: TVmtFieldTableEx;}
    property Tail: Pointer read GetTail;
  end;

  PVmtMethodEntry = ^TVmtMethodEntry;
  TVmtMethodEntry = packed object
  protected
    {$ifdef EXTENDEDRTTI}
    function GetSignature: PVmtMethodSignature; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Len: Word;
    CodeAddress: Pointer;
    Name: ShortStringHelper;
    {Signature: TVmtMethodSignature;} // only exists if Len indicates data here
    {$ifdef EXTENDEDRTTI}
    property Signature: PVmtMethodSignature read GetSignature;
    {$endif}
    property Tail: Pointer read GetTail;
  end;

  PVmtMethodTable = ^TVmtMethodTable;
  TVmtMethodTable = packed object
  protected
    function GetTail: Pointer;
  public
    Count: Word;
    Entries: TVmtMethodEntry;
    {Entries: array[1..Count] of TVmtMethodEntry;
    Tail: TVmtMethodTableEx;}
    property Tail: Pointer read GetTail;
  end;

  PIntfMethodParamTail = ^TIntfMethodParamTail;
  TIntfMethodParamTail = packed object
  protected
    {$ifdef EXTENDEDRTTI}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    ParamType: PTypeInfoRef;
    {$ifdef EXTENDEDRTTI}
    AttrDataRec: TAttrData; // not currently entered
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;

  PIntfMethodParam = ^TIntfMethodParam;
  TIntfMethodParam = packed object
  protected
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

  PIntfMethodSignature = ^TIntfMethodSignature;
  TIntfMethodSignature = packed object
  protected
    function GetParamsTail: PByte;
    function GetResultData: TResultData;
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData;
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
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

  PIntfMethodEntryTail = ^TIntfMethodEntryTail;
  TIntfMethodEntryTail = packed object(TIntfMethodSignature) end;

  PIntfMethodEntry = ^TIntfMethodEntry;
  TIntfMethodEntry = packed object
  protected
    function GetSignature: PIntfMethodSignature; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Name: ShortStringHelper;
    {Signature: TIntfMethodSignature;}
    property Signature: PIntfMethodSignature read GetSignature;
    property Tail: Pointer read GetTail;
  end;

  PIntfMethodTable = ^TIntfMethodTable;
  TIntfMethodTable = packed object
  protected
    function GetHasEntries: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData;
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
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

  {$if Defined(FPC) or Defined(EXTENDEDRTTI)}
  PProcedureParam = ^TProcedureParam;
  TProcedureParam = packed object
  protected
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function GetData: TArgumentData;
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
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

  PProcedureSignature = ^TProcedureSignature;
  TProcedureSignature = packed object
  protected
    function GetIsValid: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetResultData: TResultData;
    function GetTail: Pointer;
  public
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
  {$ifend .FPC.EXTENDEDRTTI}

  {$ifdef EXTENDEDRTTI}
  PPropInfoEx = ^TPropInfoEx;
  TPropInfoEx = packed object
  protected
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Flags: Byte;
    Info: PPropInfo;
    AttrDataRec: TAttrData;
    property AttrData: PAttrData read GetAttrData;
    property Tail: Pointer read GetTail;
  end;

  PPropDataEx = ^TPropDataEx;
  TPropDataEx = packed object
  protected
    function GetTail: Pointer;
  public
    PropCount: Word;
    PropList: TPropInfoEx;
    {PropList: array[1..PropCount] of TPropInfoEx;}
    property Tail: Pointer read GetTail;
  end;

  PArrayPropInfo = ^TArrayPropInfo;
  TArrayPropInfo = packed object
  protected
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Flags: Byte;
    ReadIndex: Word;
    WriteIndex: Word;
    Name: ShortStringHelper;
    {AttrData: TAttrData;}
    property AttrData: PAttrData read GetAttrData;
    property Tail: Pointer read GetTail;
  end;

  PArrayPropData = ^TArrayPropData;
  TArrayPropData = packed object
  protected
    function GetTail: Pointer;
  public
    Count: Word;
    PropData: TArrayPropInfo;
    {PropData: array[1..Count] of TArrayPropInfo;}
    property Tail: Pointer read GetTail;
  end;

  PVmtFieldExEntry = ^TVmtFieldExEntry;
  TVmtFieldExEntry = packed object
  protected
    function GetVisibility: TMemberVisibility; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetValue: TFieldData;
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
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

  PFieldExEntry = ^TFieldExEntry;
  TFieldExEntry = packed object(TVmtFieldExEntry) end;

  PVmtFieldTableEx = ^TVmtFieldTableEx;
  TVmtFieldTableEx = packed object
    Count: Word;
    Entries: TVmtFieldExEntry;
    {Entries: array[1..Count] of TVmtFieldExEntry;}
  end;

  PVmtMethodParam = ^TVmtMethodParam;
  TVmtMethodParam = packed object
  protected
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetData: TArgumentData;
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
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

  TVmtMethodSignature = packed object
  protected
    function GetAttrDataRec: PAttrData;
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure InternalGetResultData(var AResult: TResultData; const AHasResultParam: Integer);
    function GetResultData: TResultData;
  public
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

  PVmtMethodEntryTail = ^TVmtMethodEntryTail;
  TVmtMethodEntryTail = packed object(TVmtMethodSignature) end;

  PVmtMethodExEntry = ^TVmtMethodExEntry;
  TVmtMethodExEntry = packed object
  protected
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

  PVmtMethodTableEx = ^TVmtMethodTableEx;
  TVmtMethodTableEx = packed object
  protected
    function GetVirtualCount: Word; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Count: Word;
    Entries: array[Word] of TVmtMethodExEntry;
    {VirtualCount: Word;}
    property VirtualCount: Word read GetVirtualCount;
  end;

  PRecordTypeOptions = ^TRecordTypeOptions;
  TRecordTypeOptions = packed object
  protected
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Count: Byte;
    Values: array[Byte] of Pointer;
    property Tail: Pointer read GetTail;
  end;

  PRecordTypeField = ^TRecordTypeField;
  TRecordTypeField = packed object
  protected
    function GetVisibility: TMemberVisibility; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetFieldData: TFieldData;
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Field: TManagedField;
    Flags: Byte;
    Name: ShortStringHelper;
    {AttrData: TAttrData;}
    property Visibility: TMemberVisibility read GetVisibility;
    property AttrData: PAttrData read GetAttrData;
    property FieldData: TFieldData read GetFieldData;
    property Tail: Pointer read GetTail;
  end;

  PRecordTypeFields = ^TRecordTypeFields;
  TRecordTypeFields = packed object
  protected
    function GetTail: Pointer;
  public
    Count: Integer;
    Fields: TRecordTypeField;
    {Fields: array[1..Count] of TRecordTypeField;}
    property Tail: Pointer read GetTail;
  end;

  PRecordTypeMethod = ^TRecordTypeMethod;
  TRecordTypeMethod = packed object
  protected
    function GetMemberVisibility: TMemberVisibility; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetMethodKind: TMethodKind; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetSignature: PProcedureSignature; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
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

  PRecordTypeMethods = ^TRecordTypeMethods;
  TRecordTypeMethods = packed object
  protected
    function GetTail: Pointer;
  public
    Count: Word;
    Methods: TRecordTypeMethod;
    {Methods: array[1..Count] of TRecordTypeMethod;}
    property Tail: Pointer read GetTail;
  end;
  {$endif .EXTENDEDRTTI}

  PEnumerationTypeData = ^TEnumerationTypeData;
  TEnumerationTypeData = packed object
  protected
    function GetCount: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetEnumName(const AValue: Integer): PShortStringHelper;
    function GetEnumValue(const AName: ShortString): Integer;
    function GetUnitName: PShortStringHelper;
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    OrdType: TOrdType;
    MinValue: Integer;
    MaxValue: Integer;
    BaseType: PTypeInfoRef;
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

  PSetTypeData = ^TSetTypeData;
  TSetTypeData = packed object
  protected
    {$ifdef EXTENDEDRTTI}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    function GetSize: Integer;
    function GetAdjustment: Integer;
  public
    SetTypeOrSize: Byte;
    CompType: PTypeInfoRef;
    {$ifdef EXTENDEDRTTI}
    AttrDataRec: TAttrData;
    {// Tokyo +
     SetLoByte: Byte;
     SetSize: Byte;}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
    property Size: Integer{Byte or -1} read GetSize;
    property Adjustment: Integer{Byte or -1} read GetAdjustment;
  end;

  PMethodParam = ^TMethodParam;
  TMethodParam = packed object
  protected
    function GetTypeName: PShortStringHelper; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    Flags: TParamFlags;
    ParamName: ShortStringHelper;
    {TypeName: ShortStringHelper;}
    property TypeName: PShortStringHelper read GetTypeName;
    property Tail: Pointer read GetTail;
  end;

  PMethodSignature = ^TMethodSignature;
  TMethodSignature = packed object
  protected
    function GetParamsTail: Pointer;
    function InternalGetResultData(const APtr: PByte; var AResult: TResultData): PByte;
    function GetResultData: TResultData;
    function GetResultTail: Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCallConv: TCallConv; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetParamTypes: PPTypeInfoRef; {$ifdef INLINESUPPORT}inline;{$endif}
  public
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

  PMethodTypeData = ^TMethodTypeData;
  TMethodTypeData = packed object(TMethodSignature)
  {$ifdef EXTENDEDRTTI}
  protected
    function GetSignature: PProcedureSignature; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    property Signature: PProcedureSignature read GetSignature;
    property AttrData: PAttrData read GetAttrData;
  {$endif}
  end;

  PClassTypeData = ^TClassTypeData;
  TClassTypeData = packed object
  protected
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
    ClassType: TClass;
    ParentInfo: PTypeInfoRef;
    PropCount: SmallInt;
    UnitName: ShortStringHelper;
    {PropData: TPropData;
    // extended rtti
    PropDataEx: TPropDataEx;
    ClassAttrData: TAttrData;
    ArrayPropCount: Word;
    ArrayPropData: array[1..ArrayPropCount] of TArrayPropInfo;}
    function VmtFunctionOffset(const AAddress: Pointer; const AStandardFunctions: Boolean = True): NativeInt{-1 means fail};
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

  PInterfaceTypeData = ^TInterfaceTypeData;
  TInterfaceTypeData = packed object
  protected
    function GetMethodTable: PIntfMethodTable; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
    Parent: PTypeInfoRef; { ancestor }
    Flags: TIntfFlags;
    Guid: TGUID;
    UnitName: ShortStringHelper;
    {IntfMethods: TIntfMethodTable;
    IntfAttrData: TAttrData;}
    property MethodTable: PIntfMethodTable read GetMethodTable;
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;

  PDynArrayTypeData = ^TDynArrayTypeData;
  TDynArrayTypeData = packed object
  protected
    function GetArrElType: PTypeInfo; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
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
    UnitName: ShortStringHelper;
    {DynArrElType: PTypeInfoRef; // actual element type, even if dynamic array
    DynArrAttrData: TAttrData;}
    property ArrElType: PTypeInfo read GetArrElType;
    {$ifdef EXTENDEDRTTI}
    property AttrData: PAttrData read GetAttrData;
    {$endif}
  end;

  PArrayTypeData = ^TArrayTypeData;
  TArrayTypeData = packed object
  protected
    {$ifdef EXTENDEDRTTI}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
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

  PRecordTypeData = ^TRecordTypeData;
  TRecordTypeData = packed object
  protected
    {$ifdef EXTENDEDRTTI}
    function GetOptions: PRecordTypeOptions; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetFields: PRecordTypeFields; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrDataRec: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAttrData: PAttrData; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetMethods: PRecordTypeMethods; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
  public
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
          tkRecord: (RecordData: TRecordTypeData);
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
                NameList: ShortStringHelper;
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
        UnitName: ShortStringHelper;
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
        IntfFlags: TIntfFlags;
        Guid: TGUID;
        IntfUnit: ShortStringHelper;
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
        DynUnitName: ShortStringHelper;
        {DynArrElType: PTypeInfoRef; // actual element type, even if dynamic array
        DynArrAttrData: TAttrData;});
      tkArray: (
        ArrayData: TArrayTypeData;
        {ArrAttrData: TAttrData;});
      tkRecord: ( {RecordData: TRecordTypeData;}
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
      {$ifdef EXTENDEDRTTI}
      tkClassRef: (
        InstanceType: PTypeInfoRef;
        ClassRefAttrData: TAttrData;);
      tkPointer: (
        RefType: PTypeInfoRef;
        PtrAttrData: TAttrData;);
      tkProcedure: (
        ProcSig: PProcedureSignature;
        ProcAttrData: TAttrData;);
      {$endif}
      {$ifdef FPC}
      tkHelper: (
        HelperParent: PTypeInfo;
        ExtendedInfo: PTypeInfo;
        HelperProps: SmallInt;
        HelperUnit: ShortStringHelper;
        {here the properties follow as array of TPropInfo});
      tkProcVar: (
        ProcSig: TProcedureSignature);
      tkQWord: (
        MinQWordValue, MaxQWordValue: QWord);
      tkInterfaceRaw: (
        RawIntfParent: PTypeInfoRef;
        RawIntfFlags: TIntfFlags;
        IID: TGUID;
        RawIntfUnit: ShortStringHelper;
        IIDStr: ShortStringHelper;);
      {$endif}
  end;


{ UniConv aliases
  More details: https://github.com/d-mozulyov/UniConv}


{$ifdef UNICODE}
var
  _utf8_equal_utf8_ignorecase: function(S1: PUTF8Char; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): Boolean;
{$endif}


{ Universal RTTI types }

type
  PRttiHFA = ^TRttiHFA;
  TRttiHFA = (hfaNone, hfaSingle1, hfaDouble1, hfaSingle2, hfaDouble2,
    hfaSingle3, hfaDouble3, hfaSingle4, hfaDouble4);
  PRttiHFAs = ^TRttiHFAs;
  TRttiHFAs = set of TRttiHFA;

  PRttiCallConv = ^TRttiCallConv;
  TRttiCallConv = (rcRegister, rcCdecl, rcPascal, rcStdCall, rcSafeCall,
    // https://clang.llvm.org/docs/AttributeReference.html#calling-conventions
    rcVectorPCV,
    rcFastCall,
    rcWindows,
    rcPCV,
    rcPreserveAll,
    rcPreserveMost,
    rcRegisterAll,
    rcRegister1, rcRegister2, rcRegister3, {regparm(N)}
    rcThisCall,
    rcVectorCall
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
    {000} rgVariant,
    {011} rgFunction,
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
    {002} rtBoolean,
    {003} rtBoolean16,
    {004} rtBoolean32,
    {005} rtBoolean64,
    {006} rtByteBool,
    {007} rtWordBool,
    {008} rtLongBool,
    {009} rtQWordBool,
    // rgOrdinal
    {010} rtByte,
    {011} rtShortInt,
    {012} rtWord,
    {013} rtSmallInt,
    {014} rtCardinal,
    {015} rtInteger,
    {016} rtUInt64,
    {017} rtInt64,
    // rgFloat
    {018} rtComp,
    {019} rtCurrency,
    {020} rtSingle,
    {021} rtDouble,
    {022} rtExtended,
    // rgDateTime
    {023} rtDate,
    {024} rtTime,
    {025} rtDateTime,
    {026} rtTimeStamp,
    // rgString
    {027} rtSBCSChar,
    {028} rtUTF8Char,
    {029} rtWideChar,
    {020} rtShortString,
    {031} rtSBCSString,
    {032} rtUTF8String,
    {033} rtWideString,
    {034} rtUnicodeString,
    {035} rtUCS4String,
    // rgEnumeration
    {036} rtEnumeration,
    // rgMetaType
    {037} rtSet,
    {038} rtRecord,
    {039} rtStaticArray,
    {030} rtDynamicArray,
    {041} rtObject,
    {042} rtInterface,
    // rgMetaTypeRef
    {043} rtClassRef,
    // rgVariant
    {044} rtBytes,
    {045} rtVariant,
    {046} rtOleVariant,
    {047} rtVarRec,
    // rgFunction
    {048} rtFunction,
    {049} rtMethod,
    {050} rtClosure,
    // Reserved
    {051} rt051, {052} rt052, {053} rt053, {054} rt054, {055} rt055,
    {056} rt056, {057} rt057, {058} rt058, {059} rt059, {060} rt060, {061} rt061, {062} rt062, {063} rt063,
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

  PRttiFlag = ^TRttiFlag;
  TRttiFlag = (_);
  PRttiFlags = ^TRttiFlags;
  TRttiFlags = set of TRttiFlag;

  PRttiRules = ^TRttiRules;
  TRttiRules = packed object
    Size: Cardinal;
    StackSize: Byte;
    HFA: TRttiHFA;
    Flags: TRttiFlags;
  end;

  PRttiRangeData = ^TRttiRangeData;
  TRttiRangeData = packed object
  protected
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

  PRttiEnumerationData = ^TRttiEnumerationData;
  TRttiEnumerationData = packed object(TRttiRangeData)
  protected
    FBaseType: PTypeInfoRef;
  public
    NameList: ShortStringHelper;
  end;

  PRttiExTypeData = ^TRttiExTypeData;
  TRttiExTypeData = packed object
    // ToDo
  end;

  PRttiMetaType = ^TRttiMetaType;
  TRttiMetaType = packed object(TRttiExTypeData)
    // ToDo
  end;

  PRttiExType = ^TRttiExType;
  TRttiExType = packed object
  protected
    F: packed record
    case Integer of
      0: (
        Base: TRttiType;
        PointerDepth: Byte;
        case Integer of
          0: (Id: Word);
          1: (CodePage: Word);
          2: (MaxLength: Byte; Flags: Byte);
          3: (ExFlags: Word);
          High(Integer): (_: packed record end;));
      1: (
        Options: Cardinal;
        case Integer of
          0: (Data: Pointer);
          1: (TypeData: PTypeData);
          2: (RangeData: PRttiRangeData);
          3: (EnumerationData: PRttiEnumerationData);
          4: (MetaType: PRttiMetaType);
          High(Integer): (__: packed record end;));
    end;
    function GetTempRules: PRttiRules;
    function GetRules: PRttiRules; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    property Base: TRttiType read F.Base write F.Base;
    property PointerDepth: Byte read F.PointerDepth write F.PointerDepth;
    property Id: Word read F.Id write F.Id;
    property CodePage: Word read F.CodePage write F.CodePage;
    property MaxLength: Byte read F.MaxLength write F.MaxLength;
    property Flags: Byte read F.Flags write F.Flags;
    property ExFlags: Word read F.ExFlags write F.ExFlags;
    property Options: Cardinal read F.Options write F.Options;
    property Rules: PRttiRules read GetRules;

    property Data: Pointer read F.Data write F.Data;
    property TypeData: PTypeData read F.TypeData write F.TypeData;
    property RangeData: PRttiRangeData read F.RangeData write F.RangeData;
    property EnumerationData: PRttiEnumerationData read F.EnumerationData write F.EnumerationData;
    property MetaType: PRttiMetaType read F.MetaType write F.MetaType;
  end;


var
  RTTI_TYPE_GROUPS: array[TRttiType] of TRttiTypeGroup = (
    // rgUnknown
    {000} rgUnknown, // rtUnknown,
    // rgPointer
    {001} rgPointer, // rtPointer,
    // rgBoolean
    {002} rgBoolean, // rtBoolean,
    {003} rgBoolean, // rtBoolean16,
    {004} rgBoolean, // rtBoolean32,
    {005} rgBoolean, // rtBoolean64,
    {006} rgBoolean, // rtByteBool,
    {007} rgBoolean, // rtWordBool,
    {008} rgBoolean, // rtLongBool,
    {009} rgBoolean, // rtQWordBool,
    // rgOrdinal
    {010} rgOrdinal, // rtByte,
    {011} rgOrdinal, // rtShortInt,
    {012} rgOrdinal, // rtWord,
    {013} rgOrdinal, // rtSmallInt,
    {014} rgOrdinal, // rtCardinal,
    {015} rgOrdinal, // rtInteger,
    {016} rgOrdinal, // rtUInt64,
    {017} rgOrdinal, // rtInt64,
    // rgFloat
    {018} rgFloat, // rtComp,
    {019} rgFloat, // rtCurrency,
    {020} rgFloat, // rtSingle,
    {021} rgFloat, // rtDouble,
    {022} rgFloat, // rtExtended,
    // rgDateTime
    {023} rgDateTime, // rtDate,
    {024} rgDateTime, // rtTime,
    {025} rgDateTime, // rtDateTime,
    {026} rgDateTime, // rtTimeStamp,
    // rgString
    {027} rgString, // rtSBCSChar,
    {028} rgString, // rtUTF8Char,
    {029} rgString, // rtWideChar,
    {020} rgString, // rtShortString,
    {031} rgString, // rtSBCSString,
    {032} rgString, // rtUTF8String,
    {033} rgString, // rtWideString,
    {034} rgString, // rtUnicodeString,
    {035} rgString, // rtUCS4String,
    // rgEnumeration
    {036} rgEnumeration, // rtEnumeration,
    // rgMetaType
    {037} rgMetaType, // rtSet,
    {038} rgMetaType, // rtRecord,
    {039} rgMetaType, // rtStaticArray,
    {030} rgMetaType, // rtDynamicArray,
    {041} rgMetaType, // rtObject,
    {042} rgMetaType, // rtInterface,
    // rgMetaTypeRef
    {043} rgMetaTypeRef, // rtClassRef,
    // rgVariant
    {044} rgVariant, // rtBytes,
    {045} rgVariant, // rtVariant,
    {046} rgVariant, // rtOleVariant,
    {047} rgVariant, // rtVarRec,
    // rgFunction
    {048} rgFunction, // rtFunction,
    {049} rgFunction, // rtMethod,
    {050} rgFunction, // rtClosure,
    // Reserved
    {051} rgUnknown,
    {052} rgUnknown, {053} rgUnknown, {054} rgUnknown, {055} rgUnknown, {056} rgUnknown, {057} rgUnknown,
    {058} rgUnknown, {059} rgUnknown, {060} rgUnknown, {061} rgUnknown, {062} rgUnknown, {063} rgUnknown,
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


const

{ Dummy type information
  "TypeInfo" equivalents that can be used within the rtti context to define TRttiType and TRttiExType
  First of all, for FreePascal and old Delphi versions, where, for example, there is no TypeInfo for TClass, Pointer, procedures
  Consists of (can be created using the DummyTypeInfo function):
    DUMMY_TYPEINFO_BASE
    PointerDepth: 0..15
    RttiType: TRttiType
    Id/CodePage: Word}

  DUMMY_TYPEINFO_BASE = NativeUInt(NativeInt(Integer($70000000)));
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
  TYPEINFO_PANSICHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtSBCSChar) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_PUTF8CHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtUTF8Char) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_PWIDECHAR = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtWideChar) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_ANSISTRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtSBCSString) shl 16);
  TYPEINFO_UTF8STRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtUTF8String) shl 16);
  TYPEINFO_SHORTSTRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtShortString) shl 16);
  TYPEINFO_PANSISTRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtSBCSString) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_PUTF8STRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtUTF8String) shl 16 + DUMMY_TYPEINFO_PTR + 65001);
  TYPEINFO_PSHORTSTRING = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtShortString) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_ENUMERATION = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtEnumeration) shl 16);
  TYPEINFO_PENUMERATION = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtEnumeration) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_SET = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtSet) shl 16);
  TYPEINFO_PSET = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtSet) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_RECORD = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtRecord) shl 16);
  TYPEINFO_PRECORD = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtRecord) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_STATICARRAY = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtStaticArray) shl 16);
  TYPEINFO_PSTATICARRAY = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtStaticArray) shl 16 + DUMMY_TYPEINFO_PTR);
  TYPEINFO_DYNAMICARRAY = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtDynamicArray) shl 16);
  TYPEINFO_PDYNAMICARRAY = Pointer(DUMMY_TYPEINFO_BASE + NativeUInt(rtDynamicArray) shl 16 + DUMMY_TYPEINFO_PTR);
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

  PRttiContext = ^TRttiContext;
  TRttiContext = packed object
  protected
    function GetBaseTypeInfo(const ATypeInfo: PTypeInfo; const ATypeInfoList: array of PTypeInfo): Integer;
    function GetBooleanType(const ATypeInfo: PTypeInfo): TRttiType;
    {$ifdef EXTENDEDRTTI}
    function IsClosureType(const ATypeData: PTypeData): Boolean;
    {$endif}
  public
    procedure Init;

    function GetType(const ATypeInfo: Pointer): TRttiType;
    function GetExType(const ATypeInfo: Pointer): TRttiExType;
  end;


{ RTTI helpers? }

function DummyTypeInfo(const ARttiType: TRttiType;
  const APointerDepth: Byte = 0; const AId: Word = 0): Pointer;

function RttiTypeGroupCurrent: TRttiTypeGroup;
function RttiTypeGroupAdd: TRttiTypeGroup;
function RttiTypeCurrent: TRttiType;
function RttiTypeAdd(const AGroup: TRttiTypeGroup): TRttiType;

function RttiAlloc(const ASize: Integer): Pointer;



{ System.TypInfo/System.Rtti helpers }

procedure CopyRecord(Dest, Source, TypeInfo: Pointer); {$if Defined(FPC) or (not Defined(CPUINTEL))}inline;{$ifend}
{$if Defined(FPC) or (CompilerVersion <= 20)}
procedure CopyArray(Dest, Source, TypeInfo: Pointer; Count: NativeUInt);
procedure InitializeArray(Source, TypeInfo: Pointer; Count: NativeUInt);
procedure FinalizeArray(Source, TypeInfo: Pointer; Count: NativeUInt);
{$ifend}

function GetTypeName(const ATypeInfo: PTypeInfo): PShortStringHelper; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
function GetTypeData(const ATypeInfo: PTypeInfo): PTypeData; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
function GetEnumName(const ATypeInfo: PTypeInfo; const AValue: Integer): PShortStringHelper;
function GetEnumValue(const ATypeInfo: PTypeInfo; const AName: ShortString): Integer;
function IsManaged(const ATypeInfo: PTypeInfo): Boolean;
function HasWeakRef(const ATypeInfo: PTypeInfo): Boolean; {$if Defined(INLINESUPPORTSIMPLE) and not Defined(WEAKREF)}inline;{$ifend}


implementation

const
  CP_UTF8 = 65001;
  SHORTSTR_RESULT: array[0..6] of Byte = (6, Ord('R'), Ord('e'), Ord('s'), Ord('u'), Ord('l'), Ord('t'));
  REFERENCED_TYPE_KINDS = [{$ifdef WEAKINSTREF}tkClass, tkMethod,{$endif} {$ifdef WEAKREF}tkInterface{$endif}];


{ Default code page }

var
  DefaultCP: Word;

{$if Defined(MSWINDOWS)}
function GetACP: Cardinal; external 'kernel32.dll' name 'GetACP';
{$elseif Defined(FPC)}
type
  TCodePageMapEntry = record
    LocaleName: string;
    CodePage: Cardinal;
  end;

const
  // Predefined set of Name <=> CP mappings for POSIX
  CodePageMapA: array[0..2] of TCodePageMapEntry = (
    (LocaleName: 'ar'; CodePage: 1256),
    (LocaleName: 'az-cyrl'; CodePage: 1251),
    (LocaleName: 'az-latn'; CodePage: 1254));

  CodePageMapBC: array[0..2] of TCodePageMapEntry = (
    (LocaleName: 'be'; CodePage: 1251),
    (LocaleName: 'bg'; CodePage: 1251),
    (LocaleName: 'cs'; CodePage: 1250));

  CodePageMapEF: array[0..2] of TCodePageMapEntry = (
    (LocaleName: 'el'; CodePage: 1253),
    (LocaleName: 'et'; CodePage: 1257),
    (LocaleName: 'fa'; CodePage: 1256));

  CodePageMapH: array[0..2] of TCodePageMapEntry = (
    (LocaleName: 'he'; CodePage: 1255),
    (LocaleName: 'hr'; CodePage: 1250),
    (LocaleName: 'hu'; CodePage: 1250));

  CodePageMapJK: array[0..2] of TCodePageMapEntry = (
    (LocaleName: 'ja'; CodePage: 932),
    (LocaleName: 'kk'; CodePage: 1251),
    (LocaleName: 'ko'; CodePage: 949));

  CodePageMapLM: array[0..2] of TCodePageMapEntry = (
    (LocaleName: 'lt'; CodePage: 1257),
    (LocaleName: 'lv'; CodePage: 1257),
    (LocaleName: 'mk'; CodePage: 1251));

  CodePageMapP: array[0..1] of TCodePageMapEntry = (
    (LocaleName: 'pa-arab'; CodePage: 1256),
    (LocaleName: 'pl'; CodePage: 1250));

  CodePageMapR: array[0..1] of TCodePageMapEntry = (
    (LocaleName: 'ro'; CodePage: 1250),
    (LocaleName: 'ru'; CodePage: 1251));

  CodePageMapS: array[0..4] of TCodePageMapEntry = (
    (LocaleName: 'sk'; CodePage: 1250),
    (LocaleName: 'sl'; CodePage: 1250),
    (LocaleName: 'sq'; CodePage: 1250),
    (LocaleName: 'sr-cyrl'; CodePage: 1251),
    (LocaleName: 'sr-latn'; CodePage: 1250));

  CodePageMapT: array[0..1] of TCodePageMapEntry = (
    (LocaleName: 'th'; CodePage: 874),
    (LocaleName: 'tr'; CodePage: 1254));

  CodePageMapUV: array[0..5] of TCodePageMapEntry = (
    (LocaleName: 'uk'; CodePage: 1251),
    (LocaleName: 'ur'; CodePage: 1256),
    (LocaleName: 'uz-arab'; CodePage: 1256),
    (LocaleName: 'uz-cyrl'; CodePage: 1251),
    (LocaleName: 'uz-latn'; CodePage: 1254),
    (LocaleName: 'vi'; CodePage: 1258));

  // Special case - needs full LANG_CNTRY to determine proper codepage
  CodePageMapZH: array[0..6] of TCodePageMapEntry = (
    (LocaleName: 'zh_cn'; CodePage: 936),
    (LocaleName: 'zh_hk'; CodePage: 950),
    (LocaleName: 'zh-hans_hk'; CodePage: 936),
    (LocaleName: 'zh_mo'; CodePage: 950),
    (LocaleName: 'zh-hans_mo'; CodePage: 936),
    (LocaleName: 'zh_sg'; CodePage: 936),
    (LocaleName: 'zh_tw'; CodePage: 950));

function GetPosixLocaleName: string;
{$IF defined(MACOS)}
var
  Locale: CFLocaleRef;
begin
  Locale := CFLocaleCopyCurrent;
  try
    Result := StringRefToString(CFLocaleGetIdentifier(Locale));
  finally
    CFRelease(Locale);
  end;
end;
{$ELSEIF defined(ANDROID)}
begin
  Result := GetAndroidLocaleName;
end;
{$ELSE !MACOS and !ANDROID}
var
  Env: PAnsiChar;
  I, Len: Integer;
begin
  Env := FpGetEnv('LANG');
  Result := '';
  if Assigned(Env) then
  begin
    // LANG environment variable is treated as 7-bit ASCII encoding
    Len := 0;
    while (Env[Len] <> #0) and (Env[Len] <> '.') do
      Inc(Len);

    SetLength(Result, Len);
    for I := 0 to Len - 1 do
      Result[I + 1] := Char(Ord(Env[I]));
  end;
end;
{$IFEND !MACOS and !ANDROID}

function GetACP: Cardinal;

  function FindCodePage(const Name: string; const Map: array of TCodePageMapEntry;
    var CodePage: Cardinal): Boolean;
  var
    I: Integer;
  begin
    for I := Low(Map) to High(Map) do
      if Map[I].LocaleName = Name then
      begin
        CodePage := Map[I].CodePage;
        Exit(True);
      end;
    Result := False;
  end;

var
  I: Integer;
  LName: string;
  LCodePage: Cardinal;
begin
  LName := GetPosixLocaleName;
  I := Low(string);
  while I <= High(LName) do
  begin
    if AnsiChar(LName[I]) in ['A'..'Z'] then         // do not localize
      Inc(LName[I], Ord('a') - Ord('A'))   // do not localize
    else if LName[I] = '_' then            // do not localize
    begin
      SetLength(LName, I - Low(string));
      Break;
    end;
    Inc(I);
  end;

  Result := 1252; // Default codepage
  if Length(LName) > 0 then
    case LName[Low(string)] of
      'a':
        if FindCodePage(LName, CodePageMapA, LCodePage) then
          Result := LCodePage;
      'b','c':
        if FindCodePage(LName, CodePageMapBC, LCodePage) then
          Result := LCodePage;
      'e','f':
        if FindCodePage(LName, CodePageMapEF, LCodePage) then
          Result := LCodePage;
      'h':
        if FindCodePage(LName, CodePageMapH, LCodePage) then
          Result := LCodePage;
      'j','k':
        if FindCodePage(LName, CodePageMapJK, LCodePage) then
          Result := LCodePage;
      'l','m':
        if FindCodePage(LName, CodePageMapLM, LCodePage) then
          Result := LCodePage;
      'p':
        if FindCodePage(LName, CodePageMapP, LCodePage) then
          Result := LCodePage;
      'r':
        if FindCodePage(LName, CodePageMapR, LCodePage) then
          Result := LCodePage;
      's':
        if FindCodePage(LName, CodePageMapS, LCodePage) then
          Result := LCodePage;
      't':
        if FindCodePage(LName, CodePageMapT, LCodePage) then
          Result := LCodePage;
      'u','v':
        if FindCodePage(LName, CodePageMapUV, LCodePage) then
          Result := LCodePage;
      'z':
        begin
          LName := GetPosixLocaleName;
          I := Low(string);
          while I <= High(LName) do
          begin
            if AnsiChar(LName[I]) in ['A'..'Z'] then         // do not localize
              Inc(LName[I], Ord('a') - Ord('A'))   // do not localize
            else if LName[I] = '@' then            // do not localize
            // Non Gregorian calendars include "@calendar=<calendar>" on MACOS
            begin
              SetLength(LName, I - Low(string));
              Break;
            end;
            Inc(I);
          end;
          if FindCodePage(LName, CodePageMapZH, LCodePage) then
            Result := LCodePage
          else if (Length(LName) >= 2) and (LName[Low(string) + 1] = 'h') then
            // Fallback for Chinese in countries other than cn, hk, mo, tw, sg
            Result := 936;
        end;
    end;
end;
{$ifend}

procedure InitDefaultCP;
begin
  DefaultCP := GetACP;
  if (DefaultCP = CP_UTF8) then
  begin
    DefaultCP := 1252;
  end;
end;


{ Dummy type information }

function DummyTypeInfo(const ARttiType: TRttiType;
  const APointerDepth: Byte = 0; const AId: Word = 0): Pointer;
begin
  if (APointerDepth > $0f) then
  begin
    System.Error(reRangeError);
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


{ Groups and types }

var
  TypeGroupCurrent: TRttiTypeGroup = rgFunction;
  TypeCurrent: TRttiType = rtClosure;

function RttiTypeGroupCurrent: TRttiTypeGroup;
begin
  Result := TypeGroupCurrent;
end;

function RttiTypeGroupAdd: TRttiTypeGroup;
begin
  Result := TypeGroupCurrent;

  if (Result = High(TRttiTypeGroup)) then
  begin
    System.Error(reIntOverflow);
  end;

  Inc(Result);
  TypeGroupCurrent := Result;
end;

function RttiTypeCurrent: TRttiType;
begin
  Result := TypeCurrent;
end;

function RttiTypeAdd(const AGroup: TRttiTypeGroup): TRttiType;
begin
  Result := TypeCurrent;

  if (Result = High(TRttiType)) then
  begin
    System.Error(reIntOverflow);
  end;

  if (Byte(AGroup) > Byte(TypeGroupCurrent)) then
  begin
    System.Error(reInvalidCast);
  end;

  Inc(Result);
  TypeCurrent := Result;
  RTTI_TYPE_GROUPS[Result] := AGroup;
end;


{ Effective 8 bytes aligned allocator }

var
  MemoryDefaultBuffer: array[0..8 * 1024 - 1] of Byte;
  MemoryCurrent, MemoryOverflow: PByte;
  MemoryBuffers: array of TBytes;

function RttiMemoryReserve(const ASize: NativeUInt): PByte;
const
  MAX_BUFFER_SIZE = 4 * 1024 * 1024 - 128;
var
  LBufferCount: NativeUInt;
  LBufferSize: NativeUInt;
begin
  LBufferCount := Length(MemoryBuffers);
  SetLength(MemoryBuffers, LBufferCount + 1);

  if (ASize > MAX_BUFFER_SIZE) then
  begin
    LBufferSize := ASize;
  end else
  begin
    LBufferSize := SizeOf(MemoryDefaultBuffer);
    while (LBufferSize < ASize) do
    begin
      LBufferSize := LBufferSize shl 1;
    end;
  end;

  SetLength(MemoryBuffers[LBufferCount], LBufferSize);
  Result := Pointer(MemoryBuffers[LBufferCount]);
  MemoryCurrent := Result;
  MemoryOverflow := Pointer(NativeUInt(Result) + LBufferSize);
end;

function RttiAlloc(const ASize: Integer): Pointer;
var
  LSize: NativeUInt;
  LPtr: PByte;
begin
  if (ASize <= 0) then
  begin
    Result := nil;
    Exit;
  end;

  LSize := Cardinal(ASize);
  LPtr := MemoryCurrent;
  if (not Assigned(LPtr)) then
  begin
    LPtr := @MemoryDefaultBuffer[Low(MemoryDefaultBuffer)];
    MemoryCurrent := LPtr;
    MemoryOverflow := Pointer(NativeUInt(LPtr) + SizeOf(MemoryDefaultBuffer));
  end;

  LPtr := Pointer((NativeInt(LPtr) + 7) and -8);
  Result := LPtr;
  Inc(LPtr, LSize);
  if (NativeUInt(LPtr) <= NativeUInt(MemoryOverflow)) then
  begin
    MemoryCurrent := LPtr;
    Exit;
  end;

  LPtr := RttiMemoryReserve(LSize + 7);
  LPtr := Pointer((NativeInt(LPtr) + 7) and -8);
  Result := LPtr;
  Inc(LPtr, LSize);
  MemoryCurrent := LPtr;
end;


{ System.TypInfo/System.Rtti helpers }

{$ifdef FPC}
function int_copy(Src, Dest, TypeInfo: Pointer): SizeInt; [external name 'FPC_COPY'];
procedure int_initialize(Data, TypeInfo: Pointer); [external name 'FPC_INITIALIZE'];
procedure int_finalize(Data, TypeInfo: Pointer); [external name 'FPC_FINALIZE'];
{$endif}

procedure CopyRecord(Dest, Source, TypeInfo: Pointer);
{$if Defined(FPC)}
begin
  int_copy(Source, Dest, TypeInfo);
end;
{$elseif Defined(CPUINTEL)}
asm
  jmp System.@CopyRecord
end;
{$else}
begin
  System.CopyArray(Dest, Source, TypeInfo, 1);
end;
{$ifend}

{$if Defined(FPC) or (CompilerVersion <= 20)}
procedure CopyArray(Dest, Source, TypeInfo: Pointer; Count: NativeUInt);
{$ifdef FPC}
var
  i, LItemSize: NativeInt;
  LItemDest, LItemSrc: Pointer;
begin
  LItemDest := Dest;
  LItemSrc := Source;

  case PTypeInfo(TypeInfo).Kind of
    tkVariant: LItemSize := SizeOf(Variant);
    tkLString, tkWString, tkInterface, tkDynArray, tkAString: LItemSize := SizeOf(Pointer);
      tkArray, tkRecord, tkObject: LItemSize := PTypeData(NativeUInt(TypeInfo) + PByte(@PTypeInfo(TypeInfo).Name)^).RecSize;
  else
    Exit;
  end;

  for i := 1 to Count do
  begin
    int_copy(LItemSrc, LItemDest, TypeInfo);

    Inc(NativeInt(LItemDest), LItemSize);
    Inc(NativeInt(LItemSrc), LItemSize);
  end;
end;
{$else}
asm
  cmp byte ptr [ecx], tkArray
  jne @1
  push eax
  push edx
    movzx edx, [ecx + TTypeInfo.Name]
    mov eax, [ecx + edx + 6]
    mov ecx, [ecx + edx + 10]
    mul Count
    mov ecx, [ecx]
    mov Count, eax
  pop edx
  pop eax
  @1:

  pop ebp
  jmp System.@CopyArray
end;
{$endif}

procedure InitializeArray(Source, TypeInfo: Pointer; Count: NativeUInt);
{$ifdef FPC}
var
  i, LItemSize: NativeInt;
  LItemPtr: Pointer;
begin
  LItemPtr := Source;

  case PTypeInfo(TypeInfo).Kind of
    tkVariant: LItemSize := SizeOf(Variant);
    tkLString, tkWString, tkInterface, tkDynArray, tkAString: LItemSize := SizeOf(Pointer);
      tkArray, tkRecord, tkObject: LItemSize := PTypeData(NativeUInt(TypeInfo) + PByte(@PTypeInfo(TypeInfo).Name)^).RecSize;
  else
    Exit;
  end;

  for i := 1 to Count do
  begin
    int_initialize(LItemPtr, TypeInfo);
    Inc(NativeInt(LItemPtr), LItemSize);
  end;
end;
{$else}
asm
  jmp System.@InitializeArray
end;
{$endif}

procedure FinalizeArray(Source, TypeInfo: Pointer; Count: NativeUInt);
{$ifdef FPC}
var
  i, LItemSize: NativeInt;
  LItemPtr: Pointer;
begin
  LItemPtr := Source;

  case PTypeInfo(TypeInfo).Kind of
    tkVariant: LItemSize := SizeOf(Variant);
    tkLString, tkWString, tkInterface, tkDynArray, tkAString: LItemSize := SizeOf(Pointer);
      tkArray, tkRecord, tkObject: LItemSize := PTypeData(NativeUInt(TypeInfo) + PByte(@PTypeInfo(TypeInfo).Name)^).RecSize;
  else
    Exit;
  end;

  for i := 1 to Count do
  begin
    int_finalize(LItemPtr, TypeInfo);
    Inc(NativeInt(LItemPtr), LItemSize);
  end;
end;
{$else}
asm
  jmp System.@FinalizeArray
end;
{$endif}
{$ifend}

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
    Result := -1;
  end;
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
    tkRecord{$ifdef FPC}, tkObject{$endif}:
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


{ TDynArrayRec }

{$ifdef FPC}
function TDynArrayRec.GetLength: NativeInt;
begin
  Result := High + 1;
end;

procedure TDynArrayRec.SetLength(const AValue: NativeInt);
begin
  High := AValue - 1;
end;
{$else .DELPHI}
function TDynArrayRec.GetHigh: NativeInt;
begin
  Result := Length - 1;
end;

procedure TDynArrayRec.SetHigh(const AValue: NativeInt);
begin
  Length := AValue + 1;
end;
{$endif}


{ TWideStrRec }

{$ifdef MSWINDOWS}
function TWideStrRec.GetLength: Integer;
begin
  Result := Size shr 1;
end;

procedure TWideStrRec.SetLength(const AValue: Integer);
begin
  Size := AValue + AValue;
end;
{$endif}


{ ShortStringHelper }

function ShortStringHelper.GetValue: Integer;
begin
  Result := Byte(Pointer(@Value)^);
end;

procedure ShortStringHelper.SetValue(const AValue: Integer);
begin
  Byte(Pointer(@Value)^) := AValue;
end;

function ShortStringHelper.GetAnsiValue: AnsiString;
var
  LCount: Integer;
begin
  LCount := Byte(Pointer(@Value)^);
  SetLength(Result, LCount);
  System.Move(Value[1], Pointer(Result)^, LCount);
end;

function ShortStringHelper.GetUTF8Value: UTF8String;
var
  LCount: Integer;
begin
  LCount := Byte(Pointer(@Value)^);
  SetLength(Result, LCount);
  System.Move(Value[1], Pointer(Result)^, LCount);
end;

function ShortStringHelper.GetUnicodeValue: UnicodeString;
{$ifdef UNICODE}
var
  LCount: Integer;
begin
  if (Byte(Pointer(@Value)^) = 0) then
  begin
    Result := '';
  end else
  begin
    LCount := {$ifdef MSWINDOWS}MultiByteToWideChar{$else}UnicodeFromLocaleChars{$endif}(CP_UTF8,
      0, Pointer(@Value[1]), Byte(Pointer(@Value)^), nil, 0);

    SetLength(Result, LCount);
    {$ifdef MSWINDOWS}MultiByteToWideChar{$else}UnicodeFromLocaleChars{$endif}(CP_UTF8, 0,
      Pointer(@Value[1]), Byte(Pointer(@Value)^), Pointer(Result), LCount);
  end;
end;
{$else .ANSI}
var
  i: Integer;
  LCount: Integer;
  LSource: PByte;
  LTarget: PWord;
begin
  LCount := Byte(Pointer(@Value)^);
  SetLength(Result, LCount);
  LSource := Pointer(@Value[1]);
  LTarget := Pointer(Result);
  for i := 1 to LCount do
  begin
    LTarget^ := LSource^;
    Inc(LSource);
    Inc(LTarget);
  end;
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
  System.Error(reRangeError);
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
  System.Move(LCurrent^, ABuffer, ASize);
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
      System.Error(reInvalidCast);
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
  System.Move(LPtr^, Result[1], LCount);
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
  System.Move(LPtr^, Pointer(Result)^, LCount);
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

  LTargetCount := {$ifdef MSWINDOWS}MultiByteToWideChar{$else}UnicodeFromLocaleChars{$endif}(CP_UTF8,
    0, Pointer(LPtr), LCount, nil, 0);

  SetLength(Result, LTargetCount);
  {$ifdef MSWINDOWS}MultiByteToWideChar{$else}UnicodeFromLocaleChars{$endif}(CP_UTF8, 0,
    Pointer(LPtr), LCount, Pointer(Result), LTargetCount);
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
      System.Error(reInvalidPtr);
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
      System.Error(reInvalidPtr);
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
    tkRecord: Result := LTypeData.RecordData.GetAttrDataRec;
  else
    Result := nil;
  end;

  if (Assigned(Result)) then
  begin
    case Result.Len of
      0, 1: System.Error(reInvalidPtr);
      2: Result := nil;
    end;
  end;
end;
{$endif}


{ PTypeInfoRef }

{$ifNdef INLINESUPPORT}
function PTypeInfoRef.GetAddress: Pointer;
begin
  Result := Self;
end;
{$endif}

function PTypeInfoRef.GetAssigned: Boolean;
begin
  Result := System.Assigned({$ifdef INLINESUPPORT}F.Address{$else}Self{$endif});
end;

{$ifNdef FPC}
function PTypeInfoRef.GetValue: PTypeInfo;
begin
  Result := Pointer({$ifdef INLINESUPPORT}F.Value{$else}Self{$endif});
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
  Reference := rfDefault;

  if (System.Assigned(AAttrData)) and (System.Assigned(TypeInfo)) and
    (TypeInfo.Kind in REFERENCED_TYPE_KINDS) then
  begin
    if (AAttrData.Reference = rfUnsafe) then
    begin
      Reference := rfUnsafe;
    end;
  end;
end;
{$endif}

function TResultData.GetAssigned: Boolean;
begin
  Result := System.Assigned(Name);
end;


{ TAttributedParamData }

{$ifdef WEAKREF}
procedure TAttributedParamData.InitReference;
begin
  Reference := rfDefault;

  if (System.Assigned(AttrData)) and (Assigned(TypeInfo)) and
    (TypeInfo.Kind in REFERENCED_TYPE_KINDS) then
  begin
    Reference := AttrData.Reference;
  end;
end;
{$endif}


{ TArgumentData }

{$ifdef WEAKREF}
procedure TArgumentData.InitReference;
begin
  if (pfConst in Flags) then
  begin
    Reference := rfDefault;
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
  Result.Name := @ParamName;
  Result.TypeInfo := ParamType;
  Result.TypeName := TypeName;
  Result.Flags := Flags;
  {$ifdef EXTENDEDRTTI}
  Result.AttrData := AttrData;
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
  Result.Reference := rfDefault;
  if (Kind = 1) then
  begin
    LPtr := GetParamsTail;
    Result.TypeName := PShortStringHelper(LPtr);
    if (Result.TypeName.Length <> 0) then
    begin
      LPtr := PShortStringHelper(LPtr).Tail;
      Result.TypeInfo := PTypeInfoRef(PPointer(LPtr)^).Value;
      Result.Name := PShortStringHelper(@SHORTSTR_RESULT);

      {$ifdef WEAKREF}
      {
        Attention!
        RTTI does not contain Result reference
        Therefore, the only correct way to specify unsafe result is this:
        [Result: Unsafe] function ...
      }
      if (Assigned(Result.TypeInfo)) and
        (Result.TypeInfo.Kind in REFERENCED_TYPE_KINDS) then
      begin
        Result.InitReference(AttrData);
      end;
      {$endif}

      Exit;
    end;
  end;

  Result.Name := nil;
  Result.TypeInfo := nil;
  Result.TypeName := nil;
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
  Result.Name := @Name;
  Result.TypeInfo := ParamType.Value;
  Result.TypeName := nil;
  Result.Flags := Flags;
  {$ifdef EXTENDEDRTTI}
  Result.AttrData := AttrData;
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
  Result.Reference := rfDefault;
  Result.TypeName := nil;
  Result.Name := nil;
  if (IsValid) then
  begin
    Result.TypeInfo := ResultType.Value;
    if (Assigned(Result.TypeInfo)) then
    begin
      Result.Name := PShortStringHelper(@SHORTSTR_RESULT);

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
    Result.TypeInfo := nil;
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
    AData.ArgumentCount := -1;
    Result := -1;
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
  Result.Name := @Name;
  Result.TypeInfo := TypeRef.Value;
  Result.TypeName := nil;
  Result.Visibility := Visibility;
  Result.AttrData := AttrData;
  {$ifdef WEAKREF}
  Result.InitReference;
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
  Result.Name := @Name;
  Result.TypeInfo := ParamType.Value;
  Result.TypeName := nil;
  Result.Flags := Flags;
  {$ifdef EXTENDEDRTTI}
  Result.AttrData := AttrData;
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
  AResult.Reference := rfDefault;
  AResult.TypeInfo := ResultType.Value;
  AResult.TypeName := nil;
  if (Assigned(AResult.TypeInfo)) then
  begin
    AResult.Name := PShortStringHelper(@SHORTSTR_RESULT);

    {$ifdef WEAKREF}
    if (AResult.TypeInfo.Kind in REFERENCED_TYPE_KINDS) then
    begin
      if (AHasResultParam >= 0) then
      begin
        if (AHasResultParam = 0) then
        begin
          AResult.Reference := rfUnsafe;
        end;
      end else
      begin
        AResult.Reference := rfUnsafe;
        LParam := @Params;
        for i := 0 to Integer(ParamCount) - 1 do
        begin
          if (pfResult in LParam.Flags) then
          begin
            AResult.Reference := rfDefault;
            Break;
          end;

          LParam := LParam.Tail;
        end;
      end;
    end;
    {$endif}
  end else
  begin
    AResult.Name := nil;
  end;
end;

function TVmtMethodSignature.GetResultData: TResultData;
begin
  InternalGetResultData(Result, -1);
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

  AData.ArgumentCount := -1;
  Result := -1;
end;


{ TVmtMethodTableEx }

function TVmtMethodTableEx.GetVirtualCount: Word;
begin
  Result := PWord(@Entries[Count])^;
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
  Result.Name := @Name;
  Result.TypeInfo := Field.TypeRef.Value;
  Result.TypeName := nil;
  Result.Visibility := Visibility;
  Result.Offset := Cardinal(Field.FldOffset);
  Result.AttrData := AttrData;
  {$ifdef WEAKREF}
  Result.InitReference;
  {$else}
  Result.Reference := rfDefault;
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

function TRecordTypeMethod.GetSignature: PProcedureSignature;
begin
  Result := Name.Tail;
end;

function TRecordTypeMethod.GetAttrDataRec: PAttrData;
begin
  Result := Signature.Tail;
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

  AData.ArgumentCount := -1;
  Result := -1;
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
  if (Assigned(_utf8_equal_utf8_ignorecase)) then
  begin
    Result := _utf8_equal_utf8_ignorecase(PUTF8Char(AStr1), ACount, PUTF8Char(AStr2), ACount);
  end else
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
end;
{$endif}

function TEnumerationTypeData.GetEnumValue(const AName: ShortString): Integer;
label
  failure;
var
  LCount, LTempCount: NativeUInt;
  LMaxResult: Integer;
  LSource, LTarget: PAnsiChar;
  LSourceChar, LTargetChar: Cardinal;
begin
  LSource := Pointer(@AName[0]);
  LCount := PByte(LSource)^;
  if (MinValue <> 0) or (LCount = 0) then
    goto failure;

  LMaxResult := MaxValue;
  LTarget := Pointer(@NameList);
  Result := -1;
  repeat
    Inc(Result);
    if (PByte(LTarget)^ = LCount) then
    begin
      repeat
        Inc(LSource);
        Inc(LTarget);
        if (LCount = 0) then Exit;

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
              Break;
          end;
        end
        {$ifdef UNICODE}
        else
        if (LSourceChar xor LTargetChar > $7f) then
        begin
          Break;
        end else
        begin
          Inc(LCount);
          LTempCount := LCount;
          Dec(LSource);
          Dec(LTarget);
          repeat
            Inc(LSource);
            Inc(LTarget);
            if (LCount = 0) then Exit;

            Dec(LCount);
            if (LSource^ <> LTarget^) then
              Break;
          until (False);

          Inc(LCount);
          Dec(NativeInt(LCount), NativeInt(LTempCount));
          Inc(LSource, NativeInt(LCount));
          Inc(LTarget, NativeInt(LCount));
          LCount := LTempCount;
          if (InternalUTF8CharsCompare(LSource, LTarget, LCount)) then
            Exit;

          Dec(LCount);
          Break;
        end
        {$endif}
        ;
      until (False);

      LSource := Pointer(@AName[0]);
      LTempCount := LCount;
      LCount := PByte(LSource)^;
      Dec(NativeInt(LTempCount), NativeInt(LCount));
      Inc(LTarget, NativeInt(LTempCount));
    end;

    LTarget := LTarget + PByte(LTarget)^ + 1;
  until (Result = LMaxResult);

failure:
  Result := -1;
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
    Result := -1;
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
    Result := -1;
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
  AResult.Reference := rfDefault;
  if (MethodKind <> mkFunction) then
  begin
    AResult.Name := nil;
    AResult.Reference := rfDefault;
    AResult.TypeInfo := nil;
    AResult.TypeName := nil;
    Result := APtr;
    Exit;
  end;

  LPtr := APtr;
  if (not Assigned(LPtr)) then
  begin
    LPtr := GetParamsTail;
  end;

  AResult.Name := PShortStringHelper(@SHORTSTR_RESULT);
  AResult.TypeName := Pointer(LPtr);
  LPtr := PShortStringHelper(LPtr).Tail;
  AResult.TypeInfo := PTypeInfoRef(PPointer(LPtr)^).Value;
  Inc(LPtr, SizeOf(Pointer));
  Result := LPtr;

  AResult.Reference := rfDefault;
  {$ifdef WEAKREF}
  {
    Attention!
    RTTI does not contain Result reference
    Therefore, the only correct way to specify unsafe result is this:
    [Unsafe] TMethodType = function ... unsafe of object;
  }
  if (Assigned(AResult.TypeInfo)) and
    (AResult.TypeInfo.Kind in REFERENCED_TYPE_KINDS) then
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
    Result := -1;
    AData.ArgumentCount := -1;
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
  LPtr := GetResultTail;
  Inc(LPtr, SizeOf(TCallConv));
  Inc(LPtr, NativeUInt(ParamCount) * SizeOf(PTypeInfoRef));
  Result := PPointer(LPtr)^;
end;

function TMethodTypeData.GetAttrDataRec: PAttrData;
var
  LPtr: PByte;
begin
  LPtr := GetResultTail;
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

  Result := -1;
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


{ TRttiRangeData }

function TRttiRangeData.GetCount: Cardinal;
begin
  Result := F.UHigh - F.ULow + 1;
end;

function TRttiRangeData.GetCount64: UInt64;
begin
  Result := F.U64High - F.U64Low + 1;
end;


{ TRttiExType }

function TRttiExType.GetTempRules: PRttiRules;
begin
  Result := nil;
end;

function TRttiExType.GetRules: PRttiRules;
begin
  Result := GetTempRules;
end;


{ TRttiContext }

procedure TRttiContext.Init;
begin
  FillChar(Self, SizeOf(Self), #0);
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

  Result := -1;
end;

function TRttiContext.GetBooleanType(const ATypeInfo: PTypeInfo): TRttiType;
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
      Result := rtBoolean;
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
    Result := rtBoolean;
  end else
  if (LTypeInfo = System.TypeInfo(ByteBool)) then
  begin
    Result := rtByteBool;
  end else
  if (LTypeInfo = System.TypeInfo(WordBool)) then
  begin
    Result := rtWordBool;
  end else
  if (LTypeInfo = System.TypeInfo(LongBool)) then
  begin
    Result := rtLongBool;
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
    Result := rtQWordBool;
  end else
  {$endif}
  begin
    LTypeData := GetTypeData(LTypeInfo);
    if (LTypeData.MinValue = 0) and (LTypeData.MaxValue = 1) then
    begin
      LPtr := Pointer(@LTypeInfo.Name);
      if (LPtr^ <> 4) then Exit;
      Inc(LPtr);
      if (LPtr^ <> Ord('b')) then Exit;
      Inc(LPtr);
      if (LPtr^ <> Ord('o')) then Exit;
      Inc(LPtr);
      if (LPtr^ <> Ord('o')) then Exit;
      Inc(LPtr);
      if (LPtr^ <> Ord('l')) then Exit;

      Result := rtBoolean;
    end;
  end;
end;

{$ifdef EXTENDEDRTTI}
function TRttiContext.IsClosureType(const ATypeData: PTypeData): Boolean;
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
{$endif}

function TRttiContext.GetType(const ATypeInfo: Pointer): TRttiType;
var
  LExType: TRttiExType;
begin
  LExType := GetExType(ATypeInfo);
  if (LExType.PointerDepth <> 0) then
  begin
    Result := rtPointer;
  end else
  begin
    Result := LExType.Base;
  end;
end;

function TRttiContext.GetExType(const ATypeInfo: Pointer): TRttiExType;
label
  detect_base_type, copy_type_data, string_post_processing, post_processing;
var
  LTypeInfo: PTypeInfo;
  LTypeData: PTypeData;
  {$ifNdef SHORTSTRSUPPORT}
  LCount: NativeUInt;
  LPtr: PByte;
  {$endif}
begin
  Result.Options := 0;
  Result.Data := nil;

  if (NativeUInt(ATypeInfo) <= High(Word)) then
  begin
    System.Error(reInvalidPtr);
    Exit;
  end;

  if (NativeUInt(ATypeInfo) >= DUMMY_TYPEINFO_BASE) then
  begin
    Result.PointerDepth := (NativeUInt(ATypeInfo) shr 24) and $0f;
    Result.Base := TRttiType(Byte(NativeUInt(ATypeInfo) shr 16));
    Result.Id := Word(NativeUInt(ATypeInfo));

    // ToDo Range
    case Result.Base of
      rtByte: ;
      rtShortInt: ;
      rtWord: ;
      rtSmallInt: ;
      rtCardinal: ;
      rtInteger: ;
      rtUInt64: ;
      rtInt64: ;
    end;
  end else
  (*if (False) then
  begin
    // MetaType check
    // ToDo
  end else*)
  begin
    LTypeInfo := ATypeInfo;
  detect_base_type:
    Result.Base := GetBooleanType(LTypeInfo);
    if (Result.Base = rtUnknown) then
    begin
      LTypeData := LTypeInfo.GetTypeData;

      case LTypeInfo.Kind of
        tkInteger:
        begin
          case LTypeData.OrdType of
            otSByte: Result.Base := rtShortInt;
            otSWord: Result.Base := rtSmallInt;
            otUWord: Result.Base := rtWord;
            otSLong: Result.Base := rtInteger;
            otULong: Result.Base := rtCardinal;
          else
            // otUByte
            Result.Base := rtByte;
            {$ifNdef ANSISTRSUPPORT}
            case GetBaseTypeInfo(LTypeInfo, [TypeInfo(AnsiChar), TypeInfo(UTF8Char)]) of
              0:
              begin
                Result.Base := rtSBCSChar;
                goto string_post_processing;
              end;
              1:
              begin
                Result.Base := rtUTF8Char;
                goto string_post_processing;
              end;
            end;
            {$endif}
          end;
          goto copy_type_data;
        end;
        {$ifdef FPC}
        tkQWord:
        begin
          Result.Base := rtUInt64;
          goto copy_type_data;
        end;
        {$endif}
        tkInt64:
        begin
          if (GetBaseTypeInfo(LTypeInfo, [TypeInfo(TimeStamp)]) = 0) then
          begin
            Result.Base := rtTimeStamp;
          end else
          if LTypeData.MinInt64Value > LTypeData.MaxInt64Value then
          begin
            Result.Base := rtUInt64;
            goto copy_type_data;
          end else
          begin
            Result.Base := rtInt64;
            goto copy_type_data;
          end;
        end;
        tkEnumeration:
        begin
          Result.Base := rtEnumeration;
          // 1, 2, 4?
          // ToDo
          goto copy_type_data;
        end;
        tkFloat:
        begin
          case LTypeData.FloatType of
            ftSingle: Result.Base := rtSingle;
            ftExtended: Result.Base := rtExtended;
            ftComp: Result.Base := rtComp;
            ftCurr: Result.Base := rtCurrency;
          else
            // ftDouble
            Result.Base := rtDouble;
            case GetBaseTypeInfo(LTypeInfo, [TypeInfo(TDate), TypeInfo(TTime), TypeInfo(TDateTime)]) of
              0: Result.Base := rtDate;
              1: Result.Base := rtTime;
              2: Result.Base := rtDateTime;
            end;
          end;
        end;
        tkChar:
        begin
          Result.Base := rtSBCSChar;
        end;
        tkWChar:
        begin
          Result.Base := rtWideChar;
        end;
        tkString:
        begin
          Result.Base := rtShortString; //1, 2, 4?
          Result.MaxLength := LTypeData.MaxLength;
        end;
        {$ifdef FPC}tkAString,{$endif}
        tkLString:
        begin
          Result.Base := rtSBCSString;
          {$ifdef INTERNALCODEPAGE}
            Result.CodePage := LTypeData.CodePage;
          {$else}
            case GetBaseTypeInfo(LTypeInfo, [TypeInfo(UTF8String), TypeInfo(RawByteString)]) of
              0:
              begin
                Result.Base := rtUTF8String;
              end;
              1:
              begin
                Result.Base := rtSBCSString;
                Result.CodePage := $ffff;
              end;
            end;
          {$endif}
        end;
        {$ifdef UNICODE}
        tkUString:
        begin
          Result.Base := rtUnicodeString;
        end;
        {$endif}
        tkWString:
        begin
          Result.Base := rtWideString;
        end;
        tkClass:
        begin
          Result.Base := rtObject;
          goto copy_type_data;
        end;
        tkVariant:
        begin
          if (LTypeInfo = TypeInfo(OleVariant)) then
          begin
            Result.Base := rtOleVariant;
          end else
          begin
            Result.Base := rtVariant;
          end;
        end;
        {$ifdef EXTENDEDRTTI}
        tkPointer:
        begin
          repeat
            Result.PointerDepth := Result.PointerDepth + 1;
            LTypeInfo := LTypeInfo.TypeData.RefType.Value;
            if (not Assigned(LTypeInfo)) or (LTypeInfo.Kind <> tkPointer) then
              Break;
          until (False);

          if (not Assigned(LTypeInfo)) then
          begin
            Result.PointerDepth := Result.PointerDepth - 1;
            Result.Base := rtPointer;
          end else
          begin
            goto detect_base_type;
          end;
        end;
        tkClassRef:
        begin
          Result.Base := rtClassRef;
          goto copy_type_data;
        end;
        tkProcedure:
        begin
          Result.Base := rtFunction;
          goto copy_type_data;
        end;
        {$endif}
        {$ifdef FPC}
        tkProcVar:
        begin
          Result.Base := rtFunction;
          goto copy_type_data;
        end;
        {$endif}
        tkSet:
        begin
          Result.Base := rtSet;
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
        tkRecord{$ifdef FPC}, tkObject{$endif}:
        begin
          Result.Base := rtRecord;
          goto copy_type_data;
        end;
        tkArray:
        begin
          Result.Base := rtStaticArray;

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
                  if (LPtr^ or $20 <> Ord('s')) then goto copy_type_data;
                  Inc(LPtr);
                  if (LPtr^ or $20 <> Ord('t')) then goto copy_type_data;
                  Inc(LPtr);
                  if (LPtr^ or $20 <> Ord('r')) then goto copy_type_data;
                  Inc(LPtr);
                  if (LPtr^ or $20 <> Ord('i')) then goto copy_type_data;
                  Inc(LPtr);
                  if (LPtr^ or $20 <> Ord('n')) then goto copy_type_data;
                  Inc(LPtr);
                  if (LPtr^ or $20 <> Ord('g')) then goto copy_type_data;
                  Inc(LPtr);

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
                Result.Base := rtShortString;
                Result.MaxLength := LCount;
                goto string_post_processing;
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
            0: Result.Base := rtBytes;
            1: Result.Base := rtUCS4String;
            {$ifNdef WIDESTRSUPPORT}
            2:
            begin
              Result.Base := rtWideString;
            end;
            {$endif !WIDESTRSUPPORT}
            {$ifNdef ANSISTRSUPPORT}
            {$ifNdef WIDESTRSUPPORT}2{$else}1{$endif} + 1:
            begin
              Result.Base := rtSBCSString;
            end;
            {$ifNdef WIDESTRSUPPORT}2{$else}1{$endif} + 2:
            begin
              Result.Base := rtUTF8String;
            end;
            {$ifNdef WIDESTRSUPPORT}2{$else}1{$endif} + 3:
            begin
              Result.Base := rtSBCSString;
              Result.CodePage := $ffff;
            end;
            {$endif !ANSISTRSUPPORT}
          else
            Result.Base := rtDynamicArray;
            goto copy_type_data;
          end;
        end;
        tkInterface:
        begin
          {$ifdef EXTENDEDRTTI}
          if (IsClosureType(LTypeData)) then
          begin
            Result.Base := rtClosure;
          end else
          {$endif}
          begin
            Result.Base := rtInterface;
          end;
          goto copy_type_data;
        end;
        tkMethod:
        begin
          Result.Base := rtMethod;
        copy_type_data:
          Result.Data := LTypeData;
        end;
      end;
    end;
  end;

string_post_processing:
  // ANSI/UTF8 routine
  case Result.Base of
    rtSBCSChar,
    rtSBCSString:
    begin
      case Result.CodePage of
        0:
        begin
          Result.CodePage := DefaultCP;
        end;
        CP_UTF8:
        begin
          Result.Base := Succ(Result.Base);
        end;
      end;
    end;
    rtUTF8Char,
    rtUTF8String:
    begin
      if (Result.CodePage = 0) then
      begin
        Result.CodePage := CP_UTF8;
      end;
    end;
  end;

post_processing:
  // post processing
  // ToDo
end;

initialization
  InitDefaultCP;

finalization
  MemoryBuffers := nil;

end.
