
#ifndef tiny_rtti_h
#define tiny_rtti_h

#include "tiny.defines.h"

typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef signed short int16_t;
typedef unsigned short uint16_t;
typedef signed int int32_t;
typedef unsigned int uint32_t;
typedef signed long long int64_t;
typedef unsigned long long uint64_t;
#if defined (SMALLINT)
  typedef int32_t size_t;
  typedef uint32_t usize_t;
#else
  typedef int64_t size_t;
  typedef uint64_t usize_t;
#endif
typedef int32_t HRESULT;


#endif
