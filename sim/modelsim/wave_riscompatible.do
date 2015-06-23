onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Basic Signals}
add wave -noupdate -format Logic /riscompatible_tb/reset_w
add wave -noupdate -format Logic /riscompatible_tb/clk_w
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/int_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/intmask_v
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/interruptenable_w
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/intack_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/intack_v
add wave -noupdate -divider GPIO
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/outputports_o
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/inputports_i
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_gpio/outputdata_o
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/mspc_outputdata_w
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/dmem_address_w
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_gpio/outputports_o
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_gpio/inputports_i
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_gpio/address_i
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_cy_o_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_ng_o_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_ov_o_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_zr_o_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_function_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/aps_v
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/psw_data_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/psw_wen_o
add wave -noupdate -format Literal -label PSW -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/psw1/data_o
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/phase_v
add wave -noupdate -format Literal -label PC -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/pc1/data_o
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/pc_data_i
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/pmem_outputdata_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/pmem_address_w
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_data_memory/outputdata_o
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/t1_t0_v
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/c4_c0_v
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/f1_f0_ss2_v
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/dst_v
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/ft1_v
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/ft2_v
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/condition_v
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/enable_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/write_i
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/phase_v
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/regbnk_register1_o
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/regbnk_register2_o
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/register1_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/register2_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/ft1outputdata_o
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/ft2outputdata_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/rda_wen_o
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/rua_data_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/rdb_wen_o
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/rub_data_o
add wave -noupdate -format Literal -label RUA -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/rua1/data_o
add wave -noupdate -format Literal -label RUB -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/rub1/data_o
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/pc_data_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/pc_wen_o
add wave -noupdate -divider ULA
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/source1_i
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/source2_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/function_i
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/output_o
add wave -noupdate -divider UD
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/inputdata_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/shiftamount_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/function_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/outputdata_o
add wave -noupdate -divider DMEM
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/dmem_address_w
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_data_memory/address_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_data_memory/inputdata_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_data_memory/outputdata_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_data_memory/write_i
add wave -noupdate -divider RegBank
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/register1_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/register2_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/registerw_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/inputdata_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/write_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/enable_i
add wave -noupdate -divider Debug
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/phase_v
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/pmem_address_o
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/pmem_outputdata_i
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/t1_t0_v
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/c4_c0_v
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/f1_f0_ss2_v
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/ft1_v
add wave -noupdate -format Literal -radix decimal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/kp_v
add wave -noupdate -format Literal -radix decimal /riscompatible_tb/riscompatible1/u_riscompatible_core/regbkn_ft1_outputdatai_w
add wave -noupdate -format Literal -radix decimal /riscompatible_tb/riscompatible1/u_riscompatible_core/regbkn_ft2_outputdatai_w
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_cy_o_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_ng_o_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_ov_o_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_zr_o_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/condition_v
add wave -noupdate -divider Controle
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/dmem_write_o
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/dmem_address_w
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/dmem_inputdata_o
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/dmem_outputdata_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/pmem_address_o
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_program_memory/outputdata_o
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/phase_v
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/t1_t0_v
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/c4_c0_v
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/f1_f0_ss2_v
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/ft1_v
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/ft2_v
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/kp_v
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/dst_v
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_function_o
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/ula_output_i
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/psw_data_o
add wave -noupdate -format Literal -label RUA.data_o -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/rua_w.data_o
add wave -noupdate -format Literal -label RUB.data_o -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/rub_w.data_o
add wave -noupdate -format Literal -label data_o -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/pc_w.data_o
add wave -noupdate -divider RegisterBank
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/register1_i
add wave -noupdate -format Literal -radix unsigned /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/register2_i
add wave -noupdate -format Literal -radix hexadecimal -expand /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/memory
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/ft1outputdata_o
add wave -noupdate -format Literal -radix hexadecimal /riscompatible_tb/riscompatible1/u_riscompatible_core/registerbank1/ft2outputdata_o
add wave -noupdate -divider {Registers & Flags}
add wave -noupdate -format Literal -expand /riscompatible_tb/riscompatible1/u_riscompatible_core/psw_w
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/rda_w
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/rdb_w
add wave -noupdate -format Literal -expand /riscompatible_tb/riscompatible1/u_riscompatible_core/rua_w
add wave -noupdate -format Literal -expand /riscompatible_tb/riscompatible1/u_riscompatible_core/rub_w
add wave -noupdate -format Literal -radix unsigned -expand /riscompatible_tb/riscompatible1/u_riscompatible_core/pc_w
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/selectandcontrol1/p_select_and_control/phase_v
add wave -noupdate -divider Memories
add wave -noupdate -format Literal -label {Program Memory} -radix hexadecimal /riscompatible_tb/riscompatible1/u_program_memory/memory
add wave -noupdate -format Literal -label {Data Memory} -radix hexadecimal -expand /riscompatible_tb/riscompatible1/u_data_memory/memory
add wave -noupdate -divider ULA
add wave -noupdate -format Literal -radix decimal /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/source1_i
add wave -noupdate -format Literal -radix decimal /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/source2_i
add wave -noupdate -format Literal -radix decimal /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/output_o
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/function_i
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/ng_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/zr_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/ov_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/cy_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/ula1/cy_i
add wave -noupdate -divider UD
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/outputdata_o
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/function_i
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/outputdata_w
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/cy_o
add wave -noupdate -format Logic /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/cy_i
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/shiftamount_i
add wave -noupdate -format Literal /riscompatible_tb/riscompatible1/u_riscompatible_core/ud1/inputdata_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{R8 = R2 and R3} {1120 ns} 1} {{Cursor 8} {1460 ns} 1} {{Cursor 3} {1534 ns} 0}
configure wave -namecolwidth 197
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1319 ns} {1721 ns}
