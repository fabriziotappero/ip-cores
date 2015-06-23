@echo off
Rem
Rem     This batch file assembles and generates executable code for a ModelSim test at
Rem     \cpu\toplevel\simulation\modelsim         (Select "test_top" test in ModelSim)
Rem
Rem     Give it an argument of the ASM file you want to use, or you can simply drag
Rem     and drop an asm file into it. If you drop an ASM file and there were errors,
Rem     this script will keep the DOS window open so you can see the errors.
Rem
zmac --zmac %1
if errorlevel 1 goto error
bindump.py zout\%~n1.cim ..\..\cpu\toplevel\simulation\modelsim\ram.hexdump
if errorlevel 1 goto error
goto end

:error
@echo ------------------------------------------------------
@echo Errors assembling %1
@echo ------------------------------------------------------
cmd
:end