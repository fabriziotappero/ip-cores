onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Literal -radix hexadecimal /testbench/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/data
add wave -noupdate -format Logic /testbench/ramsn
add wave -noupdate -format Logic /testbench/ramoen
add wave -noupdate -format Logic /testbench/rwen
add wave -noupdate -format Literal /testbench/ramben
add wave -noupdate -format Logic /testbench/romsn
add wave -noupdate -format Logic /testbench/iosn
add wave -noupdate -format Logic /testbench/oen
add wave -noupdate -format Logic /testbench/writen
add wave -noupdate -format Logic /testbench/dsutx
add wave -noupdate -format Logic /testbench/dsurx
add wave -noupdate -format Logic /testbench/dsubre
add wave -noupdate -format Logic /testbench/dsuact
add wave -noupdate -format Logic /testbench/dsurst
add wave -noupdate -format Literal /testbench/gpio
add wave -noupdate -format Logic /testbench/txd1
add wave -noupdate -format Logic /testbench/rxd1
add wave -noupdate -format Logic /testbench/etx_clk
add wave -noupdate -format Logic /testbench/erx_clk
add wave -noupdate -format Logic /testbench/erx_dv
add wave -noupdate -format Logic /testbench/erx_er
add wave -noupdate -format Logic /testbench/erx_col
add wave -noupdate -format Logic /testbench/erx_crs
add wave -noupdate -format Logic /testbench/etx_en
add wave -noupdate -format Logic /testbench/etx_er
add wave -noupdate -format Literal /testbench/erxd
add wave -noupdate -format Literal /testbench/etxd
add wave -noupdate -format Logic /testbench/emdc
add wave -noupdate -format Logic /testbench/emdio
add wave -noupdate -format Literal /testbench/led_cfg
add wave -noupdate -format Logic /testbench/flash_byten
add wave -noupdate -format Logic /testbench/flash_rpn
add wave -noupdate -format Logic /testbench/sram_pwrdwn
add wave -noupdate -format Logic /testbench/sram_gwen
add wave -noupdate -format Logic /testbench/sram_adsc
add wave -noupdate -format Logic /testbench/sram_adsp
add wave -noupdate -format Logic /testbench/sram_adv
add wave -noupdate -format Logic /testbench/can_txd
add wave -noupdate -format Logic /testbench/can_rxd
add wave -noupdate -format Logic /testbench/ramclk
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/apbi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/apbo
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbso
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbmo
add wave -noupdate -format Logic /testbench/d3/clkm
add wave -noupdate -format Logic /testbench/d3/rstn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 150
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
update
WaveRestoreZoom {0 ps} {5250 ns}
