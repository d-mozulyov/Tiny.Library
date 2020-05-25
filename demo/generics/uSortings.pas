unit uSortings;

{$I TINY.DEFINES.inc}

interface
uses
  Winapi.Windows, System.SysUtils, Generics.Defaults, Generics.Collections,
  Tiny.Types, Tiny.Generics;

const
  ITEMS_COUNT = 1000000;

type
  TProc = procedure of object;

  {$M+}
  TTest<T> = class
  public type
    TItems = array[0..ITEMS_COUNT - 1] of T;
    TRandomFunc = reference to function: T;
  public
    Items: TItems;
    SourceItems: TItems;
    Comparison: Generics.Defaults.TComparison<T>;

    constructor Create(const RandomFunc: TRandomFunc; const AComparison: Generics.Defaults.TComparison<T>);
    destructor Destroy; override;
    procedure Run(const SystemTest, TinyTest: TProc; const IterationsCount: Integer;
      const MakeCopy: Boolean = True);

    procedure RunEach;
  published
    procedure SystemSortComparison;
    procedure TinySortComparison;
    procedure SystemSort;
    procedure TinySort;
    procedure SystemSearchComparison;
    procedure TinySearchComparison;
    procedure SystemSearch;
    procedure TinySearch;
  end;
  {$M-}


procedure Run;

implementation


procedure Run;
begin
  with TTest<string>.Create(
    function: string
    var
      Len, i: Integer;
    begin
      Len := 5 + Random(8);
      SetLength(Result, Len);

      for i := 1 to Len do
        Result[i] := Char(Ord('A') + Random(Ord('Z') - Ord('A') + 1));
    end,
    function(const Left, Right: string): Integer
    begin
      Result := CompareStr(Left, Right);
    end) do
  try
    RunEach;
  finally
    Free;
  end;

  with TTest<Single>.Create(
    function: Single
    begin
      Result := Random * ITEMS_COUNT;
    end,
    function(const Left, Right: Single): Integer
    begin
      Result := Shortint(Byte(Left >= Right) - Byte(Left <= Right));
    end) do
  try
    RunEach;
  finally
    Free;
  end;

  with TTest<Integer>.Create(
    function: Integer
    begin
      Result := Random(ITEMS_COUNT);
    end,
    function(const Left, Right: Integer): Integer
    begin
      Result := Shortint(Byte(Left >= Right) - Byte(Left <= Right));
    end) do
  try
    RunEach;
  finally
    Free;
  end;
end;


{ TTest<T> }

constructor TTest<T>.Create(const RandomFunc: TRandomFunc; const AComparison: Generics.Defaults.TComparison<T>);
var
  i: Integer;
begin
  Comparison := AComparison;

  for i := Low(TItems) to High(TItems) do
    SourceItems[i] := RandomFunc;
end;

destructor TTest<T>.Destroy;
begin
  FillChar(Items, SizeOf(Items), #0);
  inherited;
end;

procedure TTest<T>.Run(const SystemTest, TinyTest: TProc; const IterationsCount: Integer;
  const MakeCopy: Boolean);
var
  i: Integer;
  N: Boolean;
  Proc: TProc;
  TotalTime, Time: Cardinal;
begin
  for N := Low(Boolean) to High(Boolean) do
  begin
    Proc := SystemTest;
    if (N = True) then Proc := TinyTest;
    Write(Self.MethodName(TMethod(Proc).Code), '... ');

    TotalTime := 0;
    for i := 1 to IterationsCount do
    begin
      if (MakeCopy) then
      begin
        Move(SourceItems, Items, SizeOf(TItems));
      end;

      Time := GetTickCount;
      Proc;
      Time := GetTickCount - Time;

      Inc(TotalTime, Time);
    end;

    Writeln(TotalTime, 'ms');
  end;
end;

procedure TTest<T>.SystemSortComparison;
begin
  Generics.Collections.TArray.Sort<T>(Items,
    Generics.Defaults.TComparer<T>.Construct(Comparison)
  );
end;

procedure TTest<T>.TinySortComparison;
begin
  Tiny.Generics.TArray.Sort<T>(Items,
    Tiny.Generics.TComparer<T>.Construct(Tiny.Generics.TComparison<T>(Comparison))
  );
end;

procedure TTest<T>.SystemSort;
begin
  Generics.Collections.TArray.Sort<T>(Items);
end;

procedure TTest<T>.TinySort;
begin
  Tiny.Generics.TArray.Sort<T>(Items);
end;

procedure TTest<T>.SystemSearchComparison;
var
  i: NativeInt;
  Index: Integer;
  Found: Boolean;
begin
  for i := Low(Items) to High(Items) do
  begin
    Found := Generics.Collections.TArray.BinarySearch<T>(Items, Items[i],
      Index, Generics.Defaults.TComparer<T>.Construct(Comparison)
    );

    if (not Found) then
      raise Exception.Create('');
  end;
end;

procedure TTest<T>.TinySearchComparison;
var
  i: NativeInt;
  Index: Integer;
  Found: Boolean;
begin
  for i := Low(Items) to High(Items) do
  begin
    Found := Tiny.Generics.TArray.BinarySearch<T>(Items, Items[i],
      Index, Tiny.Generics.TComparer<T>.Construct(Tiny.Generics.TComparison<T>(Comparison))
    );

    if (not Found) then
      raise Exception.Create('');
  end;
end;

procedure TTest<T>.SystemSearch;
var
  i: NativeInt;
  Index: Integer;
  Found: Boolean;
begin
  for i := Low(Items) to High(Items) do
  begin
    Found := Generics.Collections.TArray.BinarySearch<T>(Items, Items[i], Index);

    if (not Found) then
      raise Exception.Create('');
  end;
end;


procedure TTest<T>.TinySearch;
var
  i: NativeInt;
  Index: Integer;
  Found: Boolean;
begin
  for i := Low(Items) to High(Items) do
  begin
    Found := Tiny.Generics.TArray.BinarySearch<T>(Items, Items[i], Index);

    if (not Found) then
      raise Exception.Create('');
  end;
end;

procedure TTest<T>.RunEach;
begin
  Writeln;
  Writeln(PShortString(NativeUInt(TypeInfo(T)) + 1)^);

  Run(SystemSortComparison, TinySortComparison, 5);
  Run(SystemSort, TinySort, 5);
  Run(SystemSearchComparison, TinySearchComparison, 5, False);
  Run(SystemSearch, TinySearch, 5, False);
end;

end.
