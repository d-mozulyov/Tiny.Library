
#include "tiny.defines.h"
#include "tiny.rtti.h"
#include "tiny.invoke.h"
#include "tiny.invoke.intrjumps.h"


#if defined (WIN64)
  #define intercept_jump_x64_alter
#else
  #define intercept_jump_x64_alter \
    ".byte 0xEB, 0x04 \n\t" /* jmp L.start */ \
    ".byte 0x48, 0x8B, 0x47, 0xF8 \n\t" /* mov rax, [rdi - 8] */
#endif
#if defined (CPUX86)
  #define intercept_jump_params \
    [offs_EDX] "n" (sizeof(RttiRegisters) - (offsetof(RttiInvokeDump, registers) + offsetof(RttiRegisters, RegEDX))),
  #define intercept_jump_code \
    ".byte 0x89, 0xC8 \n\t" /* mov eax, ecx */ \
    ".byte 0xEB, 0x04 \n\t" /* jmp L.start */ \
    ".byte 0x8B, 0x44, 0x24, 0x04 \n\t" /* mov eax, [esp + 4] */ \
    "mov [esp - %c[offs_EDX]], edx \n\t" \
    "mov edx, [eax - 4] \n\t" \
    "add edx, %c[offset] \n\t" \
    "jmp [edx] \n\t"
  #define intercept_jump_offset 8
#elif defined (CPUX64)
  #define intercept_jump_params
  #define intercept_jump_code \
    ".byte 0x48, 0x8B, 0x41, 0xF8 \n\t" /* mov rax, [rcx - 8] */ \
    intercept_jump_x64_alter \
    "add rax, %c[offset] \n\t" \
    "jmp [rax] \n\t"

    #if defined (WIN64)
      #define intercept_jump_offset 0
    #else
      #define intercept_jump_offset 6
    #endif
#elif defined (CPUARM32)
  #define intercept_jump_params
  #define intercept_jump_code \
    "ldr r12, [r0, #-4] \n\t" \
    "add r12, r12, %[arm32offset_low] \n\t" \
    "add r12, r12, %[arm32offset_high] \n\t" \
    "ldmia r12!, {pc} \n\t"
  #define intercept_jump_offset 0
#else // CPUARM64
  #define intercept_jump_params
  #define intercept_jump_code \
    "ldr x16, [x0, #-8] \n\t" \
    "mov x17, %[offset] \n\t" \
    "add x16, x16, x17 \n\t" \
    "ldr x17, [x16], 8 \n\t" \
    "br x17 \n\t"
  #define intercept_jump_offset 0
#endif

#define intercept_jump(n) NAKED void intercept_jump##n() { \
    __asm__ volatile ( \
        asm_syntax_intel \
        intercept_jump_code \
    : : \
      intercept_jump_params \
      [offset] "n" (n * sizeof(RttiVirtualMethodData)), \
      [arm32offset_low] "n" ((n * sizeof(RttiVirtualMethodData)) & -4096), \
      [arm32offset_high] "n" ((n * sizeof(RttiVirtualMethodData)) & 4095) \
    ); \
}

#include "tiny.invoke.intr.jumps.inc"

/* get appropriate interception jump */
REGISTER_DECL void* get_intercept_jump(int32_t index, int32_t mode)
{
    if (((uint32_t)index) >= (sizeof(INTERCEPT_JUMPS) / sizeof(INTERCEPT_JUMPS[0])))
        return 0;

    uint8_t* ptr = ((uint8_t*)INTERCEPT_JUMPS[index]) + intercept_jump_offset;

    #if defined (CPUX86)
    switch (mode)
    {
        case 1: ptr -= 4; break;
        case 2: ptr -= (4 + 4); break;
    }
    #endif

    #if defined (POSIXINTEL64)
    switch (mode)
    {
        case 1: ptr -= 6; break;
    }
    #endif

    return ptr;
}
