
set snps [getenv {SNPS_HOME}]

set synthetic_library {"dw01.sldb" "dw02.sldb"} 
set search_path  ". /usr/local/synlibs/dare/db $snps/libraries/syn"
set target_library "RadHardUMC18_WLM.db RadHardUMC18_CORE_STD_WCMIL.db RadHardUMC18_CORE_HIT_WCMIL.db"
set link_library "RadHardUMC18_WLM.db * RadHardUMC18_CORE_HIT_WCMIL.db RadHardUMC18_CORE_STD_WCMIL.db \
	Post_RH_UMC018_LVDSLIB_WCMIL.db Post_RH_UMC018_IOLIB_WCMIL.db \
	SRAM_1024wx40b_wcmil.db SRAM_128wx32b_wcmil.db SRAM_128wx40b_wcmil.db \
	SRAM_256wx32b_wcmil.db SRAM_2048wx40b_wcmil.db RadHardUMC18_PLL.db \
	standard.sldb dw01.sldb dw02.sldb \
	dw03.sldb dw04.sldb dw05.sldb dw07.sldb dw_foundation.sldb"
set symbol_library "generic.sdb"
set allow_newer_db_files "true"

set_ultra_optimization true
#define_design_lib work -path synopsys

#################################
# synopsys design vision setup
#################################
set sh_enable_line_editing true
#set hdlin_enable_presto_for_vhdl true
alias h history
alias rc "report_constraint -all_violators"
alias rda "remove_design -all"

# Architecture was already analyzed
suppress_message VHD-4

# Initial values not supported for synthesis
suppress_message VHD-7        

# Floating input ports are connected to ground
suppress_message ELAB-294     

# DEFAULT branch of CASE statement cannot be reached
suppress_message ELAB-311     

# Potential simulation-synthesis mismatch if index exceeds size of array
suppress_message ELAB-349

# Presto division message
suppress_message ELAB-402     

# Signal assignment delays not supported
suppress_message ELAB-924     

# Pads are dont touch
suppress_message OPT-1006

# ... index exceeds size of array
# suppress_message ELAB-349     

################
# Old options 
################

# set cache_write "/data/asic/synopsys_cache"  
# set cache_read  "/data/asic/synopsys_cache"

set hdlin_translate_off_skip_text true
#set bus_naming_style "%s_%d"
#set vhdlout_bit_type std_logic
#set vhdlout_write_components false
#set vhdlout_single_bit user
#set vhdlout_follow_vector_direction true
#set vhdlout_dont_write_types true

# Avoid Warning for setting Design Rule attributes from driving cell on a port.
suppress_message {UID-401}
# Avoid Warning for Assert statements.
suppress_message {VHDL-2099}


set view_script_submenu_items "$view_script_submenu_items\
  \"Clean Sweep\" \"remove_design -designs\""

#########################
# wire load estimation 
#########################
set auto_wire_load_selection "true"

############
# vhdl out 
############
#set vhdlout_single_bit "false" 
#set vhdlout_use_packages {IEEE.std_logic_1164 \
#	umc.vcomponents umc.ramcomponents }
#set vhdlout_write_top_configuration "true"

#######
# sge 
#######
set set_fix_multiple_port_nets "true"

##########
# hdlin 
##########
set hdlin_latch_synch_set_reset "false" 

set_dont_use RadHardUMC18_CORE_STD_WCMIL/LATCH
set_dont_use RadHardUMC18_CORE_STD_WCMIL/LATCHD2
set_dont_use RadHardUMC18_CORE_STD_WCMIL/SLATCH
set_dont_use RadHardUMC18_CORE_STD_WCMIL/SLATCHD2
set_dont_use RadHardUMC18_CORE_STD_WCMIL/DFF
set_dont_use RadHardUMC18_CORE_STD_WCMIL/DFFD2
set_dont_use RadHardUMC18_CORE_STD_WCMIL/DFFRL
set_dont_use RadHardUMC18_CORE_STD_WCMIL/DFFRLD2
set_dont_use RadHardUMC18_CORE_STD_WCMIL/DFFSL
set_dont_use RadHardUMC18_CORE_STD_WCMIL/DFFSLD2
set_dont_use RadHardUMC18_CORE_STD_WCMIL/DFFSLRL
set_dont_use RadHardUMC18_CORE_STD_WCMIL/DFFSLRLD2
set_dont_use RadHardUMC18_CORE_STD_WCMIL/SDFF
set_dont_use RadHardUMC18_CORE_STD_WCMIL/SDFFD2
set_dont_use RadHardUMC18_CORE_STD_WCMIL/SDFFRL
set_dont_use RadHardUMC18_CORE_STD_WCMIL/SDFFRLD2
set_dont_use RadHardUMC18_CORE_STD_WCMIL/SDFFSL
set_dont_use RadHardUMC18_CORE_STD_WCMIL/SDFFSLD2
set_dont_use RadHardUMC18_CORE_STD_WCMIL/SDFFSLRL
set_dont_use RadHardUMC18_CORE_STD_WCMIL/SDFFSLRLD2 
