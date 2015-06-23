onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /c2sb_soc_tb/clk
add wave -noupdate -format Logic /c2sb_soc_tb/done
add wave -noupdate -format Logic /c2sb_soc_tb/uut/mpu/reset
add wave -noupdate -format Literal -radix hexadecimal /c2sb_soc_tb/green_leds
add wave -noupdate -color Tan -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mpu/cpu_addr
add wave -noupdate -format Logic /c2sb_soc_tb/uut/mpu/cpu_vma
add wave -noupdate -format Logic /c2sb_soc_tb/uut/mpu/cpu_rd
add wave -noupdate -format Logic /c2sb_soc_tb/uut/mpu/cpu_wr
add wave -noupdate -format Logic /c2sb_soc_tb/uut/mpu/cpu_io
add wave -noupdate -color Wheat -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mpu/cpu_data_i
add wave -noupdate -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mpu/cpu_data_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4550000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 70
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
WaveRestoreZoom {1565431 ps} {2946311 ps}
