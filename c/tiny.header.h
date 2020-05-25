
#ifndef tiny_header_h
#define tiny_header_h

#include "tiny.defines.h"
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

typedef uint8_t char8_t;
typedef uint16_t char16_t;
typedef uint32_t char32_t;
typedef intptr_t native_int;
typedef uintptr_t native_uint;
typedef int32_t HRESULT;
typedef void* ptr_t;
#if defined (CPUX86) || defined (CPUARM32) || defined (WIN64)
  typedef int64_t out_general;
#else
  typedef PACKED_STRUCT {native_int low; native_int high;} out_general;
#endif
typedef PACKED_STRUCT
{
  #if defined (CPUARM) || defined (POSIX64)
    double d0;
    double d1;
    #if defined (CPUARM)
    double d2;
    double d3;
    #endif
  #endif
}
hfa_struct;
typedef uint8_t block16 __attribute__((__vector_size__(16), __aligned__(16)));
typedef uint8_t data16 __attribute__((__vector_size__(16), __aligned__(1)));
typedef uint8_t data8 __attribute__((__vector_size__(8), __aligned__(1)));
/*
#if defined (CPUX86)
  #pragma clang attribute push(__attribute__((target("sse2"))), apply_to=function)
  ...
  #pragma clang attribute pop
#endif
*/
typedef out_general (*GeneralFunc)();
typedef REGISTER_DECL out_general (*GeneralFunc1)(ptr_t p1);
typedef REGISTER_DECL out_general (*GeneralFunc2)(ptr_t p1, ptr_t p2);
typedef REGISTER_DECL out_general (*GeneralFunc3)(ptr_t p1, ptr_t p2, ptr_t p3);
typedef REGISTER_DECL out_general (*GeneralFunc4)(ptr_t p1, ptr_t p2, ptr_t p3, ptr_t p4);


/*
    Tagged pointer routine
*/
#pragma pack(push, 1)
typedef struct
{
    ptr_t value;
    native_int counter;
}
tagged_ptr ALIGNED(sizeof(void*) * 2);
#pragma pack(pop)
typedef tagged_ptr tagged_unaligned_ptr ALIGNED(1);
#if defined (SMALLINT)
  typedef int64_t tagged_int ALIGNED(8);
  typedef data8 tagged_data ALIGNED(8);
#else
  typedef __int128 tagged_int ALIGNED(16);
  typedef data16 tagged_data ALIGNED(16);
#endif
FORCEINLINE void tagged_copy(volatile tagged_ptr* target/*aligned*/, volatile tagged_ptr* source/*aligned*/)
{
  #if defined (CPUX86)
    __asm__ volatile
    (
        "fildq %1 \n\t"
        "fistpq %0 \n\t"
    :   "=m"(*target)
    :   "m" (*source)
    :   "st", "memory"
    );
  #elif defined (CPUX64)
    tagged_data temp;
    __asm__ volatile
    (
        "movaps %2, %0 \n\t"
        "movaps %0, %1 \n\t"
        : "=&x" (temp), "=m" (*target)
        : "m" (*source)
        : "memory"
    );
  #elif defined (CPUARM32)
    tagged_data temp;
    __asm__ volatile
    (
        "vldr %0, %2 \n\t"
        "vstr %0, %1 \n\t"
        : "=&w" (temp), "=m" (*target)
        : "m" (*source)
        : "memory"
    );
  #elif defined (CPUARM64)
    tagged_data temp;
    __asm__ volatile
    (
        "ldr %q0, %2 \n\t"
        "str %q0, %1 \n\t"
        : "=&w" (temp), "=m" (*target)
        : "m" (*source)
        : "memory"
    );
  #endif
}
FORCEINLINE void tagged_read(volatile tagged_unaligned_ptr* target, volatile tagged_ptr* source/*aligned*/)
{
  #if defined (CPUX64)
    tagged_data temp;
    __asm__ volatile
    (
        "movaps %2, %0 \n\t"
        "movups %0, %1 \n\t"
        : "=&x" (temp), "=m" (*target)
        : "m" (*source)
        : "memory"
    );
  #else
    tagged_copy(target, source);
  #endif
}
FORCEINLINE void tagged_write(volatile tagged_ptr* target/*aligned*/, volatile tagged_unaligned_ptr* source)
{
  #if defined (CPUX64)
    tagged_data temp;
    __asm__ volatile
    (
        "movups %2, %0 \n\t"
        "movaps %0, %1 \n\t"
        : "=&x" (temp), "=m" (*target)
        : "m" (*source)
        : "memory"
    );
  #else
    tagged_copy(target, source);
  #endif
}
FORCEINLINE tagged_ptr tagged_exchange(tagged_ptr* target/*aligned*/, tagged_unaligned_ptr value)
{
    tagged_int ret = atomic_exchange((tagged_int*)target, *((tagged_int*)&value));
    return *((tagged_ptr*)&ret);
}
FORCEINLINE bool tagged_cmp_exchange(tagged_ptr* target/*aligned*/, tagged_unaligned_ptr value, tagged_unaligned_ptr comparand)
{
    return atomic_cmp_exchange((tagged_int*)target, *((tagged_int*)&value), *((tagged_int*)&comparand));
}


#endif
