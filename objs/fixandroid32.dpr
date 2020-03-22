program fixandroid32;

{$APPTYPE CONSOLE}
{$I ..\TINY.DEFINES.inc}

uses
  SysUtils;

var
  N: Integer;
  FileName: string;
  Handle: THandle;
  Buffer: AnsiString;
  BufferSize: Integer;
  P: Integer;
  S: PAnsiChar;
  Value: Byte;

begin
  FileName := ParamStr(1);
  if (not FileExists(FileName)) then
  begin
    Writeln('Object file "', FileName, '" not found');
    Halt(1);
  end;

  N := 0;
  repeat
    Handle := FileOpen(FileName, fmOpenReadWrite);
    if (Handle <> THandle(-1)) then
    begin
      Break;
    end;  

    Inc(N);
    if (N = 10) or (not FileExists(FileName)) then
    begin
      Writeln('Object file "', FileName, '" not opened');
      Halt(1);
    end;
    Sleep(100);
  until (False);

  try
    BufferSize := FileSeek(Handle, -60, 2);
    Value := $3C;
    FileWrite(Handle, Value, SizeOf(Value));

    SetLength(Buffer, BufferSize);
    FileSeek(Handle, 0, 0);
    FileRead(Handle, Pointer(Buffer)^, BufferSize);
    P := Pos('clang version ', Buffer);
    if (P <> 0) then
    begin
      UniqueString(Buffer);
      S := @Buffer[P + Length('clang version ')];
      while (S^ <> ')') do
        Inc(S);

      Inc(S);
      PByte(S + 2)^ := $3B;
      PByte(S + 13)^ := $31;
      PCardinal(S + 57)^ := PCardinal(S + 57 + 2)^;
      PWord(S + 57 + 4)^ := $0000;
    end;
    FileSeek(Handle, 0, 0);
    FileWrite(Handle, Pointer(Buffer)^, BufferSize);
  finally
    FileClose(Handle);
  end;
end.
