program FileReaders;

{$I TINY.DEFINES.inc}
{$APPTYPE CONSOLE}

uses {$ifdef UNITSCOPENAMES}
       Winapi.Windows, System.SysUtils, System.Classes,
     {$else}
       Windows, SysUtils, Classes,
     {$endif}
     Tiny.Types, Tiny.Text, Tiny.Cache.Text;


// test file information
const
  STRINGS_COUNT = 1000;
  ITERATIONS_COUNT = 22000;
  CORRECT_LINES_COUNT = ITERATIONS_COUNT * STRINGS_COUNT;
  CORRECT_FILE_NAME = 'Correct.txt';

procedure GenerateTestFile;
var
  Iteration, i: Integer;
  T: TextFile;
  Buffer: array[Word] of Byte;
begin
  AssignFile(T, CORRECT_FILE_NAME);
  ReWrite(T);
  SetTextBuf(T, Buffer);
  try
    // UTF-8 BOM
    Write(T, AnsiString(#$EF#$BB#$BF));

    // text
    SetTextCodePage(T, CODEPAGE_UTF8);
    for Iteration := 1 to ITERATIONS_COUNT do
    for i := 1 to STRINGS_COUNT do
      Writeln(T, i);
  finally
    CloseFile(T);
  end;
end;


type
  TReaderMethod = function(const FileName: string): Integer;


function StringListReader(const FileName: string): Integer;
var
  List: TStringList;
begin
  List := TStringList.Create;
  try
    List.LoadFromFile(FileName);
    Result := List.Count;
  finally
    List.Free;
  end;
end;

function TextFileReader(const FileName: string): Integer;
var
  T: TextFile;
  S: string;
begin
  Result := 0;

  AssignFile(T, FileName);
  Reset(T);
  SetTextCodePage(T, CODEPAGE_UTF8);
  try
    while (not EOF(T)) do
    begin
      Readln(T, S);
      Inc(Result);
    end;
  finally
    CloseFile(T);
  end;
end;

function BufferedTextFileReader(const FileName: string): Integer;
var
  T: TextFile;
  S: string;
  Buffer: array[Word] of Byte;
begin
  Result := 0;

  AssignFile(T, FileName);
  Reset(T);
  SetTextBuf(T, Buffer);
  SetTextCodePage(T, CODEPAGE_UTF8);
  try
    while (not EOF(T)) do
    begin
      Readln(T, S);
      Inc(Result);
    end;
  finally
    CloseFile(T);
  end;
end;

function CachedANSIReader(const FileName: string): Integer;
var
  T: TByteTextReader;
  S: ByteString;
begin
  Result := 0;

  T := TByteTextReader.CreateFromFile(0, FileName);
  try
    while (T.Readln(S)) do
    begin
      Inc(Result);
    end;
  finally
    T.Free
  end;
end;

function CachedUTF8Reader(const FileName: string): Integer;
var
  T: TByteTextReader;
  S: ByteString;
begin
  Result := 0;

  T := TByteTextReader.CreateFromFile(CODEPAGE_UTF8, FileName);
  try
    while (T.Readln(S)) do
    begin
      Inc(Result);
    end;
  finally
    T.Free
  end;
end;

function CachedUTF16Reader(const FileName: string): Integer;
var
  T: TUTF16TextReader;
  S: UTF16String;
begin
  Result := 0;

  T := TUTF16TextReader.CreateFromFile(FileName);
  try
    while (T.Readln(S)) do
    begin
      Inc(Result);
    end;
  finally
    T.Free
  end;
end;

function CachedUTF32Reader(const FileName: string): Integer;
var
  T: TUTF32TextReader;
  S: UTF32String;
begin
  Result := 0;

  T := TUTF32TextReader.CreateFromFile(FileName);
  try
    while (T.Readln(S)) do
    begin
      Inc(Result);
    end;
  finally
    T.Free
  end;
end;


var
  ReaderMethodNumber: Cardinal = 0;

procedure RunReaderMethod(const Description: string; const ReaderMethod: TReaderMethod);
var
  Time: Cardinal;
  LinesCount: Integer;
begin
  // reset filesystem cache to have same test conditions
  // (thanks for Sapersky)
  FileClose(CreateFile(PChar(CORRECT_FILE_NAME), GENERIC_READ, FILE_SHARE_READ, nil ,OPEN_EXISTING, FILE_FLAG_NO_BUFFERING, 0));

  Inc(ReaderMethodNumber);
  Write(ReaderMethodNumber, ') ', Description, '...');
  Time := GetTickCount;
    LinesCount := ReaderMethod(CORRECT_FILE_NAME);
  Time := GetTickCount - Time;

  Write(' ', Time, 'ms');
  if (LinesCount <> CORRECT_LINES_COUNT) then Write(' FAILURE LINES COUNT = ', LinesCount);
  Writeln;
end;


begin
  try
    // benchmark text
    Writeln('The benchmark shows how to use TCachedTextReader-classes to carry out');
    Writeln('the reading of text files lines by analogy with standard solutions.');
    if (not FileExists(CORRECT_FILE_NAME)) then
    begin
      Write('Correct file generating... ');
      GenerateTestFile;
      Writeln('done.');
    end;

    // run readers, measure time, compare lines count
    Writeln;
    RunReaderMethod('TStringList <-- UTF8', StringListReader);
    RunReaderMethod('TextFile <-- UTF8', TextFileReader);
    RunReaderMethod('TextFile + Buffer <-- UTF8', BufferedTextFileReader);
    RunReaderMethod('CachedByteReader ANSI <-- UTF8', CachedANSIReader);
    RunReaderMethod('CachedByteReader UTF8 <-- UTF8', CachedUTF8Reader);
    RunReaderMethod('CachedUTF16Reader <-- UTF8', CachedUTF16Reader);
    RunReaderMethod('CachedUTF32Reader <-- UTF8', CachedUTF32Reader);

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
