onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/error
add wave -noupdate -format Literal -radix hexadecimal /testbench/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/data
add wave -noupdate -format Literal /testbench/romsn
add wave -noupdate -format Logic /testbench/iosn
add wave -noupdate -format Logic /testbench/oen
add wave -noupdate -format Logic /testbench/writen
add wave -noupdate -format Logic /testbench/ssram_ce3n
add wave -noupdate -format Logic /testbench/ssram_wen
add wave -noupdate -format Literal /testbench/ssram_bw
add wave -noupdate -format Logic /testbench/ssram_oen
add wave -noupdate -format Literal -radix hexadecimal /testbench/ssaddr
add wave -noupdate -format Literal -radix hexadecimal /testbench/ssdata
add wave -noupdate -format Logic /testbench/ssram_clk
add wave -noupdate -format Logic /testbench/ddr_cke
add wave -noupdate -format Logic /testbench/ddr_clk
add wave -noupdate -format Logic /testbench/ddr_clkb
add wave -noupdate -format Logic /testbench/ddr_csb
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_ba
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_ad
add wave -noupdate -format Literal /testbench/ddr_dm
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_dq
add wave -noupdate -format Literal -expand /testbench/ddr_dqs
add wave -noupdate -format Logic /testbench/ddr_rasb
add wave -noupdate -format Logic /testbench/ddr_casb
add wave -noupdate -format Logic /testbench/ddr_web
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
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbso
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/d3/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /testbench/d3/ahbmo
add wave -noupdate -format Literal -radix hexadecimal /testbench/from_ata
add wave -noupdate -format Literal -radix hexadecimal /testbench/to_ata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {119390198 ps} 0}
configure wave -namecolwidth 189
configure wave -valuecolwidth 121
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
WaveRestoreZoom {120003641 ps} {120240617 ps}
