#include "tiny.types.h"

#if defined (CPUX86) && defined (MSWINDOWS)


REGISTER_DECL void AStrClear(void* value) /*AStrClear_old*/
{
    RtlStrRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void* AStrInit(void* value, char8_t* chars, uint32_t length, uint16_t codepage) /*AStrInit_old*/
{
    RtlStrRec* rec = *((ptr_t*)value);

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
                rtl_rec_realloc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                goto markup;
            }
            else
            {
                *((ptr_t*)value) = 0;
                rtl_string_release(rec, RETURN_ADDRESS, 0);
                goto allocate;
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_lstr_markup(rec, length, codepage);
    copy:
        *((ptr_t*)value) = rec;
        if (chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
        return rec;
    }

    return 0;
}

REGISTER_DECL void* AStrReserve(void* value, uint32_t length) /*AStrReserve_old*/
{
    RtlStrRec* rec = *((ptr_t*)value);
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
                    rtl_rec_realloc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                    goto markup;
                }
            }

            *((ptr_t*)value) = 0;
            rtl_string_release(rec, RETURN_ADDRESS, 0);
            goto allocate;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_lstr_markup(rec, length, DefaultCP);
        *((ptr_t*)value) = rec;
        return rec;
    }

    return 0;
}

REGISTER_DECL void* AStrSetLength(void* value, uint32_t length, uint16_t codepage) /*AStrSetLength_old*/
{
    RtlStrRec* source = *((ptr_t*)value);
    RtlStrRec* target;
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
            rtl_string_release(source, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc(target, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
        rtl_lstr_markup(target, length, codepage);
        *((ptr_t*)value) = target;
        if (source)
        {
            if (length > (source - 1)->length) length = (source - 1)->length;
            rtl_memcopy(target, source, length * sizeof(*chars));
            rtl_string_release(source, RETURN_ADDRESS, 0);
        }

        return target;
    }

    return 0;
}

REGISTER_DECL void UStrClear(void* value) /*WStrClear*/
{
    RtlWideStrRec* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        MMSysStrFree(rec);
    }
}

REGISTER_DECL void* UStrInit(void* value, char16_t* chars, uint32_t length) /*WStrInit*/
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

REGISTER_DECL void* UStrReserve(void* value, uint32_t length) /*WStrReserve*/
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

REGISTER_DECL void* UStrSetLength(void* value, uint32_t length) /*WStrSetLength*/
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
