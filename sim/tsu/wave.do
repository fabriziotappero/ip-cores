onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/gmii_clk
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/gmii_ctrl
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/gmii_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/nibble_h
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/gmii_ctrl_conv
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/gmii_data_conv
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/ts_req
add wave -noupdate -format Literal -radix hexadecimal /tsu_queue_tb/DUT_RX/rtc_time_stamp
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/ts_ack
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/ts_ack_clr
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/tsu_time_stamp
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/int_gmii_ctrl
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/int_gmii_data
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/int_bcnt
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/int_valid
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/int_sop
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/int_eop
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/int_data
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/int_mod
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/int_valid_d1
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/int_sop_d1
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/int_eop_d1
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/int_mod_d1
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/int_data_d1
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix unsigned /tsu_queue_tb/DUT_RX/parser/int_cnt
add wave -noupdate -format Literal -radix unsigned /tsu_queue_tb/DUT_RX/parser/bypass_ipv4_cnt
add wave -noupdate -format Literal -radix unsigned /tsu_queue_tb/DUT_RX/parser/bypass_ipv6_cnt
add wave -noupdate -format Literal -radix unsigned /tsu_queue_tb/DUT_RX/parser/bypass_udp_cnt
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/parser/bypass_vlan
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/parser/bypass_mpls
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/parser/bypass_ipv4
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/parser/bypass_ipv6
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/parser/bypass_udp
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/parser/ptp_l2
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/parser/ptp_l4
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/parser/ptp_event
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/parser/int_data_d1
add wave -noupdate -format Literal -radix unsigned /tsu_queue_tb/DUT_RX/parser/ptp_cnt
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/parser/ptp_data
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/parser/ptp_msgid
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/parser/ptp_seqid
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/parser/ptp_cksum
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/parser/ptp_found
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/parser/ptp_infor
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/q_wr_clk
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/q_wr_en
add wave -noupdate -format Literal /tsu_queue_tb/DUT_RX/q_wr_data
add wave -noupdate -format Literal -radix unsigned /tsu_queue_tb/DUT_RX/q_wrusedw
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/queue/rdclk
add wave -noupdate -format Logic /tsu_queue_tb/DUT_RX/queue/rdreq
add wave -noupdate -format Literal -radix unsigned /tsu_queue_tb/DUT_RX/queue/rdusedw
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix unsigned /tsu_queue_tb/BFM_RX/num_rx
add wave -noupdate -format Literal -radix unsigned /tsu_queue_tb/rx_ptp_event_cnt
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {381314 ps} 0}
configure wave -namecolwidth 188
configure wave -valuecolwidth 165
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
configure wave -timelineunits ns
update
WaveRestoreZoom {384590838 ps} {384971009 ps}
