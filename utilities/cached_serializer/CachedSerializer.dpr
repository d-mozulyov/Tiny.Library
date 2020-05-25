program CachedSerializer;

{$I TINY.DEFINES.inc}
{$WARN SYMBOL_PLATFORM OFF}
{$APPTYPE CONSOLE}

uses {$ifdef UNITSCOPENAMES}Winapi.Windows{$else}Windows{$endif},
     {$ifdef UNITSCOPENAMES}System.SysUtils{$else}SysUtils{$endif},
     Tiny.Types,
     Tiny.Text,
     uSerialize in 'uSerialize.pas',
     uIdentifiers in 'uIdentifiers.pas';


procedure SetClipboardText(const Text: UnicodeString);
var
  Size: NativeUInt;
  Handle: HGLOBAL;
  Ptr: Pointer;
begin
  OpenClipboard(0);
  try
    Size := (Length(Text) + 1) * SizeOf(WideChar);
    Handle := GlobalAlloc(GMEM_DDESHARE or GMEM_MOVEABLE, Size);
    try
      Win32Check(Handle <> 0);
      Ptr := GlobalLock(Handle);
      Win32Check(Assigned(Ptr));
      Move(PUnicodeChar(Text)^, Ptr^, Size);
      GlobalUnlock(Handle);
      SetClipboardData(CF_UNICODETEXT, Handle);
    finally
      GlobalFree(Handle);
    end;
  finally
    CloseClipboard;
  end;
end;

var
  FlagLog, FlagWait, FlagCopy: Boolean;
  Index, i: Integer;
  OptionsFileName, S: string;
  Options: TSerializeOptions;
  Serializer: TSerializer;
  List: TUnicodeStrings;
  Text: UnicodeString;
begin
  // check flags: -nolog, -nowait, -nocopy
  FlagLog := True;
  FlagWait := True;
  FlagCopy := True;
  Index := 1;
  repeat
    S := ParamStr(Index);
    if (S = '') then Break;

    if (S = '-nolog') then FlagLog := False;
    if (S = '-nowait') then FlagWait := False;
    if (S = '-nocopy') then FlagCopy := False;
    Inc(Index);
  until (False);

  // load file
  OptionsFileName := ParamStr(1);
  try
    if (not FileExists(OptionsFileName)) then
    begin
      Writeln('Identifiers file not found!');
      Writeln('See the detailed description of the utility here:');
      Writeln('https://github.com/d-mozulyov/CachedTexts#cachedserializer');
    end else
    begin
      Options.Clear;
      Options.AddFromFile(OptionsFileName, True);

      // update options
      Index := 2;
      repeat
        S := ParamStr(Index);
        if (S = '') then Break;

        if (not Options.ParseOption(S)) then
        begin
          if (S <> '-nolog') and (S <> '-nowait') and (S <> '-nocopy') then
            Writeln('Unknown parameter "', S, '"');
        end;
        Inc(Index);
      until (False);

      // serialize
      Serializer := TSerializer.Create;
      try
        List := Serializer.Process(Options);

        // display to the console
        if (FlagLog) then        
        for i := 0 to Length(List) - 1 do
        begin
          if (Text <> '') then Text := Text + #13#10;
          Text := Text + List[i];

          Writeln(List[i]);
        end;

        // copy to the clipboard
        if (FlagCopy) then
        begin
          SetClipboardText(Text);
          Writeln;
          Writeln('The code has been successfully copied to the clipboard');
        end;
      finally
        Serializer.Free;
      end;
    end;
  except
    on EAbort do ;

    on E: Exception do
    begin
      Writeln(E.ClassName, ':');
      Writeln(E.Message);
    end;
  end;

  if (FlagWait) then
  begin
    Writeln;
    Write('Press Enter to quit');
    Readln;
  end;
end.
