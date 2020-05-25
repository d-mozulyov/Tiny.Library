program StringConversion;

{$I TINY.DEFINES.inc}
{$APPTYPE CONSOLE}

{$WARN IMPLICIT_STRING_CAST OFF}
{$WARN IMPLICIT_STRING_CAST_LOSS OFF}

uses {$ifdef UNITSCOPENAMES}
       Winapi.Windows, System.SysUtils,
     {$else}
       Windows, SysUtils,
     {$endif}
     Tiny.Types, Tiny.Text;


const
  CODEPAGE_LATIN = 1250;
  CODEPAGE_ISO_LATIN = 28592;

type
  LatinString = type AnsiString(CODEPAGE_LATIN);
  IsoLatinString = type AnsiString(CODEPAGE_ISO_LATIN);

// NOTE:
// there is an internal AnsiString code page field in the desktop
// Delphi (ver >= 2009) compilers
//
// The Tiny.Library supports an internal code page field, but you should
// perform simple explicit typecast AnsiString() to avoid the hidden conversion.
// for example:
// var
//   L1: LatinString;
//   L2: {Iso}LatinString;
// begin
//   // Incorrect!!!
//   // L1 and L2 will be implicit converted to the default AnsiString code page
//   L1 := sbcs_from_sbcs(L2, CODEPAGE_LATIN);
//
//   // Correct
//   // will be used and assigned the internal L1 and L2 code pages
//   sbcs_from_sbcs(AnsiString(L1), AnsiString(L2), CODEPAGE_LATIN);

const
  ITERATIONS_COUNT = 5 * 1000000;


function ansi_from_ansi_standard(const Source: IsoLatinString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: LatinString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := AnsiUpperCase(Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;

function ansi_from_ansi_textconv(const Source: IsoLatinString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: LatinString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.sbcs_from_sbcs_upper(AnsiString(Destination), AnsiString(Source), CODEPAGE_LATIN);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.sbcs_from_sbcs(AnsiString(Destination), AnsiString(Source), CODEPAGE_LATIN);
  end;

  Result := Length(Destination);
end;

function ansi_from_utf16_standard(const Source: UnicodeString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: LatinString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := AnsiUpperCase(Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;

function ansi_from_utf16_textconv(const Source: UnicodeString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: LatinString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.sbcs_from_utf16_upper(AnsiString(Destination), Source, CODEPAGE_LATIN);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.sbcs_from_utf16(AnsiString(Destination), Source, CODEPAGE_LATIN);
  end;

  Result := Length(Destination);
end;

function ansi_from_utf8_standard(const Source: UTF8String; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: LatinString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := AnsiUpperCase(Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;

function ansi_from_utf8_textconv(const Source: UTF8String; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: LatinString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.sbcs_from_utf8_upper(AnsiString(Destination), Source, CODEPAGE_LATIN);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.sbcs_from_utf8(AnsiString(Destination), Source, CODEPAGE_LATIN);
  end;

  Result := Length(Destination);
end;

function utf16_from_ansi_standard(const Source: IsoLatinString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UnicodeString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := AnsiUpperCase(Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;

function utf16_from_ansi_textconv(const Source: IsoLatinString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UnicodeString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.utf16_from_sbcs_upper(Destination, AnsiString(Source));
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.utf16_from_sbcs(Destination, AnsiString(Source));
  end;

  Result := Length(Destination);
end;

function utf16_from_utf16_standard(const Source: UnicodeString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UnicodeString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := AnsiUpperCase(Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;

function utf16_from_utf16_textconv(const Source: UnicodeString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UnicodeString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.utf16_from_utf16_upper(Destination, Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;

function utf16_from_utf8_standard(const Source: UTF8String; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UnicodeString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := AnsiUpperCase(Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;

function utf16_from_utf8_textconv(const Source: UTF8String; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UnicodeString;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.utf16_from_utf8_upper(Destination, Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.utf16_from_utf8(Destination, Source);
  end;

  Result := Length(Destination);
end;

function utf8_from_ansi_standard(const Source: IsoLatinString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UTF8String;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := AnsiUpperCase(Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;

function utf8_from_ansi_textconv(const Source: IsoLatinString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UTF8String;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.utf8_from_sbcs_upper(Destination, AnsiString(Source));
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.utf8_from_sbcs(Destination, AnsiString(Source));
  end;

  Result := Length(Destination);
end;

function utf8_from_utf16_standard(const Source: UnicodeString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UTF8String;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := AnsiUpperCase(Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;

function utf8_from_utf16_textconv(const Source: UnicodeString; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UTF8String;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.utf8_from_utf16_upper(Destination, Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
	Tiny.Text.utf8_from_utf16(Destination, Source);
  end;

  Result := Length(Destination);
end;

function utf8_from_utf8_standard(const Source: UTF8String; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UTF8String;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := AnsiUpperCase(Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;

function utf8_from_utf8_textconv(const Source: UTF8String; const UpperCase: Boolean): Integer;
var
  i: Integer;
  Destination: UTF8String;
begin
  if (UpperCase) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    Tiny.Text.utf8_from_utf8_upper(Destination, Source);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    Destination := Source;
  end;

  Result := Length(Destination);
end;


procedure RunTest(const DestinationEncoding, SourceEncoding: string;
  const Source; const ProcStandard, ProcTextConv: Pointer;
  const UpperCaseOnly: Boolean = False);
type
  TTestProc = function(const Source: Pointer{some string type}; const UpperCase: Boolean): Integer;
var
  Conversion: string;
  UpperCase: Boolean;
  Time: Cardinal;
begin
  for UpperCase := UpperCaseOnly to High(Boolean) do
  begin
    Conversion := DestinationEncoding + ' <== ' + SourceEncoding;
    if (UpperCase) then Conversion := Conversion + ' upper';
    while (Length(Conversion) < 37) do Conversion := Conversion + ' ';

    Write(Conversion, ' Standard - ');
    Time := GetTickCount;
    TTestProc(ProcStandard)(Pointer(Source), UpperCase);
    Time := GetTickCount - Time;
    Write(Time, 'ms, Tiny - ');

    Time := GetTickCount;
    TTestProc(ProcTextConv)(Pointer(Source), UpperCase);
    Time := GetTickCount - Time;
    Writeln(Time, 'ms');
  end;
end;


const
  TEST_STRING: string = 'If you keep your eye on the profit, you’re going to ' +
                        'skimp on the product. But if you focus on making really ' +
                        'great products, then the profits will follow. Steve Jobs.';

procedure RunAnsiAnsi;
const
  TD = 'ansi(1250)';
  TS = 'ansi(iso-2859-2)';
var
  Source: IsoLatinString;
begin
  Source := TEST_STRING;
  RunTest(TD, TS, Source,
    @ansi_from_ansi_standard,
    @ansi_from_ansi_textconv
    );
end;

procedure RunAnsiUtf16;
const
  TD = 'ansi';
  TS = 'utf16';
var
  Source: UnicodeString;
begin
  Source := TEST_STRING;
  RunTest(TD, TS, Source,
    @ansi_from_utf16_standard,
    @ansi_from_utf16_textconv
    );
end;

procedure RunAnsiUtf8;
const
  TD = 'ansi';
  TS = 'utf8';
var
  Source: UTF8String;
begin
  Source := TEST_STRING;
  RunTest(TD, TS, Source,
    @ansi_from_utf8_standard,
    @ansi_from_utf8_textconv
    );
end;

procedure RunUtf16Ansi;
const
  TD = 'utf16';
  TS = 'ansi';
var
  Source: IsoLatinString;
begin
  Source := TEST_STRING;
  RunTest(TD, TS, Source,
    @utf16_from_ansi_standard,
    @utf16_from_ansi_textconv
    );
end;

procedure RunUtf16Utf16;
const
  TD = 'utf16';
  TS = 'utf16';
var
  Source: UnicodeString;
begin
  Source := TEST_STRING;
  RunTest(TD, TS, Source,
    @utf16_from_utf16_standard,
    @utf16_from_utf16_textconv, True
    );
end;

procedure RunUtf16Utf8;
const
  TD = 'utf16';
  TS = 'utf8';
var
  Source: UTF8String;
begin
  Source := TEST_STRING;
  RunTest(TD, TS, Source,
    @utf16_from_utf8_standard,
    @utf16_from_utf8_textconv
    );
end;

procedure RunUtf8Ansi;
const
  TD = 'utf8';
  TS = 'ansi';
var
  Source: IsoLatinString;
begin
  Source := TEST_STRING;
  RunTest(TD, TS, Source,
    @utf8_from_ansi_standard,
    @utf8_from_ansi_textconv
    );
end;

procedure RunUtf8Utf16;
const
  TD = 'utf8';
  TS = 'utf16';
var
  Source: UnicodeString;
begin
  Source := TEST_STRING;
  RunTest(TD, TS, Source,
    @utf8_from_utf16_standard,
    @utf8_from_utf16_textconv
    );
end;

procedure RunUtf8Utf8;
const
  TD = 'utf8';
  TS = 'utf8';
var
  Source: UTF8String;
begin
  Source := TEST_STRING;
  RunTest(TD, TS, Source,
    @utf8_from_utf8_standard,
    @utf8_from_utf8_textconv, True
    );
end;


begin
  try
    Writeln('The benchmark shows how you can use convert functions of Tiny.Library');
    Writeln('among the most used encodings: UTF16, UTF8 and Single byte encodings (ANSI).');
    Writeln;
    Writeln('The library contains 169 functions to perform an optional case sensitive');
    Writeln('conversion among many string types (such as PAnsiChar, ShortString,');
    Writeln('WideString, AnsiString, etc), so you''ll find a suitable function easyly.');
    Writeln('To change text register use "upper" and "lower" functions.');
    Writeln;
    Writeln;

    // run string conversion tests
    RunAnsiAnsi;
    RunAnsiUtf16;
    RunAnsiUtf8;
    RunUtf16Ansi;
    RunUtf16Utf16;
    RunUtf16Utf8;
    RunUtf8Ansi;
    RunUtf8Utf16;
    RunUtf8Utf8;

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
