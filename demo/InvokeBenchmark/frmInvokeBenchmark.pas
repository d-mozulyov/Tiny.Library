unit frmInvokeBenchmark;

{$define RTTION_METHODS}
{$I TINY.DEFINES.inc}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, System.Diagnostics,
  System.Rtti,
  Tiny.Rtti, Tiny.Invoke;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SomeMethod(const X, Y, Z: Integer);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.SomeMethod(const X, Y, Z: Integer);
begin
  Tag := X + Y + Z;
end;

procedure TForm1.Button1Click(Sender: TObject);
const
  COUNT = 1000000;
var
  i: Integer;
  LStopwatch: TStopwatch;
  LContext: System.Rtti.TRttiContext;
  LMethod: System.Rtti.TRttiMethod;
  LMethodEntry: Tiny.Rtti.PVmtMethodExEntry;
  LSignature: Tiny.Invoke.TRttiSignature;
  LInvokeFunc: Tiny.Invoke.TRttiInvokeFunc;
  LDump: Tiny.Invoke.TRttiInvokeDump;
  T1, T2, T3, T4: Int64;
begin
  // initialization
  LContext := System.Rtti.TRttiContext.Create;
  LMethod := LContext.GetType(TForm1).GetMethod('SomeMethod');
  LMethodEntry := Tiny.Rtti.PTypeInfo(TypeInfo(TForm1)).TypeData.ClassData.MethodTableEx.Find('SomeMethod');
  LSignature.Init(LMethodEntry^);
  LInvokeFunc := LSignature.OptimalInvokeFunc;

  // System.Rtti
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LMethod.Invoke(Form1, [1, 2, 3]);
  end;
  T1 := LStopwatch.ElapsedMilliseconds;

  // Tiny.Rtti(Invoke) values
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LSignature.Invoke(LDump, LMethodEntry.CodeAddress, Form1, {TValue}[1, 2, 3], LInvokeFunc);
  end;
  T2 := LStopwatch.ElapsedMilliseconds;

  // Tiny.Rtti(Invoke) arguments
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    LSignature.Invoke(LDump, LMethodEntry.CodeAddress, Form1, {array of}[1, 2, 3], nil, LInvokeFunc);
  end;
  T3 := LStopwatch.ElapsedMilliseconds;

  // Tiny.Rtti(Invoke) direct
  LStopwatch := TStopwatch.StartNew;
  for i := 1 to COUNT do
  begin
    PPointer(@LDump.Bytes[LSignature.DumpOptions.ThisOffset])^ := Form1;
    PInteger(@LDump.Bytes[LSignature.Arguments[0].Offset])^ := 1;
    PInteger(@LDump.Bytes[LSignature.Arguments[1].Offset])^ := 2;
    PInteger(@LDump.Bytes[LSignature.Arguments[2].Offset])^ := 3;
    LInvokeFunc(@LSignature, LMethodEntry.CodeAddress, @LDump);
  end;
  T4 := LStopwatch.ElapsedMilliseconds;

  // result
  Caption := Format('System.Rtti: %dms, Tiny.Rtti (values): %dms, ' +
    'Tiny.Rtti (args): %dms, Tiny.Rtti (direct): %dms', [T1, T2, T3, T4]);
end;


end.
