/* Set Artisan Sage-X UMC 0.18u standard cell library */

search_path = {. /libs/Artisan/aci/sc-x/synopsys/ } + \
		{ /libs/Artisan/aci/sc-x/symbols/synopsys/ }
snps = get_unix_variable("SYNOPSYS")
synthetic_library = { \
           snps + "/libraries/syn/dw01.sldb" \
           snps + "/libraries/syn/dw02.sldb" \
           snps + "/libraries/syn/dw03.sldb" \
           snps + "/libraries/syn/dw04.sldb" \
           snps + "/libraries/syn/dw05.sldb" \
           snps + "/libraries/syn/dw06.sldb" \
           snps + "/libraries/syn/dw07.sldb" }
target_library = { typical.db }
link_library = target_library + synthetic_library
symbol_library = { umc18.sdb }

