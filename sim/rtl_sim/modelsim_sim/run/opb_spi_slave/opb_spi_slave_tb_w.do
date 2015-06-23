onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider OPB-Bus
add wave -noupdate -format Logic /opb_spi_slave_tb/opb_rst
add wave -noupdate -format Literal -radix hexadecimal /opb_spi_slave_tb/opb_abus
add wave -noupdate -format Literal /opb_spi_slave_tb/opb_be
add wave -noupdate -format Logic /opb_spi_slave_tb/opb_clk
add wave -noupdate -format Literal -radix hexadecimal /opb_spi_slave_tb/opb_dbus
add wave -noupdate -format Logic /opb_spi_slave_tb/opb_rnw
add wave -noupdate -format Logic /opb_spi_slave_tb/opb_select
add wave -noupdate -format Logic /opb_spi_slave_tb/opb_seqaddr
add wave -noupdate -format Literal -radix hexadecimal /opb_spi_slave_tb/sln_dbus
add wave -noupdate -format Logic /opb_spi_slave_tb/sln_xferack
add wave -noupdate -divider SPI
add wave -noupdate -format Logic /opb_spi_slave_tb/sclk
add wave -noupdate -format Logic /opb_spi_slave_tb/ss_n
add wave -noupdate -format Logic /opb_spi_slave_tb/mosi
add wave -noupdate -format Logic /opb_spi_slave_tb/miso
add wave -noupdate -divider Internal
add wave -noupdate -format Literal /opb_spi_slave_tb/opb_read_data
add wave -noupdate -format Literal /opb_spi_slave_tb/dut/rx_fifo_1/dout
add wave -noupdate -format Literal -radix hexadecimal /opb_spi_slave_tb/dut/tx_thresh
add wave -noupdate -format Literal -radix hexadecimal /opb_spi_slave_tb/dut/rx_thresh
add wave -noupdate -format Literal /opb_spi_slave_tb/spi_value_in
add wave -noupdate -divider TX_FIFO
add wave -noupdate -format Literal /opb_spi_slave_tb/dut/tx_fifo_1/prog_full_thresh
add wave -noupdate -format Literal /opb_spi_slave_tb/dut/tx_fifo_1/prog_empty_thresh
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/tx_fifo_1/wr_clk
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/tx_fifo_1/wr_en
add wave -noupdate -format Literal -radix hexadecimal /opb_spi_slave_tb/dut/tx_fifo_1/din
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/tx_fifo_1/prog_empty
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/tx_fifo_1/empty
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/tx_fifo_1/underflow
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/tx_fifo_1/prog_full
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/tx_fifo_1/full
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/tx_fifo_1/overflow
add wave -noupdate -divider RX_FIFO
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/rx_fifo_1/wr_clk
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/rx_fifo_1/wr_en
add wave -noupdate -format Literal /opb_spi_slave_tb/dut/rx_fifo_1/din
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/rx_fifo_1/empty
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/rx_fifo_1/prog_empty
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/rx_fifo_1/underflow
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/rx_fifo_1/prog_full
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/rx_fifo_1/full
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/rx_fifo_1/overflow
add wave -noupdate -divider Internal
add wave -noupdate -format Logic /opb_spi_slave_tb/dut/opb_abort_flg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {525982512 ps} 0}
configure wave -namecolwidth 302
configure wave -valuecolwidth 53
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
WaveRestoreZoom {0 ps} {568438500 ps}
