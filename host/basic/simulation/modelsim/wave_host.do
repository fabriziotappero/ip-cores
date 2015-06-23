onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_bench_host/reset
add wave -noupdate /test_bench_host/uart_tx
add wave -noupdate /test_bench_host/clk
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nM1
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nMREQ
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nIORQ
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nRD
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nWR
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nRFSH
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nHALT
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nBUSACK
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nWAIT
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nINT
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nNMI
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nRESET
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/nBUSRQ
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/CLK
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/A
add wave -noupdate -expand -group {CPU
} /test_bench_host/host_/z80_/D
add wave -noupdate -expand -group {host
} /test_bench_host/host_/A
add wave -noupdate -expand -group {host
} /test_bench_host/host_/D
add wave -noupdate -expand -group {host
} /test_bench_host/host_/RamData
add wave -noupdate -group {RAM
} /test_bench_host/host_/ram_/address
add wave -noupdate -group {RAM
} /test_bench_host/host_/ram_/clock
add wave -noupdate -group {RAM
} /test_bench_host/host_/ram_/data
add wave -noupdate -group {RAM
} /test_bench_host/host_/ram_/wren
add wave -noupdate -group {RAM
} /test_bench_host/host_/ram_/q
add wave -noupdate -group {UART
} /test_bench_host/host_/uart_io_/reset
add wave -noupdate -group {UART
} /test_bench_host/host_/uart_io_/clk
add wave -noupdate -group {UART
} /test_bench_host/host_/uart_io_/Address
add wave -noupdate -group {UART
} /test_bench_host/host_/uart_io_/Data
add wave -noupdate -group {UART
} /test_bench_host/host_/uart_io_/IORQ
add wave -noupdate -group {UART
} /test_bench_host/host_/uart_io_/RD
add wave -noupdate -group {UART
} /test_bench_host/host_/uart_io_/WR
add wave -noupdate -group {UART
} /test_bench_host/host_/uart_io_/uart_tx
add wave -noupdate -group {UART
} /test_bench_host/host_/uart_io_/busy_tx
add wave -noupdate -group {UART
} /test_bench_host/host_/uart_io_/data_in_wr
add wave -noupdate -group {UART core
} /test_bench_host/host_/uart_io_/uart_core_/BAUD
add wave -noupdate -group {UART core
} /test_bench_host/host_/uart_io_/uart_core_/uart_tx
add wave -noupdate -group {UART core
} -color Gold /test_bench_host/host_/uart_io_/uart_core_/busy_tx
add wave -noupdate -group {UART core
} /test_bench_host/host_/uart_io_/uart_core_/clk
add wave -noupdate -group {UART core
} /test_bench_host/host_/uart_io_/uart_core_/reset
add wave -noupdate -group {UART core
} /test_bench_host/host_/uart_io_/uart_core_/data_in
add wave -noupdate -group {UART core
} /test_bench_host/host_/uart_io_/uart_core_/data_in_wr
add wave -noupdate -group {UART core
} -radix hexadecimal -childformat {{{/test_bench_host/host_/uart_io_/uart_core_/baud_count[31]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[30]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[29]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[28]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[27]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[26]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[25]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[24]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[23]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[22]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[21]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[20]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[19]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[18]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[17]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[16]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[15]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[14]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[13]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[12]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[11]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[10]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[9]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[8]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[7]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[6]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[5]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[4]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[3]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[2]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[1]} -radix hexadecimal} {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[0]} -radix hexadecimal}} -subitemconfig {{/test_bench_host/host_/uart_io_/uart_core_/baud_count[31]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[30]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[29]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[28]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[27]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[26]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[25]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[24]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[23]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[22]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[21]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[20]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[19]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[18]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[17]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[16]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[15]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[14]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[13]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[12]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[11]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[10]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[9]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[8]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[7]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[6]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[5]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[4]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[3]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[2]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[1]} {-height 15 -radix hexadecimal} {/test_bench_host/host_/uart_io_/uart_core_/baud_count[0]} {-height 15 -radix hexadecimal}} /test_bench_host/host_/uart_io_/uart_core_/baud_count
add wave -noupdate -group {UART core
} /test_bench_host/host_/uart_io_/uart_core_/data
add wave -noupdate -group {UART core
} /test_bench_host/host_/uart_io_/uart_core_/state
add wave -noupdate -group {UART core
} /test_bench_host/host_/uart_io_/uart_core_/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {344787 ps} 0} {{Cursor 2} {727941 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 184
configure wave -valuecolwidth 60
configure wave -justifyvalue right
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {2113838 ps}
