program FileWriters;

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


type
  TWriterMethod = procedure(const FileName: string);

procedure StringListWriter(const FileName: string);
var
  Iteration, i: Integer;
  List: TStringList;
begin
  List := TStringList.Create;
  try
    for Iteration := 1 to ITERATIONS_COUNT do
    for i := 1 to STRINGS_COUNT do
      List.Add(IntToStr(i));

    List.SaveToFile(FileName, TEncoding.UTF8);
  finally
    List.Free;
  end;
end;

procedure TextFileWriter(const FileName: string);
var
  Iteration, i: Integer;
  T: TextFile;
begin
  AssignFile(T, FileName);
  ReWrite(T);
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

procedure BufferedTextFileWriter(const FileName: string);
var
  Iteration, i: Integer;
  T: TextFile;
  Buffer: array[Word] of Byte;
begin
  AssignFile(T, FileName);
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

procedure CachedTextWriterAppend(const Text: TCachedTextWriter);
var
  Iteration, i: Integer;
begin
  for Iteration := 1 to ITERATIONS_COUNT do
  for i := 1 to STRINGS_COUNT do
  begin
    Text.WriteInteger(i);
    Text.WriteCRLF;
  end;
end;

procedure CachedANSIWriter(const FileName: string);
var
  Text: TByteTextWriter;
begin
  Text := TByteTextWriter.CreateFromFile(0, FileName, bomUTF8);
  try
    CachedTextWriterAppend(Text);
  finally
    Text.Free;
  end;
end;

procedure CachedUTF8Writer(const FileName: string);
var
  Text: TByteTextWriter;
begin
  Text := TByteTextWriter.CreateFromFile(CODEPAGE_UTF8, FileName, bomUTF8);
  try
    CachedTextWriterAppend(Text);
  finally
    Text.Free;
  end;
end;

procedure CachedUTF16Writer(const FileName: string);
var
  Text: TUTF16TextWriter;
begin
  Text := TUTF16TextWriter.CreateFromFile(FileName, bomUTF8);
  try
    CachedTextWriterAppend(Text);
  finally
    Text.Free;
  end;
end;

procedure CachedUTF32Writer(const FileName: string);
var
  Text: TUTF32TextWriter;
begin
  Text := TUTF32TextWriter.CreateFromFile(FileName, bomUTF8);
  try
    CachedTextWriterAppend(Text);
  finally
    Text.Free;
  end;
end;


var
  WriterMethodNumber: Cardinal = 0;

procedure RunWriterMethod(const Description: string; const WriterMethod: TWriterMethod);
var
  Time: Cardinal;
begin
  Inc(WriterMethodNumber);
  Write(WriterMethodNumber, ') ', Description, '...');

  Time := GetTickCount;
    WriterMethod(OUTPUT_FILE_NAME);
  Time := GetTickCount - Time;
  Write(' ', Time, 'ms ');

  CompareOutputAndCorrectFiles;
end;


begin
  try
    // benchmark text
    Writeln('The benchmark shows how to use TCachedTextWriter-classes to carry out');
    Writeln('the text data writing by analogy with standard solutions.');
    if (not FileExists(CORRECT_FILE_NAME)) then
    begin
      Write('Correct file generating... ');
      BufferedTextFileWriter(CORRECT_FILE_NAME);
      Writeln('done.');
    end;

    // run writers, measure time, compare with correct file
    Writeln;
    RunWriterMethod('TStringList --> UTF8', StringListWriter);
    RunWriterMethod('TextFile --> UTF8', TextFileWriter);
    RunWriterMethod('TextFile + Buffer --> UTF8', BufferedTextFileWriter);
    RunWriterMethod('CachedByteWriter ANSI --> UTF8', CachedANSIWriter);
    RunWriterMethod('CachedByteWriter UTF8 --> UTF8', CachedUTF8Writer);
    RunWriterMethod('CachedUTF16Writer --> UTF8', CachedUTF16Writer);
    RunWriterMethod('CachedUTF32Writer --> UTF8', CachedUTF32Writer);

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
