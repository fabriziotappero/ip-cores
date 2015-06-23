-- ProjNav VHDL simulation template: USB_TMC_IP_tb.udo
-- You may edit this file after the line that starts with
-- '-- START' to customize your simulation
-- START user-defined simulation commands
-- ProjNav VHDL simulation template: usb_tmc_ip_tb.udo
-- You may edit this file after the line that starts with
-- '-- START' to customize your simulation
-- START user-defined simulation commands
delete wave *
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Magenta -format Logic -itemcolor Magenta -label CLK /usb_tmc_ip_tb/sim_clk
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan -label RST /usb_tmc_ip_tb/sim_rst
add wave -noupdate -format Logic -label {SIM_1 -> FLAG} /usb_tmc_ip_tb/sim_1
add wave -noupdate -color {Spring Green} -format Logic -itemcolor {Spring Green} -label WRU /usb_tmc_ip_tb/wru
add wave -noupdate -color {Spring Green} -format Logic -itemcolor {Spring Green} -label RDYU /usb_tmc_ip_tb/rdyu
add wave -noupdate -color Gold -format Logic -itemcolor Gold -label WRX /usb_tmc_ip_tb/wrx
add wave -noupdate -color Gold -format Logic -itemcolor Gold -label RDYX /usb_tmc_ip_tb/rdyx
add wave -noupdate -divider {DATA GPIF}
add wave -noupdate -format Literal -label DBUS -radix hexadecimal /usb_tmc_ip_tb/data_bus
add wave -noupdate -divider {GPIO FSM}
add wave -noupdate -color Khaki -format Literal -itemcolor Khaki -label PR_STATE /usb_tmc_ip_tb/dut/fsm_gpif/pr_state
add wave -noupdate -color Khaki -format Literal -itemcolor Khaki -label NX_STATE /usb_tmc_ip_tb/dut/fsm_gpif/nx_state
add wave -noupdate -divider {FPGA DATA BUSES}
add wave -noupdate -format Literal -label DBUS_FIFO_IN -radix hexadecimal /usb_tmc_ip_tb/dut/s_dbus_in
add wave -noupdate -format Literal -label DBUS_FIFO_OUT -radix hexadecimal /usb_tmc_ip_tb/dut/s_dbus_out
add wave -noupdate -format Literal -label OPB_FIFO_IN -radix hexadecimal /usb_tmc_ip_tb/dut/s_opb_in
add wave -noupdate -format Literal -label OPB_FIFO_OUT -radix hexadecimal /usb_tmc_ip_tb/dut/s_opb_out
add wave -noupdate -divider {U2X R/W}
add wave -noupdate -format Logic -label U2X_WR_EN /usb_tmc_ip_tb/dut/s_u2x_wr_en
add wave -noupdate -format Logic -label U2X_RD_EN /usb_tmc_ip_tb/dut/s_u2x_rd_en
add wave -noupdate -divider {LOOPBACK FSM}
add wave -noupdate -color Khaki -format Literal -itemcolor Khaki -label PR_STATE /usb_tmc_ip_tb/dut/loopback/pr_stateloop
add wave -noupdate -color Khaki -format Literal -itemcolor Khaki -label NX_STATE /usb_tmc_ip_tb/dut/loopback/nx_stateloop
add wave -noupdate -divider {U2X FIFO FLAGS}
add wave -noupdate -format Logic -label u2x_AM_empty /usb_tmc_ip_tb/dut/s_u2x_am_empty
add wave -noupdate -format Logic -label u2x_empty /usb_tmc_ip_tb/dut/s_u2x_empty
add wave -noupdate -format Logic -label u2x_full /usb_tmc_ip_tb/dut/f_in/full
add wave -noupdate -format Logic -label u2x_am_full /usb_tmc_ip_tb/dut/f_in/almost_full
add wave -noupdate -divider {X2U R/W}
add wave -noupdate -format Logic -label X2U_WR_EN /usb_tmc_ip_tb/dut/f_out/wr_en
add wave -noupdate -format Logic -label X2U_RD_EN /usb_tmc_ip_tb/dut/f_out/rd_en
add wave -noupdate -divider {X2U FIFO Flags}
add wave -noupdate -format Logic -label X2U_AM_EMPTY /usb_tmc_ip_tb/dut/f_out/almost_empty
add wave -noupdate -format Logic -label X2U_EMPTY /usb_tmc_ip_tb/dut/s_x2u_empty
add wave -noupdate -format Logic -label x2u_full /usb_tmc_ip_tb/dut/f_out/full
add wave -noupdate -format Logic -label x2u_am_full /usb_tmc_ip_tb/dut/f_out/almost_full
add wave -noupdate -color Magenta -format Logic -itemcolor Magenta -label IFCLK /usb_tmc_ip_tb/dut/i_ifclk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {630 ns} 0}
configure wave -namecolwidth 215
configure wave -valuecolwidth 127
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
WaveRestoreZoom {570 ns} {780 ns}
