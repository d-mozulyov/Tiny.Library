unit Tiny.Types;

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
{$HPPEMIT '#if defined(__arm__) || defined(__arm64__) || (defined(_WIN64) && !defined(USEPACKAGES))'}
{$HPPEMIT '  #define HPP_DRECORD __declspec(delphirecord)'}
{$HPPEMIT '#else'}
{$HPPEMIT '  #define HPP_DRECORD __declspec(delphirecord, dllimport)'}
{$HPPEMIT '#endif'}
{$HPPEMIT '#define HPP_INHERIT(record, parent) record: parent /##/'}
{$HPPEMIT '#define HPP_RETRIEVE(parent) HPP_DRECORD'}
{$HPPEMIT '#undef EOF'}

interface
uses
  {$if Defined(FPC) and Defined(UNIX) and Defined(UseCThreads)}cthreads,{$ifend}
  {$if Defined(MSWINDOWS)}
    {$ifdef UNITSCOPENAMES}Winapi.Windows{$else}Windows{$endif}
  {$elseif Defined(FPC)}
    BaseUnix, Linux
  {$else DELPHI.POSIX}
    Posix.String_, Posix.SysTypes, Posix.Unistd, Posix.Time, Posix.Sched, Posix.Pthread
  {$ifend};


const

{ Common constants }

  PLATFORM_NAME =
    {$if Defined(MSWINDOWS)}
      'win'
    {$elseif Defined(ANDROID)}
      'android'
    {$elseif Defined(IOS)}
      'ios'
    {$elseif Defined(LINUX)}
      'linux'
    {$elseif Defined(MACOS)}
      'macos'
    {$else}
      {$MESSAGE ERROR 'Unknown platform'}
    {$ifend}
     + {$ifdef SMALLINT}'32'{$else .LARGEINT}'64'{$endif};
  PLATFORM_OBJ_PATH = 'objs\' + PLATFORM_NAME + '\';

  {$ifdef BCB}
  HPP_PROTECTED = #13#10'protected:'; {$NODEFINE HPP_PROTECTED}
  HPP_PUBLIC = #13#10'public:'; {$NODEFINE HPP_PUBLIC}
  HPP_INHERIT = '#define DECLSPEC_DRECORD HPP_INHERIT'; {$NODEFINE HPP_INHERIT}
  HPP_RETRIEVE = '#define DECLSPEC_DRECORD HPP_RETRIEVE'; {$NODEFINE HPP_RETRIEVE}
  {$endif}

  INVALID_INDEX = -1;
  INVALID_COUNT = INVALID_INDEX;
  INVALID_UINTPOINTER = NativeUInt(1);
  INVALID_POINTER = Pointer(INVALID_UINTPOINTER);

  {$ifdef FPC}
  INFINITE = Cardinal($FFFFFFFF);
  {$endif}
  DEFAULT_MEMORY_ALIGN = NativeInt(SizeOf(Pointer) * 2);

  {$if not Defined(FPC) and (CompilerVersion < 20)}
  varUInt64 = $15;
  {$ifend}
  varDeepData = $BFE8;


type

{ RTL types }

  {$ifdef FPC}
    PUInt64 = ^UInt64;
    PBoolean = ^Boolean;
    PString = ^string;
  {$else}
    {$if CompilerVersion < 16}
      UInt64 = Int64;
    {$ifend}
    {$if CompilerVersion < 20}
      TDate = type TDateTime;
      TTime = type TDateTime;
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
    {$if CompilerVersion < 24}
      PMethod = ^TMethod;
    {$ifend}
    PWord = ^Word;
  {$endif}
  PDate = ^TDate;
  PTime = ^TTime;
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
    WideString = type UnicodeString;
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

  PAlterNativeInt = ^TAlterNativeInt;
  TAlterNativeInt = {$ifdef SMALLINT}Int64{$else .LARGEINT}Integer{$endif};

  PNothing = ^TNothing;
  TNothing = packed record
  end;

  PHugeShortIntArray = ^HugeShortIntArray;
  HugeShortIntArray = array[0..High(Integer) div SizeOf(ShortInt) - 1] of ShortInt;
  PHugeByteArray = ^HugeByteArray;
  HugeByteArray = array[0..High(Integer) div SizeOf(Byte) - 1] of Byte;
  PHugeSmallIntArray = ^HugeSmallIntArray;
  HugeSmallIntArray = array[0..High(Integer) div SizeOf(SmallInt) - 1] of SmallInt;
  PHugeWordArray = ^HugeWordArray;
  HugeWordArray = array[0..High(Integer) div SizeOf(Word) - 1] of Word;
  PHugeIntegerArray = ^HugeIntegerArray;
  HugeIntegerArray = array[0..High(Integer) div SizeOf(Integer) - 1] of Integer;
  PHugeCardinalArray = ^HugeCardinalArray;
  HugeCardinalArray = array[0..High(Integer) div SizeOf(Cardinal) - 1] of Cardinal;
  PHugeNativeIntArray = ^HugeNativeIntArray;
  HugeNativeIntArray = array[0..High(Integer) div SizeOf(NativeInt) - 1] of NativeInt;
  PHugeNativeUIntArray = ^HugeNativeUIntArray;
  HugeNativeUIntArray = array[0..High(Integer) div SizeOf(NativeUInt) - 1] of NativeUInt;
  PHugePointerArray = ^HugePointerArray;
  HugePointerArray = array[0..High(Integer) div SizeOf(Pointer) - 1] of Pointer;
  PHugeAnsiCharArray = ^HugeAnsiCharArray;
  HugeAnsiCharArray = array[0..High(Integer) div SizeOf(AnsiChar) - 1] of AnsiChar;
  PHugeUTF8CharArray = ^HugeUTF8CharArray;
  HugeUTF8CharArray = array[0..High(Integer) div SizeOf(UTF8Char) - 1] of UTF8Char;
  PHugeWideCharArray = ^HugeWideCharArray;
  HugeWideCharArray = array[0..High(Integer) div SizeOf(WideChar) - 1] of WideChar;
  PHugeUCS4CharArray = ^HugeUCS4CharArray;
  HugeUCS4CharArray = array[0..High(Integer) div SizeOf(UCS4Char) - 1] of UCS4Char;

  PMemoryItems = ^TMemoryItems;
  TMemoryItems = packed record
  case Integer of
    0: (Bytes: HugeByteArray);
    1: (Words: HugeWordArray);
    2: (Cardinals: HugeCardinalArray);
    3: (NativeUInts: HugeNativeUIntArray);
    4: (A1: array[1..1] of Byte;
        case Integer of
          0: (Words1: HugeWordArray);
          1: (Cardinals1: HugeCardinalArray);
          2: (NativeUInts1: HugeNativeUIntArray);
          3: (_: packed record end);
        );
    5: (A2: array[1..2] of Byte;
        case Integer of
          0: (Cardinals2: HugeCardinalArray);
          1: (NativeUInts2: HugeNativeUIntArray);
          2: (__: packed record end);
        );
    6: (A3: array[1..3] of Byte;
        case Integer of
          0: (Cardinals3: HugeCardinalArray);
          1: (NativeUInts3: HugeNativeUIntArray);
          2: (___: packed record end);
        );
  {$ifdef LARGEINT}
    7: (A4: array[1..4] of Byte; NativeUInts4: HugeNativeUIntArray);
    8: (A5: array[1..5] of Byte; NativeUInts5: HugeNativeUIntArray);
    9: (A6: array[1..6] of Byte; NativeUInts6: HugeNativeUIntArray);
   10: (A7: array[1..7] of Byte; NativeUInts7: HugeNativeUIntArray);
  {$endif}
    -1: (____: packed record end);
  end;

  {$ifdef FPC}
  string0 = array[0..0] of AnsiChar;
  {$else}
  string0 = {$ifdef SHORTSTRSUPPORT}string[0]{$else}array[0..0] of AnsiChar{$endif};
  {$endif}
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


{ RTL structures }

type
  PDynArrayRec = ^TDynArrayRec;
  {$A1}
  TDynArrayRec = {$ifdef BCB}record{$else}object{$endif}
  private
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
  {$A4}

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
  {$A1}
  TWideStrRec = {$ifdef BCB}record{$else}object{$endif}
  private
    function GetLength: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetLength(const AValue: Integer); {$ifdef INLINESUPPORT}inline;{$endif}
  public
    property Length: Integer read GetLength write SetLength;
  public
    Size: Integer;
  end;
  {$A4}
const
  WSTR_OFFSET_LENGTH = 4{SizeOf(Integer)};
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
  USTR_OFFSET_LENGTH = WSTR_OFFSET_LENGTH;
{$endif}

type
  PUCS4StrRec = ^TUCS4StrRec;
  TUCS4StrRec = TDynArrayRec;

const
  DARR_REFCOUNT_LITERAL = {$if Defined(FPC) or (CompilerVersion <= 26)}0{$else}-1{$ifend};
  ASTR_REFCOUNT_LITERAL = {$ifdef ANSISTRSUPPORT}-1{$else}DARR_REFCOUNT_LITERAL{$endif};
  {$ifNdef MSWINDOWS}
  WSTR_REFCOUNT_LITERAL = {$ifdef WIDESTRSUPPORT}-1{$else}DARR_REFCOUNT_LITERAL{$endif};
  {$endif}
  {$ifdef UNICODE}
  USTR_REFCOUNT_LITERAL = -1;
  {$endif}
  UCS4STR_REFCOUNT_LITERAL = DARR_REFCOUNT_LITERAL;


type

{ Interface structures }

  PInterfaceVmt = ^TInterfaceVmt;
  {$A1}
  TInterfaceVmt = {$ifdef BCB}record{$else}object{$endif}
  public
    QueryInterface: function(const AInstance: Pointer; {$ifdef FPC}constref{$else}const{$endif} IID: TGUID; out Obj): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult; stdcall{$else}Longint; cdecl{$ifend};
    _AddRef: function(const AInstance: Pointer): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
    _Release: function(const AInstance: Pointer): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
  end;
  {$A4}

  PInterfaceInstance = ^TInterfaceInstance;
  {$A1}
  TInterfaceInstance = {$ifdef BCB}record{$else}object{$endif}
  public
    Vmt: PInterfaceVmt;
  end;
  {$A4}

  PDummyInterface = ^TDummyInterface;
  {$A1}
  TDummyInterface = {$ifdef BCB}record{$else}object{$endif}
  public
    {Vmt: PInterfaceVmt;}
    function QueryInterface({$ifdef FPC}constref{$else}const{$endif} IID: TGUID; out Obj): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult; stdcall{$else}Longint; cdecl{$ifend};
    function _AddRef: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
    function _Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
  end;
  {$A4}

const
  DUMMY_INTERFACE_VMT: array[0..2] of Pointer = (
    @TDummyInterface.QueryInterface,
    @TDummyInterface._AddRef,
    @TDummyInterface._Release
  );
{$ifdef EXTERNALLINKER}
var
  DUMMY_INTERFACE_DATA: Pointer;
const
{$else}
  DUMMY_INTERFACE_DATA: Pointer = @DUMMY_INTERFACE_VMT; {$ifdef FPC}public name 'DUMMY_INTERFACE_DATA';{$endif}
{$endif}
  DUMMY_INTERFACE: Pointer{PDummyInterface/IInterface} = @DUMMY_INTERFACE_DATA;

{$ifdef EXTERNALLINKER}
exports DUMMY_INTERFACE_DATA;
{$endif}


{ Universal timestamp format
  Recommendation:
    The number of 100-nanosecond intervals since January 1, 1601 (Windows FILETIME format) }

const
  TIMESTAMP_MICROSECOND = Int64(10);
  TIMESTAMP_MILLISECOND = TIMESTAMP_MICROSECOND * 1000;
  TIMESTAMP_SECOND = TIMESTAMP_MILLISECOND * 1000;
  TIMESTAMP_MINUT = TIMESTAMP_SECOND * 60;
  TIMESTAMP_HOUR = TIMESTAMP_MINUT * 60;
  TIMESTAMP_DAY = TIMESTAMP_HOUR * 24;
  TIMESTAMP_UNDAY = 1 / TIMESTAMP_DAY;
  TIMESTAMP_DELTA = 109205 * TIMESTAMP_DAY;

type
  TimeStamp = type Int64;
  PTimeStamp = ^TimeStamp;

  TOSTime = class
  protected
    {$ifdef POSIX}
    class function InternalClockGetTime(const AClockId: Integer): Int64; {$ifdef STATICSUPPORT}static;{$endif} {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$endif}
    class procedure Initialize; {$ifdef STATICSUPPORT}static;{$endif}
    class function InternalInitLocal(const AUTC: TimeStamp): TimeStamp; {$ifdef STATICSUPPORT}static;{$endif}
  public
    class function ToLocal(const AUTC: TimeStamp): TimeStamp; {$ifdef STATICSUPPORT}static;{$endif}
    class function ToUTC(const ALocal: TimeStamp): TimeStamp; {$ifdef STATICSUPPORT}static;{$endif}
    class function ToDateTime(const ATimeStamp: TimeStamp): TDateTime; {$ifdef STATICSUPPORT}static;{$endif}
    class function ToTimeStamp(const ADateTime: TDateTime): TimeStamp; {$ifdef STATICSUPPORT}static;{$endif}
    class function TickCount: Cardinal; {$ifdef STATICSUPPORT}static;{$endif}
    class function Now: TimeStamp; {$ifdef STATICSUPPORT}static;{$endif}
    class function UTCNow: TimeStamp; {$ifdef STATICSUPPORT}static;{$endif}
  end;


{ TSyncYield record
  Improves the performance of spin loops by providing the processor with a hint
  displaying that the current code is in a spin loop }

  PSyncYieldData = ^TSyncYieldData;
  TSyncYieldData = Byte;

  PSyncYield = ^TSyncYield;
  {$A1}
  TSyncYield = {$ifdef STATICSUPPORT}record{$else}object{$endif}
  private
    FCount: TSyncYieldData;
  {$ifNdef SMALLOBJECTSUPPORT}
  public
    Padding: array[1..8 - SizeOf(TSyncYieldData)] of Byte;
  {$endif}
  public
    {$ifdef STATICSUPPORT}
    class function Create: TSyncYield; static; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    procedure Reset; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Execute;

    property Count: Byte read FCount write FCount;
  end;
  {$A4}


{ TSyncSpinlock record
  The simplest and sufficiently fast synchronization primitive
  Accepts only two values: locked and unlocked }

  PSyncSpinlockData = ^TSyncSpinlockData;
  TSyncSpinlockData = Byte;

  PSyncSpinlock = ^TSyncSpinlock;
  {$A1}
  TSyncSpinlock = {$ifdef STATICSUPPORT}record{$else}object{$endif}
  private
    {$ifdef VOLATILESUPPORT}[Volatile]{$endif}
    FValue: TSyncSpinlockData;

    function GetLocked: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure InternalEnter;
    procedure InternalWait;
  {$ifNdef SMALLOBJECTSUPPORT}
  public
    Padding: array[1..8 - SizeOf(TSyncSpinlockData)] of Byte;
  {$endif}
  public
    {$ifdef STATICSUPPORT}
    class function Create: TSyncSpinlock; static; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    procedure Reset; {$ifdef INLINESUPPORT}inline;{$endif}

    function TryEnter: Boolean; {$ifNdef CPUINTELASM}inline;{$endif}
    function Enter(const ATimeout: Cardinal): Boolean; overload;
    procedure Enter; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Leave; {$ifdef INLINESUPPORT}inline;{$endif}
    function Wait(const ATimeout: Cardinal): Boolean; overload;
    procedure Wait; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    property Locked: Boolean read GetLocked;
  end;
  {$A4}


{ TSyncLocker record
  Synchronization primitive, minimizes thread serialization to gain
  read access to a resource shared among threads while still providing complete
  exclusivity to callers needing write access to the shared resource }

  PSyncLockerData = ^TSyncLockerData;
  TSyncLockerData = Integer;

  PSyncLocker = ^TSyncLocker;
  {$A1}
  TSyncLocker = {$ifdef STATICSUPPORT}record{$else}object{$endif}
  private
    {$ifdef VOLATILESUPPORT}[Volatile]{$endif}
    FValue: TSyncLockerData;

    function GetLocked: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetLockedRead: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetLockedExclusive: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure InternalEnterRead;
    procedure InternalEnterExclusive;
    procedure InternalWait;
  {$ifNdef SMALLOBJECTSUPPORT}
  public
    Padding: array[1..8 - SizeOf(TSyncLockerData)] of Byte;
  {$endif}
  public
    {$ifdef STATICSUPPORT}
    class function Create: TSyncLocker; static; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    procedure Reset; {$ifdef INLINESUPPORT}inline;{$endif}

    function TryEnterRead: Boolean;
    function TryEnterExclusive: Boolean;
    function EnterRead(const ATimeout: Cardinal): Boolean; overload;
    function EnterExclusive(const ATimeout: Cardinal): Boolean; overload;

    procedure EnterRead; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure EnterExclusive; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure LeaveRead; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure LeaveExclusive; {$ifdef INLINESUPPORT}inline;{$endif}

    function Wait(const ATimeout: Cardinal): Boolean; overload;
    procedure Wait; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    property Locked: Boolean read GetLocked;
    property LockedRead: Boolean read GetLockedRead;
    property LockedExclusive: Boolean read GetLockedExclusive;
  end;
  {$A4}


{ TSyncSmallLocker record
  One-byte implementation of TSyncLocker }

  PSyncSmallLockerData = ^TSyncSmallLockerData;
  TSyncSmallLockerData = Byte;

  PSyncSmallLocker = ^TSyncSmallLocker;
  {$A1}
  TSyncSmallLocker = {$ifdef STATICSUPPORT}record{$else}object{$endif}
  private
    {$ifdef VOLATILESUPPORT}[Volatile]{$endif}
    FValue: TSyncSmallLockerData;

    function GetLocked: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetLockedRead: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetLockedExclusive: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure InternalEnterRead;
    procedure InternalEnterExclusive;
    procedure InternalWait;
  {$ifNdef SMALLOBJECTSUPPORT}
  public
    Padding: array[1..8 - SizeOf(TSyncSmallLockerData)] of Byte;
  {$endif}
  public
    {$ifdef STATICSUPPORT}
    class function Create: TSyncSmallLocker; static; {$ifdef INLINESUPPORT}inline;{$endif}
    {$endif}
    procedure Reset; {$ifdef INLINESUPPORT}inline;{$endif}

    function TryEnterRead: Boolean;
    function TryEnterExclusive: Boolean;
    function EnterRead(const ATimeout: Cardinal): Boolean; overload;
    function EnterExclusive(const ATimeout: Cardinal): Boolean; overload;

    procedure EnterRead; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure EnterExclusive; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure LeaveRead; {$ifNdef CPUINTELASM}inline;{$endif}
    procedure LeaveExclusive; {$ifNdef CPUINTELASM}inline;{$endif}

    function Wait(const ATimeout: Cardinal): Boolean; overload;
    procedure Wait; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    property Locked: Boolean read GetLocked;
    property LockedRead: Boolean read GetLockedRead;
    property LockedExclusive: Boolean read GetLockedExclusive;
  end;
  {$A4}


{ TaggedPtr record
  Atomic 8/16 bytes tagged pointer structure, optional auto incremented
  Useful for lock-free algorithms (must be 8/16 bytes aligned) }

  PTaggedPtr = ^TaggedPtr;
  TaggedPtr = packed record
    Value: Pointer;
    Counter: NativeInt;
  end;

procedure TaggedPtrCopy(var ATarget: TaggedPtr{aligned}; const ASource{aligned});
procedure TaggedPtrRead(var ATarget: TaggedPtr{unaligned}; const ASource{aligned});
procedure TaggedPtrWrite(var ATarget: TaggedPtr{aligned}; const ASource{unaligned});
procedure TaggedPtrExchange(var ALastValue{unaligned}; var ATarget: TaggedPtr{aligned}; const AValue{unaligned});
function TaggedPtrCmpExchange(var ATarget: TaggedPtr{aligned}; const AValue, AComparand{unaligned}): Boolean;
function TaggedPtrChange(var ATarget: TaggedPtr{aligned}; const AValue: Pointer): Pointer;
function TaggedPtrInvalidate(var ATarget: TaggedPtr{aligned}): Pointer;
function TaggedPtrValidate(var ATarget: TaggedPtr{aligned}; const AValue: Pointer): Boolean;
function TaggedPtrPush(var ATarget: TaggedPtr{aligned}; const AItem: Pointer): Pointer;
function TaggedPtrPushCalcList(var ATarget: TaggedPtr{aligned}; const AFirst: Pointer): Pointer;
function TaggedPtrPushList(var ATarget: TaggedPtr{aligned}; const AFirst, ALast: Pointer): Pointer;
function TaggedPtrPop(var ATarget: TaggedPtr{aligned}): Pointer;
function TaggedPtrPopList(var ATarget: TaggedPtr{aligned}): Pointer;
function TaggedPtrPopReversed(var ATarget: TaggedPtr{aligned}): Pointer;


{ Thread buffer }

const
  THREAD_BUFFER_SIZE = 64 * 1024;

type
  PThreadBuffer = ^TThreadBuffer;
  TThreadBuffer = packed record
    Size: NativeUInt;
    Padding: NativeUInt;
    Bytes: array[0..THREAD_BUFFER_SIZE - 1] of Byte;
  end;

threadvar
  THREAD_BUFFER: TThreadBuffer;


type

{ TTinyObject/ITinyObject class
  TInterfacedObject alternative, the differences:
   - contains an original object instance
   - optimized initialize, cleanup and atomic operations
   - NEXTGEN-like rule of DisposeOf method, i.e. allows to call destructor before reference count set to zero
   - data in child classes is 8/16 byte aligned (this may be useful for lock-free algorithms)
   - allows to be placed not in memory heap }

  PInstanceStorage = ^TInstanceStorage;
  TInstanceStorage = (isHeap, isAllocator, isFreeList, isPreallocated);

  IAllocator = interface
    ['{23539ECE-534A-452A-A14D-027B597AA996}']
    function Alloc: Pointer;
    procedure Release(const Value: Pointer);
    function GetSize: Integer;
    property Size: Integer read GetSize;
  end;

  IManagedAllocator = interface(IAllocator)
    ['{B420C1DD-569B-46D6-9B99-C370E56CBC30}']
    procedure Clear;
    function GetCount: Integer;
    property Count: Integer read GetCount;
  end;

  TTinyObject = class;
  ITinyObject = interface
    ['{77DF6501-CA5E-4989-B03A-283ABEA31387}']
    function GetSelf: TTinyObject {$ifdef AUTOREFCOUNT}unsafe{$endif};
    function GetStorage: TInstanceStorage;
    function GetDisposed: Boolean;
    function GetConstructed: Boolean;
    function GetSingleThread: Boolean;
    procedure SetSingleThread(const AValue: Boolean);
    function GetRefCount: Integer;
    function GetAllocator: Pointer{IAllocator};
    procedure DisposeOf;
    procedure CheckDisposed;
    procedure CheckConstructed;
    function ToString: UnicodeString;
    property Self: TTinyObject read GetSelf;
    property Storage: TInstanceStorage read GetStorage;
    property Disposed: Boolean read GetDisposed;
    property Constructed: Boolean read GetConstructed;
    property SingleThread: Boolean read GetSingleThread write SetSingleThread;
    property RefCount: Integer read GetRefCount;
    property Allocator: Pointer{IAllocator} read GetAllocator;
  end;

  TTinyObject = class(TObject, ITinyObject)
  public
    function __ObjAddRef: Integer; {$ifdef AUTOREFCOUNT}override{$else}virtual{$endif};
    function __ObjRelease: Integer; {$ifdef AUTOREFCOUNT}override{$else}virtual{$endif};
    function ToString: UnicodeString; {$if Defined(FPC)}virtual; reintroduce;{$elseif Defined(UNICODE)}override;{$else}virtual;{$ifend}
  protected
    {$ifdef STATICSUPPORT}
    const
      objDestroyingFlag = Integer($80000000);
      objDisposedFlag = Integer($40000000);
      objNonConstructedFlag = Integer($20000000);
      objSingleThreadFlag = Integer($10000000);
      objStorageShift = 25;
      objStorageMask = Integer(High(TInstanceStorage)) shl objStorageShift;
      objRefCountMask = objDestroyingFlag + (1 shl objStorageShift - 1);
      objDefaultRefCount = {$ifdef AUTOREFCOUNT}1{$else}0{$endif};
      objInvalidRefCount = objNonConstructedFlag + (objRefCountMask xor (1 shl (objStorageShift - 1))) + (Ord(isPreallocated) shl objStorageShift);
      {$ifNdef AUTOREFCOUNT}
      vmtObjAddRef = {$ifdef FPC}System.vmtToString + SizeOf(Pointer){$else}0{$endif};
      vmtObjRelease = vmtObjAddRef + SizeOf(Pointer);
      {$endif}
      {$if Defined(FPC) or not Defined(UNICODE)}
      vmtToString = vmtObjRelease + SizeOf(Pointer);
      {$ifend}
      {$if not Defined(FPC) and (CompilerVersion >= 32)}
      monFlagsMask = NativeInt($01);
      monMonitorMask = not monFlagsMask;
      monWeakReferencedFlag = NativeInt($01);
      {$ifend}
    {$endif}
  protected
    {$ifNdef AUTOREFCOUNT}
    {$ifdef VOLATILESUPPORT}[Volatile]{$endif}
    FRefCount: Integer;
    {$ifdef LARGEINT}FPadding: Integer;{$endif}
    {$endif}
    FAllocator: Pointer{IAllocator};

    function QueryInterface({$ifdef FPC}constref{$else}const{$endif} IID: TGUID; out Obj): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult; stdcall{$else}Longint; cdecl{$ifend};
    function _AddRef: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
    function _Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
    function GetSelf: TTinyObject {$ifdef AUTOREFCOUNT}unsafe{$endif};
    function GetStorage: TInstanceStorage; {$ifdef STATICSUPPORT}inline;{$endif}
    function GetDisposed: Boolean; {$ifdef STATICSUPPORT}inline;{$endif}
    function GetConstructed: Boolean; {$ifdef STATICSUPPORT}inline;{$endif}
    function GetSingleThread: Boolean; {$ifdef STATICSUPPORT}inline;{$endif}
    procedure SetSingleThread(const AValue: Boolean); virtual;
    function GetRefCount: Integer; {$ifdef STATICSUPPORT}inline;{$endif}
    function GetAllocator: Pointer{IAllocator};
  protected
    constructor PreallocatedCreate(const AParam: Pointer; const ABuffer: Pointer; const ASize: NativeUInt); virtual;
    class function PreallocatedBufferSize(const AParam, AThreadBufferMemory: Pointer; const AThreadBufferMargin: NativeUInt): NativeInt; virtual;
    class procedure PreallocatedExecute(const AParam: Pointer; const AUseThreadBuffer: Boolean = True);
  public
    {$WARNINGS OFF}
    class function NewInstance(const APtr: Pointer; const AStorage: TInstanceStorage; const AAllocator: Pointer): TTinyObject {$ifdef AUTOREFCOUNT}unsafe{$ENDIF}; overload;
    class function NewInstance: TObject; overload; override;
    {$WARNINGS ON}
    procedure FreeInstance; override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    {$ifNdef AUTOREFCOUNT}
    procedure Free; reintroduce; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}
    {$endif}
    procedure DisposeOf; {$if not Defined(FPC) and (CompilerVersion >= 25)}reintroduce;{$ifend}
    procedure CheckDisposed; {$ifdef STATICSUPPORT}inline;{$endif}
    procedure CheckConstructed; {$ifdef STATICSUPPORT}inline;{$endif}

    property Storage: TInstanceStorage read GetStorage;
    property Disposed: Boolean read GetDisposed;
    property Constructed: Boolean read GetConstructed;
    property SingleThread: Boolean read GetSingleThread write SetSingleThread;
    property RefCount: Integer read GetRefCount;
    property Allocator: Pointer{IAllocator} read FAllocator;
  end;
  PTinyObjectClass = ^TTinyObjectClass;
  TTinyObjectClass = class of TTinyObject;


{ TTinyBuffer object
  Basic primitive that allows you to allocate temporary memory }

  PTinyBuffer = ^TTinyBuffer;

  TTinyBufferVmt = class
    class procedure Init(const ABuffer: PTinyBuffer; const AResetMode: Boolean); virtual; abstract;
    class procedure Clear(const ABuffer: PTinyBuffer); virtual; abstract;
    class function Grow(const ABuffer: PTinyBuffer; const ASize: NativeUInt; const AAlign: NativeUInt): Pointer; virtual; abstract;
  end;
  TTinyBufferVmtClass = class of TTinyBufferVmt;

  {$A1}
  {$ifdef BCB}
  TTinyBuffer = record public [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TTinyBuffer = object protected
  {$endif}
    FVmt: TTinyBufferVmtClass;
    function GetMargin: NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    function InternalAlloc(const ASize: NativeUInt; const AAlign: NativeUInt): Pointer;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    Current: PByte;
    Overflow: PByte;

    procedure Init(const AVmt: TTinyBufferVmtClass); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Clear; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Reset; {$ifdef INLINESUPPORT}inline;{$endif}

    function Alloc(const ASize: NativeUInt): Pointer;
    function AllocPacked(const ASize: NativeUInt): Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function AllocAligned(const ASize: NativeUInt): Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function AllocAligned2(const ASize: NativeUInt): Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function AllocAligned4(const ASize: NativeUInt): Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function AllocAligned8(const ASize: NativeUInt): Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
    function AllocAligned16(const ASize: NativeUInt): Pointer; {$ifdef INLINESUPPORT}inline;{$endif}

    property Vmt: TTinyBufferVmtClass read FVmt;
    property Margin: NativeInt read GetMargin;
  end;
  {$A4}


{ TBuffer object
  High-performance buffer that allows you to use fragments of pre-allocated memory
  Does not require initialization or cleanup if it is a global variable or a member of a class }

  TBufferVmt = class(TTinyBufferVmt)
    class procedure Init(const ABuffer: PTinyBuffer; const AResetMode: Boolean); override;
    class procedure Clear(const ABuffer: PTinyBuffer); override;
    class function Grow(const ABuffer: PTinyBuffer; const ASize: NativeUInt; const AAlign: NativeUInt): Pointer; override;
  end;

  PBuffer = ^TBuffer;
  {$A1}
  {$ifdef BCB}
  TBuffer__ = record [HPPGEN(HPP_INHERIT + '(TBuffer, TTinyBuffer)'#13#10)] _: Byte; end;
  TBuffer = record public
    [HPPGEN(HPP_RETRIEVE + '(TTinyBuffer)'#13#10)] This: TTinyBuffer;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TBuffer = object(TTinyBuffer) protected
  {$endif}
    FFragments: Pointer;
    FBlockCount: NativeUInt;
    FBlocks: array of TBytes;
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    procedure Init; reintroduce; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Clear; reintroduce; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Increase(const AMemory: Pointer; const ASize: NativeUInt);
  end;
  {$A4}


{ TEntireBuffer object
  Buffer in which the memory resides in a entire piece }

  TEntireBufferVmt = class(TTinyBufferVmt)
    class procedure Init(const ABuffer: PTinyBuffer; const AResetMode: Boolean); override;
    class procedure Clear(const ABuffer: PTinyBuffer); override;
    class function Grow(const ABuffer: PTinyBuffer; const ASize: NativeUInt; const AAlign: NativeUInt): Pointer; override;
  end;

  PEntireBuffer = ^TEntireBuffer;
  {$A1}
  {$ifdef BCB}
  TEntireBuffer__ = record [HPPGEN(HPP_INHERIT + '(TEntireBuffer, TTinyBuffer)'#13#10)] _: Byte;end;
  TEntireBuffer = record public
    [HPPGEN(HPP_RETRIEVE + '(TTinyBuffer)'#13#10)] This: TTinyBuffer;
    [HPPGEN(HPP_PROTECTED)]__protected__: TNothing;
  {$else .DELPHI.FPC}
  TEntireBuffer = object(TTinyBuffer) protected
  {$endif}
    FBytes: TBytes;
    function GetPosition: NativeUInt; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetSize: NativeUInt; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    {$ifdef BCB}[HPPGEN(HPP_PUBLIC)]__public__: TNothing;{$endif}
    procedure Init; reintroduce; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Clear; reintroduce; {$ifdef INLINESUPPORT}inline;{$endif}

    property Bytes: TBytes read FBytes;
    property Position: NativeUInt read GetPosition;
    property Size: NativeUInt read GetSize;
  end;
  {$A4}


(* Standard ReturnAddress macro equivalent
  Attention: in the calling function must be enabled stack frames
  Do this with the compiler options {$W+/-}

  {$W+}
  procedure Example;
  begin
    raise Exception.Create('Error Message') at ReturnAddress;
  end;
  {$W-} *)

{$ifNdef RETURNADDRESSSUPPORT}
function ReturnAddress: Pointer;
{$endif}


{ Lightweight error routine
  Equivalent to System.Error function, throws a run-time exception:
    - allows to explicitly specify the call address
    - allows to override an extended error handler, including the message text
    - allows calling from external libraries
    - allows to get rid of warnings through raise TinyError() construct }

type
  PTinyError = ^TTinyError;
  TTinyError = (
    {000} teNone,
    {001} teAccessViolation,
    {002} teStackOverflow,
    {003} teSafeCallError,
    {004} teOutOfMemory,
    {005} teRangeError,
    {006} teIntOverflow,
    {007} teIntfCastError,
    {008} teInvalidCast,
    {009} teInvalidPtr,
    {010} teInvalidOp,
    {011} teVarInvalidOp,
    {012} teVarTypeCast,
    {013} tePrivInstruction,
     // Reserved
    {014} te014, {015} te015,
    {016} te016, {017} te017, {018} te018, {019} te019, {020} te020, {021} te021, {022} te022, {023} te023,
    {024} te024, {025} te025, {026} te026, {027} te027, {028} te028, {029} te029, {030} te030, {031} te031,
    {032} te032, {033} te033, {034} te034, {035} te035, {036} te036, {037} te037, {038} te038, {039} te039,
    {040} te040, {041} te041, {042} te042, {043} te043, {044} te044, {045} te045, {046} te046, {047} te047,
    {048} te048, {049} te049, {050} te050, {051} te051, {052} te052, {053} te053, {054} te054, {055} te055,
    {056} te056, {057} te057, {058} te058, {059} te059, {060} te060, {061} te061, {062} te062, {063} te063,
    {064} te064, {065} te065, {066} te066, {067} te067, {068} te068, {069} te069, {070} te070, {071} te071,
    {072} te072, {073} te073, {074} te074, {075} te075, {076} te076, {077} te077, {078} te078, {079} te079,
    {080} te080, {081} te081, {082} te082, {083} te083, {084} te084, {085} te085, {086} te086, {087} te087,
    {088} te088, {089} te089, {090} te090, {091} te091, {092} te092, {093} te093, {094} te094, {095} te095,
    {096} te096, {097} te097, {098} te098, {099} te099, {100} te100, {101} te101, {102} te102, {103} te103,
    {104} te104, {105} te105, {106} te106, {107} te107, {108} te108, {109} te109, {110} te110, {111} te111,
    {112} te112, {113} te113, {114} te114, {115} te115, {116} te116, {117} te117, {118} te118, {119} te119,
    {120} te120, {121} te121, {122} te122, {123} te123, {124} te124, {125} te125, {126} te126, {127} te127,
    {128} te128, {129} te129, {130} te130, {131} te131, {132} te132, {133} te133, {134} te134, {135} te135,
    {136} te136, {137} te137, {138} te138, {139} te139, {140} te140, {141} te141, {142} te142, {143} te143,
    {144} te144, {145} te145, {146} te146, {147} te147, {148} te148, {149} te149, {150} te150, {151} te151,
    {152} te152, {153} te153, {154} te154, {155} te155, {156} te156, {157} te157, {158} te158, {159} te159,
    {160} te160, {161} te161, {162} te162, {163} te163, {164} te164, {165} te165, {166} te166, {167} te167,
    {168} te168, {169} te169, {170} te170, {171} te171, {172} te172, {173} te173, {174} te174, {175} te175,
    {176} te176, {177} te177, {178} te178, {179} te179, {180} te180, {181} te181, {182} te182, {183} te183,
    {184} te184, {185} te185, {186} te186, {187} te187, {188} te188, {189} te189, {190} te190, {191} te191,
    {192} te192, {193} te193, {194} te194, {195} te195, {196} te196, {197} te197, {198} te198, {199} te199,
    {200} te200, {201} te201, {202} te202, {203} te203, {204} te204, {205} te205, {206} te206, {207} te207,
    {208} te208, {209} te209, {210} te210, {211} te211, {212} te212, {213} te213, {214} te214, {215} te215,
    {216} te216, {217} te217, {218} te218, {219} te219, {220} te220, {221} te221, {222} te222, {223} te223,
    {224} te224, {225} te225, {226} te226, {227} te227, {228} te228, {229} te229, {230} te230, {231} te231,
    {232} te232, {233} te233, {234} te234, {235} te235, {236} te236, {237} te237, {238} te238, {239} te239,
    {240} te240, {241} te241, {242} te242, {243} te243, {244} te244, {245} te245, {246} te246, {247} te247,
    {248} te248, {249} te249, {250} te250, {251} te251, {252} te252, {253} te253, {254} te254, {255} te255);

var
  TINY_ERRORS: array[TTinyError] of packed record
    {$ifdef BCB}[HPPGEN('unsigned char RuntimeError')]{$endif}
    RuntimeError: TRuntimeError;
    ExitCode: Integer;
    Description: PWideChar;
  end = (
    {000} (RuntimeError: reNone; ExitCode: 1; Description: nil), // teNone,
    {001} (RuntimeError: reAccessViolation; ExitCode: 216; Description: 'Access violation'), // teAccessViolation,
    {002} (RuntimeError: reStackOverflow; ExitCode: 202; Description: 'Stack overflow'), // teStackOverflow,
    {003} (RuntimeError: reSafeCallError; ExitCode: 229; Description: 'Exception in safecall method'), // teSafeCallError,
    {004} (RuntimeError: reOutOfMemory; ExitCode: 203; Description: 'Out of memory'), // teOutOfMemory,
    {005} (RuntimeError: reRangeError; ExitCode: 201; Description: 'Range check error'), // teRangeError,
    {006} (RuntimeError: reIntOverflow; ExitCode: 215; Description: 'Integer overflow'), // teIntOverflow,
    {007} (RuntimeError: reIntfCastError; ExitCode: 228; Description: 'Interface not supported'), // teIntfCastError,
    {008} (RuntimeError: reInvalidCast; ExitCode: 219; Description: 'Invalid typecast'), // teInvalidCast,
    {009} (RuntimeError: reInvalidPtr; ExitCode: 204; Description: 'Invalid pointer operation'), // teInvalidPtr,
    {010} (RuntimeError: reInvalidOp; ExitCode: 207; Description: 'Invalid operation'), // teInvalidOp,
    {011} (RuntimeError: reVarInvalidOp; ExitCode: 221; Description: 'Invalid variant operation'), // teVarInvalidOp,
    {012} (RuntimeError: reVarTypeCast; ExitCode: 220; Description: 'Invalid variant type conversion'), // teVarTypeCast,
    {013} (RuntimeError: rePrivInstruction; ExitCode: 218; Description: 'Privileged instruction'), // tePrivInstruction,
    // Reserved
    {014} (), {015} (),
    {016} (), {017} (), {018} (), {019} (), {020} (), {021} (), {022} (), {023} (),
    {024} (), {025} (), {026} (), {027} (), {028} (), {029} (), {030} (), {031} (),
    {032} (), {033} (), {034} (), {035} (), {036} (), {037} (), {038} (), {039} (),
    {040} (), {041} (), {042} (), {043} (), {044} (), {045} (), {046} (), {047} (),
    {048} (), {049} (), {050} (), {051} (), {052} (), {053} (), {054} (), {055} (),
    {056} (), {057} (), {058} (), {059} (), {060} (), {061} (), {062} (), {063} (),
    {064} (), {065} (), {066} (), {067} (), {068} (), {069} (), {070} (), {071} (),
    {072} (), {073} (), {074} (), {075} (), {076} (), {077} (), {078} (), {079} (),
    {080} (), {081} (), {082} (), {083} (), {084} (), {085} (), {086} (), {087} (),
    {088} (), {089} (), {090} (), {091} (), {092} (), {093} (), {094} (), {095} (),
    {096} (), {097} (), {098} (), {099} (), {100} (), {101} (), {102} (), {103} (),
    {104} (), {105} (), {106} (), {107} (), {108} (), {109} (), {110} (), {111} (),
    {112} (), {113} (), {114} (), {115} (), {116} (), {117} (), {118} (), {119} (),
    {120} (), {121} (), {122} (), {123} (), {124} (), {125} (), {126} (), {127} (),
    {128} (), {129} (), {130} (), {131} (), {132} (), {133} (), {134} (), {135} (),
    {136} (), {137} (), {138} (), {139} (), {140} (), {141} (), {142} (), {143} (),
    {144} (), {145} (), {146} (), {147} (), {148} (), {149} (), {150} (), {151} (),
    {152} (), {153} (), {154} (), {155} (), {156} (), {157} (), {158} (), {159} (),
    {160} (), {161} (), {162} (), {163} (), {164} (), {165} (), {166} (), {167} (),
    {168} (), {169} (), {170} (), {171} (), {172} (), {173} (), {174} (), {175} (),
    {176} (), {177} (), {178} (), {179} (), {180} (), {181} (), {182} (), {183} (),
    {184} (), {185} (), {186} (), {187} (), {188} (), {189} (), {190} (), {191} (),
    {192} (), {193} (), {194} (), {195} (), {196} (), {197} (), {198} (), {199} (),
    {200} (), {201} (), {202} (), {203} (), {204} (), {205} (), {206} (), {207} (),
    {208} (), {209} (), {210} (), {211} (), {212} (), {213} (), {214} (), {215} (),
    {216} (), {217} (), {218} (), {219} (), {220} (), {221} (), {222} (), {223} (),
    {224} (), {225} (), {226} (), {227} (), {228} (), {229} (), {230} (), {231} (),
    {232} (), {233} (), {234} (), {235} (), {236} (), {237} (), {238} (), {239} (),
    {240} (), {241} (), {242} (), {243} (), {244} (), {245} (), {246} (), {247} (),
    {248} (), {249} (), {250} (), {251} (), {252} (), {253} (), {254} (), {255} ());

var
  TinyErrorProc: procedure(const AError: TTinyError; const AMessage: PWideChar; const AReturnAddress: Pointer);

function TinyError(const AError: TTinyError; const AMessage: PWideChar; const AReturnAddress: Pointer): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif}; overload; {$ifdef FPC}public name 'TinyError';{$endif}
function TinyError(const AError: TTinyError; const AReturnAddress: Pointer): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif}; overload;
function TinyError(const AError: TTinyError): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif}; overload;
function TinyErrorSafeCall(const ACode: Integer; const AReturnAddress: Pointer = nil): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif}; {$ifdef FPC}public name 'TinyErrorSafeCall';{$endif}
function TinyErrorOutOfMemory(const AReturnAddress: Pointer = nil): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif}; {$ifdef FPC}public name 'TinyErrorOutOfMemory';{$endif}
function TinyErrorRange(const AReturnAddress: Pointer = nil): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif}; {$ifdef FPC}public name 'TinyErrorRange';{$endif}
function TinyErrorIntOverflow(const AReturnAddress: Pointer = nil): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif}; {$ifdef FPC}public name 'TinyErrorIntOverflow';{$endif}
function TinyErrorInvalidCast(const AReturnAddress: Pointer = nil): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif}; {$ifdef FPC}public name 'TinyErrorInvalidCast';{$endif}
function TinyErrorInvalidPtr(const AReturnAddress: Pointer = nil): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif}; {$ifdef FPC}public name 'TinyErrorInvalidPtr';{$endif}
function TinyErrorInvalidOp(const AReturnAddress: Pointer = nil): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif}; {$ifdef FPC}public name 'TinyErrorInvalidOp';{$endif}
function TinyErrorIncrease(const ARuntimeError: {$ifdef BCB}Byte{$else}TRuntimeError{$endif}; const AExitCode: Integer; const ADescription: PWideChar): TTinyError;


{ Atomic operations }

{$if Defined(FPC) or (CompilerVersion < 24)}
function AtomicIncrement(var ATarget: Integer; const AValue: Integer = 1): Integer; overload; {$ifdef FPC}inline;{$endif}
function AtomicDecrement(var ATarget: Integer; const AValue: Integer = 1): Integer; overload; {$ifdef FPC}inline;{$endif}
function AtomicIncrement(var ATarget: Cardinal; const AValue: Cardinal = 1): Cardinal; overload; {$ifdef FPC}inline;{$endif}
function AtomicDecrement(var ATarget: Cardinal; const AValue: Cardinal = 1): Cardinal; overload; {$ifdef FPC}inline;{$endif}
function AtomicIncrement(var ATarget: Int64; const AValue: Int64 = 1): Int64; overload; {$ifdef FPC}inline;{$endif}
function AtomicDecrement(var ATarget: Int64; const AValue: Int64 = 1): Int64; overload; {$ifdef FPC}inline;{$endif}
function AtomicExchange(var ATarget: Integer; const AValue: Integer): Integer; overload; {$ifdef FPC}inline;{$endif}
function AtomicExchange(var ATarget: Cardinal; const AValue: Cardinal): Cardinal; overload; {$ifdef FPC}inline;{$endif}
function AtomicExchange(var ATarget: Pointer; const AValue: Pointer): Pointer; overload; {$ifdef FPC}inline;{$endif}
function AtomicExchange(var ATarget: Int64; const AValue: Int64): Int64; overload; {$ifdef FPC}inline;{$endif}
function AtomicCmpExchange(var ATarget: Integer; const ANewValue, AComparand: Integer): Integer; overload; {$ifdef FPC}inline;{$endif}
function AtomicCmpExchange(var ATarget: Cardinal; const ANewValue, AComparand: Cardinal): Cardinal; overload; {$ifdef FPC}inline;{$endif}
function AtomicCmpExchange(var ATarget: Pointer; const ANewValue, AComparand: Pointer): Pointer; overload; {$ifdef FPC}inline;{$endif}
function AtomicCmpExchange(var ATarget: Int64; const ANewValue, AComparand: Int64): Int64; overload; {$ifdef FPC}inline;{$endif}
{$ifend}


{ RTTI helpers }

procedure InitializeRecord(Source, TypeInfo: Pointer); {$if Defined(FPC) or not Defined(CPUINTELASM)}inline;{$ifend}
procedure FinalizeRecord(Source, TypeInfo: Pointer); {$if Defined(FPC) or not Defined(CPUINTELASM)}inline;{$ifend}
{$if Defined(FPC) or (CompilerVersion <= 30)}
procedure CopyRecord(Dest, Source, TypeInfo: Pointer); {$if Defined(FPC)}inline;{$ifend}
{$ifend}
{$if Defined(FPC) or (CompilerVersion <= 20)}
procedure InitializeArray(Source, TypeInfo: Pointer; Count: NativeUInt);
procedure FinalizeArray(Source, TypeInfo: Pointer; Count: NativeUInt);
procedure CopyArray(Dest, Source, TypeInfo: Pointer; Count: NativeUInt);
{$ifend}
procedure VarDataClear(var ASource: TVarData);

var
  SysVmtAddRef: NativeInt {$ifdef FPC}public name 'SysVmtAddRef'{$endif};
  SysVmtRelease: NativeInt {$ifdef FPC}public name 'SysVmtRelease'{$endif};
  SysInitStruct: procedure(const ATarget, ATypeInfo: Pointer) {$ifdef FPC}public name 'SysInitStruct'{$endif};
  SysFinalStruct: procedure(const ATarget, ATypeInfo: Pointer) {$ifdef FPC}public name 'SysFinalStruct'{$endif};
  SysCopyStruct: procedure(const ATarget, ASource, ATypeInfo: Pointer) {$ifdef FPC}public name 'SysCopyStruct'{$endif};
  SysInitArray: procedure(const ATarget, ATypeInfo: Pointer; const ACount: NativeUInt) {$ifdef FPC}public name 'SysInitArray'{$endif};
  SysFinalArray: procedure(const ATarget, ATypeInfo: Pointer; const ACount: NativeUInt) {$ifdef FPC}public name 'SysFinalArray'{$endif};
  SysCopyArray: procedure(const ATarget, ASource, ATypeInfo: Pointer; const ACount: NativeUInt) {$ifdef FPC}public name 'SysCopyArray'{$endif};
  SysFinalDynArray: procedure(const ATarget, ATypeInfo: Pointer) {$ifdef FPC}public name 'SysFinalDynArray'{$endif};
  SysFinalVariant: procedure(const ATarget: Pointer) {$ifdef FPC}public name 'SysFinalVariant'{$endif};
  SysCopyVariant: procedure(const ATarget, ASource: Pointer) {$ifdef FPC}public name 'SysCopyVariant'{$endif};
  SysFinalWeakIntf: procedure(const ATarget: Pointer) {$ifdef FPC}public name 'SysFinalWeakIntf'{$endif};
  SysCopyWeakIntf: procedure(const ATarget, ASource: Pointer) {$ifdef FPC}public name 'SysCopyWeakIntf'{$endif};
  SysFinalWeakObj: procedure(const ATarget: Pointer) {$ifdef FPC}public name 'SysFinalWeakObj'{$endif};
  SysCopyWeakObj: procedure(const ATarget, ASource: Pointer) {$ifdef FPC}public name 'SysCopyWeakObj'{$endif};
  SysFinalWeakMethod: procedure(const ATarget: Pointer) {$ifdef FPC}public name 'SysFinalWeakMethod'{$endif};
  SysCopyWeakMethod: procedure(const ATarget, ASource: Pointer) {$ifdef FPC}public name 'SysCopyWeakMethod'{$endif};

{$ifdef EXTERNALLINKER}
exports SysVmtAddRef, SysVmtRelease, SysInitStruct, SysFinalStruct, SysCopyStruct,
  SysInitArray, SysFinalArray, SysCopyArray, SysFinalDynArray, SysFinalVariant,
  SysCopyVariant, SysFinalWeakIntf, SysCopyWeakIntf, SysFinalWeakObj, SysCopyWeakObj,
  SysFinalWeakMethod, SysCopyWeakMethod;
{$endif}


{ Memory management }

var
  MMGetMem: function(Size: NativeUInt): Pointer {$ifdef FPC}public name 'MMGetMem'{$endif};
  MMFreeMem: function(P: Pointer): {$ifdef FPC}NativeUInt{$else}Cardinal{$endif} {$ifdef FPC}public name 'MMFreeMem'{$endif};
  MMReallocMem: function({$ifdef FPC}var{$endif} P: Pointer; Size: NativeUInt): Pointer {$ifdef FPC}public name 'MMReallocMem'{$endif};
  MMAllocMem: function(Size: NativeUInt): Pointer {$ifdef FPC}public name 'MMAllocMem'{$endif};
  MMRegisterExpectedMemoryLeak: function(P: Pointer): Boolean {$ifdef FPC}public name 'MMRegisterExpectedMemoryLeak'{$endif};
  MMUnregisterExpectedMemoryLeak: function(P: Pointer): Boolean {$ifdef FPC}public name 'MMUnregisterExpectedMemoryLeak'{$endif};
  {$ifdef MSWINDOWS}
  MMSysStrAlloc: function(P: PWideChar; Len: Integer): PWideChar {$ifdef FPC}public name 'MMSysStrAlloc'{$endif}; stdcall;
  MMSysStrRealloc: function(var S{: WideString}; P: PWideChar; Len: Integer): LongBool {$ifdef FPC}public name 'MMSysStrRealloc'{$endif}; stdcall;
  MMSysStrFree: procedure(const S: PWideChar{WideString}) {$ifdef FPC}public name 'MMSysStrFree'{$endif}; stdcall;
  {$endif}

{$ifdef EXTERNALLINKER}
exports MMGetMem, MMFreeMem, MMReallocMem, MMAllocMem, MMRegisterExpectedMemoryLeak, MMUnregisterExpectedMemoryLeak;
{$endif}

procedure TinyMove(const ASource; var ADest; const ACount: NativeUInt);


{ String functions }

function AStrLen(const S: PAnsiChar): NativeUInt;
function WStrLen(const S: PWideChar): NativeUInt;
function CStrLen(const S: PUCS4Char): NativeUInt;

procedure OStrClear(var S{: ShortString}); {$ifdef INLINESUPPORT}inline;{$endif}
function OStrInit(var S{: ShortString}; const AChars: PAnsiChar; const ALength: Byte): PAnsiChar; {$ifdef INLINESUPPORT}inline;{$endif}
function OStrReserve(var S{: ShortString}; const ALength: Byte): PAnsiChar; {$ifdef INLINESUPPORT}inline;{$endif}
function OStrSetLength(var S{: ShortString}; const ALength: Byte): PAnsiChar; {$ifdef INLINESUPPORT}inline;{$endif}

procedure AStrClear(var S{: AnsiString});
function AStrInit(var S{: AnsiString}; const AChars: PAnsiChar; const ALength: NativeUInt; const ACodePage: Word): PAnsiChar;
function AStrReserve(var S{: AnsiString}; const ALength: NativeUInt): PAnsiChar;
function AStrSetLength(var S{: AnsiString}; const ALength: NativeUInt; const ACodePage: Word): PAnsiChar;

procedure WStrClear(var S: WideString);
function WStrInit(var S: WideString; const AChars: PWideChar; const ALength: NativeUInt): PWideChar;
function WStrReserve(var S: WideString; const ALength: NativeUInt): PWideChar;
function WStrSetLength(var S: WideString; const ALength: NativeUInt): PWideChar;

procedure UStrClear(var S: UnicodeString);
function UStrInit(var S: UnicodeString; const AChars: PWideChar; const ALength: NativeUInt): PWideChar;
function UStrReserve(var S: UnicodeString; const ALength: NativeUInt): PWideChar;
function UStrSetLength(var S: UnicodeString; const ALength: NativeUInt): PWideChar;

procedure CStrClear(var S: UCS4String);
function CStrInit(var S: UCS4String; const AChars: PUCS4Char; const ALength: NativeUInt): UCS4Char;
function CStrReserve(var S: UCS4String; const ALength: NativeUInt): UCS4Char;
function CStrSetLength(var S: UCS4String; const ALength: NativeUInt): UCS4Char;


{ Auxiliary routine }

type
  TPreallocatedCallback = procedure(const AParam: Pointer; const AMemory: Pointer; const ASize: NativeUInt);

function TinyAlloc(const ASize: NativeUInt): Pointer;
function TinyAllocPacked(const ASize: NativeUInt): Pointer;
function TinyAllocAligned(const ASize: NativeUInt): Pointer;
function TinyAllocAligned2(const ASize: NativeUInt): Pointer;
function TinyAllocAligned4(const ASize: NativeUInt): Pointer;
function TinyAllocAligned8(const ASize: NativeUInt): Pointer;
function TinyAllocAligned16(const ASize: NativeUInt): Pointer;
procedure TinyAllocIncrease(const AMemory: Pointer; const ASize: NativeUInt);

procedure PreallocatedCall(const AParam: Pointer; const ASize: NativeUInt; const ACallback: TPreallocatedCallback);


var
  {$ifdef FPC}
  MainThreadID: TThreadID public name 'MainThreadID';
  {$endif}
  CompilerMode: Cardinal {$ifdef FPC}public name 'CompilerMode'{$endif};
  DefaultCP: Word {$ifdef FPC}public name 'DefaultCP'{$endif};
  IDERunning: Boolean {$ifdef FPC}public name 'IDERunning'{$endif};

{$ifdef EXTERNALLINKER}
exports MainThreadID, CompilerMode, DefaultCP, IDERunning;
{$endif}

implementation


{ Default code page }

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


{ Library initialization }

{$ifdef FPC}
{$ifdef MSWINDOWS}
function IsDebuggerPresent: Integer stdcall; external 'kernel32.dll';
function DebugHook: Integer;
begin
  Result := IsDebuggerPresent;
end;
{$else}
function DebugHook: Integer;
begin
  Result := 0;
end;
{$endif}
{$endif}

procedure InternalNone;
begin
end;

{$if Defined(FPC) or not Defined(CPUINTELASM)}
function GetInitStructAddress: Pointer;
begin
  Result := @InitializeRecord;
end;

function GetFinalStructAddress: Pointer;
begin
  Result := @FinalizeRecord;
end;

function GetCopyStructAddress: Pointer;
begin
  Result := @CopyRecord;
end;

function GetInitArrayAddress: Pointer;
begin
  Result := @InitializeArray;
end;

function GetFinalArrayAddress: Pointer;
begin
  Result := @FinalizeArray;
end;

function GetCopyArrayAddress: Pointer;
begin
  Result := @CopyArray;
end;

function GetFinalDynArrayAddress: Pointer;
begin
  Result := @DynArrayClear;
end;
{$else}
function GetInitStructAddress: Pointer;
asm
  {$ifdef CPUX86}
    lea eax, System.@InitializeRecord
  {$else .CPUX64}
    lea rax, System.@InitializeRecord
  {$endif}
end;

function GetFinalStructAddress: Pointer;
asm
  {$ifdef CPUX86}
    lea eax, System.@FinalizeRecord
  {$else .CPUX64}
    lea rax, System.@FinalizeRecord
  {$endif}
end;

function GetCopyStructAddress: Pointer;
asm
  {$ifdef CPUX86}
    lea eax, System.@CopyRecord
  {$else .CPUX64}
    lea rax, System.@CopyRecord
  {$endif}
end;

function GetInitArrayAddress: Pointer;
asm
  {$ifdef CPUX86}
    lea eax, System.@InitializeArray
  {$else .CPUX64}
    lea rax, System.@InitializeArray
  {$endif}
end;

function GetFinalArrayAddress: Pointer;
asm
  {$ifdef CPUX86}
    lea eax, System.@FinalizeArray
  {$else .CPUX64}
    lea rax, System.@FinalizeArray
  {$endif}
end;

function GetCopyArrayAddress: Pointer;
asm
  {$ifdef CPUX86}
    lea eax, System.@CopyArray
  {$else .CPUX64}
    lea rax, System.@CopyArray
  {$endif}
end;

function GetFinalDynArrayAddress: Pointer;
asm
  {$ifdef CPUX86}
    lea eax, System.@DynArrayClear
  {$else .CPUX64}
    lea rax, System.@DynArrayClear
  {$endif}
end;
{$ifend}

procedure InternalVarDataCopy(var ATarget, ASource: TVarData);
begin
  if Assigned(VarCopyProc) then
  begin
    VarCopyProc(ATarget, ASource);
  end else
  begin
    TinyError(teVarInvalidOp);
  end;
end;

{$ifdef WEAKINTFREF}
procedure InternalWeakIntfClear(const AValue: Pointer);
type
  TInstance = record
    [Weak] Intf: IInterface;
  end;
  PInstance = ^TInstance;
begin
  PInstance(AValue).Intf := nil;
end;

procedure InternalWeakIntfCopy(const ATarget, ASource: Pointer);
type
  TInstance = record
    [Weak] Intf: IInterface;
  end;
  PInstance = ^TInstance;
begin
  PInstance(ATarget).Intf := PInstance(ASource).Intf;
end;
{$endif}

{$ifdef WEAKINSTREF}
procedure InternalWeakObjClear(const AValue: Pointer);
type
  TInstance = record
    [Weak] Obj: TObject;
  end;
  PInstance = ^TInstance;
begin
  PInstance(AValue).Obj := nil;
end;

procedure InternalWeakObjCopy(const ATarget, ASource: Pointer);
type
  TInstance = record
    [Weak] Obj: TObject;
  end;
  PInstance = ^TInstance;
begin
  PInstance(ATarget).Obj := PInstance(ASource).Obj;
end;

procedure InternalWeakMethodClear(const AValue: Pointer);
type
  TInstance = record
    Method: procedure of object;
  end;
  PInstance = ^TInstance;
begin
  PInstance(AValue).Method := nil;
end;

procedure InternalWeakMethodCopy(const ATarget, ASource: Pointer);
type
  TInstance = record
    Method: procedure of object;
  end;
  PInstance = ^TInstance;
begin
  PInstance(ATarget).Method := PInstance(ASource).Method;
end;
{$endif}

{$if not Defined(FPC) and (CompilerVersion < 18)}
function InternalMMAllocMem(Size: NativeInt): Pointer;
begin
  if (Size <= 0) then
  begin
    Result := nil;
  end else
  begin
    Result := MMGetMem(Size);
    if Result = nil then
    begin
      Result := TinyError(teOutOfMemory);
    end else
    begin
      FillChar(Result^, Size, #0);
    end;
  end;
end;
{$ifend}

procedure InitLibrary;
var
  LMemoryManager: {$if Defined(FPC) or (CompilerVersion < 18)}TMemoryManager{$else}TMemoryManagerEx{$ifend};
  {$ifdef MSWINDOWS}
  LHandle: THandle;
  {$endif}
begin
  // general
  {$ifdef EXTERNALLINKER}
  DUMMY_INTERFACE_DATA := @DUMMY_INTERFACE_VMT;
  {$endif}
  {$ifdef FPC}
  MainThreadID := GetCurrentThreadId;
  {$endif}
  CompilerMode := {$ifdef FPC}0{$else .DELPHI}Round(CompilerVersion * 10){$endif};
  DefaultCP := GetACP;
  if (DefaultCP = 65001{CP_UTF8}) then
  begin
    DefaultCP := 1252;
  end;
  {$WARNINGS OFF}
  IDERunning := (DebugHook > 0);
  {$WARNINGS ON}
  TOSTime.Initialize;

  // RTTI helpers
  Pointer(@SysInitStruct) := GetInitStructAddress;
  Pointer(@SysFinalStruct) := GetFinalStructAddress;
  Pointer(@SysCopyStruct) := GetCopyStructAddress;
  Pointer(@SysInitArray) := GetInitArrayAddress;
  Pointer(@SysFinalArray) := GetFinalArrayAddress;
  Pointer(@SysCopyArray) := GetCopyArrayAddress;
  Pointer(@SysFinalDynArray) := GetFinalDynArrayAddress;
  Pointer(@SysFinalVariant) := @VarDataClear;
  Pointer(@SysCopyVariant) := @InternalVarDataCopy;
  {$ifdef WEAKINTFREF}
  Pointer(@SysFinalWeakIntf) := @InternalWeakIntfClear;
  Pointer(@SysCopyWeakIntf) := @InternalWeakIntfCopy;
  {$else}
  Pointer(@SysFinalWeakIntf) := @InternalNone;
  Pointer(@SysCopyWeakIntf) := @InternalNone;
  {$endif}
  {$ifdef WEAKINSTREF}
  Pointer(@SysFinalWeakObj) := @InternalWeakObjClear;
  Pointer(@SysCopyWeakObj) := @InternalWeakObjCopy;
  Pointer(@SysFinalWeakMethod) := @InternalWeakMethodClear;
  Pointer(@SysCopyWeakMethod) := @InternalWeakMethodCopy;
  {$else}
  Pointer(@SysFinalWeakObj) := @InternalNone;
  Pointer(@SysCopyWeakObj) := @InternalNone;
  Pointer(@SysFinalWeakMethod) := @InternalNone;
  Pointer(@SysCopyWeakMethod) := @InternalNone;
  {$endif}

  // memory manager
  {$WARNINGS OFF} // deprecated warning bug fix (like Delphi 2010 compiler)
  System.GetMemoryManager(LMemoryManager);
  {$WARNINGS ON}
  Pointer(@MMGetMem) := @LMemoryManager.GetMem;
  Pointer(@MMFreeMem) := @LMemoryManager.FreeMem;
  Pointer(@MMReallocMem) := @LMemoryManager.ReallocMem;
  {$if Defined(FPC) or (CompilerVersion >= 18)}
  Pointer(@MMAllocMem) := @LMemoryManager.AllocMem;
  {$else}
  Pointer(@MMAllocMem) := @InternalMMAllocMem;
  {$ifend}
  {$if not Defined(FPC) and (CompilerVersion >= 18)}
  Pointer(@MMRegisterExpectedMemoryLeak) := @LMemoryManager.RegisterExpectedMemoryLeak;
  Pointer(@MMUnregisterExpectedMemoryLeak) := @LMemoryManager.UnregisterExpectedMemoryLeak;
  {$ifend}

  // WideString
  {$ifdef MSWINDOWS}
  LHandle := LoadLibrary('oleaut32.dll');
  MMSysStrAlloc := GetProcAddress(LHandle, 'SysAllocStringLen');
  MMSysStrRealloc := GetProcAddress(LHandle, 'SysReAllocStringLen');
  MMSysStrFree := GetProcAddress(LHandle, 'SysFreeString');
  FreeLibrary(LHandle);
  {$endif}
end;


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


{ TDummyInterface }

function TDummyInterface.QueryInterface(
  {$ifdef FPC}constref{$else}const{$endif} IID: TGUID; out Obj):
  {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult; stdcall{$else}Longint; cdecl{$ifend};
begin
  Result := E_NOINTERFACE;
end;

function TDummyInterface._AddRef:
  {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
begin
  Result := -1;
end;

function TDummyInterface._Release:
  {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer; stdcall{$else}Longint; cdecl{$ifend};
begin
  Result := -1;
end;


{ Lightweight error routine }

var
  InternalTinyErrorCurrent: Integer{TTinyError} = Ord(tePrivInstruction);

{$W+}
function TinyError(const AError: TTinyError; const AMessage: PWideChar;
  const AReturnAddress: Pointer): TObject;
const
  RUNTIME_ERROR_TEMPLATE: PWideChar = 'Runtime error 000';
  RUNTIME_ERROR_TEMPLATE_LENGTH = 17;
var
  LMessage: PWideChar;
  LReturnAddress: Pointer;
  LMessageBuffer: array[0..RUNTIME_ERROR_TEMPLATE_LENGTH] of WideChar;
begin
  Result := nil;
  LMessage := AMessage;
  LReturnAddress := AReturnAddress;

  if (not Assigned(AMessage)) or (AError = teSafeCallError) then
  begin
    LMessage := TINY_ERRORS[AError].Description;
    if (not Assigned(LMessage)) then
    begin
      TinyMove(RUNTIME_ERROR_TEMPLATE^, LMessageBuffer, RUNTIME_ERROR_TEMPLATE_LENGTH * SizeOf(WideChar));
      LMessageBuffer[RUNTIME_ERROR_TEMPLATE_LENGTH] := #0;
      Word(LMessageBuffer[RUNTIME_ERROR_TEMPLATE_LENGTH - 1]) := Ord('0') + Ord(AError) mod 10;
      Word(LMessageBuffer[RUNTIME_ERROR_TEMPLATE_LENGTH - 2]) := Ord('0') + (Ord(AError) div 10) mod 10;
      Word(LMessageBuffer[RUNTIME_ERROR_TEMPLATE_LENGTH - 3]) := Ord('0') + (Ord(AError) div 100) mod 10;
      LMessage := @LMessageBuffer[0];
    end;
  end;

  if (not Assigned(LReturnAddress)) then
  begin
    LReturnAddress := ReturnAddress;
  end;

  if (Assigned(TinyErrorProc)) then
  begin
    TinyErrorProc(AError, LMessage, LReturnAddress);
  end;

  if (AError = teSafeCallError) and (Assigned(System.SafeCallErrorProc)) then
  begin
    System.SafeCallErrorProc(NativeInt(AMessage), LReturnAddress);
  end;

  if (Assigned(System.ErrorProc)) then
  begin
    System.ErrorProc(Ord(TINY_ERRORS[AError].{$ifdef FPC}ExitCode{$else}RuntimeError{$endif}), LReturnAddress {$ifdef FPC}, nil{$endif});
  end;

  System.ErrorAddr := LReturnAddress;
  System.ExitCode := TINY_ERRORS[AError].ExitCode;
  if (System.ExitCode = 0) then
  begin
    System.ExitCode := Ord(AError);
  end;

  if (IDERunning) then
  begin
    System.IsConsole := False;
  end;

  System.Halt;
end;
{$W-}

{$ifdef EXTERNALLINKER}
function __TinyError(const AError: TTinyError; const AMessage: PWideChar;
  AReturnAddress: Pointer): TObject {$ifdef AUTOREFCOUNT}unsafe{$endif};
begin
  if (not Assigned(AReturnAddress)) then
  begin
    AReturnAddress := ReturnAddress;
  end;

  Result := TinyError(AError, AMessage, AReturnAddress);
end;
exports __TinyError name 'TinyError';
{$endif}

{$W+}
function TinyError(const AError: TTinyError; const AReturnAddress: Pointer): TObject;
var
  LReturnAddress: Pointer;
begin
  LReturnAddress := AReturnAddress;
  if (not Assigned(LReturnAddress)) then
  begin
    LReturnAddress := ReturnAddress;
  end;

  Result := TinyError(AError, nil, LReturnAddress);
end;
{$W-}

{$W+}
function TinyError(const AError: TTinyError): TObject;
begin
  Result := TinyError(AError, nil, ReturnAddress);
end;
{$W-}

{$W+}
function TinyErrorSafeCall(const ACode: Integer; const AReturnAddress: Pointer): TObject;
var
  LReturnAddress: Pointer;
begin
  LReturnAddress := AReturnAddress;
  if (not Assigned(LReturnAddress)) then
  begin
    LReturnAddress := ReturnAddress;
  end;

  Result := TinyError(teSafeCallError, PWideChar(NativeInt(ACode)), LReturnAddress);
end;
{$if Defined(EXTERNALLINKER)}
exports TinyErrorSafeCall;
{$ifend}
{$W-}

{$W+}
function TinyErrorOutOfMemory(const AReturnAddress: Pointer): TObject;
var
  LReturnAddress: Pointer;
begin
  LReturnAddress := AReturnAddress;
  if (not Assigned(LReturnAddress)) then
  begin
    LReturnAddress := ReturnAddress;
  end;

  Result := TinyError(teOutOfMemory, nil, LReturnAddress);
end;
{$if Defined(EXTERNALLINKER)}
exports TinyErrorOutOfMemory;
{$ifend}
{$W-}

{$W+}
function TinyErrorRange(const AReturnAddress: Pointer): TObject;
var
  LReturnAddress: Pointer;
begin
  LReturnAddress := AReturnAddress;
  if (not Assigned(LReturnAddress)) then
  begin
    LReturnAddress := ReturnAddress;
  end;

  Result := TinyError(teRangeError, nil, LReturnAddress);
end;
{$if Defined(EXTERNALLINKER)}
exports TinyErrorRange;
{$ifend}
{$W-}

{$W+}
function TinyErrorIntOverflow(const AReturnAddress: Pointer): TObject;
var
  LReturnAddress: Pointer;
begin
  LReturnAddress := AReturnAddress;
  if (not Assigned(LReturnAddress)) then
  begin
    LReturnAddress := ReturnAddress;
  end;

  Result := TinyError(teIntOverflow, nil, LReturnAddress);
end;
{$if Defined(EXTERNALLINKER)}
exports TinyErrorIntOverflow;
{$ifend}
{$W-}

{$W+}
function TinyErrorInvalidCast(const AReturnAddress: Pointer): TObject;
var
  LReturnAddress: Pointer;
begin
  LReturnAddress := AReturnAddress;
  if (not Assigned(LReturnAddress)) then
  begin
    LReturnAddress := ReturnAddress;
  end;

  Result := TinyError(teInvalidCast, nil, LReturnAddress);
end;
{$if Defined(EXTERNALLINKER)}
exports TinyErrorInvalidCast;
{$ifend}
{$W-}

{$W+}
function TinyErrorInvalidPtr(const AReturnAddress: Pointer): TObject;
var
  LReturnAddress: Pointer;
begin
  LReturnAddress := AReturnAddress;
  if (not Assigned(LReturnAddress)) then
  begin
    LReturnAddress := ReturnAddress;
  end;

  Result := TinyError(teInvalidPtr, nil, LReturnAddress);
end;
{$if Defined(EXTERNALLINKER)}
exports TinyErrorInvalidPtr;
{$ifend}
{$W-}

{$W+}
function TinyErrorInvalidOp(const AReturnAddress: Pointer): TObject;
var
  LReturnAddress: Pointer;
begin
  LReturnAddress := AReturnAddress;
  if (not Assigned(LReturnAddress)) then
  begin
    LReturnAddress := ReturnAddress;
  end;

  Result := TinyError(teInvalidOp, nil, LReturnAddress);
end;
{$if Defined(EXTERNALLINKER)}
exports TinyErrorInvalidOp;
{$ifend}
{$W-}

function TinyErrorIncrease(const ARuntimeError: {$ifdef BCB}Byte{$else}TRuntimeError{$endif};
  const AExitCode: Integer; const ADescription: PWideChar): TTinyError;
var
  LValue: Integer;
begin
  repeat
    LValue := InternalTinyErrorCurrent;
    if (LValue >= Ord(High(TTinyError))) then
    begin
      TinyError(teIntOverflow);
    end;
  until (LValue = AtomicCmpExchange(InternalTinyErrorCurrent, LValue + 1, LValue));

  Result := TTinyError(LValue + 1);

  TINY_ERRORS[Result].RuntimeError := TRuntimeError(ARuntimeError);
  TINY_ERRORS[Result].ExitCode := AExitCode;
  TINY_ERRORS[Result].Description := ADescription;
end;


{ Atomic operations }

{$if Defined(FPC) or (CompilerVersion < 24)}
function AtomicIncrement(var ATarget: Integer; const AValue: Integer): Integer; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedExchangeAdd(ATarget, AValue) + AValue;
end;
{$elseif Defined(CPUX86)}
asm
  mov ecx, edx
  lock xadd [eax], edx
  lea eax, [edx + ecx]
end;
{$else .CPUX64} .NOFRAME
asm
  mov eax, edx
  lock xadd [rcx], eax
  add eax, edx
end;
{$ifend}

function AtomicDecrement(var ATarget: Integer; const AValue: Integer): Integer; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedExchangeAdd(ATarget, -AValue) - AValue;
end;
{$elseif Defined(CPUX86)}
asm
  neg edx
  mov ecx, edx
  lock xadd [eax], edx
  lea eax, [edx + ecx]
end;
{$else .CPUX64} .NOFRAME
asm
  neg edx
  mov eax, edx
  lock xadd [rcx], eax
  add eax, edx
end;
{$ifend}

function AtomicIncrement(var ATarget: Cardinal; const AValue: Cardinal): Cardinal; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedExchangeAdd(ATarget, AValue) + AValue;
end;
{$elseif Defined(CPUX86)}
asm
  mov ecx, edx
  lock xadd [eax], edx
  lea eax, [edx + ecx]
end;
{$else .CPUX64} .NOFRAME
asm
  mov eax, edx
  lock xadd [rcx], eax
  add eax, edx
end;
{$ifend}

function AtomicDecrement(var ATarget: Cardinal; const AValue: Cardinal): Cardinal; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedExchangeAdd(Integer(ATarget), -Integer(AValue)) - Integer(AValue);
end;
{$elseif Defined(CPUX86)}
asm
  neg edx
  mov ecx, edx
  lock xadd [eax], edx
  lea eax, [edx + ecx]
end;
{$else .CPUX64} .NOFRAME
asm
  neg edx
  mov eax, edx
  lock xadd [rcx], eax
  add eax, edx
end;
{$ifend}

function AtomicIncrement(var ATarget: Int64; const AValue: Int64): Int64; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedExchangeAdd64(ATarget, AValue) + AValue;
end;
{$elseif Defined(CPUX86)}
asm
  push esi
  push edi
  push ebx
  mov ebp, eax
  mov esi, [esp + 20]
  mov edi, [esp + 24]

  @loop:
    mov eax, [ebp]
    mov edx, [ebp + 4]

    mov ebx, esi
    mov ecx, edi
    add ebx, eax
    adc ecx, edx

    lock cmpxchg8b [ebp]
  jnz @loop

  add eax, esi
  adc edx, edi

  pop ebx
  pop edi
  pop esi
end;
{$else .CPUX64} .NOFRAME
asm
  mov rax, rdx
  lock xadd [rcx], rdx
  add rax, rdx
end;
{$ifend}

function AtomicDecrement(var ATarget: Int64; const AValue: Int64): Int64; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedExchangeAdd64(ATarget, -AValue) - AValue;
end;
{$elseif Defined(CPUX86)}
asm
  push esi
  push edi
  push ebx
  mov ebp, eax
  mov esi, [esp + 20]
  mov edi, [esp + 24]
  neg esi
  adc edi, 0
  neg edi

  @loop:
    mov eax, [ebp]
    mov edx, [ebp + 4]

    mov ebx, esi
    mov ecx, edi
    add ebx, eax
    adc ecx, edx

    lock cmpxchg8b [ebp]
  jnz @loop

  add eax, esi
  adc edx, edi

  pop ebx
  pop edi
  pop esi
end;
{$else .CPUX64} .NOFRAME
asm
  neg rdx
  mov rax, rdx
  lock xadd [rcx], rdx
  add rax, rdx
end;
{$ifend}

function AtomicExchange(var ATarget: Integer; const AValue: Integer): Integer; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedExchange(ATarget, AValue);
end;
{$elseif Defined(CPUX86)}
asm
  lock xchg [eax], edx
  mov eax, edx
end;
{$else .CPUX64} .NOFRAME
asm
  mov eax, edx
  lock xchg eax, [rcx]
end;
{$ifend}

function AtomicExchange(var ATarget: Cardinal; const AValue: Cardinal): Cardinal; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedExchange(ATarget, AValue);
end;
{$elseif Defined(CPUX86)}
asm
  lock xchg [eax], edx
  mov eax, edx
end;
{$else .CPUX64} .NOFRAME
asm
  mov eax, edx
  lock xchg eax, [rcx]
end;
{$ifend}

function AtomicExchange(var ATarget: Pointer; const AValue: Pointer): Pointer; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedExchange(ATarget, AValue);
end;
{$elseif Defined(CPUX86)}
asm
  lock xchg [eax], edx
  mov eax, edx
end;
{$else .CPUX64} .NOFRAME
asm
  mov rax, rdx
  lock xchg rax, [rcx]
end;
{$ifend}

function AtomicExchange(var ATarget: Int64; const AValue: Int64): Int64; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedExchange64(ATarget, AValue);
end;
{$elseif Defined(CPUX86)}
asm
  push ebx
  mov ebp, eax
  mov ebx, [esp + 12]
  mov ecx, [esp + 16]

  @loop:
    mov eax, [ebp]
    mov edx, [ebp + 4]
    lock cmpxchg8b [ebp]
  jnz @loop

  pop ebx
end;
{$else .CPUX64} .NOFRAME
asm
  mov rax, rdx
  lock xchg rax, [rcx]
end;
{$ifend}

function AtomicCmpExchange(var ATarget: Integer; const ANewValue, AComparand: Integer): Integer; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedCompareExchange(ATarget, ANewValue, AComparand);
end;
{$elseif Defined(CPUX86)}
asm
  xchg eax, ecx
  lock cmpxchg [ecx], edx
end;
{$else .CPUX64} .NOFRAME
asm
  mov eax, r8d
  lock cmpxchg [rcx], edx
end;
{$ifend}

function AtomicCmpExchange(var ATarget: Cardinal; const ANewValue, AComparand: Cardinal): Cardinal; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedCompareExchange(ATarget, ANewValue, AComparand);
end;
{$elseif Defined(CPUX86)}
asm
  xchg eax, ecx
  lock cmpxchg [ecx], edx
end;
{$else .CPUX64} .NOFRAME
asm
  mov eax, r8d
  lock cmpxchg [rcx], edx
end;
{$ifend}

function AtomicCmpExchange(var ATarget: Pointer; const ANewValue, AComparand: Pointer): Pointer; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedCompareExchange(ATarget, ANewValue, AComparand);
end;
{$elseif Defined(CPUX86)}
asm
  xchg eax, ecx
  lock cmpxchg [ecx], edx
end;
{$else .CPUX64} .NOFRAME
asm
  mov rax, r8
  lock cmpxchg [rcx], rdx
end;
{$ifend}

function AtomicCmpExchange(var ATarget: Int64; const ANewValue, AComparand: Int64): Int64; overload;
{$if Defined(FPC)}
begin
  Result := System.InterLockedCompareExchange64(ATarget, ANewValue, AComparand);
end;
{$elseif Defined(CPUX86)}
asm
  push ebx
  mov ebp, eax
  mov eax, [esp + 12]
  mov edx, [esp + 16]
  mov ebx, [esp + 20]
  mov ecx, [esp + 24]

  cmp eax, [ebp]
  jne @done
  cmp edx, [ebp + 4]
  jne @done
  lock cmpxchg8b [ebp]

@done:
  pop ebx
end;
{$else .CPUX64} .NOFRAME
asm
  mov rax, r8
  lock cmpxchg [rcx], rdx
end;
{$ifend}
{$ifend FPC.CompilerVersionm24}


{ RTTI helpers }

type
  {$if Defined(FPC)}
    TTypeKind = (
      tkLString = 8,
      tkAString = 9,
      tkWString = 10,
      tkVariant = 11,
      tkArray = 12,
      tkRecord = 13,
      tkInterface = 14,
      tkObject = 16,
      tkDynArray = 21,
      tkUString = 24
    );
  {$elseif (CompilerVersion >= 28)}
    TTypeKind = System.TTypeKind;
  {$else}
    TTypeKind = (
      tkLString = 10,
      tkWString = 11,
      tkVariant = 12,
      tkArray = 13,
      tkRecord = 14,
      tkInterface = 15,
      tkDynArray = 17,
      tkUString = 18,
      tkMRecord = 22
    );
  {$ifend}

  PPTypeInfo = ^PTypeInfo;
  PTypeInfo = ^TTypeInfo;
  TTypeInfo = packed record
    Kind: TTypeKind;
    NameLength: Byte;
  end;

  PFieldInfo = ^TFieldInfo;
  TFieldInfo = packed record
    TypeInfo: {$ifdef FPC}PTypeInfo{$else}PPTypeInfo{$endif};
    Offset: NativeInt;
  end;

  PFieldTable = ^TFieldTable;
  TFieldTable = packed record
    X: Word;
    Size: Cardinal;
    Count: Cardinal;
    Fields: array [0..0] of TFieldInfo;
  end;

  {$ifdef WEAKINTFREF}
  PWeakIntf = ^TWeakIntf;
  TWeakIntf = record
    [Weak] Intf: IInterface;
  end;
  {$endif}

  {$ifdef WEAKINSTREF}
  PWeakObj = ^TWeakObj;
  TWeakObj = record
    [Weak] Obj: TObject;
  end;

  PWeakMethod = ^TWeakMethod;
  TWeakMethod = record
    Method: procedure of object;
  end;
  {$endif}

{$ifdef FPC}
function int_copy(Src, Dest, TypeInfo: Pointer): SizeInt; [external name 'FPC_COPY'];
procedure int_initialize(Data, TypeInfo: Pointer); [external name 'FPC_INITIALIZE'];
procedure int_finalize(Data, TypeInfo: Pointer); [external name 'FPC_FINALIZE'];
{$endif}

procedure InitializeRecord(Source, TypeInfo: Pointer);
{$if Defined(FPC)}
begin
  int_initialize(Source, TypeInfo);
end;
{$elseif Defined(CPUINTELASM)}
asm
  jmp System.@InitializeRecord
end;
{$else}
begin
  System.InitializeArray(Source, TypeInfo, 1);
end;
{$ifend}

procedure FinalizeRecord(Source, TypeInfo: Pointer);
{$if Defined(FPC)}
begin
  int_finalize(Source, TypeInfo);
end;
{$elseif Defined(CPUINTELASM)}
asm
  jmp System.@FinalizeRecord
end;
{$else}
begin
  System.FinalizeArray(Source, TypeInfo, 1);
end;
{$ifend}

{$if Defined(FPC) or (CompilerVersion <= 30)}
procedure CopyRecord(Dest, Source, TypeInfo: Pointer);
{$if Defined(FPC)}
begin
  int_copy(Source, Dest, TypeInfo);
end;
{$elseif Defined(CPUINTELASM)}
asm
  jmp System.@CopyRecord
end;
{$else}
begin
  System.CopyArray(Dest, Source, TypeInfo, 1);
end;
{$ifend}
{$ifend}

{$if Defined(FPC) or (CompilerVersion <= 20)}
procedure InitializeArray(Source, TypeInfo: Pointer; Count: NativeUInt);
{$ifdef FPC}
var
  i, LItemSize: NativeInt;
  LItemPtr: Pointer;
begin
  LItemPtr := Source;

  case PTypeInfo(TypeInfo).Kind of
    tkVariant: LItemSize := SizeOf(TVarData);
    tkLString, tkWString, tkInterface, tkDynArray, tkAString: LItemSize := SizeOf(Pointer);
      tkArray, tkRecord, tkObject: LItemSize := PFieldTable(NativeInt(TypeInfo) + PTypeInfo(TypeInfo).NameLength).Size;
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
    tkVariant: LItemSize := SizeOf(TVarData);
    tkLString, tkWString, tkInterface, tkDynArray, tkAString: LItemSize := SizeOf(Pointer);
      tkArray, tkRecord, tkObject: LItemSize := PFieldTable(NativeInt(TypeInfo) + PTypeInfo(TypeInfo).NameLength).Size;
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

procedure CopyArray(Dest, Source, TypeInfo: Pointer; Count: NativeUInt);
{$ifdef FPC}
var
  i, LItemSize: NativeInt;
  LItemDest, LItemSrc: Pointer;
begin
  LItemDest := Dest;
  LItemSrc := Source;

  case PTypeInfo(TypeInfo).Kind of
    tkVariant: LItemSize := SizeOf(TVarData);
    tkLString, tkWString, tkInterface, tkDynArray, tkAString: LItemSize := SizeOf(Pointer);
      tkArray, tkRecord, tkObject: LItemSize := PFieldTable(NativeUInt(TypeInfo) + PTypeInfo(TypeInfo).NameLength).Size;
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
  cmp byte ptr [ecx], 13 // tkArray
  jne @1
  push eax
  push edx
    movzx edx, [ecx + 1] // TTypeInfo.Name
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
{$ifend}

procedure VarDataClear(var ASource: TVarData);
var
  LType: Integer;
begin
  LType := ASource.VType;

  if (LType and varDeepData <> 0) then
  case LType of
    varBoolean, varUnknown + 1..varUInt64: ;
  else
    if Assigned(System.VarClearProc) then
    begin
      System.VarClearProc(ASource);
    end else
    begin
      TinyError(teVarInvalidOp);
    end;
  end;
end;


{ Library API }

{$if Defined(EXTERNALLINKER)}
const
  LIB_TINY_TYPES = PLATFORM_OBJ_PATH + 'tiny.types.o';
{$else}
  {$if Defined(MSWINDOWS)}
    {$ifdef SMALLINT}
      {$L objs\win32\tiny.types.o}
    {$else}
      {$L objs\win64\tiny.types.o}
    {$endif}
  {$elseif Defined(ANDROID)}
    {$ifdef SMALLINT}
      {$L objs\android32\tiny.types.o}
    {$else}
      {$L objs\android64\tiny.types.o}
    {$endif}
  {$elseif Defined(IOS)}
    {$ifdef SMALLINT}
      {$L objs\ios32\tiny.types.o}
    {$else}
      {$L objs\ios64\tiny.types.o}
    {$endif}
  {$elseif Defined(MACOS)}
    {$ifdef SMALLINT}
      {$L objs\mac32\tiny.types.o}
    {$else}
      {$L objs\mac64\tiny.types.o}
    {$endif}
  {$else .LINUX}
    {$ifdef SMALLINT}
      {$L objs\linux32\tiny.types.o}
    {$else}
      {$L objs\linux64\tiny.types.o}
    {$endif}
  {$ifend}
{$ifend}

{$ifNdef OBJLINKNAME}
  {$ifdef UNICODE}
    {$L objs\win32\tiny.types.new86.o}
  {$else .OLD}
    {$L objs\win32\tiny.types.old86.o}
  {$endif}
{$endif}

procedure TaggedPtrCopy; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrCopy'{$endif};
procedure TaggedPtrRead; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrRead'{$endif};
procedure TaggedPtrWrite; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrWrite'{$endif};
procedure TaggedPtrExchange; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrExchange'{$endif};
function TaggedPtrCmpExchange; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrCmpExchange'{$endif};
function TaggedPtrChange; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrChange'{$endif};
function TaggedPtrInvalidate; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrInvalidate'{$endif};
function TaggedPtrValidate; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrValidate'{$endif};
function TaggedPtrPush; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrPush'{$endif};
function TaggedPtrPushCalcList; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrPushCalcList'{$endif};
function TaggedPtrPushList; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrPushList'{$endif};
function TaggedPtrPop; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrPop'{$endif};
function TaggedPtrPopList; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrPopList'{$endif};
function TaggedPtrPopReversed; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TaggedPtrPopReversed'{$endif};

{$ifNdef RETURNADDRESSSUPPORT}
function ReturnAddress; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'ReturnAddress'{$endif};
{$endif}

procedure TinyMove; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'TinyMove'{$endif};

function AStrLen; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'AStrLen'{$endif};
function WStrLen; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'WStrLen'{$endif};
function CStrLen; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'CStrLen'{$endif};

procedure OStrClear(var S{: ShortString});
begin
  PByte(@S)^ := 0;
end;

function OStrInit(var S{: ShortString}; const AChars: PAnsiChar; const ALength: Byte): PAnsiChar;
begin
  PByte(@S)^ := ALength;
  Result := PAnsiChar(@S) + 1;

  if (Assigned(AChars)) and (AChars <> Result) and (ALength <> 0) then
  begin
    TinyMove(AChars^, Result^, ALength);
  end;
end;

function OStrReserve(var S{: ShortString}; const ALength: Byte): PAnsiChar;
begin
  PByte(@S)^ := ALength;
  Result := PAnsiChar(@S) + 1;
end;

function OStrSetLength(var S{: ShortString}; const ALength: Byte): PAnsiChar;
begin
  PByte(@S)^ := ALength;
  Result := PAnsiChar(@S) + 1;
end;

procedure AStrClear; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(ANSISTRSUPPORT)}
      'AStrClear_nextgen'
    {$elseif not Defined(FPC)}
      'AStrClear_new'
    {$else .FPC}
      'AStrClear_fpc'
    {$ifend}
  {$endif};
function AStrInit; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(ANSISTRSUPPORT)}
      'AStrInit_nextgen'
    {$elseif not Defined(FPC)}
      'AStrInit_new'
    {$else .FPC}
      'AStrInit_fpc'
    {$ifend}
  {$endif};
function AStrReserve; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(ANSISTRSUPPORT)}
      'AStrReserve_nextgen'
    {$elseif not Defined(FPC)}
      'AStrReserve_new'
    {$else .FPC}
      'AStrReserve_fpc'
    {$ifend}
  {$endif};
function AStrSetLength; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(ANSISTRSUPPORT)}
      'AStrSetLength_nextgen'
    {$elseif not Defined(FPC)}
      'AStrSetLength_new'
    {$else .FPC}
      'AStrSetLength_fpc'
    {$ifend}
  {$endif};

procedure WStrClear; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if Defined(MSWINDOWS)}
      'WStrClear'
    {$elseif not Defined(FPC)}
      'UStrClear_new'
    {$else .FPC}
      'UStrClear_fpc'
    {$ifend}
  {$endif};
function WStrInit; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if Defined(MSWINDOWS)}
      'WStrInit'
    {$elseif not Defined(FPC)}
      'UStrInit_new'
    {$else .FPC}
      'UStrInit_fpc'
    {$ifend}
  {$endif};
function WStrReserve; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if Defined(MSWINDOWS)}
      'WStrReserve'
    {$elseif not Defined(FPC)}
      'UStrReserve_new'
    {$else .FPC}
      'UStrReserve_fpc'
    {$ifend}
  {$endif};
function WStrSetLength; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if Defined(MSWINDOWS)}
      'WStrSetLength'
    {$elseif not Defined(FPC)}
      'UStrSetLength_new'
    {$else .FPC}
      'UStrSetLength_fpc'
    {$ifend}
  {$endif};

procedure UStrClear; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(FPC)}
      'UStrClear_new'
    {$else .FPC}
      'UStrClear_fpc'
    {$ifend}
  {$endif};
function UStrInit; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(FPC)}
      'UStrInit_new'
    {$else .FPC}
      'UStrInit_fpc'
    {$ifend}
  {$endif};
function UStrReserve; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(FPC)}
      'UStrReserve_new'
    {$else .FPC}
      'UStrReserve_fpc'
    {$ifend}
  {$endif};
function UStrSetLength; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(FPC)}
      'UStrSetLength_new'
    {$else .FPC}
      'UStrSetLength_fpc'
    {$ifend}
  {$endif};

procedure CStrClear; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(FPC)}
      'CStrClear'
    {$else .FPC}
      'CStrClear_fpc'
    {$ifend}
  {$endif};
function CStrInit; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(FPC)}
      'CStrInit'
    {$else .FPC}
      'CStrInit_fpc'
    {$ifend}
  {$endif};
function CStrReserve; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(FPC)}
      'CStrReserve'
    {$else .FPC}
      'CStrReserve_fpc'
    {$ifend}
  {$endif};
function CStrSetLength; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name
    {$if not Defined(FPC)}
      'CStrSetLength'
    {$else .FPC}
      'CStrSetLength_fpc'
    {$ifend}
  {$endif};

function tm_to_timestamp(const Atm: Pointer): TimeStamp; external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'tm_to_timestamp'{$endif};

procedure preallocated_call(const AParam: Pointer; const ASize: NativeUInt;
  const ACallback: TPreallocatedCallback); external {$ifdef EXTERNALLINKER}LIB_TINY_TYPES{$endif}
  {$ifdef OBJLINKNAME}name 'preallocated_call'{$endif};


{ Auxiliary routine}

var
  INTERNAL_BUFFER: TBuffer;
  INTERNAL_BUFFER_MEMORY: array[0..8 * 1024 - 1] of Byte;

{$W+}
function TinyAlloc(const ASize: NativeUInt): Pointer;
begin
  if (GetCurrentThreadId <> MainThreadID) then
  begin
    raise TinyError(tePrivInstruction, ReturnAddress);
  end;

  Result := INTERNAL_BUFFER.{$ifdef BCB}This.{$endif}Alloc(ASize);
end;
{$W-}

{$W+}
function TinyAllocPacked(const ASize: NativeUInt): Pointer;
begin
  if (GetCurrentThreadId <> MainThreadID) then
  begin
    raise TinyError(tePrivInstruction, ReturnAddress);
  end;

  Result := INTERNAL_BUFFER.{$ifdef BCB}This.{$endif}AllocPacked(ASize);
end;
{$W-}

{$W+}
function TinyAllocAligned(const ASize: NativeUInt): Pointer;
begin
  if (GetCurrentThreadId <> MainThreadID) then
  begin
    raise TinyError(tePrivInstruction, ReturnAddress);
  end;

  Result := INTERNAL_BUFFER.{$ifdef BCB}This.{$endif}AllocAligned(ASize);
end;
{$W-}

{$W+}
function TinyAllocAligned2(const ASize: NativeUInt): Pointer;
begin
  if (GetCurrentThreadId <> MainThreadID) then
  begin
    raise TinyError(tePrivInstruction, ReturnAddress);
  end;

  Result := INTERNAL_BUFFER.{$ifdef BCB}This.{$endif}AllocAligned2(ASize);
end;
{$W-}

{$W+}
function TinyAllocAligned4(const ASize: NativeUInt): Pointer;
begin
  if (GetCurrentThreadId <> MainThreadID) then
  begin
    raise TinyError(tePrivInstruction, ReturnAddress);
  end;

  Result := INTERNAL_BUFFER.{$ifdef BCB}This.{$endif}AllocAligned4(ASize);
end;
{$W-}

{$W+}
function TinyAllocAligned8(const ASize: NativeUInt): Pointer;
begin
  if (GetCurrentThreadId <> MainThreadID) then
  begin
    raise TinyError(tePrivInstruction, ReturnAddress);
  end;

  Result := INTERNAL_BUFFER.{$ifdef BCB}This.{$endif}AllocAligned8(ASize);
end;
{$W-}

{$W+}
function TinyAllocAligned16(const ASize: NativeUInt): Pointer;
begin
  if (GetCurrentThreadId <> MainThreadID) then
  begin
    raise TinyError(tePrivInstruction, ReturnAddress);
  end;

  Result := INTERNAL_BUFFER.{$ifdef BCB}This.{$endif}AllocAligned16(ASize);
end;
{$W-}

{$W+}
procedure TinyAllocIncrease(const AMemory: Pointer; const ASize: NativeUInt);
begin
  if (GetCurrentThreadId <> MainThreadID) then
  begin
    raise TinyError(tePrivInstruction, ReturnAddress);
  end;

  INTERNAL_BUFFER.Increase(AMemory, ASize);
end;
{$W-}

procedure PreallocatedCall(const AParam: Pointer; const ASize: NativeUInt;
  const ACallback: TPreallocatedCallback);
const
  MAX_PREALLOCATED_SIZE = 80 * 1024;
var
  LMemory: Pointer;
begin
  if (ASize <= MAX_PREALLOCATED_SIZE) then
  begin
    preallocated_call(AParam, ASize, ACallback);
  end else
  begin
    GetMem(LMemory, ASize);
    try
      ACallback(AParam, LMemory, ASize);
    finally
      FreeMem(LMemory);
    end;
  end;
end;


{ TOSTime }

type
  PTimestampLocal = ^TTimestampLocal;
  TTimestampLocal = packed record
    DELTA: Int64;
    UTC_LIMIT: Int64;
  end;

var
  TIMESTAMP_LOCAL_BUFFER: array[0..7 + SizeOf(TTimestampLocal)] of Byte;
  TIMESTAMP_LOCAL: PTimestampLocal;
{$ifdef POSIX}
  TIMESTAMP_REALTIME_DELTA: Int64;
const
  TIMESTAMP_EPOCH_OFFSET = 134774 * TIMESTAMP_DAY;
  CLOCK_REALTIME_COARSE = 5;
  CLOCK_MONOTONIC_COARSE = 6;
{$endif}

{$ifdef POSIX}
class function TOSTime.InternalClockGetTime(const AClockId: Integer): Int64;
var
  LTimeSpec: timespec;
begin
  clock_gettime(AClockId, @LTimeSpec);
  Result := LTimeSpec.tv_sec * TIMESTAMP_SECOND + Trunc(LTimeSpec.tv_nsec * (1 / 100));
end;
{$endif}

class procedure TOSTime.Initialize;
{$ifdef POSIX}
var
  i: Integer;
  LDelta: Int64;
{$endif}
begin
  TIMESTAMP_LOCAL := Pointer(NativeInt(@TIMESTAMP_LOCAL_BUFFER[7]) and -8);

  {$ifdef POSIX}
  TIMESTAMP_REALTIME_DELTA := InternalClockGetTime(CLOCK_REALTIME_COARSE) - InternalClockGetTime(CLOCK_MONOTONIC_COARSE);
  for i := 1 to 10 do
  begin
    LDelta := InternalClockGetTime(CLOCK_REALTIME_COARSE) - InternalClockGetTime(CLOCK_MONOTONIC_COARSE);
    if (LDelta < TIMESTAMP_REALTIME_DELTA) then
      TIMESTAMP_REALTIME_DELTA := LDelta;
  end;
  TIMESTAMP_REALTIME_DELTA := TIMESTAMP_REALTIME_DELTA + TIMESTAMP_EPOCH_OFFSET;
  {$endif}
end;

{$if Defined(FPC) and Defined(UNIX)}
const
  libc = 'libc.so';

type
  tm = packed record
    tm_sec: Integer;            // Seconds. [0-60] (1 leap second)
    tm_min: Integer;            // Minutes. [0-59]
    tm_hour: Integer;           // Hours.[0-23]
    tm_mday: Integer;           // Day.[1-31]
    tm_mon: Integer;            // Month.[0-11]
    tm_year: Integer;           // Year since 1900
    tm_wday: Integer;           // Day of week [0-6] (Sunday = 0)
    tm_yday: Integer;           // Days of year [0-365]
    tm_isdst: Integer;          // Daylight Savings flag [-1/0/1]
    tm_gmtoff: Integer;         // Seconds east of UTC
    tm_zone: PAnsiChar;         // Timezone abbreviation
  end;
  Ptm = ^tm;

function localtime(var Timer: time_t): Ptm; cdecl; external libc name 'localtime';
function gmtime(var Timer: time_t): Ptm; cdecl; external libc name 'gmtime';
function usleep(useconds: NativeUInt): longint; cdecl; external libc name 'usleep';
{$ifend}

class function TOSTime.ToLocal(const AUTC: TimeStamp): TimeStamp;
{$ifdef MSWINDOWS}
begin
  if (not FileTimeToLocalFileTime(PFileTime(@AUTC)^, PFileTime(@Result)^)) then
  begin
    TinyError(teInvalidCast);
  end;
end;
{$else .POSIX}
var
  LTime: Int64;
  LSeconds: time_t;
  Ltm: Ptm;
begin
  LTime := AUTC - TIMESTAMP_EPOCH_OFFSET;
  LSeconds := LTime div TIMESTAMP_SECOND;
  Ltm := localtime(LSeconds);
  if (not Assigned(Ltm)) then
  begin
    TinyError(teInvalidCast);
  end;

  Result := tm_to_timestamp(Ltm) + (LTime - Int64(LSeconds) * TIMESTAMP_SECOND);
end;
{$endif}

class function TOSTime.ToUTC(const ALocal: TimeStamp): TimeStamp;
{$ifdef MSWINDOWS}
begin
  if (not LocalFileTimeToFileTime(PFileTime(@ALocal)^, PFileTime(@Result)^)) then
  begin
    TinyError(teInvalidCast);
  end
end;
{$else .POSIX}
var
  LTime: Int64;
  LSeconds: time_t;
  Ltm: Ptm;
begin
  LTime := ALocal - TIMESTAMP_EPOCH_OFFSET;
  LSeconds := LTime div TIMESTAMP_SECOND;
  Ltm := gmtime(LSeconds);
  if (not Assigned(Ltm)) then
  begin
    TinyError(teInvalidCast);
  end;

  Result := tm_to_timestamp(Ltm) + (LTime - Int64(LSeconds) * TIMESTAMP_SECOND);
end;
{$endif}

class function TOSTime.ToDateTime(const ATimeStamp: TimeStamp): TDateTime;
begin
  Result := (ATimeStamp - TIMESTAMP_DELTA) * (1 / TIMESTAMP_DAY);
end;

class function TOSTime.ToTimeStamp(const ADateTime: TDateTime): TimeStamp;
begin
  Result := Round(ADateTime * TIMESTAMP_DAY) + TIMESTAMP_DELTA;
end;

class function TOSTime.TickCount: Cardinal;
{$ifdef MSWINDOWS}
var
  LFileTime: TFileTime;
begin
  GetSystemTimeAsFileTime(LFileTime);
  Result := Round(TimeStamp(LFileTime) * (1 / TIMESTAMP_MILLISECOND));
end;
{$else .POSIX}
var
  LTimeSpec: timespec;
begin
  clock_gettime(CLOCK_MONOTONIC_COARSE, @LTimeSpec);
  Result := Cardinal(LTimeSpec.tv_sec * 1000 + Round(LTimeSpec.tv_nsec * (1 / 1000000)));
end;
{$endif}

class function TOSTime.InternalInitLocal(const AUTC: TimeStamp): TimeStamp;
const
  HALF_HOUR = TIMESTAMP_HOUR div 2;
  LIMIT_LOCKED = Low(Int64);
var
  LLocalDelta: Int64;
  LLocalUtcLimit: Int64;
  LValue: Int64;
begin
  // result
  Result := ToLocal(AUTC);
  LLocalDelta := (Result - AUTC);
  LLocalUtcLimit := (AUTC - AUTC mod HALF_HOUR) + HALF_HOUR;

  // lock
  repeat
    {$ifdef LARGEINT}
    LValue := TIMESTAMP_LOCAL.UTC_LIMIT;
    {$else}
    repeat
      LValue := TIMESTAMP_LOCAL.UTC_LIMIT;
    until (AtomicCmpExchange(TIMESTAMP_LOCAL.UTC_LIMIT, LValue, LValue) = LValue);
    {$endif}

    if (LValue = LIMIT_LOCKED) or (LValue >= LLocalUtcLimit) then
    begin
      Exit;
    end;
  until (AtomicCmpExchange(TIMESTAMP_LOCAL.UTC_LIMIT, LIMIT_LOCKED, LValue) = LValue);
  try
    // new delta
    TIMESTAMP_LOCAL.DELTA := LLocalDelta;
  finally
    // unlock
    {$ifdef LARGEINT}
    TIMESTAMP_LOCAL.UTC_LIMIT := LLocalUtcLimit;
    {$else}
    AtomicExchange(TIMESTAMP_LOCAL.UTC_LIMIT, LLocalUtcLimit);
    {$endif}
  end;
end;

class function TOSTime.Now: TimeStamp;
var
  LLocalDelta: Int64;
  LUtcTime: TimeStamp;
begin
  LLocalDelta := TIMESTAMP_LOCAL.DELTA;

  {$ifdef MSWINDOWS}
  GetSystemTimeAsFileTime(PFileTime(@LUtcTime)^);
  {$else .POSIX}
  LUtcTime := InternalClockGetTime(CLOCK_MONOTONIC_COARSE) + TIMESTAMP_REALTIME_DELTA;
  {$endif}

  if (LUtcTime < TIMESTAMP_LOCAL.UTC_LIMIT) and (LLocalDelta = TIMESTAMP_LOCAL.DELTA) then
  begin
    Result := LUtcTime + LLocalDelta;
  end else
  begin
    Result := InternalInitLocal(LUtcTime);
  end;
end;

class function TOSTime.UTCNow: TimeStamp;
{$ifdef MSWINDOWS}
var
  LFileTime: TFileTime;
begin
  GetSystemTimeAsFileTime(LFileTime);
  Result := TimeStamp(LFileTime);
end;
{$else .POSIX}
begin
  Result := InternalClockGetTime(CLOCK_MONOTONIC_COARSE) + TIMESTAMP_REALTIME_DELTA;
end;
{$endif}


{ TSyncYield }

{$ifdef STATICSUPPORT}
class function TSyncYield.Create: TSyncYield;
begin
  Result.FCount := 0;
end;
{$endif}

procedure TSyncYield.Reset;
begin
  FCount := 0;
end;

{$if Defined(FPC) and Defined(MSWINDOWS)}
function SwitchToThread: BOOL; stdcall; external kernel32 name 'SwitchToThread';
{$ifend}

{$ifNdef MSWINDOWS}
procedure SwitchToThread; inline;
begin
  sched_yield;
end;
{$endif}

procedure YieldProcessor;
{$ifdef CPUINTELASM} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  pause
end;
{$else}
begin
  SwitchToThread;
end;
{$endif}

procedure TSyncYield.Execute;
var
  LCount: Integer;
begin
  LCount := FCount;
  Inc(LCount);
  FCount := LCount;
  Dec(LCount);

  case (LCount and 7) of
    0..4: YieldProcessor;
    5, 6: SwitchToThread;
  else
    {$ifdef MSWINDOWS}
      Sleep(1);
    {$else .POSIX}
      usleep(1000);
    {$endif}
  end;
end;


{ TSyncSpinlock }

{$ifdef STATICSUPPORT}
class function TSyncSpinlock.Create: TSyncSpinlock;
begin
  Result.FValue := 0;
end;
{$endif}

procedure TSyncSpinlock.Reset;
begin
  FValue := 0;
end;

function TSyncSpinlock.GetLocked: Boolean;
begin
  Result := (FValue <> 0);
end;

function TSyncSpinlock.TryEnter: Boolean;
{$ifdef CPUINTELASM} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$if Defined(CPUX86)}
  xchg eax, ecx
  {$elseif Defined(POSIX)}
  xchg rdi, rcx
  {$ifend}
  mov edx, 1
  xor eax, eax

  {$ifdef CPUX86}
    cmp byte ptr [ECX].TSyncSpinlock.FValue, 0
    jne @done
    lock xchg byte ptr [ECX].TSyncSpinlock.FValue, dl
  {$else .CPUX64}
    cmp byte ptr [RCX].TSyncSpinlock.FValue, 0
    jne @done
    lock xchg byte ptr [RCX].TSyncSpinlock.FValue, dl
  {$endif}
@done:
  sete al
end;
{$else .NEXTGEN}
begin
  Result := (FValue = 0) and (AtomicCmpExchange(FValue, 1, 0) = 0);
end;
{$endif}

function TSyncSpinlock.Enter(const ATimeout: Cardinal): Boolean;
var
  LYield: TSyncYield;
  LTimeout, LTimeStart, LTimeFinish, LTimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
    begin
      Result := TryEnter;
    end;
    INFINITE:
    begin
      Enter();
      Result := True;
    end;
  else
    LTimeout := ATimeout;
    LYield.Reset;
    LTimeStart := TOSTime.TickCount;
    repeat
      Result := TryEnter;
      if (Result) then
        Exit;

      LTimeFinish := TOSTime.TickCount;
      LTimeDelta := LTimeFinish - LTimeStart;
      if (LTimeDelta >= LTimeout) then
        Break;
      Dec(LTimeout, LTimeDelta);
      LTimeStart := LTimeFinish;

      LYield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncSpinlock.InternalEnter;
var
  LYield: TSyncYield;
begin
  LYield.Reset;
  repeat
    LYield.Execute;
  until (TryEnter);
end;

procedure TSyncSpinlock.Enter;
begin
  if (not TryEnter) then
    InternalEnter;
end;

procedure TSyncSpinlock.Leave;
begin
  FValue := 0;
end;

function TSyncSpinlock.Wait(const ATimeout: Cardinal): Boolean;
var
  LYield: TSyncYield;
  LTimeout, LTimeStart, LTimeFinish, LTimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
    begin
      Result := (FValue = 0);
    end;
    INFINITE:
    begin
      Wait();
      Result := True;
    end;
  else
    LTimeout := ATimeout;
    LYield.Reset;
    LTimeStart := TOSTime.TickCount;
    repeat
      Result := (FValue = 0);
      if (Result) then
        Exit;

      LTimeFinish := TOSTime.TickCount;
      LTimeDelta := LTimeFinish - LTimeStart;
      if (LTimeDelta >= LTimeout) then
        Break;
      Dec(LTimeout, LTimeDelta);
      LTimeStart := LTimeFinish;

      LYield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncSpinlock.InternalWait;
var
  LYield: TSyncYield;
begin
  LYield.Reset;
  repeat
    LYield.Execute;
  until (FValue = 0);
end;

procedure TSyncSpinlock.Wait;
begin
  if (FValue <> 0) then
    InternalWait;
end;


{ TSyncLocker }

{$ifdef STATICSUPPORT}
class function TSyncLocker.Create: TSyncLocker;
begin
  Result.FValue := 0;
end;
{$endif}

procedure TSyncLocker.Reset;
begin
  FValue := 0;
end;

function TSyncLocker.GetLocked: Boolean;
begin
  Result := (FValue <> 0);
end;

function TSyncLocker.GetLockedRead: Boolean;
var
  LValue: Integer;
begin
  LValue := FValue;
  Result := (LValue <> 0) and (LValue and 1 = 0);
end;

function TSyncLocker.GetLockedExclusive: Boolean;
begin
  Result := (FValue and 1 <> 0);
end;

function TSyncLocker.TryEnterRead: Boolean;
var
  LValue: Integer;
begin
  LValue := FValue;
  if (LValue and 1 = 0) then
  begin
    LValue := AtomicIncrement(FValue, 2);
    if (LValue and 1 = 0) then
    begin
      Result := True;
      Exit;
    end else
    begin
      AtomicDecrement(FValue, 2)
    end;
  end;

  Result := False;
end;

function TSyncLocker.TryEnterExclusive: Boolean;
var
  LValue: Integer;
  LYield: TSyncYield;
begin
  repeat
    LValue := FValue;
    if (LValue and 1 <> 0) then
      Break;

    if (AtomicCmpExchange(FValue, LValue + 1, LValue) = LValue) then
    begin
      LYield.Reset;

      repeat
        if (FValue and -2 = 0) then
          Break;

        LYield.Execute;
      until (False);

      Result := True;
      Exit;
    end;
  until (False);

  Result := False;
end;

function TSyncLocker.EnterRead(const ATimeout: Cardinal): Boolean;
var
  LYield: TSyncYield;
  LTimeout, LTimeStart, LTimeFinish, LTimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
    begin
      Result := TryEnterRead;
    end;
    INFINITE:
    begin
      EnterRead();
      Result := True;
    end;
  else
    LTimeout := ATimeout;
    LYield.Reset;
    LTimeStart := TOSTime.TickCount;
    repeat
      Result := TryEnterRead;
      if (Result) then
        Exit;

      LTimeFinish := TOSTime.TickCount;
      LTimeDelta := LTimeFinish - LTimeStart;
      if (LTimeDelta >= LTimeout) then
        Break;
      Dec(LTimeout, LTimeDelta);
      LTimeStart := LTimeFinish;

      LYield.Execute;
    until (False);

    Result := False;
  end;
end;

function TSyncLocker.EnterExclusive(const ATimeout: Cardinal): Boolean;
var
  LYield: TSyncYield;
  LTimeout, LTimeStart, LTimeFinish, LTimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
    begin
      Result := TryEnterExclusive;
    end;
    INFINITE:
    begin
      EnterExclusive();
      Result := True;
    end;
  else
    LTimeout := ATimeout;
    LYield.Reset;
    LTimeStart := TOSTime.TickCount;
    repeat
      Result := TryEnterExclusive;
      if (Result) then
        Exit;

      LTimeFinish := TOSTime.TickCount;
      LTimeDelta := LTimeFinish - LTimeStart;
      if (LTimeDelta >= LTimeout) then
        Break;
      Dec(LTimeout, LTimeDelta);
      LTimeStart := LTimeFinish;

      LYield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncLocker.InternalEnterRead;
var
  LYield: TSyncYield;
begin
  LYield.Reset;
  repeat
    LYield.Execute;
  until (TryEnterRead);
end;

procedure TSyncLocker.EnterRead;
var
  LValue: Integer;
begin
  // if (not inline TryEnterRead) then
  //   InternalEnterRead;

  LValue := FValue;
  if (LValue and 1 = 0) then
  begin
    LValue := AtomicIncrement(FValue, 2);
    if (LValue and 1 = 0) then
    begin
      Exit;
    end else
    begin
      AtomicDecrement(FValue, 2)
    end;
  end;

  InternalEnterRead;
end;

procedure TSyncLocker.InternalEnterExclusive;
var
  LYield: TSyncYield;
begin
  LYield.Reset;
  repeat
    LYield.Execute;
  until (TryEnterExclusive);
end;

procedure TSyncLocker.EnterExclusive;
begin
  if (not TryEnterExclusive) then
    InternalEnterExclusive;
end;

procedure TSyncLocker.LeaveRead;
begin
  AtomicDecrement(FValue, 2);
end;

procedure TSyncLocker.LeaveExclusive;
begin
  AtomicDecrement(FValue, 1);
end;

function TSyncLocker.Wait(const ATimeout: Cardinal): Boolean;
var
  LYield: TSyncYield;
  LTimeout, LTimeStart, LTimeFinish, LTimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
    begin
      Result := (FValue = 0);
    end;
    INFINITE:
    begin
      Wait();
      Result := True;
    end;
  else
    LTimeout := ATimeout;
    LYield.Reset;
    LTimeStart := TOSTime.TickCount;
    repeat
      Result := (FValue = 0);
      if (Result) then
        Exit;

      LTimeFinish := TOSTime.TickCount;
      LTimeDelta := LTimeFinish - LTimeStart;
      if (LTimeDelta >= LTimeout) then
        Break;
      Dec(LTimeout, LTimeDelta);
      LTimeStart := LTimeFinish;

      LYield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncLocker.InternalWait;
var
  LYield: TSyncYield;
begin
  LYield.Reset;
  repeat
    LYield.Execute;
  until (FValue = 0);
end;

procedure TSyncLocker.Wait;
begin
  if (FValue <> 0) then
    InternalWait;
end;


{ TSyncSmallLocker }

function SmallLockerCAS(var AValue: Byte; const ANewValue, AComparand: Byte): Boolean; {$ifNdef CPUINTELASM}inline;{$endif}
{$ifdef CPUINTELASM} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$if Defined(CPUX86)}
    xchg eax, ecx
    cmp byte ptr [ECX], al
    jne @done
    lock xchg byte ptr [ECX], dl
  {$elseif Defined(POSIX)}
    mov rax, rdx
    xchg rdx, rsi
    cmp byte ptr [RDI], al
    jne @done
    lock xchg byte ptr [RDI], dl
  {$else .CPUX64}
    xchg rax, r8
    cmp byte ptr [RCX], al
    jne @done
    lock xchg byte ptr [RCX], dl
  {$ifend}
@done:
  sete al
end;
{$else .NEXTGEN}
begin
  Result := (AValue = AComparand) and (AtomicCmpExchange(AValue, ANewValue, AComparand) = AComparand);
end;
{$endif}

{$ifdef STATICSUPPORT}
class function TSyncSmallLocker.Create: TSyncSmallLocker;
begin
  Result.FValue := 0;
end;
{$endif}

procedure TSyncSmallLocker.Reset;
begin
  FValue := 0;
end;

function TSyncSmallLocker.GetLocked: Boolean;
begin
  Result := (FValue <> 0);
end;

function TSyncSmallLocker.GetLockedRead: Boolean;
var
  LValue: Integer;
begin
  LValue := FValue;
  Result := (LValue <> 0) and (LValue and 1 = 0);
end;

function TSyncSmallLocker.GetLockedExclusive: Boolean;
begin
  Result := (FValue and 1 <> 0);
end;

function TSyncSmallLocker.TryEnterRead: Boolean;
var
  LValue: Integer;
begin
  repeat
    LValue := FValue;
    if (LValue and 1 <> 0) or (LValue = 254) then
      Break;

    if (SmallLockerCAS(FValue, LValue + 2, LValue)) then
    begin
      Result := True;
      Exit;
    end;
  until (False);

  Result := False;
end;

function TSyncSmallLocker.TryEnterExclusive: Boolean;
var
  LValue: Integer;
  LYield: TSyncYield;
begin
  repeat
    LValue := FValue;
    if (LValue and 1 <> 0) then
      Break;

    if (SmallLockerCAS(FValue, LValue + 1, LValue)) then
    begin
      LYield.Reset;

      repeat
        if (FValue and -2 = 0) then
          Break;

        LYield.Execute;
      until (False);

      Result := True;
      Exit;
    end;
  until (False);

  Result := False;
end;

function TSyncSmallLocker.EnterRead(const ATimeout: Cardinal): Boolean;
var
  LYield: TSyncYield;
  LTimeout, LTimeStart, LTimeFinish, LTimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
    begin
      Result := TryEnterRead;
    end;
    INFINITE:
    begin
      EnterRead();
      Result := True;
    end;
  else
    LTimeout := ATimeout;
    LYield.Reset;
    LTimeStart := TOSTime.TickCount;
    repeat
      Result := TryEnterRead;
      if (Result) then
        Exit;

      LTimeFinish := TOSTime.TickCount;
      LTimeDelta := LTimeFinish - LTimeStart;
      if (LTimeDelta >= LTimeout) then
        Break;
      Dec(LTimeout, LTimeDelta);
      LTimeStart := LTimeFinish;

      LYield.Execute;
    until (False);

    Result := False;
  end;
end;

function TSyncSmallLocker.EnterExclusive(const ATimeout: Cardinal): Boolean;
var
  LYield: TSyncYield;
  LTimeout, LTimeStart, LTimeFinish, LTimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
    begin
      Result := TryEnterExclusive;
    end;
    INFINITE:
    begin
      EnterExclusive();
      Result := True;
    end;
  else
    LTimeout := ATimeout;
    LYield.Reset;
    LTimeStart := TOSTime.TickCount;
    repeat
      Result := TryEnterExclusive;
      if (Result) then
        Exit;

      LTimeFinish := TOSTime.TickCount;
      LTimeDelta := LTimeFinish - LTimeStart;
      if (LTimeDelta >= LTimeout) then
        Break;
      Dec(LTimeout, LTimeDelta);
      LTimeStart := LTimeFinish;

      LYield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncSmallLocker.InternalEnterRead;
var
  LYield: TSyncYield;
begin
  LYield.Reset;
  repeat
    LYield.Execute;
  until (TryEnterRead);
end;

procedure TSyncSmallLocker.EnterRead;
begin
  if (not TryEnterRead) then
    InternalEnterRead;
end;

procedure TSyncSmallLocker.InternalEnterExclusive;
var
  LYield: TSyncYield;
begin
  LYield.Reset;
  repeat
    LYield.Execute;
  until (TryEnterExclusive);
end;

procedure TSyncSmallLocker.EnterExclusive;
begin
  if (not TryEnterExclusive) then
    InternalEnterExclusive;
end;

procedure TSyncSmallLocker.LeaveRead;
{$ifdef CPUINTELASM} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  mov edx, -2

  {$if Defined(CPUX86)}
  lock xadd [EAX].FValue, dl
  {$elseif Defined(POSIX)}
  lock xadd [RDI].FValue, dl
  {$else .CPUX64}
  lock xadd [RCX].FValue, dl
  {$ifend}
end;
{$else .NEXTGEN}
begin
  AtomicDecrement(FValue, 2);
end;
{$endif}

procedure TSyncSmallLocker.LeaveExclusive;
{$ifdef CPUINTELASM} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  or edx, -1

  {$if Defined(CPUX86)}
  lock xadd [EAX].FValue, dl
  {$elseif Defined(POSIX)}
  lock xadd [RDI].FValue, dl
  {$else .CPUX64}
  lock xadd [RCX].FValue, dl
  {$ifend}
end;
{$else .NEXTGEN}
begin
  AtomicDecrement(FValue, 1);
end;
{$endif}

function TSyncSmallLocker.Wait(const ATimeout: Cardinal): Boolean;
var
  LYield: TSyncYield;
  LTimeout, LTimeStart, LTimeFinish, LTimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
    begin
      Result := (FValue = 0);
    end;
    INFINITE:
    begin
      Wait();
      Result := True;
    end;
  else
    LTimeout := ATimeout;
    LYield.Reset;
    LTimeStart := TOSTime.TickCount;
    repeat
      Result := (FValue = 0);
      if (Result) then
        Exit;

      LTimeFinish := TOSTime.TickCount;
      LTimeDelta := LTimeFinish - LTimeStart;
      if (LTimeDelta >= LTimeout) then
        Break;
      Dec(LTimeout, LTimeDelta);
      LTimeStart := LTimeFinish;

      LYield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncSmallLocker.InternalWait;
var
  LYield: TSyncYield;
begin
  LYield.Reset;
  repeat
    LYield.Execute;
  until (FValue = 0);
end;

procedure TSyncSmallLocker.Wait;
begin
  if (FValue <> 0) then
    InternalWait;
end;


{ TTinyObject }

{$ifNdef STATICSUPPORT}
const
  objDestroyingFlag = Integer($80000000);
  objDisposedFlag = Integer($40000000);
  objNonConstructedFlag = Integer($20000000);
  objSingleThreadFlag = Integer($10000000);
  objStorageShift = 25;
  objStorageMask = Integer(High(TInstanceStorage)) shl objStorageShift;
  objRefCountMask = objDestroyingFlag + (1 shl objStorageShift - 1);
  objDefaultRefCount = {$ifdef AUTOREFCOUNT}1{$else}0{$endif};
  objInvalidRefCount = objNonConstructedFlag + (objRefCountMask xor (1 shl (objStorageShift - 1))) + (Ord(isPreallocated) shl objStorageShift);
  {$ifNdef AUTOREFCOUNT}
  vmtObjAddRef = {$ifdef FPC}System.vmtToString + SizeOf(Pointer){$else}0{$endif};
  vmtObjRelease = vmtObjAddRef + SizeOf(Pointer);
  {$endif}
  {$if Defined(FPC) or not Defined(UNICODE)}
  vmtToString = vmtObjRelease + SizeOf(Pointer);
  {$ifend}
{$endif}

function TTinyObject.QueryInterface({$ifdef FPC}constref{$else}const{$endif} IID: TGUID;
  out Obj): {$if (not Defined(FPC)) or Defined(MSWINDOWS)}HResult{$else}Longint{$ifend};
begin
  if GetInterface(IID, Obj) then
  begin
    Result := 0;
  end else
  begin
    Result := E_NOINTERFACE;
  end;
end;

function TTinyObject.__ObjAddRef: Integer;
var
  LRefCount: Integer;
begin
  LRefCount := FRefCount;
  Result := objRefCountMask;
  Result := Result and LRefCount;
  if (LRefCount and objSingleThreadFlag <> 0) or (Cardinal(Result) <= 1) then
  begin
    Inc(LRefCount);
    Inc(Result);
    FRefCount := LRefCount;
  end else
  begin
    Result := AtomicIncrement(FRefCount) and objRefCountMask;
  end;
end;

function TTinyObject._AddRef: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer{$else}Longint{$ifend};
var
  LRefCount: Integer;
begin
  if (PPointer(PNativeInt(Self)^ + vmtObjAddRef)^ <> @TTinyObject.__ObjAddRef) then
  begin
    Result := __ObjAddRef;
    Exit;
  end;

  LRefCount := FRefCount;
  Result := objRefCountMask;
  Result := Result and LRefCount;
  if (LRefCount and objSingleThreadFlag <> 0) or (Cardinal(Result) <= 1) then
  begin
    Inc(LRefCount);
    Inc(Result);
    FRefCount := LRefCount;
  end else
  begin
    Result := AtomicIncrement(FRefCount) and objRefCountMask;
  end;
end;

function TTinyObject.__ObjRelease: Integer;
var
  LRefCount: Integer;
begin
  LRefCount := FRefCount;
  Result := objRefCountMask;
  Result := Result and LRefCount;
  if (LRefCount and objSingleThreadFlag <> 0) or (Result = 1) then
  begin
    Dec(LRefCount);
    Dec(Result);
    FRefCount := LRefCount;
    if (Result <> 0) then
    begin
      Exit;
    end;
  end else
  begin
    Result := AtomicDecrement(FRefCount) and objRefCountMask;
    if (Result <> 0) then
    begin
      Exit;
    end;
  end;

  LRefCount := FRefCount;
  if (LRefCount and objDisposedFlag = 0) then
  begin
    FRefCount := LRefCount or (objDestroyingFlag or objDisposedFlag);
    Destroy;
  end else
  begin
    FreeInstance;
  end;

  Result := 0;
end;

function TTinyObject._Release: {$if (not Defined(FPC)) or Defined(MSWINDOWS)}Integer{$else}Longint{$ifend};
var
  LRefCount: Integer;
begin
  if (PPointer(PNativeInt(Self)^ + vmtObjRelease)^ <> @TTinyObject.__ObjRelease) then
  begin
    Result := __ObjRelease;
    Exit;
  end;

  LRefCount := FRefCount;
  Result := objRefCountMask;
  Result := Result and LRefCount;
  if (LRefCount and objSingleThreadFlag <> 0) or (Result = 1) then
  begin
    Dec(LRefCount);
    Dec(Result);
    FRefCount := LRefCount;
    if (Result <> 0) then
    begin
      Exit;
    end;
  end else
  begin
    Result := AtomicDecrement(FRefCount) and objRefCountMask;
    if (Result <> 0) then
    begin
      Exit;
    end;
  end;

  LRefCount := FRefCount;
  if (LRefCount and objDisposedFlag = 0) then
  begin
    FRefCount := LRefCount or (objDestroyingFlag or objDisposedFlag);
    Destroy;
  end else
  begin
    FreeInstance;
  end;

  Result := 0;
end;

function TTinyObject.ToString: UnicodeString;
var
  LClassName: PShortString;
  {$ifNdef SHORTSTRSUPPORT}
  LSource: Pointer;
  LSourceCount, LTargetCount: Integer;
  {$endif}
begin
  LClassName := PPointer(PNativeInt(Self)^ + vmtClassName)^;

  {$ifdef SHORTSTRSUPPORT}
    Result := UnicodeString(LClassName^);
  {$else .NEXTGEN}
    LSourceCount := PByte(LClassName)^;
    LSource := @LClassName^[1];
    LTargetCount := UnicodeFromLocaleChars(65001, 0, LSource, LSourceCount, nil, 0);
    SetLength(Result, LTargetCount);
    UnicodeFromLocaleChars(65001, 0, LSource, LSourceCount, Pointer(Result), LTargetCount);
  {$endif}
end;

function TTinyObject.GetSelf: TTinyObject;
begin
  Result := Self;
end;

function TTinyObject.GetStorage: TInstanceStorage;
begin
  Result := TInstanceStorage((FRefCount and objStorageMask) shr objStorageShift);
end;

function TTinyObject.GetDisposed: Boolean;
begin
  Result := (FRefCount and objDisposedFlag <> 0);
end;

function TTinyObject.GetConstructed: Boolean;
begin
  Result := (FRefCount and objNonConstructedFlag = 0);
end;

function TTinyObject.GetSingleThread: Boolean;
begin
  Result := (FRefCount and objSingleThreadFlag <> 0);
end;

procedure TTinyObject.SetSingleThread(const AValue: Boolean);
var
  LRefCount: Integer;
begin
  LRefCount := FRefCount;

  if (AValue) then
  begin
    if (LRefCount and objSingleThreadFlag = 0) then
    begin
      FRefCount := LRefCount + objSingleThreadFlag;
    end;
  end else
  begin
    if (LRefCount and objSingleThreadFlag <> 0) then
    begin
      FRefCount := LRefCount and (not objSingleThreadFlag);
    end;
  end;
end;

function TTinyObject.GetRefCount: Integer;
begin
  Result := FRefCount and objRefCountMask;
end;

function TTinyObject.GetAllocator: Pointer{IAllocator};
begin
  Result := FAllocator;
end;

constructor TTinyObject.PreallocatedCreate(const AParam: Pointer;
  const ABuffer: Pointer; const ASize: NativeUInt);
begin
  {inherited Create;}
end;

class function TTinyObject.PreallocatedBufferSize(const AParam, AThreadBufferMemory: Pointer;
  const AThreadBufferMargin: NativeUInt): NativeInt;
begin
  {
    Note:
    The size of the extra buffer involved in the preallocation call
    A negative value means that the buffer must continue the address space of the object
  }
  Result := 0;
end;

type
  PPrecallocatedParam = ^TPrecallocatedParam;
  TPrecallocatedParam = packed record
    ClassType: TTinyObjectClass;
    Param: Pointer;
    InstanceSize: NativeUInt;
    Buffer: Pointer;
    BufferSize: NativeUInt;
  end;

procedure TinyObjectPreallocatedExecute(const AParam: Pointer;
  const AMemory: Pointer; const ASize: NativeUInt);
var
  LInternalParam: PPrecallocatedParam;
  {$ifdef AUTOREFCOUNT}[Unsafe]{$endif} LObject: TTinyObject;
begin
  LInternalParam := AParam;
  if (not Assigned(LInternalParam.Buffer)) and (LInternalParam.BufferSize <> 0) then
  begin
    LInternalParam.Buffer := Pointer(NativeUInt(AMemory) + LInternalParam.InstanceSize);
  end;

  LObject := LInternalParam.ClassType.NewInstance(AMemory, isPreallocated, nil);
  LObject.PreallocatedCreate(LInternalParam.Param, LInternalParam.Buffer, LInternalParam.BufferSize);
  LObject.Destroy;
end;

class procedure TTinyObject.PreallocatedExecute(const AParam: Pointer;
  const AUseThreadBuffer: Boolean);
var
  LPrecallocatedParam: TPrecallocatedParam;
  LThreadBuffer: PThreadBuffer;
  LThreadBufferSize: NativeUInt;
  LThreadBufferMemory: Pointer;
  LThreadBufferMargin: NativeUInt;
  LBufferSize: NativeInt;
  LTotalSize: NativeUInt;
begin
  LPrecallocatedParam.ClassType := Self;
  LPrecallocatedParam.Param := AParam;
  LPrecallocatedParam.InstanceSize := NativeUInt((NativeInt(PInteger(NativeInt(Self) + vmtInstanceSize)^) + (DEFAULT_MEMORY_ALIGN - 1)) and -DEFAULT_MEMORY_ALIGN);
  LPrecallocatedParam.Buffer := nil;
  LPrecallocatedParam.BufferSize := 0;

  if (AUseThreadBuffer) then
  begin
    LThreadBuffer := @THREAD_BUFFER;
    LThreadBufferSize := LThreadBuffer.Size;
    LThreadBufferMemory := Pointer((NativeInt(@LThreadBuffer.Bytes[LThreadBufferSize]) + (DEFAULT_MEMORY_ALIGN - 1)) and -DEFAULT_MEMORY_ALIGN);
    LThreadBufferMargin := NativeUInt(NativeInt(@LThreadBuffer.Bytes) + THREAD_BUFFER_SIZE - NativeInt(LThreadBufferMemory));
    if (NativeInt(LThreadBufferMargin) < DEFAULT_MEMORY_ALIGN) then
    begin
      LThreadBuffer := nil;
      LThreadBufferMemory := nil;
      LThreadBufferMargin := 0;
    end;
  end else
  begin
    LThreadBuffer := nil;
    LThreadBufferSize := 0;
    LThreadBufferMemory := nil;
    LThreadBufferMargin := 0;
  end;
  LBufferSize := PreallocatedBufferSize(AParam, LThreadBufferMemory, LThreadBufferMargin);

  try
    LPrecallocatedParam.BufferSize := Abs(LBufferSize);
    LTotalSize := LPrecallocatedParam.InstanceSize + LPrecallocatedParam.BufferSize;

    if (LThreadBufferMargin < LPrecallocatedParam.BufferSize) then
    begin
      // stack: object + buffer
      PreallocatedCall(@LPrecallocatedParam, LTotalSize, TinyObjectPreallocatedExecute);
    end else
    if (LThreadBufferMargin >= LTotalSize) then
    begin
      // thread buffer: object + buffer
      LThreadBuffer.Size := THREAD_BUFFER_SIZE - (LThreadBufferMargin - LTotalSize);
      TinyObjectPreallocatedExecute(@LPrecallocatedParam, LThreadBufferMemory, LTotalSize);
    end else
    begin
      // stack: object, thread buffer: buffer
      LPrecallocatedParam.Buffer := LThreadBufferMemory;
      LThreadBuffer.Size := THREAD_BUFFER_SIZE - (LThreadBufferMargin - LPrecallocatedParam.BufferSize);
      PreallocatedCall(@LPrecallocatedParam, LPrecallocatedParam.InstanceSize, TinyObjectPreallocatedExecute);
    end;
  finally
    if (Assigned(LThreadBuffer)) then
    begin
      LThreadBuffer.Size := LThreadBufferSize;
    end;
  end;
end;

class function TTinyObject.NewInstance(const APtr: Pointer; const AStorage: TInstanceStorage;
  const AAllocator: Pointer): TTinyObject;
label
  _0, _1, _2, _3, _4, _5, _6, _7, _8;
type
  InternalPointerArray = array[0..High(Integer) div SizeOf(Pointer) - 1] of Pointer;
var
  LSize: NativeUInt;
  LPtr: ^InternalPointerArray;
  LNull: Pointer;
  LClass: TClass;
  LTable: PInterfaceTable;
  LEntry, LTopEntry: PInterfaceEntry;
  LValue: Pointer;
begin
  // initialization
  LPtr := APtr;
  LPtr[0] := Self;
  LPtr[1]{FRefCount} := Pointer(NativeUInt((1 + objNonConstructedFlag) + (Ord(AStorage) shl objStorageShift)));
  LPtr[2] := AAllocator;
  LSize := PCardinal(NativeInt(Self) + vmtInstanceSize)^;
  PPointer(NativeUInt(LPtr) + LSize - SizeOf(Pointer))^ := nil;
  LPtr[3] := PInterfaceTable(PPointer(NativeInt(TTinyObject) + vmtIntfTable)^).Entries[0].VTable;

  // clear
  Dec(LSize, 4 * SizeOf(Pointer));
  Inc(NativeInt(LPtr), 4 * SizeOf(Pointer));
  LSize := LSize shr {$ifdef LARGEINT}3{$else .SMALLINT}2{$endif};
  LNull := nil;
  case (LSize) of
    8: goto _8;
    7: goto _7;
    6: goto _6;
    5: goto _5;
    4: goto _4;
    3: goto _3;
    2: goto _2;
    1: goto _1;
    0: goto _0;
  else
    FillChar(LPtr^, LSize shl {$ifdef LARGEINT}3{$else .SMALLINT}2{$endif}, #0);
    goto _0;
  end;
  _8: LPtr[7] := LNull;
  _7: LPtr[6] := LNull;
  _6: LPtr[5] := LNull;
  _5: LPtr[4] := LNull;
  _4: LPtr[3] := LNull;
  _3: LPtr[2] := LNull;
  _2: LPtr[1] := LNull;
  _1: LPtr[0] := LNull;
  _0: Dec(NativeInt(LPtr), 4 * SizeOf(Pointer));

  // interfaces
  LClass := {$ifdef CPUX86}PPointer(LPtr)^{$else}Self{$endif};
  if (LClass <> TTinyObject) then
  repeat
    LTable := PInterfaceTable(PPointer(NativeInt(LClass) + vmtIntfTable)^);
    if (Assigned(LTable)) then
    begin
      LTopEntry := @LTable.Entries[LTable.EntryCount];
      LEntry := @LTable.Entries[0];
      if (LEntry <> LTopEntry) then
      repeat
        LValue := LEntry.VTable;
        if (Assigned(LValue)) then
          PPointer(NativeInt(LPtr) + LEntry.IOffset)^ := LValue;

        Inc(LEntry);
      until (LEntry = LTopEntry);
    end;

    {$ifdef FPC}
      LClass := TClass(PPointer(NativeInt(LClass) + vmtParent)^);
    {$else .DELPHI}
      LClass := TClass(PPointer(PPointer(NativeInt(LClass) + vmtParent)^)^);
    {$endif}
  until (LClass = TTinyObject);

  // result
  Result := Pointer(LPtr);
end;

class function TTinyObject.NewInstance: TObject;
var
  LPtr: Pointer;
begin
  GetMem(LPtr, PInteger(NativeInt(Self) + vmtInstanceSize)^);
  Result := NewInstance(LPtr, isHeap, nil);
end;

{$if Defined(WEAKREF) and Defined(CPUINTELASM)}
procedure _CleanupInstance(Instance: Pointer);
asm
  jmp System.@CleanupInstance
end;
{$ifend}

procedure TTinyObject.FreeInstance;
label
  next_field, next_class, free_memory;
type
  PAllocatorVmt = ^TAllocatorVmt;
  TAllocatorVmt = packed record
    Base: TInterfaceVmt;
    Alloc: function(const AInstance: Pointer): Pointer;
    Release: procedure(const AInstance: Pointer; const Value: Pointer);
  end;

  PAllocatorInstance = ^TAllocatorInstance;
  TAllocatorInstance = packed record
    Vmt: PAllocatorVmt;
  end;
var
  {$if (not Defined(WEAKREF)) or Defined(CPUINTELASM) or (CompilerVersion >= 32)}
  LClass: TClass;
  LTypeInfo: PTypeInfo;
  {$ifdef MONITORSUPPORT}
  LSize: Integer;
  LMonitor, LMonitorFlags: NativeInt;
  LLockEvent: Pointer;
  {$endif}
  LFieldTable: PFieldTable;
  LField, LTopField: PFieldInfo;
  {$ifdef WEAKREF}
  LWeakMode: Boolean;
  {$endif}
  LPtr: Pointer;
  VType: Integer;
  {$ifend}
  LAllocator: PAllocatorInstance;
begin
  {$if (not Defined(WEAKREF)) or Defined(CPUINTELASM) or (CompilerVersion >= 32)}
    // monitor start, weak references
    {$ifdef MONITORSUPPORT} // XE2+
    LSize := PInteger(PNativeInt(Self)^ + vmtInstanceSize)^;
    LMonitorFlags := PNativeInt(NativeInt(Self) + LSize + (- hfFieldSize + hfMonitorOffset))^;
    {$if CompilerVersion >= 32}
    if (LMonitorFlags and monWeakReferencedFlag <> 0) then
    {$ifend}
    {$endif}
    {$ifdef WEAKREF}
    begin
      {$ifdef CPUINTELASM}
      _CleanupInstance(Pointer(Self));
      {$else .NEXTGEN}
      Self.CleanupInstance;
      goto free_memory;
      {$endif}
    end;
    {$endif}

    // monitor finish
    {$ifdef MONITORSUPPORT}
    LMonitor := LMonitorFlags {$if CompilerVersion >= 32}and monMonitorMask{$ifend};
    if (LMonitor <> 0) then
    begin
      LLockEvent := PPointer(LMonitor + (SizeOf(Integer) + SizeOf(Integer) + SizeOf(System.TThreadID)))^;
      if Assigned(LLockEvent) then
      begin
        MonitorSupport.FreeSyncObject(LLockEvent);
      end;

      FreeMem(Pointer(LMonitor));
    end;
    {$endif}

    // fields
    LClass := PPointer(Self)^;
    if (LClass <> TTinyObject) then
    repeat
      LTypeInfo := PPointer(NativeInt(LClass) + vmtInitTable)^;
      if (not Assigned(LTypeInfo)) then
        goto next_class;

      LFieldTable := Pointer(NativeInt(LTypeInfo) + LTypeInfo.NameLength);
      if (LFieldTable.Count = 0) then
        goto next_class;

      {$ifdef WEAKREF}
      LWeakMode := False;
      {$endif}
      LTopField := @LFieldTable.Fields[LFieldTable.Count];
      LField := @LFieldTable.Fields[0];
      repeat
        LPtr := Pointer(NativeInt(Self) + NativeInt(LField.Offset));

        {$ifdef WEAKREF}
        if (LField.TypeInfo = nil) then
        begin
          LWeakMode := True;
          goto next_field;
        end;
        if (not LWeakMode) then
        begin
        {$endif}
          case (LField.TypeInfo^.Kind) of
            tkVariant:
            begin
              VType := Word(LPtr^);
              if (VType and varDeepData <> 0) and (VType <> varBoolean) and
                (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
                VarDataClear(PVarData(LPtr)^);
            end;
            {$ifdef AUTOREFCOUNT}
            tkClass:
            begin
              if Assigned(PPointer(LPtr)^) then
                TObject(PPointer(LPtr)^).__ObjRelease;
            end;
            {$endif}
            {$ifdef MSWINDOWS}
            tkWString:
            begin
              LPtr := PPointer(LPtr)^;
              if Assigned(LPtr) then
                MMSysStrFree(LPtr)
            end;
            {$else}
            tkWString,
            {$endif}
            {$ifdef FPC}tkAString,{$endif}
            {$ifdef UNICODE}tkUString,{$endif}
            tkLString:
            begin
              if Assigned(PPointer(LPtr)^) then
                AStrClear(PPointer(LPtr)^);
            end;
            tkInterface:
            begin
              LPtr := PPointer(LPtr)^;
              if Assigned(LPtr) then
                PInterfaceInstance(LPtr).Vmt._Release(LPtr);
            end;
            tkDynArray:
            begin
              if Assigned(PPointer(LPtr)^) then
                SysFinalDynArray(LPtr, LField.TypeInfo{$ifNdef FPC}^{$endif});
            end;
            tkArray{static array}:
            begin
              FinalizeArray(LPtr, LField.TypeInfo{$ifNdef FPC}^{$endif}, LFieldTable.Count);
            end;
            {$ifdef FPC}tkObject,{$endif}
            {$ifdef MANAGEDRECORDS}tkMRecord,{$endif}
            tkRecord:
            begin
              FinalizeRecord(LPtr, LField.TypeInfo{$ifNdef FPC}^{$endif});
            end;
          end;
        {$ifdef WEAKREF}
        end else
        case LField.TypeInfo^.Kind of
        {$ifdef WEAKINTFREF}
          tkInterface:
          begin
            if Assigned(PPointer(LPtr)^) then
              PWeakIntf(LPtr).Intf := nil;
          end;
        {$endif}
        {$ifdef WEAKINSTREF}
          tkClass:
          begin
            if Assigned(PPointer(LPtr)^) then
              PWeakObj(LPtr).Obj := nil;
          end;
          tkMethod:
          begin
            if Assigned(PMethod(LPtr)^.Data) then
              PWeakMethod(LPtr).Method := nil;
          end;
        {$endif}
        end;
        {$endif .WEAKREF}

      next_field:
        Inc(LField);
      until (LField = LTopField);

    next_class:
      {$ifdef FPC}
        LClass := TClass(PPointer(NativeInt(LClass) + vmtParent)^);
      {$else .DELPHI}
        LClass := TClass(PPointer(PPointer(NativeInt(LClass) + vmtParent)^)^);
      {$endif}
    until (LClass = TTinyObject);
  {$else}
  next_field{dummy}:
  next_class{dummy}:
    Self.CleanupInstance;
  {$ifend}

  // memory
free_memory:
  LAllocator := FAllocator;
  if (Assigned(LAllocator)) then
  begin
    LAllocator.Vmt.Release(LAllocator, Self);
  end else
  if (FRefCount and objStorageMask = Ord(isHeap) shl objStorageShift) then
  begin
    FreeMem(Pointer(Self));
  end;
end;

procedure TTinyObject.AfterConstruction;
label
  failure;
const
  DECREMENT = objNonConstructedFlag + 1 - objDefaultRefCount;
var
  LRefCount: Integer;
begin
  LRefCount := FRefCount;
  if (LRefCount and objRefCountMask > 0) then
  begin
    if (LRefCount and objSingleThreadFlag <> 0) or
      (LRefCount and objRefCountMask = 1) then
    begin
      Dec(LRefCount, DECREMENT);
      FRefCount := LRefCount;
    end else
    if (AtomicDecrement(FRefCount, DECREMENT) < 0) then
    begin
      goto failure;
    end;
  end else
  begin
  failure:
    { Invalid reference count }
    FRefCount := objInvalidRefCount;
    TinyError(teInvalidPtr);
  end;
end;

procedure TTinyObject.BeforeDestruction;
label
  failure;
var
  LRefCount: Integer;
begin
  LRefCount := FRefCount;
  if (LRefCount <> objInvalidRefCount) then
  begin
    if (LRefCount and (objNonConstructedFlag or objDisposedFlag) = 0) then
    begin
      { Direct destructor call }
      if (LRefCount and objRefCountMask <> 0) then
      begin
        goto failure;
      end;

      FRefCount := LRefCount + objDisposedFlag;
    end;
  end else
  begin
  failure:
    { Skip destructor and instance free }
    TinyError(teInvalidPtr);
  end;
end;

{$ifNdef AUTOREFCOUNT}
procedure TTinyObject.Free;
{$ifdef INLINESUPPORTSIMPLE}
begin
  DisposeOf;
end;
{$else .OLD.DELPHI}
asm
  jmp TTinyObject.DisposeOf
end;
{$endif}
{$endif}

procedure TTinyObject.DisposeOf;
var
  LRefCount: Integer;
  LVmt: NativeInt;
  LAddRef: function(const AInstance: Pointer): Integer;
  {$ifdef WEAKINSTREF}[Unsafe]{$endif} LRelease: function: Integer of object;
  LBeforeDestructionProc: procedure(const AInstance: Pointer);
  LDestructor: procedure(const AInstance: Pointer; const AOuterMost: ShortInt);
begin
  if (Self = nil) then
  begin
    Exit;
  end;

  LRefCount := FRefCount;
  if (LRefCount and objDisposedFlag <> 0) then
  begin
    Exit;
  end;

  if (LRefCount and objRefCountMask = 0) then
  begin
    FRefCount := LRefCount + objDisposedFlag;
    Destroy;
    Exit;
  end;

  // add reference
  LRelease := __ObjRelease;
  LVmt := PNativeInt(Self)^;
  LAddRef := PPointer(LVmt + vmtObjAddRef)^;
  if (Pointer(@LAddRef) = @TTinyObject.__ObjAddRef) then
  begin
    if (LRefCount and objSingleThreadFlag <> 0) or
      (LRefCount and objRefCountMask = 1) then
    begin
      Inc(LRefCount);
      FRefCount := LRefCount;
    end else
    begin
      AtomicIncrement(FRefCount);
    end;
  end else
  begin
    LAddRef(Self);
  end;
  try
    // mark disposed
    repeat
      LRefCount := FRefCount;
      if (LRefCount and objDisposedFlag <> 0) then
      begin
        Exit;
      end;

      if (LRefCount and objSingleThreadFlag <> 0) or (LRefCount and objRefCountMask = 1) then
      begin
        FRefCount := LRefCount + objDisposedFlag;
        Break;
      end else
      if (AtomicCmpExchange(FRefCount, LRefCount + objDisposedFlag, LRefCount) = LRefCount) then
      begin
        Break;
      end;
    until (False);

    // call destructor
    LBeforeDestructionProc := PPointer(LVmt + vmtBeforeDestruction)^;
    if (Pointer(@LBeforeDestructionProc) <> @TTinyObject.BeforeDestruction) then
    begin
      LBeforeDestructionProc(Self);
    end;
    LDestructor := PPointer(LVmt + vmtDestroy)^;
    LDestructor(Self, 0);
  finally
    // release reference
    if (TMethod(LRelease).Code = @TTinyObject.__ObjRelease) then
    begin
      with TTinyObject(TMethod(LRelease).Data) do
      begin
        LRefCount := FRefCount;

        if (LRefCount and objSingleThreadFlag <> 0) or (LRefCount and objRefCountMask = 1) then
        begin
          Dec(LRefCount);
          FRefCount := LRefCount;
        end else
        begin
          LRefCount := AtomicDecrement(FRefCount);
        end;

        if (LRefCount and objRefCountMask = 0) then
        begin
          FreeInstance;
        end;
      end;
    end else
    begin
      LRelease;
    end;
  end;
end;

procedure TTinyObject.CheckDisposed;
begin
  if (FRefCount and objDisposedFlag <> 0) then
  begin
    TinyError(teAccessViolation);
  end;
end;

procedure TTinyObject.CheckConstructed;
begin
  if (FRefCount and objNonConstructedFlag <> 0) then
  begin
    TinyError(teAccessViolation);
  end;
end;


{ TTinyBuffer }

function TTinyBuffer.GetMargin: NativeInt;
begin
  Result := NativeInt(Overflow);
  Dec(Result, NativeInt(Current));
end;

function TTinyBuffer.InternalAlloc(const ASize: NativeUInt; const AAlign: NativeUInt): Pointer;
var
  P: PByte;
  LAlign: NativeInt;
begin
  if (not Assigned(Overflow)) and (Assigned(Current)) then
  begin
    FVmt.Init(@Self, True{Reset});

    LAlign := NativeInt(AAlign) - 1;
    P := Pointer((NativeInt(Current) + LAlign) and (not LAlign) + NativeInt(ASize));
    if (NativeUInt(P) <= NativeUInt(Overflow)) then
    begin
      Current := P;
      Dec(P, ASize);
      Result := P;
      Exit;
    end;
  end;

  Result := FVmt.Grow(@Self, ASize, AAlign);
end;

procedure TTinyBuffer.Init(const AVmt: TTinyBufferVmtClass);
var
  LSelf: PTinyBuffer;
begin
  LSelf := @Self;

  with LSelf^ do
  begin
    Current := nil;
    Overflow := nil;
    FVmt := AVmt;
    AVmt.Init(LSelf, False);
  end;
end;

procedure TTinyBuffer.Clear;
var
  LSelf: PTinyBuffer;
begin
  LSelf := @Self;

  with LSelf^ do
  begin
    Current := nil;
    Overflow := nil;
    FVmt.Clear(LSelf);
  end;
end;

procedure TTinyBuffer.Reset;
begin
  Overflow := nil;
end;

function TTinyBuffer.Alloc(const ASize: NativeUInt): Pointer;
const
  ALIGNS: array[0..8] of Byte = ({0}1 - 1, {1}1 - 1, {2}2 - 1,
    {3}4 - 1, {4}4 - 1, {5}8 - 1, {6}8 - 1, {7}8 - 1, {8}8 - 1);
var
  P: NativeUInt;
  LAlign: NativeInt;
begin
  P := NativeUInt(Current);

  if (ASize > High(ALIGNS)) then
  begin
    LAlign := DEFAULT_MEMORY_ALIGN - 1;
  end else
  begin
    LAlign := ALIGNS[ASize];
  end;

  Inc(P, LAlign);
  LAlign := not LAlign;
  NativeInt(P) := NativeInt(P) and LAlign;

  Inc(P, ASize);
  if (P > NativeUInt(Overflow)) then
  begin
    LAlign := -LAlign;
    Result := InternalAlloc(ASize, NativeUInt(LAlign));
  end else
  begin
    NativeUInt(Current) := P;
    Dec(P, ASize);
    Result := Pointer(P);
  end;
end;

function TTinyBuffer.AllocPacked(const ASize: NativeUInt): Pointer;
const
  ALIGN = 1;
var
  P: NativeUInt;
begin
  with PTinyBuffer(@Self)^ do
  begin
    P := NativeUInt(Current);
    Inc(P, ASize);
    if (P > NativeUInt(Overflow)) then
    begin
      Result := InternalAlloc(ASize, ALIGN);
    end else
    begin
      NativeUInt(Current) := P;
      Dec(P, ASize);
      Result := Pointer(P);
    end;
  end;
end;

function TTinyBuffer.AllocAligned(const ASize: NativeUInt): Pointer;
const
  ALIGN = DEFAULT_MEMORY_ALIGN;
var
  P: NativeUInt;
begin
  with PTinyBuffer(@Self)^ do
  begin
    P := NativeUInt(Current);
    Inc(P, ALIGN - 1);
    NativeInt(P) := NativeInt(P) and -ALIGN;
    Inc(P, ASize);
    if (P > NativeUInt(Overflow)) then
    begin
      Result := InternalAlloc(ASize, ALIGN);
    end else
    begin
      NativeUInt(Current) := P;
      Dec(P, ASize);
      Result := Pointer(P);
    end;
  end;
end;

function TTinyBuffer.AllocAligned2(const ASize: NativeUInt): Pointer;
const
  ALIGN = 2;
var
  P: NativeUInt;
begin
  with PTinyBuffer(@Self)^ do
  begin
    P := NativeUInt(Current);
    Inc(P, ALIGN - 1);
    NativeInt(P) := NativeInt(P) and -ALIGN;
    Inc(P, ASize);
    if (P > NativeUInt(Overflow)) then
    begin
      Result := InternalAlloc(ASize, ALIGN);
    end else
    begin
      NativeUInt(Current) := P;
      Dec(P, ASize);
      Result := Pointer(P);
    end;
  end;
end;

function TTinyBuffer.AllocAligned4(const ASize: NativeUInt): Pointer;
const
  ALIGN = 4;
var
  P: NativeUInt;
begin
  with PTinyBuffer(@Self)^ do
  begin
    P := NativeUInt(Current);
    Inc(P, ALIGN - 1);
    NativeInt(P) := NativeInt(P) and -ALIGN;
    Inc(P, ASize);
    if (P > NativeUInt(Overflow)) then
    begin
      Result := InternalAlloc(ASize, ALIGN);
    end else
    begin
      NativeUInt(Current) := P;
      Dec(P, ASize);
      Result := Pointer(P);
    end;
  end;
end;

function TTinyBuffer.AllocAligned8(const ASize: NativeUInt): Pointer;
const
  ALIGN = 8;
var
  P: NativeUInt;
begin
  with PTinyBuffer(@Self)^ do
  begin
    P := NativeUInt(Current);
    Inc(P, ALIGN - 1);
    NativeInt(P) := NativeInt(P) and -ALIGN;
    Inc(P, ASize);
    if (P > NativeUInt(Overflow)) then
    begin
      Result := InternalAlloc(ASize, ALIGN);
    end else
    begin
      NativeUInt(Current) := P;
      Dec(P, ASize);
      Result := Pointer(P);
    end;
  end;
end;

function TTinyBuffer.AllocAligned16(const ASize: NativeUInt): Pointer;
const
  ALIGN = 16;
var
  P: NativeUInt;
begin
  with PTinyBuffer(@Self)^ do
  begin
    P := NativeUInt(Current);
    Inc(P, ALIGN - 1);
    NativeInt(P) := NativeInt(P) and -ALIGN;
    Inc(P, ASize);
    if (P > NativeUInt(Overflow)) then
    begin
      Result := InternalAlloc(ASize, ALIGN);
    end else
    begin
      NativeUInt(Current) := P;
      Dec(P, ASize);
      Result := Pointer(P);
    end;
  end;
end;


{ TBufferVmt }

type
  PBufferFragment = ^TBufferFragment;
  TBufferFragment = packed record
    Next: PBufferFragment;
    Memory: Pointer;
    Size: NativeUInt;
  end;

class procedure TBufferVmt.Init(const ABuffer: PTinyBuffer; const AResetMode: Boolean);
var
  LBuffer: PBuffer;
  LNull: Pointer;
begin
  LBuffer := Pointer(ABuffer);

  LNull := nil;
  LBuffer.FFragments := LNull;
  if (not AResetMode) then
  begin
    LBuffer.{$ifdef BCB}This.{$endif}Current := LNull;
    LBuffer.{$ifdef BCB}This.{$endif}Overflow := LNull;
    LBuffer.FBlockCount := NativeUInt(LNull);
    LBuffer.{$ifdef BCB}This.{$endif}FVmt := Self;
  end else
  if (not Assigned(LBuffer.FBlocks)) then
  begin
    LBuffer.{$ifdef BCB}This.{$endif}Current := LNull;
    LBuffer.{$ifdef BCB}This.{$endif}Overflow := LNull;
    LBuffer.FBlockCount := NativeUInt(LNull);
  end else
  begin
    LBuffer.{$ifdef BCB}This.{$endif}Current := Pointer(LBuffer.FBlocks[0]);
    LBuffer.{$ifdef BCB}This.{$endif}Overflow := Pointer(NativeUInt(LBuffer.{$ifdef BCB}This.{$endif}Current) + NativeUInt(Length(LBuffer.FBlocks[0])));
    LBuffer.FBlockCount := 1;
  end;
end;

class procedure TBufferVmt.Clear(const ABuffer: PTinyBuffer);
var
  LBuffer: PBuffer;
begin
  LBuffer := Pointer(ABuffer);
  LBuffer.Clear;
end;

procedure TBufferVmtMoveBlock(const ABlocks: PHugePointerArray;
  const AFrom, ATo: Integer);
var
  i: Integer;
  LItem: Pointer;
begin
  LItem := ABlocks[AFrom];

  if (ATo < AFrom) then
  begin
    for i := AFrom downto ATo + 1 do
    begin
      ABlocks[i] := ABlocks[i - 1];
    end;
  end else
  begin
    for i := AFrom + 1 to ATo do
    begin
      ABlocks[i - 1] := ABlocks[i];
    end;
  end;

  ABlocks[ATo] := LItem;
end;

class function TBufferVmt.Grow(const ABuffer: PTinyBuffer; const ASize: NativeUInt;
  const AAlign: NativeUInt): Pointer;
const
  MAX_BUFFER_SIZE = 4 * 1024 * 1024 - 128;
var
  i: NativeUInt;
  LBuffer: PBuffer;
  LAlign: NativeInt;
  P, LOverflow: PByte;
  LPrevFragment, LFragment: PBufferFragment;
  LReserveSize: NativeUInt;
  LCount, LBlockSize: NativeUInt;
begin
  // initialization
  LBuffer := Pointer(ABuffer);
  LAlign := NativeInt(AAlign) - 1;

  // find apposite fragment
  LPrevFragment := nil;
  LFragment := LBuffer.FFragments;
  if (Assigned(LFragment)) then
  repeat
    P := LFragment.Memory;
    LOverflow := Pointer(NativeUInt(P) + LFragment.Size);
    P := Pointer((NativeInt(P) + LAlign) and (not LAlign) + NativeInt(ASize));

    if (NativeUInt(P) <= NativeUInt(LOverflow)) then
    begin
      LBuffer.{$ifdef BCB}This.{$endif}Current := P;
      LBuffer.{$ifdef BCB}This.{$endif}Overflow := LOverflow;

      if (not Assigned(LPrevFragment)) then
      begin
        LBuffer.FFragments := LFragment.Next;
      end else
      begin
        LPrevFragment.Next := LFragment.Next;
      end;

      Dec(P, ASize);
      Result := P;
      Exit;
    end;

    LPrevFragment := LFragment;
    LFragment := LFragment.Next;
  until (not Assigned(LFragment));

  // find apposite cached block
  if (Assigned(LBuffer.FBlocks)) then
  for i := LBuffer.FBlockCount to NativeUInt(Length(LBuffer.FBlocks)) - 1 do
  begin
    P := Pointer(LBuffer.FBlocks[i]);
    LOverflow := Pointer(NativeUInt(P) + NativeUInt(Length(LBuffer.FBlocks[i])));
    P := Pointer((NativeInt(P) + LAlign) and (not LAlign) + NativeInt(ASize));

    if (NativeUInt(P) <= NativeUInt(LOverflow)) then
    begin
      LBuffer.{$ifdef BCB}This.{$endif}Current := P;
      LBuffer.{$ifdef BCB}This.{$endif}Overflow := LOverflow;

      if (LBuffer.FBlockCount <> i) then
      begin
        TBufferVmtMoveBlock(Pointer(LBuffer.FBlocks), i, LBuffer.FBlockCount);
      end;
      Inc(LBuffer.FBlockCount);

      Dec(P, ASize);
      Result := P;
      Exit;
    end;
  end;

  // detect new block size
  LReserveSize := ASize + NativeUInt(LAlign);
  LCount := Length(LBuffer.FBlocks);
  if (LReserveSize >= MAX_BUFFER_SIZE) then
  begin
    LBlockSize := LReserveSize;
  end else
  begin
    LBlockSize := 4 * 1024;
    for i := 2 to LCount do
    begin
      LBlockSize := LBlockSize shl 1;
      if (LBlockSize < 256 * 1024) then
      begin
        LBlockSize := LBlockSize shl 1;
      end;
    end;

    while (LBlockSize < LReserveSize) do
    begin
      LBlockSize := LBlockSize shl 1;
    end;
  end;

  // allocate new block
  i := LCount;
  SetLength(LBuffer.FBlocks, LCount + 1);
  SetLength(LBuffer.FBlocks[i], LBlockSize);
  if (i <> LBuffer.FBlockCount) then
  begin
    TBufferVmtMoveBlock(Pointer(LBuffer.FBlocks), i, LBuffer.FBlockCount);
  end;
  Inc(LBuffer.FBlockCount);

  // result
  P := Pointer(LBuffer.FBlocks[LBuffer.FBlockCount - 1]);
  LBuffer.{$ifdef BCB}This.{$endif}Overflow := Pointer(NativeUInt(P) + LBlockSize);
  P := Pointer((NativeInt(P) + LAlign) and (not LAlign) + NativeInt(ASize));
  LBuffer.{$ifdef BCB}This.{$endif}Current := P;
  Dec(P, ASize);
  Result := P;
end;

{ TBuffer }

procedure TBuffer.Init;
var
  LNull: Pointer;
begin
  with PBuffer(@Self)^ do
  begin
    LNull := nil;
    {$ifdef BCB}This.{$endif}Current := LNull;
    {$ifdef BCB}This.{$endif}Overflow := LNull;
    FFragments := LNull;
    FBlockCount := NativeUInt(LNull);
    {$ifdef BCB}This.{$endif}FVmt := TBufferVmt;
  end;
end;

procedure TBuffer.Clear;
var
  LNull: Pointer;
begin
  with PBuffer(@Self)^ do
  begin
    LNull := nil;
    {$ifdef BCB}This.{$endif}Current := LNull;
    {$ifdef BCB}This.{$endif}Overflow := LNull;
    FFragments := LNull;
    FBlockCount := NativeUInt(LNull);
    if (Assigned(FBlocks)) then
    begin
      FBlocks := nil;
    end;
  end;
end;

procedure TBuffer.Increase(const AMemory: Pointer; const ASize: NativeUInt);
var
  LFragment: PBufferFragment;
begin
  if (ASize >= SizeOf(TBufferFragment)) then
  begin
    LFragment := AMemory;
    LFragment.Memory := AMemory;
    LFragment.Size := ASize;

    LFragment.Next := FFragments;
    FFragments := LFragment;
  end;
end;


{ TEntireBufferVmt }

class procedure TEntireBufferVmt.Init(const ABuffer: PTinyBuffer; const AResetMode: Boolean);
var
  LBuffer: PEntireBuffer;
  LNull: Pointer;
begin
  LBuffer := Pointer(ABuffer);

  LNull := nil;
  if (not AResetMode) then
  begin
    LBuffer.{$ifdef BCB}This.{$endif}Current := LNull;
    LBuffer.{$ifdef BCB}This.{$endif}Overflow := LNull;
    LBuffer.{$ifdef BCB}This.{$endif}FVmt := Self;
  end else
  if (not Assigned(LBuffer.FBytes)) then
  begin
    LBuffer.{$ifdef BCB}This.{$endif}Current := LNull;
    LBuffer.{$ifdef BCB}This.{$endif}Overflow := LNull;
  end else
  begin
    LBuffer.{$ifdef BCB}This.{$endif}Current := Pointer(LBuffer.FBytes);
    LBuffer.{$ifdef BCB}This.{$endif}Overflow := Pointer(NativeUInt(LBuffer.{$ifdef BCB}This.{$endif}Current) + NativeUInt(Length(LBuffer.FBytes)));
  end;
end;

class procedure TEntireBufferVmt.Clear(const ABuffer: PTinyBuffer);
var
  LBuffer: PEntireBuffer;
begin
  LBuffer := Pointer(ABuffer);
  LBuffer.Clear;
end;

class function TEntireBufferVmt.Grow(const ABuffer: PTinyBuffer; const ASize: NativeUInt;
  const AAlign: NativeUInt): Pointer;
const
  MAX_GROW_SIZE = 4 * 1024 * 1024;
var
  LBuffer: PEntireBuffer;
  LAlign: NativeInt;
  LPosition: NativeUInt;
  LTargetSize: NativeUInt;
  LBufferSize: NativeUInt;
  P: PByte;
begin
  // initialization
  LBuffer := Pointer(ABuffer);
  LAlign := NativeInt(AAlign) - 1;
  LPosition := LBuffer.Position;
  LTargetSize := LPosition + ASize + NativeUInt(LAlign);

  // detect buffer size
  LBufferSize := 128;
  while (LBufferSize < LTargetSize) do
  begin
    if (LBufferSize >= MAX_GROW_SIZE) then
    begin
      Inc(LBufferSize, MAX_GROW_SIZE)
    end else
    begin
      LBufferSize := LBufferSize shl 1;
    end;
  end;

  // reallocation
  SetLength(LBuffer.FBytes, LBufferSize);
  LBuffer.{$ifdef BCB}This.{$endif}Current := Pointer(NativeUInt(Pointer(LBuffer.FBytes)) + LPosition);
  LBuffer.{$ifdef BCB}This.{$endif}Overflow := Pointer(NativeUInt(Pointer(LBuffer.FBytes)) + LBufferSize);

  // result
  P := Pointer((NativeInt(LBuffer.{$ifdef BCB}This.{$endif}Current) + LAlign) and (not LAlign) + NativeInt(ASize));
  LBuffer.{$ifdef BCB}This.{$endif}Current := P;
  Dec(P, ASize);
  Result := P;
end;

{ TEntireBuffer }

function TEntireBuffer.GetPosition: NativeUInt;
begin
  Result := NativeUInt({$ifdef BCB}This.{$endif}Current);
  Dec(Result, NativeUInt(Pointer(FBytes)));
end;

function TEntireBuffer.GetSize: NativeUInt;
var
  LRec: PDynArrayRec;
begin
  LRec := Pointer(FBytes);
  if (not Assigned(LRec)) then
  begin
    Result := NativeUInt(LRec);
  end else
  begin
    Dec(LRec);
    Result := LRec.Length;
  end;
end;

procedure TEntireBuffer.Init;
var
  LNull: Pointer;
begin
  with PEntireBuffer(@Self)^ do
  begin
    LNull := nil;
    {$ifdef BCB}This.{$endif}Current := LNull;
    {$ifdef BCB}This.{$endif}Overflow := LNull;
    {$ifdef BCB}This.{$endif}FVmt := TEntireBufferVmt;
  end;
end;

procedure TEntireBuffer.Clear;
var
  LNull: Pointer;
begin
  with PEntireBuffer(@Self)^ do
  begin
    LNull := nil;
    {$ifdef BCB}This.{$endif}Current := LNull;
    {$ifdef BCB}This.{$endif}Overflow := LNull;
    if (Assigned(FBytes)) then
    begin
      FBytes := nil;
    end;
  end;
end;


initialization
  if (NativeInt(@InternalTinyErrorCurrent) and 3 <> 0)  then
  begin
    TinyError(teInvalidPtr);
  end;
  {$WARNINGS OFF}
  SysVmtAddRef := {$if Defined(STATICSUPPORT) and not Defined(AUTOREFCOUNT)}TTinyObject.{$ifend}vmtObjAddRef;
  SysVmtRelease := {$if Defined(STATICSUPPORT) and not Defined(AUTOREFCOUNT)}TTinyObject.{$ifend}vmtObjRelease;
  {$WARNINGS ON}
  InitLibrary;
  INTERNAL_BUFFER.Init;
  INTERNAL_BUFFER.Increase(@INTERNAL_BUFFER_MEMORY, SizeOf(INTERNAL_BUFFER_MEMORY));

finalization
  INTERNAL_BUFFER.Clear;

end.
