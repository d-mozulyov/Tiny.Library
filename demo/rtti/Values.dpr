program Values;

{$APPTYPE CONSOLE}
{$I TINY.DEFINES.inc}

uses
  System.SysUtils,
  System.Rtti,
  System.Typinfo,
  System.Diagnostics,
  System.Generics.Collections,
  System.Math,
  OtlCommon,
  Cromis.AnyValue,
  Tiny.Types,
  Tiny.Rtti;

const
  BENCHMARK_COUNT = 5;
  ITERATION_COUNT = 100000;
  TRY_COUNT = 10;

type
  {$M+}
  TBenchmark = class
  protected
    FStopwatch: TStopwatch;
    FStdValue: System.Rtti.TValue;
    FOmniValue: TOmniValue;
    FAnyValue: TAnyValue;
    FTinyValue: Tiny.Rtti.TValue;
    FTimes: array[1..BENCHMARK_COUNT] of Int64;

    VBoolean: Boolean;
    VInteger: Integer;
    VInt64: Int64;
    VSingle: Single;
    VExtended: Extended;
    VAnsiString: AnsiString;
    VUnicodeString: UnicodeString;
    VInterface: IInterface;
    VDynamicArray: TBytes;

    procedure TimeStart; inline;
    procedure TimeStop(const AIndex: Integer); inline;
  public
    constructor Create;
    procedure Run;
  published
    procedure RunBoolean;
    procedure RunInteger;
    procedure RunInt64;
    procedure RunSingle;
    procedure RunExtended;
    procedure RunAnsiString;
    procedure RunUnicodeString;
    procedure RunInterface;
    procedure RunDynamicArray;
  end;
  {$M-}


{ TBenchmark }

constructor TBenchmark.Create;
begin
  inherited Create;

  VBoolean := Boolean(Random(2));
  VInteger := Random(1000);
  VInt64 := Random(1000000);
  VSingle := 1000 * Random;
  VExtended := 1000000 * Random;
  VAnsiString := 'Test AnsiString';
  VUnicodeString := 'Test UnicodeString';
  VInterface := TInterfacedObject.Create;
  SetLength(VDynamicArray, 1 + Random(10));
end;

procedure TBenchmark.TimeStart;
begin
  FStopwatch := TStopwatch.StartNew;
end;

procedure TBenchmark.TimeStop(const AIndex: Integer);
begin
  FTimes[AIndex] := FStopwatch.ElapsedTicks;
end;

procedure TBenchmark.Run;
const
  BENCHMARK_NAMES: array[1..BENCHMARK_COUNT] of string = (
    'System.Rtti.TValue',
    'TOmniValue',
    'TAnyValue',
    'Tiny.Rtti.TValue',
    'Tiny.Rtti.TValue+As');
  COLUMN_WIDTH = 19;
  COLON = '|';
var
  i, j, k: Integer;
  LLine: string;
  LBenchmarkFunc: procedure of object;
  LTypeData: Tiny.Rtti.PTypeData;
  LMethodTable: PVmtMethodTable;
  LMethodEntry: PVmtMethodEntry;
  LName: string;
  LTimes: array[1..BENCHMARK_COUNT] of Int64;

  procedure WriteTitle(const ATitle: string);
  var
    LSpaces: Integer;
  begin
    LSpaces := Max(0, COLUMN_WIDTH - Length(ATitle));
    Write('':(LSpaces shr 1), ATitle, '':(LSpaces - (LSpaces shr 1)));
  end;
begin
  // header
  LLine := StringOfChar('-', (COLUMN_WIDTH + 1) * (BENCHMARK_COUNT + 1));
  Writeln;
  Writeln(LLine);
  WriteTitle('Name');
  Write(COLON);
  for i := Low(BENCHMARK_NAMES) to High(BENCHMARK_NAMES) do
  begin
    WriteTitle(BENCHMARK_NAMES[i]);
    Write(COLON);
  end;
  Writeln;
  Writeln(LLine);

  // benchmarks
  LBenchmarkFunc := Run;
  LTypeData := Tiny.Rtti.PTypeInfo(TypeInfo(TBenchmark)).TypeData;
  LMethodTable := LTypeData.ClassData.MethodTable;
  LMethodEntry := @LMethodTable.Entries;
  for i := 0 to Integer(LMethodTable.Count) - 1 do
  begin
    // name, code address
    LName := Copy(LMethodEntry.Name.AsString, 4, MaxInt);
    Write(LName, '':(COLUMN_WIDTH - Length(LName)), COLON);
    TMethod(LBenchmarkFunc).Code := LMethodEntry.CodeAddress;

    // clear times
    for j := Low(LTimes) to High(LTimes) do
    begin
      LTimes[j] := High(Int64);;
    end;

    // choose minimal times
    for k := 1 to TRY_COUNT do
    begin
      LBenchmarkFunc();

      for j := Low(LTimes) to High(LTimes) do
      begin
        if (LTimes[j] > FTimes[j]) then
        begin
          LTimes[j] := FTimes[j];
        end;
      end;
    end;

    // print times
    for j := Low(LTimes) to High(LTimes) do
    begin
      if (LTimes[j] = High(Int64)) then
      begin
        WriteTitle('---');
        Write(COLON);
      end else
      begin
        Write(LTimes[j]:COLUMN_WIDTH, COLON);
      end;
    end;
    Writeln;
    Writeln(LLine);
    LMethodEntry := LMethodEntry.Tail;
  end;
end;

procedure TBenchmark.RunBoolean;
var
  i: NativeInt;
begin
  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FStdValue := VBoolean;
    VBoolean := FStdValue.AsType<Boolean>;
  end;
  TimeStop(1);
  FStdValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FOmniValue := VBoolean;
    VBoolean := FOmniValue;
  end;
  TimeStop(2);
  FOmniValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FAnyValue := VBoolean;
    VBoolean := FAnyValue;
  end;
  TimeStop(3);
  FAnyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue := VBoolean;
    VBoolean := FTinyValue;
  end;
  TimeStop(4);
  FTinyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue.AsBoolean := VBoolean;
    VBoolean := FTinyValue.AsBoolean;
  end;
  TimeStop(5);
  FTinyValue := 0;
end;

procedure TBenchmark.RunInteger;
var
  i: NativeInt;
begin
  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FStdValue := VInteger;
    VInteger := FStdValue.AsType<Integer>;
  end;
  TimeStop(1);
  FStdValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FOmniValue := VInteger;
    VInteger := FOmniValue;
  end;
  TimeStop(2);
  FOmniValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FAnyValue := VInteger;
    VInteger := FAnyValue;
  end;
  TimeStop(3);
  FAnyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue := VInteger;
    VInteger := FTinyValue;
  end;
  TimeStop(4);
  FTinyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue.AsInteger := VInteger;
    VInteger := FTinyValue.AsInteger;
  end;
  TimeStop(5);
  FTinyValue := 0;
end;

procedure TBenchmark.RunInt64;
var
  i: NativeInt;
begin
  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FStdValue := VInt64;
    VInt64 := FStdValue.AsType<Int64>;
  end;
  TimeStop(1);
  FStdValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FOmniValue := VInt64;
    VInt64 := FOmniValue;
  end;
  TimeStop(2);
  FOmniValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FAnyValue := VInt64;
    VInt64 := FAnyValue;
  end;
  TimeStop(3);
  FAnyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue := VInt64;
    VInt64 := FTinyValue;
  end;
  TimeStop(4);
  FTinyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue.AsInt64 := VInt64;
    VInt64 := FTinyValue.AsInt64;
  end;
  TimeStop(5);
  FTinyValue := 0;
end;

procedure TBenchmark.RunSingle;
var
  i: NativeInt;
  VDouble: Double;
begin
  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FStdValue := VSingle;
    VSingle := FStdValue.AsType<Single>;
  end;
  TimeStop(1);
  FStdValue := 0;

  TimeStart;
  VDouble := VSingle;
  for i := 1 to ITERATION_COUNT do
  begin
    FOmniValue := VDouble;
    VDouble := FOmniValue;
  end;
  TimeStop(2);
  FOmniValue := 0;

  TimeStart;
  VDouble := VSingle;
  for i := 1 to ITERATION_COUNT do
  begin
    FAnyValue := VDouble;
    VDouble := FAnyValue;
  end;
  VSingle := VDouble;
  TimeStop(3);
  FAnyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue := VSingle;
    VSingle := FTinyValue;
  end;
  TimeStop(4);
  FTinyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue.AsSingle := VSingle;
    VSingle := FTinyValue.AsSingle;
  end;
  TimeStop(5);
  FTinyValue := 0;
end;

procedure TBenchmark.RunExtended;
var
  i: NativeInt;
begin
  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FStdValue := VExtended;
    VExtended := FStdValue.AsType<Extended>;
  end;
  TimeStop(1);
  FStdValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FOmniValue := VExtended;
    VExtended := FOmniValue;
  end;
  TimeStop(5);
  FOmniValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FAnyValue := VExtended;
    VExtended := FAnyValue;
  end;
  TimeStop(3);
  FAnyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue := VExtended;
    VExtended := FTinyValue;
  end;
  TimeStop(4);
  FTinyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue.AsExtended := VExtended;
    VExtended := FTinyValue.AsExtended;
  end;
  TimeStop(5);
  FTinyValue := 0;
end;

procedure TBenchmark.RunAnsiString;
var
  i: NativeInt;
begin
  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FStdValue := System.Rtti.TValue.From<AnsiString>(VAnsiString);
    VAnsiString := FStdValue.AsType<AnsiString>;
  end;
  TimeStop(1);
  FStdValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FOmniValue := VAnsiString;
    VAnsiString := FOmniValue;
  end;
  TimeStop(2);
  FOmniValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FAnyValue := VAnsiString;
    VAnsiString := FAnyValue;
  end;
  TimeStop(3);
  FAnyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue := VAnsiString;
    VAnsiString := FTinyValue;
  end;
  TimeStop(4);
  FTinyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue.AsAnsiString := VAnsiString;
    VAnsiString := FTinyValue.AsAnsiString;
  end;
  TimeStop(5);
  FTinyValue := 0;
end;

procedure TBenchmark.RunUnicodeString;
var
  i: NativeInt;
begin
  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FStdValue := VUnicodeString;
    VUnicodeString := FStdValue.AsType<UnicodeString>;
  end;
  TimeStop(1);
  FStdValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FOmniValue := VUnicodeString;
    VUnicodeString := FOmniValue;
  end;
  TimeStop(2);
  FOmniValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FAnyValue := VUnicodeString;
    VUnicodeString := FAnyValue;
  end;
  TimeStop(3);
  FAnyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue := VUnicodeString;
    VUnicodeString := FTinyValue;
  end;
  TimeStop(4);
  FTinyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue.AsUnicodeString := VUnicodeString;
    VUnicodeString := FTinyValue.AsUnicodeString;
  end;
  TimeStop(5);
  FTinyValue := 0;
end;

procedure TBenchmark.RunInterface;
var
  i: NativeInt;
begin
  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FStdValue := System.Rtti.TValue.From<IInterface>(VInterface);
    VInterface := FStdValue.AsType<IInterface>;
  end;
  TimeStop(1);
  FStdValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FOmniValue := VInterface;
    VInterface := FOmniValue;
  end;
  TimeStop(2);
  FOmniValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FAnyValue := VInterface;
    VInterface := FAnyValue;
  end;
  TimeStop(3);
  FAnyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue := VInterface;
    VInterface := FTinyValue;
  end;
  TimeStop(4);
  FTinyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue.AsInterface := VInterface;
    VInterface := FTinyValue.AsInterface;
  end;
  TimeStop(5);
  FTinyValue := 0;
end;

procedure TBenchmark.RunDynamicArray;
var
  i: NativeInt;
begin
  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FStdValue := System.Rtti.TValue.From<TBytes>(VDynamicArray);
    VDynamicArray := FStdValue.AsType<TBytes>;
  end;
  TimeStop(1);
  FStdValue := 0;

  FTimes[2] := High(Int64);
  FTimes[3] := High(Int64);

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue := VDynamicArray;
    VDynamicArray := FTinyValue;
  end;
  TimeStop(4);
  FTinyValue := 0;

  TimeStart;
  for i := 1 to ITERATION_COUNT do
  begin
    FTinyValue.AsBytes := VDynamicArray;
    VDynamicArray := FTinyValue.AsBytes;
  end;
  TimeStop(5);
  FTinyValue := 0;
end;


var
  Benchmark: TBenchmark;

begin
  ReportMemoryLeaksOnShutdown := True;

  try
    Benchmark := TBenchmark.Create;
    try
      Benchmark.Run;
    finally
      Benchmark.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  Writeln;
  Write('Press Enter to quit');
  Readln;

  System.IsConsole := False;
end.
