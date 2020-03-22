unit uCommon;

interface
  uses System.SysUtils;

type
  TAddProc = reference to procedure(const AText: string);

  TInvokePlatform = (ipX86, ipWin64, ipX64, ipARM32, ipARM64);
  PInvokePlatform = ^TInvokePlatform;
  TInvokePlatforms = set of TInvokePlatform;
  PInvokePlatforms = ^TInvokePlatforms;

  TInvokeDecl = (idRegister, idMicrosoft, idCdecl, idStdCall, idSafeCall);
  PInvokeDecl = ^TInvokeDecl;
  TInvokeDecls = set of TInvokeDecl;
  PInvokeDecls = ^TInvokeDecls;

  TInvokeType = (itNone, itGeneral, itOutputGeneral,
    itSingle, itDouble, itFPU, itFPUInt64, itHFA, itReturnPtr);
  PInvokeType = ^TInvokeType;
  TInvokeTypes = set of TInvokeType;
  PInvokeTypes = ^TInvokeTypes;

  TInvokeSignature = (isGeneral, isExtended, isGeneralExtended, isMicrosoftGeneralExtended);
  PInvokeSignature = ^TInvokeSignature;
  TInvokeSignatures = set of TInvokeSignature;
  PInvokeSignatures = ^TInvokeSignatures;


const
  ALL_INVOKE_PLATFORMS = [Low(TInvokePlatform)..High(TInvokePlatform)];
  ALL_INVOKE_DECLS = [Low(TInvokeDecl)..High(TInvokeDecl)];
  ALL_INVOKE_TYPES = [Low(TInvokeType)..High(TInvokeType)];
  ALL_INVOKE_SIGNATURES = [Low(TInvokeSignature)..High(TInvokeSignature)];

  INVOKE_PLATFORM_NAMES: array[TInvokePlatform] of string = (
    'CPUX86', 'WIN64', 'POSIXCPUX64', 'CPUARM32', 'CPUARM64');

  INVOKE_DECL_KINDS: array[TInvokeDecl] of string = (
    'register', 'msabi', 'cdecl', 'stdcall', 'safecall');
  INVOKE_DECL_NAMES: array[TInvokeDecl] of string = (
    'REGISTER_DECL', 'MS_DECL', 'CDECL', 'STDCALL', 'SAFECALL');

  INVOKE_TYPE_KINDS: array[TInvokeType] of string = (
    'none', 'gen', 'outgen', 'float', 'ext', 'fpu', 'fpuint64', 'hfa', 'retptr');
  INVOKE_TYPE_NAMES: array[TInvokeType] of string = (
    '', 'g', '', '', 'e', '', '', '', 'r');


type
  TInvokePlatformProc = reference to procedure(const APlatform: TInvokePlatform; const APlatformName: string);
  TInvokeDeclProc = reference to procedure(const ADecl: TInvokeDecl; const ADeclKind, ADeclName: string);
  TInvokeTypeProc = reference to procedure(const AType: TInvokeType; const ATypeKind, ATypeName: string);
  TInvokeSignatureProc = reference to procedure(const ASignatureTitle, ASignature: string;
    const AGenCount, AExtCount, AArgs: Integer);


var
  AddProc: TAddProc;

procedure Add(const AText: string);
procedure AddFmt(const AFmtStr: string; const AArgs: array of const);

function InvokeFuncName(const ADeclKind, ATypeKind, ASignatureTitle: string): string;

procedure ForEachInvokePlatform(const AProc: TInvokePlatformProc;
  const APlatforms: TInvokePlatforms = ALL_INVOKE_PLATFORMS);

procedure ForEachInvokeDecl(const AProc: TInvokeDeclProc;
  const ADecls: TInvokeDecls = ALL_INVOKE_DECLS; const ARegDecls: Boolean = False);

procedure ForEachInvokeType(const AProc: TInvokeTypeProc ;
  const ATypes: TInvokeTypes = ALL_INVOKE_TYPES);

procedure ForEachInvokeSignature(const AProc: TInvokeSignatureProc;
  const ASignature: TInvokeSignature; const AEmpty: Boolean = False;
  const ARegDeclsArgs: Boolean = False);


procedure AddDefinePlatforms(const APlatforms: TInvokePlatforms; const ASpaces: Cardinal = 4);
procedure AddEndifPlatforms(const APlatforms: TInvokePlatforms; const ASpaces: Cardinal = 4);

implementation

procedure Add(const AText: string);
begin
  if (Assigned(AddProc)) then
  begin
    AddProc(AText);
  end;
end;

procedure AddFmt(const AFmtStr: string; const AArgs: array of const);
begin
  Add(Format(AFmtStr, AArgs));
end;

function InvokeFuncName(const ADeclKind, ATypeKind, ASignatureTitle: string): string;
begin
  if (ADeclKind = 'safecall') then
  begin
    Result := Format('%s_%s', [ADeclKind, ASignatureTitle])
  end else
  begin
    Result := Format('%s_%s_%s', [ADeclKind, ATypeKind, ASignatureTitle])
  end;
end;

procedure ForEachInvokePlatform(const AProc: TInvokePlatformProc;
  const APlatforms: TInvokePlatforms);
var
  LPlatform: TInvokePlatform;
begin
  for LPlatform in APlatforms do
  begin
    AProc(LPlatform, INVOKE_PLATFORM_NAMES[LPlatform]);
  end;
end;

procedure ForEachInvokeDecl(const AProc: TInvokeDeclProc;
  const ADecls: TInvokeDecls; const ARegDecls: Boolean);
var
  LDecl: TInvokeDecl;
  LPrefix: string;
begin
  for LDecl in ADecls do
  begin
    LPrefix := '';
    if (LDecl in [idCdecl, idStdCall]) and (ARegDecls) then
    begin
      LPrefix := 'REG_';
    end;

    AProc(LDecl, INVOKE_DECL_KINDS[LDecl], LPrefix + INVOKE_DECL_NAMES[LDecl]);
  end;
end;

procedure ForEachInvokeType(const AProc: TInvokeTypeProc;
  const ATypes: TInvokeTypes);
var
  LType: TInvokeType;
begin
  for LType in ATypes do
  begin
    AProc(LType, INVOKE_TYPE_KINDS[LType], INVOKE_TYPE_NAMES[LType]);
  end;
end;

procedure ForEachInvokeSignature(const AProc: TInvokeSignatureProc;
  const ASignature: TInvokeSignature; const AEmpty, ARegDeclsArgs: Boolean);
const
  TYPES: array[0..2] of TInvokeType = (itNone, itGeneral, itDouble);
var
  i: Integer;
  LDone: Boolean;
  a0, a1, a2, a3: Byte;
  t0, t1, t2, t3: TInvokeType;
  a: array[0..3] of Byte;
  LGenCount, LExtCount: Integer;
  LFormat: string;
  LSignatureTitle: string;
  LSignature: string;
begin
  for a0 := 0 to 2 do
  for a1 := 0 to 2 do
  for a2 := 0 to 2 do
  for a3 := 0 to 2 do
  begin
    if (a0 = 0) then
    begin
      if (a1 <> 0) or (a2 <> 0) or (a3 <> 0) then Continue;
      if (not AEmpty) then Continue;
      LFormat := '';
    end else
    if (a1 = 0) then
    begin
      if (a2 <> 0) or (a3 <> 0) then Continue;
      LFormat := '%s a0';
    end else
    if (a2 = 0) then
    begin
      if (a3 <> 0) then Continue;
      LFormat := '%s a0, %s a1';
    end else
    if (a3 = 0) then
    begin
      LFormat := '%s a0, %s a1, %s a2';
    end else
    begin
      LFormat := '%s a0, %s a1, %s a2, %s a3';
    end;
    LGenCount := Ord(a0 = 1) + Ord(a1 = 1) + Ord(a2 = 1) + Ord(a3 = 1);
    LExtCount := Ord(a0 = 2) + Ord(a1 = 2) + Ord(a2 = 2) + Ord(a3 = 2);

    if (ASignature = isGeneral) then
    begin
      if (LExtCount <> 0) then
        Continue;
    end else
    if (ASignature = isExtended) then
    begin
      if (LGenCount <> 0) then
        Continue;
    end;
    if (ASignature = isGeneralExtended) then
    begin
      LDone := True;
      a[0] := a0;
      a[1] := a1;
      a[2] := a2;
      a[3] := a3;

      for i := 0 to LGenCount - 1 do
      begin
        if (a[i] <> 1) then
        begin
          LDone := False;
          Break;
        end;
      end;

      if (not LDone) then
        Continue;
    end;

    t0 := TYPES[a0];
    t1 := TYPES[a1];
    t2 := TYPES[a2];
    t3 := TYPES[a3];
    LSignatureTitle := INVOKE_TYPE_NAMES[t0] + INVOKE_TYPE_NAMES[t1] + INVOKE_TYPE_NAMES[t2] + INVOKE_TYPE_NAMES[t3];
    LSignature := Format(LFormat, [
      INVOKE_TYPE_KINDS[t0], INVOKE_TYPE_KINDS[t1], INVOKE_TYPE_KINDS[t2], INVOKE_TYPE_KINDS[t3]
      ]);

    if (ARegDeclsArgs) then
    begin
      if (LSignature = '') then
      begin
        LSignature := 'gen eax, gen edx, gen ecx';
      end else
      begin
        LSignature := 'gen eax, gen edx, gen ecx, ' + LSignature;
      end;
    end;

    AProc(LSignatureTitle, LSignature, LGenCount, LExtCount,
      Integer(a0) + (Integer(a1) shl 2) + (Integer(a2) shl 4) + (Integer(a3) shl 6));
  end;
end;

procedure AddDefinePlatforms(const APlatforms: TInvokePlatforms; const ASpaces: Cardinal);
const
  DEFINE_NAMES: array[TInvokePlatform] of string = (
    'CPUX86', 'WIN64', 'POSIXINTEL64', 'CPUARM32', 'CPUARM64');
label
  done;
var
  S: string;
  LPlatforms: TInvokePlatforms;
  LPlatform: TInvokePlatform;
  LDefines: TArray<string>;
  LBuffer: string;
begin
  if (APlatforms = []) or (APlatforms = ALL_INVOKE_PLATFORMS) then
    Exit;

  LPlatforms := APlatforms;
  if (LPlatforms = [ipX64, ipARM32, ipARM64]) then
  begin
    LBuffer := '#if defined (' + DEFINE_NAMES[ipX64] + ') || defined (CPUARM)';
    goto done;
  end;

  for LPlatform := Low(TInvokePlatform) to High(TInvokePlatform) do
  begin
    if (LPlatforms = ALL_INVOKE_PLATFORMS - [LPlatform]) then
    begin
      LBuffer := '#if !defined (' + DEFINE_NAMES[LPlatform] + ')';
      goto done;
    end;
  end;

  if (LPlatforms * [ipWin64, ipX64] = [ipWin64, ipX64]) then
  begin
    if (ipARM64 in LPlatforms) then
    begin
      LPlatforms := LPlatforms - [ipWin64, ipX64, ipARM64];
      LDefines := LDefines + ['LARGEINT'];
    end else
    begin
      LPlatforms := LPlatforms - [ipWin64, ipX64];
      LDefines := LDefines + ['CPUX64'];
    end;
  end;
  if (LPlatforms * [ipX86, ipARM32] = [ipX86, ipARM32]) then
  begin
    LPlatforms := LPlatforms - [ipX86, ipARM32];
    LDefines := LDefines + ['SMALLINT'];
  end;
  if (LPlatforms * [ipX64, ipARM64] = [ipX64, ipARM64]) then
  begin
    LPlatforms := LPlatforms - [ipX64, ipARM64];
    LDefines := LDefines + ['POSIX64'];
  end;
  if (LPlatforms * [ipARM32, ipARM64] = [ipARM32, ipARM64]) then
  begin
    LPlatforms := LPlatforms - [ipARM32, ipARM64];
    LDefines := LDefines + ['CPUARM'];
  end;

  for LPlatform in LPlatforms do
  begin
    LDefines := LDefines + [DEFINE_NAMES[LPlatform]];
  end;

  LBuffer := '#if';
  for S in LDefines do
  begin
    if (Length(LBuffer) > 3) then LBuffer := LBuffer + ' ||';
    LBuffer := LBuffer + ' defined (' + S + ')';
  end;

done:
  Add(string.Create(' ', ASpaces) + LBuffer);
end;

procedure AddEndifPlatforms(const APlatforms: TInvokePlatforms; const ASpaces: Cardinal);
begin
  if (APlatforms = []) or (APlatforms = ALL_INVOKE_PLATFORMS) then
    Exit;

  Add(string.Create(' ',  ASpaces) + '#endif');;
end;

end.
