@rem This build BAT file assumes you use the SDCC compiler, and the compiler is
@rem in the path.
@rem Set compiler name...
@set CC=sdcc
@rem ...and set the path for the VHDL file tool.
@set BR_PATH=..\..\tools\build_rom
@rem Generate VHDL object package in this directory.
@set VHDL_TB_PATH=.

@rem Compile the file as a single-file program...
%SDCC% -o obj\ src\hello.c

@rem ...move the executable HEX file to the BIN directory...
@copy obj\hello.ihx bin

@rem ...and build the VHDL object code package.
@python %BR_PATH%\src\build_rom.py ^
     -f bin/hello.ihx  ^
     -v %BR_PATH%/templates/obj_code_pkg_template.vhdl ^
     -o %VHDL_TB_PATH%/obj_code_pkg.vhdl ^
     --name hello_c


