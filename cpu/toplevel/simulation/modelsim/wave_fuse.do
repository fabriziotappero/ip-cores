onerror {resume}
quietly virtual function -install /test_fuse/dut/alu_ -env /test_fuse { &{/test_fuse/dut/alu_/op1_high, /test_fuse/dut/alu_/op1_low }} OP1
quietly virtual function -install /test_fuse/dut/alu_ -env /test_fuse { &{/test_fuse/dut/alu_/op2_high, /test_fuse/dut/alu_/op2_low }} OP2
quietly virtual function -install /test_fuse/dut/alu_ -env /test_fuse { &{/test_fuse/dut/alu_/result_hi, /test_fuse/dut/alu_/result_lo }} RESULT
quietly virtual function -install /test_fuse/dut/reg_file_ -env /test_fuse/dut/reg_file_/b2v_latch_af_lo { &{/test_fuse/dut/reg_file_/b2v_latch_af_hi/latch, /test_fuse/dut/reg_file_/b2v_latch_af_lo/latch }} AF
quietly virtual function -install /test_fuse/dut/reg_file_ -env /test_fuse/dut/reg_file_/b2v_latch_pc_lo { &{/test_fuse/dut/reg_file_/b2v_latch_pc_hi/latch, /test_fuse/dut/reg_file_/b2v_latch_pc_lo/latch }} PC
quietly virtual function -install /test_fuse/dut/reg_file_ -env /test_fuse/dut/reg_file_/b2v_latch_ir_lo { &{/test_fuse/dut/reg_file_/b2v_latch_ir_hi/latch, /test_fuse/dut/reg_file_/b2v_latch_ir_lo/latch }} IR
quietly virtual function -install /test_fuse/dut/reg_file_ -env /test_fuse/dut/reg_file_/b2v_latch_bc_lo { &{/test_fuse/dut/reg_file_/b2v_latch_bc_hi/latch, /test_fuse/dut/reg_file_/b2v_latch_bc_lo/latch }} BC
quietly virtual function -install /test_fuse/dut/reg_file_ -env /test_fuse/dut/reg_file_/b2v_latch_de_lo { &{/test_fuse/dut/reg_file_/b2v_latch_de_hi/latch, /test_fuse/dut/reg_file_/b2v_latch_de_lo/latch }} DE
quietly virtual function -install /test_fuse/dut/reg_file_ -env /test_fuse/dut/reg_file_/b2v_latch_hl_lo { &{/test_fuse/dut/reg_file_/b2v_latch_hl_hi/latch, /test_fuse/dut/reg_file_/b2v_latch_hl_lo/latch }} HL
quietly virtual function -install /test_fuse/dut/reg_file_ -env /test_fuse/dut/reg_file_/b2v_latch_sp_lo { &{/test_fuse/dut/reg_file_/b2v_latch_sp_hi/latch, /test_fuse/dut/reg_file_/b2v_latch_sp_lo/latch }} SP
quietly virtual function -install /test_fuse/dut/reg_file_ -env /test_fuse/dut/reg_file_/b2v_latch_wz_lo { &{/test_fuse/dut/reg_file_/b2v_latch_wz_hi/latch, /test_fuse/dut/reg_file_/b2v_latch_wz_lo/latch }} WZ
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {pads
} /test_fuse/z80/CLK
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nM1
add wave -noupdate -expand -group {pads
} -color Gray90 /test_fuse/z80/nMREQ
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nIORQ
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nRD
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nWR
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nRFSH
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nBUSRQ
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nBUSACK
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nHALT
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nWAIT
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nINT
add wave -noupdate -expand -group {pads
} /test_fuse/z80/nNMI
add wave -noupdate -expand -group {pads
} -radix hexadecimal /test_fuse/z80/A
add wave -noupdate -expand -group {pads
} -radix hexadecimal -childformat {{{/test_fuse/z80/D[7]} -radix hexadecimal} {{/test_fuse/z80/D[6]} -radix hexadecimal} {{/test_fuse/z80/D[5]} -radix hexadecimal} {{/test_fuse/z80/D[4]} -radix hexadecimal} {{/test_fuse/z80/D[3]} -radix hexadecimal} {{/test_fuse/z80/D[2]} -radix hexadecimal} {{/test_fuse/z80/D[1]} -radix hexadecimal} {{/test_fuse/z80/D[0]} -radix hexadecimal}} -subitemconfig {{/test_fuse/z80/D[7]} {-height 15 -radix hexadecimal} {/test_fuse/z80/D[6]} {-height 15 -radix hexadecimal} {/test_fuse/z80/D[5]} {-height 15 -radix hexadecimal} {/test_fuse/z80/D[4]} {-height 15 -radix hexadecimal} {/test_fuse/z80/D[3]} {-height 15 -radix hexadecimal} {/test_fuse/z80/D[2]} {-height 15 -radix hexadecimal} {/test_fuse/z80/D[1]} {-height 15 -radix hexadecimal} {/test_fuse/z80/D[0]} {-height 15 -radix hexadecimal}} /test_fuse/z80/D
add wave -noupdate -group sequencer /test_fuse/dut/sequencer_/nextM
add wave -noupdate -group sequencer /test_fuse/dut/sequencer_/setM1
add wave -noupdate -group sequencer -group internal /test_fuse/dut/sequencer_/hold_clk_iorq
add wave -noupdate -group sequencer -group internal /test_fuse/dut/sequencer_/hold_clk_wait
add wave -noupdate -group sequencer -group internal /test_fuse/dut/sequencer_/hold_clk_busrq
add wave -noupdate -group sequencer -group internal /test_fuse/dut/sequencer_/ena_M
add wave -noupdate -group sequencer -group internal /test_fuse/dut/sequencer_/ena_T
add wave -noupdate -group sequencer -expand -group function /test_fuse/dut/pin_control_/fFetch
add wave -noupdate -group sequencer -expand -group function /test_fuse/dut/pin_control_/fMRead
add wave -noupdate -group sequencer -expand -group function /test_fuse/dut/pin_control_/fMWrite
add wave -noupdate -group sequencer -expand -group function /test_fuse/dut/pin_control_/fIORead
add wave -noupdate -group sequencer -expand -group function /test_fuse/dut/pin_control_/fIOWrite
add wave -noupdate -group sequencer -expand -group M /test_fuse/dut/sequencer_/M1
add wave -noupdate -group sequencer -expand -group M /test_fuse/dut/sequencer_/M2
add wave -noupdate -group sequencer -expand -group M /test_fuse/dut/sequencer_/M3
add wave -noupdate -group sequencer -expand -group M /test_fuse/dut/sequencer_/M4
add wave -noupdate -group sequencer -expand -group M /test_fuse/dut/sequencer_/M5
add wave -noupdate -group sequencer -expand -group M /test_fuse/dut/sequencer_/M6
add wave -noupdate -group sequencer -expand -group T /test_fuse/dut/sequencer_/T1
add wave -noupdate -group sequencer -expand -group T /test_fuse/dut/sequencer_/T2
add wave -noupdate -group sequencer -expand -group T /test_fuse/dut/sequencer_/T3
add wave -noupdate -group sequencer -expand -group T /test_fuse/dut/sequencer_/T4
add wave -noupdate -group sequencer -expand -group T /test_fuse/dut/sequencer_/T5
add wave -noupdate -group sequencer -expand -group T /test_fuse/dut/sequencer_/T6
add wave -noupdate -group opcode /test_fuse/dut/instruction_reg_/ctl_ir_we
add wave -noupdate -group opcode /test_fuse/dut/instruction_reg_/opcode
add wave -noupdate -group db -radix hexadecimal /test_fuse/dut/db0
add wave -noupdate -group db -radix hexadecimal /test_fuse/dut/db1
add wave -noupdate -group db -radix hexadecimal /test_fuse/dut/db2
add wave -noupdate -group {bus control} /test_fuse/dut/bus_control_/ctl_bus_ff_oe
add wave -noupdate -group {bus control} /test_fuse/dut/bus_control_/ctl_bus_zero_oe
add wave -noupdate -group {bus control} /test_fuse/dut/bus_control_/ctl_bus_db_oe
add wave -noupdate -group {bus control} /test_fuse/dut/pin_control_/bus_ab_pin_we
add wave -noupdate -group {bus control} /test_fuse/dut/pin_control_/bus_db_pin_oe
add wave -noupdate -group {bus control} /test_fuse/dut/pin_control_/bus_db_pin_re
add wave -noupdate -group {bus control} /test_fuse/dut/fpga_reset
add wave -noupdate -group {bus control} /test_fuse/dut/nreset
add wave -noupdate -group {bus control} /test_fuse/dut/control_pins_/in_halt
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_exx
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_ex_af
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_ex_de_hl
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_use_sp
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/nreset
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_sel_pc
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_sel_ir
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_sel_wz
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_gp_we
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_not_pc
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/use_ixiy
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/use_ix
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_sys_we_lo
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_sys_we_hi
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_sys_we
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/clk
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_gp_hilo
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_gp_sel
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/ctl_reg_sys_hilo
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_bc
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_bc2
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_ix
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_iy
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_de
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_hl
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_de2
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_hl2
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_af
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_af2
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_wz
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_pc
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_ir
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_sp
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_gp_hi
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_gp_lo
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_sys_lo
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sel_sys_hi
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_gp_we
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sys_we_lo
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/reg_sys_we_hi
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/bank_af
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/bank_exx
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/bank_hl_de1
add wave -noupdate -group {reg control} /test_fuse/dut/reg_control_/bank_hl_de2
add wave -noupdate -group regfile /test_fuse/dut/reg_file_/AF
add wave -noupdate -group regfile /test_fuse/dut/reg_file_/BC
add wave -noupdate -group regfile /test_fuse/dut/reg_file_/DE
add wave -noupdate -group regfile /test_fuse/dut/reg_file_/HL
add wave -noupdate -group regfile /test_fuse/dut/reg_file_/SP
add wave -noupdate -group regfile /test_fuse/dut/reg_file_/WZ
add wave -noupdate -group regfile /test_fuse/dut/reg_file_/PC
add wave -noupdate -group regfile /test_fuse/dut/reg_file_/IR
add wave -noupdate -group regfile -radix hexadecimal /test_fuse/dut/reg_file_/db_hi_ds
add wave -noupdate -group regfile -radix hexadecimal /test_fuse/dut/reg_file_/db_lo_ds
add wave -noupdate -group regfile -group selects -color Thistle /test_fuse/dut/reg_file_/reg_gp_we
add wave -noupdate -group regfile -group selects -color Gold /test_fuse/dut/reg_file_/reg_sel_gp_lo
add wave -noupdate -group regfile -group selects -color Gold /test_fuse/dut/reg_file_/reg_sel_gp_hi
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_sp
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_iy
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_ix
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_hl2
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_hl
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_de2
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_de
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_bc2
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_bc
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_af2
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_af
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sys_we_lo
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sys_we_hi
add wave -noupdate -group regfile -group selects -color Gold /test_fuse/dut/reg_file_/reg_sel_sys_lo
add wave -noupdate -group regfile -group selects -color Gold /test_fuse/dut/reg_file_/reg_sel_sys_hi
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_wz
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_ir
add wave -noupdate -group regfile -group selects /test_fuse/dut/reg_file_/reg_sel_pc
add wave -noupdate -group regfile -radix hexadecimal /test_fuse/dut/reg_file_/db_hi_as
add wave -noupdate -group regfile -radix hexadecimal -childformat {{{/test_fuse/dut/reg_file_/db_lo_as[7]} -radix hexadecimal} {{/test_fuse/dut/reg_file_/db_lo_as[6]} -radix hexadecimal} {{/test_fuse/dut/reg_file_/db_lo_as[5]} -radix hexadecimal} {{/test_fuse/dut/reg_file_/db_lo_as[4]} -radix hexadecimal} {{/test_fuse/dut/reg_file_/db_lo_as[3]} -radix hexadecimal} {{/test_fuse/dut/reg_file_/db_lo_as[2]} -radix hexadecimal} {{/test_fuse/dut/reg_file_/db_lo_as[1]} -radix hexadecimal} {{/test_fuse/dut/reg_file_/db_lo_as[0]} -radix hexadecimal}} -subitemconfig {{/test_fuse/dut/reg_file_/db_lo_as[7]} {-height 15 -radix hexadecimal} {/test_fuse/dut/reg_file_/db_lo_as[6]} {-height 15 -radix hexadecimal} {/test_fuse/dut/reg_file_/db_lo_as[5]} {-height 15 -radix hexadecimal} {/test_fuse/dut/reg_file_/db_lo_as[4]} {-height 15 -radix hexadecimal} {/test_fuse/dut/reg_file_/db_lo_as[3]} {-height 15 -radix hexadecimal} {/test_fuse/dut/reg_file_/db_lo_as[2]} {-height 15 -radix hexadecimal} {/test_fuse/dut/reg_file_/db_lo_as[1]} {-height 15 -radix hexadecimal} {/test_fuse/dut/reg_file_/db_lo_as[0]} {-height 15 -radix hexadecimal}} /test_fuse/dut/reg_file_/db_lo_as
add wave -noupdate -group switch /test_fuse/dut/bus_switch_/ctl_sw_mask543_en
add wave -noupdate -group switch /test_fuse/dut/bus_switch_/ctl_sw_1u
add wave -noupdate -group switch /test_fuse/dut/bus_switch_/ctl_sw_1d
add wave -noupdate -group switch /test_fuse/dut/bus_switch_/ctl_sw_2u
add wave -noupdate -group switch /test_fuse/dut/bus_switch_/ctl_sw_2d
add wave -noupdate -group switch -color Aquamarine /test_fuse/dut/reg_file_/ctl_sw_4d
add wave -noupdate -group switch -color Aquamarine /test_fuse/dut/reg_file_/ctl_sw_4u
add wave -noupdate -group {data pins} /test_fuse/dut/data_pins_/bus_db_pin_oe
add wave -noupdate -group {data pins} /test_fuse/dut/data_pins_/bus_db_pin_re
add wave -noupdate -group {data pins} /test_fuse/dut/data_pins_/ctl_bus_db_we
add wave -noupdate -group {data pins} /test_fuse/dut/data_pins_/bus_db_oe
add wave -noupdate -group {data pins} -radix hexadecimal /test_fuse/dut/data_pins_/D
add wave -noupdate -group {data pins} -radix hexadecimal /test_fuse/dut/data_pins_/db
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/alu_shift_db0
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/alu_shift_db7
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/ctl_shift_en
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/flags_hf
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/ctl_alu_op_low
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/alu_parity_out
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/flags_zf
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/flags_pf
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/flags_sf
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/ctl_cond_short
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/alu_vf_out
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/iff2
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/ctl_pf_sel
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/op543
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/alu_shift_in
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/alu_shift_right
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/alu_shift_left
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/shift_cf_out
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/alu_parity_in
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/flags_cond_true
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/pf_sel
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/alu_op_low
add wave -noupdate -group {alu
 control} /test_fuse/dut/alu_control_/alu_core_cf_in
add wave -noupdate -group {alu
 control} -radix hexadecimal /test_fuse/dut/alu_control_/db
add wave -noupdate -group {alu
 control} -radix hexadecimal /test_fuse/dut/alu_control_/out
add wave -noupdate -group {alu
 control} -radix hexadecimal /test_fuse/dut/alu_control_/sel
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_oe
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_bus
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_alu
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/alu_sf_out
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/alu_yf_out
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/alu_xf_out
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_nf_set
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/alu_zero
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/shift_cf_out
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/alu_core_cf_out
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/daa_cf_out
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_cf_set
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_cf_cpl
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_hf_cpl
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/pf_sel
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_cf_we
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_sz_we
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_xy_we
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_hf_we
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_pf_we
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/ctl_flags_nf_we
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/flags_sf
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/flags_zf
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/flags_pf
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/flags_cf
add wave -noupdate -group {alu flags} /test_fuse/dut/alu_flags_/flags_nf
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_oe
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_shift_oe
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_op2_oe
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_res_oe
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_op1_oe
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_bs_oe
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_op1_sel_bus
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_op1_sel_low
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_op1_sel_zero
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_op2_sel_zero
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_op2_sel_bus
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_op2_sel_lq
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_sel_op2_neg
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_sel_op2_high
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_core_R
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_core_V
add wave -noupdate -group {alu select} /test_fuse/dut/alu_select_/ctl_alu_core_S
add wave -noupdate -group {alu
} -color Green -radix hexadecimal /test_fuse/dut/alu_/OP1
add wave -noupdate -group {alu
} -color Green -radix hexadecimal /test_fuse/dut/alu_/OP2
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/RESULT
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_bs_oe
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_parity_in
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_oe
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_shift_oe
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_op2_oe
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_op1_oe
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_res_oe
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_op1_sel_low
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_op1_sel_zero
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_op1_sel_bus
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_op2_sel_zero
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_op2_sel_bus
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_op2_sel_lq
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_op_low
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_shift_in
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_sel_op2_neg
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_sel_op2_high
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_shift_left
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_shift_right
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/bsel
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_zero
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_parity_out
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_high_eq_9
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_high_gt_9
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_low_gt_9
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_shift_db0
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_shift_db7
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_sf_out
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_yf_out
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_xf_out
add wave -noupdate -group {alu
} /test_fuse/dut/alu_/alu_vf_out
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/db
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/test_db_high
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/test_db_low
add wave -noupdate -group {alu
} -color Magenta /test_fuse/dut/alu_/alu_core_R
add wave -noupdate -group {alu
} -color Magenta /test_fuse/dut/alu_/alu_core_V
add wave -noupdate -group {alu
} -color Magenta /test_fuse/dut/alu_/alu_core_S
add wave -noupdate -group {alu
} -color Magenta /test_fuse/dut/alu_/alu_core_cf_in
add wave -noupdate -group {alu
} -color Magenta -radix hexadecimal /test_fuse/dut/alu_/alu_op1
add wave -noupdate -group {alu
} -color Magenta -radix hexadecimal /test_fuse/dut/alu_/alu_op2
add wave -noupdate -group {alu
} -color Red /test_fuse/dut/alu_/alu_core_cf_out
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/result_hi
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/result_lo
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/db_high
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/db_low
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/op1_high
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/op1_low
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/op2_high
add wave -noupdate -group {alu
} -radix hexadecimal /test_fuse/dut/alu_/op2_low
add wave -noupdate -group {address latch} /test_fuse/dut/address_latch_/ctl_inc_cy
add wave -noupdate -group {address latch} /test_fuse/dut/address_latch_/ctl_inc_dec
add wave -noupdate -group {address latch} /test_fuse/dut/address_latch_/ctl_inc_zero
add wave -noupdate -group {address latch} /test_fuse/dut/address_latch_/ctl_al_we
add wave -noupdate -group {address latch} /test_fuse/dut/address_latch_/ctl_inc_limit6
add wave -noupdate -group {address latch} /test_fuse/dut/address_latch_/ctl_bus_inc_oe
add wave -noupdate -group {address latch} /test_fuse/dut/address_latch_/address_is_1
add wave -noupdate -group {address latch} /test_fuse/dut/address_latch_/ctl_apin_mux
add wave -noupdate -group {address latch} /test_fuse/dut/address_latch_/ctl_apin_mux2
add wave -noupdate -group {address latch} -radix hexadecimal /test_fuse/dut/address_latch_/abus
add wave -noupdate -group {address latch} -radix hexadecimal -childformat {{{/test_fuse/dut/address_latch_/address[15]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[14]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[13]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[12]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[11]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[10]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[9]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[8]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[7]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[6]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[5]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[4]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[3]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[2]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[1]} -radix hexadecimal} {{/test_fuse/dut/address_latch_/address[0]} -radix hexadecimal}} -subitemconfig {{/test_fuse/dut/address_latch_/address[15]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[14]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[13]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[12]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[11]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[10]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[9]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[8]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[7]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[6]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[5]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[4]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[3]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[2]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[1]} {-height 15 -radix hexadecimal} {/test_fuse/dut/address_latch_/address[0]} {-height 15 -radix hexadecimal}} /test_fuse/dut/address_latch_/address
add wave -noupdate -group {address pins} /test_fuse/dut/address_pins_/bus_ab_pin_we
add wave -noupdate -group {address pins} /test_fuse/dut/address_pins_/pin_control_oe
add wave -noupdate -group {address pins} -label apin_latch /test_fuse/dut/address_pins_/DFFE_apin_latch
add wave -noupdate -group state /test_fuse/dut/decode_state_/ctl_state_iy_set
add wave -noupdate -group state /test_fuse/dut/decode_state_/ctl_state_ixiy_clr
add wave -noupdate -group state /test_fuse/dut/decode_state_/ctl_state_ixiy_we
add wave -noupdate -group state /test_fuse/dut/decode_state_/ctl_state_halt_set
add wave -noupdate -group state /test_fuse/dut/decode_state_/ctl_state_tbl_clr
add wave -noupdate -group state /test_fuse/dut/decode_state_/ctl_state_tbl_ed_set
add wave -noupdate -group state /test_fuse/dut/decode_state_/ctl_state_tbl_cb_set
add wave -noupdate -group state /test_fuse/dut/decode_state_/ctl_state_alu
add wave -noupdate -group state /test_fuse/dut/decode_state_/address_is_1
add wave -noupdate -group state /test_fuse/dut/decode_state_/ctl_repeat_we
add wave -noupdate -group state /test_fuse/dut/decode_state_/in_intr
add wave -noupdate -group state /test_fuse/dut/decode_state_/in_nmi
add wave -noupdate -group state /test_fuse/dut/decode_state_/nreset
add wave -noupdate -group state /test_fuse/dut/decode_state_/in_halt
add wave -noupdate -group state /test_fuse/dut/decode_state_/table_cb
add wave -noupdate -group state /test_fuse/dut/decode_state_/table_ed
add wave -noupdate -group state /test_fuse/dut/decode_state_/table_xx
add wave -noupdate -group state /test_fuse/dut/decode_state_/use_ix
add wave -noupdate -group state /test_fuse/dut/decode_state_/use_ixiy
add wave -noupdate -group state /test_fuse/dut/decode_state_/in_alu
add wave -noupdate -group state /test_fuse/dut/decode_state_/repeat_en
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/intr
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/iff1
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/iff2
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/im1
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/im2
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/nmi
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/ctl_iff1_iff2
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/ctl_iffx_we
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/ctl_iffx_bit
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/ctl_im_we
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/ctl_no_ints
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/in_nmi
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/in_intr
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/int_armed
add wave -noupdate -group interrupts /test_fuse/dut/interrupts_/nmi_armed
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {Cursor {3900 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 163
configure wave -valuecolwidth 53
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits us
update
WaveRestoreZoom {0 ns} {7800 ns}
