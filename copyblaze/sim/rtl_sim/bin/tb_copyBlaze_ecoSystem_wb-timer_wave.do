onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {WISHBONE timer}
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/clk
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/reset
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/wb_timer/wb_adr_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/wb_timer/wb_dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/wb_timer/wb_dat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/wb_cyc_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/wb_stb_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/wb_ack_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/wb_we_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/wb_irq0_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/wb_irq1_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/wbactive
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/wb_timer/counter0
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/wb_timer/counter1
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/wb_timer/compare0
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/wb_timer/compare1
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/en0
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/en1
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/ar0
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/ar1
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/trig0
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/trig1
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/irq0en
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/wb_timer/irq1en
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/wb_timer/tcr0
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/wb_timer/tcr1
add wave -noupdate -divider COPYBLAZE
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/clk_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/rst_i_n
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/address_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/instruction_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/interrupt_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/interrupt_ack_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/in_port_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/out_port_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/port_id_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/read_strobe_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/write_strobe_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/freeze_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/adr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/dat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/we_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/sel_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/stb_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ack_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/cyc_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iphase1
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iphase2
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iaaa
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/ikk
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iss
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/ipp
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iz
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ic
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/izi
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ici
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/ialuresult
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/isxdatain
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/isxdata
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/isydata
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/isxptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/isyptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iscratchptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iscratchdataout
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ibancwriteop
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ibancwrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iscratchwrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ifetch
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iinput
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iouput
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/ioperationselect
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ioperandselect
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iarithoper
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/ilogicoper
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/ishiftbit
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ishiftsens
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iflagswrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iflagspush
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iflagspop
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iconditionctrl
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ijump
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/icall
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ireturn
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ireturni
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ipcenable
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iievent
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iiewrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iievalue
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/ifreeze
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwbadr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwbdat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwbdat
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwbdat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwbwe_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwbsel_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwbstb_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwback_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwbcyc
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwbwrsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwbrdsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwb_validhandshake
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwb_validpc
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/iwb_validoperand
add wave -noupdate -divider {BANC REGISTERS}
add wave -noupdate -color {Orange Red} -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/ipointer
add wave -noupdate -color Cyan -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/address_o
add wave -noupdate -color Cyan -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/instruction_i
add wave -noupdate -radix hexadecimal -expand -subitemconfig {/tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(0) {-color {Medium Orchid} -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(1) {-color {Medium Orchid} -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(2) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(3) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(4) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(5) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(6) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(7) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(8) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(9) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(10) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(11) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(12) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(13) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(14) {-color Goldenrod -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem(15) {-color Goldenrod -height 15 -radix hexadecimal}} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_bancregister/ibancregmem
add wave -noupdate -divider STACK
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/clk_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/rst_i_n
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/data_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/data_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/enable_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/push_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/pop_i
add wave -noupdate -color {Orange Red} -radix hexadecimal -subitemconfig {/tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(0) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(1) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(2) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(3) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(4) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(5) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(6) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(7) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(8) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(9) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(10) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(11) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(12) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(13) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(14) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(15) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(16) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(17) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(18) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(19) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(20) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(21) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(22) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(23) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(24) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(25) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(26) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(27) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(28) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(29) {-color #ffff45450000 -height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem(30) {-color #ffff45450000 -height 15 -radix hexadecimal}} /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istackmem
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/istacken
add wave -noupdate -color {Orange Red} -radix hexadecimal /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/ipointer
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/iptrup
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/iptrdown
add wave -noupdate /tb_copyblaze_ecosystem_wb_timer/uut/processor/u_programflowcontrol/u_stack/itempo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {74306953 ps} 0}
configure wave -namecolwidth 503
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
configure wave -timelineunits ps
update
WaveRestoreZoom {63456889 ps} {93813222 ps}
