

new_design -name "libero_designer" -family "<DEVICE_FAMILY>" -path {.} -block "off" 

set_device -die     "<DEVICE_NAME>"    \
           -package "<DEVICE_PACKAGE>" \
	   -speed   "<SPEED_GRADE>" 

import_source -format "edif" -edif_flavor "GENERIC" {../work_synplify/synplify.edn}  \
              -format "sdc"  -scenario "Primary"    {../design_constraints.post.sdc} \
              -format "pdc"  -abort_on_error  "yes" {../design_constraints.pdc}      \
	      -merge_physical "no" -merge_timing "yes" 

compile -pdc_abort_on_error "on"              -pdc_eco_display_unmatched_objects "off" -pdc_eco_max_warnings 10000         \
        -demote_globals "off"                 -demote_globals_max_fanout 12            -promote_globals "off"              \
        -promote_globals_min_fanout 200       -promote_globals_max_limit 0             -localclock_max_shared_instances 12 \
	-localclock_buffer_tree_max_fanout 12 -combine_register "off"                  -delete_buffer_tree "off"           \
	-delete_buffer_tree_max_fanout 12     -report_high_fanout_nets_limit 10 

layout -timing_driven -place_incremental  "off"                \
                      -route_incremental  "off"                \
                      -mindel_repair      "on"                 \
                      -placer_high_effort "on"                 \
                      -seq_opt            "on" 


report -type "status" {./report_status.txt} 
report -type "timer"                 -format "TEXT" -analysis "max" -print_summary "yes"                     \
                                     -use_slack_threshold "no" -print_paths "yes" -max_paths 5               \
                                     -max_expanded_paths 1 -include_user_sets "no" -include_pin_to_pin "yes" \
                                     -include_clock_domains "yes" -select_clock_domains "no"                 \
                                     "./report_timing_max.txt"
report -type "timing_violations"     -format "TEXT" -analysis "max" -use_slack_threshold "yes"               \
                                     -slack_threshold 0.00 -limit_max_paths "yes" -max_paths 100             \
                                     -max_expanded_paths 0                                                   \
                                     "./report_timing_violations_max.txt"
report -type "bottleneck"            -format "TEXT" -analysis "max" -slack_threshold 0.00                    \
                                     -max_parallel_paths 1 -max_paths 100 -max_instances 10                  \
                                     -cost_type "path_count"                                                 \
                                     "./report_bottleneck_max.txt"
report -type "datasheet"             -format "TEXT"                                                          \
                                     "./reports_datasheet.txt"
report -type "constraints_coverage"  "./reports_constraints_coverage.txt"
report -type "combinational_loops"   "./reports_combinational_loops.txt"
report -type "pin"                   -listby "name"                                                          \
                                     "./reports_pin.txt"
report -type "flipflop"              "./reports_flipflop.txt"
report -type "ccc_configuration"     "./reports_ccc_configuration.txt"
report -type "globalnet"             "./reports_globalnet.txt"
report -type "globalusage"           "./reports_globalusage.txt"
export -format "log" -diagnostic     "./libero_designer.log"


export -format "pdb " -feature "prog_fpga" "./fpga_bitstream.pdb"

save_design "./libero_designer.adb"
