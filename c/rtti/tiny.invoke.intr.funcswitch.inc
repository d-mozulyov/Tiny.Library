    /* 01. (n/g/d)   _/g [all] */
    case 0x000000: return &intercept_none_;
    case 0x000001: return &intercept_none_g;
    case 0x100000: return &intercept_gen_;
    case 0x100001: return &intercept_gen_g;
    case 0x200000: return &intercept_ext_;
    case 0x200001: return &intercept_ext_g;
    /* 02. (s/f64)   _/g [x86] */
    #if defined (CPUX86)
    case 0x400000: return &intercept_float_;
    case 0x400001: return &intercept_float_g;
    case 0x500000: return &intercept_fpuint64_;
    case 0x500001: return &intercept_fpuint64_g;
    #endif
    /* 03. (f)       _/g [x86, X64] */
    #if defined (CPUX86) || defined (POSIXINTEL64)
    case 0x300000: return &intercept_fpu_;
    case 0x300001: return &intercept_fpu_g;
    #endif
    /* 04. (h)       _/g [X64, ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x600000: return &intercept_hfa_;
    case 0x600001: return &intercept_hfa_g;
    #endif
    /* 05. (p)       _/g [ARM64] */
    #if defined (CPUARM64)
    case 0x700000: return &intercept_retptr_;
    case 0x700001: return &intercept_retptr_g;
    #endif
    /* 06. (n/g/d)   gg [all - x86] */
    #if !defined (CPUX86)
    case 0x000005: return &intercept_none_gg;
    case 0x100005: return &intercept_gen_gg;
    case 0x200005: return &intercept_ext_gg;
    #endif
    /* 07. (f)       gg [X64] */
    #if defined (POSIXINTEL64)
    case 0x300005: return &intercept_fpu_gg;
    #endif
    /* 08. (h)       gg [X64, ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x600005: return &intercept_hfa_gg;
    #endif
    /* 09. (p)       gg [ARM64] */
    #if defined (CPUARM64)
    case 0x700005: return &intercept_retptr_gg;
    #endif
    /* 10. (n/g/d)   ggg [all] */
    case 0x000015: return &intercept_none_ggg;
    case 0x100015: return &intercept_gen_ggg;
    case 0x200015: return &intercept_ext_ggg;
    /* 11. (s/f64)   ggg [x86] */
    #if defined (CPUX86)
    case 0x400015: return &intercept_float_ggg;
    case 0x500015: return &intercept_fpuint64_ggg;
    #endif
    /* 12. (f)       ggg [x86, X64] */
    #if defined (CPUX86) || defined (POSIXINTEL64)
    case 0x300015: return &intercept_fpu_ggg;
    #endif
    /* 13. (h)       ggg [X64, ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x600015: return &intercept_hfa_ggg;
    #endif
    /* 14. (p)       ggg [ARM64] */
    #if defined (CPUARM64)
    case 0x700015: return &intercept_retptr_ggg;
    #endif
    /* 15. (all-h/p) ggg+ [x86] */
    #if defined (CPUX86)
    case 0x010015: return &intercept_none_ggg1;
    case 0x020015: return &intercept_none_ggg2;
    case 0x030015: return &intercept_none_ggg3;
    case 0x040015: return &intercept_none_ggg4;
    case 0x050015: return &intercept_none_ggg5;
    case 0x060015: return &intercept_none_ggg6;
    case 0x070015: return &intercept_none_ggg7;
    case 0x080015: return &intercept_none_ggg8;
    case 0x110015: return &intercept_gen_ggg1;
    case 0x120015: return &intercept_gen_ggg2;
    case 0x130015: return &intercept_gen_ggg3;
    case 0x140015: return &intercept_gen_ggg4;
    case 0x150015: return &intercept_gen_ggg5;
    case 0x160015: return &intercept_gen_ggg6;
    case 0x170015: return &intercept_gen_ggg7;
    case 0x180015: return &intercept_gen_ggg8;
    case 0x410015: return &intercept_float_ggg1;
    case 0x420015: return &intercept_float_ggg2;
    case 0x430015: return &intercept_float_ggg3;
    case 0x440015: return &intercept_float_ggg4;
    case 0x450015: return &intercept_float_ggg5;
    case 0x460015: return &intercept_float_ggg6;
    case 0x470015: return &intercept_float_ggg7;
    case 0x480015: return &intercept_float_ggg8;
    case 0x210015: return &intercept_ext_ggg1;
    case 0x220015: return &intercept_ext_ggg2;
    case 0x230015: return &intercept_ext_ggg3;
    case 0x240015: return &intercept_ext_ggg4;
    case 0x250015: return &intercept_ext_ggg5;
    case 0x260015: return &intercept_ext_ggg6;
    case 0x270015: return &intercept_ext_ggg7;
    case 0x280015: return &intercept_ext_ggg8;
    case 0x310015: return &intercept_fpu_ggg1;
    case 0x320015: return &intercept_fpu_ggg2;
    case 0x330015: return &intercept_fpu_ggg3;
    case 0x340015: return &intercept_fpu_ggg4;
    case 0x350015: return &intercept_fpu_ggg5;
    case 0x360015: return &intercept_fpu_ggg6;
    case 0x370015: return &intercept_fpu_ggg7;
    case 0x380015: return &intercept_fpu_ggg8;
    case 0x510015: return &intercept_fpuint64_ggg1;
    case 0x520015: return &intercept_fpuint64_ggg2;
    case 0x530015: return &intercept_fpuint64_ggg3;
    case 0x540015: return &intercept_fpuint64_ggg4;
    case 0x550015: return &intercept_fpuint64_ggg5;
    case 0x560015: return &intercept_fpuint64_ggg6;
    case 0x570015: return &intercept_fpuint64_ggg7;
    case 0x580015: return &intercept_fpuint64_ggg8;
    #endif
    /* 16. (n/g/d)   gggg [all - x86] */
    #if !defined (CPUX86)
    case 0x000055: return &intercept_none_gggg;
    case 0x100055: return &intercept_gen_gggg;
    case 0x200055: return &intercept_ext_gggg;
    #endif
    /* 17. (f)       gggg [X64] */
    #if defined (POSIXINTEL64)
    case 0x300055: return &intercept_fpu_gggg;
    #endif
    /* 18. (h)       gggg [X64, ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x600055: return &intercept_hfa_gggg;
    #endif
    /* 19. (p)       gggg [ARM64] */
    #if defined (CPUARM64)
    case 0x700055: return &intercept_retptr_gggg;
    #endif
    /* 20. (n/g/d)   eeee [all - x86] */
    #if !defined (CPUX86)
    case 0x000002: return &intercept_none_e;
    case 0x00000A: return &intercept_none_ee;
    case 0x00002A: return &intercept_none_eee;
    case 0x0000AA: return &intercept_none_eeee;
    case 0x100002: return &intercept_gen_e;
    case 0x10000A: return &intercept_gen_ee;
    case 0x10002A: return &intercept_gen_eee;
    case 0x1000AA: return &intercept_gen_eeee;
    case 0x200002: return &intercept_ext_e;
    case 0x20000A: return &intercept_ext_ee;
    case 0x20002A: return &intercept_ext_eee;
    case 0x2000AA: return &intercept_ext_eeee;
    #endif
    /* 21. (f)       eeee [X64] */
    #if defined (POSIXINTEL64)
    case 0x300002: return &intercept_fpu_e;
    case 0x30000A: return &intercept_fpu_ee;
    case 0x30002A: return &intercept_fpu_eee;
    case 0x3000AA: return &intercept_fpu_eeee;
    #endif
    /* 22. (h)       eeee [X64, ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x600002: return &intercept_hfa_e;
    case 0x60000A: return &intercept_hfa_ee;
    case 0x60002A: return &intercept_hfa_eee;
    case 0x6000AA: return &intercept_hfa_eeee;
    #endif
    /* 23. (p)       eeee [ARM64] */
    #if defined (CPUARM64)
    case 0x700002: return &intercept_retptr_e;
    case 0x70000A: return &intercept_retptr_ee;
    case 0x70002A: return &intercept_retptr_eee;
    case 0x7000AA: return &intercept_retptr_eeee;
    #endif
    /* 24. (n/g/d)   gege [Win64, X64] */
    #if defined (CPUX64)
    case 0x010095: return &intercept_msabi_none_ggge;
    case 0x010025: return &intercept_msabi_none_gge;
    case 0x010065: return &intercept_msabi_none_ggeg;
    case 0x0100A5: return &intercept_msabi_none_ggee;
    case 0x010009: return &intercept_msabi_none_ge;
    case 0x010019: return &intercept_msabi_none_geg;
    case 0x010059: return &intercept_msabi_none_gegg;
    case 0x010099: return &intercept_msabi_none_gege;
    case 0x010029: return &intercept_msabi_none_gee;
    case 0x010069: return &intercept_msabi_none_geeg;
    case 0x0100A9: return &intercept_msabi_none_geee;
    case 0x010006: return &intercept_msabi_none_eg;
    case 0x010016: return &intercept_msabi_none_egg;
    case 0x010056: return &intercept_msabi_none_eggg;
    case 0x010096: return &intercept_msabi_none_egge;
    case 0x010026: return &intercept_msabi_none_ege;
    case 0x010066: return &intercept_msabi_none_egeg;
    case 0x0100A6: return &intercept_msabi_none_egee;
    case 0x01001A: return &intercept_msabi_none_eeg;
    case 0x01005A: return &intercept_msabi_none_eegg;
    case 0x01009A: return &intercept_msabi_none_eege;
    case 0x01006A: return &intercept_msabi_none_eeeg;
    case 0x110095: return &intercept_msabi_gen_ggge;
    case 0x110025: return &intercept_msabi_gen_gge;
    case 0x110065: return &intercept_msabi_gen_ggeg;
    case 0x1100A5: return &intercept_msabi_gen_ggee;
    case 0x110009: return &intercept_msabi_gen_ge;
    case 0x110019: return &intercept_msabi_gen_geg;
    case 0x110059: return &intercept_msabi_gen_gegg;
    case 0x110099: return &intercept_msabi_gen_gege;
    case 0x110029: return &intercept_msabi_gen_gee;
    case 0x110069: return &intercept_msabi_gen_geeg;
    case 0x1100A9: return &intercept_msabi_gen_geee;
    case 0x110006: return &intercept_msabi_gen_eg;
    case 0x110016: return &intercept_msabi_gen_egg;
    case 0x110056: return &intercept_msabi_gen_eggg;
    case 0x110096: return &intercept_msabi_gen_egge;
    case 0x110026: return &intercept_msabi_gen_ege;
    case 0x110066: return &intercept_msabi_gen_egeg;
    case 0x1100A6: return &intercept_msabi_gen_egee;
    case 0x11001A: return &intercept_msabi_gen_eeg;
    case 0x11005A: return &intercept_msabi_gen_eegg;
    case 0x11009A: return &intercept_msabi_gen_eege;
    case 0x11006A: return &intercept_msabi_gen_eeeg;
    case 0x210095: return &intercept_msabi_ext_ggge;
    case 0x210025: return &intercept_msabi_ext_gge;
    case 0x210065: return &intercept_msabi_ext_ggeg;
    case 0x2100A5: return &intercept_msabi_ext_ggee;
    case 0x210009: return &intercept_msabi_ext_ge;
    case 0x210019: return &intercept_msabi_ext_geg;
    case 0x210059: return &intercept_msabi_ext_gegg;
    case 0x210099: return &intercept_msabi_ext_gege;
    case 0x210029: return &intercept_msabi_ext_gee;
    case 0x210069: return &intercept_msabi_ext_geeg;
    case 0x2100A9: return &intercept_msabi_ext_geee;
    case 0x210006: return &intercept_msabi_ext_eg;
    case 0x210016: return &intercept_msabi_ext_egg;
    case 0x210056: return &intercept_msabi_ext_eggg;
    case 0x210096: return &intercept_msabi_ext_egge;
    case 0x210026: return &intercept_msabi_ext_ege;
    case 0x210066: return &intercept_msabi_ext_egeg;
    case 0x2100A6: return &intercept_msabi_ext_egee;
    case 0x21001A: return &intercept_msabi_ext_eeg;
    case 0x21005A: return &intercept_msabi_ext_eegg;
    case 0x21009A: return &intercept_msabi_ext_eege;
    case 0x21006A: return &intercept_msabi_ext_eeeg;
    #endif
    /* 25. (f)!h     gege [X64] */
    #if defined (POSIXINTEL64)
    case 0x310095: return &intercept_msabi_fpu_ggge;
    case 0x310025: return &intercept_msabi_fpu_gge;
    case 0x310065: return &intercept_msabi_fpu_ggeg;
    case 0x3100A5: return &intercept_msabi_fpu_ggee;
    case 0x310009: return &intercept_msabi_fpu_ge;
    case 0x310019: return &intercept_msabi_fpu_geg;
    case 0x310059: return &intercept_msabi_fpu_gegg;
    case 0x310099: return &intercept_msabi_fpu_gege;
    case 0x310029: return &intercept_msabi_fpu_gee;
    case 0x310069: return &intercept_msabi_fpu_geeg;
    case 0x3100A9: return &intercept_msabi_fpu_geee;
    case 0x310006: return &intercept_msabi_fpu_eg;
    case 0x310016: return &intercept_msabi_fpu_egg;
    case 0x310056: return &intercept_msabi_fpu_eggg;
    case 0x310096: return &intercept_msabi_fpu_egge;
    case 0x310026: return &intercept_msabi_fpu_ege;
    case 0x310066: return &intercept_msabi_fpu_egeg;
    case 0x3100A6: return &intercept_msabi_fpu_egee;
    case 0x31001A: return &intercept_msabi_fpu_eeg;
    case 0x31005A: return &intercept_msabi_fpu_eegg;
    case 0x31009A: return &intercept_msabi_fpu_eege;
    case 0x31006A: return &intercept_msabi_fpu_eeeg;
    #endif
    /* 26. (n/g/d/h) ggee [X64/ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x000009: return &intercept_none_ge;
    case 0x000029: return &intercept_none_gee;
    case 0x0000A9: return &intercept_none_geee;
    case 0x0002A9: return &intercept_none_geeee;
    case 0x000025: return &intercept_none_gge;
    case 0x0000A5: return &intercept_none_ggee;
    case 0x0002A5: return &intercept_none_ggeee;
    case 0x000AA5: return &intercept_none_ggeeee;
    case 0x000095: return &intercept_none_ggge;
    case 0x000295: return &intercept_none_gggee;
    case 0x000A95: return &intercept_none_gggeee;
    case 0x002A95: return &intercept_none_gggeeee;
    case 0x000255: return &intercept_none_gggge;
    case 0x000A55: return &intercept_none_ggggee;
    case 0x002A55: return &intercept_none_ggggeee;
    case 0x00AA55: return &intercept_none_ggggeeee;
    case 0x100009: return &intercept_gen_ge;
    case 0x100029: return &intercept_gen_gee;
    case 0x1000A9: return &intercept_gen_geee;
    case 0x1002A9: return &intercept_gen_geeee;
    case 0x100025: return &intercept_gen_gge;
    case 0x1000A5: return &intercept_gen_ggee;
    case 0x1002A5: return &intercept_gen_ggeee;
    case 0x100AA5: return &intercept_gen_ggeeee;
    case 0x100095: return &intercept_gen_ggge;
    case 0x100295: return &intercept_gen_gggee;
    case 0x100A95: return &intercept_gen_gggeee;
    case 0x102A95: return &intercept_gen_gggeeee;
    case 0x100255: return &intercept_gen_gggge;
    case 0x100A55: return &intercept_gen_ggggee;
    case 0x102A55: return &intercept_gen_ggggeee;
    case 0x10AA55: return &intercept_gen_ggggeeee;
    case 0x200009: return &intercept_ext_ge;
    case 0x200029: return &intercept_ext_gee;
    case 0x2000A9: return &intercept_ext_geee;
    case 0x2002A9: return &intercept_ext_geeee;
    case 0x200025: return &intercept_ext_gge;
    case 0x2000A5: return &intercept_ext_ggee;
    case 0x2002A5: return &intercept_ext_ggeee;
    case 0x200AA5: return &intercept_ext_ggeeee;
    case 0x200095: return &intercept_ext_ggge;
    case 0x200295: return &intercept_ext_gggee;
    case 0x200A95: return &intercept_ext_gggeee;
    case 0x202A95: return &intercept_ext_gggeeee;
    case 0x200255: return &intercept_ext_gggge;
    case 0x200A55: return &intercept_ext_ggggee;
    case 0x202A55: return &intercept_ext_ggggeee;
    case 0x20AA55: return &intercept_ext_ggggeeee;
    case 0x600009: return &intercept_hfa_ge;
    case 0x600029: return &intercept_hfa_gee;
    case 0x6000A9: return &intercept_hfa_geee;
    case 0x6002A9: return &intercept_hfa_geeee;
    case 0x600025: return &intercept_hfa_gge;
    case 0x6000A5: return &intercept_hfa_ggee;
    case 0x6002A5: return &intercept_hfa_ggeee;
    case 0x600AA5: return &intercept_hfa_ggeeee;
    case 0x600095: return &intercept_hfa_ggge;
    case 0x600295: return &intercept_hfa_gggee;
    case 0x600A95: return &intercept_hfa_gggeee;
    case 0x602A95: return &intercept_hfa_gggeeee;
    case 0x600255: return &intercept_hfa_gggge;
    case 0x600A55: return &intercept_hfa_ggggee;
    case 0x602A55: return &intercept_hfa_ggggeee;
    case 0x60AA55: return &intercept_hfa_ggggeeee;
    #endif
    /* 27. (f)       ggee [X64] */
    #if defined (POSIXINTEL64)
    case 0x300009: return &intercept_fpu_ge;
    case 0x300029: return &intercept_fpu_gee;
    case 0x3000A9: return &intercept_fpu_geee;
    case 0x3002A9: return &intercept_fpu_geeee;
    case 0x300025: return &intercept_fpu_gge;
    case 0x3000A5: return &intercept_fpu_ggee;
    case 0x3002A5: return &intercept_fpu_ggeee;
    case 0x300AA5: return &intercept_fpu_ggeeee;
    case 0x300095: return &intercept_fpu_ggge;
    case 0x300295: return &intercept_fpu_gggee;
    case 0x300A95: return &intercept_fpu_gggeee;
    case 0x302A95: return &intercept_fpu_gggeeee;
    case 0x300255: return &intercept_fpu_gggge;
    case 0x300A55: return &intercept_fpu_ggggee;
    case 0x302A55: return &intercept_fpu_ggggeee;
    case 0x30AA55: return &intercept_fpu_ggggeeee;
    #endif
    /* 28. (p)       ggee [ARM64] */
    #if defined (CPUARM64)
    case 0x700009: return &intercept_retptr_ge;
    case 0x700029: return &intercept_retptr_gee;
    case 0x7000A9: return &intercept_retptr_geee;
    case 0x7002A9: return &intercept_retptr_geeee;
    case 0x700025: return &intercept_retptr_gge;
    case 0x7000A5: return &intercept_retptr_ggee;
    case 0x7002A5: return &intercept_retptr_ggeee;
    case 0x700AA5: return &intercept_retptr_ggeeee;
    case 0x700095: return &intercept_retptr_ggge;
    case 0x700295: return &intercept_retptr_gggee;
    case 0x700A95: return &intercept_retptr_gggeee;
    case 0x702A95: return &intercept_retptr_gggeeee;
    case 0x700255: return &intercept_retptr_gggge;
    case 0x700A55: return &intercept_retptr_ggggee;
    case 0x702A55: return &intercept_retptr_ggggeee;
    case 0x70AA55: return &intercept_retptr_ggggeeee;
    #endif
