unit uSerialize;

{$I TINY.DEFINES.inc}

interface
  uses {$ifdef UNITSCOPENAMES}
         System.SysUtils,
       {$else}
         SysUtils,
       {$endif}
       Tiny.Types, Tiny.Text, Tiny.Cache.Buffers, Tiny.Cache.Text,
       uIdentifiers;

type
  TOptionParams = record
    Name: UnicodeString;
    Count: NativeUInt;
    O1, O2, O3: UnicodeString;
  end;

{ TSerializeOptions record }

  TSerializeOptions = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FCount: NativeUInt;
    FItems: TUnicodeStrings;
    FEncoding: Word;
    FIgnoreCase: Boolean;
    FFuncName: UnicodeString;
    FFuncSType: UnicodeString;
    FPrefix: UnicodeString;
    FEnumTypeName: UnicodeString;
    FUseFuncHeaders: Boolean;
    FCharsParam: UnicodeString;
    FLengthParam: UnicodeString;
    FCodeIndent: NativeUInt;
    FFileName: UnicodeString;

    procedure FillFuncParams(const AFuncNameSType, APrefix, AEnumTypeName: UnicodeString);
    procedure FillSerializeParams(const ACharsParam, ALengthParam: UnicodeString; const ACodeIndent: NativeUInt);
    function ParseParams(var Params: TOptionParams; const S: UnicodeString): Boolean;
    procedure ParseOptionsLine(const S: UTF16String);
    procedure SetEncoding(const Value: Word);
  public
    procedure Clear;
    function TinyStringType(const ANullTerminated: Boolean): UnicodeString;
    function ParseOption(const S: UnicodeString): Boolean;
    function Add(const S: UnicodeString): NativeUInt;
    procedure Delete(const AFrom: NativeUInt; const ACount: NativeUInt = 1);
    procedure AddFromFile(const OptionsFileName: string; const OptionsLine: Boolean);
    property Count: NativeUInt read FCount;
    property Items: TUnicodeStrings read FItems;

    property Encoding: Word read FEncoding write SetEncoding;
    property IgnoreCase: Boolean read FIgnoreCase write FIgnoreCase;
    property FuncName: UnicodeString read FFuncName write FFuncName;
    property FuncSType: UnicodeString read FFuncSType write FFuncSType;
    property Prefix: UnicodeString read FPrefix write FPrefix;
    property EnumTypeName: UnicodeString read FEnumTypeName write FEnumTypeName;
    property UseFuncHeaders: Boolean read FUseFuncHeaders write FUseFuncHeaders;
    property CharsParam: UnicodeString read FCharsParam write FCharsParam;
    property LengthParam: UnicodeString read FLengthParam write FLengthParam;
    property CodeIndent: NativeUInt read FCodeIndent write FCodeIndent;
    property FileName: UnicodeString read FFileName write FFileName;
  end;


{ TSerializer class }

const
  RIGHT_MARGIN_VALUE = 120;

type
  PCases = ^TCases;
  TCases = record
    Count: NativeUInt;
    Values: array[0..3] of Cardinal;
  end;

  PCasesInfo = ^TCasesInfo;
  TCasesInfo = record
    ByteCount: NativeUInt;
    OrMask: NativeUInt;
    CheckedCount: NativeUInt;
    CaseCount: NativeUInt;
    GroupCount: NativeUInt;
  end;

  PWholeCasesInfo = ^TWholeCasesInfo;
  TWholeCasesInfo = array[1..4] of TCasesInfo;

  TSerializer = class(TObject)
  private
    FLines: PUnicodeStrings;
    FLinesCount: NativeUInt;
    FOptions: ^TSerializeOptions;
    FStringKind: TTinyStringKind;
    FCharSize: NativeUInt;
    FNullTerminatedAlignment: NativeUInt;
    FIsFunction: Boolean;
    FIsConsts: Boolean;
    FIsNullTerminated: Boolean;
    FFunctionValues: TUnicodeStrings;

    procedure InspecOptions;
    function FunctionValue(const Identifier: UnicodeString): UnicodeString;
  private
    FTextBuffer: UnicodeString;

    procedure AddLine; overload;
    procedure AddLine(const S: UnicodeString); overload;
    procedure AddLineFmt(const FmtStr: UnicodeString; const Args: array of const);
    procedure TextBufferClear;
    procedure TextBufferFlush;
    procedure TextBufferInclude(const Level: NativeUInt; const S: UnicodeString);
    procedure TextBufferIncludeFmt(const Level: NativeUInt; const FmtStr: UnicodeString; const Args: array of const);
    procedure TextBufferInit(const Level: NativeUInt; const S: UnicodeString);
    procedure TextBufferInitFmt(const Level: NativeUInt; const FmtStr: UnicodeString; const Args: array of const);
    procedure TextBufferIncludeLengthCondition(const Level, Offset, MinDataSize, MaxDataSize: NativeUInt; const ModeThen: Boolean = True);
    procedure TextBufferIncludeIfThenLine(const Level: NativeUInt; const Item: PIdentifier; Offset, ByteCount: NativeUInt; ModeIf: Boolean = True);
    procedure TextBufferIncludeComments(const Items: PIdentifierItems; const Count: NativeUInt);
  private
    FCaseGroups: array of TCases;

    function CheckCases(const Items: PIdentifierItems; const Count, Offset, ByteCount, OrMask: Cardinal; const KnownLength: Boolean; var CheckedCount, CaseCount: NativeUInt): NativeUInt; overload;
    function CheckCases(const Items: PIdentifierItems; const Count, Offset: NativeUInt; const KnownLength: Boolean): TWholeCasesInfo; overload;
    function CalculateBestCases(const Items: PIdentifierItems; const Count, Offset: NativeUInt; const KnownLength: Boolean): TCasesInfo;
    function InspectIdentifiers(const Items: PIdentifierItems; const Count, Offset: NativeUInt; const KnownLength: Boolean; var MinDataSize, MaxDataSize, SameDataSize: NativeUInt): Boolean;
    procedure WriteCaseIdentifiers(const Items: PIdentifierItems; const Count, Offset, Level: NativeUInt; const BestCases: TCasesInfo; const KnownLength: Boolean; const UnknownLenghtRangeMin, UnknownLenghtRangeMax: NativeUInt);
    procedure WriteLengthIdentifiers(const Items: PIdentifierItems; const Count, Offset, Level: NativeUInt);
    procedure WriteSplittedIdentifiers(const Items: PIdentifierItems; const Count, Offset, LargeCodeLevel, Level: NativeUInt; KnownLength: Boolean; UnknownLenghtRangeMin, UnknownLenghtRangeMax: NativeUInt);
    procedure WriteIdentifiers(const Items: PIdentifierItems; const Count, Offset, LargeCodeLevel, Level: NativeUInt; KnownLength: Boolean; UnknownLenghtRangeMin, UnknownLenghtRangeMax: NativeUInt);
  public
    function Process(const Options: TSerializeOptions): TUnicodeStrings;
  end;


implementation

const
  AND_VALUES: array[1..4] of Cardinal = ($ff, $ffff, $ffffff, $ffffffff);
  INDENT_STEP = 2;
  NONE_IF: array[Boolean] of string = ('', 'if ');
  AND_THEN: array[Boolean] of string = ('and', 'then');
  MEMORYDATA_POSTFIXES: array[0..3] of string = ('', '1', '2', '3');

type
  T4Bytes = array[0..3] of Byte;
  P4Bytes = ^T4Bytes;
  TUseDataProc = function(const Item: PIdentifier; const Offset, NullTerminatedAlignment: NativeUInt): UnicodeString;

function UnicodeFormat(const FmtStr: UnicodeString; const Args: array of const): UnicodeString;
begin
  Result := {$ifdef UNICODE}Format{$else}WideFormat{$endif}(FmtStr, Args);
end;

function InternalException: Exception;
begin
  Result := Exception.Create('Internal exception.'#13+
    'Please, send your file to developers at softforyou@inbox.ru');
end;

function UseByte(const Item: PIdentifier; const Offset, NullTerminatedAlignment: NativeUInt): UnicodeString;
begin
  Result := UnicodeFormat('Bytes[%d]', [Offset]);
end;

function UseWord(const Item: PIdentifier; const Offset, NullTerminatedAlignment: NativeUInt): UnicodeString;
begin
  Result := UnicodeFormat('Words%s[%d]', [MEMORYDATA_POSTFIXES[Offset and 1], Offset shr 1]);
end;

function UseCardinal(const Item: PIdentifier; const Offset, NullTerminatedAlignment: NativeUInt): UnicodeString;
begin
  Result := UnicodeFormat('Cardinals%s[%d]', [MEMORYDATA_POSTFIXES[Offset and 3], Offset shr 2]);
end;

function UseThree(const Item: PIdentifier; const Offset, NullTerminatedAlignment: NativeUInt): UnicodeString;
begin
  if (Offset = 0) then
  begin
    if (Item.DataSize >= 4) and
      ((NullTerminatedAlignment = 0) or (NullTerminatedAlignment >= 4)) then
    begin
      Result := UseCardinal(Item, 0, NullTerminatedAlignment) + ' and $ffffff';
    end else
    begin
      Result := UseWord(Item, Offset, NullTerminatedAlignment) + ' + ' + UseByte(Item, Offset + SizeOf(Word), NullTerminatedAlignment) + ' shl 16';
    end;
  end else
  begin
    Result := UseCardinal(Item, Offset - 1, NullTerminatedAlignment) + ' shr 8';
  end;
end;

var
  USE_DATA_PROCS: array[1..4] of TUseDataProc = (
    UseByte,
    UseWord,
    UseThree,
    UseCardinal
  );

function HexConst(const Value, ByteCount: NativeUInt): UnicodeString;
var
  i: NativeUInt;
begin
  Result := UnicodeFormat('$%*x', [Integer(ByteCount) * 2, Value]);
  for i := 1 to Length(Result) do
  if (Result[i] = #32) then Result[i] := '0';
end;

function UseDataMasked(Item: PIdentifier; Offset, NullTerminatedAlignment, OrMask, ByteCount: NativeUInt): UnicodeString;
begin
  Result := USE_DATA_PROCS[ByteCount](Item, Offset, NullTerminatedAlignment);
  OrMask := OrMask and AND_VALUES[ByteCount];
  if (OrMask <> 0) then Result := Result + ' or ' + HexConst(OrMask, ByteCount);
end;


{ TSerializeOptions }

function TSerializeOptions.Add(const S: UnicodeString): NativeUInt;
begin
  Result := FCount;
  Inc(FCount);
  SetLength(FItems, FCount);
  FItems[Result] := S;
end;

procedure TSerializeOptions.Delete(const AFrom, ACount: NativeUInt);
var
  L, i: NativeUInt;
begin
  L := FCount;
  if (AFrom < L) and (ACount <> 0) then
  begin
    Dec(L, AFrom);
    if (L <= ACount) then
    begin
      L := AFrom;
    end else
    begin
      Inc(L, AFrom);
      Dec(L, ACount);

      for i := 0 to (L - AFrom - 1) do
        FItems[AFrom + i] := FItems[AFrom + ACount + i];
    end;

    FCount := L;
    SetLength(FItems, L);
  end;
end;

procedure TSerializeOptions.SetEncoding(const Value: Word);
begin
  if (Value <> CODEPAGE_UTF8) and (Value <> CODEPAGE_UTF16) and
    (Value <> CODEPAGE_UTF32) then
  begin
    if (not TextConvIsSBCS(Value)) then
      raise Exception.CreateFmt('Unsupported encoding "%d"', [Value]);
  end;

  FEncoding := Value;
end;

procedure TSerializeOptions.Clear;
begin
  Finalize(Self);
  FillChar(Self, SizeOf(Self), #0);
end;

function TSerializeOptions.TinyStringType(const ANullTerminated: Boolean): UnicodeString;
begin
  if (ANullTerminated) then
  begin
    case FEncoding of
      CODEPAGE_UTF16: Result := 'PWideChar';
      CODEPAGE_UTF32: Result := 'PUCS4Char';
    else
      Result := 'PAnsiChar';
    end;
  end else
  begin
    case FEncoding of
      CODEPAGE_UTF16: Result := 'UTF16String';
      CODEPAGE_UTF32: Result := 'UTF32String';
    else
      Result := 'ByteString';
    end;
  end;
end;

procedure TSerializeOptions.FillFuncParams(const AFuncNameSType, APrefix,
  AEnumTypeName: UnicodeString);
var
  P: Integer;
begin
  P := Pos('-', AFuncNameSType);
  if (P = 0) then
  begin
    FFuncName := AFuncNameSType;
    FFuncSType := '';
    FCharsParam := 'S.Chars';
    FLengthParam := 'S.Length';
  end else
  begin
    FFuncName := Copy(AFuncNameSType, 1, P - 1);
    FFuncSType := AFuncNameSType;
    System.Delete(FFuncSType, 1, P);
  end;

  FPrefix := APrefix;
  FEnumTypeName := AEnumTypeName;
end;

procedure TSerializeOptions.FillSerializeParams(const ACharsParam,
  ALengthParam: UnicodeString; const ACodeIndent: NativeUInt);
begin
  FCharsParam := ACharsParam;
  FLengthParam := ALengthParam;
  FCodeIndent := ACodeIndent;
end;

function TSerializeOptions.ParseParams(var Params: TOptionParams;
  const S: UnicodeString): Boolean;
var
  P: NativeInt;
  Str: UTF16String;

  function ParseParam(var O: UnicodeString): Boolean;
  begin
    Result := True;

    P := Str.CharPos(':');
    if (P = 0) then
    begin
      Result := False;
      Exit;
    end;

    Inc(Params.Count);
    if (P < 0) then
    begin
      O := Str.ToUnicodeString;
      Str.Length := 0;
      Exit;
    end;

    O := Str.SubString(P).ToUnicodeString;
    Str.Skip(P + 1);
  end;
begin
  Result := False;
  Params.Count := 0;
  Str.Assign(S);

  P := Str.CharPos('"');
  if (P < 0) then
  begin
    Params.Name := Str.ToUnicodeString;
    Result := True;
    Exit;
  end else
  begin
    if (P = 0) then Exit;
    Params.Name := Str.SubString(0, P).ToUnicodeString;

    Str.Skip(P + 1);
    P := Str.CharPos('"');
    if (P < 0) or (NativeUInt(P) <> Str.Length - 1) then Exit;
    Str.Length := Str.Length - 1;

    if (not ParseParam(Params.O1)) then Exit;
    if (Str.Length <> 0) then
    begin
      if (not ParseParam(Params.O2)) then Exit;

      if (Str.Length <> 0) then
      begin
        if (not ParseParam(Params.O3)) then Exit;
        if (Str.Length <> 0) then Exit;
      end;
    end;

    Result := True;
  end;
end;

function TSerializeOptions.ParseOption(const S: UnicodeString): Boolean;
label
  func_params;
var
  Params: TOptionParams;
  A: AnsiString;
  ALength: Integer;
  Enc: Integer;
begin
  Result := False;
  if (not ParseParams(Params, S)) then Exit;

  // utf16 ascii, ignore case
  with PMemoryItems(Params.Name)^ do
  if (Words[0] = $002D) then
  case Length(Params.Name) of
    2: case (Words[1] or $0020) of // "-f", "-i", "-p", "-s"
         $0066:
         begin
           // "-f"
           UseFuncHeaders := True;
           goto func_params;
         end;
         $0069: IgnoreCase := True; // "-i"
         $0070:
         begin
           // "-p"
           case Params.Count of
             1: FillSerializeParams(Params.O1 + '.Chars', Params.O1 + '.Length', 0);
             2: FillSerializeParams(Params.O1, Params.O2, 0);
             3: if (StrToIntDef(Params.O3, -1) >= 0) then
                FillSerializeParams(Params.O1, Params.O2, StrToInt(Params.O3));
           else
             Exit;
           end;
         end;
         $0073:
         begin
           // "-s"
           case Params.Count of
             1: FileName := Params.O1;
             2: FileName := Params.O1 + Params.O2;
           else
             Exit;
           end;
         end;
       end;
    3: if (Cardinals2[0] or $00200020 = $006E0066) then
    begin
      // "-fn"
      UseFuncHeaders := False;
      func_params:
      case Params.Count of
        2: FillFuncParams(Params.O1, Params.O2, '');
        3: FillFuncParams(Params.O1, Params.O2, Params.O3);
      else
        Exit;
      end;
    end;
  else
    A := AnsiString(S);
    ALength := Length(A);
    Enc := -1;

    // byte ascii, ignore case
    with PMemoryItems(A)^ do
    if (Bytes[0] = $2D) then
    if (ALength >= 4) then
    case (Bytes[1]) of // "-10000", "-10007", "-1250", "-1251", "-1252", "-1253", "-1254", ...
      $31: case (Words[1]) of // "-10000", "-10007", "-1250", "-1251", "-1252", "-1253", ...
             $3030: if (ALength = 6) then
                    if (Bytes[4] = $30) then
                    case (Bytes[5]) of // "-10000", "-10007"
                      $30: Enc := 10000; // "-10000"
                      $37: Enc := 10007; // "-10007"
                    end;
             $3532: if (ALength = 5) then
                    case (Bytes[4]) of // "-1250", "-1251", "-1252", "-1253", "-1254", ...
                      $30: Enc := 1250; // "-1250"
                      $31: Enc := 1251; // "-1251"
                      $32: Enc := 1252; // "-1252"
                      $33: Enc := 1253; // "-1253"
                      $34: Enc := 1254; // "-1254"
                      $35: Enc := 1255; // "-1255"
                      $36: Enc := 1256; // "-1256"
                      $37: Enc := 1257; // "-1257"
                      $38: Enc := 1258; // "-1258"
                    end;
           end;
      $32: if (ALength = 6) then
           case (Cardinals1[0] shr 8) of // "-20866", "-21866", "-28592", "-28593", ...
             $363830: if (Bytes[5] = $36) then Enc := 20866; // "-20866"
             $363831: if (Bytes[5] = $36) then Enc := 21866; // "-21866"
             $393538: case (Bytes[5]) of // "-28592", "-28593", "-28594", "-28595", ...
                        $32: Enc := 28592; // "-28592"
                        $33: Enc := 28593; // "-28593"
                        $34: Enc := 28594; // "-28594"
                        $35: Enc := 28595; // "-28595"
                        $36: Enc := 28596; // "-28596"
                        $37: Enc := 28597; // "-28597"
                        $38: Enc := 28598; // "-28598"
                      end;
             $303638: case (Bytes[5]) of // "-28600", "-28603", "-28604", "-28605", "-28606"
                        $30: Enc := 28600; // "-28600"
                        $33: Enc := 28603; // "-28603"
                        $34: Enc := 28604; // "-28604"
                        $35: Enc := 28605; // "-28605"
                        $36: Enc := 28606; // "-28606"
                      end;
           end;
      $38: if (ALength = 4) then
           case (Words[1]) of // "-866", "-874"
             $3636: Enc := 866; // "-866"
             $3437: Enc := 874; // "-874"
           end;
      $61, $41: if (ALength = 5) and (Cardinals1[0] shr 8 or $202020 = $69736E) then
                Enc := 0; // "-ansi"
      $72, $52: if (ALength = 4) and (Words[1] or $2020 = $7761) then
                Enc := CODEPAGE_RAWDATA; // "-raw"
      $75, $55: case (Words[1] or $2020) of // "-user", "-utf16", "-utf32", "-utf8"
                  $6573: if (ALength = 5) and (Bytes[4] or $20 = $72) then
                         Enc := CODEPAGE_USERDEFINED; // "-user"
                  $6674: case ALength of // "-utf8", "-utf16", "-utf32"
                           5: if (Bytes[4] = $38) then Enc := CODEPAGE_UTF8; // "-utf8"
                           6: case (Words[2]) of // "-utf16", "-utf32"
                                $3631: Enc := CODEPAGE_UTF16; // "-utf16"
                                $3233: Enc := CODEPAGE_UTF32; // "-utf32"
                              end;
                         end;
                end;
    end;

    if (Enc < 0) then Exit;
    Encoding := Enc;
  end;

  Result := True;
end;

procedure TSerializeOptions.ParseOptionsLine(const S: UTF16String);
var
  Str: UTF16String;
  Buf: UnicodeString;
  L: NativeUInt;
  Temp: Cardinal;
begin
  Str := S;
  while (Str.Trim) do
  begin
    L := 0;
    while (L < Str.Length) and (Str.Chars[L] > #32) do
    begin
      Inc(L);
    end;

    Buf := Str.SubString(L).ToUnicodeString;
    if (not ParseOption(Buf)) then
      raise Exception.CreateFmt('Unknown file parameter: %s', [Buf]);

    Str.Skip(L);
  end;

  if (FFuncSType = '') then
  begin
    Str.Assign(FLengthParam);
    FFuncSType := TinyStringType(Str.TryToCardinal(Temp));
  end;
end;

procedure TSerializeOptions.AddFromFile(const OptionsFileName: string;
  const OptionsLine: Boolean);
var
  Text: TUTF16TextReader;
  S: UTF16String;
begin
  Text := TUTF16TextReader.CreateFromFile(OptionsFileName);
  try
    if (OptionsLine) and (Text.Readln(S)) then
      ParseOptionsLine(S);

    while (Text.Readln(S)) do
      Add(S.ToUnicodeString);
  finally
    Text.Free;
  end;
end;


{ TSerializer }

procedure TSerializer.InspecOptions;
var
  S: UTF16String;
begin
  FStringKind := csByte;
  case FOptions.Encoding of
    CODEPAGE_UTF16: FStringKind := csUTF16;
    CODEPAGE_UTF32: FStringKind := csUTF32;
  end;
  FCharSize := 1 shl SHIFT_VALUES[FStringKind];
  FIsFunction := (FOptions.FuncName <> '');
  FIsConsts := (FIsFunction) and (FOptions.EnumTypeName = '');

  S.Assign(FOptions.FLengthParam);
  if (S.TryToCardinal(PCardinal(@FNullTerminatedAlignment)^)) then
  begin
    FIsNullTerminated := True;
    if (FNullTerminatedAlignment < FCharSize) then
      FNullTerminatedAlignment := FCharSize;
  end;

  if (FOptions.Count = 0) then
    raise Exception.Create('Identifier list not defined');

  if (FOptions.FCharsParam = '') then
    raise Exception.Create('CharsParam not defined');

  if (FOptions.FLengthParam = '') then
    raise Exception.Create('LengthParam not defined');
end;

function TSerializer.FunctionValue(const Identifier: UnicodeString): UnicodeString;
var
  i, Number: NativeUInt;
  Base: UnicodeString;
  Found: Boolean;
begin
  if (Identifier = '') then
  begin
    Result := 'None';
  end else
  begin
    case Identifier[1] of
      '0'..'9': Result := '_';
    else
      Result := '';
    end;

    for i := 1 to Length(Identifier) do
    case Identifier[i] of
      'a'..'z', 'A'..'Z', '0'..'9', '_':
      begin
        // Ok
        Result := Result + Identifier[i];
      end;
      (*
         Cyrillic characters conversion
      *)
      #$430: Result := Result + 'a';
      #$431: Result := Result + 'b';
      #$432: Result := Result + 'v';
      #$433: Result := Result + 'g';
      #$434: Result := Result + 'd';
      #$435: Result := Result + 'e';
      #$451: Result := Result + 'yo';
      #$436: Result := Result + 'zh';
      #$437: Result := Result + 'z';
      #$438: Result := Result + 'i';
      #$439: Result := Result + 'j';
      #$43A: Result := Result + 'k';
      #$43B: Result := Result + 'l';
      #$43C: Result := Result + 'm';
      #$43D: Result := Result + 'n';
      #$43E: Result := Result + 'o';
      #$43F: Result := Result + 'p';
      #$440: Result := Result + 'r';
      #$441: Result := Result + 's';
      #$442: Result := Result + 't';
      #$443: Result := Result + 'u';
      #$444: Result := Result + 'f';
      #$445: Result := Result + 'h';
      #$446: Result := Result + 'c';
      #$447: Result := Result + 'ch';
      #$448: Result := Result + 'sh';
      #$449: Result := Result + 'sch';
      #$44A: Result := Result + 'j';
      #$44B: Result := Result + 'i';
      #$44C: Result := Result + 'j';
      #$44D: Result := Result + 'e';
      #$44E: Result := Result + 'yu';
      #$44F: Result := Result + 'ya';
      #$410: Result := Result + 'A';
      #$411: Result := Result + 'B';
      #$412: Result := Result + 'V';
      #$413: Result := Result + 'G';
      #$414: Result := Result + 'D';
      #$415: Result := Result + 'E';
      #$401: Result := Result + 'Yo';
      #$416: Result := Result + 'Zh';
      #$417: Result := Result + 'Z';
      #$418: Result := Result + 'I';
      #$419: Result := Result + 'J';
      #$41A: Result := Result + 'K';
      #$41B: Result := Result + 'L';
      #$41C: Result := Result + 'M';
      #$41D: Result := Result + 'N';
      #$41E: Result := Result + 'O';
      #$41F: Result := Result + 'P';
      #$420: Result := Result + 'R';
      #$421: Result := Result + 'S';
      #$422: Result := Result + 'T';
      #$423: Result := Result + 'U';
      #$424: Result := Result + 'F';
      #$425: Result := Result + 'H';
      #$426: Result := Result + 'C';
      #$427: Result := Result + 'Ch';
      #$428: Result := Result + 'Sh';
      #$429: Result := Result + 'Sch';
      #$42A: Result := Result + 'J';
      #$42B: Result := Result + 'I';
      #$42C: Result := Result + 'J';
      #$42D: Result := Result + 'E';
      #$42E: Result := Result + 'Yu';
      #$42F: Result := Result + 'Ya';
    else
      Result := Result + '_';
    end;
  end;

  // include prefix, char case
  if (FIsConsts) then
  begin
    Result := utf16_from_utf16_upper(FOptions.Prefix + Result);
  end else
  begin
    Result[1] := TEXTCONV_CHARCASE.UPPER[Result[1]];
    Result := FOptions.Prefix + Result;
  end;

  // duplicates, enumerate
  if (FFunctionValues <> nil) then
  begin
    Base := Result;
    Number := 0;

    repeat
      Found := False;

      for i := 0 to Length(FFunctionValues) - 1 do
      if (utf16_equal_utf16_ignorecase(Base, FFunctionValues[i])) then
      begin
        Found := True;
        Inc(Number);
        Base := Result + IntToStr(Number);
        Break;
      end;
    until (not Found);

    Result := Base;
  end;

  // add
  i := Length(FFunctionValues);
  SetLength(FFunctionValues, i + 1);
  FFunctionValues[i] := Result;
end;

procedure TSerializer.AddLine;
begin
  AddLine('');
end;

procedure TSerializer.AddLine(const S: UnicodeString);
var
  Index: NativeUInt;
begin
  Index := FLinesCount;
  Inc(FLinesCount);
  SetLength(FLines^, FLinesCount);
  FLines^[Index] := S;
end;

procedure TSerializer.AddLineFmt(const FmtStr: UnicodeString;
  const Args: array of const);
begin
  AddLine(UnicodeFormat(FmtStr, Args));
end;

procedure TSerializer.TextBufferClear;
begin
  FTextBuffer := '';
end;

procedure TSerializer.TextBufferFlush;
var
  LCount: Integer;
begin
  if (FTextBuffer <> '') then
  begin
    LCount := Length(FTextBuffer);
    while (LCount <> 0) and (FTextBuffer[LCount] <= #32) do
    begin
      Dec(LCount);
      SetLength(FTextBuffer, LCount);
    end;

    AddLine(FTextBuffer);
    TextBufferClear;
  end;
end;

procedure TSerializer.TextBufferInclude(const Level: NativeUInt;
  const S: UnicodeString);
var
  L1, L2: NativeUInt;
begin
  L1 := Length(FTextBuffer);
  L2 := Length(S);
  if (L2 = 0) then Exit;

  if (L1 = 0) or (L1 - (Level div 2) + L2 >= RIGHT_MARGIN_VALUE) then
  begin
    TextBufferFlush;
    TextBufferInit(Level, S);
  end else
  begin
    FTextBuffer := FTextBuffer + S;
  end;
end;

procedure TSerializer.TextBufferIncludeFmt(const Level: NativeUInt;
  const FmtStr: UnicodeString; const Args: array of const);
begin
  TextBufferInclude(Level, UnicodeFormat(FmtStr, Args));
end;

procedure TSerializer.TextBufferInit(const Level: NativeUInt;
  const S: UnicodeString);
var
  i: NativeUInt;
begin
  TextBufferClear;

  if (Level <> 0) then
  begin
    SetLength(FTextBuffer, Level);
    for i := 1 to Level do
      FTextBuffer[i] := #32;
  end;

  FTextBuffer := FTextBuffer + S;
end;

procedure TSerializer.TextBufferInitFmt(const Level: NativeUInt;
  const FmtStr: UnicodeString; const Args: array of const);
begin
  TextBufferInit(Level, UnicodeFormat(FmtStr, Args));
end;

procedure TSerializer.TextBufferIncludeLengthCondition(const Level, Offset,
  MinDataSize, MaxDataSize: NativeUInt; const ModeThen: Boolean);
const
  COMPARISONS: array[Boolean] of string = ('>=', '=');
var
  Value: NativeUInt;
begin
  Value := (Offset + MinDataSize) div FCharSize;

  if (Value = 1) and (MinDataSize <> MaxDataSize) then
  begin
    TextBufferIncludeFmt(Level, 'if (%s <> 0) %s ', [FOptions.FLengthParam, AND_THEN[ModeThen]]);
  end else
  begin
    TextBufferIncludeFmt(Level, 'if (%s %s %d) %s ',
    [
      FOptions.FLengthParam,
      COMPARISONS[MinDataSize = MaxDataSize], Value, AND_THEN[ModeThen]
    ]);
  end;
end;

procedure TSerializer.TextBufferIncludeIfThenLine(const Level: NativeUInt;
  const Item: PIdentifier; Offset, ByteCount: NativeUInt; ModeIf: Boolean);
var
  Buf: UnicodeString;
  i, Count, MaxCount: NativeUInt;
  OrMask, AndMask, V1, V2: Cardinal;
begin
  while (ByteCount <> 0) do
  begin
    OrMask := PCardinal(@Item.DataOr[Offset])^;
    V1 := PCardinal(@Item.Data1[Offset])^;
    V2 := PCardinal(@Item.Data2[Offset])^;
    Count := 1;
    if (not FIsNullTerminated) then
    begin
      MaxCount := ByteCount;
    end else
    begin
      MaxCount := FNullTerminatedAlignment - Offset mod FNullTerminatedAlignment;
      if (ByteCount < MaxCount) then
      begin
        MaxCount := ByteCount;
      end;
    end;

    for i := 1 to MaxCount do
    begin
      if (i > SizeOf(Cardinal)) then Break;

      AndMask := AND_VALUES[i];
      if ((V1 or OrMask) and AndMask <> (V2 or OrMask) and AndMask) then Break;

      Count := i;
    end;

    AndMask := AND_VALUES[Count];
    V1 := (V1 or OrMask) and AndMask;
    V2 := (V2 or OrMask) and AndMask;
    Buf := UseDataMasked(Item, Offset, FNullTerminatedAlignment, OrMask, Count);

    // = $... / in [$.., $..]
    if (V1 = V2) then
    begin
      Buf := Buf + ' = ' + HexConst(V1, Count);
    end else
    begin
      if (Count <> 1) then
        raise InternalException;

      Buf := Buf + ' in [' + HexConst(V1, 1) + ', ' + HexConst(V2, 1) + ']';
    end;

    Inc(Offset, Count);
    Dec(ByteCount, Count);
    TextBufferIncludeFmt(Level, '%s(%s) %s ',
    [
      NONE_IF[ModeIf], Buf, AND_THEN[ByteCount = 0]
    ]);
    ModeIf := False;
  end;
end;

procedure TSerializer.TextBufferIncludeComments(const Items: PIdentifierItems;
  const Count: NativeUInt);
var
  i: NativeUInt;
  Item: PIdentifier;
  BufferLength, L: NativeUInt;
begin
  FTextBuffer := FTextBuffer + '// ';
  BufferLength := Length(FTextBuffer);

  for i := 1 to Count do
  begin
    Item := @Items[i - 1];
    L := Length(Item.Info.Comment);
    if (i <> 1) then
    begin
      FTextBuffer := FTextBuffer + ', ';
      Inc(BufferLength, 2);
    end;

    if (i = 1) or (i = Count) or (BufferLength + L < RIGHT_MARGIN_VALUE) then
    begin
      FTextBuffer := FTextBuffer + Item.Info.Comment;
      Inc(BufferLength, L);
    end else
    begin
      FTextBuffer := FTextBuffer + '...';
      Break;
    end;
  end;
end;

function TSerializer.Process(const Options: TSerializeOptions): TUnicodeStrings;
var
  i, j: NativeUInt;
  IdentifiersCount: NativeUInt;
  Info: TIdentifierInfo;
  List: TIdentifierList;
  Buf: UnicodeString;
  Ascii: Boolean;

  Text: TUTF16TextWriter;
  DefaultByteEncoding: Word;
begin
  Result := nil;
  FLines := @Result;
  FLinesCount := 0;
  FOptions := @Options;
  InspecOptions;

  // function values
  FFunctionValues := nil;
  if (FIsFunction) then
  begin
    FunctionValue('Unknown');
  end;

  // parse each identifier line
  for i := 0 to Options.Count - 1 do
  begin
    if (not Info.Parse(Options.Items[i])) then Continue;

    Buf := '';
    if (not Info.MarkerReference) and (FIsFunction) then
      Buf := FunctionValue(Info.Value);

    AddIdentifier(List, Info, Options.Encoding, Options.IgnoreCase,
      FIsNullTerminated, Buf);
  end;
  IdentifiersCount := Length(List);
  if (IdentifiersCount = 0) then
    raise Exception.Create('Identifier list not defined');

  // type header
  if (FIsFunction) and (Options.UseFuncHeaders) then
  begin
    if (Length(FFunctionValues) > 2) then
    for i := 1 to Length(FFunctionValues) - 2 do
    for j := i + 1 to Length(FFunctionValues) - 1 do
    if (FFunctionValues[i] > FFunctionValues[j]) then
    begin
      Buf := FFunctionValues[i];
      FFunctionValues[i] := FFunctionValues[j];
      FFunctionValues[j] := Buf;
    end;

    if (FIsConsts) then
    begin
      Self.AddLine('const');
    end else
    begin
      Self.AddLine('type');
    end;

    if (FIsConsts) then
    begin
      for i := 0 to Length(FFunctionValues) - 1 do
        Self.AddLineFmt('  %s = %d;', [FFunctionValues[i], i]);
    end else
    begin
      TextBufferInit(INDENT_STEP, Options.EnumTypeName + ' = (');
      for i := 0 to Length(FFunctionValues) - 1 do
        TextBufferIncludeFmt(INDENT_STEP * 2, '%s, ', [FFunctionValues[i]]);

      FTextBuffer[Length(FTextBuffer) - 1] := ')';
      FTextBuffer[Length(FTextBuffer)] := ';';
      TextBufferFlush;
    end;

    Self.AddLine;
  end;

  // function Header
  if (FIsFunction) and (Options.UseFuncHeaders) then
  begin
    Buf := Options.EnumTypeName;
    if (FIsConsts) then Buf := 'Cardinal';

    Self.AddLine('function ' + Options.FuncName + '(const S: ' + Options.FuncSType + '): ' + Buf + ';');
    Self.AddLine('begin');
  end;

  // default value
  if (FIsFunction) then
  begin
    TextBufferFlush;
    TextBufferInit(Options.FCodeIndent + INDENT_STEP, '// default value');
    TextBufferFlush;
    TextBufferInitFmt(Options.FCodeIndent + INDENT_STEP, 'Result := %s;', [FFunctionValues[0]]);
    TextBufferFlush;
    Self.AddLine;
  end;

  // serialize comment
  begin
    case Options.Encoding of
       CODEPAGE_UTF8: Buf := 'utf8';
      CODEPAGE_UTF16: Buf := 'utf16';
      CODEPAGE_UTF32: Buf := 'utf32';
    CODEPAGE_RAWDATA: Buf := 'raw';
CODEPAGE_USERDEFINED: Buf := 'user';
                   0: Buf := 'ansi';
    else
      Buf := UnicodeFormat('cp%d', [Options.Encoding]);
    end;

    Ascii := True;
    for i := 0 to Length(List) - 1 do
    if (not List[i].Info.IsAscii) then
    begin
      Ascii := False;
      Break;
    end;

    if (Ascii) then
    begin
      if (FStringKind = csByte) then
      begin
        Buf := 'byte ascii';
      end else
      begin
        Buf := Buf + ' ascii';
      end;
    end;

    if (FIsNullTerminated) then
    begin
      Buf := Buf + ', #0 terminated (' + IntToStr(FNullTerminatedAlignment) + ' byte';
      if (FNullTerminatedAlignment > 1) then
      begin
        Buf := Buf + 's';
      end;
      Buf := Buf + ' aligned)';
    end;

    if (Options.IgnoreCase) then
    begin
      Buf := Buf + ', ignore case';
    end;

    TextBufferFlush;
    TextBufferInitFmt(Options.FCodeIndent + INDENT_STEP, '// %s', [Buf]);
    TextBufferFlush;
  end;

  // case start
  TextBufferFlush;
  if (FIsNullTerminated) then
  begin
    TextBufferInitFmt(Options.FCodeIndent + INDENT_STEP, 'if (Pointer(%s) <> nil) then', [Options.CharsParam]);
    TextBufferFlush;
  end;
  TextBufferInitFmt(Options.FCodeIndent + INDENT_STEP, 'with PMemoryItems(%s)^ do', [Options.CharsParam]);
  TextBufferFlush;

  // recursion
  SetLength(FCaseGroups, IdentifiersCount);
  SortIdentifiers(List, 0, DefaultIdentifierComparator);
  Self.WriteIdentifiers(Pointer(List), IdentifiersCount, 0, Options.FCodeIndent + INDENT_STEP, Options.FCodeIndent + INDENT_STEP, False, 0, 0);

  // case finish
  if (FIsFunction) and (Options.UseFuncHeaders) then
    Self.AddLine('end;');

  // save lines to file
  if (Options.FileName <> '') then
  begin
    DefaultByteEncoding := 0;
    if (FStringKind = csByte) then DefaultByteEncoding := Options.Encoding;
    Text := TUTF16TextWriter.CreateFromFile(Options.FileName, bomUTF8, DefaultByteEncoding);
    try
      for i := 1 to FLinesCount do
      begin
        if (i <> 1) then Text.WriteCRLF;
        Text.WriteData(Pointer(Result[i - 1])^, Length(Result[i - 1]) * SizeOf(UnicodeChar));
      end;
    finally
      Text.Free;
    end;
  end;
end;

function TSerializer.CheckCases(const Items: PIdentifierItems;
  const Count, Offset, ByteCount, OrMask: Cardinal;
  const KnownLength: Boolean; var CheckedCount, CaseCount: NativeUInt): NativeUInt;
label
  fail;
var
  i, j: NativeUInt;
  Item: PIdentifier;
  AndConst: Cardinal;

  v1, v2: Cardinal;
  LocalCases: TCases;
  n: NativeInt;

  function GroupIndex(const Value: Cardinal; const GroupCount: NativeInt): NativeInt;
  var
    k: NativeUInt;
  begin
    for Result := 0 to GroupCount - 1 do
    with FCaseGroups[Result] do
    begin
      for k := 0 to Count - 1 do
      if (Values[k] = Value) then Exit;
    end;

    Result := -1;
  end;

begin
  Result := 0;
  CheckedCount := 0;
  CaseCount := 0;
  AndConst := AND_VALUES[ByteCount];

  for i := 0 to NativeUInt(Count) - 1 do
  begin
    Item := @Items[i];
    if (Item.DataSize < Offset + ByteCount) then
    begin
      if (KnownLength) then goto fail;
      Continue;
    end;
    Inc(CheckedCount);

    // basic alternatives
    v1 := (PCardinal(@Item.Data1[Offset])^ or OrMask) and AndConst;
    v2 := (PCardinal(@Item.Data2[Offset])^ or OrMask) and AndConst;

    // case alternatives for Item/ByteCount (max = 4)
    LocalCases.Count := 1;
    LocalCases.Values[0] := v1;
    if (v1 <> v2) then
    for j := 0 to 3 do
    if (T4Bytes(v1)[j] <> T4Bytes(v2)[j]) then
    begin
      if (LocalCases.Count = 1) then
      begin
        LocalCases.Count := 2;
        LocalCases.Values[1] := LocalCases.Values[0];
        T4Bytes(LocalCases.Values[1])[j] := T4Bytes(v2)[j];
      end else
      if (LocalCases.Count = 2) then
      begin
        LocalCases.Count := 4;
        LocalCases.Values[2] := LocalCases.Values[0];
        LocalCases.Values[3] := LocalCases.Values[1];
        T4Bytes(LocalCases.Values[2])[j] := T4Bytes(v2)[j];
        T4Bytes(LocalCases.Values[3])[j] := T4Bytes(v2)[j];
      end else
      goto fail;
    end;

    // find child group
    n := GroupIndex(LocalCases.Values[0], Result);
    for j := 1 to LocalCases.Count - 1 do
    begin
      if (n <> GroupIndex(LocalCases.Values[j], Result)) then goto fail;
      if (n >= 0) and (NativeUInt(n) <> {Top group}Result - 1) then goto fail;
    end;

    // add if not found
    if (n < 0) then
    begin
      n := Result;
      Inc(Result);
      FCaseGroups[n] := LocalCases;
      Inc(CaseCount, LocalCases.Count);
    end;

    // child number (group)
    Item.CasesGroup := n;
  end;

// done
  Exit;
fail:
  CheckedCount := 0;
  CaseCount := 0;
  Result := 0;
end;

function TSerializer.CheckCases(const Items: PIdentifierItems;
  const Count, Offset: NativeUInt; const KnownLength: Boolean): TWholeCasesInfo;
var
  i: NativeUInt;
  OrMask: Cardinal;
  Item: PIdentifier;
  Found: Boolean;
begin
  // detect or mask
  OrMask := 0;
  if (FOptions.IgnoreCase) then
  begin
    OrMask := PCardinal(@Items[0].DataOr[Offset])^;
    for i := 1 to Count - 1 do
    begin
      OrMask := OrMask and PCardinal(@Items[i].DataOr[Offset])^;
      if (OrMask = 0) then Break;
    end;
  end;

  // best case bytes/or mask
  Found := False;
  FillChar(Result, SizeOf(Result), #0);
  for i := 1 to 4 do
  begin
    Result[i].GroupCount := CheckCases(Items, Count, Offset, i, OrMask,
      KnownLength, Result[i].CheckedCount, Result[i].CaseCount);

    if (Result[i].GroupCount <> 0) then
    begin
      Found := True;
      Result[i].ByteCount := i;
      Result[i].OrMask := OrMask and AND_VALUES[i];
    end;
  end;

  if (not Found) then
  begin
    // check case sensitivity
    if (Count <> 0) then
    for i := 0 to Count - 1 do
    begin
      Item := @Items[i];
      if (Item.Data1[Offset] <> Item.Data2[Offset]) then
        Exit;
    end;

    // exception
    raise InternalException;
  end;
end;

function TSerializer.CalculateBestCases(const Items: PIdentifierItems;
  const Count, Offset: NativeUInt; const KnownLength: Boolean): TCasesInfo;
const
  COST_MUL: array[1..4] of Double = (1, 1 + 0.20, 1 + 0.40, 1 + 0.50);

type
  TBuffer = array[1..SizeOf(TIdentifier)] of Byte;

  function CasesCount(const Cases: TCasesInfo): NativeUInt;
  begin
    Result := Cases.CaseCount + (Count - Cases.CheckedCount);
  end;

  function CasesCost(const Cases: TCasesInfo; const ByteCount: NativeUInt): NativeUInt;
  begin
    if (Cases.GroupCount <> 0) then
    begin
      Result := Round(CasesCount(Cases) * 100 / COST_MUL[ByteCount]);
    end else
    begin
      Result := High(NativeUInt);
    end;
  end;

var
  i, j, MaxByteCount: NativeUInt;
  BestByteCount, BestValue, Value: NativeUInt;
  WholeCases: TWholeCasesInfo;
  MovedCount: NativeUInt;
  Temp: TBuffer;
begin
  WholeCases := CheckCases(Items, Count, Offset, KnownLength);

  MaxByteCount := 4;
  if (FIsNullTerminated) then
  begin
    MaxByteCount := FNullTerminatedAlignment - Offset mod FNullTerminatedAlignment;
  end;

  BestByteCount := 1;
  BestValue := CasesCost(WholeCases[1], 1);
  for i := 2 to MaxByteCount do
  if (WholeCases[i].ByteCount <> 0) then
  begin
    Value := CasesCost(WholeCases[i], i);

    if (Value <= BestValue) then
    begin
      if (not KnownLength) and (not FIsNullTerminated) and (i mod FCharSize <> 0) then Continue;
      BestByteCount := i;
      BestValue := Value;
    end;
  end;

  // unknown length --> known length
  if (not KnownLength) and (not FIsNullTerminated) then
  begin
    if (BestByteCount < FCharSize) or (CasesCount(WholeCases[FCharSize]) > Count shr 1) then
    begin
      Result.ByteCount := 0;
      Exit;
    end;
  end;

  // best cases
  Result := WholeCases[BestByteCount];

  // initialize case indexes
  CheckCases(Items, Count, Offset, BestByteCount, Result.OrMask, KnownLength, {Buffers}BestValue, Value);

  // move and sort unchecked identifiers
  if (Result.CheckedCount = Count) then Exit;
  MovedCount := 0;
  for i := 0 to Count - 1 do
  if (Items[i].DataSize - Offset < Result.ByteCount) then
  begin
    if (i <> 0) then
    begin
      Temp := TBuffer(Items[i]);
        for j := i - 1 downto MovedCount do
        TBuffer(Items[j + 1]) := TBuffer(Items[j]);
      TBuffer(Items[MovedCount]) := Temp;
    end;
    Inc(MovedCount);
  end;
  if (MovedCount <> (Count - Result.CheckedCount)) then raise InternalException;
  SortIdentifiers(Items, MovedCount, Offset, DataSizeIdentifierComparator);
end;

function TSerializer.InspectIdentifiers(const Items: PIdentifierItems;
  const Count, Offset: NativeUInt; const KnownLength: Boolean;
  var MinDataSize, MaxDataSize, SameDataSize: NativeUInt): Boolean;
label
  next;
var
  i, Offs: NativeUInt;
  Item: PIdentifier;
  WholeCases: TWholeCasesInfo;
begin
  MinDataSize := High(NativeUInt);
  MaxDataSize := 0;
  for i := 0 to Count - 1 do
  begin
    Item := @Items[i];
    if (Item.DataSize > MaxDataSize) then MaxDataSize := Item.DataSize;
    if (Item.DataSize < MinDataSize) then MinDataSize := Item.DataSize;
  end;
  Dec(MinDataSize, Offset);
  Dec(MaxDataSize, Offset);

  if (Count = 1) then
  begin
    SameDataSize := MinDataSize{=MaxDataSize};
    Result := True;
    Exit;
  end;

  // same data size
  Offs := Offset;
  Result := False;
  while (Offs <> Offset + MinDataSize) do
  begin
    WholeCases := CheckCases(Items, Count, Offs, True);
    for i := 4 downto 1 do
    if (WholeCases[i].CaseCount <> 0) then
    begin
      Result := True;
      if (WholeCases[i].CaseCount = 1) then
      begin
        Inc(Offs, i);
        goto next;
      end;
    end;
    Break;

  next:
  end;
  SameDataSize := Offs - Offset;
  if (not KnownLength) and (not FIsNullTerminated) and (SameDataSize > FCharSize) then
    SameDataSize := SameDataSize and -FCharSize;
end;

// case identifiers recursion
procedure TSerializer.WriteCaseIdentifiers(const Items: PIdentifierItems;
  const Count, Offset, Level: NativeUInt; const BestCases: TCasesInfo;
  const KnownLength: Boolean; const UnknownLenghtRangeMin, UnknownLenghtRangeMax: NativeUInt);
var
  i, j, ChildCount, ChildLevel: NativeUInt;
  EstimatedCount: NativeUInt;
  Cases: PCases;
  LocalCaseGroups: array of TCases;
begin
  SetLength(LocalCaseGroups, BestCases.GroupCount);
  Move(Pointer(FCaseGroups)^, Pointer(LocalCaseGroups)^, SizeOf(TCases) * BestCases.GroupCount);

  TextBufferIncludeFmt(Level, 'case (%s) of ', [UseDataMasked(@Items[0], Offset, FNullTerminatedAlignment, BestCases.OrMask, BestCases.ByteCount)]);
  TextBufferIncludeComments(Items, Count);
  TextBufferFlush;
  begin
    i := 0;
    while (i < Count) do
    begin
      ChildCount := 1;
      while (i + ChildCount < Count) and
        (Items[i].CasesGroup = Items[i + ChildCount].CasesGroup) do Inc(ChildCount);

      // cases
      TextBufferFlush;
      Cases := @LocalCaseGroups[Items[i].CasesGroup];
      TextBufferIncludeFmt(Level + INDENT_STEP, '%s, ', [HexConst(Cases.Values[0], BestCases.ByteCount)]);
      for j := 1 to Cases.Count - 1 do
      begin
        FTextBuffer := FTextBuffer + HexConst(Cases.Values[j], BestCases.ByteCount) + ', ';
      end;
      FTextBuffer[Length(FTextBuffer) - 1] := ':';

      // estimated write chars count
      if (UnknownLenghtRangeMax <> 0) then
      begin
        EstimatedCount := UnknownLenghtRangeMax * FCharSize;
      end else
      begin
        EstimatedCount := Items[0].DataSize;
      end;
      EstimatedCount := (EstimatedCount - Offset - BestCases.ByteCount) *
        (4 + 2 * Byte(FOptions.FIgnoreCase));

      // childs
      ChildLevel := Level + INDENT_STEP + (3 + 2 * BestCases.ByteCount) * Cases.Count;
      if ((ChildLevel > 22) and (ChildCount <> 1)) or
        ((ChildLevel < RIGHT_MARGIN_VALUE - 40) and ((RIGHT_MARGIN_VALUE - ChildLevel) * 2 < EstimatedCount)) then
      begin
        TextBufferFlush;
        TextBufferInit(Level + INDENT_STEP, 'begin');
        TextBufferFlush;
          WriteIdentifiers(PIdentifierItems(@Items[i]), ChildCount,
            Offset + BestCases.ByteCount,
            Level + INDENT_STEP * 2, Level + INDENT_STEP * 2,
            KnownLength, UnknownLenghtRangeMin, UnknownLenghtRangeMax);
        TextBufferInit(Level + INDENT_STEP, 'end;');
        TextBufferFlush;
      end else
      begin
        WriteIdentifiers(PIdentifierItems(@Items[i]), ChildCount,
          Offset + BestCases.ByteCount,
          Level + INDENT_STEP, ChildLevel,
          KnownLength, UnknownLenghtRangeMin, UnknownLenghtRangeMax);
      end;

      Inc(i, ChildCount);
    end;
  end;
  TextBufferFlush;
  TextBufferInit(Level, 'end;');
  TextBufferFlush;
end;

procedure TSerializer.WriteLengthIdentifiers(const Items: PIdentifierItems;
  const Count, Offset, Level: NativeUInt);
var
  i, ChildCount: NativeUInt;
  Value: NativeUInt;
begin
  // items
  i := 0;
  while (i < Count) do
  begin
    ChildCount := 1;
    while (i + ChildCount < Count) and
      (Items[i].DataSize = Items[i + ChildCount].DataSize) do Inc(ChildCount);

    // length:
    Value := Items[i].DataSize div FCharSize;
    TextBufferInitFmt(Level + INDENT_STEP, '%d: ', [Value]);

    // childs
    WriteIdentifiers(PIdentifierItems(@Items[i]), ChildCount, Offset,
      Level + INDENT_STEP,
      Level + INDENT_STEP + NativeUInt(Length(IntToStr(Value))) + 2, True, 0, 0);
    Inc(i, ChildCount);
  end;
end;

procedure TSerializer.WriteSplittedIdentifiers(const Items: PIdentifierItems;
  const Count, Offset, LargeCodeLevel, Level: NativeUInt; KnownLength: Boolean;
  UnknownLenghtRangeMin, UnknownLenghtRangeMax: NativeUInt);
var
  LCount, i: NativeUInt;
  LItem: PIdentifier;
  LBuffer: TIdentifierList;
begin
  LCount := 0;
  SetLength(LBuffer, Count * 2);

  if (Count <> 0) then
  for i := 0 to Count - 1 do
  begin
    LItem := @Items[i];
    LBuffer[LCount] := LItem^;

    if (LItem.Data1[Offset] = LItem.Data2[Offset]) then
    begin
      Inc(LCount);
    end else
    begin
      LBuffer[LCount].Data2 := Copy(LItem.Data2, 0, MaxInt);
      LBuffer[LCount].Data2[Offset] := LItem.Data1[Offset];
      LBuffer[LCount].DataOr := Copy(LItem.DataOr, 0, MaxInt);
      LBuffer[LCount].DataOr[Offset] := 0;
      Inc(LCount);
      LBuffer[LCount] := LItem^;
      LBuffer[LCount].Data1 := Copy(LItem.Data1, 0, MaxInt);
      LBuffer[LCount].Data1[Offset] := LItem.Data2[Offset];
      LBuffer[LCount].DataOr := Copy(LItem.DataOr, 0, MaxInt);
      LBuffer[LCount].DataOr[Offset] := 0;
      Inc(LCount);
    end;
  end;

  SetLength(LBuffer, LCount);
  SortIdentifiers(LBuffer, Offset, DefaultIdentifierComparator);
  WriteIdentifiers(Pointer(LBuffer), LCount, Offset, LargeCodeLevel, Level,
    KnownLength, UnknownLenghtRangeMin, UnknownLenghtRangeMax);
end;

// identifiers recursion
procedure TSerializer.WriteIdentifiers(const Items: PIdentifierItems;
  const Count, Offset, LargeCodeLevel, Level: NativeUInt; KnownLength: Boolean;
  UnknownLenghtRangeMin, UnknownLenghtRangeMax: NativeUInt);
label
  sort_length_cases, length_cases;
var
  i, UncheckedCount: NativeUInt;
  Item: PIdentifier;
  MinDataSize, MaxDataSize, SameDataSize: NativeUInt;
  CodeLines: NativeUInt;
  BestCases: TCasesInfo;
  Buf: UnicodeString;
begin
  // min/max/same data size
  // optional split
  if (not InspectIdentifiers(Items, Count, Offset, KnownLength, MinDataSize, MaxDataSize, SameDataSize)) then
  begin
    if (MinDataSize <> MaxDataSize) and (not FIsNullTerminated) then
    begin
      goto sort_length_cases;
    end;

    WriteSplittedIdentifiers(Items, Count, Offset, LargeCodeLevel, Level,
      KnownLength, UnknownLenghtRangeMin, UnknownLenghtRangeMax);
  end;

  // final identifier
  if (Count = 1) then
  begin
    Item := @Items[0];
    if (not KnownLength) and (not FIsNullTerminated) then
    begin
      TextBufferIncludeLengthCondition(Level, Offset, SameDataSize, SameDataSize, {ModeThen}(SameDataSize = 0));
    end;
    TextBufferIncludeIfThenLine(Level, Item, Offset, SameDataSize, KnownLength);

    CodeLines := Length(Item.Info.Code);
    if (CodeLines = 1) then
    begin
      // single line
      TextBufferIncludeFmt(Level, '%s // %s', [Item.Info.Code[0], Item.Info.Comment]);
      TextBufferFlush;
    end else
    begin
      // multi lines
      TextBufferFlush;
      TextBufferInit(LargeCodeLevel, 'begin');
      TextBufferFlush;
      TextBufferIncludeFmt(LargeCodeLevel, '  // %s', [Item.Info.Comment]);
      TextBufferFlush;

      if (CodeLines = 0) then
      begin
        AddLine;
      end else
      begin
        for i := 0 to CodeLines - 1 do
        begin
          TextBufferInclude(LargeCodeLevel + INDENT_STEP, Item.Info.Code[i]);
          TextBufferFlush;
        end;
      end;

      TextBufferInit(LargeCodeLevel, 'end;');
      TextBufferFlush;
    end;

    Exit;
  end;

  // same (one) length --> known length
  if (MinDataSize = MaxDataSize) and (not KnownLength) and (not FIsNullTerminated) then
  begin
    TextBufferIncludeLengthCondition(Level, Offset, MinDataSize, MaxDataSize);
    TextBufferFlush;
    KnownLength := True;
  end;

  // emmit childs
  BestCases := CalculateBestCases(Items, Count, Offset, KnownLength);
  if (FIsNullTerminated) then
  begin
    WriteCaseIdentifiers(Items, Count, Offset, Level, BestCases, False, 0, 0);
  end else
  if (BestCases.ByteCount >= FCharSize) then
  begin
    if ({usually 0}SameDataSize < FCharSize) then
    begin
      // cases and unchecked lengths
      UncheckedCount := Count - BestCases.CheckedCount;
      if (UncheckedCount <> 0) then
      begin
        // recalculate min data size
        MinDataSize := High(NativeUInt);
        for i := UncheckedCount to Count - 1 do
        begin
          Item := @Items[i];
          if (Item.DataSize < MinDataSize) then MinDataSize := Item.DataSize;
        end;
        Dec(MinDataSize, Offset);
      end;

      // direct identifiers data cases
      if (KnownLength) or
        ((UncheckedCount = 0) and ((Offset + BestCases.ByteCount) div FCharSize <= UnknownLenghtRangeMin)) then
      begin
        WriteCaseIdentifiers(Items, Count, Offset, Level, BestCases, KnownLength, UnknownLenghtRangeMin, UnknownLenghtRangeMax);
        Exit;
      end;

      // unknown length routine
      if (UncheckedCount = 0) then
      begin
        TextBufferIncludeLengthCondition(Level, Offset, MinDataSize, MaxDataSize);
        TextBufferFlush;
        if (UnknownLenghtRangeMax < (Offset + MinDataSize) div FCharSize) then UnknownLenghtRangeMax := (Offset + MinDataSize) div FCharSize;
        WriteCaseIdentifiers(Items, Count, Offset, Level, BestCases, KnownLength, (Offset + MinDataSize) div FCharSize, UnknownLenghtRangeMax);
      end else
      begin
        // same length checked
        if (MinDataSize = MaxDataSize) then goto length_cases;

        // unchecked/checked routine:
        if (NativeUInt(Length(FTextBuffer)) = Level) then
        begin
          TextBufferIncludeFmt(Level, 'case %s of ', [FOptions.FLengthParam]);
        end else
        begin
          TextBufferFlush;
          TextBufferInitFmt(Level, 'case %s of ', [FOptions.FLengthParam]);
        end;
        TextBufferFlush;
        begin
          WriteLengthIdentifiers(Items, UncheckedCount, Offset, Level);
          TextBufferFlush;

          // length
          UnknownLenghtRangeMin := (Offset + MinDataSize) div FCharSize;
          UnknownLenghtRangeMax := (Offset + MaxDataSize) div FCharSize;
          Buf := UnicodeFormat('%d..%d: ', [UnknownLenghtRangeMin, UnknownLenghtRangeMax]);
          TextBufferInit(Level + INDENT_STEP, Buf);

          // childs
          WriteIdentifiers(PIdentifierItems(@Items[UncheckedCount]),
            BestCases.CheckedCount, Offset,
            Level + INDENT_STEP,
            Level + INDENT_STEP + NativeUInt(Length(Buf)), False, UnknownLenghtRangeMin, UnknownLenghtRangeMax);
        end;
        TextBufferFlush;
        TextBufferInit(Level, 'end;');
        TextBufferFlush;
      end;
    end else
    begin
      // same data size
      Item := @Items[0];

      // length/data condition
      if (KnownLength) or ((Offset + SameDataSize) div FCharSize <= UnknownLenghtRangeMin) then
      begin
        TextBufferIncludeIfThenLine(Level, Item, Offset, SameDataSize, True);
      end else
      begin
        TextBufferIncludeLengthCondition(Level, Offset, SameDataSize, MaxDataSize, False);
        TextBufferIncludeIfThenLine(Level, Item, Offset, SameDataSize, False);

        UnknownLenghtRangeMin := (Offset + SameDataSize) div FCharSize;
        if (UnknownLenghtRangeMax < UnknownLenghtRangeMin) then
          UnknownLenghtRangeMax := UnknownLenghtRangeMin;
      end;
      TextBufferFlush;

      // childs
      WriteIdentifiers(Items, Count, Offset + SameDataSize, LargeCodeLevel, Level, KnownLength, UnknownLenghtRangeMin, UnknownLenghtRangeMax);
    end;
  end else
  if (KnownLength) then
  begin
    // cases
    WriteCaseIdentifiers(Items, Count, Offset, Level, BestCases, True, 0, 0);
  end else
  begin
    // length and cases
  sort_length_cases:
    SortIdentifiers(Items, Count, Offset, DataSizeIdentifierComparator);
  length_cases:
    if (NativeUInt(Length(FTextBuffer)) = Level) then
    begin
      TextBufferIncludeFmt(Level, 'case %s of ', [FOptions.FLengthParam]);
    end else
    begin
      TextBufferFlush;
      TextBufferInitFmt(Level, 'case %s of ', [FOptions.FLengthParam]);
    end;
    if (Level <> (FOptions.FCodeIndent + INDENT_STEP)) then TextBufferIncludeComments(Items, Count);
    TextBufferFlush;
      WriteLengthIdentifiers(Items, Count, Offset, Level);
    TextBufferFlush;
    TextBufferInit(Level, 'end;');
    TextBufferFlush;
  end;
end;


end.
