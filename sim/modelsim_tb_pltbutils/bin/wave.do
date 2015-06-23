onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Simulation info}
add wave -noupdate -expand /tb_pltbutils/pltbs
add wave -noupdate -divider {Expected counters}
add wave -noupdate /tb_pltbutils/expected_checks_cnt
add wave -noupdate /tb_pltbutils/expected_errors_cnt
add wave -noupdate -divider Tb
add wave -noupdate /tb_pltbutils/clk
add wave -noupdate /tb_pltbutils/clk_cnt
add wave -noupdate /tb_pltbutils/clk_cnt_clr
add wave -noupdate /tb_pltbutils/s_i
add wave -noupdate /tb_pltbutils/s_sl
add wave -noupdate /tb_pltbutils/s_slv
add wave -noupdate /tb_pltbutils/s_u
add wave -noupdate /tb_pltbutils/s_s
add wave -noupdate -divider End
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 133
configure wave -valuecolwidth 40
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
configure wave -timelineunits ps
update
WaveRestoreZoom {998488788 ps} {999322038 ps}
