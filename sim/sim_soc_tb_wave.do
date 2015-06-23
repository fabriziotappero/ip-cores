onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /l80soc_tb/clk
add wave -noupdate -expand -group {CPU MEM/IO}
add wave -noupdate -group {CPU MEM/IO} -format Literal -radix hexadecimal /l80soc_tb/soc/cpu/addr_out
add wave -noupdate -group {CPU MEM/IO} -format Literal -radix hexadecimal /l80soc_tb/soc/cpu/data_in
add wave -noupdate -group {CPU MEM/IO} -format Logic /l80soc_tb/soc/cpu_io
add wave -noupdate -group {CPU MEM/IO} -format Logic /l80soc_tb/soc/cpu_rd
add wave -noupdate -group {CPU MEM/IO} -format Logic /l80soc_tb/soc/cpu_wr
add wave -noupdate -group {CPU MEM/IO} -color Gold -format Logic /l80soc_tb/soc/cpu_fetch
add wave -noupdate -expand -group {CPU IRQ}
add wave -noupdate -group {CPU IRQ} -format Logic /l80soc_tb/soc/cpu_intr
add wave -noupdate -group {CPU IRQ} -color White -format Logic /l80soc_tb/soc/cpu_halt
add wave -noupdate -group {CPU IRQ} -format Logic /l80soc_tb/soc/cpu_inte
add wave -noupdate -group {CPU IRQ} -color White -format Logic /l80soc_tb/soc/cpu_inta
add wave -noupdate -divider UART
add wave -noupdate -format Literal -radix hexadecimal /l80soc_tb/soc/ram(331)
add wave -noupdate -group UART
add wave -noupdate -group UART -format Logic /l80soc_tb/soc/uart/rx_irq_flag
add wave -noupdate -group UART -format Logic /l80soc_tb/soc/uart/tx_irq_flag
add wave -noupdate -group UART -color Khaki -format Logic /l80soc_tb/txd
add wave -noupdate -group UART -color Wheat -format Logic /l80soc_tb/txd
add wave -noupdate -group UART -format Literal /l80soc_tb/soc/uart/status
add wave -noupdate -divider PORTS
add wave -noupdate -format Literal -radix binary /l80soc_tb/p2out
add wave -noupdate -divider {IRQ CON}
add wave -noupdate -format Literal /l80soc_tb/soc/extint
add wave -noupdate -format Literal /l80soc_tb/soc/irq_control/irq_level
add wave -noupdate -format Literal /l80soc_tb/soc/irq_control/irq_pending_reg
add wave -noupdate -format Literal /l80soc_tb/soc/irq_control/irq_trigger
add wave -noupdate -format Literal /l80soc_tb/soc/irq_control/irq_clear
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2052730000 ps} 0} {{Cursor 2} {2000630000 ps} 0}
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
WaveRestoreZoom {14374987 ps} {26369738 ps}
