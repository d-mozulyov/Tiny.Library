
intercept_func(none_, 0, 0, 0, 0);

intercept_func(none_g, 0, 1, 0, 0);

intercept_func(gen_, 1, 0, 0, 0);

intercept_func(gen_g, 1, 1, 0, 0);

intercept_func(ext_, 2, 0, 0, 0);

intercept_func(ext_g, 2, 1, 0, 0);

#if defined (CPUX86)
intercept_func(float_, 4, 0, 0, 0);
#endif

#if defined (CPUX86)
intercept_func(float_g, 4, 1, 0, 0);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_, 5, 0, 0, 0);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_g, 5, 1, 0, 0);
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
intercept_func(fpu_, 3, 0, 0, 0);
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
intercept_func(fpu_g, 3, 1, 0, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_, 6, 0, 0, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_g, 6, 1, 0, 0);
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_()
{
    intercept_begin
        intercept_prologue
        intercept_store(0, 0)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_g()
{
    intercept_begin
        intercept_prologue
        intercept_store(1, 0)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_g)
    intercept_end(0)
}
#endif

#if !defined (CPUX86)
intercept_func(none_gg, 0, 2, 0, 0);
#endif

#if !defined (CPUX86)
intercept_func(gen_gg, 1, 2, 0, 0);
#endif

#if !defined (CPUX86)
intercept_func(ext_gg, 2, 2, 0, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_gg, 3, 2, 0, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_gg, 6, 2, 0, 0);
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_gg()
{
    intercept_begin
        intercept_prologue
        intercept_store(2, 0)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_gg)
    intercept_end(0)
}
#endif

intercept_func(none_ggg, 0, 3, 0, 0);

intercept_func(gen_ggg, 1, 3, 0, 0);

intercept_func(ext_ggg, 2, 3, 0, 0);

#if defined (CPUX86)
intercept_func(float_ggg, 4, 3, 0, 0);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_ggg, 5, 3, 0, 0);
#endif

#if defined (CPUX86) || defined (POSIXINTEL64)
intercept_func(fpu_ggg, 3, 3, 0, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_ggg, 6, 3, 0, 0);
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_ggg()
{
    intercept_begin
        intercept_prologue
        intercept_store(3, 0)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_ggg)
    intercept_end(0)
}
#endif

#if defined (CPUX86)
intercept_func(none_ggg1, 0, 3, 0, 1);
#endif

#if defined (CPUX86)
intercept_func(none_ggg2, 0, 3, 0, 2);
#endif

#if defined (CPUX86)
intercept_func(none_ggg3, 0, 3, 0, 3);
#endif

#if defined (CPUX86)
intercept_func(none_ggg4, 0, 3, 0, 4);
#endif

#if defined (CPUX86)
intercept_func(none_ggg5, 0, 3, 0, 5);
#endif

#if defined (CPUX86)
intercept_func(none_ggg6, 0, 3, 0, 6);
#endif

#if defined (CPUX86)
intercept_func(none_ggg7, 0, 3, 0, 7);
#endif

#if defined (CPUX86)
intercept_func(none_ggg8, 0, 3, 0, 8);
#endif

#if defined (CPUX86)
intercept_func(gen_ggg1, 1, 3, 0, 1);
#endif

#if defined (CPUX86)
intercept_func(gen_ggg2, 1, 3, 0, 2);
#endif

#if defined (CPUX86)
intercept_func(gen_ggg3, 1, 3, 0, 3);
#endif

#if defined (CPUX86)
intercept_func(gen_ggg4, 1, 3, 0, 4);
#endif

#if defined (CPUX86)
intercept_func(gen_ggg5, 1, 3, 0, 5);
#endif

#if defined (CPUX86)
intercept_func(gen_ggg6, 1, 3, 0, 6);
#endif

#if defined (CPUX86)
intercept_func(gen_ggg7, 1, 3, 0, 7);
#endif

#if defined (CPUX86)
intercept_func(gen_ggg8, 1, 3, 0, 8);
#endif

#if defined (CPUX86)
intercept_func(float_ggg1, 4, 3, 0, 1);
#endif

#if defined (CPUX86)
intercept_func(float_ggg2, 4, 3, 0, 2);
#endif

#if defined (CPUX86)
intercept_func(float_ggg3, 4, 3, 0, 3);
#endif

#if defined (CPUX86)
intercept_func(float_ggg4, 4, 3, 0, 4);
#endif

#if defined (CPUX86)
intercept_func(float_ggg5, 4, 3, 0, 5);
#endif

#if defined (CPUX86)
intercept_func(float_ggg6, 4, 3, 0, 6);
#endif

#if defined (CPUX86)
intercept_func(float_ggg7, 4, 3, 0, 7);
#endif

#if defined (CPUX86)
intercept_func(float_ggg8, 4, 3, 0, 8);
#endif

#if defined (CPUX86)
intercept_func(ext_ggg1, 2, 3, 0, 1);
#endif

#if defined (CPUX86)
intercept_func(ext_ggg2, 2, 3, 0, 2);
#endif

#if defined (CPUX86)
intercept_func(ext_ggg3, 2, 3, 0, 3);
#endif

#if defined (CPUX86)
intercept_func(ext_ggg4, 2, 3, 0, 4);
#endif

#if defined (CPUX86)
intercept_func(ext_ggg5, 2, 3, 0, 5);
#endif

#if defined (CPUX86)
intercept_func(ext_ggg6, 2, 3, 0, 6);
#endif

#if defined (CPUX86)
intercept_func(ext_ggg7, 2, 3, 0, 7);
#endif

#if defined (CPUX86)
intercept_func(ext_ggg8, 2, 3, 0, 8);
#endif

#if defined (CPUX86)
intercept_func(fpu_ggg1, 3, 3, 0, 1);
#endif

#if defined (CPUX86)
intercept_func(fpu_ggg2, 3, 3, 0, 2);
#endif

#if defined (CPUX86)
intercept_func(fpu_ggg3, 3, 3, 0, 3);
#endif

#if defined (CPUX86)
intercept_func(fpu_ggg4, 3, 3, 0, 4);
#endif

#if defined (CPUX86)
intercept_func(fpu_ggg5, 3, 3, 0, 5);
#endif

#if defined (CPUX86)
intercept_func(fpu_ggg6, 3, 3, 0, 6);
#endif

#if defined (CPUX86)
intercept_func(fpu_ggg7, 3, 3, 0, 7);
#endif

#if defined (CPUX86)
intercept_func(fpu_ggg8, 3, 3, 0, 8);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_ggg1, 5, 3, 0, 1);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_ggg2, 5, 3, 0, 2);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_ggg3, 5, 3, 0, 3);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_ggg4, 5, 3, 0, 4);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_ggg5, 5, 3, 0, 5);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_ggg6, 5, 3, 0, 6);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_ggg7, 5, 3, 0, 7);
#endif

#if defined (CPUX86)
intercept_func(fpuint64_ggg8, 5, 3, 0, 8);
#endif

#if !defined (CPUX86)
intercept_func(none_gggg, 0, 4, 0, 0);
#endif

#if !defined (CPUX86)
intercept_func(gen_gggg, 1, 4, 0, 0);
#endif

#if !defined (CPUX86)
intercept_func(ext_gggg, 2, 4, 0, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_gggg, 3, 4, 0, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_gggg, 6, 4, 0, 0);
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_gggg()
{
    intercept_begin
        intercept_prologue
        intercept_store(4, 0)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_gggg)
    intercept_end(0)
}
#endif

#if !defined (CPUX86)
intercept_func(none_e, 0, 0, 1, 0);
#endif

#if !defined (CPUX86)
intercept_func(none_ee, 0, 0, 2, 0);
#endif

#if !defined (CPUX86)
intercept_func(none_eee, 0, 0, 3, 0);
#endif

#if !defined (CPUX86)
intercept_func(none_eeee, 0, 0, 4, 0);
#endif

#if !defined (CPUX86)
intercept_func(gen_e, 1, 0, 1, 0);
#endif

#if !defined (CPUX86)
intercept_func(gen_ee, 1, 0, 2, 0);
#endif

#if !defined (CPUX86)
intercept_func(gen_eee, 1, 0, 3, 0);
#endif

#if !defined (CPUX86)
intercept_func(gen_eeee, 1, 0, 4, 0);
#endif

#if !defined (CPUX86)
intercept_func(ext_e, 2, 0, 1, 0);
#endif

#if !defined (CPUX86)
intercept_func(ext_ee, 2, 0, 2, 0);
#endif

#if !defined (CPUX86)
intercept_func(ext_eee, 2, 0, 3, 0);
#endif

#if !defined (CPUX86)
intercept_func(ext_eeee, 2, 0, 4, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_e, 3, 0, 1, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_ee, 3, 0, 2, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_eee, 3, 0, 3, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_eeee, 3, 0, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_e, 6, 0, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_ee, 6, 0, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_eee, 6, 0, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_eeee, 6, 0, 4, 0);
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_e()
{
    intercept_begin
        intercept_prologue
        intercept_store(0, 1)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_e)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_ee()
{
    intercept_begin
        intercept_prologue
        intercept_store(0, 2)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_ee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_eee()
{
    intercept_begin
        intercept_prologue
        intercept_store(0, 3)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_eee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_eeee()
{
    intercept_begin
        intercept_prologue
        intercept_store(0, 4)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_eeee)
    intercept_end(0)
}
#endif

#if defined (CPUX64)
intercept_msabi_func(none_ggge, 0, 1, 1, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_gge, 0, 1, 1, 2, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_ggeg, 0, 1, 1, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_ggee, 0, 1, 1, 2, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_ge, 0, 1, 2, 0, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_geg, 0, 1, 2, 1, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_gegg, 0, 1, 2, 1, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_gege, 0, 1, 2, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_gee, 0, 1, 2, 2, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_geeg, 0, 1, 2, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_geee, 0, 1, 2, 2, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_eg, 0, 2, 1, 0, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_egg, 0, 2, 1, 1, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_eggg, 0, 2, 1, 1, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_egge, 0, 2, 1, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_ege, 0, 2, 1, 2, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_egeg, 0, 2, 1, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_egee, 0, 2, 1, 2, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_eeg, 0, 2, 2, 1, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_eegg, 0, 2, 2, 1, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_eege, 0, 2, 2, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(none_eeeg, 0, 2, 2, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_ggge, 1, 1, 1, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_gge, 1, 1, 1, 2, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_ggeg, 1, 1, 1, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_ggee, 1, 1, 1, 2, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_ge, 1, 1, 2, 0, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_geg, 1, 1, 2, 1, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_gegg, 1, 1, 2, 1, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_gege, 1, 1, 2, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_gee, 1, 1, 2, 2, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_geeg, 1, 1, 2, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_geee, 1, 1, 2, 2, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_eg, 1, 2, 1, 0, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_egg, 1, 2, 1, 1, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_eggg, 1, 2, 1, 1, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_egge, 1, 2, 1, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_ege, 1, 2, 1, 2, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_egeg, 1, 2, 1, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_egee, 1, 2, 1, 2, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_eeg, 1, 2, 2, 1, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_eegg, 1, 2, 2, 1, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_eege, 1, 2, 2, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(gen_eeeg, 1, 2, 2, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_ggge, 2, 1, 1, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_gge, 2, 1, 1, 2, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_ggeg, 2, 1, 1, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_ggee, 2, 1, 1, 2, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_ge, 2, 1, 2, 0, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_geg, 2, 1, 2, 1, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_gegg, 2, 1, 2, 1, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_gege, 2, 1, 2, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_gee, 2, 1, 2, 2, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_geeg, 2, 1, 2, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_geee, 2, 1, 2, 2, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_eg, 2, 2, 1, 0, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_egg, 2, 2, 1, 1, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_eggg, 2, 2, 1, 1, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_egge, 2, 2, 1, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_ege, 2, 2, 1, 2, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_egeg, 2, 2, 1, 2, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_egee, 2, 2, 1, 2, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_eeg, 2, 2, 2, 1, 0);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_eegg, 2, 2, 2, 1, 1);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_eege, 2, 2, 2, 1, 2);
#endif

#if defined (CPUX64)
intercept_msabi_func(ext_eeeg, 2, 2, 2, 2, 1);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_ggge, 3, 1, 1, 1, 2);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_gge, 3, 1, 1, 2, 0);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_ggeg, 3, 1, 1, 2, 1);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_ggee, 3, 1, 1, 2, 2);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_ge, 3, 1, 2, 0, 0);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_geg, 3, 1, 2, 1, 0);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_gegg, 3, 1, 2, 1, 1);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_gege, 3, 1, 2, 1, 2);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_gee, 3, 1, 2, 2, 0);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_geeg, 3, 1, 2, 2, 1);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_geee, 3, 1, 2, 2, 2);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_eg, 3, 2, 1, 0, 0);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_egg, 3, 2, 1, 1, 0);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_eggg, 3, 2, 1, 1, 1);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_egge, 3, 2, 1, 1, 2);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_ege, 3, 2, 1, 2, 0);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_egeg, 3, 2, 1, 2, 1);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_egee, 3, 2, 1, 2, 2);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_eeg, 3, 2, 2, 1, 0);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_eegg, 3, 2, 2, 1, 1);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_eege, 3, 2, 2, 1, 2);
#endif

#if defined (POSIXINTEL64)
intercept_msabi_func(fpu_eeeg, 3, 2, 2, 2, 1);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_ge, 0, 1, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_gee, 0, 1, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_geee, 0, 1, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_geeee, 0, 1, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_gge, 0, 2, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_ggee, 0, 2, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_ggeee, 0, 2, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_ggeeee, 0, 2, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_ggge, 0, 3, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_gggee, 0, 3, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_gggeee, 0, 3, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_gggeeee, 0, 3, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_gggge, 0, 4, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_ggggee, 0, 4, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_ggggeee, 0, 4, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(none_ggggeeee, 0, 4, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_ge, 1, 1, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_gee, 1, 1, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_geee, 1, 1, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_geeee, 1, 1, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_gge, 1, 2, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_ggee, 1, 2, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_ggeee, 1, 2, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_ggeeee, 1, 2, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_ggge, 1, 3, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_gggee, 1, 3, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_gggeee, 1, 3, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_gggeeee, 1, 3, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_gggge, 1, 4, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_ggggee, 1, 4, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_ggggeee, 1, 4, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(gen_ggggeeee, 1, 4, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_ge, 2, 1, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_gee, 2, 1, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_geee, 2, 1, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_geeee, 2, 1, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_gge, 2, 2, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_ggee, 2, 2, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_ggeee, 2, 2, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_ggeeee, 2, 2, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_ggge, 2, 3, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_gggee, 2, 3, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_gggeee, 2, 3, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_gggeeee, 2, 3, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_gggge, 2, 4, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_ggggee, 2, 4, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_ggggeee, 2, 4, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(ext_ggggeeee, 2, 4, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_ge, 6, 1, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_gee, 6, 1, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_geee, 6, 1, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_geeee, 6, 1, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_gge, 6, 2, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_ggee, 6, 2, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_ggeee, 6, 2, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_ggeeee, 6, 2, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_ggge, 6, 3, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_gggee, 6, 3, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_gggeee, 6, 3, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_gggeeee, 6, 3, 4, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_gggge, 6, 4, 1, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_ggggee, 6, 4, 2, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_ggggeee, 6, 4, 3, 0);
#endif

#if defined (POSIXINTEL64) || defined (CPUARM)
intercept_func(hfa_ggggeeee, 6, 4, 4, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_ge, 3, 1, 1, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_gee, 3, 1, 2, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_geee, 3, 1, 3, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_geeee, 3, 1, 4, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_gge, 3, 2, 1, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_ggee, 3, 2, 2, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_ggeee, 3, 2, 3, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_ggeeee, 3, 2, 4, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_ggge, 3, 3, 1, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_gggee, 3, 3, 2, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_gggeee, 3, 3, 3, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_gggeeee, 3, 3, 4, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_gggge, 3, 4, 1, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_ggggee, 3, 4, 2, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_ggggeee, 3, 4, 3, 0);
#endif

#if defined (POSIXINTEL64)
intercept_func(fpu_ggggeeee, 3, 4, 4, 0);
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_ge()
{
    intercept_begin
        intercept_prologue
        intercept_store(1, 1)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_ge)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_gee()
{
    intercept_begin
        intercept_prologue
        intercept_store(1, 2)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_gee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_geee()
{
    intercept_begin
        intercept_prologue
        intercept_store(1, 3)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_geee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_geeee()
{
    intercept_begin
        intercept_prologue
        intercept_store(1, 4)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_geeee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_gge()
{
    intercept_begin
        intercept_prologue
        intercept_store(2, 1)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_gge)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_ggee()
{
    intercept_begin
        intercept_prologue
        intercept_store(2, 2)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_ggee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_ggeee()
{
    intercept_begin
        intercept_prologue
        intercept_store(2, 3)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_ggeee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_ggeeee()
{
    intercept_begin
        intercept_prologue
        intercept_store(2, 4)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_ggeeee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_ggge()
{
    intercept_begin
        intercept_prologue
        intercept_store(3, 1)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_ggge)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_gggee()
{
    intercept_begin
        intercept_prologue
        intercept_store(3, 2)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_gggee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_gggeee()
{
    intercept_begin
        intercept_prologue
        intercept_store(3, 3)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_gggeee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_gggeeee()
{
    intercept_begin
        intercept_prologue
        intercept_store(3, 4)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_gggeeee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_gggge()
{
    intercept_begin
        intercept_prologue
        intercept_store(4, 1)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_gggge)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_ggggee()
{
    intercept_begin
        intercept_prologue
        intercept_store(4, 2)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_ggggee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_ggggeee()
{
    intercept_begin
        intercept_prologue
        intercept_store(4, 3)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_ggggeee)
    intercept_end(0)
}
#endif

#if defined (CPUARM64)
REGISTER_DECL NAKED void intercept_retptr_ggggeeee()
{
    intercept_begin
        intercept_prologue
        intercept_store(4, 4)
        intercept_store_retptr
        intercept_call
        intercept_load(0)
        intercept_epilogue(retptr_ggggeeee)
    intercept_end(0)
}
#endif
