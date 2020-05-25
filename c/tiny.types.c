#include "tiny.types.h"


/*
    Tagged pointer routine
*/

#include "tiny.types.taggedimpl.inc"


/*
    Standard Delphi ReturnAddress equivalent
*/

NAKED
void* ReturnAddress()
{
    __asm__ volatile
    (
#if defined (CPUX86)
    ".intel_syntax noprefix \n\t"
    "mov eax, [ebp + 4] \n\t"
    "ret \n\t"
#elif defined (CPUX64)
    ".intel_syntax noprefix \n\t"
    "mov rax, [rbp + 8] \n\t"
    "ret \n\t"
#elif defined (CPUARM32)
    "ldr r0, [r7, 4] \n\t"
    "bx lr \n\t"
#else
    "ldr x0, [x29, 8] \n\t"
    "ret \n\t"
#endif
    );
}


/*
    Lightweight error routine
*/

#if !defined (DELPHI)
REGISTER_DECL void* TinyErrorSafeCall(int32_t code, void* return_address)
{
    native_int ncode = code;
    char16_t* message = (char16_t*)ncode;
    return TinyError(ERRORCODE_SAFECALLERROR, message, return_address);
}

REGISTER_DECL void* TinyErrorOutOfMemory(void* return_address)
{
    return TinyError(ERRORCODE_OUTOFMEMORY, 0, return_address?return_address:RETURN_ADDRESS);
}

REGISTER_DECL void* TinyErrorRange(void* return_address)
{
    return TinyError(ERRORCODE_RANGEERROR, 0, return_address?return_address:RETURN_ADDRESS);
}

REGISTER_DECL void* TinyErrorIntOverflow(void* return_address)
{
    return TinyError(ERRORCODE_INTOVERFLOW, 0, return_address?return_address:RETURN_ADDRESS);
}

REGISTER_DECL void* TinyErrorInvalidCast(void* return_address)
{
    return TinyError(ERRORCODE_INVALIDCAST, 0, return_address?return_address:RETURN_ADDRESS);
}

REGISTER_DECL void* TinyErrorInvalidPtr(void* return_address)
{
    return TinyError(ERRORCODE_INVALIDPTR, 0, return_address?return_address:RETURN_ADDRESS);
}

REGISTER_DECL void* TinyErrorInvalidOp(void* return_address)
{
    return TinyError(ERRORCODE_INVALIDOP, 0, return_address?return_address:RETURN_ADDRESS);
}
#endif


/*
    Memory management
*/

// asmmove_reg_size = size (count)
// asmmove_reg_base = 16x count * 8
#if defined (WIN64)
  #define asmmove_reg_size asm_regr
  #define asmmove_regd_size asm_regdr
  #define asmmove_regw_size asm_regwr
  #define asmmove_regb_size asm_regbr
#else
  #define asmmove_reg_size asm_reg2
  #define asmmove_regd_size asm_regd2
  #define asmmove_regw_size asm_regw2
  #define asmmove_regb_size asm_regb2
#endif
#if defined (CPUX86)
  #define asmmove_reg_base "ebx"
#elif defined (CPUX64)
  #define asmmove_reg_base "rbx"
#endif

#if defined (CPUINTEL)
NAKED
NOINLINE REGISTER_DECL64 void TinyMove(void* source, void* target, native_uint count)
{
assembler_begin
    // count > 64? goto move_large
    asm_op("cmp", asm_reg2, "64")
    #if defined (WIN64)
      asm_op("xchg", asmmove_reg_size, asm_reg2)
    #elif defined (POSIXINTEL64)
      asm_nop(2)
    #endif
    asm_ja(move_large)

    // count >= 16? goto move_16plus : goto move_cases[]
    asm_op("sub", asmmove_reg_size, "16")
    asm_ja(move_16plus)
    asm_je(move_16)
    asm_switch_offs(move_cases, asmmove_reg_size, "16")
    asm_nop(1)

asm_label(move_16plus)
    // count > 32? goto move_3364 : goto move_1732
    asm_op("cmp", asm_reg1, asm_reg0)
    asm_je(move_0)
    asm_op("cmp", asmmove_reg_size, "32 - 16")
    asm_ja(move_3364)
    #if defined (CPUX64)
      asm_nop(1)
    #endif
asm_label(move_1732)
    asm_op("movups", "xmm0", asm_addr(asm_reg0))
    asm_op("movups", "xmm1", asm_addrx(asm_reg0, asmmove_reg_size, "16 - 16"))
    asm_op("movups", asm_addr(asm_reg1), "xmm0")
    asm_op("movups", asm_addrx(asm_reg1, asmmove_reg_size, "16 - 16"), "xmm1")
    asm_ret
    #if defined (CPUX86)
      asm_nop(4)
    #elif defined (CPUX64)
      asm_nop(1)
    #endif
asm_label(move_16)
    asm_op("movups", "xmm0", asm_addr(asm_reg0))
    asm_op("movups", asm_addr(asm_reg1), "xmm0")
asm_label(move_0)
    asm_ret
    #if defined (CPUX86)
      asm_nop(1)
    #elif defined (CPUX64)
      asm_nop(9)
    #endif

asm_label(move_cases)
    asm_case(move_0)
    asm_case(move_1)
    asm_case(move_2)
    asm_case(move_3)
    asm_case(move_4)
    asm_case(move_5)
    asm_case(move_6)
    asm_case(move_7)
    asm_case(move_8)
    asm_case(move_9)
    asm_case(move_10)
    asm_case(move_11)
    asm_case(move_12)
    asm_case(move_13)
    asm_case(move_14)
    asm_case(move_15)
asm_label(move_4)
    asm_op("mov", asm_regd0, asm_addr(asm_reg0))
    asm_op("mov", asm_addr(asm_reg1), asm_regd0)
    asm_ret
    asm_nop(3)
asm_label(move_8)
    #if defined (CPUX86)
      asm_cmd("fild qword ptr [eax]")
      asm_cmd("fistp qword ptr [edx]")
      asm_ret
      asm_nop(3)
    #elif defined (CPUX64)
      asm_op("mov", asm_reg0, asm_addr(asm_reg0))
      asm_op("mov", asm_addr(asm_reg1), asm_reg0)
      asm_ret
      asm_nop(1)
    #endif
asm_label(move_1)
    asm_op("movzx", asmmove_regd_size, "byte ptr " asm_addr(asm_reg0))
    asm_op("mov", asm_addr(asm_reg1), asmmove_regb_size)
    asm_ret
    asm_nop(2)
asm_label(move_2)
    asm_op("movzx", asmmove_regd_size, "word ptr " asm_addr(asm_reg0))
    asm_op("mov", asm_addr(asm_reg1), asmmove_regw_size)
    asm_ret
    asm_nop(1)
asm_label(move_3)
    #if defined (CPUX86)
      asm_op("movzx", asmmove_regd_size, "word ptr " asm_addr(asm_reg0))
      asm_op("movzx", asm_regd0, "byte ptr " asm_address(asm_reg0, "2"))
      asm_op("mov", asm_addr(asm_reg1), asmmove_regw_size)
      asm_op("mov", asm_address(asm_reg1, "2"), asm_regb0)
    #elif defined (CPUX64)
      asm_op("movzx", asmmove_regd_size, "word ptr " asm_addr(asm_reg0))
      asm_op("movzx", "ecx", "byte ptr " asm_address(asm_reg0, "2"))
      asm_op("mov", asm_addr(asm_reg1), asmmove_regw_size)
      asm_op("mov", asm_address(asm_reg1, "2"), "cl")
    #endif
    asm_ret
    asm_nop(2)

asm_label(move_5)
    asm_op("mov", asmmove_regd_size, asm_addr(asm_reg0))
    asm_op("mov", asm_regd0, asm_address(asm_reg0, "5 - 4"))
    asm_op("mov", asm_addr(asm_reg1), asmmove_regd_size)
    asm_op("mov", asm_address(asm_reg1, "5 - 4"), asm_regd0)
    asm_ret
    asm_nop(5)
asm_label(move_6)
    asm_op("mov", asmmove_regd_size, asm_addr(asm_reg0))
    asm_op("mov", asm_regd0, asm_address(asm_reg0, "6 - 4"))
    asm_op("mov", asm_addr(asm_reg1), asmmove_regd_size)
    asm_op("mov", asm_address(asm_reg1, "6 - 4"), asm_regd0)
    asm_ret
    asm_nop(5)
asm_label(move_7)
    asm_op("mov", asmmove_regd_size, asm_addr(asm_reg0))
    asm_op("mov", asm_regd0, asm_address(asm_reg0, "7 - 4"))
    asm_op("mov", asm_addr(asm_reg1), asmmove_regd_size)
    asm_op("mov", asm_address(asm_reg1, "7 - 4"), asm_regd0)
    asm_ret
    asm_nop(5)
asm_label(move_9)
asm_label(move_10)
asm_label(move_11)
asm_label(move_12)
    #if defined (CPUX86)
      asm_cmd("fild qword ptr [eax]")
      asm_cmd("mov eax, [eax + ecx + 16 - 4]")
      asm_cmd("fistp qword ptr [edx]")
      asm_cmd("mov [edx + ecx + 16 - 4], eax")
      asm_ret
      asm_nop(3)
    #elif defined (CPUX64)
      asm_op("mov", "r8", asm_addr(asm_reg0))
      asm_op("mov", asm_regd0, asm_addrx(asm_reg0, asmmove_reg_size, "16 - 4"))
      asm_op("mov", asm_addr(asm_reg1), "r8")
      asm_op("mov", asm_addrx(asm_reg1, asmmove_reg_size, "16 - 4"), asm_regd0)
      asm_ret
      asm_nop(1)
    #endif
asm_label(move_13)
asm_label(move_14)
asm_label(move_15)
    #if defined (CPUX86)
      asm_cmd("fild qword ptr [eax]")
      asm_cmd("fild qword ptr [eax + ecx + 16 - 8]")
      asm_cmd("fistp qword ptr [edx + ecx + 16 - 8]")
      asm_cmd("fistp qword ptr [edx]")
      asm_ret
      asm_nop(3)
    #elif defined (CPUX64)
      asm_op("mov", "r8", asm_addr(asm_reg0))
      asm_op("mov", asm_reg0, asm_addrx(asm_reg0, asmmove_reg_size, "16 - 8"))
      asm_op("mov", asm_addr(asm_reg1), "r8")
      asm_op("mov", asm_addrx(asm_reg1, asmmove_reg_size, "16 - 8"), asm_reg0)
      asm_ret
      asm_nop(15)
      asm_nop(16)
      asm_nop(16)
    #endif

asm_label(move_3364)
    // count <= 48? goto move_3348 : goto move_4964
    asm_op("cmp", asmmove_regd_size, "48 - 16")
    asm_jbe(move_3348)
asm_label(move_4964)
    asm_op("movups", "xmm0", asm_address(asm_reg0, "0"))
    asm_op("movups", "xmm1", asm_address(asm_reg0, "16"))
    asm_op("movups", "xmm2", asm_address(asm_reg0, "32"))
    asm_op("movups", "xmm3", asm_addrx(asm_reg0, asmmove_reg_size, "16 - 16"))
    asm_op("movups", asm_address(asm_reg1, "0"), "xmm0")
    asm_op("movups", asm_address(asm_reg1, "16"), "xmm1")
    asm_op("movups", asm_address(asm_reg1, "32"), "xmm2")
    asm_op("movups", asm_addrx(asm_reg1, asmmove_reg_size, "16 - 16"), "xmm3")
    asm_ret
asm_label(move_3348)
    asm_op("movups", "xmm0", asm_address(asm_reg0, "0"))
    asm_op("movups", "xmm1", asm_address(asm_reg0, "16"))
    asm_op("movups", "xmm2", asm_addrx(asm_reg0, asmmove_reg_size, "16 - 16"))
    asm_op("movups", asm_address(asm_reg1, "0"), "xmm0")
    asm_op("movups", asm_address(asm_reg1, "16"), "xmm1")
    asm_op("movups", asm_addrx(asm_reg1, asmmove_reg_size, "16 - 16"), "xmm2")
asm_label(move_done)
    asm_ret
    asm_nop(5)
    asm_nop(16)

asm_label(move_large)
    asm_op("cmp", asm_reg1, asm_reg0)
    asm_je(move_done)
    asm_op("sub", asmmove_reg_size, "16")
    // 16x count * 8
    asm_uop("push", asmmove_reg_base)
    asm_op("lea", asmmove_reg_base, asm_address(asmmove_reg_size, "-1"))
    asm_op("shr", asmmove_reg_base, "4")
    asm_op("shl", asmmove_reg_base, "3")
    // forward/backward
    #if defined (CPUX64)
      asm_op("lea", "r11", asm_addr("rip + " asm_label_name(forward_move_bottom)))
    #endif
    asm_op("cmp", asm_reg1, asm_reg0)
    asm_jb(forward_move)
    #if defined (CPUX86)
      asm_cmd("push eax")
      asm_cmd("lea eax, [eax + ecx + 16]")
      asm_cmd("cmp eax, edx")
      asm_cmd("pop eax")
    #elif defined (CPUX64)
      asm_op("lea", "r9", asm_addrx(asm_reg0, asmmove_reg_size, "16"))
      asm_op("cmp", "r9", asm_reg1)
    #endif
    asm_jbe(forward_move)
    asm_op("lea", asm_reg0, asm_addrx(asm_reg0, asmmove_reg_size, "16"))
    asm_op("lea", asm_reg1, asm_addrx(asm_reg1, asmmove_reg_size, "16"))
    #if defined (CPUX64)
      asm_op("lea", "r11", asm_addr("rip + " asm_label_name(backward_move_bottom)))
    #endif
    asm_jmp(backward_move)
    #if defined (CPUX86)
      asm_nop(4)
    #elif defined (CPUX64)
      asm_nop(6)
      asm_nop(16)
      asm_nop(16)
    #endif

asm_label(forward_move_loop)
    #if defined (CPUX86)
      asm_cmd("lea eax, [eax + 128]")
      asm_cmd("lea edx, [edx + 128]")
      asm_cmd("lea ecx, [ecx - 128]")
      asm_nop(1)
    #elif defined (CPUX64)
      asm_op("sub", asm_reg0, "-128")
      asm_op("sub", asm_reg1, "-128")
      asm_op("add", asmmove_reg_size, "-128")
      asm_op("test", asmmove_reg_base, asmmove_reg_base)
      asm_nop(1)
    #endif
    asm_label(forward_move_16x8)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "-128"))
      asm_op("movups", asm_address(asm_reg1, "-128"), "xmm0")
    asm_label(forward_move_16x7)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "-112"))
      asm_op("movups", asm_address(asm_reg1, "-112"), "xmm0")
    asm_label(forward_move_16x6)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "-96"))
      asm_op("movups", asm_address(asm_reg1, "-96"), "xmm0")
    asm_label(forward_move_16x5)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "-80"))
      asm_op("movups", asm_address(asm_reg1, "-80"), "xmm0")
    asm_label(forward_move_16x4)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "-64"))
      asm_op("movups", asm_address(asm_reg1, "-64"), "xmm0")
    asm_label(forward_move_16x3)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "-48"))
      asm_op("movups", asm_address(asm_reg1, "-48"), "xmm0")
    asm_label(forward_move_16x2)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "-32"))
      asm_op("movups", asm_address(asm_reg1, "-32"), "xmm0")
    asm_label(forward_move_16x1)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "-16"))
      asm_op("movups", asm_address(asm_reg1, "-16"), "xmm0")
    asm_label(forward_move_bottom)
      asm_jbe(forward_move_done)
      asm_nop(6)
    asm_label(forward_move)
      asm_op("sub", asmmove_reg_base, "8 * 8")
      asm_jae(forward_move_loop)
      asm_op("lea", asm_reg0, asm_addrx2(asm_reg0, asmmove_reg_base, "128"))
      asm_op("lea", asm_reg1, asm_addrx2(asm_reg1, asmmove_reg_base, "128"))
      asm_op("lea", asmmove_reg_base, asm_address(asmmove_reg_base, "8 * 8"))
      asm_uop("neg", asmmove_reg_base)
      asm_op("lea", asmmove_reg_size, asm_addrx2(asmmove_reg_size, asmmove_reg_base, "0"))
      #if defined (CPUX86)
        asm_op("lea", "ebx", asm_address("ebx", asm_label_name(forward_move_bottom)))
      #elif defined (CPUX64)
        asm_cmd("lea rbx, [rbx + r11]")
      #endif
      asm_uop("jmp", asmmove_reg_base)
      #if defined (CPUX86)
        asm_nop(5)
      #elif defined (CPUX64)
        asm_nop(1)
      #endif
    asm_label(forward_move_done)
      asm_uop("pop", asmmove_reg_base)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "0"))
      asm_op("movups", "xmm1", asm_addrx(asm_reg0, asmmove_reg_size, "16 - 16"))
      asm_op("movups", asm_address(asm_reg1, "0"), "xmm0")
      asm_op("movups", asm_addrx(asm_reg1, asmmove_reg_size, "16 - 16"), "xmm1")
      asm_ret

asm_label(backward_move_loop)
    asm_op("lea", asm_reg0, asm_address(asm_reg0, "-128"))
    asm_op("lea", asm_reg1, asm_address(asm_reg1, "-128"))
    asm_op("lea", asmmove_reg_size, asm_address(asmmove_reg_size, "-128"))
    #if defined (CPUX86)
      asm_nop(7)
    #elif defined (CPUX64)
      asm_nop(4)
    #endif
    asm_label(backward_move_16x8)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "112"))
      asm_op("movups", asm_address(asm_reg1, "112"), "xmm0")
    asm_label(backward_move_16x7)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "96"))
      asm_op("movups", asm_address(asm_reg1, "96"), "xmm0")
    asm_label(backward_move_16x6)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "80"))
      asm_op("movups", asm_address(asm_reg1, "80"), "xmm0")
    asm_label(backward_move_16x5)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "64"))
      asm_op("movups", asm_address(asm_reg1, "64"), "xmm0")
    asm_label(backward_move_16x4)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "48"))
      asm_op("movups", asm_address(asm_reg1, "48"), "xmm0")
    asm_label(backward_move_16x3)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "32"))
      asm_op("movups", asm_address(asm_reg1, "32"), "xmm0")
    asm_label(backward_move_16x2)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "16"))
      asm_op("movups", asm_address(asm_reg1, "16"), "xmm0")
    asm_label(backward_move_16x1)
      asm_op("movups", "xmm0", asm_address(asm_reg0, "0"))
      asm_op("movups", asm_address(asm_reg1, "0"), "xmm0")
      asm_jbe(backward_move_done)
    asm_label(backward_move_bottom)
    asm_label(backward_move)
      asm_op("sub", asmmove_reg_base, "8 * 8")
      asm_jae(backward_move_loop)
      asm_op("lea", asmmove_reg_base, asm_address(asmmove_reg_base, "8 * 8"))
      asm_uop("neg", asmmove_reg_base)
      asm_op("lea", asm_reg0, asm_addrx2(asm_reg0, asmmove_reg_base, "0"))
      asm_op("lea", asm_reg1, asm_addrx2(asm_reg1, asmmove_reg_base, "0"))
      asm_op("lea", asmmove_reg_size, asm_addrx2(asmmove_reg_size, asmmove_reg_base, "0"))
      #if defined (CPUX86)
        asm_op("lea", "ebx", asm_address("ebx", asm_label_name(backward_move_bottom)))
      #elif defined (CPUX64)
        asm_cmd("lea rbx, [rbx + r11]")
      #endif
      asm_uop("jmp", asmmove_reg_base)
      #if defined (CPUX86)
        asm_nop(5)
      #elif defined (CPUX64)
        asm_nop(1)
      #endif

    asm_label(backward_move_done)
      asm_uop("pop", asmmove_reg_base)
      asm_uop("neg", asmmove_reg_size)
      asm_op("movups", "xmm0", asm_addrx(asm_reg0, asmmove_reg_size, "-16"))
      asm_op("movups", "xmm1", asm_address(asm_reg0, "-16"))
      asm_op("movups", asm_addrx(asm_reg1, asmmove_reg_size, "-16"), "xmm0")
      asm_op("movups", asm_address(asm_reg1, "-16"), "xmm1")
      asm_ret
      #if defined (CPUX86)
        asm_nop(7)
        asm_nop(16)
        asm_nop(16)
      #elif defined (CPUX64)
        asm_nop(6)
        asm_nop(16)
        asm_nop(16)
      #endif
assembler_end
}
#else
NOINLINE REGISTER_DECL void TinyMove_large(void* source, void* target, native_uint count);

NOINLINE REGISTER_DECL64 void TinyMove(void* source, void* target, native_uint count)
{
    uint8_t* s = source;
    uint8_t* t = target;
    uint8_t b;
    uint16_t w;
    uint32_t c0, c1;
    data8 q0, q1;
    data16 x0, x1, x2, x3;

    if (s == t) return;
    if (count > 64)
    {
        TinyMove_large(source, target, count);
        return;
    }

    if (count <= 16)
    {
        if (count != 16)
        {
            void *move_cases[16] = {&&move_0, &&move_1, &&move_2, &&move_3, &&move_4, &&move_5, &&move_6, &&move_7,
                &&move_8, &&move_9, &&move_10, &&move_11, &&move_12, &&move_13, &&move_14, &&move_15};
            goto *move_cases[count];
        }
        else
        {
            *((data16*)t) = *((data16*)s);
        move_0:
            return;
        }

    move_4:
        *((uint32_t*)t) = *((uint32_t*)s);
        return;
    move_8:
        *((data8*)t) = *((data8*)s);
        return;
    move_1:
        *((uint8_t*)t) = *((uint8_t*)s);
        return;
    move_2:
        *((uint16_t*)t) = *((uint16_t*)s);
        return;
    move_3:
        w = *((uint16_t*)s);
        b = *((uint8_t*)(s + 2));
        *((uint16_t*)t) = w;
        *((uint8_t*)(t + 2)) = b;
        return;
    move_5:
        c0 = *((uint32_t*)s);
        c1 = *((uint32_t*)(s + 5 - 4));
        *((uint32_t*)t) = c0;
        *((uint32_t*)(t + 5 - 4)) = c1;
        return;
    move_6:
        c0 = *((uint32_t*)s);
        c1 = *((uint32_t*)(s + 6 - 4));
        *((uint32_t*)t) = c0;
        *((uint32_t*)(t + 6 - 4)) = c1;
        return;
    move_7:
        c0 = *((uint32_t*)s);
        c1 = *((uint32_t*)(s + 7 - 4));
        *((uint32_t*)t) = c0;
        *((uint32_t*)(t + 7 - 4)) = c1;
        return;
    move_9:
    move_10:
    move_11:
    move_12:
        q0 = *((data8*)s);
        c1 = *((uint32_t*)(s + count - 4));
        *((data8*)t) = q0;
        *((uint32_t*)(t + count - 4)) = c1;
        return;
    move_13:
    move_14:
    move_15:
        q0 = *((data8*)s);
        q1 = *((data8*)(s + count - 8));
        *((data8*)t) = q0;
        *((data8*)(t + count - 8)) = q1;
        return;
    }
    else
    if (count <= 32)
    {
        x0 = *((data16*)(s + 0));
        x1 = *((data16*)(s + count - 16));
        *((data16*)(t + 0)) = x0;
        *((data16*)(t + count - 16)) = x1;
    }
    else
    if (count >= 49)
    {
        x0 = *((data16*)(s + 0));
        x1 = *((data16*)(s + 16));
        x2 = *((data16*)(s + 32));
        x3 = *((data16*)(s + count - 16));
        *((data16*)(t + 0)) = x0;
        *((data16*)(t + 16)) = x1;
        *((data16*)(t + 32)) = x2;
        *((data16*)(t + count - 16)) = x3;
    }
    else
    {
        x0 = *((data16*)(s + 0));
        x1 = *((data16*)(s + 16));
        x2 = *((data16*)(s + count - 16));
        *((data16*)(t + 0)) = x0;
        *((data16*)(t + 16)) = x1;
        *((data16*)(t + count - 16)) = x2;
    }
}

NOINLINE REGISTER_DECL64 void TinyMove_large(void* source, void* target, native_uint count)
{
    uint8_t* s = source;
    uint8_t* t = target;
    data16 x0, x1;
    native_uint base;

    if (t < s || (s + count) <= t) goto forward_move;
    s += count;
    t += count;
    goto backward_move;

    forward_move_loop:
        s += 128;
        t += 128;
        count -= 128;
    forward_move_16x8:
        *((data16*)(t - 128)) = *((data16*)(s - 128));
    forward_move_16x7:
        *((data16*)(t - 112)) = *((data16*)(s - 112));
    forward_move_16x6:
        *((data16*)(t - 96)) = *((data16*)(s - 96));
    forward_move_16x5:
        *((data16*)(t - 80)) = *((data16*)(s - 80));
    forward_move_16x4:
        *((data16*)(t - 64)) = *((data16*)(s - 64));
    forward_move_16x3:
        *((data16*)(t - 48)) = *((data16*)(s - 48));
    forward_move_16x2:
        *((data16*)(t - 32)) = *((data16*)(s - 32));
    forward_move_16x1:
        *((data16*)(t - 16)) = *((data16*)(s - 16));
    forward_move_bottom:
    if (count > 32)
    {
    forward_move:
        if (count >= (32 + 128)) goto forward_move_loop;

        base = (count - 17) & ((native_uint)-16);
        s += base;
        t += base;
        count -= base;
        void *forward_cases[8] = {
            &&forward_move_16x1, &&forward_move_16x2, &&forward_move_16x3, &&forward_move_16x4,
            &&forward_move_16x5, &&forward_move_16x6, &&forward_move_16x7, &&forward_move_16x8};
        goto *forward_cases[(base >> 4) - 1];
    }
    else
    {
        x0 = *((data16*)(s + 0));
        x1 = *((data16*)(s + count - 16));
        *((data16*)(t + 0)) = x0;
        *((data16*)(t + count - 16)) = x1;
        return;
    }

    backward_move_loop:
        s -= 128;
        t -= 128;
        count -= 128;
    backward_move_16x8:
        *((data16*)(t + 112)) = *((data16*)(s + 112));
    backward_move_16x7:
        *((data16*)(t + 96)) = *((data16*)(s + 96));
    backward_move_16x6:
        *((data16*)(t + 80)) = *((data16*)(s + 80));
    backward_move_16x5:
        *((data16*)(t + 64)) = *((data16*)(s + 64));
    backward_move_16x4:
        *((data16*)(t + 48)) = *((data16*)(s + 48));
    backward_move_16x3:
        *((data16*)(t + 32)) = *((data16*)(s + 32));
    backward_move_16x2:
        *((data16*)(t + 16)) = *((data16*)(s + 16));
    backward_move_16x1:
        *((data16*)(t + 0)) = *((data16*)(s + 0));
    backward_move_bottom:
    if (count > 32)
    {
    backward_move:
        if (count >= (32 + 128)) goto backward_move_loop;

        base = (count - 17) & ((native_uint)-16);
        s -= base;
        t -= base;
        count -= base;
        void *backward_cases[8] = {
            &&backward_move_16x1, &&backward_move_16x2, &&backward_move_16x3, &&backward_move_16x4,
            &&backward_move_16x5, &&backward_move_16x6, &&backward_move_16x7, &&backward_move_16x8};
        goto *backward_cases[(base >> 4) - 1];
    }
    else
    {
        x0 = *((data16*)(s - count));
        x1 = *((data16*)(s - 16));
        *((data16*)(t - count)) = x0;
        *((data16*)(t - 16)) = x1;
        return;
    }
}
#endif


/*
    String routine
*/

REGISTER_DECL64 native_uint AStrLen(char8_t* chars)
{
    if (!chars) return 0;

    static native_uint arr[sizeof(native_uint) / sizeof(char8_t)] = {
        0,
        ((native_uint)1 << (8 * 1)) - 1,
        ((native_uint)1 << (8 * 2)) - 1,
        ((native_uint)1 << (8 * 3)) - 1
    #if defined (LARGEINT)
        ,
        ((native_uint)1 << (8 * 4)) - 1,
        ((native_uint)1 << (8 * 5)) - 1,
        ((native_uint)1 << (8 * 6)) - 1,
        ((native_uint)1 << (8 * 7)) - 1
    #endif
    };

    char8_t* s = (char8_t*)((native_int)chars & -sizeof(native_uint));
    native_uint index = (native_int)chars & (sizeof(native_uint) - 1);
    native_uint x = *((native_uint*)s) | arr[index];

    for (;;x = *((native_uint*)s))
    {
        native_uint u = x - MASK_01_NATIVE;
        x = ~x & u;
        if (x & MASK_80_NATIVE) break;
        s += sizeof(native_uint);
    }
    s += bit_fastindex(x & MASK_80_NATIVE) >> 3;

    return ((native_uint)s - (native_uint)chars);
}

REGISTER_DECL64 native_uint WStrLen(char16_t* chars)
{
    if (!chars) return 0;

    if ((native_int)chars & 1)
    {
        char16_t* _s = chars;
        for (;;)
        {
            if (*_s == 0) break;
            _s++;
        }
        return ((native_uint)_s - (native_uint)chars) >> 1;
    }

    static native_uint arr[sizeof(native_uint) / sizeof(char16_t)] = {
        0,
        ((native_uint)1 << (16 * 1)) - 1
    #if defined (LARGEINT)
        ,
        ((native_uint)1 << (16 * 2)) - 1,
        ((native_uint)1 << (16 * 3)) - 1
    #endif
    };

    char8_t* s = (char8_t*)((native_int)chars & -sizeof(native_uint));
    native_uint index = ((native_int)chars & (sizeof(native_uint) - 1)) >> 1;
    native_uint x = *((native_uint*)s) | arr[index];

    for (;;x = *((native_uint*)s))
    {
    #if defined (SMALLINT)
        if ((x & 0x0000ffff) == 0) break;
        s += sizeof(char16_t);
        if ((x & 0xffff0000) == 0) break;
        s += sizeof(char16_t);
    #else
        native_uint u = x - MASK_0001_NATIVE;
        x = ~x & u;
        if (x & MASK_8000_NATIVE) break;
        s += sizeof(native_uint);
    #endif
    }
    #if defined (LARGEINT)
    s += (bit_fastindex(x & MASK_8000_NATIVE) >> 4) * sizeof(char16_t);
    #endif

    return ((native_uint)s - (native_uint)chars) >> 1;
}

REGISTER_DECL64 native_uint CStrLen(char32_t* chars)
{
    if (!chars) return 0;

    char32_t* s = chars;
    for (;;)
    {
        if (*s == 0) break;
        s++;
    }

    return ((native_uint)s - (native_uint)chars) >> 2;
}

#if defined (MSWINDOWS)
REGISTER_DECL void WStrClear(void* value)
{
    RtlWideStrRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        MMSysStrFree(rec);
    }
}

REGISTER_DECL void* WStrInit(void* value, char16_t* chars, uint32_t length)
{
    RtlWideStrRec* rec = *((ptr_t*)value);

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->size == length * sizeof(char16_t))
            {
                if (chars && (void*)rec != chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
                return rec;
            }
            else
            {
                if (MMSysStrRealloc(value, chars, length)) return *((ptr_t*)value);
                TinyErrorOutOfMemory(RETURN_ADDRESS);
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            MMSysStrFree(rec);
        }
    }
    else
    if (length)
    {
        ptr_t s = MMSysStrAlloc(chars, length);
        if (s)
        {
            *((ptr_t*)value) = s;
            return s;
        }
        else
        {
            TinyErrorOutOfMemory(RETURN_ADDRESS);
        }
    }

    return 0;
}

REGISTER_DECL void* WStrReserve(void* value, uint32_t length)
{
    if (!length) return 0;
    RtlWideStrRec* rec = *((ptr_t*)value);

    if (rec)
    {
        if ((rec - 1)->size >= length * sizeof(char16_t)) return rec;
        if (MMSysStrRealloc(value, 0, length)) return *((ptr_t*)value);
        TinyErrorOutOfMemory(RETURN_ADDRESS);
    }
    else
    {
        ptr_t s = MMSysStrAlloc(0, length);
        if (s)
        {
            *((ptr_t*)value) = s;
            return s;
        }
        else
        {
            TinyErrorOutOfMemory(RETURN_ADDRESS);
        }
    }

    return 0;
}

REGISTER_DECL void* WStrSetLength(void* value, uint32_t length)
{
    RtlWideStrRec* rec = *((ptr_t*)value);

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->size == length * sizeof(char16_t)) return rec;
            if (!MMSysStrRealloc(value, (void*)rec, length)) return *((ptr_t*)value);
            TinyErrorOutOfMemory(RETURN_ADDRESS);
        }
        else
        {
            *((ptr_t*)value) = 0;
            MMSysStrFree(rec);
        }
    }
    else
    if (length)
    {
        ptr_t s = MMSysStrAlloc(0, length);
        if (s)
        {
            *((ptr_t*)value) = s;
        }
        else
        {
            TinyErrorOutOfMemory(RETURN_ADDRESS);
        }
    }

    return 0;
}
#endif

REGISTER_DECL void AStrClear_new(void* value)
{
    RtlStrRec_new* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release_new(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void AStrClear_nextgen(void* value)
{
    RtlStrRec_nextgen* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release_nextgen(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void AStrClear_fpc(void* value)
{
    RtlStrRec_fpc* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release_fpc(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void UStrClear_new(void* value)
{
    RtlStrRec_new* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release_new(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void UStrClear_fpc(void* value)
{
    RtlStrRec_fpc* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release_fpc(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void CStrClear(void* value)
{
    RtlDynArray* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_dynarray_release(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void CStrClear_fpc(void* value)
{
    RtlDynArray_fpc* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_dynarray_release_fpc(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void* AStrInit_new(void* value, char8_t* chars, uint32_t length, uint16_t codepage)
{
    RtlStrRec_new* rec = *((ptr_t*)value);

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->length == length)
            {
                if ((void*)rec != chars && chars) goto copy;
                return rec;
            }
            if ((rec - 1)->refcount == 1 && rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
            {
                rtl_rec_realloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                goto markup;
            }
            else
            {
                *((ptr_t*)value) = 0;
                rtl_string_release_new(rec, RETURN_ADDRESS, 0);
                goto allocate;
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_lstr_markup_new(rec, length, codepage);
    copy:
        *((ptr_t*)value) = rec;
        if (chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
        return rec;
    }

    return 0;
}

REGISTER_DECL void* AStrInit_nextgen(void* value, char8_t* chars, uint32_t length, uint16_t codepage)
{
    RtlStrRec_nextgen* rec = *((ptr_t*)value);

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->length == length)
            {
                if ((void*)rec != chars && chars) goto copy;
                return rec;
            }
            if ((rec - 1)->refcount == 1 && rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
            {
                rtl_rec_realloc_nextgen(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                goto markup;
            }
            else
            {
                *((ptr_t*)value) = 0;
                rtl_string_release_nextgen(rec, RETURN_ADDRESS, 0);
                goto allocate;
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_nextgen(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_nextgen(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_lstr_markup_nextgen(rec, length, codepage);
    copy:
        *((ptr_t*)value) = rec;
        if (chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
        return rec;
    }

    return 0;
}

REGISTER_DECL void* AStrInit_fpc(void* value, char8_t* chars, uint32_t length, uint16_t codepage)
{
    RtlStrRec_fpc* rec = *((ptr_t*)value);

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->length == length)
            {
                if ((void*)rec != chars && chars) goto copy;
                return rec;
            }
            if ((rec - 1)->refcount == 1 && rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
            {
                rtl_rec_realloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                goto markup;
            }
            else
            {
                *((ptr_t*)value) = 0;
                rtl_string_release_fpc(rec, RETURN_ADDRESS, 0);
                goto allocate;
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_fpc(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_lstr_markup_fpc(rec, length, codepage);
    copy:
        *((ptr_t*)value) = rec;
        if (chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
        return rec;
    }

    return 0;
}

REGISTER_DECL void* UStrInit_new(void* value, char16_t* chars, uint32_t length)
{
    RtlStrRec_new* rec = *((ptr_t*)value);

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->length == length)
            {
                if ((void*)rec != chars && chars) goto copy;
                return rec;
            }
            if ((rec - 1)->refcount == 1 && rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
            {
                rtl_rec_realloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                goto markup;
            }
            else
            {
                *((ptr_t*)value) = 0;
                rtl_string_release_new(rec, RETURN_ADDRESS, 0);
                goto allocate;
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_ustr_markup_new(rec, length);
    copy:
        *((ptr_t*)value) = rec;
        if (chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
        return rec;
    }

    return 0;
}

REGISTER_DECL void* UStrInit_fpc(void* value, char16_t* chars, uint32_t length)
{
    RtlStrRec_fpc* rec = *((ptr_t*)value);

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->length == length)
            {
                if ((void*)rec != chars && chars) goto copy;
                return rec;
            }
            if ((rec - 1)->refcount == 1 && rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
            {
                rtl_rec_realloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                goto markup;
            }
            else
            {
                *((ptr_t*)value) = 0;
                rtl_string_release_fpc(rec, RETURN_ADDRESS, 0);
                goto allocate;
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_fpc(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_ustr_markup_fpc(rec, length);
    copy:
        *((ptr_t*)value) = rec;
        if (chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
        return rec;
    }

    return 0;
}

REGISTER_DECL void* CStrInit(void* value, char32_t* chars, uint32_t length)
{
    RtlDynArray* rec = *((ptr_t*)value);

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->length == length)
            {
                if ((void*)rec != chars && chars) goto copy;
                return rec;
            }
            if ((rec - 1)->refcount == 1 && rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
            {
                rtl_rec_realloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                goto markup;
            }
            else
            {
                *((ptr_t*)value) = 0;
                rtl_dynarray_release(rec, RETURN_ADDRESS, 0);
                goto allocate;
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_dynarray_release(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_cstr_markup(rec, length);
    copy:
        *((ptr_t*)value) = rec;
        if (chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
        return rec;
    }

    return 0;
}

REGISTER_DECL void* CStrInit_fpc(void* value, char32_t* chars, uint32_t length)
{
    RtlDynArray_fpc* rec = *((ptr_t*)value);

    if (rec)
    {
        if (length)
        {
            if (((rec - 1)->high + 1) == length)
            {
                if ((void*)rec != chars && chars) goto copy;
                return rec;
            }
            if ((rec - 1)->refcount == 1 && rtl_rec_hintrealloc(((rec - 1)->high + 1), sizeof(*chars), length))
            {
                rtl_rec_realloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                goto markup;
            }
            else
            {
                *((ptr_t*)value) = 0;
                rtl_dynarray_release_fpc(rec, RETURN_ADDRESS, 0);
                goto allocate;
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_dynarray_release_fpc(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_cstr_markup_fpc(rec, length);
    copy:
        *((ptr_t*)value) = rec;
        if (chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
        return rec;
    }

    return 0;
}

REGISTER_DECL void* AStrReserve_new(void* value, uint32_t length)
{
    RtlStrRec_new* rec = *((ptr_t*)value);
    char8_t* chars/*none*/;

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->refcount == 1)
            {
                if ((rec - 1)->length >= length) return rec;
                if (rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
                {
                    rtl_rec_realloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                    goto markup;
                }
            }

            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
            goto allocate;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_lstr_markup_new(rec, length, DefaultCP);
        *((ptr_t*)value) = rec;
        return rec;
    }

    return 0;
}

REGISTER_DECL void* AStrReserve_nextgen(void* value, uint32_t length)
{
    RtlStrRec_nextgen* rec = *((ptr_t*)value);
    char8_t* chars/*none*/;

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->refcount == 1)
            {
                if ((rec - 1)->length >= length) return rec;
                if (rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
                {
                    rtl_rec_realloc_nextgen(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                    goto markup;
                }
            }

            *((ptr_t*)value) = 0;
            rtl_string_release_nextgen(rec, RETURN_ADDRESS, 0);
            goto allocate;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_nextgen(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_nextgen(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_lstr_markup_nextgen(rec, length, DefaultCP);
        *((ptr_t*)value) = rec;
        return rec;
    }

    return 0;
}

REGISTER_DECL void* AStrReserve_fpc(void* value, uint32_t length)
{
    RtlStrRec_fpc* rec = *((ptr_t*)value);
    char8_t* chars/*none*/;

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->refcount == 1)
            {
                if ((rec - 1)->length >= length) return rec;
                if (rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
                {
                    rtl_rec_realloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                    goto markup;
                }
            }

            *((ptr_t*)value) = 0;
            rtl_string_release_fpc(rec, RETURN_ADDRESS, 0);
            goto allocate;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_fpc(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_lstr_markup_fpc(rec, length, DefaultCP);
        *((ptr_t*)value) = rec;
        return rec;
    }

    return 0;
}

REGISTER_DECL void* UStrReserve_new(void* value, uint32_t length)
{
    RtlStrRec_new* rec = *((ptr_t*)value);
    char16_t* chars/*none*/;

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->refcount == 1)
            {
                if ((rec - 1)->length >= length) return rec;
                if (rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
                {
                    rtl_rec_realloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                    goto markup;
                }
            }

            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
            goto allocate;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_ustr_markup_new(rec, length);
        *((ptr_t*)value) = rec;
        return rec;
    }

    return 0;
}

REGISTER_DECL void* UStrReserve_fpc(void* value, uint32_t length)
{
    RtlStrRec_fpc* rec = *((ptr_t*)value);
    char16_t* chars/*none*/;

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->refcount == 1)
            {
                if ((rec - 1)->length >= length) return rec;
                if (rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
                {
                    rtl_rec_realloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                    goto markup;
                }
            }

            *((ptr_t*)value) = 0;
            rtl_string_release_fpc(rec, RETURN_ADDRESS, 0);
            goto allocate;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_fpc(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_ustr_markup_fpc(rec, length);
        *((ptr_t*)value) = rec;
        return rec;
    }

    return 0;
}

REGISTER_DECL void* CStrReserve(void* value, uint32_t length)
{
    RtlDynArray* rec = *((ptr_t*)value);
    char32_t* chars/*none*/;

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->refcount == 1)
            {
                if ((rec - 1)->length >= length) return rec;
                if (rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
                {
                    rtl_rec_realloc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                    goto markup;
                }
            }

            *((ptr_t*)value) = 0;
            rtl_dynarray_release(rec, RETURN_ADDRESS, 0);
            goto allocate;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_dynarray_release(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_cstr_markup(rec, length);
        *((ptr_t*)value) = rec;
        return rec;
    }

    return 0;
}

REGISTER_DECL void* CStrReserve_fpc(void* value, uint32_t length)
{
    RtlDynArray_fpc* rec = *((ptr_t*)value);
    char32_t* chars/*none*/;

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->refcount == 1)
            {
                if (((rec - 1)->high + 1) >= length) return rec;
                if (rtl_rec_hintrealloc(((rec - 1)->high + 1), sizeof(*chars), length))
                {
                    rtl_rec_realloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                    goto markup;
                }
            }

            *((ptr_t*)value) = 0;
            rtl_dynarray_release_fpc(rec, RETURN_ADDRESS, 0);
            goto allocate;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_dynarray_release_fpc(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_fpc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_cstr_markup_fpc(rec, length);
        *((ptr_t*)value) = rec;
        return rec;
    }

    return 0;
}

REGISTER_DECL void* AStrSetLength_new(void* value, uint32_t length, uint16_t codepage)
{
    RtlStrRec_new* source = *((ptr_t*)value);
    RtlStrRec_new* target;
    char8_t* chars/*none*/;

    if (source)
    {
        if (length)
        {
            if ((source - 1)->refcount != 1 || (source - 1)->length != length) goto allocate;
            (source - 1)->cpelemsize = ((uint32_t)codepage) + 0x10000;
            return source;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(source, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(target, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
        rtl_lstr_markup_new(target, length, codepage);
        *((ptr_t*)value) = target;
        if (source)
        {
            if (length > (source - 1)->length) length = (source - 1)->length;
            rtl_memcopy(target, source, length * sizeof(*chars));
            rtl_string_release_new(source, RETURN_ADDRESS, 0);
        }

        return target;
    }

    return 0;
}

REGISTER_DECL void* AStrSetLength_nextgen(void* value, uint32_t length, uint16_t codepage)
{
    RtlStrRec_nextgen* source = *((ptr_t*)value);
    RtlStrRec_nextgen* target;
    char8_t* chars/*none*/;

    if (source)
    {
        if (length)
        {
            if ((source - 1)->refcount != 1 || (source - 1)->length != length) goto allocate;
            return source;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_nextgen(source, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_nextgen(target, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
        rtl_lstr_markup_nextgen(target, length, codepage);
        *((ptr_t*)value) = target;
        if (source)
        {
            if (length > (source - 1)->length) length = (source - 1)->length;
            rtl_memcopy(target, source, length * sizeof(*chars));
            rtl_string_release_nextgen(source, RETURN_ADDRESS, 0);
        }

        return target;
    }

    return 0;
}

REGISTER_DECL void* AStrSetLength_fpc(void* value, uint32_t length, uint16_t codepage)
{
    RtlStrRec_fpc* source = *((ptr_t*)value);
    RtlStrRec_fpc* target;
    char8_t* chars/*none*/;

    if (source)
    {
        if (length)
        {
            if ((source - 1)->refcount != 1 || (source - 1)->length != length) goto allocate;
            (source - 1)->cpelemsize = ((uint32_t)codepage) + 0x10000;
            return source;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_fpc(source, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_fpc(target, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
        rtl_lstr_markup_fpc(target, length, codepage);
        *((ptr_t*)value) = target;
        if (source)
        {
            if (length > (source - 1)->length) length = (source - 1)->length;
            rtl_memcopy(target, source, length * sizeof(*chars));
            rtl_string_release_fpc(source, RETURN_ADDRESS, 0);
        }

        return target;
    }

    return 0;
}

REGISTER_DECL void* UStrSetLength_new(void* value, uint32_t length)
{
    RtlStrRec_new* source = *((ptr_t*)value);
    RtlStrRec_new* target;
    char16_t* chars/*none*/;

    if (source)
    {
        if (length)
        {
            if ((source - 1)->refcount != 1 || (source - 1)->length != length) goto allocate;
            (source - 1)->cpelemsize = USTR_CPELEMSIZE;
            return source;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(source, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(target, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
        rtl_ustr_markup_new(target, length);
        *((ptr_t*)value) = target;
        if (source)
        {
            if (length > (source - 1)->length) length = (source - 1)->length;
            rtl_memcopy(target, source, length * sizeof(*chars));
            rtl_string_release_new(source, RETURN_ADDRESS, 0);
        }

        return target;
    }

    return 0;
}

REGISTER_DECL void* UStrSetLength_fpc(void* value, uint32_t length)
{
    RtlStrRec_fpc* source = *((ptr_t*)value);
    RtlStrRec_fpc* target;
    char16_t* chars/*none*/;

    if (source)
    {
        if (length)
        {
            if ((source - 1)->refcount != 1 || (source - 1)->length != length) goto allocate;
            (source - 1)->cpelemsize = USTR_CPELEMSIZE;
            return source;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_fpc(source, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_fpc(target, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
        rtl_ustr_markup_fpc(target, length);
        *((ptr_t*)value) = target;
        if (source)
        {
            if (length > (source - 1)->length) length = (source - 1)->length;
            rtl_memcopy(target, source, length * sizeof(*chars));
            rtl_string_release_fpc(source, RETURN_ADDRESS, 0);
        }

        return target;
    }

    return 0;
}

REGISTER_DECL void* CStrSetLength(void* value, uint32_t length)
{
    RtlDynArray* source = *((ptr_t*)value);
    RtlDynArray* target;
    char32_t* chars/*none*/;

    if (source)
    {
        if (length)
        {
            if ((source - 1)->refcount != 1 || (source - 1)->length != length) goto allocate;
            return source;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_dynarray_release(source, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc(target, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
        rtl_cstr_markup(target, length);
        *((ptr_t*)value) = target;
        if (source)
        {
            if (length > (source - 1)->length) length = (source - 1)->length;
            rtl_memcopy(target, source, length * sizeof(*chars));
            rtl_dynarray_release(source, RETURN_ADDRESS, 0);
        }

        return target;
    }

    return 0;
}

REGISTER_DECL void* CStrSetLength_fpc(void* value, uint32_t length)
{
    RtlDynArray_fpc* source = *((ptr_t*)value);
    RtlDynArray_fpc* target;
    char32_t* chars/*none*/;

    if (source)
    {
        if (length)
        {
            if ((source - 1)->refcount != 1 || ((source - 1)->high + 1) != length) goto allocate;
            return source;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_dynarray_release_fpc(source, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_fpc(target, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
        rtl_cstr_markup_fpc(target, length);
        *((ptr_t*)value) = target;
        if (source)
        {
            if (length > ((source - 1)->high + 1)) length = (source - 1)->high + 1;
            rtl_memcopy(target, source, length * sizeof(*chars));
            rtl_dynarray_release_fpc(source, RETURN_ADDRESS, 0);
        }

        return target;
    }

    return 0;
}


/*
    TimeStamp routine
*/

#define TIMESTAMP_MICROSECOND ((int64_t)(10))
#define TIMESTAMP_MILLISECOND TIMESTAMP_MICROSECOND * 1000
#define TIMESTAMP_SECOND TIMESTAMP_MILLISECOND * 1000
#define TIMESTAMP_MINUT TIMESTAMP_SECOND * 60
#define TIMESTAMP_HOUR TIMESTAMP_MINUT * 60
#define TIMESTAMP_DAY TIMESTAMP_HOUR * 24

typedef PACKED_STRUCT
{
    int tm_sec;         /* seconds */
    int tm_min;         /* minutes */
    int tm_hour;        /* hours */
    int tm_mday;        /* day of the month */
    int tm_mon;         /* month */
    int tm_year;        /* year */
    int tm_wday;        /* day of the week */
    int tm_yday;        /* day in the year */
    int tm_isdst;       /* daylight saving time */
}
tm;

REGISTER_DECL int64_t tm_to_timestamp(void *_tm)
{
    tm* t = _tm;
    int32_t seconds = t->tm_sec + t->tm_min * 60 + t->tm_hour * 3600 +
      t->tm_yday * 86400 + (t->tm_year - 70) * 31536000 + ((t->tm_year - 69) / 4) * 86400 -
      ((t->tm_year - 1) / 100) * 86400 + ((t->tm_year + 299) / 400) * 86400;

    return seconds * TIMESTAMP_SECOND + 134774 * TIMESTAMP_DAY;
}


/*
    Preallocated routine
*/

#if defined (MSWINDOWS)
NAKED
REGISTER_DECL void preallocated_call(ptr_t param, native_uint size, PreallocatedCallback callback)
{
    __asm__ volatile
    (
    ".intel_syntax noprefix \n\t"
    #if defined (CPUX86)
        "push ebp \n\t"
        "mov ebp, esp \n\t"
        "push ecx \n\t"
        "lea ecx, [edx + 15] \n\t"
        "and ecx, -16 \n\t"
        "and esp, -16 \n\t"
        "sub ecx, 4096 \n\t"
        "jb L.small_alloc \n\t"

    "L.page_alloc: \n\t"
        "sub esp, 4092 \n\t"
        "push eax \n\t"
        "sub ecx, 4096 \n\t"
        "jae L.page_alloc \n\t"

    "L.small_alloc: \n\t"
        "add ecx, 4092 \n\t"
        "jl L.call \n\t"
        "sub esp, ecx \n\t"
        "push eax \n\t"
    "L.call: \n\t"
        "mov ecx, edx \n\t"
        "mov edx, esp \n\t"
        "call [ebp - 4] \n\t"
        "mov esp, ebp \n\t"
        "pop ebp \n\t"
    #else
        "push rbp \n\t"
        "mov rbp, rsp \n\t"
        "lea rax, [rdx + 47] \n\t"
        "and rax, -16 \n\t"
        "sub rax, 4096 \n\t"
        "jb L.small_alloc \n\t"

    "L.page_alloc: \n\t"
        "sub rsp, 4088 \n\t"
        "push rax \n\t"
        "sub rax, 4096 \n\t"
        "jae L.page_alloc \n\t"

    "L.small_alloc: \n\t"
        "add rax, 4088 \n\t"
        "jl L.call \n\t"
        "sub rsp, rax \n\t"
        "push rax \n\t"

    "L.call: \n\t"
        "mov rax, r8 \n\t"
        "lea r8, [rsp + 32] \n\t"
        "xchg rdx, r8 \n\t"
        "call rax \n\t"
        "mov rsp, rbp \n\t"
        "pop rbp \n\t"
    #endif
    "ret \n\t"
    );
}
#else
REGISTER_DECL void preallocated_call(ptr_t param, native_uint size, PreallocatedCallback callback)
{
  uint8_t buffer[size] ALIGNED(16);
  callback(param, &buffer, size);
}
#endif
