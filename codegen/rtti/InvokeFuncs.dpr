program InvokeFuncs;

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

  (n/g/d) - all
  (s/f64) - x86
  (f) - x86/X64
  (h) - X64/ARM
  (p) - ARM64 only

  // ggg-g
  01. (n/g/d)   ggg [all]
  02. (s/f64)   ggg [x86]
  03. (f)       ggg [x86, X64]
  04. (h)       ggg [X64, ARM]
  05. (n/g/d)   gggg [all - x86]
  06. (f)       gggg [X64]
  07. (h)       gggg [X64/ARM]

  // eeee
  08. (n/g/d)   eeee [all - x86]
  09. (f)       eeee [X64]
  10. (h)       eeee [X64/ARM]

  // gege MSABI
  11. (n/g/d)   gege [Win64, X64]
  12. (f)!h     gege [X64]

  // ggee
  13. (n/g/d/h) ggee [X64/ARM]
  14. (f)       ggee [X64]

  // (p) ARM64
  15. (p)       xxxx [ARM64]

  // xxxgggg x86
  16. (all-h/p) xxxgggg [x86-cdecl]
  17. (all-h/p) xxxgggg [x86-stdcall]

  // xxxx safecall
  18. safecall  gggg [all]
  19. safecall  eeee [all - x86]
  20. safecall  gege [Win64]
  21. safecall  ggee [X64/ARM]
*)


var
  List: TStringList;

procedure __AddProc(const S: string);
begin
  Writeln(S);
  List.Add(S);
end;

type
  TParams = record
    Decl: TInvokeDecl;
    DeclName: string;
    ResultType: TInvokeType;
    ResultTypeName: string;
    FuncName: string;
    Signature: string;
    GenCount: Integer;
    ExtCount: Integer;
    Args: Integer;

    function GetCode(const APlatform: TInvokePlatform): Integer;
  end;
  PParams = ^TParams;

  TNakedMode = (nmNone, nmX86, nmWin32);
  PNakedMode = ^TNakedMode;


function TParams.GetCode(const APlatform: TInvokePlatform): Integer;
type
  TInternalResult = (
    {0}irNone,
    {1}irGeneral,
    {2}irSafeCall,
    {3}irFloat,
    {4}irDouble,
    {5}irFPU,
    {6}irFPUInt64,
    {7}irHFA,
    {8}irRetPtr
  );
  TInternalDecl = (
    {0}idGeneral,
    {1}idAlternative{CdeclX86/idMicrosoftX64}
  );
var
  LResult: TInternalResult;
  LDecl: TInternalDecl;
  LStackCount: Integer;
  LArgs: Integer;
begin
  LResult := irSafeCall;
  if (Decl <> idSafeCall) then
  case ResultType of
    itNone: LResult := irNone;
    itGeneral, itOutputGeneral: LResult := irGeneral;
    itSingle: LResult := irFloat;
    itDouble: LResult := irDouble;
    itFPU: LResult := irFPU;
    itFPUInt64: LResult := irFPUInt64;
    itHFA: LResult := irHFA;
    itReturnPtr: LResult := irRetPtr;
  end;

  LDecl := idGeneral;
  LStackCount := 0;
  LArgs := Args;
  if (APlatform = ipX86) and (Decl in [idCdecl, idStdCall]) then
  begin
    LStackCount := GenCount;
    if (LStackCount <> 0) then
    begin
      LArgs := 1 + (1 shl 2) + (1 shl 4);
      if (Decl = idCdecl) then
      begin
        LDecl := idAlternative{idCdeclX86};
      end;
    end;
  end;
  if (Decl = idMicrosoft) and (GenCount <> 0) then
  begin
    LDecl := idAlternative{idMicrosoftX64};
  end;

  Result := LArgs + (Ord(LResult) shl 8) + (Ord(LDecl) shl 12) + (Integer(LStackCount) shl 16);
end;


type
  TForEachProc = reference to procedure(var APlatforms: TInvokePlatforms; const AParams: TParams);

var
  USED_FUNCS: array[TInvokeDecl, TInvokeType, Byte{Args}] of TInvokePlatforms;
  FUNC_PARAMS: array[TInvokeDecl, TInvokeType, Byte{Args}] of TParams;

procedure ForEach(const ADecls: TInvokeDecls; const AResultTypes: TInvokeTypes;
  const ASignature: TInvokeSignature; const AEmpty: Boolean; const AProc: TForEachProc);
begin
  ForEachInvokeDecl(
    procedure(const ADecl: TInvokeDecl; const ADeclKind, ADeclName: string)
    begin
      ForEachInvokeType(
        procedure(const AType: TInvokeType; const ATypeKind, ATypeName: string)
        begin
          ForEachInvokeSignature(
            procedure(const ASignatureTitle, ASignature: string; const AGenCount, AExtCount, AArgs: Integer)
            var
              LParams: PParams;
              LPlatforms: TInvokePlatforms;
              LResult: PInvokePlatforms;
            begin
              LParams := @FUNC_PARAMS[ADecl, AType, Byte(AArgs)];
              LResult := @USED_FUNCS[ADecl, AType, Byte(AArgs)];
              if (LResult^ = []) then
              begin
                LParams.Decl := ADecl;
                LParams.DeclName := ADeclName;
                LParams.ResultType := AType;
                LParams.ResultTypeName := ATypeKind{!!!};
                LParams.FuncName := 'invoke_' + InvokeFuncName(ADeclKind, ATypeKind, ASignatureTitle);
                LParams.Signature := ASignature;
                LParams.GenCount := AGenCount;
                LParams.ExtCount := AExtCount;
                LParams.Args := AArgs;
              end;

              LPlatforms := [];
              AProc(LPlatforms, LParams^);
              LResult^ := LResult^ + LPlatforms;
            end, ASignature, AEmpty, ADecl in [idCdecl, idStdCall]);
        end, AResultTypes);
    end, ADecls, True);
end;

procedure ForEachUsed(const AProc: TForEachProc);
var
  LDecl: TInvokeDecl;
  LType: TInvokeType;
  LArgs: Byte;
  LParams: PParams;
  LResult: PInvokePlatforms;
begin
  for LDecl := Low(TInvokeDecl) to High(TInvokeDecl) do
  for LType := Low(TInvokeType) to High(TInvokeType) do
  for LArgs := Low(Byte) to High(Byte) do
  begin
    LParams := @FUNC_PARAMS[LDecl, LType, LArgs];
    LResult := @USED_FUNCS[LDecl, LType, LArgs];
    if (LResult^ <> []) then
    begin
      AProc(LResult^, LParams^);
    end;
  end;
end;

procedure AddFuncCase(const APlatform: TInvokePlatform; const AParams: TParams);
begin
  AddFmt('    case 0x%.6x: return &%s;', [AParams.GetCode(APlatform), AParams.FuncName]);
end;

type
  TWriteEachProc = reference to function(const AParams: TParams): Boolean;

var
  WRITE_NUMBER: Integer = 0;

procedure WriteEach(
  const ATitle: string;
  const APlatforms: TInvokePlatforms;
  const ADecls: TInvokeDecls; const AResultTypes: TInvokeTypes;
  const ASignature: TInvokeSignature; const AProc: TWriteEachProc;
  const AEmpty: Boolean = False);
var
  LPlatforms: TInvokePlatforms;
  LFirstPlatform, LTemp: TInvokePlatform;
begin
  Inc(WRITE_NUMBER);
  AddFmt('    /* %.2d. %s */', [WRITE_NUMBER, ATitle]);

  LPlatforms := APlatforms;
  LFirstPlatform := Low(TInvokePlatform);
  for LTemp in LPlatforms do
  begin
    LFirstPlatform := LTemp;
    Break;
  end;

  AddDefinePlatforms(LPlatforms);
  begin
    ForEach(ADecls, AResultTypes, ASignature, AEmpty,
      procedure(var APlatforms: TInvokePlatforms; const AParams: TParams)
      begin
        if (AProc(AParams)) then
        begin
          APlatforms := LPlatforms;
          AddFuncCase(LFirstPlatform, AParams);
        end;
      end);
  end;
  AddEndifPlatforms(LPlatforms);
end;

procedure AddFuncImplementation(const AParams: TParams; const ANakedMode: TNakedMode; const AStdCode: Boolean);
var
  i: Integer;
  LGenSafeCall: Boolean;
  LArg, LGenArgCount, LExtArgCount: Integer;
  LParam: string;
  LResult: string;
  LFuncType: string;
  LSignature: string;
  LOffset: string;

  function Regs(const AName: string): string;
  begin
    Result := 'dumpregs.' + AName;
  end;

  function Gens(const AIndex: Integer): string;
  begin
    if (AParams.Decl = idMicrosoft) then
    begin
      case AIndex of
        0: Result := Regs('RegRCX');
        1: Result := Regs('RegRDX');
        2: Result := Regs('RegR8');
      else
        // 3:
        Result := Regs('RegR9');
      end;
    end else
    if (LGenSafeCall) then
    begin
      Result := Format('dumpsafegen(%d)', [AIndex]);
    end else
    begin
      Result := Format('dumpgens[%d]', [AIndex]);
    end;
  end;

  function Exts(const AIndex: Integer): string;
  begin
    if (AParams.Decl = idMicrosoft) then
    begin
      Result := Regs('RegXMM') + IntToStr(AIndex);
    end else
    begin
      Result := Format('dumpexts[%d]', [AIndex]);
    end;
  end;

  function Stack(const AIndex: Integer): string;
  begin
    Result := Format('dumpstack[%d]', [AIndex]);
  end;
begin
  // result
  LResult := '';
  if (AParams.Decl = idSafeCall) then
  begin
    LResult := Regs('OutInt32');
  end else
  case (AParams.ResultType) of
    itGeneral, itOutputGeneral: LResult := Regs('OutGeneral');
    itSingle: LResult := Regs('OutFloat');
    itDouble: LResult := Regs('OutDouble');
    itFPU: LResult := Regs('OutLongDouble');
    itFPUInt64: LResult := 'long double R';
    itHFA: LResult := Regs('OutHFA');
    itReturnPtr: LResult := '';
  end;

  // function type
  LFuncType := StringReplace(AParams.FuncName, 'invoke_', 'func_', [rfReplaceAll]);
  LFuncType := StringReplace(LFuncType, '_none_', '_outgen_', [rfReplaceAll]);
  LFuncType := StringReplace(LFuncType, '_fpuint64_', '_fpu_', [rfReplaceAll]);

  // general safe call mode
  LGenSafeCall := (AParams.Decl = idSafeCall) and
    (
      (AParams.Args = 0) or
      (AParams.Args = 1) or
      (AParams.Args = (1 shl 2) + 1) or
      (AParams.Args = (1 shl 4) + (1 shl 2) + 1) or
      (AParams.Args = (1 shl 6) + (1 shl 4) + (1 shl 2) + 1)
    );

  // signature
  LSignature := '';
  LGenArgCount := 0;
  LExtArgCount := 0;
  if (AParams.ResultType = itReturnPtr) then
  begin
    for i := 0 to AParams.GenCount - 1 do
    begin
      LSignature := LSignature + ', ' + Format('"r"(x%d)', [i]);
    end;

    for i := 0 to AParams.ExtCount - 1 do
    begin
      LSignature := LSignature + ', ' + Format('"r"(d%d)', [i]);
    end;

    LSignature := '__asm__ volatile ("br x4" :: "r"(x4), "r"(x8)' + LSignature + ');'
  end else
  if (AParams.Decl in [idCdecl, idStdCall]) then
  begin
    LSignature := Regs('RegEAX') + ', ' + Regs('RegEDX') + ', ' + Regs('RegECX');

    for i := 0 to 3 do
    begin
      LArg := (AParams.Args shr (i * 2)) and 3;
      if (LArg = 0) then
        Break;

      Inc(LGenArgCount);
    end;

    for i := 0 to LGenArgCount - 1 do
    begin
      LSignature := LSignature + ', ' + Stack(i);
    end;
  end else
  for i := 0 to 3 do
  begin
    LArg := (AParams.Args shr (i * 2)) and 3;
    if (LArg = 0) then
      Break;

    if (LSignature <> '') then
      LSignature := LSignature + ', ';

    if (LArg = 1) then
    begin
      LSignature := LSignature + Gens(LGenArgCount);
      Inc(LGenArgCount);
      if (AParams.Decl = idMicrosoft) then
        Inc(LExtArgCount);
    end else
    if (LArg = 2) then
    begin
      LSignature := LSignature + Exts(LExtArgCount);
      Inc(LExtArgCount);
      if (AParams.Decl = idMicrosoft) then
        Inc(LGenArgCount);
    end;
  end;

  // output
  LOffset := string.Create(' ', Ord((ANakedMode <> nmNone) and AStdCode) * 4);
  if (ANakedMode <> nmNone) then
  begin
    if (AStdCode) then
    begin
      if (ANakedMode = nmX86) then
      begin
        Add('    #if defined (CPUX86)');
      end else
      begin
        Add('    #if defined (WIN32)');
      end;
    end;

    if (not AStdCode) then
    begin
      AddFmt('    // ((%s)(code_address))(%s);', [LFuncType, LSignature]);
    end;

    if (AParams.Decl = idRegister) then
    begin
      AddFmt(LOffset + '    x86tailfunc(%d, 0);', [AParams.GenCount]);
    end else
    begin
      AddFmt(LOffset + '    x86tailfunc(3, %d);', [AParams.GenCount]);
    end;

    if (AStdCode) then
    begin
      Add('    #else');
    end;
  end;
  if (AStdCode) then
  begin
    if (AParams.ResultType = itReturnPtr) then
    begin
      AddFmt('    arm64registers(%d, %d);', [AParams.GenCount, AParams.ExtCount]);
      Add('    ' + LSignature);
    end else
    begin
      if (LResult <> '') then LResult := LResult + ' = ';
      AddFmt(LOffset + '    %s((%s)(code_address))(%s);', [LResult, LFuncType, LSignature]);
    end;

    // fpuint64 routine
    if (AParams.ResultType = itFPUInt64) then
    begin
      Add('    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");');
    end;

    // safecall routine
    if (AParams.Decl = idSafeCall) then
    begin
      LParam := Regs('OutInt32');
      AddFmt('    if (%s < 0) TinyErrorSafeCall(%s, RETURN_ADDRESS);', [LParam, LParam]);
    end;
  end;

  // x86 naked #endif
  if (ANakedMode <> nmNone) and (AStdCode) then
  begin
    Add('    #endif');
  end;
end;


begin
  try
    List := TStringList.Create;
    try
      uCommon.AddProc := __AddProc;

      // function switch
      begin
        WriteEach('(n/g/d)   ggg [all]',
          ALL_INVOKE_PLATFORMS, [idRegister],
          [itNone, itOutputGeneral, itDouble], isGeneral,
          function(const AParams: TParams): Boolean
          begin
            Result := (AParams.GenCount <= 3);
          end, True);

        WriteEach('(s/f64)   ggg [x86]',
          [ipX86], [idRegister],
          [itSingle, itFPUInt64], isGeneral,
          function(const AParams: TParams): Boolean
          begin
            Result := (AParams.GenCount <= 3);
          end, True);

        WriteEach('(f)       ggg [x86, X64]',
          [ipX86, ipX64], [idRegister],
          [itFPU], isGeneral,
          function(const AParams: TParams): Boolean
          begin
            Result := (AParams.GenCount <= 3);
          end, True);

        WriteEach('(h)       ggg [X64, ARM]',
          [ipX64, ipARM32, ipARM64], [idRegister],
          [itHFA], isGeneral,
          function(const AParams: TParams): Boolean
          begin
            Result := (AParams.GenCount <= 3);
          end, True);

        WriteEach('(n/g/d)   gggg [all - x86]',
          ALL_INVOKE_PLATFORMS - [ipX86], [idRegister],
          [itNone, itOutputGeneral, itDouble], isGeneral,
          function(const AParams: TParams): Boolean
          begin
            Result := (AParams.GenCount = 4);
          end, True);

        WriteEach('(f)       gggg [X64]',
          [ipX64], [idRegister],
          [itFPU], isGeneral,
          function(const AParams: TParams): Boolean
          begin
            Result := (AParams.GenCount = 4);
          end, True);

        WriteEach('(h)       gggg [X64/ARM]',
          [ipX64, ipARM32, ipARM64], [idRegister],
          [itHFA], isGeneral,
          function(const AParams: TParams): Boolean
          begin
            Result := (AParams.GenCount = 4);
          end, True);

        WriteEach('(n/g/d)   eeee [all - x86]',
          ALL_INVOKE_PLATFORMS - [ipX86], [idRegister],
          [itNone, itOutputGeneral, itDouble], isExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := True;
          end);

        WriteEach('(f)       eeee [X64]',
          [ipX64], [idRegister],
          [itFPU], isExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := True;
          end);

        WriteEach('(h)       eeee [X64/ARM]',
          [ipX64, ipARM32, ipARM64], [idRegister],
          [itHFA], isExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := True;
          end);

        WriteEach('(n/g/d)   gege [Win64, X64]',
          [ipWin64, ipX64], [idMicrosoft],
          [itNone, itOutputGeneral, itDouble], isMicrosoftGeneralExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := False;
            if (AParams.GenCount = 0) or (AParams.ExtCount = 0) then
              Exit;

            Result := True;
          end);

        WriteEach('(f)!h     gege [X64]',
          [ipX64], [idMicrosoft],
          [itFPU], isMicrosoftGeneralExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := False;
            if (AParams.GenCount = 0) or (AParams.ExtCount = 0) then
              Exit;

            Result := True;
          end);

        WriteEach('(n/g/d/h) ggee [X64/ARM]',
          [ipX64, ipARM32, ipARM64], [idRegister],
          [itNone, itOutputGeneral, itDouble, itHFA], isGeneralExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := False;
            if (AParams.GenCount = 0) or (AParams.ExtCount = 0) then
              Exit;

            Result := True;
          end);

        WriteEach('(f)       ggee [X64]',
          [ipX64], [idRegister],
          [itFPU], isGeneralExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := False;
            if (AParams.GenCount = 0) or (AParams.ExtCount = 0) then
              Exit;

            Result := True;
          end);

        WriteEach('(p)       xxxx [ARM64]',
          [ipARM64], [idRegister],
          [itReturnPtr], isGeneralExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := True;
          end, True);

        WriteEach('(all-h/p) xxxgggg [x86-cdecl]',
          [ipX86], [idCdecl],
          [itNone, itOutputGeneral, itSingle, itDouble, itFPU, itFPUInt64], isGeneral,
          function(const AParams: TParams): Boolean
          begin
            Result := (AParams.GenCount > 0);
          end);

        WriteEach('(all-h/p) xxxgggg [x86-stdcall]',
          [ipX86], [idStdCall],
          [itNone, itOutputGeneral, itSingle, itDouble, itFPU, itFPUInt64], isGeneral,
          function(const AParams: TParams): Boolean
          begin
            Result := (AParams.GenCount > 0);
          end);

        WriteEach('safecall  gggg [all]',
          ALL_INVOKE_PLATFORMS, [idSafeCall],
          [itNone], isGeneral,
          function(const AParams: TParams): Boolean
          begin
            Result := True;
          end, True);

        WriteEach('safecall  eeee [all - x86]',
          ALL_INVOKE_PLATFORMS - [ipX86], [idSafeCall],
          [itNone], isExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := True;
          end);

        WriteEach('safecall  gege [Win64]',
          [ipWin64], [idSafeCall],
          [itNone], isMicrosoftGeneralExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := False;
            if (AParams.GenCount = 0) or (AParams.ExtCount = 0) then
              Exit;
            Result := True;
          end);

        WriteEach('safecall  ggee [X64/ARM]',
          [ipX64, ipARM32, ipARM64], [idSafeCall],
          [itNone], isGeneralExtended,
          function(const AParams: TParams): Boolean
          begin
            Result := False;
            if (AParams.GenCount = 0) or (AParams.ExtCount = 0) then
              Exit;
            Result := True;
          end);
      end;
      List.SaveToFile('..\..\c\rtti\tiny.invoke.funcswitch.inc');

      // function implementation
      List.Clear;
      ForEachUsed(
        procedure(var APlatforms: TInvokePlatforms; const AParams: TParams)
        var
          LNakedMode: TNakedMode;
        begin
          Add('');
          AddDefinePlatforms(APlatforms, 0);

          LNakedMode := nmNone;
          if (ipX86 in APlatforms) and (AParams.ResultType = itNone) and
            (AParams.Decl in [idRegister, idStdCall]) and (AParams.ExtCount = 0) and
            ((AParams.GenCount > 1) or (AParams.Decl = idStdCall)) then
          begin
            LNakedMode := nmX86;
            if (AParams.Decl = idStdCall) then
            case AParams.GenCount of
              0, 4: ;
            else
              LNakedMode := nmWin32;
            end;
          end;

          case (LNakedMode) of
            nmX86: Add('X86NAKED');
            nmWin32: Add('WIN32NAKED');
          end;

          AddFmt('REGISTER_DECL void %s(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)', [AParams.FuncName]);
          Add('{');
          begin
            AddFuncImplementation(AParams, LNakedMode, (LNakedMode <> nmX86) or (APlatforms <> [ipX86]));
          end;
          Add('}');

          AddEndifPlatforms(APlatforms, 0);
        end);

      List.SaveToFile('..\..\c\rtti\tiny.invoke.funcimpl.inc');
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
