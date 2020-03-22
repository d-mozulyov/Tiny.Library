
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
#define FORCEINLINE __attribute__((always_inline))
#define NAKED __attribute__((naked))


#if defined (CPUINTEL)
  #define asm_syntax_intel ".intel_syntax noprefix\n\t"
#else
  #define asm_syntax_intel
#endif

#define offsetof(s,m) (size_t)&(((s *)0)->m)
#define RETURN_ADDRESS __builtin_return_address(0)


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


#endif
