/* Set Virtual Silicon UMC 0.18u standard cell library */

search_path = {. /libs/Virtual_silicon/UMCL18U250D2_2.1/design_compiler/ }
snps = get_unix_variable("SYNOPSYS")
synthetic_library = { \
           snps + "/libraries/syn/dw01.sldb" \
           snps + "/libraries/syn/dw02.sldb" \
           snps + "/libraries/syn/dw03.sldb" \
           snps + "/libraries/syn/dw04.sldb" \
           snps + "/libraries/syn/dw05.sldb" \
           snps + "/libraries/syn/dw06.sldb" \
           snps + "/libraries/syn/dw07.sldb" }
target_library = { umcl18u250t2_typ.db }
link_library = target_library + synthetic_library
symbol_library = { umcl18u250t2.sdb }

