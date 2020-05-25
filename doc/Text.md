### Concept

The library has rich capabilities for high-performance text processing. The low-level logic for converting text, comparing and representing strings as a pair of pointer and length is located in the _Tiny.Text.pas_ unit. The _Tiny.Cache.Text.pas_ unit contains the logic for parsing and writing text documents, including very large ones.

More details in the sections:
* [Low level conversion](#low-lovel-conversion)
* [High level conversion](#high-lovel-conversion)
* [Comparison](#comparison)
* [Tiny strings](#tiny-strings-bytestringutf16stringutf32string)
* [String buffer](#string-buffer)
* [CachedSerializer utility](#cachedserializer-utility)


### Low level conversion

The conversion context `TTextConvContext` is used to convert text from one encoding to another, changing the case of letters "on-the-fly" if necessary. For identification of encoding the number of code page is used. And as for some encodings the code page number is not provided in the library there are defined several "fake" code pages (e.g.  for encoding `UTF-1` and `UCS-2143`). The type `TTextConvContext` is `an object`, which means it does not require constructors and destructors. It is enough to declare as a usual variable and call necessary methods.

For initialization of `TTextConvContext` the `Init` (takes as a parameter code pages and case sensitivity) method is used. Alternative `Init` takes byte order mark (`TBOM`) what is convenient for reading and writing of text files. In addition initializing `TBOM` much less possible encodings are analyzed so that the size of the output binary file will be approximately 50 KB less. If the conversion takes place between the UTF-8, UTF-16 or a single-byte character set, you may initialize by such methods as the `InitUTF16FromSBCS` or `InitUTF8FromSBCS`.

To make the conversion, you need to assign the `Source`, `SourceSize`, `Destination`, `DestinationSize` fields and call the `Convert` function. After the conversion `SourceRead` and `DestinationWritten` fields will be filled. For convenience, there are two more species `Convert` functions, which assign the necessary fields automatically.

`TTextConvContext` allows sequential processing of large files, using small memory buffers. There may be occasions when converted characters do not fit in the `Destination` buffer or vice versa `Source` buffer is too small to read a character at the end of the buffer. In these cases, `TTextConvContext` will contain the latest stable state, and the `Convert` function will return integer value, by which it is possible to determine how the conversion process took place. Null means that the conversion was successful. Positive - `Destination` means that buffer is too small. Negative - `Source` means that buffer is too small to read a character at the end of the buffer. Some encodings (e.g. UTF-7, BOCU-1, iso-2022-jp) use "state", which is important for the conversion of text in parts. However, you may call `ResetState` if there is a need to start the conversion again. `ModeFinalize` property (default value is `True`) is important for the encodings that use "state", as in the case of the end of conversion into `Destination` a few bytes are being written. Do not forget to set `ModeFinalize` property to `False` value if it is assumed that the data of `Source` is not ended. In the case of `ModeFinalize = True` and successful conversion - `ResetState` is called automatically.

The library supports 50 encodings:
* 12 Unicode encodings: UTF-8, UTF-16(LE) ~ UCS2, UTF-16BE, UTF-32(LE) = UCS4, UTF-32BE, UCS4 unusual octet order 2143, UCS4 unusual octet order 3412, UTF-1, UTF-7, UTF-EBCDIC, SCSU, BOCU-1
* 10 ANSI code pages (may be returned by Windows.GetACP): CP874, CP1250, CP1251, CP1252, CP1253, CP1254, CP1255, CP1256, CP1257, CP1258
* 4 another multy-byte encodings, that may be specified as default in POSIX systems: shift_jis, gb2312, ks_c_5601-1987, big5
* 23 single/multy-byte encodings, that also can be defined as "encoding" in XML/HTML: ibm866, iso-8859-2, iso-8859-3, iso-8859-4, iso-8859-5, iso-8859-6, iso-8859-7, iso-8859-8, iso-8859-10, iso-8859-13, iso-8859-14, iso-8859-15, iso-8859-16, koi8-r, koi8-u, macintosh, x-mac-cyrillic, x-user-defined, gb18030, hz-gb-2312, euc-jp, iso-2022-jp, euc-kr
* Raw data

![](../data/text/StringConversion.png)

### High level conversion

There are several classes for sequential text data reading or writing: `TByteTextReader`, `TUTF16TextReader`, `TUTF32TextReader`, `TByteTextWriter`, `TUTF16TextWriter` and `TUTF32TextWriter`. You may choose any class for parsing in dependence which encoding is more comfortable to use. In case the encoding of the source (for reading) or target (writing) text data is different, the conversion will be executed automatically, but it might significantly slow down the application execution. The most of text files are in the byte-encoding, so it is recommended to use the `TByteTextReader`/`TByteTextWriter` classes for parts of a code which are demanding for performance, because the automatic conversion of text will not be made and `ByteString` is the fastest string type.

The functionality of the `TCachedTextReader`-class has much in common with the functionality of the `TCachedReader`-class. In both classes an access can be carried out with properties `Current`, `Overflow`, `Margin` and the function `Flush`. There are also high-level functions: `ReadData`, `Skip`, `ReadChar`, `Export` and two kinds of `Readln`. It is strongly recommended to use `Readln` function for text data consisting of many lines. The functionality of the `TCachedTextWriter`-class has much in common with the functionality of the `TCachedWriter`-class. In both classes an access can be carried out with properties `Current`, `Overflow`, `Margin` and the function `Flush`. The function `WriteData` can be used to direct text data writing.

![](../data/text/FileConversion.png)

### Comparison

For the encodings of UTF-8, UTF-16 and SBCS(Ansi) `Tiny.Library` contains many functions that allow comparing strings among) themselves without preliminary conversion into a universal encoding. All comparison functions are divided into `equal` and `compare`, common and `ignorecase`. If you need to compare two strings for equality then use `equal` option function as it is faster than `compare`. If string comparison is necessary to make case insensitive - use `ignorecase`. The `Tiny.Library` allows comparison between SBCS(Ansi) strings in different encodings. However, if you are sure that the encoding of such strings are the same - it is recommended to use `samesbcs`-functions.

For `AnsiString` types with non-default code page (e.g. `AnsiString(1253)`), calling the comparing function, **use explicit conversion** in `AnsiString` (e.g. `utf8_compare_sbcs_ignorecase(MyUTF8String, AnsiString(MyGreekString));`).
```pascal
  // examples
  function utf16_equal_utf8(const S1: UnicodeString; const S2: UTF8String): Boolean;
  function utf16_equal_utf8_ignorecase(const S1: UnicodeString; const S2: UTF8String): Boolean;
  function utf8_compare_sbcs(const S1: UTF8String; const S2: AnsiString): NativeInt;
  function utf8_compare_sbcs_ignorecase(const S1: UTF8String; const S2: AnsiString): NativeInt;  
  function sbcs_equal_samesbcs(const S1: AnsiString; const S2: AnsiString): Boolean;
  function sbcs_compare_samesbcs_ignorecase(const S1: AnsiString; const S2: AnsiString): NativeInt; 
```

![](../data/text/StringComparison.png)

### Tiny strings: ByteString/UTF16String/UTF32String

TinyString - is a simple structure that contains a pointer to the characters, string length and a set of flags. The peculiarity of these strings lies in the fact that for keeping data they do not take memory in the heap, but they refer to text data (`CachedBuffer`), which significantly increases the performance

```pascal
type
  ByteString/UTF16String/UTF32String = record
  public
    property Chars: PChar read/write
    property Length: NativeUInt read/write
    property Ascii: Boolean read/write
    property References: Boolean read/write (*useful for &amp;-like character references*) 
    property Tag: Byte read/write
    property Empty: Boolean read/write
    
    procedure Assign(AChars: PChar; ALength: NativeUInt);
    procedure Assign(const S: string);
    procedure Delete(const From, Count: NativeUInt);
    
    function DetermineAscii: Boolean;
    function TrimLeft: Boolean;
    function TrimRight: Boolean;
    function Trim: Boolean;
    function SubString(const From, Count: NativeUInt): TinyString;
    function SubString(const Count: NativeUInt): TinyString;
    function Skip(const Count: NativeUInt): Boolean;
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal;
    
    function CharPos(const C: Char; const From: NativeUInt = 0): NativeInt;
    function CharPosIgnoreCase(const C: Char; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: TinyString; const From: NativeUInt = 0): NativeInt;
    function Pos(const AChars: PChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: string; const From: NativeUInt = 0): NativeInt;
    function PosIgnoreCase(const S: TinyString; const From: NativeUInt = 0): NativeInt;
    function PosIgnoreCase(const AChars: PChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt;
    function PosIgnoreCase(const S: string; const From: NativeUInt = 0): NativeInt;
  public
    function ToBoolean: Boolean;
    function ToBooleanDef(const Default: Boolean): Boolean;
    function TryToBoolean(out Value: Boolean): Boolean;
    function ToHex: Integer;
    function ToHexDef(const Default: Integer): Integer;
    function TryToHex(out Value: Integer): Boolean;
    function ToInteger: Integer;
    function ToIntegerDef(const Default: Integer): Integer;
    function TryToInteger(out Value: Integer): Boolean;
    function ToCardinal: Cardinal;
    function ToCardinalDef(const Default: Cardinal): Cardinal;
    function TryToCardinal(out Value: Cardinal): Boolean;
    function ToHex64: Int64;
    function ToHex64Def(const Default: Int64): Int64;
    function TryToHex64(out Value: Int64): Boolean;
    function ToInt64: Int64;
    function ToInt64Def(const Default: Int64): Int64;
    function TryToInt64(out Value: Int64): Boolean;
    function ToUInt64: UInt64;
    function ToUInt64Def(const Default: UInt64): UInt64;
    function TryToUInt64(out Value: UInt64): Boolean;
    function ToFloat: Extended;
    function ToFloatDef(const Default: Extended): Extended;
    function TryToFloat(out Value: Single): Boolean;
    function TryToFloat(out Value: Double): Boolean;
    function TryToFloat(out Value: TExtended80Rec): Boolean;
    function ToDate: TDateTime;
    function ToDateDef(const Default: TDateTime): TDateTime;
    function TryToDate(out Value: TDateTime): Boolean;
    function ToTime: TDateTime;
    function ToTimeDef(const Default: TDateTime): TDateTime;
    function TryToTime(out Value: TDateTime): Boolean;
    function ToDateTime: TDateTime;
    function ToDateTimeDef(const Default: TDateTime): TDateTime;
    function TryToDateTime(out Value: TDateTime): Boolean; 
  public
    procedure ToAnsiString/ToLowerAnsiString/ToUpperAnsiString(var S: AnsiString; const CodePage: Word = 0);
    procedure ToAnsiShortString/ToLowerAnsiShortString/ToUpperAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUTF8String/ToLowerUTF8String/ToUpperUTF8String(var S: UTF8String);
    procedure ToUTF8ShortString/ToLowerUTF8ShortString/ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString/ToLowerWideString/ToUpperWideString(var S: WideString);
    procedure ToUnicodeString/ToLowerUnicodeString/ToUpperUnicodeString(var S: UnicodeString);
    procedure ToString/ToLowerString/ToUpperString(var S: string); 

    function ToAnsiString/ToLowerAnsiString/ToUpperAnsiString: AnsiString;
    function ToUTF8String/ToLowerUTF8String/ToUpperUTF8String: UTF8String;
    function ToWideString/ToLowerWideString/ToUpperWideString: WideString;
    function ToUnicodeString/ToLowerUnicodeString/ToUpperUnicodeString: UnicodeString;
    function ToString/ToLowerString/ToUpperString: string;
    class operator Implicit(const a: TinyString): string;  
  public
    function Equal/EqualIgnoreCase(const S: TinyString/AnsiString/UTF8String/WideString/UnicodeString): Boolean; 
    function Compare/CompareIgnoreCase(const S: TinyString/AnsiString/UTF8String/WideString/UnicodeString): NativeInt; 
    function Equal/EqualIgnoreCase(const AChars: PAnsiChar/PUTF8Char; const ALength: NativeUInt; const CodePage: Word): Boolean;
    function Compare/CompareIgnoreCase(const AChars: PAnsiChar/PUTF8Char; const ALength: NativeUInt; const CodePage: Word): NativeInt;
    function Equal/EqualIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt; const CodePage: Word): Boolean;
    function Compare/CompareIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt; const CodePage: Word): NativeInt;

    class operator <Comparison>(const S: TinyString/AnsiString/UTF8String/WideString/UnicodeString): Boolean;  
  end;
```

![](../data/text/TypeConversion.png)

### String buffer

Memory manager operations and reference counting can take almost all the time during the parsing. All the system string types are served by intenal System.pas module functions and they produce several difficult operations for redistribution of allocated memory, which has a bad influence on performance during such prevalent operations as initialization, concatenation and finalization. Because of this the major emphasis in `Tiny.Library` is based on static-memory strings: ByteString, UTF16String and UTF32String. There are some goals though difficult to be solved without dynamic memory allocation, e.g. unpacking XML-string, which contains character references, or converting ByteString to UTF16String. Special for such tasks there is `TStringBuffer` type based on dynamic array of byte and memory reserve principle, which means that memory is meant to be never or rarely reallocated. `TStringBuffer` can keep only one of three data types at the same time: ByteString, UTF16String or UTF32String. `InitByteString`, `InitUTF16String` or `InitUTF32String` methods can be caused anytime. Data filling, converting and concatenation are executed due to `Append` methods. Data is added to the end of string or converted to necessary encoding previously.
One of the most important feature of `TStringBuffer` is an opportunity of system string types “emulation”. In this case special system header (which allows compiler Delphi using `TStringBuffer` as “constant system strings”) is added to character data. It might be useful if your algorithms or functions use system strings, e.g. `Writeln`, `ExtractFileName` or `StrToDate(FormatSettings)`. However be careful, because emulated string lifetime is restricted by `TStringBuffer` data lifetime. Emulated string use as a temporary string constant is highly recommended. For using real system strings choose `TinyString.ToString`-methods or `UniqueString` after string variable assignment.

```pascal
program Produce;
var
  Buffer: TStringBuffer;
  P: PUnicodeString;
  S: UnicodeString;
begin
  // initialization
  Buffer.InitUTF16String;

  // concatenation and automatic conversion
  Buffer.Append(UnicodeString('Delphi'));
  Buffer.Append(AnsiString(' is the way to build applications for'));
  Buffer.Append(UTF8String(' Windows 10, Mac,'), ccUpper);
  Buffer.Append(WideString(' Mobile Platforms and more.'), ccLower);

  // system string
  Writeln(Buffer.CastUTF16String.ToUnicodeString);

  // constant system string emulation
  P := Buffer.EmulateUnicodeString;
  Writeln(P^);

  // copying the constant system string
  S := P^;
  UniqueString(S);
  Writeln(S);

  // reinitialization
  Buffer.InitByteString(CODEPAGE_DEFAULT);
  Buffer.Append(UTF8String('Delphi is the best.'));
  Writeln(Buffer.EmulateAnsiString^);

  Readln;
end.
```
Output:
```
Delphi is the way to build applications for WINDOWS 10, MAC, mobile platforms and more.
Delphi is the way to build applications for WINDOWS 10, MAC, mobile platforms and more.
Delphi is the way to build applications for WINDOWS 10, MAC, mobile platforms and more.
Delphi is the best.
```

### CachedSerializer utility

`CachedSerializer` utility works for the one and only aim - to identificate string data with the maximum performance. You may build the project from the source in folder "utilities/CachedSerializer" or download [binary](https://github.com/d-mozulyov/Tiny.Library/raw/master/data/archives/CachedSerializer.zip) with examples. As the first argument of command line utility gets the path of a text file, which contains options and identifiers. It’s necessary to have the following options for serialization:
* `-<encoding>`. "-utf16", "-utf8", "-utf32" and the other code page encodings can act as an encoding option, e.g. "-1250". "-raw" means `CODEPAGE_RAWDATA`, "-user" means `CODEPAGE_USERDEFINED`, "-ansi" means `CODEPAGE_DEFAULT`. "-ansi" is a default encoding. If your `ByteString` identifier contains only ASCII-characters, then encoding is unnecessary, you may specify "-ansi" or don't do this at all.
* `-p"<variable_name>"` or `-p"<pointer_name>:<length_name>"` or `-p"<pointer_name>:<length_name>:<code_indent>"`. Serialization goes for 2 parameters: character pointer and character length. If your identifier is stored in `TinyString`, then use `<variable_name>`, so that serialization will be going for parameters `<Name>.Chars` and `<Name>.Length`. Default value is `"S"`. Default code indent is `0`. To serialize null-terminated strings, the `<variable_name>` parameter should be the number of bytes, to which the memory is aligned. `0` means the memory is aligned to the size of the character.
* `-i`. This option tells that serialization will be insensitive.
* `-f"<Name(-SType)>:<Prefix>"` or `-f"<Name(-SType)>:<Prefix>:<TypeName>"`. Option `-f` helps to generate function `<Name>` with string parameter `S`. If `-SType` not defined - `TinyString` will be used. Ordinal constant (`<PREFIX>IDENTIFIERN = N`) or enumerate values (`<TypeName> = <prefix>Identifier1, <prefix>Identifier2, …)` will be generated for each identifier.
* `-fn"<Name(-SType)>:<Prefix>"` or `-fn"<Name(-SType)>:<Prefix>:<TypeName>"`. Option `-fn` meaning is the same as `-f`, but only serialization code will be generated.
* `-s"FileName"`. This option allows you to save the generated code into a file.

Each of these options can be mentioned as a command line argument. Besides, the following options are permitted:
* `-nolog`. Don't display the generated code in the console.
* `-nocopy`. Don't copy the generated code to the clipboard.
* `-nowait`. Don't wait for press Enter after code generation.

Each text file line can be introduced in several formats:
* `<identifier>`
* `<identifier>::<implementation>`
* `<identifier>:<marker>:<implementation>`
* `<identifier>:<marker>`

Besides `<identifier>` there's an important code  `<implementation>`, which is called for `<identifier>` case. If options `-f`  or `-fn` are mentioned, then `<implementation>` will be made automatically. If there's a situation where the same `<implementation>` must be used for several `<identifier>` define `<marker>` - some string constant. For writing `<identifier>`, `<marker>` or `<implementation>` the following special symbols are permitted: `"\:"`, `"\\"`, `"\n"`, `"\r"`, `"\t"` (tab), `"\s"` (space).

File an example serialization ("examples/simple1.txt"):
```
-ansi -f"ValueToID-AnsiString:ID_" -p"S:Length(S)"
sheet
row
cell
data
value
style
```
Output:
```pascal
const
  ID_UNKNOWN = 0;
  ID_CELL = 1;
  ID_DATA = 2;
  ID_ROW = 3;
  ID_SHEET = 4;
  ID_STYLE = 5;
  ID_VALUE = 6;

function ValueToID(const S: AnsiString): Cardinal;
begin
  // default value
  Result := ID_UNKNOWN;

  // byte ascii
  with PMemoryItems(S)^ do
  case Length(S) of 
    3: if (Words[0] + Bytes[2] shl 16 = $776F72) then Result := ID_ROW; // "row"
    4: case (Cardinals[0]) of // "cell", "data"
         $6C6C6563: Result := ID_CELL; // "cell"
         $61746164: Result := ID_DATA; // "data"
       end;
    5: case (Cardinals[0]) of // "sheet", "style", "value"
         $65656873: if (Bytes[4] = $74) then Result := ID_SHEET; // "sheet"
         $6C797473: if (Bytes[4] = $65) then Result := ID_STYLE; // "style"
         $756C6176: if (Bytes[4] = $65) then Result := ID_VALUE; // "value"
       end;
  end;
end;
```
Change options line to `-f"ValueToEnum:tk:TTagKind"` ("examples/simple2.txt"):
```pascal
type
  TTagKind = (tkUnknown, tkCell, tkData, tkRow, tkSheet, tkStyle, tkValue);

function ValueToEnum(const S: ByteString): TTagKind;
begin
  // default value
  Result := tkUnknown;

  // byte ascii
  with PMemoryItems(S.Chars)^ do
  case S.Length of 
    3: if (Words[0] + Bytes[2] shl 16 = $776F72) then Result := tkRow; // "row"
    4: case (Cardinals[0]) of // "cell", "data"
         $6C6C6563: Result := tkCell; // "cell"
         $61746164: Result := tkData; // "data"
       end;
    5: case (Cardinals[0]) of // "sheet", "style", "value"
         $65656873: if (Bytes[4] = $74) then Result := tkSheet; // "sheet"
         $6C797473: if (Bytes[4] = $65) then Result := tkStyle; // "style"
         $756C6176: if (Bytes[4] = $65) then Result := tkValue; // "value"
       end;
  end;
end;
```