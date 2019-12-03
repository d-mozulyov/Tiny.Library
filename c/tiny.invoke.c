
#include "tiny.defines.h"
#include "tiny.rtti.h"
#include "tiny.invoke.h"

#if defined (CPUINTEL)
  #define asm_syntax_intel ".intel_syntax noprefix\n\t"
#else
  #define asm_syntax_intel
#endif
#define offsetof(s,m) (size_t)&(((s *)0)->m)

REGISTER_DECL void TinyThrowSafeCall(int32_t code, void* return_address); /*forward*/

/* universal invoke implementation */
REGISTER_DECL NAKED void invoke_universal(RttiSignature* signature, void* address, RttiInvokeDump* dump)
#if defined (CPUX86)
{
    /* Windows32, Linux32, MacOS32 */
    __asm__ volatile
    (
    ".intel_syntax noprefix\n\t"
        "push ebp \n\t"
        "mov ebp, esp \n\t"

        // initialization
        "push esi \n\t"
        "push edi \n\t"
        "sub esp, 12 \n\t"
        "mov esi, eax \n\t" // esi = signature
        "mov edi, ecx \n\t" // edi = dump
        "push edx \n\t" // [ebp - 24] = address

         // stack (large) allocation
        "mov ecx, [ESI + %c[signature_stack_size]] \n\t" // ecx = stack_size
        "lea eax, [ecx + 15] \n\t"
        "shr ecx, 2 \n\t"
        "jz L.call \n\t"
        "and eax, -16 \n\t"
        "cmp ecx, 1020 \n\t" // 4080 bytes
        "jbe L.stack_copy \n\t"
        "sub eax, 4096 \n\t"
    "L.stack_page_alloc: \n\t"
        "push ecx \n\t"
        "sub esp, 4092 \n\t"
        "sub eax, 4096 \n\t"
        "jbe L.stack_page_alloc \n\t"
        "add eax, 4096 \n\t"

        // stack copying
    "L.stack_copy: \n\t"
        "sub esp, eax \n\t"
        "lea edx, [EDI + %c[dump_Stack]] \n\t"
        "xchg eax, edi \n\t"
        "xchg edx, esi \n\t"
        "mov edi, esp \n\t"
        "rep movsd \n\t"
        "xchg eax, edi \n\t"
        "xchg edx, esi \n\t"

        // function calling
    "L.call: \n\t"
        "mov eax, [EDI + %c[dump_RegEAX]] \n\t"
        "mov edx, [EDI + %c[dump_RegEDX]] \n\t"
        "mov ecx, [EDI + %c[dump_RegECX]] \n\t"
        "call [ebp - 24] \n\t"
        "mov [EDI + %c[dump_OutEAX]], eax \n\t"
        "mov [EDI + %c[dump_OutEDX]], edx \n\t"

        // restore registers
        "movzx edx, byte ptr [ESI + %c[signature_return_strategy]] \n\t" // edx = return_strategy
        "mov ecx, edi \n\t" // ecx = dump
        "lea esp, [ebp - 8] \n\t"
        "pop edi \n\t"
        "pop esi \n\t"
        "pop ebp \n\t"

        // return strategy
        "sub edx, 3 \n\t"
        "jb L.done \n\t"
        "jmp [L.return_strategies + edx * 4] \n\t"
    "L.return_strategies: \n\t"
        ".long L.check_safecall \n\t"
        ".long L.fpu_to_int64 \n\t"
        ".long L.fpu_to_longdouble \n\t"
        ".long L.fpu_to_float \n\t"
        ".long L.fpu_to_double \n\t"
    "L.fpu_to_int64: \n\t"
        "fistp qword ptr [ECX + %c[dump_OutInt64]] \n\t"
        "jmp L.done \n\t"
    "L.fpu_to_float: \n\t"
        "fstp dword ptr [ECX + %c[dump_OutFloat]] \n\t"
        "jmp L.done \n\t"
    "L.fpu_to_double: \n\t"
        "fstp qword ptr [ECX + %c[dump_OutDouble]] \n\t"
        "jmp L.done \n\t"
    "L.fpu_to_longdouble: \n\t"
        "fstp tbyte ptr [ECX + %c[dump_OutLongDouble]] \n\t"
        "jmp L.done \n\t"
    "L.check_safecall: \n\t"
        "mov edx, [esp] \n\t"
        "test eax, eax \n\t"
        "jl TinyThrowSafeCall \n\t"

    "L.done: \n\t"
    "ret \n\t"
    :
    :   /* input */
        [signature_stack_size] "n" (offsetof(RttiSignature, dump_options.stack_size)),
        [signature_return_strategy] "n" (offsetof(RttiSignature, dump_options.return_strategy)),

        [dump_RegEAX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegEAX)),
        [dump_RegEDX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegEDX)),
        [dump_RegECX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegECX)),
        [dump_OutEAX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutEAX)),
        [dump_OutEDX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutEDX)),
        [dump_OutInt64] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutInt64)),
        [dump_OutFloat] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutFloat)),
        [dump_OutDouble] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutDouble)),
        [dump_OutLongDouble] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutLongDouble)),

        [dump_Stack] "n" (offsetof(RttiInvokeDump, stack))
    );
}
#elif defined (WIN64)
{
    /* Windows64 */
    __asm__ volatile
    (
    ".intel_syntax noprefix\n\t"
        "push rbp \n\t"
        "sub rsp, 0x1f0 \n\t"
        "mov rbp, rsp \n\t"

        // initialization
        "mov [rbp + %c[stored_Signature]], rcx \n\t"
        "mov [rbp + %c[stored_Address]], rdx \n\t"
        "mov [rbp + %c[stored_Dump]], r8 \n\t"
        "mov rdx, r8 \n\t" // rdx = dump

        // stack copying
        "mov ecx, [RCX + %c[signature_stack_size]] \n\t" // rcx = stack_size
        "shr rcx, 3 \n\t"
        "jz L.call \n\t"
        "xchg rax, rsi \n\t"
        "xchg r8, rdi \n\t"
        "lea rsi, [RDX + %c[dump_Stack]] \n\t"
        "lea rdi, [rsp + 0x20] \n\t"
        "rep movsq \n\t"
        "xchg rax, rsi \n\t"
        "xchg r8, rdi \n\t"

        // function calling
    "L.call: \n\t"
        "mov rcx, [RDX + %c[dump_RegRCX]] \n\t"
        "mov r8, [RDX + %c[dump_RegR8]] \n\t"
        "mov r9, [RDX + %c[dump_RegR9]] \n\t"
        "mov rdx, [RDX + %c[dump_RegRDX]] \n\t"
        "movq xmm0, [RDX + %c[dump_RegXMM0]] \n\t"
        "movq xmm1, [RDX + %c[dump_RegXMM1]] \n\t"
        "movq xmm2, [RDX + %c[dump_RegXMM2]] \n\t"
        "movq xmm3, [RDX + %c[dump_RegXMM3]] \n\t"
        "call [rbp + %c[stored_Address]] \n\t"
        "mov rdx, [rbp + %c[stored_Dump]] \n\t"
        "mov [RDX + %c[dump_OutRAX]], rax \n\t"

        // restore registers
        "mov rcx, [rbp + %c[stored_Signature]] \n\t" // rcx = signature
        "lea rsp, [rbp + 0x1f0] \n\t"
        "pop rbp \n\t"

        // return strategy
        "movzx rcx, byte ptr [RCX + %c[signature_return_strategy]] \n\t"
        "cmp rcx, 3 \n\t"
        "jb L.done \n\t"
        "je L.check_safecall \n\t"

    "L.store_xmm: \n\t"
        "movsd [RDX + %c[dump_OutXMM0]], xmm0 \n\t"
        "jmp L.done \n\t"
    "L.check_safecall: \n\t"
        "mov rdx, [rsp] \n\t"
        "test eax, eax \n\t"
        "xchg rax, rcx \n\t"
        "jl TinyThrowSafeCall \n\t"

    "L.done: \n\t"
    "ret \n\t"
    :
    :   /* input */
        [stored_Signature] "n" (0x208),
        [stored_Address] "n" (0x210),
        [stored_Dump] "n" (0x218),
        [signature_stack_size] "n" (offsetof(RttiSignature, dump_options.stack_size)),
        [signature_return_strategy] "n" (offsetof(RttiSignature, dump_options.return_strategy)),

        [dump_RegRCX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegRCX)),
        [dump_RegRDX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegRDX)),
        [dump_RegR8] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegR8)),
        [dump_RegR9] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegR9)),
        [dump_RegXMM0] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM0)),
        [dump_RegXMM1] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM1)),
        [dump_RegXMM2] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM2)),
        [dump_RegXMM3] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM3)),
        [dump_OutRAX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutRAX)),
        [dump_OutXMM0] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutXMM0)),

        [dump_Stack] "n" (offsetof(RttiInvokeDump, stack))
    );
}
#elif defined (CPUX64)
{
    /* Linux64/MacOS64 */
    __asm__ volatile
    (
    ".intel_syntax noprefix\n\t"
        "push rbp \n\t"
        "mov rbp, rsp \n\t"

        // initialization
        "push rbx \n\t"
        "push rdi \n\t" // [rbp - 16] = signature
        "mov rbx, rdx \n\t" // rbx = dump

        // stack copying
        "mov ecx, [RDI + %c[signature_stack_size]] \n\t" // rcx = stack_size
        "mov rax, rsi \n\t" // rax = address
        "and rcx, -8 \n\t"
        "jz L.call \n\t"
        "sub rsp, rcx \n\t"
        "lea rsi, [RBX + %c[dump_Stack]] \n\t"
        "mov rdi, rsp \n\t"
        "shr rcx, 3 \n\t"
        "rep movsq \n\t"

        // function calling
    "L.call: \n\t"
        "mov rdi, [RBX + %c[dump_RegRDI]] \n\t"
        "mov rsi, [RBX + %c[dump_RegRSI]] \n\t"
        "mov rdx, [RBX + %c[dump_RegRDX]] \n\t"
        "mov rcx, [RBX + %c[dump_RegRCX]] \n\t"
        "mov r8, [RBX + %c[dump_RegR8]] \n\t"
        "mov r9, [RBX + %c[dump_RegR9]] \n\t"
        "movq xmm0, [RBX + %c[dump_RegXMM0]] \n\t"
        "movq xmm1, [RBX + %c[dump_RegXMM1]] \n\t"
        "movq xmm2, [RBX + %c[dump_RegXMM2]] \n\t"
        "movq xmm3, [RBX + %c[dump_RegXMM3]] \n\t"
        "movq xmm4, [RBX + %c[dump_RegXMM4]] \n\t"
        "movq xmm5, [RBX + %c[dump_RegXMM5]] \n\t"
        "movq xmm6, [RBX + %c[dump_RegXMM6]] \n\t"
        "movq xmm7, [RBX + %c[dump_RegXMM7]] \n\t"
        "call rax \n\t"
        "mov [RBX + %c[dump_OutRAX]], rax \n\t"
        "mov [RBX + %c[dump_OutRDX]], rdx \n\t"

        // restore registers
        "mov rcx, [rbp - 16] \n\t" // rcx = signature
        "mov rdx, rbx \n\t" // rdx = dump
        "lea rsp, [rbp - 8] \n\t"
        "pop rbx \n\t"
        "pop rbp \n\t"

        // return strategy
        "movzx rcx, byte ptr [RCX + %c[signature_return_strategy]] \n\t"
        "cmp rcx, 3 \n\t"
        "jb L.done \n\t"
        "je L.check_safecall \n\t"
        "cmp rcx, 5 \n\t"
        "jne L.store_xmm \n\t"
    "L.store_fpu: \n\t"
        "fstp tbyte ptr [RDX + %c[dump_OutLongDouble]] \n\t"
        "jmp L.done \n\t"
    "L.store_xmm: \n\t"
        "movsd [RDX + %c[dump_OutXMM0]], xmm0 \n\t"
        "movsd [RDX + %c[dump_OutXMM1]], xmm1 \n\t"
        "jmp L.done \n\t"
    "L.check_safecall: \n\t"
        "mov rsi, [rsp] \n\t"
        "test eax, eax \n\t"
        "xchg rax, rdi \n\t"
        "jl TinyThrowSafeCall \n\t"

    "L.done: \n\t"
    "ret \n\t"
    :
    :   /* input */
        [signature_stack_size] "n" (offsetof(RttiSignature, dump_options.stack_size)),
        [signature_return_strategy] "n" (offsetof(RttiSignature, dump_options.return_strategy)),

        [dump_RegRDI] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegRDI)),
        [dump_RegRSI] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegRSI)),
        [dump_RegRDX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegRDX)),
        [dump_RegRCX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegRCX)),
        [dump_RegR8] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegR8)),
        [dump_RegR9] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegR9)),
        [dump_RegXMM0] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM0)),
        [dump_RegXMM1] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM1)),
        [dump_RegXMM2] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM2)),
        [dump_RegXMM3] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM3)),
        [dump_RegXMM4] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM4)),
        [dump_RegXMM5] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM5)),
        [dump_RegXMM6] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM6)),
        [dump_RegXMM7] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegXMM7)),
        [dump_OutRAX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutRAX)),
        [dump_OutRDX] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutRDX)),
        [dump_OutXMM0] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutXMM0)),
        [dump_OutXMM1] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutXMM1)),
        [dump_OutLongDouble] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutLongDouble)),

        [dump_Stack] "n" (offsetof(RttiInvokeDump, stack))
    );
}
#elif defined (CPUARM32)
{
    /* Android32, iOS32 */
    __asm__ volatile
    (
        "push {r4, r5, r6, r7, lr} \n\t"
        "add r7, sp, 12 \n\t"
        "sub sp, 4 \n\t"

        // initialization
        "mov r4, r0 \n\t" // r4 = signature
        "mov r5, r1 \n\t" // r5 = address
        "mov r6, r2 \n\t" // r6 = dump

        // stack copying
        "ldr r3, [r4, %[signature_stack_size]] \n\t" // r3 = stack_size
        "bics r3, 3 \n\t"
        "beq L.call \n\t"
        "sub sp, r3 \n\t"
        "add r0, r6, %[dump_Stack] \n\t"
        "mov r1, sp \n\t"
    "L.stack_copy: \n\t"
        "ldmia r0!, {r2} \n\t"
        "stmia r1!, {r2} \n\t"
        "subs r3, 4 \n\t"
        "bne L.stack_copy \n\t"

        // function calling
    "L.call: \n\t"
        "add r0, r6, %[dump_Extendeds] \n\t"
        "add r1, r6, %[dump_Generals] \n\t"
        "vldm r0, {d0, d1, d2, d3, d4, d5, d6, d7} \n\t"
        "ldm r1, {r0, r1, r2, r3} \n\t"
        "blx r5 \n\t"
        "str r0, [r6, %[dump_OutR0]] \n\t"
        "str r1, [r6, %[dump_OutR1]] \n\t"

        // restore registers
        "mov r2, r4 \n\t" // r2 = signature
        "mov r3, r6 \n\t" // r3 = dump
        "sub r1, r7, 12 \n\t"
        "mov sp, r1 \n\t"
        "pop {r4, r5, r6, r7, lr} \n\t"

        // return strategy
        "ldrb r2, [r2, %[signature_return_strategy]] \n\t"
        "cmp r2, 3 \n\t"
        "bcc L.done \n\t"
        "beq L.check_safecall \n\t"
    "L.store_fpu: \n\t"
        "vstr d0, [r3, %[dump_OutD0]] \n\t"
        "vstr d1, [r3, %[dump_OutD1]] \n\t"
        "vstr d2, [r3, %[dump_OutD2]] \n\t"
        "vstr d3, [r3, %[dump_OutD3]] \n\t"
        "b L.done \n\t"
    "L.check_safecall: \n\t"
        "cmp r0, 0 \n\t"
        "bge L.done \n\t"
        "mov r1, lr \n\t"
        "b TinyThrowSafeCall \n\t"

    "L.done: \n\t"
    "bx lr \n\t"
    :
    :   /* input */
        [signature_stack_size] "n" (offsetof(RttiSignature, dump_options.stack_size)),
        [signature_return_strategy] "n" (offsetof(RttiSignature, dump_options.return_strategy)),

        [dump_Generals] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, Generals)),
        [dump_Extendeds] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, Extendeds)),
        [dump_OutR0] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutR0)),
        [dump_OutR1] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutR1)),
        [dump_OutD0] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutHFA) + offsetof(hfa_struct, d0)),
        [dump_OutD1] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutHFA) + offsetof(hfa_struct, d1)),
        [dump_OutD2] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutHFA) + offsetof(hfa_struct, d2)),
        [dump_OutD3] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutHFA) + offsetof(hfa_struct, d3)),

        [dump_Stack] "n" (offsetof(RttiInvokeDump, stack))
    );
}
#else
{
    /* Android64, iOS64 */
    __asm__ volatile
    (
        "stp x29, x30, [sp, -16]! \n\t"
        "mov x29, sp \n\t"

        // initialization
        "stp x0, x2, [sp, -16]! \n\t" // [sp] = signature, dump
        "mov x16, x1 \n\t" // x16 = address
        "mov x17, x2 \n\t" // x17 = dump

        // stack copying
        "ldr w4, [x15, %[signature_stack_size]] \n\t" // x4 = stack_size
        "ands x4, x4, -16 \n\t"
        "beq L.call \n\t"
        "sub sp, sp, x4 \n\t"
        "add x0, x17, %[dump_Stack] \n\t"
        "mov x1, sp \n\t"
    "L.stack_copy: \n\t"
        "ldp x2, x3, [x0], 16 \n\t"
        "stp x2, x3, [x1], 16 \n\t"
        "subs x4, x4, 16 \n\t"
        "bne L.stack_copy \n\t"

        // function calling
    "L.call: \n\t"
        "ldp x0, x1, [x17, %[dump_RegX0]] \n\t"
        "ldp x2, x3, [x17, %[dump_RegX2]] \n\t"
        "ldp x4, x5, [x17, %[dump_RegX4]] \n\t"
        "ldp x6, x7, [x17, %[dump_RegX6]] \n\t"
        "ldr x8, [x17, %[dump_RegX8]] \n\t"
        "ldp d0, d1, [x17, %[dump_RegD0]] \n\t"
        "ldp d2, d3, [x17, %[dump_RegD2]] \n\t"
        "ldp d4, d5, [x17, %[dump_RegD4]] \n\t"
        "ldp d6, d7, [x17, %[dump_RegD6]] \n\t"
        "blr x16 \n\t"
        "ldr x17, [x29, -24] \n\t"
        "stp x0, x1, [x17, %[dump_OutGeneral]] \n\t"

        // restore registers
        "ldr x16, [x29, -32] \n\t" // x16 = signature
        "mov sp, x29  \n\t"
        "ldp x29, x30, [sp], 16 \n\t"

        // return strategy
        "ldrb w16, [x16, %[signature_return_strategy]] \n\t"
        "cmp w16, 3 \n\t"
        "bcc L.done \n\t"
        "beq L.check_safecall \n\t"
    "L.store_fpu: \n\t"
        "stp d0, d1, [x17, %[dump_OutD0]] \n\t"
        "stp d2, d3, [x17, %[dump_OutD2]] \n\t"
        "b L.done \n\t"
    "L.check_safecall: \n\t"
        "cmp w0, 0 \n\t"
        "bge L.done \n\t"
        "mov x1, x30 \n\t"
        "b TinyThrowSafeCall \n\t"

    "L.done: \n\t"
    "ret \n\t"
    :
    :   /* input */
        [signature_stack_size] "n" (offsetof(RttiSignature, dump_options.stack_size)),
        [signature_return_strategy] "n" (offsetof(RttiSignature, dump_options.return_strategy)),

        [dump_RegX0] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegX0)),
        [dump_RegX2] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegX2)),
        [dump_RegX4] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegX4)),
        [dump_RegX6] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegX6)),
        [dump_RegX8] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegX8)),
        [dump_RegD0] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegD0)),
        [dump_RegD2] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegD2)),
        [dump_RegD4] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegD4)),
        [dump_RegD6] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegD6)),
        [dump_OutGeneral] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutGeneral)),
        [dump_OutD0] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutHFA) + offsetof(hfa_struct, d0)),
        [dump_OutD2] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutHFA) + offsetof(hfa_struct, d2)),

        [dump_Stack] "n" (offsetof(RttiInvokeDump, stack))
    );
}
#endif


/*
    Special cases of invokes
*/
typedef size_t gen;
typedef double ext;
typedef long double fpu;
typedef out_general outgen;
typedef hfa_struct hfa;
typedef struct{char a[sizeof(out_general) + 1];} retptr;

#if defined (POSIXINTEL64)
  #define MS_DECL __attribute__((ms_abi))
#else
  #define MS_DECL
#endif
#if defined (CPUX86)
  #define REG_CDECL __attribute__((regparm(3)))
  #define REG_STDCALL __attribute__((stdcall)) __attribute__((regparm(3)))
  #define X86NAKED __attribute__ ((naked))
#else
  #define REG_CDECL
  #define REG_STDCALL
  #define X86NAKED
#endif
#if defined (CPUX86) && defined (MSWINDOWS)
  #define WIN32NAKED __attribute__ ((naked))
#else
  #define WIN32NAKED
#endif

#define dumpregs dump->registers
#define dumpgens dump->registers.Generals
#define dumpexts dump->registers.Extendeds
#define dumpstack dump->stack
#if defined (CPUX86)
  #define dumpsafegen(n) dumpstack[n]
#else
  #define dumpsafegen(n) dumpgens[n]
#endif

#define arm64prefix48 register void* x4 asm("x4") = address; register size_t x8 asm("x8") = dumpregs.RegX8;
#define arm64gen(n) register size_t x##n asm("x" #n) = dumpregs.RegX##n;
#define arm64ext(n) register double d##n asm("d" #n) = dumpregs.RegD##n;
#define arm64gens0
#define arm64gens1 arm64gen(0);
#define arm64gens2 arm64gen(0); arm64gen(1);
#define arm64gens3 arm64gen(0); arm64gen(1); arm64gen(2);
#define arm64gens4 arm64gen(0); arm64gen(1); arm64gen(2); arm64gen(3);
#define arm64gens(n) arm64gens##n
#define arm64exts0
#define arm64exts1 arm64ext(0);
#define arm64exts2 arm64ext(0); arm64ext(1);
#define arm64exts3 arm64ext(0); arm64ext(1); arm64ext(2);
#define arm64exts4 arm64ext(0); arm64ext(1); arm64ext(2); arm64ext(3);
#define arm64exts(n) arm64exts##n
#define arm64registers(gens, exts) arm64prefix48; arm64gens(gens); arm64exts(exts);

#define x86tailstart __asm__ volatile (".intel_syntax noprefix\n\t"
#define x86tailend : : \
  [dumpreg0] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegEAX)), \
  [dumpreg1] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegEDX)), \
  [dumpreg2] "n" (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegECX)), \
  [dumpstack0] "n" (offsetof(RttiInvokeDump, stack[0])), \
  [dumpstack1] "n" (offsetof(RttiInvokeDump, stack[1])), \
  [dumpstack2] "n" (offsetof(RttiInvokeDump, stack[2])), \
  [dumpstack3] "n" (offsetof(RttiInvokeDump, stack[3])) );
#define x86tailpopaddr "pop eax \n\t"
#define x86tailpopaddr0
#define x86tailpopaddr1 x86tailpopaddr
#define x86tailpopaddr2 x86tailpopaddr
#define x86tailpopaddr3 x86tailpopaddr
#define x86tailpopaddr4 x86tailpopaddr
#define x86tailpushaddr "push eax \n\t"
#define x86tailpushaddr0
#define x86tailpushaddr1 x86tailpushaddr
#define x86tailpushaddr2 x86tailpushaddr
#define x86tailpushaddr3 x86tailpushaddr
#define x86tailpushaddr4 x86tailpushaddr
#define x86tailpush0
#define x86tailpush1 "push [ecx + %c[dumpstack0]] \n\t"
#define x86tailpush2 "push [ecx + %c[dumpstack1]] \n\t" x86tailpush1
#define x86tailpush3 "push [ecx + %c[dumpstack2]] \n\t" x86tailpush2
#define x86tailpush4 "push [ecx + %c[dumpstack3]] \n\t" x86tailpush3
#define x86tailpush(n) x86tailpopaddr##n x86tailpush##n  x86tailpushaddr##n
#define x86tailregs0
#define x86tailregs1 "mov eax, [ecx + %c[dumpreg0]] \n\t"
#define x86tailregs2 x86tailregs1 "mov ecx, [ecx + %c[dumpreg1]] \n\t" "xchg edx, ecx \n\t"
#define x86tailregs3 "mov [esp - 4], edx \n\t" x86tailregs1 "mov edx, [ecx + %c[dumpreg1]] \n\t" "mov ecx, [ecx + %c[dumpreg2]] \n\t"
#define x86tailregs(n) x86tailregs##n
#define x86tailjump0 "jmp edx \n\t"
#define x86tailjump1 "jmp edx \n\t"
#define x86tailjump2 "jmp ecx \n\t"
#define x86tailjump3 "jmp [esp - 4] \n\t"
#define x86tailjump(n) x86tailjump##n
#define x86tailfunc(gens, stacks) x86tailstart x86tailpush(stacks) x86tailregs(gens) x86tailjump(gens) x86tailend

#include "tiny.invoke.functypes.inc"
#include "tiny.invoke.funcimpl.inc"

/* detect optimal invoke implementation */
REGISTER_DECL InvokeFunc get_invoke_func(int32_t code/*RttiSignature* signature*/)
{
    if (code >= 0)
    switch (code)
    {
    #include "tiny.invoke.funcswitch.inc"
    };

    return &invoke_universal;
}


#define intercept_frame_basesize (sizeof(RttiRegisters) + sizeof(void*) - platform_stack_retsize)
#define intercept_frame_size ((intercept_frame_basesize + sizeof(void*) + platform_stack_align - 1) & -(platform_stack_align))
#if defined (CPUARM)
  #define intercept_frame_window (sizeof(void*) * 2)
#else
  #define intercept_frame_window (platform_stack_window + platform_stack_align - platform_stack_retsize)
#endif
#define intercept_frame_offset (intercept_frame_window + intercept_frame_size - intercept_frame_basesize)
#if defined (CPUARM)
  #define intercept_frame_decrement (intercept_frame_window + intercept_frame_size - sizeof(void*) * 2)
#else
  #define intercept_frame_decrement (intercept_frame_window + intercept_frame_size)
#endif
#define intercept_frame_general(n) (intercept_frame_offset + offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, Generals) + n * sizeof(((RttiRegisters*)(0))->Generals[0]))
#define intercept_frame_extended(n) (intercept_frame_offset + offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, Extendeds) + n * sizeof(((RttiRegisters*)(0))->Extendeds[0]))

#define intercept_store_generals0
#define intercept_store_extendeds0
#if defined (CPUX86)
  #define intercept_store_generals1 "mov [esp + %c[Gen0]], eax \n\t"
  #define intercept_store_generals2 intercept_store_generals1
  #define intercept_store_generals3 intercept_store_generals2 "mov [esp + %c[Gen2]], ecx \n\t"
#elif defined (WIN64)
  #define intercept_store_generals1 "mov [rsp + %c[Gen0]], rcx \n\t"
  #define intercept_store_generals2 intercept_store_generals1 "mov [rsp + %c[Gen1]], rdx \n\t"
  #define intercept_store_generals3 intercept_store_generals2 "mov [rsp + %c[Gen2]], r8 \n\t"
  #define intercept_store_generals4 intercept_store_generals3 "mov [rsp + %c[Gen3]], r9 \n\t"
  #define intercept_store_extendeds1 "movq [rsp + %c[Ext0]], xmm0 \n\t"
  #define intercept_store_extendeds2 intercept_store_extendeds1 "movq [rsp + %c[Ext1]], xmm1 \n\t"
  #define intercept_store_extendeds3 intercept_store_extendeds2 "movq [rsp + %c[Ext2]], xmm2 \n\t"
  #define intercept_store_extendeds4 intercept_store_extendeds3 "movq [rsp + %c[Ext3]], xmm3 \n\t"
  #define intercept_msabi_store_general0 "mov [rsp + %c[Gen0]], rcx \n\t"
  #define intercept_msabi_store_general1 "mov [rsp + %c[Gen1]], rdx \n\t"
  #define intercept_msabi_store_general2 "mov [rsp + %c[Gen2]], r8 \n\t"
  #define intercept_msabi_store_general3 "mov [rsp + %c[Gen3]], r9 \n\t"
  #define intercept_msabi_store_extended0 "movq [rsp + %c[Ext0]], xmm0 \n\t"
  #define intercept_msabi_store_extended1 "movq [rsp + %c[Ext1]], xmm1 \n\t"
  #define intercept_msabi_store_extended2 "movq [rsp + %c[Ext2]], xmm2 \n\t"
  #define intercept_msabi_store_extended3 "movq [rsp + %c[Ext3]], xmm3 \n\t"
#elif defined (CPUX64)
  #define intercept_store_generals1 "mov [rsp + %c[Gen0]], rdi \n\t"
  #define intercept_store_generals2 intercept_store_generals1 "mov [rsp + %c[Gen1]], rsi \n\t"
  #define intercept_store_generals3 intercept_store_generals2 "mov [rsp + %c[Gen2]], rdx \n\t"
  #define intercept_store_generals4 intercept_store_generals3 "mov [rsp + %c[Gen3]], rcx \n\t"
  #define intercept_store_generals5 intercept_store_generals4 "mov [rsp + %c[Gen4]], r8 \n\t"
  #define intercept_store_generals6 intercept_store_generals5 "mov [rsp + %c[Gen5]], r9 \n\t"
  #define intercept_store_extendeds1 "movq [rsp + %c[Ext0]], xmm0 \n\t"
  #define intercept_store_extendeds2 intercept_store_extendeds1 "movq [rsp + %c[Ext1]], xmm1 \n\t"
  #define intercept_store_extendeds3 intercept_store_extendeds2 "movq [rsp + %c[Ext2]], xmm2 \n\t"
  #define intercept_store_extendeds4 intercept_store_extendeds3 "movq [rsp + %c[Ext3]], xmm3 \n\t"
  #define intercept_store_extendeds5 intercept_store_extendeds4 "movq [rsp + %c[Ext4]], xmm4 \n\t"
  #define intercept_store_extendeds6 intercept_store_extendeds5 "movq [rsp + %c[Ext5]], xmm5 \n\t"
  #define intercept_store_extendeds7 intercept_store_extendeds6 "movq [rsp + %c[Ext6]], xmm6 \n\t"
  #define intercept_store_extendeds8 intercept_store_extendeds7 "movq [rsp + %c[Ext7]], xmm7 \n\t"
  #define intercept_msabi_store_general0 "mov [rsp + %c[Gen3]], rcx \n\t"
  #define intercept_msabi_store_general1 "mov [rsp + %c[Gen2]], rdx \n\t"
  #define intercept_msabi_store_general2 "mov [rsp + %c[Gen4]], r8 \n\t"
  #define intercept_msabi_store_general3 "mov [rsp + %c[Gen5]], r9 \n\t"
  #define intercept_msabi_store_extended0 "movq [rsp + %c[Ext0]], xmm0 \n\t"
  #define intercept_msabi_store_extended1 "movq [rsp + %c[Ext1]], xmm1 \n\t"
  #define intercept_msabi_store_extended2 "movq [rsp + %c[Ext2]], xmm2 \n\t"
  #define intercept_msabi_store_extended3 "movq [rsp + %c[Ext3]], xmm3 \n\t"
#elif defined (CPUARM32)
  #define intercept_store_generals1 "str r0, [sp, %[Gen0]] \n\t"
  #define intercept_store_generals2 "strd r0, r1, [sp, %[Gen0]] \n\t"
  #define intercept_store_generals3 intercept_store_generals2 "str r2, [sp, %[Gen2]] \n\t"
  #define intercept_store_generals4 intercept_store_generals2 "strd r2, r3, [sp, %[Gen2]] \n\t"
  #define intercept_store_extendeds1 "vstr d0, [sp, %[Ext0]] \n\t"
  #define intercept_store_extendeds2 intercept_store_extendeds1 "vstr d1, [sp, %[Ext1]] \n\t"
  #define intercept_store_extended_list(list) "add r3, sp, %[Ext0] \n\t" "vstmia  r3, {" list "} \n\t"
  #define intercept_store_extendeds3 intercept_store_extended_list("d0, d1, d2")
  #define intercept_store_extendeds4 intercept_store_extended_list("d0, d1, d2, d3")
  #define intercept_store_extendeds5 intercept_store_extended_list("d0, d1, d2, d3, d4")
  #define intercept_store_extendeds6 intercept_store_extended_list("d0, d1, d2, d3, d4, d5")
  #define intercept_store_extendeds7 intercept_store_extended_list("d0, d1, d2, d3, d4, d5, d6")
  #define intercept_store_extendeds8 intercept_store_extended_list("d0, d1, d2, d3, d4, d5, d6, d7")
#else
  #define intercept_store_retptr "str x8, [sp, %[Gen8]] \n\t"
  #define intercept_store_generals1 "str x0, [sp, %[Gen0]] \n\t"
  #define intercept_store_generals2 "stp x0, x1, [sp, %[Gen0]] \n\t"
  #define intercept_store_generals3 intercept_store_generals2 "str x2, [sp, %[Gen2]] \n\t"
  #define intercept_store_generals4 intercept_store_generals2 "stp x2, x3, [sp, %[Gen2]] \n\t"
  #define intercept_store_generals5 intercept_store_generals4 "str x4, [sp, %[Gen4]] \n\t"
  #define intercept_store_generals6 intercept_store_generals4 "stp x4, x5, [sp, %[Gen4]] \n\t"
  #define intercept_store_generals7 intercept_store_generals6 "str x6, [sp, %[Gen6]] \n\t"
  #define intercept_store_generals8 intercept_store_generals6 "stp x6, x7, [sp, %[Gen6]] \n\t"
  #define intercept_store_generals9 intercept_store_generals8 intercept_store_retptr
  #define intercept_store_extendeds1 "str d0, [sp, %[Ext0]] \n\t"
  #define intercept_store_extendeds2 "stp d0, d1, [sp, %[Ext0]] \n\t"
  #define intercept_store_extendeds3 intercept_store_extendeds2 "str d2, [sp, %[Ext2]] \n\t"
  #define intercept_store_extendeds4 intercept_store_extendeds2 "stp d2, d3, [sp, %[Ext2]] \n\t"
  #define intercept_store_extendeds5 intercept_store_extendeds4 "str d4, [sp, %[Ext4]] \n\t"
  #define intercept_store_extendeds6 intercept_store_extendeds4 "stp d4, d5, [sp, %[Ext4]] \n\t"
  #define intercept_store_extendeds7 intercept_store_extendeds6 "str d6, [sp, %[Ext6]] \n\t"
  #define intercept_store_extendeds8 intercept_store_extendeds6 "stp d6, d7, [sp, %[Ext6]] \n\t"
#endif
#define intercept_store_generals(n) intercept_store_generals##n
#define intercept_store_extendeds(n) intercept_store_extendeds##n
#define intercept_store(gens, exts) intercept_store_generals(gens) intercept_store_extendeds(exts)

#if defined (CPUARM32)
  #define intercept_ret(n) "bx lr \n\t"
#elif defined (CPUX86)
  #define intercept_ret(n) "ret " #n " * 4 \n\t"
#else
  #define intercept_ret(n) "ret \n\t"
#endif
#define intercept_begin __asm__ volatile ( asm_syntax_intel
#define intercept_end(n) \
  intercept_ret(n) \
  : : \
  [frame_decrement] "n" (intercept_frame_decrement), \
  [frame_window] "n" (intercept_frame_window), \
  [frame_offset] "n" (intercept_frame_offset), \
  [Gen0] "n" (intercept_frame_general(0)), \
  [Gen1] "n" (intercept_frame_general(1)), \
  [Gen2] "n" (intercept_frame_general(2)), \
  [Gen3] "n" (intercept_frame_general(3)), \
  [Gen4] "n" (intercept_frame_general(4)), \
  [Gen5] "n" (intercept_frame_general(5)), \
  [Gen6] "n" (intercept_frame_general(6)), \
  [Gen7] "n" (intercept_frame_general(7)), \
  [Gen8] "n" (intercept_frame_general(8)), \
  [Ext0] "n" (intercept_frame_extended(0)), \
  [Ext1] "n" (intercept_frame_extended(1)), \
  [Ext2] "n" (intercept_frame_extended(2)), \
  [Ext3] "n" (intercept_frame_extended(3)), \
  [Ext4] "n" (intercept_frame_extended(4)), \
  [Ext5] "n" (intercept_frame_extended(5)), \
  [Ext6] "n" (intercept_frame_extended(6)), \
  [Ext7] "n" (intercept_frame_extended(7)), \
  [RetAddr] "n" (intercept_frame_offset + offsetof(RttiInvokeDump, return_address)), \
  [OutBytes] "n" (intercept_frame_offset + offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, OutBytes)), \
  [method_offset] "n" (offsetof(RttiVirtualMethodData, method)), \
  [method_this] "n" (offsetof(RttiVirtualMethodData, callback_this) - offsetof(RttiVirtualMethodData, method)), \
  [method_callback] "n" (offsetof(RttiVirtualMethodData, callback) - offsetof(RttiVirtualMethodData, method)), \
  [method_signature] "n" (offsetof(RttiVirtualMethod, signature)), \
  [signature_return_strategy] "n" (offsetof(RttiSignature, dump_options.return_strategy)), \
  [signature_popsize] "n" (offsetof(RttiSignature, dump_options.stack_size) + sizeof(((RttiSignature*)(0))->dump_options.stack_size)));

#define intercept_load0
#if defined (CPUX86)
  #define intercept_prologue \
    "sub esp, %c[frame_decrement] \n\t" \
    "add edx, %c[method_offset] \n\t"
  #define intercept_epilogue(name) "L.done_" #name ": \n\t" \
    "add esp, %c[frame_decrement] \n\t"
  #define intercept_store_all intercept_store(3, 0)
  #define intercept_call \
    "mov eax, [edx + %c[method_this]] \n\t" \
    "lea ecx, [esp + %c[frame_offset]] \n\t" \
    "call [edx + %c[method_callback]] \n\t"
  #define intercept_load1 "mov eax, [esp + %c[OutBytes]] \n\t" "mov edx, [esp + %c[OutBytes] + 4] \n\t"
  #define intercept_load2 "fld qword ptr [esp + %c[OutBytes]] \n\t"
  #define intercept_load3 "fld tbyte ptr [esp + %c[OutBytes]] \n\t"
  #define intercept_load4 "fld dword ptr [esp + %c[OutBytes]] \n\t"
  #define intercept_load5 "fild qword ptr [esp + %c[OutBytes]] \n\t"
#elif defined (CPUX64)
  #define intercept_prologue \
    "sub rsp, %c[frame_decrement] \n\t" \
    "add rax, %c[method_offset] \n\t"
  #define intercept_epilogue(name) "L.done_" #name ": \n\t" \
    "add rsp, %c[frame_decrement] \n\t"
  #if defined (WIN64)
    #define intercept_store_all intercept_store(4, 4)
    #define intercept_call \
      "mov rcx, [rax + %c[method_this]] \n\t" \
      "mov rdx, rax \n\t" \
      "lea r8, [rsp + %c[frame_offset]] \n\t" \
      "call [rax + %c[method_callback]] \n\t"
    #define intercept_load1 "mov rax, [rsp + %c[OutBytes]] \n\t"
  #else
    #define intercept_store_all intercept_store(6, 8)
    #define intercept_call \
      "mov rdi, [rax + %c[method_this]] \n\t" \
      "mov rsi, rax \n\t" \
      "lea rdx, [rsp + %c[frame_offset]] \n\t" \
      "call [rax + %c[method_callback]] \n\t"
    #define intercept_load1 "mov rax, [rsp + %c[OutBytes]] \n\t" "mov rdx, [rsp + %c[OutBytes] + 8] \n\t"
  #endif
  #define intercept_load2 "movq xmm0, [rsp + %c[OutBytes]] \n\t"
  #if defined (POSIX)
    #define intercept_load3 "fld tbyte ptr [rsp + %c[OutBytes]] \n\t"
    #define intercept_load6 "movq xmm0, [rsp + %c[OutBytes]] \n\t" "movq xmm1, [rsp + %c[OutBytes] + 8] \n\t"
  #endif
#elif defined (CPUARM32)
  #define intercept_prologue \
    "sub sp, sp, %[frame_decrement] \n\t" \
    "push {r7, lr} \n\t" \
    "mov r7, sp \n\t"
  #define intercept_epilogue(name) "L.done_" #name ": \n\t" \
    "pop {r7, lr} \n\t" \
    "add sp, sp, %[frame_decrement] \n\t"
  #define intercept_store_all intercept_store(4, 8)
  #define intercept_call \
    "str lr, [sp, %c[RetAddr]] \n\t" \
    "ldr r0, [r12, %[method_this]] \n\t" \
    "mov r1, r12 \n\t" \
    "add r2, sp, %[frame_offset] \n\t" \
    "ldr r12, [r12, %[method_callback]] \n\t" \
    "blx r12 \n\t"
    #define intercept_load1 "ldrd r0, r1, [sp, %[OutBytes]] \n\t"
    #define intercept_load2 "vldr d0, [sp, %[OutBytes]] \n\t"
    #define intercept_load6 "add r3, sp, %[OutBytes] \n\t" "vldm r3, {d0, d1, d2, d3} \n\t"
#else // ARM64
  #define intercept_prologue \
    "sub sp, sp, %[frame_decrement] \n\t" \
    "stp x29, x30, [sp, -16]! \n\t" \
    "mov x29, sp \n\t"
  #define intercept_epilogue(name) "L.done_" #name ": \n\t" \
    "ldp x29, x30, [sp], %[frame_decrement] + 16 \n\t"
  #define intercept_store_all intercept_store(9, 8)
  #define intercept_call \
    "str x30, [sp, %c[RetAddr]] \n\t" \
    "ldr x0, [x16, %[method_this]] \n\t" \
    "mov x1, x16 \n\t" \
    "add x2, sp, %[frame_offset] \n\t" \
    "ldr x17, [x16, %[method_callback]] \n\t" \
    "blr x17 \n\t"
    #define intercept_load1 "ldp x0, x1, [sp, %[OutBytes]] \n\t"
    #define intercept_load2 "ldr d0, [sp, %[OutBytes]] \n\t"
    #define intercept_load6 "ldp d0, d1, [sp, %[OutBytes]] \n\t" "ldp d2, d3, [sp, %[OutBytes] + 16] \n\t"
#endif
#define intercept_load(n) intercept_load##n


#define intercept_func(name, r, g, e, s) REGISTER_DECL NAKED void intercept_##name() \
{ \
    intercept_begin \
        intercept_prologue " \n\t" \
        intercept_store(g, e) " \n\t" \
        intercept_call " \n\t" \
        intercept_load(r) \
        intercept_epilogue(name) \
    intercept_end(s) \
}

#define intercept_msabi_store_0_0
#define intercept_msabi_store_1_0
#define intercept_msabi_store_2_0
#define intercept_msabi_store_3_0
#define intercept_msabi_store_0_1 intercept_msabi_store_general0
#define intercept_msabi_store_1_1 intercept_msabi_store_general1
#define intercept_msabi_store_2_1 intercept_msabi_store_general2
#define intercept_msabi_store_3_1 intercept_msabi_store_general3
#define intercept_msabi_store_0_2 intercept_msabi_store_extended0
#define intercept_msabi_store_1_2 intercept_msabi_store_extended1
#define intercept_msabi_store_2_2 intercept_msabi_store_extended2
#define intercept_msabi_store_3_2 intercept_msabi_store_extended3

#define intercept_msabi_func(name, r, a0, a1, a2, a3) REGISTER_DECL NAKED void intercept_msabi_##name() \
{ \
    intercept_begin \
        intercept_prologue " \n\t" \
        intercept_msabi_store_0_##a0 \
        intercept_msabi_store_1_##a1 \
        intercept_msabi_store_2_##a2 \
        intercept_msabi_store_3_##a3 " \n\t" \
        intercept_call " \n\t" \
        intercept_load(r) \
        intercept_epilogue(msabi##name) \
    intercept_end(0) \
}

/* universal intercept implementation */
REGISTER_DECL NAKED void intercept_universal()
#if defined (CPUX86)
{
    /* Windows32, Linux32, MacOS32 */
    intercept_begin
        intercept_prologue " \n\t"
        "mov [esp + %c[frame_window]], edx \n\t"
        intercept_store_all " \n\t"
        intercept_call " \n\t"

        "mov ecx, [esp + %c[frame_window]] \n\t"
        "mov ecx, [ecx + %c[method_signature]] \n\t"
        "test ecx, ecx \n\t"
        "jz L.done_u \n\t"

        "movzx edx, byte ptr [ecx + %c[signature_return_strategy]] \n\t"
        "mov ecx, [ecx + %c[signature_popsize]] \n\t"
        "sub edx, 4 \n\t"
        "jb L.generals \n\t"
        "jmp [L.return_strategies_u + edx * 4] \n\t"
    "L.return_strategies_u: \n\t"
        ".long L.fpu_from_int64 \n\t"
        ".long L.fpu_from_longdouble \n\t"
        ".long L.fpu_from_float \n\t"
        ".long L.fpu_from_double \n\t"
    "L.fpu_from_int64: \n\t"
        intercept_load(5)
        "jmp L.done_u \n\t"
    "L.fpu_from_float: \n\t"
        intercept_load(4)
        "jmp L.done_u \n\t"
    "L.fpu_from_double: \n\t"
        intercept_load(2)
        "jmp L.done_u \n\t"
    "L.fpu_from_longdouble: \n\t"
        intercept_load(3)
        "jmp L.done_u \n\t"
    "L.generals: \n\t"
        intercept_load(1)
        intercept_epilogue(u)
    "lea ecx, [esp + ecx + 4] \n\t"
    "xchg esp, ecx \n\t"
    "jmp [ecx] \n\t"
    intercept_end(0)
}
#elif defined (CPUX64)
{
    /* Windows64/Linux64/MacOS64 */
    intercept_begin
        intercept_prologue " \n\t"
    #if defined (POSIX)
        "mov [rsp + %c[frame_window]], rax \n\t"
    #endif
        intercept_store_all " \n\t"
        intercept_call " \n\t"

    #if defined (WIN64)
        intercept_load(1)
        "movq xmm0, rax \n\t"
    #else
        "mov rcx, [rsp + %c[frame_window]] \n\t"
        "mov rcx, [rcx + %c[method_signature]] \n\t"
        "test rcx, rcx \n\t"
        "jz L.done_u \n\t"

        "movzx rcx, byte ptr [rcx + %c[signature_return_strategy]] \n\t"
        intercept_load(1)
        "cmp rcx, 5 \n\t"
        "jb L.done_u \n\t"
        "jne L.load_xmm \n\t"
    "L.load_fpu: \n\t"
        intercept_load(3)
        "jmp L.done_u \n\t"
    "L.load_xmm: \n\t"
        "movq xmm0, rax \n\t"
        "movq xmm1, rdx \n\t"
    #endif

        intercept_epilogue(u)
    intercept_end(0)
}
#elif defined (CPUARM32)
{
    /* Android32, iOS32 */
    intercept_begin
        intercept_prologue " \n\t"
        "str r12, [sp, %c[frame_window]] \n\t"
        intercept_store_all " \n\t"
        intercept_call " \n\t"

        "ldr r12, [sp, %c[frame_window]] \n\t"
        "ldr r12, [r12, %[method_signature]] \n\t"
        "cmp r12, 0 \n\t"
        "beq L.done_u \n\t"
        "ldrb r12, [r12, %[signature_return_strategy]] \n\t"
        intercept_load(1)
        "cmp r12, 6 \n\t"
        "bcc L.done_u \n\t"
        intercept_load(6)

        intercept_epilogue(u)
    intercept_end(0)
}
#else
{
    /* Android64, iOS64 */
    intercept_begin
        intercept_prologue " \n\t"
        "str x16, [sp, %c[frame_window]] \n\t"
        intercept_store_all " \n\t"
        intercept_call " \n\t"

        "ldr x16, [sp, %c[frame_window]] \n\t"
        "ldr x16, [x16, %[method_signature]] \n\t"
        "cbz x16, L.done_u \n\t"
        "ldrb w16, [x16, %[signature_return_strategy]] \n\t"
        intercept_load(1)
        "cmp w16, 6 \n\t"
        "bcc L.done_u \n\t"
        intercept_load(6)

        intercept_epilogue(u)
    intercept_end(0)
}
#endif


#include "tiny.invoke.intr.funcimpl.inc"

/* detect optimal intercept implementation */
REGISTER_DECL void* get_intercept_func(int32_t code/*RttiSignature* signature*/)
{
    if (code >= 0)
    switch (code)
    {
    #include "tiny.invoke.intr.funcswitch.inc"
    };

    return &intercept_universal;
}