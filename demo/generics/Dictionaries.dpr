program Dictionaries;

{$I TINY.DEFINES.inc}
{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Tiny.Generics in '..\..\Tiny.Generics.pas',
  uDictionaries in 'uDictionaries.pas';

begin
  try
    Run;
  except
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
