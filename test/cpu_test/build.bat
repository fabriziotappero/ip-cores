@rem build.bat -- Assemble the test source file(s) and create an VHDL package 
@rem file with the object code for ROM initialization.
@rem 
@rem This ia our assembler's path and executable name...
@set AS_PATH=..\..\local\tools\asem51
@set AS=%AS_PATH%\asem.exe
@set AS_OPTS=/INCLUDEs:..\include
@rem ...this is the path of the IHEX-to-VHDL script...
@set BR_PATH=..\..\tools\build_rom
@rem ...and this is where the object code vhdl package will be written to.
@set VHDL_TB_PATH=.

@rem Assemble the test program with default options...
@echo Assembling with default options...
@%AS% src\tb51_cpu.a51 bin\tb51_cpu.hex lst\tb51_cpu.lst %AS_OPTS%
@rem ...and assemble it with all CPU options enabled: BCD opcodes
@echo Assembling with all options enabled...
@%AS% src\tb51_cpu.a51 bin\tb51_all.hex lst\tb51_all.lst /DEFINE:BCD %AS_OPTS%

@rem ...and build the object code vhdl packages
@python %BR_PATH%\src\build_rom.py ^
     -f bin/tb51_cpu.hex  ^
     -v %BR_PATH%/templates/obj_code_pkg_template.vhdl ^
     -o %VHDL_TB_PATH%/obj_code_pkg.vhdl ^
     --xcode 40000 ^
     --xdata 1024 ^
     --name cpu_test
     
@python %BR_PATH%\src\build_rom.py ^
     -f bin/tb51_all.hex  ^
     -v %BR_PATH%/templates/obj_code_pkg_template.vhdl ^
     -o %VHDL_TB_PATH%/full_test_pkg.vhdl ^
     --xcode 40000 ^
     --xdata 1024 ^
     --name cpu_test
