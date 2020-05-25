program FileReading;

{$I TINY.DEFINES.inc}
{$APPTYPE CONSOLE}

uses {$ifdef UNITSCOPENAMES}
       Winapi.Windows, System.SysUtils, System.Classes,
     {$else}
       Windows, SysUtils, Classes,
     {$endif}
     Tiny.Types, Tiny.Cache.Buffers;


// test file information
const
  CORRECT_FILE_NAME = 'Correct.txt';
  CORRECT_SUM = Int64($2904E86C0);

procedure GenerateTestFile;
const
  STRINGS_COUNT = 1000;
  ITERATIONS_COUNT = 22000;
var
  Iteration, i: Integer;
  T: TextFile;
  Buffer: array[Word] of Byte;
begin
  AssignFile(T, CORRECT_FILE_NAME);
  ReWrite(T);
  SetTextBuf(T, Buffer);
  try
    for Iteration := 1 to ITERATIONS_COUNT do
    for i := 1 to STRINGS_COUNT do
      Writeln(T, i);

  finally
    CloseFile(T);
  end;
end;

// copied from System.ValLong and corrected to ShortString with DefValue 0
function ShortStrToInt(const S: ShortString): Integer;
var
  I, Len: Integer;
  Negative, Hex: Boolean;
begin
  Result := 0;
  Negative := False;
  Hex := False;
  I := 1;
  Len := Length(S);

  while (I <= Len) and (S[I] = ' ') do Inc(I);
  if (I > Len) then Exit;  

  case S[I] of
    '$',
    'x',
    'X': begin
           Hex := True;
           Inc(I);
         end;
    '0': begin
          Hex := (Len > I) and (S[I+1] in ['x', 'X']);
    if Hex then Inc(I,2);
         end;
    '-': begin
          Negative := True;
          Inc(I);
         end;
    '+': Inc(I);
  end;
  if Hex then
    while I <= Len do
    begin
      if Result > (High(Result) div 16) then
      begin
        Result := 0;
        Exit;
      end;
      case s[I] of
        '0'..'9': Result := Result * 16 + Ord(S[I]) - Ord('0');
        'a'..'f': Result := Result * 16 + Ord(S[I]) - Ord('a') + 10;
        'A'..'F': Result := Result * 16 + Ord(S[I]) - Ord('A') + 10;
      else
        Result := 0;
        Exit;
      end;
    end
  else
    while (I <= Len) do
    begin
      if Result > (High(Result) div 10) then
      begin
        Result := 0;
        Exit;
      end;
      Result := Result * 10 + Ord(S[I]) - Ord('0');
      Inc(I);
    end;
  if Negative then
    Result := -Result;
end;

const
  PARSE_MARKER_CRLF = #13;
  PARSE_MARKER_DIGIT = '1';

(*
   Many of the parsing algorithms use the <Pointer, Size> variables.
   However, lots of tests show that it is more effective to use <Pointer, Overflow>
   + some character markers in Additional memory on which the parser will
   definitely stop. The productivity benefits are made due to fact that there is
   no need to analyze the Size at every character reading time. Moreover with a
   shortage of CPU registers, Overflow variables store on stack and the
   comparison takes only 2 CPU cycles instead of 2 + 6 cycles at comparison and
   modification of Size.

   Sometimes it is useful to modify a "reading" memory. For example, with XML parsing
   it is possible to replace the &...; entities with the real characters.
   Knowing the storage features of System types it is possible for example
   to emulate UnicodeString or dynamic array instances. In this function we emulate
   ShortString by store length byte on Previous memory.

   The function parses and sums up the numbers stopping on markers at the end.
   It returns the pointer to the last non-parsed data at the end of the buffer.
*)
function AddParsedTextNumbers(var Sum: Int64; Current: PAnsiChar; Overflow: PAnsiChar): PAnsiChar;
var
  S: PAnsiChar;
  Len: NativeUInt;
begin
  repeat
    // left trim
    while (Current^ <= ' ') do Inc(Current);
    if (Current >= Overflow{overflow marker found}) then
    begin
      Current := Overflow;
      Break;
    end;

    // find first non-numeric character or marker
    S := Current + 1;
    while (S^ > ' ') do Inc(S);
    if (S >= Overflow{overflow marker found}) then Break;

    // length
    Len := NativeUInt(S) - NativeUInt(Current);

    // WRITE length to previous memory and use char buffer as ShortString pointer
    // ShortString = [Len: Byte] array(Len) of AnsiChar
    Dec(Current);
    Byte(Current^) := Len;
    Sum := Sum + ShortStrToInt(PShortString(Current)^);

    // next current character
    Current := S + 1;
  until (False);

  // return current usually numeric string pointer
  Result := Current;
end;


type
  TParsingMethod = function(const FileName: string): Int64;

// standard way to load file and
// process every TStringList item
function StringListParsing(const FileName: string): Int64;
var
  i: Integer;
  List: TStringList;
begin
  Result := 0;
  List := TStringList.Create;
  try
    List.LoadFromFile(FileName);

    for i := 0 to List.Count - 1 do
    Result := Result + StrToInt(List[i]);
  finally
    List.Free;
  end;
end;

// fast parsing method
// but it need too much memory (same as file size)
function AllocatedMemoryParsing(const FileName: string): Int64;
var
  Memory: Pointer;
  F: TFileStream;
  Size: Integer;
  Current, Overflow: PAnsiChar;
begin
  Memory := nil;
  try
    // read entire file to allocated memory buffer
    F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      Size := F.Size;
      GetMem(Memory, 1{previous} + Size + 3{markers});

      Current := PAnsiChar(Memory) + 1;
      F.Read(Current^, Size);
    finally
      F.Free;
    end;

    // overflow
    Overflow := Current + Size;

    // mark CRLF to parse last number correctly
    Overflow^ := #13;
    Inc(Overflow);

    // advanced markers
    Overflow[0] := PARSE_MARKER_CRLF;
    Overflow[1] := PARSE_MARKER_DIGIT;

    // parse numbers
    Result := 0;
    AddParsedTextNumbers(Result, Current, Overflow);
  finally
    if (Memory <> nil) then FreeMem(Memory);
  end;
end;

// optimal way to sequential file parsing
// flush and parse memory buffer by TCachedReader interface
function CachedReaderParsing(const FileName: string): Int64;
var
  Reader: TCachedReader;
  Current, Overflow: PAnsiChar;
begin
  Result := 0;

  Reader := TCachedFileReader.Create(FileName);
  try
    while (not Reader.EOF) do
    begin
      Current := PAnsiChar(Reader.Current);
      Overflow := PAnsiChar(Reader.Overflow);

      // mark CRLF to parse last number correctly
      if (Reader.Finishing) then
      begin
        Overflow^ := #13;
        Inc(Overflow);
      end;

      // markers
      Overflow[0] := PARSE_MARKER_CRLF;
      Overflow[1] := PARSE_MARKER_DIGIT;

      // parse reader memory, flush reader (or EOF in Finishing case)
      Reader.Current := PByte(AddParsedTextNumbers(Result, Current, Overflow));
      if (Reader.Finishing) then Reader.Current := Reader.Overflow;
      Reader.Flush;
    end;
  finally
    Reader.Free;
  end;
end;

// run parser and measure the time
var
  ParsingMethodNumber: Cardinal = 0;

procedure RunParsingMethod(const Description: string; const ParsingMethod: TParsingMethod);
var
  Time: Cardinal;
  Sum: Int64;
begin
  // reset filesystem cache to have same test conditions
  // (thanks for Sapersky)
  FileClose(CreateFile(PChar(CORRECT_FILE_NAME), GENERIC_READ, FILE_SHARE_READ, nil ,OPEN_EXISTING, FILE_FLAG_NO_BUFFERING, 0));

  Inc(ParsingMethodNumber);
  Write(ParsingMethodNumber, ') ', Description, '...');
  Time := GetTickCount;
    Sum := ParsingMethod(CORRECT_FILE_NAME);
  Time := GetTickCount - Time;

  Write(' ', Time, 'ms');
  if (Sum <> CORRECT_SUM) then Write(' FAILURE Sum = 0x%s', IntToHex(Sum, 0));
  Writeln;
end;


begin
  try
    // benchmark text
    Writeln('The benchmark helps to compare the time of binary/text files parsing methods');
    Writeln('Testing file is "Correct.txt" (about 100Mb)');
    Writeln('Total sum of numbers must be equal 0x', IntToHex(CORRECT_SUM, 0));
    if (not FileExists(CORRECT_FILE_NAME)) then
    begin
      Write('Correct file generating... ');
      GenerateTestFile;
      Writeln('done.');
    end;

    // run parsers, measure time, compare summary value
    Writeln;
    Writeln('Let''s test parsing methods (it may take a few minutes):');
    RunParsingMethod('Allocated 100Mb memory', AllocatedMemoryParsing);
    RunParsingMethod('CachedReader', CachedReaderParsing);
    RunParsingMethod('StringList', StringListParsing);
  except
    on E: Exception do
    Writeln(E.ClassName, ': ', E.Message);
  end;

  if (ParamStr(1) <> '-nowait') then
  begin
    Writeln;
    Write('Press Enter to quit');
    Readln;
  end;
end.
