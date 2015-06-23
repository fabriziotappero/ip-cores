set_global_assignment -entity "mAltLvdsPll" -library "lib_mAltLvdsPll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "mAltLvdsPll" -library "lib_mAltLvdsPll" -name IP_TOOL_VERSION "12.0sp2"
set_global_assignment -entity "mAltLvdsPll" -library "lib_mAltLvdsPll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_mAltLvdsPll" -name SPD_FILE [file join $::quartus(sip_path) mAltLvdsPll.spd]

set_global_assignment -library "lib_mAltLvdsPll" -name MISC_FILE [file join $::quartus(sip_path) mAltLvdsPll_sim/mAltLvdsPll.vo]
