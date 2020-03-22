
#include "tiny.defines.h"
#include "tiny.rtti.h"


/* Internal types */

#pragma pack(push, 1)
typedef struct
{
   uint8_t bytes[16];
}
data16;
#pragma pack(pop)


/* Delphi/FPC RTL structures */

#pragma pack(push, 1)
typedef struct
{
    #if defined(LARGEINT)
    int32_t _padding;
    #endif
    int32_t refcount;
    size_t length;
}
DelphiDynArrayRec;
typedef struct
{
    size_t refcount;
    size_t high;
}
FPCDynArrayRec;

typedef struct
{
    #if defined(LARGEINT)
    int32_t _padding;
    #endif
    union
    {
        int32_t cpelemsize;
        struct {uint16_t code_page; uint16_t elem_size;};
    };
    int32_t refcount;
    int32_t length;
}
DelphiStrRec;
typedef struct
{
    union
    {
        int32_t cpelemsize;
        struct {uint16_t code_page; uint16_t elem_size;};
    };
    #if defined(LARGEINT)
    int32_t _padding;
    #endif
    size_t refcount;
    size_t length;
}
FPCStrRec;
typedef struct
{
    int32_t refcount;
    int32_t length;
}
OldDelphiStrRec;

typedef struct
{
    uint32_t size;
}
WideStrRec;

typedef struct
{
    ptr_t* VMT;
}
InterfaceRec;

typedef STDCALL int32_t (*DelphiInterfaceFunc)(InterfaceRec* instance);
#if defined (MSWINDOWS)
  typedef STDCALL int32_t (*FPCInterfaceFunc)(InterfaceRec* instance);
#else
  typedef CDECL int32_t (*FPCInterfaceFunc)(InterfaceRec* instance);
#endif

typedef struct
{
    int32_t elsize;
    ptr_t* eltype;
    int32_t vartype;
    ptr_t* eltype2;
}
DelphiDynArrayData;
typedef struct
{
    usize_t elsize;
    ptr_t eltype2;
    int32_t vartype;
    ptr_t eltype;
}
FPCDynArrayData;

typedef struct
{
    int32_t size;
    int32_t count;
    ptr_t* eltype;
}
DelphiStaticArrayData;
typedef struct
{
    usize_t size;
    usize_t count;
    ptr_t eltype;
}
FPCStaticArrayData;

typedef struct
{
    int32_t size;
    int32_t managed_field_count;
    struct
    {
    } managed_fields;
}
RTLRecordData;

#if defined (SMALLINT)
  #define RTL_VARIANT_SIZE 16
#else
  #define RTL_VARIANT_SIZE 24
#endif
typedef struct
{
    union
    {
        struct {uint16_t vartype; uint8_t vardata[RTL_VARIANT_SIZE - sizeof(uint16_t)];};
        uint8_t rawdata[RTL_VARIANT_SIZE];
    };
}
RTLVariant/*TVarData*/;

typedef struct
{
    ptr_t code;
    ptr_t data;
}
RTLMethod;
#pragma pack(pop)


/* atomic operations */

FORCEINLINE FORCEINLINE REGISTER_DECL int32_t atomic_increment(int32_t* value)
{
    return __sync_add_and_fetch(value, 1);
}

FORCEINLINE REGISTER_DECL int32_t atomic_incrementx(int32_t* value, int32_t x)
{
    return __sync_add_and_fetch(value, x);
}

FORCEINLINE REGISTER_DECL int32_t atomic_decrement(int32_t* value)
{
    return __sync_sub_and_fetch(value, 1);
}

FORCEINLINE REGISTER_DECL int32_t atomic_decrementx(int32_t* value, int32_t x)
{
    return __sync_sub_and_fetch(value, x);
}

FORCEINLINE REGISTER_DECL int64_t atomic_increment64(int64_t* value)
{
    return __sync_add_and_fetch(value, 1);
}

FORCEINLINE REGISTER_DECL int64_t atomic_increment64x(int64_t* value, int64_t x)
{
    return __sync_add_and_fetch(value, x);
}

FORCEINLINE REGISTER_DECL int64_t atomic_decrement64(int64_t* value)
{
    return __sync_sub_and_fetch(value, 1);
}

FORCEINLINE REGISTER_DECL int64_t atomic_decrement64x(int64_t* value, int64_t x)
{
    return __sync_sub_and_fetch(value, x);
}

FORCEINLINE REGISTER_DECL size_t atomic_incrementN(size_t* value)
{
    return __sync_add_and_fetch(value, 1);
}

FORCEINLINE REGISTER_DECL size_t atomic_incrementNx(size_t* value, size_t x)
{
    return __sync_add_and_fetch(value, x);
}

FORCEINLINE REGISTER_DECL size_t atomic_decrementN(size_t* value)
{
    return __sync_sub_and_fetch(value, 1);
}

FORCEINLINE REGISTER_DECL size_t atomic_decrementNx(size_t* value, size_t x)
{
    return __sync_sub_and_fetch(value, x);
}


/* Internal functions */

RttiOptions rtti_options;

FORCEINLINE RttiOptions* get_rtti_options()
{
    return &rtti_options;
}

REGISTER_DECL void internal_memmove(void* target, void* source, uint32_t size)
{
    for (int i = (size / 16); i != 0; i--)
    {
        *(data16*)target = *(data16*)source;
        target = (uint8_t*)target + sizeof(data16);
        source = (uint8_t*)source + sizeof(data16);
    }

    if (size & 8)
    {
        *(uint64_t*)target = *(uint64_t*)source;
        target = (uint8_t*)target + sizeof(uint64_t);
        source = (uint8_t*)source + sizeof(uint64_t);
    }
    if (size & 4)
    {
        *(uint32_t*)target = *(uint32_t*)source;
        target = (uint8_t*)target + sizeof(uint32_t);
        source = (uint8_t*)source + sizeof(uint32_t);
    }
    if (size & 2)
    {
        *(uint16_t*)target = *(uint16_t*)source;
        target = (uint8_t*)target + sizeof(uint16_t);
        source = (uint8_t*)source + sizeof(uint16_t);
    }
    if (size & 1)
    {
        *(uint8_t*)target = *(uint8_t*)source;
    }
}

#if defined (DELPHI)
FORCEINLINE REGISTER_DECL ptr_t internal_rtl_getmem(size_t size, void* return_address)
{
    ptr_t r = rtti_options.getmem(size);
    if (r == 0)
    {
        rtti_options.error_handler(ERRORCODE_OUTOFMEMORY, 0, return_address);
        r = 0;
    }
    return r;
}

FORCEINLINE REGISTER_DECL void internal_delphi_freemem(ptr_t p, void* return_address)
{
    int32_t r = rtti_options.freemem(p);
    if (r != 0)
    {
        rtti_options.error_handler(ERRORCODE_INVALIDPTR, 0, return_address);
    }
}

FORCEINLINE REGISTER_DECL void internal_fpc_freemem(ptr_t p, void* return_address)
{
    int32_t r = rtti_options.freemem(p);
    if (r == 0)
    {
        rtti_options.error_handler(ERRORCODE_INVALIDPTR, 0, return_address);
    }
}

#define internal_delphi_string_addref(rec) \
{  \
    if ((rec - 1)->refcount > 0) \
    { \
        if ((rec - 1)->refcount == 1) (rec - 1)->refcount = 2; \
        else \
        atomic_increment(&(rec - 1)->refcount); \
    } \
}
#define internal_olddelphi_string_addref(rec) internal_delphi_string_addref(rec)

#define internal_fpc_string_addref(rec) \
{  \
    if ((rec - 1)->refcount > 0) \
    { \
        if ((rec - 1)->refcount == 1) (rec - 1)->refcount = 2; \
        else \
        atomic_incrementN(&(rec - 1)->refcount); \
    } \
}

#define internal_delphi_string_release(rec, return_address) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        ((rec - 1)->refcount > 0 && atomic_decrement(&(rec - 1)->refcount) == 0) \
      ) \
      internal_delphi_freemem(rec - 1, return_address); \
}
#define internal_olddelphi_string_release(rec, return_address) internal_delphi_string_release(rec, return_address)

#define internal_fpc_string_release(rec, return_address) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        ((rec - 1)->refcount > 0 && atomic_decrementN(&(rec - 1)->refcount) == 0) \
      ) \
      internal_fpc_freemem(rec - 1, return_address); \
}

#define internal_delphi_dynarray_addref(rec) \
{  \
    if ((rec - 1)->refcount > 0) \
    { \
        if ((rec - 1)->refcount == 1) (rec - 1)->refcount = 2; \
        else \
        atomic_increment(&(rec - 1)->refcount); \
    } \
}

#define internal_fpc_dynarray_addref(rec) \
{  \
    if ((rec - 1)->refcount == 1) (rec - 1)->refcount = 2; \
    else \
    atomic_incrementN(&(rec - 1)->refcount); \
}

#define internal_delphi_dynarray_release_simple(rec, return_address) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        ((rec - 1)->refcount > 0 && atomic_decrement(&(rec - 1)->refcount) == 0) \
      ) \
      internal_delphi_freemem(rec - 1, return_address); \
}

#define internal_fpc_dynarray_release_simple(rec, return_address) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        atomic_decrementN(&(rec - 1)->refcount) == 0 \
      ) \
      internal_fpc_freemem(rec - 1, return_address); \
}

#define internal_delphi_dynarray_release(rec, return_address) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        ((rec - 1)->refcount > 0 && atomic_decrement(&(rec - 1)->refcount) == 0) \
      ) \
        { \
            if ((rec - 1)->length > 0) rtti_options.final_array(rec, *((DelphiDynArrayData*)type->custom_data)->eltype, (rec - 1)->length); \
            internal_delphi_freemem(rec - 1, return_address); \
        } \
}

#define internal_fpc_dynarray_release(rec, return_address) \
{ \
    if ( \
        (rec - 1)->refcount == 1 || \
        atomic_decrementN(&(rec - 1)->refcount) == 0 \
      ) \
        { \
            if ((rec - 1)->high >= 0) rtti_options.final_array(rec, ((FPCDynArrayData*)type->custom_data)->eltype, (rec - 1)->high + 1); \
            internal_fpc_freemem(rec - 1, return_address); \
        } \
}

FORCEINLINE REGISTER_DECL void* get_delphi_record_typeinfo(uint8_t* data)
{
    data -= 2;
    for (uint8_t* target = data; ; target--)
    {
        if (target + target[1] == data)
        {
            if (target[0] == 14 /*tkRecord*/ || target[0] == 22 /*tkMRecord*/)
            {
                return target;
            }
        }
    }
}

FORCEINLINE REGISTER_DECL void* get_fpc_record_typeinfo(uint8_t* data)
{
    data -= 2;
    for (uint8_t* target = data; ; target--)
    {
        if (target + target[1] == data)
        {
            if (target[0] == 13 /*tkRecord*/ || target[0] == 16 /*tkObject*/)
            {
                return target;
            }
        }
    }
}

REGISTER_DECL RttiTypeRules* get_rules(RttiExType* type, RttiTypeRules* buffer)
{
    usize_t options = type->options;
    if ((options & 0xff00) == 0)
    {
        RttiTypeRules* r = rtti_options.rules[options & 0xff];
        if (r) return r;

        RttiMetaType* meta_type = type->meta_type;
        if ((meta_type->marker & RTTI_TYPEDATA_MASK) == RTTI_TYPEDATA_MARKER)
        {
            return &meta_type->rules;
        }
        else
        {
            return rtti_options.get_calculated_rules(type, buffer);
        }
    }
    else
    {
        return rtti_options.rules[1];
    }
}
#endif


/* initialize/finalize/copy none */

REGISTER_DECL void none_func()
{
}


/* initialization functions */

REGISTER_DECL void init_metatype_func(RttiExType* type, void* value)
{
    RttiMetaType* meta_type = type->meta_type;
    meta_type->init_func(meta_type, value);
}

REGISTER_DECL void init_value_func(RttiExType* type, void* value)
{
    ((RttiValue*)value)->managed_data = 0;
}

#define init_data(n) REGISTER_DECL void init_data##n(RttiExType* type, void* value) \
{ \
    struct {uint8_t bytes[n];} *v = value, null = {0}; \
    *v = null; \
}

#define init_data0 none_func
init_data(1);
init_data(2);
init_data(3);
init_data(4);
init_data(5);
init_data(6);
init_data(7);
init_data(8);
init_data(9);
init_data(10);
init_data(11);
init_data(12);
init_data(13);
init_data(14);
init_data(15);
init_data(16);
init_data(17);
init_data(18);
init_data(19);
init_data(20);
init_data(21);
init_data(22);
init_data(23);
init_data(24);
init_data(25);
init_data(26);
init_data(27);
init_data(28);
init_data(29);
init_data(30);
init_data(31);
init_data(32);

#if defined (DELPHI)
REGISTER_DECL void init_delphi_staticarray_func(RttiExType* type, void* value)
{
    DelphiStaticArrayData* data = type->custom_data;
    rtti_options.init_array(value, *data->eltype, data->count);
}

REGISTER_DECL void init_fpc_staticarray_func(RttiExType* type, void* value)
{
    FPCStaticArrayData* data = type->custom_data;
    rtti_options.init_array(value, data->eltype, data->count);
}

REGISTER_DECL void init_delphi_structure_func(RttiExType* type, void* value)
{
    void* typeinfo = get_delphi_record_typeinfo(type->custom_data);
    rtti_options.init_structure(value, typeinfo);
}

REGISTER_DECL void init_fpc_structure_func(RttiExType* type, void* value)
{
    void* typeinfo = get_fpc_record_typeinfo(type->custom_data);
    rtti_options.init_structure(value, typeinfo);
}
#endif


/* finalization functions */

REGISTER_DECL void final_metatype_func(RttiExType* type, void* value)
{
    RttiMetaType* meta_type = type->meta_type;
    meta_type->final_func(meta_type, value);
}

REGISTER_DECL void final_metatype_weakfunc(RttiExType* type, void* value)
{
    RttiMetaType* meta_type = type->meta_type;
    meta_type->weak_final_func(meta_type, value);
}

#if defined (DELPHI)
REGISTER_DECL void final_delphi_interface(RttiExType* type, void* value)
{
    InterfaceRec* interface = *((ptr_t*)value);
    if (interface)
    {
        *((ptr_t*)value) = 0;
        DelphiInterfaceFunc func = interface->VMT[2/*Release*/];
        func(interface);
    }
}

REGISTER_DECL void final_fpc_interface(RttiExType* type, void* value)
{
    InterfaceRec* interface = *((ptr_t*)value);
    if (interface)
    {
        *((ptr_t*)value) = 0;
        FPCInterfaceFunc func = interface->VMT[2/*Release*/];
        func(interface);
    }
}

REGISTER_DECL void final_delphi_value(RttiExType* type, void* value)
{
    final_delphi_interface(type, &((RttiValue*)value)->managed_data);
}

REGISTER_DECL void final_fpc_value(RttiExType* type, void* value)
{
    final_fpc_interface(type, &((RttiValue*)value)->managed_data);
}
#else
REGISTER_DECL void final_value(RttiExType* type, void* value)
{
    RTTI_FINAL_FUNCS[3](type, &((RttiValue*)value)->managed_data);
}
#endif

#if defined (DELPHI)
REGISTER_DECL void final_delphi_string(RttiExType* type, void* value)
{
    DelphiStrRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        internal_delphi_string_release(rec, RETURN_ADDRESS);
    }
}

REGISTER_DECL void final_olddelphi_string(RttiExType* type, void* value)
{
    OldDelphiStrRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        internal_olddelphi_string_release(rec, RETURN_ADDRESS);
    }
}

REGISTER_DECL void final_fpc_string(RttiExType* type, void* value)
{
    FPCStrRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        internal_fpc_string_release(rec, RETURN_ADDRESS);
    }
}
#endif

#if defined (MSWINDOWS)
REGISTER_DECL void final_widestring(RttiExType* type, void* value)
{
    void* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtti_options.SysFreeString(rec);
    }
}
#endif

#if defined (DELPHI)
REGISTER_DECL void final_delphi_weakinterface(RttiExType* type, void* value)
{
    ptr_t interface = *((ptr_t*)value);
    if (interface)
    {
        rtti_options.weakinterface_clear(value);
    }
}

REGISTER_DECL void final_delphi_refobject(RttiExType* type, void* value)
{
    ptr_t object = *((ptr_t*)value);
    if (object)
    {
        *((ptr_t*)value) = 0;
        ptr_t VMT = *((ptr_t*)object);
        GeneralFunc1 func = *(GeneralFunc1*)((uint8_t*)VMT + rtti_options.vmt_obj_release);
        func(object);
    }
}

REGISTER_DECL void final_delphi_weakrefobject(RttiExType* type, void* value)
{
    ptr_t object = *((ptr_t*)value);
    if (object)
    {
        rtti_options.weakrefobject_clear(value);
    }
}

REGISTER_DECL void final_rtl_variant(RttiExType* type, void* value)
{
    RTLVariant* rec = value;
    uint32_t vartype = rec->vartype;
    if ((vartype & 0xBFE8/*varDeepData*/) == 0 ||
        vartype == 0x000B/*vt_bool*/ ||
        (vartype >= 0x000D/*vt_unknown*/ && vartype <= 0x0015/*vt_ui8*/))
        {
            rec->vartype = 0;
        }
        else
        {
            rtti_options.variant_clear(value);
        }
}

REGISTER_DECL void final_delphi_weakmethod(RttiExType* type, void* value)
{
    RTLMethod* rec = value;
    if (rec->data)
    {
        rtti_options.weakmethod_clear(rec);
    }
    else
    {
        rec->code = 0;
    }
}

REGISTER_DECL void final_delphi_dynarray_simple(RttiExType* type, void* value)
{
    DelphiDynArrayRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        internal_delphi_dynarray_release_simple(rec, RETURN_ADDRESS);
    }
}

REGISTER_DECL void final_fpc_dynarray_simple(RttiExType* type, void* value)
{
    FPCDynArrayRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        internal_fpc_dynarray_release_simple(rec, RETURN_ADDRESS);
    }
}

REGISTER_DECL void final_delphi_dynarray(RttiExType* type, void* value)
{
    DelphiDynArrayRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        internal_delphi_dynarray_release(rec, RETURN_ADDRESS);
    }
}

REGISTER_DECL void final_fpc_dynarray(RttiExType* type, void* value)
{
    FPCDynArrayRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        internal_fpc_dynarray_release(rec, RETURN_ADDRESS);
    }
}

REGISTER_DECL void final_delphi_staticarray(RttiExType* type, void* value)
{
    DelphiStaticArrayData* data = type->custom_data;
    rtti_options.final_array(value, *data->eltype, data->count);
}

REGISTER_DECL void final_fpc_staticarray(RttiExType* type, void* value)
{
    FPCStaticArrayData* data = type->custom_data;
    rtti_options.final_array(value, data->eltype, data->count);
}

REGISTER_DECL void final_delphi_structure(RttiExType* type, void* value)
{
    void* typeinfo = get_delphi_record_typeinfo(type->custom_data);
    rtti_options.final_structure(value, typeinfo);
}

REGISTER_DECL void final_fpc_structure(RttiExType* type, void* value)
{
    void* typeinfo = get_fpc_record_typeinfo(type->custom_data);
    rtti_options.final_structure(value, typeinfo);
}
#endif


/* copy functions */

REGISTER_DECL void copy_refenence(RttiExType* type, void* target, void* source)
{
    *((ptr_t*)target) = source;
}

#if defined (CPUX86)
NAKED
REGISTER_DECL void copy_metatype_func(RttiExType* type, void* target, void* source)
{
    __asm__ volatile
    (
    ".intel_syntax noprefix\n\t"
      "mov eax, [eax + %c[meta_type]] \n\t"
      "jmp [eax + %c[copy_func]] \n\t"
    :
    :   /* input */
        [meta_type] "n" (offsetof(RttiExType, meta_type)),
        [copy_func] "n" (offsetof(RttiMetaType, copy_func))
    );
}
#else
REGISTER_DECL void copy_metatype_func(RttiExType* type, void* target, void* source)
{
    RttiMetaType* meta_type = type->meta_type;
    meta_type->copy_func(meta_type, target, source);
}
#endif

#if defined (CPUX86)
NAKED
REGISTER_DECL void copy_metatype_weakfunc(RttiExType* type, void* target, void* source)
{
    __asm__ volatile
    (
    ".intel_syntax noprefix\n\t"
      "mov eax, [eax + %c[meta_type]] \n\t"
      "jmp [eax + %c[weak_copy_func]] \n\t"
    :
    :   /* input */
        [meta_type] "n" (offsetof(RttiExType, meta_type)),
        [weak_copy_func] "n" (offsetof(RttiMetaType, weak_copy_func))
    );
}
#else
REGISTER_DECL void copy_metatype_weakfunc(RttiExType* type, void* target, void* source)
{
    RttiMetaType* meta_type = type->meta_type;
    meta_type->weak_copy_func(meta_type, target, source);
}
#endif

REGISTER_DECL void copy_metatype_bytes(RttiExType* type, void* target, void* source)
{
    uint32_t size = type->meta_type->rules.size;

    for (int i = (size / 16); i != 0; i--)
    {
        *(data16*)target = *(data16*)source;
        target = (uint8_t*)target + sizeof(data16);
        source = (uint8_t*)source + sizeof(data16);
    }

    if (size & 8)
    {
        *(uint64_t*)target = *(uint64_t*)source;
        target = (uint8_t*)target + sizeof(uint64_t);
        source = (uint8_t*)source + sizeof(uint64_t);
    }
    if (size & 4)
    {
        *(uint32_t*)target = *(uint32_t*)source;
        target = (uint8_t*)target + sizeof(uint32_t);
        source = (uint8_t*)source + sizeof(uint32_t);
    }
    if (size & 2)
    {
        *(uint16_t*)target = *(uint16_t*)source;
        target = (uint8_t*)target + sizeof(uint16_t);
        source = (uint8_t*)source + sizeof(uint16_t);
    }
    if (size & 1)
    {
        *(uint8_t*)target = *(uint8_t*)source;
    }
}

#if defined (DELPHI)
REGISTER_DECL void copy_delphi_interface(RttiExType* type, void* target, void* source)
{
    InterfaceRec* t = *((ptr_t*)target);
    InterfaceRec* s = *((ptr_t*)source);
    DelphiInterfaceFunc func;
    if (t != s)
    {
        if (s)
        {
            func = s->VMT[1/*AddRef*/];
            func(s);
        }
        *((ptr_t*)target) = s;
        if (t)
        {
            func = t->VMT[2/*Release*/];
            func(t);
        }
    }
}

REGISTER_DECL void copy_fpc_interface(RttiExType* type, void* target, void* source)
{
    InterfaceRec* t = *((ptr_t*)target);
    InterfaceRec* s = *((ptr_t*)source);
    FPCInterfaceFunc func;
    if (t != s)
    {
        if (s)
        {
            func = s->VMT[1/*AddRef*/];
            func(s);
        }
        *((ptr_t*)target) = s;
        if (t)
        {
            func = t->VMT[2/*Release*/];
            func(t);
        }
    }
}

REGISTER_DECL void copy_delphi_value(RttiExType* type, void* target, void* source)
{
    RttiValue* t = target;
    RttiValue* s = source;
    DelphiInterfaceFunc func;
    t->extype = s->extype;

    InterfaceRec* tintf = t->managed_data;
    InterfaceRec* sintf = s->managed_data;
    ptr_t dummy_interface = rtti_options.dummy_interface;
    if (tintf == sintf)
    {
        if (sintf == dummy_interface)
        {
            *((data16*)&t->buffer) = *((data16*)&s->buffer);
        }
    }
    else
    {
        if (sintf)
        {
            if (sintf == dummy_interface)
            {
                *((data16*)&t->buffer) = *((data16*)&s->buffer);
            }
            else
            {
                func = sintf->VMT[1/*AddRef*/];
                func(sintf);
                dummy_interface = rtti_options.dummy_interface;
            }
        }
        t->managed_data = sintf;

        if (tintf && tintf != dummy_interface)
        {
            func = tintf->VMT[2/*Release*/];
            func(tintf);
        }
    }
}

REGISTER_DECL void copy_fpc_value(RttiExType* type, void* target, void* source)
{
    RttiValue* t = target;
    RttiValue* s = source;
    FPCInterfaceFunc func;
    t->extype = s->extype;

    InterfaceRec* tintf = t->managed_data;
    InterfaceRec* sintf = s->managed_data;
    ptr_t dummy_interface = rtti_options.dummy_interface;
    if (tintf == sintf)
    {
        if (sintf == dummy_interface)
        {
            *((data16*)&t->buffer) = *((data16*)&s->buffer);
        }
    }
    else
    {
        if (sintf)
        {
            if (sintf == dummy_interface)
            {
                *((data16*)&t->buffer) = *((data16*)&s->buffer);
            }
            else
            {
                func = sintf->VMT[1/*AddRef*/];
                func(sintf);
                dummy_interface = rtti_options.dummy_interface;
            }
        }
        t->managed_data = sintf;

        if (tintf && tintf != dummy_interface)
        {
            func = tintf->VMT[2/*Release*/];
            func(tintf);
        }
    }
}
#else
REGISTER_DECL void copy_value(RttiExType* type, void* target, void* source)
{
    RttiValue* t = target;
    RttiValue* s = source;
    t->extype = s->extype;
    *((data16*)&t->buffer) = *((data16*)&s->buffer);
    RTTI_COPY_FUNCS[6](type, &t->managed_data, &s->managed_data);
}
#endif

#define copy_data(n) REGISTER_DECL void copy_data##n(RttiExType* type, void* target, void* source) \
{ \
    for (int i = 0; i < (n / 32); i++) \
    { \
        struct {uint8_t bytes[32];} *t32, *s32; \
        t32 = target; \
        s32 = source; \
        *t32 = *s32; \
        target = t32 + 1; \
        source = s32 + 1; \
    } \
    struct {uint8_t bytes[n & 31];} *t2, *s2; \
    t2 = target; \
    s2 = source; \
    *t2 = *s2; \
}

#define copy_data0 none_func
copy_data(1);
copy_data(2);
copy_data(3);
copy_data(4);
copy_data(5);
copy_data(6);
copy_data(7);
copy_data(8);
copy_data(9);
copy_data(10);
copy_data(11);
copy_data(12);
copy_data(13);
copy_data(14);
copy_data(15);
copy_data(16);
copy_data(17);
copy_data(18);
copy_data(19);
copy_data(20);
copy_data(21);
copy_data(22);
copy_data(23);
copy_data(24);
copy_data(25);
copy_data(26);
copy_data(27);
copy_data(28);
copy_data(29);
copy_data(30);
copy_data(31);
copy_data(32);
copy_data(33);
copy_data(34);
copy_data(35);
copy_data(36);
copy_data(37);
copy_data(38);
copy_data(39);
copy_data(40);
copy_data(41);
copy_data(42);
copy_data(43);
copy_data(44);
copy_data(45);
copy_data(46);
copy_data(47);
copy_data(48);
copy_data(49);
copy_data(50);
copy_data(51);
copy_data(52);
copy_data(53);
copy_data(54);
copy_data(55);
copy_data(56);
copy_data(57);
copy_data(58);
copy_data(59);
copy_data(60);
copy_data(61);
copy_data(62);
copy_data(63);
copy_data(64);

REGISTER_DECL void copy_hfaread_f2(RttiExType* type, void* target, void* source)
{
    uint32_t* t = target;
    uint32_t* s = source;

    t[0] = s[0];
    t[1] = s[2];
}

REGISTER_DECL void copy_hfaread_f3(RttiExType* type, void* target, void* source)
{
    uint32_t* t = target;
    uint32_t* s = source;

    t[0] = s[0];
    t[1] = s[2];
    t[2] = s[4];
}

REGISTER_DECL void copy_hfaread_f4(RttiExType* type, void* target, void* source)
{
    uint32_t* t = target;
    uint32_t* s = source;

    t[0] = s[0];
    t[1] = s[2];
    t[2] = s[4];
    t[3] = s[6];
}

REGISTER_DECL void copy_hfawrite_f2(RttiExType* type, void* target, void* source)
{
    uint32_t* t = target;
    uint32_t* s = source;

    t[0] = s[0];
    t[2] = s[1];
}

REGISTER_DECL void copy_hfawrite_f3(RttiExType* type, void* target, void* source)
{
    uint32_t* t = target;
    uint32_t* s = source;

    t[0] = s[0];
    t[2] = s[1];
    t[4] = s[2];
}

REGISTER_DECL void copy_hfawrite_f4(RttiExType* type, void* target, void* source)
{
    uint32_t* t = target;
    uint32_t* s = source;

    t[0] = s[0];
    t[2] = s[1];
    t[4] = s[2];
    t[6] = s[3];
}

REGISTER_DECL void copy_shortstring(RttiExType* type, void* target, void* source)
{
    usize_t length = *((uint8_t*)source);
    usize_t max_length = type->max_length;
    if (length > max_length) length = max_length;
    length++;

    for (int i = (length / 16); i != 0; i--)
    {
        *(data16*)target = *(data16*)source;
        target = (uint8_t*)target + sizeof(data16);
        source = (uint8_t*)source + sizeof(data16);
    }
    uint8_t* stored_target = (uint8_t*)target - (length & sizeof(data16));

    if (length & 8)
    {
        *(uint64_t*)target = *(uint64_t*)source;
        target = (uint8_t*)target + sizeof(uint64_t);
        source = (uint8_t*)source + sizeof(uint64_t);
    }
    if (length & 4)
    {
        *(uint32_t*)target = *(uint32_t*)source;
        target = (uint8_t*)target + sizeof(uint32_t);
        source = (uint8_t*)source + sizeof(uint32_t);
    }
    if (length & 2)
    {
        *(uint16_t*)target = *(uint16_t*)source;
        target = (uint8_t*)target + sizeof(uint16_t);
        source = (uint8_t*)source + sizeof(uint16_t);
    }
    if (length & 1)
    {
        *(uint8_t*)target = *(uint8_t*)source;
    }

    *stored_target = length - 1;
}

#if defined (DELPHI)
REGISTER_DECL void copy_delphi_string(RttiExType* type, void* target, void* source)
{
    DelphiStrRec* t = *((ptr_t*)target);
    DelphiStrRec* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s) internal_delphi_string_addref(s);
        *((ptr_t*)target) = s;
        if (t) internal_delphi_string_release(t, RETURN_ADDRESS);
    }
}

REGISTER_DECL void copy_olddelphi_string(RttiExType* type, void* target, void* source)
{
    OldDelphiStrRec* t = *((ptr_t*)target);
    OldDelphiStrRec* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s) internal_olddelphi_string_addref(s);
        *((ptr_t*)target) = s;
        if (t) internal_olddelphi_string_release(t, RETURN_ADDRESS);
    }
}

REGISTER_DECL void copy_fpc_string(RttiExType* type, void* target, void* source)
{
    FPCStrRec* t = *((ptr_t*)target);
    FPCStrRec* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s) internal_fpc_string_addref(s);
        *((ptr_t*)target) = s;
        if (t) internal_fpc_string_release(t, RETURN_ADDRESS);
    }
}
#endif

#if defined (MSWINDOWS)
REGISTER_DECL void copy_widestring(RttiExType* type, void* target, void* source)
{
    WideStrRec* t = *((ptr_t*)target);
    WideStrRec* s = *((ptr_t*)source);
    if (t != s)
    {
        if (!s)
        {
            *((ptr_t*)target) = 0;
            rtti_options.SysFreeString(t);
        }
        else
        {
            if (!t)
            {
                *((ptr_t*)target) = rtti_options.SysAllocStringLen((char16_t*)s, (s - 1)->size >> 1);
            }
            else
            {
                rtti_options.SysReAllocStringLen(target, (char16_t*)s, (s - 1)->size >> 1);
            }
        }
    }
}
#endif

#if defined (DELPHI)
REGISTER_DECL void copy_delphi_weakinterface(RttiExType* type, void* target, void* source)
{
    ptr_t interface = *((ptr_t*)source);
    if (*((ptr_t*)target) != interface)
    {
        if (interface)
        {
            rtti_options.weakinterface_copy(target, source);
        }
        else
        {
            rtti_options.weakinterface_clear(target);
        }
    }
}

REGISTER_DECL void copy_delphi_refobject(RttiExType* type, void* target, void* source)
{
    ptr_t t = *((ptr_t*)target);
    ptr_t s = *((ptr_t*)source);
    ptr_t VMT;
    GeneralFunc1 func;
    if (t != s)
    {
        if (s)
        {
            VMT = *((ptr_t*)s);
            func = *(GeneralFunc1*)((uint8_t*)VMT + rtti_options.vmt_obj_addref);
            func(s);
        }
        *((ptr_t*)target) = s;
        if (t)
        {
            VMT = *((ptr_t*)t);
            func = *(GeneralFunc1*)((uint8_t*)VMT + rtti_options.vmt_obj_release);
            func(t);
        }
    }
}

REGISTER_DECL void copy_delphi_weakrefobject(RttiExType* type, void* target, void* source)
{
    ptr_t object = *((ptr_t*)source);
    if (*((ptr_t*)target) != object)
    {
        if (object)
        {
            rtti_options.weakrefobject_copy(target, source);
        }
        else
        {
            rtti_options.weakrefobject_clear(target);
        }
    }
}

REGISTER_DECL void copy_rtl_variant(RttiExType* type, void* target, void* source)
{
    rtti_options.variant_copy(target, source);
}

REGISTER_DECL void copy_delphi_weakmethod(RttiExType* type, void* target, void* source)
{
    RTLMethod* t = target;
    RTLMethod* s = source;
    if (t->data != s->data)
    {
        if (s->data)
        {
            rtti_options.weakmethod_copy(t, s);
        }
        else
        {
            rtti_options.weakmethod_clear(t);
        }
    }
    else
    {
        t->code = s->code;
    }
}

REGISTER_DECL void copy_delphi_dynarray_simple(RttiExType* type, void* target, void* source)
{
    DelphiDynArrayRec* t = *((ptr_t*)target);
    DelphiDynArrayRec* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s) internal_delphi_dynarray_addref(s);
        *((ptr_t*)target) = s;
        if (t) internal_delphi_dynarray_release_simple(t, RETURN_ADDRESS);
    }
}

REGISTER_DECL void copy_fpc_dynarray_simple(RttiExType* type, void* target, void* source)
{
    FPCDynArrayRec* t = *((ptr_t*)target);
    FPCDynArrayRec* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s)
        {
            if (s->refcount > 0)
            {
                internal_fpc_dynarray_addref(s);
            }
            else
            {
                size_t length = (s - 1)->high + 1;
                FPCDynArrayData* data = type->custom_data;
                FPCDynArrayRec* temp = internal_rtl_getmem(sizeof(FPCDynArrayRec) + length * data->elsize, RETURN_ADDRESS);
                temp->refcount = 1;
                temp->high = length - 1;
                temp++;
                internal_memmove(temp, s, length * data->elsize);
                s = temp;
            }
        }
        *((ptr_t*)target) = s;
        if (t) internal_fpc_dynarray_release_simple(t, RETURN_ADDRESS);
    }
}

REGISTER_DECL void copy_delphi_dynarray(RttiExType* type, void* target, void* source)
{
    DelphiDynArrayRec* t = *((ptr_t*)target);
    DelphiDynArrayRec* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s) internal_delphi_dynarray_addref(s);
        *((ptr_t*)target) = s;
        if (t) internal_delphi_dynarray_release(t, RETURN_ADDRESS);
    }
}

REGISTER_DECL void copy_fpc_dynarray(RttiExType* type, void* target, void* source)
{
    FPCDynArrayRec* t = *((ptr_t*)target);
    FPCDynArrayRec* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s)
        {
            if (s->refcount > 0)
            {
                internal_fpc_dynarray_addref(s);
            }
            else
            {
                size_t length = (s - 1)->high + 1;
                FPCDynArrayData* data = type->custom_data;
                FPCDynArrayRec* temp = internal_rtl_getmem(sizeof(FPCDynArrayRec) + length * data->elsize, RETURN_ADDRESS);
                temp->refcount = 1;
                temp->high = length - 1;
                temp++;
                rtti_options.init_array(temp, data->eltype, length);
                rtti_options.copy_array(temp, s, data->eltype, length);
                s = temp;
            }
        }
        *((ptr_t*)target) = s;
        if (t) internal_fpc_dynarray_release(t, RETURN_ADDRESS);
    }
}

REGISTER_DECL void copy_delphi_staticarray_simple(RttiExType* type, void* target, void* source)
{
    DelphiStaticArrayData* data = type->custom_data;
    internal_memmove(target, source, data->size);
}

REGISTER_DECL void copy_fpc_staticarray_simple(RttiExType* type, void* target, void* source)
{
    FPCStaticArrayData* data = type->custom_data;
    internal_memmove(target, source, data->size);
}

REGISTER_DECL void copy_delphi_staticarray(RttiExType* type, void* target, void* source)
{
    DelphiStaticArrayData* data = type->custom_data;
    rtti_options.copy_array(target, source, *data->eltype, data->count);
}

REGISTER_DECL void copy_fpc_staticarray(RttiExType* type, void* target, void* source)
{
    FPCStaticArrayData* data = type->custom_data;
    rtti_options.copy_array(target, source, data->eltype, data->count);
}

REGISTER_DECL void copy_rtl_structure_simple(RttiExType* type, void* target, void* source)
{
    RTLRecordData* data = type->custom_data;
    internal_memmove(target, source, data->size);
}

REGISTER_DECL void copy_delphi_structure(RttiExType* type, void* target, void* source)
{
    void* typeinfo = get_delphi_record_typeinfo(type->custom_data);
    rtti_options.copy_structure(target, source, typeinfo);
}

REGISTER_DECL void copy_fpc_structure(RttiExType* type, void* target, void* source)
{
    void* typeinfo = get_fpc_record_typeinfo(type->custom_data);
    rtti_options.copy_structure(target, source, typeinfo);
}

REGISTER_DECL void copy_rtl_varopenstring_write(RttiExType* type, void* target, void* source)
{
    RttiArgument* argument = (RttiArgument*)type;
    *((ptr_t*)target) = source;
    *((size_t*)target + argument->high_offset) = argument->max_length;
}

REGISTER_DECL void copy_delphi_argarray_read(RttiExType* type, void* target, void* source)
{
    RttiTypeRules rules_buffer;
    RttiTypeRules* rules = get_rules(type, &rules_buffer);
    uint8_t *t, *s;
    usize_t elsize = rules->size;
    usize_t length;
    RttiTypeFunc func;
    RttiCopyFunc copy_func;

    // dynarray_releasesimple + optional finalization
    DelphiDynArrayRec* rec = *((ptr_t*)target);
    if (rec)
    {
        *((ptr_t*)target) = 0;
        if (
            (rec - 1)->refcount == 1 || \
            ((rec - 1)->refcount > 0 && atomic_decrement(&(rec - 1)->refcount) == 0) \
            )
        {
            if (rules->final_func != 0)
            {
                func = RTTI_FINAL_FUNCS[rules->final_func];
                t = (uint8_t*)rec;
                length = (rec - 1)->length;
                for (; length != 0; length--)
                {
                    func(type, t);
                    t += elsize;
                }
            }
            internal_delphi_freemem(rec - 1, RETURN_ADDRESS);
        }
    }

    // new dynamic array
    RttiArgument* argument = (RttiArgument*)type;
    length = *((size_t*)source + argument->high_offset) + 1;
    if (!length) return;
    rec = internal_rtl_getmem(sizeof(DelphiDynArrayRec) + length * elsize, RETURN_ADDRESS);
    rec->refcount = 1;
    rec->length = length;
    if (rules->init_func != 0)
    {
        func = RTTI_INIT_FUNCS[rules->init_func];
        t = (uint8_t*)rec;
        for (; length != 0; length--)
        {
            func(type, t);
            t += elsize;
        }
        length = (rec - 1)->length;
    }
    *((ptr_t*)target) = rec;

    // copying
    t = (uint8_t*)rec;
    s = (uint8_t*)source;
    copy_func = RTTI_COPY_FUNCS[rules->copy_func];
    for (; length != 0; length--)
    {
        copy_func(type, t, s);
        t += elsize;
        s += elsize;
    }
}

REGISTER_DECL void copy_fpc_argarray_read(RttiExType* type, void* target, void* source)
{
    RttiTypeRules rules_buffer;
    RttiTypeRules* rules = get_rules(type, &rules_buffer);
    uint8_t *t, *s;
    usize_t elsize = rules->size;
    usize_t length;
    RttiTypeFunc func;
    RttiCopyFunc copy_func;

    // dynarray_releasesimple + optional finalization
    FPCDynArrayRec* rec = *((ptr_t*)target);
    if (rec)
    {
        *((ptr_t*)target) = 0;
        if (
            (rec - 1)->refcount == 1 || \
            atomic_decrementN(&(rec - 1)->refcount) == 0 \
            )
        {
            if (rules->final_func != 0)
            {
                func = RTTI_FINAL_FUNCS[rules->final_func];
                t = (uint8_t*)rec;
                length = (rec - 1)->high + 1;
                for (; length != 0; length--)
                {
                    func(type, t);
                    t += elsize;
                }
            }
            internal_fpc_freemem(rec - 1, RETURN_ADDRESS);
        }
    }

    // new dynamic array
    RttiArgument* argument = (RttiArgument*)type;
    length = *((size_t*)source + argument->high_offset) + 1;
    if (!length) return;
    rec = internal_rtl_getmem(sizeof(FPCDynArrayRec) + length * elsize, RETURN_ADDRESS);
    rec->refcount = 1;
    rec->high = length - 1;
    if (rules->init_func != 0)
    {
        func = RTTI_INIT_FUNCS[rules->init_func];
        t = (uint8_t*)rec;
        for (; length != 0; length--)
        {
            func(type, t);
            t += elsize;
        }
        length = (rec - 1)->high + 1;
    }
    *((ptr_t*)target) = rec;

    // copying
    t = (uint8_t*)rec;
    s = (uint8_t*)source;
    copy_func = RTTI_COPY_FUNCS[rules->copy_func];
    for (; length != 0; length--)
    {
        copy_func(type, t, s);
        t += elsize;
        s += elsize;
    }
}

REGISTER_DECL void copy_delphi_argarray_write(RttiExType* type, void* target, void* source)
{
    RttiArgument* argument = (RttiArgument*)type;
    DelphiDynArrayRec* rec = *((ptr_t*)source);
    size_t high = -1;
    if (rec)
    {
        high = (rec - 1)->length - 1;
    }
    *((ptr_t*)target) = rec;
    *((size_t*)target + argument->high_offset) = high;
}

REGISTER_DECL void copy_fpc_argarray_write(RttiExType* type, void* target, void* source)
{
    RttiArgument* argument = (RttiArgument*)type;
    FPCDynArrayRec* rec = *((ptr_t*)source);
    size_t high = -1;
    if (rec)
    {
        high = (rec - 1)->high;
    }
    *((ptr_t*)target) = rec;
    *((size_t*)target + argument->high_offset) = high;
}
#endif


/* initialization */

REGISTER_DECL void init_library(RttiOptions* options)
{
    // copy options to rtti_options variable
    void *target = &rtti_options, *source = options;
    for (int i = 0; i < (sizeof(RttiOptions) / 32); i++)
    {
        struct {uint8_t bytes[32];} *t32, *s32;
        t32 = target;
        s32 = source;
        *t32 = *s32;
        target = t32 + 1;
        source = s32 + 1;
    }
    struct {uint8_t bytes[sizeof(RttiOptions) & 31];} *t2, *s2;
    t2 = target;
    s2 = source;
    *t2 = *s2;

    // mode
    usize_t mode = options->mode;
    #if defined (DELPHI)
    uint32_t WEAKINTFREF = 0;
    uint32_t WEAKINSTREF = 0;
    if (mode != 0)
    {
        #if defined (CPUARM)
            if (mode >= 250)
            {
                WEAKINTFREF = 1;
                WEAKINSTREF = 1;
            }
        #else
            if (mode >= 310) WEAKINTFREF = 1;
            #if defined (LINUX64)
            if (mode == 320) WEAKINSTREF = 1;
            #endif
        #endif
    }
    #endif

    // initialization functions
    RTTI_INIT_FUNCS[0] = &none_func;
    #if defined (SMALLINT)
    RTTI_INIT_FUNCS[1] = &init_data4;
    RTTI_INIT_FUNCS[2] = &init_data8;
    #else
    RTTI_INIT_FUNCS[1] = &init_data8;
    RTTI_INIT_FUNCS[2] = &init_data16;
    #endif
    RTTI_INIT_FUNCS[3] = &init_metatype_func;
    RTTI_INIT_FUNCS[4] = &init_value_func;

    RTTI_INIT_FUNCS[5] = &init_data0;
    RTTI_INIT_FUNCS[6] = &init_data1;
    RTTI_INIT_FUNCS[7] = &init_data2;
    RTTI_INIT_FUNCS[8] = &init_data3;
    RTTI_INIT_FUNCS[9] = &init_data4;
    RTTI_INIT_FUNCS[10] = &init_data5;
    RTTI_INIT_FUNCS[11] = &init_data6;
    RTTI_INIT_FUNCS[12] = &init_data7;
    RTTI_INIT_FUNCS[13] = &init_data8;
    RTTI_INIT_FUNCS[14] = &init_data9;
    RTTI_INIT_FUNCS[15] = &init_data10;
    RTTI_INIT_FUNCS[16] = &init_data11;
    RTTI_INIT_FUNCS[17] = &init_data12;
    RTTI_INIT_FUNCS[18] = &init_data13;
    RTTI_INIT_FUNCS[19] = &init_data14;
    RTTI_INIT_FUNCS[20] = &init_data15;
    RTTI_INIT_FUNCS[21] = &init_data16;
    RTTI_INIT_FUNCS[22] = &init_data17;
    RTTI_INIT_FUNCS[23] = &init_data18;
    RTTI_INIT_FUNCS[24] = &init_data19;
    RTTI_INIT_FUNCS[25] = &init_data20;
    RTTI_INIT_FUNCS[26] = &init_data21;
    RTTI_INIT_FUNCS[27] = &init_data22;
    RTTI_INIT_FUNCS[28] = &init_data23;
    RTTI_INIT_FUNCS[29] = &init_data24;
    RTTI_INIT_FUNCS[30] = &init_data25;
    RTTI_INIT_FUNCS[31] = &init_data26;
    RTTI_INIT_FUNCS[32] = &init_data27;
    RTTI_INIT_FUNCS[33] = &init_data28;
    RTTI_INIT_FUNCS[34] = &init_data29;
    RTTI_INIT_FUNCS[35] = &init_data30;
    RTTI_INIT_FUNCS[36] = &init_data31;
    RTTI_INIT_FUNCS[37] = &init_data32;
    #if defined (DELPHI)
    if (mode == 0)
    {
        /* FPC */
        RTTI_INIT_FUNCS[38] = &init_fpc_staticarray_func;
        RTTI_INIT_FUNCS[39] = &init_fpc_structure_func;
    }
    else
    {
        /* DELPHI */
        RTTI_INIT_FUNCS[38] = &init_delphi_staticarray_func;
        RTTI_INIT_FUNCS[39] = &init_delphi_structure_func;
    }
    #endif

    // finalization functions
    RTTI_FINAL_FUNCS[0] = &none_func;
    RTTI_FINAL_FUNCS[1] = &final_metatype_func;
    RTTI_FINAL_FUNCS[2] = &final_metatype_weakfunc;
    #if defined (DELPHI)
    if (mode == 0)
    {
        /* FPC */
        RTTI_FINAL_FUNCS[3] = &final_fpc_interface;
        RTTI_FINAL_FUNCS[4] = &final_fpc_value;
        RTTI_FINAL_FUNCS[5] = &final_fpc_string;
        #if defined (MSWINDOWS)
        RTTI_FINAL_FUNCS[6] = &final_widestring;
        #else
        RTTI_FINAL_FUNCS[6] = &final_fpc_string;
        #endif
        RTTI_FINAL_FUNCS[7] = &final_fpc_interface;
        RTTI_FINAL_FUNCS[8] = &none_func;
        RTTI_FINAL_FUNCS[9] = &none_func;
        RTTI_FINAL_FUNCS[10] = &final_rtl_variant;
        RTTI_FINAL_FUNCS[11] = &none_func;
        RTTI_FINAL_FUNCS[12] = &final_fpc_dynarray_simple;
        RTTI_FINAL_FUNCS[13] = &final_fpc_dynarray;
        RTTI_FINAL_FUNCS[14] = &final_fpc_staticarray;
        RTTI_FINAL_FUNCS[15] = &final_fpc_structure;
    }
    else
    {
        /* DELPHI */
        RTTI_FINAL_FUNCS[3] = &final_delphi_interface;
        RTTI_FINAL_FUNCS[4] = &final_delphi_value;
        RTTI_FINAL_FUNCS[5] = &final_delphi_string;
        #if defined (MSWINDOWS)
        RTTI_FINAL_FUNCS[6] = &final_widestring;
        #else
        RTTI_FINAL_FUNCS[6] = &final_delphi_dynarray_simple;
        #endif
        RTTI_FINAL_FUNCS[7] = &final_delphi_weakinterface;
        RTTI_FINAL_FUNCS[8] = &final_delphi_refobject;
        RTTI_FINAL_FUNCS[9] = &final_delphi_weakrefobject;
        RTTI_FINAL_FUNCS[10] = &final_rtl_variant;
        RTTI_FINAL_FUNCS[11] = &final_delphi_weakmethod;
        RTTI_FINAL_FUNCS[12] = &final_delphi_dynarray_simple;
        RTTI_FINAL_FUNCS[13] = &final_delphi_dynarray;
        RTTI_FINAL_FUNCS[14] = &final_delphi_staticarray;
        RTTI_FINAL_FUNCS[15] = &final_delphi_structure;

        if (mode < 200)
        {
            RTTI_FINAL_FUNCS[5] = &final_olddelphi_string;
        }
        if (!WEAKINTFREF)
        {
            RTTI_FINAL_FUNCS[7] = &final_delphi_interface;
        }
        if (!WEAKINSTREF)
        {
            RTTI_FINAL_FUNCS[8] = &none_func;
            RTTI_FINAL_FUNCS[9] = &none_func;
            RTTI_FINAL_FUNCS[11] = &none_func;
        }
    }
    #else
    RTTI_FINAL_FUNCS[3] = options->final_interface;
    RTTI_FINAL_FUNCS[4] = &final_value;
    #endif

    // copy functions
    RTTI_COPY_FUNCS[0] = &copy_refenence;
    #if defined (SMALLINT)
    RTTI_COPY_FUNCS[1] = &copy_data4;
    RTTI_COPY_FUNCS[2] = &copy_data8;
    #else
    RTTI_COPY_FUNCS[1] = &copy_data8;
    RTTI_COPY_FUNCS[2] = &copy_data4;
    #endif
    RTTI_COPY_FUNCS[3] = &copy_metatype_func;
    RTTI_COPY_FUNCS[4] = &copy_metatype_weakfunc;
    RTTI_COPY_FUNCS[5] = &copy_metatype_bytes;
    #if defined (DELPHI)
    if (mode == 0)
    {
        RTTI_COPY_FUNCS[6] = &copy_fpc_interface;
        RTTI_COPY_FUNCS[7] = &copy_fpc_value;
    }
    else
    {
        RTTI_COPY_FUNCS[6] = &copy_delphi_interface;
        RTTI_COPY_FUNCS[7] = &copy_delphi_value;
    }
    #else
    RTTI_COPY_FUNCS[6] = options->copy_interface;
    RTTI_COPY_FUNCS[7] = &copy_value;
    #endif
    RTTI_COPY_FUNCS[8] = copy_data0;
    RTTI_COPY_FUNCS[9] = copy_data1;
    RTTI_COPY_FUNCS[10] = copy_data2;
    RTTI_COPY_FUNCS[11] = copy_data3;
    RTTI_COPY_FUNCS[12] = copy_data4;
    RTTI_COPY_FUNCS[13] = copy_data5;
    RTTI_COPY_FUNCS[14] = copy_data6;
    RTTI_COPY_FUNCS[15] = copy_data7;
    RTTI_COPY_FUNCS[16] = copy_data8;
    RTTI_COPY_FUNCS[17] = copy_data9;
    RTTI_COPY_FUNCS[18] = copy_data10;
    RTTI_COPY_FUNCS[19] = copy_data11;
    RTTI_COPY_FUNCS[20] = copy_data12;
    RTTI_COPY_FUNCS[21] = copy_data13;
    RTTI_COPY_FUNCS[22] = copy_data14;
    RTTI_COPY_FUNCS[23] = copy_data15;
    RTTI_COPY_FUNCS[24] = copy_data16;
    RTTI_COPY_FUNCS[25] = copy_data17;
    RTTI_COPY_FUNCS[26] = copy_data18;
    RTTI_COPY_FUNCS[27] = copy_data19;
    RTTI_COPY_FUNCS[28] = copy_data20;
    RTTI_COPY_FUNCS[29] = copy_data21;
    RTTI_COPY_FUNCS[30] = copy_data22;
    RTTI_COPY_FUNCS[31] = copy_data23;
    RTTI_COPY_FUNCS[32] = copy_data24;
    RTTI_COPY_FUNCS[33] = copy_data25;
    RTTI_COPY_FUNCS[34] = copy_data26;
    RTTI_COPY_FUNCS[35] = copy_data27;
    RTTI_COPY_FUNCS[36] = copy_data28;
    RTTI_COPY_FUNCS[37] = copy_data29;
    RTTI_COPY_FUNCS[38] = copy_data30;
    RTTI_COPY_FUNCS[39] = copy_data31;
    RTTI_COPY_FUNCS[40] = copy_data32;
    RTTI_COPY_FUNCS[41] = copy_data33;
    RTTI_COPY_FUNCS[42] = copy_data34;
    RTTI_COPY_FUNCS[43] = copy_data35;
    RTTI_COPY_FUNCS[44] = copy_data36;
    RTTI_COPY_FUNCS[45] = copy_data37;
    RTTI_COPY_FUNCS[46] = copy_data38;
    RTTI_COPY_FUNCS[47] = copy_data39;
    RTTI_COPY_FUNCS[48] = copy_data40;
    RTTI_COPY_FUNCS[49] = copy_data41;
    RTTI_COPY_FUNCS[50] = copy_data42;
    RTTI_COPY_FUNCS[51] = copy_data43;
    RTTI_COPY_FUNCS[52] = copy_data44;
    RTTI_COPY_FUNCS[53] = copy_data45;
    RTTI_COPY_FUNCS[54] = copy_data46;
    RTTI_COPY_FUNCS[55] = copy_data47;
    RTTI_COPY_FUNCS[56] = copy_data48;
    RTTI_COPY_FUNCS[57] = copy_data49;
    RTTI_COPY_FUNCS[58] = copy_data50;
    RTTI_COPY_FUNCS[59] = copy_data51;
    RTTI_COPY_FUNCS[60] = copy_data52;
    RTTI_COPY_FUNCS[61] = copy_data53;
    RTTI_COPY_FUNCS[62] = copy_data54;
    RTTI_COPY_FUNCS[63] = copy_data55;
    RTTI_COPY_FUNCS[64] = copy_data56;
    RTTI_COPY_FUNCS[65] = copy_data57;
    RTTI_COPY_FUNCS[66] = copy_data58;
    RTTI_COPY_FUNCS[67] = copy_data59;
    RTTI_COPY_FUNCS[68] = copy_data60;
    RTTI_COPY_FUNCS[69] = copy_data61;
    RTTI_COPY_FUNCS[70] = copy_data62;
    RTTI_COPY_FUNCS[71] = copy_data63;
    RTTI_COPY_FUNCS[72] = copy_data64;
    RTTI_COPY_FUNCS[73] = &copy_hfaread_f2;
    RTTI_COPY_FUNCS[74] = &copy_hfaread_f3;
    RTTI_COPY_FUNCS[75] = &copy_hfaread_f4;
    RTTI_COPY_FUNCS[76] = &copy_hfawrite_f2;
    RTTI_COPY_FUNCS[77] = &copy_hfawrite_f3;
    RTTI_COPY_FUNCS[78] = &copy_hfawrite_f4;
    RTTI_COPY_FUNCS[79] = &copy_shortstring;
    #if defined (DELPHI)
    if (mode == 0)
    {
        /* FPC */
        RTTI_COPY_FUNCS[80] = &copy_fpc_string;
        #if defined (MSWINDOWS)
        RTTI_COPY_FUNCS[81] = &copy_widestring;
        #else
        RTTI_COPY_FUNCS[81] = &copy_fpc_string;
        #endif
        RTTI_COPY_FUNCS[82] = &copy_fpc_interface;
        RTTI_COPY_FUNCS[83] = RTTI_COPY_FUNCS[1];
        RTTI_COPY_FUNCS[84] = RTTI_COPY_FUNCS[1];
        RTTI_COPY_FUNCS[85] = &copy_rtl_variant;
        RTTI_COPY_FUNCS[86] = RTTI_COPY_FUNCS[8 + sizeof(ptr_t) * 2];
        RTTI_COPY_FUNCS[87] = &copy_fpc_dynarray_simple;
        RTTI_COPY_FUNCS[88] = &copy_fpc_dynarray;
        RTTI_COPY_FUNCS[89] = &copy_fpc_staticarray_simple;
        RTTI_COPY_FUNCS[90] = &copy_fpc_staticarray;
        RTTI_COPY_FUNCS[91] = &copy_rtl_structure_simple;
        RTTI_COPY_FUNCS[92] = &copy_fpc_structure;
        RTTI_COPY_FUNCS[93] = &copy_rtl_varopenstring_write;
        RTTI_COPY_FUNCS[94] = &copy_fpc_argarray_read;
        RTTI_COPY_FUNCS[95] = &copy_fpc_argarray_write;
    }
    else
    {
        /* DELPHI */
        RTTI_COPY_FUNCS[80] = &copy_delphi_string;
        #if defined (MSWINDOWS)
        RTTI_COPY_FUNCS[81] = &copy_widestring;
        #else
        RTTI_COPY_FUNCS[81] = &copy_delphi_dynarray;
        #endif
        RTTI_COPY_FUNCS[82] = &copy_delphi_weakinterface;
        RTTI_COPY_FUNCS[83] = &copy_delphi_refobject;
        RTTI_COPY_FUNCS[84] = &copy_delphi_weakrefobject;
        RTTI_COPY_FUNCS[85] = &copy_rtl_variant;
        RTTI_COPY_FUNCS[86] = &copy_delphi_weakmethod;
        RTTI_COPY_FUNCS[87] = &copy_delphi_dynarray_simple;
        RTTI_COPY_FUNCS[88] = &copy_delphi_dynarray;
        RTTI_COPY_FUNCS[89] = &copy_delphi_staticarray_simple;
        RTTI_COPY_FUNCS[90] = &copy_delphi_staticarray;
        RTTI_COPY_FUNCS[91] = &copy_rtl_structure_simple;
        RTTI_COPY_FUNCS[92] = &copy_delphi_structure;
        RTTI_COPY_FUNCS[93] = &copy_rtl_varopenstring_write;
        RTTI_COPY_FUNCS[94] = &copy_delphi_argarray_read;
        RTTI_COPY_FUNCS[95] = &copy_delphi_argarray_write;

        if (mode < 200)
        {
            RTTI_COPY_FUNCS[80] = &copy_olddelphi_string;
        }
        if (!WEAKINTFREF)
        {
            RTTI_COPY_FUNCS[82] = &copy_delphi_interface;
        }
        if (!WEAKINSTREF)
        {
            RTTI_COPY_FUNCS[82] = RTTI_COPY_FUNCS[1];
            RTTI_COPY_FUNCS[83] = RTTI_COPY_FUNCS[1];
            RTTI_COPY_FUNCS[86] = RTTI_COPY_FUNCS[8 + sizeof(ptr_t) * 2];
        }
    }
    #endif
}
