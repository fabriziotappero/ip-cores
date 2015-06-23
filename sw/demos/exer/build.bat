@rem Build script for the SoC basic demo 'hello'.

@rem Set the program name.
@set PROG=8080exer

@rem Build vhdl test bench file with object code embedded into it.
python ..\..\..\tools\obj2hdl\src\obj2hdl.py ^
  -f %PROG%.hex ^
  -c obj_code ^
  --package obj_code_pkg ^
  --output obj_code_pkg.vhdl
:done

