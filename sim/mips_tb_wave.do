onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /mips_tb/clk
add wave -noupdate -format Logic /mips_tb/reset
add wave -noupdate -color Gold -format Literal -radix hexadecimal /mips_tb/mpu/cpu/p1_ir_reg
add wave -noupdate -divider Debug
add wave -noupdate -format Literal -radix hexadecimal /mips_tb/log_info
add wave -noupdate -color Gold -format Literal -radix hexadecimal /mips_tb/log_info.debug
add wave -noupdate -format Logic -radix hexadecimal /mips_tb/log_info.code_rd_vma
add wave -noupdate -format Logic -radix hexadecimal /mips_tb/log_info.write_pending
add wave -noupdate -color {Light Blue} -format Literal -radix hexadecimal /mips_tb/log_info.pending_data_wr_addr
add wave -noupdate -color {Light Blue} -format Literal -radix hexadecimal /mips_tb/log_info.pending_data_wr_pc
add wave -noupdate -color {Light Blue} -format Literal -radix hexadecimal /mips_tb/log_info.pending_data_wr
add wave -noupdate -color {Light Blue} -format Literal -radix binary /mips_tb/log_info.pending_data_wr_we
add wave -noupdate -divider Cache
add wave -noupdate -format Logic /mips_tb/mpu/cache/cache_enable
add wave -noupdate -color Pink -format Literal /mips_tb/mpu/cache/ps
add wave -noupdate -format Literal -radix hexadecimal /mips_tb/mpu/cache/data_wr_reg
add wave -noupdate -format Literal -radix hexadecimal /mips_tb/mpu/cache/data_wr_addr_reg
add wave -noupdate -expand -group SRAM
add wave -noupdate -group SRAM -format Literal -radix hexadecimal /mips_tb/sram_chip_addr
add wave -noupdate -group SRAM -format Literal -radix hexadecimal /mips_tb/mpu_sram_data_wr
add wave -noupdate -group SRAM -format Literal /mips_tb/mpu_sram_byte_we_n
add wave -noupdate -group SRAM -format Literal -radix hexadecimal /mips_tb/mpu_sram_address
add wave -noupdate -group SRAM -format Logic /mips_tb/mpu_sram_oe_n
add wave -noupdate -group I-Cache
add wave -noupdate -group I-Cache -format Literal /mips_tb/mpu/cache/code_refill_ctr
add wave -noupdate -group I-Cache -format Logic /mips_tb/mpu/cache/code_wait
add wave -noupdate -group I-Cache -color Orange -format Logic /mips_tb/mpu/cache/code_miss
add wave -noupdate -group I-Cache -format Literal -radix hexadecimal /mips_tb/mpu/cache/code_rd_addr_reg
add wave -noupdate -format Literal -radix hexadecimal /mips_tb/mpu/cache/bram_rd_addr
add wave -noupdate -format Literal -radix hexadecimal /mips_tb/mpu/cache/bram_rd_data
add wave -noupdate -group D-Cache
add wave -noupdate -group D-Cache -format Literal -radix unsigned /mips_tb/mpu/cache/data_line_addr
add wave -noupdate -group D-Cache -format Literal /mips_tb/mpu/cache/data_refill_ctr
add wave -noupdate -group D-Cache -format Literal -radix hexadecimal /mips_tb/mpu/cache/data_refill_data
add wave -noupdate -group D-Cache -format Logic /mips_tb/mpu/cache/data_miss
add wave -noupdate -group D-Cache -format Logic /mips_tb/mpu/cache/data_miss_cached
add wave -noupdate -group D-Cache -format Logic /mips_tb/mpu/cache/data_miss_uncached
add wave -noupdate -group D-Cache -format Logic /mips_tb/mpu/cache/data_wait
add wave -noupdate -group D-Cache -color {Forest Green} -format Logic /mips_tb/mpu/cache/read_pending
add wave -noupdate -group D-Cache -color Khaki -format Logic /mips_tb/mpu/cache/write_pending
add wave -noupdate -group STALL
add wave -noupdate -group STALL -format Logic /mips_tb/mpu/cpu/stalled_interlock
add wave -noupdate -group STALL -format Logic /mips_tb/mpu/cpu/stalled_memwait
add wave -noupdate -group STALL -format Logic /mips_tb/mpu/cpu/stalled_muldiv
add wave -noupdate -group DRAM
add wave -noupdate -group DRAM -color Tan -format Literal /mips_tb/mpu/cache/byte_we
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {332910000 ps} 0} {{Cursor 4} {333210000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 64
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
update
WaveRestoreZoom {0 ps} {2940094500 ps}
