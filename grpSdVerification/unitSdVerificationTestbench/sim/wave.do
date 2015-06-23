onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -divider -noupdate CardInterface
add wave -noupdate /Testbed/CardInterface/*
add wave -divider -noupdate IWbBus
add wave -noupdate /Testbed/IWbBus/*
add wave -divider -noupdate sdcontroller_inst
add wave -noupdate /Testbed/top/sdclkdomain_inst/sdcontroller_inst/*
add wave -divider -noupdate sdcmd_inst
add wave -noupdate /Testbed/top/sdclkdomain_inst/sdcmd_inst/*
add wave -divider -noupdate sddata_inst
add wave -noupdate /Testbed/top/sdclkdomain_inst/sddata_inst/*
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2496665 ns} 0} {{Cursor 2} {6033878 ns} 0} {{Cursor 3} {18655442 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {21 ms}
