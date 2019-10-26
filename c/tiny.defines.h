
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

#define NO_INLINE __attribute__((noinline))

#if defined (CPUX86)
  #define BORLAND_DECL __attribute__((stdcall)) __attribute__((regparm(3)))
  #define STDCALL __attribute__((stdcall))
#else
  #define BORLAND_DECL
  #define STDCALL
#endif


#endif