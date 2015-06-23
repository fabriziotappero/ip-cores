onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group {CLOCK & RESET} -divider Reset
add wave -noupdate -group {CLOCK & RESET} -format Literal /versatile_mem_ctrl_tb/dut/wb_rst
add wave -noupdate -group {CLOCK & RESET} -divider Clocks
add wave -noupdate -group {CLOCK & RESET} -format Literal /versatile_mem_ctrl_tb/dut/wb_clk
add wave -noupdate -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk
add wave -noupdate -group {CLOCK & RESET} -divider {DCM/PLL generated clocks}
add wave -noupdate -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_0
add wave -noupdate -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_90
add wave -noupdate -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_180
add wave -noupdate -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_270
add wave -noupdate -group DCM/PLL -divider {Xilinx DCM or Altera altpll}
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/rst
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clk_in
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clkfb_in
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clk0_out
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clk90_out
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clk180_out
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clk270_out
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clkfb_out
add wave -noupdate -group {WISHBONE IF} -divider {Clock & reset}
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wb_rst
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wb_clk
add wave -noupdate -group {WISHBONE IF} -divider <NULL>
add wave -noupdate -group {WISHBONE IF} -expand -group wb0 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_dat_i_0
add wave -noupdate -group {WISHBONE IF} -expand -group wb0 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_adr_i_0
add wave -noupdate -group {WISHBONE IF} -expand -group wb0 -format Literal /versatile_mem_ctrl_tb/dut/wb_stb_i_0
add wave -noupdate -group {WISHBONE IF} -expand -group wb0 -format Literal /versatile_mem_ctrl_tb/dut/wb_cyc_i_0
add wave -noupdate -group {WISHBONE IF} -expand -group wb0 -format Literal -expand /versatile_mem_ctrl_tb/dut/wb_ack_o_0
add wave -noupdate -group {WISHBONE IF} -expand -group wb0 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_dat_o_0
add wave -noupdate -group {WISHBONE IF} -expand -group wb0 -divider <NULL>
add wave -noupdate -group {WISHBONE IF} -expand -group wb1 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_dat_i_1
add wave -noupdate -group {WISHBONE IF} -expand -group wb1 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_adr_i_1
add wave -noupdate -group {WISHBONE IF} -expand -group wb1 -format Literal /versatile_mem_ctrl_tb/dut/wb_stb_i_1
add wave -noupdate -group {WISHBONE IF} -expand -group wb1 -format Literal /versatile_mem_ctrl_tb/dut/wb_cyc_i_1
add wave -noupdate -group {WISHBONE IF} -expand -group wb1 -format Literal -expand /versatile_mem_ctrl_tb/dut/wb_ack_o_1
add wave -noupdate -group {WISHBONE IF} -expand -group wb1 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_dat_o_1
add wave -noupdate -group {WISHBONE IF} -expand -group wb1 -divider <NULL>
add wave -noupdate -group {WISHBONE IF} -group wb2 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_dat_i_2
add wave -noupdate -group {WISHBONE IF} -group wb2 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_adr_i_2
add wave -noupdate -group {WISHBONE IF} -group wb2 -format Literal /versatile_mem_ctrl_tb/dut/wb_stb_i_2
add wave -noupdate -group {WISHBONE IF} -group wb2 -format Literal /versatile_mem_ctrl_tb/dut/wb_cyc_i_2
add wave -noupdate -group {WISHBONE IF} -group wb2 -format Literal /versatile_mem_ctrl_tb/dut/wb_ack_o_2
add wave -noupdate -group {WISHBONE IF} -group wb2 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_dat_o_2
add wave -noupdate -group {WISHBONE IF} -group wb2 -divider <NULL>
add wave -noupdate -group {WISHBONE IF} -group wb3 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_dat_i_3
add wave -noupdate -group {WISHBONE IF} -group wb3 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_adr_i_3
add wave -noupdate -group {WISHBONE IF} -group wb3 -format Literal /versatile_mem_ctrl_tb/dut/wb_stb_i_3
add wave -noupdate -group {WISHBONE IF} -group wb3 -format Literal /versatile_mem_ctrl_tb/dut/wb_cyc_i_3
add wave -noupdate -group {WISHBONE IF} -group wb3 -format Literal /versatile_mem_ctrl_tb/dut/wb_ack_o_3
add wave -noupdate -group {WISHBONE IF} -group wb3 -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wb_dat_o_3
add wave -noupdate -group {WISHBONE IF} -group wb3 -divider <NULL>
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix ascii /versatile_mem_ctrl_tb/wb0i/statename
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/wb0_dat_i
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/wb0_adr_i
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/wb0_dat_o
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Logic /versatile_mem_ctrl_tb/wb0_ack_o
add wave -noupdate -group {WISHBONE IF} -group Testbench -divider <NULL>
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix ascii /versatile_mem_ctrl_tb/wb1i/statename
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/wb1_dat_i
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/wb1_adr_i
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/wb1_dat_o
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Logic /versatile_mem_ctrl_tb/wb1_ack_o
add wave -noupdate -group {WISHBONE IF} -group Testbench -divider <NULL>
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix ascii /versatile_mem_ctrl_tb/wb4i/statename
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/wb4_dat_i
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/wb4_adr_i
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/wb4_dat_o
add wave -noupdate -group {WISHBONE IF} -group Testbench -format Logic /versatile_mem_ctrl_tb/wb4_ack_o
add wave -noupdate -group {WISHBONE IF} -group Testbench -divider <NULL>
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[31]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[30]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[29]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[28]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[27]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[26]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[25]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[24]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[23]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[22]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[21]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[20]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[19]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[18]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[17]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -group FIFO_0_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[16]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[15]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[14]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[13]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[12]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[11]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[10]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[9]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[8]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[7]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[6]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[5]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[4]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[3]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[2]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[1]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 0} -expand -group FIFO_0_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/dpram/ram[0]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[31]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[30]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[29]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[28]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[27]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[26]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[25]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[24]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[23]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[22]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[21]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[20]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[19]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[18]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[17]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -group FIFO_1_1 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[16]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[15]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[14]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[13]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[12]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[11]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[10]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[9]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[8]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[7]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[6]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[5]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[4]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[3]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[2]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[1]}
add wave -noupdate -group {TX FIFO (Egress FIFO)} -expand -group {Tx FIFO 1} -expand -group FIFO_1_0 -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/dpram/ram[0]}
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/rst
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/clk
add wave -noupdate -group {MAIN STATE MACHINE} -divider State
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal -radix ascii /versatile_mem_ctrl_tb/dut/ddr_16_0/statename
add wave -noupdate -group {MAIN STATE MACHINE} -divider Input
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/bl_ack
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal /versatile_mem_ctrl_tb/dut/ddr_16_0/burst_adr
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/fifo_empty
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/fifo_re_d
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/next_row_open
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/ref_delay_ack
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/ref_req
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/stall
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic -radix hexadecimal {/versatile_mem_ctrl_tb/dut/ddr_16_0/tx_fifo_dat_o[5]}
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/ddr_16_0/tx_fifo_dat_o
add wave -noupdate -group {MAIN STATE MACHINE} -divider Output
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/ddr_16_0/a
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/adr_init
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/bl_en
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/close_cur_row
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal /versatile_mem_ctrl_tb/dut/ddr_16_0/cmd
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/cs_n
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/fifo_re
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal /versatile_mem_ctrl_tb/dut/ddr_16_0/open_ba
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/open_cur_row
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal /versatile_mem_ctrl_tb/dut/ddr_16_0/open_row
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/read
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/ref_ack
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/ref_delay
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/state_idle
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/write
add wave -noupdate -group {MAIN STATE MACHINE} -divider {Other usefull signals (Non-FSM)}
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal /versatile_mem_ctrl_tb/dut/fifo_sel_domain_reg
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/fifo_dat_o
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/state_idle
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/tx_fifo_re_i
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/tx_fifo_re
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/burst_mask
add wave -noupdate -group {BURST ADDRESS} -divider State
add wave -noupdate -group {BURST ADDRESS} -format Literal -radix ascii /versatile_mem_ctrl_tb/dut/ddr_16_0/statename
add wave -noupdate -group {BURST ADDRESS} -divider {Burst Address}
add wave -noupdate -group {BURST ADDRESS} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/rst
add wave -noupdate -group {BURST ADDRESS} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/clk
add wave -noupdate -group {BURST ADDRESS} -divider Input
add wave -noupdate -group {BURST ADDRESS} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/inc_adr0/adr_i
add wave -noupdate -group {BURST ADDRESS} -format Literal /versatile_mem_ctrl_tb/dut/inc_adr0/cti_i
add wave -noupdate -group {BURST ADDRESS} -format Literal /versatile_mem_ctrl_tb/dut/inc_adr0/bte_i
add wave -noupdate -group {BURST ADDRESS} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/init
add wave -noupdate -group {BURST ADDRESS} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/inc
add wave -noupdate -group {BURST ADDRESS} -divider Internal
add wave -noupdate -group {BURST ADDRESS} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/init_i
add wave -noupdate -group {BURST ADDRESS} -format Literal /versatile_mem_ctrl_tb/dut/inc_adr0/bte
add wave -noupdate -group {BURST ADDRESS} -format Literal /versatile_mem_ctrl_tb/dut/inc_adr0/cnt
add wave -noupdate -group {BURST ADDRESS} -divider Output
add wave -noupdate -group {BURST ADDRESS} -format Literal /versatile_mem_ctrl_tb/dut/inc_adr0/adr_o
add wave -noupdate -group {BURST ADDRESS} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/done
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -divider {Micron DDR2 SDRAM}
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal -radix ascii /versatile_mem_ctrl_tb/dut/ddr_16_0/statename
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/ck
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/ck_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/cke
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/cs_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/ras_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/cas_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/we_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal /versatile_mem_ctrl_tb/ddr2_sdram/ba
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/ddr2_sdram/addr
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/odt
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal /versatile_mem_ctrl_tb/ddr2_sdram/dm_rdqs
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/ddr2_sdram/dq
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal /versatile_mem_ctrl_tb/ddr2_sdram/dqs
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal /versatile_mem_ctrl_tb/ddr2_sdram/dqs_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal /versatile_mem_ctrl_tb/ddr2_sdram/rdqs_n
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -divider {Rx FIFO 0}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/d
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Logic /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/write
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Literal /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/write_enable
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Logic /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/clk1
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Logic /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/rst1
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Logic /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/read
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Literal /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/read_enable
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Logic /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/clk2
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Logic /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/rst2
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Literal /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/fifo_full
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/q
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -group {Fifo Control} -format Literal /versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/fifo_empty
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[31]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[30]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[29]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[28]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[27]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[26]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[25]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[24]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[23]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[22]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[21]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[20]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[19]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[18]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[17]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 0} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[16]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[15]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[14]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[13]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[12]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[11]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[10]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[9]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[8]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[7]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[6]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[5]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[4]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[3]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[2]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[1]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -expand -group {Fifo 0 1} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/genblk1/wb0/ingress_FIFO/dpram/ram[0]}
add wave -noupdate -group {RX FIFO (Ingress FIFO)} -divider {Rx FIFO 1}
add wave -noupdate -group {BURST LENGTH} -format Logic /versatile_mem_ctrl_tb/dut/burst_length_counter0/rst
add wave -noupdate -group {BURST LENGTH} -format Logic /versatile_mem_ctrl_tb/dut/burst_length_counter0/clk
add wave -noupdate -group {BURST LENGTH} -format Logic /versatile_mem_ctrl_tb/dut/burst_length_counter0/cke
add wave -noupdate -group {BURST LENGTH} -format Literal /versatile_mem_ctrl_tb/dut/burst_length_counter0/length
add wave -noupdate -group {BURST LENGTH} -format Literal /versatile_mem_ctrl_tb/dut/burst_length_counter0/clear_value
add wave -noupdate -group {BURST LENGTH} -format Literal /versatile_mem_ctrl_tb/dut/burst_length_counter0/set_value
add wave -noupdate -group {BURST LENGTH} -format Literal /versatile_mem_ctrl_tb/dut/burst_length_counter0/wrap_value
add wave -noupdate -group {BURST LENGTH} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/burst_length_counter0/qi
add wave -noupdate -group {BURST LENGTH} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/burst_length_counter0/q_next
add wave -noupdate -group {BURST LENGTH} -format Logic /versatile_mem_ctrl_tb/dut/burst_length_counter0/zq
add wave -noupdate -group {DDR2 IF} -divider FSM
add wave -noupdate -group {DDR2 IF} -format Literal -radix ascii /versatile_mem_ctrl_tb/dut/ddr_16_0/statename
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_270
add wave -noupdate -group {DDR2 IF} -divider {Controller side}
add wave -noupdate -group {DDR2 IF} -divider {Clock & reset}
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/sdram_rst
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk
add wave -noupdate -group {DDR2 IF} -divider {Tx Data}
add wave -noupdate -group {DDR2 IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/versatile_mem_ctrl_ddr_0/tx_dat_i
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/versatile_mem_ctrl_ddr_0/dq_en
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/versatile_mem_ctrl_ddr_0/dqm_en
add wave -noupdate -group {DDR2 IF} -divider {Rx Data}
add wave -noupdate -group {DDR2 IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/versatile_mem_ctrl_ddr_0/rx_dat_o
add wave -noupdate -group {DDR2 IF} -divider {SDRAM side}
add wave -noupdate -group {DDR2 IF} -divider Address
add wave -noupdate -group {DDR2 IF} -format Literal /versatile_mem_ctrl_tb/dut/ba_pad_o
add wave -noupdate -group {DDR2 IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/addr_pad_o
add wave -noupdate -group {DDR2 IF} -divider {Data & mask}
add wave -noupdate -group {DDR2 IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/dq_pad_io
add wave -noupdate -group {DDR2 IF} -format Literal /versatile_mem_ctrl_tb/dut/dm_rdqs_pad_io
add wave -noupdate -group {DDR2 IF} -divider {Clock & strobe}
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/cke_pad_o
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/ck_pad_o
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/ck_n_pad_o
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/ck_fb_pad_o
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/ck_fb_pad_i
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/dqs_oe
add wave -noupdate -group {DDR2 IF} -format Literal /versatile_mem_ctrl_tb/dut/dqs_pad_io
add wave -noupdate -group {DDR2 IF} -format Literal /versatile_mem_ctrl_tb/dut/dqs_n_pad_io
add wave -noupdate -group {DDR2 IF} -format Literal /versatile_mem_ctrl_tb/dut/rdqs_n_pad_i
add wave -noupdate -group {DDR2 IF} -divider Command
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/cs_n_pad_o
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/ras_pad_o
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/cas_pad_o
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/we_pad_o
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/odt_pad_o
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/versatile_mem_ctrl_ddr_0/dq_en
add wave -noupdate -group {DDR2 IF} -format Logic /versatile_mem_ctrl_tb/dut/versatile_mem_ctrl_ddr_0/dqm_en
add wave -noupdate -group {DDR2 IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/versatile_mem_ctrl_ddr_0/tx_dat_i
add wave -noupdate -group {OPEN BANKS & ROWS} -divider State
add wave -noupdate -group {OPEN BANKS & ROWS} -format Literal -radix ascii /versatile_mem_ctrl_tb/dut/ddr_16_0/statename
add wave -noupdate -group {OPEN BANKS & ROWS} -divider {Open bank & row}
add wave -noupdate -group {OPEN BANKS & ROWS} -format Literal /versatile_mem_ctrl_tb/dut/open_bank_i
add wave -noupdate -group {OPEN BANKS & ROWS} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/open_row_i
add wave -noupdate -group {OPEN BANKS & ROWS} -format Logic /versatile_mem_ctrl_tb/dut/open_cur_row
add wave -noupdate -group {OPEN BANKS & ROWS} -format Logic /versatile_mem_ctrl_tb/dut/close_cur_row
add wave -noupdate -group {OPEN BANKS & ROWS} -format Literal /versatile_mem_ctrl_tb/dut/open_row
add wave -noupdate -group {OPEN BANKS & ROWS} -format Literal /versatile_mem_ctrl_tb/dut/next_row
add wave -noupdate -group {OPEN BANKS & ROWS} -format Literal /versatile_mem_ctrl_tb/dut/next_row
add wave -noupdate -group {OPEN BANKS & ROWS} -format Literal /versatile_mem_ctrl_tb/dut/next_bank
add wave -noupdate -group {OPEN BANKS & ROWS} -format Logic /versatile_mem_ctrl_tb/dut/next_row_open
add wave -noupdate -group {FIFO Pointers & Flags} -divider FIFO_0_1
add wave -noupdate -group {FIFO Pointers & Flags} -divider FIFO_0_0
add wave -noupdate -group {FIFO Pointers & Flags} -format Literal -radix unsigned {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/fifo_adr[0]/egresscmp/wptr_bin}
add wave -noupdate -group {FIFO Pointers & Flags} -format Literal -radix unsigned {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/fifo_adr[0]/egresscmp/rptr_bin}
add wave -noupdate -group {FIFO Pointers & Flags} -format Literal -radix unsigned {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/fifo_adr[0]/egresscmp/ptr_diff}
add wave -noupdate -group {FIFO Pointers & Flags} -format Logic {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/fifo_adr[0]/egresscmp/fifo_empty}
add wave -noupdate -group {FIFO Pointers & Flags} -format Logic {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/fifo_adr[0]/egresscmp/fifo_full}
add wave -noupdate -group {FIFO Pointers & Flags} -format Logic {/versatile_mem_ctrl_tb/dut/genblk1/wb0/egress_FIFO/fifo_adr[0]/egresscmp/fifo_flag}
add wave -noupdate -group {FIFO Pointers & Flags} -divider FIFO_1_1
add wave -noupdate -group {FIFO Pointers & Flags} -divider FIFO_1_0
add wave -noupdate -group {FIFO Pointers & Flags} -format Literal -radix unsigned {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/fifo_adr[0]/egresscmp/wptr_bin}
add wave -noupdate -group {FIFO Pointers & Flags} -format Literal -radix unsigned {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/fifo_adr[0]/egresscmp/rptr_bin}
add wave -noupdate -group {FIFO Pointers & Flags} -format Literal -radix unsigned {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/fifo_adr[0]/egresscmp/ptr_diff}
add wave -noupdate -group {FIFO Pointers & Flags} -format Logic {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/fifo_adr[0]/egresscmp/fifo_empty}
add wave -noupdate -group {FIFO Pointers & Flags} -format Logic {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/fifo_adr[0]/egresscmp/fifo_full}
add wave -noupdate -group {FIFO Pointers & Flags} -format Logic {/versatile_mem_ctrl_tb/dut/genblk3/wb1/egress_FIFO/fifo_adr[0]/egresscmp/fifo_flag}
add wave -noupdate -group {FIFO Pointers & Flags} -divider {FIFO Flags on top-level}
add wave -noupdate -group {FIFO Pointers & Flags} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/fifo_empty
add wave -noupdate -group {FIFO Pointers & Flags} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/fifo_flag
add wave -noupdate -group {FIFO Pointers & Flags} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/versatile_mem_ctrl_ddr_0/dq_rx
add wave -noupdate -divider tmp
add wave -noupdate -format Logic /versatile_mem_ctrl_tb/dut/ck_pad_o
add wave -noupdate -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/dq_pad_io
add wave -noupdate -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_270
add wave -noupdate -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/versatile_mem_ctrl_ddr_0/dq_rx
add wave -noupdate -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_180
add wave -noupdate -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/versatile_mem_ctrl_ddr_0/dq_rx_reg
add wave -noupdate -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/fifo_dat_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {222981669 ps} 0}
configure wave -namecolwidth 441
configure wave -valuecolwidth 151
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
WaveRestoreZoom {0 ps} {346500 ns}
