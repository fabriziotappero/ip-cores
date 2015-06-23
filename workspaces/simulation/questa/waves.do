configure wave -signalnamewidth 1

add wave -position end  sim:/testbench/clk
add wave -position end  sim:/testbench/reset
add wave -position end  sim:/testbench/fifoInterface.writeRequest
add wave -position end  sim:/testbench/fifoInterface.readRequest
add wave -position end  sim:/testbench/memoryDepth
add wave -position end -hexadecimal -expand sim:/testbench/fifoInterface.writeRequest
add wave -position end -hexadecimal -expand sim:/testbench/duv/i_writeRequest
add wave -position end  sim:/testbench/duv/writeRequested
add wave -position end -hexadecimal sim:/testbench/fifoInterface.writeResponse
add wave -position end -hexadecimal -expand sim:/testbench/fifoInterface.readRequest
add wave -position end -hexadecimal -expand sim:/testbench/duv/i_readRequest
add wave -position end  sim:/testbench/duv/readRequested
add wave -position end -hexadecimal sim:/testbench/fifoInterface.readResponse
add wave -position end -hexadecimal sim:/testbench/duv/ptr
add wave -position end -decimal sim:/testbench/duv/fifoCtrl.pctFilled
add wave -position end  sim:/testbench/duv/write
add wave -position end  sim:/testbench/duv/read
add wave -position end  sim:/testbench/duv/fifoCtrl.nearFull
add wave -position end  sim:/testbench/duv/fifoCtrl.full
add wave -position end  sim:/testbench/duv/fifoCtrl.nearEmpty
add wave -position end  sim:/testbench/duv/fifoCtrl.empty
add wave -position end  sim:/testbench/duv/fifoCtrl.overflow
add wave -position end  sim:/testbench/duv/fifoCtrl.underflow
add wave -position end -hexadecimal sim:/testbench/duv/memory

run 80 ns;

wave zoomfull
#.wave.tree zoomfull	# with some versions of ModelSim
