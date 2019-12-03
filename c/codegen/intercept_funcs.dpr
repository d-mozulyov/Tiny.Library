program intercept_funcs;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  uCommon;

(*
  TInvokePlatform = (ipX86, ipWin64, ipX64, ipARM32, ipARM64);
  TInvokeDecl = idRegister, idMicrosoft(Intel64), idCdecl/idStdCall(x86), idSafeCall
  TInvokeType = itNone, itGeneral, itOutputGeneral, itDouble,
    itSingle(x86), itFPU (x86/X64), itFPUInt64(x86), itHFA(X64/ARM), itReturnPtr(ARM64));
  TInvokeSignature = isGeneral(gggg), isGeneralExtended(ggee), isMicrosoftGeneralExtended(gege)

  0 - none (n)
  1 - genpair (g)
  2 - double (d)
  3 - long double (f)
  4 - single (s)
  5 - int64 via fpu (f64)
  6 - hfa (h)
  7 - retptr (p)

  (n/g/d) - all
  (s/f64) - x86
  (f) - x86/X64
  (h) - X64/ARM
  (p) - ARM64 only

  // _/g
  01. (n/g/d)   _/g [all]
  02. (s/f64)   _/g [x86]
  03. (f)       _/g [x86, X64]
  04. (h)       _/g [X64, ARM]
  05. (p)       _/g [ARM64]

  // ggg-g
  06. (n/g/d)   gg [all - x86]
  07. (f)       gg [X64]
  08. (h)       gg [X64, ARM]
  09. (p)       gg [ARM64]
  10. (n/g/d)   ggg [all]
  11. (s/f64)   ggg [x86]
  12. (f)       ggg [x86, X64]
  13. (h)       ggg [X64, ARM]
  14. (p)       ggg [ARM64]
  15. (all-h/p) ggg+ [x86]
  16. (f)       gggg [X64]
  17. (h)       gggg [X64/ARM]
  18. (p)       gggg [ARM64]

  // eeee (e1..4)
  19. (n/g/d)   eeee [all - x86]
  20. (f)       eeee [X64]
  21. (h)       eeee [X64/ARM]
  22. (p)       eeee [ARM64]

  // gege MSABI
  23. (n/g/d)   gege [Win64, X64]
  24. (f)!h     gege [X64]

  // ggee (g1..4, e1..4)
  25. (n/g/d/h) ggee [X64/ARM]
  26. (f)       ggee [X64]
  27. (p)       ggee [ARM64]
*)

var
  List: TStringList;

procedure __AddProc(const S: string);
begin
  Writeln(S);
  List.Add(S);
end;

type
  TFuncParams = record
    Platforms: TInvokePlatforms;
    Name: string;
    ResultType: TInvokeType;
    Args: Integer;
    GenCount: Integer;
    ExtCount: Integer;
    StackPopCount: Integer; {x86: pop stack count}
    MSABI: Boolean;

    class function Create(const APlatforms: TInvokePlatforms; const AResult: TInvokeType;
      const AArgs: Integer; const AStackPopCount: Integer = 0;
      const AMSABI: Boolean = False): TFuncParams; static;
    function GetCode: Integer;
    function GetFullName: string;
  end;
  PFuncParams = ^TFuncParams;


class function TFuncParams.Create(const APlatforms: TInvokePlatforms; const AResult: TInvokeType;
  const AArgs: Integer; const AStackPopCount: Integer; const AMSABI: Boolean): TFuncParams;
var
  LArgs: Integer;
begin
  FillChar(Result, SizeOf(Result), #0);

  Result.Platforms := APlatforms;
  Result.ResultType := AResult;
  Result.Args := AArgs;
  Result.StackPopCount := AStackPopCount;
  Result.MSABI := AMSABI;

  if (AResult = itOutputGeneral) then
  begin
    Result.Name := 'gen';
  end else
  begin
    Result.Name := INVOKE_TYPE_KINDS[AResult];
  end;
  Result.Name := Result.Name + '_';

  LArgs := AArgs;
  while (LArgs <> 0) do
  begin
    case (LArgs and 3) of
      1:
      begin
        Inc(Result.GenCount);
        Result.Name := Result.Name + 'g';
      end;
      2:
      begin
        Inc(Result.ExtCount);
        Result.Name := Result.Name + 'e';
      end;
    end;

    LArgs := LArgs shr 2;
  end;

  if (AStackPopCount <> 0) then
  begin
    Result.Name := Result.Name + IntToStr(AStackPopCount);
  end;
end;

function TFuncParams.GetCode: Integer;
type
  TInternalResult = (
    {0}irNone,
    {1}irGeneral,
    {2}irDouble,
    {3}irFPU,
    {4}irFloat,
    {5}irFPUInt64,
    {6}irHFA,
    {7}irRetPtr
  );
var
  LResult: TInternalResult;
begin
  case ResultType of
    itNone: LResult := irNone;
    itGeneral, itOutputGeneral: LResult := irGeneral;
    itSingle: LResult := irFloat;
    itDouble: LResult := irDouble;
    itFPU: LResult := irFPU;
    itFPUInt64: LResult := irFPUInt64;
    itHFA: LResult := irHFA;
  else
    // itReturnPtr
    LResult := irRetPtr;
  end;

  Result := Args + (StackPopCount shl 16) + Ord(LResult) shl 20;
  if (MSABI) then
  begin
    Inc(Result, 1 shl 16);
  end;
end;

function TFuncParams.GetFullName: string;
begin
  if (MSABI) then
  begin
    Result := 'msabi_' + Name;
  end else
  begin
    Result := Name;
  end;

  Result := 'intercept_' + Result;
end;

var
  Params: TFuncParams;
  Functions: TArray<TFuncParams>;

  procedure AddFunction(const AFuncParams: TFuncParams); overload;
  begin
    Functions := Functions + [AFuncParams];
  end;

  procedure AddFunction(const APlatforms: TInvokePlatforms;
    const AResult: TInvokeType; const AArgs: Integer; const AStackPopCount: Integer = 0;
    const AMSABI: Boolean = False); overload;
  begin
    AddFunction(TFuncParams.Create(APlatforms, AResult, AArgs, AStackPopCount, AMSABI));
  end;


procedure AddFuncCase(const AParams: TFuncParams);
begin
  AddFmt('    case 0x%.6x: return &%s;', [AParams.GetCode, AParams.GetFullName]);
end;

type
  TWriteEachProc = reference to function(const AParams: TFuncParams): Boolean;

var
  WRITE_NUMBER: Integer = 0;

  procedure WriteEach(
    const ATitle: string;
    const APlatforms: TInvokePlatforms;
    const AResultTypes: TInvokeTypes;
    const AMinGenerals, AMaxGenerals: Integer;
    const AMinExtendeds, AMaxExtendeds: Integer;
    const AProc: TWriteEachProc = nil;
    const AMinStackPopCount: Integer = 0; const AMaxStackPopCount: Integer = 0);
  var
    LResult: TInvokeType;
    LParams: TFuncParams;
    LArgs, i: Integer;
    g, e, s: Integer;
  begin
    Inc(WRITE_NUMBER);
    AddFmt('    /* %.2d. %s */', [WRITE_NUMBER, ATitle]);

    AddDefinePlatforms(APlatforms);
    for LResult in AResultTypes do
    begin
      for g := AMinGenerals to AMaxGenerals do
      for e := AMinExtendeds to AMaxExtendeds do
      begin
        LArgs := 0;
        for i := 0 to e - 1 do
        begin
          LArgs := (LArgs shl 2) + 2;
        end;
        for i := 0 to g - 1 do
        begin
          LArgs := (LArgs shl 2) + 1;
        end;

        for s := AMinStackPopCount to AMaxStackPopCount do
        begin
          LParams := TFuncParams.Create(APlatforms, LResult, LArgs, s, False);
          if (not Assigned(AProc)) or (AProc(LParams)) then
          begin
            AddFuncCase(LParams);
            AddFunction(LParams);
          end;
        end;
      end;
    end;
    AddEndifPlatforms(APlatforms);
  end;

  procedure WriteEachMSABI(
    const ATitle: string;
    const APlatforms: TInvokePlatforms;
    const AResultTypes: TInvokeTypes;
    const AProc: TWriteEachProc = nil);
  var
    LResult: TInvokeType;
    LParams: TFuncParams;
  begin
    Inc(WRITE_NUMBER);
    AddFmt('    /* %.2d. %s */', [WRITE_NUMBER, ATitle]);

    AddDefinePlatforms(APlatforms);
    for LResult in AResultTypes do
    begin
      ForEachInvokeSignature(
        procedure(const ASignatureTitle, ASignature: string; const AGenCount, AExtCount, AArgs: Integer)
        begin
          if (AGenCount = 0) or (AExtCount = 0) or (AGenCount = 4) or (AExtCount = 4) then
            Exit;

          LParams := TFuncParams.Create(APlatforms, LResult, AArgs, 0, True);
          if (not Assigned(AProc)) or (AProc(LParams)) then
          begin
            AddFuncCase(LParams);
            AddFunction(LParams);
          end;
        end, isMicrosoftGeneralExtended);
    end;
    AddEndifPlatforms(APlatforms);
  end;

begin
  try
    List := TStringList.Create;
    try
      uCommon.AddProc := __AddProc;

      // function switch
      begin
        WriteEach('(n/g/d)   _/g [all]',
          ALL_INVOKE_PLATFORMS, [itNone, itOutputGeneral, itDouble],
          0, 1, 0, 0);
        WriteEach('(s/f64)   _/g [x86]',
          [ipX86], [itSingle, itFPUInt64],
          0, 1, 0, 0);
        WriteEach('(f)       _/g [x86, X64]',
          [ipX86, ipX64], [itFPU],
          0, 1, 0, 0);
        WriteEach('(h)       _/g [X64, ARM]',
          [ipX64, ipARM32, ipARM64], [itHFA],
          0, 1, 0, 0);
        WriteEach('(p)       _/g [ARM64]',
          [ipARM64], [itReturnPtr],
          0, 1, 0, 0);

        WriteEach('(n/g/d)   gg [all - x86]',
          ALL_INVOKE_PLATFORMS - [ipX86], [itNone, itOutputGeneral, itDouble],
          2, 2, 0, 0);
        WriteEach('(f)       gg [X64]',
          [ipX64], [itFPU],
          2, 2, 0, 0);
        WriteEach('(h)       gg [X64, ARM]',
          [ipX64, ipARM32, ipARM64], [itHFA],
          2, 2, 0, 0);
        WriteEach('(p)       gg [ARM64]',
          [ipARM64], [itReturnPtr],
          2, 2, 0, 0);

        WriteEach('(n/g/d)   ggg [all]',
          ALL_INVOKE_PLATFORMS, [itNone, itOutputGeneral, itDouble],
          3, 3, 0, 0);
        WriteEach('(s/f64)   ggg [x86]',
          [ipX86], [itSingle, itFPUInt64],
          3, 3, 0, 0);
        WriteEach('(f)       ggg [x86, X64]',
          [ipX86, ipX64], [itFPU],
          3, 3, 0, 0);
        WriteEach('(h)       ggg [X64, ARM]',
          [ipX64, ipARM32, ipARM64], [itHFA],
          3, 3, 0, 0);
        WriteEach('(p)       ggg [ARM64]',
          [ipARM64], [itReturnPtr],
          3, 3, 0, 0);
        WriteEach('(all-h/p) ggg+ [x86]',
          [ipX86], [itNone, itOutputGeneral, itSingle, itDouble, itFPU, itFPUInt64],
          3, 3, 0, 0, nil, 1, 8);
        WriteEach('(f)       gggg [X64]',
          [ipX64], [itFPU],
          4, 4, 0, 0);
        WriteEach('(h)       gggg [X64, ARM]',
          [ipX64, ipARM32, ipARM64], [itHFA],
          4, 4, 0, 0);
        WriteEach('(p)       gggg [ARM64]',
          [ipARM64], [itReturnPtr],
          4, 4, 0, 0);

        WriteEach('(n/g/d)   eeee [all - x86]',
          ALL_INVOKE_PLATFORMS - [ipX86], [itNone, itOutputGeneral, itDouble],
          0, 0, 1, 4);
        WriteEach('(f)       eeee [X64]',
          [ipX64], [itFPU],
          0, 0, 1, 4);
        WriteEach('(h)       eeee [X64, ARM]',
          [ipX64, ipARM32, ipARM64], [itHFA],
          0, 0, 1, 4);
        WriteEach('(p)       eeee [ARM64]',
          [ipARM64], [itReturnPtr],
          0, 0, 1, 4);

        WriteEachMSABI('(n/g/d)   gege [Win64, X64]',
          [ipWin64, ipX64], [itNone, itOutputGeneral, itDouble]);
        WriteEachMSABI('(f)!h     gege [X64]',
          [ipX64], [itFPU]);

        WriteEach('(n/g/d/h) ggee [X64/ARM]',
          [ipX64, ipARM32, ipARM64], [itNone, itOutputGeneral, itDouble, itHFA],
          1, 4, 1, 4);
        WriteEach('(f)       ggee [X64]',
          [ipX64], [itFPU],
          1, 4, 1, 4);
        WriteEach('(p)       ggee [ARM64]',
          [ipARM64], [itReturnPtr],
          1, 4, 1, 4);
      end;
      List.SaveToFile('..\tiny.invoke.intr.funcswitch.inc');

      // function implementation
      List.Clear;
      for Params in Functions do
      begin
        Add('');
        AddDefinePlatforms(Params.Platforms, 0);

        if (Params.ResultType = itReturnPtr) then
        begin
          AddFmt('REGISTER_DECL NAKED void %s()', [Params.GetFullName]);
          Add('{');
          Add('    intercept_begin');
          Add('        intercept_prologue');
          AddFmt('        intercept_store(%d, %d)', [Params.GenCount, Params.ExtCount]);
          Add('        intercept_store_retptr');
          Add('        intercept_call');
          Add('        intercept_load(0)');
          AddFmt('        intercept_epilogue(%s)', [Params.Name]);
          Add('    intercept_end(0)');
          Add('}');
        end else
        if (Params.MSABI) then
        begin
          AddFmt('intercept_msabi_func(%s, %d, %d, %d, %d, %d);',
            [
               Params.Name,
               Params.GetCode shr 20,
               Params.Args and 3,
               (Params.Args shr 2) and 3,
               (Params.Args shr 4) and 3,
               (Params.Args shr 6) and 3
            ]);
        end else
        begin
          AddFmt('intercept_func(%s, %d, %d, %d, %d);',
            [
               Params.Name,
               Params.GetCode shr 20,
               Params.GenCount,
               Params.ExtCount,
               Params.StackPopCount
            ]);
        end;

        AddEndifPlatforms(Params.Platforms, 0);
      end;
      List.SaveToFile('..\tiny.invoke.intr.funcimpl.inc');
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
