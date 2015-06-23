
SIM_EXE=iversim.elf

all: cfi_ctrl_wb_bench cfi_engine_bench cfi_ctrl_engine_wb_bench

cfi_ctrl_engine_wb_bench:
	iverilog -f ../bin/iver.script -s cfi_ctrl_engine_wb_bench \
	../../bench/verilog/cfi_ctrl_engine_wb_bench.v -o $(SIM_EXE)
	./$(SIM_EXE)

cfi_ctrl_wb_bench:
	iverilog -f ../bin/iver.script -s cfi_ctrl_wb_bench \
	../../bench/verilog/cfi_ctrl_wb_bench.v -o $(SIM_EXE)
	./$(SIM_EXE)


cfi_engine_bench:
	iverilog -f ../bin/iver.script -s cfi_ctrl_engine_bench \
	../../bench/verilog/cfi_ctrl_engine_bench.v -o $(SIM_EXE)
	./$(SIM_EXE)


clean:
	rm -f *.* ../out/*
