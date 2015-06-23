onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /altera_de_ii_demo/clk
add wave -noupdate /altera_de_ii_demo/port_out
add wave -noupdate /altera_de_ii_demo/rst_n
add wave -noupdate /altera_de_ii_demo/toggle_in
add wave -noupdate /altera_de_ii_demo/gen_to_blinkerENABLE_FROM_GEN
add wave -noupdate -radix unsigned /altera_de_ii_demo/gen_to_blinkerSIGNAL_FROM_GEN
add wave -noupdate -radix unsigned /altera_de_ii_demo/port_blinker_1/val_cnt_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {32390762 ns} 0}
configure wave -namecolwidth 557
configure wave -valuecolwidth 176
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ns} {1260000630 ns}
