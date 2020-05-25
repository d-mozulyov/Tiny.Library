unit uContainers;

{$I TINY.DEFINES.inc}

interface
uses
  Winapi.Windows, System.SysUtils, Generics.Defaults, Generics.Collections,
  Tiny.Types, Tiny.Generics;

type
  T = Integer;

const
  ITEMS_COUNT = 1000000;

var
  ITEMS: array[0..ITEMS_COUNT - 1] of T;

type
  TTest = class
  public
    constructor Create; virtual; abstract;
    procedure FillContainer(const UseCapacity: Boolean); virtual; abstract;
    procedure Prepare; virtual; abstract;
    function Execute: T; virtual; abstract;

    class procedure Run(const IterationsCount: Integer);
  end;
  TTestClass = class of TTest;

  TSystemListTest = class(TTest)
  public
    List: Generics.Collections.TList<T>;

    constructor Create; override;
    destructor Destroy; override;
    procedure FillContainer(const UseCapacity: Boolean); override;
    procedure Prepare; override;
  end;

  TTinyListTest = class(TTest)
  public
    List: Tiny.Generics.TList<T>;

    constructor Create; override;
    destructor Destroy; override;
    procedure FillContainer(const UseCapacity: Boolean); override;
    procedure Prepare; override;
  end;

  TSystemStackTest = class(TTest)
  public
    Stack: Generics.Collections.TStack<T>;

    constructor Create; override;
    destructor Destroy; override;
    procedure FillContainer(const UseCapacity: Boolean); override;
    procedure Prepare; override;
  end;

  TTinyStackTest = class(TTest)
  public
    Stack: Tiny.Generics.TStack<T>;

    constructor Create; override;
    destructor Destroy; override;
    procedure FillContainer(const UseCapacity: Boolean); override;
    procedure Prepare; override;
  end;

  TSystemQueueTest = class(TTest)
  public
    Queue: Generics.Collections.TQueue<T>;

    constructor Create; override;
    destructor Destroy; override;
    procedure FillContainer(const UseCapacity: Boolean); override;
    procedure Prepare; override;
  end;

  TTinyQueueTest = class(TTest)
  public
    Queue: Tiny.Generics.TQueue<T>;

    constructor Create; override;
    destructor Destroy; override;
    procedure FillContainer(const UseCapacity: Boolean); override;
    procedure Prepare; override;
  end;

  SystemListAdd = class(TSystemListTest)
    procedure Prepare; override;
    function Execute: T; override;
  end;

  TinyListAdd = class(TTinyListTest)
    procedure Prepare; override;
    function Execute: T; override;
  end;

  SystemListAdd_Capacity = class(TSystemListTest)
    procedure Prepare; override;
    function Execute: T; override;
  end;

  TinyListAdd_Capacity = class(TTinyListTest)
    procedure Prepare; override;
    function Execute: T; override;
  end;

  SystemListItems = class(TSystemListTest)
    function Execute: T; override;
  end;

  TinyListItems = class(TTinyListTest)
    function Execute: T; override;
  end;

  SystemListDelete = class(TSystemListTest)
    function Execute: T; override;
  end;

  TinyListDelete = class(TTinyListTest)
    function Execute: T; override;
  end;

  SystemListIndexOf = class(TSystemListTest)
    function Execute: T; override;
  end;

  TinyListIndexOf = class(TTinyListTest)
    function Execute: T; override;
  end;

  SystemListReverse = class(TSystemListTest)
    constructor Create; override;
    procedure Prepare; override;
    function Execute: T; override;
  end;

  TinyListReverse = class(TTinyListTest)
    constructor Create; override;
    procedure Prepare; override;
    function Execute: T; override;
  end;

  SystemListPack = class(TSystemListTest)
    function Execute: T; override;
  end;

  TinyListPack = class(TTinyListTest)
    function Execute: T; override;
  end;

  SystemStackPush = class(TSystemStackTest)
    function Execute: T; override;
  end;

  TinyStackPush = class(TTinyStackTest)
    function Execute: T; override;
  end;

  SystemStackPush_Capacity = class(TSystemStackTest)
    function Execute: T; override;
  end;

  TinyStackPush_Capacity = class(TTinyStackTest)
    function Execute: T; override;
  end;

  SystemStackPop = class(TSystemStackTest)
    procedure Prepare; override;
    function Execute: T; override;
  end;

  TinyStackPop = class(TTinyStackTest)
    procedure Prepare; override;
    function Execute: T; override;
  end;

  SystemQueueEnqueue = class(TSystemQueueTest)
    function Execute: T; override;
  end;

  TinyQueueEnqueue = class(TTinyQueueTest)
    function Execute: T; override;
  end;

  SystemQueueEnqueue_Capacity = class(TSystemQueueTest)
    function Execute: T; override;
  end;

  TinyQueueEnqueue_Capacity = class(TTinyQueueTest)
    function Execute: T; override;
  end;

  SystemQueueDequeue = class(TSystemQueueTest)
    procedure Prepare; override;
    function Execute: T; override;
  end;

  TinyQueueDequeue = class(TTinyQueueTest)
    procedure Prepare; override;
    function Execute: T; override;
  end;


procedure Run;

implementation


procedure FillItems;
var
  i: Integer;
begin
  RandSeed := 0;

  for i := Low(ITEMS) to High(ITEMS) do
    ITEMS[i] := 1 + Random(ITEMS_COUNT - 1);

  for i := 1 to 20 do
    ITEMS[Random(ITEMS_COUNT)] := Default(T);
end;

procedure InternalRun(const SystemTest, TinyTest: TTestClass; const IterationsCount: Integer);
begin
  SystemTest.Run(IterationsCount);
  TinyTest.Run(IterationsCount);
end;

procedure Run;
begin
  FillItems;

  InternalRun(SystemListAdd, TinyListAdd, 300);
  InternalRun(SystemListAdd_Capacity, TinyListAdd_Capacity, 300);
  InternalRun(SystemListItems, TinyListItems, 1000);
  InternalRun(SystemListDelete, TinyListDelete, 500);
  InternalRun(SystemListIndexOf, TinyListIndexOf, 1000);
  InternalRun(SystemListReverse, TinyListReverse, 8000);
  InternalRun(SystemListPack, TinyListPack, 500);
  InternalRun(SystemStackPush, TinyStackPush, 300);
  InternalRun(SystemStackPush_Capacity, TinyStackPush_Capacity, 300);
  InternalRun(SystemStackPop, TinyStackPop, 500);
  InternalRun(SystemQueueEnqueue, TinyQueueEnqueue, 300);
  InternalRun(SystemQueueEnqueue_Capacity, TinyQueueEnqueue_Capacity, 300);
  InternalRun(SystemQueueDequeue, TinyQueueDequeue, 500);
end;


{ TTest }

class procedure TTest.Run(const IterationsCount: Integer);
var
  i: Integer;
  TotalTime, Time: Cardinal;
  Instance: TTest;
begin
  Write(Self.ClassName, '... ');

  TotalTime := 0;
  Instance := Self.Create;
  try
    for i := 1 to IterationsCount do
    begin
      Instance.Prepare;

      Time := GetTickCount;
      Instance.Execute;
      Time := GetTickCount - Time;

      Inc(TotalTime, Time);
    end;
  finally
    Instance.Free;
  end;

  Writeln(TotalTime, 'ms');
end;

{ TSystemListTest }

constructor TSystemListTest.Create;
begin
  List := Generics.Collections.TList<T>.Create;
end;

destructor TSystemListTest.Destroy;
begin
  List.Free;
  inherited;
end;

procedure TSystemListTest.FillContainer(const UseCapacity: Boolean);
var
  i: Integer;
begin
  List.Clear;
  if (UseCapacity) then List.Capacity := ITEMS_COUNT;

  for i := 0 to ITEMS_COUNT - 1 do
    List.Add(ITEMS[i]);
end;

procedure TSystemListTest.Prepare;
begin
  FillContainer(True);
end;

{ TTinyListTest }

constructor TTinyListTest.Create;
begin
  List := Tiny.Generics.TList<T>.Create;
end;

destructor TTinyListTest.Destroy;
begin
  List.Free;
  inherited;
end;

procedure TTinyListTest.FillContainer(const UseCapacity: Boolean);
var
  i: Integer;
begin
  List.Clear;
  if (UseCapacity) then List.Capacity := ITEMS_COUNT;

  for i := 0 to ITEMS_COUNT - 1 do
    List.Add(ITEMS[i]);
end;

procedure TTinyListTest.Prepare;
begin
  FillContainer(True);
end;

{ TSystemStackTest }

constructor TSystemStackTest.Create;
begin
  Stack := Generics.Collections.TStack<T>.Create;
end;

destructor TSystemStackTest.Destroy;
begin
  Stack.Free;
  inherited;
end;

procedure TSystemStackTest.FillContainer(const UseCapacity: Boolean);
var
  i: Integer;
begin
  Stack.Clear;
  if (UseCapacity) then Stack.Capacity := ITEMS_COUNT;

  for i := 0 to ITEMS_COUNT - 1 do
    Stack.Push(ITEMS[i]);
end;

procedure TSystemStackTest.Prepare;
begin
  Stack.Clear;
end;

{ TTinyStackTest }

constructor TTinyStackTest.Create;
begin
  Stack := Tiny.Generics.TStack<T>.Create;
end;

destructor TTinyStackTest.Destroy;
begin
  Stack.Free;
  inherited;
end;

procedure TTinyStackTest.FillContainer(const UseCapacity: Boolean);
var
  i: Integer;
begin
  Stack.Clear;
  if (UseCapacity) then Stack.Capacity := ITEMS_COUNT;

  for i := 0 to ITEMS_COUNT - 1 do
    Stack.Push(ITEMS[i]);
end;

procedure TTinyStackTest.Prepare;
begin
  Stack.Clear;
end;

{ TSystemQueueTest }

constructor TSystemQueueTest.Create;
begin
  Queue := Generics.Collections.TQueue<T>.Create;
end;

destructor TSystemQueueTest.Destroy;
begin
  Queue.Free;
  inherited;
end;

procedure TSystemQueueTest.FillContainer(const UseCapacity: Boolean);
var
  i: Integer;
begin
  Queue.Clear;
  if (UseCapacity) then Queue.Capacity := ITEMS_COUNT;

  for i := 0 to ITEMS_COUNT - 1 do
    Queue.Enqueue(ITEMS[i]);
end;

procedure TSystemQueueTest.Prepare;
begin
  Queue.Clear;
end;

{ TTinyQueueTest }

constructor TTinyQueueTest.Create;
begin
  Queue := Tiny.Generics.TQueue<T>.Create;
end;

destructor TTinyQueueTest.Destroy;
begin
  Queue.Free;
  inherited;
end;

procedure TTinyQueueTest.FillContainer(const UseCapacity: Boolean);
var
  i: Integer;
begin
  Queue.Clear;
  if (UseCapacity) then Queue.Capacity := ITEMS_COUNT;

  for i := 0 to ITEMS_COUNT - 1 do
    Queue.Enqueue(ITEMS[i]);
end;

procedure TTinyQueueTest.Prepare;
begin
  Queue.Clear;
end;

{ SystemListAdd }

procedure SystemListAdd.Prepare;
begin
  List.Clear;
end;

function SystemListAdd.Execute: T;
begin
  FillContainer(False);
  Result := Default(T);
end;

{ TinyListAdd }

procedure TinyListAdd.Prepare;
begin
  List.Clear;
end;

function TinyListAdd.Execute: T;
begin
  FillContainer(False);
  Result := Default(T);
end;

{ SystemListAdd_Capacity }

procedure SystemListAdd_Capacity.Prepare;
begin
  List.Clear;
end;

function SystemListAdd_Capacity.Execute: T;
begin
  FillContainer(True);
  Result := Default(T);
end;

{ TinyListAdd_Capacity }

procedure TinyListAdd_Capacity.Prepare;
begin
  List.Clear;
end;

function TinyListAdd_Capacity.Execute: T;
begin
  FillContainer(True);
  Result := Default(T);
end;

{ SystemListItems }

function SystemListItems.Execute: T;
var
  i: Integer;
begin
  for i := 0 to ITEMS_COUNT - 1 do
    Result := List[i];
end;

{ TinyListItems }

function TinyListItems.Execute: T;
var
  i: Integer;
begin
  for i := 0 to ITEMS_COUNT - 1 do
    Result := List[i];
end;

{ SystemListDelete }

function SystemListDelete.Execute: T;
var
  i: Integer;
begin
  for i := ITEMS_COUNT - 1 downto 0 do
    List.Delete(i);

  Result := Default(T);
end;

{ TinyListDelete }

function TinyListDelete.Execute: T;
var
  i: Integer;
begin
  for i := ITEMS_COUNT - 1 downto 0 do
    List.Delete(i);

  Result := Default(T);
end;

{ SystemListIndexOf }

function SystemListIndexOf.Execute: T;
begin
  Result := List.IndexOf(Low(T))
end;

{ TinyListIndexOf }

function TinyListIndexOf.Execute: T;
begin
  Result := List.IndexOf(Low(T))
end;

{ SystemListReverse }

constructor SystemListReverse.Create;
begin
  inherited;
  FillContainer(True);
end;

procedure SystemListReverse.Prepare;
begin
end;

function SystemListReverse.Execute: T;
begin
  List.Reverse;
  Result := Default(T);
end;

{ TinyListReverse }

constructor TinyListReverse.Create;
begin
  inherited;
  FillContainer(True);
end;

procedure TinyListReverse.Prepare;
begin
end;

function TinyListReverse.Execute: T;
begin
  List.Reverse;
  Result := Default(T);
end;

{ SystemListPack }

function SystemListPack.Execute: T;
begin
  List.Pack;
  Result := Default(T);
end;

{ TinyListPack }

function TinyListPack.Execute: T;
begin
  List.Pack;
  Result := Default(T);
end;

{ SystemStackPush }

function SystemStackPush.Execute: T;
begin
  FillContainer(False);
  Result := Default(T);
end;

{ TinyStackPush }

function TinyStackPush.Execute: T;
begin
  FillContainer(False);
  Result := Default(T);
end;

{ SystemStackPush_Capacity }

function SystemStackPush_Capacity.Execute: T;
begin
  FillContainer(True);
  Result := Default(T);
end;

{ TinyStackPush_Capacity }

function TinyStackPush_Capacity.Execute: T;
begin
  FillContainer(True);
  Result := Default(T);
end;

{ SystemStackPop }

procedure SystemStackPop.Prepare;
begin
  FillContainer(True);
end;

function SystemStackPop.Execute: T;
var
  i: Integer;
begin
  for i := ITEMS_COUNT - 1 downto 0 do
    Result := Stack.Pop;
end;

{ TinyStackPop }

procedure TinyStackPop.Prepare;
begin
  FillContainer(True);
end;

function TinyStackPop.Execute: T;
var
  i: Integer;
begin
  for i := ITEMS_COUNT - 1 downto 0 do
    Result := Stack.Pop;
end;

{ SystemQueueEnqueue }

function SystemQueueEnqueue.Execute: T;
begin
  FillContainer(False);
  Result := Default(T);
end;

{ TinyQueueEnqueue }

function TinyQueueEnqueue.Execute: T;
begin
  FillContainer(False);
  Result := Default(T);
end;

{ SystemQueueEnqueue_Capacity }

function SystemQueueEnqueue_Capacity.Execute: T;
begin
  FillContainer(True);
  Result := Default(T);
end;

{ TinyQueueEnqueue_Capacity }

function TinyQueueEnqueue_Capacity.Execute: T;
begin
  FillContainer(True);
  Result := Default(T);
end;

{ SystemQueueDequeue }

procedure SystemQueueDequeue.Prepare;
begin
  FillContainer(True);
end;

function SystemQueueDequeue.Execute: T;
var
  i: Integer;
begin
  for i := ITEMS_COUNT - 1 downto 0 do
    Result := Queue.Dequeue;
end;

{ TinyQueueDequeue }

procedure TinyQueueDequeue.Prepare;
begin
  FillContainer(True);
end;

function TinyQueueDequeue.Execute: T;
var
  i: Integer;
begin
  for i := ITEMS_COUNT - 1 downto 0 do
    Result := Queue.Dequeue;
end;

end.
