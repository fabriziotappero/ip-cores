
// Title       : jpeg_top_tb
// Design      : jpeg_top


SetActiveLib -work
#Compiling UUT module design files
comp -include $DSN\src\y_huff.v
comp -include $DSN\src\y_quantizer.v
comp -include $DSN\src\y_dct.v
comp -include $DSN\src\cb_huff.v
comp -include $DSN\src\cb_quantizer.v
comp -include $DSN\src\cb_dct.v
comp -include $DSN\src\cr_huff.v
comp -include $DSN\src\cr_quantizer.v
comp -include $DSN\src\cr_dct.v
comp -include $DSN\src\yd_q_h.v
comp -include $DSN\src\cbd_q_h.v
comp -include $DSN\src\crd_q_h.v
comp -include $DSN\src\rgb2ycbcr.v
comp -include $DSN\src\sync_fifo_ff.v
comp -include $DSN\src\sync_fifo_32.v
comp -include $DSN\src\pre_fifo.v
comp -include $DSN\src\ff_checker.v
comp -include $DSN\src\fifo_out.v
comp -include $DSN\src\jpeg_top.v
comp -include "$DSN\src\TestBench\jpeg_top_TB.v"
asim jpeg_top_tb

wave
wave -noreg end_of_file_signal
wave -noreg data_in
wave -noreg clk
wave -noreg rst
wave -noreg enable
wave -noreg JPEG_bitstream
wave -noreg data_ready
wave -noreg end_of_file_bitstream_count
wave -noreg eof_data_partial_ready

run 200000000.00 ns

#End simulation macro
