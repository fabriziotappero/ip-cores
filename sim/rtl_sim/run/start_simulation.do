perl sim/create_uart_stim.pl > sim/uart_stim.dat
vsim uart_transactor
do sim/tb_uart_wave.do
run
