create_project -force ha1588 . -part xc7z020clg484-1
set_property board zc702 [current_project]

add_files -norecurse ha1588.ucf
add_files -norecurse ./ip/define.h
set_property is_global_include true [get_files  ./ip/define.h]
add_files -norecurse ./ip/dcfifo_128b_16.ngc
add_files -norecurse ./ip/dcfifo_128b_16.v
add_files -norecurse ../../rtl/top/ha1588.v
add_files -norecurse ../../rtl/reg/reg.v
add_files -norecurse ../../rtl/rtc/rtc.v
add_files -norecurse ../../rtl/tsu/tsu.v
add_files -norecurse ../../rtl/tsu/ptp_parser.v
add_files -norecurse ../../rtl/tsu/ptp_queue.v

reset_run synth_1
reset_run impl_1

#launch_runs synth_1 -jobs 1
#wait_on_run synth_1

#launch_runs impl_1 -jobs 1
#wait_on_run impl_1

