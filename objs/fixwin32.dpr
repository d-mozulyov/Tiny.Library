program fixwin32;

{$APPTYPE CONSOLE}
{$I ..\TINY.DEFINES.inc}

uses
  Windows,
  SysUtils;

function GetTempFolder(const APrefix: string): string;
var
  LBuffer: array[0..MAX_PATH] of Char;
  LTempFolder: string;
  LRandSeed: Integer;
begin
  FillChar(LBuffer, MAX_PATH, 0);
  GetTempPath(High(LBuffer), LBuffer);
  LTempFolder := IncludeTrailingPathDelimiter(LBuffer) + APrefix + '_';
  LRandSeed := System.RandSeed;
  try
    Randomize;

    repeat
      Result := LTempFolder + IntToHex(Random(100000000), 8);
    until (CreateDir(Result));
  finally
    System.RandSeed := LRandSeed;
  end;
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
  i: Integer;
  FileName: string;
  TempFolder: string;
  TempFileName: string;
  Done: Boolean;
begin
  FileName := ParamStr(1);
  if (not FileExists(FileName)) then
  begin
    Writeln('Object file "', FileName, '" not found');
    Halt(1);
  end;

  TempFolder := GetTempFolder('fixwin32');
  TempFileName := IncludeTrailingPathDelimiter(TempFolder) + 'temp.o';
  if (not RenameFile(FileName, TempFileName)) then
  begin
    RemoveDir(TempFolder);
    Writeln('Object file "', FileName, '" temporary copying failure');
    Halt(1);
  end;

  ExecuteAndWait('coff2omf.exe "' + TempFileName + '"');
  Done := RenameFile(TempFileName, FileName);
  begin
    i := 0;
    repeat
      DeleteFile(TempFileName);
      if (not FileExists(TempFileName)) or (i >= 50) then
        Break;

      Inc(i);
      Sleep(100);
    until (False);

    i := 0;
    repeat
      RemoveDir(TempFolder);
      if (not DirectoryExists(TempFolder)) or (i >= 50) then
        Break;

      Inc(i);
      Sleep(100);
    until (False);
  end;

  if (not Done) then
  begin
    Writeln('Object file "', FileName, '" temporary restore failure');
    Halt(1);
  end;

  ExecuteAndWait('omf2d.exe "' + FileName + '"');
end.
