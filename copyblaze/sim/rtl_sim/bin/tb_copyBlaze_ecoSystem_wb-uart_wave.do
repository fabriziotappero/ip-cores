onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {WISHBONE uart}
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/clk
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/reset
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/wb_uart/wb_adr_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/wb_uart/wb_dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/wb_uart/wb_dat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/wb_cyc_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/wb_stb_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/wb_ack_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/wb_we_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/wb_rxirq_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/wb_txirq_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/uart_rx
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/uart_tx
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/active
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/activelast
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/ack
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/wr
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/rd
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/rx_avail
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/tx_avail
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/wb_uart/rxdata
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/wb_uart/txdata
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/wb_uart/status_reg
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/wb_uart/data_reg
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/tx_irqen
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/wb_uart/rx_irqen
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/wb_uart/divisor
add wave -noupdate -divider {REG BANK}
add wave -noupdate -label {copyBlaze REGBANK} -radix hexadecimal -subitemconfig {/tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(0) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(1) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(2) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(3) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(4) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(5) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(6) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(7) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(8) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(9) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(10) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(11) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(12) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(13) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(14) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem(15) {-height 15 -radix hexadecimal}} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_bancregister/ibancregmem
add wave -noupdate -divider {SCRATCH PAD}
add wave -noupdate -label {copyBlaze SCRATCHPAD} -radix hexadecimal -subitemconfig {/tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(0) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(1) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(2) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(3) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(4) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(5) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(6) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(7) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(8) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(9) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(10) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(11) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(12) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(13) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(14) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(15) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(16) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(17) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(18) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(19) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(20) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(21) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(22) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(23) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(24) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(25) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(26) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(27) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(28) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(29) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(30) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(31) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(32) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(33) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(34) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(35) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(36) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(37) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(38) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(39) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(40) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(41) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(42) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(43) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(44) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(45) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(46) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(47) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(48) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(49) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(50) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(51) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(52) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(53) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(54) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(55) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(56) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(57) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(58) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(59) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(60) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(61) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(62) {-radix hexadecimal} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem(63) {-radix hexadecimal}} /tb_copyblaze_ecosystem_wb_uart/uut/processor/u_scratchpad/iscratchpadmem
add wave -noupdate -divider COPYBLAZE
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/clk_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/rst_i_n
add wave -noupdate -color Firebrick -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/address_o
add wave -noupdate -color Firebrick -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/instruction_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/interrupt_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/interrupt_ack_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/in_port_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/out_port_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/port_id_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/read_strobe_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/write_strobe_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/freeze_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/adr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/dat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/we_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/sel_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/stb_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ack_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/cyc_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iphase1
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iphase2
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iaaa
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/ikk
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iss
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/ipp
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iz
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ic
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/izi
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ici
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/ialuresult
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/isxdatain
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/isxdata
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/isydata
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/isxptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/isyptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iscratchptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iscratchdataout
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ibancwriteop
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ibancwrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iscratchwrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ifetch
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iinput
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iouput
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/ioperationselect
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ioperandselect
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iarithoper
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/ilogicoper
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/ishiftbit
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ishiftsens
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iflagswrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iflagspush
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iflagspop
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iconditionctrl
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ijump
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/icall
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ireturn
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ireturni
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ipcenable
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iievent
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iiewrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iievalue
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/ifreeze
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwbadr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwbdat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwbdat
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwbdat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwbwe_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwbsel_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwbstb_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwback_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwbcyc
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwbwrsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwbrdsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwb_validhandshake
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwb_validpc
add wave -noupdate /tb_copyblaze_ecosystem_wb_uart/uut/processor/iwb_validoperand
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {125527929 ps} 0}
configure wave -namecolwidth 368
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
WaveRestoreZoom {0 ps} {262500 ns}
