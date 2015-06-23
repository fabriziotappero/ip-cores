perl uart_test_stim.pl > uart_stim.dat

ghdl -a src/txt_util.vhd
ghdl -a src/slib_clock_div.vhd
ghdl -a src/slib_counter.vhd
ghdl -a src/slib_edge_detect.vhd
ghdl -a src/slib_fifo.vhd
ghdl -a src/slib_input_filter.vhd
ghdl -a src/slib_input_sync.vhd
ghdl -a src/slib_mv_filter.vhd
ghdl -a src/uart_baudgen.vhd
ghdl -a src/uart_interrupt.vhd
ghdl -a src/uart_receiver.vhd
ghdl -a src/uart_transmitter.vhd
ghdl -a src/wb8_uart_16750.vhd
ghdl -a src/wb8_uart_package.vhd
ghdl -a --ieee=synopsys src/wb8_uart_transactor.vhd

ghdl -e --ieee=synopsys uart_transactor
ghdl -r uart_transactor tb --stop-time=1000ms

