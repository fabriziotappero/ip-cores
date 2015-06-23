onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tbtimeoutgenerator/clk
add wave -noupdate -format Logic /tbtimeoutgenerator/resetsync
add wave -noupdate -format Logic /tbtimeoutgenerator/done
add wave -noupdate -format Logic /tbtimeoutgenerator/timeout
add wave -noupdate -format Logic /tbtimeoutgenerator/enable
add wave -noupdate -format Literal /tbtimeoutgenerator/dut/gclkfrequency
add wave -noupdate -format Literal /tbtimeoutgenerator/dut/gtimeouttime
add wave -noupdate -format Logic /tbtimeoutgenerator/dut/iclk
add wave -noupdate -format Logic /tbtimeoutgenerator/dut/inresetasync
add wave -noupdate -format Logic /tbtimeoutgenerator/dut/ienable
add wave -noupdate -format Logic /tbtimeoutgenerator/dut/otimeout
add wave -noupdate -format Literal -radix unsigned /tbtimeoutgenerator/dut/counter
add wave -noupdate -format Logic /tbtimeoutgenerator/dut/enabled
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {300000200 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {299998728 ns} {300002066 ns}
