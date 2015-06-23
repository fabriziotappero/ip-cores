create_project -force up_monitor . -part xc7z020clg484-1
set_property board zc702 [current_project]

add_files -norecurse ./vendor.h
add_files -norecurse ../../rtl/up_monitor_wrapper.v
add_files -norecurse ../../rtl/up_monitor.v
add_files -norecurse ../../rtl/xilinx/chipscope_vio_adda_fifo.v
add_files -norecurse ../../rtl/xilinx/chipscope_vio_adda_trig.v
add_files -norecurse ../../rtl/xilinx/chipscope_vio_addr_mask.v
add_files -norecurse ../../rtl/xilinx/coregen/chipscope_icon.ngc
add_files -norecurse ../../rtl/xilinx/coregen/chipscope_icon.v
add_files -norecurse ../../rtl/xilinx/coregen/scfifo.ngc
add_files -norecurse ../../rtl/xilinx/coregen/scfifo.v
add_files -norecurse ../../rtl/xilinx/coregen/chipscope_vio_fifo.ngc
add_files -norecurse ../../rtl/xilinx/coregen/chipscope_vio_fifo.v
add_files -norecurse ../../rtl/xilinx/coregen/chipscope_vio_mask.ngc
add_files -norecurse ../../rtl/xilinx/coregen/chipscope_vio_mask.v
add_files -norecurse ../../rtl/xilinx/coregen/chipscope_vio_trig.ngc
add_files -norecurse ../../rtl/xilinx/coregen/chipscope_vio_trig.v
set_property is_global_include true [get_files ./vendor.h]
set_property top up_monitor_wrapper [current_fileset]
set_property top_file ../../rtl/up_monitor_wrapper.v [current_fileset]

reset_run synth_1
reset_run impl_1

launch_runs synth_1 -jobs 1
wait_on_run synth_1

launch_runs impl_1 -jobs 1
wait_on_run impl_1

#launch_runs impl_1 -to_step Bitgen
#wait_on_run impl_1

