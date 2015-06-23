VERILOG_FILES = ./../../../rtl/verilog/versatile_library.v
INC_DIR = ./../../../rtl/verilog

tb_wb_b3_ram_be:
	vppreproc --noline --noblank +define+SYSTEMVERILOG +define+WB_B3_RAM_BE $(VERILOG_FILES) > wb_b3_ram_be.v
	vlog -reportprogress 300 -work work /home/michael/work/ocsvn/versatile_library/trunk/sim/rtl_sim/run/wb_b3_ram_be.v
	vlog -reportprogress 300 -work work /home/michael/work/ocsvn/versatile_library/trunk/bench/wbm.v
	vlog -reportprogress 300 -work work /home/michael/work/ocsvn/versatile_library/trunk/bench/tb_wb_b3_ram_be.v
	vsim -do "run 10 us" -l log.txt -c work.vl_wb_b3_ram_be_tb

tb_wb_b3_dpram:
	vppreproc --noline --noblank +define+SYSTEMVERILOG +define+WB_B3_DPRAM $(VERILOG_FILES) > wb_b3_dpram.v
	vlog -reportprogress 300 -work work ./wb_b3_dpram.v
	vlog -reportprogress 300 -work work ./../../../bench/wbm.v
	vlog -reportprogress 300 -work work ./../../../bench/tb_wb_b3_dpram.v

tb_wb_cache:
	vppreproc --noline --noblank +define+SYSTEMVERILOG +incdir+$(INC_DIR) +define+WB_AVALON_MEM_CACHE +define+WB_RAM +define+RAM_BE +define+WB_AVALON_MEM_CACHE $(VERILOG_FILES) > wb_cache.v
	vlog -reportprogress 300 -work work ./wb_cache.v
	vlog -reportprogress 300 -work work ./../../../bench/wbm.v
	vlog -reportprogress 300 -work work ./../../../bench/tb_wb_cache.v
