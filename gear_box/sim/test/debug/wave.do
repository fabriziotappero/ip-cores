onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_top/clk_250
add wave -noupdate -radix hexadecimal /tb_top/tb_rst
add wave -noupdate -radix hexadecimal /tb_top/fifo_full
add wave -noupdate -radix hexadecimal /tb_top/fifo_empty
add wave -noupdate -radix hexadecimal /tb_top/tb_clk
add wave -noupdate -radix hexadecimal /tb_top/fifo_wr_data
add wave -noupdate -radix hexadecimal /tb_top/fifo_wr_en
add wave -noupdate -radix hexadecimal -subitemconfig {{/tb_top/fifo_rd_data[12]} {-radix hexadecimal} {/tb_top/fifo_rd_data[11]} {-radix hexadecimal} {/tb_top/fifo_rd_data[10]} {-radix hexadecimal} {/tb_top/fifo_rd_data[9]} {-radix hexadecimal} {/tb_top/fifo_rd_data[8]} {-radix hexadecimal} {/tb_top/fifo_rd_data[7]} {-radix hexadecimal} {/tb_top/fifo_rd_data[6]} {-radix hexadecimal} {/tb_top/fifo_rd_data[5]} {-radix hexadecimal} {/tb_top/fifo_rd_data[4]} {-radix hexadecimal} {/tb_top/fifo_rd_data[3]} {-radix hexadecimal} {/tb_top/fifo_rd_data[2]} {-radix hexadecimal} {/tb_top/fifo_rd_data[1]} {-radix hexadecimal} {/tb_top/fifo_rd_data[0]} {-radix hexadecimal}} /tb_top/fifo_rd_data
add wave -noupdate -radix hexadecimal /tb_top/fifo_rd_en
add wave -noupdate -radix hexadecimal /tb_top/ugb_adc_bus
add wave -noupdate -radix hexadecimal /tb_top/ugb_out
add wave -noupdate -radix hexadecimal -subitemconfig {{/tb_top/ugb_out_r[103]} {-radix hexadecimal} {/tb_top/ugb_out_r[102]} {-radix hexadecimal} {/tb_top/ugb_out_r[101]} {-radix hexadecimal} {/tb_top/ugb_out_r[100]} {-radix hexadecimal} {/tb_top/ugb_out_r[99]} {-radix hexadecimal} {/tb_top/ugb_out_r[98]} {-radix hexadecimal} {/tb_top/ugb_out_r[97]} {-radix hexadecimal} {/tb_top/ugb_out_r[96]} {-radix hexadecimal} {/tb_top/ugb_out_r[95]} {-radix hexadecimal} {/tb_top/ugb_out_r[94]} {-radix hexadecimal} {/tb_top/ugb_out_r[93]} {-radix hexadecimal} {/tb_top/ugb_out_r[92]} {-radix hexadecimal} {/tb_top/ugb_out_r[91]} {-radix hexadecimal} {/tb_top/ugb_out_r[90]} {-radix hexadecimal} {/tb_top/ugb_out_r[89]} {-radix hexadecimal} {/tb_top/ugb_out_r[88]} {-radix hexadecimal} {/tb_top/ugb_out_r[87]} {-radix hexadecimal} {/tb_top/ugb_out_r[86]} {-radix hexadecimal} {/tb_top/ugb_out_r[85]} {-radix hexadecimal} {/tb_top/ugb_out_r[84]} {-radix hexadecimal} {/tb_top/ugb_out_r[83]} {-radix hexadecimal} {/tb_top/ugb_out_r[82]} {-radix hexadecimal} {/tb_top/ugb_out_r[81]} {-radix hexadecimal} {/tb_top/ugb_out_r[80]} {-radix hexadecimal} {/tb_top/ugb_out_r[79]} {-radix hexadecimal} {/tb_top/ugb_out_r[78]} {-radix hexadecimal} {/tb_top/ugb_out_r[77]} {-radix hexadecimal} {/tb_top/ugb_out_r[76]} {-radix hexadecimal} {/tb_top/ugb_out_r[75]} {-radix hexadecimal} {/tb_top/ugb_out_r[74]} {-radix hexadecimal} {/tb_top/ugb_out_r[73]} {-radix hexadecimal} {/tb_top/ugb_out_r[72]} {-radix hexadecimal} {/tb_top/ugb_out_r[71]} {-radix hexadecimal} {/tb_top/ugb_out_r[70]} {-radix hexadecimal} {/tb_top/ugb_out_r[69]} {-radix hexadecimal} {/tb_top/ugb_out_r[68]} {-radix hexadecimal} {/tb_top/ugb_out_r[67]} {-radix hexadecimal} {/tb_top/ugb_out_r[66]} {-radix hexadecimal} {/tb_top/ugb_out_r[65]} {-radix hexadecimal} {/tb_top/ugb_out_r[64]} {-radix hexadecimal} {/tb_top/ugb_out_r[63]} {-radix hexadecimal} {/tb_top/ugb_out_r[62]} {-radix hexadecimal} {/tb_top/ugb_out_r[61]} {-radix hexadecimal} {/tb_top/ugb_out_r[60]} {-radix hexadecimal} {/tb_top/ugb_out_r[59]} {-radix hexadecimal} {/tb_top/ugb_out_r[58]} {-radix hexadecimal} {/tb_top/ugb_out_r[57]} {-radix hexadecimal} {/tb_top/ugb_out_r[56]} {-radix hexadecimal} {/tb_top/ugb_out_r[55]} {-radix hexadecimal} {/tb_top/ugb_out_r[54]} {-radix hexadecimal} {/tb_top/ugb_out_r[53]} {-radix hexadecimal} {/tb_top/ugb_out_r[52]} {-radix hexadecimal} {/tb_top/ugb_out_r[51]} {-radix hexadecimal} {/tb_top/ugb_out_r[50]} {-radix hexadecimal} {/tb_top/ugb_out_r[49]} {-radix hexadecimal} {/tb_top/ugb_out_r[48]} {-radix hexadecimal} {/tb_top/ugb_out_r[47]} {-radix hexadecimal} {/tb_top/ugb_out_r[46]} {-radix hexadecimal} {/tb_top/ugb_out_r[45]} {-radix hexadecimal} {/tb_top/ugb_out_r[44]} {-radix hexadecimal} {/tb_top/ugb_out_r[43]} {-radix hexadecimal} {/tb_top/ugb_out_r[42]} {-radix hexadecimal} {/tb_top/ugb_out_r[41]} {-radix hexadecimal} {/tb_top/ugb_out_r[40]} {-radix hexadecimal} {/tb_top/ugb_out_r[39]} {-radix hexadecimal} {/tb_top/ugb_out_r[38]} {-radix hexadecimal} {/tb_top/ugb_out_r[37]} {-radix hexadecimal} {/tb_top/ugb_out_r[36]} {-radix hexadecimal} {/tb_top/ugb_out_r[35]} {-radix hexadecimal} {/tb_top/ugb_out_r[34]} {-radix hexadecimal} {/tb_top/ugb_out_r[33]} {-radix hexadecimal} {/tb_top/ugb_out_r[32]} {-radix hexadecimal} {/tb_top/ugb_out_r[31]} {-radix hexadecimal} {/tb_top/ugb_out_r[30]} {-radix hexadecimal} {/tb_top/ugb_out_r[29]} {-radix hexadecimal} {/tb_top/ugb_out_r[28]} {-radix hexadecimal} {/tb_top/ugb_out_r[27]} {-radix hexadecimal} {/tb_top/ugb_out_r[26]} {-radix hexadecimal} {/tb_top/ugb_out_r[25]} {-radix hexadecimal} {/tb_top/ugb_out_r[24]} {-radix hexadecimal} {/tb_top/ugb_out_r[23]} {-radix hexadecimal} {/tb_top/ugb_out_r[22]} {-radix hexadecimal} {/tb_top/ugb_out_r[21]} {-radix hexadecimal} {/tb_top/ugb_out_r[20]} {-radix hexadecimal} {/tb_top/ugb_out_r[19]} {-radix hexadecimal} {/tb_top/ugb_out_r[18]} {-radix hexadecimal} {/tb_top/ugb_out_r[17]} {-radix hexadecimal} {/tb_top/ugb_out_r[16]} {-radix hexadecimal} {/tb_top/ugb_out_r[15]} {-radix hexadecimal} {/tb_top/ugb_out_r[14]} {-radix hexadecimal} {/tb_top/ugb_out_r[13]} {-radix hexadecimal} {/tb_top/ugb_out_r[12]} {-radix hexadecimal} {/tb_top/ugb_out_r[11]} {-radix hexadecimal} {/tb_top/ugb_out_r[10]} {-radix hexadecimal} {/tb_top/ugb_out_r[9]} {-radix hexadecimal} {/tb_top/ugb_out_r[8]} {-radix hexadecimal} {/tb_top/ugb_out_r[7]} {-radix hexadecimal} {/tb_top/ugb_out_r[6]} {-radix hexadecimal} {/tb_top/ugb_out_r[5]} {-radix hexadecimal} {/tb_top/ugb_out_r[4]} {-radix hexadecimal} {/tb_top/ugb_out_r[3]} {-radix hexadecimal} {/tb_top/ugb_out_r[2]} {-radix hexadecimal} {/tb_top/ugb_out_r[1]} {-radix hexadecimal} {/tb_top/ugb_out_r[0]} {-radix hexadecimal}} /tb_top/ugb_out_r
add wave -noupdate -radix hexadecimal -subitemconfig {{/tb_top/dbg_ugb_shift[7]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[6]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[5]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[4]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[3]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[2]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[1]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[0]} {-height 15 -radix hexadecimal}} -expand -subitemconfig {{/tb_top/dbg_ugb_shift[7]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[6]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[5]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[4]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[3]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[2]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[1]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_shift[0]} {-height 15 -radix hexadecimal}} /tb_top/dbg_ugb_shift
add wave -noupdate -radix hexadecimal -subitemconfig {{/tb_top/dbg_ugb_out[12]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[11]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[10]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[9]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[8]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[7]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[6]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[5]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[4]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[3]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[2]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[1]} {-radix hexadecimal} {/tb_top/dbg_ugb_out[0]} {-radix hexadecimal}} /tb_top/dbg_ugb_out
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/fifo_clock
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/fifo_wr_data
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/fifo_wr_en
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/fifo_full
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/fifo_rd_en
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/fifo_rd_data
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/fifo_empty
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/fifo_reset
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/wr_en
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/wr_ptr
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/rd_en
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/rd_ptr
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/ptr_are_equal
add wave -noupdate -radix hexadecimal /tb_top/i_sync_fifo/ptr_msb_are_equal
add wave -noupdate -radix hexadecimal -subitemconfig {{/tb_top/i_sync_fifo/reg_file[3]} {-height 15 -radix hexadecimal} {/tb_top/i_sync_fifo/reg_file[2]} {-height 15 -radix hexadecimal} {/tb_top/i_sync_fifo/reg_file[1]} {-height 15 -radix hexadecimal} {/tb_top/i_sync_fifo/reg_file[0]} {-height 15 -radix hexadecimal}} -expand -subitemconfig {{/tb_top/i_sync_fifo/reg_file[3]} {-height 15 -radix hexadecimal} {/tb_top/i_sync_fifo/reg_file[2]} {-height 15 -radix hexadecimal} {/tb_top/i_sync_fifo/reg_file[1]} {-height 15 -radix hexadecimal} {/tb_top/i_sync_fifo/reg_file[0]} {-height 15 -radix hexadecimal}} /tb_top/i_sync_fifo/reg_file
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/adc_bus
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/out
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/clk_250
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/sys_reset
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/adc_bus_bank_select
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/gear_select
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/ugb_enable
add wave -noupdate -radix hexadecimal -subitemconfig {{/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[12]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[11]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[10]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[9]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[8]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[7]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[6]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[5]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[4]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[3]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[2]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[1]} {-radix hexadecimal} {/tb_top/i_unbuffered_gear_box/adc_bus_b0_r[0]} {-radix hexadecimal}} /tb_top/i_unbuffered_gear_box/adc_bus_b0_r
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/adc_bus_b1_r
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/adc_bus_b0_w
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/adc_bus_b1_w
add wave -noupdate -radix hexadecimal /tb_top/i_unbuffered_gear_box/adc_bus_mux
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal -subitemconfig {{/tb_top/dbg_ugb_pixels_out_r[7]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[6]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[5]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[4]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[3]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[2]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[1]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[0]} {-height 15 -radix hexadecimal}} -expand -subitemconfig {{/tb_top/dbg_ugb_pixels_out_r[7]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[6]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[5]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[4]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[3]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[2]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[1]} {-height 15 -radix hexadecimal} {/tb_top/dbg_ugb_pixels_out_r[0]} {-height 15 -radix hexadecimal}} /tb_top/dbg_ugb_pixels_out_r
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /tb_top/tb_rst
add wave -noupdate -radix hexadecimal /tb_top/fifo_wr_data
add wave -noupdate -radix hexadecimal /tb_top/fifo_wr_en
add wave -noupdate -radix hexadecimal /tb_top/fifo_full
add wave -noupdate -radix hexadecimal -subitemconfig {{/tb_top/fifo_rd_data[12]} {-radix hexadecimal} {/tb_top/fifo_rd_data[11]} {-radix hexadecimal} {/tb_top/fifo_rd_data[10]} {-radix hexadecimal} {/tb_top/fifo_rd_data[9]} {-radix hexadecimal} {/tb_top/fifo_rd_data[8]} {-radix hexadecimal} {/tb_top/fifo_rd_data[7]} {-radix hexadecimal} {/tb_top/fifo_rd_data[6]} {-radix hexadecimal} {/tb_top/fifo_rd_data[5]} {-radix hexadecimal} {/tb_top/fifo_rd_data[4]} {-radix hexadecimal} {/tb_top/fifo_rd_data[3]} {-radix hexadecimal} {/tb_top/fifo_rd_data[2]} {-radix hexadecimal} {/tb_top/fifo_rd_data[1]} {-radix hexadecimal} {/tb_top/fifo_rd_data[0]} {-radix hexadecimal}} /tb_top/fifo_rd_data
add wave -noupdate -radix hexadecimal /tb_top/fifo_rd_en
add wave -noupdate -radix hexadecimal /tb_top/fifo_empty
add wave -noupdate -radix hexadecimal /tb_top/bank_sel
add wave -noupdate -radix unsigned /tb_top/gear
add wave -noupdate -radix hexadecimal /tb_top/gear_box_out
add wave -noupdate -radix hexadecimal /tb_top/clk_250
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {43950 ps} 0}
configure wave -namecolwidth 197
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
WaveRestoreZoom {0 ps} {890400 ps}
