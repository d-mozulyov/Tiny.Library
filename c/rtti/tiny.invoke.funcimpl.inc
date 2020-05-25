
REGISTER_DECL void invoke_register_none_(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_)(code_address))();
}

REGISTER_DECL void invoke_register_none_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_g)(code_address))(dumpgens[0]);
}

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_none_e(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_e)(code_address))(dumpexts[0]);
}
#endif

X86NAKED
REGISTER_DECL void invoke_register_none_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    #if defined (CPUX86)
        x86tailfunc(2, 0);
    #else
        ((func_register_outgen_gg)(code_address))(dumpgens[0], dumpgens[1]);
    #endif
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_ge)(code_address))(dumpgens[0], dumpexts[0]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_none_ee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_ee)(code_address))(dumpexts[0], dumpexts[1]);
}
#endif

X86NAKED
REGISTER_DECL void invoke_register_none_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    #if defined (CPUX86)
        x86tailfunc(3, 0);
    #else
        ((func_register_outgen_ggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2]);
    #endif
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_gge)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_gee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_none_eee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_eee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_none_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_gggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpgens[3]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_ggge)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_ggee)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_geee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_none_eeee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_register_outgen_eeee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
}
#endif

REGISTER_DECL void invoke_register_outgen_(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_)(code_address))();
}

REGISTER_DECL void invoke_register_outgen_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_g)(code_address))(dumpgens[0]);
}

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_outgen_e(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_e)(code_address))(dumpexts[0]);
}
#endif

REGISTER_DECL void invoke_register_outgen_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_gg)(code_address))(dumpgens[0], dumpgens[1]);
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_ge)(code_address))(dumpgens[0], dumpexts[0]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_outgen_ee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_ee)(code_address))(dumpexts[0], dumpexts[1]);
}
#endif

REGISTER_DECL void invoke_register_outgen_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_ggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2]);
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_gge)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_gee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_outgen_eee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_eee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_outgen_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_gggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpgens[3]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_ggge)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_ggee)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_geee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_outgen_eeee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_eeee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_float_(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_register_float_)(code_address))();
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_float_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_register_float_g)(code_address))(dumpgens[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_float_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_register_float_gg)(code_address))(dumpgens[0], dumpgens[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_float_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_register_float_ggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2]);
}
#endif

REGISTER_DECL void invoke_register_ext_(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_)(code_address))();
}

REGISTER_DECL void invoke_register_ext_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_g)(code_address))(dumpgens[0]);
}

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_ext_e(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_e)(code_address))(dumpexts[0]);
}
#endif

REGISTER_DECL void invoke_register_ext_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_gg)(code_address))(dumpgens[0], dumpgens[1]);
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_ge)(code_address))(dumpgens[0], dumpexts[0]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_ext_ee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_ee)(code_address))(dumpexts[0], dumpexts[1]);
}
#endif

REGISTER_DECL void invoke_register_ext_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_ggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2]);
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_gge)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_gee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_ext_eee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_eee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_ext_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_gggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpgens[3]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_ggge)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_ggee)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_geee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_ext_eeee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_eeee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
}
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_)(code_address))();
}
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_g)(code_address))(dumpgens[0]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_e(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_e)(code_address))(dumpexts[0]);
}
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_gg)(code_address))(dumpgens[0], dumpgens[1]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_ge)(code_address))(dumpgens[0], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_ee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_ee)(code_address))(dumpexts[0], dumpexts[1]);
}
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_ggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_gge)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_gee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_eee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_eee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_gggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpgens[3]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_ggge)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_ggee)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_geee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_eeee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_eeee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_fpuint64_(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_register_fpu_)(code_address))();
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_fpuint64_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_register_fpu_g)(code_address))(dumpgens[0]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_fpuint64_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_register_fpu_gg)(code_address))(dumpgens[0], dumpgens[1]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_fpuint64_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_register_fpu_ggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_)(code_address))();
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_g)(code_address))(dumpgens[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_e(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_e)(code_address))(dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_gg)(code_address))(dumpgens[0], dumpgens[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_ge)(code_address))(dumpgens[0], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_ee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_ee)(code_address))(dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_ggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_gge)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_gee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_eee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_eee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_gggg)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpgens[3]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_ggge)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_ggee)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_geee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_eeee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_eeee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(0, 0);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(1, 0);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_e(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(0, 1);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(d0));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(2, 0);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(1, 1);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(d0));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_ee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(0, 2);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(d0), "r"(d1));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(3, 0);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1), "r"(x2));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(2, 1);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1), "r"(d0));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(1, 2);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(d0), "r"(d1));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_eee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(0, 3);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(d0), "r"(d1), "r"(d2));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(4, 0);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1), "r"(x2), "r"(x3));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(3, 1);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1), "r"(x2), "r"(d0));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(2, 2);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1), "r"(d0), "r"(d1));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(1, 3);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(d0), "r"(d1), "r"(d2));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_eeee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    arm64registers(0, 4);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(d0), "r"(d1), "r"(d2), "r"(d3));
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_ge)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_egg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_egg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_geg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_geg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_gge)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_ege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_ege)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_gee)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eggg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_gegg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_gegg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eegg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eegg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_ggeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_ggeg)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_egeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_egeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_geeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_geeg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eeeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eeeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_ggge)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_egge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_egge)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_gege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_gege)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eege)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_ggee)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_egee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_egee)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_geee)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_ge)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_egg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_egg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_geg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_geg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_gge)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_ege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_ege)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_gee)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eggg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_gegg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_gegg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eegg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eegg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_ggeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_ggeg)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_egeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_egeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_geeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_geeg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eeeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eeeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_ggge)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_egge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_egge)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_gege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_gege)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eege)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_ggee)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_egee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_egee)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_geee)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_ge)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_egg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_egg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_geg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_geg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_gge)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_ege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_ege)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_gee)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eggg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_gegg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_gegg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eegg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eegg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_ggeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_ggeg)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_egeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_egeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_geeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_geeg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eeeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eeeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_ggge)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_egge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_egge)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_gege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_gege)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eege)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_ggee)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_egee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_egee)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_geee)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_ge)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_egg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_egg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_geg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_geg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_gge)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_ege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_ege)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_gee)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eggg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_gegg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_gegg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eegg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eegg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_ggeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_ggeg)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_egeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_egeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_geeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_geeg)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eeeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eeeg)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_ggge)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_egge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_egge)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_gege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_gege)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eege)(code_address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_ggee)(code_address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_egee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_egee)(code_address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_geee)(code_address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_none_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_cdecl_outgen_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_none_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_cdecl_outgen_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_none_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_cdecl_outgen_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_none_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    ((func_cdecl_outgen_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_outgen_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_cdecl_outgen_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_outgen_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_cdecl_outgen_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_outgen_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_cdecl_outgen_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_outgen_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_cdecl_outgen_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_float_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_cdecl_float_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_float_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_cdecl_float_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_float_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_cdecl_float_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_float_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_cdecl_float_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_ext_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_cdecl_ext_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_ext_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_cdecl_ext_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_ext_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_cdecl_ext_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_ext_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_cdecl_ext_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpu_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_cdecl_fpu_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpu_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_cdecl_fpu_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpu_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_cdecl_fpu_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpu_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_cdecl_fpu_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpuint64_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_cdecl_fpu_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpuint64_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_cdecl_fpu_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpuint64_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_cdecl_fpu_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpuint64_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_cdecl_fpu_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
WIN32NAKED
REGISTER_DECL void invoke_stdcall_none_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    #if defined (WIN32)
        x86tailfunc(3, 1);
    #else
        ((func_stdcall_outgen_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
    #endif
}
#endif

#if defined (CPUX86)
WIN32NAKED
REGISTER_DECL void invoke_stdcall_none_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    #if defined (WIN32)
        x86tailfunc(3, 2);
    #else
        ((func_stdcall_outgen_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
    #endif
}
#endif

#if defined (CPUX86)
WIN32NAKED
REGISTER_DECL void invoke_stdcall_none_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    #if defined (WIN32)
        x86tailfunc(3, 3);
    #else
        ((func_stdcall_outgen_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
    #endif
}
#endif

#if defined (CPUX86)
X86NAKED
REGISTER_DECL void invoke_stdcall_none_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    // ((func_stdcall_outgen_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
    x86tailfunc(3, 4);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_outgen_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_stdcall_outgen_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_outgen_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_stdcall_outgen_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_outgen_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_stdcall_outgen_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_outgen_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_stdcall_outgen_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_float_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_stdcall_float_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_float_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_stdcall_float_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_float_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_stdcall_float_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_float_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_stdcall_float_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_ext_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_stdcall_ext_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_ext_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_stdcall_ext_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_ext_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_stdcall_ext_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_ext_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_stdcall_ext_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpu_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_stdcall_fpu_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpu_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_stdcall_fpu_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpu_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_stdcall_fpu_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpu_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_stdcall_fpu_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpuint64_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_stdcall_fpu_g)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpuint64_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_stdcall_fpu_gg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpuint64_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_stdcall_fpu_ggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpuint64_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    long double R = ((func_stdcall_fpu_gggg)(code_address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

REGISTER_DECL void invoke_safecall_(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_)(code_address))();
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}

REGISTER_DECL void invoke_safecall_g(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_g)(code_address))(dumpsafegen(0));
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_e(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_e)(code_address))(dumpexts[0]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

REGISTER_DECL void invoke_safecall_gg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gg)(code_address))(dumpsafegen(0), dumpsafegen(1));
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eg)(code_address))(dumpexts[0], dumpgens[0]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_ge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ge)(code_address))(dumpgens[0], dumpexts[0]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_ee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ee)(code_address))(dumpexts[0], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

REGISTER_DECL void invoke_safecall_ggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ggg)(code_address))(dumpsafegen(0), dumpsafegen(1), dumpsafegen(2));
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_egg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_egg)(code_address))(dumpexts[0], dumpgens[0], dumpgens[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_geg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_geg)(code_address))(dumpgens[0], dumpexts[0], dumpgens[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eeg)(code_address))(dumpexts[0], dumpexts[1], dumpgens[0]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_gge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gge)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_ege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ege)(code_address))(dumpexts[0], dumpgens[0], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_gee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_eee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

REGISTER_DECL void invoke_safecall_gggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gggg)(code_address))(dumpsafegen(0), dumpsafegen(1), dumpsafegen(2), dumpsafegen(3));
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eggg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eggg)(code_address))(dumpexts[0], dumpgens[0], dumpgens[1], dumpgens[2]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_gegg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gegg)(code_address))(dumpgens[0], dumpexts[0], dumpgens[1], dumpgens[2]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eegg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eegg)(code_address))(dumpexts[0], dumpexts[1], dumpgens[0], dumpgens[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_ggeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ggeg)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpgens[2]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_egeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_egeg)(code_address))(dumpexts[0], dumpgens[0], dumpexts[1], dumpgens[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_geeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_geeg)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpgens[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eeeg(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eeeg)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpgens[0]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_ggge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ggge)(code_address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_egge(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_egge)(code_address))(dumpexts[0], dumpgens[0], dumpgens[1], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_gege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gege)(code_address))(dumpgens[0], dumpexts[0], dumpgens[1], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eege(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eege)(code_address))(dumpexts[0], dumpexts[1], dumpgens[0], dumpexts[2]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_ggee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ggee)(code_address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_egee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_egee)(code_address))(dumpexts[0], dumpgens[0], dumpexts[1], dumpexts[2]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_geee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_geee)(code_address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_eeee(RttiSignature* signature, void* code_address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eeee)(code_address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
    if (dumpregs.OutInt32 < 0) TinyErrorSafeCall(dumpregs.OutInt32, RETURN_ADDRESS);
}
#endif
