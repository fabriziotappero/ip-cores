onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_bus/clk
add wave -noupdate /test_bus/abusw
add wave -noupdate /test_bus/abus
add wave -noupdate -color Gold /test_bus/address
add wave -noupdate /test_bus/ctl_al_we
add wave -noupdate /test_bus/ctl_bus_inc_oe
add wave -noupdate /test_bus/ctl_inc_dec
add wave -noupdate /test_bus/ctl_inc_limit6
add wave -noupdate /test_bus/ctl_inc_cy
add wave -noupdate /test_bus/ctl_inc_zero
add wave -noupdate /test_bus/address_is_1
add wave -noupdate /test_bus/address_latch_/ctl_apin_mux
add wave -noupdate /test_bus/address_latch_/ctl_apin_mux2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5500 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 141
configure wave -valuecolwidth 62
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {39500 ns}
