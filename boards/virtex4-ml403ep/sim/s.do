vsim -L /opt/Xilinx/10.1/modelsim/verilog/unisims -novopt -t ps work.testbench work.glbl
add wave -label clk100 /testbench/clk
add wave -label clk /testbench/kotku/clk
add wave -label rst /testbench/kotku/rst
add wave -label pc -radix hexadecimal /testbench/kotku/zet_proc/fetch0/pc
add wave -divider fetch
add wave -label state -radix hexadecimal /testbench/kotku/zet_proc/fetch0/state
add wave -label next_state -radix hexadecimal /testbench/kotku/zet_proc/fetch0/next_state
add wave -label opcode -radix hexadecimal /testbench/kotku/zet_proc/fetch0/opcode
add wave -label modrm -radix hexadecimal /testbench/kotku/zet_proc/fetch0/modrm
add wave -label seq_addr /testbench/kotku/zet_proc/fetch0/decode0/seq_addr
add wave -label end_seq /testbench/kotku/zet_proc/fetch0/end_seq
add wave -label need_modrm /testbench/kotku/zet_proc/fetch0/need_modrm
add wave -label need_off /testbench/kotku/zet_proc/fetch0/need_off
add wave -label need_imm /testbench/kotku/zet_proc/fetch0/need_imm
add wave -label ir /testbench/kotku/zet_proc/fetch0/ir
add wave -label imm -radix hexadecimal /testbench/kotku/zet_proc/fetch0/imm
add wave -label off -radix hexadecimal /testbench/kotku/zet_proc/fetch0/off
add wave -divider mem
add wave -label cs -radix hexadecimal /testbench/kotku/zet_proc/wm0/cs
add wave -label op -radix hexadecimal /testbench/kotku/zet_proc/wm0/op
add wave -label block /testbench/kotku/zet_proc/wm0/cpu_block
add wave -label dat_o -radix hexadecimal sim:/testbench/kotku/dat_o
add wave -label dat_i -radix hexadecimal sim:/testbench/kotku/dat_i
add wave -label adr -radix hexadecimal /testbench/kotku/adr
add wave -label byte_o -radix hexadecimal /testbench/kotku/zet_proc/wm0/cpu_byte_o
add wave -label sel_o -radix hexadecimal /testbench/kotku/zet_proc/wm0/wb_sel_o
add wave -label stb_o -radix hexadecimal /testbench/kotku/zet_proc/wm0/wb_stb_o
add wave -label cyc_o -radix hexadecimal /testbench/kotku/zet_proc/wm0/wb_cyc_o
add wave -label ack_i -radix hexadecimal /testbench/kotku/zet_proc/wm0/wb_ack_i
add wave -label we_o -radix hexadecimal /testbench/kotku/zet_proc/wm0/wb_we_o
add wave -label tga_o -radix hexadecimal /testbench/kotku/zet_proc/wm0/wb_tga_o
add wave -label cpu_dat_i -radix hexadecimal /testbench/kotku/zet_proc/wm0/cpu_dat_i
add wave -divider alu
add wave -label x -radix hexadecimal /testbench/kotku/zet_proc/exec0/a
add wave -label y -radix hexadecimal /testbench/kotku/zet_proc/exec0/bus_b
add wave -label t -radix hexadecimal /testbench/kotku/zet_proc/exec0/alu0/t
add wave -label func -radix hexadecimal /testbench/kotku/zet_proc/exec0/alu0/func
add wave -label r\[1\] -radix hexadecimal /testbench/kotku/zet_proc/exec0/reg0/r\[1\]
add wave -label d -radix hexadecimal /testbench/kotku/zet_proc/exec0/reg0/d
add wave -label addr_a /testbench/kotku/zet_proc/exec0/reg0/addr_a
add wave -label addr_d /testbench/kotku/zet_proc/exec0/reg0/addr_d
add wave -label wr /testbench/kotku/zet_proc/exec0/reg0/wr
add wave -label we /testbench/kotku/we
add wave -label ack /testbench/kotku/ack
add wave -label fetch_or_exec /testbench/kotku/zet_proc/fetch_or_exec
add memory /testbench/zbt/mem
run 3ms
