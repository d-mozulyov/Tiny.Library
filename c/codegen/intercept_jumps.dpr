program intercept_jumps;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  uCommon;

const
  JUMPS_COUNT = 1024;
  COMMA: array[Boolean] of string = ('', ',');

var
  i: Integer;
  List: TStringList;

procedure __AddProc(const S: string);
begin
  Writeln(S);
  List.Add(S);
end;

begin
  try
    List := TStringList.Create;
    try
      uCommon.AddProc := __AddProc;

      // C-jumps
      begin
        for i := 0 to JUMPS_COUNT - 1 do
        begin
          AddFmt('intercept_jump(%d);', [i]);
        end;

        Add('');

        Add('const');
        AddFmt('    void* INTERCEPT_JUMPS[%d] = {', [JUMPS_COUNT]);
        for i := 0 to JUMPS_COUNT - 1 do
        begin
          AddFmt('        &intercept_jump%d%s', [i, COMMA[i <> JUMPS_COUNT - 1]]);
        end;
        Add('    };');
      end;
      List.SaveToFile('..\tiny.invoke.intr.jumps.inc');

      // OldDelphi-jumps
      List.Clear;
      begin
        for i := 0 to JUMPS_COUNT - 1 do
        begin
          Add('');
          AddFmt('procedure intercept_jump%d;', [i]);
          Add('const');
          AddFmt('  ITEM_OFFSET = %d * SizeOf(TRttiVirtualMethodData);', [i]);
          Add('asm');
          Add('  DB $89, $C8, $EB, $04, $8B, $44, $24, $04');
          Add('  mov [esp - $18], edx');
          Add('  mov edx, [eax - 4]');
          Add('  add edx, ITEM_OFFSET');
          Add('  jmp [edx]');
          Add('end;');
        end;

        Add('');

        Add('const');
        AddFmt('  INTERCEPT_JUMPS: array[0..%d] of Pointer = (', [JUMPS_COUNT - 1]);
        for i := 0 to JUMPS_COUNT - 1 do
        begin
          AddFmt('    @intercept_jump%d%s', [i, COMMA[i <> JUMPS_COUNT - 1]]);
        end;
        Add('    );');

        Add('');

        Add('function get_intercept_jump(const AIndex, AMode: Integer): Pointer;');
        Add('var');
        Add('  LPtr: PByte;');
        Add('begin');
        Add('  if (AIndex < Low(INTERCEPT_JUMPS)) or (AIndex > High(INTERCEPT_JUMPS)) then');
        Add('  begin');
        Add('    Result := nil;');
        Add('    Exit;');
        Add('  end;');
        Add('');
        Add('  LPtr := INTERCEPT_JUMPS[AIndex];');
        Add('  Inc(LPtr, 8);');
        Add('');
        Add('  case (AMode) of');
        Add('    1: Dec(LPtr, 4);');
        Add('    2: Dec(LPtr, 4 + 4);');
        Add('  end;');
        Add('');
        Add('  Result := LPtr;');
        Add('end;');
      end;
      List.SaveToFile('..\tiny.invoke.intr.jumps.olddelphi.inc');
    finally
      List.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  Write('Press Enter to quit');
  Readln;
end.
