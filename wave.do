onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix decimal /processor_tb/u_cpu/prog_adr
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
add wave -noupdate -format Logic /processor_tb/u_cpu/go_step
add wave -noupdate -format Logic /processor_tb/u_cpu/one_step
add wave -noupdate -format Logic /processor_tb/u_cpu/rst
add wave -noupdate -format Literal /processor_tb/u_ram/addr
add wave -noupdate -format Literal /processor_tb/u_ram/data_in
add wave -noupdate -format Literal /processor_tb/u_ram/data_out
add wave -noupdate -format Logic /processor_tb/u_ram/ce_nwr
add wave -noupdate -format Logic /processor_tb/u_ram/ce_nrd
add wave -noupdate -format Literal /processor_tb/u_ram/memory
add wave -noupdate -format Literal /processor_tb/u_rom/addr
add wave -noupdate -format Literal /processor_tb/u_rom/data
add wave -noupdate -format Literal /processor_tb/u_rom/memory
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {529000 ns} 1} {{Cursor 2} {200000 ns} 1}
configure wave -namecolwidth 211
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
WaveRestoreZoom {526130 ns} {537616 ns}
