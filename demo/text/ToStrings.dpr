program ToStrings;

{$I TINY.DEFINES.inc}
{$APPTYPE CONSOLE}

uses {$ifdef UNITSCOPENAMES}
       Winapi.Windows, System.SysUtils,
     {$else}
       Windows, SysUtils,
     {$endif}
     Tiny.Types, Tiny.Text, Tiny.Cache.Text;


type
  TSysUtilsProc = procedure(var S: string);
  TStringBufferProc = procedure(var S: TStringBuffer);

const
  CONST_BOOLEAN: Boolean = True;
  CONST_INTEGER: Integer = 123456;
  CONST_INT64: Int64 = 9876543210;
  CONST_HEX: Integer = $abcdef;
  CONST_HEX64: Int64 = $012345abcdef;
  CONST_FLOAT: Extended = 768.645;
  CONST_DATE: TDateTime = 42094{2015-03-31};
  CONST_TIME: TDateTime = 0.524259259259259{12:34:56};
  CONST_DATETIME: TDateTime = 42094.524259259259259;

  ITERATIONS_COUNT = 10 * 1000000;


procedure SysUtilsBoolean(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := BoolToStr(CONST_BOOLEAN, True);
  end;
end;

procedure StringBufferBoolean(var S: TStringBuffer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendBoolean(CONST_BOOLEAN);
  end;
end;

procedure SysUtilsInteger(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := IntToStr(CONST_INTEGER);
  end;
end;

procedure StringBufferInteger(var S: TStringBuffer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendInteger(CONST_INTEGER);
  end;
end;

procedure SysUtilsInt64(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := IntToStr(CONST_INT64);
  end;
end;

procedure StringBufferInt64(var S: TStringBuffer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendInt64(CONST_INT64);
  end;
end;

procedure SysUtilsHex(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := IntToHex(CONST_HEX, 0);
  end;
end;

procedure StringBufferHex(var S: TStringBuffer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendHex(CONST_HEX);
  end;
end;

procedure SysUtilsHex64(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := IntToHex(CONST_HEX64, 0);
  end;
end;

procedure StringBufferHex64(var S: TStringBuffer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendHex64(CONST_HEX64);
  end;
end;

procedure SysUtilsFloat(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := FloatToStr(CONST_FLOAT);
  end;
end;

procedure StringBufferFloat(var S: TStringBuffer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendFloat(CONST_FLOAT);
  end;
end;

procedure SysUtilsDate(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := DateToStr(CONST_DATE);
  end;
end;

procedure StringBufferDate(var S: TStringBuffer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendDate(CONST_DATE);
  end;
end;

procedure SysUtilsTime(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := TimeToStr(CONST_TIME);
  end;
end;

procedure StringBufferTime(var S: TStringBuffer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendTime(CONST_TIME);
  end;
end;

procedure SysUtilsDateTime(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := DateTimeToStr(CONST_DATETIME);
  end;
end;

procedure StringBufferDateTime(var S: TStringBuffer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendDateTime(CONST_DATETIME);
  end;
end;


procedure RunTest(const Description: string; const SysUtilsProc: TSysUtilsProc;
  const StringBufferProc: TStringBufferProc);
const
  STRINGTYPES: array[1..3] of string = ('ByteString', 'UTF16String', 'UTF32String');
var
  i: Integer;
  Time: Cardinal;
  Str: string;
  Temp: TStringBuffer;
begin
  Writeln(Description, '...');

  Write('SysUtils', ': ');
  Time := GetTickCount;
    SysUtilsProc(Str);
  Time := GetTickCount - Time;
  Write(Time:5, 'ms; ');

  for i := 1 to 3 do
  begin
    case i of
      1: Temp.InitByteString(CODEPAGE_UTF8);
      2: Temp.InitUTF16String;
      3: Temp.InitUTF32String;
    end;

    Write(STRINGTYPES[i], ': ');
    Time := GetTickCount;
      StringBufferProc(Temp);
    Time := GetTickCount - Time;
    Write(Time:3, 'ms; ');
  end;

  Writeln;
end;

begin
  try
    Writeln('The benchmark shows how to convert Booleans, Ordinals, Floats and DateTimes');
    Writeln('to strings (TStringBuffer) by analogy with SysUtils-functions.');

    // initialize the same (default) format settings
    FormatSettings.ThousandSeparator := #32;
    FormatSettings.DecimalSeparator := '.';
    FormatSettings.DateSeparator := '-';
    FormatSettings.TimeSeparator := ':';
    FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
    FormatSettings.LongTimeFormat := 'hh:mm:ss';

    // run conversion tests
    Writeln;
    RunTest('BooleanToStr', SysUtilsBoolean, StringBufferBoolean);
    RunTest('IntegerToStr', SysUtilsInteger, StringBufferInteger);
    RunTest('Int64ToStr', SysUtilsInt64, StringBufferInt64);
    RunTest('HexToStr', SysUtilsHex, StringBufferHex);
    RunTest('Hex64ToStr', SysUtilsHex64, StringBufferHex64);
    RunTest('FloatToStr', SysUtilsFloat, StringBufferFloat);
    RunTest('DateToStr', SysUtilsDate, StringBufferDate);
    RunTest('TimeToStr', SysUtilsTime, StringBufferTime);
    RunTest('DateTimeToStr', SysUtilsDateTime, StringBufferDateTime);

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
