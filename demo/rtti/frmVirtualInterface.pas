unit frmVirtualInterface;

{$I TINY.DEFINES.inc}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, System.Diagnostics,
  System.Rtti,
  Tiny.Types, Tiny.Rtti, Tiny.Invoke;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

type
  IMyInterface = interface(IInvokable)
    ['{89EDBA5C-DFBA-48FA-889C-FC857B0ED609}']
    function Func(const X, Y, Z: Integer): Integer;
  end;

procedure TForm1.Button1Click(Sender: TObject);
const
  COUNT = 1000000;
var
  i: Integer;
  LStopwatch: TStopwatch;
  LInterface: IMyInterface;
  LValue: Integer;
  T1, T2, T3: Int64;
begin
  // System.Rtti virtual interface
  LInterface := System.Rtti.TVirtualInterface.Create(TypeInfo(IMyInterface),
    procedure(Method: System.Rtti.TRttiMethod;
      const Args: TArray<System.Rtti.TValue>; out Result: System.Rtti.TValue)
    begin
      Result := Args[1].AsInteger + Args[2].AsInteger + Args[3].AsInteger;
    end) as IMyInterface;
  LValue := LInterface.Func(1, 2, 3);
  Assert(LValue = (1 + 2 + 3), 'System.Rtti virtual interface');
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LInterface.Func(1, 2, 3);
  end;
  T1 := LStopwatch.ElapsedMilliseconds;

  // Tiny.Rtti(Invoke) virtual interface
  LInterface := Tiny.Invoke.TRttiVirtualInterface.Create(TypeInfo(IMyInterface),
    function(const AMethod: Tiny.Invoke.TRttiVirtualMethod;
      const AArgs: TArray<Tiny.Rtti.TValue>; const AReturnAddress: Pointer): TValue
    begin
      Result := AArgs[1].AsInteger + AArgs[2].AsInteger + AArgs[3].AsInteger;
    end) as IMyInterface;
  LValue := LInterface.Func(1, 2, 3);
  Assert(LValue = (1 + 2 + 3), 'Tiny.Rtti(Invoke) virtual interface');
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LInterface.Func(1, 2, 3);
  end;
  T2 := LStopwatch.ElapsedMilliseconds;

  // Tiny.Rtti(Invoke) direct virtual interface
  LInterface := Tiny.Invoke.TRttiVirtualInterface.CreateDirect(TypeInfo(IMyInterface),
     procedure(const AMethod: Tiny.Invoke.TRttiVirtualMethod; var ADump: Tiny.Invoke.TRttiInvokeDump)
     var
       LSignature: Tiny.Invoke.PRttiSignature;
     begin
       LSignature := AMethod.Signature;
       ADump.OutInt32 := PInteger(@ADump.Bytes[LSignature.Arguments[0].Offset])^ +
         PInteger(@ADump.Bytes[LSignature.Arguments[1].Offset])^ +
         PInteger(@ADump.Bytes[LSignature.Arguments[2].Offset])^;
     end) as IMyInterface;
  LValue := LInterface.Func(1, 2, 3);
  Assert(LValue = (1 + 2 + 3), 'Tiny.Rtti(Invoke) direct virtual interface');
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LInterface.Func(1, 2, 3);
  end;
  T3 := LStopwatch.ElapsedMilliseconds;

  // result
  Caption := Format('System.Rtti: %dms, Tiny.Rtti (values): %dms, Tiny.Rtti (direct): %dms', [T1, T2, T3]);
end;

end.
