set process "5"
set part "2s200pq208"
set tristate_map "FALSE"
set opt_auto_mode "TRUE"
set opt_best_result "29223.458000"
set dont_lock_lcells "auto"
set input2output "20.000000"
set input2register "20.000000"
set register2output "20.000000"
set register2register "20.000000"
set wire_table "xis215-5_avg"
set encoding "auto"
set edifin_ground_port_names "GND"
set edifin_power_port_names "VCC"
set edif_array_range_extraction_style "%s\[%d:%d\]"

set_xilinx_eqn

load_library xis2

read -technology xis2 {
../../../rtl/vhdl/AX_Pack.vhd
../../../rtl/vhdl/AX_DPRAM.vhd
../../../rtl/vhdl/AX_Reg.vhd
../../../rtl/vhdl/AX_ALU.vhd
../../../rtl/vhdl/AX_PCS.vhd
../../../rtl/vhdl/AX8.vhd
../../../rtl/vhdl/AX_Port.vhd
../../../rtl/vhdl/AX_TC8.vhd
../src/ROM1200_Echo_leo.vhd
../../../rtl/vhdl/A90S1200.vhd
}

pre_optimize

optimize -hierarchy=auto

optimize_timing

report_area

report_delay

write a90s1200_leo.edf
