
The test programs have been assembled with TASM (Telemark Cross Assembler), 
a free assembler available for DOS and Linux.

A few test benches and demos are included in the /sw directory. All of them 
assume you have installed the TASM assembler and include a build BAT script, so
they should be easy to 

A few Modelsim simulation scripts are included to assist in running the test
benches with that simulator. They are in the /sim directory.
The scripts expect that Modelsim's current directory is the /sim directory.
(you can change the working directory with 'File'->'change directory').

By examining the build scripts and the modelsim scripts it should be easy to 
identify what parts of the 


Most relevant files
===================

vhdl\light8080.vhdl                     Core source (single file)

vhdl\test\light8080_tb.vhdl             Test bench entity (without object code)

vhdl\demo\cs2b_4kbasic_cpu.vhdl         altair 4K Basic demo on DE-1 board
vhdl\demo\cs2b_4kbasic_rom.vhdl         ROM/RAM for 4K Basic demo
vhdl\demo\rs232_tx.vhdl                 Serial tx code for demo
vhdl\demo\rs232_rx.vhdl                 Serial rx code for demo
vhdl\demo\c2sb_4kbasic.csv              Pin assignment file for Quartus II

verilog\rtl\                            Verilog files of CPU and SOC
verilog\bench\                          Verilog light8080 SOC testbench 
verilog\sim\icarus                      Verilog simulation files for Icarus
verilog\syn\altera_c2                   Altera Quartus project file (Cyclone II)
verilog\syn\xilinx_s3                   Xilinx ISE project file (Spartan 3)

util\uasm.pl                            Microcode assembler
util\microrom.bat                       Sample DOS bat file for assembler

ucode\light8080.m80                     Microcode source file

sim\sim_tb0.do                    		Modelsim script for test bench 0
sim\sim_tb1.do                    		Modelsim script for test bench 1

doc\designNotes.tex                     Core documentation in LaTeX format
doc\designNotes.pdf                     Core documentation in PDF format
doc\Light8080 Core Specifications.odf	Specs doc for the VHDL/Verilog core


sw\tb\tb0.asm                           Test bench 0 source
sw\tb\tb1.asm                           Test bench 1 source
sw\tb\soc_tb.vhdl						Test bench for VHDL SoC
sw\demo\hello.asm						'Hello World' for VHDL SoC on DE-1 board
sw\demo\c2sb							VHDL top entity for DE-1 board demos

c\                                      Hello World Small-C light8080 SOC sample 

tools\readme.txt						Brief description of all the tools.
tools\c80\                              C80 compiler and AS80 assembler tools 
										used to compile the C example program. 
										Compiled with TCC (Tiny C Compiler).
tools\ihex2vlog\                        Intel HEX to Verilog tool used to 
										generate the Verilog program & RAM 
										memory file used by the verilog SOC. 
                                        Compiled with TCC (Tiny C Compiler).
tools\obj2hdl							HEX to VHDL conversion tool.
tools\hexconv							Deprecated HEX to VHDL conversion tool.