
#ifndef tiny_defines_h
#define tiny_defines_h

#if defined (__i386__)
  #define CPUINTEL
  #define CPUX86
#endif

#if defined (__x86_64__)
  #define CPUINTEL
  #define CPUX64
#endif

#if defined (__arm__)
  #define CPUARM
  #define CPUARM32
#endif

#if defined (__aarch64__)
  #define CPUARM
  #define CPUARM64
#endif

#if defined (CPUX86) || defined (CPUARM32)
  #define SMALLINT
#else
  #define LARGEINT
#endif

#if defined (_WIN64)
  #define MSWINDOWS
  #ifndef WIN64
    #define WIN64
  #endif
#elif defined (_WIN32)
  #define MSWINDOWS
  #ifndef WIN32
    #define WIN32
  #endif
#endif

#if !defined (MSWINDOWS)
  #define POSIX
  #if defined (SMALLINT)
    #define POSIX32
  #else
    #define POSIX64
  #endif
  #if defined (CPUINTEL)
    #if defined (SMALLINT)
      #define POSIXINTEL32
    #else
      #define POSIXINTEL64
    #endif
  #else
    #if defined (SMALLINT)
      #define POSIXARM32
    #else
      #define POSIXARM64
    #endif
  #endif
#endif

#if defined (__linux__) && !defined (__ANDROID__)
  #define LINUX
  #if defined (SMALLINT)
    #define LINUX32
  #else
    #define LINUX64
  #endif
#endif

#if defined (__APPLE__)
  #define MACOS
  #if defined (SMALLINT)
    #define MACOS32
  #else
    #define MACOS64
  #endif

  #if defined (CPUARM)
    #define IOS
    #if defined (SMALLINT)
      #define IOS32
    #else
      #define IOS64
    #endif
  #else
    #define OSX
    #if defined (SMALLINT)
      #define OSX32
    #else
      #define OSX64
    #endif
  #endif
#endif

#if defined (__ANDROID__)
  #define ANDROID
  #if defined (SMALLINT)
    #define ANDROID32
  #else
    #define ANDROID64
  #endif
#endif

#if defined (CPUX86)
  #define REGISTER_DECL __attribute__((stdcall)) __attribute__((regparm(3)))
  #define STDCALL __attribute__((stdcall))
#else
  #define REGISTER_DECL
  #define STDCALL
#endif
#define CDECL
#define NOINLINE __attribute__((noinline))
#define FORCEINLINE static __attribute__((always_inline))
#define NAKED __attribute__((naked))
#define ALIGNED(A) __attribute__((aligned(A)))
#define REGISTER_DECL64 ALIGNED(64) REGISTER_DECL
#define PACKED_STRUCT struct __attribute__((packed))

#define INVALID_INDEX -1
#define INVALID_COUNT INVALID_INDEX
#define INVALID_UINTPTR 1
#define INVALID_PTR ((void*)INVALID_UINTPTR)

#define RETURN_ADDRESS __builtin_return_address(0)
#define atomic_increment(x) __sync_add_and_fetch(x, 1)
#define atomic_decrement(x) __sync_sub_and_fetch(x, 1)
#define atomic_add(x, value) __sync_add_and_fetch(x, value)
#define atomic_sub(x, value) __sync_sub_and_fetch(x, value)
#define atomic_or(x, value) __sync_or_and_fetch(x, value)
#define atomic_or_prev(x, value) __sync_fetch_and_or(x, value)
#define atomic_and(x, value) __sync_and_and_fetch(x, value)
#define atomic_and_prev(x, value) __sync_fetch_and_and(x, value)
#define atomic_xor(x, value) __sync_xor_and_fetch(x, value)
#define atomic_nand(x, value) __sync_nand_and_fetch(x, value)
#define atomic_exchange(x, value) __sync_lock_test_and_set(x, value)
#define atomic_cmp_exchange(x, value, comparand) __sync_bool_compare_and_swap(x, comparand, value)
#define bswap_16(x) __builtin_bswap16(x)
#define bswap_32(x) __builtin_bswap32(x)
#define bswap_64(x) __builtin_bswap64(x)
#define bit_index(x) __builtin_ctz(x)
#if defined (CPUX86)
  FORCEINLINE unsigned long bit_fastindex(unsigned long x)
  {
    unsigned long res;
    __asm__("rep bsfl %1, %0" : "=r"(res) : "r"(x));
    return res;
  }
#elif defined (CPUX64)
  FORCEINLINE unsigned long long bit_fastindex(unsigned long long x)
  {
    unsigned long long res;
    __asm__("rep bsfq %1, %0" : "=r"(res) : "r"(x));
    return res;
  }
#else
  #define bit_fastindex(x) __builtin_ctz(x)
#endif


#if defined (CPUX86) && defined (MSWINDOWS)
  #define platform_stack_align sizeof(void*)
#elif defined (CPUX86)
  #define platform_stack_align 16
#else
  #define platform_stack_align (sizeof(void*) * 2)
#endif
#if defined (CPUARM)
  #define platform_stack_retsize 0
#else
  #define platform_stack_retsize sizeof(void*)
#endif
#if defined (WIN64)
  #define platform_stack_window 32
#else
  #define platform_stack_window 0
#endif


#if defined (CPUINTEL)
  #define asm_syntax_intel ".intel_syntax noprefix \n\t"
#else
  #define asm_syntax_intel
#endif
#define asm_cmd(cmd) cmd " \n\t"
#define asm_uop(cmd, x) asm_cmd(cmd " " x)
#define asm_op(cmd, a, b) asm_cmd(cmd " " a " , " b)
#if defined (CPUINTEL) || defined (CPUARM64)
  #define asm_ret asm_cmd("ret")
#else
  #define asm_ret asm_cmd("bx lr")
#endif
#define asm_cat(a, b) asm_cmd(a b)
#define asm_cat3(a, b, c) asm_cmd(a b c)
#define asm_cat4(a, b, c, d) asm_cmd(a b c d)
#define assembler_begin __asm__ volatile ( asm_syntax_intel
#if defined (ANDROID32)
  #define assembler_end_ asm_ret asm_cmd("trap")
#elif defined (ANDROID64)
  #define assembler_end_ asm_ret asm_cmd("brk 1")
#elif defined (CPUARM) || defined (MACOS) || defined (WIN64)
  #define assembler_end_ asm_ret
#else
  #define assembler_end_ asm_ret asm_cmd("ud2")
#endif
#define assembler_end assembler_end_ );
#define asm_addr(addr) "[" addr "]"
#define asm_address(base, offset) asm_addr(base " + " offset)
#define asm_addrx(base, index, offset) asm_addr(base " + " index " + " offset)
#define asm_addrx2(base, index, offset) asm_addr(base " + " index " * 2 + " offset)
#define asm_addrx4(base, index, offset) asm_addr(base " + " index " * 4 + " offset)
#define asm_addrx8(base, index, offset) asm_addr(base " + " index " * 8 + " offset)

#define asm_reg_none "0"
#if defined (CPUX86)
  #define asm_reg0 "eax"
  #define asm_reg1 "edx"
  #define asm_reg2 "ecx"
  #define asm_regr "eax"
  #define asm_regr2 "edx"
  #define asm_regw0 "ax"
  #define asm_regw1 "dx"
  #define asm_regw2 "cx"
  #define asm_regw2 "cx"
  #define asm_regwr "ax"
  #define asm_regb0 "al"
  #define asm_regb1 "dl"
  #define asm_regb2 "cl"
  #define asm_regbr "al"
#elif defined (WIN64)
  #define asm_reg0 "rcx"
  #define asm_reg1 "rdx"
  #define asm_reg2 "r8"
  #define asm_reg3 "r9"
  #define asm_regr "rax"
  #define asm_regd0 "ecx"
  #define asm_regd1 "edx"
  #define asm_regd2 "r8d"
  #define asm_regd3 "r9d"
  #define asm_regdr "eax"
  #define asm_regw0 "cx"
  #define asm_regw1 "dx"
  #define asm_regw2 "r8w"
  #define asm_regw3 "r9w"
  #define asm_regwr "ax"
  #define asm_regb0 "cl"
  #define asm_regb1 "dl"
  #define asm_regb2 "r8b"
  #define asm_regb3 "r9b"
  #define asm_regbr "al"
#elif defined (POSIXINTEL64)
  #define asm_reg0 "rdi"
  #define asm_reg1 "rsi"
  #define asm_reg2 "rdx"
  #define asm_reg3 "rcx"
  #define asm_regr "rax"
  #define asm_regr2 "rdx"
  #define asm_regd0 "edi"
  #define asm_regd1 "esi"
  #define asm_regd2 "edx"
  #define asm_regd3 "ecx"
  #define asm_regdr "eax"
  #define asm_regw0 "di"
  #define asm_regw1 "si"
  #define asm_regw2 "dx"
  #define asm_regw3 "cx"
  #define asm_regwr "ax"
  #define asm_regb0 "dil"
  #define asm_regb1 "sil"
  #define asm_regb2 "dl"
  #define asm_regb3 "cl"
  #define asm_regbr "al"
#elif defined (CPUARM32)
  #define asm_reg0 "r0"
  #define asm_reg1 "r1"
  #define asm_reg2 "r2"
  #define asm_reg3 "r3"
  #define asm_regr "r0"
  #define asm_regr2 "r1"
#elif defined (CPUARM64)
  #define asm_reg0 "x0"
  #define asm_reg1 "x1"
  #define asm_reg2 "x2"
  #define asm_reg3 "x3"
  #define asm_regr "x0"
  #define asm_regr2 "x1"
  #define asm_regd0 "w0"
  #define asm_regd1 "w1"
  #define asm_regd2 "w2"
  #define asm_regd3 "w3"
  #define asm_regdr "w0"
#endif
#if defined (SMALLINT)
  #define asm_regd0 asm_reg0
  #define asm_regd1 asm_reg1
  #define asm_regd2 asm_reg2
  #define asm_regd3 asm_reg3
  #define asm_regdr asm_regr
#endif
#define asm_reg(n) asm_reg##n
#define asm_regd(n) asm_regd##n
#define asm_regw(n) asm_regw##n
#define asm_regb(n) asm_regb##n

#if defined (CPUINTEL)
  #define asm_nop0
  #define asm_nop1 asm_cmd(".byte 0x90")
  #define asm_nop2 asm_cmd(".byte 0x66,0x90")
  #define asm_nop3 asm_cmd(".byte 0x0f,0x1f,0x00")
  #define asm_nop4 asm_cmd(".byte 0x0f,0x1f,0x40,0x00")
  #define asm_nop5 asm_cmd(".byte 0x0f,0x1f,0x44,0x0,0x000")
  #define asm_nop6 asm_cmd(".byte 0x66,0x0f,0x1f,0x44,0x00,0x00")
  #define asm_nop7 asm_cmd(".byte 0x0f,0x1f,0x80,0x00,0x00,0x00,0x00")
  #define asm_nop8 asm_cmd(".byte 0x0f,0x1f,0x84,0x00,0x00,0x00,0x00,0x00")
  #define asm_nop9 asm_cmd(".byte 0x66,0x0f,0x1f,0x84,0x00,0x00,0x00,0x00,0x00 ")
  #define asm_nop10 asm_cmd(".byte 0x66,0x66,0x0f,0x1f,0x84,0x00,0x00,0x00,0x00,0x00")
  #define asm_nop11 asm_cmd(".byte 0x66,0x66,0x66,0x0f,0x1f,0x84,0x00,0x00,0x00,0x00,0x00")
  #define asm_nop12 asm_nop4 asm_nop8
  #define asm_nop13 asm_nop5 asm_nop8
  #define asm_nop14 asm_nop6 asm_nop8
  #define asm_nop15 asm_nop7 asm_nop8
  #define asm_nop16 asm_nop8 asm_nop8
#endif
#define asm_nop(n) asm_nop##n

#define asm_label_name(label) ".L" #label
#define asm_label(label) asm_cmd(asm_label_name(label) ":")
#if defined (SMALLINT)
  #define asm_native "4"
  #define asm_case(label) asm_cmd(".long " asm_label_name(label))
#elif defined (LARGEINT)
  #define asm_native "8"
  #define asm_case(label) asm_cmd(".quad " asm_label_name(label))
#endif
#define asm_jump_to(jump, addr) asm_cmd(jump " " addr)
#define asm_jump_to_label(jump, label) asm_jump_to(jump, asm_label_name(label))
#if defined (CPUINTEL)
  #define asm_call_ "call"
  #define asm_jmp_ "jmp"
  #define asm_jo_ "jo"
  #define asm_jno_ "jno"
  #define asm_jb_ "jb"
  #define asm_jc_ "jc"
  #define asm_jnae_ "jnae"
  #define asm_jae_ "jae"
  #define asm_jnb_ "jnb"
  #define asm_jnc_ "jnc"
  #define asm_je_ "je"
  #define asm_jz_ "jz"
  #define asm_jnz_ "jnz"
  #define asm_jne_ "jne"
  #define asm_jbe_ "jbe"
  #define asm_jna_ "jna"
  #define asm_ja_ "ja"
  #define asm_jnbe_ "jnbe"
  #define asm_js_ "js"
  #define asm_jns_ "jns"
  #define asm_jp_ "jp"
  #define asm_jpe_ "jpe"
  #define asm_jpo_ "jpo"
  #define asm_jnp_ "jnp"
  #define asm_jl_ "jl"
  #define asm_jnge_ "jnge"
  #define asm_jge_ "jge"
  #define asm_jnl_ "jnl"
  #define asm_jle_ "jle"
  #define asm_jng_ "jng"
  #define asm_jg_ "jg"
  #define asm_jnle_ "jnle"
#elif defined (CPUARM)
  #define asm_call_ "bl"
  #define asm_jmp_ "b"
  #define asm_jo_ "bvs"
  #define asm_jno_ "bvc"
  #define asm_jb_ "bcc"
  #define asm_jc_ "bcc"
  #define asm_jnae_ "bcc"
  #define asm_jae_ "bcs"
  #define asm_jnb_ "bcs"
  #define asm_jnc_ "bcs"
  #define asm_je_ "beq"
  #define asm_jz_ "beq"
  #define asm_jnz_ "bnz"
  #define asm_jne_ "bnz"
  #define asm_jbe_ "bls"
  #define asm_jna_ "bls"
  #define asm_ja_ "bhi"
  #define asm_jnbe_ "bhi"
  #define asm_js_ "bmi"
  #define asm_jns_ "bpl"
  #define asm_jl_ "blt"
  #define asm_jnge_ "blt"
  #define asm_jge_ "bge"
  #define asm_jnl_ "bge"
  #define asm_jle_ "ble"
  #define asm_jng_ "ble"
  #define asm_jg_ "bgt"
  #define asm_jnle_ "bgt"
#endif
#define asm_call(label) asm_jump_to_label(asm_call_, label)
#define asm_jmp(label) asm_jump_to_label(asm_jmp_, label)
#define asm_jo(label) asm_jump_to_label(asm_jo_, label)
#define asm_jno(label) asm_jump_to_label(asm_jno_, label)
#define asm_jb(label) asm_jump_to_label(asm_jb_, label)
#define asm_jc(label) asm_jump_to_label(asm_jc_, label)
#define asm_jnae(label) asm_jump_to_label(asm_jnae_, label)
#define asm_jae(label) asm_jump_to_label(asm_jae_, label)
#define asm_jnb(label) asm_jump_to_label(asm_jnb_, label)
#define asm_jnc(label) asm_jump_to_label(asm_jnc_, label)
#define asm_je(label) asm_jump_to_label(asm_je_, label)
#define asm_jz(label) asm_jump_to_label(asm_jz_, label)
#define asm_jnz(label) asm_jump_to_label(asm_jnz_, label)
#define asm_jne(label) asm_jump_to_label(asm_jne_, label)
#define asm_jbe(label) asm_jump_to_label(asm_jbe_, label)
#define asm_jna(label) asm_jump_to_label(asm_jna_, label)
#define asm_ja(label) asm_jump_to_label(asm_ja_, label)
#define asm_jnbe(label) asm_jump_to_label(asm_jnbe_, label)
#define asm_js(label) asm_jump_to_label(asm_js_, label)
#define asm_jns(label) asm_jump_to_label(asm_jns_, label)
#define asm_jp(label) asm_jump_to_label(asm_jp_, label)
#define asm_jpe(label) asm_jump_to_label(asm_jpe_, label)
#define asm_jpo(label) asm_jump_to_label(asm_jpo_, label)
#define asm_jnp(label) asm_jump_to_label(asm_jnp_, label)
#define asm_jl(label) asm_jump_to_label(asm_jl_, label)
#define asm_jnge(label) asm_jump_to_label(asm_jnge_, label)
#define asm_jge(label) asm_jump_to_label(asm_jge_, label)
#define asm_jnl(label) asm_jump_to_label(asm_jnl_, label)
#define asm_jle(label) asm_jump_to_label(asm_jle_, label)
#define asm_jng(label) asm_jump_to_label(asm_jng_, label)
#define asm_jg(label) asm_jump_to_label(asm_jg_, label)
#define asm_jnle(label) asm_jump_to_label(asm_jnle_, label)
#if defined (CPUX86)
  #define asm_switch_offs(switch_label, index, index_offset) \
    asm_cmd("jmp [" index " * " asm_native " + " asm_label_name(switch_label) " + " index_offset  " * " asm_native)
#elif defined (CPUINTEL)
  #define asm_switch_offs(switch_label, index, index_offset) \
    asm_cmd("lea r11, [rip + " asm_label_name(switch_label) " + " index_offset  " * " asm_native "]") \
    asm_cmd("jmp [r11 + " index " * " asm_native "]")
#endif
#define asm_switch(label, index) asm_switch_offset(label, index, "+ 0")


#endif
