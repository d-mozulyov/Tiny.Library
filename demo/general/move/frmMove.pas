unit frmMove;

{$I TINY.DEFINES.inc}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox,
  FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, uMove;

type
  TForm1 = class(TForm)
    btnRun: TButton;
    memLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure Log(const AMessage: string);
begin
  Form1.memLog.Lines.Add(AMessage)
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  uMove.LogProc := Log;
end;

procedure TForm1.btnRunClick(Sender: TObject);
begin
  uMove.Run;
end;

end.
