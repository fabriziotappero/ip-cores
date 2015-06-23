onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {WB SRAM}
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/data_width
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/addr_width
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb_clk_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb_rst_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb1_cyc_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb1_stb_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb1_we_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb1_adr_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb1_dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb1_dat_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb1_ack_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb2_cyc_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb2_stb_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb2_we_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb2_adr_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb2_dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb2_dat_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb2_ack_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb3_cyc_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb3_stb_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb3_we_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb3_adr_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb3_dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb3_dat_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/wb3_ack_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/we
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/a
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/d
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut_wb_sram/q
add wave -noupdate -divider {CPU wishbone}
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/clk_i
add wave -noupdate -color {Medium Slate Blue} /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iphase1
add wave -noupdate -color {Medium Slate Blue} /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iphase2
add wave -noupdate -color Goldenrod -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/iaddress
add wave -noupdate -color Goldenrod -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/iinstruction
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwbadr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwbdat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwbdat
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwbdat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwbwe_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwbsel_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwbstb_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwback_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwbcyc
add wave -noupdate /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwbwrsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwbrdsing
add wave -noupdate -color {Cornflower Blue} /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwb_validhandshake
add wave -noupdate -color {Cornflower Blue} /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwb_validpc
add wave -noupdate -color {Cornflower Blue} /tb_copyblaze_ecosystem_wb_sram_3p/uut/processor/iwb_validoperand
add wave -noupdate -divider CPU
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/gen_width_data
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/gen_width_pc
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/gen_width_inst
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/gen_depth_stack
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/gen_depth_banc
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/gen_depth_scratch
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/gen_int_vector
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/clk_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/interrupt_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/interrupt_ack_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/in_port_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/out_port_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/port_id_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/read_strobe_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/write_strobe_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/freeze_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/adr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/dat_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/we_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/sel_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/stb_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/ack_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/cyc_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/iaddress
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/iinstruction
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/ireset
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram_3p/uut/ireset_counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {208077206 ps} 0}
configure wave -namecolwidth 408
configure wave -valuecolwidth 40
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
WaveRestoreZoom {199046875 ps} {215453125 ps}
