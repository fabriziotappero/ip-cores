# ---------------------------------------------------------------------------------
# INIT SCRIPT
# ---------------------------------------------------------------------------------
 puts "=============================================================================="
 puts "INIT MACRO - SYNTAX: do init.do <ENVIRONMENT>"
 puts "=============================================================================="
# ---------------------------------------------------------------------------------
# PROJECT ENVIRONMENTS
# ---------------------------------------------------------------------------------
 set path_project_files ""
 set path_log_files     "Simulation/Logs"
 set path_script_files  "Simulation/Scripts"
 set path_wave_files    "Simulation/Waves"
 set path_meminit_files "Simulation/Memory_Init"
 set path_msim_files    "Simulation/Modelsim"
#
 if {$1 == "home"} {
 puts "==========================="
 puts "HOME ENVIRONMENT SELECTED"
 puts "==========================="
 set path_project_files "d:/Documenten/Projects/ESoC"
 } elseif {$1 == "work"} {
 puts "==========================="
 puts "WORK ENVIRONMENT SELECTED"
 puts "==========================="
 set path_project_files "c:/data/temp/ESoC"
 } else {
 puts "==========================="
 puts "NO ENVIRONMENT SELECTED"
 puts "==========================="}
#
# ---------------------------------------------------------------------------------
# DESIGN ENVIRONMENTS
# ---------------------------------------------------------------------------------
 set   path_design_files_altera   "Sources/altera"
 set   path_design_files_ease     "Sources/esoc.ews/design.hdl" 
 set   path_design_files_logixa   "Sources/logixa" 
#
 puts "=============================================================================="
 puts "Ready to use BUILD.DO to compile the design and RUN.DO to perform a simulation."
 puts "=============================================================================="