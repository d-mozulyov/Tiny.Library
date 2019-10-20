unit Tiny.Invoke;

{******************************************************************************}
{ Copyright (c) Dmitry Mozulyov                                                }
{                                                                              }
{ Permission is hereby granted, free of charge, to any person obtaining a copy }
{ of this software and associated documentation files (the "Software"), to deal}
{ in the Software without restriction, including without limitation the rights }
{ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    }
{ copies of the Software, and to permit persons to whom the Software is        }
{ furnished to do so, subject to the following conditions:                     }
{                                                                              }
{ The above copyright notice and this permission notice shall be included in   }
{ all copies or substantial portions of the Software.                          }
{                                                                              }
{ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   }
{ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     }
{ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  }
{ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       }
{ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,}
{ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN    }
{ THE SOFTWARE.                                                                }
{                                                                              }
{ email: softforyou@inbox.ru                                                   }
{ skype: dimandevil                                                            }
{ repository: https://github.com/d-mozulyov/Tiny.Rtti                          }
{******************************************************************************}

{$I TINY.DEFINES.inc}

{.$ifNdef MSWINDOWS}
  {.$MESSAGE ERROR 'Invoke routine not yet implemented'}
{.$endif}

interface
uses
  Tiny.Rtti;


type

  {$if Defined(IOS) and Defined(CPUARM32) and (CompilerVersion < 28)}
    {$define ARM_NO_VFP_USE}
  {$ifend}

  {$if Defined(CPUX86)}
    TRttiGeneralRegisters = array[0..2] of Integer;
    TRttiExtendedRegisters = packed record end;
    TRttiRegisters = packed record
    case Integer of
      0:
      (
        RegEAX: Integer;
        RegEDX: Integer;
        RegECX: Integer;
        case Integer of
          0: (OutEAX, OutEDX: Integer);
          1: (OutInt64: Int64);
          2: (OutSingle: Single);
          3: (OutDouble: Double);
          4: (OutExtended: Extended; OutFPUAlign: Word);
          5: (OutSafeCall: HRESULT);
          6: (_: packed record end);
      );
      1:
      (
        Generals: array[0..2] of Integer;
        Extendeds: packed record end;
      );
    end;
  {$elseif Defined(CPUX64) and Defined(MSWINDOWS)}
    TRttiGeneralRegisters = array[0..3] of Int64;
    TRttiExtendedRegisters = array[0..3] of Double;
    TRttiRegisters = packed record
    case Integer of
      0:
      (
        RegRCX: Int64;
        RegRDX: Int64;
        RegR8: Int64;
        RegR9: Int64;
        OutXMM0: Double;
        case Integer of
          0: (OutEAX: Integer);
          1: (OutRAX: Int64);
          2: (OutSafeCall: HRESULT);
          3: (_: packed record end);
      );
      1: (Generals: array[0..3] of Int64);
      2: (Extendeds: array[0..3] of Double);
    end;
  {$elseif Defined(CPUX64) and (not Defined(MSWINDOWS))}
    TRttiGeneralRegisters = array[0..5] of Int64;
    TRttiExtendedRegisters = array[0..7] of Double;
    TRttiRegisters = packed record
    case Integer of
      0:
      (
        RegXMM: array [0..7] of Double; {XMM0-XMM7}
        RegR: array [0..5] of Int64;    {RDI, RSI, RDX, RCX, R8, R9}
        OutRAX: Int64;
        OutRDX: Int64;
        OutExtended: Extended;
        StackData: PByte;
        StackDataSize: Integer;
        OutXMM0: Double;
      );
      1:
      (
        Extendeds: array[0..7] of Double;
        Generals: array[0..5] of Int64;
        OutSafeCall: HRESULT;
      );
    end;
  {$elseif Defined(CPUARM32)}
    TRttiGeneralRegisters = array[0..3] of Integer;
    TRttiExtendedRegisters = {$ifdef ARM_NO_VFP_USE}packed record end{$else}array[0..15] of Single{$endif};
    TRttiRegisters = packed record
    case Integer of
      0:
      (
        RegCR: array[0..3] of Integer;
        StackData: PByte;
        StackDataSize: Integer;
        case Integer of
          0: (RegD: array[0..7] of Double);
          1: (RegS: array[0..15] of Single);
          2: (Extendeds: array[0..15] of Single;
              case Integer of
                0: (OutCR: Integer; OutD: Double);
                1: (OutSafeCall: HRESULT);
                2: (_: packed record end);
             );
          3: (__: packed record end);
      );
      1: (Generals: array[0..3] of Integer);
    end;
  {$elseif Defined(CPUARM64)}
    TRttiRegister128 = record
    case Integer of
      1: (Lo, Hi: Int64);
      2: (LL, LH, HL, HH: Cardinal);
    end align 16;
    TRttiRegister128x4 = array[0..3] of TRttiRegister128;
    TRttiHFARegisters = packed record
    case Integer of
      0: (Singles: array[0..3] of Cardinal);
      1: (Doubles: array[0..3] of Int64);
    end;
    TRttiGeneralRegisters = array[0..7] of Int64;
    TRttiExtendedRegisters = array[0..7] of TRttiRegister128;
    TRttiRegisters = packed record
    case Integer of
      0:
      (
        RegX: array[0..7] of Int64;
        RegQ: array[0..7] of TRttiRegister128;
        RegX8: Int64;
        StackData: PByte;
        StackDataSize: Integer;
        OutHFA: TRttiHFARegisters;
        case Integer of
          0: (OutX: Int64; OutQ: TRttiRegister128);
          1: (OutSafeCall: HRESULT);
          2: (_: packed record end);
      );
      1:
      (
        Generals: array[0..7] of Int64;
        case Integer of
          0: (Extendeds: array[0..7] of TRttiRegister128);
          1: (Reg128x4: TRttiRegister128x4);
          2: (__: packed record end);
      );
    end;
  {$else}
    {$MESSAGE ERROR 'Unknown compiler'}
  {$ifend}
  PRttiRegisters = ^TRttiRegisters;

const
  RTTI_GENERAL_REGISTER_SIZE = SizeOf(Pointer);
  {$if Defined(CPUARM32)}
    RTTI_EXTENDED_REGISTER_SIZE = SizeOf(Single);
  {$elseif Defined(CPUARM32)}
    RTTI_EXTENDED_REGISTER_SIZE = SizeOf(TRttiRegister128);
  {$else}
    RTTI_EXTENDED_REGISTER_SIZE = SizeOf(Double);
  {$ifend}
  RTTI_GENERAL_REGISTER_COUNT = SizeOf(TRttiGeneralRegisters) div RTTI_GENERAL_REGISTER_SIZE;
  RTTI_EXTENDED_REGISTER_COUNT = SizeOf(TRttiExtendedRegisters) div RTTI_EXTENDED_REGISTER_SIZE;


type

  PRttiInvokeDump = ^TRttiInvokeDump;
  TRttiInvokeDump = packed object
    Registers: TRttiRegisters;
    MethodIndex: NativeInt;
    ReturnAddress: Pointer;
    {StackData: array[] of Byte;}
  end;


type
  PRttiArgument = ^TRttiArgument;
  TRttiArgument = packed object(TRttiExType)
    Name: PShortStringHelper;
    Offset: Integer;
    GetterStrategy: Byte;
    SetterStrategy: Byte;
  end;

  PRttiAfterCall = ^TRttiAfterCall;
  TRttiAfterCall = (acNone, acSafeCall, acInt64, acLongDouble, acSingle1, acDouble1,
    acSingle2, acDouble2, acSingle3, acDouble3, acSingle4, acDouble4);
  PRttiAfterCalls = ^TRttiAfterCalls;
  TRttiAfterCalls = set of TRttiAfterCall;

  PRttiSignature = ^TRttiSignature;
  PRttiSignatureInvoke = ^TRttiSignatureInvoke;
  TRttiSignatureInvoke = procedure(const ASignature: PRttiSignature;
    const AAddress: Pointer; const AInvokeDump: PRttiInvokeDump);

  TRttiSignature = packed object(TRttiExTypeData)
    CallConv: TRttiCallConv;
    AfterCall: TRttiAfterCall;

    Invoke: TRttiSignatureInvoke;

    SelfOffset: Integer;
    ConstructorFlagOffset: Integer;

    StackDataSize: Integer;
    Result: TRttiArgument;
    ArgumentCount: Integer;
    Arguments: array[Byte] of TRttiArgument;
  end;


  PRttiMethodKind = ^TRttiMethodKind;
  TRttiMethodKind = (
    rmGlobal,
    rmInstantiated,
    rmClass,
    rmClassConstructor,
    rmClassDestructor,
    rmClassStatic,
    rmRecordConstructor,
    rmOperator
  );
  PRttiMethodKinds = ^TRttiMethodKinds;
  TRttiMethodKinds = set of TRttiMethodKind;

//   TLuaMethodKind = (mkStatic, mkInstance, mkClass, mkConstructor, mkDestructor, {ToDo}mkOperator);

(*
  TMethodKind = (mkProcedure, mkFunction, mkConstructor, mkDestructor,
    mkClassProcedure, mkClassFunction
    {$if Defined(FPC) or (CompilerVersion >= 21)}
    , mkClassConstructor, mkClassDestructor, mkOperatorOverload
    {$ifend}
    {$ifNdef FPC}
    , mkSafeProcedure, mkSafeFunction
    {$endif}
    );
*)

  //TMethodKind;

  PRttiMethod = ^TRttiMethod;
  TRttiMethod = packed object
  protected

  public
    Name: PShortStringHelper;
    Kind: TRttiMethodKind;
    Address: Pointer;
    Signature: PRttiSignature;
  end;


implementation


{$ifNdef MSWINDOWS}
const
  RTLHelperLibName =
  {$if Defined(PIC) and Defined(LINUX)}
    'librtlhelper_PIC.a';
  {$else}
    'librtlhelper.a';
  {$ifend}

procedure RawInvoke(const AAddress: Pointer; const AInvokeDump: PRttiInvokeDump);
  external RTLHelperLibName name 'rtti_raw_invoke';
{$endif}

{$if Defined(FPC)}
procedure CheckAutoResult(AResultCode: HResult); [external name 'FPC_SAFECALLCHECK'];
{$elseif not Defined(MSWINDOWS)}
procedure CheckAutoResult(AResultCode: HResult);
begin
  if AResultCode < 0 then
  begin
    if Assigned(SafeCallErrorProc) then
      SafeCallErrorProc(AResultCode, ReturnAddress);
    System.Error(reSafeCallError);
  end;
end;
{$ifend}


{ TRttiSignature }

procedure RttiSignatureStdInvoke(const ASignature: PRttiSignature;
  const AAddress: Pointer; const AInvokeDump: PRttiInvokeDump); {$ifdef FPC}assembler;nostackframe;{$endif}
{$if Defined(CPUX86)}
const
  RTTI_INVOKE_DUMP_SIZE = SizeOf(TRttiInvokeDump);
asm
  push ebp
  mov ebp, esp
  push esi
  push ebx
  mov esi, eax // esi = Signature
  mov ebx, ecx // ebx = InvokeDump
  push edx // [ebp - 12] = Address

  // copy block to stack (native aligned)
  mov ecx, [ESI].TRttiSignature.StackDataSize
  test ecx, ecx
  jz @skip_push
  cmp ecx, 16
  ja @do_push

  // small block
  sub esp, ecx
  shr ecx, 2
  jmp [offset @move_cases + ecx * 4 - 4]
  @move_cases: DD @move_4, @move_8, @move_12, @move_16

@do_push:
  test ecx, ecx
{$ifdef ALIGN_STACK}
  mov eax, ecx
  and eax, 15
  jz @no_align
  sub eax, 16
  add esp, eax
@no_align:
{$endif ALIGN_STACK}
  // touch stack pages in case it needs to grow
  // while (count > 0) { touch(stack); stack -= 4096; count -= 4096; }
  mov eax, ecx
  jmp @touch_loop_begin

@touch_loop:
  mov [esp],0
@touch_loop_begin:
  sub esp, 4096
  sub eax, 4096
  jns @touch_loop
  sub esp, eax

  lea eax, [ebx + RTTI_INVOKE_DUMP_SIZE]
  mov edx, esp
  push offset @skip_push
  jmp System.Move // eax = source, edx = dest, ecx = count

@move_16:
  mov edx, [ebx + RTTI_INVOKE_DUMP_SIZE + 12]
  mov [esp + 12], edx
@move_12:
  mov edx, [ebx + RTTI_INVOKE_DUMP_SIZE + 8]
  mov [esp + 8], edx
@move_8:
  mov edx, [ebx + RTTI_INVOKE_DUMP_SIZE + 4]
  mov [esp + 4], edx
@move_4:
  mov edx, [ebx + RTTI_INVOKE_DUMP_SIZE]
  mov [esp], edx

@skip_push:
  // call
  mov   eax, [EBX].TRttiInvokeDump.Registers.RegEAX
  mov   edx, [EBX].TRttiInvokeDump.Registers.RegEDX
  mov   ecx, [EBX].TRttiInvokeDump.Registers.RegECX
  call  [ebp - 12]
  mov   [EBX].TRttiInvokeDump.Registers.OutEAX, eax
  mov   [EBX].TRttiInvokeDump.Registers.OutEDX, edx

  // restore registers
  movzx edx, byte ptr [ESI].TRttiSignature.AfterCall
  mov ecx, ebx // InvokeDump
  lea esp, [ebp - 8]
  pop ebx
  pop esi
  pop ebp

  // after call
  test edx, edx
  jz @done
  jmp [offset @after_calls + edx * 4 - 4]
  @after_calls: DD @safecall, @fpu_to_int64, @fpu_to_longdouble, @fpu_to_single, @fpu_to_double

@fpu_to_int64:
  fistp qword ptr [ECX].TRttiInvokeDump.Registers.OutInt64
  jmp @done
@fpu_to_single:
  fstp dword ptr [ECX].TRttiInvokeDump.Registers.OutSingle
  jmp @done
@fpu_to_double:
  fstp qword ptr [ECX].TRttiInvokeDump.Registers.OutDouble
  jmp @done
@fpu_to_longdouble:
  fstp tbyte ptr [ECX].TRttiInvokeDump.Registers.OutExtended
  jmp @done
@safecall:
  test eax, eax
  {$ifdef FPC}
  jl CheckAutoResult
  {$else .DELPHI}
  jl System.@CheckAutoResult
  {$endif}
@done:
end;
{$elseif Defined(CPUX64) and Defined(MSWINDOWS)}
const
  RTTI_INVOKE_DUMP_SIZE = SizeOf(TRttiInvokeDump);

  procedure InvokeError(const AReturnAddress: Pointer); far;
  begin
    System.ErrorAddr := AReturnAddress;
    System.ExitCode := 207{reInvalidOp};
    System.Halt;
  end;
asm
  {$ifNdef FPC}.NOFRAME{$endif}
  // .PARAMS 62
  // there's actually room for 64, assembler is saving locals for Self, Address & Dump
  push rbp
  sub rsp, $1f0
  mov rbp, rsp

  mov [rbp + $208], rcx // Signature
  mov [rbp + $210], rdx // Address
  mov [rbp + $218], r8 // InvokeDump
  xchg rdx, r8 // rdx = InvokeDump

  // copy block to stack (native aligned)
  mov  eax, [RCX].TRttiSignature.StackDataSize
  test eax, eax
  jz @skip_push

  // small/System.Move
  cmp eax, 32
  ja @do_move
  shr rax, 3
  lea rcx, [@move_cases - 8]
  mov rcx, [rcx + rax * 8]
  jmp rcx
  @move_cases: DQ @move_8, @move_16, @move_24, @move_32

@do_move:
  cmp eax, 480 // (64-4) params * 8 bytes.
  ja @invalid_frame
  lea rcx, [rdx + RTTI_INVOKE_DUMP_SIZE]
  lea rdx, [rbp + $20]
  xchg r8, rax
  call System.Move
  mov rdx, [rbp + $218]
  jmp @skip_push

@invalid_frame:
  lea rsp, [rbp + $1f0]
  pop rbp
  mov rcx, [rsp]
  jmp InvokeError

@move_32:
  mov rax, [rdx + RTTI_INVOKE_DUMP_SIZE + 24]
  mov [rbp + $20 + 24], rax
@move_24:
  mov rax, [rdx + RTTI_INVOKE_DUMP_SIZE + 16]
  mov [rbp + $20 + 16], rax
@move_16:
  mov rax, [rdx + RTTI_INVOKE_DUMP_SIZE + 8]
  mov [rbp + $20 + 8], rax
@move_8:
  mov rax, [rdx + RTTI_INVOKE_DUMP_SIZE]
  mov [rbp + $20], rax

@skip_push:
  // call
  mov rcx, [RDX].TRttiInvokeDump.Registers.RegRCX
  mov r8, [RDX].TRttiInvokeDump.Registers.RegR8
  mov r9, [RDX].TRttiInvokeDump.Registers.RegR9
  mov rdx, [RDX].TRttiInvokeDump.Registers.RegRDX
  movq xmm0, rcx
  movq xmm1, rdx
  movq xmm2, r8
  movq xmm3, r9
  call [rbp + $210]
  mov rdx, [rbp + $218]
  mov [RDX].TRttiInvokeDump.Registers.OutRAX, rax
  movsd [RDX].TRttiInvokeDump.Registers.OutXMM0, xmm0

  // restore registers
  mov rcx, [rbp + $208] // Signature
  lea rsp, [rbp + $1f0]
  pop rbp

  // after call (safecall check)
  test eax, eax
  jge @ret
  cmp byte ptr [RCX].TRttiSignature.AfterCall, 1
  xchg rax, rcx
  {$ifdef FPC}
  je CheckAutoResult
  {$else .DELPHI}
  je System.@CheckAutoResult
  {$endif}
@ret:
end;
{$elseif Defined(CPUX64)} {!MSWINDOWS}
var
  LStoredXMM0: Double;
begin
  LStoredXMM0 := AInvokeDump.Registers.RegXMM[0];
  try
    AInvokeDump.Registers.StackData := Pointer(NativeInt(AInvokeDump) + SizeOf(TRttiInvokeDump));
    AInvokeDump.Registers.StackDataSize := ASignature.StackDataSize;
    RawInvoke(AAddress, AInvokeDump);

    AInvokeDump.Registers.OutXMM0 := AInvokeDump.Registers.RegXMM[0];
  finally
    AInvokeDump.Registers.RegXMM[0] := LStoredXMM0;
  end;

  if (ASignature.AfterCall = acSafeCall) and (AInvokeDump.Registers.OutSafeCall < 0) then
    CheckAutoResult(AInvokeDump.Registers.OutSafeCall);
end;
{$elseif Defined(CPUARM32)}
var
  LStoredCR: Integer;
  LStoredD: Double;
begin
  LStoredCR := AInvokeDump.Registers.RegCR[0];
  LStoredD := AInvokeDump.Registers.RegD[0];
  try
    AInvokeDump.Registers.StackData := Pointer(NativeInt(AInvokeDump) + SizeOf(TRttiInvokeDump));
    AInvokeDump.Registers.StackDataSize := ASignature.StackDataSize;
    RawInvoke(AAddress, AInvokeDump);

    AInvokeDump.Registers.OutCR := AInvokeDump.Registers.RegCR[0];
    AInvokeDump.Registers.OutD := AInvokeDump.Registers.RegD[0];
  finally
    AInvokeDump.Registers.RegCR[0] := LStoredCR;
    AInvokeDump.Registers.RegD[0] := LStoredD;
  end;

  if (ASignature.AfterCall = acSafeCall) and (AInvokeDump.Registers.OutSafeCall < 0) then
    CheckAutoResult(AInvokeDump.Registers.OutSafeCall);
end;
{$else .CPUARM64}
var
  LStoredX: Int64;
  LStored128x4: TRttiRegister128x4;
  LAfterCall: TRttiAfterCall;
begin
  LStoredX := AInvokeDump.Registers.RegX[0];
  LStored128x4 := AInvokeDump.Registers.Reg128x4;
  try
    AInvokeDump.Registers.StackData := Pointer(NativeInt(AInvokeDump) + SizeOf(TRttiInvokeDump);
    AInvokeDump.Registers.StackDataSize := ASignature.StackDataSize;
    RawInvoke(AAddress, AInvokeDump);

    AInvokeDump.Registers.OutX := AInvokeDump.Registers.RegX[0];
    AInvokeDump.Registers.OutQ := AInvokeDump.Registers.RegQ[0];

    LAfterCall := ASignature.AfterCall;
    if (LAfterCall >= acSingle1) then
    begin
      if (LAfterCall in [acSingle1, acSingle2, acSingle3, acSingle4) then
      begin
        AInvokeDump.Registers.OutHFA.Singles[0] := AInvokeDump.Registers.RegQ[0].LL;
        AInvokeDump.Registers.OutHFA.Singles[1] := AInvokeDump.Registers.RegQ[1].LL;
        AInvokeDump.Registers.OutHFA.Singles[2] := AInvokeDump.Registers.RegQ[2].LL;
        AInvokeDump.Registers.OutHFA.Singles[3] := AInvokeDump.Registers.RegQ[3].LL;
      end else
      begin
        AInvokeDump.Registers.OutHFA.Doubles[0] := AInvokeDump.Registers.RegQ[0].Lo;
        AInvokeDump.Registers.OutHFA.Doubles[1] := AInvokeDump.Registers.RegQ[1].Lo;
        AInvokeDump.Registers.OutHFA.Doubles[2] := AInvokeDump.Registers.RegQ[2].Lo;
        AInvokeDump.Registers.OutHFA.Doubles[3] := AInvokeDump.Registers.RegQ[3].Lo;
      end;
    end;
  finally
    AInvokeDump.Registers.RegX[0] := LStoredX;
    AInvokeDump.Registers.Reg128x4 := LStored128x4;
  end;

  if (ASignature.AfterCall = acSafeCall) and (AInvokeDump.Registers.OutSafeCall < 0) then
    CheckAutoResult(AInvokeDump.Registers.OutSafeCall);
end;
{$ifend}

end.
