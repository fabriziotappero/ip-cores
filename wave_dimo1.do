onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -label clk /processor_tb/clk
add wave -noupdate -format Literal -label control /processor_tb/u_cpu/control_int
add wave -noupdate -format Logic -label nrd /processor_tb/datmem_nrd
add wave -noupdate -format Logic -label nwr /processor_tb/datmem_nwr
add wave -noupdate -format Literal -label ram_addr -radix unsigned /processor_tb/datmem_adr
add wave -noupdate -format Literal -label rom_data -radix unsigned /processor_tb/prog_data
add wave -noupdate -format Literal -label rom_addr -radix unsigned /processor_tb/prog_adr
add wave -noupdate -format Literal -label a -radix unsigned /processor_tb/u_cpu/a_reg_alu
add wave -noupdate -format Literal -label b -radix unsigned /processor_tb/u_cpu/b_reg_alu
add wave -noupdate -format Literal -label d_from_ram -radix unsigned /processor_tb/datmem_data_in
add wave -noupdate -format Literal -label d_to_ram -radix unsigned /processor_tb/datmem_data_out
add wave -noupdate -format Literal -label pr_state /processor_tb/u_cpu/control_i/pr_state
add wave -noupdate -format Literal -label nxt_state /processor_tb/u_cpu/control_i/nxt_state
add wave -noupdate -format Logic -label carry /processor_tb/u_cpu/carry_reg_alu
add wave -noupdate -format Logic -label zero /processor_tb/u_cpu/zero_reg_alu
add wave -noupdate -format Logic -label carry_new /processor_tb/u_cpu/carry_alu_reg
add wave -noupdate -format Logic -label zero_new /processor_tb/u_cpu/zero_alu_reg
add wave -noupdate -format Literal -label result -radix unsigned /processor_tb/u_cpu/result_alu_reg
add wave -noupdate -format Literal -label result_var -radix unsigned /processor_tb/u_cpu/alu_i/alu_p/result_int
add wave -noupdate -format Literal -label PC -radix unsigned /processor_tb/u_cpu/pc_i/pc_p/pc_int
add wave -noupdate -format Literal -label RAM -radix unsigned /processor_tb/u_ram/memory
add wave -noupdate -format Literal -label ROM -radix unsigned /processor_tb/u_rom/memory
add wave -noupdate -format Logic -label rst /processor_tb/u_cpu/rst_int
add wave -noupdate -format Literal -label add_result -radix unsigned /processor_tb/u_cpu/alu_i/alu_p/add_result_int
add wave -noupdate -format Literal -label a_add -radix unsigned /processor_tb/u_cpu/alu_i/alu_p/a_add_int
add wave -noupdate -format Literal -label b_add -radix unsigned /processor_tb/u_cpu/alu_i/alu_p/b_add_int
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {200000 ns} 1} {{Cursor 2} {572000 ns} 1} {{Cursor 3} {551000 ns} 1}
configure wave -namecolwidth 131
configure wave -valuecolwidth 79
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {545708 ns} {558822 ns}
