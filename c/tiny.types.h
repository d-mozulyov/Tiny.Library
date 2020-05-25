
#ifndef tiny_types_h
#define tiny_types_h

#include "tiny.header.h"


/*
    Tagged pointer routine
*/
REGISTER_DECL void TaggedPtrCopy(volatile tagged_ptr* target/*aligned*/, volatile tagged_ptr* source/*aligned*/);
REGISTER_DECL void TaggedPtrRead(volatile tagged_unaligned_ptr* target, volatile tagged_ptr* source/*aligned*/);
REGISTER_DECL void TaggedPtrWrite(volatile tagged_ptr* target/*aligned*/, volatile tagged_unaligned_ptr* source);
REGISTER_DECL void TaggedPtrExchange(tagged_unaligned_ptr* last_value, tagged_ptr* target/*aligned*/, tagged_unaligned_ptr* value);
REGISTER_DECL bool TaggedPtrCmpExchange(tagged_ptr* target/*aligned*/, tagged_unaligned_ptr* value, tagged_unaligned_ptr* comparand);
REGISTER_DECL ptr_t TaggedPtrChange(tagged_ptr* target/*aligned*/, ptr_t value);
REGISTER_DECL ptr_t TaggedPtrInvalidate(tagged_ptr* target/*aligned*/);
REGISTER_DECL bool TaggedPtrValidate(tagged_ptr* target/*aligned*/, ptr_t value);
REGISTER_DECL ptr_t TaggedPtrPush(tagged_ptr* target/*aligned*/, ptr_t item);
REGISTER_DECL ptr_t TaggedPtrPushCalcList(tagged_ptr* target/*aligned*/, ptr_t first);
REGISTER_DECL ptr_t TaggedPtrPushList(tagged_ptr* target/*aligned*/, ptr_t first, ptr_t last);
REGISTER_DECL ptr_t TaggedPtrPop(tagged_ptr* target/*aligned*/);
REGISTER_DECL ptr_t TaggedPtrPopList(tagged_ptr* target/*aligned*/);
REGISTER_DECL ptr_t TaggedPtrPopReversed(tagged_ptr* target/*aligned*/);


/*
    Standard Delphi ReturnAddress equivalent
*/
void* ReturnAddress();


/*
    Lightweight error routine
*/
#define ERRORCODE_NONE 0
#define ERRORCODE_ACCESSVIOLATION 1
#define ERRORCODE_STACKOVERFLOW 2
#define ERRORCODE_SAFECALLERROR 3
#define ERRORCODE_OUTOFMEMORY 4
#define ERRORCODE_RANGEERROR 5
#define ERRORCODE_INTOVERFLOW 6
#define ERRORCODE_INTFCASTERROR 7
#define ERRORCODE_INVALIDCAST 8
#define ERRORCODE_INVALIDPTR 9
#define ERRORCODE_INVALIDOP 10
#define ERRORCODE_VARINVALIDOP 11
#define ERRORCODE_VARTYPECAST 12
#define ERRORCODE_PRIVINSTRUCTION 13
typedef REGISTER_DECL void* (*ErrorHandlerFunc)(uint32_t error_code, char16_t* message, void* return_address);
REGISTER_DECL void* TinyError(uint32_t error_code, char16_t* message, void* return_address)/*forward*/;
REGISTER_DECL void* TinyErrorSafeCall(int32_t code, void* return_address);
REGISTER_DECL void* TinyErrorOutOfMemory(void* return_address);
REGISTER_DECL void* TinyErrorRange(void* return_address);
REGISTER_DECL void* TinyErrorIntOverflow(void* return_address);
REGISTER_DECL void* TinyErrorInvalidCast(void* return_address);
REGISTER_DECL void* TinyErrorInvalidPtr(void* return_address);
REGISTER_DECL void* TinyErrorInvalidOp(void* return_address);


/*
    RTTI helpers
*/
native_int SysVmtAddRef;
native_int SysVmtRelease;
REGISTER_DECL void (*SysInitStruct)(ptr_t target, void* type_info);
REGISTER_DECL void (*SysFinalStruct)(ptr_t target, void* type_info);
REGISTER_DECL void (*SysCopyStruct)(ptr_t target, ptr_t source, void* type_info);
REGISTER_DECL void (*SysInitArray)(ptr_t target, void* type_info, native_uint count);
REGISTER_DECL void (*SysFinalArray)(ptr_t target, void* type_info, native_uint count);
REGISTER_DECL void (*SysCopyArray)(ptr_t target, ptr_t source, void* type_info, native_uint count);
REGISTER_DECL void (*SysFinalDynArray)(ptr_t target, void* type_info);
REGISTER_DECL void (*SysFinalVariant)(ptr_t target);
REGISTER_DECL void (*SysCopyVariant)(ptr_t target, ptr_t source);
REGISTER_DECL void (*SysFinalWeakIntf)(ptr_t target);
REGISTER_DECL void (*SysCopyWeakIntf)(ptr_t target, ptr_t source);
REGISTER_DECL void (*SysFinalWeakObj)(ptr_t target);
REGISTER_DECL void (*SysCopyWeakObj)(ptr_t target, ptr_t source);
REGISTER_DECL void (*SysFinalWeakMethod)(ptr_t target);
REGISTER_DECL void (*SysCopyWeakMethod)(ptr_t target, ptr_t source);


/*
    Memory management
*/
REGISTER_DECL ptr_t (*MMGetMem)(native_uint size);
REGISTER_DECL native_uint (*MMFreeMem)(ptr_t p);
REGISTER_DECL ptr_t (*MMReallocMem)(ptr_t p, native_uint size);
#if defined (MSWINDOWS)
STDCALL ptr_t (*MMSysStrAlloc)(char16_t* chars, uint32_t length);
STDCALL int32_t (*MMSysStrRealloc)(ptr_t* value, char16_t* chars, uint32_t length);
STDCALL void (*MMSysStrFree)(ptr_t value);
#endif
NOINLINE REGISTER_DECL void TinyMove(void* source, void* target, native_uint count);
#define rtl_memcopy(target, source, size) TinyMove(source, target, size)
#define rtl_getmem(result, size, return_address, failure_value) \
    result = MMGetMem(size); \
    if (result == 0) \
    { \
        TinyErrorOutOfMemory(return_address); \
        return failure_value; \
    }
#define rtl_getmem_new rtl_getmem
#define rtl_getmem_nexgen rtl_getmem
#define rtl_getmem_fpc rtl_getmem
#define rtl_freemem(ptr, return_address, failure_value) \
    if (((uint32_t)MMFreeMem(ptr)) != 0) \
    { \
        TinyErrorInvalidPtr(return_address); \
        return failure_value; \
    }
#define rtl_freemem_new rtl_freemem
#define rtl_freemem_nextgen rtl_freemem
#define rtl_freemem_fpc(ptr, return_address, failure_value) \
    if (MMFreeMem(ptr) == 0) \
    { \
        TinyErrorInvalidPtr(return_address); \
        return failure_value; \
    }
#define rtl_realloc(ptr, new_size, return_address, failure_value) \
    for (ptr_t temp = MMReallocMem(ptr, new_size);;) \
    { \
        if (temp) \
        { \
            ptr = temp; \
        } \
        else \
        { \
            TinyErrorOutOfMemory(return_address); \
            return failure_value; \
        } \
        break; \
    }
#define rtl_realloc_new rtl_realloc
#define rtl_realloc_nextgen rtl_realloc
#define rtl_realloc_fpc(ptr, new_size, return_address, failure_value) \
    for (ptr_t temp = ptr;;) \
    { \
        MMReallocMem(&temp, new_size); \
        ptr = temp; \
        break; \
    }



/*
    Delphi/FPC RTL routine
*/
typedef PACKED_STRUCT
{
    union
    {
        char chars[256];
        uint8_t length;
    };
}
ShortString;
typedef PACKED_STRUCT
{
    #if defined (LARGEINT)
    int32_t _padding;
    #endif
    int32_t refcount;
    native_int length;
}
RtlDynArray;
typedef PACKED_STRUCT
{
    native_int refcount;
    native_int high;
}
RtlDynArray_fpc;
typedef PACKED_STRUCT
{
    int32_t refcount;
    int32_t length;
}
RtlStrRec;
typedef PACKED_STRUCT
{
    #if defined (LARGEINT)
    int32_t _padding;
    #endif
    union
    {
        uint32_t cpelemsize;
        PACKED_STRUCT {uint16_t code_page; uint16_t elem_size;};
    };
    int32_t refcount;
    int32_t length;
}
RtlStrRec_new;
typedef RtlDynArray RtlStrRec_nextgen;
typedef PACKED_STRUCT
{
    union
    {
        uint32_t cpelemsize;
        PACKED_STRUCT {uint16_t code_page; uint16_t elem_size;};
    };
    #if defined (LARGEINT)
    int32_t _padding;
    #endif
    native_int refcount;
    native_int length;
}
RtlStrRec_fpc;
typedef PACKED_STRUCT
{
    uint32_t size;
}
RtlWideStrRec;
typedef PACKED_STRUCT
{
    ptr_t* VMT;
}
RtlInterface;
typedef STDCALL int32_t (*RtlInterfaceFunc)(RtlInterface* instance);
#if defined (MSWINDOWS)
  typedef STDCALL int32_t (*RtlInterfaceFunc_fpc)(RtlInterface* instance);
#else
  typedef CDECL int32_t (*RtlInterfaceFunc_fpc)(RtlInterface* instance);
#endif
typedef PACKED_STRUCT
{
    int32_t elsize;
    ptr_t* eltype;
    int32_t vartype;
    ptr_t* eltype2;
}
RtlDynArrayData;
typedef PACKED_STRUCT
{
    native_uint elsize;
    ptr_t eltype2;
    int32_t vartype;
    ptr_t eltype;
}
RtlDynArrayData_fpc;
typedef PACKED_STRUCT
{
    int32_t size;
    int32_t count;
    ptr_t* eltype;
}
RtlArrayData;
typedef PACKED_STRUCT
{
    native_uint size;
    native_uint count;
    ptr_t eltype;
}
RtlArrayData_fpc;
typedef PACKED_STRUCT
{
    int32_t size;
    int32_t managed_field_count;
    PACKED_STRUCT
    {
    } managed_fields;
}
RtlRecordData;
#if defined (SMALLINT)
  #define RTL_VARIANT_SIZE 16
#else
  #define RTL_VARIANT_SIZE 24
#endif
typedef PACKED_STRUCT
{
    union
    {
        PACKED_STRUCT {uint16_t vartype; uint8_t vardata[RTL_VARIANT_SIZE - sizeof(uint16_t)];};
        uint8_t rawdata[RTL_VARIANT_SIZE];
    };
}
RtlVariant/*TVarData*/;
typedef PACKED_STRUCT
{
    ptr_t code;
    ptr_t data;
}
RtlMethod;
#define rtl_interface_addref(interface) ((RtlInterfaceFunc)interface->VMT[1])(interface)
#define rtl_interface_addref_new rtl_interface_addref
#define rtl_interface_addref_nextgen rtl_interface_addref
#define rtl_interface_addref_fpc(interface) ((RtlInterfaceFunc_fpc)interface->VMT[1])(interface)
#define rtl_interface_release(interface) ((RtlInterfaceFunc)interface->VMT[2])(interface)
#define rtl_interface_release_new rtl_interface_release
#define rtl_interface_release_nextgen rtl_interface_release
#define rtl_interface_release_fpc(interface) ((RtlInterfaceFunc_fpc)interface->VMT[2])(interface)
#define rtl_dynarray_addref(rec) \
{  \
    if ((rec - 1)->refcount > 0) \
    { \
        if ((rec - 1)->refcount == 1) (rec - 1)->refcount = 2; \
        else \
        atomic_increment(&(rec - 1)->refcount); \
    } \
}
#define rtl_dynarray_addref_new rtl_dynarray_addref
#define rtl_dynarray_addref_nextgen rtl_dynarray_addref
#define rtl_dynarray_addref_fpc(rec) \
{  \
    if ((rec - 1)->refcount == 1) (rec - 1)->refcount = 2; \
    else \
    atomic_increment(&(rec - 1)->refcount); \
}
#define /*simple*/ rtl_dynarray_release(rec, return_address, failure_value) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        ((rec - 1)->refcount > 0 && atomic_decrement(&(rec - 1)->refcount) == 0) \
      ) \
      rtl_freemem(rec - 1, return_address, failure_value); \
}
#define /*simple*/ rtl_dynarray_release_new rtl_dynarray_release
#define /*simple*/ rtl_dynarray_release_nextgen rtl_dynarray_release
#define /*simple*/ rtl_dynarray_release_fpc(rec, return_address, failure_value) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        atomic_decrement(&(rec - 1)->refcount) == 0 \
      ) \
      rtl_freemem_fpc(rec - 1, return_address, failure_value); \
}
#define rtl_fulldynarray_release(rec, eltype, return_address, failure_value) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        ((rec - 1)->refcount > 0 && atomic_decrement(&(rec - 1)->refcount) == 0) \
      ) \
        { \
            if ((rec - 1)->length > 0) SysFinalArray(rec, eltype, (rec - 1)->length); \
            rtl_freemem(rec - 1, return_address, failure_value); \
        } \
}
#define rtl_fulldynarray_release_new rtl_fulldynarray_release
#define rtl_fulldynarray_release_nextgen rtl_fulldynarray_release
#define rtl_fulldynarray_release_fpc(rec, eltype, return_address, failure_value) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        atomic_decrement(&(rec - 1)->refcount) == 0 \
      ) \
        { \
            if ((rec - 1)->high >= 0) SysFinalArray(rec, eltype, (rec - 1)->high + 1); \
            rtl_freemem_fpc(rec - 1, return_address, failure_value); \
        } \
}
#define rtl_rec_alloc(rec, size, return_address, failure_value) \
{ \
  rtl_getmem(rec, sizeof(*rec) + size, return_address, failure_value) \
  rec++; \
  (rec - 1)->refcount = 1; \
}
#define rtl_rec_alloc_new rtl_rec_alloc
#define rtl_rec_alloc_nextgen rtl_rec_alloc
#define rtl_rec_alloc_fpc rtl_rec_alloc
#define rtl_rec_realloc(rec, new_size, return_address, failure_value) \
{ \
  rec--; \
  rtl_realloc(rec, sizeof(*rec) + new_size, return_address, failure_value); \
  rec++; \
}
#define rtl_rec_realloc_new rtl_rec_realloc
#define rtl_rec_realloc_nextgen rtl_rec_realloc
#define rtl_rec_realloc_fpc(rec, new_size, return_address, failure_value) \
{ \
  rec--; \
  rtl_realloc_fpc(rec, sizeof(*rec) + new_size, return_address, failure_value); \
  rec++; \
}
FORCEINLINE bool rtl_rec_hintrealloc(uint32_t rec_length, uint32_t char_size, uint32_t length)
{
    if (rec_length >= length) return true;
    if (rec_length <= (32 / char_size)) return true;
    if (rec_length >= ((length * 3) >> 2)) return true;
    return false;
}
#define rtl_dynarray_markup(rec, length) \
{ \
  (rec - 1)->length = length; \
}
#define rtl_dynarray_markup_new dynarray_markup
#define rtl_dynarray_markup_nextgen dynarray_markup
#define rtl_dynarray_markup_fpc(rec, length) \
{ \
  (rec - 1)->high = length - 1; \
}


/*
    String routine
*/
#define CHARS_IN_CARDINAL 4
#define WORDS_IN_CARDINAL 2
#define MASK_80_SMALL 0x80808080
#define MASK_80_LARGE 0x8080808080808080
#define MASK_7F_SMALL 0x7F7F7F7F
#define MASK_7F_LARGE 0x7F7F7F7F7F7F7F7F
#define MASK_40_SMALL 0x40404040
#define MASK_40_LARGE 0x4040404040404040
#define MASK_60_SMALL 0x60606060
#define MASK_60_LARGE 0x6060606060606060
#define MASK_65_SMALL 0x65656565
#define MASK_65_LARGE 0x6565656565656565
#define MASK_01_SMALL 0x01010101
#define MASK_01_LARGE 0x0101010101010101
#define MASK_8000_SMALL 0x80008000
#define MASK_8000_LARGE 0x8000800080008000
#define MASK_FF80_SMALL 0xFF80FF80
#define MASK_FF80_LARGE 0xFF80FF80FF80FF80
#define MASK_7FFF_SMALL 0x7FFF7FFF
#define MASK_7FFF_LARGE 0x7FFF7FFF7FFF7FFF
#define MASK_007F_SMALL 0x007F007F
#define MASK_007F_LARGE 0x007F007F007F007F
#define MASK_0040_SMALL 0x00400040
#define MASK_0040_LARGE 0x0040004000400040
#define MASK_0060_SMALL 0x00600060
#define MASK_0060_LARGE 0x0060006000600060
#define MASK_0065_SMALL 0x00650065
#define MASK_0065_LARGE 0x0065006500650065
#define MASK_0001_SMALL 0x00010001
#define MASK_0001_LARGE 0x0001000100010001
#if defined (SMALLINT)
  #define CHARS_IN_NATIVE 4
  #define WORDS_IN_NATIVE 2
  #define MASK_80_NATIVE MASK_80_SMALL
  #define MASK_7F_NATIVE MASK_7F_SMALL
  #define MASK_40_NATIVE MASK_40_SMALL
  #define MASK_60_NATIVE MASK_60_SMALL
  #define MASK_65_NATIVE MASK_65_SMALL
  #define MASK_01_NATIVE MASK_01_SMALL
  #define MASK_8000_NATIVE MASK_8000_SMALL
  #define MASK_FF80_NATIVE MASK_FF80_SMALL
  #define MASK_7FFF_NATIVE MASK_7FFF_SMALL
  #define MASK_007F_NATIVE MASK_007F_SMALL
  #define MASK_0040_NATIVE MASK_0040_SMALL
  #define MASK_0060_NATIVE MASK_0060_SMALL
  #define MASK_0065_NATIVE MASK_0065_SMALL
  #define MASK_0001_NATIVE MASK_0001_SMALL
#else
  #define CHARS_IN_NATIVE 8
  #define WORDS_IN_NATIVE 4
  #define MASK_80_NATIVE MASK_80_LARGE
  #define MASK_7F_NATIVE MASK_7F_LARGE
  #define MASK_40_NATIVE MASK_40_LARGE
  #define MASK_60_NATIVE MASK_60_LARGE
  #define MASK_65_NATIVE MASK_65_LARGE
  #define MASK_01_NATIVE MASK_01_LARGE
  #define MASK_8000_NATIVE MASK_8000_LARGE
  #define MASK_FF80_NATIVE MASK_FF80_LARGE
  #define MASK_7FFF_NATIVE MASK_7FFF_LARGE
  #define MASK_007F_NATIVE MASK_007F_LARGE
  #define MASK_0040_NATIVE MASK_0040_LARGE
  #define MASK_0060_NATIVE MASK_0060_LARGE
  #define MASK_0065_NATIVE MASK_0065_LARGE
  #define MASK_0001_NATIVE MASK_0001_LARGE
#endif
#define rtl_string_addref(rec) \
{  \
    if ((rec - 1)->refcount > 0) \
    { \
        if ((rec - 1)->refcount == 1) (rec - 1)->refcount = 2; \
        else \
        atomic_increment(&(rec - 1)->refcount); \
    } \
}
#define rtl_string_addref_new rtl_string_addref
#define rtl_string_addref_nextgen rtl_dynarray_addref_nextgen
#define rtl_string_addref_fpc(rec) \
{  \
    if ((rec - 1)->refcount > 0) \
    { \
        if ((rec - 1)->refcount == 1) (rec - 1)->refcount = 2; \
        else \
        atomic_increment(&(rec - 1)->refcount); \
    } \
}
#define rtl_string_release(rec, return_address, failure_value) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        ((rec - 1)->refcount > 0 && atomic_decrement(&(rec - 1)->refcount) == 0) \
      ) \
      rtl_freemem(rec - 1, return_address, failure_value); \
}
#define rtl_string_release_new rtl_string_release
#define rtl_string_release_nextgen rtl_dynarray_release_nextgen
#define rtl_string_release_fpc(rec, return_address, failure_value) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        ((rec - 1)->refcount > 0 && atomic_decrement(&(rec - 1)->refcount) == 0) \
      ) \
      rtl_freemem_fpc(rec - 1, return_address, failure_value); \
}
#define rtl_lstr_markup(rec, length, codepage) \
{ \
  (rec - 1)->length = length; \
  ((uint8_t*)rec)[length] = 0; \
}
#define rtl_lstr_markup_new(rec, length, codepage) \
{ \
  (rec - 1)->cpelemsize = ((uint32_t)codepage) + 0x10000; \
  rtl_lstr_markup(rec, length, codepage) \
}
#define rtl_lstr_markup_nextgen rtl_lstr_markup
#define rtl_lstr_markup_fpc(rec, length, codepage)\
{ \
  (rec - 1)->cpelemsize = ((uint32_t)codepage) + 0x10000; \
  rtl_lstr_markup(rec, length, codepage) \
}
#define USTR_CPELEMSIZE 0x204B0
#define rtl_ustr_markup_new(rec, length) \
{ \
  (rec - 1)->cpelemsize = USTR_CPELEMSIZE; \
  (rec - 1)->length = length; \
  ((uint16_t*)rec)[length] = 0; \
}
#define rtl_ustr_markup_nextgen rtl_ustr_markup
#define rtl_ustr_markup_fpc(rec, length) \
{ \
  (rec - 1)->cpelemsize = USTR_CPELEMSIZE; \
  (rec - 1)->length = length; \
  ((uint16_t*)rec)[length] = 0; \
}
#define rtl_cstr_markup(rec, length) \
{ \
  (rec - 1)->length = length; \
  ((uint32_t*)rec)[length] = 0; \
}
#define rtl_cstr_markup_new rtl_cstr_markup
#define rtl_cstr_markup_nextgen rtl_cstr_markup
#define rtl_cstr_markup_fpc(rec, length) \
{ \
  (rec - 1)->high = length - 1; \
  ((uint32_t*)rec)[length] = 0; \
}
REGISTER_DECL native_uint AStrLen(char8_t* chars);
REGISTER_DECL native_uint WStrLen(char16_t* chars);
REGISTER_DECL native_uint CStrLen(char32_t* chars);
#if defined (MSWINDOWS)
REGISTER_DECL void WStrClear(void* value);
REGISTER_DECL void* WStrInit(void* value, char16_t* chars, uint32_t length);
REGISTER_DECL void* WStrReserve(void* value, uint32_t length);
REGISTER_DECL void* WStrSetLength(void* value, uint32_t length);
#endif
REGISTER_DECL void AStrClear_new(void* value);
REGISTER_DECL void AStrClear_nextgen(void* value);
REGISTER_DECL void AStrClear_fpc(void* value);
REGISTER_DECL void UStrClear_new(void* value);
REGISTER_DECL void UStrClear_fpc(void* value);
REGISTER_DECL void CStrClear(void* value);
REGISTER_DECL void CStrClear_fpc(void* value);
REGISTER_DECL void* AStrInit_new(void* value, char8_t* chars, uint32_t length, uint16_t codepage);
REGISTER_DECL void* AStrInit_nextgen(void* value, char8_t* chars, uint32_t length, uint16_t codepage);
REGISTER_DECL void* AStrInit_fpc(void* value, char8_t* chars, uint32_t length, uint16_t codepage);
REGISTER_DECL void* UStrInit_new(void* value, char16_t* chars, uint32_t length);
REGISTER_DECL void* UStrInit_fpc(void* value, char16_t* chars, uint32_t length);
REGISTER_DECL void* CStrInit(void* value, char32_t* chars, uint32_t length);
REGISTER_DECL void* CStrInit_fpc(void* value, char32_t* chars, uint32_t length);
REGISTER_DECL void* AStrReserve_new(void* value, uint32_t length);
REGISTER_DECL void* AStrReserve_nextgen(void* value, uint32_t length);
REGISTER_DECL void* AStrReserve_fpc(void* value, uint32_t length);
REGISTER_DECL void* UStrReserve_new(void* value, uint32_t length);
REGISTER_DECL void* UStrReserve_fpc(void* value, uint32_t length);
REGISTER_DECL void* CStrReserve(void* value, uint32_t length);
REGISTER_DECL void* CStrReserve_fpc(void* value, uint32_t length);
REGISTER_DECL void* AStrSetLength_new(void* value, uint32_t length, uint16_t codepage);
REGISTER_DECL void* AStrSetLength_nextgen(void* value, uint32_t length, uint16_t codepage);
REGISTER_DECL void* AStrSetLength_fpc(void* value, uint32_t length, uint16_t codepage);
REGISTER_DECL void* UStrSetLength(void* value, uint32_t length);
REGISTER_DECL void* UStrSetLength_new(void* value, uint32_t length);
REGISTER_DECL void* UStrSetLength_fpc(void* value, uint32_t length);
REGISTER_DECL void* CStrSetLength(void* value, uint32_t length);
REGISTER_DECL void* CStrSetLength_fpc(void* value, uint32_t length);


/*
    General
*/
ptr_t DUMMY_INTERFACE_DATA;
#define DUMMY_INTERFACE ((void*)&DUMMY_INTERFACE_DATA)
#ifdef MSWINDOWS
  uint32_t MainThreadID;
#else
  native_uint MainThreadID;
#endif
uint32_t CompilerMode;
uint16_t DefaultCP;
bool IDERunning;


/*
    TimeStamp routine
*/
REGISTER_DECL int64_t tm_to_timestamp(void *_tm);


/*
    Preallocated routine
*/
typedef REGISTER_DECL void (*PreallocatedCallback)(ptr_t param, void* memory, native_uint size);
REGISTER_DECL void preallocated_call(ptr_t param, native_uint size, PreallocatedCallback callback);

#endif
