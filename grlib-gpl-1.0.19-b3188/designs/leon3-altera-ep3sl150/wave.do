onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/error
add wave -noupdate -format Literal -radix hexadecimal /testbench/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/data
add wave -noupdate -format Logic /testbench/sram_clk
add wave -noupdate -format Logic /testbench/sram_csn
add wave -noupdate -format Logic /testbench/sram_wen
add wave -noupdate -format Literal /testbench/sram_ben
add wave -noupdate -format Logic /testbench/sram_oen
add wave -noupdate -format Logic /testbench/flash_resetn
add wave -noupdate -format Logic /testbench/flash_clk
add wave -noupdate -format Logic /testbench/flash_cen
add wave -noupdate -format Logic /testbench/flash_wen
add wave -noupdate -format Logic /testbench/flash_oen
add wave -noupdate -format Literal /testbench/ddr_clk
add wave -noupdate -format Literal /testbench/ddr_clkb
add wave -noupdate -format Literal /testbench/ddr_cke
add wave -noupdate -format Literal /testbench/ddr_odt
add wave -noupdate -format Literal /testbench/ddr_csb
add wave -noupdate -format Literal /testbench/ddr_ba
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_ad
add wave -noupdate -format Logic -radix hexadecimal /testbench/ddr_rasb
add wave -noupdate -format Logic -radix hexadecimal /testbench/ddr_casb
add wave -noupdate -format Logic -radix hexadecimal /testbench/ddr_web
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_dm
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_dqsp
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_dqsn
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_dq
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_dq2
add wave -noupdate -divider {CPU 1}
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/ici
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/ico
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/dci
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/dco
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/rfi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/rfo
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/irqi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/irqo
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/dbgi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/dbgo
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/r
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/wpr
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/dsur
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/p0/iu0/ir
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/cmem0/crami
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/l3/cpu__0/u0/cmem0/cramo
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/mg2/sr1/r
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbso
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbmo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {119390198 ps} 0}
configure wave -namecolwidth 349
configure wave -valuecolwidth 206
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
WaveRestoreZoom {120003641 ps} {122090610 ps}
