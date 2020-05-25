program FileConversion;

{$I TINY.DEFINES.inc}
{$APPTYPE CONSOLE}

uses {$ifdef UNITSCOPENAMES}
       Winapi.Windows, System.SysUtils, System.Classes,
     {$else}
       Windows, SysUtils, Classes,
     {$endif}
     Tiny.Types, Tiny.Text;


const
  TEXTS_DIRECTORY = 'Texts';
  CORRECT_FILE_NAME = TEXTS_DIRECTORY + PathDelim + 'Correct.txt';
  OUTPUT_FILE_NAME = TEXTS_DIRECTORY + PathDelim + 'Output.txt';


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
    Exit;
  end;
  if (not FileExists(OUTPUT_FILE_NAME)) then
  begin
    Writeln('"', OUTPUT_FILE_NAME, '" not found');
    Exit;
  end;

  F1 := TFileStream.Create(CORRECT_FILE_NAME, fmOpenRead or fmShareDenyWrite);
  try
    Size := F1.Size;
    F2 := TFileStream.Create(OUTPUT_FILE_NAME, fmOpenRead or fmShareDenyWrite);
    try
      if (Size <> F2.Size) then
      begin
        Writeln('FAILURE SIZE: ', Size, ' and ', F2.Size);
        Exit;
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
        Exit;
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

procedure GenerateCorrectFile;
const
  QUOTES: array[0..9] of string = (
    'If you keep your eye on the profit, you’re going to skimp on the product. But if you focus on making really great products, then the profits will follow. Steve Jobs.',
    'Lisp isn''t a language, it''s a building material. Alan Kay',
    'Good design adds value faster than it adds cost. Thomas C. Gale',
    'In theory, theory and practice are the same. In practice, they’re not. Yoggi Berra',
    'It is easier to port a shell than a shell script. Larry Wall',
    'Computer system analysis is like child-rearing; you can do grievous damage, but you cannot ensure success. Tom DeMarco',
    'Sometimes it pays to stay in bed on Monday, rather than spending the rest of the week debugging Monday''s code. Christopher Thompson',
    'Measuring programming progress by lines of code is like measuring aircraft building progress by weight. Bill Gates',
    'First learn computer science and all the theory. Next develop a programming style. Then forget all that and just hack. George Carrette',
    'Most of you are familiar with the virtues of a programmer. There are three, of course: laziness, impatience, and hubris. Larry Wall'
  );
var
  i: Integer;
  List: TStringList;
begin
  List := TStringList.Create;
  try
    for i := 1 to 10000 do
      List.Add(QUOTES[Random(Length(QUOTES))]);

    List.SaveToFile(CORRECT_FILE_NAME, TEncoding.UTF8);
  finally
    List.Free;
  end;
end;

// the universal text file conversion example
// from any byte order mark (BOM) to any other
procedure ConvertTextFile(const SourceFileName, DestFileName: string; const BOM: TBOM);
var
  SourceBOM: TBOM;
  SourceStream, DestStream: TFileStream;
  SourceBuffer, DestBuffer: array[0..16*1024-1] of Byte;

  Done: Boolean;
  SourceOffset, SourceSize, Size: NativeUInt;
  Context: TTextConvContext;
  ConversionResult: NativeInt;
begin
  DestStream := TFileStream.Create(DestFileName, fmCreate);
  try
    // BOM
    DestStream.Write(BOM_INFO[BOM].Data, BOM_INFO[BOM].Size);

    // conversion
    SourceStream := TFileStream.Create(SourceFileName, fmOpenRead or fmShareDenyWrite);
    try
      // detect source file byte order mark
      SourceSize := SourceStream.Read(SourceBuffer, SizeOf(SourceBuffer));
      Done := (SourceSize <> SizeOf(SourceBuffer));
      SourceBOM := DetectBOM(@SourceBuffer, SourceSize);
      SourceOffset := BOM_INFO[SourceBOM].Size;
      Dec(SourceSize, SourceOffset);

      // initialize conversion context
      Context.Init(BOM, SourceBOM);

      // conversion loop
      repeat
        Context.ModeFinalize := Done;
        repeat
          Context.Source := @SourceBuffer[SourceOffset];
          Context.SourceSize := SourceSize;
          Context.Destination := @DestBuffer;
          Context.DestinationSize := SizeOf(DestBuffer);
          ConversionResult := Context.Convert;

          DestStream.Write(DestBuffer, Context.DestinationWritten);
          Inc(SourceOffset, Context.SourceRead);
          Dec(SourceSize, Context.SourceRead);
        until (ConversionResult <= 0);

        if (Done) then Break;
        Move(SourceBuffer[SourceOffset], SourceBuffer, SourceSize);
        SourceOffset := SourceSize;

        Size := SizeOf(SourceBuffer) - SourceOffset;
        SourceSize := SourceStream.Read(SourceBuffer[SourceOffset], Size);
        Done := (SourceSize <> Size);
        Inc(SourceSize, SourceOffset);
        SourceOffset := 0;
      until (False);
    finally
      SourceStream.Free;
    end;
  finally
    DestStream.Free;
  end;
end;


var
  BOM: TBOM;
  Encoding, FileName: string;

begin
  try
    // create output directory
    CreateDir(TEXTS_DIRECTORY);

    // benchmark text
    Writeln('The benchmark shows an example of universal text file conversions');
    Writeln('among each possible byte order mark (BOM) encodings.');
    if (not FileExists(CORRECT_FILE_NAME)) then
    begin
      Write('Correct file generating... ');
      GenerateCorrectFile;
      Writeln('done.');
    end;
    Writeln;
    Writeln;

    // each BOM conversion
    for BOM := Low(TBOM) to High(TBOM) do
    begin
      // encoding/file name
      if (BOM = bomNone) then Encoding := 'ANSI'
      else Encoding := BOM_INFO[BOM].Name;
      FileName := TEXTS_DIRECTORY + PathDelim + Encoding + '.txt';

      // convert from source "Correct.txt" to current BOM encoding
      Write('UTF8 --> ', Encoding);
      ConvertTextFile(CORRECT_FILE_NAME, FileName, BOM);

      // second conversion from BOM encoding to "Output.txt" (as UTF-8)
      Write(' --> UTF8... ');
      ConvertTextFile(FileName, OUTPUT_FILE_NAME, bomUTF8);

      // check double conversion: "Correct.txt" and "Output.txt"
      CompareOutputAndCorrectFiles;
    end;

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
