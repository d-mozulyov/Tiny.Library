program FromStrings;

{$I TINY.DEFINES.inc}
{$APPTYPE CONSOLE}

uses {$ifdef UNITSCOPENAMES}
       Winapi.Windows, System.SysUtils,
     {$else}
       Windows, SysUtils,
     {$endif}
     Tiny.Types, Tiny.Text, Tiny.Cache.Text;


const
  CONST_BOOLEAN = 'True';
  CONST_INTEGER = '123456';
  CONST_INT64 = '9876543210';
  CONST_HEX = 'abcdef';
  CONST_HEX64 = '012345abcdef';
  CONST_FLOAT = '768.645';
  CONST_DATE = '2015-03-31';
  CONST_TIME = '12:34:56';
  CONST_DATETIME = CONST_DATE + ' ' + CONST_TIME;

  ITERATIONS_COUNT = 10 * 1000000;


var
  Result: record
    VBoolean: Boolean;
    VInteger: Integer;
    VInt64: Int64;
    VFloat: Extended;
    VDateTime: TDateTime;
  end;
  UCS4StringBuffer: UCS4String;

function UTF32StringAssign(const Value: WideString): UTF32String;
begin
  UCS4StringBuffer := WideStringToUCS4String(Value);
  Result.Assign(UCS4StringBuffer, True);
end;


procedure SysUtilsToBoolean;
var
  i: Integer;
  S: string;
begin
  S := CONST_BOOLEAN;

  for i := 1 to ITERATIONS_COUNT do
  Result.VBoolean := StrToBool(S);
end;

procedure ByteStringToBoolean;
var
  i: Integer;
  S: ByteString;
begin
  S.Assign(AnsiString(CONST_BOOLEAN));

  for i := 1 to ITERATIONS_COUNT do
  Result.VBoolean := S.ToBoolean;
end;

procedure UTF16StringToBoolean;
var
  i: Integer;
  S: UTF16String;
begin
  S.Assign(UnicodeString(CONST_BOOLEAN));

  for i := 1 to ITERATIONS_COUNT do
  Result.VBoolean := S.ToBoolean;
end;

procedure UTF32StringToBoolean;
var
  i: Integer;
  S: UTF32String;
begin
  S := UTF32StringAssign(CONST_BOOLEAN);

  for i := 1 to ITERATIONS_COUNT do
  Result.VBoolean := S.ToBoolean;
end;

procedure SysUtilsToInteger;
var
  i: Integer;
  S: string;
begin
  S := CONST_INTEGER;

  for i := 1 to ITERATIONS_COUNT do
  Result.VInteger := StrToInt(S);
end;

procedure ByteStringToInteger;
var
  i: Integer;
  S: ByteString;
begin
  S.Assign(AnsiString(CONST_INTEGER));

  for i := 1 to ITERATIONS_COUNT do
  Result.VInteger := S.ToInteger;
end;

procedure UTF16StringToInteger;
var
  i: Integer;
  S: UTF16String;
begin
  S.Assign(UnicodeString(CONST_INTEGER));

  for i := 1 to ITERATIONS_COUNT do
  Result.VInteger := S.ToInteger;
end;

procedure UTF32StringToInteger;
var
  i: Integer;
  S: UTF32String;
begin
  S := UTF32StringAssign(CONST_INTEGER);

  for i := 1 to ITERATIONS_COUNT do
  Result.VInteger := S.ToInteger;
end;

procedure SysUtilsToInt64;
var
  i: Integer;
  S: string;
begin
  S := CONST_INT64;

  for i := 1 to ITERATIONS_COUNT do
  Result.VInt64 := StrToInt64(S);
end;

procedure ByteStringToInt64;
var
  i: Integer;
  S: ByteString;
begin
  S.Assign(AnsiString(CONST_INT64));

  for i := 1 to ITERATIONS_COUNT do
  Result.VInt64 := S.ToInt64;
end;

procedure UTF16StringToInt64;
var
  i: Integer;
  S: UTF16String;
begin
  S.Assign(UnicodeString(CONST_INT64));

  for i := 1 to ITERATIONS_COUNT do
  Result.VInt64 := S.ToInt64;
end;

procedure UTF32StringToInt64;
var
  i: Integer;
  S: UTF32String;
begin
  S := UTF32StringAssign(CONST_INT64);

  for i := 1 to ITERATIONS_COUNT do
  Result.VInt64 := S.ToInt64;
end;

procedure SysUtilsToHex;
var
  i: Integer;
  S: string;
begin
  S := '$' + CONST_HEX;

  for i := 1 to ITERATIONS_COUNT do
  Result.VInteger := StrToInt(S);
end;

procedure ByteStringToHex;
var
  i: Integer;
  S: ByteString;
begin
  S.Assign(AnsiString(CONST_HEX));

  for i := 1 to ITERATIONS_COUNT do
  Result.VInteger := S.ToHex;
end;

procedure UTF16StringToHex;
var
  i: Integer;
  S: UTF16String;
begin
  S.Assign(UnicodeString(CONST_HEX));

  for i := 1 to ITERATIONS_COUNT do
  Result.VInteger := S.ToHex;
end;

procedure UTF32StringToHex;
var
  i: Integer;
  S: UTF32String;
begin
  S := UTF32StringAssign(CONST_HEX);

  for i := 1 to ITERATIONS_COUNT do
  Result.VInteger := S.ToHex;
end;

procedure SysUtilsToHex64;
var
  i: Integer;
  S: string;
begin
  S := '$' + CONST_HEX64;

  for i := 1 to ITERATIONS_COUNT do
  Result.VInt64 := StrToInt64(S);
end;

procedure ByteStringToHex64;
var
  i: Integer;
  S: ByteString;
begin
  S.Assign(AnsiString(CONST_HEX64));

  for i := 1 to ITERATIONS_COUNT do
  Result.VInt64 := S.ToHex64;
end;

procedure UTF16StringToHex64;
var
  i: Integer;
  S: UTF16String;
begin
  S.Assign(UnicodeString(CONST_HEX64));

  for i := 1 to ITERATIONS_COUNT do
  Result.VInt64 := S.ToHex64;
end;

procedure UTF32StringToHex64;
var
  i: Integer;
  S: UTF32String;
begin
  S := UTF32StringAssign(CONST_HEX64);

  for i := 1 to ITERATIONS_COUNT do
  Result.VInt64 := S.ToHex64;
end;

procedure SysUtilsToFloat;
var
  i: Integer;
  S: string;
begin
  S := CONST_FLOAT;

  for i := 1 to ITERATIONS_COUNT do
  Result.VFloat := StrToFloat(S);
end;

procedure ByteStringToFloat;
var
  i: Integer;
  S: ByteString;
begin
  S.Assign(AnsiString(CONST_FLOAT));

  for i := 1 to ITERATIONS_COUNT do
  Result.VFloat := S.ToFloat;
end;

procedure UTF16StringToFloat;
var
  i: Integer;
  S: UTF16String;
begin
  S.Assign(UnicodeString(CONST_FLOAT));

  for i := 1 to ITERATIONS_COUNT do
  Result.VFloat := S.ToFloat;
end;

procedure UTF32StringToFloat;
var
  i: Integer;
  S: UTF32String;
begin
  S := UTF32StringAssign(CONST_FLOAT);

  for i := 1 to ITERATIONS_COUNT do
  Result.VFloat := S.ToFloat;
end;

procedure SysUtilsToDate;
var
  i: Integer;
  S: string;
begin
  S := CONST_DATE;

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := StrToDate(S);
end;

procedure ByteStringToDate;
var
  i: Integer;
  S: ByteString;
begin
  S.Assign(AnsiString(CONST_DATE));

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := S.ToDate;
end;

procedure UTF16StringToDate;
var
  i: Integer;
  S: UTF16String;
begin
  S.Assign(UnicodeString(CONST_DATE));

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := S.ToDate;
end;

procedure UTF32StringToDate;
var
  i: Integer;
  S: UTF32String;
begin
  S := UTF32StringAssign(CONST_DATE);

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := S.ToDate;
end;

procedure SysUtilsToTime;
var
  i: Integer;
  S: string;
begin
  S := CONST_TIME;

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := StrToTime(S);
end;

procedure ByteStringToTime;
var
  i: Integer;
  S: ByteString;
begin
  S.Assign(AnsiString(CONST_TIME));

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := S.ToTime;
end;

procedure UTF16StringToTime;
var
  i: Integer;
  S: UTF16String;
begin
  S.Assign(UnicodeString(CONST_TIME));

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := S.ToTime;
end;

procedure UTF32StringToTime;
var
  i: Integer;
  S: UTF32String;
begin
  S := UTF32StringAssign(CONST_TIME);

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := S.ToTime;
end;

procedure SysUtilsToDateTime;
var
  i: Integer;
  S: string;
begin
  S := CONST_DATETIME;

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := StrToDateTime(S);
end;

procedure ByteStringToDateTime;
var
  i: Integer;
  S: ByteString;
begin
  S.Assign(AnsiString(CONST_DATETIME));

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := S.ToDateTime;
end;

procedure UTF16StringToDateTime;
var
  i: Integer;
  S: UTF16String;
begin
  S.Assign(UnicodeString(CONST_DATETIME));

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := S.ToDateTime;
end;

procedure UTF32StringToDateTime;
var
  i: Integer;
  S: UTF32String;
begin
  S := UTF32StringAssign(CONST_DATETIME);

  for i := 1 to ITERATIONS_COUNT do
  Result.VDateTime := S.ToDateTime;
end;


procedure MeasureProcTime(const Name: string; const Proc: TProcedure;
  const TimeWidth: Integer = 3);
var
  Time: Cardinal;
begin
  Write(Name, ': ');
  begin
    Time := GetTickCount;
      Proc;
    Time := GetTickCount - Time;
  end;
  Write(Time:TimeWidth, 'ms; ');
end;

procedure RunTest(const Description: string;
  const SysUtilsProc, ByteStringProc, UTF16StringProc, UTF32StringProc: TProcedure);
begin
  Writeln(Description, '...');

  MeasureProcTime('SysUtils', SysUtilsProc, 5);
  MeasureProcTime('ByteString', ByteStringProc);
  MeasureProcTime('UTF16String', UTF16StringProc);
  MeasureProcTime('UTF32String', UTF32StringProc);

  Writeln;
end;

begin
  try
    Writeln('The benchmark shows how to convert character data to');
    Writeln('Booleans, Ordinals, Floats and DateTimes by analogy with SysUtils-functions.');

    // initialize the same (default) format settings
    FormatSettings.ThousandSeparator := #32;
    FormatSettings.DecimalSeparator := '.';
    FormatSettings.DateSeparator := '-';
    FormatSettings.TimeSeparator := ':';
    FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
    FormatSettings.LongTimeFormat := 'hh:mm:ss';

    // run conversion tests
    Writeln;
    RunTest('StrToBoolean', SysUtilsToBoolean, ByteStringToBoolean, UTF16StringToBoolean, UTF32StringToBoolean);
    RunTest('StrToInteger', SysUtilsToInteger, ByteStringToInteger, UTF16StringToInteger, UTF32StringToInteger);
    RunTest('StrToInt64', SysUtilsToInt64, ByteStringToInt64, UTF16StringToInt64, UTF32StringToInt64);
    RunTest('StrToHex', SysUtilsToHex, ByteStringToHex, UTF16StringToHex, UTF32StringToHex);
    RunTest('StrToHex64', SysUtilsToHex64, ByteStringToHex64, UTF16StringToHex64, UTF32StringToHex64);
    RunTest('StrToFloat', SysUtilsToFloat, ByteStringToFloat, UTF16StringToFloat, UTF32StringToFloat);
    RunTest('StrToDate', SysUtilsToDate, ByteStringToDate, UTF16StringToDate, UTF32StringToDate);
    RunTest('StrToTime', SysUtilsToTime, ByteStringToTime, UTF16StringToTime, UTF32StringToTime);
    RunTest('StrToDateTime', SysUtilsToDateTime, ByteStringToDateTime, UTF16StringToDateTime, UTF32StringToDateTime);

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
