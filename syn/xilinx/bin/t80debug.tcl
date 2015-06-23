set process "5"
set part "2s200pq208"
set tristate_map "TRUE"
set opt_auto_mode "TRUE"
set opt_best_result "29223.458000"
set dont_lock_lcells "auto"
set input2output "30.000000"
set input2register "20.000000"
set register2output "20.000000"
set register2register "40.000000"
set wire_table "xis215-5_avg"
set encoding "auto"
set edifin_ground_port_names "GND"
set edifin_power_port_names "VCC"
set edif_array_range_extraction_style "%s\[%d:%d\]"

set_xilinx_eqn

load_library xis2

read -technology xis2 {
../../../rtl/vhdl/T80_Pack.vhd
../../../rtl/vhdl/T80_MCode.vhd
../../../rtl/vhdl/T80_ALU.vhd
../../../rtl/vhdl/T80_RegX.vhd
../../../rtl/vhdl/T80.vhd
../../../rtl/vhdl/T80s.vhd
../../../rtl/vhdl/T16450.vhd
../src/MonZ80_leo.vhd
../../../rtl/vhdl/SSRAMX.vhd
../../../rtl/vhdl/DebugSystem.vhd
}

pre_optimize

optimize -hierarchy=auto

optimize_timing

report_area

report_delay

write t80debug_leo.edf
