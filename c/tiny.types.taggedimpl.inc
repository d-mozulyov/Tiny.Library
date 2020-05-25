REGISTER_DECL void TaggedPtrCopy(volatile tagged_ptr* target/*aligned*/, volatile tagged_ptr* source/*aligned*/)
{
    tagged_copy(target, source);
}

REGISTER_DECL void TaggedPtrRead(volatile tagged_unaligned_ptr* target, volatile tagged_ptr* source/*aligned*/)
{
    tagged_read(target, source);
}


REGISTER_DECL void TaggedPtrWrite(volatile tagged_ptr* target/*aligned*/, volatile tagged_unaligned_ptr* source)
{
    tagged_write(target, source);
}

REGISTER_DECL void TaggedPtrExchange(tagged_unaligned_ptr* last_value, tagged_ptr* target/*aligned*/, tagged_unaligned_ptr* value)
{
    *last_value = tagged_exchange(target, *value);
}

REGISTER_DECL bool TaggedPtrCmpExchange(tagged_ptr* target/*aligned*/, tagged_unaligned_ptr* value, tagged_unaligned_ptr* comparand)
{
    return  tagged_cmp_exchange(target, *value, *comparand);
}

REGISTER_DECL ptr_t TaggedPtrChange(tagged_ptr* target/*aligned*/, ptr_t value)
{
    for (;;)
    {
    #if defined (CPUARM)
        ptr_t item = target->value;
        if (item == INVALID_PTR) return item;

        if (atomic_cmp_exchange(&(target->value), value, item))
        {
            return item;
        }
    #else
        tagged_unaligned_ptr item = *target;
        if (item.value == INVALID_PTR) return item.value;

        tagged_unaligned_ptr new_item;
        new_item.value = value;
        new_item.counter = item.counter + 1;

        if (tagged_cmp_exchange(target, new_item, item))
        {
            return item.value;
        }
    #endif
    }
}

REGISTER_DECL ptr_t TaggedPtrInvalidate(tagged_ptr* target/*aligned*/)
{
    for (;;)
    {
    #if defined (CPUARM)
        ptr_t item = target->value;
        if (item == INVALID_PTR) return item;

        if (atomic_cmp_exchange(&(target->value), INVALID_PTR, item))
        {
            return item;
        }
    #else
        tagged_unaligned_ptr item = *target;
        if (item.value == INVALID_PTR) return item.value;

        tagged_unaligned_ptr new_item;
        new_item.value = INVALID_PTR;
        new_item.counter = item.counter + 1;

        if (tagged_cmp_exchange(target, new_item, item))
        {
            return item.value;
        }
    #endif
    }
}

REGISTER_DECL bool TaggedPtrValidate(tagged_ptr* target/*aligned*/, ptr_t value)
{
    for (;;)
    {
    #if defined (CPUARM)
        ptr_t item = target->value;
        if (item != INVALID_PTR) return false;

        if (atomic_cmp_exchange(&(target->value), value, INVALID_PTR))
        {
            return true;
        }
    #else
        tagged_unaligned_ptr item = *target;
        if (item.value != INVALID_PTR) return false;

        tagged_unaligned_ptr new_item;
        new_item.value = value;
        new_item.counter = item.counter + 1;

        if (tagged_cmp_exchange(target, new_item, item))
        {
            return true;
        }
    #endif
    }
}

REGISTER_DECL ptr_t TaggedPtrPush(tagged_ptr* target/*aligned*/, ptr_t item)
{
    return TaggedPtrPushList(target, item, item);
}

REGISTER_DECL ptr_t TaggedPtrPushCalcList(tagged_ptr* target/*aligned*/, ptr_t first)
{
    ptr_t next = *((ptr_t*)first);
    ptr_t last;

    for (last = first; next;)
    {
        last = next;
        next = *((ptr_t*)next);
    }

    return TaggedPtrPushList(target, first, last);
}

/*
REGISTER_DECL ptr_t TaggedPtrPushList(tagged_ptr* target, ptr_t first, ptr_t last)
{
    for (;;)
    {
        tagged_unaligned_ptr item = *target;
        if (item.value == INVALID_PTR) return item.value;

        tagged_unaligned_ptr new_item;
        new_item.value = first;
        new_item.counter = item.counter + 1;
        *((ptr_t*)last) = item.value;

        if (tagged_cmp_exchange(target, new_item, item))
        {
            return item.value;
        }
    }
}
*/

#if defined (CPUARM)
REGISTER_DECL ptr_t TaggedPtrPushList(tagged_ptr* target/*aligned*/, ptr_t first, ptr_t last)
{
    /* Android32/64, iOS32/64 */
    for (;;)
    {
        ptr_t item = target->value;
        if (item == INVALID_PTR) return item;

        *((ptr_t*)last) = item;

        if (atomic_cmp_exchange(&(target->value), first, item))
        {
            return item;
        }
    }
}
#elif defined (CPUX86)
NAKED REGISTER_DECL ptr_t TaggedPtrPushList(tagged_ptr* target/*aligned*/, ptr_t first, ptr_t last)
{
    /* Windows32, Linux32, MacOS32 */
    __asm__ volatile
    (
    ".intel_syntax noprefix \n\t"
        "push ebx \n\t"
        "push esi \n\t"
        "push edi \n\t"
        "mov ebx, edx \n\t" // first
        "mov esi, ecx \n\t" // last
        "mov edi, eax \n\t" // target

        // item (eax:edx) = *target
        "mov eax, [edi] \n\t"
        "mov edx, [edi + 4] \n\t"
        asm_nop(2)

    ".Lloop_push: \n\t"
        // item.value == INVALID?
        "cmp eax, 1 \n\t"
        "je .Ldone_push \n\t"

        // *last = item.value
        // new_item (ebx:ecx) = first:item.counter + 1
        "mov [esi], eax \n\t"
        "lea ecx, [edx + 1] \n\t"

        // atomic cmpexchange
        "lock cmpxchg8b [edi] \n\t"
        "jne .Lloop_push \n\t"

    ".Ldone_push: \n\t"
        "pop edi \n\t"
        "pop esi \n\t"
        "pop ebx \n\t"
    "ret \n\t"
    );
}
#else
NAKED REGISTER_DECL ptr_t TaggedPtrPushList(tagged_ptr* target/*aligned*/, ptr_t first, ptr_t last)
{
    /* Windows64/Linux64/MacOS64 */
    __asm__ volatile
    (
    ".intel_syntax noprefix \n\t"
        "xchg rbx, r11 \n\t"
    #if defined (WIN64)
        "mov rbx, rdx \n\t" // first
        "mov r9, r8 \n\t" // last
        "mov r8, rcx \n\t" // target
    #else
        "mov rbx, rsi \n\t" // first
        "mov r9, rdx \n\t" // last
        "mov r8, rdi \n\t" // target
    #endif

        // item (rax:rdx) = *target
        "mov rax, [r8] \n\t"
        "mov rdx, [r8 + 8] \n\t"
        asm_nop(13)

    ".Lloop_push: \n\t"
        // item.value == INVALID?
        "cmp rax, 1 \n\t"
        "je .Ldone_push \n\t"

        // *last = item.value
        // new_item (rbx:rcx) = first:item.counter + 1
        "mov [r9], rax \n\t"
        "lea rcx, [rdx + 1] \n\t"

        // atomic cmpexchange
        "lock cmpxchg16b [r8] \n\t"
        "jne .Lloop_push \n\t"

    ".Ldone_push: \n\t"
        "xchg r11, rbx \n\t"
    "ret \n\t"
    );
}
#endif

/*REGISTER_DECL ptr_t TaggedPtrPop(tagged_ptr* target)
{
    for (;;)
    {
        tagged_unaligned_ptr item = *target;
        if ((native_uint)item.value <= (native_uint)INVALID_PTR) return item.value;

        tagged_unaligned_ptr new_item;
        new_item.value = *((ptr_t*)&(item.value));
        new_item.counter = item.counter + 1;

        if (tagged_cmp_exchange(target, new_item, item))
        {
            return item.value;
        }
    }
}*/

#if defined (CPUARM)
REGISTER_DECL ptr_t TaggedPtrPop(tagged_ptr* target/*aligned*/)
{
    /* Android32/64, iOS32/64 */
    for (;;)
    {
        ptr_t item = target->value;
        if ((native_uint)item <= (native_uint)INVALID_PTR) return item;

        ptr_t new_item = *((ptr_t*)item);

        if (atomic_cmp_exchange(&(target->value), new_item, item))
        {
            return item;
        }
    }
}
#elif defined (CPUX86)
NAKED REGISTER_DECL ptr_t TaggedPtrPop(tagged_ptr* target/*aligned*/)
{
    /* Windows32, Linux32, MacOS32 */
    __asm__ volatile
    (
    ".intel_syntax noprefix \n\t"
        "push esi \n\t"
        "push ebx \n\t"
        "mov esi, eax \n\t" // this

        // item (eax:edx) = *target
        "mov eax, [eax] \n\t"
        "mov edx, [esi + 4] \n\t"
        asm_nop(7)

    ".Lloop_pop: \n\t"
        // item.value <= INVALID?
        "cmp eax, 2 \n\t"
        "jb .Ldone_pop \n\t"

        // new_item (ebx:ecx) = [item.value]:item.counter + 1
        "mov ebx, [eax] \n\t"
        "lea ecx, [edx + 1] \n\t"

        // atomic cmpexchange
        "lock cmpxchg8b [esi] \n\t"
        "jne .Lloop_pop \n\t"

    ".Ldone_pop: \n\t"
        "pop ebx \n\t"
        "pop esi \n\t"
    "ret \n\t"
    );
}
#else
NAKED REGISTER_DECL ptr_t TaggedPtrPop(tagged_ptr* target/*aligned*/)
{
    /* Windows64/Linux64/MacOS64 */
    __asm__ volatile
    (
    ".intel_syntax noprefix \n\t"
        "xchg rbx, r11 \n\t"
    #if defined (WIN64)
        "mov r8, rcx \n\t" // target
    #else
        "mov r8, rdi \n\t" // target
    #endif

        // item (rax:rdx) = *target
        "mov rax, [r8] \n\t"
        "mov rdx, [r8 + 8] \n\t"
        asm_nop(3)

    ".Lloop_pop: \n\t"
        // item.value <= INVALID?
        "cmp rax, 2 \n\t"
        "jb .Ldone_pop \n\t"

        // new_item (rbx:rcx) = [item.value]:item.counter + 1
        "mov rbx, [rax] \n\t"
        "lea rcx, [rdx + 1] \n\t"

        // atomic cmpexchange
        "lock cmpxchg16b [r8] \n\t"
        "jne .Lloop_pop \n\t"

    ".Ldone_pop: \n\t"
        "xchg r11, rbx \n\t"
    "ret \n\t"
    );
}
#endif

/*REGISTER_DECL ptr_t TaggedPtrPopList(tagged_ptr* target)
{
    for (;;)
    {
        tagged_unaligned_ptr item = *target;
        if ((native_uint)item.value <= (native_uint)INVALID_PTR) return item.value;

        tagged_unaligned_ptr new_item;
        new_item.value = 0;
        new_item.counter = item.counter + 1;

        if (tagged_cmp_exchange(target, new_item, item))
        {
            return item.value;
        }
    }
}*/

#if defined (CPUARM)
REGISTER_DECL ptr_t TaggedPtrPopList(tagged_ptr* target/*aligned*/)
{
    /* Android32/64, iOS32/64 */
    for (;;)
    {
        ptr_t item = target->value;
        if ((native_uint)item <= (native_uint)INVALID_PTR) return item;

        if (atomic_cmp_exchange(&(target->value), 0, item))
        {
            return item;
        }
    }
}
#elif defined (CPUX86)
NAKED REGISTER_DECL ptr_t TaggedPtrPopList(tagged_ptr* target/*aligned*/)
{
    /* Windows32, Linux32, MacOS32 */
    __asm__ volatile
    (
    ".intel_syntax noprefix \n\t"
        "push esi \n\t"
        "push ebx \n\t"
        "mov esi, eax \n\t" // this

        // item (eax:edx) = *target
        "mov eax, [eax] \n\t"
        "mov edx, [esi + 4] \n\t"
        asm_nop(7)

    ".Lloop_poplist: \n\t"
        // item.value <= INVALID?
        "cmp eax, 2 \n\t"
        "jb .Lldone_poplist \n\t"

        // new_item (ebx:ecx) = 0:item.counter + 1
        "xor ebx, ebx \n\t"
        "lea ecx, [edx + 1] \n\t"

        // atomic cmpexchange
        "lock cmpxchg8b [esi] \n\t"
        "jne .Lloop_poplist \n\t"

    ".Lldone_poplist: \n\t"
        "pop ebx \n\t"
        "pop esi \n\t"
    "ret \n\t"
    );
}
#else
NAKED REGISTER_DECL ptr_t TaggedPtrPopList(tagged_ptr* target/*aligned*/)
{
    /* Windows64/Linux64/MacOS64 */
    __asm__ volatile
    (
    ".intel_syntax noprefix \n\t"
        "xchg rbx, r11 \n\t"
    #if defined (WIN64)
        "mov r8, rcx \n\t" // target
    #else
        "mov r8, rdi \n\t" // target
    #endif

        // item (rax:rdx) = *target
        "mov rax, [r8] \n\t"
        "mov rdx, [r8 + 8] \n\t"
        asm_nop(3)

    ".Lloop_poplist: \n\t"
        // item.value <= INVALID?
        "cmp rax, 2 \n\t"
        "jb .Lldone_poplist \n\t"

        // new_item (rbx:rcx) = 0:item.counter + 1
        "xor rbx, rbx \n\t"
        "lea rcx, [rdx + 1] \n\t"

        // atomic cmpexchange
        "lock cmpxchg16b [r8] \n\t"
        "jne .Lloop_poplist \n\t"

    ".Lldone_poplist: \n\t"
        "xchg r11, rbx \n\t"
    "ret \n\t"
    );
}
#endif

REGISTER_DECL ptr_t TaggedPtrReverse(ptr_t current, ptr_t next);

/*REGISTER_DECL ptr_t TaggedPtrPopReversed(tagged_ptr* target)
{
    for (;;)
    {
        tagged_unaligned_ptr item = *target;
        if ((native_uint)item.value <= (native_uint)INVALID_PTR) return item.value;

        tagged_unaligned_ptr new_item;
        new_item.value = 0;
        new_item.counter = item.counter + 1;

        if (tagged_cmp_exchange(target, new_item, item))
        {
            ptr_t next = *((ptr_t*)item.value);
            if (next) return TaggedPtrReverse(item.value, next);
            return item.value;
        }
    }
}*/

#if defined (CPUARM)
REGISTER_DECL ptr_t TaggedPtrPopReversed(tagged_ptr* target/*aligned*/)
{
    /* Android32/64, iOS32/64 */
    for (;;)
    {
        ptr_t item = target->value;
        if ((native_uint)item <= (native_uint)INVALID_PTR) return item;

        if (atomic_cmp_exchange(&(target->value), 0, item))
        {
            ptr_t next = *((ptr_t*)item);
            if (next) return TaggedPtrReverse(item, next);
            return item;
        }
    }
}
#elif defined (CPUX86)
NAKED REGISTER_DECL ptr_t TaggedPtrPopReversed(tagged_ptr* target/*aligned*/)
{
    /* Windows32, Linux32, MacOS32 */
    __asm__ volatile
    (
    ".intel_syntax noprefix \n\t"
        "push esi \n\t"
        "push ebx \n\t"
        "mov esi, eax \n\t" // this

        // item (eax:edx) = *target
        "mov eax, [eax] \n\t"
        "mov edx, [esi + 4] \n\t"
        asm_nop(7)

    ".Lloop_popreverse: \n\t"
        // item.value <= INVALID?
        "cmp eax, 2 \n\t"
        "jb .Lldone_popreverse \n\t"

        // new_item (ebx:ecx) = 0:item.counter + 1
        "xor ebx, ebx \n\t"
        "lea ecx, [edx + 1] \n\t"

        // atomic cmpexchange
        "lock cmpxchg8b [esi] \n\t"
        "jne .Lloop_popreverse \n\t"

        // optional reverse
        "pop ebx \n\t"
        "pop esi \n\t"
        "mov edx, [eax] \n\t"
        "test edx, edx \n\t"
        "jnz TaggedPtrReverse \n\t"
    "ret \n\t"

    ".Lldone_popreverse: \n\t"
        "pop ebx \n\t"
        "pop esi \n\t"
    "ret \n\t"
    );
}
#else
NAKED REGISTER_DECL ptr_t TaggedPtrPopReversed(tagged_ptr* target/*aligned*/)
{
    /* Windows64/Linux64/MacOS64 */
    __asm__ volatile
    (
    ".intel_syntax noprefix \n\t"
        "xchg rbx, r11 \n\t"
    #if defined (WIN64)
        "mov r8, rcx \n\t" // target
    #else
        "mov r8, rdi \n\t" // target
    #endif

        // item (rax:rdx) = *target
        "mov rax, [r8] \n\t"
        "mov rdx, [r8 + 8] \n\t"
        asm_nop(3)

    ".Lloop_popreverse: \n\t"
        // item.value <= INVALID?
        "cmp rax, 2 \n\t"
        "jb .Lldone_popreverse \n\t"

        // new_item (rbx:rcx) = 0:item.counter + 1
        "xor rbx, rbx \n\t"
        "lea rcx, [rdx + 1] \n\t"

        // atomic cmpexchange
        "lock cmpxchg16b [r8] \n\t"
        "jne .Lloop_popreverse \n\t"

        // optional reverse
        "xchg r11, rbx \n\t"
    #if defined (WIN64)
        "mov rdx, [rax] \n\t"
        "test rdx, rdx \n\t"
        "mov rcx, rax \n\t"
    #else
        "mov rsi, [rax] \n\t"
        "test rsi, rsi \n\t"
        "mov rdi, rax \n\t"
    #endif
        "jnz TaggedPtrReverse \n\t"
    "ret \n\t"

    ".Lldone_popreverse: \n\t"
        "xchg r11, rbx \n\t"
    "ret \n\t"
    );
}
#endif

REGISTER_DECL ptr_t TaggedPtrReverse(ptr_t current, ptr_t next)
{
    ptr_t ret = current;

    current = next;
    *((ptr_t*)ret) = 0;

    for (;;)
    {
        next = *((ptr_t*)current);
        *((ptr_t*)current) = ret;
        ret = current;
        current = next;
        if (!next) break;
    }

    return ret;
}