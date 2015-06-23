#
#	File import script for the PCIe DMA core hdl project
#
#	

#Script Configuration

set proj_name pcie_dma_top
# Set the supportfiles directory path
set scriptdir [pwd]
set proj_dir $scriptdir/../../

#Close currently open project and create a new one. (OVERWRITES PROJECT!!)
close_project -quiet

create_project -force -part xc7vx690tffg1761-2 $proj_name $proj_dir/Projects/$proj_name

set_property target_language VHDL [current_project]
set_property default_lib work [current_project]

# ----------------------------------------------------------
# PCIe DMA top module
# ----------------------------------------------------------
read_vhdl -library work $proj_dir/sources/shared/virtex7_dma_top.vhd
# ----------------------------------------------------------
# packages
# ----------------------------------------------------------
read_vhdl -library work $proj_dir/sources/packages/pcie_package.vhd

# ----------------------------------------------------------
# dma sources
# ----------------------------------------------------------

read_vhdl -library work $proj_dir/sources/pcie/DMA_Core.vhd
read_vhdl -library work $proj_dir/sources/pcie/dma_read_write.vhd
read_vhdl -library work $proj_dir/sources/pcie/intr_ctrl.vhd
read_vhdl -library work $proj_dir/sources/pcie/pcie_dma_wrap.vhd
read_vhdl -library work $proj_dir/sources/pcie/pcie_ep_wrap.vhd
read_vhdl -library work $proj_dir/sources/pcie/pcie_init.vhd
read_vhdl -library work $proj_dir/sources/pcie/dma_control.vhd
read_vhdl -library work $proj_dir/sources/pcie/pcie_clocking.vhd
read_vhdl -library work $proj_dir/sources/pcie/pcie_slow_clock.vhd

import_ip $proj_dir/sources/pcie/pcie_x8_gen3_3_0.xci
import_ip $proj_dir/sources/pcie/clk_wiz_40.xci

# ----------------------------------------------------------
# example application
# ----------------------------------------------------------

read_vhdl -library work $proj_dir/sources/application/application.vhd
import_ip $proj_dir/sources/application/fifo_256x256.xci

upgrade_ip [get_ips  {pcie_x8_gen3_3_0 cache_fifo clk_wiz_40 fifo_256x256}]

read_xdc -verbose $proj_dir/constraints/pcie_dma_top_VC709.xdc
read_xdc -verbose $proj_dir/constraints/pcie_dma_top_HTG710.xdc
close [ open $proj_dir/constraints/probes.xdc w ]
read_xdc -verbose $proj_dir/constraints/probes.xdc
set_property target_constrs_file $proj_dir/constraints/probes.xdc [current_fileset -constrset]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE MoreGlobalIterations [get_runs impl_1]

set_property top virtex7_dma_top [current_fileset]

puts "INFO: Done!"







