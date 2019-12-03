
REGISTER_DECL void invoke_register_none_(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_)(address))();
}

REGISTER_DECL void invoke_register_none_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_g)(address))(dumpgens[0]);
}

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_none_e(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_e)(address))(dumpexts[0]);
}
#endif

X86NAKED
REGISTER_DECL void invoke_register_none_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    #if defined (CPUX86)
        x86tailfunc(2, 0);
    #else
        ((func_register_outgen_gg)(address))(dumpgens[0], dumpgens[1]);
    #endif
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_ge)(address))(dumpgens[0], dumpexts[0]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_none_ee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_ee)(address))(dumpexts[0], dumpexts[1]);
}
#endif

X86NAKED
REGISTER_DECL void invoke_register_none_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    #if defined (CPUX86)
        x86tailfunc(3, 0);
    #else
        ((func_register_outgen_ggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2]);
    #endif
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_gge)(address))(dumpgens[0], dumpgens[1], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_gee)(address))(dumpgens[0], dumpexts[0], dumpexts[1]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_none_eee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_eee)(address))(dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_none_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_gggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpgens[3]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_ggge)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_ggee)(address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_none_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_geee)(address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_none_eeee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_register_outgen_eeee)(address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
}
#endif

REGISTER_DECL void invoke_register_outgen_(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_)(address))();
}

REGISTER_DECL void invoke_register_outgen_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_g)(address))(dumpgens[0]);
}

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_outgen_e(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_e)(address))(dumpexts[0]);
}
#endif

REGISTER_DECL void invoke_register_outgen_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_gg)(address))(dumpgens[0], dumpgens[1]);
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_ge)(address))(dumpgens[0], dumpexts[0]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_outgen_ee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_ee)(address))(dumpexts[0], dumpexts[1]);
}
#endif

REGISTER_DECL void invoke_register_outgen_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_ggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2]);
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_gge)(address))(dumpgens[0], dumpgens[1], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_gee)(address))(dumpgens[0], dumpexts[0], dumpexts[1]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_outgen_eee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_eee)(address))(dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_outgen_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_gggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpgens[3]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_ggge)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_ggee)(address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_outgen_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_geee)(address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_outgen_eeee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_register_outgen_eeee)(address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_float_(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_register_float_)(address))();
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_float_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_register_float_g)(address))(dumpgens[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_float_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_register_float_gg)(address))(dumpgens[0], dumpgens[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_float_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_register_float_ggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2]);
}
#endif

REGISTER_DECL void invoke_register_ext_(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_)(address))();
}

REGISTER_DECL void invoke_register_ext_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_g)(address))(dumpgens[0]);
}

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_ext_e(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_e)(address))(dumpexts[0]);
}
#endif

REGISTER_DECL void invoke_register_ext_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_gg)(address))(dumpgens[0], dumpgens[1]);
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_ge)(address))(dumpgens[0], dumpexts[0]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_ext_ee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_ee)(address))(dumpexts[0], dumpexts[1]);
}
#endif

REGISTER_DECL void invoke_register_ext_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_ggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2]);
}

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_gge)(address))(dumpgens[0], dumpgens[1], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_gee)(address))(dumpgens[0], dumpexts[0], dumpexts[1]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_ext_eee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_eee)(address))(dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_ext_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_gggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpgens[3]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_ggge)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_ggee)(address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_ext_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_geee)(address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_register_ext_eeee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_register_ext_eeee)(address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
}
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_)(address))();
}
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_g)(address))(dumpgens[0]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_e(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_e)(address))(dumpexts[0]);
}
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_gg)(address))(dumpgens[0], dumpgens[1]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_ge)(address))(dumpgens[0], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_ee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_ee)(address))(dumpexts[0], dumpexts[1]);
}
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_ggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_gge)(address))(dumpgens[0], dumpgens[1], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_gee)(address))(dumpgens[0], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_eee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_eee)(address))(dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_gggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpgens[3]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_ggge)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_ggee)(address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_geee)(address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_register_fpu_eeee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_register_fpu_eeee)(address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_fpuint64_(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_register_fpu_)(address))();
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_fpuint64_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_register_fpu_g)(address))(dumpgens[0]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_fpuint64_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_register_fpu_gg)(address))(dumpgens[0], dumpgens[1]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_register_fpuint64_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_register_fpu_ggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_)(address))();
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_g)(address))(dumpgens[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_e(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_e)(address))(dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_gg)(address))(dumpgens[0], dumpgens[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_ge)(address))(dumpgens[0], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_ee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_ee)(address))(dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_ggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_gge)(address))(dumpgens[0], dumpgens[1], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_gee)(address))(dumpgens[0], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_eee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_eee)(address))(dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_gggg)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpgens[3]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_ggge)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_ggee)(address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_geee)(address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
}
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
REGISTER_DECL void invoke_register_hfa_eeee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutHFA = ((func_register_hfa_eeee)(address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(0, 0);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(1, 0);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_e(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(0, 1);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(d0));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(2, 0);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(1, 1);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(d0));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_ee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(0, 2);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(d0), "r"(d1));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(3, 0);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1), "r"(x2));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(2, 1);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1), "r"(d0));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(1, 2);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(d0), "r"(d1));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_eee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(0, 3);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(d0), "r"(d1), "r"(d2));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(4, 0);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1), "r"(x2), "r"(x3));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(3, 1);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1), "r"(x2), "r"(d0));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(2, 2);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(x1), "r"(d0), "r"(d1));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(1, 3);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(x0), "r"(d0), "r"(d1), "r"(d2));
}
#endif

#if defined (CPUARM64)
REGISTER_DECL void invoke_register_retptr_eeee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    arm64registers(0, 4);
    __asm__ volatile ("br x4" :: "r"(x4), "r"(x8), "r"(d0), "r"(d1), "r"(d2), "r"(d3));
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_ge)(address))(dumpregs.RegRCX, dumpregs.RegXMM1);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_egg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_egg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_geg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_geg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eeg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_gge)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_ege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_ege)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_gee)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eggg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_gegg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_gegg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eegg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eegg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_ggeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_ggeg)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_egeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_egeg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_geeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_geeg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eeeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eeeg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_ggge)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_egge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_egge)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_gege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_gege)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_eege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_eege)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_ggee)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_egee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_egee)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_none_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_msabi_outgen_geee)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_ge)(address))(dumpregs.RegRCX, dumpregs.RegXMM1);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_egg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_egg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_geg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_geg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eeg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_gge)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_ege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_ege)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_gee)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eggg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_gegg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_gegg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eegg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eegg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_ggeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_ggeg)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_egeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_egeg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_geeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_geeg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eeeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eeeg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_ggge)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_egge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_egge)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_gege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_gege)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_eege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_eege)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_ggee)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_egee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_egee)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_outgen_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_msabi_outgen_geee)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_ge)(address))(dumpregs.RegRCX, dumpregs.RegXMM1);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_egg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_egg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_geg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_geg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eeg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_gge)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_ege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_ege)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_gee)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eggg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_gegg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_gegg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eegg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eegg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_ggeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_ggeg)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_egeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_egeg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_geeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_geeg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eeeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eeeg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_ggge)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_egge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_egge)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_gege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_gege)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_eege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_eege)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_ggee)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_egee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_egee)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX64)
REGISTER_DECL void invoke_msabi_ext_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_msabi_ext_geee)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_ge)(address))(dumpregs.RegRCX, dumpregs.RegXMM1);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_egg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_egg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_geg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_geg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eeg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_gge)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_ege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_ege)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_gee)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eggg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_gegg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_gegg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eegg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eegg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_ggeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_ggeg)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_egeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_egeg)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_geeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_geeg)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eeeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eeeg)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegR9);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_ggge)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_egge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_egge)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_gege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_gege)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_eege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_eege)(address))(dumpregs.RegXMM0, dumpregs.RegXMM1, dumpregs.RegR8, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_ggee)(address))(dumpregs.RegRCX, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_egee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_egee)(address))(dumpregs.RegXMM0, dumpregs.RegRDX, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (POSIXINTEL64)
REGISTER_DECL void invoke_msabi_fpu_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_msabi_fpu_geee)(address))(dumpregs.RegRCX, dumpregs.RegXMM1, dumpregs.RegXMM2, dumpregs.RegXMM3);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_none_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_cdecl_outgen_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_none_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_cdecl_outgen_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_none_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_cdecl_outgen_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_none_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    ((func_cdecl_outgen_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_outgen_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_cdecl_outgen_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_outgen_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_cdecl_outgen_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_outgen_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_cdecl_outgen_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_outgen_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_cdecl_outgen_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_float_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_cdecl_float_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_float_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_cdecl_float_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_float_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_cdecl_float_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_float_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_cdecl_float_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_ext_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_cdecl_ext_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_ext_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_cdecl_ext_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_ext_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_cdecl_ext_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_ext_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_cdecl_ext_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpu_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_cdecl_fpu_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpu_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_cdecl_fpu_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpu_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_cdecl_fpu_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpu_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_cdecl_fpu_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpuint64_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_cdecl_fpu_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpuint64_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_cdecl_fpu_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpuint64_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_cdecl_fpu_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_cdecl_fpuint64_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_cdecl_fpu_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
WIN32NAKED
REGISTER_DECL void invoke_stdcall_none_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    #if defined (WIN32)
        x86tailfunc(3, 1);
    #else
        ((func_stdcall_outgen_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
    #endif
}
#endif

#if defined (CPUX86)
WIN32NAKED
REGISTER_DECL void invoke_stdcall_none_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    #if defined (WIN32)
        x86tailfunc(3, 2);
    #else
        ((func_stdcall_outgen_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
    #endif
}
#endif

#if defined (CPUX86)
WIN32NAKED
REGISTER_DECL void invoke_stdcall_none_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    #if defined (WIN32)
        x86tailfunc(3, 3);
    #else
        ((func_stdcall_outgen_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
    #endif
}
#endif

#if defined (CPUX86)
X86NAKED
REGISTER_DECL void invoke_stdcall_none_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    // ((func_stdcall_outgen_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
    x86tailfunc(3, 4);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_outgen_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_stdcall_outgen_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_outgen_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_stdcall_outgen_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_outgen_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_stdcall_outgen_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_outgen_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutGeneral = ((func_stdcall_outgen_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_float_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_stdcall_float_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_float_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_stdcall_float_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_float_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_stdcall_float_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_float_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutFloat = ((func_stdcall_float_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_ext_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_stdcall_ext_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_ext_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_stdcall_ext_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_ext_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_stdcall_ext_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_ext_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutDouble = ((func_stdcall_ext_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpu_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_stdcall_fpu_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpu_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_stdcall_fpu_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpu_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_stdcall_fpu_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpu_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutLongDouble = ((func_stdcall_fpu_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpuint64_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_stdcall_fpu_g)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpuint64_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_stdcall_fpu_gg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpuint64_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_stdcall_fpu_ggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

#if defined (CPUX86)
REGISTER_DECL void invoke_stdcall_fpuint64_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    long double R = ((func_stdcall_fpu_gggg)(address))(dumpregs.RegEAX, dumpregs.RegEDX, dumpregs.RegECX, dumpstack[0], dumpstack[1], dumpstack[2], dumpstack[3]);
    __asm__ ("fistpq %0": "=m" (dumpregs.OutInt64): "t" (R): "st");
}
#endif

REGISTER_DECL void invoke_safecall_(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_)(address))();
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}

REGISTER_DECL void invoke_safecall_g(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_g)(address))(dumpsafegen(0));
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_e(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_e)(address))(dumpexts[0]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

REGISTER_DECL void invoke_safecall_gg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gg)(address))(dumpsafegen(0), dumpsafegen(1));
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eg)(address))(dumpexts[0], dumpgens[0]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_ge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ge)(address))(dumpgens[0], dumpexts[0]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_ee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ee)(address))(dumpexts[0], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

REGISTER_DECL void invoke_safecall_ggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ggg)(address))(dumpsafegen(0), dumpsafegen(1), dumpsafegen(2));
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_egg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_egg)(address))(dumpexts[0], dumpgens[0], dumpgens[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_geg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_geg)(address))(dumpgens[0], dumpexts[0], dumpgens[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eeg)(address))(dumpexts[0], dumpexts[1], dumpgens[0]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_gge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gge)(address))(dumpgens[0], dumpgens[1], dumpexts[0]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_ege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ege)(address))(dumpexts[0], dumpgens[0], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_gee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gee)(address))(dumpgens[0], dumpexts[0], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_eee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eee)(address))(dumpexts[0], dumpexts[1], dumpexts[2]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

REGISTER_DECL void invoke_safecall_gggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gggg)(address))(dumpsafegen(0), dumpsafegen(1), dumpsafegen(2), dumpsafegen(3));
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eggg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eggg)(address))(dumpexts[0], dumpgens[0], dumpgens[1], dumpgens[2]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_gegg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gegg)(address))(dumpgens[0], dumpexts[0], dumpgens[1], dumpgens[2]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eegg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eegg)(address))(dumpexts[0], dumpexts[1], dumpgens[0], dumpgens[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_ggeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ggeg)(address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpgens[2]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_egeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_egeg)(address))(dumpexts[0], dumpgens[0], dumpexts[1], dumpgens[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_geeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_geeg)(address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpgens[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eeeg(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eeeg)(address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpgens[0]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_ggge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ggge)(address))(dumpgens[0], dumpgens[1], dumpgens[2], dumpexts[0]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_egge(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_egge)(address))(dumpexts[0], dumpgens[0], dumpgens[1], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_gege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_gege)(address))(dumpgens[0], dumpexts[0], dumpgens[1], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_eege(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eege)(address))(dumpexts[0], dumpexts[1], dumpgens[0], dumpexts[2]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_ggee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_ggee)(address))(dumpgens[0], dumpgens[1], dumpexts[0], dumpexts[1]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if defined (WIN64)
REGISTER_DECL void invoke_safecall_egee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_egee)(address))(dumpexts[0], dumpgens[0], dumpexts[1], dumpexts[2]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_geee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_geee)(address))(dumpgens[0], dumpexts[0], dumpexts[1], dumpexts[2]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif

#if !defined (CPUX86)
REGISTER_DECL void invoke_safecall_eeee(RttiSignature* signature, void* address, RttiInvokeDump* dump)
{
    dumpregs.OutInt32 = ((func_safecall_eeee)(address))(dumpexts[0], dumpexts[1], dumpexts[2], dumpexts[3]);
    if (dumpregs.OutInt32 < 0) TinyThrowSafeCall(dumpregs.OutInt32, __builtin_return_address(0));
}
#endif
