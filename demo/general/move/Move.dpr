program Move;

{$I TINY.DEFINES.inc}
{$WARNINGS OFF}

{$ifdef CPUARM}
uses
  System.StartUpCopy,
  FMX.Forms,
  frmMove {Form1};

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
{$else .CONSOLE}

{$APPTYPE CONSOLE}
uses
  uMove;

  procedure Log(const AMessage: string);
  begin
    Writeln(AMessage);
  end;

begin
  uMove.LogProc := Log;
  uMove.Run;

  Writeln;
  Write('Press Enter to quit');
  Readln;
end.
{$endif}
