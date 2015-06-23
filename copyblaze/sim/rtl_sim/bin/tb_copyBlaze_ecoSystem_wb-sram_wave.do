onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {WB SRAM}
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/clk
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/reset
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/wb_adr_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/wb_dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/wb_dat_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/wb_cyc_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/wb_stb_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/wb_ack_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/wb_we_i
add wave -noupdate -radix hexadecimal -subitemconfig {/tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(0) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(1) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(2) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(3) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(4) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(5) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(6) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(7) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(8) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(9) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(10) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(11) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(12) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(13) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(14) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(15) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(16) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(17) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(18) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(19) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(20) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(21) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(22) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(23) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(24) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(25) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(26) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(27) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(28) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(29) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(30) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(31) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(32) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(33) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(34) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(35) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(36) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(37) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(38) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(39) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(40) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(41) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(42) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(43) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(44) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(45) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(46) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(47) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(48) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(49) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(50) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(51) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(52) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(53) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(54) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(55) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(56) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(57) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(58) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(59) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(60) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(61) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(62) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray(63) {-height 15 -radix hexadecimal}} /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemarray
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemdatain
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemdataout
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemaddr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut_wb_sram/imemwrite
add wave -noupdate -divider {REG BANK}
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/u_bancregister/clk_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/u_bancregister/rst_i_n
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/u_bancregister/sxptr_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/u_bancregister/syptr_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/u_bancregister/write_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/u_bancregister/sxdata_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/u_bancregister/sxdata_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/u_bancregister/sydata_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/u_bancregister/ibancregmem
add wave -noupdate -divider CPU
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/clk_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/rst_i_n
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/address_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/instruction_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/interrupt_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/interrupt_ack_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/in_port_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/out_port_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/port_id_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/read_strobe_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/write_strobe_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/freeze_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/adr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/dat_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/we_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/sel_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/stb_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ack_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/cyc_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iphase1
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iphase2
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iaaa
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ikk
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iss
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ipp
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iz
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ic
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/izi
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ici
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ialuresult
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/isxdatain
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/isxdata
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/isydata
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/isxptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/isyptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iscratchptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iscratchdataout
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ibancwriteop
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ibancwrite
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iscratchwrite
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ifetch
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iinput
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iouput
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ioperationselect
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ioperandselect
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iarithoper
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ilogicoper
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ishiftbit
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ishiftsens
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iflagswrite
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iflagspush
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iflagspop
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iconditionctrl
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ijump
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/icall
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ireturn
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ireturni
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ipcenable
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iievent
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iiewrite
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iievalue
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/ifreeze
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwbadr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwbdat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwbdat
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwbdat_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwbwe_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwbsel_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwbstb_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwback_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwbcyc
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwbwrsing
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwbrdsing
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwb_validhandshake
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwb_validpc
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_sram/uut/processor/iwb_validoperand
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {215500000 ps} 0}
configure wave -namecolwidth 355
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
WaveRestoreZoom {207252383 ps} {223747617 ps}
