onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {CPU BFM}
add wave -noupdate -format Logic /up_monitor_tb/CPU/up_clk
add wave -noupdate -format Logic /up_monitor_tb/CPU/up_csn
add wave -noupdate -format Logic /up_monitor_tb/CPU/up_wbe
add wave -noupdate -format Literal /up_monitor_tb/CPU/up_addr
add wave -noupdate -format Literal /up_monitor_tb/CPU/up_data_io
add wave -noupdate -divider {REG BFM}
add wave -noupdate -format Logic /up_monitor_tb/REG/up_clk
add wave -noupdate -format Logic /up_monitor_tb/REG/up_csn
add wave -noupdate -format Logic /up_monitor_tb/REG/up_wbe
add wave -noupdate -format Literal /up_monitor_tb/REG/up_addr
add wave -noupdate -format Literal /up_monitor_tb/REG/up_data_io
add wave -noupdate -divider MON_LO
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/up_wbe
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/up_csn
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/up_addr
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/up_data_io
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/up_clk
add wave -noupdate -divider pin-to-transaction
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/wr_en
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/rd_en
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/addr_in
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/data_in
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/wr_en_d1
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/rd_en_d1
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/inst/addr_in_d1
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/inst/data_in_d1
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/addr_mask_ok
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/trig_cond_ok_d1
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/capture_wr
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/inst/capture_in
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/clk
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/wr_en
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/data_in
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/reset
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/usedw
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/rd_en
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/data_out
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/inst/pretrig_num
add wave -noupdate -format Literal /up_monitor_tb/MON_LO/inst/pretrig_cnt
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/pretrig_full
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/pretrig_wr
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/pretrig_rd
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix unsigned /up_monitor_tb/MON_LO/inst/inter_cap_cnt
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_fifo/sld_virtual_jtag_component/user_input/vj_sim_done
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/u_virtual_jtag_adda_trig/sld_virtual_jtag_component/user_input/vj_sim_done
add wave -noupdate -format Logic /up_monitor_tb/MON_LO/inst/u_virtual_jtag_addr_mask/sld_virtual_jtag_component/user_input/vj_sim_done
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8603967 ps} 0}
configure wave -namecolwidth 147
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
WaveRestoreZoom {0 ps} {10500 ns}
