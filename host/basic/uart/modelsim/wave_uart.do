onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {test
} /test_uart/clk
add wave -noupdate -expand -group {test
} /test_uart/reset
add wave -noupdate -expand -group {test
} /test_uart/Address
add wave -noupdate -expand -group {test
} /test_uart/Data_wr
add wave -noupdate -expand -group {test
} /test_uart/Data_rd
add wave -noupdate -expand -group {test
} /test_uart/IORQ
add wave -noupdate -expand -group {test
} /test_uart/RD
add wave -noupdate -expand -group {test
} /test_uart/WR
add wave -noupdate -expand -group {UART core
} -radix decimal /test_uart/uart_io/uart_core_/BAUD
add wave -noupdate -expand -group {UART core
} /test_uart/uart_io/uart_core_/uart_tx
add wave -noupdate -expand -group {UART core
} -color Magenta /test_uart/uart_io/uart_core_/busy_tx
add wave -noupdate -expand -group {UART core
} /test_uart/uart_io/uart_core_/clk
add wave -noupdate -expand -group {UART core
} /test_uart/uart_io/uart_core_/reset
add wave -noupdate -expand -group {UART core
} /test_uart/uart_io/uart_core_/data_in
add wave -noupdate -expand -group {UART core
} /test_uart/uart_io/uart_core_/data_in_wr
add wave -noupdate -expand -group {UART core
} -radix decimal /test_uart/uart_io/uart_core_/baud_count
add wave -noupdate -expand -group {UART core
} /test_uart/uart_io/uart_core_/data
add wave -noupdate -expand -group {UART core
} /test_uart/uart_io/uart_core_/state
add wave -noupdate -expand -group {UART core
} /test_uart/uart_io/uart_core_/next_state
add wave -noupdate -expand -group {UART IO
} /test_uart/uart_io/reset
add wave -noupdate -expand -group {UART IO
} /test_uart/uart_io/clk
add wave -noupdate -expand -group {UART IO
} /test_uart/uart_io/Address
add wave -noupdate -expand -group {UART IO
} /test_uart/uart_io/Data
add wave -noupdate -expand -group {UART IO
} /test_uart/uart_io/IORQ
add wave -noupdate -expand -group {UART IO
} /test_uart/uart_io/RD
add wave -noupdate -expand -group {UART IO
} /test_uart/uart_io/WR
add wave -noupdate -expand -group {UART IO
} /test_uart/uart_io/uart_tx
add wave -noupdate -expand -group {UART IO
} -color Magenta /test_uart/uart_io/busy_tx
add wave -noupdate -expand -group {UART IO
} /test_uart/uart_io/data_in_wr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {700 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 164
configure wave -valuecolwidth 100
configure wave -justifyvalue right
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits us
update
WaveRestoreZoom {200 ns} {10600 ns}
