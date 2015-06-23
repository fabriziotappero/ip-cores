onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {ECO SYSTEM}
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iclk
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/ireset
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iresetn
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iinterrupt
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iinterrupt_ack
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/iin_port
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/iout_port
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/iport_id
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iread_strobe
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iwrite_strobe
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/ifreeze
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/ireset_counter
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/icounter
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/iwaveforms
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iextintevent
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iwbstb
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iwbcyc
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iwback
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/iwbwe
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/iwbdat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/iwbdat_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/iwbadr
add wave -noupdate -divider {WB GPIO}
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/clk
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/reset
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/wb_adr_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/wb_dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/wb_dat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/wb_cyc_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/wb_stb_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/wb_ack_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/wb_we_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/iport
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/oport
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/wbactive
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/oport_reg
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/wb_gpio/iport_reg
add wave -noupdate -divider {REG BANC}
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/clk_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/rst_i_n
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/sxptr_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/syptr_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/write_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/sxdata_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/sxdata_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/sydata_o
add wave -noupdate -radix hexadecimal -expand -subitemconfig {/tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(0) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(1) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(2) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(3) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(4) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(5) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(6) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(7) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(8) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(9) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(10) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(11) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(12) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(13) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(14) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(15) {-height 15 -radix hexadecimal}} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem
add wave -noupdate -divider CPU
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/clk_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/rst_i_n
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/address_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/instruction_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/interrupt_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/interrupt_ack_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/in_port_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/out_port_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/port_id_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/read_strobe_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/write_strobe_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/freeze_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/adr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/dat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/dat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/we_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/sel_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/stb_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ack_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/cyc_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iphase1
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iphase2
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iaaa
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ikk
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iss
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ipp
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iz
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ic
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/izi
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ici
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ialuresult
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/isxdatain
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/isxdata
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/isydata
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/isxptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/isyptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iscratchptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iscratchdataout
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ibancwriteop
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ibancwrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iscratchwrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ifetch
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iinput
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iouput
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ioperationselect
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ioperandselect
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iarithoper
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ilogicoper
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ishiftbit
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ishiftsens
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iflagswrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iflagspush
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iflagspop
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iconditionctrl
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ijump
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/icall
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ireturn
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ireturni
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ipcenable
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iievent
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iiewrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iievalue
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/ifreeze
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbadr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbdat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbdat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbwe_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbsel_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbstb_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwback_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbcyc
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbwrsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbrdsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwb_validhandshake
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwb_validpc
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwb_validoperand
add wave -noupdate -divider DECODER
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/phase2_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ievent_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/instruction_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/fetch_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/input_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ouput_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/jump_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/call_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/return_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/returni_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iewrite_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/bancwrite_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/scratchwrite_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/operationselect_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/flagswrite_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/flagspush_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/flagspop_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/aaa_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/kk_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ss_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/pp_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/sxptr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/syptr_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/operandselect_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/arithoper_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/logicoper_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/shiftbit_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/shiftsens_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/conditionctrl_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ievalue_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/wbrdsing_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/wbwrsing_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iinstruction
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ioperationselect
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ibancwrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iscratchwrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iflagswrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iflagspush
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iflagspop
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iiewrite
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iaddsub
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/icompare
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iload
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ilogic
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/itest
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ishift
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/istore
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ifetch
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iinput
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iouput
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ijump
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/icall
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ireturn
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ireturni
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/isetinterrupt
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iwbwrsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iwbrdsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iievent
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iievalue
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iconditionctrl
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ishiftsens
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ishiftbit
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ilogicoper
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iarithoper
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ioperandselect
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/isyptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/isxptr
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ipp
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iss
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/ikk
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iaaa
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_decodecontrol/iinstructioncode
add wave -noupdate -divider {WISHBONE control}
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_toggle/clk_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_toggle/rst_i_n
add wave -noupdate -color Cyan /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_toggle/phase1_o
add wave -noupdate -color Cyan /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_toggle/phase2_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/address_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/instruction_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbadr_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbdat_i
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbdat_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbwe_o
add wave -noupdate -radix hexadecimal /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbsel_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbstb_o
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwback_i
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbcyc
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbwrsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwbrdsing
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwb_validhandshake
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwb_validpc
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/iwb_validoperand
add wave -noupdate -divider {WISHBONE regbanc}
add wave -noupdate /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/write_i
add wave -noupdate -radix hexadecimal -subitemconfig {/tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(0) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(1) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(2) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(3) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(4) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(5) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(6) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(7) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(8) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(9) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(10) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(11) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(12) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(13) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(14) {-height 15 -radix hexadecimal} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem(15) {-height 15 -radix hexadecimal}} /tb_copyblaze_ecosystem_wb_gpio/uut/processor/u_bancregister/ibancregmem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {207250000 ps} 0}
configure wave -namecolwidth 430
configure wave -valuecolwidth 39
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
WaveRestoreZoom {192424686 ps} {222075314 ps}
