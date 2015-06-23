onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/DUT/i_clk
add wave -noupdate /tb/DUT/i_rst
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group PB_MASTER /tb/DUT/i_pb_master_stb0
add wave -noupdate -expand -group PB_MASTER /tb/DUT/i_pb_master_stb1
add wave -noupdate -expand -group PB_MASTER /tb/DUT/iv_pb_master_cmd
add wave -noupdate -expand -group PB_MASTER -radix hexadecimal /tb/DUT/iv_pb_master_addr
add wave -noupdate -expand -group PB_MASTER -radix hexadecimal /tb/DUT/iv_pb_master_data
add wave -noupdate -expand -group PB_SLAVE /tb/DUT/o_pb_slave_ready
add wave -noupdate -expand -group PB_SLAVE /tb/DUT/o_pb_slave_complete
add wave -noupdate -expand -group PB_SLAVE /tb/DUT/o_pb_slave_stb0
add wave -noupdate -expand -group PB_SLAVE /tb/DUT/o_pb_slave_stb1
add wave -noupdate -expand -group PB_SLAVE -radix hexadecimal /tb/DUT/ov_pb_slave_data
add wave -noupdate -expand -group PB_SLAVE /tb/DUT/ov_pb_slave_dmar
add wave -noupdate -expand -group PB_SLAVE /tb/DUT/o_pb_slave_irq
add wave -noupdate -expand -group WB_IF -radix hexadecimal /tb/DUT/ov_wbm_addr
add wave -noupdate -expand -group WB_IF -radix hexadecimal /tb/DUT/ov_wbm_data
add wave -noupdate -expand -group WB_IF /tb/DUT/ov_wbm_sel
add wave -noupdate -expand -group WB_IF /tb/DUT/o_wbm_we
add wave -noupdate -expand -group WB_IF /tb/DUT/o_wbm_cyc
add wave -noupdate -expand -group WB_IF /tb/DUT/o_wbm_stb
add wave -noupdate -expand -group WB_IF /tb/DUT/ov_wbm_cti
add wave -noupdate -expand -group WB_IF /tb/DUT/ov_wbm_bte
add wave -noupdate -expand -group WB_IF -radix hexadecimal /tb/DUT/iv_wbm_data
add wave -noupdate -expand -group WB_IF /tb/DUT/i_wbm_ack
add wave -noupdate -expand -group WB_IF /tb/DUT/i_wbm_err
add wave -noupdate -expand -group WB_IF /tb/DUT/i_wbm_rty
add wave -noupdate -expand -group WB_IF /tb/DUT/i_wdm_irq_0
add wave -noupdate -expand -group WB_IF /tb/DUT/iv_wbm_irq_dmar
add wave -noupdate /tb/DUT/sv_wbm_fsm
add wave -noupdate /tb/DUT/sv_pb_fsm
add wave -noupdate -expand -group OUTGOING_FIFO /tb/DUT/WB_COMP_OUTGOING_FIFO/clk
add wave -noupdate -expand -group OUTGOING_FIFO /tb/DUT/WB_COMP_OUTGOING_FIFO/rst
add wave -noupdate -expand -group OUTGOING_FIFO /tb/DUT/WB_COMP_OUTGOING_FIFO/wr_en
add wave -noupdate -expand -group OUTGOING_FIFO /tb/DUT/WB_COMP_OUTGOING_FIFO/rd_en
add wave -noupdate -expand -group OUTGOING_FIFO /tb/DUT/WB_COMP_OUTGOING_FIFO/full
add wave -noupdate -expand -group OUTGOING_FIFO /tb/DUT/WB_COMP_OUTGOING_FIFO/empty
add wave -noupdate -expand -group OUTGOING_FIFO -radix hexadecimal /tb/DUT/WB_COMP_OUTGOING_FIFO/din
add wave -noupdate -expand -group OUTGOING_FIFO -radix hexadecimal /tb/DUT/WB_COMP_OUTGOING_FIFO/dout
add wave -noupdate -expand -group OUTGOING_FIFO -radix unsigned /tb/DUT/WB_COMP_OUTGOING_FIFO/data_count
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {27631191 ps} 0}
configure wave -namecolwidth 329
configure wave -valuecolwidth 115
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
WaveRestoreZoom {27506551 ps} {27783449 ps}
