program fixwin32;

{$APPTYPE CONSOLE}
{$I ..\TINY.DEFINES.inc}

uses
  Windows,
  SysUtils;

function MyGetTempFile(const APrefix: string): string;
var
  LTempPath, LResult: array[0..MAX_PATH] of Char;
begin
  FillChar(LTempPath, MAX_PATH, 0);
  FillChar(LResult, MAX_PATH, 0);
  GetTempPath(SizeOf(LTempPath), LTempPath);
  GetTempFileName(@LTempPath[0], PChar(APrefix), 0, LResult);
  Result := LResult;
end;

procedure ExecuteAndWait(const ACmdLine: string);
var
  LStartupInfo: TStartupInfo;
  LProcessInformation: TProcessInformation;
begin
  FillChar(LStartupInfo, SizeOf(LStartupInfo), 0);
  with LStartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    wShowWindow := SW_HIDE;
  end;

  if CreateProcess(nil, PChar(ACmdLine), nil, nil, true, CREATE_NO_WINDOW,
    nil, nil, LStartupInfo, LProcessInformation) then
  begin
    WaitForSingleObject(LProcessInformation.hProcess, INFINITE);
    CloseHandle(LProcessInformation.hProcess);
    CloseHandle(LProcessInformation.hThread);
  end else
  begin
    RaiseLastOSError;
  end;
end;

var
  FileName: string;
  TempFileName: string;
begin
  FileName := ParamStr(1);
  if (not FileExists(FileName)) then
  begin
    Writeln('Object file "', FileName, '" not found');
    Halt(1);
  end;

  TempFileName := MyGetTempFile('fixwin32');
  if (not DeleteFile(TempFileName)) or (not RenameFile(FileName, TempFileName)) then
  begin
    Writeln('Object file "', FileName, '" temporary copying failure');
    Halt(1);
  end;

  ExecuteAndWait('coff2omf.exe "' + TempFileName + '"');
  if (not RenameFile(TempFileName, FileName)) then
  begin
    Writeln('Object file "', FileName, '" temporary restore failure');
    Halt(1);
  end;

  ExecuteAndWait('omf2d.exe "' + FileName + '"');
end.
