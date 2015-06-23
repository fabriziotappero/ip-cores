onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/DUT/clk_i
add wave -noupdate /tb/DUT/rst_i
add wave -noupdate -group CM_WBM#0 -radix hexadecimal /tb/DUT/m0_addr_i
add wave -noupdate -group CM_WBM#0 /tb/DUT/m0_cyc_i
add wave -noupdate -group CM_WBM#0 -radix hexadecimal /tb/DUT/m0_data_i
add wave -noupdate -group CM_WBM#0 -radix hexadecimal /tb/DUT/m0_data_o
add wave -noupdate -group CM_WBM#0 /tb/DUT/m0_err_o
add wave -noupdate -group CM_WBM#0 /tb/DUT/m0_rty_o
add wave -noupdate -group CM_WBM#0 /tb/DUT/m0_sel_i
add wave -noupdate -group CM_WBM#0 /tb/DUT/m0_stb_i
add wave -noupdate -group CM_WBM#0 /tb/DUT/m0_we_i
add wave -noupdate -group CM_WBM#0 /tb/DUT/m0_ack_o
add wave -noupdate -group CM_WBM#0 /tb/DUT/m0_cti_i
add wave -noupdate -group CM_WBM#0 /tb/DUT/m0_bte_i
add wave -noupdate -group CM_WBM#1 -radix hexadecimal /tb/DUT/m1_addr_i
add wave -noupdate -group CM_WBM#1 /tb/DUT/m1_cyc_i
add wave -noupdate -group CM_WBM#1 -radix hexadecimal /tb/DUT/m1_data_i
add wave -noupdate -group CM_WBM#1 -radix hexadecimal /tb/DUT/m1_data_o
add wave -noupdate -group CM_WBM#1 /tb/DUT/m1_err_o
add wave -noupdate -group CM_WBM#1 /tb/DUT/m1_rty_o
add wave -noupdate -group CM_WBM#1 /tb/DUT/m1_sel_i
add wave -noupdate -group CM_WBM#1 /tb/DUT/m1_stb_i
add wave -noupdate -group CM_WBM#1 /tb/DUT/m1_we_i
add wave -noupdate -group CM_WBM#1 /tb/DUT/m1_ack_o
add wave -noupdate -group CM_WBM#1 /tb/DUT/m1_cti_i
add wave -noupdate -group CM_WBM#1 /tb/DUT/m1_bte_i
add wave -noupdate -group CM_WBM#2 -radix hexadecimal /tb/DUT/m2_addr_i
add wave -noupdate -group CM_WBM#2 /tb/DUT/m2_cyc_i
add wave -noupdate -group CM_WBM#2 -radix hexadecimal /tb/DUT/m2_data_i
add wave -noupdate -group CM_WBM#2 -radix hexadecimal /tb/DUT/m2_data_o
add wave -noupdate -group CM_WBM#2 /tb/DUT/m2_err_o
add wave -noupdate -group CM_WBM#2 /tb/DUT/m2_rty_o
add wave -noupdate -group CM_WBM#2 /tb/DUT/m2_sel_i
add wave -noupdate -group CM_WBM#2 /tb/DUT/m2_stb_i
add wave -noupdate -group CM_WBM#2 /tb/DUT/m2_we_i
add wave -noupdate -group CM_WBM#2 /tb/DUT/m2_ack_o
add wave -noupdate -group CM_WBM#2 /tb/DUT/m2_cti_i
add wave -noupdate -group CM_WBM#2 /tb/DUT/m2_bte_i
add wave -noupdate -group CM_WBM#3 -radix hexadecimal /tb/DUT/m3_addr_i
add wave -noupdate -group CM_WBM#3 /tb/DUT/m3_cyc_i
add wave -noupdate -group CM_WBM#3 -radix hexadecimal /tb/DUT/m3_data_i
add wave -noupdate -group CM_WBM#3 -radix hexadecimal /tb/DUT/m3_data_o
add wave -noupdate -group CM_WBM#3 /tb/DUT/m3_err_o
add wave -noupdate -group CM_WBM#3 /tb/DUT/m3_rty_o
add wave -noupdate -group CM_WBM#3 /tb/DUT/m3_sel_i
add wave -noupdate -group CM_WBM#3 /tb/DUT/m3_stb_i
add wave -noupdate -group CM_WBM#3 /tb/DUT/m3_we_i
add wave -noupdate -group CM_WBM#3 /tb/DUT/m3_ack_o
add wave -noupdate -group CM_WBM#3 /tb/DUT/m3_cti_i
add wave -noupdate -group CM_WBM#3 /tb/DUT/m3_bte_i
add wave -noupdate -group CM_WBM#4 -radix hexadecimal /tb/DUT/m4_addr_i
add wave -noupdate -group CM_WBM#4 /tb/DUT/m4_cyc_i
add wave -noupdate -group CM_WBM#4 -radix hexadecimal /tb/DUT/m4_data_i
add wave -noupdate -group CM_WBM#4 -radix hexadecimal /tb/DUT/m4_data_o
add wave -noupdate -group CM_WBM#4 /tb/DUT/m4_err_o
add wave -noupdate -group CM_WBM#4 /tb/DUT/m4_rty_o
add wave -noupdate -group CM_WBM#4 /tb/DUT/m4_sel_i
add wave -noupdate -group CM_WBM#4 /tb/DUT/m4_stb_i
add wave -noupdate -group CM_WBM#4 /tb/DUT/m4_we_i
add wave -noupdate -group CM_WBM#4 /tb/DUT/m4_ack_o
add wave -noupdate -group CM_WBM#4 /tb/DUT/m4_cti_i
add wave -noupdate -group CM_WBM#4 /tb/DUT/m4_bte_i
add wave -noupdate -group CM_WBM#5 -radix hexadecimal /tb/DUT/m5_addr_i
add wave -noupdate -group CM_WBM#5 /tb/DUT/m5_cyc_i
add wave -noupdate -group CM_WBM#5 -radix hexadecimal /tb/DUT/m5_data_i
add wave -noupdate -group CM_WBM#5 -radix hexadecimal /tb/DUT/m5_data_o
add wave -noupdate -group CM_WBM#5 /tb/DUT/m5_err_o
add wave -noupdate -group CM_WBM#5 /tb/DUT/m5_rty_o
add wave -noupdate -group CM_WBM#5 /tb/DUT/m5_sel_i
add wave -noupdate -group CM_WBM#5 /tb/DUT/m5_stb_i
add wave -noupdate -group CM_WBM#5 /tb/DUT/m5_we_i
add wave -noupdate -group CM_WBM#5 /tb/DUT/m5_ack_o
add wave -noupdate -group CM_WBM#5 /tb/DUT/m5_cti_i
add wave -noupdate -group CM_WBM#5 /tb/DUT/m5_bte_i
add wave -noupdate -expand -group CM_WBM#6 -radix hexadecimal /tb/DUT/m6_addr_i
add wave -noupdate -expand -group CM_WBM#6 /tb/DUT/m6_cyc_i
add wave -noupdate -expand -group CM_WBM#6 -radix hexadecimal /tb/DUT/m6_data_i
add wave -noupdate -expand -group CM_WBM#6 -radix hexadecimal /tb/DUT/m6_data_o
add wave -noupdate -expand -group CM_WBM#6 /tb/DUT/m6_err_o
add wave -noupdate -expand -group CM_WBM#6 /tb/DUT/m6_rty_o
add wave -noupdate -expand -group CM_WBM#6 /tb/DUT/m6_sel_i
add wave -noupdate -expand -group CM_WBM#6 /tb/DUT/m6_stb_i
add wave -noupdate -expand -group CM_WBM#6 /tb/DUT/m6_we_i
add wave -noupdate -expand -group CM_WBM#6 /tb/DUT/m6_ack_o
add wave -noupdate -expand -group CM_WBM#6 /tb/DUT/m6_cti_i
add wave -noupdate -expand -group CM_WBM#6 /tb/DUT/m6_bte_i
add wave -noupdate -group CM_WBM#7 -radix hexadecimal /tb/DUT/m7_addr_i
add wave -noupdate -group CM_WBM#7 /tb/DUT/m7_cyc_i
add wave -noupdate -group CM_WBM#7 -radix hexadecimal /tb/DUT/m7_data_i
add wave -noupdate -group CM_WBM#7 -radix hexadecimal /tb/DUT/m7_data_o
add wave -noupdate -group CM_WBM#7 /tb/DUT/m7_err_o
add wave -noupdate -group CM_WBM#7 /tb/DUT/m7_rty_o
add wave -noupdate -group CM_WBM#7 /tb/DUT/m7_sel_i
add wave -noupdate -group CM_WBM#7 /tb/DUT/m7_stb_i
add wave -noupdate -group CM_WBM#7 /tb/DUT/m7_we_i
add wave -noupdate -group CM_WBM#7 /tb/DUT/m7_ack_o
add wave -noupdate -group CM_WBM#7 /tb/DUT/m7_cti_i
add wave -noupdate -group CM_WBM#7 /tb/DUT/m7_bte_i
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group CM_WBS#0 /tb/DUT/s0_ack_i
add wave -noupdate -expand -group CM_WBS#0 -radix hexadecimal /tb/DUT/s0_addr_o
add wave -noupdate -expand -group CM_WBS#0 /tb/DUT/s0_cyc_o
add wave -noupdate -expand -group CM_WBS#0 -radix hexadecimal /tb/DUT/s0_data_i
add wave -noupdate -expand -group CM_WBS#0 -radix hexadecimal /tb/DUT/s0_data_o
add wave -noupdate -expand -group CM_WBS#0 /tb/DUT/s0_err_i
add wave -noupdate -expand -group CM_WBS#0 /tb/DUT/s0_rty_i
add wave -noupdate -expand -group CM_WBS#0 /tb/DUT/s0_sel_o
add wave -noupdate -expand -group CM_WBS#0 /tb/DUT/s0_stb_o
add wave -noupdate -expand -group CM_WBS#0 /tb/DUT/s0_we_o
add wave -noupdate -expand -group CM_WBS#0 /tb/DUT/s0_cti_o
add wave -noupdate -expand -group CM_WBS#0 /tb/DUT/s0_bte_o
add wave -noupdate -expand -group CM_WBS#1 /tb/DUT/s1_ack_i
add wave -noupdate -expand -group CM_WBS#1 -radix hexadecimal /tb/DUT/s1_addr_o
add wave -noupdate -expand -group CM_WBS#1 /tb/DUT/s1_cyc_o
add wave -noupdate -expand -group CM_WBS#1 -radix hexadecimal /tb/DUT/s1_data_i
add wave -noupdate -expand -group CM_WBS#1 -radix hexadecimal /tb/DUT/s1_data_o
add wave -noupdate -expand -group CM_WBS#1 /tb/DUT/s1_err_i
add wave -noupdate -expand -group CM_WBS#1 /tb/DUT/s1_rty_i
add wave -noupdate -expand -group CM_WBS#1 /tb/DUT/s1_sel_o
add wave -noupdate -expand -group CM_WBS#1 /tb/DUT/s1_stb_o
add wave -noupdate -expand -group CM_WBS#1 /tb/DUT/s1_we_o
add wave -noupdate -expand -group CM_WBS#1 /tb/DUT/s1_cti_o
add wave -noupdate -expand -group CM_WBS#1 /tb/DUT/s1_bte_o
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_ack_i
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_addr_o
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_cyc_o
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_data_i
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_data_o
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_err_i
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_rty_i
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_sel_o
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_stb_o
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_we_o
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_cti_o
add wave -noupdate -group CM_WBS#2 /tb/DUT/s2_bte_o
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_ack_i
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_addr_o
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_cyc_o
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_data_i
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_data_o
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_err_i
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_rty_i
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_sel_o
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_stb_o
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_we_o
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_cti_o
add wave -noupdate -group CM_WBS#3 /tb/DUT/s3_bte_o
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_ack_i
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_addr_o
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_cyc_o
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_data_i
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_data_o
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_err_i
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_rty_i
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_sel_o
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_stb_o
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_we_o
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_cti_o
add wave -noupdate -group CM_WBS#4 /tb/DUT/s4_bte_o
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_ack_i
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_addr_o
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_cyc_o
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_data_i
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_data_o
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_err_i
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_rty_i
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_sel_o
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_stb_o
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_we_o
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_cti_o
add wave -noupdate -group CM_WBS#5 /tb/DUT/s5_bte_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -group WBS_RAM_0 -radix hexadecimal -childformat {{{/tb/slave_ram_gen[0]/ram_slave/adr_i[31]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[30]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[29]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[28]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[27]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[26]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[25]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[24]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[23]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[22]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[21]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[20]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[19]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[18]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[17]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[16]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[15]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[14]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[13]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[12]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[11]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[10]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[9]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[8]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[7]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[6]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[5]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[4]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[3]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[2]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[1]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/adr_i[0]} -radix hexadecimal}} -subitemconfig {{/tb/slave_ram_gen[0]/ram_slave/adr_i[31]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[30]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[29]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[28]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[27]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[26]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[25]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[24]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[23]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[22]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[21]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[20]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[19]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[18]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[17]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[16]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[15]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[14]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[13]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[12]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[11]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[10]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[9]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[8]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[7]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[6]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[5]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[4]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[3]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[2]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[1]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/adr_i[0]} {-height 15 -radix hexadecimal}} {/tb/slave_ram_gen[0]/ram_slave/adr_i}
add wave -noupdate -group WBS_RAM_0 {/tb/slave_ram_gen[0]/ram_slave/clk}
add wave -noupdate -group WBS_RAM_0 {/tb/slave_ram_gen[0]/ram_slave/ack_o}
add wave -noupdate -group WBS_RAM_0 {/tb/slave_ram_gen[0]/ram_slave/cyc_i}
add wave -noupdate -group WBS_RAM_0 -radix hexadecimal -childformat {{{/tb/slave_ram_gen[0]/ram_slave/dat_i[63]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[62]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[61]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[60]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[59]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[58]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[57]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[56]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[55]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[54]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[53]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[52]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[51]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[50]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[49]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[48]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[47]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[46]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[45]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[44]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[43]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[42]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[41]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[40]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[39]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[38]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[37]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[36]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[35]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[34]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[33]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[32]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[31]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[30]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[29]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[28]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[27]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[26]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[25]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[24]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[23]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[22]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[21]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[20]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[19]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[18]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[17]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[16]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[15]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[14]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[13]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[12]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[11]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[10]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[9]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[8]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[7]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[6]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[5]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[4]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[3]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[2]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[1]} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/dat_i[0]} -radix hexadecimal}} -subitemconfig {{/tb/slave_ram_gen[0]/ram_slave/dat_i[63]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[62]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[61]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[60]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[59]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[58]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[57]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[56]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[55]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[54]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[53]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[52]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[51]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[50]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[49]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[48]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[47]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[46]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[45]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[44]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[43]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[42]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[41]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[40]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[39]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[38]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[37]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[36]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[35]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[34]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[33]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[32]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[31]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[30]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[29]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[28]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[27]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[26]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[25]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[24]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[23]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[22]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[21]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[20]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[19]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[18]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[17]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[16]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[15]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[14]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[13]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[12]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[11]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[10]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[9]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[8]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[7]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[6]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[5]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[4]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[3]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[2]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[1]} {-height 15 -radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/dat_i[0]} {-height 15 -radix hexadecimal}} {/tb/slave_ram_gen[0]/ram_slave/dat_i}
add wave -noupdate -group WBS_RAM_0 -radix hexadecimal {/tb/slave_ram_gen[0]/ram_slave/dat_o}
add wave -noupdate -group WBS_RAM_0 {/tb/slave_ram_gen[0]/ram_slave/err_o}
add wave -noupdate -group WBS_RAM_0 {/tb/slave_ram_gen[0]/ram_slave/rst}
add wave -noupdate -group WBS_RAM_0 {/tb/slave_ram_gen[0]/ram_slave/sel_i}
add wave -noupdate -group WBS_RAM_0 {/tb/slave_ram_gen[0]/ram_slave/stb_i}
add wave -noupdate -group WBS_RAM_0 {/tb/slave_ram_gen[0]/ram_slave/we_i}
add wave -noupdate -group WBS_RAM_0 -radix hexadecimal {/tb/slave_ram_gen[0]/ram_slave/ram[1]}
add wave -noupdate -group WBS_RAM_0 -radix hexadecimal {/tb/slave_ram_gen[0]/ram_slave/ram[0]}
add wave -noupdate -group WBS_RAM_0 -radix hexadecimal -childformat {{{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](65)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](64)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](63)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](62)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](61)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](60)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](59)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](58)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](57)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](56)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](55)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](54)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](53)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](52)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](51)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](50)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](49)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](48)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](47)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](46)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](45)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](44)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](43)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](42)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](41)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](40)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](39)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](38)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](37)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](36)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](35)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](34)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](33)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](32)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](31)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](30)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](29)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](28)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](27)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](26)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](25)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](24)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](23)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](22)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](21)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](20)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](19)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](18)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](17)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](16)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](15)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](14)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](13)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](12)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](11)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](10)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](9)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](8)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](7)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](6)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](5)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](4)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](3)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](2)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](1)} -radix hexadecimal} {{/tb/slave_ram_gen[0]/ram_slave/ram[65:0](0)} -radix hexadecimal}} -subitemconfig {{/tb/slave_ram_gen[0]/ram_slave/ram[65]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[64]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[63]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[62]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[61]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[60]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[59]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[58]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[57]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[56]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[55]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[54]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[53]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[52]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[51]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[50]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[49]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[48]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[47]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[46]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[45]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[44]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[43]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[42]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[41]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[40]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[39]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[38]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[37]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[36]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[35]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[34]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[33]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[32]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[31]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[30]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[29]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[28]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[27]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[26]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[25]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[24]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[23]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[22]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[21]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[20]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[19]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[18]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[17]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[16]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[15]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[14]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[13]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[12]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[11]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[10]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[9]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[8]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[7]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[6]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[5]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[4]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[3]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[2]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[1]} {-radix hexadecimal} {/tb/slave_ram_gen[0]/ram_slave/ram[0]} {-radix hexadecimal}} {/tb/slave_ram_gen[0]/ram_slave/ram[65:0]}
add wave -noupdate -group WBS_RAM_1 {/tb/slave_ram_gen[1]/ram_slave/ack_o}
add wave -noupdate -group WBS_RAM_1 -radix hexadecimal {/tb/slave_ram_gen[1]/ram_slave/adr_i}
add wave -noupdate -group WBS_RAM_1 {/tb/slave_ram_gen[1]/ram_slave/cyc_i}
add wave -noupdate -group WBS_RAM_1 -radix hexadecimal {/tb/slave_ram_gen[1]/ram_slave/dat_i}
add wave -noupdate -group WBS_RAM_1 -radix hexadecimal {/tb/slave_ram_gen[1]/ram_slave/dat_o}
add wave -noupdate -group WBS_RAM_1 {/tb/slave_ram_gen[1]/ram_slave/err_o}
add wave -noupdate -group WBS_RAM_1 {/tb/slave_ram_gen[1]/ram_slave/sel_i}
add wave -noupdate -group WBS_RAM_1 {/tb/slave_ram_gen[1]/ram_slave/stb_i}
add wave -noupdate -group WBS_RAM_1 {/tb/slave_ram_gen[1]/ram_slave/we_i}
add wave -noupdate -group WBS_RAM_1 -radix hexadecimal {/tb/slave_ram_gen[1]/ram_slave/ram[1]}
add wave -noupdate -group WBS_RAM_1 -radix hexadecimal {/tb/slave_ram_gen[1]/ram_slave/ram[0]}
add wave -noupdate -group WBS_RAM_2 {/tb/slave_ram_gen[2]/ram_slave/ack_o}
add wave -noupdate -group WBS_RAM_2 -radix hexadecimal {/tb/slave_ram_gen[2]/ram_slave/adr_i}
add wave -noupdate -group WBS_RAM_2 {/tb/slave_ram_gen[2]/ram_slave/cyc_i}
add wave -noupdate -group WBS_RAM_2 -radix hexadecimal {/tb/slave_ram_gen[2]/ram_slave/dat_i}
add wave -noupdate -group WBS_RAM_2 -radix hexadecimal {/tb/slave_ram_gen[2]/ram_slave/dat_o}
add wave -noupdate -group WBS_RAM_2 {/tb/slave_ram_gen[2]/ram_slave/err_o}
add wave -noupdate -group WBS_RAM_2 {/tb/slave_ram_gen[2]/ram_slave/sel_i}
add wave -noupdate -group WBS_RAM_2 {/tb/slave_ram_gen[2]/ram_slave/stb_i}
add wave -noupdate -group WBS_RAM_2 {/tb/slave_ram_gen[2]/ram_slave/we_i}
add wave -noupdate -group WBS_RAM_2 -radix hexadecimal {/tb/slave_ram_gen[2]/ram_slave/ram[1]}
add wave -noupdate -group WBS_RAM_2 -radix hexadecimal {/tb/slave_ram_gen[2]/ram_slave/ram[0]}
add wave -noupdate -divider {New Divider}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/ack_i}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/adr_o}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/cb_event}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/cyc_o}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/dat_i}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/dat_o}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/err_i}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/rty_i}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/sel_o}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/stb_o}
add wave -noupdate -group WBM_IF#7 {/tb/m_if[7]/cb/we_o}
add wave -noupdate {/tb/wb_s_adr_o[0]}
add wave -noupdate {/tb/wb_s_adr_o[1]}
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/DUT/m0/slv_sel
add wave -noupdate -radix hexadecimal -childformat {{{/tb/DUT/m0/wb_addr_i[31]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[30]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[29]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[28]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[27]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[26]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[25]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[24]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[23]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[22]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[21]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[20]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[19]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[18]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[17]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[16]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[15]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[14]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[13]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[12]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[11]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[10]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[9]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[8]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[7]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[6]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[5]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[4]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[3]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[2]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[1]} -radix hexadecimal} {{/tb/DUT/m0/wb_addr_i[0]} -radix hexadecimal}} -subitemconfig {{/tb/DUT/m0/wb_addr_i[31]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[30]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[29]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[28]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[27]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[26]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[25]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[24]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[23]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[22]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[21]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[20]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[19]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[18]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[17]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[16]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[15]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[14]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[13]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[12]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[11]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[10]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[9]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[8]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[7]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[6]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[5]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[4]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[3]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[2]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[1]} {-height 15 -radix hexadecimal} {/tb/DUT/m0/wb_addr_i[0]} {-height 15 -radix hexadecimal}} /tb/DUT/m0/wb_addr_i
add wave -noupdate -radix unsigned /tb/DUT/s1/mast_sel
add wave -noupdate /tb/DUT/s1/m0_bte_i
add wave -noupdate /tb/DUT/s1/m0_cti_i
add wave -noupdate /tb/DUT/s1/m1_bte_i
add wave -noupdate /tb/DUT/s1/m1_cti_i
add wave -noupdate /tb/DUT/s1/m2_bte_i
add wave -noupdate /tb/DUT/s1/m2_cti_i
add wave -noupdate /tb/DUT/s1/m3_bte_i
add wave -noupdate /tb/DUT/s1/m3_cti_i
add wave -noupdate /tb/DUT/s1/m4_bte_i
add wave -noupdate /tb/DUT/s1/m4_cti_i
add wave -noupdate /tb/DUT/s1/m5_bte_i
add wave -noupdate /tb/DUT/s1/m5_cti_i
add wave -noupdate /tb/DUT/s1/m6_bte_i
add wave -noupdate /tb/DUT/s1/m6_cti_i
add wave -noupdate /tb/DUT/s1/m7_bte_i
add wave -noupdate /tb/DUT/s1/m7_cti_i
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/DUT/m6/wb_bte_i
add wave -noupdate /tb/DUT/m6/wb_cti_i
add wave -noupdate /tb/DUT/m6/s0_bte_o
add wave -noupdate /tb/DUT/m6/s0_cti_o
add wave -noupdate /tb/DUT/m6/s1_bte_o
add wave -noupdate /tb/DUT/m6/s1_cti_o
add wave -noupdate /tb/DUT/m6/slv_sel
add wave -noupdate /tb/DUT/m6s1_bte
add wave -noupdate /tb/DUT/m6s1_cti
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3668516 ps} 0}
configure wave -namecolwidth 281
configure wave -valuecolwidth 123
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
configure wave -timelineunits ps
update
WaveRestoreZoom {3656193 ps} {3695303 ps}
