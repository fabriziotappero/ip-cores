onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/error
add wave -noupdate -format Literal -radix hexadecimal /testbench/address
add wave -noupdate -format Literal -radix hexadecimal /testbench/data
add wave -noupdate -format Literal /testbench/ramsn
add wave -noupdate -format Literal /testbench/ramoen
add wave -noupdate -format Literal /testbench/rwen
add wave -noupdate -format Literal /testbench/romsn
add wave -noupdate -format Logic /testbench/iosn
add wave -noupdate -format Logic /testbench/oen
add wave -noupdate -format Logic /testbench/read
add wave -noupdate -format Logic /testbench/writen
add wave -noupdate -format Literal -radix hexadecimal /testbench/sa
add wave -noupdate -format Literal -radix hexadecimal /testbench/sd
add wave -noupdate -format Literal /testbench/sdcsn
add wave -noupdate -format Logic /testbench/sdwen
add wave -noupdate -format Logic /testbench/sdrasn
add wave -noupdate -format Logic /testbench/sdcasn
add wave -noupdate -format Literal /testbench/sddqm
add wave -noupdate -format Literal /testbench/ramben
add wave -noupdate -format Logic /testbench/dsuen
add wave -noupdate -format Logic /testbench/dsutx
add wave -noupdate -format Logic /testbench/dsurx
add wave -noupdate -format Logic /testbench/dsubre
add wave -noupdate -format Logic /testbench/dsuact
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/apbi
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/apbo
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/ahbso
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/ahbmo
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/iu0/r
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/iu0/wpr
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/iu0/dsur
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/iu0/ir
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/rfi
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/rfo
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/crami
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/cramo
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/irqi
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/irqo
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/dbgi
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/dbgo
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/ici
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/ico
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/dci
add wave -noupdate -format Literal -radix hexadecimal /testbench/leon3ax_0/l3/cpu__0/u0/p0/dco
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {139381 ps} 0}
configure wave -namecolwidth 140
configure wave -valuecolwidth 99
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
WaveRestoreZoom {0 ps} {70604530 ps}
