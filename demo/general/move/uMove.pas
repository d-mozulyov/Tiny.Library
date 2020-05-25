unit uMove;

{$I TINY.DEFINES.inc}

interface
uses
  {$if Defined(MSWINDOWS)}
    Windows,
  {$elseif not Defined(FPC)}
    System.Diagnostics, System.TimeSpan,
  {$ifend}
  Tiny.Types,
  SysUtils;


var
  LogProc: procedure(const AMessage: string);

procedure Run;

implementation

procedure Log(const AMessage: string);
begin
  if (Assigned(LogProc)) then
  begin
    LogProc(AMessage);
  end;
end;

procedure LogFmt(const AFmtStr: string; const AArgs: array of const);
begin
  Log(Format(AFmtStr, AArgs));
end;

{$if not Defined(MSWINDOWS) and not Defined(FPC)}
function GetTickCount: Cardinal;
begin
  Result := TStopwatch.GetTimeStamp div TTimeSpan.TicksPerMillisecond;
end;
{$ifend}


const
  BUFFER_SIZE = 1024;

var
  BUFFER_BYTES: array[0..BUFFER_SIZE * 3 + 15] of Byte;
  BUFFER_TARGET, BUFFER_SOURCE, BUFFER_ETHALON: Pointer;

procedure InitBuffers;
var
  i: Integer;
  P: PByte;
begin
  BUFFER_TARGET := Pointer(NativeInt(@BUFFER_BYTES[0 * BUFFER_SIZE + 15]) and -16);
  BUFFER_SOURCE := Pointer(NativeInt(@BUFFER_BYTES[1 * BUFFER_SIZE + 15]) and -16);
  BUFFER_ETHALON := Pointer(NativeInt(@BUFFER_BYTES[2 * BUFFER_SIZE + 15]) and -16);

  Randomize;
  P := BUFFER_ETHALON;
  for i := 1 to BUFFER_SIZE do
  begin
    P^ := Random(256);
    Inc(P);
  end;
end;

function SourcePtr(const AOffset: NativeUInt): Pointer;
begin
  Result := Pointer(NativeUInt(BUFFER_SOURCE) + AOffset);
end;

function TargetPtr(const AOffset: NativeUInt): Pointer;
begin
  Result := Pointer(NativeUInt(BUFFER_TARGET) + AOffset);
end;

function EthalonPtr(const AOffset: NativeUInt): Pointer;
begin
  Result := Pointer(NativeUInt(BUFFER_ETHALON) + AOffset);
end;

function InternalCompare(const ATargetOffset, AEthalonOffset, ASize: NativeUInt): Boolean;
begin
  Result := CompareMem(
    TargetPtr(ATargetOffset),
    EthalonPtr(AEthalonOffset),
    ASize);
end;

procedure InternalValidate(const ASize: NativeInt);
var
  i: Integer;
  T, S, E: PByte;
  LBackwardSize: Integer;
begin
  T := BUFFER_TARGET;
  S := BUFFER_SOURCE;
  E := BUFFER_ETHALON;
  for i := 1 to BUFFER_SIZE do
  begin
    S^ := E^;
    T^ := not E^;
    Inc(E);
    Inc(S);
    Inc(T);
  end;

  TinyMove(BUFFER_SOURCE^, BUFFER_TARGET^, ASize);
  if (not CompareMem(BUFFER_SOURCE, BUFFER_ETHALON, BUFFER_SIZE)) then
  begin
    raise Exception.Create('Source damaged');
  end;
  if (not CompareMem(BUFFER_TARGET, BUFFER_ETHALON, ASize)) then
  begin
    raise Exception.Create('Target not copied');
  end;

  T := BUFFER_TARGET;
  E := BUFFER_ETHALON;
  Inc(T, ASize);
  Inc(E, ASize);
  for i := ASize + 1 to BUFFER_SIZE do
  begin
    if (T^ <> not E^) then
    begin
      raise Exception.CreateFmt('Target[%d] damaged', [i - 1]);
    end;

    Inc(E);
    Inc(T);
  end;

  LBackwardSize := ASize mod 256;
  System.Move(BUFFER_ETHALON^, BUFFER_TARGET^, BUFFER_SIZE);

  TinyMove(BUFFER_TARGET^, BUFFER_TARGET^, LBackwardSize);
  if (not InternalCompare(0, 0, BUFFER_SIZE)) then
  begin
    raise Exception.Create('Same address failue');
  end;

  S := TargetPtr(0);
  T := TargetPtr(LBackwardSize);
  TinyMove(S^, T^, LBackwardSize);
  if (not InternalCompare(0, 0, LBackwardSize)) or
    (not InternalCompare(LBackwardSize, 0, LBackwardSize)) or
    (not InternalCompare(LBackwardSize * 2, LBackwardSize * 2, BUFFER_SIZE - LBackwardSize * 2))
  then
  begin
    raise Exception.Create('None collision');
  end;

  for i := 1 to 16 do
  begin
    System.Move(BUFFER_ETHALON^, BUFFER_TARGET^, BUFFER_SIZE);
    S := TargetPtr(LBackwardSize);
    T := TargetPtr(LBackwardSize + i);
    TinyMove(S^, T^, LBackwardSize);

    if (not InternalCompare(0, 0, LBackwardSize + i)) then
    begin
      raise Exception.Create('Previous damaged');
    end;

    if (not InternalCompare(LBackwardSize + i, LBackwardSize, LBackwardSize)) then
    begin
      raise Exception.Create('Backward not copied');
    end;

    if (not InternalCompare(LBackwardSize * 2 + i, LBackwardSize * 2 + i,
      BUFFER_SIZE - LBackwardSize * 2 - i)) then
    begin
      raise Exception.Create('Following damaged');
    end;
  end;
end;

type
  TRunProc = procedure(const ASource, ATarget: Pointer);

const
  ITERATIONS_BASE = 100000 {$ifdef CPUARM}div 8{$endif};
  ITERATIONS_1 = ITERATIONS_BASE * 330;
  ITERATIONS_8 = ITERATIONS_BASE * 330;
  ITERATIONS_32 = ITERATIONS_BASE * 330;
  ITERATIONS_1024 = ITERATIONS_BASE * 10;

procedure RunSystem1(const ASource, ATarget: Pointer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_1 do
  begin
    System.Move(ASource^, ATarget^, 1);
    System.Move(ASource^, ATarget^, 1);
    System.Move(ASource^, ATarget^, 1);
    System.Move(ASource^, ATarget^, 1);
    System.Move(ASource^, ATarget^, 1);
    System.Move(ASource^, ATarget^, 1);
    System.Move(ASource^, ATarget^, 1);
    System.Move(ASource^, ATarget^, 1);
    System.Move(ASource^, ATarget^, 1);
    System.Move(ASource^, ATarget^, 1);
  end;
end;

procedure RunSystem8(const ASource, ATarget: Pointer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_8 do
  begin
    System.Move(ASource^, ATarget^, 8);
    System.Move(ASource^, ATarget^, 8);
    System.Move(ASource^, ATarget^, 8);
    System.Move(ASource^, ATarget^, 8);
    System.Move(ASource^, ATarget^, 8);
    System.Move(ASource^, ATarget^, 8);
    System.Move(ASource^, ATarget^, 8);
    System.Move(ASource^, ATarget^, 8);
    System.Move(ASource^, ATarget^, 8);
    System.Move(ASource^, ATarget^, 8);
  end;
end;

procedure RunSystem32(const ASource, ATarget: Pointer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_32 do
  begin
    System.Move(ASource^, ATarget^, 32);
    System.Move(ASource^, ATarget^, 32);
    System.Move(ASource^, ATarget^, 32);
    System.Move(ASource^, ATarget^, 32);
    System.Move(ASource^, ATarget^, 32);
    System.Move(ASource^, ATarget^, 32);
    System.Move(ASource^, ATarget^, 32);
    System.Move(ASource^, ATarget^, 32);
    System.Move(ASource^, ATarget^, 32);
    System.Move(ASource^, ATarget^, 32);
  end;
end;

procedure RunSystem1024(const ASource, ATarget: Pointer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_1024 do
  begin
    System.Move(ASource^, ATarget^, 1024);
    System.Move(ASource^, ATarget^, 1024);
    System.Move(ASource^, ATarget^, 1024);
    System.Move(ASource^, ATarget^, 1024);
    System.Move(ASource^, ATarget^, 1024);
    System.Move(ASource^, ATarget^, 1024);
    System.Move(ASource^, ATarget^, 1024);
    System.Move(ASource^, ATarget^, 1024);
    System.Move(ASource^, ATarget^, 1024);
    System.Move(ASource^, ATarget^, 1024);
  end;
end;

procedure RunTiny1(const ASource, ATarget: Pointer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_1 do
  begin
    TinyMove(ASource^, ATarget^, 1);
    TinyMove(ASource^, ATarget^, 1);
    TinyMove(ASource^, ATarget^, 1);
    TinyMove(ASource^, ATarget^, 1);
    TinyMove(ASource^, ATarget^, 1);
    TinyMove(ASource^, ATarget^, 1);
    TinyMove(ASource^, ATarget^, 1);
    TinyMove(ASource^, ATarget^, 1);
    TinyMove(ASource^, ATarget^, 1);
    TinyMove(ASource^, ATarget^, 1);
  end;
end;

procedure RunTiny8(const ASource, ATarget: Pointer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_8 do
  begin
    TinyMove(ASource^, ATarget^, 8);
    TinyMove(ASource^, ATarget^, 8);
    TinyMove(ASource^, ATarget^, 8);
    TinyMove(ASource^, ATarget^, 8);
    TinyMove(ASource^, ATarget^, 8);
    TinyMove(ASource^, ATarget^, 8);
    TinyMove(ASource^, ATarget^, 8);
    TinyMove(ASource^, ATarget^, 8);
    TinyMove(ASource^, ATarget^, 8);
    TinyMove(ASource^, ATarget^, 8);
  end;
end;

procedure RunTiny32(const ASource, ATarget: Pointer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_32 do
  begin
    TinyMove(ASource^, ATarget^, 32);
    TinyMove(ASource^, ATarget^, 32);
    TinyMove(ASource^, ATarget^, 32);
    TinyMove(ASource^, ATarget^, 32);
    TinyMove(ASource^, ATarget^, 32);
    TinyMove(ASource^, ATarget^, 32);
    TinyMove(ASource^, ATarget^, 32);
    TinyMove(ASource^, ATarget^, 32);
    TinyMove(ASource^, ATarget^, 32);
    TinyMove(ASource^, ATarget^, 32);
  end;
end;

procedure RunTiny1024(const ASource, ATarget: Pointer);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_1024 do
  begin
    TinyMove(ASource^, ATarget^, 1024);
    TinyMove(ASource^, ATarget^, 1024);
    TinyMove(ASource^, ATarget^, 1024);
    TinyMove(ASource^, ATarget^, 1024);
    TinyMove(ASource^, ATarget^, 1024);
    TinyMove(ASource^, ATarget^, 1024);
    TinyMove(ASource^, ATarget^, 1024);
    TinyMove(ASource^, ATarget^, 1024);
    TinyMove(ASource^, ATarget^, 1024);
    TinyMove(ASource^, ATarget^, 1024);
  end;
end;

procedure RunProcs(const AName: string; const AProcs: array of TRunProc);
const
  TRY_COUNT = 10 {$ifdef CPUARM}div 3{$endif};
  SIZES: array[0..3] of Integer = (1, 8, 32, 1024);
var
  i, j: Integer;
  S: string;
  LBestTime, LTime: Cardinal;
begin
  Log(AName + '...');

  S := '';
  for i := Low(SIZES) to High(SIZES) do
  begin
    if (S <> '') then
    begin
      S := S + ', ';
    end;
    S := S + IntToStr(SIZES[i]) + ': ';

    LBestTime := High(Cardinal);
    for j := 1 to TRY_COUNT do
    begin
      LTime := GetTickCount;
      AProcs[i](BUFFER_SOURCE, BUFFER_TARGET);
      LTime := GetTickCount - LTime;

      if (LTime < LBestTime) then
      begin
        LBestTime := LTime;
      end;
    end;

    S := S + IntToStr(LBestTime);
  end;

  Log(S);
end;

procedure Run;
var
  i: Integer;
begin
  // validation
  for i := 0 to 255 do
  begin
    InternalValidate(i);
  end;

  // benchmark
  RunProcs('System.Move', [RunSystem1, RunSystem8, RunSystem32, RunSystem1024]);
  Log('');
  RunProcs('TinyMove', [RunTiny1, RunTiny8, RunTiny32, RunTiny1024]);
end;


initialization
  InitBuffers;

end.
