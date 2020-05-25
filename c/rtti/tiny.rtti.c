
#include "../tiny.defines.h"
#include "../tiny.types.h"
#include "tiny.rtti.h"


/* Internal functions */

#if defined (DELPHI)
FORCEINLINE REGISTER_DECL void* get_record_typeinfo(uint8_t* data)
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

FORCEINLINE REGISTER_DECL void* get_fpc_record_typeinfo_fpc(uint8_t* data)
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
    native_uint options = type->options;
    if ((options & 0xff00) == 0)
    {
        RttiTypeRules* r = RTTI_TYPE_RULES[options & 0xff];
        if (r) return r;

        RttiMetaType* meta_type = type->meta_type;
        if ((meta_type->marker & RTTI_TYPEDATA_MASK) == RTTI_TYPEDATA_MARKER)
        {
            return &meta_type->rules;
        }
        else
        {
            return RttiCalculatedRules(type, buffer);
        }
    }
    else
    {
        return RTTI_TYPE_RULES[1];
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

REGISTER_DECL void init_value(RttiExType* type, void* value)
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
REGISTER_DECL void init_fullstaticarray(RttiExType* type, void* value)
{
    RtlArrayData* data = type->custom_data;
    SysInitArray(value, *data->eltype, data->count);
}

REGISTER_DECL void init_fullstaticarray_fpc(RttiExType* type, void* value)
{
    RtlArrayData_fpc* data = type->custom_data;
    SysInitArray(value, data->eltype, data->count);
}

REGISTER_DECL void init_fullstructure(RttiExType* type, void* value)
{
    void* typeinfo = get_record_typeinfo(type->custom_data);
    SysInitStruct(value, typeinfo);
}

REGISTER_DECL void init_fullstructure_fpc(RttiExType* type, void* value)
{
    void* typeinfo = get_fpc_record_typeinfo_fpc(type->custom_data);
    SysInitStruct(value, typeinfo);
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
REGISTER_DECL void final_interface(RttiExType* type, void* value)
{
    RtlInterface* interface = *((ptr_t*)value);
    if (interface)
    {
        *((ptr_t*)value) = 0;
        rtl_interface_release(interface);
    }
}

REGISTER_DECL void final_interface_fpc(RttiExType* type, void* value)
{
    RtlInterface* interface = *((ptr_t*)value);
    if (interface)
    {
        *((ptr_t*)value) = 0;
        rtl_interface_release_fpc(interface);
    }
}

REGISTER_DECL void final_value(RttiExType* type, void* value)
{
    RtlInterface* interface = ((RttiValue*)value)->managed_data;
    if (interface)
    {
        ((RttiValue*)value)->managed_data = 0;
        if (interface != DUMMY_INTERFACE) rtl_interface_release(interface);
    }
}

REGISTER_DECL void final_value_fpc(RttiExType* type, void* value)
{
    RtlInterface* interface = ((RttiValue*)value)->managed_data;
    if (interface)
    {
        ((RttiValue*)value)->managed_data = 0;
        if (interface != DUMMY_INTERFACE) rtl_interface_release_fpc(interface);
    }
}
#else
REGISTER_DECL void final_value(RttiExType* type, void* value)
{
    RTTI_FINAL_FUNCS[RTTI_FINALINTERFACE_FUNC](type, &((RttiValue*)value)->managed_data);
}
#endif

#if defined (DELPHI)
REGISTER_DECL void final_string(RttiExType* type, void* value)
{
    RtlStrRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void final_string_new(RttiExType* type, void* value)
{
    RtlStrRec_new* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release_new(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void final_string_fpc(RttiExType* type, void* value)
{
    RtlStrRec_fpc* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release_fpc(rec, RETURN_ADDRESS, );
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
        MMSysStrFree(rec);
    }
}
#endif

#if defined (DELPHI)
REGISTER_DECL void final_weakinterface(RttiExType* type, void* value)
{
    ptr_t interface = *((ptr_t*)value);
    if (interface)
    {
        SysFinalWeakIntf(value);
    }
}

REGISTER_DECL void final_refobject(RttiExType* type, void* value)
{
    ptr_t object = *((ptr_t*)value);
    if (object)
    {
        *((ptr_t*)value) = 0;
        ptr_t VMT = *((ptr_t*)object);
        GeneralFunc1 func = *(GeneralFunc1*)((uint8_t*)VMT + SysVmtRelease);
        func(object);
    }
}

REGISTER_DECL void final_weakrefobject(RttiExType* type, void* value)
{
    ptr_t object = *((ptr_t*)value);
    if (object)
    {
        SysFinalWeakObj(value);
    }
}

REGISTER_DECL void final_variant(RttiExType* type, void* value)
{
    RtlVariant* rec = value;
    uint32_t vartype = rec->vartype;
    if ((vartype & 0xBFE8/*varDeepData*/) == 0 ||
        vartype == 0x000B/*vt_bool*/ ||
        (vartype >= 0x000D/*vt_unknown*/ && vartype <= 0x0015/*vt_ui8*/))
        {
            rec->vartype = 0;
        }
        else
        {
            SysFinalVariant(value);
        }
}

REGISTER_DECL void final_weakmethod(RttiExType* type, void* value)
{
    RtlMethod* rec = value;
    if (rec->data)
    {
        SysFinalWeakMethod(rec);
    }
    else
    {
        rec->code = 0;
    }
}

REGISTER_DECL void final_dynarray(RttiExType* type, void* value)
{
    RtlDynArray* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_dynarray_release(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void final_dynarray_fpc(RttiExType* type, void* value)
{
    RtlDynArray_fpc* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_dynarray_release_fpc(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void final_fulldynarray(RttiExType* type, void* value)
{
    RtlDynArray* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_fulldynarray_release(rec, *((RtlDynArrayData*)type->custom_data)->eltype, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void final_fulldynarray_fpc(RttiExType* type, void* value)
{
    RtlDynArray_fpc* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_fulldynarray_release_fpc(rec, ((RtlDynArrayData_fpc*)type->custom_data)->eltype, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void final_fullstaticarray(RttiExType* type, void* value)
{
    RtlArrayData* data = type->custom_data;
    SysFinalArray(value, *data->eltype, data->count);
}

REGISTER_DECL void final_fullstaticarray_fpc(RttiExType* type, void* value)
{
    RtlArrayData_fpc* data = type->custom_data;
    SysFinalArray(value, data->eltype, data->count);
}

REGISTER_DECL void final_fullstructure(RttiExType* type, void* value)
{
    void* typeinfo = get_record_typeinfo(type->custom_data);
    SysFinalStruct(value, typeinfo);
}

REGISTER_DECL void final_fullstructure_fpc(RttiExType* type, void* value)
{
    void* typeinfo = get_fpc_record_typeinfo_fpc(type->custom_data);
    SysFinalStruct(value, typeinfo);
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
    ".intel_syntax noprefix \n\t"
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
    ".intel_syntax noprefix \n\t"
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
REGISTER_DECL void copy_interface(RttiExType* type, void* target, void* source)
{
    RtlInterface* t = *((ptr_t*)target);
    RtlInterface* s = *((ptr_t*)source);
    RtlInterfaceFunc func;
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

REGISTER_DECL void copy_interface_fpc(RttiExType* type, void* target, void* source)
{
    RtlInterface* t = *((ptr_t*)target);
    RtlInterface* s = *((ptr_t*)source);
    RtlInterfaceFunc_fpc func;
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

REGISTER_DECL void copy_value(RttiExType* type, void* target, void* source)
{
    RttiValue* t = target;
    RttiValue* s = source;
    RtlInterfaceFunc func;
    t->extype = s->extype;

    RtlInterface* tintf = t->managed_data;
    RtlInterface* sintf = s->managed_data;
    if (tintf == sintf)
    {
        if (sintf == DUMMY_INTERFACE)
        {
            *((data16*)&t->buffer) = *((data16*)&s->buffer);
        }
    }
    else
    {
        if (sintf)
        {
            if (sintf == DUMMY_INTERFACE)
            {
                *((data16*)&t->buffer) = *((data16*)&s->buffer);
            }
            else
            {
                func = sintf->VMT[1/*AddRef*/];
                func(sintf);
            }
        }
        t->managed_data = sintf;

        if (tintf && tintf != DUMMY_INTERFACE)
        {
            func = tintf->VMT[2/*Release*/];
            func(tintf);
        }
    }
}

REGISTER_DECL void copy_value_fpc(RttiExType* type, void* target, void* source)
{
    RttiValue* t = target;
    RttiValue* s = source;
    RtlInterfaceFunc_fpc func;
    t->extype = s->extype;

    RtlInterface* tintf = t->managed_data;
    RtlInterface* sintf = s->managed_data;
    if (tintf == sintf)
    {
        if (sintf == DUMMY_INTERFACE)
        {
            *((data16*)&t->buffer) = *((data16*)&s->buffer);
        }
    }
    else
    {
        if (sintf)
        {
            if (sintf == DUMMY_INTERFACE)
            {
                *((data16*)&t->buffer) = *((data16*)&s->buffer);
            }
            else
            {
                func = sintf->VMT[1/*AddRef*/];
                func(sintf);
             }
        }
        t->managed_data = sintf;

        if (tintf && tintf != DUMMY_INTERFACE)
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
    native_uint length = *((uint8_t*)source);
    native_uint max_length = type->max_length;
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
REGISTER_DECL void copy_string(RttiExType* type, void* target, void* source)
{
    RtlStrRec* t = *((ptr_t*)target);
    RtlStrRec* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s) rtl_string_addref(s);
        *((ptr_t*)target) = s;
        if (t) rtl_string_release(t, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void copy_string_new(RttiExType* type, void* target, void* source)
{
    RtlStrRec_new* t = *((ptr_t*)target);
    RtlStrRec_new* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s) rtl_string_addref_new(s);
        *((ptr_t*)target) = s;
        if (t) rtl_string_release_new(t, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void copy_string_fpc(RttiExType* type, void* target, void* source)
{
    RtlStrRec_fpc* t = *((ptr_t*)target);
    RtlStrRec_fpc* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s) rtl_string_addref_fpc(s);
        *((ptr_t*)target) = s;
        if (t) rtl_string_release_fpc(t, RETURN_ADDRESS, );
    }
}
#endif

#if defined (MSWINDOWS)
REGISTER_DECL void copy_widestring(RttiExType* type, void* target, void* source)
{
    RtlWideStrRec* t = *((ptr_t*)target);
    RtlWideStrRec* s = *((ptr_t*)source);
    if (t != s)
    {
        if (!s)
        {
            *((ptr_t*)target) = 0;
            MMSysStrFree(t);
        }
        else
        {
            if (!t)
            {
                *((ptr_t*)target) = MMSysStrAlloc((char16_t*)s, (s - 1)->size >> 1);
            }
            else
            {
                MMSysStrRealloc(target, (char16_t*)s, (s - 1)->size >> 1);
            }
        }
    }
}
#endif

#if defined (DELPHI)
REGISTER_DECL void copy_weakinterface(RttiExType* type, void* target, void* source)
{
    ptr_t interface = *((ptr_t*)source);
    if (*((ptr_t*)target) != interface)
    {
        if (interface)
        {
            SysCopyWeakIntf(target, source);
        }
        else
        {
            SysFinalWeakIntf(target);
        }
    }
}

REGISTER_DECL void copy_refobject(RttiExType* type, void* target, void* source)
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
            func = *(GeneralFunc1*)((uint8_t*)VMT + SysVmtAddRef);
            func(s);
        }
        *((ptr_t*)target) = s;
        if (t)
        {
            VMT = *((ptr_t*)t);
            func = *(GeneralFunc1*)((uint8_t*)VMT + SysVmtRelease);
            func(t);
        }
    }
}

REGISTER_DECL void copy_weakrefobject(RttiExType* type, void* target, void* source)
{
    ptr_t object = *((ptr_t*)source);
    if (*((ptr_t*)target) != object)
    {
        if (object)
        {
            SysCopyWeakObj(target, source);
        }
        else
        {
            SysFinalWeakObj(target);
        }
    }
}

REGISTER_DECL void copy_variant(RttiExType* type, void* target, void* source)
{
    SysCopyVariant(target, source);
}

REGISTER_DECL void copy_weakmethod(RttiExType* type, void* target, void* source)
{
    RtlMethod* t = target;
    RtlMethod* s = source;
    if (t->data != s->data)
    {
        if (s->data)
        {
            SysCopyWeakMethod(t, s);
        }
        else
        {
            SysFinalWeakMethod(t);
        }
    }
    else
    {
        t->code = s->code;
    }
}

REGISTER_DECL void copy_dynarray(RttiExType* type, void* target, void* source)
{
    RtlDynArray* t = *((ptr_t*)target);
    RtlDynArray* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s) rtl_dynarray_addref(s);
        *((ptr_t*)target) = s;
        if (t) rtl_dynarray_release(t, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void copy_dynarray_fpc(RttiExType* type, void* target, void* source)
{
    RtlDynArray_fpc* t = *((ptr_t*)target);
    RtlDynArray_fpc* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s)
        {
            if (s->refcount > 0)
            {
                rtl_dynarray_addref_fpc(s);
            }
            else
            {
                native_int length = (s - 1)->high + 1;
                RtlDynArrayData_fpc* data = type->custom_data;
                RtlDynArray_fpc* temp;
                rtl_rec_alloc_fpc(temp, length * data->elsize, RETURN_ADDRESS, );
                temp->refcount = 1;
                temp->high = length - 1;
                temp++;
                rtl_memcopy(temp, s, length * data->elsize);
                s = temp;
            }
        }
        *((ptr_t*)target) = s;
        if (t) rtl_dynarray_release_fpc(t, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void copy_fulldynarray(RttiExType* type, void* target, void* source)
{
    RtlDynArray* t = *((ptr_t*)target);
    RtlDynArray* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s) rtl_dynarray_addref(s);
        *((ptr_t*)target) = s;
        if (t) rtl_fulldynarray_release(t, *((RtlDynArrayData*)type->custom_data)->eltype, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void copy_fulldynarray_fpc(RttiExType* type, void* target, void* source)
{
    RtlDynArray_fpc* t = *((ptr_t*)target);
    RtlDynArray_fpc* s = *((ptr_t*)source);
    if (t != s)
    {
        if (s)
        {
            if (s->refcount > 0)
            {
                rtl_dynarray_addref_fpc(s);
            }
            else
            {
                native_int length = (s - 1)->high + 1;
                RtlDynArrayData_fpc* data = type->custom_data;
                RtlDynArray_fpc* temp;
                rtl_rec_alloc_fpc(temp, length * data->elsize, RETURN_ADDRESS, );
                temp->refcount = 1;
                temp->high = length - 1;
                temp++;
                SysInitArray(temp, data->eltype, length);
                SysCopyArray(temp, s, data->eltype, length);
                s = temp;
            }
        }
        *((ptr_t*)target) = s;
        if (t) rtl_fulldynarray_release_fpc(t, ((RtlDynArrayData_fpc*)type->custom_data)->eltype, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void copy_staticarray(RttiExType* type, void* target, void* source)
{
    RtlArrayData* data = type->custom_data;
    rtl_memcopy(target, source, data->size);
}

REGISTER_DECL void copy_staticarray_fpc(RttiExType* type, void* target, void* source)
{
    RtlArrayData_fpc* data = type->custom_data;
    rtl_memcopy(target, source, data->size);
}

REGISTER_DECL void copy_fullstaticarray(RttiExType* type, void* target, void* source)
{
    RtlArrayData* data = type->custom_data;
    SysCopyArray(target, source, *data->eltype, data->count);
}

REGISTER_DECL void copy_fullstaticarray_fpc(RttiExType* type, void* target, void* source)
{
    RtlArrayData_fpc* data = type->custom_data;
    SysCopyArray(target, source, data->eltype, data->count);
}

REGISTER_DECL void copy_structure(RttiExType* type, void* target, void* source)
{
    RtlRecordData* data = type->custom_data;
    rtl_memcopy(target, source, data->size);
}

REGISTER_DECL void copy_fullstructure(RttiExType* type, void* target, void* source)
{
    void* typeinfo = get_record_typeinfo(type->custom_data);
    SysCopyStruct(target, source, typeinfo);
}

REGISTER_DECL void copy_fullstructure_fpc(RttiExType* type, void* target, void* source)
{
    void* typeinfo = get_fpc_record_typeinfo_fpc(type->custom_data);
    SysCopyStruct(target, source, typeinfo);
}

REGISTER_DECL void copy_varopenstring_write(RttiExType* type, void* target, void* source)
{
    RttiArgument* argument = (RttiArgument*)type;
    *((ptr_t*)target) = source;
    *((native_int*)target + argument->high_offset) = argument->max_length;
}

REGISTER_DECL void copy_argarray_read(RttiExType* type, void* target, void* source)
{
    RttiTypeRules rules_buffer;
    RttiTypeRules* rules = get_rules(type, &rules_buffer);
    uint8_t *t, *s;
    native_uint elsize = rules->size;
    native_uint length;
    RttiTypeFunc func;
    RttiCopyFunc copy_func;

    // dynarray_releasesimple + optional finalization
    RtlDynArray* rec = *((ptr_t*)target);
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
            rtl_freemem(rec - 1, RETURN_ADDRESS, );
        }
    }

    // new dynamic array
    RttiArgument* argument = (RttiArgument*)type;
    length = *((native_int*)source + argument->high_offset) + 1;
    if (!length) return;
    rtl_rec_alloc(rec, length * elsize, RETURN_ADDRESS, );
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

REGISTER_DECL void copy_argarray_read_fpc(RttiExType* type, void* target, void* source)
{
    RttiTypeRules rules_buffer;
    RttiTypeRules* rules = get_rules(type, &rules_buffer);
    uint8_t *t, *s;
    native_uint elsize = rules->size;
    native_uint length;
    RttiTypeFunc func;
    RttiCopyFunc copy_func;

    // dynarray_releasesimple + optional finalization
    RtlDynArray_fpc* rec = *((ptr_t*)target);
    if (rec)
    {
        *((ptr_t*)target) = 0;
        if (
            (rec - 1)->refcount == 1 || \
            atomic_decrement(&(rec - 1)->refcount) == 0 \
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
            rtl_freemem_fpc(rec - 1, RETURN_ADDRESS, );
        }
    }

    // new dynamic array
    RttiArgument* argument = (RttiArgument*)type;
    length = *((native_int*)source + argument->high_offset) + 1;
    if (!length) return;
    rtl_rec_alloc_fpc(rec, length * elsize, RETURN_ADDRESS, );
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

REGISTER_DECL void copy_argarray_write(RttiExType* type, void* target, void* source)
{
    RttiArgument* argument = (RttiArgument*)type;
    RtlDynArray* rec = *((ptr_t*)source);
    native_int high = -1;
    if (rec)
    {
        high = (rec - 1)->length - 1;
    }
    *((ptr_t*)target) = rec;
    *((native_int*)target + argument->high_offset) = high;
}

REGISTER_DECL void copy_argarray_write_fpc(RttiExType* type, void* target, void* source)
{
    RttiArgument* argument = (RttiArgument*)type;
    RtlDynArray_fpc* rec = *((ptr_t*)source);
    native_int high = -1;
    if (rec)
    {
        high = (rec - 1)->high;
    }
    *((ptr_t*)target) = rec;
    *((native_int*)target + argument->high_offset) = high;
}
#endif


/* initialization */

void init_library()
{
    // mode
    native_uint mode = CompilerMode;
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
    RTTI_INIT_FUNCS[RTTI_INITNONE_FUNC] = &none_func;
    #if defined (SMALLINT)
    RTTI_INIT_FUNCS[RTTI_INITPOINTER_FUNC] = &init_data4;
    RTTI_INIT_FUNCS[RTTI_INITPOINTERPAIR_FUNC] = &init_data8;
    #else
    RTTI_INIT_FUNCS[RTTI_INITPOINTER_FUNC] = &init_data8;
    RTTI_INIT_FUNCS[RTTI_INITPOINTERPAIR_FUNC] = &init_data16;
    #endif
    RTTI_INIT_FUNCS[RTTI_INITMETATYPE_FUNC] = &init_metatype_func;
    RTTI_INIT_FUNCS[RTTI_INITVALUE_FUNC] = &init_value;

    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 0] = &init_data0;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 1] = &init_data1;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 2] = &init_data2;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 3] = &init_data3;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 4] = &init_data4;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 5] = &init_data5;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 6] = &init_data6;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 7] = &init_data7;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 8] = &init_data8;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 9] = &init_data9;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 10] = &init_data10;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 11] = &init_data11;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 12] = &init_data12;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 13] = &init_data13;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 14] = &init_data14;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 15] = &init_data15;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 16] = &init_data16;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 17] = &init_data17;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 18] = &init_data18;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 19] = &init_data19;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 20] = &init_data20;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 21] = &init_data21;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 22] = &init_data22;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 23] = &init_data23;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 24] = &init_data24;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 25] = &init_data25;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 26] = &init_data26;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 27] = &init_data27;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 28] = &init_data28;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 29] = &init_data29;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 30] = &init_data30;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 31] = &init_data31;
    RTTI_INIT_FUNCS[RTTI_INITBYTES_LOWFUNC + 32] = &init_data32;
    #if defined (DELPHI)
    if (mode == 0)
    {
        /* FPC */
        RTTI_INIT_FUNCS[RTTI_INITFULLSTATICARRAY_FUNC] = &init_fullstaticarray_fpc;
        RTTI_INIT_FUNCS[RTTI_INITFULLSTRUCTURE_FUNC] = &init_fullstructure_fpc;
    }
    else
    {
        /* DELPHI */
        RTTI_INIT_FUNCS[RTTI_INITFULLSTATICARRAY_FUNC] = &init_fullstaticarray;
        RTTI_INIT_FUNCS[RTTI_INITFULLSTRUCTURE_FUNC] = &init_fullstructure;
    }
    #endif

    // finalization functions
    RTTI_FINAL_FUNCS[RTTI_FINALNONE_FUNC] = &none_func;
    RTTI_FINAL_FUNCS[RTTI_FINALMETATYPE_FUNC] = &final_metatype_func;
    RTTI_FINAL_FUNCS[RTTI_FINALWEAKMETATYPE_FUNC] = &final_metatype_weakfunc;
    #if defined (DELPHI)
    if (mode == 0)
    {
        /* FPC */
        RTTI_FINAL_FUNCS[RTTI_FINALINTERFACE_FUNC] = &final_interface_fpc;
        RTTI_FINAL_FUNCS[RTTI_FINALVALUE_FUNC] = &final_value_fpc;
        RTTI_FINAL_FUNCS[RTTI_FINALSTRING_FUNC] = &final_string_fpc;
        #if defined (MSWINDOWS)
        RTTI_FINAL_FUNCS[RTTI_FINALWIDESTRING_FUNC] = &final_widestring;
        #else
        RTTI_FINAL_FUNCS[RTTI_FINALWIDESTRING_FUNC] = &final_string_fpc;
        #endif
        RTTI_FINAL_FUNCS[RTTI_FINALWEAKINTERFACE_FUNC] = &final_interface_fpc;
        RTTI_FINAL_FUNCS[RTTI_FINALREFOBJECT_FUNC] = &none_func;
        RTTI_FINAL_FUNCS[RTTI_FINALWEAKREFOBJECT_FUNC] = &none_func;
        RTTI_FINAL_FUNCS[RTTI_FINALVARIANT_FUNC] = &final_variant;
        RTTI_FINAL_FUNCS[RTTI_FINALWEAKMETHOD_FUNC] = &none_func;
        RTTI_FINAL_FUNCS[RTTI_FINALDYNARRAY_FUNC] = &final_dynarray_fpc;
        RTTI_FINAL_FUNCS[RTTI_FINALFULLDYNARRAY_FUNC] = &final_fulldynarray_fpc;
        RTTI_FINAL_FUNCS[RTTI_FINALFULLSTATICARRAY_FUNC] = &final_fullstaticarray_fpc;
        RTTI_FINAL_FUNCS[RTTI_FINALFULLSTRUCTURE_FUNC] = &final_fullstructure_fpc;
    }
    else
    {
        /* DELPHI */
        RTTI_FINAL_FUNCS[RTTI_FINALINTERFACE_FUNC] = &final_interface;
        RTTI_FINAL_FUNCS[RTTI_FINALVALUE_FUNC] = &final_value;
        RTTI_FINAL_FUNCS[RTTI_FINALSTRING_FUNC] = &final_string_new;
        #if defined (MSWINDOWS)
        RTTI_FINAL_FUNCS[RTTI_FINALWIDESTRING_FUNC] = &final_widestring;
        #else
        RTTI_FINAL_FUNCS[RTTI_FINALWIDESTRING_FUNC] = &final_dynarray;
        #endif
        RTTI_FINAL_FUNCS[RTTI_FINALWEAKINTERFACE_FUNC] = &final_weakinterface;
        RTTI_FINAL_FUNCS[RTTI_FINALREFOBJECT_FUNC] = &final_refobject;
        RTTI_FINAL_FUNCS[RTTI_FINALWEAKREFOBJECT_FUNC] = &final_weakrefobject;
        RTTI_FINAL_FUNCS[RTTI_FINALVARIANT_FUNC] = &final_variant;
        RTTI_FINAL_FUNCS[RTTI_FINALWEAKMETHOD_FUNC] = &final_weakmethod;
        RTTI_FINAL_FUNCS[RTTI_FINALDYNARRAY_FUNC] = &final_dynarray;
        RTTI_FINAL_FUNCS[RTTI_FINALFULLDYNARRAY_FUNC] = &final_fulldynarray;
        RTTI_FINAL_FUNCS[RTTI_FINALFULLSTATICARRAY_FUNC] = &final_fullstaticarray;
        RTTI_FINAL_FUNCS[RTTI_FINALFULLSTRUCTURE_FUNC] = &final_fullstructure;

        if (mode < 200)
        {
            RTTI_FINAL_FUNCS[RTTI_FINALSTRING_FUNC] = &final_string;
        }
        if (!WEAKINTFREF)
        {
            RTTI_FINAL_FUNCS[RTTI_FINALWEAKINTERFACE_FUNC] = &final_interface;
        }
        if (!WEAKINSTREF)
        {
            RTTI_FINAL_FUNCS[RTTI_FINALREFOBJECT_FUNC] = &none_func;
            RTTI_FINAL_FUNCS[RTTI_FINALWEAKREFOBJECT_FUNC] = &none_func;
            RTTI_FINAL_FUNCS[RTTI_FINALWEAKMETHOD_FUNC] = &none_func;
        }
    }
    #else
    RTTI_FINAL_FUNCS[RTTI_FINALINTERFACE_FUNC] = options->final_interface;
    RTTI_FINAL_FUNCS[RTTI_FINALVALUE_FUNC] = &final_value;
    #endif

    // copy functions
    RTTI_COPY_FUNCS[RTTI_COPYREFERENCE_FUNC] = &copy_refenence;
    #if defined (SMALLINT)
    RTTI_COPY_FUNCS[RTTI_COPYNATIVE_FUNC] = &copy_data4;
    RTTI_COPY_FUNCS[RTTI_COPYALTERNATIVE_FUNC] = &copy_data8;
    #else
    RTTI_COPY_FUNCS[RTTI_COPYNATIVE_FUNC] = &copy_data8;
    RTTI_COPY_FUNCS[RTTI_COPYALTERNATIVE_FUNC] = &copy_data4;
    #endif
    RTTI_COPY_FUNCS[RTTI_COPYMETATYPE_FUNC] = &copy_metatype_func;
    RTTI_COPY_FUNCS[RTTI_COPYWEAKMETATYPE_FUNC] = &copy_metatype_weakfunc;
    RTTI_COPY_FUNCS[RTTI_COPYMETATYPEBYTES_FUNC] = &copy_metatype_bytes;
    #if defined (DELPHI)
    if (mode == 0)
    {
        RTTI_COPY_FUNCS[RTTI_COPYINTERFACE_FUNC] = &copy_interface_fpc;
        RTTI_COPY_FUNCS[RTTI_COPYVALUE_FUNC] = &copy_value_fpc;
    }
    else
    {
        RTTI_COPY_FUNCS[RTTI_COPYINTERFACE_FUNC] = &copy_interface;
        RTTI_COPY_FUNCS[RTTI_COPYVALUE_FUNC] = &copy_value;
    }
    #else
    RTTI_COPY_FUNCS[RTTI_COPYINTERFACE_FUNC] = 0;
    RTTI_COPY_FUNCS[RTTI_COPYVALUE_FUNC] = 0;
    #endif
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 0] = copy_data0;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 1] = copy_data1;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 2] = copy_data2;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 3] = copy_data3;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 4] = copy_data4;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 5] = copy_data5;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 6] = copy_data6;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 7] = copy_data7;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 8] = copy_data8;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 9] = copy_data9;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 10] = copy_data10;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 11] = copy_data11;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 12] = copy_data12;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 13] = copy_data13;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 14] = copy_data14;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 15] = copy_data15;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 16] = copy_data16;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 17] = copy_data17;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 18] = copy_data18;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 19] = copy_data19;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 20] = copy_data20;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 21] = copy_data21;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 22] = copy_data22;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 23] = copy_data23;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 24] = copy_data24;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 25] = copy_data25;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 26] = copy_data26;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 27] = copy_data27;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 28] = copy_data28;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 29] = copy_data29;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 30] = copy_data30;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 31] = copy_data31;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 32] = copy_data32;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 33] = copy_data33;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 34] = copy_data34;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 35] = copy_data35;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 36] = copy_data36;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 37] = copy_data37;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 38] = copy_data38;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 39] = copy_data39;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 40] = copy_data40;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 41] = copy_data41;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 42] = copy_data42;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 43] = copy_data43;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 44] = copy_data44;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 45] = copy_data45;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 46] = copy_data46;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 47] = copy_data47;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 48] = copy_data48;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 49] = copy_data49;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 50] = copy_data50;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 51] = copy_data51;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 52] = copy_data52;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 53] = copy_data53;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 54] = copy_data54;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 55] = copy_data55;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 56] = copy_data56;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 57] = copy_data57;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 58] = copy_data58;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 59] = copy_data59;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 60] = copy_data60;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 61] = copy_data61;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 62] = copy_data62;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 63] = copy_data63;
    RTTI_COPY_FUNCS[RTTI_COPYBYTES_LOWFUNC + 64] = copy_data64;
    RTTI_COPY_FUNCS[RTTI_COPYHFAREAD_LOWFUNC + 0] = &copy_hfaread_f2;
    RTTI_COPY_FUNCS[RTTI_COPYHFAREAD_LOWFUNC + 1] = &copy_hfaread_f3;
    RTTI_COPY_FUNCS[RTTI_COPYHFAREAD_LOWFUNC + 2] = &copy_hfaread_f4;
    RTTI_COPY_FUNCS[RTTI_COPYHFAWRITE_LOWFUNC + 0] = &copy_hfawrite_f2;
    RTTI_COPY_FUNCS[RTTI_COPYHFAWRITE_LOWFUNC + 1] = &copy_hfawrite_f3;
    RTTI_COPY_FUNCS[RTTI_COPYHFAWRITE_LOWFUNC + 2] = &copy_hfawrite_f4;
    RTTI_COPY_FUNCS[RTTI_COPYSHORTSTRING_FUNC] = &copy_shortstring;
    #if defined (DELPHI)
    if (mode == 0)
    {
        /* FPC */
        RTTI_COPY_FUNCS[RTTI_COPYSTRING_FUNC] = &copy_string_fpc;
        #if defined (MSWINDOWS)
        RTTI_COPY_FUNCS[RTTI_COPYWIDESTRING_FUNC] = &copy_widestring;
        #else
        RTTI_COPY_FUNCS[RTTI_COPYWIDESTRING_FUNC] = &copy_string_fpc;
        #endif
        RTTI_COPY_FUNCS[RTTI_COPYWEAKINTERFACE_FUNC] = &copy_interface_fpc;
        RTTI_COPY_FUNCS[RTTI_COPYREFOBJECT_FUNC] = RTTI_COPY_FUNCS[RTTI_COPYNATIVE_FUNC];
        RTTI_COPY_FUNCS[RTTI_COPYWEAKREFOBJECT_FUNC] = RTTI_COPY_FUNCS[RTTI_COPYNATIVE_FUNC];
        RTTI_COPY_FUNCS[RTTI_COPYVARIANT_FUNC] = &copy_variant;
        RTTI_COPY_FUNCS[RTTI_COPYWEAKMETHOD_FUNC] = RTTI_COPY_FUNCS[8 + sizeof(ptr_t) * 2];
        RTTI_COPY_FUNCS[RTTI_COPYDYNARRAY_FUNC] = &copy_dynarray_fpc;
        RTTI_COPY_FUNCS[RTTI_COPYFULLDYNARRAY_FUNC] = &copy_fulldynarray_fpc;
        RTTI_COPY_FUNCS[RTTI_COPYSTATICARRAY_FUNC] = &copy_staticarray_fpc;
        RTTI_COPY_FUNCS[RTTI_COPYFULLSTATICARRAY_FUNC] = &copy_fullstaticarray_fpc;
        RTTI_COPY_FUNCS[RTTI_COPYSTRUCTURE_FUNC] = &copy_structure;
        RTTI_COPY_FUNCS[RTTI_COPYFULLSTRUCTURE_FUNC] = &copy_fullstructure_fpc;
        RTTI_COPY_FUNCS[RTTI_COPYVAROPENSTRINGWRITE_FUNC] = &copy_varopenstring_write;
        RTTI_COPY_FUNCS[RTTI_COPYARGARRAYREAD_FUNC] = &copy_argarray_read_fpc;
        RTTI_COPY_FUNCS[RTTI_COPYARGARRAYWRITE_FUNC] = &copy_argarray_write_fpc;
    }
    else
    {
        /* DELPHI */
        RTTI_COPY_FUNCS[RTTI_COPYSTRING_FUNC] = &copy_string_new;
        #if defined (MSWINDOWS)
        RTTI_COPY_FUNCS[RTTI_COPYWIDESTRING_FUNC] = &copy_widestring;
        #else
        RTTI_COPY_FUNCS[RTTI_COPYWIDESTRING_FUNC] = &copy_fulldynarray;
        #endif
        RTTI_COPY_FUNCS[RTTI_COPYWEAKINTERFACE_FUNC] = &copy_weakinterface;
        RTTI_COPY_FUNCS[RTTI_COPYREFOBJECT_FUNC] = &copy_refobject;
        RTTI_COPY_FUNCS[RTTI_COPYWEAKREFOBJECT_FUNC] = &copy_weakrefobject;
        RTTI_COPY_FUNCS[RTTI_COPYVARIANT_FUNC] = &copy_variant;
        RTTI_COPY_FUNCS[RTTI_COPYWEAKMETHOD_FUNC] = &copy_weakmethod;
        RTTI_COPY_FUNCS[RTTI_COPYDYNARRAY_FUNC] = &copy_dynarray;
        RTTI_COPY_FUNCS[RTTI_COPYFULLDYNARRAY_FUNC] = &copy_fulldynarray;
        RTTI_COPY_FUNCS[RTTI_COPYSTATICARRAY_FUNC] = &copy_staticarray;
        RTTI_COPY_FUNCS[RTTI_COPYFULLSTATICARRAY_FUNC] = &copy_fullstaticarray;
        RTTI_COPY_FUNCS[RTTI_COPYSTRUCTURE_FUNC] = &copy_structure;
        RTTI_COPY_FUNCS[RTTI_COPYFULLSTRUCTURE_FUNC] = &copy_fullstructure;
        RTTI_COPY_FUNCS[RTTI_COPYVAROPENSTRINGWRITE_FUNC] = &copy_varopenstring_write;
        RTTI_COPY_FUNCS[RTTI_COPYARGARRAYREAD_FUNC] = &copy_argarray_read;
        RTTI_COPY_FUNCS[RTTI_COPYARGARRAYWRITE_FUNC] = &copy_argarray_write;

        if (mode < 200)
        {
            RTTI_COPY_FUNCS[RTTI_COPYSTRING_FUNC] = &copy_string;
        }
        if (!WEAKINTFREF)
        {
            RTTI_COPY_FUNCS[RTTI_COPYWEAKINTERFACE_FUNC] = &copy_interface;
        }
        if (!WEAKINSTREF)
        {
            RTTI_COPY_FUNCS[RTTI_COPYWEAKINTERFACE_FUNC] = RTTI_COPY_FUNCS[RTTI_COPYNATIVE_FUNC];
            RTTI_COPY_FUNCS[RTTI_COPYREFOBJECT_FUNC] = RTTI_COPY_FUNCS[RTTI_COPYNATIVE_FUNC];
            RTTI_COPY_FUNCS[RTTI_COPYWEAKMETHOD_FUNC] = RTTI_COPY_FUNCS[8 + sizeof(ptr_t) * 2];
        }
    }
    #endif
}
