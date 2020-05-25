unit Tiny.Text;

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
{ previous location: https://github.com/d-mozulyov/UniConv|CachedTexts         }
{******************************************************************************}


{  --------------------- SUPPORTED UNICODE ENCODINGS ----------------------  }
(*
     UTF-8
     UTF-16(LE) ~ UCS2
     UTF-16BE
     UTF-32(LE) = UCS4
     UTF-32BE
     UCS4 unusual octet order 2143
     UCS4 unusual octet order 3412
     UTF-1
     UTF-7
     UTF-EBCDIC
     SCSU
     BOCU-1
*)

{  ------------------- SUPPORTED NON-UNICODE ENCODINGS --------------------  }
(*
     ANSI Code Pages(may be returned by Windows.GetACP):
         874 - Thai
         1250 - Central and East European Latin
         1251 - Cyrillic
         1252 - West European Latin
         1253 - Greek
         1254 - Turkish
         1255 - Hebrew
         1256 - Arabic
         1257 - Baltic
         1258 - Vietnamese

     Another (multy-byte) encodings, that may be specified as default in POSIX systems:
         932 - Japanese (shift_jis)
         936 - Simplified Chinese (gb2312)
         949 - Korean (ks_c_5601-1987)
         950 - Traditional Chinese (big5)

     Single-byte encodings, that also can be defined as "encoding" in XML/HTML:
         866 - Cyrillic (OEM)
         28592 - Central European (iso-8859-2)
         28593 - Latin 3 (iso-8859-3)
         28594 - Baltic (iso-8859-4)
         28595 - Cyrillic (iso-8859-5)
         28596 - Arabic (iso-8859-6)
         28597 - Greek (iso-8859-7)
         28598 - Hebrew (iso-8859-8)
         28600 - Nordic (iso-8859-10)
         28603 - Estonian (iso-8859-13)
         28604 - Celtic (iso-8859-14)
         28605 - Latin-9 (iso-8859-15)
         28606 - South-Eastern European (iso-8859-16)
         20866 - Cyrillic (koi8-r)
         21866 - Ukrainian (koi8-u)
         10000 - Western European (Mac)
         10007 - Cyrillic (Mac)
         $fffd - User defined

     Multy-byte encodings, that also can be defined as "encoding" in XML/HTML:
         54936 - Simplified Chinese (gb18030)
         52936 - Simplified Chinese (hz-gb-2312)
         20932 - Japanese (euc-jp)
         50221 - Japanese with halfwidth Katakana (iso-2022-jp)
         51949 - EUC Korean (euc-kr)
*)

{$I TINY.DEFINES.inc}

interface
uses
  Tiny.Types;


type
  // character types
  PByteCharArray = ^TByteCharArray;
  TByteCharArray = array[0..High(Integer) div SizeOf(Byte) - 1] of Byte;

  PUTF16CharArray = ^TUTF16CharArray;
  TUTF16CharArray = array[0..High(Integer) div SizeOf(Word) - 1] of Word;

  PUTF32CharArray = ^TUTF32CharArray;
  TUTF32CharArray = array[0..High(Integer) div SizeOf(Cardinal) - 1] of Cardinal;

  // case sensitivity
  TCharCase = (ccOriginal, ccLower, ccUpper);
  PCharCase = ^TCharCase;

  // byte order mark
  TBOM = (bomNone,
          bomUTF8, bomUTF16, bomUTF16BE, bomUTF32, bomUTF32BE, bomUCS2143, bomUCS3412,
          bomUTF1, bomUTF7, bomUTFEBCDIC, bomSCSU, bomBOCU1, bomGB18030);
  PBOM = ^TBOM;

  // byte order mark detection
  function DetectBOM(const Data: Pointer; const Size: NativeUInt = 4): TBOM;

var
  // automatically defined default code page
  CODEPAGE_DEFAULT: Word;

const
  // unicode code page identifiers
  CODEPAGE_UTF7 = 65000;
  CODEPAGE_UTF8 = 65001;
  CODEPAGE_UTF16 = 1200;
  CODEPAGE_UTF16BE = 1201;
  CODEPAGE_UTF32 = 12000;
  CODEPAGE_UTF32BE = 12001;

  // non-defined (fake) code page identifiers
  CODEPAGE_UCS2143 = 12002;
  CODEPAGE_UCS3412 = 12003;
  CODEPAGE_UTF1 = 65002;
  CODEPAGE_UTFEBCDIC = 65003;
  CODEPAGE_SCSU = 65004;
  CODEPAGE_BOCU1 = 65005;
  CODEPAGE_USERDEFINED = $fffd;
  CODEPAGE_RAWDATA = $ffff;

  // byte order mark information
  BOM_INFO: array[TBOM] of
  record
    Data: Cardinal;
    Size: Cardinal;
    Name: string;
    CodePage: Word;
  end = (
    (Data: $00000000; Size: 0; Name: ''          ; CodePage: 0),                  // none
    (Data: $00BFBBEF; Size: 3; Name: 'UTF-8'     ; CodePage: CODEPAGE_UTF8),      // EF BB BF
    (Data: $0000FEFF; Size: 2; Name: 'UTF-16 LE' ; CodePage: CODEPAGE_UTF16),     // FF FE XX XX
    (Data: $0000FFFE; Size: 2; Name: 'UTF-16 BE' ; CodePage: CODEPAGE_UTF16BE),   // FE FF XX XX
    (Data: $0000FEFF; Size: 4; Name: 'UTF-32 LE' ; CodePage: CODEPAGE_UTF32),     // FF FE 00 00
    (Data: $FFFE0000; Size: 4; Name: 'UTF-32 BE' ; CodePage: CODEPAGE_UTF32BE),   // 00 00 FE FF
    (Data: $FEFF0000; Size: 4; Name: 'UCS-2143'  ; CodePage: CODEPAGE_UCS2143),   // 00 00 FF FE
    (Data: $0000FFFE; Size: 4; Name: 'UCS-3412'  ; CodePage: CODEPAGE_UCS3412),   // FE FF 00 00
    (Data: $004C64F7; Size: 3; Name: 'UTF-1'     ; CodePage: CODEPAGE_UTF1),      // F7 64 4C
    (Data: $00762F2B; Size: 3; Name: 'UTF-7'     ; CodePage: CODEPAGE_UTF7),      // 2B 2F 76 + 38/39/2B/2F
    (Data: $736673DD; Size: 4; Name: 'UTF-EBCDIC'; CodePage: CODEPAGE_UTFEBCDIC), // DD 73 66 73
    (Data: $00FFFE0E; Size: 3; Name: 'SCSU'      ; CodePage: CODEPAGE_SCSU),      // 0E FE FF
    (Data: $0028EEFB; Size: 3; Name: 'BOCU-1'    ; CodePage: CODEPAGE_BOCU1),     // FB EE 28
    (Data: $33953184; Size: 4; Name: 'GB-18030'  ; CodePage: 54936)               // 84 31 95 33
  );

  // important characters constants
  UNKNOWN_CHARACTER = Ord('?');
  MAXIMUM_CHARACTER = $110000-1; // 1 114 111


type
  // main conversion interface
  PTextConvContext = ^TTextConvContext;
  {$A1}
  {$ifdef BCB}
  TTextConvContext = record
  {$else}
  TTextConvContext = object
  protected
  {$endif}
    F: packed record
    case Integer of
         0: (Flags: Cardinal;
             (*
               SourceMode:5: TTextConvEncoding;
               SourceStateNeeded:1: Boolean;
               DestinationStateNeeded:1: Boolean;
               DestinationMarginNeeded:1: Boolean;
               ModeFinalize: Boolean;
               CharCase: TCharCase;
               CharCaseOriginal:1(3): Boolean;
               DestinationMode:5: TTextConvEncoding;
             *)
             SourceCodePage: Word;
             DestinationCodePage: Word;
             );
         1: (_: Byte; ModeFinalize: Boolean; CharCase: TCharCase);
    end;
    FCallbacks: packed record
      Convertible: NativeInt;
      case Boolean of
       False: (Reader, Writer: Pointer);
        True: (ReaderWriter, Converter: Pointer);
    end;
    FState: packed record
    case Integer of
      0: (Write, Read: packed record
          case Integer of
            0: (I: Integer);
            1: (D: Cardinal);
            2: (B: Byte);
            3: (Bytes: array[0..3] of Byte);
          end);
      1: (WR: Int64; ScsuReadWindows: array[0..7] of Cardinal);
    end;

    FDestination: Pointer;
    FDestinationSize: NativeUInt;
    FSource: Pointer;
    FSourceSize: NativeUInt;

    FConvertProc: function(Context: PTextConvContext): NativeInt;
    FDestinationWritten: NativeUInt;
    FSourceRead: NativeUInt;

    // default conversions
    function convert_copy: NativeInt;
    function convert_universal: NativeInt;

    // fast most frequently used conversions
    function convert_sbcs_from_sbcs: NativeInt;
    function convert_utf8_from_utf8: NativeInt;
    function convert_utf16_from_utf16: NativeInt;
    function convert_utf8_from_sbcs: NativeInt;
    function convert_sbcs_from_utf8: NativeInt;
    function convert_utf16_from_sbcs: NativeInt;
    function convert_sbcs_from_utf16: NativeInt;
    function convert_utf8_from_utf16: NativeInt;
    function convert_utf16_from_utf8: NativeInt;

    // temporary convertible routine
    function call_convertible(X: NativeUInt; Callback: Pointer): Boolean; {$ifNdef CPUINTELASM}inline;{$endif}
    function sbcs_convertible(X: NativeUInt): Boolean;

    // difficult double/multy-byte encodings conversion callbacks
    function utf1_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function utf1_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function utf7_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function utf7_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function utf_ebcdic_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function utf_ebcdic_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function scsu_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function scsu_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function bocu1_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function bocu1_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function gb2312_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function gb2312_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function gb2312_convertible(X: NativeUInt): Boolean;
    function gb18030_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function gb18030_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function gb18030_convertible(X: NativeUInt): Boolean;
    function hzgb2312_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function hzgb2312_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function hzgb2312_convertible(X: NativeUInt): Boolean;
    function big5_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function big5_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function big5_convertible(X: NativeUInt): Boolean;
    function shift_jis_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function shift_jis_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function shift_jis_convertible(X: NativeUInt): Boolean;
    function euc_jp_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function euc_jp_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function euc_jp_convertible(X: NativeUInt): Boolean;
    function iso2022jp_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function iso2022jp_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function iso2022jp_convertible(X: NativeUInt): Boolean;
    function cp949_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function cp949_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function cp949_convertible(X: NativeUInt): Boolean;
    function euc_kr_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
    function euc_kr_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
    function euc_kr_convertible(X: NativeUInt): Boolean;
  public
    // "constructors"
    procedure Init(const ADestinationCodePage, ASourceCodePage: Word; const ACharCase: TCharCase = ccOriginal); overload;
    procedure Init(const ADestinationBOM, ASourceBOM: TBOM; const SBCSCodePage: Word = 0; const ACharCase: TCharCase = ccOriginal); overload;

    // most frequently used "constructors"
    procedure InitSBCSFromSBCS(const ADestinationCodePage, ASourceCodePage: Word; const ACharCase: TCharCase = ccOriginal);
    procedure InitUTF8FromSBCS(const ASourceCodePage: Word; const ACharCase: TCharCase = ccOriginal);
    procedure InitSBCSFromUTF8(const ADestinationCodePage: Word; const ACharCase: TCharCase = ccOriginal);
    procedure InitUTF16FromSBCS(const ASourceCodePage: Word; const ACharCase: TCharCase = ccOriginal);
    procedure InitSBCSFromUTF16(const ADestinationCodePage: Word; const ACharCase: TCharCase = ccOriginal);
    procedure InitUTF8FromUTF8(const ACharCase: TCharCase);
    procedure InitUTF16FromUTF16(const ACharCase: TCharCase);
    procedure InitUTF8FromUTF16(const ACharCase: TCharCase);
    procedure InitUTF16FromUTF8(const ACharCase: TCharCase);

    // context properties
    property DestinationCodePage: Word read F.DestinationCodePage;
    property SourceCodePage: Word read F.SourceCodePage;
    property CharCase: TCharCase read F.CharCase;
    property ModeFinalize: Boolean read F.ModeFinalize write F.ModeFinalize; // deafult = True
    procedure ResetState; {$ifdef INLINESUPPORT}inline;{$endif}

    // character convertibility
    function Convertible(const C: UCS4Char): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Convertible(const C: UnicodeChar): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    // conversion parameters
    property Destination: Pointer read FDestination write FDestination;
    property DestinationSize: NativeUInt read FDestinationSize write FDestinationSize;
    property Source: Pointer read FSource write FSource;
    property SourceSize: NativeUInt read FSourceSize write FSourceSize;

    // conversion
    function Convert: NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Convert(const ADestination: Pointer;
                     const ADestinationSize: NativeUInt;
                     const ASource: Pointer;
                     const ASourceSize: NativeUInt): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Convert(const ADestination: Pointer;
                     const ADestinationSize: NativeUInt;
                     const ASource: Pointer;
                     const ASourceSize: NativeUInt;
                     out ADestinationWritten: NativeUInt;
                     out ASourceRead: NativeUInt): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

    // "out" information
    property DestinationWritten: NativeUInt read FDestinationWritten;
    property SourceRead: NativeUInt read FSourceRead;
  end;
  {$A4}


type
  // internal single-byte conversion array types
  TTextConvSS = array[AnsiChar] of AnsiChar;
  PTextConvSS = ^TTextConvSS;
  TTextConvUU = array[UnicodeChar] of UnicodeChar;
  PTextConvUU = ^TTextConvUU;
  TTextConvUS = array[AnsiChar] of UnicodeChar;
  PTextConvUS = ^TTextConvUS;
  TTextConvSU = array[UnicodeChar] of AnsiChar;
  PTextConvSU = ^TTextConvSU;
  TTextConvMS = array[AnsiChar] of Cardinal;
  PTextConvMS = ^TTextConvMS;
  TTextConvSBCSValues = packed record
    SBCS: TTextConvSU;
    UCS2: TTextConvUS;
  end;
  PTextConvSBCSValues = ^TTextConvSBCSValues;
  TTextConvBB = array[Byte] of Byte;
  PTextConvBB = ^TTextConvBB;
  TTextConvWW = array[Word] of Word;
  PTextConvWW = ^TTextConvWW;
  TTextConvWB = array[Byte] of Word;
  PTextConvWB = ^TTextConvWB;
  TTextConvBW = array[Word] of Byte;
  PTextConvBW = ^TTextConvBW;
  TTextConvMB = array[Byte] of Cardinal;
  PTextConvMB = ^TTextConvMB;

var
  // fast utf16 lower/upper lookup tables
  TEXTCONV_CHARCASE: packed record
  case Integer of
    0: (LOWER, UPPER: TTextConvUU);
    1: (VALUES: array[0..1 shl 17 - 1] of Word);
  end;

  // utf8 character size by first byte
  TEXTCONV_UTF8CHAR_SIZE: TTextConvBB;

type
  // single-byte encodings lookups:
  // sbcs --> utf16(ucs2), sbcs --> utf8, utf16(ucs2) --> sbcs, sbcs --> sbcs
  //
  //(0) 0xFFFF - Raw data
  //(1) 874 - Thai
  //(2) 1250 - Central and East European Latin
  //(3) 1251 - Cyrillic
  //(4) 1252 - West European Latin
  //(5) 1253 - Greek
  //(6) 1254 - Turkish
  //(7) 1255 - Hebrew
  //(8) 1256 - Arabic
  //(9) 1257 - Baltic
  //(10) 1258 - Vietnamese
  //(11) 866 - Cyrillic (OEM)
  //(12) 28592 - Central European (iso-8859-2)
  //(13) 28593 - Latin 3 (iso-8859-3)
  //(14) 28594 - Baltic (iso-8859-4)
  //(15) 28595 - Cyrillic (iso-8859-5)
  //(16) 28596 - Arabic (iso-8859-6)
  //(17) 28597 - Greek (iso-8859-7)
  //(18) 28598 - Hebrew (iso-8859-8)
  //(19) 28600 - Nordic (iso-8859-10)
  //(20) 28603 - Estonian (iso-8859-13)
  //(21) 28604 - Celtic (iso-8859-14)
  //(22) 28605 - Latin-9 (iso-8859-15)
  //(23) 28606 - South-Eastern European (iso-8859-16)
  //(24) 20866 - Cyrillic (koi8-r)
  //(25) 21866 - Ukrainian (koi8-u)
  //(26) 10000 - Western European (Mac)
  //(27) 10007 - Cyrillic (Mac)
  //(28) $fffd - User defined

  PTextConvSBCS = ^TTextConvSBCS;
  {$A1}
  {$ifdef BCB}
  TTextConvSBCS= record
  {$else}
  TTextConvSBCS = object
  protected
  {$endif}
    {$HINTS OFF}
    FAlign: packed record
      Ptrs: array[0..4] of Pointer;
      {$ifdef LARGEINT}C: Cardinal;{$endif}
    end;
    {$HINTS ON}
    F: packed record
      Index: Word;
      CodePage: Word;
    end;
    // single-byte
    FUpperCase: PTextConvSS;
    FLowerCase: PTextConvSS;
    FTableSBCSItems: Pointer; // PTableSBCSItem
    // lower/upper unicode
    FUCS2: packed record
    case Integer of
      0: (Original, Lower, Upper: PTextConvUS);
      1: (Items: array[TCharCase] of PTextConvUS);
      2: (NumericItems: array[0..2] of PTextConvUS);
    end;
    FUTF8: packed record
    case Integer of
      0: (Original, Lower, Upper: PTextConvMS);
      1: (Items: array[TCharCase] of PTextConvMS);
      2: (NumericItems: array[0..2] of PTextConvMS);
    end;
    // unicode
    FVALUES: PTextConvSBCSValues;

    function GetLowerCase: PTextConvSS; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUpperCase: PTextConvSS; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUCS2: PTextConvUS; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetLowerCaseUCS2: PTextConvUS; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUpperCaseUCS2: PTextConvUS; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUTF8: PTextConvMS; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetLowerCaseUTF8: PTextConvMS; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUpperCaseUTF8: PTextConvMS; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetVALUES: PTextConvSBCSValues; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifNdef BCB}
  protected
  {$endif}
    procedure FillUCS2(var Buffer: TTextConvWB; const CharCase: TCharCase);
    procedure FillUTF8(var Buffer: TTextConvMB; const CharCase: TCharCase);
    procedure FillVALUES(var Buffer: TTextConvBW);
    function AllocFillUCS2(var Buffer: PTextConvUS; const CharCase: TCharCase): PTextConvUS;
    function AllocFillUTF8(var Buffer: PTextConvMS; const CharCase: TCharCase): PTextConvMS;
    function AllocFillVALUES(var Buffer: PTextConvSBCSValues): PTextConvSBCSValues;
  public
    // information
    property Index: Word read F.Index;
    property CodePage: Word read F.CodePage;

    // lower/upper single-byte tables
    property LowerCase: PTextConvSS read GetLowerCase;
    property UpperCase: PTextConvSS read GetUpperCase;

    // basic unicode tables
    property UCS2: PTextConvUS read GetUCS2;
    property UTF8: PTextConvMS read GetUTF8;
    property VALUES: PTextConvSBCSValues read GetVALUES;

    // lower/upper unicode tables
    property LowerCaseUCS2: PTextConvUS read GetLowerCaseUCS2;
    property UpperCaseUCS2: PTextConvUS read GetUpperCaseUCS2;
    property LowerCaseUTF8: PTextConvMS read GetLowerCaseUTF8;
    property UpperCaseUTF8: PTextConvMS read GetUpperCaseUTF8;

    // single-byte lookup from another encoding
    function FromSBCS(const Source: PTextConvSBCS; const CharCase: TCharCase = ccOriginal): PTextConvSS;
  end;
  {$A4}

var
  DEFAULT_TEXTCONV_SBCS: PTextConvSBCS;
  DEFAULT_TEXTCONV_SBCS_INDEX: NativeUInt;
  TEXTCONV_SUPPORTED_SBCS: array[0..28] of TTextConvSBCS;
  TEXTCONV_SUPPORTED_SBCS_HASH: array[0..31] of packed record
    CP: Word;
    Index: Byte;
    Next: Byte;
  end = (
    {00} (CP:     0; Index:$ff; Next: 31),
    {01} (CP:   866; Index: 11; Next: 13),
    {02} (CP:  1250; Index:  2; Next: 01),
    {03} (CP:  1251; Index:  3; Next: 31),
    {04} (CP:  1252; Index:  4; Next: 31),
    {05} (CP:  1253; Index:  5; Next: 31),
    {06} (CP:  1254; Index:  6; Next: 31),
    {07} (CP:  1255; Index:  7; Next: 31),
    {08} (CP:  1256; Index:  8; Next: 31),
    {09} (CP:  1257; Index:  9; Next: 31),
    {10} (CP:  1258; Index: 10; Next: 11),
    {11} (CP:   874; Index:  1; Next: 12),
    {12} (CP: 21866; Index: 25; Next: 31),
    {13} (CP: 20866; Index: 24; Next: 31),
    {14} (CP: $ffff; Index:  0; Next: $80),
    {15} (CP: 10000; Index: 26; Next: 31),
    {16} (CP: 28592; Index: 12; Next: 15),
    {17} (CP: 28593; Index: 13; Next: 31),
    {18} (CP: 28594; Index: 14; Next: 31),
    {19} (CP: 28595; Index: 15; Next: 31),
    {20} (CP: 28596; Index: 16; Next: 31),
    {21} (CP: 28597; Index: 17; Next: 31),
    {22} (CP: 28598; Index: 18; Next: 31),
    {23} (CP: 10007; Index: 27; Next: 31),
    {24} (CP: 28600; Index: 19; Next: 31),
    {25} (CP: $ffff; Index:  0; Next: $80),
    {26} (CP: $fffd; Index: 28; Next: 31),
    {27} (CP: 28603; Index: 20; Next: 31),
    {28} (CP: 28604; Index: 21; Next: 31),
    {29} (CP: 28605; Index: 22; Next: 26),
    {30} (CP: 28606; Index: 23; Next: 31),
    {31} (CP: $ffff; Index:  0; Next: $80)
  );


// detect single-byte encoding
function TextConvIsSBCS(const CodePage: Word): Boolean; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}

// get single-byte encoding lookup
// TEXTCONV_SUPPORTED_SBCS[0] if not found of raw data (CP $ffff)
function TextConvSBCS(const CodePage: Word): PTextConvSBCS; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}

// get single-byte encoding lookup index
// 0 if not found of raw data (CP $ffff)
function TextConvSBCSIndex(const CodePage: Word): NativeUInt; {$ifdef INLINESUPPORTSIMPLE}inline;{$endif}


{$ifdef undef}{$REGION 'low level SBCS<-->UTF8<-->UTF16 conversions'}{$endif}
  // result = length
  procedure sbcs_from_sbcs(Dest: PAnsiChar; Src: PAnsiChar; Length: NativeUInt; Converter: PTextConvSS); overload;
  procedure sbcs_from_sbcs_lower(Dest: PAnsiChar; Src: PAnsiChar; Length: NativeUInt; LowerCase: PTextConvSS); overload;
  procedure sbcs_from_sbcs_upper(Dest: PAnsiChar; Src: PAnsiChar; Length: NativeUInt; UpperCase: PTextConvSS); overload;

  // result = min: length/3*2; max: length*3/2
  function utf8_from_utf8_lower(Dest: PUTF8Char; Src: PUTF8Char; Length: NativeUInt): NativeUInt; overload;
  function utf8_from_utf8_upper(Dest: PUTF8Char; Src: PUTF8Char; Length: NativeUInt): NativeUInt; overload;

  // result = length
  procedure utf16_from_utf16_lower(Dest: PUnicodeChar; Src: PUnicodeChar; Length: NativeUInt); overload;
  procedure utf16_from_utf16_upper(Dest: PUnicodeChar; Src: PUnicodeChar; Length: NativeUInt); overload;

  // result = min: length; max: length*3
  function utf8_from_sbcs(Dest: PUTF8Char; Src: PAnsiChar; Length: NativeUInt; Converter: PTextConvMS): NativeUInt; overload;
  function utf8_from_sbcs_lower(Dest: PUTF8Char; Src: PAnsiChar; Length: NativeUInt; LowerCase: PTextConvMS): NativeUInt; overload;
  function utf8_from_sbcs_upper(Dest: PUTF8Char; Src: PAnsiChar; Length: NativeUInt; UpperCase: PTextConvMS): NativeUInt; overload;

  // result = min: length/6; max: length
  function sbcs_from_utf8(Dest: PAnsiChar; Src: PUTF8Char; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt; overload;
  function sbcs_from_utf8_lower(Dest: PAnsiChar; Src: PUTF8Char; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt; overload;
  function sbcs_from_utf8_upper(Dest: PAnsiChar; Src: PUTF8Char; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt; overload;

  // result = length
  procedure utf16_from_sbcs(Dest: PUnicodeChar; Src: PAnsiChar; Length: NativeUInt; Converter: PTextConvUS); overload;
  procedure utf16_from_sbcs_lower(Dest: PUnicodeChar; Src: PAnsiChar; Length: NativeUInt; LowerCase: PTextConvUS); overload;
  procedure utf16_from_sbcs_upper(Dest: PUnicodeChar; Src: PAnsiChar; Length: NativeUInt; UpperCase: PTextConvUS); overload;

  // result = min: length/2; max: length
  function sbcs_from_utf16(Dest: PAnsiChar; Src: PUnicodeChar; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt; overload;
  function sbcs_from_utf16_lower(Dest: PAnsiChar; Src: PUnicodeChar; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt; overload;
  function sbcs_from_utf16_upper(Dest: PAnsiChar; Src: PUnicodeChar; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt; overload;

  // result = min: length; max: length*3
  function utf8_from_utf16(Dest: PUTF8Char; Src: PUnicodeChar; Length: NativeUInt): NativeUInt; overload;
  function utf8_from_utf16_lower(Dest: PUTF8Char; Src: PUnicodeChar; Length: NativeUInt): NativeUInt; overload;
  function utf8_from_utf16_upper(Dest: PUTF8Char; Src: PUnicodeChar; Length: NativeUInt): NativeUInt; overload;

  // result = min: length/3; max: length
  function utf16_from_utf8(Dest: PUnicodeChar; Src: PUTF8Char; Length: NativeUInt): NativeUInt; overload;
  function utf16_from_utf8_lower(Dest: PUnicodeChar; Src: PUTF8Char; Length: NativeUInt): NativeUInt; overload;
  function utf16_from_utf8_upper(Dest: PUnicodeChar; Src: PUTF8Char; Length: NativeUInt): NativeUInt; overload;
{$ifdef undef}{$ENDREGION}{$endif}

{$ifdef undef}{$REGION 'SBCS<-->UTF8<-->UTF16 conversions'}{$endif}
  procedure sbcs_from_sbcs(var Dest: AnsiString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}); overload;
  function sbcs_from_sbcs(const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_sbcs(var Dest: ShortString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0); overload;
  procedure sbcs_from_sbcs(var Dest: AnsiString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0); overload;
  function sbcs_from_sbcs(const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_sbcs(var Dest: ShortString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}); overload;
  procedure sbcs_from_sbcs_lower(var Dest: AnsiString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}); overload;
  function sbcs_from_sbcs_lower(const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_sbcs_lower(var Dest: ShortString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0); overload;
  procedure sbcs_from_sbcs_lower(var Dest: AnsiString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0); overload;
  function sbcs_from_sbcs_lower(const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_sbcs_lower(var Dest: ShortString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}); overload;
  procedure sbcs_from_sbcs_upper(var Dest: AnsiString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}); overload;
  function sbcs_from_sbcs_upper(const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_sbcs_upper(var Dest: ShortString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0); overload;
  procedure sbcs_from_sbcs_upper(var Dest: AnsiString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0); overload;
  function sbcs_from_sbcs_upper(const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_sbcs_upper(var Dest: ShortString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}); overload;

  procedure sbcs_from_utf8(var Dest: AnsiString; const Src: UTF8String; const CodePage: Word = 0); overload;
  function sbcs_from_utf8(const Src: UTF8String; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_utf8(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0); overload;
  procedure sbcs_from_utf8(var Dest: AnsiString; const Src: ShortString; const CodePage: Word = 0); overload;
  function sbcs_from_utf8(const Src: ShortString; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_utf8(var Dest: ShortString; const Src: UTF8String; const CodePage: Word = 0); overload;
  procedure sbcs_from_utf8_lower(var Dest: AnsiString; const Src: UTF8String; const CodePage: Word = 0); overload;
  function sbcs_from_utf8_lower(const Src: UTF8String; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_utf8_lower(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0); overload;
  procedure sbcs_from_utf8_lower(var Dest: AnsiString; const Src: ShortString; const CodePage: Word = 0); overload;
  function sbcs_from_utf8_lower(const Src: ShortString; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_utf8_lower(var Dest: ShortString; const Src: UTF8String; const CodePage: Word = 0); overload;
  procedure sbcs_from_utf8_upper(var Dest: AnsiString; const Src: UTF8String; const CodePage: Word = 0); overload;
  function sbcs_from_utf8_upper(const Src: UTF8String; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_utf8_upper(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0); overload;
  procedure sbcs_from_utf8_upper(var Dest: AnsiString; const Src: ShortString; const CodePage: Word = 0); overload;
  function sbcs_from_utf8_upper(const Src: ShortString; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure sbcs_from_utf8_upper(var Dest: ShortString; const Src: UTF8String; const CodePage: Word = 0); overload;

  procedure sbcs_from_utf16(var Dest: AnsiString; const Src: WideString; const CodePage: Word = 0); overload;
  {$ifdef UNICODE} procedure sbcs_from_utf16(var Dest: AnsiString; const Src: UnicodeString; const CodePage: Word = 0); overload; {$endif}
  function sbcs_from_utf16(const Src: WideString; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function sbcs_from_utf16(const Src: UnicodeString; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure sbcs_from_utf16(var Dest: ShortString; const Src: WideString; const CodePage: Word = 0); overload;
  {$ifdef UNICODE} procedure sbcs_from_utf16(var Dest: ShortString; const Src: UnicodeString; const CodePage: Word = 0); overload; {$endif}
  procedure sbcs_from_utf16_lower(var Dest: AnsiString; const Src: WideString; const CodePage: Word = 0); overload;
  {$ifdef UNICODE} procedure sbcs_from_utf16_lower(var Dest: AnsiString; const Src: UnicodeString; const CodePage: Word = 0); overload; {$endif}
  function sbcs_from_utf16_lower(const Src: WideString; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function sbcs_from_utf16_lower(const Src: UnicodeString; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure sbcs_from_utf16_lower(var Dest: ShortString; const Src: WideString; const CodePage: Word = 0); overload;
  {$ifdef UNICODE} procedure sbcs_from_utf16_lower(var Dest: ShortString; const Src: UnicodeString; const CodePage: Word = 0); overload; {$endif}
  procedure sbcs_from_utf16_upper(var Dest: AnsiString; const Src: WideString; const CodePage: Word = 0); overload;
  {$ifdef UNICODE} procedure sbcs_from_utf16_upper(var Dest: AnsiString; const Src: UnicodeString; const CodePage: Word = 0); overload; {$endif}
  function sbcs_from_utf16_upper(const Src: WideString; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function sbcs_from_utf16_upper(const Src: UnicodeString; const CodePage: Word = 0): AnsiString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure sbcs_from_utf16_upper(var Dest: ShortString; const Src: WideString; const CodePage: Word = 0); overload;
  {$ifdef UNICODE} procedure sbcs_from_utf16_upper(var Dest: ShortString; const Src: UnicodeString; const CodePage: Word = 0); overload; {$endif}

  procedure utf8_from_sbcs(var Dest: UTF8String; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload;
  function utf8_from_sbcs(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure utf8_from_sbcs(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0); overload;
  procedure utf8_from_sbcs(var Dest: UTF8String; const Src: ShortString; const CodePage: Word = 0); overload;
  function utf8_from_sbcs(const Src: ShortString; const CodePage: Word = 0): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure utf8_from_sbcs(var Dest: ShortString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload;
  procedure utf8_from_sbcs_lower(var Dest: UTF8String; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload;
  function utf8_from_sbcs_lower(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure utf8_from_sbcs_lower(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0); overload;
  procedure utf8_from_sbcs_lower(var Dest: UTF8String; const Src: ShortString; const CodePage: Word = 0); overload;
  function utf8_from_sbcs_lower(const Src: ShortString; const CodePage: Word = 0): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure utf8_from_sbcs_lower(var Dest: ShortString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload;
  procedure utf8_from_sbcs_upper(var Dest: UTF8String; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload;
  function utf8_from_sbcs_upper(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure utf8_from_sbcs_upper(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0); overload;
  procedure utf8_from_sbcs_upper(var Dest: UTF8String; const Src: ShortString; const CodePage: Word = 0); overload;
  function utf8_from_sbcs_upper(const Src: ShortString; const CodePage: Word = 0): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure utf8_from_sbcs_upper(var Dest: ShortString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload;

  procedure utf8_from_utf8_lower(var Dest: UTF8String; const Src: UTF8String); overload;
  function utf8_from_utf8_lower(const Src: UTF8String): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure utf8_from_utf8_lower(var Dest: ShortString; const Src: ShortString); overload;
  procedure utf8_from_utf8_lower(var Dest: UTF8String; const Src: ShortString); overload;
  function utf8_from_utf8_lower(const Src: ShortString): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure utf8_from_utf8_lower(var Dest: ShortString; const Src: UTF8String); overload;
  procedure utf8_from_utf8_upper(var Dest: UTF8String; const Src: UTF8String); overload;
  function utf8_from_utf8_upper(const Src: UTF8String): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure utf8_from_utf8_upper(var Dest: ShortString; const Src: ShortString); overload;
  procedure utf8_from_utf8_upper(var Dest: UTF8String; const Src: ShortString); overload;
  function utf8_from_utf8_upper(const Src: ShortString): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  procedure utf8_from_utf8_upper(var Dest: ShortString; const Src: UTF8String); overload;

  procedure utf8_from_utf16(var Dest: UTF8String; const Src: WideString); overload;
  {$ifdef UNICODE} procedure utf8_from_utf16(var Dest: UTF8String; const Src: UnicodeString); overload; {$endif}
  function utf8_from_utf16(const Src: WideString): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf8_from_utf16(const Src: UnicodeString): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf8_from_utf16(var Dest: ShortString; const Src: WideString); overload;
  {$ifdef UNICODE} procedure utf8_from_utf16(var Dest: ShortString; const Src: UnicodeString); overload; {$endif}
  procedure utf8_from_utf16_lower(var Dest: UTF8String; const Src: WideString); overload;
  {$ifdef UNICODE} procedure utf8_from_utf16_lower(var Dest: UTF8String; const Src: UnicodeString); overload; {$endif}
  function utf8_from_utf16_lower(const Src: WideString): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf8_from_utf16_lower(const Src: UnicodeString): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf8_from_utf16_lower(var Dest: ShortString; const Src: WideString); overload;
  {$ifdef UNICODE} procedure utf8_from_utf16_lower(var Dest: ShortString; const Src: UnicodeString); overload; {$endif}
  procedure utf8_from_utf16_upper(var Dest: UTF8String; const Src: WideString); overload;
  {$ifdef UNICODE} procedure utf8_from_utf16_upper(var Dest: UTF8String; const Src: UnicodeString); overload; {$endif}
  function utf8_from_utf16_upper(const Src: WideString): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf8_from_utf16_upper(const Src: UnicodeString): UTF8String; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf8_from_utf16_upper(var Dest: ShortString; const Src: WideString); overload;
  {$ifdef UNICODE} procedure utf8_from_utf16_upper(var Dest: ShortString; const Src: UnicodeString); overload; {$endif}

  procedure utf16_from_sbcs(var Dest: WideString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload;
  {$ifdef UNICODE} procedure utf16_from_sbcs(var Dest: UnicodeString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_sbcs(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_sbcs(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_sbcs(var Dest: WideString; const Src: ShortString; const CodePage: Word = 0); overload;
  {$ifdef UNICODE} procedure utf16_from_sbcs(var Dest: UnicodeString; const Src: ShortString; const CodePage: Word = 0); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_sbcs(const Src: ShortString; const CodePage: Word = 0): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_sbcs(const Src: ShortString; const CodePage: Word = 0): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_sbcs_lower(var Dest: WideString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload;
  {$ifdef UNICODE} procedure utf16_from_sbcs_lower(var Dest: UnicodeString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_sbcs_lower(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_sbcs_lower(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_sbcs_lower(var Dest: WideString; const Src: ShortString; const CodePage: Word = 0); overload;
  {$ifdef UNICODE} procedure utf16_from_sbcs_lower(var Dest: UnicodeString; const Src: ShortString; const CodePage: Word = 0); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_sbcs_lower(const Src: ShortString; const CodePage: Word = 0): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_sbcs_lower(const Src: ShortString; const CodePage: Word = 0): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_sbcs_upper(var Dest: WideString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload;
  {$ifdef UNICODE} procedure utf16_from_sbcs_upper(var Dest: UnicodeString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_sbcs_upper(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_sbcs_upper(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_sbcs_upper(var Dest: WideString; const Src: ShortString; const CodePage: Word = 0); overload;
  {$ifdef UNICODE} procedure utf16_from_sbcs_upper(var Dest: UnicodeString; const Src: ShortString; const CodePage: Word = 0); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_sbcs_upper(const Src: ShortString; const CodePage: Word = 0): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_sbcs_upper(const Src: ShortString; const CodePage: Word = 0): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}

  procedure utf16_from_utf8(var Dest: WideString; const Src: UTF8String); overload;
  {$ifdef UNICODE} procedure utf16_from_utf8(var Dest: UnicodeString; const Src: UTF8String); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_utf8(const Src: UTF8String): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_utf8(const Src: UTF8String): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_utf8(var Dest: WideString; const Src: ShortString); overload;
  {$ifdef UNICODE} procedure utf16_from_utf8(var Dest: UnicodeString; const Src: ShortString); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_utf8(const Src: ShortString): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_utf8(const Src: ShortString): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_utf8_lower(var Dest: WideString; const Src: UTF8String); overload;
  {$ifdef UNICODE} procedure utf16_from_utf8_lower(var Dest: UnicodeString; const Src: UTF8String); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_utf8_lower(const Src: UTF8String): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_utf8_lower(const Src: UTF8String): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_utf8_lower(var Dest: WideString; const Src: ShortString); overload;
  {$ifdef UNICODE} procedure utf16_from_utf8_lower(var Dest: UnicodeString; const Src: ShortString); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_utf8_lower(const Src: ShortString): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_utf8_lower(const Src: ShortString): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_utf8_upper(var Dest: WideString; const Src: UTF8String); overload;
  {$ifdef UNICODE} procedure utf16_from_utf8_upper(var Dest: UnicodeString; const Src: UTF8String); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_utf8_upper(const Src: UTF8String): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_utf8_upper(const Src: UTF8String): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_utf8_upper(var Dest: WideString; const Src: ShortString); overload;
  {$ifdef UNICODE} procedure utf16_from_utf8_upper(var Dest: UnicodeString; const Src: ShortString); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_utf8_upper(const Src: ShortString): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_utf8_upper(const Src: ShortString): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}

  procedure utf16_from_utf16_lower(var Dest: WideString; const Src: WideString); overload;
  {$ifdef UNICODE} procedure utf16_from_utf16_lower(var Dest: UnicodeString; const Src: UnicodeString); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_utf16_lower(const Src: WideString): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_utf16_lower(const Src: UnicodeString): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  procedure utf16_from_utf16_upper(var Dest: WideString; const Src: WideString); overload;
  {$ifdef UNICODE} procedure utf16_from_utf16_upper(var Dest: UnicodeString; const Src: UnicodeString); overload; {$endif}
  {$ifNdef UNICODE} function utf16_from_utf16_upper(const Src: WideString): WideString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  {$ifdef UNICODE} function utf16_from_utf16_upper(const Src: UnicodeString): UnicodeString; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
{$ifdef undef}{$ENDREGION}{$endif}

{$ifdef undef}{$REGION 'low level comparison routine'}{$endif}
type
  TTextConvCompareOptions = record
    Length: NativeUInt;
    Lookup: Pointer;
    Length_2: NativeUInt;
    Lookup_2: Pointer;
  end;
  PTextConvCompareOptions = ^TTextConvCompareOptions;

  function __textconv_compare_bytes(S1, S2: PByte; Length: NativeUInt): NativeInt;
  function __textconv_compare_words(S1, S2: PWord; Length: NativeUInt): NativeInt;
  function __textconv_sbcs_compare_sbcs_1(S1, S2: PAnsiChar; const Comp: TTextConvCompareOptions): NativeInt;
  function __textconv_sbcs_compare_sbcs_2(S1, S2: PAnsiChar; const Comp: TTextConvCompareOptions): NativeInt;
  function __textconv_utf16_compare_utf16(S1, S2: PUnicodeChar; Length: NativeUInt): NativeInt;
  function __textconv_utf16_compare_sbcs(S1: PUnicodeChar; S2: PAnsiChar; const Comp: TTextConvCompareOptions): NativeInt;
  function __textconv_utf8_compare_utf16(S1: PUTF8Char; S2: PUnicodeChar; const Comp: TTextConvCompareOptions): NativeInt;
  function __textconv_utf8_compare_utf8(S1, S2: PUTF8Char; const Comp: TTextConvCompareOptions): NativeInt;
  function __textconv_utf8_compare_sbcs(S1: PUTF8Char; S2: PAnsiChar; const Comp: TTextConvCompareOptions): NativeInt;
{$ifdef undef}{$ENDREGION}{$endif}

{$ifdef undef}{$REGION 'SBCS<-->UTF8<-->UTF16 comparisons'}{$endif}
  function sbcs_equal_sbcs(S1: PAnsiChar; S2: PAnsiChar; Length: NativeUInt; CP1: Word = 0; CP2: Word = 0): Boolean; overload;
  function sbcs_equal_samesbcs(S1: PAnsiChar; S2: PAnsiChar; Length: NativeUInt): Boolean; overload;
  function sbcs_equal_sbcs(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP1: Word = 0; const CP2: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_equal_samesbcs(const S1: AnsiString; const S2: AnsiString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_equal_sbcs(const S1: ShortString; const S2: ShortString; const CP1: Word = 0; const CP2: Word = 0): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_equal_samesbcs(const S1: ShortString; const S2: ShortString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_equal_sbcs_ignorecase(S1: PAnsiChar; S2: PAnsiChar; Length: NativeUInt; CP1: Word = 0; CP2: Word = 0): Boolean; overload;
  function sbcs_equal_samesbcs_ignorecase(S1: PAnsiChar; S2: PAnsiChar; Length: NativeUInt; CodePage: Word = 0): Boolean; overload;
  function sbcs_equal_sbcs_ignorecase(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP1: Word = 0; const CP2: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_equal_samesbcs_ignorecase(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_equal_sbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CP1: Word = 0; const CP2: Word = 0): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_equal_samesbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_compare_sbcs(S1: PAnsiChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CP1: Word = 0; CP2: Word = 0): NativeInt; overload;
  function sbcs_compare_samesbcs(S1: PAnsiChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt): NativeInt; overload;
  function sbcs_compare_sbcs(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP1: Word = 0; const CP2: Word = 0{$endif}): NativeInt; overload;
  function sbcs_compare_samesbcs(const S1: AnsiString; const S2: AnsiString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_compare_sbcs(const S1: ShortString; const S2: ShortString; const CP1: Word = 0; const CP2: Word = 0): NativeInt; overload;
  function sbcs_compare_samesbcs(const S1: ShortString; const S2: ShortString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_compare_sbcs_ignorecase(S1: PAnsiChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CP1: Word = 0; CP2: Word = 0): NativeInt; overload;
  function sbcs_compare_samesbcs_ignorecase(S1: PAnsiChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): NativeInt; overload;
  function sbcs_compare_sbcs_ignorecase(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP1: Word = 0; const CP2: Word = 0{$endif}): NativeInt; overload;
  function sbcs_compare_samesbcs_ignorecase(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_compare_sbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CP1: Word = 0; const CP2: Word = 0): NativeInt; overload;
  function sbcs_compare_samesbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

  function sbcs_equal_utf8(S1: PAnsiChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt; CodePage: Word = 0): Boolean; overload;
  function sbcs_equal_utf8(const S1: AnsiString; const S2: UTF8String{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_equal_utf8(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_equal_utf8_ignorecase(S1: PAnsiChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt; CodePage: Word = 0): Boolean; overload;
  function sbcs_equal_utf8_ignorecase(const S1: AnsiString; const S2: UTF8String{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_equal_utf8_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_compare_utf8(S1: PAnsiChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt; CodePage: Word = 0): NativeInt; overload;
  function sbcs_compare_utf8(const S1: AnsiString; const S2: UTF8String{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_compare_utf8(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_compare_utf8_ignorecase(S1: PAnsiChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt; CodePage: Word = 0): NativeInt; overload;
  function sbcs_compare_utf8_ignorecase(const S1: AnsiString; const S2: UTF8String{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function sbcs_compare_utf8_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

  function sbcs_equal_utf16(S1: PAnsiChar; S2: PWideChar; Length: NativeUInt; CodePage: Word = 0): Boolean; overload;
  function sbcs_equal_utf16(const S1: AnsiString; const S2: WideString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function sbcs_equal_utf16(const S1: AnsiString; const S2: UnicodeString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function sbcs_equal_utf16_ignorecase(S1: PAnsiChar; S2: PWideChar; Length: NativeUInt; CodePage: Word = 0): Boolean; overload;
  function sbcs_equal_utf16_ignorecase(const S1: AnsiString; const S2: WideString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function sbcs_equal_utf16_ignorecase(const S1: AnsiString; const S2: UnicodeString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function sbcs_compare_utf16(S1: PAnsiChar; L1: NativeUInt; S2: PWideChar; L2: NativeUInt; CodePage: Word = 0): NativeInt; overload;
  function sbcs_compare_utf16(const S1: AnsiString; const S2: WideString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function sbcs_compare_utf16(const S1: AnsiString; const S2: UnicodeString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function sbcs_compare_utf16_ignorecase(S1: PAnsiChar; L1: NativeUInt; S2: PWideChar; L2: NativeUInt; CodePage: Word = 0): NativeInt; overload;
  function sbcs_compare_utf16_ignorecase(const S1: AnsiString; const S2: WideString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function sbcs_compare_utf16_ignorecase(const S1: AnsiString; const S2: UnicodeString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}

  function utf8_equal_sbcs(S1: PUTF8Char; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): Boolean; overload;
  function utf8_equal_sbcs(const S1: UTF8String; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_equal_sbcs(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_equal_sbcs_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): Boolean; overload;
  function utf8_equal_sbcs_ignorecase(const S1: UTF8String; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_equal_sbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_compare_sbcs(S1: PUTF8Char; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): NativeInt; overload;
  function utf8_compare_sbcs(const S1: UTF8String; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_compare_sbcs(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_compare_sbcs_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): NativeInt; overload;
  function utf8_compare_sbcs_ignorecase(const S1: UTF8String; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_compare_sbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

  function utf8_equal_utf8(S1: PUTF8Char; S2: PUTF8Char; Length: NativeUInt): Boolean; overload;
  function utf8_equal_utf8(const S1: UTF8String; const S2: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_equal_utf8(const S1: ShortString; const S2: ShortString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_equal_utf8_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): Boolean; overload;
  function utf8_equal_utf8_ignorecase(const S1: UTF8String; const S2: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_equal_utf8_ignorecase(const S1: ShortString; const S2: ShortString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_compare_utf8(S1: PUTF8Char; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): NativeInt; overload;
  function utf8_compare_utf8(const S1: UTF8String; const S2: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_compare_utf8(const S1: ShortString; const S2: ShortString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_compare_utf8_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): NativeInt; overload;
  function utf8_compare_utf8_ignorecase(const S1: UTF8String; const S2: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  function utf8_compare_utf8_ignorecase(const S1: ShortString; const S2: ShortString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}

  function utf8_equal_utf16(S1: PUTF8Char; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): Boolean; overload;
  function utf8_equal_utf16(const S1: UTF8String; const S2: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf8_equal_utf16(const S1: UTF8String; const S2: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf8_equal_utf16_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): Boolean; overload;
  function utf8_equal_utf16_ignorecase(const S1: UTF8String; const S2: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf8_equal_utf16_ignorecase(const S1: UTF8String; const S2: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf8_compare_utf16(S1: PUTF8Char; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): NativeInt; overload;
  function utf8_compare_utf16(const S1: UTF8String; const S2: WideString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf8_compare_utf16(const S1: UTF8String; const S2: UnicodeString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf8_compare_utf16_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): NativeInt; overload;
  function utf8_compare_utf16_ignorecase(const S1: UTF8String; const S2: WideString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf8_compare_utf16_ignorecase(const S1: UTF8String; const S2: UnicodeString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}

  function utf16_equal_sbcs(S1: PWideChar; S2: PAnsiChar; Length: NativeUInt; CodePage: Word = 0): Boolean; overload;
  function utf16_equal_sbcs(const S1: WideString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_equal_sbcs(const S1: UnicodeString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf16_equal_sbcs_ignorecase(S1: PWideChar; S2: PAnsiChar; Length: NativeUInt; CodePage: Word = 0): Boolean; overload;
  function utf16_equal_sbcs_ignorecase(const S1: WideString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_equal_sbcs_ignorecase(const S1: UnicodeString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf16_compare_sbcs(S1: PWideChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): NativeInt; overload;
  function utf16_compare_sbcs(const S1: WideString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_compare_sbcs(const S1: UnicodeString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf16_compare_sbcs_ignorecase(S1: PWideChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): NativeInt; overload;
  function utf16_compare_sbcs_ignorecase(const S1: WideString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_compare_sbcs_ignorecase(const S1: UnicodeString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}

  function utf16_equal_utf8(S1: PWideChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): Boolean; overload;
  function utf16_equal_utf8(const S1: WideString; const S2: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_equal_utf8(const S1: UnicodeString; const S2: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf16_equal_utf8_ignorecase(S1: PWideChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): Boolean; overload;
  function utf16_equal_utf8_ignorecase(const S1: WideString; const S2: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_equal_utf8_ignorecase(const S1: UnicodeString; const S2: UTF8String): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf16_compare_utf8(S1: PWideChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): NativeInt; overload;
  function utf16_compare_utf8(const S1: WideString; const S2: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_compare_utf8(const S1: UnicodeString; const S2: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf16_compare_utf8_ignorecase(S1: PWideChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): NativeInt; overload;
  function utf16_compare_utf8_ignorecase(const S1: WideString; const S2: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_compare_utf8_ignorecase(const S1: UnicodeString; const S2: UTF8String): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}

  function utf16_equal_utf16(S1: PWideChar; S2: PWideChar; Length: NativeUInt): Boolean; overload;
  function utf16_equal_utf16(const S1: WideString; const S2: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_equal_utf16(const S1: UnicodeString; const S2: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf16_equal_utf16_ignorecase(S1: PWideChar; S2: PWideChar; Length: NativeUInt): Boolean; overload;
  function utf16_equal_utf16_ignorecase(const S1: WideString; const S2: WideString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_equal_utf16_ignorecase(const S1: UnicodeString; const S2: UnicodeString): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf16_compare_utf16(S1: PWideChar; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): NativeInt; overload;
  function utf16_compare_utf16(const S1: WideString; const S2: WideString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_compare_utf16(const S1: UnicodeString; const S2: UnicodeString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
  function utf16_compare_utf16_ignorecase(S1: PWideChar; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): NativeInt; overload;
  function utf16_compare_utf16_ignorecase(const S1: WideString; const S2: WideString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifdef UNICODE} function utf16_compare_utf16_ignorecase(const S1: UnicodeString; const S2: UnicodeString): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}{$endif}
{$ifdef undef}{$ENDREGION}{$endif}

implementation

type
  T4Bytes = array[0..3] of Byte;
  P4Bytes = ^T4Bytes;

  T8Bytes = array[0..7] of Byte;
  P8Bytes = ^T8Bytes;

  {$ifNdef CPUX86}
    {$define CPUMANYREGS}
  {$endif}

const
  HIGH_NATIVE_BIT = {$ifdef SMALLINT}31{$else}63{$endif};
  UNICODE_CHARACTERS_COUNT = MAXIMUM_CHARACTER + 1;
  CHARCASE_OFFSET = $10000;
  WORDS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(Word);
  WORDS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);

  MASK_80_SMALL = $80808080;
  MASK_80_LARGE = $8080808080808080;
  MASK_80_DEFAULT = {$ifdef SMALLINT}MASK_80_SMALL{$else}MASK_80_LARGE{$endif};

  MASK_7F_SMALL = $7F7F7F7F;
  MASK_7F_LARGE = $7F7F7F7F7F7F7F7F;
  MASK_7F_DEFAULT = {$ifdef SMALLINT}MASK_7F_SMALL{$else}MASK_7F_LARGE{$endif};

  MASK_40_SMALL = $40404040;
  MASK_40_LARGE = $4040404040404040;
  MASK_40_DEFAULT = {$ifdef SMALLINT}MASK_40_SMALL{$else}MASK_40_LARGE{$endif};

  MASK_60_SMALL = $60606060;
  MASK_60_LARGE = $6060606060606060;
  MASK_60_DEFAULT = {$ifdef SMALLINT}MASK_60_SMALL{$else}MASK_60_LARGE{$endif};

  MASK_65_SMALL = $65656565;
  MASK_65_LARGE = $6565656565656565;
  MASK_65_DEFAULT = {$ifdef SMALLINT}MASK_65_SMALL{$else}MASK_65_LARGE{$endif};

  MASK_01_SMALL = $01010101;
  MASK_01_LARGE = $0101010101010101;
  MASK_01_DEFAULT = {$ifdef SMALLINT}MASK_01_SMALL{$else}MASK_01_LARGE{$endif};

  MASK_FF80_SMALL = $FF80FF80;
  MASK_FF80_LARGE = $FF80FF80FF80FF80;
  MASK_FF80_DEFAULT = {$ifdef SMALLINT}MASK_FF80_SMALL{$else}MASK_FF80_LARGE{$endif};

  MASK_007F_SMALL = $007F007F;
  MASK_007F_LARGE = $007F007F007F007F;
  MASK_007F_DEFAULT = {$ifdef SMALLINT}MASK_007F_SMALL{$else}MASK_007F_LARGE{$endif};

  MASK_0040_SMALL = $00400040;
  MASK_0040_LARGE = $0040004000400040;
  MASK_0040_DEFAULT = {$ifdef SMALLINT}MASK_0040_SMALL{$else}MASK_0040_LARGE{$endif};

  MASK_0060_SMALL = $00600060;
  MASK_0060_LARGE = $0060006000600060;
  MASK_0060_DEFAULT = {$ifdef SMALLINT}MASK_0060_SMALL{$else}MASK_0060_LARGE{$endif};

  MASK_0065_SMALL = $00650065;
  MASK_0065_LARGE = $0065006500650065;
  MASK_0065_DEFAULT = {$ifdef SMALLINT}MASK_0065_SMALL{$else}MASK_0065_LARGE{$endif};


// x86 architecture compatibility
{$ifNdef CPUX86}
function Swap(const X: NativeUInt): NativeUInt; inline;
begin
  Result := (Byte(X) shl 8) + Byte(X shr 8);
end;
{$endif}

var
  InternalLookups: Pointer = nil;

function InternalLookupAlloc(const Size: NativeInt): Pointer; {$ifdef INLINESUPPORT}inline;{$endif}
begin
  GetMem(Result, SizeOf(Pointer) + Size);
  Inc(NativeInt(Result), SizeOf(Pointer));
end;

function InternalLookupFill(var Target: Pointer; Value: Pointer): Pointer;
var
  Lookup: Pointer;
begin
  Result := AtomicCmpExchange(Target, Value, nil);
  if (Result = nil) then
  begin
    Result := Value;

    Dec(NativeInt(Value), SizeOf(Pointer));
    repeat
      Lookup := InternalLookups;
      PPointer(Value)^ := Lookup;
    until (Lookup = AtomicCmpExchange(InternalLookups, Value, Lookup));
  end else
  begin
    Dec(NativeInt(Value), SizeOf(Pointer));
    FreeMem(Value);
  end;
end;

procedure InternalLookupsFinalize;
var
  Lookup, Next: Pointer;
begin
  Lookup := InternalLookups;

  while (Lookup <> nil) do
  begin
    Next := PPointer(Lookup)^;
    FreeMem(Lookup);

    Lookup := Next;
  end;
end;

procedure InternalLookupsInitialize;
const
  SBCS_CODE_PAGES: array[Low(TEXTCONV_SUPPORTED_SBCS)..High(TEXTCONV_SUPPORTED_SBCS)] of Word  =
  (CODEPAGE_RAWDATA,874,1250,1251,1252,1253,1254,1255,1256,1257,1258,866,28592,28593,28594,
   28595,28596,28597,28598,28600,28603,28604,28605,28606,20866,21866,10000,10007,CODEPAGE_USERDEFINED);

  CHARS_TABLE: array[0..12-1+1] of Cardinal  =
  (
    ($0041{A..Z} shl 16) or $2000{correction $20} or ($005A-$0041+1){count},
    ($00C0 shl 16) or $2000{correction $20} or ($00D6-$00C0+1),
    ($00D8 shl 16) or $2000{correction $20} or ($00DE-$00D8+1),
    ($0189 shl 16) or $CD00{correction $CD} or ($018A-$0189+1),
    ($0391 shl 16) or $2000{correction $20} or ($03A1-$0391+1),
    ($03A3 shl 16) or $2000{correction $20} or ($03AB-$03A3+1),
    ($0400 shl 16) or $5000{correction $50} or ($040F-$0400+1),
    ($0410 shl 16) or $2000{correction $20} or ($042F-$0410+1),
    ($0531 shl 16) or $3000{correction $30} or ($0556-$0531+1),
    ($2160 shl 16) or $1000{correction $10} or ($216F-$2160+1),
    ($24B6 shl 16) or $1A00{correction $1A} or ($24CF-$24B6+1),
    ($2C00 shl 16) or $3000{correction $30} or ($2C2E-$2C00+1),
    (Cardinal($FF21) shl 16) or $2000{correction $20} or ($FF3A-$FF21+1)
  );

  CHARS_TABLE_INVERT: array[0..18] of Cardinal  =
  (
    ($1F08 shl 16) or $0800{correction -$08} or ($1F0F-$1F08+1){count},
    ($1F18 shl 16) or $0800{correction -$08} or ($1F1D-$1F18+1),
    ($1F28 shl 16) or $0800{correction -$08} or ($1F2F-$1F28+1),
    ($1F38 shl 16) or $0800{correction -$08} or ($1F3F-$1F38+1),
    ($1F48 shl 16) or $0800{correction -$08} or ($1F4D-$1F48+1),
    ($1F59 shl 16) or $0800{correction -$08} or ($1F5F-$1F59+1),
    ($1F68 shl 16) or $0800{correction -$08} or ($1F6F-$1F68+1),
    ($1F88 shl 16) or $0800{correction -$08} or ($1F8F-$1F88+1),
    ($1F98 shl 16) or $0800{correction -$08} or ($1F9F-$1F98+1),
    ($1FA8 shl 16) or $0800{correction -$08} or ($1FAF-$1FA8+1),
    ($1FB8 shl 16) or $0800{correction -$08} or ($1FB9-$1FB8+1),
    ($1FBA shl 16) or $4A00{correction -$4A} or ($1FBB-$1FBA+1),
    ($1FC8 shl 16) or $5600{correction -$56} or ($1FCB-$1FC8+1),
    ($1FD8 shl 16) or $0800{correction -$08} or ($1FD9-$1FD8+1),
    ($1FDA shl 16) or $6400{correction -$64} or ($1FDB-$1FDA+1),
    ($1FE8 shl 16) or $0800{correction -$08} or ($1FE9-$1FE8+1),
    ($1FEA shl 16) or $7000{correction -$70} or ($1FEB-$1FEA+1),
    ($1FF8 shl 16) or $8000{correction -$80} or ($1FF9-$1FF8+1),
    ($1FFA shl 16) or $7E00{correction -$7E} or ($1FFB-$1FFA+1)
  );

  ONE_TABLE: array[0..38] of Cardinal  =
  (
    ($0100 shl 16) or ($012E-$0100+2) shr 1{count},
    ($0132 shl 16) or ($0136-$0132+2) shr 1,
    ($0139 shl 16) or ($0147-$0139+2) shr 1,
    ($014A shl 16) or ($0176-$014A+2) shr 1,
    ($0179 shl 16) or ($017D-$0179+2) shr 1,
    ($0182 shl 16) or ($0184-$0182+2) shr 1,
    ($0187 shl 16) or ($0187-$0187+2) shr 1,
    ($018B shl 16) or ($018B-$018B+2) shr 1,
    ($0191 shl 16) or ($0191-$0191+2) shr 1,
    ($0198 shl 16) or ($0198-$0198+2) shr 1,
    ($01A0 shl 16) or ($01A4-$01A0+2) shr 1,
    ($01A7 shl 16) or ($01A7-$01A7+2) shr 1,
    ($01AC shl 16) or ($01AC-$01AC+2) shr 1,
    ($01AF shl 16) or ($01AF-$01AF+2) shr 1,
    ($01B3 shl 16) or ($01B5-$01B3+2) shr 1,
    ($01B8 shl 16) or ($01BC-$01B8+2) shr 1,
    ($01CD shl 16) or ($01DB-$01CD+2) shr 1,
    ($01DE shl 16) or ($01EE-$01DE+2) shr 1,
    ($01F8 shl 16) or ($021E-$01F8+2) shr 1,
    ($0222 shl 16) or ($0232-$0222+2) shr 1,
    ($0246 shl 16) or ($024E-$0246+2) shr 1,
    ($0370 shl 16) or ($0372-$0370+2) shr 1,
    ($03D8 shl 16) or ($03EE-$03D8+2) shr 1,
    ($0460 shl 16) or ($0480-$0460+2) shr 1,
    ($048A shl 16) or ($04BE-$048A+2) shr 1,
    ($04C1 shl 16) or ($04CD-$04C1+2) shr 1,
    ($04D0 shl 16) or ($0522-$04D0+2) shr 1,
    ($1E00 shl 16) or ($1E94-$1E00+2) shr 1,
    ($1EA0 shl 16) or ($1EFE-$1EA0+2) shr 1,
    ($2C67 shl 16) or ($2C6B-$2C67+2) shr 1,
    ($2C80 shl 16) or ($2CE2-$2C80+2) shr 1,
    ($2C82 shl 16) or ($2CE2-$2C82+2) shr 1,
    (Cardinal($A640) shl 16) or ($A65E-$A640+2) shr 1,
    (Cardinal($A662) shl 16) or ($A66C-$A662+2) shr 1,
    (Cardinal($A680) shl 16) or ($A696-$A680+2) shr 1,
    (Cardinal($A722) shl 16) or ($A72E-$A722+2) shr 1,
    (Cardinal($A732) shl 16) or ($A76E-$A732+2) shr 1,
    (Cardinal($A779) shl 16) or ($A77B-$A779+2) shr 1,
    (Cardinal($A77E) shl 16) or ($A786-$A77E+2) shr 1
  );

  SINGLE_TABLE: array[0..67] of Cardinal  =
  (
     $017800FF,$01810253,$01860254,$018E01DD,$018F0259,$0190025B,
     $01930260,$01940263,$01960269,$01970268,$019C026F,$019D0272,
     $019F0275,$01A60280,$01A90283,$01AE0288,$01B1028A,$01B2028B,
     $01B70292,$01C401C6,$01C701C9,$01CA01CC,$01F101F3,$01F401F5,
     $01F60195,$01F701BF,$0220019E,$023B023C,$023D019A,$02410242,
     $02430180,$02440289,$0245028C,$03760377,$038603AC,$038803AD,
     $038903AE,$038A03AF,$038C03CC,$038E03CD,$038F03CE,$03CF03D7,
     $03F703F8,$03F903F2,$03FA03FB,$03FD037B,$03FE037C,$03FF037D,
     $04C004CF,$1FBC1FB3,$1FCC1FC3,$1FEC1FE5,$1FFC1FF3,$2132214E,
     $21832184,$2C602C61,$2C631D7D,$2C722C73,$2C752C76,$A77D1D79,$A78BA78C,
     // 7 rarly used characters, that disturb
     // same-length utf8 lower/upper conversion
     $023A2C65,$023E2C66,$2C6F0250,$2C6D0251,$2C62026B,$2C6E0271,$2C64027D
  );


{$if Defined(LARGEINT) or Defined(CPUARM)}
var
  UCS2_INCREMENT,
  UCS2_DONE: NativeUInt;
{$else}
const
  UCS2_INCREMENT = $00020002;
  UCS2_DONE = Cardinal(Integer($fffffffe) + UCS2_INCREMENT);
{$ifend}
type
  TNativeUIntArray = array[0..$20000] of NativeUInt;
  PNativeUIntArray = ^TNativeUIntArray;
  TWordArray = array[0..$20000] of Word;
  PWordArray = ^TWordArray;
var
  P1, P2: PNativeUInt;
  i, L, U, C: NativeUInt;
  CharCaseItem: PWord;
  NativeArr: PNativeUIntArray;
begin
  // basic sbcs(ansi) information
  for i := Low(TEXTCONV_SUPPORTED_SBCS) to High(TEXTCONV_SUPPORTED_SBCS) do
  begin
    TEXTCONV_SUPPORTED_SBCS[i].F.Index := i;
    TEXTCONV_SUPPORTED_SBCS[i].F.CodePage := SBCS_CODE_PAGES[i];
  end;

  // default code page
  CODEPAGE_DEFAULT := DefaultCP;
  DEFAULT_TEXTCONV_SBCS := TextConvSBCS(CODEPAGE_DEFAULT);
  DEFAULT_TEXTCONV_SBCS_INDEX := DEFAULT_TEXTCONV_SBCS.Index;
  TEXTCONV_SUPPORTED_SBCS_HASH[0].Index := DEFAULT_TEXTCONV_SBCS_INDEX;
  if (DEFAULT_TEXTCONV_SBCS_INDEX = 0) then TEXTCONV_SUPPORTED_SBCS_HASH[0].Next := $80;

  // fill by default chars: textconv_charcase.lower & textconv_charcase.upper
  P1 := Pointer(@TEXTCONV_CHARCASE.LOWER);
  P2 := Pointer(@TEXTCONV_CHARCASE.UPPER);
  {$ifdef LARGEINT}
    U := $0003000200010000;
    UCS2_INCREMENT := $0004000400040004;
    UCS2_DONE := NativeUInt($fffffffefffdfffc) + UCS2_INCREMENT;
  {$else}
    U := $00010000;
    {$ifdef CPUARM}
    UCS2_INCREMENT := $00020002;
    UCS2_DONE := Cardinal($fffffffe) + UCS2_INCREMENT;
    {$endif}
  {$endif}
  repeat
    P1^ := U;
    P2^ := U;
    Inc(U, UCS2_INCREMENT);
    Inc(P1);
    Inc(P2);

    P1^ := U;
    P2^ := U;
    Inc(U, UCS2_INCREMENT);
    Inc(P1);
    Inc(P2);

    P1^ := U;
    P2^ := U;
    Inc(U, UCS2_INCREMENT);
    Inc(P1);
    Inc(P2);

    P1^ := U;
    P2^ := U;
    Inc(U, UCS2_INCREMENT);
    Inc(P1);
    Inc(P2);
  until (U = UCS2_DONE);

  // fill upper and lower for a..z/A..Z
  P1 := Pointer(@TEXTCONV_CHARCASE.VALUES{LOWER}[$41{Ord('A')}]);
  P2 := Pointer(@TEXTCONV_CHARCASE.VALUES{UPPER}[CHARCASE_OFFSET + $61{Ord('a')}]);
  {$ifdef LARGEINT}
    U := $0064006300620061;
    L := $0044004300420041;
  {$else}
    U := $00620061;
    L := $00420041;
  {$endif}
  for i := 0 to (26 * SizeOf(Word) div SizeOf(NativeUInt))-1 do
  begin
    P1^ := U;
    P2^ := L;
    Inc(P1);
    Inc(P2);
    Inc(U, UCS2_INCREMENT);
    Inc(L, UCS2_INCREMENT);
  end;
  {$ifdef LARGEINT}
  PCardinal(P1)^ := U;
  PCardinal(P2)^ := L;
  {$endif}

  // many upper and lower chars
  for i := Low(CHARS_TABLE) to High(CHARS_TABLE) do
  begin
    C := CHARS_TABLE[i];
    U := C shr 16;
    L := U + ((C shr 8) and $ff);

    C := C and $ff;
    repeat
      TEXTCONV_CHARCASE.VALUES{LOWER}[U] := L;
      TEXTCONV_CHARCASE.VALUES{UPPER}[CHARCASE_OFFSET + L] := U;
      Dec(C);
      Inc(L);
      Inc(U);
    until (C = 0);
  end;

  // invert logic (negative offset)
  for i := Low(CHARS_TABLE_INVERT) to High(CHARS_TABLE_INVERT) do
  begin
    C := CHARS_TABLE_INVERT[i];
    U := C shr 16;
    L := U - ((C shr 8) and $ff);

    C := C and $ff;
    repeat
      TEXTCONV_CHARCASE.VALUES{LOWER}[U] := L;
      TEXTCONV_CHARCASE.VALUES{UPPER}[CHARCASE_OFFSET + L] := U;
      Dec(C);
      Inc(L);
      Inc(U);
    until (C = 0);
  end;

  // chars where the dirrefence is 1
  for i := Low(ONE_TABLE) to High(ONE_TABLE) do
  begin
    C := ONE_TABLE[i];
    U := C shr 16;
    L := U + 1;

    C := C and $ffff;
    repeat
      // TEXTCONV_CHARCASE.LOWER[U] := L;
      CharCaseItem := @TEXTCONV_CHARCASE.VALUES{LOWER}[U];
      CharCaseItem^ := L;
      // TEXTCONV_CHARCASE.UPPER[L] := U;
      PWordArray(CharCaseItem)[CHARCASE_OFFSET + 1] := U;

      Dec(C);
      Inc(L, 2);
      Inc(U, 2);
    until (C = 0);
  end;

  // special chars
  for i := Low(SINGLE_TABLE) to High(SINGLE_TABLE) do
  begin
    C := SINGLE_TABLE[i];
    U := C shr 16;
    L := C and $ffff;
    TEXTCONV_CHARCASE.VALUES{LOWER}[U] := L;
    TEXTCONV_CHARCASE.VALUES{UPPER}[CHARCASE_OFFSET + L] := U;
  end;

  // $10A0..$10C5
  L := $2D00;
  for U := $10A0 to $10C5 do
  begin
    TEXTCONV_CHARCASE.VALUES{LOWER}[U] := L;
    TEXTCONV_CHARCASE.VALUES{UPPER}[CHARCASE_OFFSET + L] := U;
    Inc(L);
  end;

  // TEXTCONV_UTF8CHAR_SIZE
  begin
    NativeArr := Pointer(@TEXTCONV_UTF8CHAR_SIZE);

    // 0..127
    U := {$ifdef LARGEINT}$0101010101010101{$else}$01010101{$endif};
    for i := 0 to 128 div SizeOf(NativeUInt) - 1 do
    NativeArr[i] := U;

    // 128..191 (64) fail (0)
    Inc(NativeUInt(NativeArr), 128);
    U := 0;
    for i := 0 to 64 div SizeOf(NativeUInt) - 1 do
    NativeArr[i] := U;

    // 192..223 (32)
    Inc(NativeUInt(NativeArr), 64);
    U := {$ifdef LARGEINT}$0202020202020202{$else}$02020202{$endif};
    for i := 0 to 32 div SizeOf(NativeUInt) - 1 do
    NativeArr[i] := U;

    // 224..239 (16)
    Inc(NativeUInt(NativeArr), 32);
    U := {$ifdef LARGEINT}$0303030303030303{$else}$03030303{$endif};
    {$ifdef LARGEINT}
      NativeArr[0] := U;
      NativeArr[1] := U;
    {$else}
      NativeArr[0] := U;
      NativeArr[1] := U;
      NativeArr[2] := U;
      NativeArr[3] := U;
    {$endif}

    // 240..247 (8)
    Inc(NativeUInt(NativeArr), 16);
    {$ifdef LARGEINT}
      NativeArr[0] := $0404040404040404;
    {$else}
      NativeArr[0] := $04040404;
      NativeArr[1] := $04040404;
    {$endif}

    // 248..251 (4) --> 5
    // 252..253 (2) --> 6
    // 254..255 (2) --> fail (0)
    {$ifdef LARGEINT}
      NativeArr[1] := $0000060605050505;
    {$else}
      NativeArr[2] := $05050505;
      NativeArr[3] := $00000606;
    {$endif}
  end;
end;


// Byte order mark detection
function DetectBOM(const Data: Pointer; const Size: NativeUInt = 4): TBOM;
var
  Bytes: P4Bytes;
begin
  Result := bomNone;
  if (Data = nil) or (Size < 2) then Exit;

  Bytes := Data;
  case PWord(Bytes)^ of
    $2F2B:
    begin
      if (Size >= 3) and (Bytes[2] = $76) then Result := bomUTF7;
    end;
    $BBEF:
    begin
      if (Size >= 3) and (Bytes[2] = $BF) then Result := bomUTF8;
    end;
    $FEFF:
    begin
      // bomUTF16 or bomUTF32
      Result := bomUTF16;
      if (Size >= 4) and (PWord(@Bytes[2])^ = $0000) then Result := bomUTF32;
    end;
    $FFFE:
    begin
      // bomUTF16BE or bomUCS3412
      Result := bomUTF16BE;
      if (Size >= 4) and (PWord(@Bytes[2])^ = $0000) then Result := bomUCS3412;
    end;
    $0000:
    begin
      // bomUTF32BE or bomUCS2143
      if (Size >= 4) then
      case PWord(@Bytes[2])^ of
        $FFFE: Result := bomUTF32BE;
        $FEFF: Result := bomUCS2143;
      end;
    end;
    $64F7:
    begin
      if (Size >= 3) and (Bytes[2] = $4C) then Result := bomUTF1;
    end;
    $73DD:
    begin
      if (Size >= 4) and (PWord(@Bytes[2])^ = $7366) then Result := bomUTFEBCDIC;
    end;
    $FE0E:
    begin
      if (Size >= 3) and (Bytes[2] = $FF) then Result := bomSCSU;
    end;
    $EEFB:
    begin
      if (Size >= 3) and (Bytes[2] = $28) then Result := bomBOCU1;
    end;
    $3184:
    begin
      if (Size >= 4) and (PWord(@Bytes[2])^ = $3395) then Result := bomGB18030;
    end;
  end;
end;

// detect single-byte encoding
function TextConvIsSBCS(const CodePage: Word): Boolean;
var
  Index: NativeUInt;
  Value: Integer;
begin
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);

  Result := (Word(Value) = CodePage);
end;

// get single-byte encoding lookup
// TEXTCONV_SUPPORTED_SBCS[0] if not found of raw data (CP $ffff)
function TextConvSBCS(const CodePage: Word): PTextConvSBCS;
var
  Index: NativeUInt;
  Value: Integer;
begin
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);

  {$T-} // internal compiler (like Delphi 2007) bug fix
  Result := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
  {$T+}
end;

// get single-byte encoding lookup index
// 0 if not found of raw data (CP $ffff)
function TextConvSBCSIndex(const CodePage: Word): NativeUInt;
var
  Index: NativeUInt;
  Value: Integer;
begin
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);

  Result := Byte(Value shr 16);
end;

{$ifdef undef}{$REGION 'TTextConvSBCS routine'}{$endif}
const
  SBCS_UCS2_OFFSETS: array[Low(TEXTCONV_SUPPORTED_SBCS)..High(TEXTCONV_SUPPORTED_SBCS)] of Word = (
                     0,0,123,353,495,584,707,814,965,1111,1365,1496,1682,1854,1960,2111,
                     2134,2287,2332,2458,2693,2862,2944,2967,3082,3316,3583,3917,0);

  SBCS_UCS2: array[0..4101-1] of Byte = (
  $27,$00,$AC,$20,$01,$3F,$00,$02,$3F,$00,$03,$3F,$00,$04,$3F,$00,$05,$26,$20,$06,
  $3F,$00,$07,$3F,$00,$08,$3F,$00,$09,$3F,$00,$0A,$3F,$00,$0B,$3F,$00,$0C,$3F,$00,
  $0D,$3F,$00,$0E,$3F,$00,$0F,$3F,$00,$10,$3F,$00,$91,$18,$20,$02,$93,$1C,$20,$02,
  $15,$22,$20,$96,$13,$20,$02,$18,$3F,$00,$19,$3F,$00,$1A,$3F,$00,$1B,$3F,$00,$1C,
  $3F,$00,$1D,$3F,$00,$1E,$3F,$00,$1F,$3F,$00,$A1,$01,$0E,$3A,$5B,$3F,$00,$5C,$3F,
  $00,$5D,$3F,$00,$5E,$3F,$00,$DF,$3F,$0E,$1D,$7C,$3F,$00,$7D,$3F,$00,$7E,$3F,$00,
  $7F,$3F,$00,$4B,$00,$AC,$20,$01,$3F,$00,$02,$1A,$20,$03,$3F,$00,$04,$1E,$20,$05,
  $26,$20,$86,$20,$20,$02,$08,$3F,$00,$09,$30,$20,$0A,$60,$01,$0B,$39,$20,$0C,$5A,
  $01,$0D,$64,$01,$0E,$7D,$01,$0F,$79,$01,$10,$3F,$00,$91,$18,$20,$02,$93,$1C,$20,
  $02,$15,$22,$20,$96,$13,$20,$02,$18,$3F,$00,$19,$22,$21,$1A,$61,$01,$1B,$3A,$20,
  $1C,$5B,$01,$1D,$65,$01,$1E,$7E,$01,$1F,$7A,$01,$21,$C7,$02,$22,$D8,$02,$23,$41,
  $01,$25,$04,$01,$2A,$5E,$01,$2F,$7B,$01,$32,$DB,$02,$33,$42,$01,$39,$05,$01,$3A,
  $5F,$01,$3C,$3D,$01,$3D,$DD,$02,$3E,$3E,$01,$3F,$7C,$01,$40,$54,$01,$43,$02,$01,
  $45,$39,$01,$46,$06,$01,$48,$0C,$01,$4A,$18,$01,$4C,$1A,$01,$4F,$0E,$01,$50,$10,
  $01,$51,$43,$01,$52,$47,$01,$55,$50,$01,$58,$58,$01,$59,$6E,$01,$5B,$70,$01,$5E,
  $62,$01,$60,$55,$01,$63,$03,$01,$65,$3A,$01,$66,$07,$01,$68,$0D,$01,$6A,$19,$01,
  $6C,$1B,$01,$6F,$0F,$01,$70,$11,$01,$71,$44,$01,$72,$48,$01,$75,$51,$01,$78,$59,
  $01,$79,$6F,$01,$7B,$71,$01,$7E,$63,$01,$7F,$D9,$02,$2D,$80,$02,$04,$02,$02,$1A,
  $20,$03,$53,$04,$04,$1E,$20,$05,$26,$20,$86,$20,$20,$02,$08,$AC,$20,$09,$30,$20,
  $0A,$09,$04,$0B,$39,$20,$0C,$0A,$04,$0D,$0C,$04,$0E,$0B,$04,$0F,$0F,$04,$10,$52,
  $04,$91,$18,$20,$02,$93,$1C,$20,$02,$15,$22,$20,$96,$13,$20,$02,$18,$3F,$00,$19,
  $22,$21,$1A,$59,$04,$1B,$3A,$20,$1C,$5A,$04,$1D,$5C,$04,$1E,$5B,$04,$1F,$5F,$04,
  $21,$0E,$04,$22,$5E,$04,$23,$08,$04,$25,$90,$04,$28,$01,$04,$2A,$04,$04,$2F,$07,
  $04,$32,$06,$04,$33,$56,$04,$34,$91,$04,$38,$51,$04,$39,$16,$21,$3A,$54,$04,$3C,
  $58,$04,$3D,$05,$04,$3E,$55,$04,$3F,$57,$04,$C0,$10,$04,$40,$1C,$00,$AC,$20,$01,
  $3F,$00,$02,$1A,$20,$03,$92,$01,$04,$1E,$20,$05,$26,$20,$86,$20,$20,$02,$08,$C6,
  $02,$09,$30,$20,$0A,$60,$01,$0B,$39,$20,$0C,$52,$01,$0D,$3F,$00,$0E,$7D,$01,$0F,
  $3F,$00,$10,$3F,$00,$91,$18,$20,$02,$93,$1C,$20,$02,$15,$22,$20,$96,$13,$20,$02,
  $18,$DC,$02,$19,$22,$21,$1A,$61,$01,$1B,$3A,$20,$1C,$53,$01,$1D,$3F,$00,$1E,$7E,
  $01,$1F,$78,$01,$26,$00,$AC,$20,$01,$3F,$00,$02,$1A,$20,$03,$92,$01,$04,$1E,$20,
  $05,$26,$20,$86,$20,$20,$02,$08,$3F,$00,$09,$30,$20,$0A,$3F,$00,$0B,$39,$20,$0C,
  $3F,$00,$0D,$3F,$00,$0E,$3F,$00,$0F,$3F,$00,$10,$3F,$00,$91,$18,$20,$02,$93,$1C,
  $20,$02,$15,$22,$20,$96,$13,$20,$02,$18,$3F,$00,$19,$22,$21,$1A,$3F,$00,$1B,$3A,
  $20,$1C,$3F,$00,$1D,$3F,$00,$1E,$3F,$00,$1F,$3F,$00,$A1,$85,$03,$02,$2A,$3F,$00,
  $2F,$15,$20,$34,$84,$03,$B8,$88,$03,$03,$3C,$8C,$03,$BE,$8E,$03,$14,$52,$3F,$00,
  $D3,$A3,$03,$2C,$7F,$3F,$00,$22,$00,$AC,$20,$01,$3F,$00,$02,$1A,$20,$03,$92,$01,
  $04,$1E,$20,$05,$26,$20,$86,$20,$20,$02,$08,$C6,$02,$09,$30,$20,$0A,$60,$01,$0B,
  $39,$20,$0C,$52,$01,$0D,$3F,$00,$0E,$3F,$00,$0F,$3F,$00,$10,$3F,$00,$91,$18,$20,
  $02,$93,$1C,$20,$02,$15,$22,$20,$96,$13,$20,$02,$18,$DC,$02,$19,$22,$21,$1A,$61,
  $01,$1B,$3A,$20,$1C,$53,$01,$1D,$3F,$00,$1E,$3F,$00,$1F,$78,$01,$50,$1E,$01,$5D,
  $30,$01,$5E,$5E,$01,$70,$1F,$01,$7D,$31,$01,$7E,$5F,$01,$2F,$00,$AC,$20,$01,$3F,
  $00,$02,$1A,$20,$03,$92,$01,$04,$1E,$20,$05,$26,$20,$86,$20,$20,$02,$08,$C6,$02,
  $09,$30,$20,$0A,$3F,$00,$0B,$39,$20,$0C,$3F,$00,$0D,$3F,$00,$0E,$3F,$00,$0F,$3F,
  $00,$10,$3F,$00,$91,$18,$20,$02,$93,$1C,$20,$02,$15,$22,$20,$96,$13,$20,$02,$18,
  $DC,$02,$19,$22,$21,$1A,$3F,$00,$1B,$3A,$20,$1C,$3F,$00,$1D,$3F,$00,$1E,$3F,$00,
  $1F,$3F,$00,$24,$AA,$20,$2A,$D7,$00,$3A,$F7,$00,$C0,$B0,$05,$0A,$4A,$3F,$00,$CB,
  $BB,$05,$09,$D4,$F0,$05,$05,$59,$3F,$00,$5A,$3F,$00,$5B,$3F,$00,$5C,$3F,$00,$5D,
  $3F,$00,$5E,$3F,$00,$5F,$3F,$00,$E0,$D0,$05,$1B,$7B,$3F,$00,$7C,$3F,$00,$FD,$0E,
  $20,$02,$7F,$3F,$00,$2C,$00,$AC,$20,$01,$7E,$06,$02,$1A,$20,$03,$92,$01,$04,$1E,
  $20,$05,$26,$20,$86,$20,$20,$02,$08,$C6,$02,$09,$30,$20,$0A,$79,$06,$0B,$39,$20,
  $0C,$52,$01,$0D,$86,$06,$0E,$98,$06,$0F,$88,$06,$10,$AF,$06,$91,$18,$20,$02,$93,
  $1C,$20,$02,$15,$22,$20,$96,$13,$20,$02,$18,$A9,$06,$19,$22,$21,$1A,$91,$06,$1B,
  $3A,$20,$1C,$53,$01,$9D,$0C,$20,$02,$1F,$BA,$06,$21,$0C,$06,$2A,$BE,$06,$3A,$1B,
  $06,$3F,$1F,$06,$40,$C1,$06,$C1,$21,$06,$16,$D8,$37,$06,$04,$DC,$40,$06,$04,$61,
  $44,$06,$E3,$45,$06,$04,$EC,$49,$06,$02,$F0,$4B,$06,$04,$F5,$4F,$06,$02,$78,$51,
  $06,$7A,$52,$06,$FD,$0E,$20,$02,$7F,$D2,$06,$53,$00,$AC,$20,$01,$3F,$00,$02,$1A,
  $20,$03,$3F,$00,$04,$1E,$20,$05,$26,$20,$86,$20,$20,$02,$08,$3F,$00,$09,$30,$20,
  $0A,$3F,$00,$0B,$39,$20,$0C,$3F,$00,$0D,$A8,$00,$0E,$C7,$02,$0F,$B8,$00,$10,$3F,
  $00,$91,$18,$20,$02,$93,$1C,$20,$02,$15,$22,$20,$96,$13,$20,$02,$18,$3F,$00,$19,
  $22,$21,$1A,$3F,$00,$1B,$3A,$20,$1C,$3F,$00,$1D,$AF,$00,$1E,$DB,$02,$1F,$3F,$00,
  $21,$3F,$00,$25,$3F,$00,$28,$D8,$00,$2A,$56,$01,$2F,$C6,$00,$38,$F8,$00,$3A,$57,
  $01,$3F,$E6,$00,$40,$04,$01,$41,$2E,$01,$42,$00,$01,$43,$06,$01,$46,$18,$01,$47,
  $12,$01,$48,$0C,$01,$4A,$79,$01,$4B,$16,$01,$4C,$22,$01,$4D,$36,$01,$4E,$2A,$01,
  $4F,$3B,$01,$50,$60,$01,$51,$43,$01,$52,$45,$01,$54,$4C,$01,$58,$72,$01,$59,$41,
  $01,$5A,$5A,$01,$5B,$6A,$01,$5D,$7B,$01,$5E,$7D,$01,$60,$05,$01,$61,$2F,$01,$62,
  $01,$01,$63,$07,$01,$66,$19,$01,$67,$13,$01,$68,$0D,$01,$6A,$7A,$01,$6B,$17,$01,
  $6C,$23,$01,$6D,$37,$01,$6E,$2B,$01,$6F,$3C,$01,$70,$61,$01,$71,$44,$01,$72,$46,
  $01,$74,$4D,$01,$78,$73,$01,$79,$42,$01,$7A,$5B,$01,$7B,$6B,$01,$7D,$7C,$01,$7E,
  $7E,$01,$7F,$D9,$02,$2A,$00,$AC,$20,$01,$3F,$00,$02,$1A,$20,$03,$92,$01,$04,$1E,
  $20,$05,$26,$20,$86,$20,$20,$02,$08,$C6,$02,$09,$30,$20,$0A,$3F,$00,$0B,$39,$20,
  $0C,$52,$01,$0D,$3F,$00,$0E,$3F,$00,$0F,$3F,$00,$10,$3F,$00,$91,$18,$20,$02,$93,
  $1C,$20,$02,$15,$22,$20,$96,$13,$20,$02,$18,$DC,$02,$19,$22,$21,$1A,$3F,$00,$1B,
  $3A,$20,$1C,$53,$01,$1D,$3F,$00,$1E,$3F,$00,$1F,$78,$01,$43,$02,$01,$4C,$00,$03,
  $50,$10,$01,$52,$09,$03,$55,$A0,$01,$5D,$AF,$01,$5E,$03,$03,$63,$03,$01,$6C,$01,
  $03,$70,$11,$01,$72,$23,$03,$75,$A1,$01,$7D,$B0,$01,$7E,$AB,$20,$3B,$80,$10,$04,
  $30,$B0,$91,$25,$03,$33,$02,$25,$34,$24,$25,$B5,$61,$25,$02,$37,$56,$25,$38,$55,
  $25,$39,$63,$25,$3A,$51,$25,$3B,$57,$25,$3C,$5D,$25,$3D,$5C,$25,$3E,$5B,$25,$3F,
  $10,$25,$40,$14,$25,$41,$34,$25,$42,$2C,$25,$43,$1C,$25,$44,$00,$25,$45,$3C,$25,
  $C6,$5E,$25,$02,$48,$5A,$25,$49,$54,$25,$4A,$69,$25,$4B,$66,$25,$4C,$60,$25,$4D,
  $50,$25,$4E,$6C,$25,$CF,$67,$25,$02,$D1,$64,$25,$02,$53,$59,$25,$54,$58,$25,$D5,
  $52,$25,$02,$57,$6B,$25,$58,$6A,$25,$59,$18,$25,$5A,$0C,$25,$5B,$88,$25,$5C,$84,
  $25,$5D,$8C,$25,$5E,$90,$25,$5F,$80,$25,$E0,$40,$04,$10,$70,$01,$04,$71,$51,$04,
  $72,$04,$04,$73,$54,$04,$74,$07,$04,$75,$57,$04,$76,$0E,$04,$77,$5E,$04,$78,$B0,
  $00,$79,$19,$22,$7A,$B7,$00,$7B,$1A,$22,$7C,$16,$21,$7D,$A4,$00,$7E,$A0,$25,$7F,
  $A0,$00,$39,$21,$04,$01,$22,$D8,$02,$23,$41,$01,$25,$3D,$01,$26,$5A,$01,$29,$60,
  $01,$2A,$5E,$01,$2B,$64,$01,$2C,$79,$01,$2E,$7D,$01,$2F,$7B,$01,$31,$05,$01,$32,
  $DB,$02,$33,$42,$01,$35,$3E,$01,$36,$5B,$01,$37,$C7,$02,$39,$61,$01,$3A,$5F,$01,
  $3B,$65,$01,$3C,$7A,$01,$3D,$DD,$02,$3E,$7E,$01,$3F,$7C,$01,$40,$54,$01,$43,$02,
  $01,$45,$39,$01,$46,$06,$01,$48,$0C,$01,$4A,$18,$01,$4C,$1A,$01,$4F,$0E,$01,$50,
  $10,$01,$51,$43,$01,$52,$47,$01,$55,$50,$01,$58,$58,$01,$59,$6E,$01,$5B,$70,$01,
  $5E,$62,$01,$60,$55,$01,$63,$03,$01,$65,$3A,$01,$66,$07,$01,$68,$0D,$01,$6A,$19,
  $01,$6C,$1B,$01,$6F,$0F,$01,$70,$11,$01,$71,$44,$01,$72,$48,$01,$75,$51,$01,$78,
  $59,$01,$79,$6F,$01,$7B,$71,$01,$7E,$63,$01,$7F,$D9,$02,$23,$21,$26,$01,$22,$D8,
  $02,$25,$3F,$00,$26,$24,$01,$29,$30,$01,$2A,$5E,$01,$2B,$1E,$01,$2C,$34,$01,$2E,
  $3F,$00,$2F,$7B,$01,$31,$27,$01,$36,$25,$01,$39,$31,$01,$3A,$5F,$01,$3B,$1F,$01,
  $3C,$35,$01,$3E,$3F,$00,$3F,$7C,$01,$43,$3F,$00,$45,$0A,$01,$46,$08,$01,$50,$3F,
  $00,$55,$20,$01,$58,$1C,$01,$5D,$6C,$01,$5E,$5C,$01,$63,$3F,$00,$65,$0B,$01,$66,
  $09,$01,$70,$3F,$00,$75,$21,$01,$78,$1D,$01,$7D,$6D,$01,$7E,$5D,$01,$7F,$D9,$02,
  $32,$21,$04,$01,$22,$38,$01,$23,$56,$01,$25,$28,$01,$26,$3B,$01,$29,$60,$01,$2A,
  $12,$01,$2B,$22,$01,$2C,$66,$01,$2E,$7D,$01,$31,$05,$01,$32,$DB,$02,$33,$57,$01,
  $35,$29,$01,$36,$3C,$01,$37,$C7,$02,$39,$61,$01,$3A,$13,$01,$3B,$23,$01,$3C,$67,
  $01,$3D,$4A,$01,$3E,$7E,$01,$3F,$4B,$01,$40,$00,$01,$47,$2E,$01,$48,$0C,$01,$4A,
  $18,$01,$4C,$16,$01,$4F,$2A,$01,$50,$10,$01,$51,$45,$01,$52,$4C,$01,$53,$36,$01,
  $59,$72,$01,$5D,$68,$01,$5E,$6A,$01,$60,$01,$01,$67,$2F,$01,$68,$0D,$01,$6A,$19,
  $01,$6C,$17,$01,$6F,$2B,$01,$70,$11,$01,$71,$46,$01,$72,$4D,$01,$73,$37,$01,$79,
  $73,$01,$7D,$69,$01,$7E,$6B,$01,$7F,$D9,$02,$06,$A1,$01,$04,$0C,$AE,$0E,$04,$42,
  $70,$16,$21,$F1,$51,$04,$0C,$7D,$A7,$00,$FE,$5E,$04,$02,$32,$21,$3F,$00,$22,$3F,
  $00,$23,$3F,$00,$25,$3F,$00,$26,$3F,$00,$27,$3F,$00,$28,$3F,$00,$29,$3F,$00,$2A,
  $3F,$00,$2B,$3F,$00,$2C,$0C,$06,$2E,$3F,$00,$2F,$3F,$00,$30,$3F,$00,$31,$3F,$00,
  $32,$3F,$00,$33,$3F,$00,$34,$3F,$00,$35,$3F,$00,$36,$3F,$00,$37,$3F,$00,$38,$3F,
  $00,$39,$3F,$00,$3A,$3F,$00,$3B,$1B,$06,$3C,$3F,$00,$3D,$3F,$00,$3E,$3F,$00,$3F,
  $1F,$06,$40,$3F,$00,$C1,$21,$06,$1A,$5B,$3F,$00,$5C,$3F,$00,$5D,$3F,$00,$5E,$3F,
  $00,$5F,$3F,$00,$E0,$40,$06,$13,$73,$3F,$00,$74,$3F,$00,$75,$3F,$00,$76,$3F,$00,
  $77,$3F,$00,$78,$3F,$00,$79,$3F,$00,$7A,$3F,$00,$7B,$3F,$00,$7C,$3F,$00,$7D,$3F,
  $00,$7E,$3F,$00,$7F,$3F,$00,$0D,$A1,$18,$20,$02,$24,$AC,$20,$25,$AF,$20,$2A,$7A,
  $03,$2E,$3F,$00,$2F,$15,$20,$B4,$84,$03,$03,$B8,$88,$03,$03,$3C,$8C,$03,$BE,$8E,
  $03,$14,$52,$3F,$00,$D3,$A3,$03,$2C,$7F,$3F,$00,$29,$21,$3F,$00,$2A,$D7,$00,$3A,
  $F7,$00,$3F,$3F,$00,$40,$3F,$00,$41,$3F,$00,$42,$3F,$00,$43,$3F,$00,$44,$3F,$00,
  $45,$3F,$00,$46,$3F,$00,$47,$3F,$00,$48,$3F,$00,$49,$3F,$00,$4A,$3F,$00,$4B,$3F,
  $00,$4C,$3F,$00,$4D,$3F,$00,$4E,$3F,$00,$4F,$3F,$00,$50,$3F,$00,$51,$3F,$00,$52,
  $3F,$00,$53,$3F,$00,$54,$3F,$00,$55,$3F,$00,$56,$3F,$00,$57,$3F,$00,$58,$3F,$00,
  $59,$3F,$00,$5A,$3F,$00,$5B,$3F,$00,$5C,$3F,$00,$5D,$3F,$00,$5E,$3F,$00,$5F,$17,
  $20,$E0,$D0,$05,$1B,$7B,$3F,$00,$7C,$3F,$00,$FD,$0E,$20,$02,$7F,$3F,$00,$4E,$00,
  $3F,$00,$01,$3F,$00,$02,$3F,$00,$03,$3F,$00,$04,$3F,$00,$05,$3F,$00,$06,$3F,$00,
  $07,$3F,$00,$08,$3F,$00,$09,$3F,$00,$0A,$3F,$00,$0B,$3F,$00,$0C,$3F,$00,$0D,$3F,
  $00,$0E,$3F,$00,$0F,$3F,$00,$10,$3F,$00,$11,$3F,$00,$12,$3F,$00,$13,$3F,$00,$14,
  $3F,$00,$15,$3F,$00,$16,$3F,$00,$17,$3F,$00,$18,$3F,$00,$19,$3F,$00,$1A,$3F,$00,
  $1B,$3F,$00,$1C,$3F,$00,$1D,$3F,$00,$1E,$3F,$00,$1F,$3F,$00,$21,$04,$01,$22,$12,
  $01,$23,$22,$01,$24,$2A,$01,$25,$28,$01,$26,$36,$01,$28,$3B,$01,$29,$10,$01,$2A,
  $60,$01,$2B,$66,$01,$2C,$7D,$01,$2E,$6A,$01,$2F,$4A,$01,$31,$05,$01,$32,$13,$01,
  $33,$23,$01,$34,$2B,$01,$35,$29,$01,$36,$37,$01,$38,$3C,$01,$39,$11,$01,$3A,$61,
  $01,$3B,$67,$01,$3C,$7E,$01,$3D,$15,$20,$3E,$6B,$01,$3F,$4B,$01,$40,$00,$01,$47,
  $2E,$01,$48,$0C,$01,$4A,$18,$01,$4C,$16,$01,$51,$45,$01,$52,$4C,$01,$57,$68,$01,
  $59,$72,$01,$60,$01,$01,$67,$2F,$01,$68,$0D,$01,$6A,$19,$01,$6C,$17,$01,$71,$46,
  $01,$72,$4D,$01,$77,$69,$01,$79,$73,$01,$7F,$38,$01,$38,$21,$1D,$20,$25,$1E,$20,
  $28,$D8,$00,$2A,$56,$01,$2F,$C6,$00,$34,$1C,$20,$38,$F8,$00,$3A,$57,$01,$3F,$E6,
  $00,$40,$04,$01,$41,$2E,$01,$42,$00,$01,$43,$06,$01,$46,$18,$01,$47,$12,$01,$48,
  $0C,$01,$4A,$79,$01,$4B,$16,$01,$4C,$22,$01,$4D,$36,$01,$4E,$2A,$01,$4F,$3B,$01,
  $50,$60,$01,$51,$43,$01,$52,$45,$01,$54,$4C,$01,$58,$72,$01,$59,$41,$01,$5A,$5A,
  $01,$5B,$6A,$01,$5D,$7B,$01,$5E,$7D,$01,$60,$05,$01,$61,$2F,$01,$62,$01,$01,$63,
  $07,$01,$66,$19,$01,$67,$13,$01,$68,$0D,$01,$6A,$7A,$01,$6B,$17,$01,$6C,$23,$01,
  $6D,$37,$01,$6E,$2B,$01,$6F,$3C,$01,$70,$61,$01,$71,$44,$01,$72,$46,$01,$74,$4D,
  $01,$78,$73,$01,$79,$42,$01,$7A,$5B,$01,$7B,$6B,$01,$7D,$7C,$01,$7E,$7E,$01,$7F,
  $19,$20,$19,$A1,$02,$1E,$02,$A4,$0A,$01,$02,$26,$0A,$1E,$28,$80,$1E,$2A,$82,$1E,
  $2B,$0B,$1E,$2C,$F2,$1E,$2F,$78,$01,$B0,$1E,$1E,$02,$B2,$20,$01,$02,$B4,$40,$1E,
  $02,$37,$56,$1E,$38,$81,$1E,$39,$57,$1E,$3A,$83,$1E,$3B,$60,$1E,$3C,$F3,$1E,$BD,
  $84,$1E,$02,$3F,$61,$1E,$50,$74,$01,$57,$6A,$1E,$5E,$76,$01,$70,$75,$01,$77,$6B,
  $1E,$7E,$77,$01,$07,$24,$AC,$20,$26,$60,$01,$28,$61,$01,$34,$7D,$01,$38,$7E,$01,
  $BC,$52,$01,$02,$3E,$78,$01,$25,$A1,$04,$01,$02,$23,$41,$01,$24,$AC,$20,$25,$1E,
  $20,$26,$60,$01,$28,$61,$01,$2A,$18,$02,$2C,$79,$01,$AE,$7A,$01,$02,$32,$0C,$01,
  $33,$42,$01,$34,$7D,$01,$35,$1D,$20,$38,$7E,$01,$39,$0D,$01,$3A,$19,$02,$BC,$52,
  $01,$02,$3E,$78,$01,$3F,$7C,$01,$43,$02,$01,$45,$06,$01,$50,$10,$01,$51,$43,$01,
  $55,$50,$01,$57,$5A,$01,$58,$70,$01,$5D,$18,$01,$5E,$1A,$02,$63,$03,$01,$65,$07,
  $01,$70,$11,$01,$71,$44,$01,$75,$51,$01,$77,$5B,$01,$78,$71,$01,$7D,$19,$01,$7E,
  $1B,$02,$49,$00,$00,$25,$01,$02,$25,$02,$0C,$25,$03,$10,$25,$04,$14,$25,$05,$18,
  $25,$06,$1C,$25,$07,$24,$25,$08,$2C,$25,$09,$34,$25,$0A,$3C,$25,$0B,$80,$25,$0C,
  $84,$25,$0D,$88,$25,$0E,$8C,$25,$8F,$90,$25,$04,$13,$20,$23,$14,$A0,$25,$95,$19,
  $22,$02,$17,$48,$22,$98,$64,$22,$02,$1A,$A0,$00,$1B,$21,$23,$1C,$B0,$00,$1D,$B2,
  $00,$1E,$B7,$00,$1F,$F7,$00,$A0,$50,$25,$03,$23,$51,$04,$A4,$53,$25,$0F,$33,$01,
  $04,$B4,$62,$25,$0B,$3F,$A9,$00,$40,$4E,$04,$C1,$30,$04,$02,$43,$46,$04,$C4,$34,
  $04,$02,$46,$44,$04,$47,$33,$04,$48,$45,$04,$C9,$38,$04,$08,$51,$4F,$04,$D2,$40,
  $04,$04,$56,$36,$04,$57,$32,$04,$58,$4C,$04,$59,$4B,$04,$5A,$37,$04,$5B,$48,$04,
  $5C,$4D,$04,$5D,$49,$04,$5E,$47,$04,$5F,$4A,$04,$60,$2E,$04,$E1,$10,$04,$02,$63,
  $26,$04,$E4,$14,$04,$02,$66,$24,$04,$67,$13,$04,$68,$25,$04,$E9,$18,$04,$08,$71,
  $2F,$04,$F2,$20,$04,$04,$76,$16,$04,$77,$12,$04,$78,$2C,$04,$79,$2B,$04,$7A,$17,
  $04,$7B,$28,$04,$7C,$2D,$04,$7D,$29,$04,$7E,$27,$04,$7F,$2A,$04,$53,$00,$00,$25,
  $01,$02,$25,$02,$0C,$25,$03,$10,$25,$04,$14,$25,$05,$18,$25,$06,$1C,$25,$07,$24,
  $25,$08,$2C,$25,$09,$34,$25,$0A,$3C,$25,$0B,$80,$25,$0C,$84,$25,$0D,$88,$25,$0E,
  $8C,$25,$8F,$90,$25,$04,$13,$20,$23,$14,$A0,$25,$95,$19,$22,$02,$17,$48,$22,$98,
  $64,$22,$02,$1A,$A0,$00,$1B,$21,$23,$1C,$B0,$00,$1D,$B2,$00,$1E,$B7,$00,$1F,$F7,
  $00,$A0,$50,$25,$03,$23,$51,$04,$24,$54,$04,$25,$54,$25,$A6,$56,$04,$02,$A8,$57,
  $25,$05,$2D,$91,$04,$AE,$5D,$25,$05,$33,$01,$04,$34,$04,$04,$35,$63,$25,$B6,$06,
  $04,$02,$B8,$66,$25,$05,$3D,$90,$04,$3E,$6C,$25,$3F,$A9,$00,$40,$4E,$04,$C1,$30,
  $04,$02,$43,$46,$04,$C4,$34,$04,$02,$46,$44,$04,$47,$33,$04,$48,$45,$04,$C9,$38,
  $04,$08,$51,$4F,$04,$D2,$40,$04,$04,$56,$36,$04,$57,$32,$04,$58,$4C,$04,$59,$4B,
  $04,$5A,$37,$04,$5B,$48,$04,$5C,$4D,$04,$5D,$49,$04,$5E,$47,$04,$5F,$4A,$04,$60,
  $2E,$04,$E1,$10,$04,$02,$63,$26,$04,$E4,$14,$04,$02,$66,$24,$04,$67,$13,$04,$68,
  $25,$04,$E9,$18,$04,$08,$71,$2F,$04,$F2,$20,$04,$04,$76,$16,$04,$77,$12,$04,$78,
  $2C,$04,$79,$2B,$04,$7A,$17,$04,$7B,$28,$04,$7C,$2D,$04,$7D,$29,$04,$7E,$27,$04,
  $7F,$2A,$04,$6A,$80,$C4,$00,$02,$02,$C7,$00,$03,$C9,$00,$04,$D1,$00,$05,$D6,$00,
  $06,$DC,$00,$07,$E1,$00,$08,$E0,$00,$09,$E2,$00,$0A,$E4,$00,$0B,$E3,$00,$0C,$E5,
  $00,$0D,$E7,$00,$0E,$E9,$00,$0F,$E8,$00,$90,$EA,$00,$02,$12,$ED,$00,$13,$EC,$00,
  $94,$EE,$00,$02,$16,$F1,$00,$17,$F3,$00,$18,$F2,$00,$19,$F4,$00,$1A,$F6,$00,$1B,
  $F5,$00,$1C,$FA,$00,$1D,$F9,$00,$9E,$FB,$00,$02,$20,$20,$20,$21,$B0,$00,$24,$A7,
  $00,$25,$22,$20,$26,$B6,$00,$27,$DF,$00,$28,$AE,$00,$2A,$22,$21,$2B,$B4,$00,$2C,
  $A8,$00,$2D,$60,$22,$2E,$C6,$00,$2F,$D8,$00,$30,$1E,$22,$B2,$64,$22,$02,$34,$A5,
  $00,$36,$02,$22,$37,$11,$22,$38,$0F,$22,$39,$C0,$03,$3A,$2B,$22,$3B,$AA,$00,$3C,
  $BA,$00,$3D,$A9,$03,$3E,$E6,$00,$3F,$F8,$00,$40,$BF,$00,$41,$A1,$00,$42,$AC,$00,
  $43,$1A,$22,$44,$92,$01,$45,$48,$22,$46,$06,$22,$47,$AB,$00,$48,$BB,$00,$49,$26,
  $20,$4A,$A0,$00,$4B,$C0,$00,$4C,$C3,$00,$4D,$D5,$00,$CE,$52,$01,$02,$D0,$13,$20,
  $02,$D2,$1C,$20,$02,$D4,$18,$20,$02,$56,$F7,$00,$57,$CA,$25,$58,$FF,$00,$59,$78,
  $01,$5A,$44,$20,$5B,$AC,$20,$DC,$39,$20,$02,$DE,$01,$FB,$02,$60,$21,$20,$61,$B7,
  $00,$62,$1A,$20,$63,$1E,$20,$64,$30,$20,$65,$C2,$00,$66,$CA,$00,$67,$C1,$00,$68,
  $CB,$00,$69,$C8,$00,$EA,$CD,$00,$03,$6D,$CC,$00,$EE,$D3,$00,$02,$70,$FF,$F8,$71,
  $D2,$00,$F2,$DA,$00,$02,$74,$D9,$00,$75,$31,$01,$76,$C6,$02,$77,$DC,$02,$78,$AF,
  $00,$F9,$D8,$02,$03,$7C,$B8,$00,$7D,$DD,$02,$7E,$DB,$02,$7F,$C7,$02,$3B,$80,$10,
  $04,$20,$20,$20,$20,$21,$B0,$00,$22,$90,$04,$24,$A7,$00,$25,$22,$20,$26,$B6,$00,
  $27,$06,$04,$28,$AE,$00,$2A,$22,$21,$2B,$02,$04,$2C,$52,$04,$2D,$60,$22,$2E,$03,
  $04,$2F,$53,$04,$30,$1E,$22,$B2,$64,$22,$02,$34,$56,$04,$36,$91,$04,$37,$08,$04,
  $38,$04,$04,$39,$54,$04,$3A,$07,$04,$3B,$57,$04,$3C,$09,$04,$3D,$59,$04,$3E,$0A,
  $04,$3F,$5A,$04,$40,$58,$04,$41,$05,$04,$42,$AC,$00,$43,$1A,$22,$44,$92,$01,$45,
  $48,$22,$46,$06,$22,$47,$AB,$00,$48,$BB,$00,$49,$26,$20,$4A,$A0,$00,$4B,$0B,$04,
  $4C,$5B,$04,$4D,$0C,$04,$4E,$5C,$04,$4F,$55,$04,$D0,$13,$20,$02,$D2,$1C,$20,$02,
  $D4,$18,$20,$02,$56,$F7,$00,$57,$1E,$20,$58,$0E,$04,$59,$5E,$04,$5A,$0F,$04,$5B,
  $5F,$04,$5C,$16,$21,$5D,$01,$04,$5E,$51,$04,$5F,$4F,$04,$E0,$30,$04,$1F,$7F,$AC,
  $20);

{ TTextConvSBCS }

procedure TTextConvSBCS.FillUCS2(var Buffer: TTextConvWB; const CharCase: TCharCase);
var
  P: PByte;
  Base, Count, Value: NativeUInt;
  Destination: PWord;
  PackedChars: PByte;
  CharCaseLookup: PTextConvWW;
  TempBuffer: PTextConvMB;
begin
  // store packed chars pointer or raw/userdefined
  if (Self.CodePage >= CODEPAGE_USERDEFINED) then
  begin
    PackedChars := Pointer(Byte(@Self <> @TEXTCONV_SUPPORTED_SBCS[0]));
  end else
  begin
    PackedChars := @SBCS_UCS2[SBCS_UCS2_OFFSETS[Self.Index]];
  end;

  // fill by default characters
  Base := $00010000;
  for Count := 0 to 127{255} do
  begin
    {$ifdef CPUX86}
    PCardinal(@Buffer[Count * 2])^ := Base;
    {$else}
    PTextConvMB(@Buffer)^[Count] := Base;
    {$endif}
    Inc(Base, $00020002);
  end;

  // case sensitive options
  case CharCase of
    ccUpper:
    begin
      // a..z --> A..Z
      Base := $00420041;
      TempBuffer := Pointer(@Buffer[$61]);
      for Count := 0 to (26 div 2) - 1 do
      begin
        TempBuffer^[Count] := Base;
        Inc(Base, $00020002);
      end;

      CharCaseLookup := Pointer(@TEXTCONV_CHARCASE.UPPER);
    end;
    ccLower:
    begin
      // A..Z --> a..z
      Base := $00620061;
      TempBuffer := Pointer(@Buffer[$41]);
      for Count := 0 to (26 div 2) - 1 do
      begin
        TempBuffer^[Count] := Base;
        Inc(Base, $00020002);
      end;

      CharCaseLookup := Pointer(@TEXTCONV_CHARCASE.LOWER);
    end;
  else
    CharCaseLookup := nil;
  end;

  // raw data(0) or user defined(1)
  P := PackedChars;
  if (NativeUInt(P) <= 1) then
  begin
    if (NativeUInt(P) = 1) then
      CharCaseLookup := Pointer(@TEXTCONV_CHARCASE.VALUES{LOWER}[$F700]);

    if (CharCaseLookup <> nil) then
    for Count := 128 to 255 do
    begin
      Buffer[Count] := CharCaseLookup[Count];
    end;

    Exit;
  end;

  // unpack encoding characters
  Count := Cardinal(P^) shl 8;
  Inc(P);
  repeat
    Base := P^;
    Inc(P);
    Dec(Count, $0100);

    if (Base < 128) then
    begin
      Inc(Base, 128);
      if (CharCaseLookup = nil) then Buffer[Base] := PWord(P)^
      else Buffer[Base] := CharCaseLookup[PWord(P)^];
      Inc(P, 2);
    end else
    begin
      Value := PWord(P)^;
      Inc(P, 2);
      Count := Count or Cardinal(P^);
      Inc(P);
      Destination := @Buffer[Base];

      if (Value <> Ord('?')) then
      begin
        if (CharCaseLookup = nil) then
        begin
          repeat
            Destination^ := Value;
            Dec(Count);
            Inc(Destination);
            Inc(Value);
          until (Count and $ff = 0);
        end else
        begin
          repeat
            Destination^ := CharCaseLookup[Value];
            Dec(Count);
            Inc(Destination);
            Inc(Value);
          until (Count and $ff = 0);
        end;
      end else
      begin
        repeat
          Destination^ := Value{?};
          Dec(Count);
          Inc(Destination);
        until (Count and $ff = 0);
      end;
    end;
  until (Count = 0)
end;

function TTextConvSBCS.AllocFillUCS2(var Buffer: PTextConvUS; const CharCase: TCharCase): PTextConvUS;
begin
  Result := Buffer;
  if (Result = nil) then
  begin
    Result := InternalLookupAlloc(SizeOf(TTextConvUS));
    FillUCS2(PTextConvWB(Result)^, CharCase);
    Result := InternalLookupFill(Pointer(Buffer), Result);
  end;
end;

procedure TTextConvSBCS.FillUTF8(var Buffer: TTextConvMB; const CharCase: TCharCase);
var
  UCS2Chars: PTextConvWB;
  CharCaseLookup: PTextConvWW;
  i, X, Y: NativeUInt;
  P: PCardinal;
 begin
  UCS2Chars := Pointer(Self.FUCS2.Original);
  if (UCS2Chars = nil) then UCS2Chars := Pointer(Self.AllocFillUCS2(Self.FUCS2.Original, ccOriginal)); // Alloc and Fill

  // fill first 128 characters
  P := Pointer(@Buffer);
  X := $01000000;
  for i := 0 to 127 do
  begin
    P^ := X;
    Inc(P);
    Inc(X);
  end;

  // case sensitive options
  case CharCase of
    ccUpper:
    begin
      CharCaseLookup := Pointer(@TEXTCONV_CHARCASE.UPPER);
      P := Pointer(@Buffer[$61{Ord('a')}]);
      X := $01000041;
    end;
    ccLower:
    begin
      CharCaseLookup := Pointer(@TEXTCONV_CHARCASE.LOWER);
      P := Pointer(@Buffer[$41{Ord('A')}]);
      X := $01000061;
    end;
  else
    CharCaseLookup := nil;
    P := nil{warnings off};
  end;
  if (CharCaseLookup <> nil) then
  for i := 0 to 26 - 1 do
  begin
    P^ := X;
    Inc(P);
    Inc(X);
  end;

  // fill last 128 characters
  P := @Buffer[128];
  for i := 128 to 255 do
  begin
    X := UCS2Chars[i];
    if (CharCaseLookup <> nil) then X := CharCaseLookup[X];

    if (X <= $7ff) then
    begin
      if (X > $7f) then
      begin
        Y := (X and $3f) shl 8;
        X := (X shr 6) + $020080c0;
        Inc(X, Y);
      end else
      begin
        X := X + $01000000;
      end;
    end else
    begin
      Y := ((X and $3f) shl 16) + ((X and ($3f shl 6)) shl (8-6));
      X := (X shr 12) + $038080E0;
      Inc(X, Y);
    end;

    P^ := X;
    Inc(P);
  end;
end;

function TTextConvSBCS.AllocFillUTF8(var Buffer: PTextConvMS; const CharCase: TCharCase): PTextConvMS;
begin
  Result := Buffer;
  if (Result = nil) then
  begin
    Result := InternalLookupAlloc(SizeOf(TTextConvMS));
    FillUTF8(PTextConvMB(Result)^, CharCase);
    Result := InternalLookupFill(Pointer(Buffer), Result);
  end;
end;

procedure FillBytesArrayDefault(Bytes: Pointer; Size: NativeInt);
label
  fill_default;
{$ifdef LARGEINT}
var
  UCS2_INCREMENT: NativeUInt; // $0808080808080808
{$else}
const
  UCS2_INCREMENT = $04040404;
{$endif}
var
  i: Integer;
  X: NativeUInt;
begin
  {$ifdef LARGEINT}
    X := $0706050403020100;
    UCS2_INCREMENT := $0808080808080808;
  {$else}
    X := $03020100;
  {$endif}
fill_default:
  for i := 0 to (128 div SizeOf(NativeUInt)) - 1 do
  begin
    PNativeUInt(Bytes)^ := X;
    Inc(NativeUInt(Bytes), SizeOf(NativeUInt));
    Inc(X, UCS2_INCREMENT);
  end;

  // routine to fill whole 256 Bytes by default
  if (Size <= 0) then
  begin
    if (Size < 0) then
    begin
      Size := 0;
      goto fill_default;
    end;
    Exit;
  end;

  // FillChar(Bytes+128, Size-128, '?');
  Size := (Size - 128) shr (1 + SizeOf(NativeUInt) div 4);
  {$ifdef LARGEINT}
    X := $3f3f3f3f3f3f3f3f;
  {$else}
    X := $3f3f3f3f;
  {$endif}
  for i := 1 to Size do
  begin
    PNativeUInt(Bytes)^ := X;
    Inc(NativeUInt(Bytes), SizeOf(NativeUInt));
  end;
end;


const
  SBCS_BESTFITS: array[0..1440+1] of Cardinal = (
  $006900A1,$049000A2,$006300A2,$004C00A3,$20AC00A4,$002400A4,$005900A5,$007C00A6,
  $005300A7,$006300A9,$006100AA,$003C00AB,$002D00AC,$002D00AD,$007200AE,$002D00AF,
  $003200B2,$003300B3,$006000B4,$044700B5,$002E00B7,$002C00B8,$003100B9,$006F00BA,
  $003E00BB,$003100BC,$003100BD,$003300BE,$003F00BF,$004100C0,$004100C1,$004100C2,
  $004100C3,$004100C4,$004100C5,$004100C6,$004300C7,$004500C8,$004500C9,$004500CA,
  $004500CB,$004900CC,$004900CD,$004900CE,$004900CF,$004400D0,$004E00D1,$004F00D2,
  $004F00D3,$004F00D4,$004F00D5,$004F00D6,$004F00D8,$005500D9,$005500DA,$005500DB,
  $005500DC,$005900DD,$006100E0,$006100E1,$006100E2,$006100E3,$006100E4,$006100E5,
  $006100E6,$006300E7,$006500E8,$006500E9,$006500EA,$006500EB,$006900EC,$006900ED,
  $006900EE,$006900EF,$006E00F1,$006F00F2,$006F00F3,$006F00F4,$006F00F5,$006F00F6,
  $006F00F8,$007500F9,$007500FA,$007500FB,$007500FC,$007900FD,$007900FF,$00410100,
  $00610101,$00410102,$00610103,$00410104,$00610105,$00430106,$00630107,$00430108,
  $00630109,$0043010A,$0063010B,$0043010C,$0063010D,$0044010E,$0064010F,$00D00110,
  $00440110,$00640111,$00450112,$00650113,$00450114,$00650115,$00450116,$00650117,
  $00450118,$00650119,$0045011A,$0065011B,$0047011C,$0067011D,$0047011E,$0067011F,
  $00470120,$00670121,$00470122,$00670123,$00480124,$00680125,$00480126,$00680127,
  $00490128,$00690129,$0049012A,$0069012B,$0049012C,$0069012D,$0049012E,$0069012F,
  $00490130,$00690131,$004A0134,$006A0135,$004B0136,$006B0137,$006B0138,$004C0139,
  $006C013A,$004C013B,$006C013C,$004C013D,$006C013E,$004C0141,$006C0142,$004E0143,
  $006E0144,$004E0145,$006E0146,$004E0147,$006E0148,$004E014A,$006E014B,$004F014C,
  $006F014D,$004F014E,$006F014F,$004F0150,$006F0151,$004F0152,$006F0153,$00520154,
  $00720155,$00520156,$00720157,$00520158,$00720159,$0053015A,$0073015B,$0053015C,
  $0073015D,$0053015E,$0073015F,$00530160,$00730161,$00540162,$00740163,$00540164,
  $00740165,$00540166,$00740167,$00550168,$00750169,$0055016A,$0075016B,$0055016C,
  $0075016D,$0055016E,$0075016F,$00550170,$00750171,$00550172,$00750173,$00570174,
  $00770175,$00590176,$00790177,$00590178,$005A0179,$007A017A,$005A017B,$007A017C,
  $005A017D,$007A017E,$00620180,$01100189,$00D00189,$00440189,$01920191,$00660191,
  $00660192,$00490197,$006C019A,$004F019F,$004F01A0,$006F01A1,$007401AB,$005401AE,
  $005501AF,$007501B0,$007A01B6,$007C01C0,$002101C3,$004101CD,$006101CE,$004901CF,
  $006901D0,$004F01D1,$006F01D2,$005501D3,$007501D4,$00DC01D5,$005501D5,$00FC01D6,
  $007501D6,$00DC01D7,$005501D7,$00FC01D8,$007501D8,$00DC01D9,$005501D9,$00FC01DA,
  $007501DA,$00DC01DB,$005501DB,$00FC01DC,$007501DC,$00C401DE,$004101DE,$00E401DF,
  $006101DF,$004101E0,$006101E1,$00C601E2,$00E601E3,$004701E4,$006701E5,$004701E6,
  $006701E7,$004B01E8,$006B01E9,$004F01EA,$006F01EB,$004F01EC,$006F01ED,$006A01F0,
  $004701F4,$006701F5,$004E01F8,$006E01F9,$00C501FA,$00E501FB,$00C601FC,$00E601FD,
  $00D801FE,$00F801FF,$00410200,$00610201,$00410202,$00610203,$00450204,$00650205,
  $00450206,$00650207,$00490208,$00690209,$0049020A,$0069020B,$004F020C,$006F020D,
  $004F020E,$006F020F,$00520210,$00720211,$00520212,$00720213,$00550214,$00750215,
  $00550216,$00750217,$00530218,$00730219,$0054021A,$0074021B,$0048021E,$0068021F,
  $00410226,$00610227,$00450228,$00650229,$00D6022A,$00F6022B,$00D5022C,$00F5022D,
  $004F022E,$006F022F,$004F0230,$006F0231,$00590232,$00790233,$00670261,$006802B0,
  $006A02B2,$007202B3,$007702B7,$007902B8,$002702B9,$002202BA,$201802BB,$006002BB,
  $002702BC,$005E02C4,$005E02C6,$005E02C7,$002702C8,$017B02C9,$00AF02C9,$00B402CA,
  $006002CB,$005F02CD,$005E02D8,$002702D9,$00B002DA,$00B802DB,$007E02DC,$00A802DD,
  $006C02E1,$007302E2,$007802E3,$00600300,$00B40301,$005E0302,$02DC0303,$007E0303,
  $017B0304,$00AF0304,$017B0305,$00AF0305,$02D80306,$02C60306,$02D90307,$00B70307,
  $00A80308,$00B0030A,$00A7030A,$02C7030C,$02C6030C,$0384030D,$0022030E,$00B80327,
  $005F0331,$005F0332,$003B037E,$00B70387,$00470393,$00540398,$005303A3,$004603A6,
  $004F03A9,$006103B1,$00DF03B2,$006403B4,$006503B5,$00B503BC,$044703BC,$007003C0,
  $007303C3,$007403C4,$006603C6,$04010400,$04220402,$04130403,$042D0404,$00530405,
  $00490406,$00490407,$004A0408,$041B0409,$041D040A,$0048040B,$041A040C,$0419040D,
  $0423040E,$04510450,$04420452,$04330453,$044D0454,$00730455,$00690456,$00690457,
  $006A0458,$043B0459,$043D045A,$0442045B,$043A045C,$0439045D,$0443045E,$041E0460,
  $043E0461,$042A0462,$044A0463,$042E0464,$044E0465,$04240472,$04440473,$00560474,
  $00760475,$00560476,$00760477,$042E0478,$044E0479,$041E047A,$043E047B,$041E047C,
  $043E047D,$041E047E,$043E047F,$04300483,$04300484,$04300485,$04300486,$04300488,
  $04300489,$042C048C,$044C048D,$0420048E,$0440048F,$04130490,$04330491,$04130492,
  $04330493,$04130494,$04330495,$04160496,$04360497,$04170498,$04370499,$041A049A,
  $043A049B,$041A049C,$043A049D,$041A049E,$043A049F,$041A04A0,$043A04A1,$041D04A2,
  $043D04A3,$041D04A4,$043D04A5,$041F04A6,$043F04A7,$041E04A8,$043E04A9,$042104AA,
  $044104AB,$042204AC,$044204AD,$042304AE,$044304AF,$042304B0,$044304B1,$042504B2,
  $044504B3,$042604B4,$044604B5,$042704B6,$044704B7,$042704B8,$044704B9,$004804BA,
  $006804BB,$041504BC,$043504BD,$041504BE,$043504BF,$004904C0,$041604C1,$043604C2,
  $041A04C3,$043A04C4,$041D04C7,$043D04C8,$042704CB,$044704CC,$041004D0,$043004D1,
  $041004D2,$043004D3,$041004D4,$043004D5,$040104D6,$045104D7,$042D04D8,$044D04D9,
  $042D04DA,$044D04DB,$041604DC,$043604DD,$041704DE,$043704DF,$041704E0,$043704E1,
  $041904E2,$043904E3,$041904E4,$043904E5,$041E04E6,$043E04E7,$041E04E8,$043E04E9,
  $041E04EA,$043E04EB,$042D04EC,$044D04ED,$042304EE,$044304EF,$042304F0,$044304F1,
  $042304F2,$044304F3,$042704F4,$044704F5,$042B04F8,$044B04F9,$003A0589,$00300660,
  $00310661,$00320662,$00330663,$00340664,$00350665,$00360666,$00370667,$00380668,
  $00390669,$0025066A,$064A06CC,$00411E00,$00611E01,$00421E02,$00621E03,$00421E04,
  $00621E05,$00421E06,$00621E07,$00431E08,$00631E09,$00441E0A,$00641E0B,$00441E0C,
  $00641E0D,$00441E0E,$00641E0F,$00441E10,$00641E11,$00441E12,$00641E13,$01121E14,
  $01131E15,$01121E16,$01131E17,$00451E18,$00651E19,$00451E1A,$00651E1B,$00451E1C,
  $00651E1D,$00461E1E,$00661E1F,$00471E20,$00671E21,$00481E22,$00681E23,$00481E24,
  $00681E25,$00481E26,$00681E27,$00481E28,$00681E29,$00481E2A,$00681E2B,$00491E2C,
  $00691E2D,$00491E2E,$00691E2F,$004B1E30,$006B1E31,$004B1E32,$006B1E33,$004B1E34,
  $006B1E35,$004C1E36,$006C1E37,$004C1E38,$006C1E39,$004C1E3A,$006C1E3B,$004C1E3C,
  $006C1E3D,$004D1E3E,$006D1E3F,$004D1E40,$006D1E41,$004D1E42,$006D1E43,$004E1E44,
  $006E1E45,$004E1E46,$006E1E47,$004E1E48,$006E1E49,$004E1E4A,$006E1E4B,$00D51E4C,
  $00F51E4D,$00D51E4E,$00F51E4F,$014C1E50,$014D1E51,$014C1E52,$014D1E53,$00501E54,
  $00701E55,$00501E56,$00701E57,$00521E58,$00721E59,$00521E5A,$00721E5B,$00521E5C,
  $00721E5D,$00521E5E,$00721E5F,$00531E60,$00731E61,$00531E62,$00731E63,$015A1E64,
  $015B1E65,$01601E66,$01611E67,$00531E68,$00731E69,$00541E6A,$00741E6B,$00541E6C,
  $00741E6D,$00541E6E,$00741E6F,$00541E70,$00741E71,$00551E72,$00751E73,$00551E74,
  $00751E75,$00551E76,$00751E77,$00551E78,$00751E79,$016A1E7A,$016B1E7B,$00561E7C,
  $00761E7D,$00561E7E,$00761E7F,$00571E80,$00771E81,$00571E82,$00771E83,$00571E84,
  $00771E85,$00571E86,$00771E87,$00571E88,$00771E89,$00581E8A,$00781E8B,$00581E8C,
  $00781E8D,$00591E8E,$00791E8F,$005A1E90,$007A1E91,$005A1E92,$007A1E93,$005A1E94,
  $007A1E95,$00681E96,$00741E97,$00771E98,$00791E99,$00731E9B,$00411EA0,$00611EA1,
  $00411EA2,$00611EA3,$00411EA4,$00611EA5,$00411EA6,$00611EA7,$00411EA8,$00611EA9,
  $00411EAA,$00611EAB,$00411EAC,$00611EAD,$00411EAE,$00611EAF,$00411EB0,$00611EB1,
  $00411EB2,$00611EB3,$00411EB4,$00611EB5,$00411EB6,$00611EB7,$00451EB8,$00651EB9,
  $00451EBA,$00651EBB,$00451EBC,$00651EBD,$00451EBE,$00651EBF,$00451EC0,$00651EC1,
  $00451EC2,$00651EC3,$00451EC4,$00651EC5,$00451EC6,$00651EC7,$00491EC8,$00691EC9,
  $00491ECA,$00691ECB,$004F1ECC,$006F1ECD,$004F1ECE,$006F1ECF,$004F1ED0,$006F1ED1,
  $004F1ED2,$006F1ED3,$004F1ED4,$006F1ED5,$004F1ED6,$006F1ED7,$004F1ED8,$006F1ED9,
  $004F1EDA,$006F1EDB,$004F1EDC,$006F1EDD,$004F1EDE,$006F1EDF,$004F1EE0,$006F1EE1,
  $004F1EE2,$006F1EE3,$00551EE4,$00751EE5,$00551EE6,$00751EE7,$00551EE8,$00751EE9,
  $00551EEA,$00751EEB,$00551EEC,$00751EED,$00551EEE,$00751EEF,$00551EF0,$00751EF1,
  $00591EF2,$00791EF3,$00591EF4,$00791EF5,$00591EF6,$00791EF7,$00591EF8,$00791EF9,
  $00601FEF,$00202000,$00202001,$00202002,$00202003,$00202004,$00202005,$00202006,
  $00202007,$00202008,$00202009,$0020200A,$002D2010,$002D2011,$002D2013,$002D2014,
  $003D2017,$00272018,$00272019,$002C201A,$0022201C,$0022201D,$0022201E,$253C2020,
  $002B2020,$256A2021,$002B2021,$002E2022,$00B72024,$002E2024,$002E2026,$0020202F,
  $00252030,$00272032,$00222033,$00602035,$003C2039,$003E203A,$0021203C,$002F2044,
  $0020205F,$00302070,$00312071,$00322072,$00332073,$00342074,$00352075,$00362076,
  $00372077,$00382078,$00392079,$002B207A,$003D207C,$0028207D,$0029207E,$006E207F,
  $00302080,$00312081,$00302081,$00B22082,$00322082,$00B32083,$00332083,$00342084,
  $00352085,$00362086,$00372087,$00382088,$00392089,$002B208A,$003D208C,$0028208D,
  $0029208E,$00A220A1,$014120A4,$00A320A4,$005020A7,$00432102,$00452107,$0067210A,
  $0048210B,$0048210C,$0048210D,$0068210E,$00492110,$00492111,$004C2112,$006C2113,
  $004E2115,$00502118,$00502119,$0051211A,$0052211B,$0052211C,$0052211D,$00542122,
  $005A2124,$03A92126,$005A2128,$004B212A,$0139212B,$00C5212B,$0042212C,$0043212D,
  $0065212E,$0065212F,$00452130,$00462131,$004D2133,$006F2134,$00692139,$00442145,
  $00642146,$00652147,$00692148,$006A2149,$00492160,$00562164,$00582169,$004C216C,
  $0043216D,$0044216E,$004D216F,$00692170,$00762174,$00782179,$006C217C,$0063217D,
  $0064217E,$006D217F,$003C2190,$005E2191,$003E2192,$00762193,$002D2194,$00A62195,
  $007C2195,$00A621A8,$007C21A8,$04912202,$01582205,$00D82205,$002D2212,$00B12213,
  $002F2215,$005C2216,$002A2217,$00B02218,$20222219,$00B72219,$0076221A,$0038221E,
  $004C221F,$007C2223,$006E2229,$003A2236,$007E223C,$02DC2248,$003D2261,$003C2264,
  $003E2265,$00AB226A,$003C226A,$00BB226B,$003E226B,$003C226E,$003E226F,$00B722C5,
  $00A62302,$005E2303,$002D2310,$00282320,$00292321,$003C2329,$003E232A,$00312460,
  $00322461,$00332462,$00342463,$00352464,$00362465,$00372466,$00382467,$00392468,
  $004124B6,$004224B7,$004324B8,$004424B9,$004524BA,$004624BB,$004724BC,$004824BD,
  $004924BE,$004A24BF,$004B24C0,$004C24C1,$004D24C2,$004E24C3,$004F24C4,$005024C5,
  $005124C6,$005224C7,$005324C8,$005424C9,$005524CA,$005624CB,$005724CC,$005824CD,
  $005924CE,$005A24CF,$006124D0,$006224D1,$006324D2,$006424D3,$006524D4,$006624D5,
  $006724D6,$006824D7,$006924D8,$006A24D9,$006B24DA,$006C24DB,$006D24DC,$006E24DD,
  $006F24DE,$007024DF,$007124E0,$007224E1,$007324E2,$007424E3,$007524E4,$007624E5,
  $007724E6,$007824E7,$007924E8,$007A24E9,$003024EA,$002D2500,$007C2502,$0E3A250C,
  $002B250C,$0E1F2510,$002B2510,$0E202514,$002B2514,$0E392518,$002B2518,$007C251C,
  $007C2524,$002B252C,$002B2534,$002B253C,$003D2550,$00A62551,$007C2551,$002B2552,
  $002B2553,$0E292554,$002B2554,$002B2555,$002B2556,$0E1B2557,$002B2557,$002B2558,
  $002B2559,$0E28255A,$002B255A,$002B255B,$002B255C,$002B255D,$007C255E,$007C255F,
  $007C2560,$007C2561,$007C2562,$007C2563,$002B2564,$002B2565,$002B2566,$002B2567,
  $002B2568,$002B2569,$002B256A,$002B256B,$002B256C,$002D2580,$F8C22584,$002D2584,
  $007C2588,$007C258C,$007C2590,$007C2591,$007C2592,$007C2593,$002D25AC,$005E25B2,
  $003E25BA,$007625BC,$003C25C4,$006F25CB,$202225D8,$006F25D8,$006F25D9,$004F263A,
  $004F263B,$00A4263C,$006F263C,$002B2640,$003E2642,$005E2660,$005E2663,$00762665,
  $002B2666,$0064266A,$0064266B,$007C2758,$2018275B,$2019275C,$201C275D,$201D275E,
  $00203000,$003C3008,$003E3009,$00AB300A,$00BB300B,$005B301A,$005D301B,$201C301D,
  $0022301D,$201D301E,$0022301E,$201E301F,$00B730FB,$201430FC,$20ACF7C2,$002BFB29,
  $067EFB56,$067EFB57,$067EFB58,$067EFB59,$0679FB66,$0679FB67,$0679FB68,$0679FB69,
  $0686FB7A,$0686FB7B,$0686FB7C,$0686FB7D,$0688FB88,$0688FB89,$0698FB8A,$0698FB8B,
  $0691FB8C,$0691FB8D,$06A9FB8E,$06A9FB8F,$06A9FB90,$06A9FB91,$06AFFB92,$06AFFB93,
  $06AFFB94,$06AFFB95,$06BAFB9E,$06BAFB9F,$06C1FBA6,$06C1FBA7,$06C1FBA8,$06C1FBA9,
  $06BEFBAA,$06BEFBAB,$06BEFBAC,$06BEFBAD,$06D2FBAE,$06D2FBAF,$005FFE33,$005FFE34,
  $0028FE35,$0029FE36,$007BFE37,$007DFE38,$005FFE4D,$005FFE4E,$005FFE4F,$002CFE50,
  $002EFE52,$003BFE54,$003AFE55,$0021FE57,$0028FE59,$0029FE5A,$007BFE5B,$007DFE5C,
  $0023FE5F,$0026FE60,$002AFE61,$002BFE62,$002DFE63,$003CFE64,$003EFE65,$003DFE66,
  $005CFE68,$0024FE69,$0025FE6A,$0040FE6B,$064BFE70,$064BFE71,$064CFE72,$064DFE74,
  $064EFE76,$064EFE77,$064FFE78,$064FFE79,$0650FE7A,$0650FE7B,$0651FE7C,$0651FE7D,
  $0652FE7E,$0652FE7F,$0621FE80,$0622FE81,$0622FE82,$0623FE83,$0623FE84,$0624FE85,
  $0624FE86,$0625FE87,$0625FE88,$0626FE89,$0626FE8A,$0626FE8B,$0626FE8C,$0627FE8D,
  $0627FE8E,$0628FE8F,$0628FE90,$0628FE91,$0628FE92,$0629FE93,$0629FE94,$062AFE95,
  $062AFE96,$062AFE97,$062AFE98,$062BFE99,$062BFE9A,$062BFE9B,$062BFE9C,$062CFE9D,
  $062CFE9E,$062CFE9F,$062CFEA0,$062DFEA1,$062DFEA2,$062DFEA3,$062DFEA4,$062EFEA5,
  $062EFEA6,$062EFEA7,$062EFEA8,$062FFEA9,$062FFEAA,$0630FEAB,$0630FEAC,$0631FEAD,
  $0631FEAE,$0632FEAF,$0632FEB0,$0633FEB1,$0633FEB2,$0633FEB3,$0633FEB4,$0634FEB5,
  $0634FEB6,$0634FEB7,$0634FEB8,$0635FEB9,$0635FEBA,$0635FEBB,$0635FEBC,$0636FEBD,
  $0636FEBE,$0636FEBF,$0636FEC0,$0637FEC1,$0637FEC2,$0637FEC3,$0637FEC4,$0638FEC5,
  $0638FEC6,$0638FEC7,$0638FEC8,$0639FEC9,$0639FECA,$0639FECB,$0639FECC,$063AFECD,
  $063AFECE,$063AFECF,$063AFED0,$0641FED1,$0641FED2,$0641FED3,$0641FED4,$0642FED5,
  $0642FED6,$0642FED7,$0642FED8,$0643FED9,$0643FEDA,$0643FEDB,$0643FEDC,$0644FEDD,
  $0644FEDE,$0644FEDF,$0644FEE0,$0645FEE1,$0645FEE2,$0645FEE3,$0645FEE4,$0646FEE5,
  $0646FEE6,$0646FEE7,$0646FEE8,$0647FEE9,$0647FEEA,$0647FEEB,$0647FEEC,$0648FEED,
  $0648FEEE,$0649FEEF,$0649FEF0,$064AFEF1,$064AFEF2,$064AFEF3,$064AFEF4,$0021FF01,
  $0022FF02,$0023FF03,$0024FF04,$0025FF05,$0026FF06,$0027FF07,$0028FF08,$0029FF09,
  $002AFF0A,$002BFF0B,$002CFF0C,$002DFF0D,$002EFF0E,$002FFF0F,$0030FF10,$0031FF11,
  $0032FF12,$0033FF13,$0034FF14,$0035FF15,$0036FF16,$0037FF17,$0038FF18,$0039FF19,
  $003AFF1A,$003BFF1B,$003CFF1C,$003DFF1D,$003EFF1E,$003FFF1F,$0040FF20,$0041FF21,
  $0042FF22,$0043FF23,$0044FF24,$0045FF25,$0046FF26,$0047FF27,$0048FF28,$0049FF29,
  $004AFF2A,$004BFF2B,$004CFF2C,$004DFF2D,$004EFF2E,$004FFF2F,$0050FF30,$0051FF31,
  $0052FF32,$0053FF33,$0054FF34,$0055FF35,$0056FF36,$0057FF37,$0058FF38,$0059FF39,
  $005AFF3A,$005BFF3B,$005CFF3C,$005DFF3D,$005EFF3E,$005FFF3F,$0060FF40,$0061FF41,
  $0062FF42,$0063FF43,$0064FF44,$0065FF45,$0066FF46,$0067FF47,$0068FF48,$0069FF49,
  $006AFF4A,$006BFF4B,$006CFF4C,$006DFF4D,$006EFF4E,$006FFF4F,$0070FF50,$0071FF51,
  $0072FF52,$0073FF53,$0074FF54,$0075FF55,$0076FF56,$0077FF57,$0078FF58,$0079FF59,
  $007AFF5A,$007BFF5B,$007CFF5C,$007DFF5D,$007EFF5E,$00A2FFE0,$00A3FFE1,$00ACFFE2,
  $00A6FFE4, {fake}0);

procedure TTextConvSBCS.FillVALUES(var Buffer: TTextConvBW);
var
  UCS2Chars: PTextConvWB;
  S, D, i: NativeUInt;

  BESTFIT: PCardinal;
  {$ifNdef CPUX86}
  TOP_BESTFIT: PCardinal;
  {$endif}
begin
  UCS2Chars := Pointer(Self.FUCS2.Original);
  if (UCS2Chars = nil) then UCS2Chars := Pointer(Self.AllocFillUCS2(Self.FUCS2.Original, ccOriginal)); // Alloc and Fill

  // fill basic chars + TTextConvSBCSValues.UCS2
  TinyMove(UCS2Chars^, Pointer(NativeUInt(@Buffer) + SizeOf(Buffer))^, SizeOf(TTextConvWB));
  FillBytesArrayDefault(@Buffer, SizeOf(Buffer));
  for i := 128 to 255 do
  begin
    S := UCS2Chars[i];
    if (S <> $3f) then Buffer[S] := i;
  end;

  // fill bestfits
  BESTFIT := Pointer(@SBCS_BESTFITS[0]);
  {$ifNdef CPUX86}
  TOP_BESTFIT := Pointer(@SBCS_BESTFITS[High(SBCS_BESTFITS)]);
  {$endif}
  // for each F in SBCS_BESTFITS do
  repeat
    S := BESTFIT^;
    Inc(BESTFIT);
    D := S shr 16; // to (unicode)
    S := Word(S);  // from (unicode)

    {$ifdef CPUX86}
      if (UCS2Chars[Buffer[D]] = Word(D)) and (Buffer[S] = $3f) then
        Buffer[S] := Buffer[D];
    {$else}
      i := Buffer[D];
      if (UCS2Chars[i] = Word(D)) and (Buffer[S] = $3f) then Buffer[S] := i;
    {$endif}
  until (BESTFIT = {$ifNdef CPUX86} TOP_BESTFIT {$else}
            Pointer(@SBCS_BESTFITS[High(SBCS_BESTFITS)]){$endif});
end;

function TTextConvSBCS.AllocFillVALUES(var Buffer: PTextConvSBCSValues): PTextConvSBCSValues;
begin
  Result := Buffer;
  if (Result = nil) then
  begin
    Result := InternalLookupAlloc(SizeOf(TTextConvSBCSValues));
    FillVALUES(PTextConvBW(Result)^);
    Result := InternalLookupFill(Pointer(Buffer), Result);
  end;
end;

function TTextConvSBCS.GetUCS2: PTextConvUS;
begin
  Result := Self.FUCS2.Original;
  if (Result = nil) then Result := AllocFillUCS2(Self.FUCS2.Original, ccOriginal);
end;

function TTextConvSBCS.GetLowerCaseUCS2: PTextConvUS;
begin
  Result := Self.FUCS2.Lower;
  if (Result = nil) then Result := AllocFillUCS2(Self.FUCS2.Lower, ccLower);
end;

function TTextConvSBCS.GetUpperCaseUCS2: PTextConvUS;
begin
  Result := Self.FUCS2.Upper;
  if (Result = nil) then Result := AllocFillUCS2(Self.FUCS2.Upper, ccUpper);
end;

function TTextConvSBCS.GetUTF8: PTextConvMS;
begin
  Result := Self.FUTF8.Original;
  if (Result = nil) then Result := AllocFillUTF8(Self.FUTF8.Original, ccOriginal);
end;

function TTextConvSBCS.GetLowerCaseUTF8: PTextConvMS;
begin
  Result := Self.FUTF8.Lower;
  if (Result = nil) then Result := AllocFillUTF8(Self.FUTF8.Lower, ccLower);
end;

function TTextConvSBCS.GetUpperCaseUTF8: PTextConvMS;
begin
  Result := Self.FUTF8.Upper;
  if (Result = nil) then Result := AllocFillUTF8(Self.FUTF8.Upper, ccUpper);
end;

function TTextConvSBCS.GetVALUES: PTextConvSBCSValues;
begin
  Result := Self.FVALUES;
  if (Result = nil) then Result := AllocFillVALUES(Self.FVALUES);
end;

function TTextConvSBCS.GetLowerCase: PTextConvSS;
begin
  Result := FLowerCase;

  if (Result = nil) then
    Result := FromSBCS(@Self, ccLower);
end;

function TTextConvSBCS.GetUpperCase: PTextConvSS;
begin
  Result := FUpperCase;

  if (Result = nil) then
    Result := FromSBCS(@Self, ccUpper);
end;

procedure FillTable_CaseSBCS_Advanced(var Table: TTextConvBB;
  const UCS2Chars: TTextConvWB; const UnCharCaseLookup: TTextConvWW);
type
  THashItem = packed record
    UCS2: Word;
    Index: Byte;
    Next: Byte;
  end;
var
  P: PByte;
  i, X, Value, Count: NativeUInt;
  CharCaseLookup: PTextConvWW;
  HashArray: array[0..63] of Byte;
  HashItems: array[0..127] of THashItem;
begin
  // fill hash table
  P := @HashArray[0];
  for i := 0 to (SizeOf(HashArray) div SizeOf(NativeInt)) - 1 do
  begin
    PNativeInt(P)^ := -1;
    Inc(P, SizeOf(NativeInt));
  end;
  Count := 0;
  for i := 128 to 255 do
  begin
    X := UCS2Chars[i];
    Value := UnCharCaseLookup[X];
    if (Value = X) or (Value = Ord('?')) then Continue;

    HashItems[Count].UCS2 := X;
    HashItems[Count].Index := i;
    X := X and High(HashArray);
    HashItems[Count].Next := HashArray[X];

    HashArray[X] := Count;
    Inc(Count);
  end;

  // normalize lookup
  if (@UnCharCaseLookup = Pointer(@TEXTCONV_CHARCASE.LOWER)) then
  begin
    CharCaseLookup := Pointer(@TEXTCONV_CHARCASE.UPPER);
  end else
  begin
    CharCaseLookup := Pointer(@TEXTCONV_CHARCASE.LOWER);
  end;

  // fill from hash table
  for i := 128 to 255 do
  begin
    X := UCS2Chars[i];
    Value := CharCaseLookup[X];
    if (Value = X) or (Value = Ord('?')) then Continue;

    X := HashArray[Value and High(HashArray)];
    while (X <> 255) do
    begin
      if (HashItems[X].UCS2 = Value) then
      begin
        Table[i] := HashItems[X].Index;
        Break;
      end;

      X := HashItems[X].Next;
    end;
  end;
end;

procedure FillTable_CaseSBCS(var Table: TTextConvBB; const Index: NativeInt; const Upper: Boolean);
{$ifNdef CPUARM}
const
  SBCS_INCREMENT = $04040404;
{$else}
var
  SBCS_INCREMENT: Cardinal;
{$endif}
var
  i: NativeInt;
  P, D: PByte;
  Count, Value: Cardinal;
  X: NativeUInt;

  _Self: PTextConvSBCS;
  UCS2Chars: PTextConvWB;
begin
  // fill default characters
  FillBytesArrayDefault(@Table, -1);
  if (Upper) then
  begin
    P := Pointer(@Table[$61{Ord('a')}]);
    X := $44434241;
  end else
  begin
    P := Pointer(@Table[$41{Ord('A')}]);
    X := $64636261;
  end;
  // a..z, 'A'..'Z'
  {$ifdef CPUARM}
    SBCS_INCREMENT := $04040404;
  {$endif}
  for i := 0 to (26 div SizeOf(Cardinal)) - 1 do
  begin
    PCardinal(P)^ := X;
    Inc(P, SizeOf(Cardinal));
    Inc(X, SBCS_INCREMENT);
  end;
  PWord(P)^ := X;

  // raw data
  if (Index = 0) then
  begin
    if (Upper) then
    begin
      Table[255] := 63;
      P := Pointer(@Table[$E0]);
      X := $C3C2C1C0;
    end else
    begin
      P := Pointer(@Table[$C0]);
      X := $E3E2E1E0;
    end;

    for i := 0 to (30 div SizeOf(Cardinal)) - 1 do
    begin
      PCardinal(P)^ := X;
      Inc(P, SizeOf(Cardinal));
      Inc(X, SBCS_INCREMENT);
    end;
    PWord(P)^ := X;

    Exit;
  end;

  // user defined
  if (TEXTCONV_SUPPORTED_SBCS[Index].CodePage = CODEPAGE_USERDEFINED) then  Exit;

  // unpack "?" characters
  P := @SBCS_UCS2[SBCS_UCS2_OFFSETS[Index]];
  Count := Cardinal(P^) shl 8;
  Inc(P);
  repeat
    X := P^;
    Inc(P);
    Dec(Count, $0100);

    if (X < 128) then
    begin
      if (P^ = Ord('?')) then Table[X + 128] := Ord('?');
      Inc(P, 2);
    end else
    begin
      Value := PWord(P)^;
      Inc(P, 2);
      if (Value = Ord('?')) then
      begin
        Count := Count or Cardinal(P^);
        D := @Table[X];

        repeat
          D^ := Ord('?');
          Dec(Count);
          Inc(D);
        until (Count and $ff = 0);
      end;
      Inc(P);
    end;
  until (Count = 0);

  // advanced logic for 1256 code page
  if (Index = 8) and (Upper) then
  begin
    Table[224] := 65;
    Table[226] := 65;
    Table[231] := 67;
    Table[232] := 69;
    Table[233] := 69;
    Table[234] := 69;
    Table[235] := 69;
    Table[238] := 73;
    Table[239] := 73;
    Table[244] := 79;
    Table[249] := 85;
    Table[251] := 85;
    Table[252] := 85;
  end;

  // advanced logic for 10000 code page (Mac)
  if (Index = 26) then
  begin
    if (Upper) then Table[185] := Ord('?')
    else Table[189] := Ord('?');
  end;

  // UCS2Chars := Self.UCS2
  _Self := @TEXTCONV_SUPPORTED_SBCS[Index];
  UCS2Chars := Pointer(_Self.FUCS2.Original);
  if (UCS2Chars = nil) then UCS2Chars := Pointer(_Self.AllocFillUCS2(_Self.FUCS2.Original, ccOriginal)); // Alloc and Fill

  // advanced characters: 128..255
  FillTable_CaseSBCS_Advanced(Table, UCS2Chars^,
    PTextConvWW(@TEXTCONV_CHARCASE.VALUES[NativeUInt(not Upper) shl 16])^);
end;

procedure FillTable_SBCSFromSBCS(var Table: TTextConvBB; const DestSBCS: TTextConvBW;
                                 const SourceUCS2: TTextConvWB; const CharCase: TCharCase); overload;
{$ifNdef CPUARM}
const
  SBCS_INCREMENT = $04040404;
{$else}
var
  SBCS_INCREMENT: Cardinal;
{$endif}
var
  CaseLookup: PTextConvWW;
  i: Integer;

  P: PCardinal;
  X: Cardinal;
begin
  FillBytesArrayDefault(@Table, -1);
  case CharCase of
    ccUpper:
    begin
      CaseLookup := Pointer(@TEXTCONV_CHARCASE.UPPER);
      P := Pointer(@Table[$61{Ord('a')}]);
      X := $44434241;
    end;
    ccLower:
    begin
      CaseLookup := Pointer(@TEXTCONV_CHARCASE.LOWER);
      P := Pointer(@Table[$41{Ord('A')}]);
      X := $64636261;
    end;
  else
    for i := 128 to 255 do
    Table[i] := DestSBCS[SourceUCS2[i]];
    Exit;
  end;

  // a..z, 'A'..'Z'
  {$ifdef CPUARM}
    SBCS_INCREMENT := $04040404;
  {$endif}
  for i := 0 to (26 div SizeOf(Cardinal)) - 1 do
  begin
    P^ := X;
    Inc(P);
    Inc(X, SBCS_INCREMENT);
  end;
  PWord(P)^ := X;

  // 128..255
  for i := 128 to 255 do
  Table[i] := DestSBCS[CaseLookup[SourceUCS2[i]]];
end;

// low allocated memory way
// to generate SBCSFromSBCS lookup
procedure FillTable_SBCSFromSBCS(var Table: TTextConvBB; const DestIndex: Integer;
                                 const SourceUCS2: TTextConvWB; const CharCase: TCharCase); overload;
var
  DestVALUES: TTextConvSBCSValues;
begin
  TEXTCONV_SUPPORTED_SBCS[DestIndex].FillVALUES(TTextConvBW(DestVALUES.SBCS));
  FillTable_SBCSFromSBCS(Table, TTextConvBW(DestVALUES.SBCS), SourceUCS2, CharCase);
end;


function TTextConvSBCS.FromSBCS(const Source: PTextConvSBCS; const CharCase: TCharCase): PTextConvSS;
type
  PTableSBCSItem = ^TTableSBCSItem;
  TTableSBCSItem = record
    Value: Integer;
    Next: PTableSBCSItem;
    Table: TTextConvBB;
  end;
var
  AIndex, Value: Integer;
  First, Item, ResultItem: PTableSBCSItem;

  Lookup, InternalPtr: Pointer;
  SourceUCS2: PTextConvWB;
begin
  AIndex := Source.Index;
  if (AIndex = Self.Index) and (CharCase <> ccOriginal) then
  begin
    if (CharCase = ccUpper) then Result := FUpperCase
    else Result := FLowerCase;

    if (Result = nil) then
    begin
      Result := InternalLookupAlloc(SizeOf(TTextConvSS));
      FillTable_CaseSBCS(PTextConvBB(Result)^, Self.Index, (CharCase = ccUpper));

      if (CharCase = ccUpper) then Result := InternalLookupFill(Pointer(FUpperCase), Result)
      else Result := InternalLookupFill(Pointer(FLowerCase), Result);
    end;
  end else
  begin
    ResultItem := nil;
    Value := AIndex or (Ord(CharCase) shl 16);

    repeat
      First := Self.FTableSBCSItems;

      // find
      Item := First;
      while (Item <> nil) do
      begin
        if (Item.Value = Value) then
        begin
          // found
          if (ResultItem <> nil) then
          begin
            Dec(NativeInt(ResultItem), SizeOf(Pointer));
            FreeMem(ResultItem);
          end;

          Result := Pointer(@Item.Table);
          Exit;
        end;
        Item := Item.Next;
      end;

      // alloc and fill
      if (ResultItem = nil) then
      begin
        ResultItem := InternalLookupAlloc(SizeOf(TTableSBCSItem));
        ResultItem.Value := Value;

        if (Self.Index = AIndex) then
        begin
          FillBytesArrayDefault(@ResultItem.Table, -1);
        end else
        begin
          SourceUCS2 := Pointer(TEXTCONV_SUPPORTED_SBCS[AIndex].FUCS2.Original);
          if (SourceUCS2 = nil) then SourceUCS2 := Pointer(TEXTCONV_SUPPORTED_SBCS[AIndex].UCS2);

          if (Self.FVALUES <> nil) then
          begin
             FillTable_SBCSFromSBCS(ResultItem.Table, PTextConvBW(Self.FVALUES)^, SourceUCS2^, CharCase);
          end else
          begin
             FillTable_SBCSFromSBCS(ResultItem.Table, Self.Index, SourceUCS2^, CharCase);
          end;
        end;
      end;

      // try add ResultItem to list
      ResultItem.Next := First;
    until (First = AtomicCmpExchange(Self.FTableSBCSItems, ResultItem, First));

    // result
    Result := Pointer(@ResultItem.Table);

    // add to internal list of pointers
    InternalPtr := ResultItem;
    Dec(NativeInt(InternalPtr), SizeOf(Pointer));
    repeat
      Lookup := InternalLookups;
      PPointer(InternalPtr)^ := Lookup;
    until (Lookup = AtomicCmpExchange(InternalLookups, InternalPtr, Lookup));
  end;
end;
{$ifdef undef}{$ENDREGION}{$endif}

{$ifdef undef}{$REGION 'TTextConv routine'}{$endif}
const
  ENC_SBCS = 0;
  ENC_UTF8 = 1;
  ENC_UTF16 = 2;
  ENC_UTF16BE = 3;
  ENC_UTF32 = 4;
  ENC_UTF32BE = 5;
  ENC_UCS2143 = 6;
  ENC_UCS3412 = 7;
  ENC_UTF1 = 8;
  ENC_UTF7 = 9;
  ENC_UTFEBCDIC = 10;
  ENC_SCSU = 11;
  ENC_BOCU1 = 12;
  ENC_GB18030 = 13; // <-- BOM
  ENC_GB2312 = 14;
  ENC_HZGB2312 = 15;
  ENC_BIG5 = 16;
  ENC_SHIFT_JIS = 17;
  ENC_EUC_JP = 18;
  ENC_ISO2022JP = 19;
  ENC_CP949 = 20;
  ENC_EUC_KR = 21;

  ENCODING_MASK = $1f;
  ENCODING_DESTINATION_OFFSET = 27;

  FLAG_SRC_STATE_NEEDED = 1 shl 5;
  FLAG_DEST_STATE_NEEDED = 1 shl 6;
  FLAGS_STATE_NEEDED = (FLAG_SRC_STATE_NEEDED or FLAG_DEST_STATE_NEEDED);
  FLAG_DEST_MARGIN_NEEDED = 1 shl 7;
  FLAG_MODE_FINALIZE = 1 shl 8;

  CHARCASE_MASK = $3 shl 16;
  CHARCASE_MASK_ORIGINAL = $1 shl 24;
  CHARCASE_FLAGS: array[TCharCase] of Cardinal =
  (
     CHARCASE_MASK_ORIGINAL or FLAG_MODE_FINALIZE,
     (Ord(ccLower) shl 16) or FLAG_MODE_FINALIZE,
     (Ord(ccUpper) shl 16) or FLAG_MODE_FINALIZE
  );

function CodePageEncoding(const CodePage: Word): Cardinal{Word};
var
  Index: NativeUInt;
  Value: Integer;
begin
  // TextConvSBCSIndex
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);

  // detect unicode/multy-byte
  // convert to internal format
  if (Value < 0) and (CodePage <> CODEPAGE_RAWDATA) then
  begin
    Value := CodePage;
    if (CodePage = 0) then Value := CODEPAGE_DEFAULT;
    Result := 0; // undefined --> raw data (ENC_SBCS, Index 0)
    case Value{CodePage} of
       CODEPAGE_UTF8: begin Inc(Result, ENC_UTF8); Exit; end;
      CODEPAGE_UTF16: begin Inc(Result, ENC_UTF16); Exit; end;
    CODEPAGE_UTF16BE: begin Inc(Result, ENC_UTF16BE); Exit; end;
      CODEPAGE_UTF32: begin Inc(Result, ENC_UTF32); Exit; end;
    CODEPAGE_UTF32BE: begin Inc(Result, ENC_UTF32BE); Exit; end;
    CODEPAGE_UCS2143: begin Inc(Result, ENC_UCS2143); Exit; end;
    CODEPAGE_UCS3412: begin Inc(Result, ENC_UCS3412); Exit; end;
       CODEPAGE_UTF1: begin Inc(Result, ENC_UTF1); Exit; end;
       CODEPAGE_UTF7: begin Inc(Result, ENC_UTF7); Exit; end;
  CODEPAGE_UTFEBCDIC: begin Inc(Result, ENC_UTFEBCDIC); Exit; end;
       CODEPAGE_SCSU: begin Inc(Result, ENC_SCSU); Exit; end;
      CODEPAGE_BOCU1: begin Inc(Result, ENC_BOCU1); Exit; end;
                 932: begin Inc(Result, ENC_SHIFT_JIS); Exit; end;// Japanese (shift_jis)
                 936: begin Inc(Result, ENC_GB2312); Exit; end;   // Simplified Chinese (gb2312)
                 949: begin Inc(Result, ENC_CP949); Exit; end;    // Korean (ks_c_5601-1987)
                 950: begin Inc(Result, ENC_BIG5); Exit; end;     // Traditional Chinese (big5)
               54936: begin Inc(Result, ENC_GB18030); Exit; end;  // Simplified Chinese (gb18030)
               52936: begin Inc(Result, ENC_HZGB2312); Exit; end; // Simplified Chinese (hz-gb-2312)
               20932: begin Inc(Result, ENC_EUC_JP); Exit; end;   // Japanese (euc-jp)
               50221: begin Inc(Result, ENC_ISO2022JP); Exit; end;// Japanese with halfwidth Katakana (iso-2022-jp)
               51949: begin Inc(Result, ENC_EUC_KR); Exit; end;   // EUC Korean (euc-kr)
    end;
  end else
  begin
    // Low: ENC_SBCS; High: Index;
    Result := (Value shr 8) and $ff00;
  end;
end;

type
  TWordTable = array[0..0] of Word;
  PWordTable = ^TWordTable;

  TWordHashItem = packed record
    X: Word;
    Value: Word;

    Next: Word;
    __align: Word;
  end;
  PWordHashItem = ^TWordHashItem;

  TWordHash = object
    Indexes: array[0..8*1024-1] of Word;
    Items: array[1..1] of TWordHashItem;

    function Find(const X: Cardinal): Word;
  end;
  PWordHash = ^TWordHash;

var
  table_jisx0208: PWordTable;
  table_jisx0212: PWordTable;
  table_ksc5601: PWordTable;
  table_uhc_1: PWordTable;
  table_uhc_2: PWordTable;
  table_gb2312: PWordTable;
  table_gbkext1: PWordTable;
  table_gbkext2: PWordTable;
  table_gb18030ext: PWordTable;
  table_big5: PWordTable;

  range_gb18030_read: PWordTable;
  range_gb18030_write: PWordTable;
  offsets_gb18030: PWordTable;

  hash_jisx0208: PWordHash;
  hash_jisx0212: PWordHash;
  hash_ksc5601: PWordHash;
  hash_uhc_1: PWordHash;
  hash_uhc_2: PWordHash;
  hash_gb2312: PWordHash;
  hash_gbkext1: PWordHash;
  hash_gbkext2: PWordHash;
  hash_gb18030ext: PWordHash;
  hash_big5: PWordHash;

procedure generate_hash_jisx0208; forward;
procedure generate_hash_jisx0212; forward;
procedure generate_hash_ksc5601; forward;
procedure generate_hash_uhc_1; forward;
procedure generate_hash_uhc_2; forward;
procedure generate_hash_gb2312; forward;
procedure generate_hash_gbkext1; forward;
procedure generate_hash_gbkext2; forward;
procedure generate_hash_gb18030ext; forward;
procedure generate_hash_big5; forward;

function generate_table_jisx0208: PWordTable; forward;
function generate_table_jisx0212: PWordTable; forward;
function generate_table_ksc5601: PWordTable; forward;
function generate_table_uhc_1: PWordTable; forward;
function generate_table_uhc_2: PWordTable; forward;
function generate_table_gb2312: PWordTable; forward;
function generate_table_gbkext1: PWordTable; forward;
function generate_table_gbkext2: PWordTable; forward;
function generate_table_gb18030ext: PWordTable; forward;
function generate_table_big5: PWordTable; forward;

function generate_range_gb18030_read: PWordTable; forward;
function generate_range_gb18030_write: PWordTable; forward;
function generate_offsets_gb18030: PWordTable; forward;


{ TTextConvContext }

procedure TTextConvContext.ResetState;
begin
  FState.WR := 0;
end;

procedure TTextConvContext.Init(const ADestinationCodePage,
  ASourceCodePage: Word; const ACharCase: TCharCase);
var
  DestinationEncoding: Cardinal;
  SourceEncoding: Cardinal;
  SBCS: PTextConvSBCS;
begin
  // store code pages
  F.DestinationCodePage := ADestinationCodePage;
  F.SourceCodePage := ASourceCodePage;

  // fast most frequently used conversions
  DestinationEncoding := CodePageEncoding(F.DestinationCodePage);
  SourceEncoding := CodePageEncoding(F.SourceCodePage);
  if ((DestinationEncoding or SourceEncoding) and ENCODING_MASK <= ENC_UTF16) then
  begin
    case (DestinationEncoding and ENCODING_MASK) * 3 + (SourceEncoding and ENCODING_MASK) of
      0: InitSBCSFromSBCS(F.DestinationCodePage, F.SourceCodePage, ACharCase);
      1: InitSBCSFromUTF8(F.DestinationCodePage, ACharCase);
      2: InitSBCSFromUTF16(F.DestinationCodePage, ACharCase);
      3: InitUTF8FromSBCS(F.SourceCodePage, ACharCase);
      4: InitUTF8FromUTF8(ACharCase);
      5: InitUTF8FromUTF16(ACharCase);
      6: InitUTF16FromSBCS(F.SourceCodePage, ACharCase);
      7: InitUTF16FromUTF8(ACharCase);
    else
    //8:
      InitUTF16FromUTF16(ACharCase);
    end;

    Exit;
  end;

  // state, flags and conversion
  FState.WR := 0;
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (DestinationEncoding shl ENCODING_DESTINATION_OFFSET) +
    (SourceEncoding and ENCODING_MASK);
  if (DestinationEncoding = SourceEncoding) and (ACharCase = ccOriginal) then
  begin
    if (DestinationEncoding and ENCODING_MASK = 0) then
    begin
      SBCS := @TEXTCONV_SUPPORTED_SBCS[DestinationEncoding shr 8];
      F.DestinationCodePage := SBCS.CodePage;
      F.SourceCodePage := SBCS.CodePage;
    end;
    FConvertProc := Pointer(@TTextConvContext.convert_copy);
    Exit;
  end else
  begin
    FConvertProc := Pointer(@TTextConvContext.convert_universal);
  end;

  // readers
  case (SourceEncoding and ENCODING_MASK) of
    ENC_SBCS:
    begin
      SBCS := @TEXTCONV_SUPPORTED_SBCS[SourceEncoding shr 8];
      F.SourceCodePage := SBCS.CodePage;
      FCallbacks.Reader := SBCS.FUCS2.Items[F.CharCase];
      if (FCallbacks.Reader = nil) then FCallbacks.Reader := SBCS.AllocFillUCS2(SBCS.FUCS2.Items[F.CharCase], F.CharCase);
    end;
    ENC_UTF1:
    begin
      FCallbacks.Reader := @TTextConvContext.utf1_reader;
    end;
    ENC_UTF7:
    begin
      F.Flags := F.Flags or FLAG_SRC_STATE_NEEDED;
      FCallbacks.Reader := @TTextConvContext.utf7_reader;
    end;
    ENC_UTFEBCDIC:
    begin
      FCallbacks.Reader := @TTextConvContext.utf_ebcdic_reader;
    end;
    ENC_SCSU:
    begin
      F.Flags := F.Flags or FLAG_SRC_STATE_NEEDED;
      FCallbacks.Reader := @TTextConvContext.scsu_reader;
    end;
    ENC_BOCU1:
    begin
      F.Flags := F.Flags or FLAG_SRC_STATE_NEEDED;
      FCallbacks.Reader := @TTextConvContext.bocu1_reader;
    end;
    ENC_GB18030:
    begin
      FCallbacks.Reader := @TTextConvContext.gb18030_reader;
      if (table_gb2312 = nil) then generate_table_gb2312;
      if (table_gbkext1 = nil) then generate_table_gbkext1;
      if (table_gbkext2 = nil) then generate_table_gbkext2;
      if (table_gb18030ext = nil) then generate_table_gb18030ext;
      if (range_gb18030_read = nil) then generate_range_gb18030_read;
      if (offsets_gb18030 = nil) then generate_offsets_gb18030;
    end;
    ENC_GB2312:
    begin
      FCallbacks.Reader := @TTextConvContext.gb2312_reader;
      if (table_gb2312 = nil) then generate_table_gb2312;
      if (table_gbkext1 = nil) then generate_table_gbkext1;
      if (table_gbkext2 = nil) then generate_table_gbkext2;
    end;
    ENC_HZGB2312:
    begin
      F.Flags := F.Flags or FLAG_SRC_STATE_NEEDED;
      FCallbacks.Reader := @TTextConvContext.hzgb2312_reader;
      if (table_gb2312 = nil) then generate_table_gb2312;
    end;
    ENC_BIG5:
    begin
      FCallbacks.Reader := @TTextConvContext.big5_reader;
      if (table_big5 = nil) then generate_table_big5;
    end;
    ENC_SHIFT_JIS:
    begin
      FCallbacks.Reader := @TTextConvContext.shift_jis_reader;
      if (table_jisx0208 = nil) then generate_table_jisx0208;
    end;
    ENC_EUC_JP:
    begin
      FCallbacks.Reader := @TTextConvContext.euc_jp_reader;
      if (table_jisx0208 = nil) then generate_table_jisx0208;
      if (table_jisx0212 = nil) then generate_table_jisx0212;
    end;
    ENC_ISO2022JP:
    begin
      F.Flags := F.Flags or FLAG_SRC_STATE_NEEDED;
      FCallbacks.Reader := @TTextConvContext.iso2022jp_reader;
      if (table_jisx0208 = nil) then generate_table_jisx0208;
      if (table_jisx0212 = nil) then generate_table_jisx0212;
    end;
    ENC_CP949:
    begin
      FCallbacks.Reader := @TTextConvContext.cp949_reader;
      if (table_ksc5601 = nil) then generate_table_ksc5601;
      if (table_uhc_1 = nil) then generate_table_uhc_1;
      if (table_uhc_2 = nil) then generate_table_uhc_2;
    end;
    ENC_EUC_KR:
    begin
      FCallbacks.Reader := @TTextConvContext.euc_kr_reader;
      if (table_ksc5601 = nil) then generate_table_ksc5601;
    end;
  end;

  // writers
  case (DestinationEncoding and ENCODING_MASK) of
    ENC_SBCS:
    begin
      SBCS := @TEXTCONV_SUPPORTED_SBCS[DestinationEncoding shr 8];
      F.DestinationCodePage := SBCS.CodePage;
      FCallbacks.Writer := SBCS.FVALUES;
      if (FCallbacks.Writer = nil) then FCallbacks.Writer := SBCS.AllocFillVALUES(SBCS.FVALUES);
      FCallbacks.Convertible := NativeInt(FCallbacks.Writer);
    end;
    ENC_UTF1:
    begin
      FCallbacks.Writer := @TTextConvContext.utf1_writer;
      FCallbacks.Convertible := 0;
    end;
    ENC_UTF7:
    begin
      F.Flags := F.Flags or (FLAG_DEST_STATE_NEEDED or FLAG_DEST_MARGIN_NEEDED);
      FCallbacks.Writer := @TTextConvContext.utf7_writer;
      FCallbacks.Convertible := 0;
    end;
    ENC_UTFEBCDIC:
    begin
      FCallbacks.Writer := @TTextConvContext.utf_ebcdic_writer;
      FCallbacks.Convertible := 0;
    end;
    ENC_SCSU:
    begin
      F.Flags := F.Flags or FLAG_DEST_STATE_NEEDED;
      FCallbacks.Writer := @TTextConvContext.scsu_writer;
      FCallbacks.Convertible := 0;
    end;
    ENC_BOCU1:
    begin
      F.Flags := F.Flags or FLAG_DEST_STATE_NEEDED;
      FCallbacks.Writer := @TTextConvContext.bocu1_writer;
      FCallbacks.Convertible := 0;
    end;
    ENC_GB18030:
    begin
      FCallbacks.Writer := @TTextConvContext.gb18030_writer;
      FCallbacks.Convertible := -NativeInt(@TTextConvContext.gb18030_convertible);
      if (hash_gb2312 = nil) then generate_hash_gb2312;
      if (hash_gbkext1 = nil) then generate_hash_gbkext1;
      if (hash_gbkext2 = nil) then generate_hash_gbkext2;
      if (hash_gb18030ext = nil) then generate_hash_gb18030ext;
      if (range_gb18030_write = nil) then generate_range_gb18030_write;
      if (offsets_gb18030 = nil) then generate_offsets_gb18030;
    end;
    ENC_GB2312:
    begin
      FCallbacks.Writer := @TTextConvContext.gb2312_writer;
      FCallbacks.Convertible := -NativeInt(@TTextConvContext.gb2312_convertible);
      if (hash_gb2312 = nil) then generate_hash_gb2312;
      if (hash_gbkext1 = nil) then generate_hash_gbkext1;
      if (hash_gbkext2 = nil) then generate_hash_gbkext2;
    end;
    ENC_HZGB2312:
    begin
      F.Flags := F.Flags or (FLAG_DEST_STATE_NEEDED or FLAG_DEST_MARGIN_NEEDED);
      FCallbacks.Writer := @TTextConvContext.hzgb2312_writer;
      FCallbacks.Convertible := -NativeInt(@TTextConvContext.hzgb2312_convertible);
      if (hash_gb2312 = nil) then generate_hash_gb2312;
    end;
    ENC_BIG5:
    begin
      FCallbacks.Writer := @TTextConvContext.big5_writer;
      FCallbacks.Convertible := -NativeInt(@TTextConvContext.big5_convertible);
      if (hash_big5 = nil) then generate_hash_big5;
    end;
    ENC_SHIFT_JIS:
    begin
      FCallbacks.Writer := @TTextConvContext.shift_jis_writer;
      FCallbacks.Convertible := -NativeInt(@TTextConvContext.shift_jis_convertible);
      if (hash_jisx0208 = nil) then generate_hash_jisx0208;
    end;
    ENC_EUC_JP:
    begin
      FCallbacks.Writer := @TTextConvContext.euc_jp_writer;
      FCallbacks.Convertible := -NativeInt(@TTextConvContext.euc_jp_convertible);
      if (hash_jisx0208 = nil) then generate_hash_jisx0208;
      if (hash_jisx0212 = nil) then generate_hash_jisx0212;
    end;
    ENC_ISO2022JP:
    begin
      F.Flags := F.Flags or (FLAG_DEST_STATE_NEEDED or FLAG_DEST_MARGIN_NEEDED);
      FCallbacks.Writer := @TTextConvContext.iso2022jp_writer;
      FCallbacks.Convertible := -NativeInt(@TTextConvContext.iso2022jp_convertible);
      if (hash_jisx0208 = nil) then generate_hash_jisx0208;
      if (hash_jisx0212 = nil) then generate_hash_jisx0212;
    end;
    ENC_CP949:
    begin
      FCallbacks.Writer := @TTextConvContext.cp949_writer;
      FCallbacks.Convertible := -NativeInt(@TTextConvContext.cp949_convertible);
      if (hash_ksc5601 = nil) then generate_hash_ksc5601;
      if (hash_uhc_1 = nil) then generate_hash_uhc_1;
      if (hash_uhc_2 = nil) then generate_hash_uhc_2;
    end;
    ENC_EUC_KR:
    begin
      FCallbacks.Writer := @TTextConvContext.euc_kr_writer;
      FCallbacks.Convertible := -NativeInt(@TTextConvContext.euc_kr_convertible);
      if (hash_ksc5601 = nil) then generate_hash_ksc5601;
    end;
  end;
end;

procedure TTextConvContext.Init(const ADestinationBOM, ASourceBOM: TBOM;
  const SBCSCodePage: Word; const ACharCase: TCharCase);
var
  DestinationEncoding: Cardinal;
  SourceEncoding: Cardinal;
  SBCS: PTextConvSBCS;
  {$ifdef CPUX86}
  Store: record
    SBCS: PTextConvSBCS;
  end;
  {$endif}
begin
  // fast most frequently used conversions
  DestinationEncoding := Byte(ADestinationBOM);
  SourceEncoding := Byte(ASourceBOM);
  if (DestinationEncoding or SourceEncoding <= ENC_UTF16) then
  begin
    case (DestinationEncoding * 3 + SourceEncoding) of
      0: InitSBCSFromSBCS(SBCSCodePage, SBCSCodePage, ACharCase);
      1: InitSBCSFromUTF8(SBCSCodePage, ACharCase);
      2: InitSBCSFromUTF16(SBCSCodePage, ACharCase);
      3: InitUTF8FromSBCS(SBCSCodePage, ACharCase);
      4: InitUTF8FromUTF8(ACharCase);
      5: InitUTF8FromUTF16(ACharCase);
      6: InitUTF16FromSBCS(SBCSCodePage, ACharCase);
      7: InitUTF16FromUTF8(ACharCase);
    else
    //8:
      InitUTF16FromUTF16(ACharCase);
    end;

    Exit;
  end;

  // store code pages
  F.DestinationCodePage := BOM_INFO[TBOM(DestinationEncoding)].CodePage;
  F.SourceCodePage := BOM_INFO[TBOM(SourceEncoding)].CodePage;

  // SBCS
  {$ifdef CPUX86}Store.{$endif}SBCS := TextConvSBCS(SBCSCodePage);

  // state, flags and conversion
  FState.WR := 0;
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (DestinationEncoding shl ENCODING_DESTINATION_OFFSET) + SourceEncoding;
  if (DestinationEncoding = SourceEncoding) and (ACharCase = ccOriginal) then
  begin
    if (DestinationEncoding and ENCODING_MASK = 0) then
    begin
      F.DestinationCodePage := {$ifdef CPUX86}Store.{$endif}SBCS.CodePage;
      F.SourceCodePage := F.DestinationCodePage;
    end;
    FConvertProc := Pointer(@TTextConvContext.convert_copy);
    Exit;
  end else
  begin
    FConvertProc := Pointer(@TTextConvContext.convert_universal);
  end;

  // readers
  case (SourceEncoding) of
    ENC_SBCS:
    begin
      {$ifdef CPUX86}SBCS := Store.SBCS;{$endif}
      F.SourceCodePage := SBCS.CodePage;
      FCallbacks.Reader := SBCS.FUCS2.Items[F.CharCase];
      if (FCallbacks.Reader = nil) then FCallbacks.Reader := SBCS.AllocFillUCS2(SBCS.FUCS2.Items[F.CharCase], F.CharCase);
    end;
    ENC_UTF1:
    begin
      FCallbacks.Reader := @TTextConvContext.utf1_reader;
    end;
    ENC_UTF7:
    begin
      F.Flags := F.Flags or FLAG_SRC_STATE_NEEDED;
      FCallbacks.Reader := @TTextConvContext.utf7_reader;
    end;
    ENC_UTFEBCDIC:
    begin
      FCallbacks.Reader := @TTextConvContext.utf_ebcdic_reader;
    end;
    ENC_SCSU:
    begin
      F.Flags := F.Flags or FLAG_SRC_STATE_NEEDED;
      FCallbacks.Reader := @TTextConvContext.scsu_reader;
    end;
    ENC_BOCU1:
    begin
      F.Flags := F.Flags or FLAG_SRC_STATE_NEEDED;
      FCallbacks.Reader := @TTextConvContext.bocu1_reader;
    end;
    ENC_GB18030:
    begin
      FCallbacks.Reader := @TTextConvContext.gb18030_reader;
      if (table_gb2312 = nil) then generate_table_gb2312;
      if (table_gbkext1 = nil) then generate_table_gbkext1;
      if (table_gbkext2 = nil) then generate_table_gbkext2;
      if (table_gb18030ext = nil) then generate_table_gb18030ext;
      if (range_gb18030_read = nil) then generate_range_gb18030_read;
      if (offsets_gb18030 = nil) then generate_offsets_gb18030;
    end;
  end;

  // writers
  case (DestinationEncoding) of
    ENC_SBCS:
    begin
      {$ifdef CPUX86}SBCS := Store.SBCS;{$endif}
      F.DestinationCodePage := SBCS.CodePage;
      FCallbacks.Writer := SBCS.FVALUES;
      if (FCallbacks.Writer = nil) then FCallbacks.Writer := SBCS.AllocFillVALUES(SBCS.FVALUES);
      FCallbacks.Convertible := NativeInt(FCallbacks.Writer);
    end;
    ENC_UTF1:
    begin
      FCallbacks.Writer := @TTextConvContext.utf1_writer;
      FCallbacks.Convertible := 0;
    end;
    ENC_UTF7:
    begin
      F.Flags := F.Flags or (FLAG_DEST_STATE_NEEDED or FLAG_DEST_MARGIN_NEEDED);
      FCallbacks.Writer := @TTextConvContext.utf7_writer;
      FCallbacks.Convertible := 0;
    end;
    ENC_UTFEBCDIC:
    begin
      FCallbacks.Writer := @TTextConvContext.utf_ebcdic_writer;
      FCallbacks.Convertible := 0;
    end;
    ENC_SCSU:
    begin
      F.Flags := F.Flags or FLAG_DEST_STATE_NEEDED;
      FCallbacks.Writer := @TTextConvContext.scsu_writer;
      FCallbacks.Convertible := 0;
    end;
    ENC_BOCU1:
    begin
      F.Flags := F.Flags or FLAG_DEST_STATE_NEEDED;
      FCallbacks.Writer := @TTextConvContext.bocu1_writer;
      FCallbacks.Convertible := 0;
    end;
    ENC_GB18030:
    begin
      FCallbacks.Writer := @TTextConvContext.gb18030_writer;
      FCallbacks.Convertible := -NativeInt(@TTextConvContext.gb18030_convertible);
      if (hash_gb2312 = nil) then generate_hash_gb2312;
      if (hash_gbkext1 = nil) then generate_hash_gbkext1;
      if (hash_gbkext2 = nil) then generate_hash_gbkext2;
      if (hash_gb18030ext = nil) then generate_hash_gb18030ext;
      if (range_gb18030_write = nil) then generate_range_gb18030_write;
      if (offsets_gb18030 = nil) then generate_offsets_gb18030;
    end;
  end;
end;

procedure TTextConvContext.InitSBCSFromSBCS(const ADestinationCodePage,
  ASourceCodePage: Word; const ACharCase: TCharCase);
var
  DestinationSBCS: PTextConvSBCS;
  SourceSBCS: PTextConvSBCS;
begin
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (ENC_SBCS shl ENCODING_DESTINATION_OFFSET) + ENC_SBCS;
  FConvertProc := Pointer(@TTextConvContext.convert_sbcs_from_sbcs);
  FCallbacks.Convertible := -NativeInt(@TTextConvContext.sbcs_convertible);

  DestinationSBCS := TextConvSBCS(ADestinationCodePage);
  SourceSBCS := TextConvSBCS(ASourceCodePage);
  F.DestinationCodePage := DestinationSBCS.CodePage;
  F.SourceCodePage := SourceSBCS.CodePage;

  case Self.CharCase of
    ccLower:
    begin
      FCallbacks.Converter := DestinationSBCS.FromSBCS(SourceSBCS, ccLower);
      FCallbacks.ReaderWriter := @sbcs_from_sbcs_lower;
    end;
    ccUpper:
    begin
      FCallbacks.Converter := DestinationSBCS.FromSBCS(SourceSBCS, ccUpper);
      FCallbacks.ReaderWriter := @sbcs_from_sbcs_upper;
    end;
  else
    // ccOriginal:
    if (DestinationSBCS = SourceSBCS) then
    begin
      FConvertProc := Pointer(@TTextConvContext.convert_copy);
    end else
    begin
      FCallbacks.Converter := DestinationSBCS.FromSBCS(SourceSBCS, ccOriginal);
      FCallbacks.ReaderWriter := @sbcs_from_sbcs;
    end;
  end;
end;

procedure TTextConvContext.InitSBCSFromUTF16(const ADestinationCodePage: Word;
  const ACharCase: TCharCase);
var
  SBCS: PTextConvSBCS;
begin
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (ENC_SBCS shl ENCODING_DESTINATION_OFFSET) + ENC_UTF16;
  FConvertProc := Pointer(@TTextConvContext.convert_sbcs_from_utf16);
  FCallbacks.Convertible := -NativeInt(@TTextConvContext.sbcs_convertible);

  SBCS := TextConvSBCS(ADestinationCodePage);
  F.DestinationCodePage := SBCS.CodePage;
  F.SourceCodePage := CODEPAGE_UTF16;
  FCallbacks.Converter := SBCS.VALUES;

  case Self.CharCase of
    ccLower:
    begin
      FCallbacks.ReaderWriter := @sbcs_from_utf16_lower;
    end;
    ccUpper:
    begin
      FCallbacks.ReaderWriter := @sbcs_from_utf16_upper;
    end;
  else
    // ccOriginal:
    FCallbacks.ReaderWriter := @sbcs_from_utf16;
  end;
end;

procedure TTextConvContext.InitSBCSFromUTF8(const ADestinationCodePage: Word;
  const ACharCase: TCharCase);
var
  SBCS: PTextConvSBCS;
begin
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (ENC_SBCS shl ENCODING_DESTINATION_OFFSET) + ENC_UTF8;
  FConvertProc := Pointer(@TTextConvContext.convert_sbcs_from_utf8);
  FCallbacks.Convertible := -NativeInt(@TTextConvContext.sbcs_convertible);

  SBCS := TextConvSBCS(ADestinationCodePage);
  F.DestinationCodePage := SBCS.CodePage;
  F.SourceCodePage := CODEPAGE_UTF8;
  FCallbacks.Converter := SBCS.VALUES;

  case Self.CharCase of
    ccLower:
    begin
      FCallbacks.ReaderWriter := @sbcs_from_utf8_lower;
    end;
    ccUpper:
    begin
      FCallbacks.ReaderWriter := @sbcs_from_utf8_upper;
    end;
  else
    // ccOriginal:
    FCallbacks.ReaderWriter := @sbcs_from_utf8;
  end;
end;

procedure TTextConvContext.InitUTF16FromSBCS(const ASourceCodePage: Word;
  const ACharCase: TCharCase);
var
  SBCS: PTextConvSBCS;
begin
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (ENC_UTF16 shl ENCODING_DESTINATION_OFFSET) + ENC_SBCS;
  FConvertProc := Pointer(@TTextConvContext.convert_utf16_from_sbcs);
  FCallbacks.Convertible := 0;

  SBCS := TextConvSBCS(ASourceCodePage);
  F.DestinationCodePage := CODEPAGE_UTF16;
  F.SourceCodePage := SBCS.CodePage;

  case Self.CharCase of
    ccLower:
    begin
      FCallbacks.Converter := SBCS.LowerCaseUCS2;
      FCallbacks.ReaderWriter := @utf16_from_sbcs_lower;
    end;
    ccUpper:
    begin
      FCallbacks.Converter := SBCS.UpperCaseUCS2;
      FCallbacks.ReaderWriter := @utf16_from_sbcs_upper;
    end;
  else
    // ccOriginal:
    FCallbacks.Converter := SBCS.UCS2;
    FCallbacks.ReaderWriter := @utf16_from_sbcs;
  end;
end;

procedure TTextConvContext.InitUTF16FromUTF16(const ACharCase: TCharCase);
begin
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (ENC_UTF16 shl ENCODING_DESTINATION_OFFSET) + ENC_UTF16;
  FConvertProc := Pointer(@TTextConvContext.convert_utf16_from_utf16);
  FCallbacks.Convertible := 0;

  F.DestinationCodePage := CODEPAGE_UTF16;
  F.SourceCodePage := CODEPAGE_UTF16;
  case Self.CharCase of
    ccLower:
    begin
      FCallbacks.ReaderWriter := @utf16_from_utf16_lower;
    end;
    ccUpper:
    begin
      FCallbacks.ReaderWriter := @utf16_from_utf16_upper;
    end;
  else
    // ccOriginal:
    FConvertProc := Pointer(@TTextConvContext.convert_copy);
  end;
end;

procedure TTextConvContext.InitUTF16FromUTF8(const ACharCase: TCharCase);
begin
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (ENC_UTF16 shl ENCODING_DESTINATION_OFFSET) + ENC_UTF8;
  FConvertProc := Pointer(@TTextConvContext.convert_utf16_from_utf8);
  FCallbacks.Convertible := 0;

  F.DestinationCodePage := CODEPAGE_UTF16;
  F.SourceCodePage := CODEPAGE_UTF8;
  case Self.CharCase of
    ccLower:
    begin
      FCallbacks.ReaderWriter := @utf16_from_utf8_lower;
    end;
    ccUpper:
    begin
      FCallbacks.ReaderWriter := @utf16_from_utf8_upper;
    end;
  else
    // ccOriginal:
    FCallbacks.ReaderWriter := @utf16_from_utf8;
  end;
end;

procedure TTextConvContext.InitUTF8FromSBCS(const ASourceCodePage: Word;
  const ACharCase: TCharCase);
var
  SBCS: PTextConvSBCS;
begin
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (ENC_UTF8 shl ENCODING_DESTINATION_OFFSET) + ENC_SBCS;
  FConvertProc := Pointer(@TTextConvContext.convert_utf8_from_sbcs);
  FCallbacks.Convertible := 0;

  SBCS := TextConvSBCS(ASourceCodePage);
  F.DestinationCodePage := CODEPAGE_UTF8;
  F.SourceCodePage := SBCS.CodePage;
  case Self.CharCase of
    ccLower:
    begin
      FCallbacks.Converter := SBCS.LowerCaseUTF8;
      FCallbacks.ReaderWriter := @utf8_from_sbcs_lower;
    end;
    ccUpper:
    begin
      FCallbacks.Converter := SBCS.UpperCaseUTF8;
      FCallbacks.ReaderWriter := @utf8_from_sbcs_upper;
    end;
  else
    // ccOriginal:
    FCallbacks.Converter := SBCS.UTF8;
    FCallbacks.ReaderWriter := @utf8_from_sbcs;
  end;
end;

procedure TTextConvContext.InitUTF8FromUTF16(const ACharCase: TCharCase);
begin
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (ENC_UTF8 shl ENCODING_DESTINATION_OFFSET) + ENC_UTF16;
  FConvertProc := Pointer(@TTextConvContext.convert_utf8_from_utf16);
  FCallbacks.Convertible := 0;

  F.DestinationCodePage := CODEPAGE_UTF8;
  F.SourceCodePage := CODEPAGE_UTF16;
  case Self.CharCase of
    ccLower:
    begin
      FCallbacks.ReaderWriter := @utf8_from_utf16_lower;
    end;
    ccUpper:
    begin
      FCallbacks.ReaderWriter := @utf8_from_utf16_upper;
    end;
  else
    // ccOriginal:
    FCallbacks.ReaderWriter := @utf8_from_utf16;
  end;
end;

procedure TTextConvContext.InitUTF8FromUTF8(const ACharCase: TCharCase);
begin
  F.Flags := CHARCASE_FLAGS[ACharCase] +
    (ENC_UTF8 shl ENCODING_DESTINATION_OFFSET) + ENC_UTF8;
  FConvertProc := Pointer(@TTextConvContext.convert_utf8_from_utf8);
  FCallbacks.Convertible := 0;

  F.DestinationCodePage := CODEPAGE_UTF8;
  F.SourceCodePage := CODEPAGE_UTF8;
  case Self.CharCase of
    ccLower:
    begin
      FCallbacks.ReaderWriter := @utf8_from_utf8_lower;
    end;
    ccUpper:
    begin
      FCallbacks.ReaderWriter := @utf8_from_utf8_upper;
    end;
  else
    // ccOriginal:
    FConvertProc := Pointer(@TTextConvContext.convert_copy);
  end;
end;

function TTextConvContext.Convert: NativeInt;
{$ifdef INLINESUPPORT}
begin
  Result := FConvertProc(@Self);
end;
{$else .CPUX86.DELPHI}
asm
  jmp [EAX].TTextConvContext.FConvertProc
end;
{$endif}

function TTextConvContext.Convert(const ADestination: Pointer;
                                 const ADestinationSize: NativeUInt;
                                 const ASource: Pointer;
                                 const ASourceSize: NativeUInt): NativeInt;
{$if (Defined(INLINESUPPORT)) or (not Defined(CPUX86))}
begin
  FDestination := ADestination;
  FDestinationSize := ADestinationSize;
  FSource := ASource;
  FSourceSize := ASourceSize;
  Result := FConvertProc(@Self);
end;
{$else .CPUX86.DELPHI}
asm
  mov [EAX].TTextConvContext.FDestination, edx
  mov [EAX].TTextConvContext.FDestinationSize, ecx
  mov edx, ASource
  mov ecx, ASourceSize
  mov [EAX].TTextConvContext.FSource, edx
  mov [EAX].TTextConvContext.FSourceSize, ecx

  mov edx, [ebp+4] // ret
  mov ebp, [esp]
  mov [esp+12], edx
  add esp, 12

  jmp [EAX].TTextConvContext.FConvertProc
end;
{$ifend}

function TTextConvContext.Convert(const ADestination: Pointer;
                                 const ADestinationSize: NativeUInt;
                                 const ASource: Pointer;
                                 const ASourceSize: NativeUInt;
                                 out ADestinationWritten: NativeUInt;
                                 out ASourceRead: NativeUInt): NativeInt;
begin
  FDestination := ADestination;
  FDestinationSize := ADestinationSize;
  FSource := ASource;
  FSourceSize := ASourceSize;
  Result := FConvertProc(@Self);

  ADestinationWritten := FDestinationWritten;
  ASourceRead := FSourceRead;
end;


function TTextConvContext.Convertible(const C: UCS4Char): Boolean;
label
  standard_way, ret_false, ret_true;
var
  X, Y: NativeUInt;
  Callback: NativeInt;
begin
  X := C;
  if (C < $7e) then
  begin
    if ((C + $25) and $3C = 0) then goto standard_way; // catch $5c(shift_jis) or $1b(iso-2022-jp)
  {$ifdef INLINESUPPORT}
    goto ret_true;
  {$else}
  ret_true:
    Result := True;
    Exit;
  ret_false:
    Result := False;
    Exit;
  {$endif}
  end else
  begin
    case (C shr 11) of
      0..$1B-1,
      $1B+1..(UNICODE_CHARACTERS_COUNT shr 11)-1: {goto standard_way};
    else
      goto ret_false;
    end;

  standard_way:
    Callback := FCallbacks.Convertible;
    if (Callback = 0{Unicode}) then goto ret_true;
    if (Callback > 0) then
    begin
      if (X > $ffff) then goto ret_false;

      Y := PTextConvBW(Callback)^[X];
      Inc(Callback, $10000);
      Result := (PTextConvWB(Callback)[Y] = X);
      Exit;
    end else
    begin
      Callback := -Callback;
      Result := call_convertible(X, Pointer(Callback));
      Exit;
    end;
  end;

{$ifdef INLINESUPPORT}
ret_false:
  Result := False;
  Exit;
ret_true:
  Result := True;
{$endif}
end;

function TTextConvContext.Convertible(const C: UnicodeChar): Boolean;
label
  standard_way, ret_false, ret_true;
var
  X, Y: NativeUInt;
  Callback: NativeInt;
begin
  X := Word(C);
  if (C < #$7e) then
  begin
    if ((X + $25) and $3C = 0) then goto standard_way; // catch $5c(shift_jis) or $1b(iso-2022-jp)
  {$ifdef INLINESUPPORT}
    goto ret_true;
  {$else}
  ret_true:
    Result := True;
    Exit;
  ret_false:
    Result := False;
    Exit;
  {$endif}
  end else
  begin
    case Ord(C) of
      $d800..$e000-1: goto ret_false;
    end;

  standard_way:
    Callback := FCallbacks.Convertible;
    if (Callback = 0{Unicode}) then goto ret_true;
    if (Callback > 0) then
    begin
      Y := PTextConvBW(Callback)^[X];
      Inc(Callback, $10000);
      Result := (PTextConvWB(Callback)[Y] = X);
      Exit;
    end else
    begin
      Callback := -Callback;
      Result := call_convertible(X, Pointer(Callback));
      Exit;
    end;
  end;

{$ifdef INLINESUPPORT}
ret_false:
  Result := False;
  Exit;
ret_true:
  Result := True;
{$endif}
end;

function TTextConvContext.call_convertible(X: NativeUInt; Callback: Pointer): Boolean;
{$if Defined(CPUX86ASM)} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  jmp ecx
end;
{$elseif Defined(CPUX64ASM)} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  {$ifdef POSIX}
    jmp rdi
  {$else}
    jmp r8
  {$endif}
end;
{$else .POSIX}
type
  TCallback = function(const Context: PTextConvContext; X: NativeUInt): Boolean;
begin
  Result := TCallback(Callback)(@Self, X);
end;
{$ifend}

function TTextConvContext.sbcs_convertible(X: NativeUInt): Boolean;
begin
  FCallbacks.Convertible := NativeInt(TextConvSBCS(F.DestinationCodePage).VALUES);
  Result := Self.Convertible(X);
end;

function TTextConvContext.convert_copy: NativeInt;
var
  Src, Dest: PByte;
  SrcSize, DestSize: NativeUInt;
  Size, S: NativeUInt;
begin
  SrcSize := Self.SourceSize;
  DestSize := Self.DestinationSize;

  if (DestSize >= SrcSize) then
  begin
    Size := SrcSize;
    Result := 0;
  end else
  begin
    Size := DestSize;
    Result := {remaining source bytes}(SrcSize - DestSize);
  end;
  Self.FSourceRead := Size;
  Self.FDestinationWritten := Size;

  if (Size <> 0) then
  begin
    Src := Self.Source;
    Dest := Self.Destination;

    repeat
      S := Size;
      if (S > NativeUInt(High(Integer))) then S := NativeUInt(High(Integer));
      TinyMove(Src^, Dest^, S);

      Dec(Size, S);
      Inc(Src, S);
      Inc(Dest, S);
    until (Size = 0);
  end;
end;

// Universal(basic) conversion way
// (SourceEncoding)SourceSBTable/SourceProc/inline -->
// [CharCase] -->
// (DestinationEncoding)DestinationSBTable/DestinationProc/inline
function TTextConvContext.convert_universal: NativeInt;
label
  char_read_normal, char_read, char_read_unknown, char_read_done, char_read_small,
  char_write, dest_too_small, convert_finish;
type
  TReaderProc = function(Context: PTextConvContext; SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
  TWriterProc = function(Context: PTextConvContext; X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
const
  FLAG_DEST_ALREADY_FINALIZED = 1 shl (ENCODING_DESTINATION_OFFSET - 1);
var
  Dest, Src: PByte;
  SrcSize: NativeUInt;

  Flags: NativeUInt;
  X, Y: NativeUInt;
  DestSize: NativeUInt;

  FStore: record
    DestTop: Pointer;
    StoredDest, StoredSrc: Pointer;

    {$ifdef CPUX86}
    Dest, Src: Pointer;
    Reader: Pointer;
    Writer: Pointer;
    {$endif}

    SrcRead: Cardinal;

    {$ifdef CPUX86}
    Self: PTextConvContext;
    {$endif}

    case Integer of
      0: (Write, Read: packed record
          case Integer of
            0: (I: Integer);
            1: (D: Cardinal);
            2: (B: Byte);
            3: (Bytes: array[0..3] of Byte);
          end);
      1: (WR: Int64; ScsuReadWindows: array[0..7] of Cardinal);
  end;

  {$ifdef CPUX86}
  _Self: PTextConvContext;
  {$endif}
begin
  Src := Self.Source;
  SrcSize := Self.SourceSize;
  Dest := Self.Destination;
  Flags := Self.F.Flags;
  FStore.DestTop := Pointer(NativeUInt(Dest) + Self.DestinationSize);

  {$ifdef CPUX86}
  FStore.Reader := Self.FCallbacks.Reader;
  FStore.Writer := Self.FCallbacks.Writer;
  {$endif}

  FStore.StoredDest := Dest;
  FStore.StoredSrc := Src;
  FStore.WR := Self.FState.WR;
  {$ifdef CPUX86}
  FStore.Self := @Self;
  {$endif}

  if (SrcSize < 4) then goto char_read_small;
char_read_normal:
  // fill X as 4 Bytes from source
  X := PCardinal(Src)^;

char_read:
  case {SourceEncoding}(Flags and ENCODING_MASK) of
    ENC_SBCS{Single-byte: AnsiChar, AnsiString}:
    begin
      // don't need to compare source size
      // automatically char case conversion
      X := PTextConvWB({$ifdef CPUX86}FStore.Reader{$else}Self.FCallbacks.Reader{$endif})[Byte(X)];
      Inc(Src, 1);
      Dec(SrcSize, 1);
      goto char_write;
    end;
    ENC_UTF8{UTF8Char, UTF8String}:
    begin
      if (X and $80 = 0) then
      begin
        Inc(Src, 1);
        Dec(SrcSize, 1);
        X := Byte(X);
        goto char_read_done;
      end else
      if (X and $C0E0 = $80C0) then
      begin
        // X := ((X and $1F) shl 6) or ((X shr 8) and $3F);
        Y := X;
        X := X and $1F;
        Dec(SrcSize, 2);
        Y := Y shr 8;
        Inc(Src, 2);
        X := X shl 6;
        Y := Y and $3F;
        Inc(X, Y);
        if (NativeInt(SrcSize) < 0) then goto convert_finish;
        goto char_read_done;
      end else
      begin
        Y := TEXTCONV_UTF8CHAR_SIZE[Byte(X)];
        Dec(SrcSize, Y);
        Inc(Src, Y);
        if (NativeInt(SrcSize) < 0) then goto convert_finish;
        case Y of
          0: begin
               Inc(Src, 1);
               Dec(SrcSize, 1);
               goto char_read_unknown;
             end;
          3: begin
               if (X and $C0C000 = $808000) then
               begin
                  // X := ((X & 0x0f) << 12) | ((X & 0x3f00) >> 2) | ((X >> 16) & 0x3f);
                 Y := (X and $0F) shl 12;
                 Y := Y + (X shr 16) and $3F;
                 X := (X and $3F00) shr 2;
                 Inc(X, Y);
                 goto char_read_done;
               end else
               begin
                 goto char_read_unknown;
               end;
             end;
          4: begin
               if (X and $C0C0C000 = $80808000) then
               begin
                 // X := (X&07)<<18 | (X&3f00)<<4 | (X>>10)&0fc0 | (X>>24)&3f;
                 Y := (X and $07) shl 18;
                 Y := Y + (X and $3f00) shl 4;
                 Y := Y + (X shr 10) and $0fc0;
                 X := (X shr 24) and $3f;
                 Inc(X, Y);
               end else
               begin
                 goto char_read_unknown;
               end;
             end;
        else
          goto char_read_unknown;
        end;
      end;
    end;
    ENC_UTF16{WideChar, WideString, UnicodeString}:
    begin
      Y := Word(X);
      Dec(SrcSize, 2);
      Inc(Src, 2);
      Dec(Y, $d800);
      if (NativeInt(SrcSize) < 0) then goto convert_finish;

      //if (Word(X) >= $d800) and (Word(X) < $dc00) then
      if (Y < ($dc00-$d800)) then
      begin
        X := X shr 16;
        Dec(SrcSize, 2);
        Inc(Src, 2);
        Dec(X, $dc00);
        if (NativeInt(SrcSize) < 0) then goto convert_finish;

        //if (X >= $dc00) and (X < $e000) then
        if (X < ($e000-$dc00)) then
        begin
          // X := $10000 + ((Word(baseX) - $d800) shl 10) + ((baseX shr 16) - $dc00);
          Y := Y shl 10;
          Inc(X, $10000);
          Inc(X, Y);
        end else
        begin
          goto char_read_unknown;
        end;
      end else
      begin
        //if (Word(X) >= $dc00) and (Word(X) < $e000) then
        Dec(Y, ($dc00-$d800));
        if (Y < ($e000-$dc00)) then goto char_read_unknown;
        X := Word(X);
        goto char_read_done;
      end;
    end;
    ENC_UTF16BE:
    begin
      Y := Word(X);
      Dec(SrcSize, 2);
      Y := Swap(Y);
      Inc(Src, 2);
      Dec(Y, $d800);
      if (NativeInt(SrcSize) < 0) then goto convert_finish;

      //if (Word(X) >= $d800) and (Word(X) < $dc00) then
      if (Y < ($dc00-$d800)) then
      begin
        X := X shr 16;
        Dec(SrcSize, 2);
        X := Swap(X);
        Inc(Src, 2);
        Dec(X, $dc00);
        if (NativeInt(SrcSize) < 0) then goto convert_finish;

        //if (X >= $dc00) and (X < $e000) then
        if (X < ($e000-$dc00)) then
        begin
          // X := $10000 + ((Word(baseX) - $d800) shl 10) + ((baseX shr 16) - $dc00);
          Y := Y shl 10;
          Inc(X, $10000);
          Inc(X, Y);
        end else
        begin
          goto char_read_unknown;
        end;
      end else
      begin
        //if (Word(X) >= $dc00) and (Word(X) < $e000) then
        Dec(Y, ($dc00-$d800));
        if (Y < ($e000-$dc00)) then goto char_read_unknown;
        X := Word(X);
        X := Swap(X);
        goto char_read_done;
      end;
    end;
    ENC_UTF32:
    begin
      {none}
      Dec(SrcSize, 4);
      Inc(Src, 4);
      if (NativeInt(SrcSize) < 0) then goto convert_finish;
    end;
    ENC_UTF32BE:
    begin
      // 0123 --> 3210
      // X := (Swap(X){32} shl 16) or Swap(X shr 16){10};
      Y := X shr 16;
      X := Swap(X);
      Dec(SrcSize, 4);
      Y := Swap(Y);
      X := X shl 16;
      Inc(Src, 4);
      Inc(X, Y);
      if (NativeInt(SrcSize) < 0) then goto convert_finish;
    end;
    ENC_UCS2143:
    begin
      // 1032 --> 3210
      // X := (X shr 16) or (X shl 16);
      Y := X shr 16;
      X := X shl 16;
      Dec(SrcSize, 4);
      Inc(Src, 4);
      Inc(X, Y);
      if (NativeInt(SrcSize) < 0) then goto convert_finish;
    end;
    ENC_UCS3412:
    begin
      // 2301 --> 3210
      // X := (Swap(X shr 16){32} shl 16) or Swap(X);
      Y := X shr 16;
      X := Swap(X);
      Dec(SrcSize, 4);
      Y := Swap(Y) shl 16;
      X := Word(X);
      Inc(Src, 4);
      Inc(X, Y);
      if (NativeInt(SrcSize) < 0) then goto convert_finish;
    end;
  else
    // Multy-byte encoding callback
    {$ifdef CPUX86}
    FStore.Dest := Dest;
    FStore.Src := Src;
    {$endif}
      FStore.SrcRead := 0;
      X := TReaderProc({$ifdef CPUX86}FStore.Reader{$else}Self.FCallbacks.Reader{$endif})({$ifdef CPUX86}FStore.Self{$else}@Self{$endif}, SrcSize, Src, FStore.SrcRead);
    {$ifdef CPUX86}
    Dest := FStore.Dest;
    Src := FStore.Src;
    {$endif}
    Y := FStore.SrcRead;
    if (Integer(Cardinal(Y)) < 0) then
    begin
      // read none
      Inc(Src, SrcSize);
      SrcSize := 0;
      FStore.StoredSrc := Src;
      goto convert_finish;
    end;
    Dec(SrcSize, Y);
    Inc(Src, Y);
    if (NativeInt(SrcSize) < 0) then goto convert_finish;
  end;

  // decoded char range check
  if (X >= UNICODE_CHARACTERS_COUNT) then
  begin
char_read_unknown:
    X := UNKNOWN_CHARACTER;
    goto char_write;
  end;
char_read_done:

  // char case conversion
  if (((Flags and CHARCASE_MASK_ORIGINAL) or X) <= $ffff) then
  begin
    X := TEXTCONV_CHARCASE.VALUES[X + (Flags and CHARCASE_MASK) - CHARCASE_OFFSET];
  end;

char_write:
  DestSize := NativeUInt(FStore.DestTop);
  Dec(DestSize, NativeUInt(Dest));

  case {DestinationEncoding}(Flags shr ENCODING_DESTINATION_OFFSET) of
    ENC_SBCS{Single-byte: AnsiChar, AnsiString}:
    begin
      if (DestSize = 0{< 1}) then goto dest_too_small;

      if (X > $ffff) then PByte(Dest)^ := UNKNOWN_CHARACTER
      else PByte(Dest)^ := PTextConvBW({$ifdef CPUX86}FStore.Writer{$else}Self.FCallbacks.Writer{$endif})[X];

      Inc(Dest);
    end;
    ENC_UTF8{UTF8Char, UTF8String}:
    begin
      if (X <= $7f) then
      begin
        if (DestSize = 0{< 1}) then goto dest_too_small;
        PByte(Dest)^ := X;
        Inc(Dest);
      end else
      if (X <= $7ff) then
      begin
        if (DestSize < 2) then goto dest_too_small;

        // X := (X shr 6) + ((X and $3f) shl 8) + $80C0;
        Y := X;
        X := (X shr 6) + $80C0;
        Y := (Y and $3f) shl 8;
        Inc(X, Y);

        PWord(Dest)^ := X;
        Inc(Dest, 2);
      end else
      if (X <= $ffff) then
      begin
        if (DestSize < 3) then goto dest_too_small;

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
      end else
      begin
        if (DestSize < 4) then goto dest_too_small;

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
    end;
    ENC_UTF16{WideChar, WideString, UnicodeString}:
    begin
      if (DestSize < 2) then goto dest_too_small;
      if (X <= $ffff) then
      begin
        if (X shr 11 = $1B) then PWord(Dest)^ := $fffd
        else PWord(Dest)^ := X;

        Inc(Dest, 2);
      end else
      begin
        if (DestSize < 4) then goto dest_too_small;
        Y := (X - $10000) shr 10 + $d800;
        X := (X - $10000) and $3ff + $dc00;
        X := (X shl 16) + Y;

        PCardinal(Dest)^ := X;
        Inc(Dest, 4);
      end;
    end;
    ENC_UTF16BE:
    begin
      if (DestSize < 2) then goto dest_too_small;
      if (X <= $ffff) then
      begin
        if (X shr 11 = $1B) then PWord(Dest)^ := $fdff
        else PWord(Dest)^ := Swap(X);

        Inc(Dest, 2);
      end else
      begin
        if (DestSize < 4) then goto dest_too_small;
        Y := Swap((X - $10000) shr 10 + $d800);
        X := Swap((X - $10000) and $3ff + $dc00);
        X := (X shl 16) + Y;

        PCardinal(Dest)^ := X;
        Inc(Dest, 4);
      end;
    end;
    ENC_UTF32:
    begin
      if (DestSize < 4) then goto dest_too_small;
      PCardinal(Dest)^ := X;
      Inc(Dest, 4);
    end;
    ENC_UTF32BE:
    begin
      if (DestSize < 4) then goto dest_too_small;
      // 3210 --> 0123
      // X := (Swap(X){01} shl 16) or Swap(X shr 16){23};
      Y := X shr 16;
      X := Swap(X);
      Y := Swap(Y);
      X := X shl 16;
      Inc(X, Y);

      PCardinal(Dest)^ := X;
      Inc(Dest, 4);
    end;
    ENC_UCS2143:
    begin
      if (DestSize < 4) then goto dest_too_small;
      // 3210 --> 1032
      // X := (X shr 16) or (X shl 16);
      Y := X shr 16;
      X := X shl 16;
      Inc(X, Y);

      PCardinal(Dest)^ := X;
      Inc(Dest, 4);
    end;
    ENC_UCS3412:
    begin
      if (DestSize < 4) then goto dest_too_small;
      // 3210 --> 2301
      // X := (Swap(X shr 16){23} shl 16) or Swap(X);
      Y := X shr 16;
      X := Swap(X);
      Y := Swap(Y) shl 16;
      X := Word(X);
      Inc(X, Y);

      PCardinal(Dest)^ := X;
      Inc(Dest, 4);
    end;
  else
    // Multy-byte encoding callback
    if (DestSize = 0{< 1}) then goto dest_too_small;
    {$ifdef CPUX86}
    FStore.Dest := Dest;
    FStore.Src := Src;
    {$endif}
      // destination finalized (FinalMode)
      if (SrcSize = 0) and (Flags and FLAG_MODE_FINALIZE <> 0) then
        Flags := Flags or FLAG_DEST_ALREADY_FINALIZED;
      X := TWriterProc({$ifdef CPUX86}FStore.writer{$else}Self.FCallbacks.Writer{$endif})
           ({$ifdef CPUX86}FStore.Self{$else}@Self{$endif}, X, Dest, DestSize,
           Flags and FLAG_DEST_ALREADY_FINALIZED <> 0);
    {$ifdef CPUX86}
    Dest := FStore.Dest;
    Src := FStore.Src;
    {$endif}
    if (X = 0) then goto dest_too_small;
    Inc(Dest, X);
  end;

  // store correct converted Pointers
  FStore.StoredDest := Dest;
  FStore.StoredSrc := Src;
  if (Flags and FLAGS_STATE_NEEDED <> 0) then
  begin
    {$ifdef LARGEINT}
       Y := Self.FState.WR;
       FStore.WR := Y;
    {$else}
       {$ifdef CPUX86}_Self := FStore.Self;{$endif}
       Y := {$ifdef CPUX86}_Self{$else}Self{$endif}.FState.Write.D;
       FStore.Write.D := Y;
       Y := {$ifdef CPUX86}_Self{$else}Self{$endif}.FState.Read.D;
       FStore.Read.D := Y;
    {$endif}
    if (NativeInt(Y) < 0) then
    begin
      // scsu readed window modified
      {$ifdef CPUX86}_Self{$else}Self{$endif}.FState.Write.Bytes[3] := 0;
      FStore.Write.Bytes[3] := 0;
      if (Y and (1 shl (30{$ifdef LARGEINT}+32{$endif})) <> 0) then
      begin
        {$ifdef CPUX86}
        FStore.Src := Src;
        {$endif}
          TinyMove({$ifdef CPUX86}_Self{$else}Self{$endif}.FState.ScsuReadWindows, FStore.ScsuReadWindows, 32);
        {$ifdef CPUX86}
        Src := FStore.Src;
        {$endif}
      end else
      begin
        {$ifNdef CPUX86}
          {$ifdef LARGEINT}Y := Y shr 32;{$endif}
          Y := Byte(Y);
        {$endif}
        X := {$ifdef CPUX86}_Self{$else}Self{$endif}.FState.ScsuReadWindows[{$ifdef CPUX86}FStore.Write.B{$else}Y{$endif}];
        FStore.ScsuReadWindows[{$ifdef CPUX86}FStore.Write.B{$else}Y{$endif}] := X;
      end;
    end;
  end;

  // next interation
  if (SrcSize >= 4) then goto char_read_normal;
char_read_small:
  case SrcSize of
    0: begin
         if (Flags and (FLAG_DEST_MARGIN_NEEDED or FLAG_MODE_FINALIZE or FLAG_DEST_ALREADY_FINALIZED) <>
            (FLAG_DEST_MARGIN_NEEDED or FLAG_MODE_FINALIZE)) then goto convert_finish;

         // call margin data write
         {$ifdef CPUX86}
         FStore.Dest := Dest;
         {$endif}
         X := TWriterProc({$ifdef CPUX86}FStore.writer{$else}Self.FCallbacks.Writer{$endif})
           ({$ifdef CPUX86}FStore.Self{$else}@Self{$endif}, High(Cardinal),
           Dest, {DestSize}NativeUInt(FStore.DestTop) - NativeUInt(Dest), True);
         {$ifdef CPUX86}
         Dest := FStore.Dest;
         {$endif}
         if (X = 0) then goto dest_too_small;
         if (Cardinal(X) = High(Cardinal)) then goto convert_finish;
         Inc(Dest, X);
         FStore.StoredDest := Dest;
         FStore.Write.D := {$ifdef CPUX86}FStore.{$endif}Self.FState.Write.D;
         goto convert_finish;
       end;
    1: begin
         X := PByte(Src)^;
         goto char_read;
       end;
    2: begin
         X := PWord(Src)^;
         goto char_read;
       end;
    3: begin
         X := P4Bytes(Src)[2];
         Y := PWord(Src)^;
         X := (X shl 16) or Y;
         goto char_read;
       end;
  end;

dest_too_small:
  Inc(SrcSize, Ord(SrcSize = 0));

convert_finish:
  {$ifdef CPUX86}_Self := FStore.Self;{$endif}
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FDestinationWritten := NativeUInt(FStore.StoredDest)-NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FDestination);
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FSourceRead := NativeUInt(FStore.StoredSrc)-NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FSource);
  if (Flags and FLAGS_STATE_NEEDED <> 0) and
     ((SrcSize <> 0) or ({not F.ModeFinalize}Flags and FLAG_MODE_FINALIZE = 0)) then
  begin
    {$ifdef CPUX86}_Self{$else}Self{$endif}.FState.WR := FStore.WR;
    if (Flags and ENCODING_MASK = ENC_SCSU) then
    begin
      TinyMove(FStore.ScsuReadWindows, {$ifdef CPUX86}_Self{$else}Self{$endif}.FState.ScsuReadWindows, 32);
    end;
  end else
  begin
    {$ifdef CPUX86}_Self{$else}Self{$endif}.FState.WR := 0;
  end;
  Result := SrcSize;
end;
{$ifdef undef}{$ENDREGION}{$endif}

{$ifdef undef}{$REGION 'fast SBCS<-->UTF8<-->UTF16 conversions'}{$endif}
const
  HIGH_NATIVE_BIT_VALUE = (NativeUInt(1) shl HIGH_NATIVE_BIT);

  DIV3_MAX_DIVIDEND = 98303;
  DIV3_MUL_VALUE = 43691;
  DIV3_SHIFT = 17;

  MAX_SBCSCHAR_SIZE = 1;
  MAX_UTF8CHAR_SIZE = 6;
  MAX_UTF16CHAR_SIZE = 4;

type
  TExtendedConversionOptions = record
    // Most frequently used conversions
    Source: Pointer;
    Destination: Pointer;
    Length: NativeUInt;
    // Small conversion
    SourceSize: NativeUInt;
    DestinationSize: NativeUInt;
    Callback: Pointer;
    Converter: Pointer;
    CharBuffer: T8Bytes;
  end;
  PExtendedConversionOptions = ^TExtendedConversionOptions;

const
  FLAG_SOURCE_UTF16 = 1;
  FLAG_DESTINATION_UTF16 = 2;
  FLAG_USE_CONVERTER = 4;

function SmallConversion(var Options: TExtendedConversionOptions; Length: NativeUInt;
  Flags: NativeUInt): Boolean;
label
  _1;
type
  TConversionCallback1 = function(Dest, Src: Pointer; Length: NativeUInt): NativeUInt;
  TConversionCallback2 = function(Dest, Src: Pointer; Length: NativeUInt; Converter: Pointer): NativeUInt;
var
  Size: NativeUInt;
  NewSource: Pointer;
  Value: NativeUInt;
  Destination: PByte;
  X: Cardinal;
begin
  // source size
  Size := Length;
  if (Flags and FLAG_SOURCE_UTF16 <> 0) then Inc(Size, Length);
  Value := Options.SourceSize - Size;
  Options.SourceSize := Value;
  if (NativeInt(Value) < 0) then
  begin
    Result := True;
    Exit;
  end;
  NewSource := Pointer(NativeUInt(Options.Source) + Size);

  // callback
  if (Flags and FLAG_USE_CONVERTER = 0) then
  begin
    Size := TConversionCallback1(Options.Callback)(@Options.CharBuffer, Options.Source, Length);
  end else
  begin
    Size := TConversionCallback2(Options.Callback)(@Options.CharBuffer, Options.Source, Length, Options.Converter);
  end;
  if (Flags and FLAG_DESTINATION_UTF16 <> 0) then
    Size := Size shl 1;

  // destination size
  Value := Options.DestinationSize - Size;
  Options.DestinationSize := Value;
  if (NativeInt(Value) < 0) then
  begin
    if (Options.SourceSize = 0) then Options.SourceSize := 1;
    Result := True;
    Exit;
  end;

  // data copy
  Destination := Options.Destination;
  X := PCardinal(@Options.CharBuffer[0])^;
  if (Size >= SizeOf(Cardinal)) then
  begin
    PCardinal(Destination)^ := X;
    Dec(Size, SizeOf(Cardinal));
    Inc(Destination, SizeOf(Cardinal));
    X := PCardinal(@Options.CharBuffer[4])^;
  end;
  case Size of
    2:
    begin
      PWord(Destination)^ := X;
      Inc(Destination, 2);
    end;
    3:
    begin
      PWord(Destination)^ := X;
      X := X shr 16;
      Inc(Destination, 2);
      goto _1;
    end;
    1:
    begin
    _1:
      PByte(Destination)^ := X;
      Inc(Destination, 1);
    end;
  end;

  // result
  Options.Source := NewSource;
  Options.Destination := Destination;
  Result := (Options.SourceSize = 0);
end;


function TTextConvContext.convert_sbcs_from_sbcs: NativeInt;
type
  // result = length
  TCallback = procedure(Dest: PAnsiChar; Src: PAnsiChar; Length: NativeUInt; Converter: PTextConvSS);
var
  SrcLength, DestLength: NativeUInt;
  Length: NativeUInt;
begin
  SrcLength := Self.SourceSize;
  DestLength := Self.DestinationSize;

  if (DestLength >= SrcLength) then
  begin
    Length := SrcLength;
    Result := 0;
  end else
  begin
    Length := DestLength;
    Result := NativeInt(SrcLength{SrcSize} - DestLength){remaining source bytes};
  end;
  Self.FSourceRead := Length;
  Self.FDestinationWritten := Length;

  TCallback(Self.FCallbacks.ReaderWriter)(Self.Destination, Self.Source, Length, Self.FCallbacks.Converter);
end;

// result = length
procedure sbcs_from_sbcs(Dest: PAnsiChar; Src: PAnsiChar; Length: NativeUInt; Converter: PTextConvSS);
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_not_ascii,
  small_4, small_3, small_2, small_1,
  small_length;
var
  {$ifdef CPUX86}
  Store: record
    TopSrc: NativeUInt;
  end;
  {$endif}

  X: NativeUInt;
  {$ifdef CPUX86}
  Lookup: PTextConvBB;
  {$else}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
{$else .CPUARM}
var
  MASK_80: NativeUInt;
{$endif}
begin
  if (Length = 0) then Exit;
  // store parameters
  Inc(Length, NativeUInt(Src));
  Dec(Length, SizeOf(Cardinal));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;
  {$ifdef CPUX86}Lookup := Pointer(Converter);{$endif}

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      PCardinal(Dest)^ := X;
      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        X := X shr 24;
        Inc(Src, 3);
        Inc(Dest, 3);
        goto small_1;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        goto small_2;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        goto small_3;
    end else
    begin
    process_not_ascii:
      if (X and $8000 = 0) then goto small_1;
      if (X and $800000 = 0) then goto small_2;
      if (X and $80000000 = 0) then goto small_3;

      small_4:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(Converter){$endif}[Byte(X)];
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
      small_3:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(Converter){$endif}[Byte(X)];
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
      small_2:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(Converter){$endif}[Byte(X)];
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
      small_1:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(Converter){$endif}[Byte(X)];
        Inc(Src);
        Inc(Dest);
    end;
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_not_ascii;

small_length:
  case (NativeUInt(Src) - {$ifdef CPUX86}Store.{$endif}TopSrc) of
   3{1}: begin
           X := PByte(Src)^;
           goto small_1;
         end;
   2{2}: begin
           X := PWord(Src)^;
           goto small_2;
         end;
   1{3}: begin
           X := P4Bytes(Src)[2];
           X := (X shl 16) or PWord(Src)^;
           goto small_3;
         end;
  end;
end;

// result = length
procedure sbcs_from_sbcs_lower(Dest: PAnsiChar; Src: PAnsiChar; Length: NativeUInt; LowerCase: PTextConvSS);
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_not_ascii,
  small_4, small_3, small_2, small_1,
  small_length;
var
  {$ifdef CPUX86}
  Store: record
    TopSrc: NativeUInt;
  end;
  {$endif}

  X, U, V: NativeUInt;
  StoredX: NativeUInt;
  {$ifdef CPUX86}
  Lookup: PTextConvBB;
  {$else}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_40 = MASK_40_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_40, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  if (Length = 0) then Exit;
  // store parameters
  Inc(Length, NativeUInt(Src));
  Dec(Length, SizeOf(Cardinal));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_40;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X + ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      StoredX := X;
        X := X and Integer(MASK_7F);
        U := X xor MASK_40;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X + ((not V) and U) shr 2;
        PCardinal(Dest)^ := X;
      X := StoredX;
      {$ifdef CPUX86}Lookup := Pointer(LowerCase);{$endif}
      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        X := X shr 24;
        Inc(Src, 3);
        Inc(Dest, 3);
        goto small_1;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        goto small_2;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        goto small_3;
    end else
    begin
      {$ifdef CPUX86}Lookup := Pointer(LowerCase);{$endif}
    process_not_ascii:
      if (X and $8000 = 0) then goto small_1;
      if (X and $800000 = 0) then goto small_2;
      if (X and $80000000 = 0) then goto small_3;

      small_4:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(LowerCase){$endif}[Byte(X)];
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
      small_3:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(LowerCase){$endif}[Byte(X)];
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
      small_2:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(LowerCase){$endif}[Byte(X)];
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
      small_1:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(LowerCase){$endif}[Byte(X)];
        Inc(Src);
        Inc(Dest);
    end;
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_not_ascii;

small_length:
  {$ifdef CPUX86}Lookup := Pointer(LowerCase);{$endif}
  case (NativeUInt(Src) - {$ifdef CPUX86}Store.{$endif}TopSrc) of
   3{1}: begin
           X := PByte(Src)^;
           goto small_1;
         end;
   2{2}: begin
           X := PWord(Src)^;
           goto small_2;
         end;
   1{3}: begin
           X := P4Bytes(Src)[2];
           X := (X shl 16) or PWord(Src)^;
           goto small_3;
         end;
  end;
end;

// result = length
procedure sbcs_from_sbcs_upper(Dest: PAnsiChar; Src: PAnsiChar; Length: NativeUInt; UpperCase: PTextConvSS);
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_not_ascii,
  small_4, small_3, small_2, small_1,
  small_length;
var
  {$ifdef CPUX86}
  Store: record
    TopSrc: NativeUInt;
  end;
  {$endif}

  X, U, V: NativeUInt;
  StoredX: NativeUInt;
  {$ifdef CPUX86}
  Lookup: PTextConvBB;
  {$else}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_60 = MASK_60_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_60, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  if (Length = 0) then Exit;
  // store parameters
  Inc(Length, NativeUInt(Src));
  Dec(Length, SizeOf(Cardinal));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_60 := MASK_60_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_60;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X - ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      StoredX := X;
        X := X and Integer(MASK_7F);
        U := X xor MASK_60;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X - ((not V) and U) shr 2;
        PCardinal(Dest)^ := X;
      X := StoredX;
      {$ifdef CPUX86}Lookup := Pointer(UpperCase);{$endif}
      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        X := X shr 24;
        Inc(Src, 3);
        Inc(Dest, 3);
        goto small_1;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        goto small_2;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        goto small_3;
    end else
    begin
      {$ifdef CPUX86}Lookup := Pointer(UpperCase);{$endif}
    process_not_ascii:
      if (X and $8000 = 0) then goto small_1;
      if (X and $800000 = 0) then goto small_2;
      if (X and $80000000 = 0) then goto small_3;

      small_4:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(UpperCase){$endif}[Byte(X)];
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
      small_3:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(UpperCase){$endif}[Byte(X)];
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
      small_2:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(UpperCase){$endif}[Byte(X)];
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
      small_1:
        PByte(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvBB(UpperCase){$endif}[Byte(X)];
        Inc(Src);
        Inc(Dest);
    end;
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_not_ascii;

small_length:
  {$ifdef CPUX86}Lookup := Pointer(UpperCase);{$endif}
  case (NativeUInt(Src) - {$ifdef CPUX86}Store.{$endif}TopSrc) of
   3{1}: begin
           X := PByte(Src)^;
           goto small_1;
         end;
   2{2}: begin
           X := PWord(Src)^;
           goto small_2;
         end;
   1{3}: begin
           X := P4Bytes(Src)[2];
           X := (X shl 16) or PWord(Src)^;
           goto small_3;
         end;
  end;
end;

function TTextConvContext.convert_utf8_from_utf8: NativeInt;
type
  // result = min: length/3*2; max: length*3/2
  TCallback = function(Dest: PUTF8Char; Src: PUTF8Char; Length: NativeUInt): NativeUInt;
const
  SMALL_SRC_SIZE = MAX_UTF8CHAR_SIZE;
  SMALL_DEST_SIZE = (SMALL_SRC_SIZE * 3) div 2;
  SMALL_CONVERSION_FLAGS = 0;
var
  DestSize, SrcSize: NativeUInt;
  Length, Value: NativeUInt;
  {$ifdef CPUX86}
  _Self: PTextConvContext;
  {$endif}
  Done: Boolean;

  FStore: record
    Options: TExtendedConversionOptions;
    SourceTop: Pointer;
    {$ifdef CPUX86}
    Self: PTextConvContext;
    {$endif}
  end;
begin
  // store parameters
  {$ifdef CPUX86}
  FStore.Self := @Self;
  {$endif}
  FStore.Options.Source := Self.Source;
  FStore.Options.Destination := Self.Destination;
  FStore.Options.Callback := Self.FCallbacks.ReaderWriter;
  // FStore.Options.Converter := Self.FCallbacks.Converter;

  SrcSize := Self.SourceSize;
  DestSize := Self.DestinationSize;
  FStore.SourceTop := Pointer(NativeUInt(FStore.Options.Source) + SrcSize);

  // large source/destination
  // source length limit = (Destination Length * 2) div 3;
  if (SrcSize > SMALL_SRC_SIZE) and (DestSize > SMALL_DEST_SIZE) then
  repeat
    if (DestSize > (DIV3_MAX_DIVIDEND shr 1)) then
    begin
      Length := DestSize shr 1;
    end else
    begin
      Length := (NativeInt(DestSize) * (DIV3_MUL_VALUE * 2)) shr DIV3_SHIFT;
    end;
    if (Length > SrcSize) then
    begin
      FStore.Options.Length := SrcSize;
    end else
    begin
      FStore.Options.Length := Length;
    end;

    // execute conversion
    Value := TCallback(FStore.Options.Callback)(
      FStore.Options.Destination, FStore.Options.Source,
      NativeUInt(@FStore.Options) + HIGH_NATIVE_BIT_VALUE);
    Dec(DestSize, Value);
    SrcSize := NativeUInt(FStore.SourceTop) - NativeUInt(FStore.Options.Source);
  until (DestSize <= SMALL_DEST_SIZE) or (SrcSize <= SMALL_SRC_SIZE);

  // small source/destination
  if (SrcSize <> 0) then
  begin
    FStore.Options.SourceSize := SrcSize;
    FStore.Options.DestinationSize := DestSize;
    repeat
      Length := TEXTCONV_UTF8CHAR_SIZE[PByte(FStore.Options.Source)^];
      Done := SmallConversion(FStore.Options, Length + Byte(Length = 0), SMALL_CONVERSION_FLAGS);
      SrcSize := FStore.Options.SourceSize;
    until (Done);
  end;

  // result
  {$ifdef CPUX86}_Self := FStore.Self;{$endif}
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FDestinationWritten :=
     NativeUInt(FStore.Options.Destination) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FDestination);
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FSourceRead :=
     NativeUInt(FStore.Options.Source) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FSource);
  Result := SrcSize;
end;

// result = min: length/3*2; max: length*3/2
function utf8_from_utf8_lower(Dest: PUTF8Char; Src: PUTF8Char; Length: NativeUInt): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_standard, process_character, copy_1, copy_data, copy_2, ptrs_increase,
  next_iteration, small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  end;

  X, U, V: NativeUInt;
  StoredX: NativeUInt;

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_40 = MASK_40_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_40, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, MAX_UTF8CHAR_SIZE);

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_40;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X + ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      StoredX := X;
        X := X and Integer(MASK_7F);
        U := X xor MASK_40;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X + ((not V) and U) shr 2;
        PCardinal(Dest)^ := X;
      X := StoredX;

      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        Inc(Src, 3);
        Inc(Dest, 3);
        goto next_iteration;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 2) then goto process_standard;
        goto next_iteration;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 3) then goto process_standard;
        // goto next_iteration;
    end else
    begin
    process_standard:
      if (X and $C0E0 = $80C0) then
      begin
        X := ((X and $1F) shl 6) + ((X shr 8) and $3F);
        Inc(Src, 2);

      process_character:
        X := TEXTCONV_CHARCASE.VALUES[X];
        if (X <= $7ff) then
        begin
          if (X > $7f) then
          begin
            U := X;
            X := (X shr 6) + $80C0;
            U := (U and $3f) shl 8;
            Inc(X, U);
            PWord(Dest)^ := X;
            Inc(Dest, 2);
          end else
          begin
            PByte(Dest)^ := X;
            Inc(Dest);
          end;
        end else
        begin
          U := X;
          X := (X and $0fc0) shl 2;
          Inc(X, (U and $3f) shl 16);
          U := (U shr 12);
          Inc(X, $8080E0);
          Inc(X, U);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
      end else
      begin
        U := TEXTCONV_UTF8CHAR_SIZE[Byte(X)];
        case (U) of
          1:
          begin
            X := X and $7f;
            Inc(Src);
            goto process_character;
          end;
          2: goto copy_2;
          3:
          begin
            if (X and $C0C000 = $808000) then
            begin
              U := (X and $0F) shl 12;
              U := U + (X shr 16) and $3F;
              X := (X and $3F00) shr 2;
              Inc(Src, 3);
              Inc(X, U);
              goto process_character;
            end;
            PWord(Dest)^ := PWord(Src)^;
            Inc(Dest, 2);
            Inc(Src, 2);
            goto copy_1;
          end;
          0:
          begin
          copy_1:
            PByte(Dest)^ := PByte(Src)^;
            U := 1;
            goto ptrs_increase;
          end;
        else
        copy_data: {4..6}
          PCardinal(Dest)^ := X;
          if (U > SizeOf(Cardinal)) then
          begin
            Dec(U, SizeOf(Cardinal));
            Inc(Src, SizeOf(Cardinal));
            Inc(Dest, SizeOf(Cardinal));
            if (U = 1) then
            begin
              PByte(Dest)^ := PByte(Src)^;
            end else
            begin
            copy_2:
              PWord(Dest)^ := PWord(Src)^;
            end;
          end;

        ptrs_increase:
          Inc(Src, U);
          Inc(Dest, U);
        end;
      end;
    end;
  end;

next_iteration:
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_standard;

small_length:
  U := Length{TopSrc} + MAX_UTF8CHAR_SIZE;
  if (U = NativeUInt(Src)) then goto done;
  X := PByte(Src)^;
  if (X <= $7f) then
  begin
    PByte(Dest)^ := TEXTCONV_CHARCASE.VALUES[X];
    Inc(Src);
    Inc(Dest);
    if (NativeUInt(Src) <> Length{TopSrc}) then goto small_length;
    goto done;
  end;
  X := TEXTCONV_UTF8CHAR_SIZE[X];
  Dec(U, NativeUInt(Src));
  if (X{char size} > U{available source length}) then
  begin
    Options := Store.Options;
    if (Options <> nil) then goto done_extended;
    PByte(Dest)^ := UNKNOWN_CHARACTER;
    Inc(Dest);
    goto done_standard;
  end;

  case X{char size} of
    0,1:
    begin
      PByte(Dest)^ := PByte(Src)^;
      Inc(Src);
      Inc(Dest);
    end;
    2:
    begin
      X := PWord(Src)^;
      goto process_standard;
    end;
    3:
    begin
      X := P4Bytes(Src)[2];
      X := (X shl 16) or PWord(Src)^;
      goto process_standard;
    end;
  else
    // 4..5
    X := PCardinal(Src)^;
    goto copy_data;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

// result = min: length/3*2; max: length*3/2
function utf8_from_utf8_upper(Dest: PUTF8Char; Src: PUTF8Char; Length: NativeUInt): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_standard, process_character, copy_1, copy_data, copy_2, ptrs_increase,
  next_iteration, small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  end;

  X, U, V: NativeUInt;
  StoredX: NativeUInt;

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_60 = MASK_60_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_60, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, MAX_UTF8CHAR_SIZE);

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_60 := MASK_60_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_60;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X - ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      StoredX := X;
        X := X and Integer(MASK_7F);
        U := X xor MASK_60;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X - ((not V) and U) shr 2;
        PCardinal(Dest)^ := X;
      X := StoredX;

      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        Inc(Src, 3);
        Inc(Dest, 3);
        goto next_iteration;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 2) then goto process_standard;
        goto next_iteration;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 3) then goto process_standard;
        // goto next_iteration;
    end else
    begin
    process_standard:
      if (X and $C0E0 = $80C0) then
      begin
        X := ((X and $1F) shl 6) + ((X shr 8) and $3F);
        Inc(Src, 2);

      process_character:
        X := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + X];
        if (X <= $7ff) then
        begin
          if (X > $7f) then
          begin
            U := X;
            X := (X shr 6) + $80C0;
            U := (U and $3f) shl 8;
            Inc(X, U);
            PWord(Dest)^ := X;
            Inc(Dest, 2);
          end else
          begin
            PByte(Dest)^ := X;
            Inc(Dest);
          end;
        end else
        begin
          U := X;
          X := (X and $0fc0) shl 2;
          Inc(X, (U and $3f) shl 16);
          U := (U shr 12);
          Inc(X, $8080E0);
          Inc(X, U);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
      end else
      begin
        U := TEXTCONV_UTF8CHAR_SIZE[Byte(X)];
        case (U) of
          1:
          begin
            X := X and $7f;
            Inc(Src);
            goto process_character;
          end;
          2: goto copy_2;
          3:
          begin
            if (X and $C0C000 = $808000) then
            begin
              U := (X and $0F) shl 12;
              U := U + (X shr 16) and $3F;
              X := (X and $3F00) shr 2;
              Inc(Src, 3);
              Inc(X, U);
              goto process_character;
            end;
            PWord(Dest)^ := PWord(Src)^;
            Inc(Dest, 2);
            Inc(Src, 2);
            goto copy_1;
          end;
          0:
          begin
          copy_1:
            PByte(Dest)^ := PByte(Src)^;
            U := 1;
            goto ptrs_increase;
          end;
        else
        copy_data: {4..6}
          PCardinal(Dest)^ := X;
          if (U > SizeOf(Cardinal)) then
          begin
            Dec(U, SizeOf(Cardinal));
            Inc(Src, SizeOf(Cardinal));
            Inc(Dest, SizeOf(Cardinal));
            if (U = 1) then
            begin
              PByte(Dest)^ := PByte(Src)^;
            end else
            begin
            copy_2:
              PWord(Dest)^ := PWord(Src)^;
            end;
          end;

        ptrs_increase:
          Inc(Src, U);
          Inc(Dest, U);
        end;
      end;
    end;
  end;

next_iteration:
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_standard;

small_length:
  U := Length{TopSrc} + MAX_UTF8CHAR_SIZE;
  if (U = NativeUInt(Src)) then goto done;
  X := PByte(Src)^;
  if (X <= $7f) then
  begin
    PByte(Dest)^ := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + X];
    Inc(Src);
    Inc(Dest);
    if (NativeUInt(Src) <> Length{TopSrc}) then goto small_length;
    goto done;
  end;
  X := TEXTCONV_UTF8CHAR_SIZE[X];
  Dec(U, NativeUInt(Src));
  if (X{char size} > U{available source length}) then
  begin
    Options := Store.Options;
    if (Options <> nil) then goto done_extended;
    PByte(Dest)^ := UNKNOWN_CHARACTER;
    Inc(Dest);
    goto done_standard;
  end;

  case X{char size} of
    0,1:
    begin
      PByte(Dest)^ := PByte(Src)^;
      Inc(Src);
      Inc(Dest);
    end;
    2:
    begin
      X := PWord(Src)^;
      goto process_standard;
    end;
    3:
    begin
      X := P4Bytes(Src)[2];
      X := (X shl 16) or PWord(Src)^;
      goto process_standard;
    end;
  else
    // 4..5
    X := PCardinal(Src)^;
    goto copy_data;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

function TTextConvContext.convert_utf16_from_utf16: NativeInt;
type
  // result = length
  TCallback = procedure(Dest: PUnicodeChar; Src: PUnicodeChar; Length: NativeUInt);
var
  SrcSize, DestSize: NativeUInt;
  Size: NativeUInt;
begin
  SrcSize := Self.SourceSize{~ SrcLength * 2};
  DestSize := Self.DestinationSize and -2{DestLength * 2};

  if (DestSize >= SrcSize) then
  begin
    Size{Length * 2} := SrcSize and -2;
    Result := -NativeInt(SrcSize and 1);
  end else
  begin
    Size{Length * 2} := DestSize;
    Result := NativeInt(SrcSize - DestSize){remaining source bytes};
  end;
  Self.FSourceRead := Size{Length * 2};
  Self.FDestinationWritten := Size{Length * 2};

  TCallback(Self.FCallbacks.ReaderWriter)(Self.Destination, Self.Source, Size shr 1);
end;

// result = length
procedure utf16_from_utf16_lower(Dest: PUnicodeChar; Src: PUnicodeChar; Length: NativeUInt);
label
  _2;
var
  i, X: NativeUInt;
  CharCaseLookup: PTextConvWW;
begin
  CharCaseLookup := Pointer(@TEXTCONV_CHARCASE.LOWER);

  for i := 1 to (Length shr 2)  do
  begin
    X := PNativeUInt(Src)^;
    Inc(NativeUInt(Src), SizeOf(NativeUInt));

    {$ifNdef LARGEINT}
      PCardinal(Dest)^ := Cardinal(CharCaseLookup[Word(X)]) +
        Cardinal(CharCaseLookup[X shr 16]) shl 16;
      Inc(Dest, 2);
      X := PCardinal(Src)^;
      Inc(Src, 2);
      PCardinal(Dest)^ := Cardinal(CharCaseLookup[Word(X)]) +
        Cardinal(CharCaseLookup[X shr 16]) shl 16;
      Inc(Dest, 2);
    {$else}
      PNativeUInt(Dest)^ := NativeUInt(CharCaseLookup[Word(X)]) +
        (NativeUInt(CharCaseLookup[Word(X shr 16)]) shl 16) +
        (NativeUInt(CharCaseLookup[Word(X shr 32)]) shl 32) +
        (NativeUInt(CharCaseLookup[X shr 48]) shl 48);

      Inc(NativeUInt(Dest), SizeOf(NativeUInt));
    {$endif}
  end;

  case (Length and 3) of
    3:
    begin
      X := PWord(Src)^;
      Inc(Src);
      PWord(Dest)^ := CharCaseLookup[X];
      Inc(Dest);
      goto _2;
    end;
    2:
    begin _2:
      X := PCardinal(Src)^;
      PCardinal(Dest)^ := Cardinal(CharCaseLookup[Word(X)]) +
        Cardinal(CharCaseLookup[X shr 16]) shl 16;
    end;
    1:
    begin
      X := PWord(Src)^;
      PWord(Dest)^ := CharCaseLookup[X];
    end;
  end;
end;

// result = length
procedure utf16_from_utf16_upper(Dest: PUnicodeChar; Src: PUnicodeChar; Length: NativeUInt);
label
  _2;
var
  i, X: NativeUInt;
  CharCaseLookup: PTextConvWW;
begin
  CharCaseLookup := Pointer(@TEXTCONV_CHARCASE.UPPER);

  for i := 1 to (Length shr 2)  do
  begin
    X := PNativeUInt(Src)^;
    Inc(NativeUInt(Src), SizeOf(NativeUInt));

    {$ifNdef LARGEINT}
      PCardinal(Dest)^ := Cardinal(CharCaseLookup[Word(X)]) +
        Cardinal(CharCaseLookup[X shr 16]) shl 16;
      Inc(Dest, 2);
      X := PCardinal(Src)^;
      Inc(Src, 2);
      PCardinal(Dest)^ := Cardinal(CharCaseLookup[Word(X)]) +
        Cardinal(CharCaseLookup[X shr 16]) shl 16;
      Inc(Dest, 2);
    {$else}
      PNativeUInt(Dest)^ := NativeUInt(CharCaseLookup[Word(X)]) +
        (NativeUInt(CharCaseLookup[Word(X shr 16)]) shl 16) +
        (NativeUInt(CharCaseLookup[Word(X shr 32)]) shl 32) +
        (NativeUInt(CharCaseLookup[X shr 48]) shl 48);

      Inc(NativeUInt(Dest), SizeOf(NativeUInt));
    {$endif}
  end;

  case (Length and 3) of
    3:
    begin
      X := PWord(Src)^;
      Inc(Src);
      PWord(Dest)^ := CharCaseLookup[X];
      Inc(Dest);
      goto _2;
    end;
    2:
    begin _2:
      X := PCardinal(Src)^;
      PCardinal(Dest)^ := Cardinal(CharCaseLookup[Word(X)]) +
        Cardinal(CharCaseLookup[X shr 16]) shl 16;
    end;
    1:
    begin
      X := PWord(Src)^;
      PWord(Dest)^ := CharCaseLookup[X];
    end;
  end;
end;

function TTextConvContext.convert_utf8_from_sbcs: NativeInt;
type
  // result = min: length; max: length*3
  TCallback = function(Dest: PUTF8Char; Src: PAnsiChar; Length: NativeUInt; Converter: PTextConvMS): NativeUInt;
const
  SMALL_SRC_SIZE = MAX_SBCSCHAR_SIZE;
  SMALL_DEST_SIZE = SMALL_SRC_SIZE * 3;
  SMALL_CONVERSION_FLAGS = FLAG_USE_CONVERTER;
var
  DestSize, SrcSize: NativeUInt;
  Length, Value: NativeUInt;
  {$ifdef CPUX86}
  _Self: PTextConvContext;
  {$endif}
  Done: Boolean;

  FStore: record
    Options: TExtendedConversionOptions;
    SourceTop: Pointer;
    {$ifdef CPUX86}
    Self: PTextConvContext;
    {$endif}
  end;
begin
  // store parameters
  {$ifdef CPUX86}
  FStore.Self := @Self;
  {$endif}
  FStore.Options.Source := Self.Source;
  FStore.Options.Destination := Self.Destination;
  FStore.Options.Callback := Self.FCallbacks.ReaderWriter;
  FStore.Options.Converter := Self.FCallbacks.Converter;

  SrcSize := Self.SourceSize;
  DestSize := Self.DestinationSize;
  FStore.SourceTop := Pointer(NativeUInt(FStore.Options.Source) + SrcSize);

  // large source/destination
  // source length limit = (Destination Length) div 3;
  if (SrcSize > SMALL_SRC_SIZE) and (DestSize > SMALL_DEST_SIZE) then
  repeat
    if (DestSize > DIV3_MAX_DIVIDEND) then
    begin
      Length := DestSize shr 2;
    end else
    begin
      Length := (NativeInt(DestSize) * DIV3_MUL_VALUE) shr DIV3_SHIFT;
    end;
    if (Length > SrcSize) then
    begin
      FStore.Options.Length := SrcSize;
    end else
    begin
      FStore.Options.Length := Length;
    end;

    // execute conversion
    Value := TCallback(FStore.Options.Callback)(
      FStore.Options.Destination, FStore.Options.Source,
      NativeUInt(@FStore.Options) + HIGH_NATIVE_BIT_VALUE,
      FStore.Options.Converter);
    Dec(DestSize, Value);
    SrcSize := NativeUInt(FStore.SourceTop) - NativeUInt(FStore.Options.Source);
  until (DestSize <= SMALL_DEST_SIZE) or (SrcSize <= SMALL_SRC_SIZE);

  // small source/destination
  if (SrcSize <> 0) then
  begin
    FStore.Options.SourceSize := SrcSize;
    FStore.Options.DestinationSize := DestSize;
    repeat
      Done := SmallConversion(FStore.Options, 1{Length}, SMALL_CONVERSION_FLAGS);
      SrcSize := FStore.Options.SourceSize;
    until (Done);
  end;

  // result
  {$ifdef CPUX86}_Self := FStore.Self;{$endif}
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FDestinationWritten :=
     NativeUInt(FStore.Options.Destination) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FDestination);
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FSourceRead :=
     NativeUInt(FStore.Options.Source) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FSource);
  Result := SrcSize;
end;

// result = min: length; max: length*3
function utf8_from_sbcs(Dest: PUTF8Char; Src: PAnsiChar; Length: NativeUInt; Converter: PTextConvMS): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_not_ascii,
  small_4, small_3, small_2, small_1,
  small_length, done;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;

    {$ifdef CPUX86}
    TopSrc: NativeUInt;
    {$endif}
  end;

  X, U: NativeUInt;
  {$ifNdef CPUX86}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
{$else .CPUARM}
var
  MASK_80: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, SizeOf(Cardinal));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      PCardinal(Dest)^ := X;
      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        X := X shr 24;
        Inc(Src, 3);
        Inc(Dest, 3);
        goto small_1;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        goto small_2;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        goto small_3;
    end else
    begin
    process_not_ascii:
      if (X and $8000 = 0) then goto small_1;
      if (X and $800000 = 0) then goto small_2;
      if (X and $80000000 = 0) then goto small_3;

      small_4:
        U := PTextConvMB(Converter)[Byte(X)];
        X := X shr 8;
        Inc(Src);
        PCardinal(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
      small_3:
        U := PTextConvMB(Converter)[Byte(X)];
        X := X shr 8;
        Inc(Src);
        PCardinal(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
      small_2:
        U := PTextConvMB(Converter)[Byte(X)];
        X := X shr 8;
        Inc(Src);
        PCardinal(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
      small_1:
        U := PTextConvMB(Converter)[Byte(X)];
        Inc(Src);
        X := U;
        PWord(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
        if (X >= (3 shl 24)) then
        begin
          Dec(Dest);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
    end;
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_not_ascii;

small_length:
  case (NativeUInt(Src) - {$ifdef CPUX86}Store.{$endif}TopSrc) of
   3{1}: begin
           X := PByte(Src)^;
           goto small_1;
         end;
   2{2}: begin
           X := PWord(Src)^;
           goto small_2;
         end;
   1{3}: begin
           X := P4Bytes(Src)[2];
           X := (X shl 16) or PWord(Src)^;
           goto small_3;
         end;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

// result = min: length; max: length*3
function utf8_from_sbcs_lower(Dest: PUTF8Char; Src: PAnsiChar; Length: NativeUInt; LowerCase: PTextConvMS): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_not_ascii,
  small_4, small_3, small_2, small_1,
  small_length, done;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;

    {$ifdef CPUX86}
    TopSrc: NativeUInt;
    {$endif}
  end;

  X, U, V: NativeUInt;
  StoredX: NativeUInt;
  {$ifdef CPUX86}
  Lookup: PTextConvMB;
  {$else}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_40 = MASK_40_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_40, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, SizeOf(Cardinal));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_40;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X + ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      StoredX := X;
        X := X and Integer(MASK_7F);
        U := X xor MASK_40;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X + ((not V) and U) shr 2;
        PCardinal(Dest)^ := X;
      X := StoredX;
      {$ifdef CPUX86}Lookup := Pointer(LowerCase);{$endif}
      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        X := X shr 24;
        Inc(Src, 3);
        Inc(Dest, 3);
        goto small_1;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        goto small_2;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        goto small_3;
    end else
    begin
    process_not_ascii:
      {$ifdef CPUX86}Lookup := Pointer(LowerCase);{$endif}
      if (X and $8000 = 0) then goto small_1;
      if (X and $800000 = 0) then goto small_2;
      if (X and $80000000 = 0) then goto small_3;

      small_4:
        U := Byte(X);
        U := {$ifdef CPUX86}Lookup{$else}PTextConvMB(LowerCase){$endif}[U];
        X := X shr 8;
        Inc(Src);
        PCardinal(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
      small_3:
        U := Byte(X);
        U := {$ifdef CPUX86}Lookup{$else}PTextConvMB(LowerCase){$endif}[U];
        X := X shr 8;
        Inc(Src);
        PCardinal(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
      small_2:
        U := Byte(X);
        U := {$ifdef CPUX86}Lookup{$else}PTextConvMB(LowerCase){$endif}[U];
        X := X shr 8;
        Inc(Src);
        PCardinal(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
      small_1:
        U := Byte(X);
        U := {$ifdef CPUX86}Lookup{$else}PTextConvMB(LowerCase){$endif}[U];
        Inc(Src);
        X := U;
        PWord(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
        if (X >= (3 shl 24)) then
        begin
          Dec(Dest);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
    end;
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_not_ascii;

small_length:
  case (NativeUInt(Src) - {$ifdef CPUX86}Store.{$endif}TopSrc) of
   3{1}: begin
           X := PByte(Src)^;
           {$ifdef CPUX86}Lookup := Pointer(LowerCase);{$endif}
           goto small_1;
         end;
   2{2}: begin
           X := PWord(Src)^;
           {$ifdef CPUX86}Lookup := Pointer(LowerCase);{$endif}
           goto small_2;
         end;
   1{3}: begin
           X := P4Bytes(Src)[2];
           X := (X shl 16) or PWord(Src)^;
           {$ifdef CPUX86}Lookup := Pointer(LowerCase);{$endif}
           goto small_3;
         end;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

// result = min: length; max: length*3
function utf8_from_sbcs_upper(Dest: PUTF8Char; Src: PAnsiChar; Length: NativeUInt; UpperCase: PTextConvMS): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_not_ascii,
  small_4, small_3, small_2, small_1,
  small_length, done;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;

    {$ifdef CPUX86}
    TopSrc: NativeUInt;
    {$endif}
  end;

  X, U, V: NativeUInt;
  StoredX: NativeUInt;
  {$ifdef CPUX86}
  Lookup: PTextConvMB;
  {$else}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_60 = MASK_60_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_60, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, SizeOf(Cardinal));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_60 := MASK_60_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_60;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X - ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      StoredX := X;
        X := X and Integer(MASK_7F);
        U := X xor MASK_60;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X - ((not V) and U) shr 2;
        PCardinal(Dest)^ := X;
      X := StoredX;
      {$ifdef CPUX86}Lookup := Pointer(UpperCase);{$endif}
      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        X := X shr 24;
        Inc(Src, 3);
        Inc(Dest, 3);
        goto small_1;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        goto small_2;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        goto small_3;
    end else
    begin
    process_not_ascii:
      {$ifdef CPUX86}Lookup := Pointer(UpperCase);{$endif}
      if (X and $8000 = 0) then goto small_1;
      if (X and $800000 = 0) then goto small_2;
      if (X and $80000000 = 0) then goto small_3;

      small_4:
        U := Byte(X);
        U := {$ifdef CPUX86}Lookup{$else}PTextConvMB(UpperCase){$endif}[U];
        X := X shr 8;
        Inc(Src);
        PCardinal(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
      small_3:
        U := Byte(X);
        U := {$ifdef CPUX86}Lookup{$else}PTextConvMB(UpperCase){$endif}[U];
        X := X shr 8;
        Inc(Src);
        PCardinal(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
      small_2:
        U := Byte(X);
        U := {$ifdef CPUX86}Lookup{$else}PTextConvMB(UpperCase){$endif}[U];
        X := X shr 8;
        Inc(Src);
        PCardinal(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
      small_1:
        U := Byte(X);
        U := {$ifdef CPUX86}Lookup{$else}PTextConvMB(UpperCase){$endif}[U];
        Inc(Src);
        X := U;
        PWord(Dest)^ := U;
        U := U shr 24;
        Inc(Dest, U);
        if (X >= (3 shl 24)) then
        begin
          Dec(Dest);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
    end;
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_not_ascii;

small_length:
  case (NativeUInt(Src) - {$ifdef CPUX86}Store.{$endif}TopSrc) of
   3{1}: begin
           X := PByte(Src)^;
           {$ifdef CPUX86}Lookup := Pointer(UpperCase);{$endif}
           goto small_1;
         end;
   2{2}: begin
           X := PWord(Src)^;
           {$ifdef CPUX86}Lookup := Pointer(UpperCase);{$endif}
           goto small_2;
         end;
   1{3}: begin
           X := P4Bytes(Src)[2];
           X := (X shl 16) or PWord(Src)^;
           {$ifdef CPUX86}Lookup := Pointer(UpperCase);{$endif}
           goto small_3;
         end;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

function TTextConvContext.convert_sbcs_from_utf8: NativeInt;
type
  // result = min: length/6; max: length
  TCallback = function(Dest: PAnsiChar; Src: PUTF8Char; Length: NativeUInt; Converter: PTextConvSU): NativeUInt;
const
  SMALL_SRC_SIZE = MAX_UTF8CHAR_SIZE;
  SMALL_DEST_SIZE = SMALL_SRC_SIZE;
  SMALL_CONVERSION_FLAGS = FLAG_USE_CONVERTER;
var
  DestSize, SrcSize: NativeUInt;
  Length, Value: NativeUInt;
  {$ifdef CPUX86}
  _Self: PTextConvContext;
  {$endif}
  Done: Boolean;

  FStore: record
    Options: TExtendedConversionOptions;
    SourceTop: Pointer;
    {$ifdef CPUX86}
    Self: PTextConvContext;
    {$endif}
  end;
begin
  // store parameters
  {$ifdef CPUX86}
  FStore.Self := @Self;
  {$endif}
  FStore.Options.Source := Self.Source;
  FStore.Options.Destination := Self.Destination;
  FStore.Options.Callback := Self.FCallbacks.ReaderWriter;
  FStore.Options.Converter := Self.FCallbacks.Converter;

  SrcSize := Self.SourceSize;
  DestSize := Self.DestinationSize;
  FStore.SourceTop := Pointer(NativeUInt(FStore.Options.Source) + SrcSize);

  // large source/destination
  // source length limit = Destination Length;
  if (SrcSize > SMALL_SRC_SIZE) and (DestSize > SMALL_DEST_SIZE) then
  repeat
    Length := DestSize;
    if (Length > SrcSize) then
    begin
      FStore.Options.Length := SrcSize;
    end else
    begin
      FStore.Options.Length := Length;
    end;

    // execute conversion
    Value := TCallback(FStore.Options.Callback)(
      FStore.Options.Destination, FStore.Options.Source,
      NativeUInt(@FStore.Options) + HIGH_NATIVE_BIT_VALUE,
      FStore.Options.Converter);
    Dec(DestSize, Value);
    SrcSize := NativeUInt(FStore.SourceTop) - NativeUInt(FStore.Options.Source);
  until (DestSize <= SMALL_DEST_SIZE) or (SrcSize <= SMALL_SRC_SIZE);

  // small source/destination
  if (SrcSize <> 0) then
  begin
    FStore.Options.SourceSize := SrcSize;
    FStore.Options.DestinationSize := DestSize;
    repeat
      Length := TEXTCONV_UTF8CHAR_SIZE[PByte(FStore.Options.Source)^];
      Done := SmallConversion(FStore.Options, Length + Byte(Length = 0), SMALL_CONVERSION_FLAGS);
      SrcSize := FStore.Options.SourceSize;
    until (Done);
  end;

  // result
  {$ifdef CPUX86}_Self := FStore.Self;{$endif}
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FDestinationWritten :=
     NativeUInt(FStore.Options.Destination) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FDestination);
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FSourceRead :=
     NativeUInt(FStore.Options.Source) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FSource);
  Result := SrcSize;
end;

// result = min: length/6; max: length
function sbcs_from_utf8(Dest: PAnsiChar; Src: PUTF8Char; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_standard, process_character, unknown,
  next_iteration, small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
    {$ifdef CPUX86}
    TopSrc: NativeUInt;
    {$endif}
  end;
  {$ifNdef CPUX86}
  TopSrc: NativeUInt;
  {$endif}
  X, U: NativeUInt;

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
{$else .CPUARM}
var
  MASK_80: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, MAX_UTF8CHAR_SIZE);
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      PCardinal(Dest)^ := X;

      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        Inc(Src, 3);
        Inc(Dest, 3);
        goto next_iteration;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 2) then goto process_standard;
        goto next_iteration;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 3) then goto process_standard;
        // goto next_iteration;
    end else
    begin
    process_standard:
      if (X and $C0E0 = $80C0) then
      begin
        X := ((X and $1F) shl 6) + ((X shr 8) and $3F);
        Inc(Src, 2);

      process_character:
        PByte(Dest)^ := PTextConvBW(Converter)[X];
        Inc(Dest);
      end else
      begin
        U := TEXTCONV_UTF8CHAR_SIZE[Byte(X)];
        case (U) of
          1:
          begin
            X := X and $7f;
            Inc(Src);
            PByte(Dest)^ := X;
            Inc(Dest);
          end;
          3:
          begin
            if (X and $C0C000 = $808000) then
            begin
              U := (X and $0F) shl 12;
              U := U + (X shr 16) and $3F;
              X := (X and $3F00) shr 2;
              Inc(Src, 3);
              Inc(X, U);
              PByte(Dest)^ := PTextConvBW(Converter)[X];
              Inc(Dest);
              goto next_iteration;
            end;
            goto unknown;
          end;
        else
        unknown:
          PByte(Dest)^ := UNKNOWN_CHARACTER;
          Inc(Dest);
          Inc(Src, U);
          Inc(Src, NativeUInt(U = 0));
        end;
      end;
    end;
  end;

next_iteration:
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_standard;

small_length:
  U := {$ifdef CPUX86}Store.{$endif}TopSrc + MAX_UTF8CHAR_SIZE;
  if (U = NativeUInt(Src)) then goto done;
  X := PByte(Src)^;
  if (X <= $7f) then
  begin
    PByte(Dest)^ := X;
    Inc(Src);
    Inc(Dest);
    if (NativeUInt(Src) <> {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
    goto done;
  end;
  X := TEXTCONV_UTF8CHAR_SIZE[X];
  Dec(U, NativeUInt(Src));
  if (X{char size} > U{available source length}) then
  begin
    Options := Store.Options;
    if (Options <> nil) then goto done_extended;
    PByte(Dest)^ := UNKNOWN_CHARACTER;
    Inc(Dest);
    goto done_standard;
  end;

  case X{char size} of
    2:
    begin
      X := PWord(Src)^;
      goto process_standard;
    end;
    3:
    begin
      X := P4Bytes(Src)[2];
      X := (X shl 16) or PWord(Src)^;
      goto process_standard;
    end;
  else
    // 4..5
    goto unknown;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

// result = min: length/6; max: length
function sbcs_from_utf8_lower(Dest: PAnsiChar; Src: PUTF8Char; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_standard, process_character, unknown,
  next_iteration, small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
    {$ifdef CPUX86}
    TopSrc: NativeUInt;
    {$endif}
  end;
  {$ifNdef CPUX86}
  TopSrc: NativeUInt;
  {$endif}

  X, U, V: NativeUInt;
  StoredX: NativeUInt;

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_40 = MASK_40_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_40, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, MAX_UTF8CHAR_SIZE);
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_40;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X + ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      StoredX := X;
        X := X and Integer(MASK_7F);
        U := X xor MASK_40;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X + ((not V) and U) shr 2;
        PCardinal(Dest)^ := X;
      X := StoredX;

      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        Inc(Src, 3);
        Inc(Dest, 3);
        goto next_iteration;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 2) then goto process_standard;
        goto next_iteration;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 3) then goto process_standard;
        // goto next_iteration;
    end else
    begin
    process_standard:
      if (X and $C0E0 = $80C0) then
      begin
        X := ((X and $1F) shl 6) + ((X shr 8) and $3F);
        Inc(Src, 2);

      process_character:
        PByte(Dest)^ := PTextConvBW(Converter)[TEXTCONV_CHARCASE.VALUES[X]];
        Inc(Dest);
      end else
      begin
        U := TEXTCONV_UTF8CHAR_SIZE[Byte(X)];
        case (U) of
          1:
          begin
            X := X and $7f;
            Inc(Src);
            PByte(Dest)^ := TEXTCONV_CHARCASE.VALUES[X];
            Inc(Dest);
          end;
          3:
          begin
            if (X and $C0C000 = $808000) then
            begin
              U := (X and $0F) shl 12;
              U := U + (X shr 16) and $3F;
              X := (X and $3F00) shr 2;
              Inc(Src, 3);
              Inc(X, U);
              goto process_character;
            end;
            goto unknown;
          end;
        else
        unknown:
          PByte(Dest)^ := UNKNOWN_CHARACTER;
          Inc(Dest);
          Inc(Src, U);
          Inc(Src, NativeUInt(U = 0));
        end;
      end;
    end;
  end;

next_iteration:
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_standard;

small_length:
  U := {$ifdef CPUX86}Store.{$endif}TopSrc + MAX_UTF8CHAR_SIZE;
  if (U = NativeUInt(Src)) then goto done;
  X := PByte(Src)^;
  if (X <= $7f) then
  begin
    PByte(Dest)^ := TEXTCONV_CHARCASE.VALUES[X];
    Inc(Src);
    Inc(Dest);
    if (NativeUInt(Src) <> {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
    goto done;
  end;
  X := TEXTCONV_UTF8CHAR_SIZE[X];
  Dec(U, NativeUInt(Src));
  if (X{char size} > U{available source length}) then
  begin
    Options := Store.Options;
    if (Options <> nil) then goto done_extended;
    PByte(Dest)^ := UNKNOWN_CHARACTER;
    Inc(Dest);
    goto done_standard;
  end;

  case X{char size} of
    2:
    begin
      X := PWord(Src)^;
      goto process_standard;
    end;
    3:
    begin
      X := P4Bytes(Src)[2];
      X := (X shl 16) or PWord(Src)^;
      goto process_standard;
    end;
  else
    // 4..5
    goto unknown;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

// result = min: length/6; max: length
function sbcs_from_utf8_upper(Dest: PAnsiChar; Src: PUTF8Char; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_standard, process_character, unknown,
  next_iteration, small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
    {$ifdef CPUX86}
    TopSrc: NativeUInt;
    {$endif}
  end;
  {$ifNdef CPUX86}
  TopSrc: NativeUInt;
  {$endif}

  X, U, V: NativeUInt;
  StoredX: NativeUInt;

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_60 = MASK_60_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_60, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, MAX_UTF8CHAR_SIZE);
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_60 := MASK_60_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_60;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X - ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      StoredX := X;
        X := X and Integer(MASK_7F);
        U := X xor MASK_60;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X - ((not V) and U) shr 2;
        PCardinal(Dest)^ := X;
      X := StoredX;

      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        Inc(Src, 3);
        Inc(Dest, 3);
        goto next_iteration;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        Inc(Dest, 2);
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 2) then goto process_standard;
        goto next_iteration;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest);
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 3) then goto process_standard;
        // goto next_iteration;
    end else
    begin
    process_standard:
      if (X and $C0E0 = $80C0) then
      begin
        X := ((X and $1F) shl 6) + ((X shr 8) and $3F);
        Inc(Src, 2);

      process_character:
        PByte(Dest)^ := PTextConvBW(Converter)[TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + X]];
        Inc(Dest);
      end else
      begin
        U := TEXTCONV_UTF8CHAR_SIZE[Byte(X)];
        case (U) of
          1:
          begin
            X := X and $7f;
            Inc(Src);
            PByte(Dest)^ := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + X];
            Inc(Dest);
          end;
          3:
          begin
            if (X and $C0C000 = $808000) then
            begin
              U := (X and $0F) shl 12;
              U := U + (X shr 16) and $3F;
              X := (X and $3F00) shr 2;
              Inc(Src, 3);
              Inc(X, U);
              goto process_character;
            end;
            goto unknown;
          end;
        else
        unknown:
          PByte(Dest)^ := UNKNOWN_CHARACTER;
          Inc(Dest);
          Inc(Src, U);
          Inc(Src, NativeUInt(U = 0));
        end;
      end;
    end;
  end;

next_iteration:
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_standard;

small_length:
  U := {$ifdef CPUX86}Store.{$endif}TopSrc + MAX_UTF8CHAR_SIZE;
  if (U = NativeUInt(Src)) then goto done;
  X := PByte(Src)^;
  if (X <= $7f) then
  begin
    PByte(Dest)^ := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + X];
    Inc(Src);
    Inc(Dest);
    if (NativeUInt(Src) <> {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
    goto done;
  end;
  X := TEXTCONV_UTF8CHAR_SIZE[X];
  Dec(U, NativeUInt(Src));
  if (X{char size} > U{available source length}) then
  begin
    Options := Store.Options;
    if (Options <> nil) then goto done_extended;
    PByte(Dest)^ := UNKNOWN_CHARACTER;
    Inc(Dest);
    goto done_standard;
  end;

  case X{char size} of
    2:
    begin
      X := PWord(Src)^;
      goto process_standard;
    end;
    3:
    begin
      X := P4Bytes(Src)[2];
      X := (X shl 16) or PWord(Src)^;
      goto process_standard;
    end;
  else
    // 4..5
    goto unknown;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

function TTextConvContext.convert_utf16_from_sbcs: NativeInt;
type
  // result = length
  TCallback = procedure(Dest: PUnicodeChar; Src: PAnsiChar; Length: NativeUInt; Converter: PTextConvUS);
var
  SrcLength, DestLength: NativeUInt;
  Length: NativeUInt;
begin
  SrcLength := Self.SourceSize;
  DestLength := Self.DestinationSize shr 1;

  if (DestLength >= SrcLength) then
  begin
    Length := SrcLength;
    Result := 0;
  end else
  begin
    Length := DestLength;
    Result := NativeInt(SrcLength{SrcSize} - DestLength){remaining source bytes};
  end;
  Self.FSourceRead := Length;
  Self.FDestinationWritten := Length shl 1;

  TCallback(Self.FCallbacks.ReaderWriter)(Self.Destination, Self.Source, Length, Self.FCallbacks.Converter);
end;

// result = length
procedure utf16_from_sbcs(Dest: PUnicodeChar; Src: PAnsiChar; Length: NativeUInt; Converter: PTextConvUS);
label
  process4, process_not_ascii,
  small_4, small_3, small_2, small_1,
  small_length;
var
  {$ifdef CPUX86}
  Store: record
    TopSrc: NativeUInt;
  end;
  {$endif}

  X: NativeUInt;
  {$ifdef CPUX86}
  Lookup: PTextConvWB;
  {$else}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
{$else .CPUARM}
var
  MASK_80: NativeUInt;
{$endif}
begin
  if (Length = 0) then Exit;
  // store parameters
  Inc(Length, NativeUInt(Src));
  Dec(Length, SizeOf(Cardinal));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      Inc(Src, SizeOf(Cardinal));

      PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
      Inc(NativeUInt(Dest), SizeOf(Cardinal));
      PCardinal(Dest)^ := ((X shr 16) and $7f) + ((X shr 8) and $7f0000);
      Inc(NativeUInt(Dest), SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto process_not_ascii;
  end else
  begin
    process_not_ascii:
    {$ifdef CPUX86}Lookup := Pointer(Converter);{$endif}

    small_4:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(Converter){$endif}[Byte(X)];
      X := X shr 8;
      Inc(Dest);
    small_3:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(Converter){$endif}[Byte(X)];
      X := X shr 8;
      Inc(Dest);
    small_2:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(Converter){$endif}[Byte(X)];
      X := X shr 8;
      Inc(Dest);
    small_1:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(Converter){$endif}[Byte(X)];
      Inc(Dest);
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  goto small_4;

small_length:
  {$ifdef CPUX86}Lookup := Pointer(Converter);{$endif}
  case (NativeUInt(Src) - {$ifdef CPUX86}Store.{$endif}TopSrc) of
   3{1}: begin
           X := PByte(Src)^;
           goto small_1;
         end;
   2{2}: begin
           X := PWord(Src)^;
           goto small_2;
         end;
   1{3}: begin
           X := P4Bytes(Src)[2];
           X := (X shl 16) or PWord(Src)^;
           goto small_3;
         end;
  end;
end;

// result = length
procedure utf16_from_sbcs_lower(Dest: PUnicodeChar; Src: PAnsiChar; Length: NativeUInt; LowerCase: PTextConvUS);
label
  process4, process_not_ascii,
  small_4, small_3, small_2, small_1,
  small_length;
var
  {$ifdef CPUX86}
  Store: record
    TopSrc: NativeUInt;
  end;
  {$endif}

  X, U, V: NativeUInt;
  {$ifdef CPUX86}
  Lookup: PTextConvWB;
  {$else}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_40 = MASK_40_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_40, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  if (Length = 0) then Exit;
  // store parameters
  Inc(Length, NativeUInt(Src));
  Dec(Length, SizeOf(Cardinal));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_40;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X + ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));

      PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
      Inc(NativeUInt(Dest), SizeOf(Cardinal));
      PCardinal(Dest)^ := ((X shr 16) and $7f) + ((X shr 8) and $7f0000);
      Inc(NativeUInt(Dest), SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto process_not_ascii;
  end else
  begin
    process_not_ascii:
    {$ifdef CPUX86}Lookup := Pointer(LowerCase);{$endif}

    small_4:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(LowerCase){$endif}[Byte(X)];
      X := X shr 8;
      Inc(Dest);
    small_3:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(LowerCase){$endif}[Byte(X)];
      X := X shr 8;
      Inc(Dest);
    small_2:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(LowerCase){$endif}[Byte(X)];
      X := X shr 8;
      Inc(Dest);
    small_1:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(LowerCase){$endif}[Byte(X)];
      Inc(Dest);
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  goto small_4;

small_length:
  {$ifdef CPUX86}Lookup := Pointer(LowerCase);{$endif}
  case (NativeUInt(Src) - {$ifdef CPUX86}Store.{$endif}TopSrc) of
   3{1}: begin
           X := PByte(Src)^;
           goto small_1;
         end;
   2{2}: begin
           X := PWord(Src)^;
           goto small_2;
         end;
   1{3}: begin
           X := P4Bytes(Src)[2];
           X := (X shl 16) or PWord(Src)^;
           goto small_3;
         end;
  end;
end;

// result = length
procedure utf16_from_sbcs_upper(Dest: PUnicodeChar; Src: PAnsiChar; Length: NativeUInt; UpperCase: PTextConvUS);
label
  process4, process_not_ascii,
  small_4, small_3, small_2, small_1,
  small_length;
var
  {$ifdef CPUX86}
  Store: record
    TopSrc: NativeUInt;
  end;
  {$endif}

  X, U, V: NativeUInt;
  {$ifdef CPUX86}
  Lookup: PTextConvWB;
  {$else}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_60 = MASK_60_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_60, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  if (Length = 0) then Exit;
  // store parameters
  Inc(Length, NativeUInt(Src));
  Dec(Length, SizeOf(Cardinal));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_60 := MASK_60_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_60;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X - ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));

      PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
      Inc(NativeUInt(Dest), SizeOf(Cardinal));
      PCardinal(Dest)^ := ((X shr 16) and $7f) + ((X shr 8) and $7f0000);
      Inc(NativeUInt(Dest), SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto process_not_ascii;
  end else
  begin
    process_not_ascii:
    {$ifdef CPUX86}Lookup := Pointer(UpperCase);{$endif}

    small_4:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(UpperCase){$endif}[Byte(X)];
      X := X shr 8;
      Inc(Dest);
    small_3:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(UpperCase){$endif}[Byte(X)];
      X := X shr 8;
      Inc(Dest);
    small_2:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(UpperCase){$endif}[Byte(X)];
      X := X shr 8;
      Inc(Dest);
    small_1:
      Inc(Src);
      PWord(Dest)^ := {$ifdef CPUX86}Lookup{$else}PTextConvWB(UpperCase){$endif}[Byte(X)];
      Inc(Dest);
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  goto small_4;

small_length:
  {$ifdef CPUX86}Lookup := Pointer(UpperCase);{$endif}
  case (NativeUInt(Src) - {$ifdef CPUX86}Store.{$endif}TopSrc) of
   3{1}: begin
           X := PByte(Src)^;
           goto small_1;
         end;
   2{2}: begin
           X := PWord(Src)^;
           goto small_2;
         end;
   1{3}: begin
           X := P4Bytes(Src)[2];
           X := (X shl 16) or PWord(Src)^;
           goto small_3;
         end;
  end;
end;

function TTextConvContext.convert_sbcs_from_utf16: NativeInt;
type
  // result = min: length/2; max: length
  TCallback = function(Dest: PAnsiChar; Src: PUnicodeChar; Length: NativeUInt; Converter: PTextConvSU): NativeUInt;
const
  SMALL_SRC_SIZE = MAX_UTF16CHAR_SIZE;
  SMALL_DEST_SIZE = SMALL_SRC_SIZE div SizeOf(UnicodeChar);
  SMALL_CONVERSION_FLAGS = FLAG_USE_CONVERTER or FLAG_SOURCE_UTF16;
var
  DestSize, SrcSize: NativeUInt;
  Length, Value: NativeUInt;
  {$ifdef CPUX86}
  _Self: PTextConvContext;
  {$endif}
  Done: Boolean;

  FStore: record
    Options: TExtendedConversionOptions;
    SourceTop: Pointer;
    {$ifdef CPUX86}
    Self: PTextConvContext;
    {$endif}
  end;
begin
  // store parameters
  {$ifdef CPUX86}
  FStore.Self := @Self;
  {$endif}
  FStore.Options.Source := Self.Source;
  FStore.Options.Destination := Self.Destination;
  FStore.Options.Callback := Self.FCallbacks.ReaderWriter;
  FStore.Options.Converter := Self.FCallbacks.Converter;

  SrcSize := Self.SourceSize;
  DestSize := Self.DestinationSize;
  FStore.SourceTop := Pointer(NativeUInt(FStore.Options.Source) + SrcSize);

  // large source/destination
  // source length limit = Destination Length;
  if (SrcSize > SMALL_SRC_SIZE) and (DestSize > SMALL_DEST_SIZE) then
  repeat
    Length := DestSize;
    if (Length > SrcSize shr 1) then
    begin
      FStore.Options.Length := SrcSize shr 1;
    end else
    begin
      FStore.Options.Length := Length;
    end;

    // execute conversion
    Value := TCallback(FStore.Options.Callback)(
      FStore.Options.Destination, FStore.Options.Source,
      NativeUInt(@FStore.Options) + HIGH_NATIVE_BIT_VALUE,
      FStore.Options.Converter);
    Dec(DestSize, Value);
    SrcSize := NativeUInt(FStore.SourceTop) - NativeUInt(FStore.Options.Source);
  until (DestSize <= SMALL_DEST_SIZE) or (SrcSize <= SMALL_SRC_SIZE);

  // small source/destination
  if (SrcSize <> 0) then
  begin
    FStore.Options.SourceSize := SrcSize;
    FStore.Options.DestinationSize := DestSize;
    repeat
      if (SrcSize < SizeOf(UnicodeChar)) then
      begin
        Dec(SrcSize, SizeOf(UnicodeChar));
        Done := True;
      end else
      begin
        // if (Word(X) >= $d800) and (Word(X) < $dc00) then Length := 1;
        Length := Byte(NativeUInt(PWord(FStore.Options.Source)^) - $d800 < ($dc00-$d800));
        Done := SmallConversion(FStore.Options, Length{0/1} + 1, SMALL_CONVERSION_FLAGS);
        SrcSize := FStore.Options.SourceSize;
      end;
    until (Done);
  end;

  // result
  {$ifdef CPUX86}_Self := FStore.Self;{$endif}
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FDestinationWritten :=
     NativeUInt(FStore.Options.Destination) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FDestination);
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FSourceRead :=
     NativeUInt(FStore.Options.Source) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FSource);
  Result := SrcSize;
end;


// result = min: length/2; max: length
function sbcs_from_utf16(Dest: PAnsiChar; Src: PUnicodeChar; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt;
label
  process4, look_first, process_standard, process_character, unknown,
  small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  {$ifdef CPUX86}
    TopSrc: NativeUInt;
  {$endif}
  end;
  X, U: NativeUInt;

  {$ifNdef CPUX86}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUX86}
const
  MASK_FF80 = MASK_FF80_SMALL;
{$else .CPUX64/.CPUARM}
var
  MASK_FF80: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, Length);
  Inc(Length, NativeUInt(Src));
  Dec(Length, (2 * SizeOf(Cardinal)));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifNdef CPUX86}
  MASK_FF80 := {$ifdef LARGEINT}MASK_FF80_LARGE{$else}MASK_FF80_SMALL{$endif};
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then
  {$endif}
  begin
    repeat
    process4:
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

      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
    {$ifdef SMALLINT}
      X := PTextConvMB(Src)[0];
      U := PTextConvMB(Src)[1];
    until ((X or U) and Integer(MASK_FF80) <> 0);
    {$else}
      X := PNativeUInt(Src)^;
    until (X and MASK_FF80 <> 0);
    {$endif}
    goto look_first;
  end else
  begin
  look_first:
    {$ifdef LARGEINT}
    X := Cardinal(X);
    {$endif}
  process_standard:
    Inc(Src);
    U := Word(X);
    if (X and $FF80 = 0) then
    begin
      if (X and MASK_FF80 = 0) then
      begin
        // ascii_2
        X := X shr 8;
        Inc(Src);
        Inc(X, U);
        PWord(Dest)^ := X;
        Inc(Dest, 2);
      end else
      begin
        // ascii_1
        PByte(Dest)^ := X;
        Inc(Dest);
      end;
    end else
    if (U < $d800) then
    begin
    process_character:
      PByte(Dest)^ := PTextConvBW(Converter)[U];
      Inc(Dest);
    end else
    begin
      if (U >= $e000) then goto process_character;
    unknown:
      PByte(Dest)^ := UNKNOWN_CHARACTER;
      Inc(Dest);
    end;
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then goto process4;
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then goto process4;
  {$endif}
  goto look_first;

small_length:
  U := {$ifdef CPUX86}Store.{$endif}TopSrc + (2 * SizeOf(Cardinal));
  if (U = NativeUInt(Src)) then goto done;
  Dec(U, NativeUInt(Src));
  if (U >= SizeOf(Cardinal)) then
  begin
    X := PCardinal(Src)^;
    goto process_standard;
  end;
  U := PWord(Src)^;
  Inc(Src);
  if (U < $d800) then goto process_character;
  if (U >= $e000) then goto process_character;
  if (U >= $dc00) then goto unknown;

  Options := Store.Options;
  if (Options <> nil) then goto done_extended;
  PByte(Dest)^ := UNKNOWN_CHARACTER;
  Inc(Dest);
  goto done_standard;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

// result = min: length/2; max: length
function sbcs_from_utf16_lower(Dest: PAnsiChar; Src: PUnicodeChar; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt;
label
  process4, look_first, process_standard, process_character, unknown,
  small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  {$ifdef CPUX86}
    TopSrc: NativeUInt;
  {$endif}
  end;
  X, U, V: NativeUInt;

  {$ifNdef CPUX86}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_40 = MASK_40_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;

  {$ifdef CPUX86}
  MASK_FF80 = MASK_FF80_SMALL;
  {$else .CPUX64}
var
  MASK_FF80: NativeUInt;
  {$endif}
{$else .CPUARM}
var
  MASK_80, MASK_40, MASK_65, MASK_7F, MASK_FF80: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, Length);
  Inc(Length, NativeUInt(Src));
  Dec(Length, (2 * SizeOf(Cardinal)));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
    {$ifdef SMALLINT}
      MASK_FF80 := MASK_FF80_SMALL;
    {$endif}
  {$endif}
  {$ifdef LARGEINT}
    MASK_FF80 := MASK_FF80_LARGE;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then
  {$endif}
  begin
    repeat
    process4:
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

      U := X xor MASK_40;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X + ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
    {$ifdef SMALLINT}
      X := PTextConvMB(Src)[0];
      U := PTextConvMB(Src)[1];
    until ((X or U) and Integer(MASK_FF80) <> 0);
    {$else}
      X := PNativeUInt(Src)^;
    until (X and MASK_FF80 <> 0);
    {$endif}
    goto look_first;
  end else
  begin
  look_first:
    {$ifdef LARGEINT}
    X := Cardinal(X);
    {$endif}
  process_standard:
    Inc(Src);
    U := Word(X);
    if (X and $FF80 = 0) then
    begin
      if (X and MASK_FF80 = 0) then
      begin
        // ascii_2
        Inc(Src);
        X := X shr 16;
        U := TEXTCONV_CHARCASE.VALUES[U];
        X := TEXTCONV_CHARCASE.VALUES[X];
        X := X shl 8;
        Inc(X, U);
        PWord(Dest)^ := X;
        Inc(Dest, 2);
      end else
      begin
        // ascii_1
        PByte(Dest)^ := TEXTCONV_CHARCASE.VALUES[U];
        Inc(Dest);
      end;
    end else
    if (U < $d800) then
    begin
    process_character:
      X := TEXTCONV_CHARCASE.VALUES[U];
      PByte(Dest)^ := PTextConvBW(Converter)[X];
      Inc(Dest);
    end else
    begin
      if (U >= $e000) then goto process_character;
    unknown:
      PByte(Dest)^ := UNKNOWN_CHARACTER;
      Inc(Dest);
    end;
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then goto process4;
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then goto process4;
  {$endif}
  goto look_first;

small_length:
  U := {$ifdef CPUX86}Store.{$endif}TopSrc + (2 * SizeOf(Cardinal));
  if (U = NativeUInt(Src)) then goto done;
  Dec(U, NativeUInt(Src));
  if (U >= SizeOf(Cardinal)) then
  begin
    X := PCardinal(Src)^;
    goto process_standard;
  end;
  U := PWord(Src)^;
  Inc(Src);
  if (U < $d800) then goto process_character;
  if (U >= $e000) then goto process_character;
  if (U >= $dc00) then goto unknown;

  Options := Store.Options;
  if (Options <> nil) then goto done_extended;
  PByte(Dest)^ := UNKNOWN_CHARACTER;
  Inc(Dest);
  goto done_standard;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

// result = min: length/2; max: length
function sbcs_from_utf16_upper(Dest: PAnsiChar; Src: PUnicodeChar; Length: NativeUInt; Converter: PTextConvSBCSValues): NativeUInt;
label
  process4, look_first, process_standard, process_character, unknown,
  small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  {$ifdef CPUX86}
    TopSrc: NativeUInt;
  {$endif}
  end;
  X, U, V: NativeUInt;

  {$ifNdef CPUX86}
  TopSrc: NativeUInt;
  {$endif}

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_60 = MASK_60_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;

  {$ifdef CPUX86}
  MASK_FF80 = MASK_FF80_SMALL;
  {$else .CPUX64}
var
  MASK_FF80: NativeUInt;
  {$endif}
{$else .CPUARM}
var
  MASK_80, MASK_60, MASK_65, MASK_7F, MASK_FF80: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, Length);
  Inc(Length, NativeUInt(Src));
  Dec(Length, (2 * SizeOf(Cardinal)));
  {$ifdef CPUX86}Store.{$endif}TopSrc := Length;

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_60 := MASK_60_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
    {$ifdef SMALLINT}
      MASK_FF80 := MASK_FF80_SMALL;
    {$endif}
  {$endif}
  {$ifdef LARGEINT}
    MASK_FF80 := MASK_FF80_LARGE;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then
  {$endif}
  begin
    repeat
    process4:
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

      U := X xor MASK_60;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X - ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
    {$ifdef SMALLINT}
      X := PTextConvMB(Src)[0];
      U := PTextConvMB(Src)[1];
    until ((X or U) and Integer(MASK_FF80) <> 0);
    {$else}
      X := PNativeUInt(Src)^;
    until (X and MASK_FF80 <> 0);
    {$endif}
    goto look_first;
  end else
  begin
  look_first:
    {$ifdef LARGEINT}
    X := Cardinal(X);
    {$endif}
  process_standard:
    Inc(Src);
    U := Word(X);
    if (X and $FF80 = 0) then
    begin
      if (X and MASK_FF80 = 0) then
      begin
        // ascii_2
        Inc(Src);
        X := X shr 16;
        U := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + U];
        X := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + X];
        X := X shl 8;
        Inc(X, U);
        PWord(Dest)^ := X;
        Inc(Dest, 2);
      end else
      begin
        // ascii_1
        PByte(Dest)^ := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + U];
        Inc(Dest);
      end;
    end else
    if (U < $d800) then
    begin
    process_character:
      X := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + U];
      PByte(Dest)^ := PTextConvBW(Converter)[X];
      Inc(Dest);
    end else
    begin
      if (U >= $e000) then goto process_character;
    unknown:
      PByte(Dest)^ := UNKNOWN_CHARACTER;
      Inc(Dest);
    end;
  end;

  if (NativeUInt(Src) > {$ifdef CPUX86}Store.{$endif}TopSrc) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then goto process4;
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then goto process4;
  {$endif}
  goto look_first;

small_length:
  U := {$ifdef CPUX86}Store.{$endif}TopSrc + (2 * SizeOf(Cardinal));
  if (U = NativeUInt(Src)) then goto done;
  Dec(U, NativeUInt(Src));
  if (U >= SizeOf(Cardinal)) then
  begin
    X := PCardinal(Src)^;
    goto process_standard;
  end;
  U := PWord(Src)^;
  Inc(Src);
  if (U < $d800) then goto process_character;
  if (U >= $e000) then goto process_character;
  if (U >= $dc00) then goto unknown;

  Options := Store.Options;
  if (Options <> nil) then goto done_extended;
  PByte(Dest)^ := UNKNOWN_CHARACTER;
  Inc(Dest);
  goto done_standard;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

function TTextConvContext.convert_utf8_from_utf16: NativeInt;
type
  // result = min: length; max: length*3
  TCallback = function(Dest: PUTF8Char; Src: PUnicodeChar; Length: NativeUInt): NativeUInt;
const
  SMALL_SRC_SIZE = MAX_UTF16CHAR_SIZE;
  SMALL_DEST_SIZE = (MAX_UTF16CHAR_SIZE div SizeOf(UnicodeChar)) * 3;
  SMALL_CONVERSION_FLAGS = FLAG_SOURCE_UTF16;
var
  DestSize, SrcSize: NativeUInt;
  Length, Value: NativeUInt;
  {$ifdef CPUX86}
  _Self: PTextConvContext;
  {$endif}
  Done: Boolean;

  FStore: record
    Options: TExtendedConversionOptions;
    SourceTop: Pointer;
    {$ifdef CPUX86}
    Self: PTextConvContext;
    {$endif}
  end;
begin
  // store parameters
  {$ifdef CPUX86}
  FStore.Self := @Self;
  {$endif}
  FStore.Options.Source := Self.Source;
  FStore.Options.Destination := Self.Destination;
  FStore.Options.Callback := Self.FCallbacks.ReaderWriter;
  // FStore.Options.Converter := Self.FCallbacks.Converter;

  SrcSize := Self.SourceSize;
  DestSize := Self.DestinationSize;
  FStore.SourceTop := Pointer(NativeUInt(FStore.Options.Source) + SrcSize);

  // large source/destination
  // source length limit = (Destination Length) div 3;
  if (SrcSize > SMALL_SRC_SIZE) and (DestSize > SMALL_DEST_SIZE) then
  repeat
    if (DestSize > DIV3_MAX_DIVIDEND) then
    begin
      Length := DestSize shr 2;
    end else
    begin
      Length := (NativeInt(DestSize) * DIV3_MUL_VALUE) shr DIV3_SHIFT;
    end;
    if (Length > SrcSize shr 1) then
    begin
      FStore.Options.Length := SrcSize shr 1;
    end else
    begin
      FStore.Options.Length := Length;
    end;

    // execute conversion
    Value := TCallback(FStore.Options.Callback)(
      FStore.Options.Destination, FStore.Options.Source,
      NativeUInt(@FStore.Options) + HIGH_NATIVE_BIT_VALUE);
    Dec(DestSize, Value);
    SrcSize := NativeUInt(FStore.SourceTop) - NativeUInt(FStore.Options.Source);
  until (DestSize <= SMALL_DEST_SIZE) or (SrcSize <= SMALL_SRC_SIZE);

  // small source/destination
  if (SrcSize <> 0) then
  begin
    FStore.Options.SourceSize := SrcSize;
    FStore.Options.DestinationSize := DestSize;
    repeat
      if (SrcSize < SizeOf(UnicodeChar)) then
      begin
        Dec(SrcSize, SizeOf(UnicodeChar));
        Done := True;
      end else
      begin
        // if (Word(X) >= $d800) and (Word(X) < $dc00) then Length := 1;
        Length := Byte(NativeUInt(PWord(FStore.Options.Source)^) - $d800 < ($dc00-$d800));
        Done := SmallConversion(FStore.Options, Length{0/1} + 1, SMALL_CONVERSION_FLAGS);
        SrcSize := FStore.Options.SourceSize;
      end;
    until (Done);
  end;

  // result
  {$ifdef CPUX86}_Self := FStore.Self;{$endif}
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FDestinationWritten :=
     NativeUInt(FStore.Options.Destination) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FDestination);
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FSourceRead :=
     NativeUInt(FStore.Options.Source) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FSource);
  Result := SrcSize;
end;


// result = min: length; max: length*3
function utf8_from_utf16(Dest: PUTF8Char; Src: PUnicodeChar; Length: NativeUInt): NativeUInt;
label
  process4, look_first, process_standard, process_character, unknown,
  small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  end;
  X, U: NativeUInt;

{$ifdef CPUX86}
const
  MASK_FF80 = MASK_FF80_SMALL;
{$else .CPUX64/.CPUARM}
var
  MASK_FF80: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, Length);
  Inc(Length, NativeUInt(Src));
  Dec(Length, (2 * SizeOf(Cardinal)));

  {$ifNdef CPUX86}
  MASK_FF80 := {$ifdef LARGEINT}MASK_FF80_LARGE{$else}MASK_FF80_SMALL{$endif};
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then
  {$endif}
  begin
    repeat
    process4:
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

      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
    {$ifdef SMALLINT}
      X := PTextConvMB(Src)[0];
      U := PTextConvMB(Src)[1];
    until ((X or U) and Integer(MASK_FF80) <> 0);
    {$else}
      X := PNativeUInt(Src)^;
    until (X and MASK_FF80 <> 0);
    {$endif}
    goto look_first;
  end else
  begin
  look_first:
    {$ifdef LARGEINT}
    X := Cardinal(X);
    {$endif}
  process_standard:
    Inc(Src);
    U := Word(X);
    if (X and $FF80 = 0) then
    begin
      if (X and MASK_FF80 = 0) then
      begin
        // ascii_2
        X := X shr 8;
        Inc(Src);
        Inc(X, U);
        PWord(Dest)^ := X;
        Inc(Dest, 2);
      end else
      begin
        // ascii_1
        PByte(Dest)^ := X;
        Inc(Dest);
      end;
    end else
    if (U < $d800) then
    begin
    process_character:
      if (U <= $7ff) then
      begin
        if (U > $7f) then
        begin
          X := (U shr 6) + $80C0;
          U := (U and $3f) shl 8;
          Inc(X, U);
          PWord(Dest)^ := X;
          Inc(Dest, 2);
        end else
        begin
          PByte(Dest)^ := U;
          Inc(Dest);
        end;
      end else
      begin
        X := (U and $0fc0) shl 2;
        Inc(X, (U and $3f) shl 16);
        U := (U shr 12);
        Inc(X, $8080E0);
        Inc(X, U);

        PWord(Dest)^ := X;
        Inc(Dest, 2);
        X := X shr 16;
        PByte(Dest)^ := X;
        Inc(Dest);
      end;
    end else
    begin
      if (U >= $e000) then goto process_character;
      if (U >= $dc00) then
      begin
      unknown:
        PByte(Dest)^ := UNKNOWN_CHARACTER;
        Inc(Dest);
      end else
      begin
        Inc(Src);
        X := X shr 16;
        Dec(U, $d800);
        Dec(X, $dc00);
        if (X >= ($e000-$dc00)) then goto unknown;

        U := U shl 10;
        Inc(X, $10000);
        Inc(X, U);

        U := (X and $3f) shl 24;
        U := U + ((X and $0fc0) shl 10);
        U := U + (X shr 18);
        X := (X shr 4) and $3f00;
        Inc(U, Integer($808080F0));
        Inc(X, U);

        PCardinal(Dest)^ := X;
        Inc(Dest, 4);
      end;
    end;
  end;

  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then goto process4;
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then goto process4;
  {$endif}
  goto look_first;

small_length:
  U := Length{TopSrc} + (2 * SizeOf(Cardinal));
  if (U = NativeUInt(Src)) then goto done;
  Dec(U, NativeUInt(Src));
  if (U >= SizeOf(Cardinal)) then
  begin
    X := PCardinal(Src)^;
    goto process_standard;
  end;
  U := PWord(Src)^;
  Inc(Src);
  if (U < $d800) then goto process_character;
  if (U >= $e000) then goto process_character;
  if (U >= $dc00) then goto unknown;

  Options := Store.Options;
  if (Options <> nil) then goto done_extended;
  PByte(Dest)^ := UNKNOWN_CHARACTER;
  Inc(Dest);
  goto done_standard;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

// result = min: length; max: length*3
function utf8_from_utf16_lower(Dest: PUTF8Char; Src: PUnicodeChar; Length: NativeUInt): NativeUInt;
label
  process4, look_first, process_standard, process_character, unknown,
  small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  end;
  X, U, V: NativeUInt;

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_40 = MASK_40_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;

  {$ifdef CPUX86}
  MASK_FF80 = MASK_FF80_SMALL;
  {$else .CPUX64}
var
  MASK_FF80: NativeUInt;
  {$endif}
{$else .CPUARM}
var
  MASK_80, MASK_40, MASK_65, MASK_7F, MASK_FF80: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, Length);
  Inc(Length, NativeUInt(Src));
  Dec(Length, (2 * SizeOf(Cardinal)));

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
    {$ifdef SMALLINT}
      MASK_FF80 := MASK_FF80_SMALL;
    {$endif}
  {$endif}
  {$ifdef LARGEINT}
    MASK_FF80 := MASK_FF80_LARGE;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then
  {$endif}
  begin
    repeat
    process4:
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

      U := X xor MASK_40;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X + ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
    {$ifdef SMALLINT}
      X := PTextConvMB(Src)[0];
      U := PTextConvMB(Src)[1];
    until ((X or U) and Integer(MASK_FF80) <> 0);
    {$else}
      X := PNativeUInt(Src)^;
    until (X and MASK_FF80 <> 0);
    {$endif}
    goto look_first;
  end else
  begin
  look_first:
    {$ifdef LARGEINT}
    X := Cardinal(X);
    {$endif}
  process_standard:
    Inc(Src);
    U := Word(X);
    if (X and $FF80 = 0) then
    begin
      if (X and MASK_FF80 = 0) then
      begin
        // ascii_2
        Inc(Src);
        X := X shr 16;
        U := TEXTCONV_CHARCASE.VALUES[U];
        X := TEXTCONV_CHARCASE.VALUES[X];
        X := X shl 8;
        Inc(X, U);
        PWord(Dest)^ := X;
        Inc(Dest, 2);
      end else
      begin
        // ascii_1
        PByte(Dest)^ := TEXTCONV_CHARCASE.VALUES[U];
        Inc(Dest);
      end;
    end else
    if (U < $d800) then
    begin
    process_character:
      X := TEXTCONV_CHARCASE.VALUES[U];

      if (X <= $7ff) then
      begin
        if (X > $7f) then
        begin
          U := X;
          X := (X shr 6) + $80C0;
          U := (U and $3f) shl 8;
          Inc(X, U);
          PWord(Dest)^ := X;
          Inc(Dest, 2);
        end else
        begin
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
      end else
      begin
        U := X;
        X := (X and $0fc0) shl 2;
        Inc(X, (U and $3f) shl 16);
        U := (U shr 12);
        Inc(X, $8080E0);
        Inc(X, U);

        PWord(Dest)^ := X;
        Inc(Dest, 2);
        X := X shr 16;
        PByte(Dest)^ := X;
        Inc(Dest);
      end;
    end else
    begin
      if (U >= $e000) then goto process_character;
      if (U >= $dc00) then
      begin
      unknown:
        PByte(Dest)^ := UNKNOWN_CHARACTER;
        Inc(Dest);
      end else
      begin
        Inc(Src);
        X := X shr 16;
        Dec(U, $d800);
        Dec(X, $dc00);
        if (X >= ($e000-$dc00)) then goto unknown;

        U := U shl 10;
        Inc(X, $10000);
        Inc(X, U);

        U := (X and $3f) shl 24;
        U := U + ((X and $0fc0) shl 10);
        U := U + (X shr 18);
        X := (X shr 4) and $3f00;
        Inc(U, Integer($808080F0));
        Inc(X, U);

        PCardinal(Dest)^ := X;
        Inc(Dest, 4);
      end;
    end;
  end;

  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then goto process4;
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then goto process4;
  {$endif}
  goto look_first;

small_length:
  U := Length{TopSrc} + (2 * SizeOf(Cardinal));
  if (U = NativeUInt(Src)) then goto done;
  Dec(U, NativeUInt(Src));
  if (U >= SizeOf(Cardinal)) then
  begin
    X := PCardinal(Src)^;
    goto process_standard;
  end;
  U := PWord(Src)^;
  Inc(Src);
  if (U < $d800) then goto process_character;
  if (U >= $e000) then goto process_character;
  if (U >= $dc00) then goto unknown;

  Options := Store.Options;
  if (Options <> nil) then goto done_extended;
  PByte(Dest)^ := UNKNOWN_CHARACTER;
  Inc(Dest);
  goto done_standard;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

// result = min: length; max: length*3
function utf8_from_utf16_upper(Dest: PUTF8Char; Src: PUnicodeChar; Length: NativeUInt): NativeUInt;
label
  process4, look_first, process_standard, process_character, unknown,
  small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  end;
  X, U, V: NativeUInt;

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_60 = MASK_60_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;

  {$ifdef CPUX86}
  MASK_FF80 = MASK_FF80_SMALL;
  {$else .CPUX64}
var
  MASK_FF80: NativeUInt;
  {$endif}
{$else .CPUARM}
var
  MASK_80, MASK_60, MASK_65, MASK_7F, MASK_FF80: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, Length);
  Inc(Length, NativeUInt(Src));
  Dec(Length, (2 * SizeOf(Cardinal)));

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_60 := MASK_60_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
    {$ifdef SMALLINT}
      MASK_FF80 := MASK_FF80_SMALL;
    {$endif}
  {$endif}
  {$ifdef LARGEINT}
    MASK_FF80 := MASK_FF80_LARGE;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then
  {$endif}
  begin
    repeat
    process4:
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

      U := X xor MASK_60;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X - ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));
      PCardinal(Dest)^ := X;
      Inc(Dest, SizeOf(Cardinal));

      if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
    {$ifdef SMALLINT}
      X := PTextConvMB(Src)[0];
      U := PTextConvMB(Src)[1];
    until ((X or U) and Integer(MASK_FF80) <> 0);
    {$else}
      X := PNativeUInt(Src)^;
    until (X and MASK_FF80 <> 0);
    {$endif}
    goto look_first;
  end else
  begin
  look_first:
    {$ifdef LARGEINT}
    X := Cardinal(X);
    {$endif}
  process_standard:
    Inc(Src);
    U := Word(X);
    if (X and $FF80 = 0) then
    begin
      if (X and MASK_FF80 = 0) then
      begin
        // ascii_2
        Inc(Src);
        X := X shr 16;
        U := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + U];
        X := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + X];
        X := X shl 8;
        Inc(X, U);
        PWord(Dest)^ := X;
        Inc(Dest, 2);
      end else
      begin
        // ascii_1
        PByte(Dest)^ := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + U];
        Inc(Dest);
      end;
    end else
    if (U < $d800) then
    begin
    process_character:
      X := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + U];

      if (X <= $7ff) then
      begin
        if (X > $7f) then
        begin
          U := X;
          X := (X shr 6) + $80C0;
          U := (U and $3f) shl 8;
          Inc(X, U);
          PWord(Dest)^ := X;
          Inc(Dest, 2);
        end else
        begin
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
      end else
      begin
        U := X;
        X := (X and $0fc0) shl 2;
        Inc(X, (U and $3f) shl 16);
        U := (U shr 12);
        Inc(X, $8080E0);
        Inc(X, U);

        PWord(Dest)^ := X;
        Inc(Dest, 2);
        X := X shr 16;
        PByte(Dest)^ := X;
        Inc(Dest);
      end;
    end else
    begin
      if (U >= $e000) then goto process_character;
      if (U >= $dc00) then
      begin
      unknown:
        PByte(Dest)^ := UNKNOWN_CHARACTER;
        Inc(Dest);
      end else
      begin
        Inc(Src);
        X := X shr 16;
        Dec(U, $d800);
        Dec(X, $dc00);
        if (X >= ($e000-$dc00)) then goto unknown;

        U := U shl 10;
        Inc(X, $10000);
        Inc(X, U);

        U := (X and $3f) shl 24;
        U := U + ((X and $0fc0) shl 10);
        U := U + (X shr 18);
        X := (X shr 4) and $3f00;
        Inc(U, Integer($808080F0));
        Inc(X, U);

        PCardinal(Dest)^ := X;
        Inc(Dest, 4);
      end;
    end;
  end;

  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  {$ifdef SMALLINT}
    X := PTextConvMB(Src)[0];
    U := PTextConvMB(Src)[1];
    if ((X or U) and Integer(MASK_FF80) = 0) then goto process4;
  {$else}
    X := PNativeUInt(Src)^;
    if (X and MASK_FF80 = 0) then goto process4;
  {$endif}
  goto look_first;

small_length:
  U := Length{TopSrc} + (2 * SizeOf(Cardinal));
  if (U = NativeUInt(Src)) then goto done;
  Dec(U, NativeUInt(Src));
  if (U >= SizeOf(Cardinal)) then
  begin
    X := PCardinal(Src)^;
    goto process_standard;
  end;
  U := PWord(Src)^;
  Inc(Src);
  if (U < $d800) then goto process_character;
  if (U >= $e000) then goto process_character;
  if (U >= $dc00) then goto unknown;

  Options := Store.Options;
  if (Options <> nil) then goto done_extended;
  PByte(Dest)^ := UNKNOWN_CHARACTER;
  Inc(Dest);
  goto done_standard;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := NativeUInt(Dest) - NativeUInt(Options.Destination);
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := NativeUInt(Dest) - NativeUInt(Store.Dest);
  end;
end;

function TTextConvContext.convert_utf16_from_utf8: NativeInt;
type
  // result = min: length/3; max: length
  TCallback = function(Dest: PUnicodeChar; Src: PUTF8Char; Length: NativeUInt): NativeUInt;
const
  SMALL_SRC_SIZE = MAX_UTF8CHAR_SIZE;
  SMALL_DEST_SIZE = SMALL_SRC_SIZE * SizeOf(UnicodeChar);
  SMALL_CONVERSION_FLAGS = FLAG_DESTINATION_UTF16;
var
  DestSize, SrcSize: NativeUInt;
  Length, Value: NativeUInt;
  {$ifdef CPUX86}
  _Self: PTextConvContext;
  {$endif}
  Done: Boolean;

  FStore: record
    Options: TExtendedConversionOptions;
    SourceTop: Pointer;
    {$ifdef CPUX86}
    Self: PTextConvContext;
    {$endif}
  end;
begin
  // store parameters
  {$ifdef CPUX86}
  FStore.Self := @Self;
  {$endif}
  FStore.Options.Source := Self.Source;
  FStore.Options.Destination := Self.Destination;
  FStore.Options.Callback := Self.FCallbacks.ReaderWriter;
  // FStore.Options.Converter := Self.FCallbacks.Converter;

  SrcSize := Self.SourceSize;
  DestSize := Self.DestinationSize;
  FStore.SourceTop := Pointer(NativeUInt(FStore.Options.Source) + SrcSize);

  // large source/destination
  // source length limit = Destination Length;
  if (SrcSize > SMALL_SRC_SIZE) and (DestSize > SMALL_DEST_SIZE) then
  repeat
    Length := DestSize shr 1;
    if (Length > SrcSize) then
    begin
      FStore.Options.Length := SrcSize;
    end else
    begin
      FStore.Options.Length := Length;
    end;

    // execute conversion
    Value := TCallback(FStore.Options.Callback)(
      FStore.Options.Destination, FStore.Options.Source,
      NativeUInt(@FStore.Options) + HIGH_NATIVE_BIT_VALUE);
    Dec(DestSize, Value);
    SrcSize := NativeUInt(FStore.SourceTop) - NativeUInt(FStore.Options.Source);
  until (DestSize <= SMALL_DEST_SIZE) or (SrcSize <= SMALL_SRC_SIZE);

  // small source/destination
  if (SrcSize <> 0) then
  begin
    FStore.Options.SourceSize := SrcSize;
    FStore.Options.DestinationSize := DestSize;
    repeat
      Length := TEXTCONV_UTF8CHAR_SIZE[PByte(FStore.Options.Source)^];
      Done := SmallConversion(FStore.Options, Length + Byte(Length = 0), SMALL_CONVERSION_FLAGS);
      SrcSize := FStore.Options.SourceSize;
    until (Done);
  end;

  // result
  {$ifdef CPUX86}_Self := FStore.Self;{$endif}
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FDestinationWritten :=
     NativeUInt(FStore.Options.Destination) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FDestination);
  {$ifdef CPUX86}_Self{$else}Self{$endif}.FSourceRead :=
     NativeUInt(FStore.Options.Source) - NativeUInt({$ifdef CPUX86}_Self{$else}Self{$endif}.FSource);
  Result := SrcSize;
end;

// result = min: length/3; max: length
function utf16_from_utf8(Dest: PUnicodeChar; Src: PUTF8Char; Length: NativeUInt): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_standard, process_character, unknown,
  next_iteration, small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  end;
  X, U: NativeUInt;

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
{$else .CPUARM}
var
  MASK_80: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, MAX_UTF8CHAR_SIZE);

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      Inc(Src, SizeOf(Cardinal));

      {$ifNdef LARGEINT}
        PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
        X := X shr 16;
        Inc(Dest, 2);
        PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
        Inc(Dest, 2);
      {$else}
        PNativeUInt(Dest)^ := (X and $7f) + ((X and $7f00) shl 8) +
          ((X and $7f0000) shl 16) + ((X and $7f000000) shl 24);
        Inc(NativeUInt(Dest), SizeOf(NativeUInt));
      {$endif}

      if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      {$ifNdef LARGEINT}
        PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
        Inc(Dest, 2);
        PCardinal(Dest)^ := ((X shr 16) and $7f);
      {$else}
        PNativeUInt(Dest)^ := (X and $7f) + ((X and $7f00) shl 8) +
          ((X and $7f0000) shl 16);
      {$endif}

      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        Inc(Src, 3);
        Inc(Dest, 3{$ifdef SMALLINT}- 2{$endif});
        goto next_iteration;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        {$ifdef LARGEINT}Inc(Dest, 2);{$endif}
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 2) then goto process_standard;
        goto next_iteration;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest, 1{$ifdef SMALLINT}- 2{$endif});
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 3) then goto process_standard;
        // goto next_iteration;
    end else
    begin
    process_standard:
      if (X and $C0E0 = $80C0) then
      begin
        X := ((X and $1F) shl 6) + ((X shr 8) and $3F);
        Inc(Src, 2);

      process_character:
        PWord(Dest)^ := X;
        Inc(Dest);
      end else
      begin
        U := TEXTCONV_UTF8CHAR_SIZE[Byte(X)];
        case (U) of
          1:
          begin
            X := X and $7f;
            Inc(Src);
            PWord(Dest)^ := X;
            Inc(Dest);
          end;
          3:
          begin
            if (X and $C0C000 = $808000) then
            begin
              U := (X and $0F) shl 12;
              U := U + (X shr 16) and $3F;
              X := (X and $3F00) shr 2;
              Inc(Src, 3);
              Inc(X, U);
              if (U shr 11 = $1B) then X := $fffd;
              PWord(Dest)^ := X;
              Inc(Dest);
              goto next_iteration;
            end;
            goto unknown;
          end;
          4:
          begin
            if (X and $C0C0C000 = $80808000) then
            begin
              U := (X and $07) shl 18;
              U := U + (X and $3f00) shl 4;
              U := U + (X shr 10) and $0fc0;
              X := (X shr 24) and $3f;
              Inc(X, U);

              U := (X - $10000) shr 10 + $d800;
              X := (X - $10000) and $3ff + $dc00;
              X := (X shl 16) + U;

              PCardinal(Dest)^ := X;
              Inc(Dest, 2);
              goto next_iteration;
            end;
            goto unknown;
          end;
        else
        unknown:
          PWord(Dest)^ := UNKNOWN_CHARACTER;
          Inc(Dest);
          Inc(Src, U);
          Inc(Src, NativeUInt(U = 0));
        end;
      end;
    end;
  end;

next_iteration:
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_standard;

small_length:
  U := Length{TopSrc} + MAX_UTF8CHAR_SIZE;
  if (U = NativeUInt(Src)) then goto done;
  X := PByte(Src)^;
  if (X <= $7f) then
  begin
    PWord(Dest)^ := X;
    Inc(Src);
    Inc(Dest);
    if (NativeUInt(Src) <> Length{TopSrc}) then goto small_length;
    goto done;
  end;
  X := TEXTCONV_UTF8CHAR_SIZE[X];
  Dec(U, NativeUInt(Src));
  if (X{char size} > U{available source length}) then
  begin
    Options := Store.Options;
    if (Options <> nil) then goto done_extended;
    PWord(Dest)^ := UNKNOWN_CHARACTER;
    Inc(Dest);
    goto done_standard;
  end;

  case X{char size} of
    2:
    begin
      X := PWord(Src)^;
      goto process_standard;
    end;
    3:
    begin
      X := P4Bytes(Src)[2];
      X := (X shl 16) or PWord(Src)^;
      goto process_standard;
    end;
  else
    // 4..5
    goto unknown;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := (NativeUInt(Dest) - NativeUInt(Options.Destination)) shr 1;
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := (NativeUInt(Dest) - NativeUInt(Store.Dest)) shr 1;
  end;
end;

// result = min: length/3; max: length
function utf16_from_utf8_lower(Dest: PUnicodeChar; Src: PUTF8Char; Length: NativeUInt): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_standard, process_character, unknown,
  next_iteration, small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  end;

  X, U, V: NativeUInt;
  StoredX: NativeUInt;

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_40 = MASK_40_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_40, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, MAX_UTF8CHAR_SIZE);

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_40;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X + ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));

      {$ifNdef LARGEINT}
        PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
        X := X shr 16;
        Inc(Dest, 2);
        PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
        Inc(Dest, 2);
      {$else}
        PNativeUInt(Dest)^ := (X and $7f) + ((X and $7f00) shl 8) +
          ((X and $7f0000) shl 16) + ((X and $7f000000) shl 24);
        Inc(NativeUInt(Dest), SizeOf(NativeUInt));
      {$endif}

      if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      StoredX := X;
        X := X and Integer(MASK_7F);
        U := X xor MASK_40;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X + ((not V) and U) shr 2;
      {$ifNdef LARGEINT}
        PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
        Inc(Dest, 2);
        PCardinal(Dest)^ := ((X shr 16) and $7f);
      {$else}
        PNativeUInt(Dest)^ := (X and $7f) + ((X and $7f00) shl 8) +
          ((X and $7f0000) shl 16);
      {$endif}
      X := StoredX;

      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        Inc(Src, 3);
        Inc(Dest, 3{$ifdef SMALLINT}- 2{$endif});
        goto next_iteration;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        {$ifdef LARGEINT}Inc(Dest, 2);{$endif}
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 2) then goto process_standard;
        goto next_iteration;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest, 1{$ifdef SMALLINT}- 2{$endif});
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 3) then goto process_standard;
        // goto next_iteration;
    end else
    begin
    process_standard:
      if (X and $C0E0 = $80C0) then
      begin
        X := ((X and $1F) shl 6) + ((X shr 8) and $3F);
        Inc(Src, 2);

      process_character:
        PWord(Dest)^ := TEXTCONV_CHARCASE.VALUES[X];
        Inc(Dest);
      end else
      begin
        U := TEXTCONV_UTF8CHAR_SIZE[Byte(X)];
        case (U) of
          1:
          begin
            X := X and $7f;
            Inc(Src);
            goto process_character;
          end;
          3:
          begin
            if (X and $C0C000 = $808000) then
            begin
              U := (X and $0F) shl 12;
              U := U + (X shr 16) and $3F;
              X := (X and $3F00) shr 2;
              Inc(Src, 3);
              Inc(X, U);
              if (U shr 11 <> $1B) then goto process_character;
              PWord(Dest)^ := $fffd;
              Inc(Dest);
              goto next_iteration;
            end;
            goto unknown;
          end;
          4:
          begin
            if (X and $C0C0C000 = $80808000) then
            begin
              U := (X and $07) shl 18;
              U := U + (X and $3f00) shl 4;
              U := U + (X shr 10) and $0fc0;
              X := (X shr 24) and $3f;
              Inc(X, U);

              U := (X - $10000) shr 10 + $d800;
              X := (X - $10000) and $3ff + $dc00;
              X := (X shl 16) + U;

              PCardinal(Dest)^ := X;
              Inc(Dest, 2);
              goto next_iteration;
            end;
            goto unknown;
          end;
        else
        unknown:
          PWord(Dest)^ := UNKNOWN_CHARACTER;
          Inc(Dest);
          Inc(Src, U);
          Inc(Src, NativeUInt(U = 0));
        end;
      end;
    end;
  end;

next_iteration:
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_standard;

small_length:
  U := Length{TopSrc} + MAX_UTF8CHAR_SIZE;
  if (U = NativeUInt(Src)) then goto done;
  X := PByte(Src)^;
  if (X <= $7f) then
  begin
    PWord(Dest)^ := TEXTCONV_CHARCASE.VALUES[X];
    Inc(Src);
    Inc(Dest);
    if (NativeUInt(Src) <> Length{TopSrc}) then goto small_length;
    goto done;
  end;
  X := TEXTCONV_UTF8CHAR_SIZE[X];
  Dec(U, NativeUInt(Src));
  if (X{char size} > U{available source length}) then
  begin
    Options := Store.Options;
    if (Options <> nil) then goto done_extended;
    PWord(Dest)^ := UNKNOWN_CHARACTER;
    Inc(Dest);
    goto done_standard;
  end;

  case X{char size} of
    2:
    begin
      X := PWord(Src)^;
      goto process_standard;
    end;
    3:
    begin
      X := P4Bytes(Src)[2];
      X := (X shl 16) or PWord(Src)^;
      goto process_standard;
    end;
  else
    // 4..5
    goto unknown;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := (NativeUInt(Dest) - NativeUInt(Options.Destination)) shr 1;
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := (NativeUInt(Dest) - NativeUInt(Store.Dest)) shr 1;
  end;
end;

// result = min: length/3; max: length
function utf16_from_utf8_upper(Dest: PUnicodeChar; Src: PUTF8Char; Length: NativeUInt): NativeUInt;
label
  process4, look_first, process1_3,
  ascii_1, ascii_2, ascii_3,
  process_standard, process_character, unknown,
  next_iteration, small_length, done, done_extended, done_standard;
var
  Options: PExtendedConversionOptions;
  Store: record
    Options: PExtendedConversionOptions;
    Dest: Pointer;
  end;

  X, U, V: NativeUInt;
  StoredX: NativeUInt;

{$ifdef CPUINTEL}
const
  MASK_80 = MASK_80_SMALL;
  MASK_60 = MASK_60_SMALL;
  MASK_65 = MASK_65_SMALL;
  MASK_7F = MASK_7F_SMALL;
{$else .CPUARM}
var
  MASK_80, MASK_60, MASK_65, MASK_7F: NativeUInt;
{$endif}
begin
  // extended options
  if (NativeInt(Length) < 0) then
  begin
    Length := Length and (HIGH_NATIVE_BIT_VALUE - 1);
    Store.Options := PExtendedConversionOptions(Length);
    Length := PExtendedConversionOptions(Length).Length;
  end else
  begin
    Store.Dest := Dest;
    Store.Options := nil;
  end;
  if (Length = 0) then goto done;
  Inc(Length, NativeUInt(Src));
  Dec(Length, MAX_UTF8CHAR_SIZE);

  {$ifdef CPUARM}
    MASK_80 := MASK_80_SMALL;
    MASK_60 := MASK_60_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  // conversion loop
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then
  begin
    repeat
    process4:
      U := X xor MASK_60;
      V := (U + MASK_65);
      U := (U + MASK_7F) and Integer(MASK_80);
      X := X - ((not V) and U) shr 2;
      Inc(Src, SizeOf(Cardinal));

      {$ifNdef LARGEINT}
        PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
        X := X shr 16;
        Inc(Dest, 2);
        PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
        Inc(Dest, 2);
      {$else}
        PNativeUInt(Dest)^ := (X and $7f) + ((X and $7f00) shl 8) +
          ((X and $7f0000) shl 16) + ((X and $7f000000) shl 24);
        Inc(NativeUInt(Dest), SizeOf(NativeUInt));
      {$endif}

      if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
      X := PCardinal(Src)^;
    until (X and Integer(MASK_80) <> 0);
    goto look_first;
  end else
  begin
  look_first:
    if (X and $80 = 0) then
    begin
    process1_3:
      StoredX := X;
        X := X and Integer(MASK_7F);
        U := X xor MASK_60;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X - ((not V) and U) shr 2;
      {$ifNdef LARGEINT}
        PCardinal(Dest)^ := (X and $7f) + ((X and $7f00) shl 8);
        Inc(Dest, 2);
        PCardinal(Dest)^ := ((X shr 16) and $7f);
      {$else}
        PNativeUInt(Dest)^ := (X and $7f) + ((X and $7f00) shl 8) +
          ((X and $7f0000) shl 16);
      {$endif}
      X := StoredX;

      if (X and $8000 <> 0) then goto ascii_1;
      if (X and $800000 <> 0) then goto ascii_2;
      ascii_3:
        Inc(Src, 3);
        Inc(Dest, 3{$ifdef SMALLINT}- 2{$endif});
        goto next_iteration;
      ascii_2:
        X := X shr 16;
        Inc(Src, 2);
        {$ifdef LARGEINT}Inc(Dest, 2);{$endif}
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 2) then goto process_standard;
        goto next_iteration;
      ascii_1:
        X := X shr 8;
        Inc(Src);
        Inc(Dest, 1{$ifdef SMALLINT}- 2{$endif});
        if (TEXTCONV_UTF8CHAR_SIZE[Byte(X)] <= 3) then goto process_standard;
        // goto next_iteration;
    end else
    begin
    process_standard:
      if (X and $C0E0 = $80C0) then
      begin
        X := ((X and $1F) shl 6) + ((X shr 8) and $3F);
        Inc(Src, 2);

      process_character:
        PWord(Dest)^ := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + X];
        Inc(Dest);
      end else
      begin
        U := TEXTCONV_UTF8CHAR_SIZE[Byte(X)];
        case (U) of
          1:
          begin
            X := X and $7f;
            Inc(Src);
            goto process_character;
          end;
          3:
          begin
            if (X and $C0C000 = $808000) then
            begin
              U := (X and $0F) shl 12;
              U := U + (X shr 16) and $3F;
              X := (X and $3F00) shr 2;
              Inc(Src, 3);
              Inc(X, U);
              if (U shr 11 <> $1B) then goto process_character;
              PWord(Dest)^ := $fffd;
              Inc(Dest);
              goto next_iteration;
            end;
            goto unknown;
          end;
          4:
          begin
            if (X and $C0C0C000 = $80808000) then
            begin
              U := (X and $07) shl 18;
              U := U + (X and $3f00) shl 4;
              U := U + (X shr 10) and $0fc0;
              X := (X shr 24) and $3f;
              Inc(X, U);

              U := (X - $10000) shr 10 + $d800;
              X := (X - $10000) and $3ff + $dc00;
              X := (X shl 16) + U;

              PCardinal(Dest)^ := X;
              Inc(Dest, 2);
              goto next_iteration;
            end;
            goto unknown;
          end;
        else
        unknown:
          PWord(Dest)^ := UNKNOWN_CHARACTER;
          Inc(Dest);
          Inc(Src, U);
          Inc(Src, NativeUInt(U = 0));
        end;
      end;
    end;
  end;

next_iteration:
  if (NativeUInt(Src) > Length{TopSrc}) then goto small_length;
  X := PCardinal(Src)^;
  if (X and Integer(MASK_80) = 0) then goto process4;
  if (X and $80 = 0) then goto process1_3;
  goto process_standard;

small_length:
  U := Length{TopSrc} + MAX_UTF8CHAR_SIZE;
  if (U = NativeUInt(Src)) then goto done;
  X := PByte(Src)^;
  if (X <= $7f) then
  begin
    PWord(Dest)^ := TEXTCONV_CHARCASE.VALUES[CHARCASE_OFFSET + X];
    Inc(Src);
    Inc(Dest);
    if (NativeUInt(Src) <> Length{TopSrc}) then goto small_length;
    goto done;
  end;
  X := TEXTCONV_UTF8CHAR_SIZE[X];
  Dec(U, NativeUInt(Src));
  if (X{char size} > U{available source length}) then
  begin
    Options := Store.Options;
    if (Options <> nil) then goto done_extended;
    PWord(Dest)^ := UNKNOWN_CHARACTER;
    Inc(Dest);
    goto done_standard;
  end;

  case X{char size} of
    2:
    begin
      X := PWord(Src)^;
      goto process_standard;
    end;
    3:
    begin
      X := P4Bytes(Src)[2];
      X := (X shl 16) or PWord(Src)^;
      goto process_standard;
    end;
  else
    // 4..5
    goto unknown;
  end;

  // result
done:
  Options := Store.Options;
  if (Options <> nil) then
  begin
  done_extended:
    Options.Source := Src;
    Result := (NativeUInt(Dest) - NativeUInt(Options.Destination)) shr 1;
    Options.Destination := Dest;
  end else
  begin
  done_standard:
    Result := (NativeUInt(Dest) - NativeUInt(Store.Dest)) shr 1;
  end;
end;
{$ifdef undef}{$ENDREGION}{$endif}

{$ifdef undef}{$REGION 'difficult context readers and writers'}{$endif}
function TTextConvContext.utf1_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
const
  U: array[0..256-1] of Byte = (
  $be, $bf, $c0, $c1, $c2, $c3, $c4, $c5,
  $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd,
  $ce, $cf, $d0, $d1, $d2, $d3, $d4, $d5,
  $d6, $d7, $d8, $d9, $da, $db, $dc, $dd,
  $de, $00, $01, $02, $03, $04, $05, $06,
  $07, $08, $09, $0a, $0b, $0c, $0d, $0e,
  $0f, $10, $11, $12, $13, $14, $15, $16,
  $17, $18, $19, $1a, $1b, $1c, $1d, $1e,
  $1f, $20, $21, $22, $23, $24, $25, $26,
  $27, $28, $29, $2a, $2b, $2c, $2d, $2e,
  $2f, $30, $31, $32, $33, $34, $35, $36,
  $37, $38, $39, $3a, $3b, $3c, $3d, $3e,
  $3f, $40, $41, $42, $43, $44, $45, $46,
  $47, $48, $49, $4a, $4b, $4c, $4d, $4e,
  $4f, $50, $51, $52, $53, $54, $55, $56,
  $57, $58, $59, $5a, $5b, $5c, $5d, $df,
  $e0, $e1, $e2, $e3, $e4, $e5, $e6, $e7,
  $e8, $e9, $ea, $eb, $ec, $ed, $ee, $ef,
  $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7,
  $f8, $f9, $fa, $fb, $fc, $fd, $fe, $ff,
  $5e, $5f, $60, $61, $62, $63, $64, $65,
  $66, $67, $68, $69, $6a, $6b, $6c, $6d,
  $6e, $6f, $70, $71, $72, $73, $74, $75,
  $76, $77, $78, $79, $7a, $7b, $7c, $7d,
  $7e, $7f, $80, $81, $82, $83, $84, $85,
  $86, $87, $88, $89, $8a, $8b, $8c, $8d,
  $8e, $8f, $90, $91, $92, $93, $94, $95,
  $96, $97, $98, $99, $9a, $9b, $9c, $9d,
  $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5,
  $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ad,
  $ae, $af, $b0, $b1, $b2, $b3, $b4, $b5,
  $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd);
label
  too_small, done;
var
  i: Integer;
  Count: Cardinal;
begin
  Count := 0;
  Result := Src^;
  Inc(Src);

  case Result of
    0..$A0-1:
    begin
      Inc(Count){1};
    end;
    $A0:
    begin
      Inc(Count, 2){2};
      if (SrcSize < Count) then goto too_small;

      Result := Src^;
    end;
    $A1..$F6-1:
    begin
      Inc(Count, 2){2};
      if (SrcSize < Count) then goto too_small;

      Result := (Result-$A1)*$BE + U[Src^] + $100;
    end;
    $F6..$FC-1:
    begin
      Inc(Count, 3){3};
      Result := Result-$F6;
      if (SrcSize < Count) then goto too_small;

      for i := 0 to 1 do
      begin
        Result := Result * $BE + U[Src^];
        Inc(Src);
      end;

      Result := Result + $4016;
    end;
  else
    Inc(Count, 5){5};
    Result := Result-$FC;
    if (SrcSize < Count) then goto too_small;

    for i := 0 to 3 do
    begin
      Result := Result * $BE + U[Src^];
      Inc(Src);
    end;

    Result := Result + $38E2E;
  end;

too_small:
done:
  SrcRead := Count;
end;

function TTextConvContext.utf1_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
label
  fail;
const
  T: array[0..256-1] of Byte = (
  $21, $22, $23, $24, $25, $26, $27, $28,
  $29, $2a, $2b, $2c, $2d, $2e, $2f, $30,
  $31, $32, $33, $34, $35, $36, $37, $38,
  $39, $3a, $3b, $3c, $3d, $3e, $3f, $40,
  $41, $42, $43, $44, $45, $46, $47, $48,
  $49, $4a, $4b, $4c, $4d, $4e, $4f, $50,
  $51, $52, $53, $54, $55, $56, $57, $58,
  $59, $5a, $5b, $5c, $5d, $5e, $5f, $60,
  $61, $62, $63, $64, $65, $66, $67, $68,
  $69, $6a, $6b, $6c, $6d, $6e, $6f, $70,
  $71, $72, $73, $74, $75, $76, $77, $78,
  $79, $7a, $7b, $7c, $7d, $7e, $a0, $a1,
  $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9,
  $aa, $ab, $ac, $ad, $ae, $af, $b0, $b1,
  $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9,
  $ba, $bb, $bc, $bd, $be, $bf, $c0, $c1,
  $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9,
  $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1,
  $d2, $d3, $d4, $d5, $d6, $d7, $d8, $d9,
  $da, $db, $dc, $dd, $de, $df, $e0, $e1,
  $e2, $e3, $e4, $e5, $e6, $e7, $e8, $e9,
  $ea, $eb, $ec, $ed, $ee, $ef, $f0, $f1,
  $f2, $f3, $f4, $f5, $f6, $f7, $f8, $f9,
  $fa, $fb, $fc, $fd, $fe, $ff, $00, $01,
  $02, $03, $04, $05, $06, $07, $08, $09,
  $0a, $0b, $0c, $0d, $0e, $0f, $10, $11,
  $12, $13, $14, $15, $16, $17, $18, $19,
  $1a, $1b, $1c, $1d, $1e, $1f, $20, $7f,
  $80, $81, $82, $83, $84, $85, $86, $87,
  $88, $89, $8a, $8b, $8c, $8d, $8e, $8f,
  $90, $91, $92, $93, $94, $95, $96, $97,
  $98, $99, $9a, $9b, $9c, $9d, $9e, $9f);
var
  Y, D: Cardinal;
begin
  Result := 2;
  case X of
    0..$A0-1:
    begin
      Dest^ := X;
      Dec(Result);
    end;
    $A0..$100-1:
    begin
      if (DestSize < Result{2}) then goto fail;
      Dest^ := $A0;
      Inc(Dest);
      Dest^ := X;
    end;
    $100..$4016-1:
    begin
      if (DestSize < Result{2}) then goto fail;
      Y := X - $100;
      D := (y*$158ee) shr 24;

      Dest^ := $A1 + D;
      Inc(Dest);
      Dest^ := T[Y - D*$BE];
    end;
    $4016..$38E2E-1:
    begin
      Inc(Result);
      if (DestSize < Result{3}) then goto fail;
      Y := X - $4016;

      Dest^ := $F6 + Y div ($BE*$BE);
      Inc(Dest);

      D := Y div $BE;
      Dest^ := T[D - ((D*$158ee) shr 24)*$BE];
      Inc(Dest);
      Dest^ := T[Y - D*$BE];
    end;
  else
    Inc(Result, 3);
    if (DestSize < Result{5}) then
    begin
    fail:
      Result := 0;
      Exit;
    end;
    Y := X - $38E2E;

    Dest^ := $FC + Y div ($BE*$BE*$BE*$BE);
    Inc(Dest);

    Dest^ := T[(Y div ($BE*$BE*$BE)) mod $BE];
    Inc(Dest);
    Dest^ := T[(Y div ($BE*$BE)) mod $BE];
    Inc(Dest);
    Dest^ := T[(Y div $BE) mod $BE];
    Inc(Dest);

    Dest^ := T[Y mod $BE];
  end;
end;

function TTextConvContext.utf7_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
const
  direct_chars: array[0..128 div 8-1] of Byte = (
  $00, $26, $00, $00, $ff, $f7, $ff, $ff,
  $ff, $ff, $ff, $ef, $ff, $ff, $ff, $3f);
label
  inactive, active, none, unknown, too_small, done;
var
  State, Count: Cardinal;
  C: Cardinal;

  KMax, K, Base64Count: Cardinal;
  WC1, WC2: Cardinal;
begin
  State := Self.FState.Read.B;
  Result := 0;
  Count := 0;
  if (State and 3 <> 0) then goto active;

inactive:
  Inc(Count);
  if (SrcSize < Count) then goto too_small;
  C := Src^;

  //if (isdirect(C)) then
  if (C <= 127) and ((direct_chars[C shr 3] shr (C and 7)) and 1 <> 0) then
  begin
    Result := C;
    goto done;
  end;
  if (C <> Ord('+')) then goto unknown;
  Inc(Count);
  if (SrcSize < Count) then goto too_small;

  Inc(Src);
  if (Src^ = Ord('-')) then
  begin
    Result := Ord('+');
    goto done;
  end;

  Dec(Count);
  State := 1;

active:
  KMax := 2;
  K := 0;
  Base64Count := 0;

  repeat
    C := Src^;

    case C of
      Ord('A')..Ord('Z'): C{i} := C - Ord('A');
      Ord('a')..Ord('z'): C{i} := C - Ord('a') + 26;
      Ord('0')..Ord('9'): C{i} := C - Ord('0') + 52;
      Ord('+'): C := 62;
      Ord('/'): C := 63;
    else
      if (State and -4 <> 0) or (Base64Count <> 0) then
      begin
        Inc(Count, Base64Count);
        goto unknown;
      end;

      if (C = Ord('-')) then
      begin
        Inc(Src);
        Inc(Count);
      end;

      State := 0;
      if (Count = SrcSize) then goto none;
      goto inactive;
    end;

    Inc(Src);
    Inc(Base64Count);

    case (State and 3) of
      1:
      begin
        State := C shl 2;
      end;
      0:
      begin
        Result := (Result shl 8) + (State and -4) + (C shr 4);
        Inc(K);
        State  := ((C and 15) shl 4) + 2;
      end;
      2:
      begin
        Result := (Result shl 8) + (State and -4) + (C shr 2);
        Inc(K);
        State := ((C and 3) shl 6) + 3;
      end;
      3:
      begin
        Result := (Result shl 8) or (State and -4) or C;
        Inc(K);
        State := 1;
      end;
    end;
    if (K = KMax) then
    begin
      if (KMax = 2) and (Result shr 11 = $1B{UTF-16}) then KMax := 4
      else
      Break;
    end;

    if (SrcSize < Count+Base64Count+1) then
    begin
      Count := Count+Base64Count+1;
      goto too_small;
    end;
  until False;

  if (KMax = 4) then
  begin
    WC1 := Result shr 16;
    WC2 := Result and $ffff;

    if (WC1 < $d800) or (WC1 >= $dc00) then goto unknown;
    if (WC2 < $dc00) or (WC2 >= $e000) then goto unknown;

    Result := ((WC1 - $d800) shl 10) + (WC2 - $dc00) + $10000;
  end;

  Count := Count + Base64Count;
  goto done;

none:
  Count := High(Cardinal){-1};
  // goto done;
unknown:
  Result := UNKNOWN_CHARACTER;
too_small:
done:
  Self.FState.Read.B := State;
  SrcRead := Count;
end;

function TTextConvContext.utf7_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
const
  direct_chars: array[0..128 div 8-1] of Byte = (
  $00, $26, $00, $00, $81, $f3, $ff, $87,
  $fe, $ff, $ff, $07, $fe, $ff, $ff, $07);

  base64_chars: array[0..128 div 8-1] of Byte = (
  $00, $00, $00, $00, $00, $a8, $ff, $03,
  $fe, $ff, $ff, $07, $fe, $ff, $ff, $07);
label
  fail, done;
var
  State: Cardinal;
  C: Cardinal;
begin
  if (X = High(Cardinal)) then
  begin
    State := Self.FState.Write.B;

    if (State and 3 = 0) then
    begin
      Result := High(Cardinal);
      Exit;
    end;

    Result := 0;
    goto done;
  end;

  C := X;
  if (C{X} > 127) then
  begin
    State := Self.FState.Write.B;
  end else
  begin
    State := (((direct_chars[C{X} shr 3] shr (C{X} and 7)) and 1) +
             ((base64_chars[C{X} shr 3] shr (C{X} and 7)) and 1) shl 1);

    State := (State shl 8) or Self.FState.Write.B;
  end;

  Result := 0;

  if (State and 3 = 0) then
  begin
    Inc(Result);

    //if (isdirect(X)) then
    if (State and (1 shl 8) <> 0) then
    begin
      PByte(Dest)^ := C{X};
      Exit;
    end;

    Dest^ := Ord('+');
    Inc(Dest);
    if (C{X} = Ord('+')) then
    begin
      if (DestSize < 2) then goto fail;

      Dest^ := Ord('-');
      Inc(Result{ := 2});
      Exit;
    end;

    Inc(State); //State := 1;
  end;

  //if (isdirect(X)) then
  if (State and (1 shl 8) <> 0) then
  begin
    Inc(Result);
    Inc(Result, (State shr 1) and 1);
    Inc(Result, (State shr 9) {and 1});
    if (DestSize < Result) then goto fail;

    //if ((State and 3) >= 2) then
    if (State and 2 <> 0) then
    begin
      C := State and $fc;

      if (C < 26) then Inc(C, Ord('A'))
      else
      if (C < 52) then Inc(C, Ord('a')-26)
      else
      if (C < 62) then Dec(C, 52-Ord('0'))
      else
      if (C = 62) then Dec(C, 62-Ord('+'))
      else
      {if (C = 63) then} Dec(C, 63-Ord('/'));

      Dest^ := C;
      Inc(Dest);
    end;

    //if (isxbase64(X)) then
    if (State and (2 shl 8) <> 0) then
    begin
      Dest^ := Ord('-');
      Inc(Dest);
    end;

    Dest^ := X;
    State := 0;
  end else
  begin
    State := State and $ff;

    if (C <= $ffff) then
    begin
      if (C shr 11 = $1B) then X := $fffd;
      Inc(Result, 2);
      Inc(Result, (State and 2) shr 1);
      Inc(State, ((2*8) shl 8)); // k := 2;
    end else
    begin
      Inc(Result, 5);
      Inc(Result, Byte((State and 3) = 3));
      X := (($d800 + ((C{X} - $10000) shr 10)) shl 16) or ($dc00 + ((C{X} - $10000) and $3ff));
      Inc(State, ((4*8) shl 8)); // k := 4;
    end;
    if (DestSize < Result) then goto fail;

    repeat
      case (State and 3) of
        0:
        begin
          C := (State and $fc) shr 2;
          State := (State and (not $ff)) + 1;
        end;
        1:
        begin
          Dec(State, 8 shl 8); // Dec(k);
          C := (X shr (State shr 8)) and $ff;
          State := (State and (not $ff)) + 2 + ((C and 3) shl 4);
          C := C shr 2;
        end;
        2:
        begin
          Dec(State, 8 shl 8); // Dec(k);
          C := (X shr (State shr 8)) and $ff;
          Inc(C, (State and $fc) shl 4);
          State := (State and (not $ff)) + 3 + ((C and 15) shl 2);
          C := C shr 4;
        end;
        3:
        begin
          Dec(State, 8 shl 8); // Dec(k);
          C := (X shr (State shr 8)) and $ff;
          Inc(C, (State and $fc) shl 6);
          State := (State and (not $ff)) + (C and 63) shl 2;
          C := C shr 6;
        end;
      else
        //C := 0;{hints off}
      fail:
        Result := 0;
        Exit;
      end;

      if (C < 26) then Inc(C, Ord('A'))
      else
      if (C < 52) then Inc(C, Ord('a')-26)
      else
      if (C < 62) then Dec(C, 52-Ord('0'))
      else
      if (C = 62) then Dec(C, 62-Ord('+'))
      else
      {if (C = 63) then} Dec(C, 63-Ord('/'));

      PByte(Dest)^ := C;
      Inc(NativeInt(Dest));
    until ({k}State and $ff00 = 0) and (State and 3 <> 0);
  end;

done:
  if (ModeFinal) and (State and 3 <> 0) then
  begin
    Result := Result + (((State and 2) shr 1) + 1);
    if (DestSize < Result) then goto fail;

    //if ((State and 3) >= 2) then
    if (State and 2 <> 0) then
    begin
      C := State and $fc;

      if (C < 26) then Inc(C, Ord('A'))
      else
      if (C < 52) then Inc(C, Ord('a')-26)
      else
      if (C < 62) then Dec(C, 52-Ord('0'))
      else
      if (C = 62) then Dec(C, 62-Ord('+'))
      else
      {if (C = 63) then} Dec(C, 63-Ord('/'));

      Dest^ := C;
      Inc(Dest);
    end;

    State := 0;
    Dest^ := Ord('-');
  end;
  Self.FState.Write.B := State;
end;

function TTextConvContext.utf_ebcdic_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
const
  UTFEBCDICToI8Table: array[Byte] of Byte = (
  $00, $01, $02, $03, $9C, $09, $86, $7F, $97, $8D, $8E, $0B, $0C, $0D, $0E, $0F,
  $10, $11, $12, $13, $9D, $0A, $08, $87, $18, $19, $92, $8F, $1C, $1D, $1E, $1F,
  $80, $81, $82, $83, $84, $85, $17, $1B, $88, $89, $8A, $8B, $8C, $05, $06, $07,
  $90, $91, $16, $93, $94, $95, $96, $04, $98, $99, $9A, $9B, $14, $15, $9E, $1A,
  $20, $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $2E, $3C, $28, $2B, $7C,
  $26, $AA, $AB, $AC, $AD, $AE, $AF, $B0, $B1, $B2, $21, $24, $2A, $29, $3B, $5E,
  $2D, $2F, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $2C, $25, $5F, $3E, $3F,
  $BC, $BD, $BE, $BF, $C0, $C1, $C2, $C3, $C4, $60, $3A, $23, $40, $27, $3D, $22,
  $C5, $61, $62, $63, $64, $65, $66, $67, $68, $69, $C6, $C7, $C8, $C9, $CA, $CB,
  $CC, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $CD, $CE, $CF, $D0, $D1, $D2,
  $D3, $7E, $73, $74, $75, $76, $77, $78, $79, $7A, $D4, $D5, $D6, $5B, $D7, $D8,
  $D9, $DA, $DB, $DC, $DD, $DE, $DF, $E0, $E1, $E2, $E3, $E4, $E5, $5D, $E6, $E7,
  $7B, $41, $42, $43, $44, $45, $46, $47, $48, $49, $E8, $E9, $EA, $EB, $EC, $ED,
  $7D, $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $EE, $EF, $F0, $F1, $F2, $F3,
  $5C, $F4, $53, $54, $55, $56, $57, $58, $59, $5A, $F5, $F6, $F7, $F8, $F9, $FA,
  $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $FB, $FC, $FD, $FE, $FF, $9F);
label
  unknown;
var
  X, Count: Cardinal;
begin
  Result := UTFEBCDICToI8Table[Src^];
  Count := 1;
  Inc(Src);

  case Result of
    0..$9F:
    begin
      SrcRead := Count;
      Exit;
    end;
    $C0..$DF:
    begin
      Inc(Count);
      Result := Result and $1F;
    end;
    $E0..$EF:
    begin
      Inc(Count, 2);
      Result := Result and $F;
    end;
    $F0..$F7:
    begin
      Inc(Count, 3);
      Result := Result and 7;
    end;
    $F8..$F9:
    begin
      Inc(Count, 4);
      Result := Result and 1;
    end;
  else
    goto unknown;
  end;

  SrcRead := Count;
  if (SrcSize < Count) then Exit;

  Dec(Count);
  repeat
    X := UTFEBCDICToI8Table[Src^];
    Inc(Src);
    if (X shr 5 <> 5) then
    begin
    unknown:
      Result := Ord('?');
      Exit;
    end;

    X := X and $1F;
    Dec(Count);
    Result := (Result shl 5) + X;
  until (Count = 0);
end;

function TTextConvContext.utf_ebcdic_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
const
  MASKS: array[2..5] of Byte = ($C0, $E0, $F0, $F8);

  I8ToUTFEBCDICTable: array[Byte] of Byte = (
  $00, $01, $02, $03, $37, $2D, $2E, $2F, $16, $05, $15, $0B, $0C, $0D, $0E, $0F,
  $10, $11, $12, $13, $3C, $3D, $32, $26, $18, $19, $3F, $27, $1C, $1D, $1E, $1F,
  $40, $5A, $7F, $7B, $5B, $6C, $50, $7D, $4D, $5D, $5C, $4E, $6B, $60, $4B, $61,
  $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $7A, $5E, $4C, $7E, $6E, $6F,
  $7C, $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $D1, $D2, $D3, $D4, $D5, $D6,
  $D7, $D8, $D9, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $AD, $E0, $BD, $5F, $6D,
  $79, $81, $82, $83, $84, $85, $86, $87, $88, $89, $91, $92, $93, $94, $95, $96,
  $97, $98, $99, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $C0, $4F, $D0, $A1, $07,
  $20, $21, $22, $23, $24, $25, $06, $17, $28, $29, $2A, $2B, $2C, $09, $0A, $1B,
  $30, $31, $1A, $33, $34, $35, $36, $08, $38, $39, $3A, $3B, $04, $14, $3E, $FF,
  $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $51, $52, $53, $54, $55, $56,
  $57, $58, $59, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $70, $71, $72, $73,
  $74, $75, $76, $77, $78, $80, $8A, $8B, $8C, $8D, $8E, $8F, $90, $9A, $9B, $9C,
  $9D, $9E, $9F, $A0, $AA, $AB, $AC, $AE, $AF, $B0, $B1, $B2, $B3, $B4, $B5, $B6,
  $B7, $B8, $B9, $BA, $BB, $BC, $BE, $BF, $CA, $CB, $CC, $CD, $CE, $CF, $DA, $DB,
  $DC, $DD, $DE, $DF, $E1, $EA, $EB, $EC, $ED, $EE, $EF, $FA, $FB, $FC, $FD, $FE);

var
  Shift: Integer;
begin
  Result := 1;
  case X of
    0..$9F:
    begin
      Dest^ := I8ToUTFEBCDICTable[X];
      Exit{1};
    end;
    $9F+1..$3FF:
    begin
      Inc(Result){2};
    end;
    $3FF+1..$3FFF:
    begin
      Inc(Result, 2){3};
    end;
    $3FFF+1..$3FFFF:
    begin
      Inc(Result, 3){4};
    end;
  else
    Inc(Result, 4){5};
  end;

  if (DestSize < Result) then
  begin
    Result := 0;
    Exit;
  end;

  Shift := (Result-1)*5;
  Dest^ := I8ToUTFEBCDICTable[MASKS[Result] + (X shr Shift)];
  repeat
    Dec(Shift, 5);
    Inc(Dest);
    Dest^ := I8ToUTFEBCDICTable[((X shr Shift) and $1F) + $A0];
  until (Shift = 0);
end;

function TTextConvContext.scsu_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
const
  SQ0 = $01; { Quote from window pair 0 }
  SQ7 = $08; { Quote from window pair 7 }
  SDX = $0B; { Define a window as extended }
  Srs = $0C; { reserved }
  SQU = $0E; { Quote a single Unicode character }
  SCU = $0F; { Change to Unicode mode }
  SC0 = $10; { Select window 0 }
  SC7 = $17; { Select window 7 }
  SD0 = $18; { Define and select window 0 }
  SD7 = $1F; { Define and select window 7 }

  UC0 = $E0; { Select window 0 }
  UC7 = $E7; { Select window 7 }
  UD0 = $E8; { Define and select window 0 }
  UD7 = $EF; { Define and select window 7 }
  UQU = $F0; { Quote a single Unicode character }
  UDX = $F1; { Define a Window as extended }
  Urs = $F2; { reserved }

  gapThreshold = $68; { Unicode code points from 3400 to E000 are not adressible by dynamic window. }
  gapOffset = $AC00; { Therefore add gapOffset to all values from gapThreshold. }
  reservedStart = $A8; { values between reservedStart and fixedThreshold are reserved }
  fixedThreshold = $F9; { use table of predefined fixed offsets for values from fixedThreshold }


  staticOffsets: array[0..8-1] of Cardinal = (
    $0000, { ASCII for quoted tags }
    $0080, { Latin - 1 Supplement (for access to punctuation) }
    $0100, { Latin Extended-A }
    $0300, { Combining Diacritical Marks }
    $2000, { General Punctuation }
    $2080, { Currency Symbols }
    $2100, { Letterlike Symbols and Number Forms }
    $3000  { CJK Symbols and punctuation } );

  initialDynamicOffsets: array[0..8-1] of Cardinal = (
    $0080, { Latin-1 }
    $00C0, { Latin Extended A }
    $0400, { Cyrillic }
    $0600, { Arabic }
    $0900, { Devanagari }
    $3040, { Hiragana }
    $30A0, { Katakana }
    $FF00  { Fullwidth ASCII } );

  fixedOffsets: array[0..7-1] of Cardinal = (
    { $F9 } $00C0, { Latin-1 Letters + half of Latin Extended A }
    { $FA } $0250, { IPA extensions }
    { $FB } $0370, { Greek }
    { $FC } $0530, { Armenian }
    { $FD } $3040, { Hiragana }
    { $FE } $30A0, { Katakana }
    { $FF } $FF60  { Halfwidth Katakana } );

  modeNone = 0;
  modeSingleByte = 1;
  modeUnicode = 2;

  readCommand = 0;
  quotePairOne = 1;
  quotePairTwo = 2;
  quoteOne = 3;
  definePairOne = 4;
  definePairTwo = 5;
  defineOne = 6;

  FLAG_DYNAMIC_MODIFIED = 1 shl 7;
  FLAGS_DYNAMIC_MODIFIED_ALL = FLAG_DYNAMIC_MODIFIED + (1 shl 6);

type
  T8Cardinals = array[0..8-1] of Cardinal;
  P8Cardinals = ^T8Cardinals;

  TSCSUReaderState = packed record
    DynamicWindow, QuoteWindow: shortint;
    Mode: Byte{modeNone, modeSingleByte, modeUnicode};
    Flags: Byte; // windows redefined
    DynamicOffsets: T8Cardinals;
  end;

label
  fastSingle, singleByteMode, fastUnicode, unicodeByteMode,
  unknown, too_small, done_UTF16, done;
var
  State: ^TSCSUReaderState;
  Count, Value: Cardinal;
  PSrc: PByte;
  FirstUTF16Word: Cardinal;
  (*
    Result: packed record
      current_Byte: Byte;
      pair_Byte: Byte;
      zero: Byte;
      READ_MODE: Byte; {high}
    end;
  *)
begin
  State := Pointer(@FState.Read);
  if (State.Mode = modeNone) then
  begin
    State.DynamicOffsets := P8Cardinals(@initialDynamicOffsets)^;
    State.Mode := modeSingleByte;
    State.Flags := FLAGS_DYNAMIC_MODIFIED_ALL;
  end;

  Count := 0;
  PSrc := Src;
  FirstUTF16Word := Count{0};

  if (State.Mode = modeSingleByte) then
  begin
    fastSingle:
    begin
      Inc(Count);
      if (SrcSize < Count) then goto too_small;
      Result := PSrc^;

      if (Result >= $20) then
      begin
        if (Result > $7f) then
        begin
          Result := State.DynamicOffsets[State.DynamicWindow] + (Result and $7f);
        end;
        goto done;
      end else
      begin
        Dec(Count);
        Result := 0;
      end;
    end;

    singleByteMode:
    begin
      Inc(Count);
      if (SrcSize < Count) then goto too_small;
      Inc(Result, PSrc^);
      Inc(PSrc);

      case (Result shr 24){Mode} of
        readCommand:
        begin
          case Result{low Byte} of
            SQ0..SQ7:
            begin
              State.QuoteWindow := (Result-SQ0);
              Result := (quoteOne shl 24){Mode};
              goto singleByteMode;
            end;
            SDX:
            begin
              Result := (definePairOne shl 24){Mode};
              goto singleByteMode;
            end;
            Srs:
            begin
              goto unknown;
            end;
            SQU:
            begin
              Result := (quotePairOne shl 24){Mode};
              goto singleByteMode;
            end;
            SCU:
            begin
              State.Mode := modeUnicode;
              goto fastUnicode;
            end;
            SC0..SC7:
            begin
              State.DynamicWindow := (Result-SC0);
              goto fastSingle;
            end;
            SD0..SD7:
            begin
              State.DynamicWindow := (Result-SD0);
              Result := (defineOne shl 24){Mode};
              goto singleByteMode;
            end;
          else
            { CR/LF/TAB/NUL }
            goto done;
          end;
        end;
        quotePairOne:
        begin
          Result := (Result{low Byte} shl 8) + (quotePairTwo shl 24){Mode};
          goto singleByteMode;
        end;
        quotePairTwo:
        begin
          goto done_UTF16;
        end;
        quoteOne:
        begin
          Value := (Result and $7f);
          if (Byte(Result) <= $7f) then
          begin
            Result := Value + staticOffsets[State.QuoteWindow];
          end else
          begin
            Result := Value + State.DynamicOffsets[State.QuoteWindow];
          end;

          goto done;
        end;
        definePairOne:
        begin
          State.DynamicWindow := Result shr 5;
          Result := ((Result and $1f) shl 8) + (definePairTwo shl 24){Mode};
          goto singleByteMode;
        end;
        definePairTwo:
        begin
           State.DynamicOffsets[State.DynamicWindow] := ((Result and $ffff) shl 7)+$10000;
           State.Flags := State.Flags or FLAG_DYNAMIC_MODIFIED;
           goto fastSingle;{Mode := readCommand}
        end;
        defineOne:
        begin
          Result := Byte(Result);
          case Result of
            1..gapThreshold-1:
            begin
              Result := Result shl 7;
            end;
            gapThreshold..reservedStart-1:
            begin
              Result := (Result shl 7)+gapOffset;
            end;
            fixedThreshold..High(Byte):
            begin
              Result := fixedOffsets[Result-fixedThreshold];
            end;
          else
            goto unknown;
          end;

          State.DynamicOffsets[State.DynamicWindow] := Result;
          State.Flags := State.Flags or FLAG_DYNAMIC_MODIFIED;
          goto fastSingle;{Mode := readCommand}
        end;
      end; // case Mode
    end; // singleByteMode label
  end else
  // if (State.UnicodeMode) then
  begin
    // if (Mode = readCommand) then
    fastUnicode:
    begin
      Inc(Count);
      if (SrcSize < Count) then goto too_small;
      Result := PSrc^;

      if (Cardinal(Result-UC0)>(Urs-UC0)) then
      begin
        Inc(Count);
        Inc(PSrc);
        if (SrcSize < Count) then goto too_small;

        Result := (Result shl 8) + PSrc^;
        Inc(PSrc);
        goto done_UTF16;
      end else
      begin
        Dec(Count);
        Result := 0{Mode := readCommand};
      end;
    end;

    unicodeByteMode:
    begin
      Inc(Count);
      if (SrcSize < Count) then goto too_small;
      Inc(Result, PSrc^);
      Inc(PSrc);

      case (Result shr 24){Mode} of
        readCommand:
        begin
          case (Result){low Byte} of
            UC0..UC7:
            begin
              State.DynamicWindow := (Result-UC0);
              State.Mode := modeSingleByte;
              goto fastSingle;
            end;
            UD0..UD7:
            begin
              State.DynamicWindow := (Result-UD0);
              State.Mode := modeSingleByte;
              Result := (defineOne shl 24){Mode};
              goto singleByteMode;
            end;
            UQU:
            begin
              Result := (quotePairOne shl 24){Mode};
              goto unicodeByteMode;
            end;
            UDX:
            begin
              State.Mode := modeSingleByte;
              Result := (definePairOne shl 24){Mode};
              goto singleByteMode;
            end;
            Urs:
            begin
              goto unknown;
            end;
          else
            Result := (Result shl 8) + (quotePairTwo shl 24){Mode};
            goto unicodeByteMode;
          end;
        end;
        quotePairOne:
        begin
          Result := (Result shl 8) + (quotePairTwo shl 24){Mode};
          goto unicodeByteMode;
        end;
        quotePairTwo:
        begin
          goto done_UTF16;
        end;
      end;
    end;
  end;


unknown:
too_small:
  Result := UNKNOWN_CHARACTER;
  goto done;
done_UTF16:
  Result := Word(Result);
  if (Result >= $d800) and (Result < $e000) then
  begin
    // pair
    if (Result < $dc00) then
    begin
      // first
      FirstUTF16Word := Result;
      if (State.Mode = modeSingleByte) then goto singleByteMode
      else
      goto fastUnicode;
    end else
    begin
      // second
      if (FirstUTF16Word = 0) then goto unknown;
      Result := (Result and $ffff) + ($10000-$dc00) + ((FirstUTF16Word-$d800) shl 10);
    end;
  end;
done:
  SrcRead := Count;
end;

function TTextConvContext.scsu_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
label
  ascii, unicode, done_x_correct, done, fill_four;
const
  is_unicode_mode_offset = 6;
  is_unicode_mode = 1 shl is_unicode_mode_offset;
  is_modified_1 = 1 shl 7;

  current_window_offset = 0;
  current_window_mask = 7;
  need_window_offset = 3;
  need_window_mask = 7 shl need_window_offset;

  x_size_offset = 8;
  x_size_mask = $f;
  data_size_offset = 12;
  data_size_mask = $f;

  clear_current_window_mask = not(current_window_mask);
  clear_state_mask = (current_window_mask or is_unicode_mode or is_modified_1);

  // Byte mode
  SC0 = $10; { Select window 0 }
  SD0 = $18; { Define and select window 0 }
  SCU = $0F; { Change to Unicode mode }
  // inicode to Byte mode
  UC0 = $E0; { Select window 0 }
  UD0 = $E8; { Define and select window 0 }
  // unicode High(single char) = $EO..$F2
  UQU = $F0; { Quote a single Unicode character }

  modified_1_states: array[0..1] of Cardinal  =
    (
       {Byte_mode:} (SD0 shl 16) + (($100 shr 7) shl 24) + is_modified_1
                   +(1{w} shl 16) + (1{w})
                   +(2 shl data_size_offset) + (1 shl x_size_offset),
    {unicode_mode:} (UD0 shl 16) + (($100 shr 7) shl 24) + is_modified_1 - is_unicode_mode
                   +(1{w} shl 16) + (1{w})
                   +(2 shl data_size_offset) + (1 shl x_size_offset)
    );

var
  State, Y: Cardinal;
  PDest: PByte;
  (*
    State: packed record
      current_window: Byte:3;
      need_window: Byte:3;
      is_unicode_mode: Boolean:1;
      is_modified_1: Boolean:1;

      x_size: Byte: 4;
      data_size: Byte: 4;

      data: array[0..1] of Byte;
    end;
  *)
begin
  State := FState.Write.D;

  case X of
    0..$20-1:
    begin
      if ((1 shl X) and $2601 = 0) then goto unicode;
      goto ascii{#0, #9, #10, #13};
    end;
    $20..$7f:
    begin
    ascii:
      if (State and is_unicode_mode = 0) then
      begin
        Dest^ := X;
        Result := 1;
        Exit;
      end;

      // to Byte_mode with window = current_window
      Y := State and current_window_mask;
      State := State + (Y shl 16) + ((UC0 shl 16) + (1 shl data_size_offset) + (1 shl x_size_offset) - is_unicode_mode);
      goto done;
    end;
    $0080..$0080+$7f{0}:
    begin
      // need_window := 0;
      //Inc(State, 0 shl need_window_offset);
    end;
    $0100..$0100+$7f{1 modified}:
    begin
      // need_window := 1;
      Inc(State, 1 shl need_window_offset);

      if (State and is_modified_1 = 0) then
      begin
        State := (State and clear_current_window_mask) + modified_1_states[(State shr is_unicode_mode_offset) and 1];
        goto done_x_correct;
      end;
    end;
    $0400..$0400+$7f{2}:
    begin
      // need_window := 2;
      Inc(State, 2 shl need_window_offset);
    end;
    $0600..$0600+$7f{3}:
    begin
      // need_window := 3;
      Inc(State, 3 shl need_window_offset);
    end;
    $0900..$0900+$7f{4}:
    begin
      // need_window := 4;
      Inc(State, 4 shl need_window_offset);
    end;
    $3040..$30A0-1{5}:
    begin
      Dec(X, $40); // $3040
      Inc(State, 5 shl need_window_offset);
    end;
    $30A0..$30A0+$7f{6}:
    begin
      // need_window := 6;
      Dec(X, $20); // $30A0
      Inc(State, 6 shl need_window_offset);
    end;
    $FF00..$FF00+$7f{7}:
    begin
      // need_window := 7;
      Inc(State, 7 shl need_window_offset);
    end;
  else
  unicode:
    if (State and is_unicode_mode = 0) then
    begin
      State := State + ((SCU shl 16) + (1 shl data_size_offset) + is_unicode_mode);
    end;

    if (X <= $ffff) then
    begin
      if (X >= $e000) and (X <= $f2ff) then
      begin
        X := (Swap(X) shl 8) + UQU;
        State := State + (3 shl x_size_offset);
      end else
      begin
        if (X shr 11 = $1B) then X := $fdff {Swap($fffd)}
        else
        X := Swap(X);
        State := State + (2 shl x_size_offset);
      end;
    end else
    begin
      // to UTF-16
      Y := (X - $10000) shr 10 + $d800;
      X := (X - $10000) and $3ff + $dc00;
      X := (Swap(X) shl 16) + Swap(Y);
      State := State + (4 shl x_size_offset);
    end;
    goto done;
  end;

//standard:
  Y := (State and need_window_mask) shr need_window_offset;
  Inc(State, 1 shl x_size_offset{default X size});
  if (State and is_unicode_mode = 0) then
  begin
    // Byte_mode (may be window changing)
    if (State and current_window_mask = Y) then goto done_x_correct;
    State := State + ((SC0 shl 16) + (1 shl data_size_offset));
  end else
  begin
    // unicode_mode to Byte_mode (need window)
    State := State + ((UC0 shl 16) + (1 shl data_size_offset) - is_unicode_mode);
  end;

  // fill current window
  State := (State and clear_current_window_mask) + Y + (Y shl 16);
done_x_correct:
  X := (X and $7f) + $80;
done:
  FState.Write.D := State and clear_state_mask;
  Result := ((State shr x_size_offset) and x_size_mask) +
            ((State shr data_size_offset) and data_size_mask);

  if (DestSize < Result) then
  begin
    // too small
    Result := 0;
    Exit;
  end;

  // write data
  PDest := Dest;
  if (State and (data_size_mask shl data_size_offset) <> 0) then
  begin
    if (State and (1 shl data_size_offset) = 0) then
    begin
      PWord(PDest)^ := State shr 16;
      Inc(PDest, 2);
    end else
    begin
      PDest^ := State shr 16;
      Inc(PDest);
    end;
  end;

  // write character data
  if (DestSize >= 5) then goto fill_four;
  case ((State shr x_size_offset) and x_size_mask) of
    1: PByte(PDest)^ := X;
    2: PWord(PDest)^ := X;
    3: begin
         PWord(PDest)^ := X;
         X := X shr 16;
         Byte(PAnsiChar(PDest)[2]) := X;
       end;
    4: begin
       fill_four:
         PCardinal(PDest)^ := X;
       end;
  end;
end;


const
  BOCU1_ASCII_PREV  = $40;
  BOCU1_MIN         = $21;
  BOCU1_MIDDLE      = $90;
  BOCU1_MAX_LEAD    = $FE;
  BOCU1_MAX_TRAIL   = $FF;
  BOCU1_RESET       = $FF;
  BOCU1_COUNT       = (BOCU1_MAX_LEAD - BOCU1_MIN + 1);
  BOCU1_TRAIL_CONTROLS_COUNT = 20;
  BOCU1_TRAIL_BYTE_OFFSET    = (BOCU1_MIN - BOCU1_TRAIL_CONTROLS_COUNT);
  BOCU1_TRAIL_COUNT = ((BOCU1_MAX_TRAIL - BOCU1_MIN + 1) + BOCU1_TRAIL_CONTROLS_COUNT);
  BOCU1_SINGLE = 64;
  BOCU1_LEAD_2 = 43;
  BOCU1_LEAD_3 = 3;
  BOCU1_LEAD_4 = 1;
  BOCU1_REACH_POS_1 = (BOCU1_SINGLE-1);
  BOCU1_REACH_NEG_1 = (-BOCU1_SINGLE);
  BOCU1_REACH_POS_2 = (BOCU1_REACH_POS_1 + BOCU1_LEAD_2 * BOCU1_TRAIL_COUNT);
  BOCU1_REACH_NEG_2 = (BOCU1_REACH_NEG_1 - BOCU1_LEAD_2 * BOCU1_TRAIL_COUNT);
  BOCU1_REACH_POS_3 = (BOCU1_REACH_POS_2 + BOCU1_LEAD_3 * BOCU1_TRAIL_COUNT * BOCU1_TRAIL_COUNT);
  BOCU1_REACH_NEG_3 = (BOCU1_REACH_NEG_2 - BOCU1_LEAD_3 * BOCU1_TRAIL_COUNT * BOCU1_TRAIL_COUNT);
  BOCU1_START_POS_2 = (BOCU1_MIDDLE + BOCU1_REACH_POS_1 + 1);
  BOCU1_START_POS_3 = (BOCU1_START_POS_2 + BOCU1_LEAD_2);
  BOCU1_START_POS_4 = (BOCU1_START_POS_3 + BOCU1_LEAD_3);
  BOCU1_START_NEG_2 = (BOCU1_MIDDLE + BOCU1_REACH_NEG_1);
  BOCU1_START_NEG_3 = (BOCU1_START_NEG_2 - BOCU1_LEAD_2);
  BOCU1_START_NEG_4 = (BOCU1_START_NEG_3 - BOCU1_LEAD_3);

  BOCU1_BYTE_TO_TRAIL: array[0..BOCU1_MIN - 1] of Byte = (
    $FF, $00, $01, $02, $03, $04, $05, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $06, $07, $08, $09, $0A, $0B,
    $0C, $0D, $0E, $0F, $FF, $FF, $10, $11, $12, $13, $FF);

  BOCU1_TRAIL_TO_BYTE: array[0..BOCU1_TRAIL_CONTROLS_COUNT - 1] of Byte = (
    $01, $02, $03, $04, $05, $06, $10, $11, $12, $13,
    $14, $15, $16, $17, $18, $19, $1C, $1D, $1E, $1F);

function TTextConvContext.bocu1_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
label
  init_prev, loop,
  calc_prev, fill_prev, unknown, too_small, done;
var
  Ret, Prev, T: Integer;
  Count: Cardinal;
  PPrev: PInteger;
begin
  Prev := FState.Read.I;
  PPrev := @FState.Read.I;
  Ret := Src^;
  Count := 1;

  if (Prev = 0) then
  begin
  init_prev:
    Prev := BOCU1_ASCII_PREV;
    PPrev^ := prev;
  end;

  case Ret of
    0..$20:
    begin
      SrcRead := Count;
      if (Ret < $20) then
      begin
        Prev := BOCU1_ASCII_PREV;
        goto fill_prev;
      end;
      goto done;
    end;
    BOCU1_START_NEG_2..BOCU1_START_POS_2-1:
    begin
      Ret := Ret + Prev;
      Ret := Ret - BOCU1_MIDDLE;
      SrcRead := Count;
      goto calc_prev;
    end;
    BOCU1_RESET:
    begin
      Inc(Count);
      Inc(Src);
      if (SrcSize < Count) then goto too_small;
      Ret := Src^;
      goto init_prev;
    end;
  end;

  T := 1;
  if (Ret >= BOCU1_START_NEG_2) then
  begin
    if (Ret < BOCU1_START_POS_3) then
    begin
      Ret := (Ret* BOCU1_TRAIL_COUNT) + (-BOCU1_START_POS_2* BOCU1_TRAIL_COUNT + BOCU1_REACH_POS_1 + 1);
    end else
    if (Ret < BOCU1_START_POS_4) then
    begin
      Inc(T);
      Ret := (Ret*(BOCU1_TRAIL_COUNT*BOCU1_TRAIL_COUNT)) + (-BOCU1_START_POS_3*BOCU1_TRAIL_COUNT*BOCU1_TRAIL_COUNT + BOCU1_REACH_POS_2 + 1);
    end else
    begin
      Inc(T, 2);
      Ret := BOCU1_REACH_POS_3 + 1;
    end;
  end else
  begin
    if (Ret >= BOCU1_START_NEG_3) then
    begin
      Ret := (Ret*BOCU1_TRAIL_COUNT) + (-BOCU1_START_NEG_2* BOCU1_TRAIL_COUNT + BOCU1_REACH_NEG_1);
    end else
    if (Ret > BOCU1_MIN) then
    begin
      Inc(T);
      Ret := (Ret*(BOCU1_TRAIL_COUNT*BOCU1_TRAIL_COUNT)) + (-BOCU1_START_NEG_3*BOCU1_TRAIL_COUNT*BOCU1_TRAIL_COUNT + BOCU1_REACH_NEG_2);
    end else
    begin
      Inc(T, 2);
      Ret := -BOCU1_TRAIL_COUNT * BOCU1_TRAIL_COUNT * BOCU1_TRAIL_COUNT + BOCU1_REACH_NEG_3;
    end;
  end;

  Inc(Count, T);
  SrcRead := Count;
  if (SrcSize < Count) then goto too_small;
  Count := T;
loop:
  Inc(Src);
  T := Src^;

  if (T <= $20) then
  begin
    T := BOCU1_BYTE_TO_TRAIL[T];
    if (T > $13{ = $ff}) then goto unknown;
  end else
  begin
    T := T - BOCU1_TRAIL_BYTE_OFFSET;
  end;

  case Count of
    1:
    begin
      Ret := Ret + T;
      Ret := Ret + PPrev^;
      if (Cardinal(Ret) <= $10ffff) then goto calc_prev;
      unknown:
        Ret := UNKNOWN_CHARACTER;
        Prev := BOCU1_ASCII_PREV;
        goto fill_prev;
    end;
    2: Ret := Ret + T * BOCU1_TRAIL_COUNT;
    else
   {3:} Ret := Ret + T * (BOCU1_TRAIL_COUNT * BOCU1_TRAIL_COUNT);
  end;

  Dec(Count);
  goto loop;


calc_prev:
  case Ret of
    $3040..$309f: Prev := $3070;
    $4e00..$9fa5: Prev := $4e00 - BOCU1_REACH_NEG_2;
    $ac00..$d7a3: Prev := ($d7a3 + $ac00) div 2;
  else
    Prev := (Ret and (not $7f)) + BOCU1_ASCII_PREV;
  end;
fill_prev:
  PPrev^ := Prev;

too_small:
done:
  Result := Ret;
end;

function TTextConvContext.bocu1_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
var
  Diff, M: Integer;
  SavedDest: PByte;
begin
  Diff{last state} := FState.Write.I;
  if (Diff = 0) then
  begin
    Diff := BOCU1_ASCII_PREV;
    FState.Write.I := Diff;
  end;

  if (X <= $20) then
  begin
    if (X < $20) then FState.Write.I := BOCU1_ASCII_PREV;
    Dest^ := X;
    Result := 1;
    Exit; // goto done;
  end else
  begin
    Dec(Diff, X);
    case X of
      $3040..$309f: FState.Write.I := $3070;
      $4e00..$9fa5: FState.Write.I := $4e00 - BOCU1_REACH_NEG_2;
      $ac00..$d7a3: FState.Write.I := ($d7a3 + $ac00) div 2;
    else
      FState.Write.I := (X and (not $7f)) + BOCU1_ASCII_PREV;
    end;
    Diff := -Diff;
    SavedDest := Dest;

    if (Diff >= BOCU1_REACH_NEG_1) then
    begin
      if (Diff <= BOCU1_REACH_POS_1) then
      begin
        Dest^ := (Diff+BOCU1_MIDDLE);
        Result := 1;
        Exit;
      end else
      if (Diff <= BOCU1_REACH_POS_2) then
      begin
        Diff := Diff - (BOCU1_REACH_POS_1 + 1);
        Dest^{lead} := BOCU1_START_POS_2;
        Inc(Dest);
      end else
      if (Diff <= BOCU1_REACH_POS_3) then
      begin
        Diff := Diff - (BOCU1_REACH_POS_2 + 1);
        Dest^{lead} := BOCU1_START_POS_3;
        Inc(Dest, 2);
      end else
      begin
        Diff := Diff - (BOCU1_REACH_POS_3 + 1);
        Dest^{lead} := BOCU1_START_POS_4;
        Inc(Dest, 3);
      end;
    end else
    begin
      if (Diff >= BOCU1_REACH_NEG_2) then
      begin
        Diff := Diff - BOCU1_REACH_NEG_1;
        Dest^{lead} := BOCU1_START_NEG_2;
        Inc(Dest);
      end else
      if (Diff >= BOCU1_REACH_NEG_3) then
      begin // three Bytes
        Diff := Diff - BOCU1_REACH_NEG_2;
        Dest^{lead} := BOCU1_START_NEG_3;
        Inc(Dest, 2);
      end else
      begin // four Bytes */
        Diff := Diff - BOCU1_REACH_NEG_3;
        Dest^{lead} := BOCU1_START_NEG_4;
        Inc(Dest, 3);
      end;
    end;

    Result := (PAnsiChar(Dest)-PAnsiChar(SavedDest))+1;
    if (DestSize < Result) then
    begin
      // too_small
      Result := 0;
      Exit;
    end;
    DestSize := Result;

    while (SavedDest <> Dest) do
    begin
      // M := Diff mod BOCU1_TRAIL_COUNT;
      // Diff := Diff div BOCU1_TRAIL_COUNT;
      M := Diff;
      Diff := Diff div BOCU1_TRAIL_COUNT;
      Dec(M, Diff*BOCU1_TRAIL_COUNT);
      if (M < 0) then
      begin
        Dec(Diff);
        M := M + BOCU1_TRAIL_COUNT;
      end;

      if (M >= BOCU1_TRAIL_CONTROLS_COUNT) then Dest^ := M + BOCU1_TRAIL_BYTE_OFFSET
      else Dest^ := BOCU1_TRAIL_TO_BYTE[m];

      Dec(Dest);
    end;

    Inc(Dest^, Diff);
    Result := DestSize;
  end;
end;

function gbk_wctomb(X: Cardinal; Buf: PByte): Boolean;
label
  look_inv;
var
  W: Word;
begin
  if (X > $ffff) or (X = $fffd) then
  begin
    Result := False;
    Exit;
  end;

  Result := True;
  if (X <> $30fb) and (X <> $2015)  then
  begin
    W := hash_gb2312.Find(X);
    if (W <> High(Word)) then
    begin
      PWord(Buf)^ := W + $a1a1;
      Exit;
    end;
  end;

  case X of
    $0251: PWord(Buf)^ := $bba8;
    $0144: PWord(Buf)^ := $bda8;
    $0148: PWord(Buf)^ := $bea8;
    $0261: PWord(Buf)^ := $c0a8;

    $00b7: PWord(Buf)^ := $a4a1;
    $2014: PWord(Buf)^ := $aaa1;
    $2170..$2179: PWord(Buf)^ := (X-$2170) shl 8 + $a1a2;
  else
    if (X shr 8 <> $fe) then
    begin
      look_inv:

      W := hash_gbkext1.Find(X);
      if (W <> High(Word)) then
      begin
        PWord(Buf)^ := W + $4081 + Ord(W >= $3f00) shl 8;
        Exit;
      end;

      W := hash_gbkext2.Find(X);
      if (W <> High(Word)) then
      begin
        PWord(Buf)^ := W + $40a8 + Ord(W >= $3f00) shl 8;
        Exit;
      end;

      Result := False;
    end else
    case Byte(X) of
      $35: PWord(Buf)^ := $e0a6;
      $36: PWord(Buf)^ := $e1a6;
      $39: PWord(Buf)^ := $e2a6;
      $3a: PWord(Buf)^ := $e3a6;
      $3f: PWord(Buf)^ := $e4a6;
      $40: PWord(Buf)^ := $e5a6;
      $3d: PWord(Buf)^ := $e6a6;
      $3e: PWord(Buf)^ := $e7a6;
      $41: PWord(Buf)^ := $e8a6;
      $42: PWord(Buf)^ := $e9a6;
      $43: PWord(Buf)^ := $eaa6;
      $44: PWord(Buf)^ := $eba6;
      $3b: PWord(Buf)^ := $eea6;
      $3c: PWord(Buf)^ := $efa6;
      $37: PWord(Buf)^ := $f0a6;
      $38: PWord(Buf)^ := $f1a6;
      $31: PWord(Buf)^ := $f2a6;
      $33: PWord(Buf)^ := $f4a6;
      $34: PWord(Buf)^ := $f5a6;
    else
      goto look_inv;
    end;
  end;
end;


const
  table_cp936ext_1: array[0..21] of Word  =
  ($fe35, $fe36, $fe39, $fe3a, $fe3f, $fe40, $fe3d, $fe3e,
   $fe41, $fe42, $fe43, $fe44, $fffd, $fffd, $fe3b, $fe3c,
   $fe37, $fe38, $fe31, $fffd, $fe33, $fe34);
  table_cp936ext_2: array[0..5] of Word =
  ($0251, $fffd, $0144, $0148, $fffd, $0261);


function TTextConvContext.gb2312_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
label
  look_gbkext, user_defined,
  unknown, fail, done;
var
  S1: Byte;
  S2: Byte;
begin
  S1 := Src^;
  Inc(Src);

  case S1 of
    0..$7f:
    begin
      Result := S1;
      SrcRead := 1;
      Exit;
    end;
    $80:
    begin
      Result := $20ac;
      SrcRead := 1;
      Exit;
    end;
    $ff: goto unknown;
  else
    // if (not gbk_mbtowc) then
    // user-defined characters;
    if (SrcSize < 2) then goto fail;
    S2 := Src^;

    if not(S1 in [$a1..$f7]) then goto look_gbkext;

    // some consts
    if (S1 = $a1) then
    begin
      if (S2 = $a4) then
      begin
        Result := $00b7;
        goto done;
      end;
      if (S2 = $aa) then
      begin
        Result := $2014;
        goto done;
      end;
    end;

    if (S2 in [$a1..$fe]) then
    begin
      // gb2312_mbtowc
      if (S1 in [$a1..$a9, $b0..$f7]) then
      begin
        Result := 94 * (S1 - $a1) + (S2 - $a1);
        Result := table_gb2312[Result];

        if (Result <> $fffd) then
        goto done;
      end;

      // cp936ext_mbtowc
      if (S1 in [$a6,$a8]) and (S2 in [$40..$7e, $80..$fe]) then
      begin
        Result := 190*(S1-$81) + S2 - $40 - Ord(S2 >= $80);

        case Result of
          7189..7210: Result := table_cp936ext_1[Result-7189];
          7532..7537: Result := table_cp936ext_2[Result-7532];
        else
          Result := $fffd;
        end;

        if (Result <> $fffd) then
        goto done;
      end;
    end;


look_gbkext:
    if (S1 in [$81..$a0]) then
    begin
      if (S2 in [$40..$7e, $80..$fe]) then
      begin
        Result := 190 * (S1 - $81) + S2 - $40 - Ord(S2>=$80);

        Result := table_gbkext1[Result];
        goto done;
      end;

      goto user_defined;
    end;
    if (S1 in [$a8..$fe])then
    begin
      if (S2 in [$40..$7e, $80..$a0]) then
      begin
        Result := 96 * (S1 - $a8) + S2 - $40 - Ord(S2>=$80);

        Result := table_gbkext2[Result];
        goto done;
      end;

      goto user_defined;
    end;
    if (S1 = $a2) and (S2 in [$a1..$aa]) then
    begin
      Result := $2170+(S2-$a1);
      goto done;
    end;

user_defined:
    // User-defined characters
    case S1 of
      $a1..$a2:
      begin
        if (S2 in [$40..$7e, $80..$a0]) then
        begin
          Result := $e4c6 + 96 * (S1 - $a1) + (S2 - $40 - Ord(S2 >= $80));
          goto done;
        end;
      end;
      $aa..$af,$f8..$fe:
      begin
        if (S2 in [$a1..$fe]) then
        begin
          if (S1 >= $f8) then Dec(S1, $f2) else Dec(S1, $aa);
          Result := $e000 + 94 * (S1) + (S2 - $a1);
          goto done;
        end;
      end;
    end;
end;

fail: // SrcRead := SrcSize+1;
unknown: // Result := '?';
  Result := UNKNOWN_CHARACTER;
done:
  SrcRead := 2;
end;

function TTextConvContext.gb2312_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
var
  C1, C2: Cardinal;
begin
  Result := 1;

  if (X <= $7f) then
  begin
    Dest^ := X;
    Exit;
  end;
  if (X = $20ac) then
  begin
    Dest^ := $80;
    Exit;
  end;

  Inc(Result){2};
  if (DestSize < Result) then {too_small}
  begin
    Result := 0;
    Exit;
  end;

  if (gbk_wctomb(X, Dest)) then Exit;

  if (X >= $e000) and (X < $e586) then
  begin
    if (X < $e4c6) then
    begin
      Dec(X, $e000);
      C1 := (X * $2B932) shr 24;
      C2 := X - C1 * 94;
      if (C1 < 6) then Inc(C1, $aa) else Inc(C1, $f2);

      Dest^ := C1;
      Inc(Dest);
      Dest^ := C2 + $a1;
      Exit;
    end else
    begin
      Dec(X, $e4c6);
      C1 := (X * $2AAAB) shr 24;
      C2 := X - C1 * 96;

      Dest^ := C1 + $a1;
      Inc(C2, Ord(C2 >= $3f));
      Inc(Dest);
      Dest^ := C2 + $40;
      Exit;
    end;
  end;

  Dec(Result){1};
  Dest^ := UNKNOWN_CHARACTER;
end;

function TTextConvContext.gb2312_convertible(X: NativeUInt): Boolean;
var
  Buf: Word;
begin
  case X of
    0..$7f, $20ac, $e000..$e586-1: Result := True;
  else
    Result := gbk_wctomb(X, Pointer(@Buf));
  end;
end;

function TTextConvContext.gb18030_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
label
  look_gbkext, look_gb18030ext, unknown, fail;
var
  S1, S2, S3, S4: Byte;
  K, K1, K2: Cardinal;
begin
  S1 := Src^;
  Inc(Src);

  if (S1 <= $7f) then
  begin
    Result := S1;
    SrcRead := 1;
    Exit;
  end;

  SrcRead := 2;
  if (SrcSize < 2) then goto fail;
  S2 := Src^;

  if not(S1 in [$a1..$f7]) then goto look_gbkext;

  // some consts
  if (S1 = $a1) then
  begin
    if (S2 = $a4) then
    begin
      Result := $00b7;
      Exit;
    end;
    if (S2 = $aa) then
    begin
      Result := $2014;
      Exit;
    end;
  end;

  if (S2 in [$a1..$fe]) then
  begin
    // gb2312_mbtowc
    if (S1 in [$a1..$a9, $b0..$f7]) then
    begin
      Result := 94 * (S1 - $a1) + (S2 - $a1);

      Result := table_gb2312[Result];
      if (Result <> $fffd) then Exit;
    end;

    // cp936ext_mbtowc
    if (S1 in [$a6, $a8]) and (S2 in [$40..$7e, $80..$fe]) then
    begin
      Result := 190 *(S1 - $81) + S2 - $40 - Ord(S2 >= $80);

      case Result of
        7189..7210: Result := table_cp936ext_1[Result - 7189];
        7532..7537: Result := table_cp936ext_2[Result - 7532];
      else
        Result := $fffd;
      end;

      if (Result <> $fffd) then
      Exit;
    end;
  end;


look_gbkext:
  if (S1 in [$81..$a0]) then
  begin
    if (S2 in [$40..$7e, $80..$fe]) then
    begin
      Result := 190 * (S1 - $81) + S2 - $40 - Ord(S2 > $7f);

      Result := table_gbkext1[Result];
      Exit;
    end;

    goto look_gb18030ext;
  end;
  if (S1 in [$a8..$fe])then
  begin
    if (S2 in [$40..$7e, $80..$a0]) then
    begin
      Result := 96 * (S1 - $a8) + S2 - $40 - Ord(S2 > $7f);

      Result := table_gbkext2[Result];
      if (Result <> $fffd) then Exit;

      goto look_gb18030ext;
    end;

    goto look_gb18030ext;
  end;
  if (S1 = $a2) and (S2 in [$a1..$aa]) then
  begin
    Result := S2 + ($2170 - $a1);
    Exit;
  end;

look_gb18030ext:
  if (S1 in [$a2, $a4..$a9, $d7, $fe]) and (S2 in [$40..$7e,$80..$fe]) then
  begin
    if (S1 = $fe) then
    case S2 of
      $51: begin Result := $20087; Exit; end;
      $52: begin Result := $20089; Exit; end;
      $53: begin Result := $200cc; Exit; end;
      $6c: begin Result := $215d7; Exit; end;
      $76: begin Result := $2298f; Exit; end;
      $91: begin Result := $241fe; Exit; end;
    end;

    case S1 of
      $a2: Result := 0;
      $a4..$a9: Result := (S1 - $a4) + 1{7};
      $d7: Result := 8;
    else
      Result := 9;
    end;
    Result := 190 * Result + Cardinal(S2) - $40 - (S2 shr 7);

    Result := table_gb18030ext[Result];
    if (Result <> $fffd) then Exit;
  end;

  if (S1 in [$aa..$af, $f8..$fe]) then
  begin
    if (S2 in [$a1..$fe]) then
    begin
      if (S1 >= $f8) then Dec(S1, $f2) else Dec(S1, $aa);
      Result := 94*S1 + S2 + ($e000 - $a1);
      Exit;
    end;
  end else
  if (S1 in [$a1..$a7]) and (S2 in [$40..$a1]) and (S2 <> $7f) then
  begin
    Result := 96*(S1-$a1) + S2 - Ord(S2 > $7f) + ($e4c6 - $40);
    Exit;
  end;

  SrcRead := 4;
  if (SrcSize < 4) then goto fail;
  Inc(Src);
  S3 := Src^;
  Inc(Src);
  S4 := Src^;

  if  (S1 >= $81) and (S1 <= $84)
  and (S2 >= $30) and (S2 <= $39)
  and (S3 >= $81) and (S3 <= $fe)
  and (S4 >= $30) and (S4 <= $39) then
  begin
    Result := (((S1 - $81) * 10 + (S2 - $30)) * 126 + (S3 - $81)) * 10 + (S4 - $30);
    if (Result > 39419) then goto unknown;

    K1 := 0;
    K2 := 205;
    while (K1 < K2) do
    begin
      k := (K1 + K2) shr 1;
      if (Result <= range_gb18030_read[2*k+1]) then K2 := k
      else
      if (Result >= range_gb18030_read[2*k+2]) then K1 := k + 1
      else
      goto unknown;
    end;

    Inc(Result, offsets_gb18030[K1]);
    Exit;
  end;

  if  (S1 >= $90) and (S1 <= $e3)
  and (S2 >= $30) and (S2 <= $39)
  and (S3 >= $81) and (S3 <= $fe)
  and (S4 >= $30) and (S4 <= $39) then
  begin
    Result := (((S1 - $90) * 10 + (S2 - $30)) * 126 + (S3 - $81)) * 10 + (S4 - $30);
    if (Result < $100000) then
    begin
      Inc(Result, $10000);
      Exit;
    end;
  end;

fail:
unknown:
  Result := UNKNOWN_CHARACTER;
end;


function TTextConvContext.gb18030_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
label
  done_2, write_4, fail;
const
  gb18030_range_values: array[0..96 - 1] of Word = (
  $e766, $e76b,  $a2ab, $e76d, $e76d,  $a2e4, $e76e, $e76f,  $a2ef,
  $e770, $e771,  $a2fd, $e772, $e77c,  $a4f4, $e77d, $e784,  $a5f7,
  $e785, $e78c,  $a6b9, $e78d, $e793,  $a6d9, $e794, $e795,  $a6ec,
  $e796, $e796,  $a6f3, $e797, $e79f,  $a6f6, $e7a0, $e7ae,  $a7c2,
  $e7af, $e7bb,  $a7f2, $e7bc, $e7c6,  $a896, $e7c7, $e7c7,  $a8bc,
  $e7c9, $e7cc,  $a8c1, $e7cd, $e7e1,  $a8ea, $e7e2, $e7e2,  $a958,
  $e7e3, $e7e3,  $a95b, $e7e4, $e7e6,  $a95d, $e7f4, $e800,  $a997,
  $e801, $e80f,  $a9f0, $e810, $e814,  $d7fa, $e816, $e818,  $fe51,
  $e81e, $e81e,  $fe59, $e826, $e826,  $fe61, $e82b, $e82c,  $fe66,
  $e831, $e832,  $fe6c, $e83b, $e83b,  $fe76, $e843, $e843,  $fe7e,
  $e854, $e855,  $fe90, $e864, $e864,  $fea0);
var
  K1, K2, K: Cardinal;
  W: Word;
begin
  if (X <= $7f) then
  begin
    Dest^ := X;
    Result := 1;
    Exit;
  end;

  if (DestSize < 2) then goto fail; {too_small}

  if (X shr 11 = $1b) then X := $fffd;

  if (gbk_wctomb(X, Dest)) then
  begin
  done_2:
    Result := 2;
    Exit;
  end;

  case X of
    $20087: begin PWord(Dest)^ := $51fe; goto done_2; end;
    $20089: begin PWord(Dest)^ := $52fe; goto done_2; end;
    $200cc: begin PWord(Dest)^ := $53fe; goto done_2; end;
    $215d7: begin PWord(Dest)^ := $6cfe; goto done_2; end;
    $2298f: begin PWord(Dest)^ := $76fe; goto done_2; end;
    $241fe: begin PWord(Dest)^ := $91fe; goto done_2; end;
  else
    if (X <= $ffff) and (X <> $fffd) then
    begin
      W := hash_gb18030ext.Find(X);
      if (W <> High(Word)) then
      begin
        if (W >= $3f00) then Inc(W, $0100);

        case Byte(W) of
             0: PWord(Dest)^ := W + $40a2;
          1..7: PWord(Dest)^ := W + $40a3;
             8: PWord(Dest)^ := W + $40cf;
             9: PWord(Dest)^ := W + $40f5;
        end;

        goto done_2;
      end;
    end;
  end;

  case X of
    $e000..$e4c5:
    begin
      Dec(X, $e000);
      K := (X * $2b932) shr 24; // X div 94
      X := (X - (K * 94)) shl 8 + $a100; // X mod 94;

      if (K < 6) then Inc(K, $aa) else Inc(K, $f2);
      PWord(Dest)^ := K+X;
      goto done_2;
    end;
    $e4c6..$e765:
    begin
      Dec(X, $e4c6);
      K := (X * $2aaab) shr 24; // X div 96
      X := X - (K * 96); // X mod 96;

      Inc(K, $40a1);
      PWord(Dest)^ := ((X + Byte(X >= $3f)) shl 8) + K;
      goto done_2;
    end;
    $e766..$e864:
    begin
      K1 := 0;
      K2 := 32;

      while (K1 < K2) do
      begin
        K := (K1 + K2) shr 1;
        if (X < gb18030_range_values[K * 3+0]) then K2 := K
        else
        if (X > gb18030_range_values[K * 3+1]) then K1 := K + 1
        else
        begin
          PWord(Dest)^ := Swap(X - gb18030_range_values[K * 3 + 0] + gb18030_range_values[K * 3 + 2]);
          goto done_2;
        end;
      end;
    end;
  end;

  if (DestSize < 4) then {too_small}
  begin
  fail:
    Result := 0;
    Exit;
  end;

  if (X <= $ffff) then
  begin
    K1 := 0;
    K2 := 205;
    while (K1 < K2) do
    begin
      K := (K1 + K2) shr 1;
      if (X <= range_gb18030_write[2 * K + 1]) then K2 := K
      else
      if (X >= range_gb18030_write[2 * K + 2]) then K1 := K + 1
      else
      begin
        Dest^ := UNKNOWN_CHARACTER;
        Result := 1;
        Exit;
      end;
    end;

    Dec(X, offsets_gb18030[K1]);
    K := $30813081;

    goto write_4;
  end else
  begin
    Dec(X, $10000);
    K := $30813090;

  write_4:
    K1 := X div 10;
    Inc(K, (X - K1 * 10) shl 24);

    if (K1 <> 0) then
    begin
      X := K1;
      K1 := X div 126;
      Inc(K, (X - K1 * 126) shl 16);

      if (K1 <> 0) then
      begin
        X := K1;
        K1 := X div 10;
        Inc(k, K1);
        Inc(k, (X - K1 * 10) shl 8);
      end;
    end;

    PCardinal(Dest)^ := K;
    Result := 4;
  end;
end;


function TTextConvContext.gb18030_convertible(X: NativeUInt): Boolean;

begin
  case (X) of
    $E78D..$E796,
    $E7C7..$E7C7,
    $E816..$E818,
    $E81E..$E81E,
    $E826..$E826,
    $E82B..$E82C,
    $E831..$E832,
    $E83B..$E83B,
    $E843..$E843,
    $E854..$E855,
    $E864..$E864: Result := False;
  else
    Result := True;
  end;
end;

function TTextConvContext.hzgb2312_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
label
  unknown, too_small, done;
var
  Count: Cardinal;
  State, S2: Byte;
begin
  State := Self.FState.Read.B;

  Result := Src^;
  Count := 1;
  while (Result = Ord('~')) do
  begin
    Inc(Count);
    Inc(Src);
    if (SrcSize < Count) then goto too_small;
    S2 := Src^;

    if (State = 0) then
    begin
       case S2 of
         Ord('~'):
         begin
           //Result := S2;
           goto done;
         end;
         Ord('{'):
         begin
           State := 1;
         end;
         10: {ignore};
       else
         goto unknown;
       end;
    end else
    if (S2 = Ord('}')) then
    begin
      State := 0;
    end else
    goto unknown;

    Inc(Count);
    Inc(Src);
    if (SrcSize < Count) then
    begin
      if (State = 0) then Count := High(Cardinal){-1}; // goto none;
      goto too_small{/done};
    end;
    Result := Src^;
  end;

  if (State <> 0) then
  begin
    Inc(Count);
    Inc(Src);
    if (SrcSize < Count) then goto too_small;
    S2 := Src^;

    if (Result in [$21..$29, $30..$77]) and (S2 in [$21..$7e]) then
    begin
      Result := 94 * (Integer(Result) - $21) + (S2 - $21);

      Result := table_gb2312[Result];
    end else
    begin
    unknown:
      Result := UNKNOWN_CHARACTER;
    end;
  end;

too_small:
done:
  Self.FState.Read.B := State;
  SrcRead := Count;
end;

function TTextConvContext.hzgb2312_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
label
  ascii, unknown, done, fail;
var
  State: Byte;
  W: Word;
begin
  State := Self.FState.Write.B;

  if (X = High(Cardinal)) then
  begin
    if (State = 0) then
    begin
      Result := High(Cardinal);
      Exit;
    end;

    Result := 0;
    Dec(Dest, 2);
    goto done;
  end;

  if (X <= $7f) then
  begin
  ascii:
    Result := 1;

    if (State <> 0) then
    begin
      Inc(Result, 2){:= 3};
      if (DestSize < 3) then goto fail;

      PWord(Dest)^ := $7d7e;
      Inc(Dest, 2);
      Self.FState.Write.B := 0;
    end;

    if (X = Ord('~')) then
    begin
      Inc(Result){:= 2/4};
      if (DestSize < Result) then goto fail;

      Dest^ := X;
      Inc(Dest);
    end;

    Dest^ := X;
    Exit;
  end;

  if (X > $ffff) or (X = $fffd) then
  begin
  unknown:
    X := UNKNOWN_CHARACTER;
    goto ascii;
  end;

  W := hash_gb2312.Find(X);
  if (W = High(Word)) then goto unknown;

  Inc(W, $2121);

  Result := 4 - State * 2;
  if (DestSize < Result) then goto fail;
  if (State = 0) then
  begin
    PWord(Dest)^ := $7b7e;
    Inc(Dest, 2);
    Self.FState.Write.B := 1;
  end;
  PWord(Dest)^ := W;

done:
  if (ModeFinal) then
  begin
    Inc(Result, 2);
    Inc(Dest, 2);
    if (DestSize < Result) then {too_small}
    begin
    fail:
      Result := 0;
      Exit;
    end;
    PWord(Dest)^ := $7d7e;
  end;
end;

function TTextConvContext.hzgb2312_convertible(X: NativeUInt): Boolean;
begin
  if (X < $80) then Result := True
  else
  Result := (hash_gb2312.Find(X) <> High(Word));
end;

function TTextConvContext.big5_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
label
  fail, unknown, done;
var
  S1, S2: Byte;
begin
  S1 := Src^;
  Inc(Src);

  if (S1 <= $7f) then
  begin
    Result := S1;
    SrcRead := 1;
    Exit;
  end;

  if (S1 in [$80, $ff]) then goto unknown;
  if (SrcSize < 2) then goto fail;
  S2 := Src^;
  if (S2 in [$0..$39 ,$80, $ff]) then goto unknown;

  Result := 190 * (S1 - $80) + S2 - $40 - (S2 shr 7);
  Result := table_big5[Result];
  goto done;

fail:
unknown:
  Result := UNKNOWN_CHARACTER;
done:
  SrcRead := 2;
end;

function TTextConvContext.big5_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
label
  unknown, done_1, done;
var
  W: Word;
begin
  if (X <= $7f) then
  begin
    Dest^ := X;
    goto done_1;
  end;

  if (DestSize < 2) then {too_small}
  begin
    Result := 0;
    Exit;
  end;

  if (X = $a5) then
  begin
    PWord(Dest)^ := $44a2;
    goto done;
  end;

  if (X <= $ffff) and (X <> $fffd) then
  begin
    W := hash_big5.Find(X);
    if (W <> High(Word)) then
    begin
      if (W >= $3f00) then Inc(W, $0100);
      PWord(Dest)^ := W + $4080;
      goto done;
    end;
  end;

unknown:
  Dest^ := UNKNOWN_CHARACTER;
done_1:
  Result := 1;
  Exit;
done:
  Result := 2;
end;

function TTextConvContext.big5_convertible(X: NativeUInt): Boolean;
begin
  if (X <= $7f) then Result := True
  else
  Result := (hash_big5.Find(X) <> High(Word));
end;

function TTextConvContext.shift_jis_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
label
  unknown, fail, done;
var
  S1: Byte;
  S2: Byte;
begin
  S1 := Src^;
  Inc(Src);

  case S1 of
    0..$7f:
    begin
      if (S1 = $5c) then Result := $00a5
      else
      if (S1 = $7e) then Result := $203e
      else
      Result := S1;

      SrcRead := 1;
      Exit;
    end;
    $a1..$df:
    begin
      Result := S1 + $fec0;
      SrcRead := 1;
      Exit;
    end;
    $81..$9f, $e0..$ea:
    begin
      if (SrcSize < 2) then goto fail;
      S2 := Src^;
      if (S2 in [$40..$7e, $80..$fc]) then
      begin
        S1 := S1 - (Ord(S1 >= $e0) shl 6) - $81;
        S2 := S2 - Ord(S2 >= $80) - ($40-$21);
        S1 := 2*S1 + $21 + Ord(S2 >= ($5e+$21));
        if (S2 >= ($5e+$21)) then Dec(S2, $5e);

        if (S1 in [$21..$28, $30..$74]) then
        begin
          Result := 94 * (S1 - $21) + (S2 - $21);
          Result := table_jisx0208[Result];
          goto done;
        end;
      end;
    end;
    $f0..$f9:
    begin
      if (SrcSize < 2) then goto fail;
      S2 := Src^;

      if (S2 in [$40..$7e, $80..$fc]) then
      begin
        Result := ($e000-$40) + 188*(S1 - $f0) + S2 - Ord(S2>$7f);
        goto done;
      end;
    end;
  end;


fail: // SrcRead := SrcSize+1;
unknown: // Result := '?';
  Result := UNKNOWN_CHARACTER;
done:
  SrcRead := 2;
end;


function TTextConvContext.shift_jis_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
label
  not_jisx0201;
var
  C, C2: Byte;
  W: Word;
begin
  Result := 1;

  case X of
    0..$7f:
    begin
      if (X = $005c) or (X = $007e) then goto not_jisx0201;
      Dest^ := X;
      Exit;
    end;
    $00a5:
    begin
      Dest^ := $5c;
      Exit;
    end;
    $203e:
    begin
      Dest^ := $7e;
      Exit;
    end;
    $ff61..$ff9f:
    begin
      Dest^ := X - $fec0;
      Exit;
    end;
    $e000..$e757:
    begin
      Inc(Result){2};
      if (DestSize < 2) then Exit;

      Dec(X, $e000);
      C := (X*$15c99) shr 24; //X div 188;

      Dest^ := C+$f0;
      C := X - (Cardinal(C)*188);
      Inc(Dest);
      Inc(C, Ord(C >= $3f));
      Inc(C, $40);
      Dest^ := C;
      Exit;
    end;
  end;

not_jisx0201:
  Inc(Result){2};
  if (DestSize < Result) then {too small}
  begin
    Result := 0;
    Exit;
  end;

  if (X <= $ffff) and (X <> $fffd) then
  begin
    W := hash_jisx0208.Find(X);
    if (W <> High(Word)) then
    begin
      C2 := W shr 8;
      C := W;

      if (C and 1 <> 0) then Inc(C2, $5e);

      C := C shr 1;
      Dest^ := C + (Ord(C >= $1f) shl 6) + $81;

      Inc(C2, Ord(C2 >= $3f));
      Inc(Dest);
      Inc(C2, $40);
      Dest^ := C2;
      Exit;
    end;
  end;

  Dest^ := UNKNOWN_CHARACTER;
  Dec(Result);{1}
end;

function TTextConvContext.shift_jis_convertible(X: NativeUInt): Boolean;
begin
  case X of
   0..$7f: Result := (X <> $5c) and (X <> $7e);
    $00a5, $203e, $ff61..$ff9f, $e000..$e757: Result := True;
  else
    Result := (hash_jisx0208.Find(X) <> High(Word));
  end;
end;

function TTextConvContext.euc_jp_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
label
  unknown, fail, done;
var
  S1: Byte;
  S2: Byte;
begin
  S1 := Src^;
  Inc(Src);

  case S1 of
    0..$7f:
    begin
      Result := S1;
      SrcRead := 1;
      Exit;
    end;
    $a1..$fe:
    begin
      if (SrcSize < 2) then goto fail;
      S2 := Src^;
      if (S2 < $a1) or (S2 = $ff) then goto unknown;

      if (S1 >= $f5) then
      begin
        Result := $e000 + 94*(S1-$f5) + (S2-$a1);
        goto done;
      end else
      if not(S1 in [$a9..$af]) then
      begin
        Result := 94 * (S1 - $a1) + (S2 - $a1);

        Result := table_jisx0208[Result];
        goto done;
      end;
    end;
    $8e:
    begin
      if (SrcSize < 2) then goto fail;
      S2 := Src^;

      if (S2 >= $a1) and (S2 < $e0) then
      begin
        Result := S2 + $fec0;
        goto done;
      end;
    end;
    $8f:
    begin
      if (SrcSize < 3) then goto fail;
      S1 := Src^;
      SrcRead := 3;
      Inc(Src);
      if (S1 < $a1) or (S1 = $ff) then goto unknown;
      S2 := Src^;

      if (S1 >= $f5) then
      begin
        Result := $e3ac + 94*(S1-$f5) + (S2-$a1);
        Exit;
      end else
      if (S1 in [$a2, $a6..$a7, $a9..$ab, $b0..$ed]) then
      begin
        Result := 94 * (S1 - $a1) + (S2 - $a1);

        Result := table_jisx0212[Result];
        Exit;
      end;
    end;
  end;

fail: // SrcRead := SrcSize+1;
unknown: // Result := '?';
  Result := UNKNOWN_CHARACTER;
done:
  SrcRead := 2;
end;

function TTextConvContext.euc_jp_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
label
  fill_divided, fill_a1a1, unknown;
var
  C: Byte;
  W: Word;
begin
  Result := 2;

  case X of
    0..$7f:
    begin
      Dest^ := X;
      Dec(Result){1};
    end;
    $00a5:
    begin
      Dest^ := $5c;
      Dec(Result){1};
    end;
    $203e:
    begin
      Dest^ := $7e;
      Dec(Result){1};
      Exit;
    end;
    $e000..$e3ab:
    begin
      if (DestSize < Result{2}) then {too small}
      begin
        Result := 0;
        Exit;
      end;
      Dec(X, $e000);
      goto fill_divided;
    end;
    $e3ac..$e757:
    begin
      Inc(Result);
      if (DestSize < Result{3}) then {too small}
      begin
        Result := 0;
        Exit;
      end;
      Dec(X, $e3ac);
      Dest^ := $8f;
      Inc(Dest);

      fill_divided:
      C := (X*$2b932) shr 24; //X div 94;
      PWord(Dest)^ := ((X - C*94) shl 8) + C + $a1f5;
    end;
    $ff61..$ff9f:
    begin
      if (DestSize < Result{2}) then {too small}
      begin
        Result := 0;
        Exit;
      end;
      PWord(Dest)^ := ((X - $fec0) shl 8) + $8e;
    end;
  else
    if (X > $ffff) or (X = $fffd) then goto unknown;

    W := hash_jisx0208.Find(X);
    if (W <> High(Word)) then
    begin
      if (DestSize < Result{2}) then {too small}
      begin
        Result := 0;
        Exit;
      end;
      goto fill_a1a1;
    end;

    W := hash_jisx0212.Find(X);
    if (W <> High(Word)) then
    begin
      Inc(Result){3};
      if (DestSize < 3) then {too small}
      begin
        Result := 0;
        Exit;
      end;
      Dest^ := $8f;
      Inc(Dest);

      fill_a1a1:
      PWord(Dest)^ := W + $a1a1;
      Exit;
    end;

  unknown:
    Dest^ := UNKNOWN_CHARACTER;
    Dec(Result){1};
  end;
end;

function TTextConvContext.euc_jp_convertible(X: NativeUInt): Boolean;
begin
  case X of
    0..$7f, $e000..$e3ab, $e3ac..$e757, $ff61..$ff9f: Result := True;
  else
    Result := (hash_jisx0208.Find(X) <> High(Word)) or
              (hash_jisx0212.Find(X) <> High(Word));
  end;
end;

const
  JIS_ASCII = 0;
  JIS_X0201ROMAN = 1;
  JIS_X0208 = 2;
  JIS_X0212 = 3;

  JIS_ESC = $1b;

function TTextConvContext.iso2022jp_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
label
  unknown, too_small, done;
var
  Count: Cardinal;
  State, S2: Byte;
begin
  State := Self.FState.Read.B;

  Result := Src^;
  Count := 1;
  while (Result = JIS_ESC) do
  begin
    Inc(Count, 2);
    Inc(Src);
    if (SrcSize < Count) then goto too_small;

    case Src^ of
      Ord('('):
      begin
        Inc(Src);
        case Src^ of
          Ord('B'): State := JIS_ASCII;
          Ord('J'): State := JIS_X0201ROMAN;
        else
          goto unknown;
        end;
      end;
      Ord('$'):
      begin
        Inc(Src);
        case Src^ of
          Ord('@'), Ord('B'): State := JIS_X0208;
          Ord('('):
          begin
            Inc(Count);
            Inc(Src);
            State := JIS_X0212;
            if (SrcSize < Count) then goto too_small;
            if (Src^ <> Ord('D')) then goto unknown;
          end;
        end;
      end;
    end;

    Inc(Count);
    Inc(Src);
    if (SrcSize < Count) then
    begin
      if (State = JIS_ASCII) then Count := High(Cardinal){-1}; //goto none;
      goto too_small{/done};
    end;
    Result := Src^;
  end;

  case (State) of
    JIS_ASCII:
    begin
      if (Result <= $7f) then goto done;
    end;
    JIS_X0201ROMAN:
    begin
      if (Result > $7f) then goto unknown;

      if (Result = $5c) then Result := $00a5
      else
      if (Result = $7e) then Result := $203e;

      goto done;
    end;
    JIS_X0208,
    JIS_X0212:
    begin
      Inc(Count);
      if (SrcSize < Count) then goto too_small;
      if (PWord(Src)^ and $8080 = 0) then
      begin
        Inc(Src);
        S2 := Src^;

        if (State = JIS_X0208) then
        begin
          if (Result in [$21..$28, $30..$74]) and (S2 in [$21..$7e]) then
          begin
            Result := 94 * (Integer(Result) - $21) + (S2 - $21);

            Result := table_jisx0208[Result];
            goto done;
          end;
        end else
        // if (State = JIS_X0212) then
        begin
          if (Result in [$22, $26..$27, $29..$2b, $30..$6d]) and (S2 in [$21..$7e]) then
          begin
            Result := 94 * (Integer(Result) - $21) + (S2 - $21);

            Result := table_jisx0212[Result];
            goto done;
          end;
        end;
      end;
    end;
  end;

unknown:
  Result := UNKNOWN_CHARACTER;
too_small:
done:
  Self.FState.Read.B := State;
  SrcRead := Count;
end;

function TTextConvContext.iso2022jp_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
label
  unknown, std_write, not_jisx0201, done;
const
  MASK_ASCII = ((JIS_ESC shl 8) + (Ord('(') shl 16) + (Ord('B') shl 24)) + JIS_ASCII;
  MASK_X0201ROMAN = ((JIS_ESC shl 8) + (Ord('(') shl 16) + (Ord('J') shl 24)) + JIS_X0201ROMAN;
var
  State: Byte;
  Mask: Cardinal;
  W: Word;
begin
  State := Self.FState.Write.B;
  if (X = High(Cardinal)) then
  begin
    if (State = JIS_ASCII) then
    begin
      Result := High(Cardinal);
      Exit;
    end;

    Result := 3;
    if (DestSize < Result) then {too small}
    begin
      Result := 0;
      Exit;
    end;

    PWord(Dest)^ := JIS_ESC + (Ord('(') shl 8);
    Inc(Dest, 2);
    Dest^ := Ord('B');
    Exit;
  end;

  case X of
    0..$7f:
    begin
      Mask := MASK_ASCII;
      goto std_write;
    end;
    $00a5:
    begin
      X := $5c;
      Mask := MASK_X0201ROMAN;
      goto std_write;
    end;
    $203e:
    begin
      X := $7e;
      Mask := MASK_X0201ROMAN;
      goto std_write;
    end;
  else
    if (X > $ffff) or (X = $fffd) then goto unknown;

    W := hash_jisx0208.Find(X);
    if (W <> High(Word)) then
    begin
      W := W + $2121;

      Result := Byte(State<>JIS_X0208)*3 + 2;
      if (DestSize < Result) then {too small}
      begin
        Result := 0;
        Exit;
      end;

      if (State = JIS_X0208) then
      begin
        PWord(Dest)^ := W;
      end else
      begin
        PCardinal(Dest)^ := (W shl 24) + (JIS_ESC + (Ord('$') shl 8) + (Ord('B') shl 16));
        Inc(Dest, 4);
        State := JIS_X0208;
        Dest^ := W shr 8;
      end;

      goto done;
    end;

    W := hash_jisx0212.Find(X);
    if (W <> High(Word)) then
    begin
      W := W + $2121;

      Result := Byte(State<>JIS_X0212)*4 + 2;
      if (DestSize < Result) then {too small}
      begin
        Result := 0;
        Exit;
      end;

      if (State <> JIS_X0212) then
      begin
        PCardinal(Dest)^ := (JIS_ESC + (Ord('$') shl 8) + (Ord('(') shl 16) + (Ord('D') shl 24));

        Inc(Dest, 4);
        State := JIS_X0212;
      end;
      PWord(Dest)^ := W;
      Inc(Dest);
      goto done;
    end;

  unknown:
    X := UNKNOWN_CHARACTER;
    Mask := MASK_ASCII; // goto ascii;
  end;

std_write:
  Result := Byte(State<>Byte(Mask))*3 + 1;
  if (DestSize < Result) then {too small}
  begin
    Result := 0;
    Exit;
  end;

  if (State = Byte(Mask)) then
  begin
    Dest^ := X;
  end else
  begin
    State := Mask;
    PCardinal(Dest)^ := (X shl 24) + (Mask shr 8);
    Inc(Dest, 3);
  end;

done:
  if (ModeFinal) and (State <> JIS_ASCII) then
  begin
    Inc(Result, 3);
    if (DestSize < Result) then {too small}
    begin
      Result := 0;
      Exit;
    end;

    PCardinal(Dest)^ := Cardinal(Dest^) + ((JIS_ESC shl 8) + (Ord('(') shl 16) + (Ord('B') shl 24));
    State := JIS_ASCII;
  end;
  Self.FState.Write.B := State;
end;

function TTextConvContext.iso2022jp_convertible(X: NativeUInt): Boolean;
begin
  case X of
    0..$7f, $00a5, $203e: Result := (X <> $1b);
  else
    Result := (hash_jisx0208.Find(X) <> High(Word)) or
              (hash_jisx0212.Find(X) <> High(Word));
  end;
end;

function TTextConvContext.cp949_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
label
  unknown, too_small, done;
var
  C2: Byte;
begin
  Result := Src^;
  Inc(Src);

  case Result of
    0..$7f:
    begin
      SrcRead := 1;
      Exit;
    end;
    $81..$a0:
    begin
      if (SrcSize < 2) then goto too_small;

      C2 := Src^;
      if (C2 in [$41..$5a, $61..$7a, $81..$fe]) then
      begin
        Dec(Result, $81);

        if (C2 >= $81) then Dec(C2, $4d)
        else
        if (C2 >= $61) then Dec(C2, $47)
        else
        Dec(C2, $41);

        Result := 178*Result + C2;

        Result := table_uhc_1[Result];
        goto done;
      end;
    end;
    $a1..$fe:
    begin
      if (SrcSize < 2) then goto too_small;

      C2 := Src^;
      if (C2 < $a1) then
      begin
        if (Result <= $c6) and (C2 in [$41..$5a, $61..$7a, $81..$a0]) then
        begin
          Dec(Result, $a1);
          if (C2 >= $81) then Dec(C2, $4d)
          else
          if (C2 >= $61) then Dec(C2, $47)
          else
          Dec(C2, $41);

          Result := 84*Result + C2;
          Result := table_uhc_2[Result];
          goto done;
        end;
      end else
      if (C2 < $ff) and ((Result <> $a2) or (C2 <> $e8)) then
      begin
        if (Result in [$a1..$ac, $b0..$c8, $ca..$fd]) then
        if (C2 in [$a1..$fe]) then
        begin
          Result := 94 * (Integer(Result) - $a1) + (C2 - $a1);
          Result := table_ksc5601[Result];
          goto done;
        end;

        if (Result = $c9) then
        begin
          Result := $e000 + (C2 - $a1);
          goto done;
        end else
        if (Result = $fe) then
        begin
          Result := $e05e + (C2 - $a1);
          goto done;
        end;
      end;
  end;
  end;

unknown:
  Result := UNKNOWN_CHARACTER;
too_small:
done:
  SrcRead := 2;
end;

function TTextConvContext.cp949_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
label
  unknown;
var
  W: Word;
begin
  Result := 1;

  if (X <= $7f) then
  begin
    Dest^ := X;
    Exit;
  end;

  Inc(Result);
  if (DestSize < Result{2}) then {too small}
  begin
    Result := 0;
    Exit;
  end;

  if (X <> $327e) and (X <= $ffff) and (X <> $fffd) then
  begin
    W := hash_ksc5601.Find(X);
    if (W <> High(Word)) then
    begin
      PWord(Dest)^ := W + $a1a1;
      Exit;
    end;
  end;

  case X of
    $ac00..$c8a4:
    begin
      W := hash_uhc_1.Find(X);
      if (W = High(Word)) then goto unknown;

      case (W shr 8) of
        0..25: PWord(Dest)^ := W +$4181;
       26..51: PWord(Dest)^ := W +$4781;
      else
        PWord(Dest)^ := W + $4d81;
      end;

      Exit;
    end;
    $c8a5..$d7a3:
    begin
      W := hash_uhc_2.Find(X);
      if (W = High(Word)) then goto unknown;

      case (W shr 8) of
        0..25: PWord(Dest)^ := W +$41a1;
       26..51: PWord(Dest)^ := W +$47a1;
      else
        PWord(Dest)^ := W + $4da1;
      end;

      Exit;
    end;
    $e000..$e05d:
    begin
      PWord(Dest)^ := (X shl 8) - ($e00000 - $a100 - $c9);
    end;
    $e05e..$e0bb:
    begin
      PWord(Dest)^ := (X shl 8) - ($e05e00 - $a100 - $fe);
    end;
  else
  unknown:
    Dec(Result);
    Dest^ := UNKNOWN_CHARACTER;
  end;
end;

function TTextConvContext.cp949_convertible(X: NativeUInt): Boolean;
begin
  case X of
    0..$7f, $e000..$e05d, $e05e..$e0bb: Result := True;
    $327e: Result := False;
  else
    if (hash_ksc5601.Find(X) <> High(Word)) then
    begin
      Result := True;
    end else
    case X of
      $ac00..$c8a4: Result := (hash_uhc_1.Find(X) <> High(Word));
      $c8a5..$d7a3: Result := (hash_uhc_2.Find(X) <> High(Word));
    else
      Result := False;
    end;
  end;
end;

function TTextConvContext.euc_kr_reader(SrcSize: Cardinal; Src: PByte; out SrcRead: Cardinal): Cardinal;
label
  unknown, done;
var
  C2: Byte;
begin
  Result := Src^;
  Inc(Src);
  case Result of
    0..$7f:
    begin
      SrcRead := 1;
      Exit;
    end;
    $a1..$ac, $b0..$c8, $ca..$fd:
    begin
      if (SrcSize < 2) then goto done;
      C2 := Src^;
      if not(C2 in [$a1..$fe]) then goto unknown;

      Result := 94 * (Integer(Result) - $a1) + (C2 - $a1);
      Result := table_ksc5601[Result];
    end;
  else
  unknown:
    Result := UNKNOWN_CHARACTER;
  end;

done:
  SrcRead := 2;
end;

function TTextConvContext.euc_kr_writer(X: Cardinal; Dest: PByte; DestSize: Cardinal; ModeFinal: Boolean): Cardinal;
label
  unknown, single_Byte;
var
  W: Word;
begin
  if (X > $7f) then
  begin
    if (X > $ffff) or (X = $fffd) then
    begin
      unknown:
      Dest^ := UNKNOWN_CHARACTER;
      goto single_Byte;
    end;

    if (DestSize < 2) then {too small}
    begin
      Result := 0;
      Exit;
    end;

    W := hash_ksc5601.Find(X);
    if (W = High(Word)) then goto unknown;

    PWord(Dest)^ := W + $a1a1;
    Result := 2;
  end else
  begin
    Dest^ := X;
  single_Byte:
    Result := 1;
  end;
end;

function TTextConvContext.euc_kr_convertible(X: NativeUInt): Boolean;
begin
  if (X <= $7f) then Result := True
  else
  Result := (hash_ksc5601.Find(X) <> High(Word));
end;
{$ifdef undef}{$ENDREGION}{$endif}

{$ifdef undef}{$REGION 'hieroglyph lookups'}{$endif}
const
  offsets_gb18030_data: array[0..25-1] of Cardinal = (
  $5081007f,$dfc11650,$50604213,$c0635063,$0570813f,$24cbcbc1,$83000f81,$dd005b8c,$4c33c9c9,$56810f24,
  $04400751,$61cb4100,$204860d2,$03560453,$90810a25,$d0000140,$9885159f,$7a01f4b8,$64af5543,$80211e5b,
  $10409982,$59213040,$26c364d1,$7f065e04,$00000000);

const
  range_gb18030_read_data: array[0..99-1] of Cardinal = (
  $2301ffff,$80060080,$82205d4c,$80000446,$00204148,$48800001,$6045604f,$2056604d,$2dc06180,$00016101,
  $00010001,$00010001,$00010001,$56011b01,$64010e01,$c07d0001,$0ad600a5,$06010020,$36010001,$00010d01,
  $f1987f01,$8000001e,$07458200,$80000100,$55016f0c,$44800001,$2048604a,$1508803d,$016d0080,$80000105,
  $00388a84,$80000100,$40738000,$43448024,$82204b60,$80240440,$57604944,$b80250a0,$01244074,$0c088063,
  $60484480,$4682204e,$11004146,$40801e01,$01002074,$2c40987f,$40418000,$8126c064,$40500840,$0c8e00a6,
  $00204260,$60404c80,$40822052,$9c8b8045,$600bd200,$026fa045,$25406e88,$82210080,$017069f8,$28a0697d,
  $c066d803,$a97801e4,$01540135,$a6407d5f,$a00a4600,$31d802d8,$7f017001,$003cdef8,$d5a00c1a,$80272803,
  $f6a06948,$40773802,$0afe00a9,$51204360,$a04e7d01,$e30803b7,$01000883,$54448013,$48e7d8e0,$b600b2c0,
  $0292a009,$7801e4f8,$000182bc,$0c010001,$8c800001,$8e883a8d,$4067407d,$d47801e6,$014b0193,$0150011a,
  $01190108,$80000100,$00204444,$c378057f,$80000198,$00010008,$7e010001,$67f80293,$0000ec40);

const
  range_gb18030_write_data: array[0..104-1] of Cardinal = (
  $2301007f,$80062180,$8220dd5e,$80001c56,$0020c16a,$59800003,$60c560cf,$20d660cd,$2dc16580,$00026102,
  $00020002,$00020002,$00020002,$56021b02,$64020e02,$c37d0002,$1ad601a5,$06080021,$36080012,$00410d02,
  $0fd87f02,$05204120,$82228000,$03000f55,$6f1d8000,$00025502,$60ca5580,$667c60c8,$62546542,$026d2240,
  $80000205,$8c868015,$00020019,$bcb48006,$8020c879,$0325c175,$24146082,$60c95580,$0650a0d7,$244a74b8,
  $034d6329,$02100c25,$0f030904,$56568203,$05111049,$f452801e,$7f020020,$112e8098,$64424580,$518126c1,
  $a6415819,$60cc8e01,$14002242,$69494b80,$06542041,$83570105,$d2259cbb,$a0c560ab,$6e88066f,$53802542,
  $4f8220e0,$7d700850,$a201b4c1,$026e201c,$787f020a,$54023917,$427d5f02,$1a4601a6,$d806d8a0,$02700231,
  $4055f87f,$a01c1a01,$272807d5,$a0e95980,$773806f6,$fe01a941,$a0c3601a,$a0e80650,$601ede01,$248020f0,
  $13030003,$e1545580,$c14c76d8,$79b605b2,$f80692a0,$9fa67ce4,$e76cd7ff,$1f005c00,$8000220c,$524d821f,
  $0f0d4e52,$7f020d03,$02f92b78,$021a024b,$02080250,$02000519,$c4568000,$f2800021,$03fe2f78,$0b031300,
  $0f000500,$937e0500,$4667f97a,$000000ec);

const
  gb18030ext_data: array[0..59-1] of Cardinal = (
  $167fe765,$32560b6a,$e76d20ac,$16030a16,$b316030c,$0fb61615,$160f7816,$fe107818,$05f97983,$16030c16,
  $02360105,$160fe797,$040f1f81,$55160d1f,$3f1b3615,$1c02161e,$fffd01f9,$1605e7c9,$16151f25,$02160118,
  $56050201,$f0303e28,$f422152f,$4c1617e7,$090a0f1f,$2e811036,$0ffe0316,$34732e84,$2e883447,$9fb42e8b,
  $361a359e,$2e8c360e,$396e2e97,$9fb53918,$4e0f39cf,$0eded5da,$9fb79fb6,$3c6e3b4e,$2ea73ce0,$9fb8fffd,
  $40562eaa,$2eae415f,$2eb34337,$fe02e042,$ac43b104,$dd2ebb43,$be2af843,$9fb97ade,$53064723,$cada7f11,
  $7249472e,$44800521,$dfdb5e58,$9fba04de,$4ca3fffd,$60404c9f,$7f713516,$bb4dae4b,$005e169f);

const
  uhc_2_data: array[0..163-1] of Cardinal = (
  $0080c8a4,$12bf7f02,$44105002,$20015800,$010ebfc4,$60430460,$7f020001,$000112bf,$1218bfc1,$00580044,
  $00504140,$4412b3d0,$bfc11800,$8046121f,$01454a49,$1052004e,$1040e040,$c10e9fc4,$44121fbf,$c4007800,
  $d00112bf,$bfc1129f,$00441220,$00480558,$0001afc1,$0110bfc1,$00504140,$011ebfe0,$00410460,$9fd00142,
  $1f9fc212,$c1189fc1,$97c1189f,$bf7f0211,$00441221,$154c0848,$588ca000,$40014120,$4541400e,$bfd00400,
  $00441221,$41480078,$00458040,$01b7c101,$7f020100,$60010fbf,$56004104,$c1044400,$1fbfc191,$60005041,
  $97c10005,$4412afc1,$d0015800,$000112bf,$bf7f0201,$00504116,$41400560,$40500050,$01412040,$21bfd600,
  $45804312,$abd01200,$50484016,$e0036000,$bfc1129f,$0042121f,$1052004e,$40416040,$e0401050,$1abfd000,
  $58004412,$41046001,$00044100,$0111bfc1,$9fd00050,$18bfc112,$58004412,$c4105001,$bfd001b3,$04600113,
  $00560041,$00410444,$4412afc1,$bfc40800,$00441220,$04600158,$80438042,$38400444,$129fc400,$121fbfc1,
  $004e0054,$60401052,$bfd04041,$0100010e,$16bf7f02,$58004412,$9fc40501,$189fc115,$bf7f0201,$c100050d,
  $441218bf,$d0015800,$000112bf,$1218bfc1,$04480044,$00504140,$20404050,$00580161,$00504140,$4412b1e0,
  $70015800,$50e04141,$60005048,$35bfe003,$78004412,$40414800,$41004580,$48804041,$41004100,$40005400,
  $58004412,$139fd001,$011f9fc1,$16bf7f02,$40005041,$61204005,$d0015801,$bfc1139f,$0050411f,$04a9c410,
  $51400141,$04441040,$23bfd800,$58004412,$41046001,$52004584,$00e04010,$c1139fd0,$54121fbf,$48005600,
  $45804041,$40105200,$441040e0,$b1d00004,$56104412,$b1d01210,$bfd20005,$1240050d,$05500044,$00504140,
  $12abc500,$01511044,$00441050,$48401044,$6001b5d0,$56004104,$40414800,$88005440,$560058c9,$40414110,
  $48005080,$c5804041,$00000207);

const
  uhc_1_data: array[0..301-1] of Cardinal = (
  $9080ac01,$c84038c8,$41048122,$12004e00,$4005b1d0,$129fd041,$06810112,$105c8ca0,$00780044,$3840085c,
  $00504144,$20400540,$8049c561,$16401444,$01410440,$20408440,$16400141,$01410440,$80401440,$9c588c84,
  $b3d04840,$119fd002,$4412a9c1,$40005800,$12bfd041,$45804312,$18bfc100,$49804612,$78015074,$abd01210,
  $d002400e,$41072ebf,$d2004e00,$104051b3,$02afc404,$521abfd1,$80760041,$02b3d000,$0112bfe0,$00441050,
  $c1000448,$441218bf,$41006700,$02afc100,$00410460,$10500052,$00480044,$19bfc400,$01704552,$121bbfc1,
  $01580044,$803c89b0,$504d5da8,$60036000,$01004104,$0a20bfc4,$4c40e049,$03600050,$00410460,$c1010462,
  $541214bf,$10c05600,$bfc193d0,$00504120,$48400160,$15400050,$00484840,$bfd00158,$c1000112,$504118bf,
  $02b1e000,$10600050,$00704840,$d0105066,$541212bf,$87405600,$58dbd88d,$6000504c,$36bfd003,$51584287,
  $78004412,$c1044400,$d01002af,$561216bf,$01045560,$c1109fc1,$400110bf,$60005041,$bfc40001,$00441219,
  $bfd00158,$c1000112,$500111bf,$50004410,$50414005,$40405000,$58016120,$1abfd001,$a8800212,$d012005c,
  $134038a9,$bff80044,$8064123d,$01413043,$c1000e40,$bfc1109f,$b3c41220,$d0005001,$9fc1129f,$7f020118,
  $441232bf,$9fc40200,$18bfc120,$20005041,$1221bfd0,$00460042,$00441050,$04400048,$16400141,$80104840,
  $88a2b888,$0041045c,$9fd2004e,$20bfc50d,$78004412,$abd01300,$50484016,$10036000,$abc595d0,$58004412,
  $9fd01001,$17bfc10f,$50414001,$40056000,$00005041,$4412a9d5,$d0015800,$000112bf,$1218bfc1,$05440044,
  $00441240,$04600158,$c8260041,$44121bbf,$a0015800,$66005d98,$80014134,$008058ca,$bfc195d0,$0054121f,
  $0444c066,$48403840,$d01cafd0,$450a1abf,$01004580,$bfc297c1,$0050411f,$41a9d500,$05400050,$5c89b000,
  $10905600,$0005add0,$411abfd0,$4112bfd0,$c4100050,$014104a9,$239fd100,$0140a892,$5d8d8538,$44844580,
  $04384004,$bfc195d2,$80461223,$02448049,$12400e40,$43500044,$15bfc404,$56004107,$bfc40400,$c100010d,
  $400110bf,$48004412,$c1044000,$c892149f,$18458058,$01b3d000,$18bfc100,$01b3c412,$00441050,$12400544,
  $bfd80044,$00541223,$14448076,$04700e40,$004e0041,$bfc195c2,$00421224,$bfc40071,$9fe00112,$20bfce0d,
  $08004412,$c13c9fc4,$bfc1189f,$04600111,$c1110041,$bfc1579f,$10500111,$bfc80044,$00441224,$8aa00158,
  $844e005c,$0ea9c404,$00441240,$10500158,$10440044,$0a58d880,$10524078,$2040e040,$0e400141,$b5d04140,
  $41417001,$01214160,$5001b1c1,$44004410,$50414002,$40016000,$60005048,$42124005,$bfd91600,$12400112,
  $d0040044,$004412a9,$00600158,$05440044,$00481240,$1221bfd6,$9045c042,$22400142,$00441340,$189fc208,
  $121fbfc1,$00620054,$9fc10444,$14bfc130,$50804612,$b7c10800,$bfc10001,$41400110,$00600050,$1abfd000,
  $48004412,$bfc10004,$c1000110,$0201189f,$012bbf7f,$f0050460,$005041b1,$4412b3d0,$60015800,$5283703c,
  $40e04010,$60114120,$41044905,$00004400,$8038ca88,$4412599f,$70015800,$d8e88241,$410458c8,$48004a00,
  $601571c1,$4e004104,$1193d200,$04600181,$00560041,$80404148,$30520045,$48401640,$08600050,$00441240,
  $12400448,$01580044,$00410460,$10520156,$81091900,$44004410,$30484001,$2458cb80,$5ca8801d,$abd01200,
  $4152400e,$40044100,$12bfd041,$66005412,$a9d01200,$44104058,$00884004,$121abfd0,$30760054,$d58bc400,
  $00000003);

const
  gbkext1_data: array[0..436-1] of Cardinal = (
  $44804e01,$62822440,$44524847,$405c4949,$8a8b7349,$0044405e,$04400046,$b8dda400,$5cec8051,$0a020060,
  $58f98b80,$439074dc,$8a800055,$b8d8803d,$605a8c8b,$04500955,$4a799d80,$61178120,$60826018,$91414455,
  $50095e98,$03044000,$8038c884,$73455c9a,$b7d01405,$01474146,$5015b3fe,$01006420,$5001add4,$71084000,
  $bfd00440,$10413514,$12bfe000,$b3d01001,$00144302,$0042adc1,$c10d9fd0,$cb831a7f,$5071055a,$ac844440,
  $0861335f,$02542744,$4c58bd88,$00452650,$00448540,$58dea425,$59e88887,$84664104,$64005d9e,$44504148,
  $afd10094,$40044094,$f9800044,$d84640b8,$055042b1,$10405054,$a9c193d0,$640640c2,$411852c0,$30004041,
  $e05c9998,$853af993,$51015abc,$544040d3,$40406a14,$82414040,$98903e88,$1c8a813c,$405d820d,$80091951,
  $c8d9d983,$44568a5d,$81091009,$00055402,$143b8cb0,$cd780581,$20c86001,$c9910981,$020b04b9,$80406282,
  $40205a8e,$40184164,$34044013,$415c9984,$00619940,$80100841,$80345c89,$854ab8c8,$6045588d,$afd00018,
  $02006555,$015c88a1,$1359c998,$004a0056,$44400252,$82404848,$b1c10545,$00134403,$1058d885,$00408050,
  $c1020042,$01afc197,$b3c10140,$a1104001,$4500589e,$cd834822,$04110fbf,$04810630,$91005470,$4050388e,
  $9c948024,$82021059,$40805d88,$88840008,$4150965d,$00480040,$094c9244,$40540041,$42414470,$40504141,
  $10410052,$010dbfd0,$04444240,$00040050,$10bf7f03,$40005059,$00084802,$0111bfe0,$018fc101,$0dbf7f02,
  $44456001,$41144001,$44634050,$9c841f60,$981c6058,$050059d8,$8426b3c1,$60115bc8,$8b801018,$5040485c,
  $88040044,$40985d88,$91c10114,$8f948005,$04414059,$00441461,$04440158,$01afc810,$44410041,$5c888000,
  $10bfc404,$b5c20001,$40464001,$41104084,$46044550,$9fc40051,$c291c115,$404517bf,$8277c100,$58d88f5a,
  $44405606,$c85404be,$90208123,$98b03ac8,$4181003c,$21700042,$80005041,$8111398d,$49715021,$04044190,
  $84800c01,$44105c8c,$58004990,$42406000,$8f920810,$0d402058,$04550255,$00500140,$17440044,$10400051,
  $10408840,$01440540,$04408164,$f18de000,$7f021193,$c10049b3,$139fc193,$9f7f0201,$01b3c118,$8993c100,
  $8ca13d8a,$06720059,$005eb8b1,$01480240,$00490348,$10420041,$170e9fe1,$22428105,$0359adb0,$d9801043,
  $08afd038,$95d01340,$8490a9c5,$542458f8,$4b024125,$d0604015,$91820e7f,$5604588c,$b0944628,$4d1458ea,
  $61404101,$80805400,$8ca138c8,$589884b8,$04126112,$81204a51,$823474c4,$4401588f,$50007480,$80484451,
  $98923f8b,$2140815e,$44660550,$02441971,$10420840,$c880a544,$2042185e,$0440c250,$c40a2044,$400111bf,
  $abd01154,$40084101,$12bfd404,$00014011,$404cabc4,$44005000,$d8025004,$b5c1109f,$00104001,$05204954,
  $504a4281,$d8804841,$5c8cb039,$2187c110,$44448109,$8008410d,$ac80bacb,$10502158,$b9bf9134,$4550487b,
  $c880524c,$1140c05a,$810a2010,$60014424,$5e98a804,$4e004040,$62014814,$59c88140,$a4004507,$56215bc9,
  $c8841401,$90401059,$54412041,$045c9881,$60408860,$00490442,$d8951041,$41500059,$50400440,$30400050,
  $00419040,$01404860,$90471044,$00411445,$04408056,$c1189fd5,$044001a9,$4401b5d0,$50085b02,$65205448,
  $15084120,$810dbfc4,$85494160,$10400955,$a058c982,$858bc804,$44805e8d,$42505240,$49025043,$45007150,
  $89880005,$5454045e,$41490c40,$40501150,$00440240,$40440240,$9fc10140,$44a9cd17,$3454d040,$115c8880,
  $80015058,$40855c99,$c9890911,$8c900459,$05693158,$40551164,$6960d940,$00588c92,$88800064,$4145f05e,
  $90400b44,$855ae980,$00410440,$b3020042,$d1f939bf,$e48be0ca,$41ade58f,$10400050,$0054904c,$50405040,
  $00544441,$4109b1d1,$10044406,$4042b5d6,$50105100,$0fbfc450,$41116111,$04c04444,$0458c994,$00421240,
  $44505240,$00410050,$40410554,$4101b5e0,$8bc50000,$5002b5d0,$45015001,$10084004,$4001abc4,$b3d01006,
  $04114001,$5009adc4,$00014000,$4572dfe4,$40018120,$41094040,$01b5d184,$c138e880,$5c888995,$0204601e,
  $4001add0,$4490401c,$599e8540,$48004100,$41044504,$cb900300,$5d9a903c,$4c405270,$81814028,$4030598f,
  $4ac84455,$94144221,$a03240bd,$0608588d,$91388d84,$9c89389c,$44598ddc,$4d404160,$71485040,$a1b98c90,
  $55805cba,$44084844,$48444042,$ad900345,$0144485e,$205c88a0,$4a424050,$94451841,$b4410040,$50784464,
  $00450545,$02400060,$8fc10456,$420ebfd1,$00420052,$11511141,$08462650,$91350444,$a9cb3d88,$40014040,
  $41005104,$50404003,$401155c0,$d4204010,$414141b1,$50542040,$f2010041,$d00101b7,$404111b3,$00004041,
  $c9937f03,$1ebfc293,$00084001,$010f9fc4,$119f7f02,$c10d9fd1,$d0580bb1,$d0508140,$0673c204,$8c8f0581,
  $06b7d438,$075c9881,$b1c41440,$b3f90402,$c40c4001,$b7d501b7,$44035005,$40045408,$50104401,$40024020,
  $50504041,$adc40000,$40006004,$50015010,$95d00000,$c1139fc1,$88a054ab,$2040155d,$55441048,$11480642,
  $0158c888,$c195d118,$bc988a91,$5c888040,$d4056010,$00000001);

const
  jisx0212_data: array[0..947-1] of Cardinal = (
  $d67f02d7,$1ed7c06c,$d900b809,$af02dd02,$da02db00,$84ff5e02,$16038503,$00a1d808,$26d6ec44,$e23f583b,
  $a421221c,$08211600,$880386da,$20204003,$7fe2627f,$62ee41c2,$04767fe4,$5a40801d,$4a5b7b43,$76eea55f,
  $d37f3423,$2376e041,$41d37f43,$c65e56e0,$62011000,$0c627f16,$df4ec27f,$7a8e0b62,$7f14627f,$d600de18,
  $1f754710,$c460c97b,$01a43e64,$8ca5a6b6,$d6d97a1d,$435f832e,$3b2a3f9f,$fe00c353,$bb040243,$ffbb0443,
  $fc50ff03,$827f06fc,$a921be77,$0097a783,$435fa587,$b9800c1d,$8cfe1bf6,$96b78302,$9fc5fefc,$2039f989,
  $d6b780fe,$27fd7896,$6a41ffa0,$08fa9d26,$836ffafc,$a59f946b,$613e69a5,$07f6df43,$6037fd66,$cecab03e,
  $5f206034,$4d4360e3,$5f9a61e3,$5e705fc2,$a2dba2bc,$c1c2e014,$c25f8861,$01d018df,$a80d5be2,$b9800c1f,
  $abfe1bf6,$96b78302,$1fc5fedd,$fe0460a8,$16d6b780,$ff03ff97,$fa9d6772,$6ffafc08,$9ffcfe04,$03780288,
  $0c7ffe04,$824e0278,$800d2e41,$20b8aab3,$4968800b,$04718224,$0604010b,$0601090e,$0d0a0a12,$4482010a,
  $47494e68,$68544140,$03150842,$5581d32f,$68b98d96,$49737149,$58a8806a,$18155312,$8022524c,$4c598885,
  $61c96404,$24c166c1,$956a0481,$3ecb8023,$81254145,$9b821720,$3a8a843d,$8146ca0a,$c98103d1,$bf888138,
  $28800904,$599ca280,$821524f2,$545b6168,$e4004240,$8580071e,$15335c88,$08244060,$70495c82,$4482180c,
  $04050a16,$800b0a02,$75508215,$136a4841,$c2438009,$4c614064,$c9518020,$42604862,$0c21c863,$fc825181,
  $40820900,$4171624e,$80474940,$79105d8f,$5c8c99b5,$48460d0b,$60468221,$5d898261,$3ea9a041,$cd5fc970,
  $714d8220,$685c6660,$5dab9c44,$c469046c,$82128024,$0e054854,$8207110d,$024c486e,$0d50820e,$9517810f,
  $810b00d8,$bd8bbc95,$4241444a,$5e58416a,$020a1202,$015dea83,$2a46420b,$44427082,$42504d58,$0a41504e,
  $82318019,$10404869,$0509010c,$51a5810d,$60eba8c2,$8006244c,$2946c9e6,$04455b81,$62415611,$808120c9,
  $204e611e,$21c84a80,$58e88880,$3eeb9c10,$c0748b83,$a9928025,$5d484038,$24c06441,$5c4a6082,$c059a984,
  $20484c14,$20686882,$81068010,$00505006,$8023c859,$08b88986,$608012f4,$800a224b,$4db8fdac,$61445348,
  $d8034340,$800e012b,$65458202,$52800a2e,$20c96240,$80100a80,$1058d88b,$b03ae9b1,$1c5178fa,$545cdd83,
  $c97e8bad,$e8608228,$86419a03,$eb87591d,$61c84638,$820125c2,$7948414d,$01505249,$9ab4800f,$805dacdf,
  $67389c9b,$a383e544,$0924398e,$03407b82,$0880050b,$80142980,$091cbb84,$0a294c82,$224c6280,$c981aa81,
  $4a4844bc,$0b314c58,$5c638202,$0f305646,$7580e51d,$644a63c3,$bd832049,$4062c97f,$07d9a5e6,$80205151,
  $763c8992,$e34165c0,$416745c7,$4a674861,$11ac8123,$83314065,$bb0c5d98,$0a00b8c8,$0b144882,$bba89180,
  $020f204f,$17fa0b07,$624c5280,$1c586246,$820a0480,$0a424b62,$f108fc0d,$82008015,$80091269,$9c89820c,
  $be8dc05f,$61c94f3c,$24be6243,$0f237082,$4c6e7082,$fa0e0650,$0d09030a,$6782f905,$800a0851,$4f508001,
  $8029c265,$0c498221,$b082010a,$e8923a7d,$80172eb9,$81254543,$b9923032,$43414cb9,$54535a69,$4a415750,
  $82040b02,$1ba44571,$25c6423f,$38c98280,$83214940,$080458d8,$82214a5e,$2448506a,$0b020609,$aca08007,
  $0a2b68b9,$2d78810d,$a13b8ca5,$037b5d8f,$4b448208,$800d1341,$363cc8ba,$b6110081,$988c3c8f,$60d4633f,
  $810622cb,$5c9e8422,$79ac84cc,$78802542,$204b6040,$48407582,$08be49a0,$0c218012,$584b7182,$63820e09,
  $48436940,$82093959,$80101659,$0b20d540,$7c8ba280,$61c06349,$798223cf,$52486868,$5082110a,$588c9247,
  $496c0e34,$2c810620,$3daa990e,$71bdb8b3,$af800e00,$5e40b9ad,$02486964,$4d820110,$58494d59,$0c0f6060,
  $40820780,$08414045,$7082060a,$5e88b979,$1eb9a554,$6440820a,$0b414840,$aa8c800d,$c88e7d5c,$aba2645b,
  $8224427c,$09715d41,$0407010b,$823e800f,$5254527c,$030b005f,$4b4c4582,$85801131,$8f3c58cb,$64085e8a,
  $606d9140,$5c802248,$80091ec4,$9998b890,$c06005be,$4960b568,$4450801c,$80204e5e,$48388e98,$23802443,
  $60485d82,$091e604b,$254b5280,$55668202,$070b110b,$7f8fb180,$698222c8,$800a1561,$41468014,$8da0802a,
  $8003fb78,$48604251,$24518222,$5b0d800a,$020405c2,$4482ff09,$445f4841,$6180090c,$0081214f,$153d888e,
  $9c95800e,$24437339,$242e810a,$8059af8a,$48788c8c,$48688221,$a5801a02,$0923baea,$40810804,$4c3f88b8,
  $60c3624c,$a48021c8,$48543f99,$40624861,$80244265,$80244154,$59820c11,$497b5a54,$c85d8a9a,$091c8a81,
  $0b0e5282,$54802680,$818024c5,$48603bdd,$7ab08220,$b8d88f3b,$0a005c56,$48506082,$5d536845,$73606a42,
  $72615c53,$13476153,$820f8012,$48424441,$14444347,$5173820a,$5ad9aa70,$3ede94f1,$4c39c9b0,$94802543,
  $0f01bc9a,$49618202,$50800a08,$7180204a,$60c16842,$810721cd,$3eb9b501,$4f5d8005,$998e8021,$00a04b7e,
  $012c64fe,$18127982,$f9b48007,$c462cb78,$40548024,$79821220,$595c4b4a,$51414c70,$1b69586b,$0b05041a,
  $58f89b80,$3ca881d2,$ca624070,$8227c163,$9a85766d,$4213435f,$254060db,$4b718202,$05800901,$4442820b,
  $22f10452,$4821c181,$205061c5,$18238105,$44b8cb90,$28604540,$cf518009,$82204961,$44505366,$03090a28,
  $a680050c,$48403b8e,$b0604760,$4e82012a,$0e035746,$61404080,$80052348,$02235268,$7fb98080,$6387e455,
  $20ca60ce,$24464180,$42820380,$3949544c,$4c820711,$0d0c476c,$66820480,$52707240,$82061c08,$800a0071,
  $63bec9ab,$09084743,$251c6081,$69425482,$43645050,$80050d3c,$6a820a28,$48820911,$d8830e2e,$8c9d1e58,
  $424b60bc,$29445063,$c9b6800a,$494540b8,$395d9888,$16409f85,$9f932447,$3a8d9239,$1fa28121,$14810b12,
  $7eaaa014,$20c86048,$80000181,$8dc45aef,$9a833cdc,$800e02b8,$803d988c,$5909588d,$435e0480,$cab88024,
  $b9bc8839,$32406c58,$0901040c,$81822880,$8e035aec,$0874b99d,$87f9820e,$8020ca78,$cf79dab4,$50448222,
  $42674169,$b9416250,$6948589e,$39c88184,$42398cb8,$80f626c1,$c95c8004,$78658221,$040d1140,$88af4682,
  $24000459,$89bf8010,$596e65b9,$bd9a5443,$dd91475b,$e05c88dc,$c8b82c6c,$871a5059,$475abad8,$54545846,
  $05091943,$cb907d82,$6e0ddc58,$4e802049,$038025c2,$0c48820a,$8008800c,$85800a37,$0c19bb89,$05050c04,
  $82fc0904,$42435c40,$40794f40,$0e01434a,$820380f7,$f60d075c,$73820880,$85800a1d,$8abd39c8,$305c99dd,
  $20ca4b27,$084e7182,$8105010d,$38ec8901,$4ebaba9d,$2d5cc982,$73b98ca5,$6141586b,$495d526b,$0a005058,
  $24434480,$b898a880,$4d57524c,$10605851,$0903020a,$c05d8007,$c25a8024,$84800d24,$0901beac,$1f810b0d,
  $24424004,$1eed8180,$a8a7800b,$224c7239,$94604c82,$8c925ec9,$c95a3c88,$40448020,$8123c166,$19025421,
  $61820a04,$484c5944,$0b040c02,$a88201fc,$37605888,$4878ae94,$c9624760,$8224c560,$ac904245,$6110dc58,
  $64c16148,$408221cd,$6072404d,$010b1a5a,$5c8d8480,$ba9f8477,$415b89bd,$bd8cb024,$80091078,$80204852,
  $c8788d80,$81116660,$0e083d32,$444b4782,$13485872,$71448209,$6a417549,$5cada342,$808a9be8,$2017fe9d,
  $bfa8b080,$41584742,$800c1e40,$85800b00,$5864b8c8,$62427e53,$9f810c05,$40bafa87,$85098107,$d9b038e9,
  $75114d59,$718221db,$06070c1b,$1879820e,$820f010d,$38484a4c,$8a14810d,$810b1fcb,$bcbcad70,$5980090c,
  $20486245,$39584582,$01f40f0a,$517a6082,$02040c1a,$02f81007,$59685c82,$5b8e9241,$0c213120,$5a444382,
  $06020a28,$ac808009,$9a5d61b8,$61055eed,$5c8996b1,$9a574084,$22497e89,$4b496c82,$4145464a,$c7490145,
  $20414180,$9b90810a,$4550b8c8,$8219005a,$71494167,$0048504c,$51648009,$a9708220,$da089a88,$25c16945,
  $64822180,$949bb9a3,$0c209a05,$07459181,$38ada43d,$4c7c8035,$08244160,$ba9c8180,$58614855,$820b091a,
  $3b204062,$444882c8,$810c0963,$c07c240d,$09234860,$006a0081,$0a00be90,$860d5081,$484cbcba,$c1810d0a,
  $10baca80,$82022bdf,$6a6c4d44,$41474342,$0d524868,$8015800d,$8125c358,$82002c08,$10455260,$4c820413,
  $5c88a449,$b88d8107,$98800c09,$a1163b9a,$e8830272,$cc882d58,$486c49b8,$51404870,$80050b39,$4060c94b,
  $00810824,$9c816c50,$1a4063ba,$71820109,$9258eb80,$4bb98d82,$42514c4c,$80f90920,$01b889b0,$94800509,
  $599cd9ca,$b2547a02,$1821bffc,$42820180,$1280100f,$8200810a,$23c860af,$24c17080,$45407482,$88ab4841,
  $891ce05f,$4054bada,$4a4a7844,$800c0044,$5068823b,$80040b20,$c7ebc440,$758121cc,$79b8c9ba,$80090141,
  $aab8c995,$8d5958d9,$800c38ac,$10810e1f,$38bca808,$61bfd98d,$54534258,$48417041,$8f800d0d,$2c45bad8,
  $eb01020b,$66820323,$0a084045,$f4050101,$090a0511,$9d8a6181,$989e84b9,$20380298,$7559e883,$24bc5821,
  $bdb89480,$63475441,$15384d41,$98800b01,$073f37eb,$8d864b81,$050929b9,$5b804a04,$59822150,$01091854,
  $a85cd883,$4040cc95,$820b142b,$35cc1c48,$80090201,$0abdc88b,$4240800a,$89800a20,$0a02bb88,$74820180,
  $42705040,$46407841,$41445175,$61605963,$4f504860,$4d820c3a,$13f30168,$68706182,$15589d80,$50b88d83,
  $404f5945,$38306240,$60406280,$6982204e,$4a485c41,$32800b08,$ac8e8006,$614b7d3b,$3d83204c,$5f5068b9,
  $61820f38,$0c235c43,$3c998a80,$10b8c981,$4141800b,$44594e63,$cc448020,$98a08020,$f531ad7d,$20497380,
  $c9838001,$c995075a,$598c9c35,$b8bd8446,$55404b5e,$5d88a66a,$ada01bc5,$a8810d5c,$5280103c,$8680204d,
  $801358db,$422559d8,$d8b60744,$588d9038,$22155046,$2258e982,$e0b8c887,$e4414187,$5d9cb283,$405e784c,
  $50204401,$05414816,$8020c857,$42bbcd93,$48514046,$04800901,$46408210,$5db98150,$1b444614,$25389d80,
  $2506aa81,$af708009,$8102812b,$0155bd88,$1f514e80,$33134481,$38454082,$8204800f,$39d69e40,$ab800916,
  $98863c99,$47fe1198,$6c82012f,$800f005b,$78b9ac90,$484e4a59,$42454044,$80370b40,$6540821c,$18484059,
  $40458011,$0722cc64,$fc804481,$44821b3c,$10334450,$b29a7f08,$4996d85d,$60c564c0,$348023c8,$88b48011,
  $cd60c87c,$685e8220,$5a5f4141,$014a4054,$10800c09,$24c24c80,$14448981,$28504549,$427d398c,$c0698025,
  $4e614c60,$4d82011a,$4262514d,$19f00848,$40725582,$41474142,$11803f0b,$7a2c4b81,$418020d4,$65c26442,
  $81092044,$db8e2083,$8b80c058,$5d4440bc,$3b004848,$0a070202,$db98e081,$05204960,$81091480,$88b333c2,
  $39fc8c3e,$4cb8da81,$03fa0f08,$52484582,$85814d31,$d9a52641,$93330959,$46345da9,$35014800,$69bcdb86,
  $0b104940,$81090103,$801456b0,$0540b99c,$85010381,$4878badb,$4244405a,$71686941,$58a9a960,$c851203f,
  $59c98321,$e8802350,$075d88db,$81252073,$273278db,$514d82fd,$050c6b19,$0ff71202,$404c8006,$d8848028,
  $051c4879,$60486c80,$80ff21ca,$8c3dc88e,$132d58c9,$81244840,$c05f2be5,$83808124,$4259399c,$f825c960,
  $50417482,$815d0250,$b8e98070,$4b5d524e,$d0428000,$0a24c260,$48445482,$68565240,$58998045,$591c7ec1,
  $cb400544,$0a0985e0,$c9900c81,$8020517a,$023e8990,$1b167f02,$00000000);

const
  gb2312_data: array[0..2763-1] of Cardinal = (
  $057f2fff,$30fb09de,$02c702c9,$300300a8,$20153005,$2016ff5e,$c880194f,$c03014d8,$80008119,$d801f18e,
  $efe500b1,$312236d8,$da5f2960,$e3b71f5f,$fb980a29,$92187bc5,$fceb3303,$0e43e0f5,$b901f501,$de7fff17,
  $4026420e,$3200b026,$03203320,$a4ff0421,$e1ffe000,$a72030ff,$06211600,$c3433f26,$9b5fb95f,$f8dfd25f,
  $fb56203b,$7f022007,$36301318,$7f248810,$df7fd913,$0fe01913,$32200236,$60023611,$02161521,$40ff01d8,
  $0482e1a0,$e3575fe0,$1f3041ff,$0e0b7652,$36551f7f,$9f039108,$7607c110,$9f7f0808,$7607c110,$c97f4726,
  $191fea2c,$dbcb0f16,$16191fd2,$0101f80d,$512bb1e0,$86f14b72,$ae270a42,$9a69811c,$a78482de,$925b658f,
  $a01806dc,$dee48201,$31050a36,$1836241f,$4b1f2500,$4a8dde10,$c3963f55,$ce632857,$c0550954,$4c769154,
  $ee853c76,$8d827e77,$98723178,$28978d96,$fa5b896c,$9763094f,$fa5cb866,$ae684880,$ce660280,$5651f976,
  $f171ac65,$b288847f,$ca596550,$ad6fb361,$52634c82,$2753ed62,$6b7b0654,$f475a451,$cb62d45d,$8a97768d,
  $5d801962,$62973857,$7d72387f,$7e67cf76,$70644676,$dc8d254f,$917a1762,$2c73ed65,$2c627364,$7f988182,
  $6e724867,$3462cc62,$4a74e34f,$ca529e53,$2e90a67e,$9c68865e,$d1818069,$c568d27e,$51868c78,$24508d95,
  $de82de8c,$12530580,$84526589,$dd96f985,$7158214f,$b15b9d99,$b462a562,$8d8c7966,$6f72069c,$b2789167,
  $17535160,$cc8f8853,$a18d1d80,$c8500d94,$eb590772,$ab711960,$ef595488,$28672c82,$f75d297b,$f5752d7e,
  $f88e666c,$3b903c8f,$196bd49f,$7c7b1491,$d678a75f,$d5853d84,$dedec36b,$875e0115,$ed75f95e,$0a655d95,
  $9f5fc55f,$c258c18f,$5b907f81,$b997ad96,$2c7f168f,$bf62418d,$5e53d84f,$c08fa853,$4dfbfee0,$6a680790,
  $6881985f,$8b9cd688,$2a522b61,$8c5f6c76,$e86fd265,$485bbe6e,$b0517564,$1967c451,$7c79c94e,$c570b399,
  $bb5e7675,$ad83e073,$b562e864,$5a6ce294,$0f52c353,$9494c264,$1b4f2f7b,$1682365e,$24818a81,$736cca6e,
  $5c63559a,$6554fa53,$0d57e088,$655e034e,$e87c3f6b,$e6601690,$c1731c64,$4d675088,$6c8d2262,$c78e2977,
  $dc5f6991,$10852183,$9553c299,$ed6b8b86,$7f60e860,$3182cd70,$a74ed382,$cd85cf6c,$fd7cd964,$4966f969,
  $56539583,$8c4fa77b,$426d4b51,$d28e6d5c,$2c53c963,$e5833683,$3d78b467,$945bdf64,$e75dee5c,$f462c68b,
  $008c7a67,$4963ba64,$17998b87,$f27f208c,$104ea794,$0c98a496,$3a731666,$385c1d57,$7f957f5e,$8280a050,
  $45655e53,$21553175,$848d8550,$1d949e62,$6e563267,$355de26f,$66709254,$a4626f8f,$7b63a364,$f46f885f,
  $b081e390,$685c188f,$895ff166,$8196486c,$91886c8d,$ce79f064,$106a5957,$58544862,$e97a0b4e,$da6f8460,
  $1e627f8b,$e49a8b90,$f4540379,$19630175,$df6c6053,$705f1b8f,$7f803b9a,$3a4f889f,$c58d645c,$bd65a57f,
  $b2514570,$07866b51,$bd5ba05d,$74916c62,$208e0c75,$7961017a,$f84ec77b,$1177857e,$1d81ed4e,$7151fa52,
  $8753a86a,$cf95048e,$646ec196,$40695a96,$d750a878,$e6641077,$e3590489,$7f5ddd63,$20693d7a,$9882394f,
  $ae4e3255,$627a9775,$ef5e8a5e,$39521b95,$76708a54,$82952463,$3f662557,$07918769,$af6df355,$3388227e,
  $b57ef062,$c1832875,$9e96cc78,$f761488f,$648bcd74,$50523a6b,$6a6b218d,$f1847180,$ce530656,$d14e1b4e,
  $8b7c9751,$c37c0791,$e18e7f4f,$677a9c7b,$ac5d1464,$01810650,$ec7cb976,$517fe06d,$f85b5867,$ae78cb5b,
  $165d6564,$19fefed8,$be642d95,$297b548f,$27625376,$79544659,$3450a36b,$865e2662,$374ee36b,$85888b8d,
  $20902e5f,$c5803d60,$554e3962,$b890f853,$e680c663,$466c2e65,$e160ee4f,$398bde6d,$5386cb5f,$5a63215f,
  $63836151,$63520068,$128e4863,$775c9b50,$305bfc79,$bc7a3b52,$d7905360,$975fb776,$6c76845f,$7b706f8e,
  $aa7b4976,$9351f377,$4e582490,$ea6ef44f,$1b654c8f,$a472c47b,$e17fdf6d,$9562b55a,$8257305e,$1d7b2c84,
  $125f1f5e,$a07f1490,$c7638298,$b978986e,$5b517870,$3557ab97,$384f4375,$e65e9775,$c0596060,$896bbf6d,
  $d553fc78,$0151cb96,$0a638952,$03949354,$398dcc8c,$76789f72,$0d8fed87,$0153e08c,$ee76ef4e,$76948953,
  $2d9f0e98,$a25b9a95,$1c4e228b,$6351ac4e,$a861c284,$97680b52,$bb606b4f,$5c6d1e51,$97629651,$46966165,
  $d890178c,$6390fd75,$8a6bd277,$fb72ec72,$7958358b,$5c8d4c77,$9a954067,$215ea680,$ef59926e,$3b77ed7a,
  $ad6bb595,$067f0e65,$1f515158,$a95bf996,$72542858,$7f65668e,$9d56e498,$4176fe94,$c6638790,$3a591a54,
  $b2579b59,$fa67358e,$4182358d,$1560f052,$e886fe58,$c49e455c,$b9989d4f,$765a258b,$7c538460,$02904f62,
  $69997f91,$3f800c60,$14803351,$3199755c,$304e8c6d,$5a53d18d,$107b4f7f,$004e4f4f,$d06cd596,$0685e973,
  $fb756a5e,$fe6a0a7f,$41949277,$e651e17e,$d453cd70,$2983038f,$6d72af8d,$4a6cdb99,$b982b357,$3f80aa65,
  $a8963262,$bf4eff59,$3e7eba8b,$5e83f265,$de556197,$2a80a598,$208bfd53,$9f80ba54,$396cb85e,$5a82ac8d,
  $1b542991,$b752066c,$1a575f7e,$896c7e71,$fd594b7c,$245fff4e,$307caa61,$ab5c014e,$f0870267,$ce950b5c,
  $fd75af98,$af902270,$bd7f1d51,$e459498b,$264f5b51,$77592b54,$7580a465,$c262765b,$458f9062,$266c1f5e,
  $d84f0f7b,$6e670d4f,$8f6daa6d,$1788b179,$9a752b5f,$ef8f8562,$a791dc4f,$51812f65,$505e9c81,$6f8d7481,
  $4b898652,$85590d8d,$1c4ed850,$79723696,$cc8d1f81,$448ba35b,$1a598796,$7654907f,$e5560e56,$8265398b,
  $d6949969,$726e8976,$4675185e,$ff67d167,$76809d7a,$c6611f8d,$63656279,$1a51888d,$3894a252,$b2809b7f,
  $2f5c977e,$d967606e,$d8768b7b,$94818f9a,$1e7cd57f,$3f955064,$e5544a7a,$016b4c54,$3d620864,$9980f39e,
  $69527275,$3c845b97,$0186e468,$ec969496,$044e2a94,$397ed954,$158ddf68,$9a66f480,$c27fb95e,$97803f57,
  $3b5de568,$6d529f65,$9b9f9a60,$6c8eac4f,$135bab51,$5e5de95f,$2162f16c,$a951718d,$9f52fe94,$d782df6c,
  $8457a272,$1f8d2d67,$c78f9c59,$8d549583,$bd4f307b,$d15b646c,$e49f1359,$a886ca53,$a18c379a,$7e654580,
  $c756fa98,$dc522e96,$e1525074,$0263025b,$d04e5689,$fa602a62,$98517368,$c251a05b,$867ba189,$ef7f5099,
  $2f704c60,$7f51498d,$70901b5e,$2d89c474,$52784557,$fa9f9f5f,$3c8f6895,$788be19b,$dc684276,$358dea67,
  $8a523d8d,$cd6eda8f,$ed950568,$9c56fd90,$c788f967,$b854c88f,$775b699a,$a56c266d,$875bb34e,$a891639a,
  $e990af61,$b5542b97,$fd5bd26d,$55558a51,$bc7ff07f,$f1634d64,$8d61be65,$57710a60,$2f6c496c,$2a676d59,
  $8e58d582,$eb8c6a56,$7d90dd6b,$f7801759,$756d6953,$77559d54,$3883cf83,$8c79be68,$084f5554,$8976d254,
  $b396028c,$6b6db86c,$6489108d,$3f8d3a9e,$d59ed156,$e05f8875,$fc606872,$2a4ea854,$5288616a,$c48f7060,
  $7970d854,$2a9e3f86,$185b8f6d,$897ea25f,$344faf55,$9a543c73,$0e501953,$4e547c54,$5a5ffd4e,$6b58f674,
  $7480e184,$ca72d087,$276e567c,$2c864e5f,$9262a455,$376caa4e,$d782b162,$3e534e54,$3b6ed173,$16521275,
  $d08bdd53,$005f8a69,$4f6dee60,$af6b2257,$d8685373,$627f138f,$2460a363,$6275ea55,$a371158c,$7b5ba66d,
  $4c83525e,$fa9ec461,$27875778,$f076877c,$4c60f651,$4c664371,$0e604d5e,$2570708c,$bd8f8963,$d460625f,
  $c156de86,$6760946b,$e0534961,$3f666660,$1a79fd8d,$4770e94f,$f28bb36c,$647ed88b,$5a660f83,$519b425a,
  $416df76d,$196d3b8c,$b7706b4f,$d1621683,$27970d60,$fb79788d,$fa573e51,$78673a57,$ef7a3d75,$8c7b9579,
  $f9996580,$a56fc08f,$ec9e218b,$097ee959,$8154097f,$9168d867,$c67c4d8f,$2553ca96,$7275be60,$c953736c,
  $247ea75a,$0a51e063,$df5df181,$80628084,$0e5b6351,$42796d4f,$4e60b852,$c25bc46d,$b08ba15b,$cc65e28b,
  $9396455f,$aa7ee759,$b756097e,$73593967,$a05bb64f,$8a835a52,$328d3e98,$4794be75,$f77a3c50,$7e67b64e,
  $7c5ac19a,$5a76d16b,$3a5c1657,$4e95f47b,$a9517c71,$78827080,$277f0459,$ec68c083,$7778b167,$6162e378,
  $ed7b8063,$cf526a4f,$db835051,$f5927469,$c18d318d,$ad952e89,$654ef67b,$51823050,$10996f52,$a76e856e,
  $f55efa6d,$0659dc50,$5f6d465c,$8b75866c,$56686884,$208bb259,$4d917153,$12854996,$26790169,$a480f671,
  $4790ca4e,$079a846d,$0556bc5a,$eb94f064,$1a4fa577,$d272e181,$34997a89,$7f7ede7f,$75655952,$838f7f91,
  $9653eb8f,$a563ed7a,$f8768663,$36885779,$ab622a96,$54828252,$77677068,$ed776b63,$d36d017a,$d089e37e,
  $c9621259,$4c82a585,$cb501f75,$eb75a54e,$fe5c4a8b,$a47b4b5d,$ca91d165,$5f6d254e,$267d2789,$284ec595,
  $738fdb8c,$81664b97,$ec8fd179,$3d6d7870,$4652b25c,$0e516283,$76775b83,$ac9cb866,$be60ca4e,$cf7cb37c,
  $664e957e,$88666f8b,$83975998,$5c656c58,$c95f8495,$df975675,$c07ade7a,$9870af51,$7663ea7a,$967ea07a,
  $4597ed73,$5d70784e,$a991524e,$e7655153,$0581fc65,$31548e82,$a0759a5c,$d962d897,$4575bd72,$ca9a795c,
  $805c4083,$3e77e954,$5a6cae4e,$6e62d280,$775de863,$1e8ddd51,$f1952f8e,$e753e54f,$6770ac60,$43635052,
  $265a1f9e,$77773750,$857ee253,$89652b64,$14639862,$c9723550,$c051b389,$477edd8b,$a783cc57,$1b519b94,
  $ca5cfb54,$5a7ae34f,$8f90e16d,$1655809a,$fef4d32d,$e95f00af,$ef697763,$0a616851,$d8582a52,$0d574e52,
  $b7770b78,$e061775e,$97625b7c,$954ea262,$f7800370,$6070e462,$db577797,$f567ef82,$9778d568,$f379d198,
  $ef54b358,$4b6e3453,$a2523b51,$af8bfe5b,$a6554380,$51607357,$7a542d57,$5460507a,$a063a75b,$6353e362,
  $af5bc762,$9f54ed67,$7782e67a,$e45e9391,$ae593888,$e8630e57,$5780ef8d,$a97b7757,$bd5feb4f,$216b3e5b,
  $c27b5053,$ff684672,$f7773677,$8f51b565,$bf76d44e,$757aa55c,$41594e84,$8850809b,$83612799,$0657646e,
  $f0634666,$6962ec56,$145ed362,$c9578396,$21558762,$a3814a87,$b155668f,$56676583,$6a84dd8d,$e6680f5a,
  $117bee62,$9c517096,$fd8c306f,$d289c863,$c27f0661,$056ee570,$fc699474,$ce5eca72,$6a671790,$b3635e6d,
  $01726252,$e54f6c80,$d9916a59,$d26d9d70,$f74e5052,$7e956d96,$2f78ca85,$9251217d,$8b64c257,$ea7c7b80,
  $5e68f16c,$9851b769,$8168a853,$f19ece72,$bb72f87b,$066f1379,$cc674e74,$3c9ca491,$54838979,$17540f83,
  $894e3d68,$3e52b153,$a3538678,$4510317c,$e2fcfe7f,$927acb75,$b66ca57c,$83529b96,$e954e974,$b280544f,
  $708fde83,$1c5ec995,$186d9f60,$38655b5e,$4b94fe81,$c370bc60,$c97cae7e,$b1688151,$24826f7c,$cf8f864e,
  $ae667e91,$a98c054e,$da804a64,$ce759750,$bd5be571,$866f668f,$6364824e,$995ed695,$c2521765,$a370c888,
  $33730e52,$f7679774,$34971678,$de90bb4e,$db6dcb9c,$1d8d4151,$b262ce54,$f683f173,$c39f8496,$9a4f3694,
  $7551cc7f,$ad967570,$e698865c,$9c4ee453,$b474096e,$8f786b69,$18755999,$41762452,$6d67f36d,$4b9f9951,
  $3c549980,$867abf7b,$e2578496,$7c964762,$025a0469,$0f7bd364,$a6964b6f,$85536282,$895e9098,$6463b370,
  $81864f53,$8c9e939c,$ef973278,$7f8d428d,$846f5e9e,$465f5579,$74622e96,$dd54159a,$c54fa394,$615c6565,
  $517f155c,$8b6c2f86,$e473875f,$e67eff6e,$6a631b5c,$756ee65b,$a04e7153,$a1756563,$268f6e62,$a64ed14f,
  $ba7eb66c,$ba841d8b,$3b7f5787,$a9952390,$f89aa17b,$1b843d88,$dc9a866d,$bb59887e,$01739b9e,$6c868278,
  $1b9a829a,$cb541756,$a64e7057,$c853569e,$9281098f,$ee999277,$136ee186,$6266fc85,$296f2b61,$2b82928c,
  $1376f283,$bd5fd96c,$05732b83,$db951a83,$c677db6b,$02536f94,$3d519283,$388c8c5e,$ab4e488d,$85679a73,
  $09917668,$a1716497,$9277096c,$cf95415a,$277f8e6b,$b95bd066,$e85a9a59,$ec95f795,$99840c4e,$df6aac84,
  $1b953076,$5f68a673,$9a772f5b,$dc976191,$1c8ff77c,$735f258c,$c579d87c,$1c6ccc89,$425bc687,$2068c95e,
  $957ef577,$c9514d51,$055a2952,$d797627f,$8463cf82,$d285d077,$996e3a79,$1159995e,$11706d85,$bf62bf6c,
  $af654f76,$0e95fd60,$23879f66,$0d94ed9e,$2c547d54,$7964788c,$21861164,$e8819c6a,$54646978,$2b62b99b,
  $a883ab67,$ab9ed858,$de6f206c,$0b964c5b,$d0725f8c,$6162c767,$c64ea972,$936bcd59,$5566ae58,$5552df5e,
  $ee672861,$67776676,$ff7a4672,$5054ea62,$a394a054,$b35a1c90,$436c167e,$1059764e,$57594880,$be753753,
  $2056ca96,$7c811163,$d695f960,$8154626d,$e9518599,$ae80fd5a,$2a971359,$3c6ce550,$6062df5c,$7b533f4f,
  $ba900681,$c8852b6e,$be5e7462,$7b64b578,$185ff563,$1f917f5a,$4f5c3f9e,$7d804263,$4a556e5b,$85954d95,
  $e060a86d,$dd72de67,$e75b8151,$5b6cde62,$ae626d72,$137ebd94,$9c6d5381,$745f0451,$1252aa59,$96597360,
  $9f865066,$e6632a75,$fa7cef61,$2754e68b,$b49e256b,$5585d56b,$a4507654,$b4556a6c,$15722c8d,$3660155e,
  $9262cd74,$98724c63,$3e6e435f,$5865006d,$f776d86f,$fec580b3,$db52245d,$9e4e5353,$2a65c15e,$9b80d680,
  $28548662,$8d70ae52,$e18dd188,$da54786c,$f457f980,$6a8d5488,$69914d96,$b76c9b4f,$3076c655,$f962a878,
  $6d6f8e70,$da84ec5f,$f7787c68,$0b81a87b,$679e4f67,$6f78b063,$39781257,$ab627997,$35528862,$646bd774,
  $b2813e55,$3976ae75,$fb75de53,$6c5c4150,$4f7bc78b,$97724750,$0298d89a,$6874e26f,$a5648779,$9162fc77,
  $c18d2b98,$52805854,$f9576a4e,$73840d82,$f651ed5e,$4f8bc474,$fc57615c,$4698876c,$4478345a,$958feb9b,
  $5152567c,$c694fa62,$da83864e,$7eec8622,$3457d4ff,$6e570367,$316d6666,$1166dd8c,$3a671f70,$1a68166b,
  $0359bb62,$0651c44e,$8f67d26f,$cb51766c,$67594768,$0e75666b,$5081105d,$4865d79f,$91794179,$828d779a,
  $014e5e5c,$51542f4f,$68780c59,$c46c1456,$7d5f038f,$ab6ce36c,$7063908b,$756d3d60,$8e626672,$4394c594,
  $7e8fc153,$264edf7b,$d44e7e8c,$b394b19e,$5c524d94,$4590636f,$118c346d,$205d4c58,$aa6b496b,$54545b67,
  $997f8c81,$3a853758,$4762a25f,$7295396a,$65608465,$5477a768,$e74fa84e,$ac97985d,$ed7fd864,$8d4fcf5c,
  $0452077a,$2f4e1483,$a67a8360,$b24fb594,$3479e64e,$b952e474,$bd64d282,$815bdd79,$7b97526c,$3e6c228f,
  $05537f50,$7464ce6e,$c56c3066,$f7987760,$3c5e868b,$cb7a7774,$b14e1879,$42740390,$4b56da6c,$8b6cc591,
  $c6533a8d,$af66f286,$715c488e,$d66e209a,$8b5a3653,$bb8da39f,$a7570853,$9b674398,$686cc991,$f375ca51,
  $3872ac62,$3a529d52,$3870947f,$4a537476,$6e69b79e,$d996c078,$367fa488,$8971c371,$e467d351,$1858e474,
  $a956b765,$7099768b,$f97ed562,$ec70ed60,$ba4ec158,$e75fcd4e,$a44efb97,$8a52038b,$547eab59,$e54ecd62,
  $38620e65,$6384c983,$94878d83,$b96eb671,$977ed25b,$d463c951,$39808967,$12881583,$825b7a51,$738fb159,
  $656c5d4e,$6f892551,$4a962e8f,$10745e85,$a695f095,$3182e56d,$1264925f,$6e84286d,$5e9cc381,$098d5b58,
  $1e53c14e,$5165634f,$2755d368,$9a64144e,$c2626b9a,$72745f5a,$ee6da982,$8e50e768,$40780283,$99523967,
  $bb7eb16c,$5e556550,$527b5b71,$eb73ca66,$71674982,$7d52205c,$ea886b71,$c5965595,$b38d6164,$55558481,
  $2e62476c,$2458927f,$4f55464f,$0a664c8d,$f35c1a4e,$4e68a288,$e77a0d63,$fa828d70,$1197f652,$b554e85c,
  $627ecd90,$c78d4a59,$0d820c86,$448d6682,$515c0464,$3e6d8961,$378bbe79,$7b753378,$ab4f3854,$206df18e,
  $5e7ec55a,$a16c8879,$1a5a765b,$4e80be75,$f06e1761,$25751f58,$47727275,$017ef353,$6976db77,$2380dc52,
  $315e0857,$bd72ee59,$d76e7f65,$715c388b,$f3534186,$f662fe77,$df4ec065,$9e868098,$f28bc65b,$7f77e253,
  $765c4e4f,$0f59cb9a,$eb793a5f,$ff4e1658,$ed4e8b67,$1d8a9362,$2f52bf90,$6c55dc66,$d5900256,$ca4f8d4e,
  $0f997091,$435e026c,$c65ba460,$368bd589,$96624b65,$ff5b8899,$2e63885b,$2653d755,$2c517d76,$b367a285,
  $926b8a68,$d48f9362,$d1821253,$66758f6d,$708d4e4e,$af719f5b,$d9669185,$007f7266,$209ecd87,$2f5c5e9f,
  $118ff067,$0d675f68,$857ad662,$705eb658,$556f3165,$0d523760,$70645480,$05752988,$f468135e,$cc971c62,
  $01723d53,$616c348c,$2e7a0e77,$7a77ac54,$f4821c98,$1478558b,$af70c167,$36649565,$c1601d56,$1d53f879,
  $866b7b4e,$e35bfa80,$3a56db55,$724f3c4f,$7e5df399,$02803867,$01988260,$bc5b8b90,$1c8bf58b,$de825864,
  $cf55fd64,$d7916582,$1f7d204f,$f37c9f90,$af585150,$c95bbf6e,$7880838b,$97849c91,$8b867d7b,$e5968f96,
  $8e9ad37e,$575c8178,$a790427a,$59795f96,$0b635f5b,$ad84d17b,$29550668,$2274107f,$4095017d,$d6584c62,
  $795b834e,$6d585459,$4b631e73,$ce8e0f8e,$ac82d480,$f053f062,$2a915e6c,$70600159,$4a574d6c,$2b8d2a64,
  $5b6ee976,$f06a8057,$2d6f6d75,$668c088c,$926bef57,$a278b388,$ad53f963,$586c6470,$02642a58,$9b68e058,
  $d6551081,$ba50187c,$9f6dcc8e,$8f70eb8d,$d46d9b63,$047ee66e,$03684384,$766dd890,$578ba896,$e4727959,
  $bc817e85,$af8a8a75,$22525468,$d095118e,$44989863,$53557c8e,$8f66ff4f,$9560d556,$4952436d,$fb59295c,
  $30586b6d,$6c751c75,$46821460,$61631181,$3a8fe267,$348df377,$1694c18d,$2c53855e,$4070c354,$5c5ef76c,
  $ad4ead50,$47633a5e,$50901a82,$b3916e68,$dc540c77,$e55f6494,$4568767a,$df7b5263,$7775db7e,$34629550,
  $f8900f59,$8179c351,$9256fe7a,$8290145f,$1f5c606d,$54541057,$e26e4d51,$9363a856,$15817f98,$00892a87,
  $6f541e90,$d681c05c,$31625862,$409e3581,$7c9a6e96,$a5692d9a,$3e62d359,$c7631655,$3c86d954,$e65a036d,
  $6a889c74,$4c59166b,$7e5f2f8c,$7d73a96e,$f74e3898,$975b8c70,$5a633d78,$cb769666,$495b9b60,$554e075a,
  $8b6c6a81,$894ea173,$807f5167,$1b65fa5f,$845fd867,$cd5a0159,$715fae5d,$dd97e653,$f468458f,$df552f56,
  $4d4e3a60,$c77ef46f,$d4840e82,$2a4f1f59,$ac5c3e4f,$1a672a7e,$4f547385,$8280c375,$4d9b4f55,$136e2d4f,
  $705c098c,$1f536b61,$8a6e2976,$fb658786,$3b7eb995,$0a7a3354,$e195ee7d,$ee7fc155,$17631d74,$9d6da187,
  $a162117a,$e1536765,$eb6c8363,$a8545c5d,$614e4c94,$4b8bec6c,$9c65e05c,$3e68a782,$cb543454,$946b666b,
  $4863424e,$0d821e53,$5e4fae4f,$fe620a57,$69666496,$a152ff72,$ef609f52,$9966148b,$7f679071,$fd785289,
  $3b667077,$21543856,$00727a95,$0c606f7a,$9d60895e,$dc591581,$ef718460,$506eaa70,$8472806c,$2d88ad6a,
  $b34e605e,$e3559c5a,$fb6d1794,$0f96997c,$8e7ec662,$23867e77,$96971e53,$e166878f,$ed4fa05c,$a64e0b72,
  $13590f53,$28638054,$d9514895,$a49c9c4e,$2454b87e,$3788548d,$8e95f282,$cc5f266d,$69663e5a,$2e73b096,
  $7a53bf73,$a1998581,$775baa7f,$bf965096,$a276f87e,$99957653,$447bb199,$616e5889,$657fd44e,$f38be679,
  $ab54cd60,$f798794e,$cf6a615d,$61541150,$5d84278c,$4a970478,$a354ee52,$88950056,$c65bb56d,$0f66536d,
  $215b5d5c,$78809668,$487b1155,$9b695465,$4e6b474e,$4f978b87,$3a631f53,$9c90aa64,$1080c165,$b051998c,
  $f9537868,$c461c887,$226cfb6c,$aa5c518c,$0c82af85,$9b6b2395,$fb65b08f,$e15fc35f,$1f88454f,$29816566,
  $7460fa73,$8b521151,$a25f6257,$92884c90,$4f5e7891,$d3602767,$f6514459,$0880f851,$c46c7953,$11718a96,
  $9e4fee4f,$c5673d7f,$c0950855,$e3889679,$0c589f7e,$5a970062,$7b561886,$b85f9098,$5784c48b,$ed53d991,
  $5c5e8f65,$6e606475,$ea5a7f7d,$697eed7e,$a355a78f,$cb60ac5b,$09738465,$29766390,$747eda77,$66859b97,
  $ea7a745b,$cb884096,$aa718f52,$e265ec5f,$6f5bfb8b,$895de19a,$ad6c5b6b,$0a8baf8b,$8b8fc590,$2662bc53,
  $409e2d9e,$bd4e2b54,$9c725982,$595d1686,$c56daf88,$9a54d196,$098bb64e,$0954bd71,$f970df96,$2576d06d,
  $1278144e,$f65ca987,$9c8a005e,$8e960e98,$446cbf70,$3c63a959,$14884d77,$3082736f,$8c71d558,$c1781a53,
  $66550196,$b471305f,$8c8c1a5b,$2e6b839a,$e79e2f59,$6c676879,$a14f6f62,$0b7f8a75,$2796336d,$d24ef06c,
  $37517b75,$806f3e68,$96817090,$47747659,$655c2764,$237a9190,$ac59da8c,$6f820054,$00898183,$4e693080,
  $37803656,$b691ce72,$754e5f51,$1a639698,$f353f64e,$1c814b66,$006db259,$3b58f94e,$f163d653,$0a4f9d94,
  $9088634f,$57593798,$ea79fb90,$9180f04e,$9c6c8275,$5d59e85b,$8169055f,$f2501a86,$e34e595d,$7a4ee577,
  $13629182,$79909166,$794ebf5c,$3881c65f,$ab808490,$d44ea675,$c5610f88,$495fc66b,$a276ca4e,$cb8be36e,
  $fe7fc75c,$fc5f021b,$ce7fcc7f,$6b83357e,$b756e083,$3497f36b,$1f59fb96,$eb94f654,$6e5bc56d,$155c3999,
  $7096905f,$3182f153,$705a746a,$285e949e,$6a83b97f,$1ed42802,$ce8747fd,$c88d628f,$965f7176,$20786c98,
  $e554df66,$c34f6362,$b875c881,$0a96cd5e,$8f86f98e,$8c6cf354,$7f6c386d,$2852c760,$185e7d75,$e760a04f,
  $315c245f,$c090ae75,$b972b994,$496e386c,$cb670991,$5153f353,$f191c94f,$7c53c88b,$e48fc25e,$c24e8e6d,
  $5e698676,$06611a86,$de4f5982,$7c903e4f,$1d61099c,$856e146e,$314e8896,$0e96e85a,$b95c7f4e,$ed5b8779,
  $897fbd8b,$8b57df73,$0190c182,$bb904754,$a15cea55,$3261085f,$b272f16b,$748a8980,$d55bd36d,$6b988488,
  $339a6d8c,$a46e0a9e,$a3514351,$9f888157,$9563f453,$5856ed8f,$3f570654,$186e9073,$d18fdc7f,$28613f82,
  $f0966260,$8a7ea666,$a58dc38d,$a45cb394,$a667087c,$18960560,$e74e9180,$68530090,$d0514196,$5d85748f,
  $f5665591,$1d5b5597,$42783853,$c9683d67,$b0707e54,$8d8f7d5b,$b1572851,$82651254,$438d5e66,$6c810f8d,
  $df906d84,$fb51ff7c,$e967a385,$a46fa165,$6a8e8186,$82902056,$e5707676,$e98d2371,$fd521962,$0e8d3c6c,
  $8e589e60,$6066fe61,$b3624e8d,$2d6e2355,$e18f6767,$2895f894,$a8680577,$4d548b69,$c870b84e,$8b64588b,
  $845b8565,$e8503a7a,$e177bb5b,$988a796b,$cf6cbe7c,$9765a976,$555d2d8f,$0886385c,$18536068,$5b7ad962,
  $1f7efd6e,$707ae06a,$206f335f,$a8638c5f,$0867566d,$265e104e,$c04ed78d,$9c763480,$2d62db96,$bc627e66,
  $678d756c,$467f6971,$ec808751,$98906e53,$f054f262,$058f9986,$17951780,$598fd985,$9f73cd6d,$04771f65,
  $fb782775,$888d1e81,$954fa694,$ca75b967,$2f97078b,$35954763,$2384b896,$81774163,$8972f05f,$7460144e,
  $6362ef65,$27653f6b,$d175c75e,$9d8bc190,$2f679d82,$18543165,$a277e587,$41810280,$c74e4b6c,$f4804c7e,
  $96690d76,$3c62676b,$404f8450,$62630757,$ea8dbe6b,$b865e853,$1a5fd77e,$f363b763,$6e81f481,$d95e1c7f,
  $7a52365c,$1a79e966,$998d287a,$de75d470,$926cbb6e,$c54e2d7a,$9f5fe076,$c8887794,$bf79cd7e,$f291cd80,
  $1f4f174e,$de546882,$cc6d325d,$747ca58b,$1a80988f,$b154925e,$3c5b9976,$e09aa466,$db682a73,$2a673186,
  $db8bf873,$f990108b,$6e70db7a,$a962c471,$3b563177,$f184574e,$c052a967,$f88d2e86,$4f7b5194,$5d6ce84f,
  $939a7b79,$fd722a62,$164e1362,$b08f6c78,$c68d5a64,$8468697b,$8688c55e,$ee649e59,$0e72b658,$fd952569,
  $608d588f,$067f0057,$4951c68c,$5362d963,$22684c53,$4c830174,$40554491,$4a707c77,$a851796d,$ff8d4454,
  $c46ecb59,$2b5b5c6d,$7d4ed47d,$506ed37c,$0d81ea5b,$035b576e,$2a68d59b,$fc5b978e,$b5603b7e,$7090b97e,
  $cd594f8d,$b379df63,$cf53528d,$c5795665,$c4963b8b,$8294bb7e,$8956347e,$6a670091,$755c0a7f,$e6662890,
  $de4f505d,$5c505a67,$a757504f,$de05165e,$0c4e8d1f,$1051404e,$455eff4e,$984e1553,$324e1e4e,$695b6c9b,
  $ba4e2856,$154e3f79,$2d4e4753,$6e723b59,$df6c1053,$9780e456,$7e6bd399,$369f1777,$104e9f4e,$cc4e5c9f,
  $8806def4,$6c5b5b82,$c4560f55,$cf538d4e,$fce44162,$8d5d9765,$c6da531a,$7f102074,$668d5cfa,$527dfd53,
  $c56f4560,$5165c065,$da7ffb21,$527d84af,$e14e5fc4,$545182dc,$c74ebb7f,$b972b962,$187e3364,$30914237,
  $3322e202,$38da7f09,$c24f5a65,$4a4db860,$386e3e7c,$3d57cb5d,$e8379277,$db020252,$f5f90915,$2331190e,
  $1fe339a7,$f01ed1ff,$c5560319,$1e06f312,$02022a0f,$e7301c11,$1908faff,$22de7f04,$6c3d4edd,$4f654f58,
  $9fa04fce,$7c746c46,$5dfd516e,$99989ec9,$59145181,$530d52f9,$53108a07,$591951eb,$4ea05155,$4eb35156,
  $88a4886e,$81144eb5,$798088d2,$88035b34,$51ab7fb8,$653f65c5,$7f03258f,$458ba0d8,$c064c260,$b8820b20,
  $28505b7b,$aa59c8bc,$465ca992,$013c59a0,$c4222781,$7a5369dc,$c4961d53,$d25ccf5f,$4a63455f,$0d678225,
  $190a0514,$9097d87f,$693c60c3,$613f6935,$6f385f43,$5a515cb6,$5e5265c2,$67c35dba,$6ec56743,$5f4d623c,
  $7f0324c9,$42520ddc,$4952a259,$da7f1120,$52d054ff,$0cfeecc5,$71ee53df,$5ef477cd,$51fc51f5,$53b69b2f,
  $755a5f01,$574c5def,$6dc7e25c,$620ba47d,$643e6021,$76405ac5,$6de6631f,$5fb66d26,$5ec8622d,$72a85bf9,
  $4fcc4c5c,$60c27a4c,$7da65cbf,$5cac643b,$583060ed,$353b6ed2,$150745dc,$7fe61108,$99a804de,$61ff9f19,
  $60c38279,$4e5d5dcf,$60c56149,$59456651,$b51920d7,$011df71f,$ed0be8f5,$0a25f509,$ee283dd6,$d5f82bed,
  $3406de18,$093ed8ef,$cb010eec,$f47d47f5,$96b200a4,$fdf8aa28,$20d1c36a,$e11cfcf8,$0dcd49d7,$03ff33f9,
  $fe034eb3,$c8420103,$0aec013b,$f7e909e9,$3bd4f33a,$0a061dc3,$40050212,$da7ff3e4,$84185807,$0cdf4933,
  $f5d91c46,$f4300bce,$dbf101f5,$f1ca66fb,$ff09f57b,$f201141a,$0ac4ef0f,$02160d23,$0c543ca3,$16d71603,
  $26fbf5f7,$e3fb18c1,$7f29fe4e,$38750d7a,$e649b885,$c4e51c1b,$20ef5dfd,$7f1cfafc,$4377a2da,$e8646e85,
  $2a639f61,$7354ae7a,$2e71395f,$9e73e26d,$def2ad71,$085efe06,$41593c5f,$55803759,$dadf4459,$5c22530f,
  $7f082342,$5d624cd8,$cf675b7a,$d439d65e,$9c517d43,$57b92269,$b92629c8,$45dfde3f,$457acd7d,$5942de54,
  $85d28398,$a7f2869f,$ac624f5c,$e57e3b6c,$7c526854,$c5702160,$3e664667,$fee45b73,$d25f0b05,$1175195f,
  $91535f5f,$3f5ec82e,$f021d669,$50800745,$60f54f2d,$1250270a,$36f3fae3,$f0f2e901,$15dd3337,$ffd51ef2,
  $319e012d,$0d04e632,$cd02010d,$f239fa01,$39cc3d0f,$2fdf17dd,$1602ec01,$26283d03,$14d42494,$fbec11ea,
  $01011f1f,$2f2cfdbc,$082eb147,$df1ef9cf,$64eabb58,$05d601de,$56d20d51,$e8011ab2,$2be7f712,$d9010df6,
  $ef0d1b01,$8f94da7f,$61aa561e,$4dbf7135,$75457341,$70156ea1,$58425bd4,$661e78c7,$644067ba,$61646dcd,
  $5b5361c5,$62c462cd,$0fd8e93f,$bd5dc95e,$3b60496f,$42634f66,$27b82ba1,$b262c261,$c85c4067,$da56d860,
  $b262bf57,$cd66366e,$5c6ca768,$475fe360,$54543a5b,$485b267e,$ae69af77,$5e5fa066,$042b4d65,$8c73fa7f,
  $b60d5db7,$624a603e,$61c86141,$23c465c2,$629c7f07,$ad5f6188,$65406e72,$623f663e,$643a6355,$59496141,
  $6dc05bcf,$69a966bc,$6b4c5c3f,$5ccb632c,$64495ede,$7f0f214b,$821b069e,$98e75925,$59025924,$80039963,
  $ae5daf80,$80d8c10a,$4a5d505e,$3c6c3b67,$da7ff524,$5ed28d53,$e0cc64bf,$c481bada,$b966445f,$1d6aab79,
  $40635961,$e0654252,$345ab16d,$1f60db5f,$0157e23a,$28c8ff02,$13041913,$fa0fe6f0,$f6cf510f,$14eefb2c,
  $ef066cda,$0e0cd10e,$372b1f1d,$1d1013e8,$ddfa7f21,$3696b35f,$80205805,$545c9d85,$dec42940,$3f4e2c04,
  $35621572,$ee23de6c,$040be259,$0b01dcf8,$27231002,$014ad904,$2edbe6f9,$03f124f6,$0f1c22c3,$37e5ee3b,
  $15fdbf05,$e1221df5,$0335e507,$de5edf02,$7dbe022f,$61886074,$b6b693db,$37d85fe6,$d53121b1,$953dfcf7,
  $c68a607e,$1de04327,$e67dad47,$334f4046,$774a9aaf,$5932479e,$5560835b,$1d6fbc5f,$ddb9006d,$c05e4b09,
  $7552314e,$b6345463,$046020df,$0afaecff,$def857fe,$1f0cfd12,$0f02f00d,$1ef8092b,$7f0f1afc,$435b80d8,
  $1328be68,$2f0ade7f,$349a9e75,$ee5be464,$f089305b,$078e475b,$dc8fb68b,$36644f60,$35663d62,$da633f6e,
  $ca643c55,$415bc069,$be604c6a,$f924b06b,$66b9da7f,$62489074,$7f081dc5,$c65f50d8,$fc7f021f,$54ab5c3b,
  $62085c50,$7f032f14,$2a7fbcda,$dee1bf5f,$3c827405,$6e9b3b5f,$c159815c,$39605b64,$b350f25a,$bd506d62,
  $0147e733,$f5db2bd7,$29fd1321,$f012dd02,$0be3272d,$7f1326e7,$aa80ecda,$030e315a,$43ec7d44,$73a460df,
  $67a566c2,$66ec61b2,$a4446dbf,$53e81ad4,$209e66ca,$75987f0f,$3a6c919a,$89a9822c,$d411095a,$157e9f98,
  $26c27280,$389e8180,$56b8cbaf,$e91b0142,$8830a381,$7a8cb89a,$0240015b,$06ded001,$757f5e7a,$753e5ddb,
  $738e9095,$5eb46e42,$534e59ef,$5fc8663c,$7cdada5c,$1f740a98,$774e375f,$8b785a6e,$3e63c25f,$665faf5f,
  $c35f3b6d,$5d68366e,$c5603259,$c064d261,$e8355653,$97ea187f,$674cd803,$702a6546,$6423517b,$790e6764,
  $161e6736,$cf197405,$5cc7df32,$d925dccd,$f5c3232a,$3cb32c2a,$012d0135,$20e214ed,$777d9a1f,$19729b68,
  $e09fcb5f,$255daa2d,$568c5b61,$6258eaae,$0c751960,$8c56f62d,$087d612d,$e66d2273,$e0abd453,$bb2976f1,
  $ddbb4601,$0c2216fd,$2702f014,$150910dd,$72ad4bb6,$012abe30,$fa528d4d,$da0bb062,$ebc4eb59,$ff152430,
  $7f14ee19,$527337dc,$406b8173,$4066bd62,$45604c5d,$8f6bb8e4,$5897910d,$c8413925,$8ece7ae0,$800c620b,
  $0817b7af,$81e7da7f,$654474ef,$7f0220cf,$ee6534da,$59604065,$124758a7,$fa7feb21,$66f77085,$5fd85926,
  $06dadfc4,$b5665f80,$4a634d56,$47665f5b,$5c70366d,$78e14960,$50828d32,$6888624c,$c79adfbd,$d089ca89,
  $726e7805,$0909be31,$4e60820f,$6308f8d1,$e8e9f629,$0464d8dc,$c86bea80,$cb61b864,$3fe78320,$fdb3fe82,
  $df6535d8,$724dd8ea,$7fda21c4,$168662dc,$bd809f52,$da7f291b,$80bd670a,$63415d34,$408037c2,$6a4153b1,
  $10dae4b4,$cd80dd67,$5f5cc262,$dee4a460,$12671504,$368c5a81,$ac66a881,$4661d56c,$d6602570,$40694857,
  $dc7ffa18,$5ab5584d,$e73a8188,$a36ed5da,$daf0c681,$81ca6726,$7fe522b1,$d26b24d8,$13214960,$98d1987f,
  $dee04350,$406bb307,$f36bc25f,$51659089,$e865939f,$091fbe64,$80d8fd80,$c65d5b70,$b45bc46e,$46117662,
  $02190303,$65a97d42,$7698761d,$60da6ec1,$5a7f5c33,$a56368d2,$24daac44,$3e787f53,$e582ff62,$793bd801,
  $68c262c4,$63c65bc0,$5c4e6435,$67c46552,$d178e5cc,$216cff5f,$18da0dfd,$075b480a,$2ef44c50,$de7f3506,
  $7f808006,$f66c9380,$f66dfc6c,$c863c177,$dadcc066,$782d65ab,$605b602f,$54dc5240,$72455bc6,$47c054de,
  $6ec45be9,$56c65c70,$67416254,$626e5646,$69457130,$1d506f2f,$9bf87f16,$08055e9f,$76f1d8e0,$66ac6452,
  $5bc768c0,$614e5cd3,$5e366057,$613a66d6,$613066d9,$604d624b,$7f08224f,$c5753ad8,$525ebd66,$d8e4c66b,
  $df487f58,$688a48da,$c75ecb7f,$9e7ffd23,$e576cd04,$85883276,$3897b094,$80bc6ab1,$57a7de8e,$98900152,
  $8140035c,$505aa790,$32597984,$5b7b9214,$19006084,$a6878220,$3b88943c,$81273361,$901061a0,$8dd3368a,
  $05de03d8,$77e7953a,$96c977ec,$5b5779d5,$47daed47,$bf7a035d,$be72366d,$cf04deec,$7099a59e,$4576887a,
  $3aa54562,$78e4b804,$69829e20,$dc7d8040,$452c5979,$98893910,$4c80025c,$7592d8fd,$5ec960c1,$604f5bce,
  $5fad65c3,$5bd35fd2,$5f3e6255,$575b5e46,$5850614a,$59ca6344,$61bd59da,$5f267041,$674256df,$5abb66b6,
  $63b66859,$7f042a3a,$e67fca7a,$7082927a,$fa110d0d,$0605fc0c,$8864d87f,$60ca6444,$58e36fc2,$56586644,
  $744b60d4,$59555622,$63ba5c70,$653774af,$7f15324a,$758b067e,$76b280e5,$77dc76b4,$82028012,$08424b69,
  $2ada09ff,$0507030e,$7a7f0817,$98788983,$826a8208,$c8485dc9,$c6864dd8,$bb68416b,$25763f60,$4958e05f,
  $5554c65e,$5858cd66,$be5bc951,$f452c56c,$c55dc063,$16cb430e,$32f9f9eb,$0210f104,$181afc03,$ec0907e3,
  $fdec0a24,$43080ef8,$fd015ba0,$22dc10e5,$1910c81d,$2e0cf5e8,$f42af91c,$ea28fdc2,$c73a28ec,$0818fe09,
  $0aef14ea,$0ef60f11,$0cebfd28,$03180611,$7f36d87f,$da01e0cb,$7afa8210,$603b6542,$52605ad0,$57b258f7,
  $622f6154,$504a673f,$77ab60f9,$66c26817,$5fcf53cc,$68406ade,$4eca58b4,$64455964,$65306e48,$604a5ed0,
  $5f3270c3,$69b56352,$24515e4a,$fe987fff,$7fe81281,$218844da,$c9604082,$4c613960,$0a203861,$0b196582,
  $d87f0905,$a146887e,$e7e81a4f,$027f9d78,$dcc87f82,$65497c7c,$5fcb7c91,$24cf61c1,$38a55882,$dce85175,
  $66a8826e,$634e7fbf,$54821e4f,$7cf8fae4,$1e2e7d77,$7f542988,$b49eb8dc,$d08d739e,$b6afbd67,$020da815,
  $914ad87f,$6a405f45,$5cce5fbe,$5a4066c5,$5cd26241,$68435eca,$82802340,$55dcfd7d,$b89e7e8c,$53acf28d,
  $c954c83e,$1224be5e,$60307880,$656555cb,$60d555c0,$6b347229,$60cc60c8,$62ca65b5,$5a475e39,$67405c57,
  $62e55c40,$684459c5,$25bc6249,$78d87f02,$3b63c98c,$7a7ffc29,$89d6659b,$c8794f83,$793a03a2,$975378ee,
  $17fc0a96,$ff0707fb,$0e03031c,$9f80987f,$ca01e7c6,$7f0220c5,$4296b9d8,$dce1d060,$96e077bf,$acdf928e,
  $a5f8ae75,$e2cab9c5,$ca9c7f98,$7a239a03,$80069c8b,$005a8c84,$00514044,$38e88200,$2042abe0,$977cd8e4,
  $60c065c8,$27385e5a,$b1d87f02,$7ae33f9a,$9ab69e58,$c7a18204,$05204875,$8b82fe74,$e8d8fbc7,$e6706498,
  $48078a9f,$4f5e4860,$c6674b59,$7ee1cb61,$be9ebd04,$827e3b9e,$f244829e,$9d93d6da,$803dc19e,$66dea7a0,
  $4979447c,$455f4961,$007f0620);

const
  gbkext2_data: array[0..433-1] of Cardinal = (
  $037f02c9,$1302d9da,$1027c120,$c80ecf7e,$7c008028,$142f040a,$187f5801,$237f2550,$0e9f7f0e,$64606643,
  $09dc03e0,$12229526,$96e04a30,$f80bc20b,$02ea32a3,$608020c8,$e28024e2,$e2fe301c,$02ffe4ff,$2121041e,
  $fffd3231,$03162010,$9f30fcf8,$00a60801,$01e96422,$00fe49b8,$9fd01040,$3601c10d,$1630070d,$72dcb80a,
  $0a080024,$01503881,$83101050,$c8843a8c,$e00c4459,$014051b7,$c691c400,$154401b7,$41404051,$0b450044,
  $30414061,$5044004d,$d0041540,$40890fbf,$40204002,$8c851584,$7fd01058,$d4498212,$024011b7,$11010650,
  $05b37f02,$0f9ff000,$c1149fc1,$0041d5ab,$10402442,$55400050,$84004740,$45295dba,$81026110,$42abf8c8,
  $02414040,$41404444,$6003d266,$80032048,$045cc88c,$2f411174,$71440460,$d0441441,$31473641,$00404d41,
  $50414042,$41400140,$42510040,$d105114d,$404004af,$9611b1d8,$441359e8,$5a004040,$d7114520,$244602b3,
  $59c88014,$00014181,$2c02abc8,$8c8195e1,$c8300258,$105946b3,$b5c54045,$48104001,$588c9580,$58e88144,
  $67606100,$84124741,$4140599e,$c1007154,$a7e045d1,$c5b1d010,$1554e054,$588d8000,$70414404,$bfd02040,
  $1440410d,$c4040051,$04abc195,$010ebfd0,$0049025c,$59f8a100,$40015024,$04086006,$95d08dd0,$6c01afc1,
  $44815446,$55a05001,$64514002,$51006404,$b7c10504,$44005d41,$d0044000,$d981179f,$1045b058,$0a588c88,
  $c1002058,$c18fc18f,$247011ad,$48add400,$21509641,$475c1454,$40415441,$6559c8a5,$98a193d4,$04414559,
  $01604440,$20484202,$00504481,$04420140,$10520054,$00510448,$81add401,$00410044,$b7d20044,$c193f001,
  $f00222bf,$00810193,$81050212,$43105024,$49905310,$40845c00,$8dd00040,$c10d9fd1,$440512bf,$3bbfc104,
  $bfc40001,$c100012c,$040189bf,$9f7f0200,$159fc139,$4662cf41,$4766d960,$4d62d066,$0005812c,$4688afe4,
  $610c4090,$40444101,$41005500,$40114710,$45884060,$48015404,$41207001,$a0804064,$998c388c,$8e85045e,
  $5c998038,$8c810854,$bfd41458,$b7d0020d,$910049a2,$1bc25cc9,$8124c144,$88800c01,$7a4146ba,$405a998e,
  $81090810,$91b5c415,$a7c40150,$408360d4,$12815404,$01810900,$40414054,$0154404c,$82000440,$c14158c8,
  $644113bf,$7d804200,$40055200,$5fbc903a,$01514011,$4405a9c1,$4f005000,$6e415320,$4a7118c0,$120c8121,
  $a23dea84,$541058cc,$0a000544,$cc186481,$bc9720ab,$81211059,$80013c88,$a7e6c470,$52004320,$58406040,
  $b88c8001,$4258ada8,$05501151,$3042044e,$86104240,$50015d88,$58d88020,$44005000,$add00008,$58c98010,
  $54344050,$70104016,$04504006,$7051b7d0,$61204454,$49244011,$d193d040,$444501b5,$02adc500,$588f8000,
  $11b3f010,$c1010050,$014c05ab,$b3d00058,$41414002,$40015003,$48014001,$40014005,$0ebfc101,$b1c40041,
  $0d9fc101,$020197c5,$060f7f7f,$10500481,$d1200044,$85e540c9,$50588c80,$8a802040,$0143315c,$5c8ba404,
  $01024604,$205da884,$58c88910,$47156601,$41114404,$45304021,$44005410,$14144003,$46588c80,$01410054,
  $c4400140,$11440541,$0c408140,$10440440,$10add010,$10404050,$04424040,$010ebfe0,$02410450,$05440060,
  $5a58d880,$4a700441,$00504054,$50405041,$04410050,$90501248,$3c898008,$520aa9c4,$40404041,$44034024,
  $d4104804,$18bfd191,$13bfd002,$dfc10541,$0624c237,$01541081,$c4041049,$bfd001b3,$d0000135,$b7c12f9f,
  $9fc40002,$1b9fc171,$013cbfc1,$4c31dfc4,$c865c962,$596a5e6c,$4040a7e0,$41004046,$40024004,$43014002,
  $40605100,$83dfd040,$82013843,$4940557c,$84ade848,$01440240,$97d04040,$8259998d,$e2406841,$9404d060,
  $4400589d,$40044118,$46604230,$d89c1204,$d0008058,$055a11b5,$00541450,$d489d020,$004112b5,$c1109fc1,
  $6ac494df,$810b22cb,$48064042,$42a24110,$d98da390,$0c115acb,$61bb8f84,$105ea891,$61600c40,$8d900458,
  $18401258,$00600841,$01440a50,$13415554,$445ccc94,$59c88418,$53084c10,$08044405,$0113bfd4,$05afc201,
  $518dc400,$01812440,$80060811,$305ed9a0,$004cd540,$40420048,$75d0204c,$8dcc5182,$c1969fd0,$9fc1169f,
  $169fc11c,$c1729fc1,$9fc1289f,$379fc121,$9fc18fc1,$299fc164,$4c16dfc1,$82374162,$150c285f,$0c070421,
  $0305060a,$0e06050a,$00048106,$4467dfd0,$0525c769,$40409a81,$b038e890,$48135e9a,$82061040,$e140404c,
  $c44946b7,$c4000044,$ac1111ab,$4860b9c8,$4004afc8,$0184440c,$305c98a4,$b3d40144,$00804511,$1210bfc1,
  $afd04d45,$40005006,$50605401,$40045000,$30dfd454,$008122c2,$567cdfc9,$497b8021,$7125bfe2,$c800084c,
  $9fd1229f,$229fc11c,$60c1d3c2,$a480224c,$0c0abd8b,$dfd1937f,$822846c2,$0d18685d,$02400281,$20413057,
  $40410150,$01540441,$40405040,$d0100140,$7f020193,$828dd193,$d1505bd8,$3c8a919b,$7038aba4,$24c260cc,
  $68404482,$c8607878,$4e55827d,$810d1873,$40413906,$d8800921,$046012b1,$50400240,$41b7d000,$04410064,
  $516c4147,$d98dc402,$054119b5,$40400540,$09540044,$dfc293d0,$0b20422a,$c083b57f,$f92c7801,$0a521c4d,
  $b140811b,$03e1388e,$00005016);

const
  jisx0208_data: array[0..2437-1] of Cardinal = (
  $057f2fff,$ff0c04de,$30fbff0e,$21c0ff1a,$09fe7fe2,$309c309b,$ff4000b4,$ff3e00a8,$ff3fffe3,$7e0030fd,
  $031ce006,$054edd30,$09de0330,$201530fc,$ff0f2010,$301cff3c,$ff5c2016,$19bf2026,$05dec880,$ff09ff08,
  $30153014,$2ec1ff3b,$08187f02,$0bdc1130,$b12212ff,$7eefe500,$60ff1d05,$1eff1c22,$012266ff,$de7f16b7,
  $4026420b,$3200b026,$03203320,$04ffe521,$a300a2ff,$3eff0500,$daeac361,$260600a7,$5fc3433f,$5f9b5fb9,
  $dfca5fd2,$12203bdc,$3e219230,$187f0220,$0b163013,$03220878,$01fb017b,$d67fffa7,$dae03e08,$21d200ac,
  $7f0335c1,$121c0bf6,$10f0a6ca,$2bb16598,$627daf01,$01db5750,$2bdc0716,$6f203021,$1cdebe26,$20212020,
  $043600b6,$0f3625ef,$7611ff10,$1f7f0807,$07067619,$36191f7f,$1f304104,$0e0b7652,$36551f7f,$9f039108,
  $7607c110,$9f7f0808,$7607c110,$c97f4726,$191fea2c,$dbcb0f16,$16191fd2,$2500d80d,$63c364c1,$5c4f63bc,
  $608563cf,$5e4761cb,$67b867cb,$5cce4acf,$691e63ce,$7f0a2935,$9c2afe12,$0355164e,$c0963f5a,$28611b54,
  $2259f663,$1c847590,$aa7a5083,$2563e160,$6665ed6e,$f582a684,$2768939b,$7165a157,$d05b9b62,$f4867b59,
  $be7d6298,$169b8e7d,$b77c9f62,$b55b8988,$9763095e,$c7684866,$4f978d95,$244ee567,$fee4f90a,$f2504928,
  $d4593756,$095a0159,$0f60df5c,$13617061,$ba690566,$70754f70,$ad79fb75,$c37def7d,$63840e80,$558b0288,
  $3b907a90,$a54e9553,$b257df4e,$ef90c180,$f14e0078,$386ea258,$287a3290,$2f828b83,$7051419c,$e88f4c53,
  $fb07deff,$f25f1559,$e46deb98,$62852d80,$fef7cd96,$0b97fb46,$8753f354,$bd70cf5b,$e88fc27f,$5c536f96,
  $117aba9d,$fc78934e,$186e2681,$1d550456,$3b851a6b,$a959e59c,$dc6d6653,$42958f74,$4b4e9156,$4f96f290,
  $e1990c83,$3055b653,$205f715b,$0466f366,$f36c3868,$5b6d296c,$4e76c874,$f198347a,$60885b82,$b292ed8a,
  $ca75ab6d,$a699c576,$8a8b0160,$8e95b28d,$8653ad69,$30571251,$b4594458,$285ef65b,$f463a960,$146cbf63,
  $4a17796f,$7e7f7c24,$01733f2f,$d182767e,$60859782,$1b925b90,$bc58699d,$256c5a65,$2e51f975,$80596559,
  $bc5fdc5f,$2a65fa62,$b46b276a,$c1738b6b,$2c89567f,$c49d0e9d,$965ca19e,$04837b6c,$b65c4b51,$7681c661,
  $59726168,$784ffa4e,$29606953,$f37a4f6e,$164e0b97,$674eee53,$7fd264e8,$52a004fe,$560953ef,$d3b1590f,
  $09fee2ab,$668779d1,$67b6679c,$6cb36b4c,$73c2706b,$f630798d,$b1d8f4a9,$73346982,$fe7fe478,$b287661b,
  $a856298a,$4e8fe68c,$8a971e90,$e84fc486,$5962115c,$e5753b72,$fe82bd81,$c58cc086,$d5991396,$1a4ecb99,
  $de89e34f,$ca584a56,$ef5efb58,$cea698fa,$fee41db5,$3962d06e,$669b4165,$7768b066,$4c70706d,$75768675,
  $f982a57d,$8e958b87,$f18c9d96,$1652be51,$b354b359,$685d165b,$af698261,$cb788d6d,$72885784,$b893a78a,
  $a86d6c9a,$a386d999,$ce67ff57,$83920e86,$04568752,$e15ed354,$3c64b962,$bb683868,$ba73726b,$9a7a6b78,
  $6b89d289,$ed8f038d,$9495a390,$66976996,$7d5cb35b,$4e984d69,$20639b98,$7f6a2b7b,$0d68b66a,$726f5f9c,
  $70559d52,$3b62ec60,$d16e076d,$10845b6e,$148f4489,$f69c394e,$3a691b53,$2a97846a,$c3515c68,$dc84b27a,
  $5b938c91,$229d2856,$31830568,$087ca584,$e682c552,$834e7e74,$d251a04f,$d8520a5b,$fb52e752,$2a559a5d,
  $be97bb58,$7c7f4320,$5e795e72,$447c60a3,$0cfe7f5b,$656263db,$685367d1,$6b3e68fa,$6c576b53,$6f976f22,
  $74b06f45,$e27f2a67,$a17afff8,$4cbc79fe,$feeacae7,$9e826607,$cc89b383,$848cab8a,$41945190,$c2a107fb,
  $fef54db6,$3882180c,$b8542b4e,$a95dcc5c,$3c764c73,$eb5ca977,$c18d0b7f,$390b4f96,$0104fee0,$714f0e4f,
  $cb559c53,$c1b4ce46,$7bacbaeb,$faf4d9c7,$673a63ee,$b3c8289d,$f9a7e7ab,$5e300dfe,$6c176bc5,$757f6c7d,
  $5b637948,$7d007a00,$898f5fbd,$8cb48a18,$e50d52c2,$98e225fe,$9b3c9a0e,$507d4e80,$59935100,$622f5b9c,
  $64ec6280,$72a06b3a,$79477591,$87fb7fa9,$8b708abc,$83ca63ac,$540997a0,$55ab5403,$6a586854,$78278a70,
  $9ecd6775,$5ba25374,$8650811a,$4e189006,$e49a062c,$53ca18de,$5bae5438,$60255f13,$673d6551,$6c726c42,
  $70786ce3,$7a767403,$7b087aae,$7cfe7d1a,$65e77d66,$53bb725b,$5de85c45,$fc4d62d2,$6e2009de,$8a31865a,
  $92f88ddd,$79a66f01,$4ea89b5a,$12eea042,$7f763308,$717af6fa,$dd768451,$09ae5d9c,$5883fcfc,$5f375ce1,
  $220b9212,$3bde7f1d,$6559631f,$6cc16a4b,$72ed72c2,$80f877ef,$82088105,$90f7854e,$97ff93e1,$9a5a9957,
  $51dd4ef0,$66815c2d,$5c40696d,$697566f2,$68507389,$50c57c81,$574752e4,$93265dfe,$6b2365a4,$74346b3d,
  $79bd7981,$7dca7b4b,$83cc82b9,$895f887f,$8fd18b39,$541f91d1,$4e5d9280,$53e55036,$72d7533a,$77e97396,
  $8eaf82e6,$e4c199c6,$517726fe,$865e611a,$7a7a55b0,$5bd35076,$96859047,$6adb4e32,$5c5191e7,$63985c48,
  $6c937a9f,$8f619774,$718a7aaa,$7c829688,$7e706817,$936c6851,$541b52f2,$8a1385ab,$8ecd7fa4,$536690e1,
  $79418888,$4afb4fc2,$06fed33d,$572d5553,$578b73ea,$5f625951,$300bc221,$f87f42f1,$c68763b2,$05fef02c,
  $6e136842,$7a3d7566,$32507cfb,$1dfeeb19,$830e7f6b,$86cd834a,$8a638a08,$8efd8b66,$9d8f981a,$8fce82b8,
  $52879be8,$6483621f,$96996fc0,$50916841,$6c7a6b20,$7a746f54,$88407d50,$67088a23,$b7424ef6,$ef16a3e7,
  $06fee2aa,$570f55a7,$5acc5805,$61b25efa,$e7ebea45,$691c0bfe,$727d6a29,$732e72ac,$786f7814,$770c7d79,
  $898b80a9,$feff238d,$906344fe,$967a9375,$9a139855,$51439e78,$53b3539f,$5f265e7b,$6e906e1b,$73fe7384,
  $82377d43,$8afa8a00,$4e4e9650,$53e4500b,$56fa547c,$5b6459d1,$5eab5df1,$62385f27,$67af6545,$72d06e56,
  $88b47cca,$80e180a1,$864e83f0,$8de88a87,$96c79237,$9f139867,$4e924e94,$53484f0d,$543e5449,$5f8c5a2f,
  $609f5fa1,$6a8e68a7,$7881745a,$8aa48a9e,$91908b77,$9bc94e5e,$cad74ea4,$c9fda698,$6732a22c,$229ba448,
  $e9fda2d9,$6a50bc7d,$f8c87d6f,$c15de5d8,$682a80a7,$99821ca1,$0d2af9b3,$6e4ecea4,$8ac240ac,$39d6b3a7,
  $6c5ff8f3,$2c58faca,$32f87f6e,$2f935475,$7ce0d8fd,$53462964,$8015f87f,$a01aadee,$e9a8eaa2,$83520cfe,
  $8861884c,$8ca28b1b,$90ca8cfc,$92719175,$92fc783f,$dea895a4,$d8fcf93e,$5b9d3b9a,$0d2e4f52,$d51bfee1,
  $e062f758,$5f8c6a6f,$4b9eb98f,$4a523b51,$4056fd54,$6091777a,$449ed29d,$706f0973,$fd751181,$a860da5f,
  $bc72db9a,$036b648f,$f04eca98,$bd667356,$684afef9,$0f61c760,$39660666,$f768b168,$3a75d56d,$42826e7d,
  $504e9b9b,$0653c94f,$e65d6f55,$fb5dee5d,$736c9967,$50780274,$df93968a,$a7575088,$b5632b5e,$8d50ac50,
  $c9670051,$bb585e54,$695bb059,$a1624d5f,$73683d63,$7d6e086b,$8091c770,$26781572,$8e796d78,$dc7d3065,
  $0988c183,$64969b8f,$50572852,$a17f6a67,$4251b48c,$3a962a57,$b4698a58,$0e54b280,$9557fc5d,$5c9dfa78,
  $8b524a4f,$e9643e54,$7eee0baf,$567a842f,$2f7d227b,$ad685c93,$197b399b,$37518a53,$f65bdf52,$e664ae62,
  $ba672d64,$d185a96b,$d6769096,$06634c9b,$bf9bab93,$09665276,$c250984e,$e85c7153,$63649260,$e6685f65,
  $2373ca71,$827b9775,$8386957e,$788cdb8b,$ac991091,$8b66ab65,$ff4ed56b,$f87f4566,$ebbd523a,$dbfaff07,
  $df58eb56,$50a357fa,$28bb4bf3,$dee45eae,$2f630704,$af5b5c65,$def54d65,$62679d08,$0f6b7b6b,$4973456c,
  $f879c179,$fee8e07c,$0280a204,$9681f381,$d82ac789,$8986259f,$fe7f153d,$fc96cc04,$8b6b6f98,$2942b04e,
  $571efefc,$485bfa5b,$42630161,$cb6b2166,$3e6cbb6e,$d474bd72,$3a78c175,$33800c79,$9481ea80,$508f9e84,
  $0f9e7f6c,$2b8b585f,$f87afa9d,$eb5b8d8e,$f14e0396,$3957f753,$feedae5f,$7f608955,$be6f066e,$9f8cea75,
  $e085005b,$f450727b,$61829d67,$1e854a5c,$99820e7e,$685c0451,$9c8d6663,$3e716e65,$057d1779,$ca8b1d80,
  $c7906e8e,$1f90aa86,$3a52fa50,$7c67535c,$4c723570,$2b91c891,$c282e593,$f95f315b,$d64e3b60,$4b5b8853,
  $8a673162,$e072e96b,$6b7a2e73,$528da381,$12999691,$6a53d751,$885bff54,$ac6a3963,$da97007d,$6853ce56,
  $315b9754,$ee5dde5c,$fe61014f,$c06d3262,$4279cb79,$d27e4d7d,$1f81ed7f,$46849082,$90897288,$ba8e748b,
  $21319c06,$96c6fc7f,$4ec0919c,$ffbfd68e,$5f9340fe,$67d4620e,$6e0b6c41,$7e267363,$928391cd,$591953d4,
  $6dd15bbf,$7e2e795d,$587e7c9b,$51fa719f,$8ff08853,$5cfb4fca,$77ac6625,$821c7ae3,$51c699ff,$65ec5faa,
  $6b89696f,$6e966df3,$76fe6f64,$5de17d14,$91879075,$51e69806,$6240521d,$66d96691,$5eb66e1a,$7f727dd2,
  $85af66f8,$8af885f7,$53d952a9,$5e8f5973,$60555f90,$966492e4,$f66750b7,$9226a42e,$ae5dafba,$68f8ee57,
  $89f65559,$02095137,$84f87f09,$f956055e,$627ff8e8,$2b095a04,$07d87feb,$49304466,$cc8f077e,$f87f1637,
  $02cb6cbc,$04fee4ea,$7126713c,$75c77167,$aa3d6f39,$aefa2a63,$e91e5630,$809605fe,$848b83d6,$885d8549,
  $61ccae95,$61fcef57,$a48cde8c,$9c5ec191,$969cdce9,$4e0a9798,$7f392abe,$51973efe,$57ce5270,$58cc5834,
  $5e385b22,$64fe60c5,$67566761,$72b66d44,$7a637573,$8b7284b8,$932091b8,$57f45631,$62ed98fe,$6b96690d,
  $7e5471ed,$82728077,$98df89e6,$8fb18755,$4f385c3b,$4fb54fe1,$5a205507,$5be95bdd,$614e5fc3,$65b0632f,
  $68ee664b,$6d78699b,$75336df1,$771f75b9,$79e6795e,$81e37d33,$85aa82af,$8a3a89aa,$5aef8eab,$20fefaaa,
  $4eba9707,$52034ec1,$58ec5875,$751a5c0b,$814e5c3d,$8fc58a0a,$976d9663,$8acf7b25,$91629808,$53a856f3,
  $54399017,$5e255782,$6c3463a8,$7761708a,$7fe07c8b,$90428870,$e07eef11,$968f1ffe,$9ac4745e,$5d695d07,
  $67a26570,$96db8da8,$6749636e,$83c56919,$96c09817,$6f8488fe,$5bf8647a,$702c4e16,$662f755d,$523651c4,
  $59d352e2,$60275f81,$653f6210,$e54aaa34,$68f20bfe,$6b636816,$72726e05,$76db751f,$80567cbe,$88fd58f0,
  $1f3c8281,$14fe7f38,$9192901d,$97599752,$7a0e6589,$96bb8106,$60dc5e2d,$65a5621a,$67906614,$7a4d77f3,
  $7e3e7c4d,$8cac810a,$e7d9f2b7,$0778a9fc,$cb62d952,$fec56a72,$838a2d0d,$ac7bc07a,$7696ea8a,$49820c7d,
  $484ed987,$60534351,$5e5ba353,$7efc684e,$47622610,$1364b062,$c9683468,$176d456c,$5c67d36d,$7d714e6f,
  $7f65cb71,$da7bad7a,$5d7e707d,$1e2a0f47,$a629fe7f,$ce8a6e85,$788df58c,$ad907790,$83929192,$4d9bae95,
  $38558452,$6871366f,$55798551,$ce81b37e,$51564c7c,$aa5ca858,$fd66fe63,$d9695a66,$8e758f72,$56790e75,
  $9779df79,$447d207c,$3486077d,$61963b8a,$e79f2090,$5d5b8d50,$090bfee1,$ee55aa50,$3d594f58,$645b8b72,
  $e3531d5c,$5c60f360,$b6f22663,$fc6f11a7,$e30efef0,$fd69cd5d,$e56f1569,$e94e8971,$9376f875,$cf7cdf7a,
  $617d9c7d,$0e834980,$fee4fc4e,$c585fb10,$018d7088,$97906d90,$12971c93,$9750cf9a,$d3618e58,$08853581,
  $c390208d,$bf4ab04f,$6f2afef2,$5f634960,$b36e2c67,$d7901f8d,$ca5c5e4f,$9a65cf8c,$9653527d,$c3517688,
  $6b5b5863,$0d5c0a5b,$5c675164,$1a4ed690,$70592a59,$3e8a516c,$a5581555,$5360f059,$3567c162,$40695582,
  $2899c496,$064f539a,$105bfe58,$7d5cb180,$fee9ad57,$34614b88,$f066ff62,$ce6ede6c,$d4817f80,$b8888b82,
  $2e90008c,$db968a90,$e39bdb9e,$2753f04e,$8d7b2c59,$f9984c91,$276edd9d,$44535370,$585b8555,$d3629e62,
  $ef6ca262,$1774226f,$c194388a,$388afe6f,$f851e783,$e953ea86,$544f4653,$6a8fb090,$fd813159,$bf7aea5d,
  $3768da8f,$4872f88c,$b06a3d9c,$584e398a,$66560653,$a262c557,$4e65e663,$5b6de16b,$ed70ad6e,$aa7aef77,
  $3d7dbb7b,$cb80c680,$5b8a9586,$c756e393,$ad5f3e58,$80669665,$376bb56a,$248ac775,$3077e550,$655f1b57,
  $60667a60,$1a75f46c,$f47f6e7a,$45871881,$c999b390,$f9755c7b,$c47b517a,$e9901084,$367a9279,$405ae183,
  $f24e2d77,$e05b994e,$3c62bd5f,$e867f166,$77866b6c,$4e8a3b88,$d092f391,$266a1799,$e7732a70,$af845782,
  $464e018c,$8b51cb51,$165bf555,$29361c5e,$493ae069,$f23bfe7f,$a2631161,$6e671d66,$3a72526f,$74773a75,
  $78813980,$bf877681,$858adc8a,$9a8df38d,$02957792,$c59ce598,$f4635752,$88671576,$c373cd6c,$7393ae8c,
  $9c6d2596,$cc690e58,$9a8ffd69,$1a75db93,$02585a90,$fb63b468,$2c4f4369,$bb67d86f,$b485268f,$3f93547d,
  $6a6f7069,$2c58f757,$2a7d2c5b,$e3540a72,$ad9db491,$8c36a04e,$43067ee1,$488c9e52,$9a582454,$785e1d5b,
  $9e497e18,$0dfef6c8,$633a62b5,$68af63d0,$78876c40,$7a0b798e,$82477de0,$8ae68a02,$93ce8e44,$3bfee74a,
  $9f0e91d8,$64586ce5,$657564e2,$76846ef4,$90697b1b,$6eba93d1,$5fb954f2,$8f4d64a4,$92448fed,$586b5178,
  $5c555929,$6dfb5e97,$751c7e8f,$8ee28cbc,$70b9985b,$6bbf4f1d,$75306fb1,$514e96fb,$58355410,$59ac5857,
  $5f925c60,$675c6597,$767b6e21,$8ced83df,$90fd9014,$7825934d,$52aa783a,$571f5ea6,$60125974,$47475012,
  $7f332209,$55100bfe,$58585854,$5b955957,$5d8b5cf6,$629560bc,$6771642d,$e229e2d1,$76d709fe,$6e6f6dd8,
  $706f6d9b,$5f5371c8,$797775d8,$dfe82bd1,$7cd608fe,$52307d71,$85698463,$8a0e85e4,$23418b04,$7f0c3f3f,
  $9419d0fe,$982d9676,$95d89a30,$52d550cd,$5802540c,$61a75c0e,$6d1e649e,$7ae577b3,$840480f4,$92859053,
  $9d075ce0,$5f97533f,$6d9c5fb3,$77637279,$7be479bf,$72ec6bd2,$68038aad,$51f86a61,$69347a81,$9cf65c4a,
  $5bc582eb,$701e9149,$5c6f5678,$656660c7,$8c5a6c8c,$98139041,$66c75451,$5948920d,$518590a3,$51ea4e4d,
  $8b0e8599,$637a7058,$6962934b,$7e0499b4,$53577577,$8edf6960,$6c5d96e3,$5c3c4e8c,$8fe95f10,$8cd15302,
  $86798089,$65e55eff,$51654e73,$5c3f5982,$4efb97ee,$5fcd598a,$6fe18a8d,$796279b0,$84715be7,$71b1732b,
  $5ff55e74,$649a637b,$7c9871c3,$5efc4e43,$57dc4e4b,$60a956a2,$7d0d6fc3,$813380fd,$8fb281bf,$86a48997,
  $628a5df4,$898764ad,$6ce26777,$74366d3e,$5a467834,$82ad7f75,$4ff399ac,$62dd5ec3,$65576392,$76c3676f,
  $80cc724c,$8f2980ba,$500d914d,$5a9257f9,$69736885,$72fd7164,$58f28cb7,$966a8ce0,$877f9019,$77e779e4,
  $4f2f8429,$535a5265,$67cf62cd,$767d6cca,$7c957b94,$85848236,$66dd8feb,$72066f20,$83ab7e1b,$9ea699c1,
  $7bb151fd,$7bb87872,$7b488087,$5e616ae8,$7551808c,$516b7560,$6e8c9262,$9197767a,$4f109aea,$629c7f70,
  $95a57b4f,$567a9ce9,$86e45859,$4f3496bc,$0b255224,$07fee0da,$642c5e06,$677f6591,$6c4e6c3e,$f6667248,
  $15fef66c,$822c7e41,$8ca985e9,$91c67bc4,$98127169,$633d98ef,$756a6669,$78d076e4,$86ee8543,$5351532a,
  $59835426,$d6f45e87,$f8ef796c,$659004fe,$6ccc6bd4,$8afb75b2,$49fef46f,$7f777dcb,$88ab80a5,$8cbb8ab9,
  $975e907f,$6a0b98db,$50997c38,$5fae5c3e,$6bd86787,$77097435,$9f3b7f8e,$7a1767ca,$758b5339,$5f669aed,
  $83f1819d,$5f3c8098,$75625fc5,$903c7b46,$59eb6867,$7d105a9b,$8b2c767e,$5f6a4ff5,$6c376a19,$74e26f02,
  $88687968,$8c798a55,$63cf5edf,$79d275c5,$932882d7,$849c92f2,$9c2d86ed,$5f6c54c1,$6d5c658c,$8ca77015,
  $983b8cd3,$74f6654f,$4ed84e0d,$eb4a57e0,$0ffef65c,$5e0351a8,$60165e9c,$65776276,$666e65a7,$72366d6e,
  $81507b26,$8299819a,$17438b5c,$68fee8d9,$9644961c,$64ab4fae,$821e6b66,$856a8461,$5c0190e8,$98a86953,
  $8557847a,$526f4f0f,$5e455fa9,$798f670d,$89078179,$6df58986,$62555f17,$4ecf6cb8,$9b927269,$543b5206,
  $58b35674,$626e61a4,$596e711a,$7cde7c89,$96f07d1b,$805e6587,$4f754e19,$58405175,$5e735e63,$67c45f0a,
  $853d4e26,$965b9589,$98017c73,$58c150fb,$78a77656,$77a55225,$7b868511,$5909504f,$7bc77247,$8fba7de8,
  $904d8fd4,$52c94fbf,$5f015a29,$4fdd97ad,$92ea8217,$63555703,$752b6b69,$8f1488dc,$52df7a42,$61555893,
  $66ae620a,$7c3f6bcd,$502383e9,$53054ff8,$58315446,$5b9d5949,$e397ff52,$b15e96fa,$af5ab562,$0b07fee7,
  $e16cd567,$3270f96c,$de7e2b78,$fd63d480,$020afeed,$2a891287,$a68c4a8a,$fd92d290,$6c9cf398,$514e4f9d,
  $fefc8fae,$a8574a07,$d85e3d59,$3f5fd95f,$6666b462,$fef01ad2,$215192a0,$a880aa7d,$8c8b0081,$7e8cbf8c,
  $20963292,$17982c54,$5c50d553,$b258a853,$67673464,$46776672,$c391e67a,$866ca152,$4c58006b,$2c59545e,
  $e17ffb67,$6976c651,$5478e864,$cb9ebb9b,$2759b957,$ce679a66,$d954e96b,$9c5e5569,$aa679581,$5267fe9b,
  $a6685d9c,$c84fe34e,$2b62b953,$c46cab67,$6d4fad8f,$079ebf7e,$8061624e,$136f2b6e,$2a547385,$f39b4567,
  $ac7b955d,$1c5bc65c,$d16e4a87,$087a1484,$8d599981,$206c117c,$2252d977,$5f712159,$2777db72,$0b9d6197,
  $185a7f69,$0d51a55a,$0e547d54,$f776df66,$f492988f,$5d59ea9c,$4d6ec572,$bf68c951,$627dec7d,$789eba97,
  $026a2164,$5f598483,$1b6bdb5b,$b276f273,$9980177d,$28513284,$ee9ed967,$ff676276,$24990552,$7e623b5c,
  $4f8cb07c,$0b60b655,$0195807d,$b64e5f53,$3a591c51,$ce803672,$e25f2591,$79538477,$ac7d045f,$8d8a3385,
  $f397568e,$5385ae67,$08610994,$526cb961,$388aed76,$51552f8f,$3e73d84f,$a5a3def0,$a05e7d5b,$d6618260,
  $da670963,$8c6e6767,$3773366d,$50753173,$9888d579,$91904a8a,$c490f590,$15878d96,$594e8859,$894e0e4f,
  $108f3f8a,$7c50ad98,$b959965e,$da5eb85b,$c163fa63,$4a66dc64,$0b69d869,$946eb66d,$af752871,$007f8a7a,
  $c9844980,$21898184,$658e0a8b,$0a967d90,$91617e99,$836b3262,$cc6d746c,$c07ffc7f,$ba7f856d,$6588f887,
  $3c83b167,$1b96f798,$3d7d616d,$71916a84,$5053754e,$eb6b045d,$2d85cd6f,$2989a786,$65540f52,$a8674e5c,
  $83740668,$cf75e274,$cc88e188,$7896e291,$875f8b96,$4e7acb73,$6563a084,$41528975,$096e9c6d,$6b755974,
  $867c9278,$8d7adc96,$6e4fb69f,$5c65c561,$ae4e8686,$2150da4e,$ee51cc4e,$8165995b,$1f6dbc68,$ad764273,
  $e77a1c77,$d2826f7c,$cf907c8a,$18967591,$d1529b98,$98502b7d,$cb679753,$3371d06d,$2a81e874,$5796a38f,
  $609e9f9c,$99584174,$5e7d2f6d,$364ee498,$b74f8b4f,$ba52b151,$b2601c5d,$d3793c73,$b7923482,$1ee9fe96,
  $629e9743,$7466a69f,$a352176b,$c270c852,$4b5ec988,$23619060,$3e71496f,$6f7df47c,$2384ee80,$42932c90,
  $d39b6f54,$c270896a,$328def8c,$4152b497,$045eca5a,$7c67175f,$6a699469,$626f0f6d,$ed72fc72,$7e80017b,
  $ce874b80,$93516d90,$8b79849e,$d6933280,$8c502d8a,$6a8a7154,$078cc46b,$a060d181,$999df267,$104e984e,
  $c18a6b9c,$00856885,$976e7e69,$16815578,$5f0cda2b,$2a444e10,$126c8207,$032a0214,$6b069e7f,$124e8a8c,
  $8e5f0d82,$504e9e4e,$6bc2614d,$5e415bbf,$594e6354,$5a50a8d7,$5d4162a7,$63517730,$632e51c8,$a7d64f60,
  $60a2f381,$5b4264af,$60535b48,$6aac66f4,$6517903b,$614762ab,$5ae15892,$03dae1fc,$3b505567,$d55e515c,
  $2b6cc765,$c06b3e77,$4769ce54,$4a5b4763,$3869bc65,$bf5fd360,$832c4662,$1203b7c5,$7f0e08fa,$697af8da,
  $d161c051,$56d87ae0,$d583518c,$20cd4539,$b84682fc,$1f7cb686,$da7f0512,$51e98655,$64446143,$1d486345,
  $2c5a8219,$0107f516,$0a16f612,$fe0c0af5,$dffe0710,$dc7f0917,$8fa78fa8,$674052ac,$64cb65b9,$7f032246,
  $e098ed7a,$49801352,$38dae0cc,$c2530d75,$c862455f,$61820225,$fa7fff2f,$53494e17,$78722603,$18dae24a,
  $3c537b59,$c564d365,$4560c85f,$1206dee6,$df96d97c,$ee66fc53,$3a53ee71,$7b634c62,$4e602c61,$3459c759,
  $19e64138,$f90612d1,$f605e922,$41f60c0e,$07ed16db,$03e00418,$fe1ae217,$29010d1c,$fff1e905,$7d57e80d,
  $51297146,$605054ed,$bde95da1,$6da4bde7,$6cc24e54,$630e67c5,$78e04f65,$6ba56cab,$51ff5847,$2ebf545e,
  $7f0255de,$3471dfda,$455e4156,$7c45b979,$c95d5b5f,$555db46a,$4d5f4764,$f58c821d,$6556763d,$a4821fc6,
  $96cdd9a7,$609d50b1,$56d56050,$571a2744,$0a1ed9c8,$f1130d0a,$03130606,$3701fe0e,$0e280dcc,$41af5504,
  $da7f25e9,$58526bc0,$79cb7dab,$71ce65a6,$6b365e9d,$60c55f4d,$63b7663f,$1fca67bb,$1dfc8180,$a67a7f0b,
  $07592568,$daed6082,$59557ad2,$5f4b5f3b,$62465f49,$edc8673d,$ab4f5edc,$ce59a34f,$b11a6169,$fa4b014c,
  $11ed0bf2,$ecdd2c26,$30082c01,$f70d0222,$0ff426fb,$0124ed03,$1c0bff11,$080c5a9e,$11fb0205,$0a010504,
  $e6800704,$7a6588da,$e261455b,$4161ca68,$8329bc65,$2c6eb449,$418212fd,$06020d2c,$bc788210,$e922975c,
  $62dae01b,$425c764e,$dae14469,$5cab599b,$5dc55dcf,$68c85ccd,$99bd69cf,$62057a9e,$c34520c9,$0e03f6fc,
  $34fffff8,$21fdfc06,$fd110307,$0ffb20fe,$27d30f02,$ab820d05,$634f7cb7,$5fce6ac2,$605a64b8,$66bd5fcc,
  $614a5ec8,$206d51c1,$bcda7f04,$605e7f9e,$7fa88230,$fd1d4c7e,$b8e7b082,$6bbb59a2,$afff542c,$04130506,
  $0407090b,$8222e102,$060c3944,$fdff0c04,$f609fe0b,$83fffb17,$6cce7cff,$9cd354e4,$54cb55ec,$f7b93f61,
  $ea23e519,$e9fb16fa,$29e7202b,$fcebe80d,$21e01607,$eeff2ade,$9c5a0c28,$fb17ea17,$e415fb01,$73977d56,
  $313c90b3,$312f608b,$f0f1c875,$06f40901,$f6da1e09,$f739011c,$f523ffea,$0908f0fd,$042f0205,$110101e1,
  $0cf6fb09,$22f6feee,$25f1fd24,$07f006e8,$fe1e031a,$fbd12eff,$7f11f403,$cd7f79da,$d25ed861,$83253a61,
  $9879b976,$0912bef7,$66c05780,$5c4467cc,$62d363c4,$60535ac6,$11af3ec2,$14eafa43,$da7fc730,$62c864d4,
  $5c3e5853,$432e0a44,$db3603e2,$5b06e706,$cea72e7d,$386464ce,$6c45ea59,$162aba56,$2b55feb6,$e61d06d7,
  $52ce2409,$4c495d7d,$ab9a0fa9,$5793d04f,$d8a0681e,$be56bb6d,$f34fc368,$4159b86e,$6e555c5a,$0905dedb,
  $e164e082,$e362ac64,$0a7e4b64,$c563be5f,$2961da5e,$4863bf6f,$021fc160,$754bda7f,$5fcd6548,$5fc56538,
  $e04962d4,$9b8b8ada,$cb65c365,$ba3a8325,$e683092f,$8e020f98,$779c3949,$3e60030b,$445af254,$465fdc5c,
  $c25bc061,$c5625266,$c469bb5d,$3567b871,$dd5a475f,$657e05a1,$0c72822a,$ff820718,$9738da01,$5bd0672e,
  $673f5bca,$64b960d7,$7c277240,$5fe15713,$78a45dda,$43f742f7,$5d6b47f5,$45cb623f,$7f211c54,$1e6a9cda,
  $5651e768,$64ada566,$c962d5e2,$b06fc769,$3e64276e,$6aaef8d4,$6406ec0b,$fa54acab,$26829f15,$4ad023d7,
  $c12bbb04,$61ee1307,$0cd3f2dc,$53947d42,$58417c4e,$c9a59f48,$6da55fea,$586954b3,$6d897d0b,$5fbd7817,
  $fc4814e3,$1202ef22,$da7f10eb,$69ca5be8,$92474f52,$60e58e86,$74de5cbc,$92586cc9,$5f93bf0a,$b1acaeb5,
  $4be65cf9,$8aaea3de,$04705f05,$cf42c466,$e20df71b,$fd6eeaf0,$011ee413,$17da7ff4,$c76abb86,$b95db65f,
  $8b66b378,$0a284f77,$8616da7f,$e1d76afa,$1f9b31da,$dedfd86b,$3976dc04,$4798ee6b,$4662bc6b,$c3633b64,
  $68821720,$0b0aff18,$6d8209fd,$23b97a98,$0c08050a,$fc08ff0d,$9ebeda7f,$604a6c08,$7d3f6446,$6bc76637,
  $6ca7664a,$6f4a5523,$516c79be,$6bae6caa,$5e4c6111,$282a69e0,$4dda7f35,$b56d3688,$5b50bb68,$571d1f5f,
  $1ff6d130,$7f0735e0,$856fe47a,$f51c746d,$d21f12ab,$eef2260e,$35f3ea1c,$15f10bdf,$c0413f04,$dfed59eb,
  $4bc048e5,$e349177d,$da8b535b,$4a21a47a,$ee31ee28,$15f2ea1c,$ba0122ee,$ddae557d,$3a9d0a85,$0620b283,
  $be3fb341,$7d729a43,$d28e9215,$5fc85fe7,$ea97962f,$4e3a6145,$9230a175,$5f3064c6,$524c6a42,$54565b74,
  $56bd6c43,$6b2f60ed,$ae2f66b0,$6a8569ff,$66d0633b,$7ad16f34,$bb422e39,$31fbfb0c,$30fc12ec,$4cfd1ff4,
  $fcde33f0,$23160aea,$1311896c,$05e22b04,$fa0bf714,$0efb0c12,$0e06fd07,$050d0b03,$090204ff,$62454880,
  $61c96dcc,$61ca62bf,$5cd1624b,$64be6150,$603e67c3,$0fdadf57,$b3731750,$d6633a68,$d85e3a5d,$d8da01e7,
  $5273579e,$d5bf821f,$a7ae4d97,$64622d61,$3b0df0a4,$7db66a16,$6d477c93,$543a6faa,$59c6665a,$664765c6,
  $a2626452,$2ee47604,$b6bc9e80,$ff0dff30,$f78e8202,$c563ca76,$bd644767,$5355d15f,$5e80fb27,$604f5f4a,
  $5cbf6aad,$63c262d1,$67b16f3e,$61bb63b2,$63bd6db5,$6fbb64c6,$57c45ec0,$6bc05c49,$23d55e41,$4f5080f9,
  $4065ca5e,$485e555f,$58858220,$acaf775c,$c07d5fda,$c04f802a,$bc644a63,$031e8025,$862fda7f,$5fcc76fb,
  $5d3b723d,$6db56046,$66d26740,$6cc95842,$5ed45dbf,$28be6745,$85aa8206,$4962cb76,$ca634161,$13a2cf66,
  $1bb093eb,$515e6921,$d6595d5b,$e1623568,$2a64445a,$e162485f,$3771335d,$475fca69,$df6a3f69,$3b5dc75b,
  $4a62665f,$7a7f0a29,$79aa9f4b,$0f056382,$f505120c,$0b052502,$6197e883,$c2609ac1,$b269cb5c,$dae3406b,
  $7a709f9d,$674a61c8,$693e613e,$6745545e,$839addbf,$9a7ac790,$82383d6d,$0d121658,$e52dfcfb,$f3170501,
  $8a2a1a0e,$f941be49,$f30ff030,$02fb0109,$ee07fb2f,$07f1fe0f,$323ccefd,$e5030bf6,$280c1712,$7bffd203,
  $e00c07a0,$e9f62004,$f503042d,$0f12f418,$f1fb11f7,$05070810,$09070ff2,$09140d0e,$07f609f5,$fdffff0b,
  $0503040b,$0afa16fd,$3b9a7f06,$567cef9b,$6cbc65c3,$62fa5ab9,$5b4c61a3,$5c237650,$50c55b63,$493677d3,
  $6f5d5773,$68d15ab4,$96919736,$4e6c60c5,$62676827,$5bdc5d46,$6c4471af,$575e58be,$71d660aa,$61ba4adf,
  $63bb5a49,$f1831b6c,$b16f4073,$079fd25f,$daea754a,$7e7f8fae,$da832048,$a6385236,$601a6e00,$9080234a,
  $3873b7b8,$0a11fe01,$b7c58304,$fdff0a3c,$07030c09,$7f0208f5,$c58b71da,$ca61c07f,$c2624c5f,$da7f0624,
  $800698dc,$6e82233e,$fc173450,$060cfc0f,$0b2a6182,$9e3d6783,$5c55779c,$90dae946,$ee80ac51,$a761b464,
  $a6793c6a,$ba66e960,$da7f1c25,$8146968b,$abfe2a38,$01f7fd75,$02050f0e,$f51e02f6,$34bcff0f,$09050716,
  $020305fa,$04040ff8,$12f0ff08,$13070105,$aaa62881,$cc60d27d,$ff2c4c5d,$6cdc5c83,$43c301bd,$4e7d8d83,
  $db5a5862,$bc60f458,$069fe159,$38570a62,$1673a55f,$ff5cd036,$0fff1ce2,$eaf517f9,$6d01ecfc,$03f51015,
  $f96b8df4,$be39f203,$1fe92b02,$e3d81f4c,$33d5062f,$cf7d36b6,$546d514c,$d9e99d9f,$d9c4f5ac,$ac76119b,
  $421a3352,$dde714c1,$bc0a43e6,$6662947e,$79504565,$b66f2e5a,$cba7c458,$355de9fd,$3369c071,$43943f5b,
  $b05f588a,$9526c09c,$2471ea60,$056eb964,$9d4f0733,$1207db15,$ea15f139,$08080517,$09111df7,$0cfcf3f8,
  $0f16f81c,$55da7f0e,$ca86544e,$cf70c963,$c050c062,$416a3974,$8d661895,$4a64e848,$535e3361,$3860b471,
  $b86ab861,$69682c61,$aa61b865,$f915f1a1,$c14a585f,$c5682372,$06a7ba55,$bd59da6a,$326dec51,$da7f1021,
  $87ab96d6,$5fd357d8,$574279b5,$5c315f6e,$7f046b40,$5fcc5fc4,$5742624f,$67be6453,$64436246,$4bdf5ed5,
  $10bd3bc7,$eb1cfb15,$0c17eb09,$0112f20f,$5b738010,$b45c3a64,$3e63d164,$464def64,$c26ac062,$d360bb5b,
  $08fe4308,$05fd09fe,$0c665482,$83090509,$5752bd5f,$01021a01,$0b040d0a,$0ffcfa13,$0b110802,$02f4f71a,
  $f6fff134,$2402fd23,$0114f0f9,$092109f4,$081118f5,$230dfdf4,$e71502cc,$13fb31fd,$07fa35c7,$da7f1309,
  $8b2697ab,$6c2a6944,$5dbf614a,$683f624c,$62426634,$800c2148,$9f98aa8d,$091fe81a,$66445780,$820225c9,
  $28bac4b7,$da7f1ce8,$8cad621d,$6035693d,$5cd163bb,$71375fe2,$8209203d,$0316f5a0,$9f4e7a7f,$47ba8d13,
  $04065102,$29180e02,$0b15fcfc,$f00ff6fc,$04f4011f,$f6010c19,$0ff2011e,$04fbf323,$7980fd16,$5e4a6838,
  $70327c0a,$ac8224bc,$643f7e76,$6844613e,$6ac36537,$6146662b,$6c4767c2,$65d2583f,$633d67bb,$5e42643a,
  $63cc6cb1,$5e3d65be,$23bd5ecd,$006c8209,$0a040338,$0b230802,$979cf583,$346105b6,$4b61d660,$b55c5056,
  $041fce6d,$008057bf,$18f53bbc,$070a0602,$a8da7f07,$cf907296,$c95fc35d,$c66c455f,$02364360,$6248da7f,
  $67e690db,$6cbe6c46,$60ca60cb,$6c3f64c3,$645f5cbe,$1fca5dc3,$4f458206,$fa02092c,$2801f921,$e91815e1,
  $eef94dfc,$4de41b04,$4c050caa,$bf08fdfa,$32feea75,$ea4aeb26,$09f809eb,$2106fb17,$e8f21c04,$e701fc5a,
  $11011d25,$1aebf3fd,$361cf8f3,$04f0fffa,$0af52609,$110719ec,$020517f2,$da7f0cfc,$94709229,$4ec560c4,
  $9f4260e1,$20281302,$fe85800a,$3f674577,$dae5c45f,$95c36ff6,$1fc85fc9,$fd1c6982,$0106073f,$fc030a13,
  $ff02e52c,$fa0c0702,$02fd0b21,$830afd13,$d4453b68,$dae1be5e,$96dc894d,$65634470,$830b20c1,$0b16b6a3,
  $82090606,$7e298d43,$d78021d2,$6b52d2da,$cb63c597,$4b5cc45b,$cb604362,$4f5ebe65,$66800f20,$04dee850,
  $97f29f4f,$97f67adf,$75bd6cbf,$62d55eac,$2fbc6448,$5fc24380,$62416276,$71425fcd,$64456bc1,$5e4861c1,
  $65bc62c0,$61c06741,$5dca5e46,$243a6045,$080d0142,$fc230e01,$1cf9fb02,$5ec84880,$4eb666c8,$66cb68f6,
  $5dc25f3d,$1e4d5c56,$c7928208,$0343ff19,$800f040c,$80204945,$821e4862,$ca7bd5aa,$81224168,$d1630052,
  $405f4b5f,$5e6dc661,$82224d58,$0c0c3878,$090def0a,$ff110102,$590df002,$25ffffb8,$f90af5ff,$f80a02fa,
  $0aed2afa,$170ffdff,$1cf814eb,$020f0706,$61c47d6f,$6ba35fd8,$21fcb1c2,$723c574a,$5f6e5e91,$6a4163bf,
  $5fad62c0,$5f566c48,$6fca4263,$68c86249,$60bd5d3d,$6b33644b,$632e723a,$205c66c1,$bf805703,$fc15b8ae,
  $0f04080c,$9c7f03f2,$9ecc9761,$9fb09ece,$9cb262b7,$e4c04538,$76b7da01,$654b9f15,$60c765d1,$82011e4e,
  $0dfe2060,$071f04fb,$061e7f04,$69c7582f,$74649059,$719951dc,$00000014);

const
  ksc5601_data: array[0..2872-1] of Cardinal = (
  $057f2fff,$00b70b9e,$20262025,$300300a8,$201500ad,$ff3c2225,$2018223c,$3014d8c8,$d811d9c0,$efe500b1,
  $432260d8,$7f16b920,$3200b0fa,$7b3e0020,$ffe0d8e2,$42fce1c0,$20264026,$09b28422,$f15a050f,$00a7dc7f,
  $2606203b,$5fc3433f,$5f9b5fb9,$dfca5fd2,$fe219278,$137ac480,$01226a30,$18e023af,$03dc01f6,$01fb017b,
  $df3f7da7,$ffe2da01,$35c121d2,$b4dc7f03,$c7ff5e00,$bd625002,$b806dedf,$a102db00,$d000bf00,$23222e02,
  $a404dedf,$30210900,$bf25c120,$cab5ff9b,$fc1c801f,$2299da7f,$761b25c8,$821200c0,$be9a7790,$cd5ff69e,
  $00b6fae0,$ce002020,$1ec1601d,$6dd87f02,$02203c26,$7f0b1e7f,$16321c32,$2233c721,$d833c221,$ac212133,
  $7e00ae20,$01163632,$aa3affff,$5fe0055e,$31ffe31f,$705d3f31,$05d61121,$360fe027,$9f039107,$7607c110,
  $9f7f0808,$1607c110,$2500d806,$63c364c1,$5c4f63bc,$608563cf,$5e4761cb,$67b867cb,$5cce4acf,$691e63ce,
  $48496935,$5ebf643f,$283f5cbf,$2244c481,$0bc44862,$33951a36,$2113da03,$0feb3398,$e0334080,$4041e7cf,
  $01b94020,$f882df3f,$4080c771,$c0c7fac0,$26da07c8,$c033c021,$4a204044,$0101e8ef,$4080ce2c,$584259f0,
  $7fea2945,$c6d80f16,$7c0d4900,$7f0c627f,$97a0ccc2,$239689e5,$22de4a1e,$1b3f3260,$193f24d0,$0e1f2460,
  $00bd061e,$21542153,$00be00bc,$d805215b,$4fea00e6,$618224f6,$8c5bb60f,$fee4691f,$3200187f,$249c1b3f,
  $7fbf197f,$b9d80e1f,$d8e03900,$e0ca2074,$1f304125,$0e0b7652,$36551f7f,$c9041008,$191fea2c,$dbcb0f16,
  $06191fd2,$28ac0098,$ade84082,$b98fb801,$0b1a4640,$141b7182,$5d98a880,$fbb00804,$388e8138,$30398f89,
  $60c87e80,$4a812048,$38d89409,$71b98d9e,$8203091b,$487b5070,$02091b71,$88a88009,$414844b8,$010c1a45,
  $80091307,$c8798fb8,$8029c361,$543e88a8,$a8802dc6,$07145d98,$c158d9b4,$8138fba2,$80301e8e,$8138fb90,
  $214b7a8e,$0b1b7182,$1c030501,$79821880,$30604148,$0107010c,$5b820714,$801c3347,$48468238,$010c3d41,
  $475a4682,$0b075b7a,$8218801c,$19484449,$8238801f,$905e9987,$00598d80,$b98fb805,$275a4640,$9b848023,
  $684144b8,$41475a40,$507b5070,$80181b50,$48698238,$0c1b4061,$7b820424,$38800908,$46498209,$31487852,
  $821c0814,$820b075b,$50734770,$41486843,$80141b4b,$99d8d9b8,$3042415c,$fba0c044,$3bc64138,$8c849081,
  $8fb86559,$041e40b9,$0407010c,$98a88018,$7e154d40,$5f8229d3,$1c09087b,$b98fb880,$15081431,$09040407,
  $7b5e4982,$69425074,$801c3148,$48788228,$7b506840,$50454048,$3f00487b,$41823880,$40684144,$3041475a,
  $78802414,$69c7634c,$803421db,$e27c8eb8,$7b82042d,$28802318,$09087882,$0b075b82,$49475b82,$045fba86,
  $38fba00c,$ce7a8e81,$b8802320,$4540b98f,$71487b50,$40487b50,$09020d1e,$47823880,$1b111e49,$487b5f82,
  $02091b71,$7b507182,$08143148,$8238801c,$7b507157,$7b507148,$1e024148,$80083880,$813a8e94,$06145d88,
  $80398fb8,$314c7e8d,$69823880,$50444148,$4640487b,$50800b1a,$04802dc4,$49454b82,$2301101e,$02090404,
  $091b7182,$90810902,$1d398d80,$60c87c80,$21c36dc8,$175b8214,$175b8209,$98a88025,$0065045d,$d45c8882,
  $0138fba2,$26424b80,$98a88027,$38d8943d,$40b98f8a,$80091a46,$183b8001,$b8fb9080,$08101e49,$5a478214,
  $18040b07,$b888a880,$39434945,$801c080c,$82234c78,$5071575b,$8025087b,$8538d9b8,$8d9e38c8,$504540b9,
  $0640487b,$2880280f,$30427882,$0f010715,$31404480,$7b8fb880,$23546dfe,$19afb880,$8207155b,$8027075b,
  $99878238,$8d80845e,$8fb8b059,$5a4640b9,$bb5e4947,$848058ec,$4c40b98c,$40487b50,$41475a46,$070d1b70,
  $3d9b9080,$1ab8ab94,$7b5e820d,$087b5f42,$8fb88009,$425071b9,$08494947,$b8800814,$8fb83ecf,$577071b9,
  $46435071,$a8802309,$9c9438e8,$ba8fb138,$475a4068,$80231c02,$50698238,$18341b70,$48822880,$10107345,
  $82081408,$1c0b075b,$47823880,$1c081433,$46822d04,$0b00615a,$0c080404,$87823880,$81085e99,$84c1588c,
  $e8843fba,$398cae38,$487c801d,$80488125,$1500588d,$94800838,$c89d388e,$bc030058,$58f8d98f,$c994090e,
  $41475ab8,$820c1070,$475a464a,$475a4649,$405a4649,$5a464945,$5a464247,$7b507347,$7b507148,$9a444948,
  $0005589d,$091afbb0,$5c88b880,$90617010,$8d80398d,$40487bba,$74794a46,$3880141b,$41486982,$49475a45,
  $30507b5e,$d9b8801c,$b8b88538,$02020930,$82011407,$71487b5e,$80071110,$543d88b8,$2dc769c6,$798fb880,
  $63c361c8,$5a82204b,$80230947,$145d98a8,$51821812,$50704144,$1e40487b,$38802311,$30414782,$24140715,
  $47823880,$0c306149,$82081408,$8220075b,$33475a46,$1c230114,$0203101c,$8fb88023,$4a4060bb,$68404879,
  $40487b50,$2327495e,$b98fb880,$475a4640,$08101e49,$80071104,$71b98fb8,$04230d1b,$31487b82,$b8800c10,
  $1431b98f,$04180408,$71487b82,$5a46675b,$80230947,$943e88a8,$487bba8e,$487b5071,$23140640,$38f8a880,
  $7bba8e81,$475b7148,$801c3041,$71b98fb8,$15347b50,$1c140807,$b98fb880,$070d1b71,$5a468215,$3b5e4947,
  $8fb8800c,$8220627b,$4649475a,$4048705a,$41475a46,$80231530,$48698238,$475a4640,$08101e49,$b8801804,
  $1961b98f,$0f041c18,$801c0702,$31b98fb8,$801c0814,$5ebb8fb8,$4250747b,$82090869,$800b075b,$94800838,
  $8d9d388e,$8fb8b059,$370640b9,$47823880,$7b507041,$475b7148,$02093e42,$8fb88009,$231531b9,$04041804,
  $80090209,$543d98a8,$82232a46,$0409175b,$5e4a7b82,$8025087b,$71b98fb8,$49426350,$41475a46,$80231530,
  $49b8d9b8,$49475a46,$41475a46,$0b091b70,$80053880,$383ab992,$1071820b,$8007020f,$8220c878,$02091b71,
  $acb88009,$675b71ba,$820d1a46,$49475a46,$71575a46,$5e888150,$bb8fbed4,$c9475a46,$3df85e16,$1b4e354f,
  $5d3ba6ab,$fe7f7028,$c1560904,$875bb65a,$78032e66,$4c0afee3,$c273c26b,$db7a3c75,$57830482,$36888888,
  $068cc88a,$feeeacaf,$3b99d51a,$04537452,$64606a54,$cf6bbc61,$ba811a73,$a389d289,$0a4f8395,$7858be52,
  $7259e659,$c75e795e,$4663c061,$7f67ec67,$4e6f9768,$2fa6bc76,$ff1dfef1,$9d7c217a,$71826e80,$938aeb82,
  $9d4e6b95,$3466f755,$ed78a36e,$10845b7a,$a8874e89,$4e52d897,$4c582a57,$be611f5d,$62622161,$4467d165,
  $186e1b6a,$ccbe9a75,$3a0ffeec,$5190af7d,$95945294,$ac53239f,$db75325c,$98924080,$08525b95,$a159dc58,
  $2e7e755c,$fe7f1028,$5f617705,$86757a6c,$927ce075,$fefda8f6,$21815409,$41859182,$fc8b1b89,$47964d92,
  $2b4ecb9c,$dafe5c4e,$6137584f,$18fef4c6,$69ea6539,$75a56f11,$76d67686,$82a57b87,$f90084cb,$958b93a7,
  $5ba25580,$f9015751,$7fb97cb3,$502891b5,$5c4553bb,$62d25de8,$e0cdae9b,$6e2045fe,$795b70ac,$8e1e8ddd,
  $907df902,$92f89245,$4ef64e7e,$5dfe5065,$61065efa,$81716957,$8e478654,$9a2b9375,$50914e5e,$68406770,
  $528d5109,$6aa25292,$921077bc,$52ab9ed4,$8ff2602f,$61a95048,$64ca63ed,$6a84683c,$81886fc0,$969489a1,
  $727d5805,$750472ac,$7e6d7d79,$898b80a9,$90638b74,$62899d51,$6f546c7a,$7f3a7d50,$517c8a23,$7b9d614a,
  $92578b19,$4eac938c,$a9f92b26,$e0beea47,$537f04fe,$58835770,$92f65e9a,$cef8e35f,$bc0a9d64,$de7f3924,
  $87689705,$f170856d,$45749f70,$75d9faf2,$ca7f786c,$277ee16f,$7d937d45,$803f8015,$8396811b,$8f158b66,
  $93e19015,$98389803,$9be89a5a,$55534fc2,$5951583a,$5c465b63,$621260b8,$68b06842,$6eaa68e8,$7678754c,
  $7a3d78ce,$7e6b7cfb,$8a087e7c,$8c3f8aa1,$9dc4968e,$610553e4,$07de7f27,$59d156fa,$5c3b5b64,$62f75eab,
  $f64d6537,$66a009fe,$69c167af,$75fc6cbd,$777e7690,$7f947a3f,$aeda766e,$ef285b56,$85c120fe,$88b48831,
  $f9038aa5,$932e8f9c,$986796c7,$9f139ad8,$659b54ed,$688f66f2,$8c377a40,$56f09d60,$5d115764,$68b16606,
  $6efe68cd,$889e7428,$6c689be4,$9aa8f904,$13d04f9b,$69def2d8,$5de55b54,$606d6050,$63a762f1,$73d9653b,
  $86a37a7a,$978f8ca2,$5be14e32,$679c6208,$79d174dc,$8a8783d3,$8de88ab2,$934b904e,$5ed39846,$85ff69e8,
  $f90590ed,$5b9851a0,$61635bec,$6b3e68fa,$742f704c,$7ba174d8,$83c57f50,$8cab89c0,$992895dc,$605d522e,
  $900262ec,$51494f8a,$58d95321,$66e05ee3,$709a6d38,$73d672c2,$80f17b50,$5366945b,$7f6b639b,$50804e56,
  $58de584a,$6127602a,$69d062d0,$5b8f9b41,$80b17d18,$4ea48f5f,$54ac50d1,$5b0c55ac,$5de75da0,$654e652a,
  $6a4b6821,$768e72e1,$7d5e77ef,$81a07ff9,$86df854e,$8f4e8f03,$990390ca,$9bab9a55,$abec4e18,$b85ca669,
  $2a290786,$16a87e02,$7f2d360e,$5bc707fe,$5ed05d87,$62d861fc,$67b86551,$384f8630,$7f562676,$6e9d0afe,
  $72d77078,$74037396,$77e977bf,$7d7f7a76,$23f28009,$dffce048,$33886282,$0f0fc88b,$1eca9fb5,$d282fee5,
  $e99a4599,$9c9dd79c,$40570b9f,$a083ca5c,$b497ab97,$98541b9e,$d97fa47a,$e18ecd88,$48580090,$9f63985c,
  $135bae7a,$ae7a795f,$ac828e7a,$3850268e,$7752f852,$f3570853,$0a637262,$376dc36b,$5753a577,$76856873,
  $3a95d58e,$706ac367,$cc8a6d6f,$06994b8e,$786677f9,$3c8cb46b,$ebf9079b,$4e572d53,$fb63c659,$4573ea69,
  $c57aba78,$757cfe7a,$73898f84,$a890358d,$4752fb95,$60754757,$1e83cc7b,$58f90892,$4b514b6a,$1f528752,
  $7568d862,$c5969969,$e452a450,$a461c352,$ff683965,$4b747e69,$eb82b97b,$3989b283,$498fd18b,$caf90999,
  $d259974e,$8e661164,$8174346a,$a979bd79,$7f887e82,$0a895f88,$0b9326f9,$2553ca4f,$72627160,$667d1a6c,
  $624e987d,$af77dc51,$0e4f0180,$8051764f,$8b55dc51,$01abeb4a,$4c232c5e,$5bc4f87f,$ee29f6cb,$5e7e04fe,
  $62805fcc,$ea0b65d7,$b23ea00c,$6b9a9f9d,$1259ae8b,$98f8f448,$780e8d73,$6b5220a5,$788178e0,$0106526e,
  $95f87f32,$dae76a7b,$e89a7dbc,$8a18f8e5,$f2ebe336,$249321fc,$6e98e293,$56200af2,$92111e7f,$767dca9e,
  $ee54094f,$d1685462,$3a55ab91,$0cf90b51,$e65a1cf9,$cff90d61,$0e62ff62,$90a349f9,$fe47f914,$05f9198a,
  $6696111e,$7156f91d,$f91ff91e,$f92096e3,$637a634f,$f9215357,$6960678f,$f9226e73,$f9237537,$0d071e03,
  $27f9267d,$ca8872f9,$285a1856,$171e07f9,$f92d4e43,$59485167,$801067f0,$5973f92e,$649a5e74,$5ff579ca,
  $62c8606c,$5be7637b,$52aa5bd7,$5974f92f,$60125f29,$5943f930,$49f93374,$f93999d1,$c30d1e13,$45f9446f,
  $b281bff9,$4660f18f,$66f947f9,$49f94881,$4a5c3ff9,$051e0df9,$8a255ae9,$7d10677b,$fe09f952,$5880fd28,
  $3cf959f9,$3f6ce55c,$1a6eba53,$39833659,$464eb64e,$1855ae4f,$5658c757,$e665b75f,$b56a8065,$ed6e4d6b,
  $1e7aef77,$cb7dde7c,$32889286,$bb935b91,$7a6fbe64,$5475b873,$4d555690,$d461ba57,$e166c764,$bc46796d,
  $f01dfee4,$bd804375,$83854181,$5a8ac789,$93931f8b,$5475536c,$5d8e0f7b,$02551090,$62585858,$9e62075e,
  $7668e064,$b37cd675,$e39ee887,$6e57884e,$0d592757,$ee12a35c,$3412fef4,$b364e162,$8b81fa73,$8a8cb888,
  $859edb96,$b35fb75b,$00501260,$16523052,$57583557,$515c0e58,$1aa94a56,$fef29baf,$89631107,$43641763,
  $c268f968,$486dd86a,$fef0faca,$dc71fe08,$b1777976,$047a3b79,$ed89a984,$a953058c,$feff507b,$4d90fd1c,
  $dc967693,$066bd297,$a2725870,$63736872,$e479bf77,$807e9b7b,$c758a98b,$fd656660,$8c66be65,$c9711e6c,
  $138c5a71,$814e6d98,$ac4edd7a,$6c1e2051,$a761fef3,$50677161,$1e68df68,$bc6f7c6d,$e577b375,$6380f47a,
  $5c928584,$5c659751,$d8679367,$737ac775,$46f95a83,$2d90178c,$c05c6f98,$41829a81,$0d906f90,$9d5f9792,
  $c86a595d,$49767b71,$0485e47b,$3091278b,$f655879a,$69f95b61,$3f7f8576,$f887ba86,$5c908f88,$d96d1bf9,
  $6173de70,$5d843d7d,$f1916af9,$82f95e99,$0453754e,$3e6b126b,$2d721b70,$4c9e1e86,$508fa352,$2c64e55d,
  $eb6b1665,$9c7c436f,$6485cd7e,$c989bd89,$1f81d862,$175eca88,$fc6d6a67,$6f740572,$de878274,$0d4f8690,
  $0a5fa05d,$a051b784,$ae756563,$fd8b574e,$6881dce5,$7cae6a11,$05fefac2,$8ad2826f,$91cf8f1b,$f7804fb6,
  $6adef4ce,$616e5eec,$65c5623e,$6ffe6ada,$85dc792a,$95ad8823,$9a6a9a62,$9ece9e97,$66c6529b,$701d6b77,
  $8f62792b,$61909742,$65236200,$71496f23,$7df47489,$84ee806f,$90238f26,$51bd934a,$52a35217,$70c86d0c,
  $5ec988c2,$6bae6582,$7c3e6fc2,$4ee47375,$56f94f36,$5cbaf95f,$601c5dba,$7b2d73b2,$7fce7f9a,$901e8046,
  $96f69234,$98189748,$4f8b9f61,$79ae6fa7,$96b791b4,$f96052de,$64c46488,$6f5e6ad3,$72107018,$800176e7,
  $865c8606,$8f058def,$9b6f9732,$9e759dfa,$797f788c,$83c97da0,$9e7f9304,$8ad69e93,$5f0458df,$70276727,
  $7c6074cf,$5121807e,$72627028,$8cc278ca,$23feecd7,$4e8696f7,$5bee50da,$65995ed6,$764271ce,$804a77ad,
  $907c84fc,$9f8d9b27,$5a4158d8,$6a135c62,$6f0f6dda,$7d2f763b,$851e7e37,$93e48938,$5289964b,$67f365d2,
  $6d4169b4,$700f6e9c,$e2567409,$1cfeecab,$8b2c786b,$516d985e,$9678622e,$502b4f96,$6dea5d19,$8f2a7db8,
  $61445f8b,$f9616817,$52d29686,$51dc808b,$695e51cc,$7dbe7a1c,$967583f1,$52294fda,$efe9db6e,$5c6506fe,
  $674e60a7,$6d6c68a8,$36767281,$53fee7cc,$75e2f962,$7f797c6c,$83897fb8,$88e188cf,$91d091cc,$9bc996e2,
  $6f7e541d,$749871d0,$8eaa85fa,$9c5796a3,$67979e9f,$74336dcb,$971681e8,$7acb782c,$7c927b20,$746a6469,
  $78bc75f2,$99ac78e8,$9ebb9b54,$5e555bde,$819c6f20,$908883ab,$534d4e07,$5dd25a29,$61625f4e,$6669633d,
  $6eff66fc,$70636f2b,$842c779e,$883b8513,$99458f13,$551c9c3b,$672b62b9,$83096cab,$977a896a,$59844ea1,
  $5fd95fd8,$7db2671b,$82927f54,$83bd832b,$90998f1e,$63ed57cb,$67def3db,$679a6627,$6bcf6885,$7f757164,
  $8ce38cb7,$9b459081,$8c8a8108,$9a40964c,$5b5f9ea5,$731b6c13,$76df76f2,$51aa840c,$514d8993,$52c95195,
  $6c9468c9,$77207704,$7dec7dbf,$9eb59762,$85116ec5,$540d51a5,$660e547d,$6927669d,$76bf6e9f,$83177791,
  $879f84c2,$92989169,$88829cf4,$51924fae,$59c652df,$61555e3d,$64796478,$67d066ae,$6bcd6a21,$725f6bdb,
  $74417261,$77db7738,$82bc8017,$8b008305,$8c8c8b28,$6c906728,$76ee7267,$7a467766,$6b7f9da9,$59226c92,
  $84996726,$5893536f,$5edf5999,$663463cf,$6e3a6773,$7ad7732b,$932882d7,$5deb52d9,$bf5c61ae,$f34f8ebc,
  $69595afe,$6bcb6b66,$73f77121,$7e46755d,$8302821e,$8aa3856a,$97278cbf,$58a89d61,$50119ed8,$543b520e,
  $6587554f,$7d0a6c76,$805e7d0b,$9580868a,$52ff96ef,$72696c95,$5a9a5473,$5d4b5c3e,$5fae5f4c,$68b6672a,
  $6e3c6963,$77096e44,$7f8e7c73,$8b0e8587,$97618ff7,$5cb79ef4,$610d60b6,$654f61ab,$65fc65fb,$6cef6c11,
  $73c9739f,$95947de1,$871c5bc6,$525d8b10,$62cd535a,$64b2640f,$6a386734,$73c06cca,$7b94749e,$7e1b7c95,
  $8236818a,$8feb8584,$99c196f9,$534a4f34,$53db53cd,$4f5f62cc,$04fee90b,$6cee69c3,$73ed6f58,$ac1b3766,
  $22af4e17,$1afe7f31,$822c7d46,$8fd487e0,$98ef9812,$62d452c3,$6e2464a5,$767c6f51,$91b18dcb,$9aee9262,
  $50239b43,$574a508d,$5c2859a8,$5f775e47,$653e623f,$e4781e7a,$678b06fe,$6ec2699c,$7d2178c5,$aad580aa,
  $15dee87a,$868c84a1,$8b178a2a,$963290a6,$500d9f90,$f9634ff3,$5f9857f9,$639262dc,$6e43676f,$76c37119,
  $80da80cc,$f1c088f4,$8ce041fe,$914d8f29,$4f2f966a,$5e1b4f70,$682267cf,$767e767d,$5e619b44,$71696a0a,
  $756a71d4,$7e41f964,$85e98543,$4f1098dc,$7f707b4f,$51e195a5,$68b55e06,$6c4e6c3e,$72af6cdb,$83037bc4,
  $743a6cd5,$528850fb,$64d858c1,$74a76a97,$78a77656,$95e28617,$f9659739,$5f01535e,$8fa88b8a,$908a8faf,
  $77a55225,$9f089c49,$50024e19,$5c5b5175,$661e5e77,$f00e261b,$70b30efe,$75c57501,$7add79c9,$99208f27,
  $4fdd9a08,$58315821,$666e5bf6,$a3ab6b65,$2bfef02d,$752b73e4,$88dc83e9,$8b5c8913,$4f0f8f14,$531050d5,
  $5b93535c,$670d5fa9,$8179798f,$8514832f,$89868907,$8f3b8f39,$9c1299a5,$4e76672c,$59494ff8,$5cef5c01,
  $63675cf0,$70fd68d2,$742b71a2,$84ec7e2b,$90228702,$9cf392d2,$5aca4e0d,$63d0a95c,$7f6a3b68,$4a57e0f8,
  $1b2f3ceb,$0c7e7f57,$f9665e9c,$65776276,$6d6e65a7,$72366ea5,$7c3f7b26,$81507f36,$a57e4901,$7af0f962,
  $8ca08a03,$46791546,$e828de7f,$1c91dc90,$d9964496,$179ce799,$29520653,$b3567454,$6e595458,$a45fff59,
  $10626e61,$1a6c7e66,$8976c671,$1b7cde7c,$c182ac7d,$6796f08c,$174f5bf9,$c25f7f5f,$0b5d2962,$7c68da67,
  $6c7e4378,$994e159d,$54531550,$8304fef3,$875a6259,$d760b25e,$1ee2fafa,$87659005,$d469a767,$036bd66b,
  $6cb805fe,$7435f968,$781275fa,$e02d0e7e,$cb7c83fc,$c37fe17d,$fae83a62,$871a83f2,$eb2f43cd,$8cbb18de,
  $975e9119,$9f3b98db,$5b2a56ac,$658c5f6c,$6baf6ab3,$6ff16d5c,$725d7015,$8ca773ad,$983b8cd3,$6c376191,
  $9a018058,$a7fd4e4d,$a0199239,$f1f97e42,$0553f2f8,$faedcc36,$58eb56db,$7d9aba76,$dfeea4ce,$08fef6d8,
  $6368601d,$65af659c,$67fb67f6,$6b7b68ad,$f4b8f71d,$457009fc,$3b780273,$6121f807,$e904fe7f,$727d177b,
  $8680867d,$faf42e03,$88df86c7,$ebe83770,$8cdc30fe,$8fad8d66,$98fc90aa,$9e9d99df,$f969524a,$f96a6714,
  $522a5098,$65635c71,$73ca6c55,$759d7523,$849c7b97,$97309178,$64924e77,$715e6bba,$4e0985a9,$6749f96b,
  $6e1768ee,$8518829f,$63f7886b,$92126f81,$4e0a98af,$50cf50b7,$5546511f,$561755aa,$1ad85b40,$1652357b,
  $0cfe7f22,$685160f3,$6e586a61,$7240723d,$76f872c0,$7bb17965,$88f37fd4,$fed9fb00,$8cde12fe,$585e971c,
  $8cfd74bd,$f96c55c7,$7d227a61,$72728272,$7525751f,$7b19f96d,$58fb5885,$9ad25dbc,$55faed98,$ec629260,
  $47b43f36,$fef1d87a,$8068f204,$6e745e72,$b99fff7b,$e524fef9,$af821280,$93897f85,$e4901d8a,$209ecd92,
  $6d59159f,$dc5e2d59,$73661460,$50679066,$5f6dc56c,$a977f36f,$cb84c678,$d9932b91,$4850ca4e,$0b558451,
  $475ba35b,$cb657e62,$7d6e3265,$42740171,$fce3790a,$79aa766c,$4a7a7dda,$7f393d1d,$823942fe,$87ec861a,
  $8de38a75,$92919078,$994d9425,$53689bae,$69545c51,$6d296cc4,$820c6e2b,$893b859b,$8aaa8a2d,$9f6796ea,
  $66b95261,$7e966bb2,$8d0d87fe,$965d9583,$6d89651d,$f96e71ee,$59d357ce,$60275bac,$621060fa,$665f661f,
  $73f97329,$770176db,$80567b6c,$81658072,$91928aa0,$52e24e16,$6d176b72,$7b397a05,$f96f7d30,$53ec8cb0,
  $5851562f,$06595bb5,$06fefd08,$63836240,$662d6414,$6cbc68b3,$f6fc9acb,$d270a4fc,$68752671,$f8e8a7fe,
  $2ace7b11,$7f192f49,$852c2cfe,$8607856d,$900d8a34,$90b59061,$97f692b7,$4fd79a37,$675f5c6c,$7c9f6d91,
  $8b167e8c,$901f8d16,$5dfd5b6b,$84c0640d,$98e1905c,$5b8b7387,$677e609a,$8a1f6dde,$90018aa6,$5237980c,
  $7051f970,$9396788e,$91d78870,$53d74fee,$9edc55fd,$17c4b7aa,$7f15322b,$015e25fa,$c8f70b61,$1c6693b3,
  $6a39f8e4,$ee4aa750,$e76f31fa,$ea3b0171,$adceaaa8,$79c0f8f3,$bcea4a96,$eb4872d5,$297f9efc,$5e833181,
  $fef0f927,$b0889605,$388b908a,$4090428f,$23329ba2,$968bd87f,$b4ed605b,$33ce3707,$0dfe7f47,$587e53d4,
  $5b705919,$6dd15bbf,$719f6f5a,$74b97421,$83fd8085,$8ba55de1,$ecfae978,$5c681265,$fef35b8f,$f36d3508,
  $fe73e36d,$4d77ac76,$237d147b,$3c8ef881,$fe7f6f3b,$c48a6223,$1e91878a,$b4980693,$53620c99,$658ff088,
  $275d0792,$5f5d695d,$68819d74,$fe6fd587,$367fd262,$1e897289,$e74e584e,$4752dd50,$07627f53,$057e6966,
  $8d965e88,$3653194f,$d859cb56,$ffa15e4e,$faf0eed1,$65bd6043,$37b84a71,$08fe7f36,$77e2731c,$7fc5793a,
  $84cd8494,$8a668996,$3739de02,$a1fe7f25,$5bd457f4,$606f5f0f,$690d62ed,$6e5c6b96,$7bd27184,$8b588755,
  $98df8efe,$4f3898fe,$4fe14f81,$5a20547b,$613c5bb8,$666865b0,$753371fc,$7d33795e,$81e3814e,$85aa8398,
  $870385ce,$8eab8a0a,$f9718f9b,$59318fc5,$5be65ba4,$5be96089,$5fc35c0b,$f9726c81,$700b6df1,$82af751a,
  $4ec08af6,$f9735341,$6c0f96d9,$4fc44e9e,$555e5152,$5ce85a25,$72596211,$83aa82bd,$885986fe,$963f8a1d,
  $991396c5,$9d5d9d09,$5cb3580a,$5e445dbd,$611560e1,$6a0263e1,$91026e25,$984e9354,$9f779c10,$5cb85b89,
  $664f6309,$773c6848,$978d96c1,$9b9f9854,$8b0165a1,$95bc8ecb,$5ca95535,$5eb55dd6,$764c6697,$95c783f4,
  $62bc58d3,$9d2872ce,$592e4ef0,$663b600f,$79e76b83,$53939d26,$57c354c0,$611b5d16,$6daf66d6,$827e788d,
  $97449698,$627c5384,$6db26396,$814b7e0a,$6afb984d,$9daf7f4c,$4e5f9e1a,$51b6503b,$60f9591c,$693063f6,
  $8036723a,$91cef974,$f9755f31,$7d04f976,$2f8982e5,$09fef299,$f9778e8d,$f9784f6f,$58e4f979,$60595b43,
  $533d63da,$371ef2a9,$694af97a,$6d0b6a23,$716c7001,$760d75d2,$7a7079b3,$7f8af97b,$8944f97c,$8b93f97d,
  $967d91c0,$990af97e,$5fa15704,$6f0165bc,$79a67600,$99ad8a9e,$9f6c9b5a,$61b65104,$6a8d6291,$504381c6,
  $5f665830,$8a007109,$5b7c8afa,$4ffa8616,$56b4513c,$63a95944,$5daa6df9,$5186696d,$4f594e88,$1e03f97f,
  $82598211,$5ff983f9,$846c5d6b,$1674b5f9,$07f98579,$39824582,$5d8f3f83,$18f9868f,$03f98799,$4ea60efe,
  $57dff98a,$66135f79,$f98cf98b,$7e7975ab,$f98d8b6f,$9a5b9006,$438156a5,$0afee26f,$f98e5bb4,$f98f5ef6,
  $6350f990,$f991633b,$6c87693d,$204b3a37,$141e7f62,$f9926f14,$713670df,$f9937159,$71d571c3,$784ff994,
  $f995786f,$7de37b75,$7e2ff996,$884df997,$f9988edf,$5b041e03,$f6f99b92,$03f99c9c,$6085091e,$f99f6d85,
  $f9a071b1,$95b1f9a1,$f9a253ad,$d31cfe03,$8ef9a567,$30713070,$d2827674,$bbf9a682,$7d9ae595,$a766c49e,
  $4971c1f9,$a9f9a884,$aa584bf9,$b8f9abf9,$ac5f715d,$8e6620f9,$ae697966,$ba6c3869,$98b0ad0a,$20a13902,
  $fef90a3b,$5bf9ad22,$d4f9ae74,$4e76c874,$af7e937a,$f1f9b0f9,$ce8a6082,$48f9b18f,$19f9b293,$b4f9b397,
  $2a4e42f9,$08f9b550,$f353e152,$ca6c6d66,$7f730a6f,$ae7a6277,$0285dd82,$d4f9b686,$dc678e88,$b706feee,
  $b892b3f9,$109713f9,$784e9498,$f8ee8aee,$d6f55348,$62f8fa67,$3ab25758,$e40afeeb,$b9609f5b,$5661caf9,
  $6465ff65,$5a68a766,$1b6fb36c,$fefa5b73,$087b7d48,$328aa487,$4b9f079c,$446c835c,$3a738973,$656eab92,
  $69761f74,$0a7e157a,$c5514086,$ee64c158,$70751574,$957fc176,$5496cd90,$e66e2699,$aa7aa974,$d981e57a,
  $1b877886,$8c5a498a,$a15b9b5b,$63690068,$1373a96d,$97742c74,$eb7de978,$5581187f,$4c839e81,$11962e8c,
  $8066f098,$8965fa5f,$8b6c6a67,$03502d73,$ee6b6a5a,$6c591677,$255dcd5d,$ba754f73,$e5f9bbf9,$2f51f950,
  $39a2fd58,$e505fee4,$bdf9bc5b,$d75da2f9,$a9f33e62,$be0bfee6,$bf66dcf9,$c06a48f9,$6471fff9,$88f9c174,
  $477aaf7a,$fe86167e,$c20ffef6,$8187eff9,$598b2089,$80f9c390,$7e995290,$746b3261,$257e1f6d,$d18fb189,
  $fba6db4f,$c715fef2,$b9588957,$425eb85b,$8c699561,$b66e676d,$6271946e,$2c752874,$38807375,$0a84c983,
  $de93948e,$8ef9c493,$3c92c24e,$53c8d8eb,$13fef3c2,$5bd35b87,$611a5c24,$65f46182,$7397725b,$76c27440,
  $79917950,$7d0679b9,$828b7fbd,$865e85d5,$b6848fc2,$2bfeef4a,$96e89685,$52d696e9,$65ed5f67,$682f6631,
  $7a36715c,$980a90c1,$f9c54e91,$6b9e6a52,$71896f90,$82b88018,$904b8553,$96f29695,$851a97fb,$4e909b31,
  $96c4718a,$539f5143,$571354e1,$57a35712,$5ac45a9b,$60285bc3,$63f4613f,$e2b36c85,$21fee1dc,$733f7230,
  $82d17457,$8f458881,$f9c69060,$98589662,$67089d1b,$925e8d8a,$50494f4d,$537150de,$59d4570d,$5c095a01,
  $66906170,$72326e2d,$7def744b,$840e80c3,$853f8466,$f2fb875f,$04fefe9a,$97cb9055,$4e739b4f,$e57e031d,
  $f9c706fe,$55a9552f,$5ba55b7a,$02005e7c,$f47e7e19,$c41cfe01,$09653863,$d4f9c867,$c967da67,$626961f9,
  $276cb969,$38f9ca6d,$e1f9cb6e,$3773366f,$5cf9cc73,$cd753174,$ce7652f9,$adf9cff9,$3881fe7d,$c288d584,
  $dce1190b,$8e428e30,$bdb4904a,$fa49fece,$f9d0161e,$5809f9d1,$6bd3f9d2,$80b28089,$f9d4f9d3,$596b5141,
  $f9d55c39,$6f64f9d6,$80e473a7,$f9d78d07,$958f9217,$fe05f9d8,$0e807f37,$68701c62,$dc878d7d,$6957a0f9,
  $b7614760,$808abe6b,$5996b192,$eb541f4e,$70852d6d,$ee97f396,$e363d698,$dd90916c,$ba61c951,$9d9df981,
  $00501a4f,$0f5b9c51,$ec61ff61,$c5690564,$e375916b,$647fa977,$fb858f82,$bc886387,$ab8b708a,$e54e8c91,
  $dd4f0a4e,$37f9def9,$df59e859,$285df2f9,$18ec58ff,$de05f9e0,$e5723e1b,$70f9e473,$e575cd75,$e679fbf9,
  $33800cf9,$e1808480,$e7835182,$bdf9e8f9,$878cb38c,$eaf9e990,$0c98f4f9,$ecf9eb99,$ca7037f9,$c17fca76,
  $1a301ef7,$c14eba8b,$7052034e,$bdf9ed53,$fb56e054,$155bc559,$6e5fcd5f,$eff9ee6e,$357d6af9,$93f9f083,
  $f18a8d86,$77976df9,$f3f9f297,$5a4e00f9,$f94f7e4f,$a265e558,$b090386e,$fb99b993,$8a58ec4e,$4159d959,
  $f5f9f460,$f67a14f9,$c3834ff9,$4451658c,$03f9f753,$4ecd08fe,$5b555269,$4ed482bf,$54a8523a,$423559c9,
  $7f05206d,$60630bfe,$6ecb6148,$716e7099,$74f77386,$78c175b5,$80057d2b,$feecf7e4,$85c921fe,$8cc78aee,
  $4f5c96cc,$56bc52fa,$662865ab,$70b8707c,$7dbd7235,$914c828d,$9d7296c0,$68e75b71,$6f7a6b98,$5c9176de,
  $6f5b66ab,$7c2a7bb4,$96dc8836,$4ed74e08,$58345320,$e7c8ce86,$5c0712fe,$5e845e33,$638c5f35,$675666b2,
  $6aa36a1f,$6f3f6b0c,$f9fa7246,$748b7350,$7ca77ae0,$1e668178,$dae1ba28,$7f3b270a,$88dd2cfe,$91ac8d13,
  $969c9577,$54c9518d,$5bb05728,$6750624d,$6893683d,$6ed36e3d,$7e21707d,$8ca188c1,$9f4b8f09,$722d9f4e,
  $8acd7b8f,$4f47931a,$51324f4e,$59d05480,$62b55e95,$696e6775,$6cae6a17,$72d96e1a,$75bd732a,$7d357bb8,
  $771182e7,$5bfaf9f9,$d78caf8a,$fee9ee47,$5f96ce0d,$0a52e39f,$c25ae154,$7564585b,$c46ef465,$84f9fb72,
  $cd7a4d76,$fcff0cc6,$837b7fdf,$679e8b2b,$2a7da7ca,$7f7020ee,$4393d1fa,$4ce2364f,$cb520fab,$610efee1,
  $60587c58,$555c0859,$9b5edb5c,$13623060,$086bbf68,$4e6fb16c,$0f742071,$dae1881f,$7b4c7672,$7f1930fe,
  $7e8f05fe,$8f3e8a6e,$923f8f49,$f08a3a53,$5e96fbf8,$feeb2843,$2a520715,$59629862,$ca76646d,$767bc07a,
  $be53607d,$385e975c,$9870b96f,$8e97117c,$a59ede9b,$76647a63,$934e0187,$193ae85e,$4804fe7f,$9a59c354,
  $6c5e405b,$fce89926,$633a60c5,$5e34653f,$1601aa99,$6720b69e,$9f7fadcb,$fe3ea368,$04fee82e,$73fd738e,
  $775b753a,$27cc1b2b,$07fe7f72,$7d8e7cbe,$8a028247,$8c9e8aea,$361c912d,$546628da,$9706f87f,$ea58164f,
  $9f0e14fe,$52915236,$5824557c,$5f1f5e1d,$63d0608c,$6fdf68af,$7b2c796d,$85ba81cd,$8af888fd,$918d8e44,
  $86369664,$4afaf0ea,$774fce9f,$feedda13,$14563204,$aa5f6b5f,$7c6f2263,$37feb8a5,$58e77fa2,$6f15f8f2,
  $27dfe258,$aafc7f45,$56773a74,$0a120379,$f87f7524,$92477c97,$06fef2b9,$85fb8087,$8a5486a4,$8d998abf,
  $e4ce7ae7,$91e325fe,$96d5963b,$65cf9ce5,$8db37c07,$5b5893c3,$53525c0a,$731d62d9,$5b975027,$60b05f9e,
  $68d5616b,$742e6dd9,$7d427a2e,$7e317d9c,$8e2a816b,$937e8e35,$4f509418,$5de65750,$632b5ea7,$4e3b7f6a,
  $eca8ff13,$59dd0afe,$546a80c4,$55fe5468,$5b99594f,$5eda5dde,$fed3665d,$e8f8e38a,$2c5e496c,$b704fef4,
  $8773e070,$b57c4c75,$fee758a6,$db821f06,$858a3b86,$8a8d708a,$cbf6a88e,$fe7f0431,$d094440d,$a57af999,
  $014fca7c,$c851c651,$fb5bef57,$3d66595c,$3b6d5a6a,$fef1fd57,$e3756f23,$2188227a,$cb907590,$0199ff96,
  $f24e2d83,$cd88464e,$db537d91,$41696b6a,$9e847a6c,$fe618e58,$dd62ef66,$c7751170,$b87e5275,$088b4984,
  $ea4e4b8d,$3054ab53,$d7574057,$0563015f,$b8abfd9e,$16322a46,$6205fe7f,$9a6c606b,$e56f2c6c,$dc8e3f77,
  $7d19fae0,$c25f80a2,$7f1a2a9b,$871813fe,$f9fc8a8c,$8dbe8d04,$76f49072,$7a377a19,$80777e54,$55d45507,
  $632f5875,$66496422,$686d664b,$fa0fa32d,$cd6eb1fa,$98e29a73,$cc9e5dab,$fe7f6d23,$0979e667,$fb7e1d7e,
  $97852f81,$d18a3a88,$b08eeb8c,$ad90328f,$73966393,$84970796,$ea53f14f,$195ac959,$c6684e5e,$e975be74,
  $a37a9279,$ea86ed81,$ed8dcc8c,$15659f8f,$f7f9fd67,$dd6f5757,$f68f2f7d,$b596c693,$8461f25f,$984e146f,
  $c9501f4f,$6f55df53,$215dee5d,$cb6b646b,$fe7b9a78,$ca8e49f9,$49906e8e,$40643e63,$2f7a8477,$6a947f93,
  $af64b09f,$a871e66f,$c474da74,$827c127a,$987cb27e,$0a8b9a7e,$10947d8d,$39994c99,$e65bdf52,$2e672d64,
  $c350ed7d,$58587953,$fa615961,$d965ac61,$968b927a,$2150098b,$31527550,$e05a3c55,$345f705e,$ad655e61,
  $fee6b8a6,$c469cd07,$166f326e,$93762173,$1f81397a,$feee5df3,$f050b56d,$e85bc057,$a15f695b,$b5782663,
  $2183dc7d,$f591c785,$f5518a91,$ac7b5667,$bb51c48c,$5560bd59,$ff501c86,$3a5254f9,$1a617d5c,$f262d362,
  $cc65a564,$0a76206e,$5f8e6081,$df96bb96,$9853434e,$dd592955,$c964c55d,$946dfa6c,$1b7a7f73,$e485a682,
  $778e108c,$e191e790,$c6962195,$f251f897,$b9558654,$8864a45f,$1f7db46f,$358f4d8f,$1650c994,$fb6cbe5c,
  $bb751b6d,$647c3d77,$c28a797c,$be581e8a,$775e1659,$8a725263,$dc776b75,$128cbc8a,$745ef38f,$7d6df866,
  $cb83c180,$d697518a,$43fa009b,$9566ff52,$e06eef6d,$2e8ae67d,$d4905e90,$7f521d9a,$9454e852,$db628461,
  $6f68a262,$fceda91e,$71267092,$32a3785d,$7f3b2c38,$e18096f8,$dee73973,$82854904,$628d858c,$fef16891,
  $d14fc326,$d771ed56,$f8870077,$d65bf889,$a867515f,$5a53e290,$a45bf558,$60618160,$707e3d64,$83852580,
  $ac64ae92,$005d1450,$bd589c67,$0e63a862,$1e697869,$ba6e6b6a,$bb79cb76,$cf842982,$fd8da88a,$08e3148f,
  $181f73a5,$db06fee8,$0d9a3696,$5c4e119c,$9c795d75,$fce7795b,$84c47e2e,$0e1a8e59,$17fef17a,$693f6625,
  $51fa7443,$9edc672e,$5fe05145,$87f26c96,$8877885d,$81b560b4,$8d058403,$543953d6,$5a365634,$708a5c31,
  $ae797fe0,$e1feee6a,$91898da3,$9df29a5f,$4ec45074,$60fb53a0,$5c646e2c,$50244f88,$5cd955e4,$60655e5f,
  $6cbb6894,$71be6dc4,$75f475d4,$7a1a7661,$7dc77a49,$7f6e7dfb,$86a981f4,$96c98f1c,$9f5299b3,$52c55247,
  $89aa98ed,$67d24e03,$4fb56f06,$67955be2,$6d786c88,$7827741b,$937c91dd,$79e487c4,$5feb7a31,$54a44ed6,
  $58ae553e,$60f059a5,$62d66253,$69556736,$96408235,$99dd99b1,$5353502c,$577c5544,$6258fa01,$64e2fa02,
  $67dd666b,$6fef6fc1,$74387422,$94388a17,$56065451,$5f485766,$6b4e619a,$70ad7058,$8a957dbb,$812b596a,
  $770863a2,$8caa803d,$642d5854,$5b9569bb,$6e6f5e11,$8569fa03,$53f0514c,$6020592a,$6b86614b,$6cf06c70,
  $80ce7b1e,$8dc682d4,$98b190b0,$64c7fa04,$64916fa4,$514e6504,$571f5410,$615f8a0e,$fa056876,$7b5275db,
  $901a7d71,$69cc5806,$892a817f,$98399000,$59575078,$629559ac,$9b2a900f,$7279615d,$576195d6,$5df45a46,
  $64ad628a,$677764fa,$6d3e6ce2,$7436722c,$7f777834,$8ddb82ad,$52249817,$677f5742,$74e37248,$8fa68ca9,
  $962a9211,$53ed516b,$4f69634c,$60965504,$6c9b6557,$724c6d7f,$7a1772fd,$8c9d8987,$6f8e5f6d,$81a870f9,
  $4fbf610e,$6241504f,$7bc77247,$7fe97de8,$97ad904d,$8cb69a19,$5e73576a,$840d67b0,$54208a55,$5e635b16,
  $5f0a5ee2,$80ba6583,$9589853d,$4f48965b,$06075305,$7f743768,$57030cfe,$60165e03,$62b1629b,$fa066355,
  $6d666ce1,$783275b1,$ba5080de,$7f51382e,$888d52fe,$900b8912,$98fd92ea,$5e459b91,$66dd66b4,$72067011,
  $4ff5fa07,$5f6a527d,$67536153,$6f026a19,$796874e2,$8c798868,$98c498c7,$54c19a43,$69537a1f,$8c4a8af7,
  $99ae98a8,$62ab5f7c,$76ae75b2,$907f88ab,$53399642,$5fc55f3c,$73cc6ccc,$758b7562,$82fe7b46,$4e4f999d,
  $4e0b903c,$53a64f55,$5ec8590f,$6cb36630,$83777455,$8cc08766,$971e9050,$58d19c15,$86505b78,$9db48b14,
  $60685bd2,$65f1608d,$6f226c57,$701a6fa3,$7ff07f55,$f6009591,$04fef82a,$8f445272,$542b51fd,$e26aaa8c,
  $6abb2bfe,$7dd86db5,$929c8266,$9e799677,$54c85408,$86e476d2,$95d495a4,$4ea2965c,$59ee4f09,$5df75ae6,
  $62976052,$6841676d,$6e2f6c86,$809b7f38,$fa08822a,$9805fa09,$50554ea5,$579354b3,$5b69595a,$61c85bb3,
  $6d776977,$87f97023,$e74a3be9,$908210fe,$9ab899ed,$683852be,$5e785016,$8347674f,$4eab884c,$56ae5411,
  $911573e6,$370997ff,$3cfee419,$589f5653,$8a31865b,$6af661b2,$8ed2737b,$96aa6b47,$59559a57,$8d6b7200,
  $4fd49769,$5f265cf4,$665b61f8,$70ab6ceb,$73b97384,$772973fe,$7d43774d,$7e237d62,$88528237,$8ce2fa0a,
  $986f9249,$7a745b51,$98018840,$4fe05acc,$593e5354,$633e5cfd,$72f96d79,$81078105,$92cf83a2,$4ea89830,
  $52115144,$5f62578b,$6ece6cc2,$e5e92b36,$719220fe,$746973e9,$87a2834a,$90088861,$93a390a2,$516e99a8,
  $60e05f57,$66b36167,$8e4a8559,$978b91af,$4e924e4e,$58d5547c,$597d58fa,$5f275cb5,$62486236,$6667660a,
  $977d6beb,$6ea1a869,$740924ba,$72d0f87f,$e858d354,$769305fe,$7cca795c,$80e17e1e,$a53f13c4,$f148438e,
  $8b7747fe,$93ac8c6a,$98659800,$621660d1,$5a5a9177,$6df7660f,$743f6e3e,$5ffd9b42,$7b0f60da,$5f1854c4,
  $6cd36c5e,$70d86d2a,$86797d05,$9d3b8a0c,$548c5316,$6a3a5b05,$7575706b,$79be798d,$83ef82b1,$8b418a71,
  $97748ca8,$64f4fa0b,$78ba652b,$7a6b78bb,$559a4e38,$5ba65950,$60a35e7b,$6b6163db,$68536665,$71656e19,
  $7d0874b0,$9a699084,$6d3b9c25,$733e6ed1,$95ca8c41,$5e4c51f0,$6a8a935b,$04feedf9,$66446643,$6cc169a5,
  $e989a79d,$714c0dfe,$7687749c,$7c277bc1,$87578352,$968d9051,$532f9ec3,$5efb56de,$e31b5e8e,$61f717fe,
  $67036666,$6dee6a9c,$70706fae,$7e6a736a,$833481be,$8aa886d4,$52838cc4,$5b967372,$94046a6b,$568654ee,
  $65485b5d,$fd5d0e3c,$6d8d09fe,$723b6dc6,$917580b4,$4faf9a4d,$539a5019,$34c8b673,$37de7f3c,$5f8c5e3f,
  $7166673d,$900573dd,$52f352db,$58ce5864,$718f7104,$85b071fb,$66888a13,$55a785a8,$714a6684,$53498431,
  $6bc15599,$5fbd5f59,$668963ee,$8af17147,$9ebe8f1d,$643a4f11,$756670cb,$60648667,$9df88b4e,$51f65147,
  $6d365308,$9ed180f8,$6b236615,$75d57098,$5c795403,$8a167d07,$e45c6b20,$543813de,$6d3d6070,$82087fd5,
  $51de50d6,$566b559c,$59ec56cd,$5e0c5b09,$61986199,$665e6231,$719966e6,$051ee05f,$79a772a7,$7fb27a00,
  $5d168a70,$00000000);

const
  big5_data: array[0..4048-1] of Cardinal = (
  $167feeb7,$043f1fbe,$04190419,$04190419,$04190419,$04190419,$04190419,$04190419,$e3115e3f,$19043e1f,
  $19041904,$19041904,$19041904,$19041904,$19041904,$19041904,$19041904,$19041904,$1f041904,$0007de5e,
  $01ff0c30,$0e300230,$1b2027ff,$e2223fff,$30041e7f,$252026fe,$43fe5020,$fe5400b7,$5c07fe05,$312013ff,
  $332014fe,$342574fe,$0ae21afe,$48012ca0,$036a01b2,$1417dee0,$39301530,$10fe3afe,$3b301130,$0afe3cfe,
  $3d300b30,$08fe3efe,$3f300930,$0cfe40fe,$41300d30,$0efe42fe,$43300f30,$01ea40fe,$18980704,$05dec820,
  $301e301d,$20322035,$e1c2ff03,$203b04de,$300300a7,$524325cb,$5ff76dbf,$5f9b5f82,$079edfdc,$210532a3,
  $ffe300af,$02cdff3f,$3d48fe49,$01e05260,$ff0b07de,$00d7ff0d,$00b100f7,$ff1c221a,$66d8dfc1,$be1cc022,
  $187f0f34,$7a07fe62,$2229ff5e,$7b7e7b01,$dce9f7fd,$33d133d2,$2342222b,$40fc7fff,$95264226,$13e20322,
  $8020bd60,$31ff7e13,$08fedfea,$ff3cff0f,$fe682215,$ffe5ff04,$ffe03012,$e1a49200,$0921031c,$03fe6921,
  $9c33d5da,$ef604033,$35202d49,$00b07a7f,$91825159,$04bef9b7,$74e955e7,$25817cce,$d77e8000,$b3ff1777,
  $f8900083,$0196c9dd,$80177a4a,$c47f553f,$50bf60c0,$01f7a5cd,$1fc1600a,$10237f8d,$216031ff,$0f302131,
  $53441c02,$ff21fffd,$7f07197f,$0391193f,$8881109f,$109ff8b8,$310527c1,$1a1f0413,$3002d9d8,$24e1bd60,
  $1d1620ac,$594e0078,$1a4002a8,$7f2e0629,$e5513fd8,$087e74a2,$b9e699a0,$7f6c1b22,$c14e09d8,$0d30415e,
  $51e1da7f,$6b424e45,$7f1337bf,$035140fa,$5922f652,$f87f1a28,$a7cb571f,$724ba118,$9201a00f,$aad2616a,
  $607dae38,$a540604b,$20ca2e73,$4d187f08,$11d80462,$5f5ebf4e,$dae8c861,$4e885c39,$60bd61c8,$80ff2f4d,
  $f9185d8a,$5143d87f,$604572be,$3e5eb53e,$ca00a008,$6b40602b,$5f3f6762,$ff4732d8,$ecd87f03,$3f60fc58,
  $5b54f8e1,$a1584abc,$a86e1234,$e0085283,$085fc3da,$032a6d62,$652ff87f,$60c83e57,$5f0ab5d4,$2078e1f8,
  $5217426b,$25340709,$706bf87f,$60482fbe,$4201a8cb,$19d8ede9,$bf5fbd4e,$c168e261,$c7ce969f,$4b40801f,
  $78e23560,$45ff5145,$7d4d2201,$56119f40,$01661ffa,$da7f0611,$534a4edf,$273f6bbf,$f5344dff,$fb02f90f,
  $fdfc14ff,$0804fbf6,$08f5ffff,$db1c7f0e,$1656da56,$a157c459,$bde80642,$7abae22d,$a05b5fbf,$6848226f,
  $c57adfd6,$49620a5f,$7ffffe01,$4065a5f8,$3e5fed1e,$787f0220,$446a6b63,$ff0928ff,$aff87ffe,$2812d472,
  $4678c975,$e5e34064,$630bc657,$1aecb750,$0f46a108,$7f572b5a,$404e1ed8,$6f6ac079,$5a1fc165,$0bf1100a,
  $fe0103f8,$f50504e3,$0a040a03,$5149d87f,$6fc15fbe,$67232dc8,$07948283,$d8664a32,$78024f9f,$be5ec569,
  $3964b162,$3b5dbc66,$d8e5b865,$1fbe56e0,$dc058356,$03ef92a7,$2e00a1c8,$5d4a5f49,$55ffa43c,$606e600f,
  $6e70a1bd,$9f64a628,$7ffe26f8,$d82e9ae4,$d87ffd2b,$203e620e,$fdf85303,$6536f87f,$a037feb2,$600c1200,
  $1eb779d5,$21f87f04,$a85a426b,$92834729,$c458407d,$01d93a65,$7070087e,$725d725f,$7af9767e,$7cf87c73,
  $33547f36,$06090244,$c97d4c21,$6d5a00a0,$4f644860,$044f0427,$6bf87f0c,$682fd486,$897ffce1,$4e329621,
  $601a9275,$4b4667b8,$6f9b5d66,$5f3d5640,$64a8684a,$47c35cdc,$61e2545e,$fff1a8ab,$41282017,$83ff6e01,
  $fa82968c,$da01a007,$9e01a4f9,$6fb160fa,$6f1973a8,$5d54583d,$57e06699,$63365ec1,$61db5540,$e6345d31,
  $4556ead8,$075f071a,$c47f0def,$68b0633a,$3bb3963f,$6ab565e9,$5eb66236,$9baf6b37,$5ffede1a,$9ff0603e,
  $613a7203,$52ff1f40,$5e90a883,$38682883,$1b0d6d21,$0215fe45,$f60bf45f,$f20dfa24,$6212787f,$ff1373ff,
  $e413f6ea,$fb02f21d,$29dd1ffa,$fefe27d6,$39d87ff5,$b89ec165,$ef26ac0a,$5d4a4080,$6cbd55c7,$6578e1b3,
  $1c736a6b,$0107e83b,$10cf16fc,$dc1ce016,$06ebfc2e,$12f60cef,$040717f0,$76d87fea,$fba04570,$ff9fffa5,
  $d39fe98d,$4b5ffe56,$39b349a0,$f7ffddaf,$7a76fcdf,$7f557cfb,$6097f740,$5dffa13b,$7f233bc8,$dee0b9c4,
  $d2898b04,$378a0089,$47a74e8c,$42a0bb1a,$d0a1ebde,$c3611852,$da7fff1f,$90915de1,$9ebc63d0,$e059f2a5,
  $3c9632d8,$d8e0b961,$6e6f4e26,$a64267d7,$62db0a00,$56cb5330,$5ebb586e,$50d2622d,$68286d51,$fbd994c1,
  $66d36027,$404520bf,$7a75833e,$a5475f36,$6967f67c,$6a3e5fc1,$7200a050,$6e029fe9,$5160601a,$5e3b55dc,
  $5b3466cc,$6ac450d3,$7145444d,$faf8e832,$37d28856,$445c3f5f,$ce7e179f,$bc603e62,$19fd6a27,$f523f5e5,
  $7f65830a,$af4352b7,$604e65f3,$5f4279bf,$fa019ec3,$7ffd22d9,$ea710164,$d983f117,$c8076499,$f622bf5f,
  $05fd2267,$306001f9,$01570201,$0361fdfe,$100af81d,$e1061b05,$830ceb14,$e9f0999d,$5fe95fff,$034a3f41,
  $f703fbf8,$28d00919,$e0fdf701,$0914ff15,$25e806ee,$01fe27d7,$7f22e6ef,$69653e78,$ff1a3e15,$4b742183,
  $b562ce59,$17fb059e,$1c64dd66,$cf619775,$404c3a6a,$d15ac967,$295ce452,$f87f0817,$02426b23,$1e93a178,
  $25446c78,$ce191bbe,$26fe010a,$e5fe2ac9,$ed08f50c,$ce2cee29,$effa26fc,$faed43e2,$d8047f0a,$61b97095,
  $0392a738,$2f4f60a8,$4d7d5702,$d89cbe65,$4b5f77fe,$c97f979d,$dba6009f,$f0a0ef63,$4174085e,$17fe87a0,
  $dc7fff2b,$7cfe7afa,$9ff77f54,$5ebad279,$64b0673d,$a236653e,$a0e86335,$5fc7aaa5,$6ca267d3,$64b95db8,
  $26cc55c8,$05fe7ff9,$8671864e,$8868521d,$17028ecb,$0ae39fd8,$42049f98,$77f8e09c,$3a6e0895,$485e3f62,
  $6a2f771f,$9fd87f0c,$32a04d4e,$4f5fa753,$4d5f3170,$c670b353,$614bcc55,$b46bbe5a,$ae7dd9a7,$d839ffa3,
  $9682f52a,$067f9477,$2dfe9fa8,$af636499,$613b4240,$57bb72a8,$5dd3662e,$7f1716bb,$2761c2c4,$2e64c55e,
  $f87f181f,$228256ff,$5fc26148,$05e5906b,$9fbe5fcf,$5fca2e01,$6d445266,$65b06222,$e76d9d5a,$1f3e6028,
  $834d5c03,$e68d9668,$23e57247,$06235efa,$38250e54,$8482fd23,$2a8895c4,$54c46028,$5c627259,$743d523a,
  $71fa9fbf,$59f969af,$56d358b3,$62aa64ce,$5b515eb8,$3f78d8dc,$12660665,$c77d4325,$3063c659,$d299c864,
  $dd5d4c1e,$8a6dbc51,$06f4461c,$26e30dd5,$0f17d30b,$0929bd15,$d87ff5fb,$61586b6a,$1e04ae6e,$27422a99,
  $e7e417f8,$7ff9ed25,$4060e3c4,$440d255c,$05f111ee,$7f1dd907,$ce70abd8,$3e61395c,$8b9b3665,$049fd907,
  $009f79d2,$b1612b56,$f399da5b,$e1612d99,$601ec15e,$985883f9,$600836d4,$5ebe7fc0,$5fb87dc1,$9f3360d0,
  $625b520a,$e2009c51,$9fbf602c,$61680271,$06b39cc0,$fdfea7d8,$5dc2684d,$e0bd5f48,$567f3878,$7d0c4531,
  $7e24a1bd,$54b560ea,$5d5463c0,$9cc567b3,$6c48b716,$5c1e60db,$6e216eca,$6cc444c6,$5eb84dcf,$27cb5acc,
  $50d87f17,$ffa0e886,$15a1df49,$3a63394b,$8c9ef8e0,$9ffb4e01,$9ffc6240,$5fc7db23,$8364ddc7,$8603916f,
  $a0b3603b,$e827fe87,$509582dc,$40964b96,$181b14a0,$0da2e166,$03a32a9a,$f8e02ada,$625a4e58,$4655600d,
  $78135ff6,$51f5582d,$54bf5c3b,$44d369c5,$5fcd556f,$5efe5d9b,$c9deb614,$5ec0627d,$a23a5fea,$5f88168a,
  $52cca0c6,$05fea1f9,$58e77089,$662942f5,$4ad95a53,$52e75a43,$e0411e3c,$f3a8b67d,$d16bd803,$5915f89b,
  $007e4830,$822b6806,$99704a9e,$74da8339,$b3619ea7,$8303158b,$ff1eb26a,$7e044d4c,$60fa71fb,$63be57be,
  $e5f3a545,$fdfea3eb,$25faa019,$dfbf660a,$c4605918,$622b60c9,$6a455e57,$63335dda,$c2109cb8,$1bd46abe,
  $b17df04f,$4861ad72,$ad6ab15d,$e45ec056,$f803fb9f,$7ca1e764,$3460581a,$fc9cba67,$c061bad9,$f85b09a0,
  $26663e60,$898ad164,$44634592,$f05cb716,$1be707fc,$7f2905ce,$bf6b8ad8,$83046c36,$e6cb9668,$5fb362a9,
  $513f689f,$52dc4cf9,$71356cac,$104b57be,$cad87f2f,$b565cd70,$fda60697,$37f682a3,$8e9fbb60,$2561b99a,
  $759a4959,$be5ff823,$181a649f,$c9602b60,$f6a43d5f,$59624b49,$696a00a1,$c0a3c05f,$d05f791a,$c4e15652,
  $9fb363ae,$5fbc8a12,$63b75fcf,$26029d3f,$0b831ffa,$ab97c27e,$6c65080e,$6a5f77a5,$d55fb45f,$445e3260,
  $cb58c162,$7f3ad8e0,$1e707a64,$b5831245,$b1a0e576,$545ee842,$b268c654,$4c5ad45d,$fbf5f399,$5967d35f,
  $8ea1bd60,$416269be,$396bae5b,$236d3f56,$e850bd63,$d8ed3758,$6ff58654,$51c46829,$1bd39cd6,$9dc06098,
  $5f8e79fc,$5ac85f3e,$1cc25e4c,$48d87f02,$675ff18c,$5cd2d4a0,$e19dc162,$3160493e,$4e5d3a64,$9c99c75d,
  $049fc92e,$ff9fb9be,$3a604a2d,$f87ffd22,$02de9583,$bac4dfe8,$061a4660,$e2f87f5d,$fbeec998,$0a0d4d22,
  $4e7ef87f,$5df80bfb,$66c85e2b,$4c506daf,$613f6fc6,$fa5f8018,$5b392ee7,$8363057a,$5ffa757e,$df4072c9,
  $fc53c3dc,$63554666,$426c9e5e,$e453c651,$744d455c,$1076b64a,$15a6907b,$fea02ec2,$44625b55,$d5619a5e,
  $01817263,$d3a41c9a,$dc60782a,$655e1661,$25a1ac5c,$3f5fe95b,$43233d5f,$7d59ffff,$fea9a03c,$5dcc6077,
  $55d757cb,$98426544,$5fe956ca,$027fa1bd,$243f5fe8,$15200277,$832c02fd,$9fc872c9,$623b89fc,$71476b26,
  $7fd738a9,$3a5b47c4,$bd6da073,$e14cd858,$c8035296,$b81b57a2,$4265e35c,$d1783049,$ba507743,$9c7e106b,
  $4a63d061,$3b58bd53,$e2a8bf57,$475fb7e7,$555fdadf,$1ec8654f,$11ff48ff,$99848323,$2097f68e,$fcf06b83,
  $52d766f9,$b765671b,$70b15f38,$5b7a5b8a,$41d32c30,$0fffd9e9,$02f70b09,$32f87fe1,$08c2876b,$dd8a3ea0,
  $19537662,$d66bab77,$43414a5f,$6f4ee152,$fe3fbf2d,$9b480dd0,$12ed1125,$defafd07,$d342e6fe,$f9d87f27,
  $33604f70,$38ff4d99,$b7fe9aa0,$6da2bd5f,$396049f6,$2839f8a1,$c47f162d,$43063240,$1f0efc01,$50407d45,
  $16c0a154,$5c091fe9,$9283fe07,$a7633099,$480b16a0,$2a5a8da0,$381e8aa0,$335d505f,$4d8e0fa2,$dac1fea0,
  $0bbd2e1f,$03f00403,$f013eb11,$3d787fff,$32fc617f,$7d4a0402,$9ee89e6d,$5f4760c7,$cadd9a46,$a13f6018,
  $5fa83f54,$733474a0,$643853ae,$61976b36,$7f2124c0,$6a8655dc,$3986c75f,$5058cd5b,$199f2662,$2a64ae26,
  $3761a771,$a7f3079f,$c162b369,$3c593c65,$8c4978e3,$ff034f11,$bf959583,$fca577fe,$39a03c81,$bd60c7d3,
  $335f3c65,$2f60c862,$f9223469,$12d3e47f,$775a20f8,$04fdf127,$7a7ffc06,$966a9589,$30c6830b,$2a54f507,
  $05fe7fff,$7adf7ae0,$98039802,$3f8a9b5a,$eae5609e,$2b50a2d8,$af5c535c,$fae0c16a,$51f16700,$20080680,
  $3f7d75f4,$592a7e9f,$9573447d,$aa5dd266,$b3554d6c,$bb77b861,$89cd9f98,$c458e05e,$eeb0ca46,$bb721dcd,
  $4065b064,$d8a13c58,$16a65802,$525e588b,$eb2e0ba4,$e283611f,$25a07975,$24603c6a,$891eb5a9,$3b21425f,
  $0201f74c,$7df07d78,$3f289f40,$74c35d18,$6d17637b,$74f9251b,$287d1d89,$0ca8b769,$e93598a7,$e029f143,
  $c47f07fd,$682d6844,$2200ab35,$98b667d6,$a1e62276,$5fc81f64,$79ffb6c0,$5d802be8,$a1a970b9,$600a19f9,
  $6fdc9f5f,$5fb860a7,$5cd54d6d,$6f9968b9,$7fc15431,$41bb9e44,$7f8d2938,$3c6b3ed8,$26fe5b21,$fd013f33,
  $6e2fd87f,$680d6dc8,$621651f4,$5eff5c3e,$bf18388c,$057d49f9,$56592d6c,$ea32208d,$1535901b,$f6f72ee1,
  $7119d87f,$58c965c0,$bdaebbd4,$d5fca37c,$9ace5efa,$6087c310,$604f612f,$a52c5dbe,$200bf201,$f978ff45,
  $bf5b477d,$0a6a01a2,$e05ed960,$fa7672b3,$9da14e66,$ba6027ef,$7a9818dd,$4f1fbfc4,$f00d66fe,$d199830a,
  $174d99b6,$6bb26b88,$04430b2d,$0efc05ef,$84da7f03,$c07fd455,$f8ca46ba,$c55bbf6c,$b8662b5e,$9db04666,
  $d97cc826,$e509d45a,$022eb646,$e6b36303,$f531c01c,$f6d66ed8,$0bcd2bd8,$865bf87f,$6137ea83,$96486327,
  $669de20d,$4ad197c0,$5ae46a48,$69444f48,$57365ac6,$7f201e45,$608c61d8,$c95bcc76,$34623a61,$f9a43f61,
  $fc9fbb45,$2e60e931,$ce5db767,$37f73495,$6a469fa0,$ba633c60,$37cecba1,$0265f521,$0e01456a,$03ef15e6,
  $d87f0af7,$1e3b9594,$c1c47f06,$3bedfc9f,$47593d60,$5152c660,$415fc37e,$d9a16760,$01a008e2,$44602b7a,
  $07ee089d,$d87fff2c,$e1c99ec3,$ad4e82da,$c05ec750,$ca573968,$b7abb461,$622057e3,$01fefe07,$dfd87f4c,
  $5255c855,$c955cd54,$2b654068,$5e602463,$a8034892,$3f633374,$216b3a61,$b06b9d70,$7d671b9c,$bf594260,
  $f027375f,$5d69f87f,$22cb7205,$474aff50,$b806527e,$177c3576,$474f674a,$7dfe4623,$5b316438,$b8395333,
  $7f0802e9,$614b506a,$662357cf,$50685cb8,$cb6597c0,$cae6a108,$66c05fe7,$76f529ae,$69941a7f,$2dc4696d,
  $209a296e,$886516ee,$b559c26e,$454bcc72,$d8abeb9c,$2a29bf64,$6ea2d87f,$65a371cc,$5f69660e,$5f6359a0,
  $628572b1,$1e9667e7,$4ed87f0d,$bb67ca71,$4f5add52,$396c265d,$e3976154,$4d6e485e,$bcc1ff9d,$bf64bb5e,
  $416cbe51,$780719a0,$b1683068,$b562485f,$b802ea9f,$385dcf67,$4158d562,$faa14858,$e169fa2d,$bd5a4053,
  $eca0d459,$02204be9,$842cfa7f,$fa5e79bd,$a5346057,$a00a01ff,$5a0922d6,$07499ccd,$9adda018,$26b06177,
  $6ed87fcc,$47603b7f,$b19e3f7b,$fea2d806,$c75ffbb1,$f8224856,$a04dc47f,$e41a79ec,$358482d8,$f144f403,
  $ef23de05,$022cf9e1,$7fd90406,$3e865ed8,$586699a1,$831cbf5f,$7e383e56,$5f5a174e,$623c6144,$9eca54c3,
  $68791ac9,$61336046,$53b56b46,$545348fc,$663e65b5,$e62981c1,$41ff227f,$2e748583,$1ba13f68,$c66087fb,
  $ba584661,$5942cba0,$94a5b560,$3f69884a,$2868af64,$c75bbb6c,$2d61bf5f,$4812d0a1,$601fbe65,$05e1206e,
  $f01dfe03,$15e3ed19,$06f4f804,$98f87f1b,$07f2ff95,$3e5f7760,$be61ec60,$18765f9e,$180299a0,$faa3b760,
  $c4df8bbd,$fab4a048,$e1fae027,$989ce99a,$0d204a2f,$50e7d87f,$6b315bc6,$60ba5dad,$e21a8edf,$fe8fa909,
  $7f7c2ae7,$4155fed8,$56533c6d,$294e8019,$4754c86f,$e7fb2193,$cf624875,$f8a5af5b,$bd6279fd,$77fe45a0,
  $ae614477,$91a5415f,$fa2089a2,$93929380,$b219522d,$607b4e02,$f9fda0b2,$bdf36029,$78d92229,$15eb65b8,
  $3e734883,$622adaee,$9e116487,$5e77524f,$46d54bda,$baf6a6f8,$2dffa358,$7ff5205b,$cb699cd8,$6456eb56,
  $436d905c,$3d6dc858,$5c4d5e50,$680ba590,$6f33d8ee,$50d45521,$65a26a74,$7f2019a3,$56581dc4,$315d4675,
  $5921d559,$f115c2a2,$d87f2bda,$52447194,$ae0d9d4c,$b603a53a,$ff13a0ba,$9ec56067,$695a3296,$a4be5f26,
  $6a0806cd,$7de2a0b9,$65c75ded,$02ea9d36,$0aa09fe8,$0dffa788,$d2b1a019,$70aa5f67,$743b5bc5,$0f349e8f,
  $d6fca008,$60605ec7,$5f2a74a2,$6e28643f,$72356136,$bfc392b5,$f9fea009,$222c9fc9,$5cce62fb,$65031ac1,
  $0a0d0d13,$c9d87f2d,$be633684,$2a69c44a,$1323ad77,$f9152cbd,$873fd87f,$61276f1d,$917c524e,$60ef25f2,
  $623f6232,$d9d5b8ab,$62515e6e,$e83269aa,$425dc5c4,$0ca43958,$ffa22f0a,$009fe919,$fca2da62,$3e717999,
  $ca3dfea1,$4661b86b,$3b61c45b,$57febd9f,$7a835720,$481f0395,$a55f5260,$1465c86b,$95a178ea,$97928682,
  $5ff80af4,$7c2e22f0,$607d7109,$180696a0,$fda34165,$c06edadd,$18025aba,$c89ec17b,$d8e0e9fb,$5dbc5104,
  $62c861ba,$aad69e40,$a1c0600a,$ec1995fd,$4c562ed8,$b566395f,$485de95a,$01dc826e,$de5880d8,$d154d45f,
  $bb19fd9d,$2a67b279,$eb95fcab,$78a0bd5f,$f7b37802,$019fdb35,$445f8a02,$679ec55f,$fea458a2,$c65f1f01,
  $c4f63857,$693b5a3a,$51da54e8,$1849575d,$2eda7f1a,$c5646962,$9669e464,$ae5adf63,$db54d360,$d157be5f,
  $c1a84856,$35a00806,$fd2087f7,$6a23d87f,$6e5844bc,$5963523b,$614e54b7,$fb3eb1a8,$e0606557,$fc6f3fd8,
  $ae6a0d63,$5c572778,$36565f5b,$7d80f25a,$ff1f1a65,$719fd87f,$b5f7a24c,$22b2a44a,$5c617118,$82fea0bb,
  $6236608a,$de009dc1,$a629a1f9,$a2445f9a,$5facfdfa,$6b3467b5,$f76ea9a7,$25832037,$e7fe739b,$b069436f,
  $9f5d4068,$3c56fdb5,$9d65bb61,$bb653169,$b5a5435b,$06a188e9,$38201dee,$f239e47f,$60803748,$17d8df3a,
  $944ee585,$be53407e,$1859be68,$d8e31a7c,$60b28782,$585162aa,$a3355f31,$6b280707,$a0c06537,$615ec5f5,
  $ba915eb5,$6166ea2c,$72b15eb9,$b0c254b7,$21d80770,$8308fe74,$603578f6,$2df7a6b9,$1e03a31a,$624c5e5a,
  $a0b66cad,$662a6dfd,$5ec961be,$a3415943,$5fa81343,$f6b8a4c4,$560a1fa7,$41909983,$725fc7db,$324ef741,
  $685ad564,$95ad9cc1,$970495b1,$6c7d5711,$9a46039f,$6a59f1a0,$059fc865,$4e5f3b12,$3d61b65e,$08dadda3,
  $3f6ef760,$2e59f8b9,$95fae4e0,$7f10214e,$5258a8dc,$4551129f,$6aa23c5e,$b3a328a6,$d8e5f806,$66d15659,
  $59535db0,$5f4b5ebe,$7f141b3d,$3d58c1d8,$eaa1fea4,$7844173a,$4ada7f1e,$9f61b25f,$e943e12b,$68fe0c08,
  $64c5d87f,$603064bc,$5dc2555d,$a0d2594a,$751ad5ea,$214a5842,$3dd87ff1,$de60bb6a,$ca50ad68,$3c553f6e,
  $1094e957,$d8e8d877,$582f6fc2,$535c50e1,$5eb9664b,$7f141d30,$4a71bed8,$4c5b4163,$c2655452,$3e8e0093,
  $c65ac673,$08a6439f,$180f26a0,$a7faaca0,$05a03e6b,$d15f2d0a,$0a9abe9d,$ffa2b860,$3831e9b9,$83f71bb8,
  $02ee95fd,$c6c4f338,$bb63d25b,$68a32c5f,$c063d8e3,$6e2a399e,$0d53ff1f,$d87f0150,$57ce854a,$629a605f,
  $7ff41ee3,$db8783d8,$d395c35f,$b3607b22,$ca21f6a2,$184f3f9f,$1c67455f,$4267c665,$455b3560,$1dba05a1,
  $f98225a0,$cd612d74,$4c15fc9b,$749dc85f,$832ce7fa,$9f4972b7,$78d976b9,$5e7a4155,$4cee4d33,$5dd55b55,
  $7feb2c34,$eb95bbf8,$6a601802,$b762427c,$092dfca2,$97b8c960,$3c60281e,$eb95cb5b,$831f685e,$d6d291d5,
  $0ec6a0e7,$bd3263e8,$60de0e68,$a42a60c2,$2b87f3bc,$2ad87f0f,$1120b551,$52f5da7f,$67b2568e,$da04e0b5,
  $58d5568f,$7ffd1f3e,$3a5b30d8,$0af2559d,$27fb53a3,$0ac9fba0,$d87f712e,$623961c9,$026712de,$64ced87f,
  $67c766bc,$18c462b6,$02947e0b,$7ffd3558,$536a80d8,$7e5d5d58,$b96c1b44,$b946bba7,$d87f2e22,$57586fd8,
  $a3485dc0,$66b64603,$ac2c63b5,$5f8fda01,$63bf5c4e,$51eca3bf,$0729a109,$9b467368,$9fce7601,$6c8a7609,
  $9dbc62b7,$70790605,$a8bb5d42,$aac80aa5,$605d1e67,$52149cb1,$82fc2ff7,$509b2599,$b160783f,$5154505d,
  $335e535a,$4956ce62,$8abb1498,$83017520,$f7529b76,$5f475f77,$5acb5f3f,$7f683069,$c485aa18,$5add5d1a,
  $562c6d42,$62dc9160,$6f22610d,$5fcf52b4,$ef6fa14d,$a23460d7,$608d866e,$6aaf60c1,$c20b93bd,$1a339fec,
  $9e3f602a,$6a0ab202,$e6019ec1,$a1435fab,$5fecfdfa,$9f405ec6,$9fb9a6b8,$234ec1fe,$1bd54da6,$ee66cde6,
  $faea15ef,$95cad87f,$9f3c6040,$a1d81aea,$28180645,$be727e33,$facba7e9,$75833ae7,$b80f8d9a,$fe0f4434,
  $0d63fe01,$e20ade7f,$ae569553,$d858d956,$5d5b3858,$3361e35f,$be64f462,$405a4765,$9c92bf9e,$6ab3d8e4,
  $5eb86b39,$be009649,$7f37218a,$c17009d8,$169a4759,$833eb7fa,$fb7e9298,$5617b317,$7f023409,$1da9fae4,
  $51a03c60,$406b2a7f,$5802639f,$34613c76,$cb15fea2,$3c644076,$eea33163,$7ba01ac2,$417567fe,$85cfd8fd,
  $5cc2719a,$d6bf64a7,$bd87efd8,$be95eea2,$0cce41a2,$249fb361,$49753ad3,$f69dbe61,$03a889a9,$049fcce6,
  $23a00c8a,$cb5f6f0e,$be5dd065,$fd20a861,$95d4d87f,$32049d41,$a0bd5fac,$67e91602,$544c2342,$9c958302,
  $600a0e66,$a27698be,$0a41ab29,$9fbf6488,$6337fe7c,$2f909c0b,$d37fa028,$33dce168,$de56a551,$dee14058,
  $905bf504,$f25eec9f,$ff1fc461,$6500f87f,$dfdf420e,$b86ae5d8,$d87ff91e,$6443701b,$a1386132,$24a81bed,
  $78187f4a,$0a01e473,$8e18a0cd,$06d89ffa,$5f51b658,$51feab9a,$6239600f,$6bd8e43a,$3065c17e,$23bb1aa0,
  $dadfc274,$85e981d8,$672b6634,$fbd8e8c0,$2c63c987,$77ff61a2,$af8a079f,$5058bc61,$129bc05a,$71a01eba,
  $2f6147db,$df9d4d5b,$dca5e7ea,$fd325802,$93e1d87f,$622466b0,$65b96053,$99cb652b,$2d7fce10,$3afd472f,
  $fa631f7b,$887e6103,$02acc80e,$bf6dabce,$8eb60497,$019c505d,$3c604c96,$52f8daf0,$5fce56a8,$e4dae3be,
  $c25b4058,$fe7f793c,$f85dc904,$1861fa61,$c811fc65,$fa7f413c,$703e6aec,$bdd805f2,$392d4f6a,$26787f03,
  $979b8379,$b558bb9b,$ea1825f7,$8fae1c01,$7e7c7e7d,$3b2605e4,$81dadceb,$85fb8266,$65a96bbe,$7f031e44,
  $008814f8,$3da55d3a,$3a5fcdde,$a3a5b064,$b877b7fb,$dc7ffd21,$91cb91b4,$9d2b9418,$b93d3be3,$a567fe8d,
  $a0681282,$dfaf75fe,$7b9e79d8,$04304739,$37dc7ffe,$c1513851,$fee0bf56,$6c591406,$fc5dcd5c,$1d61fe61,
  $39e1ff65,$6afbd8f5,$05fedb48,$704c6bb2,$72a7721b,$51fe74d6,$05def69e,$7e8f7c50,$7fbc7e8c,$d6d58617,
  $bf8823d8,$1d29fe9f,$2eda50a0,$6e5605a0,$37fa02b7,$7a7f502d,$942e91ba,$26a18205,$0d57b691,$7b31f9a0,
  $dbc5fea6,$9656832e,$9fda1290,$7897e2db,$91f6a6c4,$0a29a51b,$dc01e099,$513b513c,$dfc156c8,$5b7f0bfe,
  $5dd25dd4,$61ff5f4e,$6b0a6524,$70516b61,$73807058,$2e3a9763,$fe047ffe,$6079b307,$7e7c5f7c,$df807d80,
  $fd897281,$95b83a31,$01b79803,$d8fe6b36,$e04c9444,$00973df8,$a99fea12,$f8affba6,$2ea47a11,$fda0c7a3,
  $5ca03e5d,$2a1fe8df,$cc04de7f,$005dd656,$c7652362,$ec04fedf,$da6b1066,$997aca74,$d8e017ff,$df427e93,
  $81e208de,$863f8638,$8b8a8831,$908f9090,$e1bd9463,$069768f8,$406fdbb3,$d8027b9e,$f80b829f,$4ae78e9f,
  $d10adee5,$2c58e956,$71705e65,$d7767276,$887f5077,$4288367f,$8b93d8f4,$05dee1bf,$8d1b8277,$946a91c0,
  $9e459742,$beeaa681,$b068d6c2,$a8180399,$26fa2600,$0cfe7ffb,$6b165ef3,$7c6c7063,$883b7c6e,$8ea189c0,
  $947291c1,$98719470,$e4cddeec,$9ecc0dde,$77da7064,$94778b9a,$9a6297c9,$7e9c9a65,$8eaa8b9c,$947d91c5,
  $0c1edf40,$9c789c77,$8c549ef7,$9e1a947f,$9a6a7228,$9e1b9b31,$7c729e1e,$4206de0e,$f54e5c4e,$82531a51,
  $444e0753,$7e7f463d,$0c56d707,$735c6efa,$874e0f5f,$204e0e51,$ff072f65,$5198f87f,$e4c9bf63,$57200bfe,
  $592c5903,$5dff5c10,$6bb365e1,$6c146bcc,$4e31723f,$5f4aae0a,$debc5c4c,$520c04fe,$534c531c,$ce005722,
  $81f8e17f,$8a36025b,$909ff862,$1ee019ef,$095fc904,$15625062,$6660c46c,$07dede3c,$72b072ae,$79b8738a,
  $961e808a,$69c94f0e,$671d6f09,$52d46837,$58b16e42,$b1f8eeb0,$67da6151,$d9ee95a0,$7afe6d5f,$56e15407,
  $0afc4ffe,$593c787f,$f609fc44,$d69f1a83,$5720fafb,$609a8683,$7da0ea57,$6125985e,$787ffbff,$a982625c,
  $633774c5,$eff8e53a,$bd3dff65,$3f613f5f,$d8dbbd62,$65ed6c18,$64bb59c9,$71f8e037,$0957ec70,$4e6ed8a0,
  $7a75dcf5,$82787f51,$e0bd61c3,$7e864ddc,$3e909989,$d8dcc260,$1e419622,$56d87f03,$a773254f,$e84d5064,
  $d6514c55,$2225c54a,$518ff87f,$a0198a29,$a00a2e02,$60e9665a,$1aa0a05b,$58e95f38,$d9c86114,$b268e4c4,
  $d8f13c53,$1f3956ee,$95b3825c,$58e7b39e,$b763b266,$bf57535b,$3fb1faab,$280695a0,$425cc166,$3c5c485f,
  $9d2a01a6,$e9f203a2,$051e425f,$fe5b1878,$1dffff5c,$ee0506fb,$f517ff03,$f4050408,$623a787f,$01020949,
  $0aeaf305,$0711f6ff,$02f506ef,$6537f87f,$5ff80eb8,$074fa13f,$5bbc6118,$26306a3c,$d0787ff1,$5e01496b,
  $071904ef,$fafee204,$0e1ad331,$f20dca07,$f87f1316,$a2057074,$62be65bf,$29f99dc2,$49832cf8,$fe9dfe98,
  $b8025a9f,$793dfaee,$0e608034,$a4c15f78,$5f67fff3,$7f022148,$01dcb7c4,$c98c78fa,$1b7df68f,$c85cc360,
  $9630d8dc,$7ffe2338,$644e33f8,$38608793,$3e57c661,$d519bb6a,$df30d34b,$0c18f708,$f0f40af8,$7f03d613,
  $dd519ed8,$7dfd7720,$29eba940,$b84064da,$6f280655,$58cf60b8,$61ce51c5,$59476327,$5fb25166,$dec345f7,
  $0256f778,$d63a8376,$5ac97d7d,$57405c45,$e38eaa45,$6a4466f8,$5ad9523f,$694662b5,$63c2659b,$0b9aa92c,
  $ba01a2d8,$f667202a,$128315fc,$c961b37b,$b65ec75a,$f69d5063,$049fddc1,$405fac3a,$bc76ef60,$4807611f,
  $d919f3f9,$4b68c47f,$61a76dcc,$612b5b4d,$5dbe52dd,$a3f7a93d,$6e4666f8,$69cb562d,$65bc6224,$7f08232e,
  $6b653d78,$08f34e13,$82f3f60e,$d37009bf,$a84ee59f,$4370a767,$2e6e4452,$3f6c305f,$47596457,$3761ba55,
  $787f1b20,$fe5b6b25,$59763f60,$ddeb03ff,$d03ad91e,$09f8f219,$e0052703,$13d6d70b,$70e25ee3,$49e9fa9d,
  $7fe81ad6,$c37094d8,$3e59cd56,$d7564466,$59afe694,$5258cc5f,$3262c15b,$b7f6d2a2,$76418320,$2b3f98cb,
  $9f406568,$31682e4d,$9c768344,$5fd80f02,$fde4dfc1,$859fdd29,$7fa02aca,$f8e87de6,$7a598035,$9ed45f58,
  $67fdc9f8,$5f2f55df,$63326cc2,$5d5b514d,$6c475cb4,$d6336f22,$3f8670d8,$56da01df,$b98fd28c,$bf643a63,
  $b806daa0,$d8dec35f,$5fc39639,$cdd8e43e,$1f66b84f,$d25b416b,$b8513d63,$a4672c73,$78f93962,$77055244,
  $1b3f7b02,$2197a783,$b860b79f,$da7ff434,$54b7830d,$672073b7,$4cd00d40,$6cb41ce6,$b5d87fd2,$44602957,
  $be62ca54,$c95bc35c,$5e9db565,$8da45863,$d160f7f6,$c26e2c58,$4d573a5f,$c966a462,$b66eab60,$3a8fba9c,
  $4a5a4768,$c47f101a,$5f2f5e42,$858325c2,$507f61d3,$089f00ac,$039ec060,$be5f4a2e,$6220c75c,$b7e77d27,
  $61a806b0,$66a7565d,$58d160b4,$42dc60b4,$a3cd69df,$68b803d3,$6c2a5f7d,$6acd5435,$64be563d,$6d266052,
  $4178daa6,$15670265,$507deb77,$3c64a761,$23673868,$e09ac46b,$706b0802,$1f70b24b,$b754207e,$3b5ce566,
  $4413574b,$dff5f8ff,$091915f7,$27ca4ac2,$f538e2df,$f901cf1f,$f87fe127,$06596b28,$60df6318,$1a00bfc7,
  $593960bc,$1c13615c,$15d159d0,$eff7e021,$647f251d,$cc1f17bf,$19c7310c,$e71adc0c,$b7d87f07,$b36f2870,
  $4069315f,$081f979a,$c261e160,$38665b9d,$4a5a4260,$6a85fd9e,$3d62b664,$7775831a,$5bc74a76,$a9326144,
  $63f80720,$0a5ea058,$444b2ce8,$7c8883fb,$b1ffa1ad,$655d600b,$5fca59c0,$a7ba5dbf,$5ff80736,$e2909fba,
  $9c466017,$6527fab1,$fb78a06e,$a0456007,$204a0600,$58d87ff9,$311e787f,$9c8e8349,$5efa8222,$5d3758d8,
  $5b5d5acd,$5a4a5742,$93ce63c5,$27288731,$0efb2545,$65d518e1,$f81eebb1,$170311f5,$fafafbef,$5e3ac47f,
  $7ffa1cd9,$bd8677d8,$cf35f7a3,$ffa15860,$03230da5,$8d72da7f,$a63e8fe3,$5ccc41f2,$5cb06ac1,$2dfda1c8,
  $54d8dffc,$c160bb96,$d87f041b,$60a7501e,$55cd674b,$61fe5f9a,$6fc04535,$66c661c4,$2ddda0ba,$7b3f639d,
  $a2c2603a,$5f87e692,$a636604b,$a8f9026a,$6346f387,$58cb4abb,$61c452f5,$563472a3,$603c58d8,$a3b576a8,
  $2c9803f5,$3d7da366,$3f5bcb54,$47643e5e,$4ca3a964,$3d6ce8ef,$ba53c06b,$14a9b363,$c563ace2,$e94a569f,
  $f84a979f,$c862c25e,$f7ff2f9c,$019e4567,$369fda1a,$0d1fdbd6,$81dae47f,$68b85e69,$68a66daf,$aa305e45,
  $a2ce29f2,$645876ab,$98c06b96,$555a820c,$56b25fd1,$5e6359d7,$56594a44,$6f275be6,$4af8e3a9,$d9fdfc65,
  $879f405f,$099e8852,$0ba00b02,$2962e7ef,$c367c760,$5855da43,$5e60c15b,$b554b05b,$4560d160,$fb15ad6f,
  $6b2cd87f,$21435f42,$827a7f39,$5e6b8880,$738304fe,$9d523d9c,$9728c05e,$0ac63154,$fc22020b,$d8079062,
  $d937f909,$1623e30c,$f3233997,$6d920402,$1bf802f8,$70dcd87f,$d74b5f37,$e27f39da,$cb5db570,$385cb460,
  $f4a94060,$36360849,$9fbfc47f,$5fa7ea89,$a3bd5c49,$605b4605,$752658cb,$5b3362bc,$5ec85cc8,$d60fa03d,
  $6054600b,$4203bceb,$643a6109,$a1b75fbc,$6538facf,$5fc25abe,$4f801750,$22fba247,$5d525f68,$5b3d62b9,
  $a33764c7,$5f481b22,$9fbf5bcc,$5f480299,$993d5fcd,$2a87fe01,$68dd4a83,$f4385115,$f90af20f,$0893b983,
  $b960cdc6,$f8a23c60,$b45ffa61,$bd5f495e,$fd1eb365,$7f5cd87f,$5ec15ec4,$783c7d3e,$9e559f3f,$e2c09fb8,
  $65bc6067,$b700a23a,$eb0d9f68,$7b956167,$60a97814,$7f061b25,$0d65dfc4,$d0799e67,$565e4d44,$3e6eba5c,
  $4d45c663,$f8f01c6f,$3dff8653,$5bae6059,$67a96643,$55ce622f,$62c75a5f,$6736612e,$03aea1b3,$8f832288,
  $4d58cd74,$b65dd358,$8a12dae3,$71cf8c47,$06d29fe8,$9fc163c8,$72a8071a,$5e3d6637,$7dfa9c48,$6039609b,
  $59c55e48,$a3c45e42,$a007fa6b,$df883285,$965c07fe,$96bc965f,$9adf98e3,$4e7f9b2f,$5f77ebf0,$5c3360bd,
  $62166a51,$2baf6cb4,$0a1a30b3,$22780983,$24626d5d,$1a6b7e9d,$67a0bf60,$6ea597f6,$06600f62,$36524268,
  $bf4a5073,$c4d9e15d,$54f27287,$66a5672b,$f7bea544,$47586f37,$65d75353,$584a67ad,$7b9c5452,$59ce5aa7,
  $576c5ac6,$65594bd3,$ae465c25,$703d5df7,$5bd15eb8,$51f75e9a,$53c662ce,$6cac59d0,$96d65935,$60e6c245,
  $5ce3692c,$9644649e,$1fcc5619,$987eff53,$d15edb12,$db56455e,$2a5fd852,$3c682270,$c7db0fa7,$39624267,
  $280682a0,$eaa43b66,$775f6816,$c06c4959,$c35ad45d,$1c74a955,$c961b569,$6332d8d9,$5db87272,$584e50ff,
  $50a369ba,$41de2457,$41d127c6,$649728ce,$6619c47f,$91bc67bc,$6979e7e2,$a13e5d3c,$760ad605,$48cb644d,
  $a9fdbfc0,$6473519a,$7ebf463d,$555a541d,$4b77632f,$5ddc6631,$6d296a35,$5dd56114,$36d8d9be,$0121bd6b,
  $8683fe59,$be569d96,$c09fc85e,$b963c4e2,$6b4f7e4a,$375fd744,$405be654,$b34b585f,$da454277,$c65d4c56,
  $1a74a170,$d8cc555b,$555270fa,$52574edf,$565c57d3,$56cc6342,$9bd45f38,$5fddbe0b,$ea9da140,$63495f07,
  $27b75f32,$026e6a0f,$fcfd0ffd,$9283f90a,$a95fcc7a,$a7ff5ba9,$c4dec366,$9fc4603c,$2497eabe,$80fef666,
  $a864bf53,$9c49faaa,$bd61b760,$0aaf1a60,$41602c4e,$f623b960,$66833f5a,$c8129798,$d846a49f,$b265315e,
  $d152ce60,$801d5359,$08914565,$3e603dc2,$b81e91a6,$ca61be5f,$c56bbd53,$b165405b,$7f63d8d6,$5f406371,
  $4980206e,$55faa3b6,$75bd5ff9,$32cfa23c,$68c15f48,$61326632,$a23668b4,$5fb89aee,$05fe9d46,$625271b9,
  $783956a5,$69b26d10,$6a5e4e43,$68486294,$59a1673e,$671964e6,$50e647d8,$7f240466,$fd865978,$c47ff869,
  $5ac35fca,$5d316bb6,$82e829c4,$93982e86,$5260b8db,$b758475d,$4e5cbe67,$cc5e4159,$fba32063,$42653bcd,
  $05f75b1e,$39d87ff2,$c070418c,$eb5e27af,$5909fe9f,$01a2b760,$bf605c5a,$00a43b5f,$455e7d0a,$cdaa3065,
  $436057ee,$5650c05f,$026dfd20,$96991983,$415fd81e,$316a2c62,$0618cb60,$957ad87f,$c6f3a0cb,$9f455fe7,
  $e99aaa4f,$9798e5dc,$ba509b99,$5756c95f,$ce60c850,$305b7345,$d9d2d7a2,$2a49ffb3,$d85be9a0,$cd85475f,
  $355f1576,$e1466563,$ce4cd157,$cb6a996c,$dc737d96,$6222c4e0,$86c45e48,$5f777652,$5bcb6bbf,$5abf6538,
  $3725a73f,$4dca5e5d,$769a5e67,$94c67416,$64c62618,$63ac6645,$6741495d,$a4c359cf,$5fe78f4c,$61b95ec8,
  $2f06b1fd,$64966278,$5edb5b34,$6bc64f46,$54e75a2b,$61af67b7,$a24961b6,$b167f6fe,$a057fe4d,$6127c31d,
  $50f61655,$ef0c18de,$04e51ef0,$7d42c302,$57b36254,$273ea344,$6ebf61cd,$8a466156,$5d755ad9,$ae1f6ad5,
  $57e9ae02,$543f6f1f,$622f5dd3,$73bd5fc4,$d358a0a7,$5c3a6028,$68665ecb,$e0e167c0,$e7c2a9e4,$c758c460,
  $da7f0818,$690c6701,$35d8b807,$633e5c29,$5a6043dd,$5edc68b9,$82e55723,$14499e3b,$4ed7de5d,$ff2dd8e4,
  $0dff23ec,$0115fab7,$35dd0e08,$102c15ce,$39d87fa2,$fd21c16b,$749a8358,$a0417967,$649f2e3c,$3f694c40,
  $1d0801b4,$1c0214c9,$1817a916,$c8ea11f5,$f40a302b,$38f7d005,$e9cefa11,$c212230e,$de13ec51,$cf14d924,
  $d87f2401,$683e7120,$5942790c,$56cf5ec1,$bde1a8c8,$606d60ec,$1a059fbd,$59645f9a,$653460ce,$a8bd5cbb,
  $5fec85d7,$7feb1dc3,$cb6343c4,$ba5fb361,$c8a8b765,$fda3f8ce,$465f39e9,$c460b762,$77f6bd99,$fd016c24,
  $8305f809,$3691985b,$60436738,$1b832837,$b67719db,$f7ff11a1,$7a45fe9f,$f8a43960,$fe24ca51,$8009f166,
  $edabb25f,$c95fcd71,$485ab69c,$5061305f,$2f6ea561,$5460a767,$ef97cd54,$c0625803,$35a03e7d,$009fe9e6,
  $6f1d6ab6,$705f8307,$adeda7b6,$6048607a,$60776540,$4ec5bac1,$9d2a229a,$fdd52a28,$b61afa18,$dcf82302,
  $f308dc42,$03eae227,$40d41f08,$f533cf06,$c47f31bc,$648d7222,$29b03458,$dc37d602,$23c0390b,$86d8d87f,
  $67ad61c9,$66b367b7,$573d67b1,$377694d0,$1d651ff8,$d6f783e2,$9ac573d0,$6cb7224e,$fd461fc2,$ecff7301,
  $0117e720,$f60d01ec,$0302f909,$8c5fd87f,$61f95fe1,$39fca432,$4f091fcb,$ce722383,$c362b362,$29974e57,
  $bf60281f,$4f5bc756,$b566c059,$f5a3bb62,$fba06d0d,$98625b59,$f125bd5d,$16e7a982,$83035efe,$22a096a3,
  $6b1e61a8,$5a3d54cb,$643e56d1,$6c9b713e,$173e5ac7,$7bd87f11,$039fd195,$0a1f7bda,$1d40c47f,$fb0642fd,
  $7d7cff2e,$86989f43,$e6dce41a,$839ef99c,$d8f8c04e,$634150bd,$55456aa8,$682e5d53,$5f595bb9,$8b1ea0ad,
  $e0425fea,$d755c3d8,$3f5dc358,$3069a369,$bba91672,$4c605905,$9b74b25a,$ed45e9a5,$2b5e5473,$a672bc5f,
  $4b5e4e5c,$0db2a25b,$3d7caa2a,$831f2f63,$644e73b1,$64316533,$6b415549,$07458bac,$4e45a008,$53b273d8,
  $593a665a,$35fb9fc9,$5e3f65ea,$077a1f42,$79fc05fa,$497efe6f,$a1600947,$bc5e316c,$1a6fa96b,$6220dceb,
  $62239168,$afa09fc1,$60e45fa8,$7f042b37,$1c67cec4,$be70425b,$d954c055,$346c3864,$e5679b5d,$9c524152,
  $ed99d279,$40a22d81,$c8605aca,$ce5fbb5d,$da7fe41d,$69666720,$69d54cb9,$7245474e,$60d4640f,$56404760,
  $b3c943f6,$5bca1d8b,$4aee4bf4,$79295171,$564f5798,$50c159e4,$c14c0edf,$6b46d87f,$22bf5f3f,$7a7f5af9,
  $6bfbfa0d,$01f65883,$7a6e9bd8,$1f780759,$d065c05a,$ab65cc63,$ae751d61,$e84cdc5c,$58624b51,$bc5c815e,
  $5d5ed65f,$0d5d5c5a,$d87ff52b,$5f4c7147,$6da15ed0,$594567c4,$55d550b7,$18af7247,$31c47f03,$dbd20ca4,
  $3f623f63,$9816ad9f,$09a2bf5f,$822fa7fe,$297d7e85,$b45f4067,$8ca34661,$bf5ff876,$7ffe5c2f,$ef6983da,
  $345a5f75,$bf5ebe63,$b75dab6b,$ba6e07a3,$7d782821,$61b26049,$56be6743,$9a72a9c4,$5dba612a,$60306835,
  $6fb6515a,$01e5aaa7,$f1fba05c,$86822977,$58cc76c1,$fe929ac7,$ea4c9fc7,$63485fe9,$66b36435,$6b315fbe,
  $074e96be,$fad89fb8,$594c5fa7,$56d35ac5,$63cf5cc7,$6a149cb0,$603c5fef,$60bf7cc3,$0a44a073,$52d65fcd,
  $e7c6594c,$5e6721da,$0818d781,$ae15c47f,$5fb8aebb,$7f0320bc,$4e84f1f8,$c261f859,$ac4c3e6a,$97864597,
  $9d77dc5c,$ea9fda5f,$19557aa5,$c946fa21,$e413ba35,$13e472b0,$c91132eb,$1d06fe15,$0cadc956,$1635fdef,
  $f435e7c6,$d87fe21a,$59b9870b,$af1c5754,$6156ae57,$ab355c3b,$5f5f41f8,$5ecf6041,$d203993f,$8344215a,
  $9297d57d,$60fa3e09,$7b9e5139,$66b160ca,$060599be,$6d3f60ef,$9f5f60bf,$69b91a00,$20bb73c0,$48dd6883,
  $0cf05e19,$19e2fd05,$ca7c7283,$9c46089c,$dc79831f,$1a089289,$44c4dedd,$db49f4a2,$4460c15f,$5fa1375f,
  $496d8802,$8d75c94f,$ab323978,$ff27fc1c,$080711e3,$c10f2bc7,$22ed0f23,$0af905dc,$9fd87fdc,$fda0bd95,
  $be600bd9,$c275f662,$39f5fd9d,$9c9d4060,$9da007fa,$b5a02926,$049fe80a,$af9febde,$faa02e3a,$d8e7ce61,
  $612e50e6,$67286550,$6c2f6333,$9eb45fc3,$200a9ef7,$7c450268,$5627d87f,$55455bae,$68a56652,$53e25c2f,
  $89d8dd3b,$4769b358,$355f3b57,$c9662f6b,$c565a85e,$6e9dd859,$d17709b2,$306a305b,$2f63be69,$b2683b5f,
  $f7a73c5f,$e4e68a5d,$71e9fe02,$5a485ebe,$5fd25b46,$683e5b3f,$02d8a2ac,$e6849fa8,$66b76057,$a0b961b9,
  $a2b7fe6f,$5fcdd646,$60d26e58,$5d5e601f,$72a05a53,$771664a1,$fad29ab7,$87ffa037,$6b4160d8,$64c05e41,
  $a84018b8,$be4e737d,$30664757,$3f760077,$fba8cb57,$bf7008b2,$1eff661f,$69b1d87f,$76976944,$67bc6c88,
  $6c356395,$58d46da6,$53b9624f,$485052ef,$6b205274,$fa3a9eb7,$59f15f96,$0b83b030,$01531fe8,$3a012301,
  $6eced87f,$70d15e66,$39047f13,$01cb45db,$d723f10d,$c47f1ddb,$f5863e6b,$0cf0133f,$071cb6f9,$f9f8c235,
  $3ee0e343,$ea11eee5,$87d87f19,$375cc871,$2c663d62,$acaabb65,$3e64383a,$3826af9f,$0c55fba0,$75b68321,
  $0691a335,$4a79a008,$61b26858,$a4b95e48,$5fbb22a3,$68ac5ec8,$ba04a72f,$5cc95f8c,$59ec4b3b,$9b4b5dc6,
  $5f2bce01,$5fbf6540,$a4b161bf,$61ea69fe,$9f395fa6,$a0080a81,$613a6641,$62bf632e,$59ce5fb7,$84dae937,
  $4a7b9952,$d80f388f,$fbb1fe9f,$4650ca60,$18623f6b,$4460b678,$9d64a360,$c7632372,$a9b3b85d,$c16009bb,
  $7e4664dc,$32c7fe38,$7ddb5583,$8215daf7,$5ecc8497,$5a536d3e,$66bd60aa,$4ecb663b,$46de6b30,$592769c9,
  $668f6272,$416d5cc5,$7b116c5d,$8ac85f3d,$6d1f3de1,$d5432230,$0a83f0ee,$d454e779,$514d475e,$9667425c,
  $4c61b773,$2c684052,$e590d55b,$c06097c3,$4d584363,$bc5ac45d,$e80eb19f,$1929ff9f,$eb09fda0,$3d63325e,
  $08aba6a3,$77ea6ba0,$99cabea0,$3066bd5f,$7b83f926,$0b9b91d7,$ff1fd803,$9123787f,$658b82f9,$fa1ec975,
  $92e0835f,$5d27ff31,$5a654fe4,$58c4d1d5,$5d47505a,$a04b2414,$db0d13f4,$fce9190b,$d70e0d06,$eef42209,
  $9e787fa2,$595e0396,$a382fd25,$1ec87195,$49ff4ffe,$3802967e,$95a33e65,$b66267fe,$bb63bf60,$38c6e9a4,
  $080256a0,$919f4062,$dae02803,$50ff9ea7,$66887643,$664757c0,$020c98c0,$fe65200e,$5648d87f,$65a964ba,
  $68bd5fc8,$64b35341,$993a68af,$790b7e0f,$612f69b2,$9e395ecb,$5f5ffe5d,$663f5d48,$63b764b5,$5e099f45,
  $63be731d,$60b167b3,$9cc45e4a,$5f4b2a03,$f3dade42,$425edb7d,$89a267a1,$f75b387d,$c4d3b25f,$5f5b5c51,
  $5bd759b2,$7a4d0cac,$646ed87f,$52c972c1,$5e336251,$9e5660bf,$9e7921c9,$5ff80edd,$0600bb41,$64395fbc,
  $7f0519c4,$456a00d8,$5c690e68,$9f7db34e,$c17c3656,$bc45e850,$58982372,$d45de722,$dd57af68,$aa66535d,
  $ad50ef53,$e94f3ab0,$5b21bf5f,$7f03ffff,$e56f4178,$cc3f0958,$d603fcfb,$3cd536ed,$d316f6e0,$07fee01d,
  $a3caff3d,$ea120a61,$de38c329,$14ce1616,$d87f11f3,$563d71b2,$673a5854,$5cc7544b,$59485ec5,$06e4a5ca,
  $25ba6bd8,$d6588301,$08e4f71d,$83201c92,$7af4d348,$fe8e9eb4,$e6a6a767,$5fc35fb7,$99cd5bc6,$a0080280,
  $601bc5fd,$bb449fba,$623d6137,$5db462bd,$1ad0a240,$22bc5ff8,$76fa7ff9,$787a396b,$039ff806,$ae5f384f,
  $d064a170,$380b0f95,$4cadffa0,$b05ece5e,$ac5be164,$be5fbb67,$38d79698,$be7fbd60,$9929831f,$73b80a7b,
  $66375fbc,$e27e9f37,$5f3f6038,$24d8e13e,$314a5685,$c35da574,$b56e2b68,$cd47ef4f,$087aa861,$475a2271,
  $3f4c5564,$3574a876,$605d9468,$015afa4c,$495fc760,$9b67c76f,$187f1626,$f3e48662,$12a00832,$255929a6,
  $ce5bc65e,$ce66375c,$505f265e,$4d5ed15f,$aa642e5a,$c456ba75,$6aaaf0a0,$4b5bc760,$cf56c060,$989dbd5d,
  $499ff806,$e29fc80a,$5a5f27de,$a660425f,$4460a76d,$c25bab69,$183b64ad,$a7ea55a4,$c2594e5f,$47f2b8a4,
  $2a11faa0,$c95fc160,$bb5dc553,$2d604c63,$c85dc55f,$8c46029d,$4560b45f,$5ba03361,$b85ff7f7,$e7f2c3a1,
  $b463c05f,$04015723,$949883f7,$6007cf4f,$6c1d6c3c,$68395761,$712f62ae,$5f227293,$63a76bc5,$643e6b34,
  $a2c4e0aa,$d8d72575,$5fef957c,$faf3a0c2,$21716307,$043058fa,$4fff48fa,$830309ff,$2a0b9307,$2b32655a,
  $fe7e0680,$801f1b19,$cc5dba4d,$f5a5b360,$bf638b99,$551fbf63,$fd0d24fd,$83ff10f5,$3e079403,$60c25fee,
  $5cb967b8,$9fbd6641,$e3b93f7e,$511cd801,$9bc261b7,$eacd56cc,$b05670d8,$bd59c466,$18964464,$ac9ffa92,
  $b660b7d7,$0a1d475d,$5b17d87f,$59c560c1,$68c55ebf,$41fea2b2,$5c447bcb,$5f3b66be,$5dc95f3c,$02b2a241,
  $7a091fe8,$959783fe,$7e09c265,$57ee574a,$d74a5dd1,$d41cc4c4,$64d7d87f,$5d3f5d3f,$6bf94634,$2e599357,
  $96259fd9,$64c15f6c,$5f2e61c0,$7f5728bf,$f16a34d8,$7545dd51,$c867de4b,$f14bb652,$6860c350,$445fac5d,
  $9c5bba6d,$385fb870,$fc39f8a0,$0351021f,$3dff1d01,$d87f03ff,$4c5d6fad,$1d515ae3,$e1f96696,$a15cde2c,
  $fef20c09,$eaf9f025,$e222e227,$787ffe03,$558371c5,$c0555d71,$bd5b4864,$a46d2e63,$c1a05364,$fd2ca802,
  $97d1a082,$60586b14,$a5c25f34,$6ae9d269,$5b4b61be,$9f3d5cc8,$2b38aa8a,$b73b8303,$7f04f206,$bd15fee4,
  $34623c60,$4062b862,$c3a03265,$ff203a7e,$4583026f,$3813269d,$cf5c3660,$9b684d5a,$ce5d386a,$1bca0696,
  $009cc260,$b660ed02,$b360525a,$c45ccd5d,$c661a963,$ffa8465b,$40637c79,$fa7ef65f,$5d12429f,$3c65475f,
  $475e445b,$4b18445f,$d8037f63,$72af8556,$5bcd62a2,$4edd62a8,$5b4c5160,$6adc4ddb,$50466f9d,$4d6b5cd1,
  $a3505bb7,$9ff806f6,$6077d336,$5cb65fbc,$66a160d4,$604a515b,$63cf53cb,$1f9497be,$85832098,$4658c971,
  $f39ecb5d,$c4eeeb45,$604167c1,$5d907b28,$61554c50,$a5b06b46,$1fe80395,$ff03f965,$417d7903,$aa2e01bb,
  $c463ba60,$c3604558,$89f60e97,$d5e08327,$0b41956e,$740b2018,$5d010239,$994883fd,$5ea7df97,$6b0913d6,
  $08df04be,$e745efef,$52beffe1,$e6ee2bdd,$22ce3dfe,$fc102adb,$fff8eaf5,$fbf70bf3,$bcd87f1b,$3b58d095,
  $b6643c60,$68aaeba3,$889f4663,$5b9fd7fa,$3a63c81e,$77eef1a1,$50750220,$0cfff9fe,$967e83f3,$5f5816d1,
  $5fc37d46,$054d3dbe,$fd02f502,$feff1107,$c47f1bea,$cb9ca528,$5b3e6087,$64bb5a54,$a205a42e,$73405fed,
  $71c073bf,$2678f557,$79578351,$f47ae43c,$83569352,$d376d181,$d6d8f95b,$031dbe58,$5b2dd87f,$64316638,
  $1fc85fbb,$02757e4d,$fab4bc48,$7ffd3537,$3261c3d8,$c45cea63,$d8db435f,$5d3a64ef,$62039cc7,$f1f55ffa,
  $8d66d2da,$6355c86a,$c55e5552,$3b65a95e,$bc722e63,$b4732e56,$c8a2c655,$78e5b946,$4bdd6fcc,$11f90fe0,
  $d3707283,$f8a2c455,$495f783f,$90994b59,$27a007ef,$a55f986b,$b461c26c,$88836124,$4afa7495,$5c9f4060,
  $366cb912,$c4dfc463,$1df79ebe,$62497029,$69366039,$9a05a234,$feb39fda,$9e415fb7,$a0198e05,$609d0e00,
  $5e3f66a3,$54565352,$5f3a634e,$55486237,$75faaf40,$22ce744b,$48da7ff1,$327e3898,$2263376f,$bb652471,
  $9c29f6a6,$769fbf63,$8ea397fa,$be607823,$2d1ac15d,$7f02ff72,$3d8583d8,$ca575767,$684c5755,$444cc35b,
  $be4cd766,$3063f64f,$2461cb63,$3d62a070,$3870bd5a,$cd56c8a7,$2b6bc25e,$465e4c5e,$bf5d5a59,$d45c2b64,
  $c860aa62,$d4b0445c,$c85fee09,$25684260,$f8066aa5,$a802439f,$5f3ac4f2,$6b455a3b,$5942612d,$6abe5dc5,
  $8334a337,$5f3f6018,$d6649fe5,$62bf6de9,$edfb9e3d,$e7449fdb,$08622b97,$49dd6183,$93a1d8fa,$f2b535a2,
  $04dc35f1,$0107d31a,$bd220d0f,$fede0f1e,$0622fdfd,$05fde604,$0bce1904,$95c7d87f,$a0ba6439,$201bd9f2,
  $83ff74fc,$1a8094c1,$5fc15fb8,$501d1ff7,$9647aa82,$600816e1,$5ebf643e,$68ff21be,$8361fe0b,$b679da20,
  $ba9e688c,$c35ff8fe,$0e524c1d,$830bfdf6,$6da277b3,$3783a73e,$5c0f6258,$dc4660c0,$c05ed4c4,$fd24395d,
  $7ff5fa7f,$ff5c9d2d,$6be26037,$72437051,$4c321fbf,$5131d87f,$98d8e03c,$425dc356,$f87ffc21,$b3cb5970,
  $b355a00c,$d8d8e00a,$8226c661,$2b73d190,$64ffd8e9,$643b5cc4,$1a979cc1,$dec06fe9,$b46ac5d8,$3452e361,
  $ad67c05e,$19aab09c,$7007d8e4,$61b46044,$60315d4e,$9d96753b,$5fefda12,$e1faa4ba,$5ac7741d,$c0831ecb,
  $87fe519e,$f71ac774,$7d4c2e80,$e2d5b756,$634c7447,$a0c65ac0,$9ffa6dff,$60cef2b2,$66bf6330,$5d416430,
  $5cd8e542,$cc62b47e,$325ec95a,$619e3767,$00a437fb,$01f5b9f2,$fa39fee4,$85b4d8df,$5fc25d51,$64c760b1,
  $614b5dbd,$a22c5eba,$5949461b,$f6aaa33f,$5cbc5ffd,$5d3b5fcf,$63b058d3,$652b6cb7,$73c17901,$d5f59a33,
  $5ec35f8d,$9c4064ba,$5fc7f7e0,$68c45ecf,$59c16628,$67af68b4,$a0d65b38,$632c1dfd,$67ff1fe3,$5b966d83,
  $b75fe817,$4163475f,$bc633f5a,$0bc5eba5,$dca14060,$03200847,$0802fd6a,$b5d87ffb,$64629793,$dd564152,
  $c75a5b53,$45683357,$60506357,$af65c359,$95d2d8e0,$8ee19f40,$c2dae028,$3996df5d,$27fe45a2,$a80686a0,
  $061cc25f,$6138c47f,$a0bd60f1,$a0095621,$68899600,$f2d49f3b,$5bc35fe7,$a0bb5ccc,$61bae5ff,$71c05e6b,
  $1fc16a4b,$4583ff7c,$da613479,$039acd51,$bc5f7e7a,$cd58505d,$bb65365e,$019cca60,$531fecce,$0f16ff22,
  $ffffff06,$f87f0924,$82005134,$b4dae60d,$c156ab53,$d8d8801c,$1f4258da,$3d187f37,$05de035b,$5e705dc3,
  $61fb5fbf,$5ec86507,$7602213c,$07fe597e,$6ae7d8f0,$63c45639,$5a3d69b2,$a83e525a,$e5b93e81,$cd7019d8,
  $366a365c,$2e62c060,$e1a6b866,$3b5fd7fb,$e8029fa1,$d8df3f5f,$993a74cb,$b4994a0b,$9fa80368,$dfecae2c,
  $3b5dc5c4,$0ada91a3,$d823caa0,$b0a7335f,$3f78b7fa,$38633861,$f4a0b865,$785ffb89,$01463121,$fb5e7e7a,
  $e0bd68e7,$4585ebd8,$4663ac5e,$c56a3d59,$c3632062,$366f355c,$d8e1af64,$643a8800,$61516033,$65b65dbf,
  $7df8a537,$5e405f8d,$623c5dc9,$9fee773c,$5f8d663f,$61525b41,$5e495bbe,$ae04a7b1,$b1bf633b,$a018026b,
  $a027faa2,$60ab05fe,$a5c45bbb,$5ffa3e46,$8202a03e,$71ff38b9,$ded87ffd,$b363a993,$3374366b,$7c484c50,
  $356cc952,$b264af59,$ce5614a8,$7c1600a5,$3c604164,$0e8ce4df,$a0665ff8,$5fd9f200,$83681d43,$fe899a66,
  $01631fc7,$f810fb73,$8307f707,$9063d4e6,$5ff922ad,$ca2a9f43,$5f35600a,$66bc60c5,$58546124,$a5b065bd,
  $609e71f9,$54c35d48,$624d5c4e,$642e58c0,$6db95dc0,$56c663ae,$90c762c9,$62e7f72b,$6052787b,$da03e44b,
  $56b25337,$e37cdf42,$c65b4558,$267e015d,$01ed0803,$1761f97a,$96778365,$dfbc22cb,$6af3d801,$683e5d3d,
  $d801deb8,$5d39703c,$283d5ec7,$d73e83f6,$460d903e,$5293a00f,$c33d9ffb,$b7535fff,$600806de,$fb32b23e,
  $1e406037,$88e47f05,$009feaee,$bf751a26,$a89f3d60,$c2602e32,$9913399f,$17fb61a7,$7f015d23,$9d8622d8,
  $256e3d60,$3c624d5b,$d87ff123,$60378819,$32029e45,$f652a02d,$59c97688,$20c15dca,$aef87f06,$c806d78d,
  $07f6d49f,$01a13e60,$fe2b5cca,$debe7d76,$940bd801,$57e45447,$5dd65544,$543458d7,$634f5bca,$67285e47,
  $5eb568af,$9ada554f,$9ff807d7,$2898034e,$62014202,$61948983,$3e68d802,$079fb365,$bd601b7a,$3365be5d,
  $999ac962,$499fc80a,$f99ff806,$4d5ef7f6,$791de6a6,$d05c465c,$ae55f59e,$b55cca5f,$c4e53862,$66c75a44,
  $63b964ad,$6dc45b45,$a04f56aa,$1ff806f1,$ff03ff4b,$052dfe4a,$38fcfffe,$513af87f,$dffd79ff,$3a56c3d8,
  $4808dee0,$cb5b475b,$f15dcf5d,$1b61fd5e,$3a6b0265,$78e3b563,$a8827043,$5a009486,$91ff9fdf,$9752b98d,
  $df4375cd,$ff7c54f8,$3d797a79,$9e3a8320,$e749b6bf,$1881ddda,$b95e5186,$4d5eb961,$c85fb363,$d87f071a,
  $1f348829,$4e70bc83,$47f322af,$ea39fda0,$7446bf77,$a80f94a0,$17fadea9,$e8a0bd6d,$742007fb,$943fd87f,
  $69b35dbc,$58c85a3f,$98d35acc,$9ff7ffb3,$a8481351,$664a0a21,$fa979d3d,$64436e27,$dcbf5f3e,$7a3604e4,
  $be604164,$2b6217b1,$3767bf5f,$fd9dc062,$061ffe55,$ef226c82,$72068307,$594055d8,$6f3c54db,$1de5aca7,
  $034f221b,$02fd2eff,$ff171d17,$b9da7f2e,$bf56c64e,$7107dee2,$4c5b4b59,$d15dd55b,$215ef25d,$fc22bf65,
  $6b0bd87f,$0ddae03d,$4070556c,$0f2dfba0,$8b5689a0,$fea1bd75,$f8e3fe55,$ee7e7935,$13e5a00a,$fe019fd8,
  $7dfda997,$7f382bde,$6b81dedc,$40863482,$03a2b95f,$be5fcfd6,$dd2dfba1,$82be3f64,$c35fe817,$fe55fa9f,
  $d0d78337,$06c898d6,$4c78fe48,$d82b8394,$fd02b60b,$973ff87f,$1ffa1aa3,$1a887e62,$84822f28,$7f0211a0,
  $fea43fc4,$d16489fd,$f09fda67,$c45f7806,$bb66ba5a,$ca5f3d5d,$b7dfa49c,$c458bc60,$4966b565,$5e5f3f58,
  $9b620790,$fffe4523,$0d2a2910,$513dfc7f,$58e85299,$fdaa29ff,$5dd804de,$5f4f882f,$e0416201,$fc6529f8,
  $d8f549c1,$dec06b11,$5b6bcafa,$ff1dff70,$dee0bf75,$d4767007,$667c6777,$6c7e957c,$c5863a82,$495ac25c,
  $c807f1a1,$ed0a049f,$da29ff9f,$fd9ec178,$7ead3af1,$dadffb2f,$946291bc,$e33a63b3,$4097c4d8,$9a56dcfd,
  $9b1e9a59,$1731a040,$613a5f88,$99c364be,$5fceb201,$66475a38,$662b68ac,$593e65b8,$9abf63c9,$60db5204,
  $6ad26061,$263f5fdb,$e1c47f0c,$7ee03e5f,$cd56d309,$6d5b4e56,$ed652d5c,$1366ee66,$83705f6b,$04fefa49,
  $74db7223,$77d574e5,$dff9fb62,$7c6a05fe,$7f897e97,$8643826d,$1fe7fff4,$941c7f16,$9e8b958b,$9dda038e,
  $3f91be8e,$946bd8e2,$e578e03d,$fd7e6196,$1e27f80d,$9a5ef87f,$709a0e76,$9e3c5fc3,$1fce8601,$d7a48309,
  $9f367f83,$67da6e06,$de03f6e7,$2e56d404,$1865b865,$031f406b,$6207fe7f,$aa722670,$d977d872,$69793977,
  $3a2a017c,$fe213e7a,$81e01c7f,$864681e1,$8979d803,$0dffa0c0,$d801f98a,$dfbf8ea5,$ff946e78,$04fed580,
  $98729749,$9c68995f,$39d7fe05,$97a79182,$61394e8f,$1fc2787d,$08de7fff,$7066571e,$883c7c6f,$8ea68db2,
  $947491c3,$7fff1f43,$749a607a,$9b67839c,$2e27ff9e,$fe047f14,$689fa405,$f7706570,$d3866a7c,$fee017ff,
  $9c8b9e05,$c98ea98c,$27974b8e,$94a57803,$416b8926,$240adee0,$179e159b,$079f489e,$276b1e62,$a8864c72,
  $3e94828e,$6911fee0,$2e9a689a,$299e199b,$9f864b72,$7994838b,$759eb79c,$7a9a6b76,$699e1d9c,$a4706a70,
  $e72ed99e,$8108dee4,$cf92b978,$5258bb88,$fa7ca760,$d125545a,$b765c858,$b55a4e5b,$d67ff128,$34674203,
  $c858d15c,$4e5bb765,$567ff51a,$00259305,$043e1fe0,$04190419,$04190419,$00005e1f);


procedure unpack_hieroglyphs(Dest: PWord; Src: PByte);
label
  loop,
  mode_2x3, mode_2x7, mode_3x2, mode_4x3, mode_7x2, mode_10x3, mode_many,
  fill_fffd;
const
  MASK_2 = (1 shl 2)-1;
  MASK_3 = (1 shl 3)-1;
  MASK_4 = (1 shl 4)-1;
  MASK_7 = (1 shl 7)-1;
  MASK_10 = (1 shl 10)-1;
  MASK_14 = (1 shl 14)-1;

  HALF_4 = (1 shl 4) div 2;
  HALF_7 = (1 shl 7) div 2;
  HALF_10 = (1 shl 10) div 2;
  HALF_14 = (1 shl 14) div 2;

  M_4 = 4-1;
  M_7 = 7-1;
  M_10 = 10-1;
  M_14 = 14-1;

  Words_in_native = SizeOf(NativeUInt) div SizeOf(Word);
  fffd_counts: array[0..10] of Word = ($ffff,1,33,295,359,375,383,507,579,720,1027);
  increment_counts: array[0..14] of Word = (1,2,3,4,5,6,7,8,9,10,11,12,157,294,315);
  copy_counts: array[0..4] of Word = (283,420,454,964,1151);

  {$ifNdef LARGEINT}
  fffd_value = NativeUInt($fffdfffd);
  {$else}
var
  fffd_value: NativeUInt;
  {$endif}

var
  current: Integer;
  m, v, cnt: Integer;
begin
  {$ifdef LARGEINT}
  fffd_value := $fffdfffdfffdfffd;
  {$endif}
  current := PWord(Src)^;
  Inc(Src, SizeOf(Word));

loop:
  v := pshortint(Src)^;
  Inc(Src);

  case v of
  -128: mode_2x3: // 2*3+2 = 1 [1..4]
  begin
    v := Src^;
    Inc(Src);

    current := current + 1 + (v and MASK_2);
    v := v shr 2;
    Dest^ := current;
    Inc(Dest);
    current := current + 1 + (v and MASK_2);
    v := v shr 2;
    Dest^ := current;
    Inc(Dest);
    current := current + 1 + (v and MASK_2);
    v := v shr 2;
    Dest^ := current;
    Inc(Dest);

    case v of
      1: goto mode_7x2;
      2: goto mode_4x3;
      3: goto mode_many;
    else {0}
      goto loop;
    end;
  end;
  -127: mode_2x7: // 2*7+2 = 2 [1..4]
  begin
    v := PWord(Src)^;
    Inc(Src, 2);

    current := current + 1 + (v and MASK_2);
    v := v shr 2;
    Dest^ := current;
    Inc(Dest);
    current := current + 1 + (v and MASK_2);
    v := v shr 2;
    Dest^ := current;
    Inc(Dest);
    current := current + 1 + (v and MASK_2);
    v := v shr 2;
    Dest^ := current;
    Inc(Dest);
    current := current + 1 + (v and MASK_2);
    v := v shr 2;
    Dest^ := current;
    Inc(Dest);
    current := current + 1 + (v and MASK_2);
    v := v shr 2;
    Dest^ := current;
    Inc(Dest);
    current := current + 1 + (v and MASK_2);
    v := v shr 2;
    Dest^ := current;
    Inc(Dest);
    current := current + 1 + (v and MASK_2);
    v := v shr 2;
    Dest^ := current;
    Inc(Dest);

    case v of
      1: goto mode_2x7;
      2: goto mode_4x3;
      3: goto mode_many;
    else {0}
      goto mode_2x3;
    end;
  end;
  -126: mode_3x2: // 3*2+2 = 1 [1..8]
  begin
    v := Src^;
    Inc(Src);

    current := current + 1 + (v and MASK_3);
    v := v shr 3;
    Dest^ := current;
    Inc(Dest);
    current := current + 1 + (v and MASK_3);
    v := v shr 3;
    Dest^ := current;
    Inc(Dest);

    case v of
      1: goto mode_3x2;
      2: goto mode_4x3;
      3: goto mode_many;
    else {0}
      goto loop;
    end;
  end;
  -125: mode_4x3: // 4*(2/3)+3 = 2 [-8..8]
  begin
    v := PWord(Src)^;
    Inc(Src, 2);

    m := ((v shr M_4) and 1);
    current := current - HALF_4 + ((v and MASK_4) + m);
    v := v shr 4;
    Dest^ := current;
    Inc(Dest);
    m := ((v shr M_4) and 1);
    current := current - HALF_4 + ((v and MASK_4) + m);
    v := v shr 4;
    Dest^ := current;
    Inc(Dest);

    if (v and (1 shl 4) <> 0) then
    begin
      m := ((v shr M_4) and 1);
      current := current - HALF_4 + ((v and MASK_4) + m);
      Dest^ := current;
      Inc(Dest);
    end;

    case (v shr 5) of
      1: goto mode_2x3;
      2: goto mode_2x7;
      3: goto mode_7x2;
      4: goto mode_10x3;
      5: goto mode_3x2;
      6: goto mode_4x3;
      7: goto mode_many;
    else {0}
      goto loop;
    end;
  end;
  -124..124: // default
  begin
    Inc(current, v);
    Dest^ := current;
    Inc(Dest);
    goto loop;
  end;
  125: mode_7x2: // 7*2+2 = 2 [-64..64]
  begin
    v := PWord(Src)^;
    Inc(Src, 2);

    m := ((v shr M_7) and 1);
    current := current - HALF_7 + ((v and MASK_7) + m);
    v := v shr 7;
    Dest^ := current;
    Inc(Dest);
    m := ((v shr M_7) and 1);
    current := current - HALF_7 + ((v and MASK_7) + m);
    v := v shr 7;
    Dest^ := current;
    Inc(Dest);

    case v of
      1: goto mode_7x2;
      2: goto mode_10x3;
      3: goto mode_many;
    else {0}
      goto loop;
    end;
  end;
  126: mode_10x3: // 10*3+2 = 4 [-512..512]
  begin
    v := PCardinal(Src)^;
    Inc(Src, 4);

    m := ((v shr M_10) and 1);
    current := current - HALF_10 + ((v and MASK_10) + m);
    v := v shr 10;
    Dest^ := current;
    Inc(Dest);
    m := ((v shr M_10) and 1);
    current := current - HALF_10 + ((v and MASK_10) + m);
    v := v shr 10;
    Dest^ := current;
    Inc(Dest);
    m := ((v shr M_10) and 1);
    current := current - HALF_10 + ((v and MASK_10) + m);
    v := v shr 10;
    Dest^ := current;
    Inc(Dest);

    case v of
      1: goto mode_7x2;
      2: goto mode_10x3;
      3: goto mode_many;
    else {0}
      goto loop;
    end;
  end;
  127: mode_many: // increment/fffd/data/done
  begin
    v := Src^;
    Inc(Src);
    if (v = 0) then Exit;

    cnt := (v shr 1) and MASK_4; // 0..15
    if (v and 1 = 0) then
    begin
      // fffd/data
      case cnt of
        0: {none};
        1..10: // fffd (cnt = table)
        begin
          cnt := fffd_counts[cnt];

          fill_fffd:
          while (cnt >= Words_in_native) do
          begin
            PNativeUInt(Dest)^ := fffd_value;
            Dec(cnt, Words_in_native);
            Inc(Dest, Words_in_native);
          end;
          {$ifdef LARGEINT}
          if (cnt and 2 <> 0) then
          begin
            PCardinal(Dest)^ := $fffdfffd;
            Inc(Dest, 2);
          end;
          {$endif}
          if (cnt and 1 <> 0) then
          begin
            Dest^ := $fffd;
            Inc(Dest);
          end;
        end;
        11: // fffd (cnt = Byte)
        begin
          cnt := Src^;
          Inc(Src);
          goto fill_fffd;
        end;
        12: // copy 1
        begin
          current := PWord(Src)^;
          Inc(Src, 2);
          Dest^ := current;
          Inc(Dest);
        end;
        13: // copy 2
        begin
          current := PCardinal(Src)^;
          Inc(Src, 4);
          PCardinal(Dest)^ := current;
          Inc(Dest, 2);
          current := current shr 16;
        end;
        14: // copy 3
        begin
          current := PCardinal(Src)^;
          Inc(Src, 4);
          PCardinal(Dest)^ := current;
          Inc(Dest, 2);

          current := PWord(Src)^;
          Inc(Src, 2);
          Dest^ := current;
          Inc(Dest);
        end;
        15: // copy (cnt = Byte/table)
        begin
          cnt := Src^;
          Inc(Src);
          if (cnt >= 251) then cnt := copy_counts[cnt-251];

          while (cnt >= Words_in_native) do
          begin
            PNativeUInt(Dest)^ := PNativeUInt(Src)^;
            Inc(Src, SizeOf(NativeUint));
            Dec(cnt, Words_in_native);
            Inc(Dest, Words_in_native);
          end;
          {$ifdef LARGEINT}
          if (cnt and 2 <> 0) then
          begin
            PCardinal(Dest)^ := PCardinal(Src)^;
            Inc(Src, 4);
            Inc(Dest, 2);
          end;
          {$endif}
          if (cnt and 1 <> 0) then
          begin
            Dest^ := PWord(Src)^;
            Inc(Src, 2);
            Inc(Dest);
          end;
          Dec(Dest);
          current := Dest^;
          Inc(Dest);
        end;
      end;
    end else
    begin
      // increment
      if (cnt = 15) then
      begin
        cnt := Src^;
        Inc(Src);
      end else
      begin
        cnt := increment_counts[cnt];
      end;
      repeat
        Inc(current);
        Dec(cnt);
        Dest^ := current;
        Inc(Dest);
      until (cnt = 0);
    end;

    case (v shr 5) of
      0: goto mode_many;
      1: begin
           current := PWord(Src)^;
           Inc(Src, 2);
           Dest^ := current;
           Inc(Dest);

           goto mode_many;
         end;
      2: begin
           current := PCardinal(Src)^;
           Inc(Src, 4);
           PCardinal(Dest)^ := current;
           Inc(Dest, 2);
           current := current shr 16;

           goto mode_many;
         end;
      3: goto loop;
      4: goto mode_2x3;
      5: goto mode_2x7;
      6: goto mode_7x2;
    else {7}
      goto mode_10x3;
    end;
  end;
  end;
end;


type
  TWordTableAlloc = function(): PWordTable;

function universal_table_alloc(var Destination: PWordTable; Count: Cardinal; Data: Pointer): PWordTable;
begin
  Result := Destination;
  if (Result <> nil) then Exit;

  Result := InternalLookupAlloc(Count*2);
  unpack_hieroglyphs(Pointer(Result), Data);

  Result := InternalLookupFill(Pointer(Destination), Result);
end;

function universal_hash_alloc(var Destination: PWordHash; Count, Divisor: NativeInt; Table: PWordTable; Callback: TWordTableAlloc): PWordHash;
var
  Size: Integer;
  W: PWord;

  X: NativeUInt;
  Index: NativeInt;
  HashIndex: NativeInt;

  High_Value, Value: Cardinal;
begin
  Result := Destination;
  if (Result <> nil) then Exit;

  High_Value := Divisor shl 8;
  if (Table = nil) then Table := Callback;

  Size := SizeOf(TWordHash) + Count*SizeOf(TWordHashItem);
  Result := InternalLookupAlloc(Size);
  FillChar(Result^, Size, #0);

  W := Pointer(Table);
  Index := 1;
  Value := 0;
  repeat
    X := W^;
    if (X <> $fffd) then
    begin
      // hash insert
      Result.Items[Index].X := X;
      Result.Items[Index].Value := Value;
      HashIndex := X and High(Result.Indexes);
      Result.Items[Index].Next := Result.Indexes[HashIndex];
      Result.Indexes[HashIndex] := Index;

      Inc(Index);
    end;

    // modified Value
    Inc(Value, $0100);
    if (Value >= High_Value) then
    begin
      Value := (Value and $ff) + 1;
    end;

    Inc(W);
  until (Index > Count);

  Result := InternalLookupFill(Pointer(Destination), Result);
end;


{ TWordHash }

function TWordHash.Find(const X: Cardinal): Word;
var
  _X: Word;
  Index: NativeInt;
  Item: PWordHashItem;
begin
  if (X <= $ffff) and (X <> $fffd) then
  begin
    _X := X;
    Index := Indexes[X and High(Indexes)];

    while (Index <> 0) do
    begin
      Item := @Items[Index];
      if (Item.X = _X) then
      begin
        Result := Item.Value;
        Exit;
      end;

      Index := Item.Next;
    end;
  end;

  Result := $ffff;
end;

function generate_table_jisx0208: PWordTable;
begin
  Result := universal_table_alloc(table_jisx0208, 8835, @jisx0208_data);
end;

function generate_table_jisx0212: PWordTable;
begin
  Result := universal_table_alloc(table_jisx0212, 7238, @jisx0212_data);
end;

function generate_table_ksc5601: PWordTable;
begin
  Result := universal_table_alloc(table_ksc5601, 8835, @ksc5601_data);
end;

function generate_table_uhc_1: PWordTable;
begin
  Result := universal_table_alloc(table_uhc_1, 5696, @uhc_1_data);
end;

function generate_table_uhc_2: PWordTable;
begin
  Result := universal_table_alloc(table_uhc_2, 3126, @uhc_2_data);
end;

function generate_table_gb2312: PWordTable;
begin
  Result := universal_table_alloc(table_gb2312, 8178, @gb2312_data);
end;

function generate_table_gbkext1: PWordTable;
begin
  Result := universal_table_alloc(table_gbkext1, 6080, @gbkext1_data);
end;

function generate_table_gbkext2: PWordTable;
begin
  Result := universal_table_alloc(table_gbkext2, 8352, @gbkext2_data);
end;

function generate_table_gb18030ext: PWordTable;
begin
  Result := universal_table_alloc(table_gb18030ext, 1900, @gb18030ext_data);
end;

function generate_table_big5: PWordTable;
begin
  Result := universal_table_alloc(table_big5, 24130, @big5_data);
end;

function generate_range_gb18030_read: PWordTable;
begin
  Result := universal_table_alloc(range_gb18030_read, 412, @range_gb18030_read_data);
end;

function generate_range_gb18030_write: PWordTable;
begin
  Result := universal_table_alloc(range_gb18030_write, 412, @range_gb18030_write_data);
end;

function generate_offsets_gb18030: PWordTable;
begin
  Result := universal_table_alloc(offsets_gb18030, 206, @offsets_gb18030_data);
end;

procedure generate_hash_jisx0208;
begin
  universal_hash_alloc(hash_jisx0208, 6879, 94, table_jisx0208, generate_table_jisx0208);
end;

procedure generate_hash_jisx0212;
begin
  universal_hash_alloc(hash_jisx0212, 6067, 94, table_jisx0212, generate_table_jisx0212);
end;

procedure generate_hash_ksc5601;
begin
  universal_hash_alloc(hash_ksc5601, 8227, 94, table_ksc5601, generate_table_ksc5601);
end;

procedure generate_hash_uhc_1;
begin
  universal_hash_alloc(hash_uhc_1, 5696, 178, table_uhc_1, generate_table_uhc_1);
end;

procedure generate_hash_uhc_2;
begin
  universal_hash_alloc(hash_uhc_2, 3126, 84, table_uhc_2, generate_table_uhc_2);
end;

procedure generate_hash_gb2312;
begin
  universal_hash_alloc(hash_gb2312, 7445, 94, table_gb2312, generate_table_gb2312);
end;

procedure generate_hash_gbkext1;
begin
  universal_hash_alloc(hash_gbkext1, 6080, 190, table_gbkext1, generate_table_gbkext1);
end;

procedure generate_hash_gbkext2;
begin
  universal_hash_alloc(hash_gbkext2, 8233, 96, table_gbkext2, generate_table_gbkext2);
end;

procedure generate_hash_gb18030ext;
begin
  universal_hash_alloc(hash_gb18030ext, 249, 190, table_gb18030ext, generate_table_gb18030ext);
end;

procedure generate_hash_big5;
begin
  universal_hash_alloc(hash_big5, 19302, 190, table_big5, generate_table_big5);
end;
{$ifdef undef}{$ENDREGION}{$endif}

{$ifdef undef}{$REGION 'SBCS<-->UTF8<-->UTF16 conversions'}{$endif}
procedure sbcs_from_sbcs(var Dest: AnsiString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}SrcCodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}SrcCodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Index := NativeUInt(SrcCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccOriginal);

  // conversion
  Buffer := AStrInit(Dest, nil, Length, DestCodePage);
  Tiny.Text.sbcs_from_sbcs(Buffer, Pointer(Src), Length, Converter);
end;

{inline} function sbcs_from_sbcs(const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}): AnsiString;
begin
  Tiny.Text.sbcs_from_sbcs(Result, Src, DestCodePage{$ifNdef INTERNALCODEPAGE}, SrcCodePage{$endif});
end;

procedure sbcs_from_sbcs(var Dest: ShortString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  if (Length > NativeUInt(High(Dest))) then Length := NativeUInt(High(Dest));
  PByte(@Dest)^ := Length;

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Index := NativeUInt(SrcCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccOriginal);

  // conversion
  Tiny.Text.sbcs_from_sbcs(Pointer(@Dest[1]), Pointer(@Src[1]), Length, Converter);
end;

procedure sbcs_from_sbcs(var Dest: AnsiString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Index := NativeUInt(SrcCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccOriginal);

  // conversion
  Buffer := AStrInit(Dest, nil, Length, DestCodePage);
  Tiny.Text.sbcs_from_sbcs(Buffer, Pointer(@Src[1]), Length, Converter);
end;

{inline} function sbcs_from_sbcs(const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_sbcs(Result, Src, DestCodePage, SrcCodePage);
end;

procedure sbcs_from_sbcs(var Dest: ShortString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}SrcCodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  if (Length > NativeUInt(High(Dest))) then Length := NativeUInt(High(Dest));
  PByte(@Dest)^ := Length;
  {$ifdef INTERNALCODEPAGE}SrcCodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Index := NativeUInt(SrcCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccOriginal);

  // conversion
  Tiny.Text.sbcs_from_sbcs(Pointer(@Dest[1]), Pointer(Src), Length, Converter);
end;

procedure sbcs_from_sbcs_lower(var Dest: AnsiString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}SrcCodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}SrcCodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  if (SrcCodePage = DestCodePage) then
  begin
    Converter := SBCS.FLowerCase;
    if (Converter = nil) then Converter := SBCS.FromSBCS(SBCS, ccLower);
  end else
  begin
    Index := NativeUInt(SrcCodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccLower);
  end;

  // conversion
  Buffer := AStrInit(Dest, nil, Length, DestCodePage);
  Tiny.Text.sbcs_from_sbcs_lower(Buffer, Pointer(Src), Length, Converter);
end;

{inline} function sbcs_from_sbcs_lower(const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}): AnsiString;
begin
  Tiny.Text.sbcs_from_sbcs_lower(Result, Src, DestCodePage{$ifNdef INTERNALCODEPAGE}, SrcCodePage{$endif});
end;

procedure sbcs_from_sbcs_lower(var Dest: ShortString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  if (Length > NativeUInt(High(Dest))) then Length := NativeUInt(High(Dest));
  PByte(@Dest)^ := Length;

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  if (SrcCodePage = DestCodePage) then
  begin
    Converter := SBCS.FLowerCase;
    if (Converter = nil) then Converter := SBCS.FromSBCS(SBCS, ccLower);
  end else
  begin
    Index := NativeUInt(SrcCodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccLower);
  end;

  // conversion
  Tiny.Text.sbcs_from_sbcs_lower(Pointer(@Dest[1]), Pointer(@Src[1]), Length, Converter);
end;

procedure sbcs_from_sbcs_lower(var Dest: AnsiString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  if (SrcCodePage = DestCodePage) then
  begin
    Converter := SBCS.FLowerCase;
    if (Converter = nil) then Converter := SBCS.FromSBCS(SBCS, ccLower);
  end else
  begin
    Index := NativeUInt(SrcCodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccLower);
  end;

  // conversion
  Buffer := AStrInit(Dest, nil, Length, DestCodePage);
  Tiny.Text.sbcs_from_sbcs_lower(Buffer, Pointer(@Src[1]), Length, Converter);
end;

{inline} function sbcs_from_sbcs_lower(const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_sbcs_lower(Result, Src, DestCodePage, SrcCodePage);
end;

procedure sbcs_from_sbcs_lower(var Dest: ShortString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}SrcCodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  if (Length > NativeUInt(High(Dest))) then Length := NativeUInt(High(Dest));
  PByte(@Dest)^ := Length;
  {$ifdef INTERNALCODEPAGE}SrcCodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  if (SrcCodePage = DestCodePage) then
  begin
    Converter := SBCS.FLowerCase;
    if (Converter = nil) then Converter := SBCS.FromSBCS(SBCS, ccLower);
  end else
  begin
    Index := NativeUInt(SrcCodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccLower);
  end;

  // conversion
  Tiny.Text.sbcs_from_sbcs_lower(Pointer(@Dest[1]), Pointer(Src), Length, Converter);
end;

procedure sbcs_from_sbcs_upper(var Dest: AnsiString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}SrcCodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}SrcCodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  if (SrcCodePage = DestCodePage) then
  begin
    Converter := SBCS.FUpperCase;
    if (Converter = nil) then Converter := SBCS.FromSBCS(SBCS, ccUpper);
  end else
  begin
    Index := NativeUInt(SrcCodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccUpper);
  end;

  // conversion
  Buffer := AStrInit(Dest, nil, Length, DestCodePage);
  Tiny.Text.sbcs_from_sbcs_upper(Buffer, Pointer(Src), Length, Converter);
end;

{inline} function sbcs_from_sbcs_upper(const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif}): AnsiString;
begin
  Tiny.Text.sbcs_from_sbcs_upper(Result, Src, DestCodePage{$ifNdef INTERNALCODEPAGE}, SrcCodePage{$endif});
end;

procedure sbcs_from_sbcs_upper(var Dest: ShortString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  if (Length > NativeUInt(High(Dest))) then Length := NativeUInt(High(Dest));
  PByte(@Dest)^ := Length;

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  if (SrcCodePage = DestCodePage) then
  begin
    Converter := SBCS.FUpperCase;
    if (Converter = nil) then Converter := SBCS.FromSBCS(SBCS, ccUpper);
  end else
  begin
    Index := NativeUInt(SrcCodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccUpper);
  end;

  // conversion
  Tiny.Text.sbcs_from_sbcs_upper(Pointer(@Dest[1]), Pointer(@Src[1]), Length, Converter);
end;

procedure sbcs_from_sbcs_upper(var Dest: AnsiString; const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  if (SrcCodePage = DestCodePage) then
  begin
    Converter := SBCS.FUpperCase;
    if (Converter = nil) then Converter := SBCS.FromSBCS(SBCS, ccUpper);
  end else
  begin
    Index := NativeUInt(SrcCodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccUpper);
  end;

  // conversion
  Buffer := AStrInit(Dest, nil, Length, DestCodePage);
  Tiny.Text.sbcs_from_sbcs_upper(Buffer, Pointer(@Src[1]), Length, Converter);
end;

{inline} function sbcs_from_sbcs_upper(const Src: ShortString; const DestCodePage: Word = 0; const SrcCodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_sbcs_upper(Result, Src, DestCodePage, SrcCodePage);
end;

procedure sbcs_from_sbcs_upper(var Dest: ShortString; const Src: AnsiString; const DestCodePage: Word = 0{$ifNdef INTERNALCODEPAGE}; const SrcCodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}SrcCodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  if (Length > NativeUInt(High(Dest))) then Length := NativeUInt(High(Dest));
  PByte(@Dest)^ := Length;
  {$ifdef INTERNALCODEPAGE}SrcCodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(DestCodePage);
  Index := NativeUInt(DestCodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = DestCodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  if (SrcCodePage = DestCodePage) then
  begin
    Converter := SBCS.FUpperCase;
    if (Converter = nil) then Converter := SBCS.FromSBCS(SBCS, ccUpper);
  end else
  begin
    Index := NativeUInt(SrcCodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = SrcCodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    Converter := SBCS.FromSBCS(Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS)), ccUpper);
  end;

  // conversion
  Tiny.Text.sbcs_from_sbcs_upper(Pointer(@Dest[1]), Pointer(Src), Length, Converter);
end;

procedure sbcs_from_utf8(var Dest: AnsiString; const Src: UTF8String; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf8(Buffer, Pointer(Src), Length, Converter), CodePage);
end;

{inline} function sbcs_from_utf8(const Src: UTF8String; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf8(Result, Src, CodePage);
end;

procedure sbcs_from_utf8(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(@Src[1]);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf8;
  if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure sbcs_from_utf8(var Dest: AnsiString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf8(Buffer, Pointer(@Src[1]), Length, Converter), CodePage);
end;

{inline} function sbcs_from_utf8(const Src: ShortString; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf8(Result, Src, CodePage);
end;

procedure sbcs_from_utf8(var Dest: ShortString; const Src: UTF8String; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf8;
  if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure sbcs_from_utf8_lower(var Dest: AnsiString; const Src: UTF8String; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf8_lower(Buffer, Pointer(Src), Length, Converter), CodePage);
end;

{inline} function sbcs_from_utf8_lower(const Src: UTF8String; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf8_lower(Result, Src, CodePage);
end;

procedure sbcs_from_utf8_lower(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(@Src[1]);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf8_lower;
  if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure sbcs_from_utf8_lower(var Dest: AnsiString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf8_lower(Buffer, Pointer(@Src[1]), Length, Converter), CodePage);
end;

{inline} function sbcs_from_utf8_lower(const Src: ShortString; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf8_lower(Result, Src, CodePage);
end;

procedure sbcs_from_utf8_lower(var Dest: ShortString; const Src: UTF8String; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf8_lower;
  if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure sbcs_from_utf8_upper(var Dest: AnsiString; const Src: UTF8String; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf8_upper(Buffer, Pointer(Src), Length, Converter), CodePage);
end;

{inline} function sbcs_from_utf8_upper(const Src: UTF8String; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf8_upper(Result, Src, CodePage);
end;

procedure sbcs_from_utf8_upper(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(@Src[1]);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf8_upper;
  if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure sbcs_from_utf8_upper(var Dest: AnsiString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf8_upper(Buffer, Pointer(@Src[1]), Length, Converter), CodePage);
end;

{inline} function sbcs_from_utf8_upper(const Src: ShortString; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf8_upper(Result, Src, CodePage);
end;

procedure sbcs_from_utf8_upper(var Dest: ShortString; const Src: UTF8String; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf8_upper;
  if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure sbcs_from_utf16(var Dest: AnsiString; const Src: WideString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  {$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf16(Buffer, Pointer(Src), Length, Converter), CodePage);
end;

{$ifdef UNICODE}
procedure sbcs_from_utf16(var Dest: AnsiString; const Src: UnicodeString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf16(Buffer, Pointer(Src), Length, Converter), CodePage);
end;
{$endif}

{inline} function sbcs_from_utf16(const Src: WideString; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf16(Result, Src, CodePage);
end;

{$ifdef UNICODE}
{inline} function sbcs_from_utf16(const Src: UnicodeString; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf16(Result, Src, CodePage);
end;
{$endif}

procedure sbcs_from_utf16(var Dest: ShortString; const Src: WideString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  {$endif}
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf16;
  if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

{$ifdef UNICODE}
procedure sbcs_from_utf16(var Dest: ShortString; const Src: UnicodeString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf16;
  if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;
{$endif}

procedure sbcs_from_utf16_lower(var Dest: AnsiString; const Src: WideString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  {$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf16_lower(Buffer, Pointer(Src), Length, Converter), CodePage);
end;

{$ifdef UNICODE}
procedure sbcs_from_utf16_lower(var Dest: AnsiString; const Src: UnicodeString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf16_lower(Buffer, Pointer(Src), Length, Converter), CodePage);
end;
{$endif}

{inline} function sbcs_from_utf16_lower(const Src: WideString; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf16_lower(Result, Src, CodePage);
end;

{$ifdef UNICODE}
{inline} function sbcs_from_utf16_lower(const Src: UnicodeString; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf16_lower(Result, Src, CodePage);
end;
{$endif}

procedure sbcs_from_utf16_lower(var Dest: ShortString; const Src: WideString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  {$endif}
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf16_lower;
  if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

{$ifdef UNICODE}
procedure sbcs_from_utf16_lower(var Dest: ShortString; const Src: UnicodeString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf16_lower;
  if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;
{$endif}

procedure sbcs_from_utf16_upper(var Dest: AnsiString; const Src: WideString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  {$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf16_upper(Buffer, Pointer(Src), Length, Converter), CodePage);
end;

{$ifdef UNICODE}
procedure sbcs_from_utf16_upper(var Dest: AnsiString; const Src: UnicodeString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);

  // conversion
  Buffer := AStrReserve(Dest, Length);
  AStrSetLength(Dest, Tiny.Text.sbcs_from_utf16_upper(Buffer, Pointer(Src), Length, Converter), CodePage);
end;
{$endif}

{inline} function sbcs_from_utf16_upper(const Src: WideString; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf16_upper(Result, Src, CodePage);
end;

{$ifdef UNICODE}
{inline} function sbcs_from_utf16_upper(const Src: UnicodeString; const CodePage: Word = 0): AnsiString;
begin
  Tiny.Text.sbcs_from_utf16_upper(Result, Src, CodePage);
end;
{$endif}

procedure sbcs_from_utf16_upper(var Dest: ShortString; const Src: WideString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  {$endif}
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf16_upper;
  if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

{$ifdef UNICODE}
procedure sbcs_from_utf16_upper(var Dest: ShortString; const Src: UnicodeString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FVALUES;
  if (Converter = nil) then Converter := SBCS.AllocFillVALUES(SBCS.FVALUES);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.sbcs_from_utf16_upper;
  if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;
{$endif}

procedure utf8_from_sbcs(var Dest: UTF8String; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Original;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Original, ccOriginal);

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_sbcs(Buffer, Pointer(Src), Length, Converter), CODEPAGE_UTF8);
end;

{inline} function utf8_from_sbcs(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UTF8String;
begin
  Tiny.Text.utf8_from_sbcs(Result, Src{$ifNdef INTERNALCODEPAGE}, CodePage{$endif});
end;

procedure utf8_from_sbcs(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(@Src[1]);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Original;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Original, ccOriginal);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_sbcs;
  Context.convert_utf8_from_sbcs;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure utf8_from_sbcs(var Dest: UTF8String; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Original;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Original, ccOriginal);

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_sbcs(Buffer, Pointer(@Src[1]), Length, Converter), CODEPAGE_UTF8);
end;

{inline} function utf8_from_sbcs(const Src: ShortString; const CodePage: Word = 0): UTF8String;
begin
  Tiny.Text.utf8_from_sbcs(Result, Src, CodePage);
end;

procedure utf8_from_sbcs(var Dest: ShortString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Original;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Original, ccOriginal);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_sbcs;
  Context.convert_utf8_from_sbcs;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure utf8_from_sbcs_lower(var Dest: UTF8String; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Lower;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Lower, ccLower);

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_sbcs_lower(Buffer, Pointer(Src), Length, Converter), CODEPAGE_UTF8);
end;

{inline} function utf8_from_sbcs_lower(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UTF8String;
begin
  Tiny.Text.utf8_from_sbcs_lower(Result, Src{$ifNdef INTERNALCODEPAGE}, CodePage{$endif});
end;

procedure utf8_from_sbcs_lower(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(@Src[1]);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Lower;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Lower, ccLower);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_sbcs_lower;
  Context.convert_utf8_from_sbcs;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure utf8_from_sbcs_lower(var Dest: UTF8String; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Lower;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Lower, ccLower);

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_sbcs_lower(Buffer, Pointer(@Src[1]), Length, Converter), CODEPAGE_UTF8);
end;

{inline} function utf8_from_sbcs_lower(const Src: ShortString; const CodePage: Word = 0): UTF8String;
begin
  Tiny.Text.utf8_from_sbcs_lower(Result, Src, CodePage);
end;

procedure utf8_from_sbcs_lower(var Dest: ShortString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Lower;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Lower, ccLower);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_sbcs_lower;
  Context.convert_utf8_from_sbcs;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure utf8_from_sbcs_upper(var Dest: UTF8String; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Upper;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Upper, ccUpper);

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_sbcs_upper(Buffer, Pointer(Src), Length, Converter), CODEPAGE_UTF8);
end;

{inline} function utf8_from_sbcs_upper(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UTF8String;
begin
  Tiny.Text.utf8_from_sbcs_upper(Result, Src{$ifNdef INTERNALCODEPAGE}, CodePage{$endif});
end;

procedure utf8_from_sbcs_upper(var Dest: ShortString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(@Src[1]);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Upper;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Upper, ccUpper);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_sbcs_upper;
  Context.convert_utf8_from_sbcs;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure utf8_from_sbcs_upper(var Dest: UTF8String; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Upper;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Upper, ccUpper);

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_sbcs_upper(Buffer, Pointer(@Src[1]), Length, Converter), CODEPAGE_UTF8);
end;

{inline} function utf8_from_sbcs_upper(const Src: ShortString; const CodePage: Word = 0): UTF8String;
begin
  Tiny.Text.utf8_from_sbcs_upper(Result, Src, CodePage);
end;

procedure utf8_from_sbcs_upper(var Dest: ShortString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUTF8.Upper;
  if (Converter = nil) then Converter := SBCS.AllocFillUTF8(SBCS.FUTF8.Upper, ccUpper);
  Context.FCallbacks.Converter := Converter;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_sbcs_upper;
  Context.convert_utf8_from_sbcs;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure utf8_from_utf8_lower(var Dest: UTF8String; const Src: UTF8String);
var
  Length: NativeUInt;
  Buffer: Pointer;
  Temp: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // conversion
  if (Pointer(Dest) = Pointer(Src)) and (PInteger(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_REFCOUNT)^ > 0) then
  begin
    Temp := nil;
    Buffer := AStrReserve(PAnsiString(@Temp)^, (Length * 3) shr 1);
    AStrSetLength(PAnsiString(@Temp)^, Tiny.Text.utf8_from_utf8_lower(Buffer, Pointer(Src), Length), CODEPAGE_UTF8);
    Pointer(Dest) := Temp;
    Temp := Pointer(Src);
    AStrClear(PAnsiString(@Temp)^);
  end else
  begin
    Buffer := AStrReserve(Dest, (Length * 3) shr 1);
    AStrSetLength(Dest, Tiny.Text.utf8_from_utf8_lower(Buffer, Pointer(Src), Length), CODEPAGE_UTF8);
  end;
end;

{inline} function utf8_from_utf8_lower(const Src: UTF8String): UTF8String;
begin
  Tiny.Text.utf8_from_utf8_lower(Result, Src);
end;

procedure utf8_from_utf8_lower(var Dest: ShortString; const Src: ShortString);
var
  Length: NativeUInt;
  Context: TTextConvContext;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(@Src[1]);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf8_lower;
  if (Context.convert_utf8_from_utf8 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure utf8_from_utf8_lower(var Dest: UTF8String; const Src: ShortString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // conversion
  Buffer := AStrReserve(Dest, (Length * 3) shr 1);
  AStrSetLength(Dest, Tiny.Text.utf8_from_utf8_lower(Buffer, Pointer(@Src[1]), Length), CODEPAGE_UTF8);
end;

{inline} function utf8_from_utf8_lower(const Src: ShortString): UTF8String;
begin
  Tiny.Text.utf8_from_utf8_lower(Result, Src);
end;

procedure utf8_from_utf8_lower(var Dest: ShortString; const Src: UTF8String);
var
  Length: NativeUInt;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf8_lower;
  if (Context.convert_utf8_from_utf8 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure utf8_from_utf8_upper(var Dest: UTF8String; const Src: UTF8String);
var
  Length: NativeUInt;
  Buffer: Pointer;
  Temp: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // conversion
  if (Pointer(Dest) = Pointer(Src)) and (PInteger(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_REFCOUNT)^ > 0) then
  begin
    Temp := nil;
    Buffer := AStrReserve(PAnsiString(@Temp)^, (Length * 3) shr 1);
    AStrSetLength(PAnsiString(@Temp)^, Tiny.Text.utf8_from_utf8_upper(Buffer, Pointer(Src), Length), CODEPAGE_UTF8);
    Pointer(Dest) := Temp;
    Temp := Pointer(Src);
    AStrClear(PAnsiString(@Temp)^);
  end else
  begin
    Buffer := AStrReserve(Dest, (Length * 3) shr 1);
    AStrSetLength(Dest, Tiny.Text.utf8_from_utf8_upper(Buffer, Pointer(Src), Length), CODEPAGE_UTF8);
  end;
end;

{inline} function utf8_from_utf8_upper(const Src: UTF8String): UTF8String;
begin
  Tiny.Text.utf8_from_utf8_upper(Result, Src);
end;

procedure utf8_from_utf8_upper(var Dest: ShortString; const Src: ShortString);
var
  Length: NativeUInt;
  Context: TTextConvContext;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(@Src[1]);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf8_upper;
  if (Context.convert_utf8_from_utf8 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure utf8_from_utf8_upper(var Dest: UTF8String; const Src: ShortString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;

  // conversion
  Buffer := AStrReserve(Dest, (Length * 3) shr 1);
  AStrSetLength(Dest, Tiny.Text.utf8_from_utf8_upper(Buffer, Pointer(@Src[1]), Length), CODEPAGE_UTF8);
end;

{inline} function utf8_from_utf8_upper(const Src: ShortString): UTF8String;
begin
  Tiny.Text.utf8_from_utf8_upper(Result, Src);
end;

procedure utf8_from_utf8_upper(var Dest: ShortString; const Src: UTF8String);
var
  Length: NativeUInt;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf8_upper;
  if (Context.convert_utf8_from_utf8 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

procedure utf8_from_utf16(var Dest: UTF8String; const Src: WideString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  {$endif}

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_utf16(Buffer, Pointer(Src), Length), CODEPAGE_UTF8);
end;

{$ifdef UNICODE}
procedure utf8_from_utf16(var Dest: UTF8String; const Src: UnicodeString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_utf16(Buffer, Pointer(Src), Length), CODEPAGE_UTF8);
end;
{$endif}

{inline} function utf8_from_utf16(const Src: WideString): UTF8String;
begin
  Tiny.Text.utf8_from_utf16(Result, Src);
end;

{$ifdef UNICODE}
{inline} function utf8_from_utf16(const Src: UnicodeString): UTF8String;
begin
  Tiny.Text.utf8_from_utf16(Result, Src);
end;
{$endif}

procedure utf8_from_utf16(var Dest: ShortString; const Src: WideString);
var
  Length: NativeUInt;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  {$endif}
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf16;
  if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

{$ifdef UNICODE}
procedure utf8_from_utf16(var Dest: ShortString; const Src: UnicodeString);
var
  Length: NativeUInt;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf16;
  if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;
{$endif}

procedure utf8_from_utf16_lower(var Dest: UTF8String; const Src: WideString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  {$endif}

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_utf16_lower(Buffer, Pointer(Src), Length), CODEPAGE_UTF8);
end;

{$ifdef UNICODE}
procedure utf8_from_utf16_lower(var Dest: UTF8String; const Src: UnicodeString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_utf16_lower(Buffer, Pointer(Src), Length), CODEPAGE_UTF8);
end;
{$endif}

{inline} function utf8_from_utf16_lower(const Src: WideString): UTF8String;
begin
  Tiny.Text.utf8_from_utf16_lower(Result, Src);
end;

{$ifdef UNICODE}
{inline} function utf8_from_utf16_lower(const Src: UnicodeString): UTF8String;
begin
  Tiny.Text.utf8_from_utf16_lower(Result, Src);
end;
{$endif}

procedure utf8_from_utf16_lower(var Dest: ShortString; const Src: WideString);
var
  Length: NativeUInt;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  {$endif}
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf16_lower;
  if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

{$ifdef UNICODE}
procedure utf8_from_utf16_lower(var Dest: ShortString; const Src: UnicodeString);
var
  Length: NativeUInt;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf16_lower;
  if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;
{$endif}

procedure utf8_from_utf16_upper(var Dest: UTF8String; const Src: WideString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  {$endif}

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_utf16_upper(Buffer, Pointer(Src), Length), CODEPAGE_UTF8);
end;

{$ifdef UNICODE}
procedure utf8_from_utf16_upper(var Dest: UTF8String; const Src: UnicodeString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    AStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := AStrReserve(Dest, Length * 3);
  AStrSetLength(Dest, Tiny.Text.utf8_from_utf16_upper(Buffer, Pointer(Src), Length), CODEPAGE_UTF8);
end;
{$endif}

{inline} function utf8_from_utf16_upper(const Src: WideString): UTF8String;
begin
  Tiny.Text.utf8_from_utf16_upper(Result, Src);
end;

{$ifdef UNICODE}
{inline} function utf8_from_utf16_upper(const Src: UnicodeString): UTF8String;
begin
  Tiny.Text.utf8_from_utf16_upper(Result, Src);
end;
{$endif}

procedure utf8_from_utf16_upper(var Dest: ShortString; const Src: WideString);
var
  Length: NativeUInt;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  {$endif}
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf16_upper;
  if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;

{$ifdef UNICODE}
procedure utf8_from_utf16_upper(var Dest: ShortString; const Src: UnicodeString);
var
  Length: NativeUInt;
  Context: TTextConvContext;
begin
  if (Pointer(Src) = nil) then
  begin
    PByte(@Dest)^ := 0;
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;
  Context.Destination := Pointer(@Dest[1]);
  Context.Source := Pointer(Src);
  Context.DestinationSize := NativeUInt(High(Dest));
  Context.SourceSize := Length + Length;

  // conversion
  Context.FCallbacks.ReaderWriter := @Tiny.Text.utf8_from_utf16_upper;
  if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> NativeUInt(High(Dest))) then
  begin
    Inc(Context.FDestinationWritten);
    Byte(Dest[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
  end;
  PByte(@Dest)^ := Context.DestinationWritten;
end;
{$endif}

procedure utf16_from_sbcs(var Dest: WideString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    WStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Original;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

  // conversion
  Buffer := WStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs(Buffer, Pointer(Src), Length, Converter);
end;

{$ifdef UNICODE}
procedure utf16_from_sbcs(var Dest: UnicodeString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    UStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Original;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

  // conversion
  Buffer := UStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs(Buffer, Pointer(Src), Length, Converter);
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_sbcs(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): WideString;
begin
  Tiny.Text.utf16_from_sbcs(Result, Src{$ifNdef INTERNALCODEPAGE}, CodePage{$endif});
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_sbcs(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UnicodeString;
begin
  Tiny.Text.utf16_from_sbcs(Result, Src{$ifNdef INTERNALCODEPAGE}, CodePage{$endif});
end;
{$endif}

procedure utf16_from_sbcs(var Dest: WideString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    WStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Original;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

  // conversion
  Buffer := WStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs(Buffer, Pointer(@Src[1]), Length, Converter);
end;

{$ifdef UNICODE}
procedure utf16_from_sbcs(var Dest: UnicodeString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    UStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Original;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

  // conversion
  Buffer := UStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs(Buffer, Pointer(@Src[1]), Length, Converter);
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_sbcs(const Src: ShortString; const CodePage: Word = 0): WideString;
begin
  Tiny.Text.utf16_from_sbcs(Result, Src, CodePage);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_sbcs(const Src: ShortString; const CodePage: Word = 0): UnicodeString;
begin
  Tiny.Text.utf16_from_sbcs(Result, Src, CodePage);
end;
{$endif}

procedure utf16_from_sbcs_lower(var Dest: WideString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    WStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Lower;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

  // conversion
  Buffer := WStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs_lower(Buffer, Pointer(Src), Length, Converter);
end;

{$ifdef UNICODE}
procedure utf16_from_sbcs_lower(var Dest: UnicodeString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    UStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Lower;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

  // conversion
  Buffer := UStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs_lower(Buffer, Pointer(Src), Length, Converter);
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_sbcs_lower(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): WideString;
begin
  Tiny.Text.utf16_from_sbcs_lower(Result, Src{$ifNdef INTERNALCODEPAGE}, CodePage{$endif});
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_sbcs_lower(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UnicodeString;
begin
  Tiny.Text.utf16_from_sbcs_lower(Result, Src{$ifNdef INTERNALCODEPAGE}, CodePage{$endif});
end;
{$endif}

procedure utf16_from_sbcs_lower(var Dest: WideString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    WStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Lower;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

  // conversion
  Buffer := WStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs_lower(Buffer, Pointer(@Src[1]), Length, Converter);
end;

{$ifdef UNICODE}
procedure utf16_from_sbcs_lower(var Dest: UnicodeString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    UStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Lower;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

  // conversion
  Buffer := UStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs_lower(Buffer, Pointer(@Src[1]), Length, Converter);
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_sbcs_lower(const Src: ShortString; const CodePage: Word = 0): WideString;
begin
  Tiny.Text.utf16_from_sbcs_lower(Result, Src, CodePage);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_sbcs_lower(const Src: ShortString; const CodePage: Word = 0): UnicodeString;
begin
  Tiny.Text.utf16_from_sbcs_lower(Result, Src, CodePage);
end;
{$endif}

procedure utf16_from_sbcs_upper(var Dest: WideString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    WStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Upper;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Upper, ccUpper);

  // conversion
  Buffer := WStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs_upper(Buffer, Pointer(Src), Length, Converter);
end;

{$ifdef UNICODE}
procedure utf16_from_sbcs_upper(var Dest: UnicodeString; const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif});
var
  Length: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    UStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;
  {$ifdef INTERNALCODEPAGE}CodePage := PWord(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_CODEPAGE)^;{$endif}

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Upper;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Upper, ccUpper);

  // conversion
  Buffer := UStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs_upper(Buffer, Pointer(Src), Length, Converter);
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_sbcs_upper(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): WideString;
begin
  Tiny.Text.utf16_from_sbcs_upper(Result, Src{$ifNdef INTERNALCODEPAGE}, CodePage{$endif});
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_sbcs_upper(const Src: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): UnicodeString;
begin
  Tiny.Text.utf16_from_sbcs_upper(Result, Src{$ifNdef INTERNALCODEPAGE}, CodePage{$endif});
end;
{$endif}

procedure utf16_from_sbcs_upper(var Dest: WideString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    WStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Upper;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Upper, ccUpper);

  // conversion
  Buffer := WStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs_upper(Buffer, Pointer(@Src[1]), Length, Converter);
end;

{$ifdef UNICODE}
procedure utf16_from_sbcs_upper(var Dest: UnicodeString; const Src: ShortString; const CodePage: Word = 0);
var
  Length: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Converter: Pointer;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    UStrClear(Dest);
    Exit;
  end;

  // SBCS := TextConvSBCS(CodePage);
  Index := NativeUInt(CodePage);
  Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));

  // converter
  Converter := SBCS.FUCS2.Upper;
  if (Converter = nil) then Converter := SBCS.AllocFillUCS2(SBCS.FUCS2.Upper, ccUpper);

  // conversion
  Buffer := UStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_sbcs_upper(Buffer, Pointer(@Src[1]), Length, Converter);
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_sbcs_upper(const Src: ShortString; const CodePage: Word = 0): WideString;
begin
  Tiny.Text.utf16_from_sbcs_upper(Result, Src, CodePage);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_sbcs_upper(const Src: ShortString; const CodePage: Word = 0): UnicodeString;
begin
  Tiny.Text.utf16_from_sbcs_upper(Result, Src, CodePage);
end;
{$endif}

procedure utf16_from_utf8(var Dest: WideString; const Src: UTF8String);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    WStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := WStrReserve(Dest, Length);
  WStrSetLength(Dest, Tiny.Text.utf16_from_utf8(Buffer, Pointer(Src), Length));
end;

{$ifdef UNICODE}
procedure utf16_from_utf8(var Dest: UnicodeString; const Src: UTF8String);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    UStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := UStrReserve(Dest, Length);
  UStrSetLength(Dest, Tiny.Text.utf16_from_utf8(Buffer, Pointer(Src), Length));
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_utf8(const Src: UTF8String): WideString;
begin
  Tiny.Text.utf16_from_utf8(Result, Src);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_utf8(const Src: UTF8String): UnicodeString;
begin
  Tiny.Text.utf16_from_utf8(Result, Src);
end;
{$endif}

procedure utf16_from_utf8(var Dest: WideString; const Src: ShortString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    WStrClear(Dest);
    Exit;
  end;

  // conversion
  Buffer := WStrReserve(Dest, Length);
  WStrSetLength(Dest, Tiny.Text.utf16_from_utf8(Buffer, Pointer(@Src[1]), Length));
end;

{$ifdef UNICODE}
procedure utf16_from_utf8(var Dest: UnicodeString; const Src: ShortString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    UStrClear(Dest);
    Exit;
  end;

  // conversion
  Buffer := UStrReserve(Dest, Length);
  UStrSetLength(Dest, Tiny.Text.utf16_from_utf8(Buffer, Pointer(@Src[1]), Length));
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_utf8(const Src: ShortString): WideString;
begin
  Tiny.Text.utf16_from_utf8(Result, Src);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_utf8(const Src: ShortString): UnicodeString;
begin
  Tiny.Text.utf16_from_utf8(Result, Src);
end;
{$endif}

procedure utf16_from_utf8_lower(var Dest: WideString; const Src: UTF8String);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    WStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := WStrReserve(Dest, Length);
  WStrSetLength(Dest, Tiny.Text.utf16_from_utf8_lower(Buffer, Pointer(Src), Length));
end;

{$ifdef UNICODE}
procedure utf16_from_utf8_lower(var Dest: UnicodeString; const Src: UTF8String);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    UStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := UStrReserve(Dest, Length);
  UStrSetLength(Dest, Tiny.Text.utf16_from_utf8_lower(Buffer, Pointer(Src), Length));
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_utf8_lower(const Src: UTF8String): WideString;
begin
  Tiny.Text.utf16_from_utf8_lower(Result, Src);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_utf8_lower(const Src: UTF8String): UnicodeString;
begin
  Tiny.Text.utf16_from_utf8_lower(Result, Src);
end;
{$endif}

procedure utf16_from_utf8_lower(var Dest: WideString; const Src: ShortString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    WStrClear(Dest);
    Exit;
  end;

  // conversion
  Buffer := WStrReserve(Dest, Length);
  WStrSetLength(Dest, Tiny.Text.utf16_from_utf8_lower(Buffer, Pointer(@Src[1]), Length));
end;

{$ifdef UNICODE}
procedure utf16_from_utf8_lower(var Dest: UnicodeString; const Src: ShortString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    UStrClear(Dest);
    Exit;
  end;

  // conversion
  Buffer := UStrReserve(Dest, Length);
  UStrSetLength(Dest, Tiny.Text.utf16_from_utf8_lower(Buffer, Pointer(@Src[1]), Length));
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_utf8_lower(const Src: ShortString): WideString;
begin
  Tiny.Text.utf16_from_utf8_lower(Result, Src);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_utf8_lower(const Src: ShortString): UnicodeString;
begin
  Tiny.Text.utf16_from_utf8_lower(Result, Src);
end;
{$endif}

procedure utf16_from_utf8_upper(var Dest: WideString; const Src: UTF8String);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    WStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := WStrReserve(Dest, Length);
  WStrSetLength(Dest, Tiny.Text.utf16_from_utf8_upper(Buffer, Pointer(Src), Length));
end;

{$ifdef UNICODE}
procedure utf16_from_utf8_upper(var Dest: UnicodeString; const Src: UTF8String);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    UStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - ASTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := UStrReserve(Dest, Length);
  UStrSetLength(Dest, Tiny.Text.utf16_from_utf8_upper(Buffer, Pointer(Src), Length));
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_utf8_upper(const Src: UTF8String): WideString;
begin
  Tiny.Text.utf16_from_utf8_upper(Result, Src);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_utf8_upper(const Src: UTF8String): UnicodeString;
begin
  Tiny.Text.utf16_from_utf8_upper(Result, Src);
end;
{$endif}

procedure utf16_from_utf8_upper(var Dest: WideString; const Src: ShortString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    WStrClear(Dest);
    Exit;
  end;

  // conversion
  Buffer := WStrReserve(Dest, Length);
  WStrSetLength(Dest, Tiny.Text.utf16_from_utf8_upper(Buffer, Pointer(@Src[1]), Length));
end;

{$ifdef UNICODE}
procedure utf16_from_utf8_upper(var Dest: UnicodeString; const Src: ShortString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  Length := PByte(@Src)^;
  if (Length = 0) then
  begin
    UStrClear(Dest);
    Exit;
  end;

  // conversion
  Buffer := UStrReserve(Dest, Length);
  UStrSetLength(Dest, Tiny.Text.utf16_from_utf8_upper(Buffer, Pointer(@Src[1]), Length));
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_utf8_upper(const Src: ShortString): WideString;
begin
  Tiny.Text.utf16_from_utf8_upper(Result, Src);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_utf8_upper(const Src: ShortString): UnicodeString;
begin
  Tiny.Text.utf16_from_utf8_upper(Result, Src);
end;
{$endif}

procedure utf16_from_utf16_lower(var Dest: WideString; const Src: WideString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    WStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    WStrClear(Dest);
    Exit;
  end;
  {$endif}

  // conversion
  Buffer := WStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_utf16_lower(Buffer, Pointer(Src), Length);
end;

{$ifdef UNICODE}
procedure utf16_from_utf16_lower(var Dest: UnicodeString; const Src: UnicodeString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    UStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := UStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_utf16_lower(Buffer, Pointer(Src), Length);
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_utf16_lower(const Src: WideString): WideString;
begin
  Tiny.Text.utf16_from_utf16_lower(Result, Src);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_utf16_lower(const Src: UnicodeString): UnicodeString;
begin
  Tiny.Text.utf16_from_utf16_lower(Result, Src);
end;
{$endif}

procedure utf16_from_utf16_upper(var Dest: WideString; const Src: WideString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    WStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - WSTR_OFFSET_LENGTH)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
  {$ifdef MSWINDOWS}
  if (Length = 0) then
  begin
    WStrClear(Dest);
    Exit;
  end;
  {$endif}

  // conversion
  Buffer := WStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_utf16_upper(Buffer, Pointer(Src), Length);
end;

{$ifdef UNICODE}
procedure utf16_from_utf16_upper(var Dest: UnicodeString; const Src: UnicodeString);
var
  Length: NativeUInt;
  Buffer: Pointer;
begin
  if (Pointer(Src) = nil) then
  begin
    UStrClear(Dest);
    Exit;
  end;
  Length := PCardinal(PAnsiChar(Pointer(Src)) - USTR_OFFSET_LENGTH)^;

  // conversion
  Buffer := UStrInit(Dest, nil, Length);
  Tiny.Text.utf16_from_utf16_upper(Buffer, Pointer(Src), Length);
end;
{$endif}

{$ifNdef UNICODE}
{inline} function utf16_from_utf16_upper(const Src: WideString): WideString;
begin
  Tiny.Text.utf16_from_utf16_upper(Result, Src);
end;
{$endif}

{$ifdef UNICODE}
{inline} function utf16_from_utf16_upper(const Src: UnicodeString): UnicodeString;
begin
  Tiny.Text.utf16_from_utf16_upper(Result, Src);
end;
{$endif}
{$ifdef undef}{$ENDREGION}{$endif}

{$ifdef undef}{$REGION 'low level comparison routine'}{$endif}
// binary compare sbcs/utf8
function __textconv_compare_bytes(S1, S2: PByte; Length: NativeUInt): NativeInt;
label
  make_result, make_result_swaped;
var
  X, Y: NativeUInt;
begin
  while (Length >= SizeOf(NativeUInt)) do
  begin
    X := PNativeUInt(S1)^;
    Dec(Length, SizeOf(NativeUInt));
    Y := PNativeUInt(S2)^;
    Inc(S1, SizeOf(NativeUInt));
    Inc(S2, SizeOf(NativeUInt));

    if (X <> Y) then
    begin
      {$ifdef LARGEINT}
        if (Cardinal(X) = Cardinal(Y)) then
        begin
          X := X shr 32;
          Y := Y shr 32;
        end else
        begin
          X := Cardinal(X);
          Y := Cardinal(Y);
        end;
      {$endif}

      goto make_result;
    end;
  end;

  // read last
  {$ifdef LARGEINT}
  if (Length >= SizeOf(Cardinal)) then
  begin
    X := PCardinal(S1)^;
    Dec(Length, SizeOf(Cardinal));
    Y := PCardinal(S2)^;
    Inc(S1, SizeOf(Cardinal));
    Inc(S2, SizeOf(Cardinal));

    if (X <> Y) then goto make_result;
  end;
  {$endif}

  case Length of
    1: begin
         X := PByte(S1)^;
         Y := PByte(S2)^;
         goto make_result_swaped;
       end;
    2: begin
         X := Swap(PWord(S1)^);
         Y := Swap(PWord(S2)^);
         goto make_result_swaped;
       end;
    3: begin
         X := Swap(PWord(S1)^);
         Y := Swap(PWord(S2)^);
         Inc(S1, SizeOf(Word));
         Inc(S2, SizeOf(Word));
         X := (X shl 8) or PByte(S1)^;
         Y := (Y shl 8) or PByte(S2)^;
         goto make_result_swaped;
       end;
  else
    // 0
    Result := 0;
    Exit;
  end;

make_result:
  X := (Swap(X) shl 16) + Swap(X shr 16);
  Y := (Swap(Y) shl 16) + Swap(Y shr 16);

make_result_swaped:
  if (X = Y) then
  begin
    Result := 0;
    Exit;
  end;
  Result := Ord(X > Y)*2 - 1;
end;

// binary compare utf16
function __textconv_compare_words(S1, S2: PWord; Length: NativeUInt): NativeInt;
label
  make_result, make_result_swaped;
var
  X, Y: NativeUInt;
begin
  while (Length >= WORDS_IN_NATIVE) do
  begin
    X := PNativeUInt(S1)^;
    Dec(Length, WORDS_IN_NATIVE);
    Y := PNativeUInt(S2)^;
    inc (S1, WORDS_IN_NATIVE);
    inc (S2, WORDS_IN_NATIVE);

    if (X <> Y) then
    begin
      {$ifdef LARGEINT}
        if (Cardinal(X) = Cardinal(Y)) then
        begin
          X := X shr 32;
          Y := Y shr 32;
        end else
        begin
          X := Cardinal(X);
          Y := Cardinal(Y);
        end;
      {$endif}

      goto make_result;
    end;
  end;

  // read last
  {$ifdef LARGEINT}
  if (Length >= WORDS_IN_CARDINAL) then
  begin
    X := PCardinal(S1)^;
    Dec(Length, WORDS_IN_CARDINAL);
    Y := PCardinal(S2)^;
    inc (S1, WORDS_IN_CARDINAL);
    inc (S2, WORDS_IN_CARDINAL);

    if (X <> Y) then goto make_result;
  end;
  {$endif}

  if (Length <> 0) then
  begin
    X := PWord(S1)^;
    Y := PWord(S2)^;
    if (X <> Y) then goto make_result_swaped;
  end;

  Result := 0;
  Exit;

  // warnings off
  X := 0;
  Y := 0;

make_result:
  X := {$ifdef LARGEINT}Cardinal{$endif}(X shl 16) + (X shr 16);
  Y := {$ifdef LARGEINT}Cardinal{$endif}(Y shl 16) + (Y shr 16);

make_result_swaped:
  Result := Ord(X > Y)*2 - 1;
end;

// comparison between same single byte enconding code page, case insensitive
// lookup is lower case PTextConvBB
function __textconv_sbcs_compare_sbcs_1(S1, S2: PAnsiChar; const Comp: TTextConvCompareOptions): NativeInt;
label
  main_loop, main_loop_finish, compare_chars, make_result;
var
  X, Y: NativeUInt;
  Length: NativeUInt;
  Lookup: PTextConvBB;

  {$ifdef CPUX86}
  F: record
    Y_Offset: NativeInt;
    TopPtr: PAnsiChar;
  end;
  {$else .CPUMANYREGS}
    TopPtr: PAnsiChar;
  {$endif}

  U, V: NativeUInt;

  {$ifdef CPUINTEL}
  const
    MASK_80 = MASK_80_SMALL;
    MASK_40 = MASK_40_SMALL;
    MASK_65 = MASK_65_SMALL;
    MASK_7F = MASK_7F_SMALL;
  {$else .CPUARM}
  var
    MASK_80, MASK_40, MASK_65, MASK_7F: NativeUInt;
  {$endif}
begin
  {$ifNdef CPUINTEL}
    // ARM
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}

  Lookup := Comp.Lookup;
  {$ifdef CPUX86}F.Y_Offset := NativeInt(S2) - NativeInt(S1){$endif};
  {$ifdef CPUX86}F.{$endif}TopPtr := PAnsiChar(S1) + Comp.Length - SizeOf(NativeUInt);

  // while (Length >= SizeOf(NativeUInt)) do
  if (PAnsiChar(S1) > {$ifdef CPUX86}F.{$endif}TopPtr) then goto main_loop_finish;
  main_loop:
  begin
    X := PNativeUInt(S1)^;
    Y := PNativeUInt({$ifdef CPUX86}S1+F.Y_Offset{$else}S2{$endif})^;
    Inc(S1, SizeOf(NativeUInt));
    {$ifdef CPUMANYREGS}Inc(S2, SizeOf(NativeUInt));{$endif}

    if (X <> Y) then
    begin
      {$ifdef LARGEINT}
        if (Cardinal(X) = Cardinal(Y)) then
        begin
          X := X shr 32;
          Y := Y shr 32;
          Dec(S1, SizeOf(Cardinal));
          {$ifdef CPUMANYREGS}Dec(S2, SizeOf(Cardinal));{$endif}
        end else
        begin
          X := Cardinal(X);
          Y := Cardinal(Y);
        end;
      {$endif}

      compare_chars:
      if (Cardinal(X or Y) and MASK_80 = 0) then
      begin
        U := X xor MASK_40;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        X := X + ((not V) and U) shr 2;

        U := Y xor MASK_40;
        V := (U + MASK_65);
        U := (U + MASK_7F) and Integer(MASK_80);
        Y := Y + ((not V) and U) shr 2;

        if (X <> Y) then
        begin
          X := (Swap(X) shl 16) + Swap(X shr 16);
          Y := (Swap(Y) shl 16) + Swap(Y shr 16);
          goto make_result;
        end;
      end else
      begin
        // make lower and swap
        X := (Lookup[X and $ff] shl 24) or
             (Lookup[(X shr 8) and $ff] shl 16) or
             (Lookup[(X shr 16) and $ff] shl 8) or
             (Lookup[X shr 24]);
        Y := (Lookup[Y and $ff] shl 24) or
             (Lookup[(Y shr 8) and $ff] shl 16) or
             (Lookup[(Y shr 16) and $ff] shl 8) or
             (Lookup[Y shr 24]);
        if (X <> Y) then goto make_result;
      end;
    end;

   if (PAnsiChar(S1) <= {$ifdef CPUX86}F.{$endif}TopPtr) then goto main_loop;
  end;
  main_loop_finish:

  Length := NativeUInt({$ifdef CPUX86}F.{$endif}TopPtr)-NativeUInt(S1)+SizeOf(NativeUInt);

  // read last
  {$ifdef LARGEINT}
  if (Length >= SizeOf(Cardinal)) then
  begin
    X := PCardinal(S1)^;
    Y := PCardinal(S2)^;
    Inc(S1, SizeOf(Cardinal));
    {$ifdef CPUMANYREGS}Inc(S2, SizeOf(Cardinal));{$endif}
    Dec(Length, SizeOf(Cardinal));

    if (X <> Y) then goto compare_chars;
  end;
  {$endif}

  case Length of
    1: begin
         X := PByte(S1)^;
         Y := PByte({$ifdef CPUX86}S1+F.Y_Offset{$else}S2{$endif})^;
         X := Lookup[X];
         Y := Lookup[Y];
         if (X <> Y) then goto make_result{compare_chars};
       end;
    2: begin
         X := PWord(S1)^;
         Y := PWord({$ifdef CPUX86}S1+F.Y_Offset{$else}S2{$endif})^;
         Inc(S1, SizeOf(Word));
         {$ifdef CPUMANYREGS}Inc(S2, SizeOf(Word));{$endif}
         if (X <> Y) then goto compare_chars;
       end;
    3: begin
         {$ifdef CPUMANYREGS}
           Y := P4Bytes(S2)[2];
           Y := (Y shl 16) + PWord(S2)^;
           Inc(S2, 3);
         {$else}
           X := NativeInt(S1) + F.Y_Offset;
           Y := P4Bytes(X)[2];
           Y := (Y shl 16) + PWord(X)^;
         {$endif}
         X := P4Bytes(S1)[2];
         X := (X shl 16) + PWord(S1)^;
         Inc(S1, 3);

         if (X <> Y) then goto compare_chars;
       end;
  else
    Result := 0;
    Exit;
  end;

  Result := 0;
  Exit;

make_result:
  Result := Ord(X > Y)*2 - 1;
end;

// comparison between different code pages, optional case insensitive
// both lookups are PTextConvWB
function __textconv_sbcs_compare_sbcs_2(S1, S2: PAnsiChar; const Comp: TTextConvCompareOptions): NativeInt;
label
  main_loop, main_loop_finish, compare_chars, make_result;
var
  X, Y: NativeUInt;
  Length: NativeUInt;

  {$ifdef CPUX86}
  F: record
    _1, _2: PTextConvWB;
    TopPtr: PAnsiChar;
  end;
  {$else .CPUMANYREGS}
    _1, _2: PTextConvWB;
    TopPtr: PAnsiChar;
  {$endif}

  {$ifdef CPUX86}
  const
    MASK_80 = MASK_80_DEFAULT;
  {$else .CPUMANYREGS}
  var
    MASK_80: NativeUInt;
  {$endif}
begin
  {$ifdef CPUMANYREGS}MASK_80 := MASK_80_DEFAULT;{$endif}

  {$ifdef CPUX86}F.{$endif}_1 := Comp.Lookup;
  {$ifdef CPUX86}F.{$endif}_2 := Comp.Lookup_2;
  {$ifdef CPUX86}F.{$endif}TopPtr := PAnsiChar(S1) + Comp.Length - SizeOf(NativeUInt);

  // while (Length >= SizeOf(NativeUInt)) do
  if (PAnsiChar(S1) > {$ifdef CPUX86}F.{$endif}TopPtr) then goto main_loop_finish;
  main_loop:
  begin
    X := PNativeUInt(S1)^;
    Y := PNativeUInt(S2)^;
    Inc(S1, SizeOf(NativeUInt));
    Inc(S2, SizeOf(NativeUInt));

    if (X <> Y) or ((X or Y) and MASK_80 <> 0) then
    begin
      {$ifdef LARGEINT}
        if (Cardinal(X) = Cardinal(Y)) and (Cardinal(X or Y) and MASK_80_SMALL = 0) then
        begin
          X := X shr 32;
          Y := Y shr 32;
          Dec(S1, SizeOf(Cardinal));
          Dec(S2, SizeOf(Cardinal));
        end else
        begin
          X := Cardinal(X);
          Y := Cardinal(Y);
        end;
      {$endif}

      compare_chars:
        if {0}({$ifdef CPUX86}F._1[X and $ff]<>F._2[Y and $ff]{$else}_1[Byte(X)]<>_2[Byte(Y)]{$endif}) then goto make_result;
        X := X shr 8;
        Y := Y shr 8;
        if {1}({$ifdef CPUX86}F._1[X and $ff]<>F._2[Y and $ff]{$else}_1[Byte(X)]<>_2[Byte(Y)]{$endif}) then goto make_result;
        X := X shr 8;
        Y := Y shr 8;
        if {2}({$ifdef CPUX86}F._1[X and $ff]<>F._2[Y and $ff]{$else}_1[Byte(X)]<>_2[Byte(Y)]{$endif}) then goto make_result;
        X := X shr 8;
        Y := Y shr 8;
        if {3}({$ifdef CPUX86}F._1[X]<>F._2[Y]{$else}_1[X]<>_2[Y]{$endif}) then goto make_result;
    end;

   if (PAnsiChar(S1) <= {$ifdef CPUX86}F.{$endif}TopPtr) then goto main_loop;
  end;
  main_loop_finish:

  Length := NativeUInt({$ifdef CPUX86}F.{$endif}TopPtr)-NativeUInt(S1)+SizeOf(NativeUInt);

  // read last
  {$ifdef LARGEINT}
  if (Length >= SizeOf(Cardinal)) then
  begin
    X := PCardinal(S1)^;
    Y := PCardinal(S2)^;
    Inc(S1, SizeOf(Cardinal));
    Inc(S2, SizeOf(Cardinal));
    Dec(Length, SizeOf(Cardinal));

    if (X <> Y) or ((X or Y) and MASK_80 <> 0) then goto compare_chars;
  end;
  {$endif}

  case Length of
    1: begin
         X := PByte(S1)^;
         Y := PByte(S2)^;
         if ({$ifdef CPUX86}F._1[X and $ff]<>F._2[Y and $ff]{$else}_1[Byte(X)]<>_2[Byte(Y)]{$endif}) then goto make_result;
       end;
    2: begin
         X := PWord(S1)^;
         Y := PWord(S2)^;
         Inc(S1, SizeOf(Word));
         Inc(S2, SizeOf(Word));
         if (X <> Y) or ((X or Y) and MASK_80 <> 0) then goto compare_chars;
       end;
    3: begin
         X := P4Bytes(S1)[2];
         X := (X shl 16) + PWord(S1)^;
         Inc(S1, 3);
         Y := P4Bytes(S2)[2];
         Y := (Y shl 16) + PWord(S2)^;
         Inc(S2, 3);
         if (X <> Y) or ((X or Y) and MASK_80 <> 0) then goto compare_chars;
       end;
  else
    Result := 0;
    Exit;
  end;

  Result := 0;
  Exit;

make_result:
  Result := Ord({$ifdef CPUX86}F._1[X and $ff]>F._2[Y and $ff]{$else}_1[Byte(X)]>_2[Byte(Y)]{$endif})*2 - 1;
end;

// case insensitive utf16 comparison
function __textconv_utf16_compare_utf16(S1, S2: PUnicodeChar; Length: NativeUInt): NativeInt;
label
  compare_chars, compare_ascii,
  make_result, make_result_swaped;
var
  X, Y: NativeUInt;

  {$ifdef LARGEINT}
    U, V: NativeUInt;
    MASK_FF80, MASK_0040, MASK_0065, MASK_007F: NativeUInt;
  {$endif}

  {$ifNdef CPUX86}
    lookup_utf16_lower: PTextConvWW;
  {$endif}
begin
  {$ifdef LARGEINT}
    MASK_FF80 := MASK_FF80_DEFAULT;
    MASK_0040 := MASK_0040_DEFAULT;
    MASK_0065 := MASK_0065_DEFAULT;
    MASK_007F := MASK_007F_DEFAULT;
  {$endif}
  {$ifNdef CPUX86}
    lookup_utf16_lower := Pointer(@TEXTCONV_CHARCASE);
  {$endif}


  while (Length >= WORDS_IN_NATIVE) do
  begin
    X := PNativeUInt(S1)^;
    Dec(Length, WORDS_IN_NATIVE);
    Y := PNativeUInt(S2)^;
    Inc(S1, WORDS_IN_NATIVE);
    Inc(S2, WORDS_IN_NATIVE);

    if (X <> Y) then
    begin
      {$ifdef LARGEINT}
      if ((X or Y) and MASK_FF80 = 0) then
      begin
        U := X xor MASK_0040;
        V := (U + MASK_0065);
        U := (U + MASK_007F) and MASK_FF80;
        X := X + ((not V) and U) shr 2;

        U := Y xor MASK_0040;
        V := (U + MASK_0065);
        U := (U + MASK_007F) and MASK_FF80;
        Y := Y + ((not V) and U) shr 2;

        if (X <> Y) then
        begin
          X := (X shl 48) + ((X and Integer($ffff0000)) shl 32) +
               ((X shr 16) and Integer($ffff0000)) + (X shr 48);
          Y := (Y shl 48) + ((Y and Integer($ffff0000)) shl 32) +
               ((Y shr 16) and Integer($ffff0000)) + (Y shr 48);
          goto make_result;
        end;
      end else
      {$endif}
      begin
        {$ifdef LARGEINT}
          if (Cardinal(X) = Cardinal(Y)) then
          begin
            X := X shr 32;
            Y := Y shr 32;
          end else
          begin
            X := Cardinal(X);
            Y := Cardinal(Y);
            Inc(Length, WORDS_IN_NATIVE div 2);
            Dec(S1, WORDS_IN_NATIVE div 2);
            Dec(S2, WORDS_IN_NATIVE div 2);
          end;
        {$endif}

      compare_chars:
        {$ifdef CPUX86}
          X := (TEXTCONV_CHARCASE.VALUES[Word(X)] shl 16) + TEXTCONV_CHARCASE.VALUES[X shr 16];
          Y := (TEXTCONV_CHARCASE.VALUES[Word(Y)] shl 16) + TEXTCONV_CHARCASE.VALUES[Y shr 16];
        {$else}
          X := (lookup_utf16_lower[Word(X)] shl 16) + lookup_utf16_lower[X shr 16];
          Y := (lookup_utf16_lower[Word(Y)] shl 16) + lookup_utf16_lower[Y shr 16];
        {$endif}

        if (X <> Y) then goto make_result;
      end;
    end;
  end;

  // read last
  {$ifdef LARGEINT}
  if (Length >= WORDS_IN_CARDINAL) then
  begin
    X := PCardinal(S1)^;
    Dec(Length, WORDS_IN_CARDINAL);
    Y := PCardinal(S2)^;
    Inc(S1, WORDS_IN_CARDINAL);
    Inc(S2, WORDS_IN_CARDINAL);

    if (X <> Y) then goto compare_chars;
  end;
  {$endif}

  if (Length <> 0) then
  begin
    X := PWord(S1)^;
    Y := PWord(S2)^;
    X := {$ifdef CPUX86}TEXTCONV_CHARCASE.VALUES{$else}lookup_utf16_lower{$endif}[X];
    Y := {$ifdef CPUX86}TEXTCONV_CHARCASE.VALUES{$else}lookup_utf16_lower{$endif}[Y];

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

// comparison between utf16 and single byte encoding
// optional case sensitive
function __textconv_utf16_compare_sbcs(S1: PUnicodeChar; S2: PAnsiChar; const Comp: TTextConvCompareOptions): NativeInt;
{$ifNdef CPUX86}
type
  TCardinalArray = array[0..0] of Cardinal;
  PCardinalArray = ^TCardinalArray;
  TWordArray = array[0..0] of Word;
  PWordArray = ^TWordArray;
label
  make_result;
var
  X, Y: NativeUInt;
  Length: NativeUInt;
  i: NativeUInt;

  _1: PTextConvWW;
  _2: PTextConvWB;
begin
  _1 := Comp.Lookup;
  _2 := Comp.Lookup_2;

  Length := Comp.Length;
  if (Length >= 2) then
  for i := 0 to (Length shr 1)-1 do
  begin
    X := PCardinalArray(S1)[i];
    if (_1 = nil) then
    begin
      X := {$ifdef LARGEINT}Cardinal{$endif}(X shl 16) + (X shr 16);
    end else
    begin
      X := (NativeUInt(_1[Word(X)]) shl 16) + NativeUInt(_1[X shr 16]);
    end;

    Y := PWordArray(S2)[i];
    Y := (NativeUInt(_2[Byte(Y)]) shl 16) + NativeUInt(_2[Y shr 8]);
    if (X <> Y) then goto make_result;
  end;

  if (Length and 1 <> 0) then
  begin
    X := PWordArray(S1)[Length-1];
    if (_1 <> nil) then X := _1[X];

    Y := Byte(PAnsiChar(S2)[Length-1]);
    Y := _2[Y];
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
{$else .CPUX86} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
  // S1 - ebx
  // S2 - ebp
  // _1 - esi
  // _2 - edi
  // X - eax
  // Y - edx
  //
  // Buffer - ecx
  // TopS1Ptr(from Length) - stack [esp]
@prefix:
  push ebx
  push ebp
  push esi
  push edi
@start:
  mov ebx, [ECX].TTextConvCompareOptions.Length
  mov esi, [ECX].TTextConvCompareOptions.Lookup
  mov edi, [ECX].TTextConvCompareOptions.Lookup_2

  lea ecx, [eax + ebx*2]
  lea ebx, [eax - 4] // S1 := PAnsiChar(S1) - 4;
  sub ecx, 8
  mov ebp, edx       // S2 := S2;
  push ecx           // TopS1Ptr(stack) := PAnsiChar(S1) + Length*SizeOf(WideChar) - 4-4;

  cmp ebx, ecx
  jnbe @after_loop
  @loop:
    movzx edx, word ptr [ebp]
    add ebx, 4
    add ebp, 2

    // Y := (NativeUInt(_2[Byte(Y)]) shl 16) + NativeUInt(_2[Y shr 8]);
    // X := PCardinal(S1)^;
    // if (_1 <> nil) then ...
    movzx ecx, dh
    movzx edx, dl
    movzx ecx, word ptr [edi + ecx*2]
    movzx edx, word ptr [edi + edx*2]
      mov eax, [ebx]
    shl edx, 16
      test esi, esi
    lea edx, [edx + ecx]
      mov ecx, eax

    jz @X_final
    @X_lookup:
      // X := (NativeUInt(_1[Word(X)]) shl 16) + NativeUInt(_1[X shr 16]);
      //  =
      // X1 := _1[Word(X)]; / X2 := _1[X shr 16] shl 16;
      // X := (X1 shl 16) + (X2 shr 16);
      shr ecx, 16
      movzx eax, ax
      movzx ecx, word ptr [esi + ecx*2]
      movzx eax, word ptr [esi + eax*2]
      shl ecx, 16 {fake shift}
    @X_final:
      // X := (X shl 16) + (X shr 16);
      shl eax, 16
      shr ecx, 16
      add eax, ecx
    @compare:
      cmp eax, edx
      jne @make_result

  @loop_continue:
    cmp ebx, [esp]
    jbe @loop

@after_loop:
  sub ebx, 4
  cmp ebx, [esp]
  je @result_equal

  // X := _1[Ord(S1[Length-1])];
  // Y := _2[Ord(S2[Length-1])];
  movzx eax, word ptr [ebx+8]
  movzx edx, byte ptr [ebp]
  test esi, esi
  movzx edx, word ptr [edi + edx*2]
  jz @X_done
  movzx eax, word ptr [esi + eax*2]
  @X_done:
  cmp eax, edx
  jne @make_result

@result_equal:
  xor eax, eax
  jmp @finish

@make_result:
  seta al
  movzx eax, al
  lea eax, [eax*2-1]
@finish:
  pop ecx
  pop edi
  pop esi
  pop ebp
  pop ebx
@Exit:
end;
{$endif}

// comparison between utf8 and utf16
// optional case sensitive (Lookup = @TEXTCONV_CHARCASE.VALUES)
function __textconv_utf8_compare_utf16(S1: PUTF8Char; S2: PUnicodeChar; const Comp: TTextConvCompareOptions): NativeInt;
label
  utf8_read_normal, utf8_read, utf8_read_one, next_interation, utf8_read_small,
  return_less, return_greater, make_fail_utf8_result, make_result;
var
  X, Y, U: NativeUInt;
  UTF8Length: NativeUInt;

  {$ifdef CPUX86}
  F: record
    TopPtr: PWideChar;
    lookup_utf16_lower: PTextConvWW;
  end;
  {$else .CPUMANYREGS}
    TopPtr: PWideChar;
    lookup_utf16_lower: PTextConvWW;
  {$endif}
begin
  UTF8Length := Comp.Length;
  {$ifdef CPUX86}F.{$endif}TopPtr := PWideChar(S2) + Comp.Length_2-1;
  {$ifdef CPUX86}F.{$endif}lookup_utf16_lower := Comp.Lookup;

  if (UTF8Length < 4) then goto utf8_read_small;
utf8_read_normal:
  X := PCardinal(S1)^;
utf8_read:
  if (S2 >= {$ifdef CPUX86}F.{$endif}TopPtr{WideLength <= 1}) then
  begin
    if (S2 = {$ifdef CPUX86}F.{$endif}TopPtr{WideLength = 1}) then goto utf8_read_one;
    goto return_greater;
  end;

  if (X and $8080 = 0) then
  begin
    // compare 2 chars
    X := ((X and $7f00) shl 8) + (X and $007f);
    Inc(S1, 2);
    Dec(UTF8Length, 2);
    Y := PCardinal(S2)^;
    Inc(S2, 2);

    if (X <> Y) then
    begin
      if ({$ifdef CPUX86}F.{$endif}lookup_utf16_lower = nil) then
      begin
        X := {$ifdef LARGEINT}Cardinal{$endif}(X shl 16) or (X shr 16);
        Y := {$ifdef LARGEINT}Cardinal{$endif}(Y shl 16) or (Y shr 16);
        goto make_result;
      end else
      begin
        {$ifdef CPUX86}
          X := (TEXTCONV_CHARCASE.VALUES[Word(X)] shl 16) + TEXTCONV_CHARCASE.VALUES[X shr 16];
          Y := (TEXTCONV_CHARCASE.VALUES[Word(Y)] shl 16) + TEXTCONV_CHARCASE.VALUES[Y shr 16];
        {$else}
          X := (lookup_utf16_lower[Word(X)] shl 16) + lookup_utf16_lower[X shr 16];
          Y := (lookup_utf16_lower[Word(Y)] shl 16) + lookup_utf16_lower[Y shr 16];
        {$endif}
        if (X <> Y) then goto make_result;
      end;
    end;
  end else
  begin
utf8_read_one:
    // compare 1 char
    if (X and $80 = 0) then
    begin
      X := X and $7f;
      Inc(S1);
      Dec(UTF8Length);
    end else
    if (X and $C0E0 = $80C0) then
    begin
      Y := X;
      X := X and $1F;
      Dec(UTF8Length, 2);
      Y := Y shr 8;
      Inc(S1, 2);
      X := X shl 6;
      Y := Y and $3F;
      Inc(X, Y);
      //if (NativeInt(UTF8Length) < 0) then goto make_fail_utf8_result;
    end else
    begin
      Y := TEXTCONV_UTF8CHAR_SIZE[Byte(X){ and $ff}];
      Dec(UTF8Length, Y);
      Inc(S1, Y);
      if (NativeInt(UTF8Length) < 0) then goto make_fail_utf8_result;

      case Y of
        0..2: goto make_fail_utf8_result;
        3:
        begin
          if (X and $C0C000 = $808000) then
          begin
            Y := (X and $0F) shl 12;
            Y := Y + (X shr 16) and $3F;
            X := (X and $3F00) shr 2;
            Inc(X, Y);
          end else
          goto make_fail_utf8_result;
        end;
        4:
        begin
          if (X and $C0C0C000 = $80808000) then
          begin
            Y := (X and $07) shl 18;
            Y := Y + (X and $3f00) shl 4;
            Y := Y + (X shr 10) and $0fc0;
            X := (X shr 24) and $3f;
            Inc(X, Y);
          end else
          goto make_fail_utf8_result;
        end;
      else
        goto return_greater;
      end;
    end;

    // one utf16
    Y := PWord(S2)^;
    Inc(S2);
    if (Y >= $d800) and (Y < $dc00) and (S2 <= {$ifdef CPUX86}F.{$endif}TopPtr{WideLength >= 1}) then
    begin
      U := PWord(S2)^;
      Inc(S2);
      Dec(U, $dc00);
      if (U < ($e000-$dc00)) then
      begin
        if (X <= $ffff) then goto return_less;

        Y := (Y - $d800) shl 10;
        Inc(U, $10000);
        Inc(Y, U);

        if (X <> Y) then goto make_result;
        goto next_interation;
        end else
      begin
        Dec(S2);
      end;
    end;

    if (X <> Y) then
    begin
      if (X > $ffff) or ({$ifdef CPUX86}F.{$endif}lookup_utf16_lower = nil) then
      begin
        goto make_result;
      end else
      begin
        {$ifdef CPUX86}
          X := TEXTCONV_CHARCASE.VALUES[X];
          Y := TEXTCONV_CHARCASE.VALUES[Y];
        {$else}
          X := lookup_utf16_lower[X];
          Y := lookup_utf16_lower[Y];
        {$endif}
        if (X <> Y) then goto make_result;
      end;
    end;
  end;

  // next interation
next_interation:
  if (UTF8Length >= 4) then goto utf8_read_normal;
utf8_read_small:
  case UTF8Length of
    1: begin
         X := PByte(S1)^;

         if (X and $80 = 0) then
         begin
           if (S2 <= {$ifdef CPUX86}F.{$endif}TopPtr{WideLength >= 1}) then goto utf8_read_one;
           goto return_greater;
         end;
       end;
    2: begin
         X := PWord(S1)^;
         goto utf8_read;
       end;
    3: begin
         X := P4Bytes(S1)[2];
         Y := PWord(S1)^;
         X := (X shl 16) or Y;
         goto utf8_read;
       end;
  end;

  // utf8 string is finished: -1 or 0
  Result := -Ord(S2 <= {$ifdef CPUX86}F.{$endif}TopPtr{WideLength > 0 (>=1)});
  Exit;

return_less:
  Result := -1;
  Exit;

return_greater:
  Result :=  1;
  Exit;

make_fail_utf8_result:
  X := 1;
  Y := {WideLength}({$ifdef CPUX86}F.{$endif}TopPtr+1)-S2;

make_result:
  Result := Ord(X > Y)*2 - 1;
end;

// comparison between utf8 strings
// case insensitive!
function __textconv_utf8_compare_utf8(S1, S2: PUTF8Char; const Comp: TTextConvCompareOptions): NativeInt;
label
  unterminated_binary_compare, compare_difficult, compare_difficult_4,
  compare_first_ascii, ascii_1, ascii_2, ascii_3, ascii_4, compare_ascii,
  next_iteration, read_small, make_result, make_result_swaped;
var
  X, Y, U, V: NativeUInt;
  CompareFlagMask: NativeInt;

  {$ifdef CPUX86}
  Store: record
    Top1: NativeUInt;
    Top2: NativeUInt;
    Overflow1: NativeUInt;
    Overflow2: NativeUInt;
  end;
  {$else .CPUMANYREGS}
    Top1: NativeUInt;
    Top2: NativeUInt;
    Overflow1: NativeUInt;
    Overflow2: NativeUInt;
  {$endif}

  {$ifdef CPUINTEL}
  const
    MASK_80 = MASK_80_SMALL;
    MASK_40 = MASK_40_SMALL;
    MASK_65 = MASK_65_SMALL;
    MASK_7F = MASK_7F_SMALL;
  {$else .CPUARM}
  var
    MASK_80, MASK_40, MASK_65, MASK_7F: NativeUInt;
  {$endif}

  {$ifdef CPUMANYREGS}
  var
    TEXTCONV_UTF8CHAR_SIZE: PTextConvBB;
  {$endif}
begin
  {$ifNdef CPUINTEL}
    // ARM
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}
  {$ifdef CPUMANYREGS}
    TEXTCONV_UTF8CHAR_SIZE := @Tiny.Text.TEXTCONV_UTF8CHAR_SIZE;
  {$endif}

  // store parameters
  X := Comp.Length;
  CompareFlagMask := (X shr HIGH_NATIVE_BIT) - 1;
  X := NativeUInt(S1) + X and (HIGH_NATIVE_BIT_VALUE - 1);
  Y := NativeUInt(S2) + Comp.Length_2;
  {$ifdef CPUX86}Store.{$endif}Overflow1 := X;
  {$ifdef CPUX86}Store.{$endif}Overflow2 := Y;
  Dec(X, SizeOf(Cardinal));
  Dec(Y, SizeOf(Cardinal));
  {$ifdef CPUX86}Store.{$endif}Top1 := X;
  {$ifdef CPUX86}Store.{$endif}Top2 := Y;
  goto next_iteration;

unterminated_binary_compare:
  Dec(S1, U);
  Dec(S2, V);
  U := {$ifdef CPUX86}Store.{$endif}Overflow1;
  V := {$ifdef CPUX86}Store.{$endif}Overflow2;
  Dec(S1);
  Dec(S2);
  repeat
    Inc(S1);
    Inc(S2);
    X := PByte(S1)^;
    Y := PByte(S2)^;
    if (X <> Y) then goto make_result_swaped;
    if (NativeUInt(S1) = U) or (NativeUInt(S2) = V) then
    begin
      Dec(U, NativeUInt(S1));
      Dec(V, NativeUInt(S2));
      X := U;
      Y := V;
      if (X{0} <> Y{0}) then goto make_result_swaped;
      Result := 0;
      Exit;
    end;
  until (False);

compare_difficult:
  U := TEXTCONV_UTF8CHAR_SIZE[Byte(X)];
  V := TEXTCONV_UTF8CHAR_SIZE[Byte(Y)] ;
  Inc(S1, U);
  Inc(S2, V);
  if (NativeUInt(S1) > {$ifdef CPUX86}Store.{$endif}Overflow1) then goto unterminated_binary_compare;
  if (NativeUInt(S2) > {$ifdef CPUX86}Store.{$endif}Overflow2) then goto unterminated_binary_compare;
  if (U = V) then
  begin
    case (U) of
      0:
      begin
        X := Byte(X);
        Y := Byte(Y);
        if (X <> Y) then goto make_result_swaped;
      end;
      1:
      begin
        X := TEXTCONV_CHARCASE.VALUES[Byte(X)];
        Y := TEXTCONV_CHARCASE.VALUES[Byte(Y)];
        if (X <> Y) then goto make_result_swaped;
      end;
      2:
      begin
        X := Word(X);
        Y := Word(Y);
        if (X = Y) then goto next_iteration;

        if (X and $C0E0 <> $80C0) then goto compare_difficult_4;
        if (Y and $C0E0 <> $80C0) then goto compare_difficult_4;
        X := ((X and $1F) shl 6) + ((X shr 8) and $3F);
        Y := ((Y and $1F) shl 6) + ((Y shr 8) and $3F);
        X := TEXTCONV_CHARCASE.VALUES[X];
        Y := TEXTCONV_CHARCASE.VALUES[Y];
        if (X <> Y) then goto make_result_swaped;
      end;
      3:
      begin
        X := X and $ffffff;
        Y := Y and $ffffff;
        if (X = Y) then goto next_iteration;

        if (X and $C0C000 <> $808000) then goto compare_difficult_4;
        if (Y and $C0C000 <> $808000) then goto compare_difficult_4;

        U := (X and $0F) shl 12;
        V := (Y and $0F) shl 12;
        U := U + (X shr 16) and $3F;
        V := V + (Y shr 16) and $3F;
        X := (X and $3F00) shr 2;
        Y := (Y and $3F00) shr 2;
        Inc(X, U);
        Inc(Y, V);

        X := TEXTCONV_CHARCASE.VALUES[X];
        Y := TEXTCONV_CHARCASE.VALUES[Y];
        if (X <> Y) then goto make_result_swaped;
      end;
      5:
      begin
        if (X <> Y) then goto make_result;
        X := PByte(PAnsiChar(S1) - SizeOf(Byte))^;
        Y := PByte(PAnsiChar(S2) - SizeOf(Byte))^;
        goto compare_difficult_4;
      end;
      6:
      begin
        if (X <> Y) then goto make_result;
        X := PWord(PAnsiChar(S1) - SizeOf(Word))^;
        Y := PWord(PAnsiChar(S2) - SizeOf(Word))^;
        goto compare_difficult_4;
      end;
    else
    compare_difficult_4:
      if (X <> Y) then goto make_result;
    end;
  end else
  // if (U <> V) then
  begin
    if (U = 2) then
    begin
      if (V <> 3) then goto make_result;

      if (Y and $C0C000 <> $808000) then goto make_result;
      if (X and $C0E0 <> $80C0) then goto make_result;

      U := (Y and $0F) shl 12;
      U := U + (Y shr 16) and $3F;
      X := ((X and $1F) shl 6) + ((X shr 8) and $3F);
      Y := (Y and $3F00) shr 2;
      Inc(Y, U);

      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
      if (X <> Y) then goto make_result_swaped;
    end else
    if (U = 3) then
    begin
      if (V <> 2) then goto make_result;
      if (X and $C0C000 <> $808000) then goto make_result;
      if (Y and $C0E0 <> $80C0) then goto make_result;

      U := (X and $0F) shl 12;
      U := U + (X shr 16) and $3F;
      Y := ((Y and $1F) shl 6) + ((Y shr 8) and $3F);
      X := (X and $3F00) shr 2;
      Inc(X, U);

      X := TEXTCONV_CHARCASE.VALUES[X];
      Y := TEXTCONV_CHARCASE.VALUES[Y];
      if (X <> Y) then goto make_result_swaped;
    end else
    goto make_result;
  end;
  goto next_iteration;

compare_first_ascii:
  if (U and $8000 <> 0) then goto ascii_1;
  if (U and $800000 <> 0) then goto ascii_2;
  ascii_3:
    X := X and $ffffff;
    Y := Y and $ffffff;
    Inc(S1, 3);
    Inc(S2, 3);
    goto compare_ascii;
  ascii_2:
    X := X and $ffff;
    Y := Y and $ffff;
    Inc(S1, 2);
    Inc(S2, 2);
    goto compare_ascii;
  ascii_1:
    X := X and $ff;
    Y := Y and $ff;
    Inc(S1, 1);
    Inc(S2, 1);
    goto compare_ascii;
ascii_4:
  Inc(S1, SizeOf(Cardinal));
  Inc(S2, SizeOf(Cardinal));
compare_ascii:
  if (X <> Y) then
  begin
    U := X xor MASK_40;
    V := (U + MASK_65);
    U := (U + MASK_7F) and Integer(MASK_80);
    X := X + ((not V) and U) shr 2;

    U := Y xor MASK_40;
    V := (U + MASK_65);
    U := (U + MASK_7F) and Integer(MASK_80);
    Y := Y + ((not V) and U) shr 2;

    if (X <> Y) then goto make_result;
  end;

  // next interation
next_iteration:
  if ((Ord(NativeUInt(S1) >= {$ifdef CPUX86}Store.{$endif}Top1) or Ord(NativeUInt(S2) >= {$ifdef CPUX86}Store.{$endif}Top2)) <> 0) then goto read_small;
  X := PCardinal(S1)^;
  Y := PCardinal(S2)^;
  U := X or Y;
  if (U and Integer(MASK_80) = 0) then goto ascii_4;
  if (U and $80 = 0) then goto compare_first_ascii;
  goto compare_difficult;

read_small:
  case {Length1}({$ifdef CPUX86}Store.{$endif}Overflow1 - NativeUInt(S1)) of
    0: begin
         // -1 or 0
         Result := -(Ord({$ifdef CPUX86}Store.{$endif}Overflow2 <> NativeUInt(S2))){-Ord(Length2>0)};
         Exit;
       end;
    1: begin
         X := PByte(S1)^;
       end;
    2: begin
         X := PWord(S1)^;
       end;
    3: begin
         X := P4Bytes(S1)[2];
         X := (X shl 16) + PWord(S1)^;
       end;
  else
    X := PCardinal(S1)^;
  end;

  case {Length2}({$ifdef CPUX86}Store.{$endif}Overflow2 - NativeUInt(S2)) of
    0: begin
         // 0 or 1
         Result := CompareFlagMask and 1{Ord(Length1>0)};
         Exit;
       end;
    1: begin
         Y := PByte(S2)^;
       end;
    2: begin
         Y := PWord(S2)^;
       end;
    3: begin
         Y := P4Bytes(S2)[2];
         Y := (Y shl 16) + PWord(S2)^;
       end;
  else
    Y := PCardinal(S2)^;
  end;
  goto compare_difficult;


make_result:
  X := (Swap(X) shl 16) + Swap(X shr 16);
  Y := (Swap(Y) shl 16) + Swap(Y shr 16);

make_result_swaped:
  Result := Ord(X > Y)*2 - 1;
end;


// comparison between utf8 and sbcs(conversion to utf16)
// optional case sensitive (Lookup = @TEXTCONV_CHARCASE.VALUES)
// Lookup2 is normal/lower utf16 (PTextConvWB)
function __textconv_utf8_compare_sbcs(S1: PUTF8Char; S2: PAnsiChar; const Comp: TTextConvCompareOptions): NativeInt;
{$ifNdef CPUX86}
label
  read_normal, read, read_small, compare_ascii, next_iteration,
  return_equal, make_result;
var
  UTF8Length, UTF16Length: NativeUInt;
  lookup_utf16_lower: PTextConvWW{optional(not nil)};
  lookup_sbcs: PTextConvWB;

  N: Byte;
  X, Y, U, V: NativeUInt;

  {$ifdef CPUINTEL}
  const
    MASK_80 = MASK_80_SMALL;
    MASK_40 = MASK_40_SMALL;
    MASK_65 = MASK_65_SMALL;
    MASK_7F = MASK_7F_SMALL;
  {$else .CPUARM}
  var
    MASK_80, MASK_40, MASK_65, MASK_7F: NativeUInt;
  {$endif}

  {$ifdef CPUMANYREGS}
  var
    TEXTCONV_UTF8CHAR_SIZE: PTextConvBB;
  {$endif}
begin
  {$ifNdef CPUINTEL}
    // ARM
    MASK_80 := MASK_80_SMALL;
    MASK_40 := MASK_40_SMALL;
    MASK_65 := MASK_65_SMALL;
    MASK_7F := MASK_7F_SMALL;
  {$endif}
  {$ifdef CPUMANYREGS}
    TEXTCONV_UTF8CHAR_SIZE := @Tiny.Text.TEXTCONV_UTF8CHAR_SIZE;
  {$endif}

  UTF8Length := Comp.Length;
  UTF16Length := Comp.Length_2;
  lookup_utf16_lower := Comp.Lookup;
  lookup_sbcs := Comp.Lookup_2;

  N := Ord(UTF8Length < 4) + Ord(UTF16Length < 4);
  if (N <> 0) then goto read_small;
read_normal:
  X := PCardinal(S1)^;
  Y := PCardinal(S2)^;
  U := X or Y;
  if (U and Integer(MASK_80) = 0) then
  begin
    Inc(S1, SizeOf(Cardinal));
    Inc(S2, SizeOf(Cardinal));
    Dec(UTF8Length, SizeOf(Cardinal));
    Dec(UTF16Length, SizeOf(Cardinal));
    goto compare_ascii;
  end else
  begin
    // compare N ascii symbols
    // N := Ord(U and $80 = 0)+Ord(U and $8080 = 0)+Ord(U and $808080 = 0);
    // if (N <> 0) then
    if (U and $80 = 0) then
    begin
      // shift X,Y(N)
      N := Ord(U and $8080 = 0)+Ord(U and $808080 = 0);
      V := N;
      N := (4-1)-N;
      U := -1 shr Byte(N shl 3{*8});
      Inc(V);

      X := X and U;
      Y := Y and U;
      Inc(S1, V);
      Inc(S2, V);
      Dec(UTF8Length, V);
      Dec(UTF16Length, V);
    compare_ascii:
      if (X <> Y) then
      begin
        if (lookup_utf16_lower <> nil) then
        begin
          U := X xor MASK_40;
          V := (U + MASK_65);
          U := (U + MASK_7F) and Integer(MASK_80);
          X := X + ((not V) and U) shr 2;

          U := Y xor MASK_40;
          V := (U + MASK_65);
          U := (U + MASK_7F) and Integer(MASK_80);
          Y := Y + ((not V) and U) shr 2;
        end;

        if (X <> Y) then
        begin
          X := (Swap(X) shl 16) + Swap(X shr 16);
          Y := (Swap(Y) shl 16) + Swap(Y shr 16);
          goto make_result;
        end;
      end;

      if (NativeInt(UTF8Length or UTF16Length) <= 0) then
      begin
        X := UTF8Length + SizeOf(Cardinal);
        Y := UTF16Length + SizeOf(Cardinal);
        if (X <> Y) then goto make_result;
        Result := 0;
        Exit;
      end;
    end else
    begin
    read:
      Y := lookup_sbcs[Byte(Y)];
      Inc(S2);
      Dec(UTF16Length);

      if (X and $80 = 0) then
      begin
        X := X and $7f;
        Inc(S1);
        Dec(UTF8Length);
      end else
      if (X and $C0E0 = $80C0) then
      begin
        // C := ((C and $1F) shl 6) + ((C shr 8) and $3F);
        U := X;
        X := X and $1F;
        U := U shr 8;
        X := X shl 6;
        U := U and $3F;
        Inc(S1, 2);
        Dec(UTF8Length, 2);
        Inc(X, U);
      end else
      if (X and $C0C000 = $808000) then
      begin
        // C := ((C & 0x0f) << 12) | ((C & 0x3f00) >> 2) | (C >> 16) & 0x3f);
        U := (X and $0F) shl 12;
        U := U + (X shr 16) and $3F;
        Inc(S1, 3);
        X := (X and $3F00) shr 2;
        Dec(UTF8Length, 3);
        Inc(X, U);
      end else
      begin
        case TEXTCONV_UTF8CHAR_SIZE[Byte(X)] of
          0..3: begin
                  Result := -1;
                  Exit;
                end;
        else
          Result := 1;
          Exit;
        end;
      end;

      if (lookup_utf16_lower <> nil) then X := lookup_utf16_lower[X];
      if (X <> Y) then goto make_result;
    end;
  end;

  // next interation
next_iteration:
  N := Ord(UTF8Length < 4) + Ord(UTF16Length < 4);
  if (N = 0) then goto read_normal;
read_small:
  case UTF8Length of
    0: begin
         // -1 or 0
         Result := -Ord(UTF16Length>0);
         Exit;
       end;
    1: begin
         X := PByte(S1)^;
       end;
    2: begin
         X := PWord(S1)^;
       end;
    3: begin
         X := P4Bytes(S1)[2];
         X := (X shl 16) + PWord(S1)^;
       end;
  else
    X := PCardinal(S1)^;
  end;

  case UTF16Length of
    0: begin
         // 0 or 1
         Result := Ord(UTF8Length>0);
         Exit;
       end;
    1: begin
         Y := PByte(S2)^;
       end;
    2: begin
         Y := PWord(S2)^;
       end;
    3: begin
         Y := P4Bytes(S2)[2];
         Y := (Y shl 16) + PWord(S2)^;
       end;
  else
    Y := PCardinal(S2)^;
  end;
  goto read;

make_result:
  Result := Ord(X > Y)*2 - 1;
end;
{$else .CPUX86} {$ifdef FPC}assembler; nostackframe;{$endif}
asm
@prefix:
  push ebp
  push esi
  push edi
  push ebx
@begin:
  mov esi, [ECX].TTextConvCompareOptions.Length   // UTF8Length
  mov edi, [ECX].TTextConvCompareOptions.Length_2 // UTF16Length
  mov ebp, [ECX].TTextConvCompareOptions.Lookup_2 // lookup_sbcs
  push [ECX].TTextConvCompareOptions.Lookup // lookup_utf16_lower (esp+8)

  lea ecx, [edx+edi]
  lea ebx, [eax+esi]
  push ecx // TopUTF16Ptr (esp+4)
  push ebx // TopUTF8Ptr (esp+0)

  cmp esi, 4
  setb cl
  cmp edi, 4
  setb bl
  add cl, bl
  jz @read_normal_2
  jmp @read_small

@read_normal:
  mov eax, [esp]
  mov edx, [esp+4]
  sub eax, esi   // S1 := TopUTF8Ptr-UTF8Length
  sub edx, edi   // S2 := TopUTF16Ptr-UTF16Length
@read_normal_2:
  mov eax, [eax] // X := PCardinal(S1)^;
  mov edx, [edx] // Y := PCardinal(S2)^;
@read:
  // U := X or Y;
  // if (U and Integer(MASK_80) = 0) then
  mov ebx, eax
  or ebx, edx
  test ebx, MASK_80_SMALL
  jnz @read_not_4
  @read_4:
    lea esi, [esi - 4]  // Dec(UTF8Length, SizeOf(Cardinal));
    cmp eax, edx
    lea edi, [edi - 4]  // Dec(UTF16Length, SizeOf(Cardinal));
    // if (X = Y) then goto @next_iteration
    mov ecx, esi  //
    je @is_length_available
    jmp @compare_ascii
  @read_not_4:
    test bl, $80
    jnz @compare_utf8
  @compare_ascii_1_3:
    // shift X,Y(N)
    // N(ebx) := Ord(U and $8080 = 0)+Ord(U and $808080 = 0);
    test ebx, $8080
    setz cl
    test ebx, $808080
    setz bl
    add bl, cl
    movzx ebx, bl
    // V := N+1 / N := (4-1)-N
    mov ecx, 4-1
    sub ecx, ebx
    inc ebx
    // Dec(UTF8Length/UTF16Length, V); / U := -1 shr Byte(N*8);
    shl ecx, 3
    sub esi, ebx
    sub edi, ebx
    or ebx, -1
    shr ebx, cl
    // X, Y
    and eax, ebx
    and edx, ebx
    mov ecx, esi //
    cmp eax, edx
    je @is_length_available
  @compare_ascii:
    bswap eax
    bswap edx
    cmp Cardinal ptr [esp+8], 0  // lookup_utf16_lower
    jz @compare_ascii_final   // cmp --> @make_result

    // make lower
    mov ebx, eax
    xor ebx, MASK_40_SMALL
    lea ecx, [ebx + MASK_65_SMALL]
    add ebx, MASK_7F_SMALL
    not ecx
    and ebx, MASK_80_SMALL
    and ecx, ebx

    mov ebx, edx
    shr ecx, 2
    xor ebx, MASK_40_SMALL
    add eax, ecx
    lea ecx, [ebx + MASK_65_SMALL]
    add ebx, MASK_7F_SMALL
    not ecx
    and ebx, MASK_80_SMALL
    and ebx, ecx
    shr ebx, 2
    mov ecx, esi //
    add edx, ebx

  @compare_ascii_final:
    cmp eax, edx
    jne @make_result

  @is_length_available:
    // if (NativeInt(UTF8Length or UTF16Length) <= 0) then
    or ecx, edi
    jg @next_iteration
    // Result := Compare(UTF8Length, UTF16Length)
    add esi, 4
    add edi, 4
    cmp esi, edi
    jne @make_result
    xor eax, eax
    jmp @postfix

  @compare_utf8:
    // Y := lookup_sbcs[Byte(Y)] / Dec(UTF16Length)
    movzx edx, dl
    mov ebx, eax
    dec edi
    mov ecx, eax
    movzx edx, word ptr [ebp + edx*2]
  @look_utf8_1:
    // if (X and $80 = 0) then
    test al, $80
    jnz @look_utf8_2
    // C := C and $7f;
    and eax, $7f
    dec esi
  jmp @look_utf8_done
  @look_utf8_2:
    // if (X and $C0E0 = $80C0) then
    and ecx, $C0E0
    and ebx, $C0C000
    cmp ecx, $80C0
    jne @look_utf8_3
    // C := ((C and $1F) shl 6) + ((C shr 8) and $3F);
    mov ebx, eax
    and eax, $1F
    shr ebx, 8
    shl eax, 6
    and ebx, $3F
    sub esi, 2
    add eax, ebx
  jmp @look_utf8_done
  @look_utf8_3:
    // if (X and $C0C000 = $808000) then
    cmp ebx, $808000
    jne @look_utf8_else
    // C := ((C & 0x0f) << 12) | ((C & 0x3f00) >> 2) | (C >> 16) & 0x3f);
    mov ebx, eax
    mov ecx, eax
    and eax, $0f
    and ebx, $3f00
    shr ecx, 16
    shl eax, 12
    shr ebx, 2
    and ecx, $3f
    add eax, ebx
    sub esi, 3
    add eax, ecx
  jmp @look_utf8_done
  @look_utf8_else:
    // case TEXTCONV_UTF8CHAR_SIZE[Byte(X)] of
    // -1 or 1
    movzx eax, al
    cmp byte ptr [TEXTCONV_UTF8CHAR_SIZE + eax], 3
    jmp @make_result

  //if (lookup_utf16_lower <> nil) then X := lookup_utf16_lower[X];
  //if (X <> Y) then goto make_result;
  @look_utf8_done:
    cmp Cardinal ptr [esp+8], 0
    jz @look_utf8_compare
    movzx eax, word ptr [TEXTCONV_CHARCASE + eax*2]
  @look_utf8_compare:
  cmp eax, edx
  jne @make_result

@next_iteration:
  cmp esi, 4
  setb cl
  cmp edi, 4
  setb bl
  add cl, bl
  jz @read_normal
@read_small:
  mov eax, [esp]
  mov edx, [esp+4]
  sub eax, esi   // S1 := TopUTF8Ptr-UTF8Length
  sub edx, edi   // S2 := TopUTF16Ptr-UTF16Length

  // case UTF8Length of
  cmp esi, 4
  jae @utf8_len_4p
  jmp [offset @case_utf8_len + esi*4]
@case_utf8_len: DD @utf8_len_0,@utf8_len_1,@utf8_len_2,@utf8_len_3
@utf8_len_0:
  // Result := -Ord(UTF16Length>0) ---> -1 or 0
  test edi, edi
  seta al
  movzx eax, al
  neg eax
  jmp @postfix
@utf8_len_1:
  movzx eax, byte ptr [eax]
  jmp @utf8_len_done
@utf8_len_2:
  movzx eax, word ptr [eax]
  jmp @utf8_len_done
@utf8_len_3:
  movzx ecx, byte ptr [eax+2]
  movzx eax, word ptr [eax]
  shl ecx, 16
  or eax, ecx
  jmp @utf8_len_done
@utf8_len_4p:
  mov eax, [eax]
@utf8_len_done:

  // case UTF16Length of
  cmp edi, 4
  jae @utf16_len_4p
  jmp [offset @case_utf16_len + edi*4]
@case_utf16_len: DD @utf16_len_0,@utf16_len_1,@utf16_len_2,@utf16_len_3
@utf16_len_0:
  // Result := Ord(UTF8Length>0) ---> 0 or 1
  xor eax, eax
  test esi, esi
  seta al
  jmp @postfix
@utf16_len_1:
  movzx edx, byte ptr [edx]
  jmp @read
@utf16_len_2:
  movzx edx, word ptr [edx]
  jmp @read
@utf16_len_3:
  movzx ecx, byte ptr [edx+2]
  movzx edx, word ptr [edx]
  shl ecx, 16
  or edx, ecx
  jmp @read
@utf16_len_4p:
  mov edx, [edx]
  jmp @read

@make_result:
  seta al
  movzx eax, al
  lea eax, [eax*2-1]
@postfix:
  add esp, 12
  pop ebx
  pop edi
  pop esi
  pop ebp
end;
{$endif}
{$ifdef undef}{$ENDREGION}{$endif}

{$ifdef undef}{$REGION 'SBCS<-->UTF8<-->UTF16 comparisons'}{$endif}
function sbcs_equal_sbcs(S1: PAnsiChar; S2: PAnsiChar; Length: NativeUInt; CP1: Word = 0; CP2: Word = 0): Boolean;
label
  same_cp, ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (Length <> 0) and ((S1 <> S2) or (CP1 <> CP2)) then
  begin
    Comp.Length := Length;
    C1 := PByte(S1)^;
    C2 := PByte(S2)^;
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    if (CP1 = CP2) then
    begin
    same_cp:
      Ret := __textconv_compare_bytes(Pointer(S1), Pointer(S2), Comp.Length);
    end else
    begin
      // Comp.Lookup := SBCS(CP1).OriginalUCS2
      Index := NativeUInt(CP1);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CP1) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup := SBCS.FUCS2.Original;
      if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

      // Comp.Lookup_2 := SBCS(CP2).OriginalUCS2
      Index := NativeUInt(CP2);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CP2) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

      if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
      Ret := __textconv_sbcs_compare_sbcs_2(Pointer(S1), Pointer(S2), Comp);
    end;
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

function sbcs_equal_samesbcs(S1: PAnsiChar; S2: PAnsiChar; Length: NativeUInt): Boolean;
label
  ret_false;
var
  Ret: NativeInt;
begin
  if (Length <> 0) and (S1 <> S2) then
  begin
    if (PByte(S1)^ <> PByte(S2)^) then goto ret_false;

    Ret := __textconv_compare_bytes(Pointer(S1), Pointer(S2), Length);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function sbcs_equal_sbcs(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP1: Word = 0; const CP2: Word = 0{$endif}): Boolean;
label
  {$ifNdef INLINESUPPORT}same_cp,{$endif} ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifNdef INLINESUPPORT}
    {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
    Index: NativeUInt;
    Value: Integer;
    SBCS: PTextConvSBCS;
    Comp: TTextConvCompareOptions;
  {$endif}
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and ((P1 <> P2){$ifNdef INTERNALCODEPAGE}or (CP1 <> CP2){$endif}) then
  begin
    C1 := PByte(P1)^;
    C2 := PByte(P2)^;
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    {$ifdef INLINESUPPORT}
      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, ASTR_OFFSET_LENGTH);
      Ret := sbcs_compare_sbcs(AnsiString(Pointer(P1)), AnsiString(Pointer(P2)){$ifNdef INTERNALCODEPAGE}, CP1, CP2{$endif});
    {$else}
      Comp.Length := Length;
      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      if ({$ifdef INTERNALCODEPAGE}CodePage = PWord(P2)^{$else}CP1 = CP2{$endif}) then
      begin
        Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      same_cp:
        Ret := __textconv_compare_bytes(Pointer(P1), Pointer(P2), Comp.Length);
      end else
      begin
        // Comp.Lookup := SBCS(CP1).OriginalUCS2
        Index := NativeUInt({$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif});
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = {$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif}) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup := SBCS.FUCS2.Original;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

        {$ifdef INTERNALCODEPAGE}CodePage := PWord(P2)^;{$endif}
        Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});

        // Comp.Lookup_2 := SBCS(CP2).OriginalUCS2
        Index := NativeUInt({$ifdef INTERNALCODEPAGE}CodePage{$else}CP2{$endif});
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = {$ifdef INTERNALCODEPAGE}CodePage{$else}CP2{$endif}) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Original;
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

        if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
        Ret := __textconv_sbcs_compare_sbcs_2(Pointer(P1), Pointer(P2), Comp);
      end;
    {$endif}
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;

{inline} function sbcs_equal_samesbcs(const S1: AnsiString; const S2: AnsiString): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    if (PByte(P1)^ <> PByte(P2)^) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    Inc(P1, ASTR_OFFSET_LENGTH);
    Inc(P2, ASTR_OFFSET_LENGTH);
    Ret := __textconv_compare_bytes(Pointer(P1), Pointer(P2), Length);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;

{inline} function sbcs_equal_sbcs(const S1: ShortString; const S2: ShortString; const CP1: Word = 0; const CP2: Word = 0): Boolean;
label
  {$ifNdef INLINESUPPORT}same_cp,{$endif} ret_false;
var
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifNdef INLINESUPPORT}
    Index: NativeUInt;
    Value: Integer;
    SBCS: PTextConvSBCS;
    Comp: TTextConvCompareOptions;
  {$endif}
  Ret: NativeInt;
begin
  Length := PByte(@S1)^;
  if (Byte(Length) <> PByte(@S2)^) then
  begin
    Result := False;
    Exit;
  end;

  if (Length <> 0) and ((@S1 <> @S2) or (CP1 <> CP2)) then
  begin
    {$ifNdef INLINESUPPORT}
    Comp.Length := Length;
    {$endif}
    C1 := Byte(S1[1]);
    C2 := Byte(S2[1]);
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    {$ifdef INLINESUPPORT}
      Ret := sbcs_compare_sbcs(S1, S2, CP1, CP2);
    {$else}
      if (CP1 = CP2) then
      begin
      same_cp:
        Ret := __textconv_compare_bytes(Pointer(@S1[1]), Pointer(@S2[1]), Comp.Length);
      end else
      begin
        // Comp.Lookup := SBCS(CP1).OriginalUCS2
        Index := NativeUInt(CP1);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP1) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup := SBCS.FUCS2.Original;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

        // Comp.Lookup_2 := SBCS(CP2).OriginalUCS2
        Index := NativeUInt(CP2);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP2) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Original;
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

        if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
        Ret := __textconv_sbcs_compare_sbcs_2(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      end;
    {$endif}
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function sbcs_equal_samesbcs(const S1: ShortString; const S2: ShortString): Boolean;
label
  ret_false;
var
  Length: Word;
  Ret: NativeInt;
begin
  Length := PWord(@S1)^;
  if (Length <> PWord(@S2)^) then
  begin
    Result := (Length and $ff = 0) and (PByte(@S2)^ = 0);
    Exit;
  end;

  if (Length and $ff <> 0) and (@S1 <> @S2) then
  begin
    Ret := __textconv_compare_bytes(Pointer(@S1[1]), Pointer(@S2[1]), Byte(Length));
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

function sbcs_equal_sbcs_ignorecase(S1: PAnsiChar; S2: PAnsiChar; Length: NativeUInt; CP1: Word = 0; CP2: Word = 0): Boolean;
label
  same_cp, ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (Length <> 0) and ((S1 <> S2) or (CP1 <> CP2)) then
  begin
    Comp.Length := Length;
    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    if (CP1 = CP2) then
    begin
      // Comp.Lookup := SBCS(CP1).Lower
      Index := NativeUInt(CP1);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CP1) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    same_cp:
      Comp.Lookup := SBCS.FLowerCase;
      if (Comp.Lookup = nil) then Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);

      Ret := __textconv_sbcs_compare_sbcs_1(Pointer(S1), Pointer(S2), Comp);
    end else
    begin
      // Comp.Lookup := SBCS(CP1).LowerUCS2
      Index := NativeUInt(CP1);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CP1) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup := SBCS.FUCS2.Lower;
      if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

      // Comp.Lookup_2 := SBCS(CP2).LowerUCS2
      Index := NativeUInt(CP2);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CP2) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

      if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
      Ret := __textconv_sbcs_compare_sbcs_2(Pointer(S1), Pointer(S2), Comp);
    end;
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

function sbcs_equal_samesbcs_ignorecase(S1: PAnsiChar; S2: PAnsiChar; Length: NativeUInt; CodePage: Word = 0): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (Length <> 0) and (S1 <> S2) then
  begin
    Comp.Length := Length;
    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    // Comp.Lookup := SBCS(CodePage).Lower
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup := SBCS.FLowerCase;
    if (Comp.Lookup = nil) then Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);

    Ret := __textconv_sbcs_compare_sbcs_1(Pointer(S1), Pointer(S2), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function sbcs_equal_sbcs_ignorecase(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP1: Word = 0; const CP2: Word = 0{$endif}): Boolean;
label
  {$ifNdef INLINESUPPORT}same_cp,{$endif} ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifNdef INLINESUPPORT}
    {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
    Index: NativeUInt;
    Value: Integer;
    SBCS: PTextConvSBCS;
    Comp: TTextConvCompareOptions;
  {$endif}
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and ((P1 <> P2){$ifNdef INTERNALCODEPAGE}or (CP1 <> CP2){$endif}) then
  begin
    C2 := PByte(P1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(P2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    {$ifdef INLINESUPPORT}
      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, ASTR_OFFSET_LENGTH);
      Ret := sbcs_compare_sbcs_ignorecase(AnsiString(Pointer(P1)), AnsiString(Pointer(P2)){$ifNdef INTERNALCODEPAGE}, CP1, CP2{$endif});
    {$else}
      Comp.Length := Length;
      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      if ({$ifdef INTERNALCODEPAGE}CodePage = PWord(P2)^{$else}CP1 = CP2{$endif}) then
      begin
        Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
        // Comp.Lookup := SBCS(CP1).Lower
        Index := NativeUInt({$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif});
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = {$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif}) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      same_cp:
        Comp.Lookup := SBCS.FLowerCase;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);

        Ret := __textconv_sbcs_compare_sbcs_1(Pointer(P1), Pointer(P2), Comp);
      end else
      begin
        // Comp.Lookup := SBCS(CP1).LowerUCS2
        Index := NativeUInt({$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif});
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = {$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif}) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup := SBCS.FUCS2.Lower;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

        {$ifdef INTERNALCODEPAGE}CodePage := PWord(P2)^;{$endif}
        Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});

        // Comp.Lookup_2 := SBCS(CP2).LowerUCS2
        Index := NativeUInt({$ifdef INTERNALCODEPAGE}CodePage{$else}CP2{$endif});
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = {$ifdef INTERNALCODEPAGE}CodePage{$else}CP2{$endif}) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Lower;
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

        if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
        Ret := __textconv_sbcs_compare_sbcs_2(Pointer(P1), Pointer(P2), Comp);
      end;
    {$endif}
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;

{inline} function sbcs_equal_samesbcs_ignorecase(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    C2 := PByte(P1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(P2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    Comp.Length := Length;
    {$ifdef INTERNALCODEPAGE}
    Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    CodePage := PWord(P1)^;
    {$endif}
    Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
    Inc(P2, ASTR_OFFSET_LENGTH);
    // Comp.Lookup := SBCS(CodePage).Lower
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup := SBCS.FLowerCase;
    if (Comp.Lookup = nil) then
    begin
      Comp.Lookup_2 := P2;
      Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);
      P2 := Comp.Lookup_2;
    end;

    Ret := __textconv_sbcs_compare_sbcs_1(Pointer(P1), Pointer(P2), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;

{inline} function sbcs_equal_sbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CP1: Word = 0; const CP2: Word = 0): Boolean;
label
  {$ifNdef INLINESUPPORT}same_cp,{$endif} ret_false;
var
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifNdef INLINESUPPORT}
    Index: NativeUInt;
    Value: Integer;
    SBCS: PTextConvSBCS;
    Comp: TTextConvCompareOptions;
  {$endif}
  Ret: NativeInt;
begin
  Length := PByte(@S1)^;
  if (Byte(Length) <> PByte(@S2)^) then
  begin
    Result := False;
    Exit;
  end;

  if (Length <> 0) and ((@S1 <> @S2) or (CP1 <> CP2)) then
  begin
    {$ifNdef INLINESUPPORT}
    Comp.Length := Length;
    {$endif}
    C2 := Byte(S1[1]);
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := Byte(S2[1]);
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    {$ifdef INLINESUPPORT}
      Ret := sbcs_compare_sbcs_ignorecase(S1, S2, CP1, CP2);
    {$else}
      if (CP1 = CP2) then
      begin
        // Comp.Lookup := SBCS(CP1).Lower
        Index := NativeUInt(CP1);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP1) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      same_cp:
        Comp.Lookup := SBCS.FLowerCase;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);

        Ret := __textconv_sbcs_compare_sbcs_1(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      end else
      begin
        // Comp.Lookup := SBCS(CP1).LowerUCS2
        Index := NativeUInt(CP1);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP1) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup := SBCS.FUCS2.Lower;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

        // Comp.Lookup_2 := SBCS(CP2).LowerUCS2
        Index := NativeUInt(CP2);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP2) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Lower;
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

        if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
        Ret := __textconv_sbcs_compare_sbcs_2(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      end;
    {$endif}
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function sbcs_equal_samesbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): Boolean;
label
  ret_false;
var
  Length: Cardinal;
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  Length := PByte(@S1)^;
  if (Byte(Length) <> PByte(@S2)^) then
  begin
    Result := False;
    Exit;
  end;

  if (Length <> 0) and (@S1 <> @S2) then
  begin
    Comp.Length := Length;
    C2 := Byte(S1[1]);
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := Byte(S2[1]);
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    // Comp.Lookup := SBCS(CodePage).Lower
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup := SBCS.FLowerCase;
    if (Comp.Lookup = nil) then Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);

    Ret := __textconv_sbcs_compare_sbcs_1(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

function sbcs_compare_sbcs(S1: PAnsiChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CP1: Word = 0; CP2: Word = 0): NativeInt;
label
  same_cp;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) and ((S1 <> S2) or (CP1 <> CP2)) then
  begin
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    C1 := PByte(S1)^;
    C2 := PByte(S2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      if (CP1 = CP2) then
      begin
      same_cp:
        Result := __textconv_compare_bytes(Pointer(S1), Pointer(S2), Comp.Length);
      end else
      begin
        // Comp.Lookup := SBCS(CP1).OriginalUCS2
        Index := NativeUInt(CP1);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP1) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup := SBCS.FUCS2.Original;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

        // Comp.Lookup_2 := SBCS(CP2).OriginalUCS2
        Index := NativeUInt(CP2);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP2) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Original;
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

        if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
        Result := __textconv_sbcs_compare_sbcs_2(Pointer(S1), Pointer(S2), Comp);
      end;
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

function sbcs_compare_samesbcs(S1: PAnsiChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt): NativeInt;
var
  C1, C2: NativeUInt;
begin
  if (L1 <> 0) and (L2 <> 0) and (S1 <> S2) then
  begin
    C1 := PByte(S1)^;
    C2 := PByte(S2)^;
    if (C1 = C2) then
    begin
      if (L1 <= L2) then
      begin
        L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        L1 := L2;
        L2 := NativeUInt(-1);
      end;

      L1 := __textconv_compare_bytes(Pointer(S1), Pointer(S2),  L1);
      Result := L1 * 2 - L2;
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

function sbcs_compare_sbcs(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP1: Word = 0; const CP2: Word = 0{$endif}): NativeInt;
label
  same_cp;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and ((P1 <> P2){$ifNdef INTERNALCODEPAGE}or (CP1 <> CP2){$endif}) then
  begin
    L1 := PByte(P1)^;
    L2 := PByte(P2)^;
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        Comp.Length := L1;
        Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        Comp.Length := L2;
        Comp.Length_2 := NativeUInt(-1);
      end;

      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      if ({$ifdef INTERNALCODEPAGE}CodePage = PWord(P2)^{$else}CP1 = CP2{$endif}) then
      begin
        Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      same_cp:
        Result := __textconv_compare_bytes(Pointer(P1), Pointer(P2), Comp.Length);
      end else
      begin
        // Comp.Lookup := SBCS(CP1).OriginalUCS2
        Index := NativeUInt({$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif});
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = {$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif}) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup := SBCS.FUCS2.Original;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

        {$ifdef INTERNALCODEPAGE}CodePage := PWord(P2)^;{$endif}
        Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});

        // Comp.Lookup_2 := SBCS(CP2).OriginalUCS2
        Index := NativeUInt({$ifdef INTERNALCODEPAGE}CodePage{$else}CP2{$endif});
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = {$ifdef INTERNALCODEPAGE}CodePage{$else}CP2{$endif}) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Original;
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

        if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
        Result := __textconv_sbcs_compare_sbcs_2(Pointer(P1), Pointer(P2), Comp);
      end;
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{inline} function sbcs_compare_samesbcs(const S1: AnsiString; const S2: AnsiString): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    L1 := PByte(P1)^;
    L2 := PByte(P2)^;
    if (L1 = L2) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        L1 := L2;
        L2 := NativeUInt(-1);
      end;

      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, ASTR_OFFSET_LENGTH);
      L1 := __textconv_compare_bytes(Pointer(P1), Pointer(P2),  L1);
      Result := L1 * 2 - L2;
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

function sbcs_compare_sbcs(const S1: ShortString; const S2: ShortString; const CP1: Word = 0; const CP2: Word = 0): NativeInt;
label
  same_cp;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) and ((@S1 <> @S2) or (CP1 <> CP2)) then
  begin
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    L1 := Byte(S1[1]);
    L2 := Byte(S2[1]);
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      if (CP1 = CP2) then
      begin
      same_cp:
        Result := __textconv_compare_bytes(Pointer(@S1[1]), Pointer(@S2[1]), Comp.Length);
      end else
      begin
        // Comp.Lookup := SBCS(CP1).OriginalUCS2
        Index := NativeUInt(CP1);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP1) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup := SBCS.FUCS2.Original;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

        // Comp.Lookup_2 := SBCS(CP2).OriginalUCS2
        Index := NativeUInt(CP2);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP2) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Original;
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

        if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
        Result := __textconv_sbcs_compare_sbcs_2(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      end;
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function sbcs_compare_samesbcs(const S1: ShortString; const S2: ShortString): NativeInt;
var
  L1, L2: NativeUInt;
begin
  L1 := PWord(@S1)^;
  L2 := PWord(@S2)^;

  if (L1 and $ff <> 0) and (L2 and $ff <> 0) and (@S1 <> @S2) then
  begin
    L1 := L1 shr 8;
    L2 := L2 shr 8;
    if (L1 = L2) then
    begin
      L1 := PByte(@S1)^;
      L2 := PByte(@S2)^;
      if (L1 <= L2) then
      begin
        L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        L1 := L2;
        L2 := NativeUInt(-1);
      end;

      L1 := __textconv_compare_bytes(Pointer(@S1[1]), Pointer(@S2[1]),  L1);
      Result := L1 * 2 - L2;
      Exit;
    end;
  end;

  Result := NativeInt(Byte(L1)) - NativeInt(Byte(L2));
end;

function sbcs_compare_sbcs_ignorecase(S1: PAnsiChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CP1: Word = 0; CP2: Word = 0): NativeInt;
label
  same_cp;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) and ((S1 <> S2) or (CP1 <> CP2)) then
  begin
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      if (CP1 = CP2) then
      begin
        // Comp.Lookup := SBCS(CP1).Lower
        Index := NativeUInt(CP1);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP1) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      same_cp:
        Comp.Lookup := SBCS.FLowerCase;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);

        Result := __textconv_sbcs_compare_sbcs_1(Pointer(S1), Pointer(S2), Comp);
      end else
      begin
        // Comp.Lookup := SBCS(CP1).LowerUCS2
        Index := NativeUInt(CP1);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP1) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup := SBCS.FUCS2.Lower;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

        // Comp.Lookup_2 := SBCS(CP2).LowerUCS2
        Index := NativeUInt(CP2);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP2) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Lower;
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

        if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
        Result := __textconv_sbcs_compare_sbcs_2(Pointer(S1), Pointer(S2), Comp);
      end;
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

function sbcs_compare_samesbcs_ignorecase(S1: PAnsiChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): NativeInt;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) and (S1 <> S2) then
  begin
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      // Comp.Lookup := SBCS(CodePage).Lower
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup := SBCS.FLowerCase;
      if (Comp.Lookup = nil) then Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);

      Result := __textconv_sbcs_compare_sbcs_1(Pointer(S1), Pointer(S2), Comp);
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

function sbcs_compare_sbcs_ignorecase(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP1: Word = 0; const CP2: Word = 0{$endif}): NativeInt;
label
  same_cp;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and ((P1 <> P2){$ifNdef INTERNALCODEPAGE}or (CP1 <> CP2){$endif}) then
  begin
    L2 := PByte(P1)^;
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := PByte(P2)^;
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        Comp.Length := L1;
        Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        Comp.Length := L2;
        Comp.Length_2 := NativeUInt(-1);
      end;

      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      if ({$ifdef INTERNALCODEPAGE}CodePage = PWord(P2)^{$else}CP1 = CP2{$endif}) then
      begin
        Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
        // Comp.Lookup := SBCS(CP1).Lower
        Index := NativeUInt({$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif});
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = {$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif}) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      same_cp:
        Comp.Lookup := SBCS.FLowerCase;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);

        Result := __textconv_sbcs_compare_sbcs_1(Pointer(P1), Pointer(P2), Comp);
      end else
      begin
        // Comp.Lookup := SBCS(CP1).LowerUCS2
        Index := NativeUInt({$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif});
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = {$ifdef INTERNALCODEPAGE}CodePage{$else}CP1{$endif}) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup := SBCS.FUCS2.Lower;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

        {$ifdef INTERNALCODEPAGE}CodePage := PWord(P2)^;{$endif}
        Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});

        // Comp.Lookup_2 := SBCS(CP2).LowerUCS2
        Index := NativeUInt({$ifdef INTERNALCODEPAGE}CodePage{$else}CP2{$endif});
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = {$ifdef INTERNALCODEPAGE}CodePage{$else}CP2{$endif}) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Lower;
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

        if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
        Result := __textconv_sbcs_compare_sbcs_2(Pointer(P1), Pointer(P2), Comp);
      end;
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{inline} function sbcs_compare_samesbcs_ignorecase(const S1: AnsiString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    L2 := PByte(P1)^;
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := PByte(P2)^;
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        Comp.Length := L1;
        Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        Comp.Length := L2;
        Comp.Length_2 := NativeUInt(-1);
      end;

      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      Inc(P2, ASTR_OFFSET_LENGTH);
      // Comp.Lookup := SBCS(CodePage).Lower
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup := SBCS.FLowerCase;
      if (Comp.Lookup = nil) then
      begin
        Comp.Lookup_2 := P2;
        Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);
        P2 := Comp.Lookup_2;
      end;

      Result := __textconv_sbcs_compare_sbcs_1(Pointer(P1), Pointer(P2), Comp);
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

function sbcs_compare_sbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CP1: Word = 0; const CP2: Word = 0): NativeInt;
label
  same_cp;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) and ((@S1 <> @S2) or (CP1 <> CP2)) then
  begin
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    L2 := Byte(S1[1]);
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := Byte(S2[1]);
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      if (CP1 = CP2) then
      begin
        // Comp.Lookup := SBCS(CP1).Lower
        Index := NativeUInt(CP1);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP1) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      same_cp:
        Comp.Lookup := SBCS.FLowerCase;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);

        Result := __textconv_sbcs_compare_sbcs_1(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      end else
      begin
        // Comp.Lookup := SBCS(CP1).LowerUCS2
        Index := NativeUInt(CP1);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP1) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup := SBCS.FUCS2.Lower;
        if (Comp.Lookup = nil) then Comp.Lookup := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

        // Comp.Lookup_2 := SBCS(CP2).LowerUCS2
        Index := NativeUInt(CP2);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CP2) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Lower;
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

        if (Comp.Lookup = Comp.Lookup_2) then goto same_cp;
        Result := __textconv_sbcs_compare_sbcs_2(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      end;
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function sbcs_compare_samesbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): NativeInt;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) and (@S1 <> @S2) then
  begin
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    L2 := Byte(S1[1]);
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := Byte(S2[1]);
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      // Comp.Lookup := SBCS(CodePage).Lower
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup := SBCS.FLowerCase;
      if (Comp.Lookup = nil) then Comp.Lookup := SBCS.FromSBCS(SBCS, ccLower);

      Result := __textconv_sbcs_compare_sbcs_1(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

function sbcs_equal_utf8(S1: PAnsiChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt; CodePage: Word = 0): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;

    if (L2 < L1) then goto ret_false;
    L1 := L1 * 3;
    if (L2 > L1) then goto ret_false;

    C1 := PByte(S1)^;
    C2 := PByte(S2)^;
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Original;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

    Comp.Lookup := nil;
    Ret := __textconv_utf8_compare_sbcs(Pointer(S2), Pointer(S1), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := (L1 = L2);
end;

{inline} function sbcs_equal_utf8(const S1: AnsiString; const S2: UTF8String{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L1 := PByte(P1)^;
    L2 := PByte(P2)^;
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    L1 := PCardinal(P1)^;
    L2 := PCardinal(P2)^;
    Comp.Length := L2;
    Comp.Length_2 := L1;

    if (L2 < L1) then goto ret_false;
    L1 := L1 * 3;
    if (L2 > L1) then goto ret_false;

    {$ifdef INTERNALCODEPAGE}
    Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    CodePage := PWord(P1)^;
    {$endif}
    Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
    Inc(P2, ASTR_OFFSET_LENGTH);
    // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Original;
    if (Comp.Lookup_2 = nil) then
    begin
      Comp.Lookup := P2;
      Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
      P2 := Comp.Lookup;
    end;

    Comp.Lookup := nil;
    Ret := __textconv_utf8_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;

{inline} function sbcs_equal_utf8(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): Boolean;
label
  ret_false;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;

    if (L2 < L1) then goto ret_false;
    L1 := L1 * 3;
    if (L2 > L1) then goto ret_false;

    L1 := Byte(S1[1]);
    L2 := Byte(S2[1]);
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Original;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

    Comp.Lookup := nil;
    Ret := __textconv_utf8_compare_sbcs(Pointer(@S2[1]), Pointer(@S1[1]), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (L1 = L2);
end;

function sbcs_equal_utf8_ignorecase(S1: PAnsiChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt; CodePage: Word = 0): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;

    if (L2 < L1) then goto ret_false;
    L1 := L1 * 3;
    if (L2 > L1) then goto ret_false;

    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Lower;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf8_compare_sbcs(Pointer(S2), Pointer(S1), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := (L1 = L2);
end;

{inline} function sbcs_equal_utf8_ignorecase(const S1: AnsiString; const S2: UTF8String{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L2 := PByte(P1)^;
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := PByte(P2)^;
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    L1 := PCardinal(P1)^;
    L2 := PCardinal(P2)^;
    Comp.Length := L2;
    Comp.Length_2 := L1;

    if (L2 < L1) then goto ret_false;
    L1 := L1 * 3;
    if (L2 > L1) then goto ret_false;

    {$ifdef INTERNALCODEPAGE}
    Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    CodePage := PWord(P1)^;
    {$endif}
    Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
    Inc(P2, ASTR_OFFSET_LENGTH);
    // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Lower;
    if (Comp.Lookup_2 = nil) then
    begin
      Comp.Lookup := P2;
      Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
      P2 := Comp.Lookup;
    end;

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf8_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;

{inline} function sbcs_equal_utf8_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): Boolean;
label
  ret_false;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;

    if (L2 < L1) then goto ret_false;
    L1 := L1 * 3;
    if (L2 > L1) then goto ret_false;

    L2 := Byte(S1[1]);
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := Byte(S2[1]);
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Lower;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf8_compare_sbcs(Pointer(@S2[1]), Pointer(@S1[1]), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (L1 = L2);
end;

function sbcs_compare_utf8(S1: PAnsiChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt; CodePage: Word = 0): NativeInt;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;
    C1 := PByte(S1)^;
    C2 := PByte(S2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

      Comp.Lookup := nil;
      Result := __textconv_utf8_compare_sbcs(Pointer(S2), Pointer(S1), Comp);
      Result := -Result;
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function sbcs_compare_utf8(const S1: AnsiString; const S2: UTF8String{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C1 := PByte(P1)^;
    C2 := PByte(P2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      Comp.Length := PCardinal(P2)^;
      Comp.Length_2 := PCardinal(P1)^;
      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      Inc(P2, ASTR_OFFSET_LENGTH);
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := nil;
      Result := __textconv_utf8_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
      Result := -Result;
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{inline} function sbcs_compare_utf8(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): NativeInt;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;
    L1 := Byte(S1[1]);
    L2 := Byte(S2[1]);
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

      Comp.Lookup := nil;
      Result := __textconv_utf8_compare_sbcs(Pointer(@S2[1]), Pointer(@S1[1]), Comp);
      Result := -Result;
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

function sbcs_compare_utf8_ignorecase(S1: PAnsiChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt; CodePage: Word = 0): NativeInt;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;
    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf8_compare_sbcs(Pointer(S2), Pointer(S1), Comp);
      Result := -Result;
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function sbcs_compare_utf8_ignorecase(const S1: AnsiString; const S2: UTF8String{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C2 := PByte(P1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(P2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      Comp.Length := PCardinal(P2)^;
      Comp.Length_2 := PCardinal(P1)^;
      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      Inc(P2, ASTR_OFFSET_LENGTH);
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf8_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
      Result := -Result;
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{inline} function sbcs_compare_utf8_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): NativeInt;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;
    L2 := Byte(S1[1]);
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := Byte(S2[1]);
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf8_compare_sbcs(Pointer(@S2[1]), Pointer(@S1[1]), Comp);
      Result := -Result;
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

function sbcs_equal_utf16(S1: PAnsiChar; S2: PWideChar; Length: NativeUInt; CodePage: Word = 0): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (Length <> 0) then
  begin
    Comp.Length := Length;
    C1 := PByte(S1)^;
    C2 := PWord(S2)^;
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Original;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

    Comp.Lookup := nil;
    Ret := __textconv_utf16_compare_sbcs(Pointer(S2), Pointer(S1), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function sbcs_equal_utf16(const S1: AnsiString; const S2: WideString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P2 <> nil) then
  begin
    if (P1 <> nil) then
    begin
      C1 := PByte(P1)^;
      C2 := PWord(P2)^;
      if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, WSTR_OFFSET_LENGTH);
      Length := PCardinal(P2)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
      if (Length <> PCardinal(P1)^) then goto ret_false;
      Comp.Length := Length;
      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      Inc(P2, WSTR_OFFSET_LENGTH);
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := nil;
      Ret := __textconv_utf16_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    {$ifdef MSWINDOWS}
      P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

ret_false:
  Result := (P1 = P2);
end;

{$ifdef UNICODE}
{inline} function sbcs_equal_utf16(const S1: AnsiString; const S2: UnicodeString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C1 := PByte(P1)^;
    C2 := PWord(P2)^;
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, USTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    Comp.Length := Length;
    {$ifdef INTERNALCODEPAGE}
    Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    CodePage := PWord(P1)^;
    {$endif}
    Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
    Inc(P2, USTR_OFFSET_LENGTH);
    // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Original;
    if (Comp.Lookup_2 = nil) then
    begin
      Comp.Lookup := P2;
      Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
      P2 := Comp.Lookup;
    end;

    Comp.Lookup := nil;
    Ret := __textconv_utf16_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;
{$endif}

function sbcs_equal_utf16_ignorecase(S1: PAnsiChar; S2: PWideChar; Length: NativeUInt; CodePage: Word = 0): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (Length <> 0) then
  begin
    Comp.Length := Length;
    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PWord(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Lower;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf16_compare_sbcs(Pointer(S2), Pointer(S1), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function sbcs_equal_utf16_ignorecase(const S1: AnsiString; const S2: WideString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P2 <> nil) then
  begin
    if (P1 <> nil) then
    begin
      C2 := PByte(P1)^;
      C1 := TEXTCONV_CHARCASE.VALUES[C2];
      C2 := PWord(P2)^;
      C2 := TEXTCONV_CHARCASE.VALUES[C2];
      if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, WSTR_OFFSET_LENGTH);
      Length := PCardinal(P2)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
      if (Length <> PCardinal(P1)^) then goto ret_false;
      Comp.Length := Length;
      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      Inc(P2, WSTR_OFFSET_LENGTH);
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Ret := __textconv_utf16_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    {$ifdef MSWINDOWS}
      P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

ret_false:
  Result := (P1 = P2);
end;

{$ifdef UNICODE}
{inline} function sbcs_equal_utf16_ignorecase(const S1: AnsiString; const S2: UnicodeString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C2 := PByte(P1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PWord(P2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, USTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    Comp.Length := Length;
    {$ifdef INTERNALCODEPAGE}
    Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    CodePage := PWord(P1)^;
    {$endif}
    Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
    Inc(P2, USTR_OFFSET_LENGTH);
    // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Lower;
    if (Comp.Lookup_2 = nil) then
    begin
      Comp.Lookup := P2;
      Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
      P2 := Comp.Lookup;
    end;

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf16_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;
{$endif}

function sbcs_compare_utf16(S1: PAnsiChar; L1: NativeUInt; S2: PWideChar; L2: NativeUInt; CodePage: Word = 0): NativeInt;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    C1 := PByte(S1)^;
    C2 := PWord(S2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

      Comp.Lookup := nil;
      Result := __textconv_utf16_compare_sbcs(Pointer(S2), Pointer(S1), Comp);
      Result := -Result;
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function sbcs_compare_utf16(const S1: AnsiString; const S2: WideString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P2 <> nil) then
  begin
    if (P1 <> nil) then
    begin
      L1 := PByte(P1)^;
      L2 := PWord(P2)^;
      if (L1 = L2) or (L1 or L2 > $7f) then
      begin
        Dec(P1, ASTR_OFFSET_LENGTH);
        Dec(P2, WSTR_OFFSET_LENGTH);
        L1 := PCardinal(P1)^;
        L2 := PCardinal(P2)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        if (L1 <= L2) then
        begin
          Comp.Length := L1;
          Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
        end else
        begin
          Comp.Length := L2;
          Comp.Length_2 := NativeUInt(-1);
        end;

        {$ifdef INTERNALCODEPAGE}
        Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
        CodePage := PWord(P1)^;
        {$endif}
        Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
        Inc(P2, WSTR_OFFSET_LENGTH);
        // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
        Index := NativeUInt(CodePage);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CodePage) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Original;
        if (Comp.Lookup_2 = nil) then
        begin
          Comp.Lookup := P2;
          Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
          P2 := Comp.Lookup;
        end;

        Comp.Lookup := nil;
        Result := __textconv_utf16_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
        Result := -Result;
        Inc(Result, Result);
        Dec(Result, Comp.Length_2);
        Exit;
      end else
      begin
        Result := NativeInt(L1) - NativeInt(L2);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{$ifdef UNICODE}
{inline} function sbcs_compare_utf16(const S1: AnsiString; const S2: UnicodeString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L1 := PByte(P1)^;
    L2 := PWord(P2)^;
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, USTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        Comp.Length := L1;
        Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        Comp.Length := L2;
        Comp.Length_2 := NativeUInt(-1);
      end;

      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      Inc(P2, USTR_OFFSET_LENGTH);
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := nil;
      Result := __textconv_utf16_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
      Result := -Result;
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;
{$endif}

function sbcs_compare_utf16_ignorecase(S1: PAnsiChar; L1: NativeUInt; S2: PWideChar; L2: NativeUInt; CodePage: Word = 0): NativeInt;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PWord(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf16_compare_sbcs(Pointer(S2), Pointer(S1), Comp);
      Result := -Result;
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function sbcs_compare_utf16_ignorecase(const S1: AnsiString; const S2: WideString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P2 <> nil) then
  begin
    if (P1 <> nil) then
    begin
      L2 := PByte(P1)^;
      L1 := TEXTCONV_CHARCASE.VALUES[L2];
      L2 := PWord(P2)^;
      L2 := TEXTCONV_CHARCASE.VALUES[L2];
      if (L1 = L2) or (L1 or L2 > $7f) then
      begin
        Dec(P1, ASTR_OFFSET_LENGTH);
        Dec(P2, WSTR_OFFSET_LENGTH);
        L1 := PCardinal(P1)^;
        L2 := PCardinal(P2)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        if (L1 <= L2) then
        begin
          Comp.Length := L1;
          Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
        end else
        begin
          Comp.Length := L2;
          Comp.Length_2 := NativeUInt(-1);
        end;

        {$ifdef INTERNALCODEPAGE}
        Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
        CodePage := PWord(P1)^;
        {$endif}
        Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
        Inc(P2, WSTR_OFFSET_LENGTH);
        // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
        Index := NativeUInt(CodePage);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CodePage) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Lower;
        if (Comp.Lookup_2 = nil) then
        begin
          Comp.Lookup := P2;
          Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
          P2 := Comp.Lookup;
        end;

        Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
        Result := __textconv_utf16_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
        Result := -Result;
        Inc(Result, Result);
        Dec(Result, Comp.Length_2);
        Exit;
      end else
      begin
        Result := NativeInt(L1) - NativeInt(L2);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{$ifdef UNICODE}
{inline} function sbcs_compare_utf16_ignorecase(const S1: AnsiString; const S2: UnicodeString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L2 := PByte(P1)^;
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := PWord(P2)^;
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, USTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        Comp.Length := L1;
        Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        Comp.Length := L2;
        Comp.Length_2 := NativeUInt(-1);
      end;

      {$ifdef INTERNALCODEPAGE}
      Dec(P1, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P1)^;
      {$endif}
      Inc(P1, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      Inc(P2, USTR_OFFSET_LENGTH);
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf16_compare_sbcs(Pointer(P2), Pointer(P1), Comp);
      Result := -Result;
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;
{$endif}

function utf8_equal_sbcs(S1: PUTF8Char; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 < L2) then goto ret_false;
    L2 := L2 * 3;
    if (L1 > L2) then goto ret_false;

    C1 := PByte(S1)^;
    C2 := PByte(S2)^;
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Original;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

    Comp.Lookup := nil;
    Ret := __textconv_utf8_compare_sbcs(Pointer(S1), Pointer(S2), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := (L1 = L2);
end;

{inline} function utf8_equal_sbcs(const S1: UTF8String; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L1 := PByte(P1)^;
    L2 := PByte(P2)^;
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    L1 := PCardinal(P1)^;
    L2 := PCardinal(P2)^;
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 < L2) then goto ret_false;
    L2 := L2 * 3;
    if (L1 > L2) then goto ret_false;

    {$ifdef INTERNALCODEPAGE}
    Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    CodePage := PWord(P2)^;
    {$endif}
    Inc(P1, ASTR_OFFSET_LENGTH);
    Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
    // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Original;
    if (Comp.Lookup_2 = nil) then
    begin
      Comp.Lookup := P2;
      Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
      P2 := Comp.Lookup;
    end;

    Comp.Lookup := nil;
    Ret := __textconv_utf8_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;

{inline} function utf8_equal_sbcs(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): Boolean;
label
  ret_false;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 < L2) then goto ret_false;
    L2 := L2 * 3;
    if (L1 > L2) then goto ret_false;

    L1 := Byte(S1[1]);
    L2 := Byte(S2[1]);
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Original;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

    Comp.Lookup := nil;
    Ret := __textconv_utf8_compare_sbcs(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (L1 = L2);
end;

function utf8_equal_sbcs_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 < L2) then goto ret_false;
    L2 := L2 * 3;
    if (L1 > L2) then goto ret_false;

    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Lower;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf8_compare_sbcs(Pointer(S1), Pointer(S2), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := (L1 = L2);
end;

{inline} function utf8_equal_sbcs_ignorecase(const S1: UTF8String; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L2 := PByte(P1)^;
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := PByte(P2)^;
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    L1 := PCardinal(P1)^;
    L2 := PCardinal(P2)^;
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 < L2) then goto ret_false;
    L2 := L2 * 3;
    if (L1 > L2) then goto ret_false;

    {$ifdef INTERNALCODEPAGE}
    Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    CodePage := PWord(P2)^;
    {$endif}
    Inc(P1, ASTR_OFFSET_LENGTH);
    Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
    // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Lower;
    if (Comp.Lookup_2 = nil) then
    begin
      Comp.Lookup := P2;
      Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
      P2 := Comp.Lookup;
    end;

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf8_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;

{inline} function utf8_equal_sbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): Boolean;
label
  ret_false;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 < L2) then goto ret_false;
    L2 := L2 * 3;
    if (L1 > L2) then goto ret_false;

    L2 := Byte(S1[1]);
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := Byte(S2[1]);
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Lower;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf8_compare_sbcs(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (L1 = L2);
end;

function utf8_compare_sbcs(S1: PUTF8Char; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): NativeInt;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;
    C1 := PByte(S1)^;
    C2 := PByte(S2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

      Comp.Lookup := nil;
      Result := __textconv_utf8_compare_sbcs(Pointer(S1), Pointer(S2), Comp);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf8_compare_sbcs(const S1: UTF8String; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C1 := PByte(P1)^;
    C2 := PByte(P2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      Comp.Length := PCardinal(P1)^;
      Comp.Length_2 := PCardinal(P2)^;
      {$ifdef INTERNALCODEPAGE}
      Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P2)^;
      {$endif}
      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := nil;
      Result := __textconv_utf8_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{inline} function utf8_compare_sbcs(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): NativeInt;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;
    L1 := Byte(S1[1]);
    L2 := Byte(S2[1]);
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

      Comp.Lookup := nil;
      Result := __textconv_utf8_compare_sbcs(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

function utf8_compare_sbcs_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): NativeInt;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;
    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf8_compare_sbcs(Pointer(S1), Pointer(S2), Comp);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf8_compare_sbcs_ignorecase(const S1: UTF8String; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C2 := PByte(P1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(P2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      Comp.Length := PCardinal(P1)^;
      Comp.Length_2 := PCardinal(P2)^;
      {$ifdef INTERNALCODEPAGE}
      Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P2)^;
      {$endif}
      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf8_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{inline} function utf8_compare_sbcs_ignorecase(const S1: ShortString; const S2: ShortString; const CodePage: Word = 0): NativeInt;
var
  L1, L2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;
    L2 := Byte(S1[1]);
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := Byte(S2[1]);
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf8_compare_sbcs(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

function utf8_equal_utf8(S1: PUTF8Char; S2: PUTF8Char; Length: NativeUInt): Boolean;
label
  ret_false;
var
  Ret: NativeInt;
begin
  if (Length <> 0) and (S1 <> S2) then
  begin
    if (PByte(S1)^ <> PByte(S2)^) then goto ret_false;

    Ret := __textconv_compare_bytes(Pointer(S1), Pointer(S2), Length);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function utf8_equal_utf8(const S1: UTF8String; const S2: UTF8String): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    if (PByte(P1)^ <> PByte(P2)^) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    Inc(P1, ASTR_OFFSET_LENGTH);
    Inc(P2, ASTR_OFFSET_LENGTH);
    Ret := __textconv_compare_bytes(Pointer(P1), Pointer(P2), Length);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;

{inline} function utf8_equal_utf8(const S1: ShortString; const S2: ShortString): Boolean;
label
  ret_false;
var
  Length: Word;
  Ret: NativeInt;
begin
  Length := PWord(@S1)^;
  if (Length <> PWord(@S2)^) then
  begin
    Result := (Length and $ff = 0) and (PByte(@S2)^ = 0);
    Exit;
  end;

  if (Length and $ff <> 0) and (@S1 <> @S2) then
  begin
    Ret := __textconv_compare_bytes(Pointer(@S1[1]), Pointer(@S2[1]), Byte(Length));
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

function utf8_equal_utf8_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (L1 <> 0) and (L2 <> 0) and (S1 <> S2) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 >= L2) then
    begin
      L2 := L2 * 3;
      L2 := L2 shr 1;
      if (L1 > L2) then goto ret_false;
    end else
    begin
      L1 := L1 * 3;
      L1 := L1 shr 1;
      if (L2 > L1) then goto ret_false;
    end;

    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Ret := __textconv_utf8_compare_utf8(Pointer(S1), Pointer(S2), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := (L1 = L2);
end;

{inline} function utf8_equal_utf8_ignorecase(const S1: UTF8String; const S2: UTF8String): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    L2 := PByte(P1)^;
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := PByte(P2)^;
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    L1 := PCardinal(P1)^;
    L2 := PCardinal(P2)^;
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 >= L2) then
    begin
      L2 := L2 * 3;
      L2 := L2 shr 1;
      if (L1 > L2) then goto ret_false;
    end else
    begin
      L1 := L1 * 3;
      L1 := L1 shr 1;
      if (L2 > L1) then goto ret_false;
    end;

    Inc(P1, ASTR_OFFSET_LENGTH);
    Inc(P2, ASTR_OFFSET_LENGTH);
    Ret := __textconv_utf8_compare_utf8(Pointer(P1), Pointer(P2), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;

{inline} function utf8_equal_utf8_ignorecase(const S1: ShortString; const S2: ShortString): Boolean;
label
  ret_false;
var
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) and (@S1 <> @S2) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 >= L2) then
    begin
      L2 := L2 * 3;
      L2 := L2 shr 1;
      if (L1 > L2) then goto ret_false;
    end else
    begin
      L1 := L1 * 3;
      L1 := L1 shr 1;
      if (L2 > L1) then goto ret_false;
    end;

    L2 := Byte(S1[1]);
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := Byte(S2[1]);
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      Ret := __textconv_utf8_compare_utf8(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      Result := (Ret = 0);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      L2 := TEXTCONV_CHARCASE.VALUES[Byte(S2[1])];
      {$endif}
    end;
  end;

ret_false:
  Result := (L1 = L2);
end;

function utf8_compare_utf8(S1: PUTF8Char; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): NativeInt;
var
  C1, C2: NativeUInt;
begin
  if (L1 <> 0) and (L2 <> 0) and (S1 <> S2) then
  begin
    C1 := PByte(S1)^;
    C2 := PByte(S2)^;
    if (C1 = C2) then
    begin
      if (L1 <= L2) then
      begin
        L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        L1 := L2;
        L2 := NativeUInt(-1);
      end;

      L1 := __textconv_compare_bytes(Pointer(S1), Pointer(S2),  L1);
      Result := L1 * 2 - L2;
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf8_compare_utf8(const S1: UTF8String; const S2: UTF8String): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    L1 := PByte(P1)^;
    L2 := PByte(P2)^;
    if (L1 = L2) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        L1 := L2;
        L2 := NativeUInt(-1);
      end;

      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, ASTR_OFFSET_LENGTH);
      L1 := __textconv_compare_bytes(Pointer(P1), Pointer(P2),  L1);
      Result := L1 * 2 - L2;
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{inline} function utf8_compare_utf8(const S1: ShortString; const S2: ShortString): NativeInt;
var
  L1, L2: NativeUInt;
begin
  L1 := PWord(@S1)^;
  L2 := PWord(@S2)^;

  if (L1 and $ff <> 0) and (L2 and $ff <> 0) and (@S1 <> @S2) then
  begin
    L1 := L1 shr 8;
    L2 := L2 shr 8;
    if (L1 = L2) then
    begin
      L1 := PByte(@S1)^;
      L2 := PByte(@S2)^;
      if (L1 <= L2) then
      begin
        L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        L1 := L2;
        L2 := NativeUInt(-1);
      end;

      L1 := __textconv_compare_bytes(Pointer(@S1[1]), Pointer(@S2[1]),  L1);
      Result := L1 * 2 - L2;
      Exit;
    end;
  end;

  Result := NativeInt(Byte(L1)) - NativeInt(Byte(L2));
end;

function utf8_compare_utf8_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): NativeInt;
var
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) and (S1 <> S2) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;
    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Result := __textconv_utf8_compare_utf8(Pointer(S1), Pointer(S2), Comp);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      C2 := TEXTCONV_CHARCASE.VALUES[PByte(S2)^];
      {$endif}
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf8_compare_utf8_ignorecase(const S1: UTF8String; const S2: UTF8String): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    C2 := PByte(P1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(P2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      Comp.Length := PCardinal(P1)^;
      Comp.Length_2 := PCardinal(P2)^;
      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, ASTR_OFFSET_LENGTH);
      Result := __textconv_utf8_compare_utf8(Pointer(P1), Pointer(P2), Comp);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      C2 := TEXTCONV_CHARCASE.VALUES[PByte(P2)^];
      {$endif}
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{inline} function utf8_compare_utf8_ignorecase(const S1: ShortString; const S2: ShortString): NativeInt;
var
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  L1 := PByte(@S1)^;
  L2 := PByte(@S2)^;

  if (L1 <> 0) and (L2 <> 0) and (@S1 <> @S2) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;
    L2 := Byte(S1[1]);
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := Byte(S2[1]);
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      Result := __textconv_utf8_compare_utf8(Pointer(@S1[1]), Pointer(@S2[1]), Comp);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      L2 := TEXTCONV_CHARCASE.VALUES[Byte(S2[1])];
      {$endif}
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

function utf8_equal_utf16(S1: PUTF8Char; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 < L2) then goto ret_false;
    L2 := L2 * 3;
    if (L1 > L2) then goto ret_false;

    C1 := PByte(S1)^;
    C2 := PWord(S2)^;
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Comp.Lookup := nil;
    Ret := __textconv_utf8_compare_utf16(Pointer(S1), Pointer(S2), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := (L1 = L2);
end;

{inline} function utf8_equal_utf16(const S1: UTF8String; const S2: WideString): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P2 <> nil) then
  begin
    if (P1 <> nil) then
    begin
      L1 := PByte(P1)^;
      L2 := PWord(P2)^;
      if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, WSTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
      Comp.Length := L1;
      Comp.Length_2 := L2;

      if (L1 < L2) then goto ret_false;
      L2 := L2 * 3;
      if (L1 > L2) then goto ret_false;

      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, WSTR_OFFSET_LENGTH);
      Comp.Lookup := nil;
      Ret := __textconv_utf8_compare_utf16(Pointer(P1), Pointer(P2), Comp);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    {$ifdef MSWINDOWS}
      P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

ret_false:
  Result := (P1 = P2);
end;

{$ifdef UNICODE}
{inline} function utf8_equal_utf16(const S1: UTF8String; const S2: UnicodeString): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L1 := PByte(P1)^;
    L2 := PWord(P2)^;
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, USTR_OFFSET_LENGTH);
    L1 := PCardinal(P1)^;
    L2 := PCardinal(P2)^;
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 < L2) then goto ret_false;
    L2 := L2 * 3;
    if (L1 > L2) then goto ret_false;

    Inc(P1, ASTR_OFFSET_LENGTH);
    Inc(P2, USTR_OFFSET_LENGTH);
    Comp.Lookup := nil;
    Ret := __textconv_utf8_compare_utf16(Pointer(P1), Pointer(P2), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;
{$endif}

function utf8_equal_utf16_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 < L2) then goto ret_false;
    L2 := L2 * 3;
    if (L1 > L2) then goto ret_false;

    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PWord(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf8_compare_utf16(Pointer(S1), Pointer(S2), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := (L1 = L2);
end;

{inline} function utf8_equal_utf16_ignorecase(const S1: UTF8String; const S2: WideString): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P2 <> nil) then
  begin
    if (P1 <> nil) then
    begin
      L2 := PByte(P1)^;
      L1 := TEXTCONV_CHARCASE.VALUES[L2];
      L2 := PWord(P2)^;
      L2 := TEXTCONV_CHARCASE.VALUES[L2];
      if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, WSTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
      Comp.Length := L1;
      Comp.Length_2 := L2;

      if (L1 < L2) then goto ret_false;
      L2 := L2 * 3;
      if (L1 > L2) then goto ret_false;

      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, WSTR_OFFSET_LENGTH);
      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Ret := __textconv_utf8_compare_utf16(Pointer(P1), Pointer(P2), Comp);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    {$ifdef MSWINDOWS}
      P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

ret_false:
  Result := (P1 = P2);
end;

{$ifdef UNICODE}
{inline} function utf8_equal_utf16_ignorecase(const S1: UTF8String; const S2: UnicodeString): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L2 := PByte(P1)^;
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := PWord(P2)^;
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    Dec(P1, ASTR_OFFSET_LENGTH);
    Dec(P2, USTR_OFFSET_LENGTH);
    L1 := PCardinal(P1)^;
    L2 := PCardinal(P2)^;
    Comp.Length := L1;
    Comp.Length_2 := L2;

    if (L1 < L2) then goto ret_false;
    L2 := L2 * 3;
    if (L1 > L2) then goto ret_false;

    Inc(P1, ASTR_OFFSET_LENGTH);
    Inc(P2, USTR_OFFSET_LENGTH);
    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf8_compare_utf16(Pointer(P1), Pointer(P2), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;
{$endif}

function utf8_compare_utf16(S1: PUTF8Char; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): NativeInt;
var
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;
    C1 := PByte(S1)^;
    C2 := PWord(S2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Comp.Lookup := nil;
      Result := __textconv_utf8_compare_utf16(Pointer(S1), Pointer(S2), Comp);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      C2 := PWord(S2)^;
      {$endif}
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf8_compare_utf16(const S1: UTF8String; const S2: WideString): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P2 <> nil) then
  begin
    if (P1 <> nil) then
    begin
      C1 := PByte(P1)^;
      C2 := PWord(P2)^;
      if (C1 = C2) or (C1 or C2 > $7f) then
      begin
        Dec(P1, ASTR_OFFSET_LENGTH);
        Dec(P2, WSTR_OFFSET_LENGTH);
        Comp.Length := PCardinal(P1)^;
        Comp.Length_2 := PCardinal(P2)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        Inc(P1, ASTR_OFFSET_LENGTH);
        Inc(P2, WSTR_OFFSET_LENGTH);
        Comp.Lookup := nil;
        Result := __textconv_utf8_compare_utf16(Pointer(P1), Pointer(P2), Comp);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        C2 := PWord(P2)^;
        {$endif}
        Result := NativeInt(C1) - NativeInt(C2);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{$ifdef UNICODE}
{inline} function utf8_compare_utf16(const S1: UTF8String; const S2: UnicodeString): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C1 := PByte(P1)^;
    C2 := PWord(P2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, USTR_OFFSET_LENGTH);
      Comp.Length := PCardinal(P1)^;
      Comp.Length_2 := PCardinal(P2)^;
      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, USTR_OFFSET_LENGTH);
      Comp.Lookup := nil;
      Result := __textconv_utf8_compare_utf16(Pointer(P1), Pointer(P2), Comp);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      C2 := PWord(P2)^;
      {$endif}
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;
{$endif}

function utf8_compare_utf16_ignorecase(S1: PUTF8Char; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): NativeInt;
var
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L1;
    Comp.Length_2 := L2;
    C2 := PByte(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PWord(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf8_compare_utf16(Pointer(S1), Pointer(S2), Comp);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      C2 := TEXTCONV_CHARCASE.VALUES[PWord(S2)^];
      {$endif}
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf8_compare_utf16_ignorecase(const S1: UTF8String; const S2: WideString): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P2 <> nil) then
  begin
    if (P1 <> nil) then
    begin
      C2 := PByte(P1)^;
      C1 := TEXTCONV_CHARCASE.VALUES[C2];
      C2 := PWord(P2)^;
      C2 := TEXTCONV_CHARCASE.VALUES[C2];
      if (C1 = C2) or (C1 or C2 > $7f) then
      begin
        Dec(P1, ASTR_OFFSET_LENGTH);
        Dec(P2, WSTR_OFFSET_LENGTH);
        Comp.Length := PCardinal(P1)^;
        Comp.Length_2 := PCardinal(P2)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        Inc(P1, ASTR_OFFSET_LENGTH);
        Inc(P2, WSTR_OFFSET_LENGTH);
        Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
        Result := __textconv_utf8_compare_utf16(Pointer(P1), Pointer(P2), Comp);
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        C2 := TEXTCONV_CHARCASE.VALUES[PWord(P2)^];
        {$endif}
        Result := NativeInt(C1) - NativeInt(C2);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{$ifdef UNICODE}
{inline} function utf8_compare_utf16_ignorecase(const S1: UTF8String; const S2: UnicodeString): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C2 := PByte(P1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PWord(P2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Dec(P1, ASTR_OFFSET_LENGTH);
      Dec(P2, USTR_OFFSET_LENGTH);
      Comp.Length := PCardinal(P1)^;
      Comp.Length_2 := PCardinal(P2)^;
      Inc(P1, ASTR_OFFSET_LENGTH);
      Inc(P2, USTR_OFFSET_LENGTH);
      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf8_compare_utf16(Pointer(P1), Pointer(P2), Comp);
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      C2 := TEXTCONV_CHARCASE.VALUES[PWord(P2)^];
      {$endif}
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;
{$endif}

function utf16_equal_sbcs(S1: PWideChar; S2: PAnsiChar; Length: NativeUInt; CodePage: Word = 0): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (Length <> 0) then
  begin
    Comp.Length := Length;
    C1 := PWord(S1)^;
    C2 := PByte(S2)^;
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Original;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

    Comp.Lookup := nil;
    Ret := __textconv_utf16_compare_sbcs(Pointer(S1), Pointer(S2), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function utf16_equal_sbcs(const S1: WideString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) then
  begin
    if (P2 <> nil) then
    begin
      C1 := PWord(P1)^;
      C2 := PByte(P2)^;
      if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

      Dec(P1, WSTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      Length := PCardinal(P1)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
      if (Length <> PCardinal(P2)^) then goto ret_false;
      Comp.Length := Length;
      {$ifdef INTERNALCODEPAGE}
      Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P2)^;
      {$endif}
      Inc(P1, WSTR_OFFSET_LENGTH);
      Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := nil;
      Ret := __textconv_utf16_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    {$ifdef MSWINDOWS}
      P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

ret_false:
  Result := (P1 = P2);
end;

{$ifdef UNICODE}
{inline} function utf16_equal_sbcs(const S1: UnicodeString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C1 := PWord(P1)^;
    C2 := PByte(P2)^;
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Dec(P1, USTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    Comp.Length := Length;
    {$ifdef INTERNALCODEPAGE}
    Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    CodePage := PWord(P2)^;
    {$endif}
    Inc(P1, USTR_OFFSET_LENGTH);
    Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
    // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Original;
    if (Comp.Lookup_2 = nil) then
    begin
      Comp.Lookup := P2;
      Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
      P2 := Comp.Lookup;
    end;

    Comp.Lookup := nil;
    Ret := __textconv_utf16_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;
{$endif}

function utf16_equal_sbcs_ignorecase(S1: PWideChar; S2: PAnsiChar; Length: NativeUInt; CodePage: Word = 0): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (Length <> 0) then
  begin
    Comp.Length := Length;
    C2 := PWord(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Lower;
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf16_compare_sbcs(Pointer(S1), Pointer(S2), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function utf16_equal_sbcs_ignorecase(const S1: WideString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) then
  begin
    if (P2 <> nil) then
    begin
      C2 := PWord(P1)^;
      C1 := TEXTCONV_CHARCASE.VALUES[C2];
      C2 := PByte(P2)^;
      C2 := TEXTCONV_CHARCASE.VALUES[C2];
      if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

      Dec(P1, WSTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      Length := PCardinal(P1)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
      if (Length <> PCardinal(P2)^) then goto ret_false;
      Comp.Length := Length;
      {$ifdef INTERNALCODEPAGE}
      Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P2)^;
      {$endif}
      Inc(P1, WSTR_OFFSET_LENGTH);
      Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Ret := __textconv_utf16_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    {$ifdef MSWINDOWS}
      P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

ret_false:
  Result := (P1 = P2);
end;

{$ifdef UNICODE}
{inline} function utf16_equal_sbcs_ignorecase(const S1: UnicodeString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C2 := PWord(P1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(P2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Dec(P1, USTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    Comp.Length := Length;
    {$ifdef INTERNALCODEPAGE}
    Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
    CodePage := PWord(P2)^;
    {$endif}
    Inc(P1, USTR_OFFSET_LENGTH);
    Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
    // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
    Index := NativeUInt(CodePage);
    Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);
    SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
    Comp.Lookup_2 := SBCS.FUCS2.Lower;
    if (Comp.Lookup_2 = nil) then
    begin
      Comp.Lookup := P2;
      Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
      P2 := Comp.Lookup;
    end;

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf16_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;
{$endif}

function utf16_compare_sbcs(S1: PWideChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): NativeInt;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    C1 := PWord(S1)^;
    C2 := PByte(S2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);

      Comp.Lookup := nil;
      Result := __textconv_utf16_compare_sbcs(Pointer(S1), Pointer(S2), Comp);
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf16_compare_sbcs(const S1: WideString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) then
  begin
    if (P2 <> nil) then
    begin
      L1 := PWord(P1)^;
      L2 := PByte(P2)^;
      if (L1 = L2) or (L1 or L2 > $7f) then
      begin
        Dec(P1, WSTR_OFFSET_LENGTH);
        Dec(P2, ASTR_OFFSET_LENGTH);
        L1 := PCardinal(P1)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        L2 := PCardinal(P2)^;
        if (L1 <= L2) then
        begin
          Comp.Length := L1;
          Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
        end else
        begin
          Comp.Length := L2;
          Comp.Length_2 := NativeUInt(-1);
        end;

        {$ifdef INTERNALCODEPAGE}
        Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
        CodePage := PWord(P2)^;
        {$endif}
        Inc(P1, WSTR_OFFSET_LENGTH);
        Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
        // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
        Index := NativeUInt(CodePage);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CodePage) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Original;
        if (Comp.Lookup_2 = nil) then
        begin
          Comp.Lookup := P2;
          Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
          P2 := Comp.Lookup;
        end;

        Comp.Lookup := nil;
        Result := __textconv_utf16_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
        Inc(Result, Result);
        Dec(Result, Comp.Length_2);
        Exit;
      end else
      begin
        Result := NativeInt(L1) - NativeInt(L2);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{$ifdef UNICODE}
{inline} function utf16_compare_sbcs(const S1: UnicodeString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L1 := PWord(P1)^;
    L2 := PByte(P2)^;
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      Dec(P1, USTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        Comp.Length := L1;
        Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        Comp.Length := L2;
        Comp.Length_2 := NativeUInt(-1);
      end;

      {$ifdef INTERNALCODEPAGE}
      Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P2)^;
      {$endif}
      Inc(P1, USTR_OFFSET_LENGTH);
      Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      // Comp.Lookup_2 := SBCS(CodePage).OriginalUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Original;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Original, ccOriginal);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := nil;
      Result := __textconv_utf16_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;
{$endif}

function utf16_compare_sbcs_ignorecase(S1: PWideChar; L1: NativeUInt; S2: PAnsiChar; L2: NativeUInt; CodePage: Word = 0): NativeInt;
var
  C1, C2: NativeUInt;
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    if (L1 <= L2) then
    begin
      Comp.Length := L1;
      Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
    end else
    begin
      Comp.Length := L2;
      Comp.Length_2 := NativeUInt(-1);
    end;

    C2 := PWord(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf16_compare_sbcs(Pointer(S1), Pointer(S2), Comp);
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf16_compare_sbcs_ignorecase(const S1: WideString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) then
  begin
    if (P2 <> nil) then
    begin
      L2 := PWord(P1)^;
      L1 := TEXTCONV_CHARCASE.VALUES[L2];
      L2 := PByte(P2)^;
      L2 := TEXTCONV_CHARCASE.VALUES[L2];
      if (L1 = L2) or (L1 or L2 > $7f) then
      begin
        Dec(P1, WSTR_OFFSET_LENGTH);
        Dec(P2, ASTR_OFFSET_LENGTH);
        L1 := PCardinal(P1)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        L2 := PCardinal(P2)^;
        if (L1 <= L2) then
        begin
          Comp.Length := L1;
          Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
        end else
        begin
          Comp.Length := L2;
          Comp.Length_2 := NativeUInt(-1);
        end;

        {$ifdef INTERNALCODEPAGE}
        Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
        CodePage := PWord(P2)^;
        {$endif}
        Inc(P1, WSTR_OFFSET_LENGTH);
        Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
        // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
        Index := NativeUInt(CodePage);
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
        repeat
          if (Word(Value) = CodePage) or (Value < 0) then Break;
          Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
        until (False);
        SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
        Comp.Lookup_2 := SBCS.FUCS2.Lower;
        if (Comp.Lookup_2 = nil) then
        begin
          Comp.Lookup := P2;
          Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
          P2 := Comp.Lookup;
        end;

        Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
        Result := __textconv_utf16_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
        Inc(Result, Result);
        Dec(Result, Comp.Length_2);
        Exit;
      end else
      begin
        Result := NativeInt(L1) - NativeInt(L2);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{$ifdef UNICODE}
{inline} function utf16_compare_sbcs_ignorecase(const S1: UnicodeString; const S2: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  {$ifdef INTERNALCODEPAGE}CodePage: Word;{$endif}
  Index: NativeUInt;
  Value: Integer;
  SBCS: PTextConvSBCS;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L2 := PWord(P1)^;
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := PByte(P2)^;
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) or (L1 or L2 > $7f) then
    begin
      Dec(P1, USTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        Comp.Length := L1;
        Comp.Length_2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        Comp.Length := L2;
        Comp.Length_2 := NativeUInt(-1);
      end;

      {$ifdef INTERNALCODEPAGE}
      Dec(P2, (ASTR_OFFSET_CODEPAGE-ASTR_OFFSET_LENGTH));
      CodePage := PWord(P2)^;
      {$endif}
      Inc(P1, USTR_OFFSET_LENGTH);
      Inc(P2, {$ifdef INTERNALCODEPAGE}ASTR_OFFSET_CODEPAGE{$else}ASTR_OFFSET_LENGTH{$endif});
      // Comp.Lookup_2 := SBCS(CodePage).LowerUCS2
      Index := NativeUInt(CodePage);
      Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[Index and High(TEXTCONV_SUPPORTED_SBCS_HASH)]);
      repeat
        if (Word(Value) = CodePage) or (Value < 0) then Break;
        Value := Integer(TEXTCONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
      until (False);
      SBCS := Pointer(NativeUInt(Byte(Value shr 16)) * SizeOf(TTextConvSBCS) + NativeUInt(@TEXTCONV_SUPPORTED_SBCS));
      Comp.Lookup_2 := SBCS.FUCS2.Lower;
      if (Comp.Lookup_2 = nil) then
      begin
        Comp.Lookup := P2;
        Comp.Lookup_2 := SBCS.AllocFillUCS2(SBCS.FUCS2.Lower, ccLower);
        P2 := Comp.Lookup;
      end;

      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf16_compare_sbcs(Pointer(P1), Pointer(P2), Comp);
      Inc(Result, Result);
      Dec(Result, Comp.Length_2);
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;
{$endif}

function utf16_equal_utf8(S1: PWideChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;

    if (L2 < L1) then goto ret_false;
    L1 := L1 * 3;
    if (L2 > L1) then goto ret_false;

    C1 := PWord(S1)^;
    C2 := PByte(S2)^;
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Comp.Lookup := nil;
    Ret := __textconv_utf8_compare_utf16(Pointer(S2), Pointer(S1), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := (L1 = L2);
end;

{inline} function utf16_equal_utf8(const S1: WideString; const S2: UTF8String): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) then
  begin
    if (P2 <> nil) then
    begin
      L1 := PWord(P1)^;
      L2 := PByte(P2)^;
      if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

      Dec(P1, WSTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
      L2 := PCardinal(P2)^;
      Comp.Length := L2;
      Comp.Length_2 := L1;

      if (L2 < L1) then goto ret_false;
      L1 := L1 * 3;
      if (L2 > L1) then goto ret_false;

      Inc(P1, WSTR_OFFSET_LENGTH);
      Inc(P2, ASTR_OFFSET_LENGTH);
      Comp.Lookup := nil;
      Ret := __textconv_utf8_compare_utf16(Pointer(P2), Pointer(P1), Comp);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    {$ifdef MSWINDOWS}
      P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

ret_false:
  Result := (P1 = P2);
end;

{$ifdef UNICODE}
{inline} function utf16_equal_utf8(const S1: UnicodeString; const S2: UTF8String): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L1 := PWord(P1)^;
    L2 := PByte(P2)^;
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    Dec(P1, USTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    L1 := PCardinal(P1)^;
    L2 := PCardinal(P2)^;
    Comp.Length := L2;
    Comp.Length_2 := L1;

    if (L2 < L1) then goto ret_false;
    L1 := L1 * 3;
    if (L2 > L1) then goto ret_false;

    Inc(P1, USTR_OFFSET_LENGTH);
    Inc(P2, ASTR_OFFSET_LENGTH);
    Comp.Lookup := nil;
    Ret := __textconv_utf8_compare_utf16(Pointer(P2), Pointer(P1), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;
{$endif}

function utf16_equal_utf8_ignorecase(S1: PWideChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;

    if (L2 < L1) then goto ret_false;
    L1 := L1 * 3;
    if (L2 > L1) then goto ret_false;

    C2 := PWord(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) and (C1 or C2 <= $7f) then goto ret_false;

    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf8_compare_utf16(Pointer(S2), Pointer(S1), Comp);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := (L1 = L2);
end;

{inline} function utf16_equal_utf8_ignorecase(const S1: WideString; const S2: UTF8String): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) then
  begin
    if (P2 <> nil) then
    begin
      L2 := PWord(P1)^;
      L1 := TEXTCONV_CHARCASE.VALUES[L2];
      L2 := PByte(P2)^;
      L2 := TEXTCONV_CHARCASE.VALUES[L2];
      if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

      Dec(P1, WSTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
      L2 := PCardinal(P2)^;
      Comp.Length := L2;
      Comp.Length_2 := L1;

      if (L2 < L1) then goto ret_false;
      L1 := L1 * 3;
      if (L2 > L1) then goto ret_false;

      Inc(P1, WSTR_OFFSET_LENGTH);
      Inc(P2, ASTR_OFFSET_LENGTH);
      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Ret := __textconv_utf8_compare_utf16(Pointer(P2), Pointer(P1), Comp);
      Result := (Ret = 0);
      Exit;
    end else
    begin
    {$ifdef MSWINDOWS}
      P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

ret_false:
  Result := (P1 = P2);
end;

{$ifdef UNICODE}
{inline} function utf16_equal_utf8_ignorecase(const S1: UnicodeString; const S2: UTF8String): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
  Comp: TTextConvCompareOptions;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    L2 := PWord(P1)^;
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := PByte(P2)^;
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 <> L2) and (L1 or L2 <= $7f) then goto ret_false;

    Dec(P1, USTR_OFFSET_LENGTH);
    Dec(P2, ASTR_OFFSET_LENGTH);
    L1 := PCardinal(P1)^;
    L2 := PCardinal(P2)^;
    Comp.Length := L2;
    Comp.Length_2 := L1;

    if (L2 < L1) then goto ret_false;
    L1 := L1 * 3;
    if (L2 > L1) then goto ret_false;

    Inc(P1, USTR_OFFSET_LENGTH);
    Inc(P2, ASTR_OFFSET_LENGTH);
    Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
    Ret := __textconv_utf8_compare_utf16(Pointer(P2), Pointer(P1), Comp);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;
{$endif}

function utf16_compare_utf8(S1: PWideChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): NativeInt;
var
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;
    C1 := PWord(S1)^;
    C2 := PByte(S2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Comp.Lookup := nil;
      Result := __textconv_utf8_compare_utf16(Pointer(S2), Pointer(S1), Comp);
      Result := -Result;
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      C2 := PByte(S2)^;
      {$endif}
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf16_compare_utf8(const S1: WideString; const S2: UTF8String): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) then
  begin
    if (P2 <> nil) then
    begin
      C1 := PWord(P1)^;
      C2 := PByte(P2)^;
      if (C1 = C2) or (C1 or C2 > $7f) then
      begin
        Dec(P1, WSTR_OFFSET_LENGTH);
        Dec(P2, ASTR_OFFSET_LENGTH);
        Comp.Length := PCardinal(P2)^;
        Comp.Length_2 := PCardinal(P1)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        Inc(P1, WSTR_OFFSET_LENGTH);
        Inc(P2, ASTR_OFFSET_LENGTH);
        Comp.Lookup := nil;
        Result := __textconv_utf8_compare_utf16(Pointer(P2), Pointer(P1), Comp);
        Result := -Result;
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        C2 := PByte(P2)^;
        {$endif}
        Result := NativeInt(C1) - NativeInt(C2);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{$ifdef UNICODE}
{inline} function utf16_compare_utf8(const S1: UnicodeString; const S2: UTF8String): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C1 := PWord(P1)^;
    C2 := PByte(P2)^;
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Dec(P1, USTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      Comp.Length := PCardinal(P2)^;
      Comp.Length_2 := PCardinal(P1)^;
      Inc(P1, USTR_OFFSET_LENGTH);
      Inc(P2, ASTR_OFFSET_LENGTH);
      Comp.Lookup := nil;
      Result := __textconv_utf8_compare_utf16(Pointer(P2), Pointer(P1), Comp);
      Result := -Result;
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      C2 := PByte(P2)^;
      {$endif}
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;
{$endif}

function utf16_compare_utf8_ignorecase(S1: PWideChar; L1: NativeUInt; S2: PUTF8Char; L2: NativeUInt): NativeInt;
var
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  if (L1 <> 0) and (L2 <> 0) then
  begin
    Comp.Length := L2;
    Comp.Length_2 := L1;
    C2 := PWord(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf8_compare_utf16(Pointer(S2), Pointer(S1), Comp);
      Result := -Result;
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      C2 := TEXTCONV_CHARCASE.VALUES[PByte(S2)^];
      {$endif}
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf16_compare_utf8_ignorecase(const S1: WideString; const S2: UTF8String): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) then
  begin
    if (P2 <> nil) then
    begin
      C2 := PWord(P1)^;
      C1 := TEXTCONV_CHARCASE.VALUES[C2];
      C2 := PByte(P2)^;
      C2 := TEXTCONV_CHARCASE.VALUES[C2];
      if (C1 = C2) or (C1 or C2 > $7f) then
      begin
        Dec(P1, WSTR_OFFSET_LENGTH);
        Dec(P2, ASTR_OFFSET_LENGTH);
        Comp.Length := PCardinal(P2)^;
        Comp.Length_2 := PCardinal(P1)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        Inc(P1, WSTR_OFFSET_LENGTH);
        Inc(P2, ASTR_OFFSET_LENGTH);
        Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
        Result := __textconv_utf8_compare_utf16(Pointer(P2), Pointer(P1), Comp);
        Result := -Result;
        Exit;
      end else
      begin
        {$ifdef CPUX86}
        C2 := TEXTCONV_CHARCASE.VALUES[PByte(P2)^];
        {$endif}
        Result := NativeInt(C1) - NativeInt(C2);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{$ifdef UNICODE}
{inline} function utf16_compare_utf8_ignorecase(const S1: UnicodeString; const S2: UTF8String): NativeInt;
var
  P1, P2: PByte;
  C1, C2: NativeUInt;
  Comp: TTextConvCompareOptions;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) then
  begin
    C2 := PWord(P1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PByte(P2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) or (C1 or C2 > $7f) then
    begin
      Dec(P1, USTR_OFFSET_LENGTH);
      Dec(P2, ASTR_OFFSET_LENGTH);
      Comp.Length := PCardinal(P2)^;
      Comp.Length_2 := PCardinal(P1)^;
      Inc(P1, USTR_OFFSET_LENGTH);
      Inc(P2, ASTR_OFFSET_LENGTH);
      Comp.Lookup := Pointer(@TEXTCONV_CHARCASE.VALUES);
      Result := __textconv_utf8_compare_utf16(Pointer(P2), Pointer(P1), Comp);
      Result := -Result;
      Exit;
    end else
    begin
      {$ifdef CPUX86}
      C2 := TEXTCONV_CHARCASE.VALUES[PByte(P2)^];
      {$endif}
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;
{$endif}

function utf16_equal_utf16(S1: PWideChar; S2: PWideChar; Length: NativeUInt): Boolean;
label
  ret_false;
var
  Ret: NativeInt;
begin
  if (Length <> 0) and (S1 <> S2) then
  begin
    if (PWord(S1)^ <> PWord(S2)^) then goto ret_false;

    Ret := __textconv_compare_words(Pointer(S1), Pointer(S2), Length);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function utf16_equal_utf16(const S1: WideString; const S2: WideString): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> P2) then
  begin
    if (P1 <> nil) then
    begin
      if (P2 <> nil) then
      begin
        if (PWord(P1)^ <> PWord(P2)^) then goto ret_false;

        Dec(P1, WSTR_OFFSET_LENGTH);
        Dec(P2, WSTR_OFFSET_LENGTH);
        Length := PCardinal(P1)^;
        if (Length <> PCardinal(P2)^) then goto ret_false;
        {$ifdef WIDESTRLENSHIFT}Length := Length shr 1;{$endif}
        Inc(P1, WSTR_OFFSET_LENGTH);
        Inc(P2, WSTR_OFFSET_LENGTH);
        Ret := __textconv_compare_words(Pointer(P1), Pointer(P2), Length);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      {$ifdef MSWINDOWS}
        P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

ret_false:
  Result := (P1 = P2);
end;

{$ifdef UNICODE}
{inline} function utf16_equal_utf16(const S1: UnicodeString; const S2: UnicodeString): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    if (PWord(P1)^ <> PWord(P2)^) then goto ret_false;

    Dec(P1, USTR_OFFSET_LENGTH);
    Dec(P2, USTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    Inc(P1, USTR_OFFSET_LENGTH);
    Inc(P2, USTR_OFFSET_LENGTH);
    Ret := __textconv_compare_words(Pointer(P1), Pointer(P2), Length);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;
{$endif}

function utf16_equal_utf16_ignorecase(S1: PWideChar; S2: PWideChar; Length: NativeUInt): Boolean;
label
  ret_false;
var
  C1, C2: NativeUInt;
  Ret: NativeInt;
begin
  if (Length <> 0) and (S1 <> S2) then
  begin
    C2 := PWord(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PWord(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) then goto ret_false;

    Ret := __textconv_utf16_compare_utf16(Pointer(S1), Pointer(S2), Length);
    Result := (Ret = 0);
    Exit;
  ret_false:
    Result := False;
    Exit;
  end;

  Result := True;
end;

{inline} function utf16_equal_utf16_ignorecase(const S1: WideString; const S2: WideString): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> P2) then
  begin
    if (P1 <> nil) then
    begin
      if (P2 <> nil) then
      begin
        C2 := PWord(P1)^;
        C1 := TEXTCONV_CHARCASE.VALUES[C2];
        C2 := PWord(P2)^;
        C2 := TEXTCONV_CHARCASE.VALUES[C2];
        if (C1 <> C2) then goto ret_false;

        Dec(P1, WSTR_OFFSET_LENGTH);
        Dec(P2, WSTR_OFFSET_LENGTH);
        Length := PCardinal(P1)^;
        if (Length <> PCardinal(P2)^) then goto ret_false;
        {$ifdef WIDESTRLENSHIFT}Length := Length shr 1;{$endif}
        Inc(P1, WSTR_OFFSET_LENGTH);
        Inc(P2, WSTR_OFFSET_LENGTH);
        Ret := __textconv_utf16_compare_utf16(Pointer(P1), Pointer(P2), Length);
        Result := (Ret = 0);
        Exit;
      end else
      begin
      {$ifdef MSWINDOWS}
        P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
      {$endif}
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
    {$endif}
    end;
  end;

ret_false:
  Result := (P1 = P2);
end;

{$ifdef UNICODE}
{inline} function utf16_equal_utf16_ignorecase(const S1: UnicodeString; const S2: UnicodeString): Boolean;
label
  ret_false;
var
  P1, P2: PByte;
  Length: Cardinal;
  C1, C2: NativeUInt;
  Ret: NativeInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    C2 := PWord(P1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PWord(P2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 <> C2) then goto ret_false;

    Dec(P1, USTR_OFFSET_LENGTH);
    Dec(P2, USTR_OFFSET_LENGTH);
    Length := PCardinal(P1)^;
    if (Length <> PCardinal(P2)^) then goto ret_false;
    Inc(P1, USTR_OFFSET_LENGTH);
    Inc(P2, USTR_OFFSET_LENGTH);
    Ret := __textconv_utf16_compare_utf16(Pointer(P1), Pointer(P2), Length);
    Result := (Ret = 0);
    Exit;
  end;

ret_false:
  Result := (P1 = P2);
end;
{$endif}

function utf16_compare_utf16(S1: PWideChar; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): NativeInt;
var
  C1, C2: NativeUInt;
begin
  if (L1 <> 0) and (L2 <> 0) and (S1 <> S2) then
  begin
    C1 := PWord(S1)^;
    C2 := PWord(S2)^;
    if (C1 = C2) then
    begin
      if (L1 <= L2) then
      begin
        L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        L1 := L2;
        L2 := NativeUInt(-1);
      end;

      L1 := __textconv_compare_words(Pointer(S1), Pointer(S2),  L1);
      Result := L1 * 2 - L2;
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf16_compare_utf16(const S1: WideString; const S2: WideString): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> P2) then
  begin
    if (P1 <> nil) and (P2 <> nil) then
    begin
      L1 := PWord(P1)^;
      L2 := PWord(P2)^;
      if (L1 = L2) then
      begin
        Dec(P1, WSTR_OFFSET_LENGTH);
        Dec(P2, WSTR_OFFSET_LENGTH);
        L1 := PCardinal(P1)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        L2 := PCardinal(P2)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        if (L1 <= L2) then
        begin
          L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
        end else
        begin
          L1 := L2;
          L2 := NativeUInt(-1);
        end;

        Inc(P1, WSTR_OFFSET_LENGTH);
        Inc(P2, WSTR_OFFSET_LENGTH);
        L1 := __textconv_compare_words(Pointer(P1), Pointer(P2),  L1);
        Result := L1 * 2 - L2;
        Exit;
      end else
      begin
        Result := NativeInt(L1) - NativeInt(L2);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      if (P2 = nil) then
      begin
        P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
      end else
      begin
        P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
      end;
    {$endif}
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{$ifdef UNICODE}
{inline} function utf16_compare_utf16(const S1: UnicodeString; const S2: UnicodeString): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    L1 := PWord(P1)^;
    L2 := PWord(P2)^;
    if (L1 = L2) then
    begin
      Dec(P1, USTR_OFFSET_LENGTH);
      Dec(P2, USTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        L1 := L2;
        L2 := NativeUInt(-1);
      end;

      Inc(P1, USTR_OFFSET_LENGTH);
      Inc(P2, USTR_OFFSET_LENGTH);
      L1 := __textconv_compare_words(Pointer(P1), Pointer(P2),  L1);
      Result := L1 * 2 - L2;
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;
{$endif}

function utf16_compare_utf16_ignorecase(S1: PWideChar; L1: NativeUInt; S2: PWideChar; L2: NativeUInt): NativeInt;
var
  C1, C2: NativeUInt;
begin
  if (L1 <> 0) and (L2 <> 0) and (S1 <> S2) then
  begin
    C2 := PWord(S1)^;
    C1 := TEXTCONV_CHARCASE.VALUES[C2];
    C2 := PWord(S2)^;
    C2 := TEXTCONV_CHARCASE.VALUES[C2];
    if (C1 = C2) then
    begin
      if (L1 <= L2) then
      begin
        L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        L1 := L2;
        L2 := NativeUInt(-1);
      end;

      L1 := __textconv_utf16_compare_utf16(Pointer(S1), Pointer(S2),  L1);
      Result := L1 * 2 - L2;
      Exit;
    end else
    begin
      Result := NativeInt(C1) - NativeInt(C2);
      Exit;
    end;
  end;

  Result := NativeInt(L1) - NativeInt(L2);
end;

{inline} function utf16_compare_utf16_ignorecase(const S1: WideString; const S2: WideString): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> P2) then
  begin
    if (P1 <> nil) and (P2 <> nil) then
    begin
      L2 := PWord(P1)^;
      L1 := TEXTCONV_CHARCASE.VALUES[L2];
      L2 := PWord(P2)^;
      L2 := TEXTCONV_CHARCASE.VALUES[L2];
      if (L1 = L2) then
      begin
        Dec(P1, WSTR_OFFSET_LENGTH);
        Dec(P2, WSTR_OFFSET_LENGTH);
        L1 := PCardinal(P1)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        L2 := PCardinal(P2)^ {$ifdef WIDESTRLENSHIFT}shr 1{$endif};
        if (L1 <= L2) then
        begin
          L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
        end else
        begin
          L1 := L2;
          L2 := NativeUInt(-1);
        end;

        Inc(P1, WSTR_OFFSET_LENGTH);
        Inc(P2, WSTR_OFFSET_LENGTH);
        L1 := __textconv_utf16_compare_utf16(Pointer(P1), Pointer(P2),  L1);
        Result := L1 * 2 - L2;
        Exit;
      end else
      begin
        Result := NativeInt(L1) - NativeInt(L2);
        Exit;
      end;
    end else
    begin
    {$ifdef MSWINDOWS}
      if (P2 = nil) then
      begin
        P1 := Pointer(PCardinal(PAnsiChar(P1) - WSTR_OFFSET_LENGTH)^ <> 0);
      end else
      begin
        P2 := Pointer(PCardinal(PAnsiChar(P2) - WSTR_OFFSET_LENGTH)^ <> 0);
      end;
    {$endif}
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;

{$ifdef UNICODE}
{inline} function utf16_compare_utf16_ignorecase(const S1: UnicodeString; const S2: UnicodeString): NativeInt;
var
  P1, P2: PByte;
  L1, L2: NativeUInt;
begin
  P2 := Pointer(S2);
  P1 := Pointer(S1);
  if (P1 <> nil) and (P2 <> nil) and (P1 <> P2) then
  begin
    L2 := PWord(P1)^;
    L1 := TEXTCONV_CHARCASE.VALUES[L2];
    L2 := PWord(P2)^;
    L2 := TEXTCONV_CHARCASE.VALUES[L2];
    if (L1 = L2) then
    begin
      Dec(P1, USTR_OFFSET_LENGTH);
      Dec(P2, USTR_OFFSET_LENGTH);
      L1 := PCardinal(P1)^;
      L2 := PCardinal(P2)^;
      if (L1 <= L2) then
      begin
        L2 := (-NativeInt(L2 - L1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
      end else
      begin
        L1 := L2;
        L2 := NativeUInt(-1);
      end;

      Inc(P1, USTR_OFFSET_LENGTH);
      Inc(P2, USTR_OFFSET_LENGTH);
      L1 := __textconv_utf16_compare_utf16(Pointer(P1), Pointer(P2),  L1);
      Result := L1 * 2 - L2;
      Exit;
    end else
    begin
      Result := NativeInt(L1) - NativeInt(L2);
      Exit;
    end;
  end;

  Result := NativeInt(P1) - NativeInt(P2);
end;
{$endif}
{$ifdef undef}{$ENDREGION}{$endif}


initialization
  InternalLookupsInitialize;

finalization
  InternalLookupsFinalize;


end.
