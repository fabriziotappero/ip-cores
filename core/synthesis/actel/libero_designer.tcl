

new_design -name "design_fpga" -family "<DEVICE_FAMILY>" -path {.} -block "off" 

set_device -die     "<DEVICE_NAME>" \
           -package "484 FBGA" \
		   -speed   "<SPEED_GRADE>" 

import_source -format "edif" -edif_flavor "GENERIC" {./rev_1/design_files.edn} \
              -format "sdc"  -scenario "Primary"    {../design_files.sdc}      \
			  -merge_physical "no" -merge_timing "yes" 

compile -pdc_abort_on_error "on"              -pdc_eco_display_unmatched_objects "off" -pdc_eco_max_warnings 10000         \
        -demote_globals "off"                 -demote_globals_max_fanout 12            -promote_globals "off"              \
  	    -promote_globals_min_fanout 200       -promote_globals_max_limit  0            -localclock_max_shared_instances 12 \
	    -localclock_buffer_tree_max_fanout 12 -combine_register "off"                  -delete_buffer_tree "off"           \
	    -delete_buffer_tree_max_fanout 12     -report_high_fanout_nets_limit 10 

layout -timing_driven -placer_high_effort "on" -seq_opt "on" 

report -type "timer"             -format "TEXT"            -analysis "max"            -print_summary "yes"   \
       -use_slack_threshold "no" -print_paths "yes"        -max_paths 5               -max_expanded_paths 1  \
	   -include_user_sets "no"   -include_pin_to_pin "yes" -select_clock_domains "no"                        \
      {./report_timing_max.txt} 

report -type "status" \
      {./report_status.txt} 


