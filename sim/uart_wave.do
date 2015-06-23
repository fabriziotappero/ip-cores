onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /top/clk_sys
add wave -noupdate -format Logic /top/rst_p
add wave -noupdate -format Logic /top/intr_o
add wave -noupdate -format Logic /top/bench_intr_o
add wave -noupdate -format Logic /top/DUT/srx_i
add wave -noupdate -format Logic /top/DUT/stx_o
add wave -noupdate -format Literal /top/DUT/ut/um/u_register/u_reg
add wave -noupdate -format Literal /top/DUT/ut/um/u_register/fifo_trans/u_fifo
add wave -noupdate -format Literal /top/DUT/ut/um/u_register/fifo_rec/u_fifo
add wave -noupdate -format Literal /top/DUT/ut/um/u_trans/trans_codec
add wave -noupdate -format Literal /top/DUT/ut/um/u_trans/next_state
add wave -noupdate -format Literal /top/DUT/ut/um/u_rec/rec_codec
add wave -noupdate -format Literal /top/DUT/ut/um/u_rec/next_state
add wave -noupdate -format Literal /top/BENCH/ut/um/u_register/u_reg
add wave -noupdate -format Literal /top/BENCH/ut/um/u_register/fifo_trans/u_fifo
add wave -noupdate -format Literal /top/BENCH/ut/um/u_register/fifo_rec/u_fifo
add wave -noupdate -format Literal /top/BENCH/ut/um/u_trans/trans_codec
add wave -noupdate -format Literal /top/BENCH/ut/um/u_trans/next_state
add wave -noupdate -format Literal /top/BENCH/ut/um/u_rec/rec_codec
add wave -noupdate -format Literal /top/BENCH/ut/um/u_rec/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 382
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
WaveRestoreZoom {0 ps} {67582904522 ps}
