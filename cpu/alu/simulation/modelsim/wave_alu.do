onerror {resume}
quietly virtual signal -install /test_alu { (context /test_alu )&{test_db_low ,test_db_high }} test_bus
quietly virtual signal -install /test_alu { (context /test_alu )&{test_db_high ,test_db_low }} test_bus001
quietly virtual function -install /test_alu/alu_inst -env /test_alu { &{/test_alu/alu_inst/op1_high, /test_alu/alu_inst/op1_low }} OP1
quietly virtual function -install /test_alu/alu_inst -env /test_alu { &{/test_alu/alu_inst/op2_high, /test_alu/alu_inst/op2_low }} OP2
quietly virtual function -install /test_alu/alu_inst -env /test_alu { &{/test_alu/alu_inst/result_hi, /test_alu/alu_inst/result_lo }} RESULT
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal -childformat {{{/test_alu/db_w[7]} -radix hexadecimal} {{/test_alu/db_w[6]} -radix hexadecimal} {{/test_alu/db_w[5]} -radix hexadecimal} {{/test_alu/db_w[4]} -radix hexadecimal} {{/test_alu/db_w[3]} -radix hexadecimal} {{/test_alu/db_w[2]} -radix hexadecimal} {{/test_alu/db_w[1]} -radix hexadecimal} {{/test_alu/db_w[0]} -radix hexadecimal}} -subitemconfig {{/test_alu/db_w[7]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db_w[6]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db_w[5]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db_w[4]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db_w[3]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db_w[2]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db_w[1]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db_w[0]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal}} /test_alu/db_w
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal -childformat {{{/test_alu/db[7]} -radix hexadecimal} {{/test_alu/db[6]} -radix hexadecimal} {{/test_alu/db[5]} -radix hexadecimal} {{/test_alu/db[4]} -radix hexadecimal} {{/test_alu/db[3]} -radix hexadecimal} {{/test_alu/db[2]} -radix hexadecimal} {{/test_alu/db[1]} -radix hexadecimal} {{/test_alu/db[0]} -radix hexadecimal}} -subitemconfig {{/test_alu/db[7]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db[6]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db[5]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db[4]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db[3]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db[2]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db[1]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal} {/test_alu/db[0]} {-color Gold -height 15 -itemcolor Gold -radix hexadecimal}} /test_alu/db
add wave -noupdate -color {Medium Orchid} -itemcolor Gold -label test_bus -radix hexadecimal -childformat {{{/test_alu/test_bus001[7]} -radix hexadecimal} {{/test_alu/test_bus001[6]} -radix hexadecimal} {{/test_alu/test_bus001[5]} -radix hexadecimal} {{/test_alu/test_bus001[4]} -radix hexadecimal} {{/test_alu/test_bus001[3]} -radix hexadecimal} {{/test_alu/test_bus001[2]} -radix hexadecimal} {{/test_alu/test_bus001[1]} -radix hexadecimal} {{/test_alu/test_bus001[0]} -radix hexadecimal}} -subitemconfig {{/test_alu/test_db_high[3]} {-color {Medium Orchid} -itemcolor Gold -radix hexadecimal} {/test_alu/test_db_high[2]} {-color {Medium Orchid} -itemcolor Gold -radix hexadecimal} {/test_alu/test_db_high[1]} {-color {Medium Orchid} -itemcolor Gold -radix hexadecimal} {/test_alu/test_db_high[0]} {-color {Medium Orchid} -itemcolor Gold -radix hexadecimal} {/test_alu/test_db_low[3]} {-color {Medium Orchid} -itemcolor Gold -radix hexadecimal} {/test_alu/test_db_low[2]} {-color {Medium Orchid} -itemcolor Gold -radix hexadecimal} {/test_alu/test_db_low[1]} {-color {Medium Orchid} -itemcolor Gold -radix hexadecimal} {/test_alu/test_db_low[0]} {-color {Medium Orchid} -itemcolor Gold -radix hexadecimal}} /test_alu/test_bus001
add wave -noupdate /test_alu/clk
add wave -noupdate -expand -group Registers -color Pink -radix hexadecimal /test_alu/alu_inst/alu_op1
add wave -noupdate -expand -group Registers -color Pink -radix hexadecimal /test_alu/alu_inst/alu_op2
add wave -noupdate -expand -group Registers -radix hexadecimal -childformat {{(7) -radix hexadecimal} {(6) -radix hexadecimal} {(5) -radix hexadecimal} {(4) -radix hexadecimal} {(3) -radix hexadecimal} {(2) -radix hexadecimal} {(1) -radix hexadecimal} {(0) -radix hexadecimal}} -subitemconfig {{/test_alu/alu_inst/op1_high[3]} {-radix hexadecimal} {/test_alu/alu_inst/op1_high[2]} {-radix hexadecimal} {/test_alu/alu_inst/op1_high[1]} {-radix hexadecimal} {/test_alu/alu_inst/op1_high[0]} {-radix hexadecimal} {/test_alu/alu_inst/op1_low[3]} {-radix hexadecimal} {/test_alu/alu_inst/op1_low[2]} {-radix hexadecimal} {/test_alu/alu_inst/op1_low[1]} {-radix hexadecimal} {/test_alu/alu_inst/op1_low[0]} {-radix hexadecimal}} /test_alu/alu_inst/OP1
add wave -noupdate -expand -group Registers -radix hexadecimal /test_alu/alu_inst/OP2
add wave -noupdate -radix hexadecimal /test_alu/alu_inst/result_hi
add wave -noupdate -radix hexadecimal /test_alu/alu_inst/result_lo
add wave -noupdate -expand -group {Bus control} /test_alu/alu_oe
add wave -noupdate -expand -group {Bus control} /test_alu/alu_op1_oe
add wave -noupdate -expand -group {Bus control} /test_alu/alu_op2_oe
add wave -noupdate -expand -group {Bus control} /test_alu/alu_res_oe
add wave -noupdate -expand -group {Bus control} /test_alu/alu_shift_oe
add wave -noupdate -expand -group {Bus control} /test_alu/alu_bs_oe
add wave -noupdate -expand -group {Input shifter} /test_alu/alu_shift_db0
add wave -noupdate -expand -group {Input shifter} /test_alu/alu_shift_db7
add wave -noupdate -expand -group {Input shifter} /test_alu/alu_shift_in
add wave -noupdate -expand -group {Input shifter} /test_alu/alu_shift_right
add wave -noupdate -expand -group {Input shifter} /test_alu/alu_shift_left
add wave -noupdate /test_alu/bsel
add wave -noupdate -expand -group {Operand selectors} /test_alu/alu_op1_sel_bus
add wave -noupdate -expand -group {Operand selectors} /test_alu/alu_op1_sel_low
add wave -noupdate -expand -group {Operand selectors} /test_alu/alu_op1_sel_zero
add wave -noupdate -expand -group {Operand selectors} /test_alu/alu_op2_sel_bus
add wave -noupdate -expand -group {Operand selectors} /test_alu/alu_op2_sel_lq
add wave -noupdate -expand -group {Operand selectors} /test_alu/alu_op2_sel_zero
add wave -noupdate -expand -group {ALU core} /test_alu/alu_core_R
add wave -noupdate -expand -group {ALU core} /test_alu/alu_core_S
add wave -noupdate -expand -group {ALU core} /test_alu/alu_core_V
add wave -noupdate -expand -group {ALU core} /test_alu/alu_sel_op2_neg
add wave -noupdate -expand -group {ALU core} /test_alu/alu_sel_op2_high
add wave -noupdate -expand -group {ALU core} /test_alu/alu_op_low
add wave -noupdate -expand -group Flags /test_alu/alu_core_cf_in
add wave -noupdate -expand -group Flags /test_alu/alu_core_cf_out
add wave -noupdate -expand -group Flags /test_alu/alu_parity_in
add wave -noupdate -expand -group Flags /test_alu/alu_parity_out
add wave -noupdate -expand -group Flags /test_alu/alu_zero
add wave -noupdate -expand -group Flags /test_alu/alu_vf_out
add wave -noupdate -expand -group Flags /test_alu/alu_sf_out
add wave -noupdate -expand -group Flags /test_alu/alu_xf_out
add wave -noupdate -expand -group Flags /test_alu/alu_yf_out
add wave -noupdate -expand -group Flags /test_alu/alu_low_gt_9
add wave -noupdate -expand -group Flags /test_alu/alu_high_gt_9
add wave -noupdate -expand -group Flags /test_alu/alu_high_eq_9
add wave -noupdate /test_alu/cf
add wave -noupdate /test_alu/pf
add wave -noupdate /test_alu/hf
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1800 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
configure wave -valuecolwidth 58
configure wave -justifyvalue right
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
WaveRestoreZoom {0 ns} {4800 ns}
