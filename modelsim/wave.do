onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_leros/cpu/fd/clk
add wave -noupdate -radix hexadecimal /tb_leros/cpu/fd/reset
add wave -noupdate -radix hexadecimal /tb_leros/ioout
add wave -noupdate -radix hexadecimal /tb_leros/ioin
add wave -noupdate -radix hexadecimal /tb_leros/cpu/fd/pc
add wave -noupdate -radix hexadecimal -expand -subitemconfig {/tb_leros/cpu/fd/din.accu {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/din.dm_data {-radix hexadecimal}} /tb_leros/cpu/fd/din
add wave -noupdate -radix hexadecimal -expand -subitemconfig {/tb_leros/cpu/fd/dout.dec {-height 15 -radix hexadecimal -expand} /tb_leros/cpu/fd/dout.dec.op {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.al_ena {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.ah_ena {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.log_add {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.add_sub {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.shr {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.sel_imm {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.store {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.outp {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.inp {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.indls {-radix hexadecimal} /tb_leros/cpu/fd/dout.dec.br_op {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dec.loadh {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.imm {-height 15 -radix hexadecimal} /tb_leros/cpu/fd/dout.dm_addr {-radix hexadecimal}} /tb_leros/cpu/fd/dout
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/din
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/dout
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/accu
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/opd
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/log
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/arith
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/a_mux
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/dm
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/wrdata
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/rddata
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/wraddr
add wave -noupdate -radix hexadecimal /tb_leros/cpu/ex/rdaddr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {84126 ps} 0}
configure wave -namecolwidth 195
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
WaveRestoreZoom {0 ps} {210 ns}
