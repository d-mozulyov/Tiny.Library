#include "tiny.types.h"

#if defined (CPUX86) && defined (MSWINDOWS)

REGISTER_DECL void AStrClear(void* value) /*AStrClear_new*/
{
    RtlStrRec_new* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release_new(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void* AStrInit(void* value, char8_t* chars, uint32_t length, uint16_t codepage) /*AStrInit_new*/
{
    RtlStrRec_new* rec = *((ptr_t*)value);

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
                rtl_rec_realloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                goto markup;
            }
            else
            {
                *((ptr_t*)value) = 0;
                rtl_string_release_new(rec, RETURN_ADDRESS, 0);
                goto allocate;
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_lstr_markup_new(rec, length, codepage);
    copy:
        *((ptr_t*)value) = rec;
        if (chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
        return rec;
    }

    return 0;
}

REGISTER_DECL void* AStrReserve(void* value, uint32_t length) /*AStrReserve_new*/
{
    RtlStrRec_new* rec = *((ptr_t*)value);
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
                    rtl_rec_realloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                    goto markup;
                }
            }

            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
            goto allocate;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_lstr_markup_new(rec, length, DefaultCP);
        *((ptr_t*)value) = rec;
        return rec;
    }

    return 0;
}

REGISTER_DECL void* AStrSetLength(void* value, uint32_t length, uint16_t codepage) /*AStrSetLength_new*/
{
    RtlStrRec_new* source = *((ptr_t*)value);
    RtlStrRec_new* target;
    char8_t* chars/*none*/;

    if (source)
    {
        if (length)
        {
            if ((source - 1)->refcount != 1 || (source - 1)->length != length) goto allocate;
            (source - 1)->cpelemsize = ((uint32_t)codepage) + 0x10000;
            return source;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(source, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(target, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
        rtl_lstr_markup_new(target, length, codepage);
        *((ptr_t*)value) = target;
        if (source)
        {
            if (length > (source - 1)->length) length = (source - 1)->length;
            rtl_memcopy(target, source, length * sizeof(*chars));
            rtl_string_release_new(source, RETURN_ADDRESS, 0);
        }

        return target;
    }

    return 0;
}

REGISTER_DECL void UStrClear(void* value) /*UStrClear_new*/
{
    RtlStrRec_new* rec = *((ptr_t*)value);
    if (rec)
    {
        *((ptr_t*)value) = 0;
        rtl_string_release_new(rec, RETURN_ADDRESS, );
    }
}

REGISTER_DECL void* UStrInit(void* value, char8_t* chars, uint32_t length, uint16_t codepage) /*UStrInit_new*/
{
    RtlStrRec_new* rec = *((ptr_t*)value);

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
                rtl_rec_realloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                goto markup;
            }
            else
            {
                *((ptr_t*)value) = 0;
                rtl_string_release_new(rec, RETURN_ADDRESS, 0);
                goto allocate;
            }
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_ustr_markup_new(rec, length);
    copy:
        *((ptr_t*)value) = rec;
        if (chars) rtl_memcopy(rec, chars, length * sizeof(*chars));
        return rec;
    }

    return 0;
}

REGISTER_DECL void* UStrReserve(void* value, uint32_t length, uint16_t codepage) /*UStrReserve_new*/
{
    RtlStrRec_new* rec = *((ptr_t*)value);
    char16_t* chars/*none*/;

    if (rec)
    {
        if (length)
        {
            if ((rec - 1)->refcount == 1)
            {
                if ((rec - 1)->length >= length) return rec;
                if (rtl_rec_hintrealloc((rec - 1)->length, sizeof(*chars), length))
                {
                    rtl_rec_realloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
                    goto markup;
                }
            }

            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
            goto allocate;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(rec, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(rec, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
    markup:
        rtl_ustr_markup_new(rec, length);
        *((ptr_t*)value) = rec;
        return rec;
    }

    return 0;
}

REGISTER_DECL void* UStrSetLength(void* value, uint32_t length) /*UStrSetLength_new*/
{
    RtlStrRec_new* source = *((ptr_t*)value);
    RtlStrRec_new* target;
    char16_t* chars/*none*/;

    if (source)
    {
        if (length)
        {
            if ((source - 1)->refcount != 1 || (source - 1)->length != length) goto allocate;
            (source - 1)->cpelemsize = USTR_CPELEMSIZE;
            return source;
        }
        else
        {
            *((ptr_t*)value) = 0;
            rtl_string_release_new(source, RETURN_ADDRESS, 0);
        }
    }
    else
    if (length)
    {
    allocate:
        rtl_rec_alloc_new(target, (length + 1) * sizeof(*chars), RETURN_ADDRESS, 0);
        rtl_ustr_markup_new(target, length);
        *((ptr_t*)value) = target;
        if (source)
        {
            if (length > (source - 1)->length) length = (source - 1)->length;
            rtl_memcopy(target, source, length * sizeof(*chars));
            rtl_string_release_new(source, RETURN_ADDRESS, 0);
        }

        return target;
    }

    return 0;
}

#endif
