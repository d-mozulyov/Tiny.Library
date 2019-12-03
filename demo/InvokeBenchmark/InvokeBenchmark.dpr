program InvokeBenchmark;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmInvokeBenchmark in 'frmInvokeBenchmark.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
