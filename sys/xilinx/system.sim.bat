rem build simulation project
simgen -p xc7z020clg484-2 -lang verilog -intstyle default -lp ../../sys/xilinx/../../ -lp ../../rtl/bus -msg simrun.lst -s isim -m behavioral ../../sys/xilinx/system.mhs -od .

rem compile and elaborate compiled models
vlogcomp -work work ../../sys/xilinx/system.tb.v -i ../../sys/xilinx/
fuse -incremental work.system_tb work.glbl -prj simulation/behavioral/system.prj -L xilinxcorelib_ver -L secureip -L unisims_ver -L unimacro_ver -o system.exe

rem run simulation
system.exe -gui -tclbatch simulation/behavioral/system_setup.tcl

pause

