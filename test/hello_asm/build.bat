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

@rem Assemble the source files...
@for %%f in (hello) do %AS% src\%%f.a51 bin\%%f.hex lst\%%f.lst %AS_OPTS%

@rem ...and build the object code vhdl package
@python %BR_PATH%\src\build_rom.py ^
     -f bin/hello.hex  ^
     -v %BR_PATH%/templates/obj_code_pkg_template.vhdl ^
     -o %VHDL_TB_PATH%/obj_code_pkg.vhdl ^
     --name hello_asm

