
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name sport_top -dir "C:/Users/jeffA/Desktop/rtl/sport/trunk/syn/xilinx/ise/sport_top/planAhead_run_2" -part xc3s700anfgg484-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/jeffA/Desktop/rtl/sport/trunk/syn/xilinx/ise/sport_top/sport_top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/jeffA/Desktop/rtl/sport/trunk/syn/xilinx/ise/sport_top} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "sport_top.ucf" [current_fileset -constrset]
add_files [list {sport_top.ucf}] -fileset [get_property constrset [current_run]]
link_design
