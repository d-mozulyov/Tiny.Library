    /* 01. (n/g/d)   ggg [all] */
    case 0x000000: return &invoke_register_none_;
    case 0x000001: return &invoke_register_none_g;
    case 0x000005: return &invoke_register_none_gg;
    case 0x000015: return &invoke_register_none_ggg;
    case 0x000100: return &invoke_register_outgen_;
    case 0x000101: return &invoke_register_outgen_g;
    case 0x000105: return &invoke_register_outgen_gg;
    case 0x000115: return &invoke_register_outgen_ggg;
    case 0x000400: return &invoke_register_ext_;
    case 0x000401: return &invoke_register_ext_g;
    case 0x000405: return &invoke_register_ext_gg;
    case 0x000415: return &invoke_register_ext_ggg;
    /* 02. (s/f64)   ggg [x86] */
    #if defined (CPUX86)
    case 0x000300: return &invoke_register_float_;
    case 0x000301: return &invoke_register_float_g;
    case 0x000305: return &invoke_register_float_gg;
    case 0x000315: return &invoke_register_float_ggg;
    case 0x000600: return &invoke_register_fpuint64_;
    case 0x000601: return &invoke_register_fpuint64_g;
    case 0x000605: return &invoke_register_fpuint64_gg;
    case 0x000615: return &invoke_register_fpuint64_ggg;
    #endif
    /* 03. (f)       ggg [x86, X64] */
    #if defined (CPUX86) || defined (POSIXINTEL64)
    case 0x000500: return &invoke_register_fpu_;
    case 0x000501: return &invoke_register_fpu_g;
    case 0x000505: return &invoke_register_fpu_gg;
    case 0x000515: return &invoke_register_fpu_ggg;
    #endif
    /* 04. (h)       ggg [X64, ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x000700: return &invoke_register_hfa_;
    case 0x000701: return &invoke_register_hfa_g;
    case 0x000705: return &invoke_register_hfa_gg;
    case 0x000715: return &invoke_register_hfa_ggg;
    #endif
    /* 05. (n/g/d)   gggg [all - x86] */
    #if !defined (CPUX86)
    case 0x000055: return &invoke_register_none_gggg;
    case 0x000155: return &invoke_register_outgen_gggg;
    case 0x000455: return &invoke_register_ext_gggg;
    #endif
    /* 06. (f)       gggg [X64] */
    #if defined (POSIXINTEL64)
    case 0x000555: return &invoke_register_fpu_gggg;
    #endif
    /* 07. (h)       gggg [X64/ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x000755: return &invoke_register_hfa_gggg;
    #endif
    /* 08. (n/g/d)   eeee [all - x86] */
    #if !defined (CPUX86)
    case 0x000002: return &invoke_register_none_e;
    case 0x00000A: return &invoke_register_none_ee;
    case 0x00002A: return &invoke_register_none_eee;
    case 0x0000AA: return &invoke_register_none_eeee;
    case 0x000102: return &invoke_register_outgen_e;
    case 0x00010A: return &invoke_register_outgen_ee;
    case 0x00012A: return &invoke_register_outgen_eee;
    case 0x0001AA: return &invoke_register_outgen_eeee;
    case 0x000402: return &invoke_register_ext_e;
    case 0x00040A: return &invoke_register_ext_ee;
    case 0x00042A: return &invoke_register_ext_eee;
    case 0x0004AA: return &invoke_register_ext_eeee;
    #endif
    /* 09. (f)       eeee [X64] */
    #if defined (POSIXINTEL64)
    case 0x000502: return &invoke_register_fpu_e;
    case 0x00050A: return &invoke_register_fpu_ee;
    case 0x00052A: return &invoke_register_fpu_eee;
    case 0x0005AA: return &invoke_register_fpu_eeee;
    #endif
    /* 10. (h)       eeee [X64/ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x000702: return &invoke_register_hfa_e;
    case 0x00070A: return &invoke_register_hfa_ee;
    case 0x00072A: return &invoke_register_hfa_eee;
    case 0x0007AA: return &invoke_register_hfa_eeee;
    #endif
    /* 11. (n/g/d)   gege [Win64, X64] */
    #if defined (CPUX64)
    case 0x001095: return &invoke_msabi_none_ggge;
    case 0x001025: return &invoke_msabi_none_gge;
    case 0x001065: return &invoke_msabi_none_ggeg;
    case 0x0010A5: return &invoke_msabi_none_ggee;
    case 0x001009: return &invoke_msabi_none_ge;
    case 0x001019: return &invoke_msabi_none_geg;
    case 0x001059: return &invoke_msabi_none_gegg;
    case 0x001099: return &invoke_msabi_none_gege;
    case 0x001029: return &invoke_msabi_none_gee;
    case 0x001069: return &invoke_msabi_none_geeg;
    case 0x0010A9: return &invoke_msabi_none_geee;
    case 0x001006: return &invoke_msabi_none_eg;
    case 0x001016: return &invoke_msabi_none_egg;
    case 0x001056: return &invoke_msabi_none_eggg;
    case 0x001096: return &invoke_msabi_none_egge;
    case 0x001026: return &invoke_msabi_none_ege;
    case 0x001066: return &invoke_msabi_none_egeg;
    case 0x0010A6: return &invoke_msabi_none_egee;
    case 0x00101A: return &invoke_msabi_none_eeg;
    case 0x00105A: return &invoke_msabi_none_eegg;
    case 0x00109A: return &invoke_msabi_none_eege;
    case 0x00106A: return &invoke_msabi_none_eeeg;
    case 0x001195: return &invoke_msabi_outgen_ggge;
    case 0x001125: return &invoke_msabi_outgen_gge;
    case 0x001165: return &invoke_msabi_outgen_ggeg;
    case 0x0011A5: return &invoke_msabi_outgen_ggee;
    case 0x001109: return &invoke_msabi_outgen_ge;
    case 0x001119: return &invoke_msabi_outgen_geg;
    case 0x001159: return &invoke_msabi_outgen_gegg;
    case 0x001199: return &invoke_msabi_outgen_gege;
    case 0x001129: return &invoke_msabi_outgen_gee;
    case 0x001169: return &invoke_msabi_outgen_geeg;
    case 0x0011A9: return &invoke_msabi_outgen_geee;
    case 0x001106: return &invoke_msabi_outgen_eg;
    case 0x001116: return &invoke_msabi_outgen_egg;
    case 0x001156: return &invoke_msabi_outgen_eggg;
    case 0x001196: return &invoke_msabi_outgen_egge;
    case 0x001126: return &invoke_msabi_outgen_ege;
    case 0x001166: return &invoke_msabi_outgen_egeg;
    case 0x0011A6: return &invoke_msabi_outgen_egee;
    case 0x00111A: return &invoke_msabi_outgen_eeg;
    case 0x00115A: return &invoke_msabi_outgen_eegg;
    case 0x00119A: return &invoke_msabi_outgen_eege;
    case 0x00116A: return &invoke_msabi_outgen_eeeg;
    case 0x001495: return &invoke_msabi_ext_ggge;
    case 0x001425: return &invoke_msabi_ext_gge;
    case 0x001465: return &invoke_msabi_ext_ggeg;
    case 0x0014A5: return &invoke_msabi_ext_ggee;
    case 0x001409: return &invoke_msabi_ext_ge;
    case 0x001419: return &invoke_msabi_ext_geg;
    case 0x001459: return &invoke_msabi_ext_gegg;
    case 0x001499: return &invoke_msabi_ext_gege;
    case 0x001429: return &invoke_msabi_ext_gee;
    case 0x001469: return &invoke_msabi_ext_geeg;
    case 0x0014A9: return &invoke_msabi_ext_geee;
    case 0x001406: return &invoke_msabi_ext_eg;
    case 0x001416: return &invoke_msabi_ext_egg;
    case 0x001456: return &invoke_msabi_ext_eggg;
    case 0x001496: return &invoke_msabi_ext_egge;
    case 0x001426: return &invoke_msabi_ext_ege;
    case 0x001466: return &invoke_msabi_ext_egeg;
    case 0x0014A6: return &invoke_msabi_ext_egee;
    case 0x00141A: return &invoke_msabi_ext_eeg;
    case 0x00145A: return &invoke_msabi_ext_eegg;
    case 0x00149A: return &invoke_msabi_ext_eege;
    case 0x00146A: return &invoke_msabi_ext_eeeg;
    #endif
    /* 12. (f)!h     gege [X64] */
    #if defined (POSIXINTEL64)
    case 0x001595: return &invoke_msabi_fpu_ggge;
    case 0x001525: return &invoke_msabi_fpu_gge;
    case 0x001565: return &invoke_msabi_fpu_ggeg;
    case 0x0015A5: return &invoke_msabi_fpu_ggee;
    case 0x001509: return &invoke_msabi_fpu_ge;
    case 0x001519: return &invoke_msabi_fpu_geg;
    case 0x001559: return &invoke_msabi_fpu_gegg;
    case 0x001599: return &invoke_msabi_fpu_gege;
    case 0x001529: return &invoke_msabi_fpu_gee;
    case 0x001569: return &invoke_msabi_fpu_geeg;
    case 0x0015A9: return &invoke_msabi_fpu_geee;
    case 0x001506: return &invoke_msabi_fpu_eg;
    case 0x001516: return &invoke_msabi_fpu_egg;
    case 0x001556: return &invoke_msabi_fpu_eggg;
    case 0x001596: return &invoke_msabi_fpu_egge;
    case 0x001526: return &invoke_msabi_fpu_ege;
    case 0x001566: return &invoke_msabi_fpu_egeg;
    case 0x0015A6: return &invoke_msabi_fpu_egee;
    case 0x00151A: return &invoke_msabi_fpu_eeg;
    case 0x00155A: return &invoke_msabi_fpu_eegg;
    case 0x00159A: return &invoke_msabi_fpu_eege;
    case 0x00156A: return &invoke_msabi_fpu_eeeg;
    #endif
    /* 13. (n/g/d/h) ggee [X64/ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x000095: return &invoke_register_none_ggge;
    case 0x000025: return &invoke_register_none_gge;
    case 0x0000A5: return &invoke_register_none_ggee;
    case 0x000009: return &invoke_register_none_ge;
    case 0x000029: return &invoke_register_none_gee;
    case 0x0000A9: return &invoke_register_none_geee;
    case 0x000195: return &invoke_register_outgen_ggge;
    case 0x000125: return &invoke_register_outgen_gge;
    case 0x0001A5: return &invoke_register_outgen_ggee;
    case 0x000109: return &invoke_register_outgen_ge;
    case 0x000129: return &invoke_register_outgen_gee;
    case 0x0001A9: return &invoke_register_outgen_geee;
    case 0x000495: return &invoke_register_ext_ggge;
    case 0x000425: return &invoke_register_ext_gge;
    case 0x0004A5: return &invoke_register_ext_ggee;
    case 0x000409: return &invoke_register_ext_ge;
    case 0x000429: return &invoke_register_ext_gee;
    case 0x0004A9: return &invoke_register_ext_geee;
    case 0x000795: return &invoke_register_hfa_ggge;
    case 0x000725: return &invoke_register_hfa_gge;
    case 0x0007A5: return &invoke_register_hfa_ggee;
    case 0x000709: return &invoke_register_hfa_ge;
    case 0x000729: return &invoke_register_hfa_gee;
    case 0x0007A9: return &invoke_register_hfa_geee;
    #endif
    /* 14. (f)       ggee [X64] */
    #if defined (POSIXINTEL64)
    case 0x000595: return &invoke_register_fpu_ggge;
    case 0x000525: return &invoke_register_fpu_gge;
    case 0x0005A5: return &invoke_register_fpu_ggee;
    case 0x000509: return &invoke_register_fpu_ge;
    case 0x000529: return &invoke_register_fpu_gee;
    case 0x0005A9: return &invoke_register_fpu_geee;
    #endif
    /* 15. (p)       xxxx [ARM64] */
    #if defined (CPUARM64)
    case 0x000800: return &invoke_register_retptr_;
    case 0x000801: return &invoke_register_retptr_g;
    case 0x000805: return &invoke_register_retptr_gg;
    case 0x000815: return &invoke_register_retptr_ggg;
    case 0x000855: return &invoke_register_retptr_gggg;
    case 0x000895: return &invoke_register_retptr_ggge;
    case 0x000825: return &invoke_register_retptr_gge;
    case 0x0008A5: return &invoke_register_retptr_ggee;
    case 0x000809: return &invoke_register_retptr_ge;
    case 0x000829: return &invoke_register_retptr_gee;
    case 0x0008A9: return &invoke_register_retptr_geee;
    case 0x000802: return &invoke_register_retptr_e;
    case 0x00080A: return &invoke_register_retptr_ee;
    case 0x00082A: return &invoke_register_retptr_eee;
    case 0x0008AA: return &invoke_register_retptr_eeee;
    #endif
    /* 16. (all-h/p) xxxgggg [x86-cdecl] */
    #if defined (CPUX86)
    case 0x011015: return &invoke_cdecl_none_g;
    case 0x021015: return &invoke_cdecl_none_gg;
    case 0x031015: return &invoke_cdecl_none_ggg;
    case 0x041015: return &invoke_cdecl_none_gggg;
    case 0x011115: return &invoke_cdecl_outgen_g;
    case 0x021115: return &invoke_cdecl_outgen_gg;
    case 0x031115: return &invoke_cdecl_outgen_ggg;
    case 0x041115: return &invoke_cdecl_outgen_gggg;
    case 0x011315: return &invoke_cdecl_float_g;
    case 0x021315: return &invoke_cdecl_float_gg;
    case 0x031315: return &invoke_cdecl_float_ggg;
    case 0x041315: return &invoke_cdecl_float_gggg;
    case 0x011415: return &invoke_cdecl_ext_g;
    case 0x021415: return &invoke_cdecl_ext_gg;
    case 0x031415: return &invoke_cdecl_ext_ggg;
    case 0x041415: return &invoke_cdecl_ext_gggg;
    case 0x011515: return &invoke_cdecl_fpu_g;
    case 0x021515: return &invoke_cdecl_fpu_gg;
    case 0x031515: return &invoke_cdecl_fpu_ggg;
    case 0x041515: return &invoke_cdecl_fpu_gggg;
    case 0x011615: return &invoke_cdecl_fpuint64_g;
    case 0x021615: return &invoke_cdecl_fpuint64_gg;
    case 0x031615: return &invoke_cdecl_fpuint64_ggg;
    case 0x041615: return &invoke_cdecl_fpuint64_gggg;
    #endif
    /* 17. (all-h/p) xxxgggg [x86-stdcall] */
    #if defined (CPUX86)
    case 0x010015: return &invoke_stdcall_none_g;
    case 0x020015: return &invoke_stdcall_none_gg;
    case 0x030015: return &invoke_stdcall_none_ggg;
    case 0x040015: return &invoke_stdcall_none_gggg;
    case 0x010115: return &invoke_stdcall_outgen_g;
    case 0x020115: return &invoke_stdcall_outgen_gg;
    case 0x030115: return &invoke_stdcall_outgen_ggg;
    case 0x040115: return &invoke_stdcall_outgen_gggg;
    case 0x010315: return &invoke_stdcall_float_g;
    case 0x020315: return &invoke_stdcall_float_gg;
    case 0x030315: return &invoke_stdcall_float_ggg;
    case 0x040315: return &invoke_stdcall_float_gggg;
    case 0x010415: return &invoke_stdcall_ext_g;
    case 0x020415: return &invoke_stdcall_ext_gg;
    case 0x030415: return &invoke_stdcall_ext_ggg;
    case 0x040415: return &invoke_stdcall_ext_gggg;
    case 0x010515: return &invoke_stdcall_fpu_g;
    case 0x020515: return &invoke_stdcall_fpu_gg;
    case 0x030515: return &invoke_stdcall_fpu_ggg;
    case 0x040515: return &invoke_stdcall_fpu_gggg;
    case 0x010615: return &invoke_stdcall_fpuint64_g;
    case 0x020615: return &invoke_stdcall_fpuint64_gg;
    case 0x030615: return &invoke_stdcall_fpuint64_ggg;
    case 0x040615: return &invoke_stdcall_fpuint64_gggg;
    #endif
    /* 18. safecall  gggg [all] */
    case 0x000200: return &invoke_safecall_;
    case 0x000201: return &invoke_safecall_g;
    case 0x000205: return &invoke_safecall_gg;
    case 0x000215: return &invoke_safecall_ggg;
    case 0x000255: return &invoke_safecall_gggg;
    /* 19. safecall  eeee [all - x86] */
    #if !defined (CPUX86)
    case 0x000202: return &invoke_safecall_e;
    case 0x00020A: return &invoke_safecall_ee;
    case 0x00022A: return &invoke_safecall_eee;
    case 0x0002AA: return &invoke_safecall_eeee;
    #endif
    /* 20. safecall  gege [Win64] */
    #if defined (WIN64)
    case 0x000295: return &invoke_safecall_ggge;
    case 0x000225: return &invoke_safecall_gge;
    case 0x000265: return &invoke_safecall_ggeg;
    case 0x0002A5: return &invoke_safecall_ggee;
    case 0x000209: return &invoke_safecall_ge;
    case 0x000219: return &invoke_safecall_geg;
    case 0x000259: return &invoke_safecall_gegg;
    case 0x000299: return &invoke_safecall_gege;
    case 0x000229: return &invoke_safecall_gee;
    case 0x000269: return &invoke_safecall_geeg;
    case 0x0002A9: return &invoke_safecall_geee;
    case 0x000206: return &invoke_safecall_eg;
    case 0x000216: return &invoke_safecall_egg;
    case 0x000256: return &invoke_safecall_eggg;
    case 0x000296: return &invoke_safecall_egge;
    case 0x000226: return &invoke_safecall_ege;
    case 0x000266: return &invoke_safecall_egeg;
    case 0x0002A6: return &invoke_safecall_egee;
    case 0x00021A: return &invoke_safecall_eeg;
    case 0x00025A: return &invoke_safecall_eegg;
    case 0x00029A: return &invoke_safecall_eege;
    case 0x00026A: return &invoke_safecall_eeeg;
    #endif
    /* 21. safecall  ggee [X64/ARM] */
    #if defined (POSIXINTEL64) || defined (CPUARM)
    case 0x000295: return &invoke_safecall_ggge;
    case 0x000225: return &invoke_safecall_gge;
    case 0x0002A5: return &invoke_safecall_ggee;
    case 0x000209: return &invoke_safecall_ge;
    case 0x000229: return &invoke_safecall_gee;
    case 0x0002A9: return &invoke_safecall_geee;
    #endif
