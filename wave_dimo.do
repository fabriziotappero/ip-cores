onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /processor_tb/clk
add wave -noupdate -format Logic /processor_tb/nreset
add wave -noupdate -format Logic /processor_tb/one_step
add wave -noupdate -format Logic /processor_tb/go_step
add wave -noupdate -format Logic /processor_tb/zflag
add wave -noupdate -format Logic /processor_tb/cflag
add wave -noupdate -format Literal /processor_tb/a
add wave -noupdate -format Literal /processor_tb/b
add wave -noupdate -format Logic /processor_tb/datmem_nrd
add wave -noupdate -format Logic /processor_tb/datmem_nwr
add wave -noupdate -format Literal /processor_tb/datmem_adr
add wave -noupdate -format Literal /processor_tb/datmem_data_in
add wave -noupdate -format Literal /processor_tb/datmem_data_out
add wave -noupdate -format Literal /processor_tb/prog_adr
add wave -noupdate -format Literal /processor_tb/prog_data
add wave -noupdate -format Literal /processor_tb/u_cpu/prog_adr
add wave -noupdate -format Literal /processor_tb/u_cpu/prog_data
add wave -noupdate -format Literal /processor_tb/u_cpu/datmem_data_in
add wave -noupdate -format Literal /processor_tb/u_cpu/datmem_data_out
add wave -noupdate -format Logic /processor_tb/u_cpu/datmem_nrd
add wave -noupdate -format Logic /processor_tb/u_cpu/datmem_nwr
add wave -noupdate -format Literal /processor_tb/u_cpu/datmem_adr
add wave -noupdate -format Literal /processor_tb/u_cpu/a
add wave -noupdate -format Literal /processor_tb/u_cpu/b
add wave -noupdate -format Logic /processor_tb/u_cpu/cflag
add wave -noupdate -format Logic /processor_tb/u_cpu/zflag
add wave -noupdate -format Logic /processor_tb/u_cpu/clk
add wave -noupdate -format Logic /processor_tb/u_cpu/nreset
add wave -noupdate -format Logic /processor_tb/u_cpu/nreset_int
add wave -noupdate -format Logic /processor_tb/u_cpu/go_step
add wave -noupdate -format Logic /processor_tb/u_cpu/one_step
add wave -noupdate -format Logic /processor_tb/u_cpu/carry_reg_alu
add wave -noupdate -format Logic /processor_tb/u_cpu/zero_reg_alu
add wave -noupdate -format Logic /processor_tb/u_cpu/rst_int
add wave -noupdate -format Logic /processor_tb/u_cpu/carry_alu_reg
add wave -noupdate -format Logic /processor_tb/u_cpu/zero_alu_reg
add wave -noupdate -format Literal /processor_tb/u_cpu/a_reg_alu
add wave -noupdate -format Literal /processor_tb/u_cpu/b_reg_alu
add wave -noupdate -format Literal /processor_tb/u_cpu/result_alu_reg
add wave -noupdate -format Literal /processor_tb/u_cpu/control_int
add wave -noupdate -format Literal /processor_tb/u_ram/addr
add wave -noupdate -format Literal /processor_tb/u_ram/data_in
add wave -noupdate -format Literal /processor_tb/u_ram/data_out
add wave -noupdate -format Logic /processor_tb/u_ram/ce_nwr
add wave -noupdate -format Logic /processor_tb/u_ram/ce_nrd
add wave -noupdate -format Literal /processor_tb/u_ram/memory
add wave -noupdate -format Literal /processor_tb/u_rom/addr
add wave -noupdate -format Literal /processor_tb/u_rom/data
add wave -noupdate -format Literal /processor_tb/u_rom/memory
add wave -noupdate -format Literal /processor_tb/u_rom/rom_init/data
add wave -noupdate -format Literal /processor_tb/u_rom/rom_init/index
add wave -noupdate -format Literal /processor_tb/u_cpu/pc_i/pc_p/pc_int
add wave -noupdate -format Literal /processor_tb/u_cpu/alu_i/alu_p/result_int
add wave -noupdate -format Literal /processor_tb/u_cpu/alu_i/alu_p/add_result_int
add wave -noupdate -format Literal /processor_tb/u_cpu/alu_i/alu_p/a_add_int
add wave -noupdate -format Literal /processor_tb/u_cpu/alu_i/alu_p/b_add_int
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {45 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ns} {841050 ns}
