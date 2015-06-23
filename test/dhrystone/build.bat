@rem This build BAT file assumes you use the SDCC compiler, and the compiler is
@rem in the path.
@rem The proper way to do this is with make but I don't want to rely on users 
@rem having it installed.
@rem Set compiler name...
@set CC=sdcc
@rem ...and set the path for the VHDL file tool.
@set BR_PATH=..\..\tools\build_rom
@rem Generate VHDL object package in this directory.
@set VHDL_TB_PATH=.
@rem 
@set CC_OPT=--code-size 8192 --xram-size 512 -D__LIGHT52__=1 -DNOSTRUCTASSIGN=1 --model-large
@set LK_OPT=--model-large
@rem This will be the final program name.
@set PROG=dhry

@rem Delete the old executable
@del bin\%PROG%.ihx

@rem Compile all source files...
%CC% -o obj\ %CC_OPT% -c src\estubs.c
%CC% -o obj\ %CC_OPT% -c src\dhry21a.c
%CC% -o obj\ %CC_OPT% -c src\dhry21b.c
%CC% -o obj\ %CC_OPT% -c src\timers_b.c
%CC% -o obj\ %CC_OPT% -c ..\common\target.c
@rem ...and link them.
%CC% %LK_OPT% -o obj\ obj\dhry21a.rel obj\dhry21b.rel obj\estubs.rel obj\timers_b.rel obj\target.rel

@rem Move the new executable HEX file to the BIN directory...
@copy obj\dhry21a.ihx bin\%PROG%.ihx

@rem ...and build the VHDL object code package.
@python %BR_PATH%\src\build_rom.py ^
     -f bin/%PROG%.ihx  ^
     -v %BR_PATH%/templates/obj_code_pkg_template.vhdl ^
     -o %VHDL_TB_PATH%/obj_code_pkg.vhdl

