tester:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../tester/" -LDFLAGS "-O3" --cc ./../../rtl/aoR3000.v --exe main_tester.cpp -I./../../rtl -I./../../rtl/block -I./../../rtl/memory -I./../../rtl/model -I./../../rtl/pipeline
	cd obj_dir && make -f VaoR3000.mk

linux:
	verilator --trace -Wall -CFLAGS "-O3 -I./../../tester/" -LDFLAGS "-O3" --cc ./../../rtl/aoR3000.v --exe main_linux.cpp -I./../../rtl -I./../../rtl/block -I./../../rtl/memory -I./../../rtl/model -I./../../rtl/pipeline
	cd obj_dir && make -f VaoR3000.mk
