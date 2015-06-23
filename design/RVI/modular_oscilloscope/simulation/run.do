quietly set ACTELLIBNAME proasic3e
quietly set PROJECT_DIR "D:/Facu/TFuni2/test_modular_oscilloscope"

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   vlib presynth
}
vmap presynth presynth
vmap proasic3e "C:/Actel/Libero_v8.5/Designer/lib/modelsim/precompiled/vhdl/proasic3e"

vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/daq/daq.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/memory/A3PE1500/dual_port_memory.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/memory/dual_port_memory_wb.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/smartgen/A3PE_pll_2clk/A3PE_pll_2clk.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/epp/eppwbn_ctrl.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/epp/eppwbn_epp_side.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/epp/eppwbn_wbn_side.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/epp/eppwbn_pkg.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/epp/eppwbn.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/epp/eppwbn_width_extension.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/epp/eppwbn_16bit.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/ctrl/output_manager.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/ctrl/generic_counter.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/ctrl/ctrl_pkg.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/ctrl/memory_writer.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/ctrl/generic_decoder.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/ctrl/data_skipper.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/ctrl/channel_selector.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/ctrl/trigger_manager.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/ctrl/address_allocation.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/ctrl/ctrl.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/daq/daq_pkg.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/memory/memory_pkg.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/modular_oscilloscope.vhd"
vcom -93 -explicit -work presynth "${PROJECT_DIR}/../modular_oscilloscope/hdl/tbench/modullar_oscilloscope_tbench_text.vhd"

vsim -L proasic3e -L presynth  -t 1ps presynth.testbench
add wave /testbench/*
run -all
