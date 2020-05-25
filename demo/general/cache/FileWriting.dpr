program FileWriting;

{$I TINY.DEFINES.inc}
{$APPTYPE CONSOLE}

uses {$ifdef UNITSCOPENAMES}
       Winapi.Windows, System.SysUtils, System.Classes,
     {$else}
       Windows, SysUtils, Classes,
     {$endif}
     Tiny.Types, Tiny.Cache.Buffers;


// test string array
var
  TEST_STRINGS: array[1..1000] of record
    Value: AnsiString;
    Length: Integer;
  end;

procedure GenerateTestStrings;
var
  i: Integer;
begin
  for i := Low(TEST_STRINGS) to High(TEST_STRINGS) do
  begin
    TEST_STRINGS[i].Value := AnsiString(IntToStr(i));
    TEST_STRINGS[i].Length := Length(TEST_STRINGS[i].Value);
  end;
end;

// file names and comparison
const
  CORRECT_FILE_NAME = 'Correct.txt';
  OUTPUT_FILE_NAME = 'Output.txt';

procedure CompareOutputAndCorrectFiles;
var
  F1, F2: TFileStream;
  Size: Int64;
  Count: Integer;
  Same: Boolean;
  Buffer1, Buffer2: array[1..64*1024] of Byte;
begin

  if (not FileExists(CORRECT_FILE_NAME)) then
  begin
    Writeln('"', CORRECT_FILE_NAME, '" not found');
    Abort;
  end;
  if (not FileExists(OUTPUT_FILE_NAME)) then
  begin
    Writeln('"', OUTPUT_FILE_NAME, '" not found');
    Abort;
  end;

  F1 := TFileStream.Create(CORRECT_FILE_NAME, fmOpenRead or fmShareDenyWrite);
  try
    Size := F1.Size;
    F2 := TFileStream.Create(OUTPUT_FILE_NAME, fmOpenRead or fmShareDenyWrite);
    try
      if (Size <> F2.Size) then
      begin
        Writeln('FAILURE SIZE: ', Size, ' and ', F2.Size);
        Abort;
      end;

      Same := True;
      while (Size <> 0) do
      begin
        Count := SizeOf(Buffer1);
        if (Count > Size) then Count := Size;

        F1.ReadBuffer(Buffer1, Count);
        F2.ReadBuffer(Buffer2, Count);
        if (not CompareMem(@Buffer1, @Buffer2, Count)) then
        begin
          Same := False;
          Break;
        end;

        Size := Size - Count;
      end;

      if (not Same) then
      begin
        Writeln('FAILURE');
        Abort;
      end else
      begin
        Writeln('done.');
      end;
    finally
      F2.Free
    end;
  finally
    F1.Free;
  end;
end;

(*
   There is a several common binary/text files generation methods:
     - TStream.Write
     - TStringList save to File/Stream
     - File/TextFile Writeln

   You can significantly increase the perfornace with CachedBuffer classes:
     - TCachedWriter (TCachedFileWriter)
     - TCachedStreamWriter (TCachedWriter) + TFileStream
     - TCachedBufferStream (TStream) + TCachedFileWriter
*)

const
  CRLF_VALUE = 13 or (10 shl 8);
  CRLF: Word = CRLF_VALUE;
  ITERATIONS_COUNT = 22000;

// standard way to write data to Stream
procedure AppendToStream(const Stream: TStream);
var
  Iteration, i: Integer;
begin
  for Iteration := 1 to ITERATIONS_COUNT do
  for i := Low(TEST_STRINGS) to High(TEST_STRINGS) do
  with TEST_STRINGS[i] do
  begin
    Stream.Write(Pointer(Value)^, Length);
    Stream.Write(CRLF, SizeOf(CRLF));
  end;
end;

// high level way to write data to CachedWriter
procedure AppendToCachedWriterHighLevel(const Writer: TCachedWriter);
var
  Iteration, i: Integer;
begin
  for Iteration := 1 to ITERATIONS_COUNT do
  for i := Low(TEST_STRINGS) to High(TEST_STRINGS) do
  with TEST_STRINGS[i] do
  begin
    Writer.Write(Pointer(Value)^, Length);
    Writer.Write(CRLF, SizeOf(CRLF));
  end;
end;

// difficult but the fastest way to write data with TCachedWriter
// you should use Current, Margin and Flush directly. [optional additional memory]
procedure AppendToCachedWriterDirectly(const Writer: TCachedWriter);
var
  Iteration, i, Length: Integer;
  Current: PByte;
begin
  // store current cached pointer to fast register variable
  Current := Writer.Current;

  for Iteration := 1 to ITERATIONS_COUNT do
  for i := Low(TEST_STRINGS) to High(TEST_STRINGS) do
  begin
    // write string data
    Length := TEST_STRINGS[i].Length;
    if (Length <= SizeOf(Int64)) then
    begin
      // use cached memory directly
      if (Length <= SizeOf(Integer)) then PInteger(Current)^ := PInteger(TEST_STRINGS[i].Value)^
      else PInt64(Current)^ := PInt64(TEST_STRINGS[i].Value)^;

      Inc(Current, Length);
    end else
    begin
      // you can use Overflow/Margin and Flush directly
      // or call smart high level Write method
      // but do not forget to retrieve Current value every high level (e.g. Flush) time
      Writer.Current := Current;
      Writer.Write(Pointer(TEST_STRINGS[i].Value)^, Length);
      Current := Writer.Current;
    end;

    // CRLF_VALUE constant is better then CRLF "variable"
    PWord(Current)^ := CRLF_VALUE;
    Inc(Current, SizeOf(Word));
    if (NativeUInt(Current) >= NativeUInt(Writer.Overflow)) then
    begin
      Writer.Current := Current;
      Writer.Flush;
      Current := Writer.Current;
    end;
  end;

  // retrieve current cached pointer
  Writer.Current := Current;
end;

// standard way to write data to File/TextFile
procedure AppendToTextFile(const T: TextFile);
var
  Iteration, i: Integer;
begin
  for Iteration := 1 to ITERATIONS_COUNT do
  for i := Low(TEST_STRINGS) to High(TEST_STRINGS) do
    Writeln(T, TEST_STRINGS[i].Value);
end;

// standard way to append strings to TStringList
procedure AppendToStringList(const List: TStringList);
var
  Iteration, i: Integer;
begin
  for Iteration := 1 to ITERATIONS_COUNT do
  for i := Low(TEST_STRINGS) to High(TEST_STRINGS) do
    List.Add(string(TEST_STRINGS[i].Value));
end;

(*
   So let's try to use some common methods, CachedWriter
   and combine some of them
*)

type
  TGeneratingMethod = procedure(const FileName: string);

// standard TStringList + SaveToFile (slow)
procedure StringListGenerating(const FileName: string);
var
  List: TStringList;
begin
  List := TStringList.Create;
  try
    AppendToStringList(List);
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

// standard sequential TFileStream writing (slow)
procedure FileStreamGenerating(const FileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    AppendToStream(F);
  finally
    F.Free;
  end;
end;

// standard sequential TMemoryStream writing + SaveToFile (slow)
procedure MemoryStreamGenerating(const FileName: string);
var
  M: TMemoryStream;
begin
  M := TMemoryStream.Create;
  try
    AppendToStream(M);
    M.SaveToFile(FileName);
  finally
    M.Free;
  end;
end;

// standard TextFile writing
procedure TextFileGenerating(const FileName: string);
var
  T: TextFile;
begin
  AssignFile(T, FileName);
  ReWrite(T);
  try
    AppendToTextFile(T);
  finally
    CloseFile(T);
  end;
end;

// standard TextFile + 64kb buffer writing (fast)
procedure BufferedTextFileGenerating(const FileName: string);
var
  T: TextFile;
  Buffer: array[Word] of Byte;
begin
  AssignFile(T, FileName);
  ReWrite(T);
  SetTextBuf(T, Buffer);
  try
    AppendToTextFile(T);
  finally
    CloseFile(T);
  end;
end;

// high level TCachedFileWriter writing (very fast)
procedure CachedFileWriterGenerating(const FileName: string);
var
  Writer: TCachedFileWriter;
begin
  Writer := TCachedFileWriter.Create(FileName);
  try
    AppendToCachedWriterHighLevel(Writer);
  finally
    Writer.Free;
  end;
end;

// low level directly TCachedFileWriter writing (extremely fast)
procedure CachedFileWriterDirectlyGenerating(const FileName: string);
var
  Writer: TCachedFileWriter;
begin
  Writer := TCachedFileWriter.Create(FileName);
  try
    AppendToCachedWriterDirectly(Writer);
  finally
    Writer.Free;
  end;
end;

// generate output file and measure the time
var
  GeneratingMethodNumber: Cardinal = 0;

procedure RunGeneratingMethod(const Description: string; const GeneratingMethod: TGeneratingMethod);
var
  Time: Cardinal;
begin
  Inc(GeneratingMethodNumber);
  Write(GeneratingMethodNumber, ') ', Description, '...');

  Time := GetTickCount;
    GeneratingMethod(OUTPUT_FILE_NAME);
  Time := GetTickCount - Time;
  Write(' ', Time, 'ms ');

  CompareOutputAndCorrectFiles;
end;


begin
  try
    // benchmark text
    Writeln('The benchmark helps to compare the time of binary/text files generating methods');
    Writeln('Output file must be equal to "Correct.txt" (about 100Mb)');
    GenerateTestStrings;
    if (not FileExists(CORRECT_FILE_NAME)) then
    begin
      Write('Correct file generating... ');
      BufferedTextFileGenerating(CORRECT_FILE_NAME);
      Writeln('done.');
    end;

    // run writers, measure time, compare with correct file
    Writeln;
    Writeln('Let''s test generating methods (it may take up to ten minutes):');
    RunGeneratingMethod('StringList + SaveToFile', StringListGenerating);
    RunGeneratingMethod('FileStream', FileStreamGenerating);
    RunGeneratingMethod('MemoryStream + SaveToFile', MemoryStreamGenerating);
    RunGeneratingMethod('TextFile', TextFileGenerating);
    RunGeneratingMethod('TextFile + Buffer', BufferedTextFileGenerating);
    RunGeneratingMethod('CachedFileWriter', CachedFileWriterGenerating);
    RunGeneratingMethod('CachedFileWriter directly', CachedFileWriterDirectlyGenerating);
  except
    on EAbort do ;

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
