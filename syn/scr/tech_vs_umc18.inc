/* Set Virtual Silicon UMC 0.18u standard cell library */

search_path = {. /projects/libs/Virtual_silicon/UMCL18U250D2_2.1/design_compiler/ /projects/libs/Artisan/artisan_rams/art_hsdp_256x40/}
snps = get_unix_variable("SYNOPSYS")
synthetic_library = { \
           snps + "/libraries/syn/dw01.sldb" \
           snps + "/libraries/syn/dw02.sldb" \
           snps + "/libraries/syn/dw03.sldb" \
           snps + "/libraries/syn/dw04.sldb" \
           snps + "/libraries/syn/dw05.sldb" \
           snps + "/libraries/syn/dw06.sldb" \
           snps + "/libraries/syn/dw07.sldb" }
target_library = { umcl18u250t2_bc.db umcl18u250t2_wc.db art_hsdp_256x40_slow_syn.db art_hsdp_256x40_fast_syn.db}
link_library = target_library + synthetic_library
symbol_library = { umcl18u250t2.sdb }
set_min_library umcl18u250t2_wc.db -min_version umcl18u250t2_bc.db
