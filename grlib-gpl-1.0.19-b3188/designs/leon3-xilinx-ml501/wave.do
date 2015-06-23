onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/sys_clk
add wave -noupdate -format Logic /testbench/sys_rst_in
add wave -noupdate -format Literal -radix hexadecimal /testbench/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/data
add wave -noupdate -format Logic /testbench/sram_cen
add wave -noupdate -format Literal /testbench/sram_bw
add wave -noupdate -format Logic /testbench/sram_flash_we_n
add wave -noupdate -format Logic /testbench/sram_clk
add wave -noupdate -format Logic /testbench/sram_clk_fb
add wave -noupdate -format Logic /testbench/sram_mode
add wave -noupdate -format Logic /testbench/sram_adv_ld_n
add wave -noupdate -format Literal /testbench/ddr_clk
add wave -noupdate -format Literal /testbench/ddr_clkb
add wave -noupdate -format Literal /testbench/ddr_cke
add wave -noupdate -format Literal /testbench/ddr_csb
add wave -noupdate -format Logic /testbench/ddr_web
add wave -noupdate -format Logic /testbench/ddr_rasb
add wave -noupdate -format Logic /testbench/ddr_casb
add wave -noupdate -format Literal /testbench/ddr_dm
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_dq
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_ad
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_ba
add wave -noupdate -divider {CPU 1}
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/apbi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/apbo
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbso
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /testbench/cpu/ahbmo
add wave -noupdate -format Logic /testbench/cpu/phy_gtx_clk
add wave -noupdate -format Literal /testbench/cpu/cgi
add wave -noupdate -format Literal /testbench/cpu/cgi2
add wave -noupdate -format Literal /testbench/cpu/cgo
add wave -noupdate -format Literal /testbench/cpu/cgo2
add wave -noupdate -format Logic /testbench/cpu/ps2_mouse_clk
add wave -noupdate -format Logic /testbench/cpu/ps2_mouse_data
add wave -noupdate -format Literal /testbench/cpu/clk_sel
add wave -noupdate -format Literal /testbench/cpu/clkval
add wave -noupdate -format Logic /testbench/cpu/clkvga
add wave -noupdate -format Logic /testbench/cpu/clk1x
add wave -noupdate -format Logic /testbench/cpu/video_clk
add wave -noupdate -format Logic /testbench/cpu/dac_clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {52212589 ps} 0}
configure wave -namecolwidth 162
configure wave -valuecolwidth 110
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
update
WaveRestoreZoom {157518816 ps} {158016606 ps}
