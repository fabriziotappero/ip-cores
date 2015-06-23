
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name LZRWcompressor -dir "/home/lukas/e-/logic-analyzer/LZRW-compressor-OC/lzrw1-compressor-core/lzrw1-compressor-core/trunk/hw/xst_14_2/planAhead_run_1" -part xa6slx45csg324-2
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "/home/lukas/e-/logic-analyzer/LZRW-compressor-OC/lzrw1-compressor-core/lzrw1-compressor-core/trunk/hw/xst_14_2/CompressorTop.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/lukas/e-/logic-analyzer/LZRW-compressor-OC/lzrw1-compressor-core/lzrw1-compressor-core/trunk/hw/xst_14_2} }
set_property target_constrs_file "LZRWcompressor.ucf" [current_fileset -constrset]
add_files [list {LZRWcompressor.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "/home/lukas/e-/logic-analyzer/LZRW-compressor-OC/lzrw1-compressor-core/lzrw1-compressor-core/trunk/hw/xst_14_2/CompressorTop.ncd"
if {[catch {read_twx -name results_1 -file "/home/lukas/e-/logic-analyzer/LZRW-compressor-OC/lzrw1-compressor-core/lzrw1-compressor-core/trunk/hw/xst_14_2/CompressorTop.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"/home/lukas/e-/logic-analyzer/LZRW-compressor-OC/lzrw1-compressor-core/lzrw1-compressor-core/trunk/hw/xst_14_2/CompressorTop.twx\": $eInfo"
}
