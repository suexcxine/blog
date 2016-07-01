title: erlang HiPE不兼容警告
date: 2016-06-30 10:31
tags: [erlang]
---

遇到了这样的警告信息, 意思好像是native code不兼容用不了, fallback成使用byte code了
```
=INFO REPORT==== 29-Jun-2016::20:40:28 ===
<HiPE (v 3.9.3)> Warning: not loading native code for module mod_player: it was compiled for an incompatible runtime system; please regenerate native code for this runtime system
```

lib/kernel/src/hipe_unified_loader.erl
```
case hipe_bifs:check_crc(CheckSum) of                                          
  false ->                                                                     
    ?msg("Warning: not loading native code for module ~w: "                    
     "it was compiled for an incompatible runtime system; "                    
     "please regenerate native code for this runtime system\n", [Mod]),        
    bad_crc;
```

erts/emulator/hipe/hipe_bif0.c
```
BIF_RETTYPE hipe_bifs_check_crc_1(BIF_ALIST_1)                                   
{                                                                                
    Uint crc;                                                                    
                                                                                 
    if (!term_to_Uint(BIF_ARG_1, &crc))                                          
    BIF_ERROR(BIF_P, BADARG);                                                    
    if (crc == HIPE_ERTS_CHECKSUM)                                               
    BIF_RET(am_true);                                                            
    BIF_RET(am_false);                                                           
}
```

