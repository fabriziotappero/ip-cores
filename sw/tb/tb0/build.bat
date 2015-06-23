@rem Build script for the TB0 test bench.
@rem This script will assemble the program source and run the object code 
@rem conversion tool to build a vhdl package that can then be used to initalize
@rem the test bench entity.
@rem You need to edit this file with the path to your TASM installation.
@rem Set the program name.
@set PROG=tb0
@rem Edit to point to the directory you installed TASM in.
@set TASM_DIR=..\..\..\local\tasm
@rem Remove output from previous assembly.
@del %PROG%.hex
@del %PROG%.lst
@rem Make sure TASM is able to find its table files (see TASM documentation).
@set TASMTABS=%TASM_DIR%
@rem Run assembler
%TASM_DIR%\tasm -85 -a %PROG%.asm %PROG%.hex %PROG%.lst
@rem Check TASM return value
@if errorlevel 1 goto done
@rem Build vhdl test bench file with object code embedded into it.
python ..\..\..\tools\obj2hdl\src\obj2hdl.py ^
  -f %PROG%.hex ^
  -c obj_code ^
  --package obj_code_pkg ^
  --output obj_code_pkg.vhdl
:done

