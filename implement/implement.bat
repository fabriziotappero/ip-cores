@echo off
REM --------------------------------------------------------------------------
REM Author: Jonathon W. Donaldson
REM Rev-Mod:  $Id: implement.bat,v 1.3 2008-11-07 01:35:17 jwdonal Exp $
REM --------------------------------------------------------------------------

REM ------------------------------------------------------------------------------
REM Script to synthesize and implement the lq057q3dc02 solution
REM ------------------------------------------------------------------------------

ECHO SCRIPT: Setting up required CVS environment variables...
set CVS_RSH="C:\Program Files\TortoiseCVS\TortoisePlink.exe"

ECHO SCRIPT: Switching to results directory...
:GETDIR
ECHO 0 - lq057q3dc02
ECHO 1 - Do not use
ECHO 2 - Do not use
set /p choice=Choice: 
if '%choice%'=='0' goto FAKEDLF
REM if '%choice%'=='1' goto REALDLF
REM if '%choice%'=='2' goto ALL
ECHO "%choice%" is not valid please try again
ECHO .
goto GETDIR

:FAKEDLF
cd results
copy ..\..\design\xupv2p.ucf board.ucf
goto IMPLEMENT

:REALDLF
cd results_dlf
copy ..\..\design\lq057q3dc02_top.ucf+..\..\design\lq057q3dc02_top_tlkcl_off.ucf board.ucf
goto IMPLEMENT

:ALL
cd results_all
copy ..\..\design\lq057q3dc02_top.ucf+..\..\design\lq057q3dc02_top_tlkcl_on.ucf board.ucf
goto IMPLEMENT

:IMPLEMENT
ECHO SCRIPT: Cleaning up past compilation results...
rd /s /q xst

ECHO SCRIPT: Cleaning up past synthesis results...
del *.ngc *.lst *.lso *.ncd *.pad *.ngd *.ngm *.xml *.unroutes *.xpi *.drc *.log *.pcf *.csv *.txt timing.twr

REM Run `cvs edit' on appropriate output files so that Xilinx can write to them and then we can compare later.
ECHO SCRIPT: Attempting to retrieve edit priveleges from CVS repository server...
cvs edit -z *.bgn *.par *.twr *.map *.mrp *.blc *.bld *.bit *.srp *.nlf

ECHO SCRIPT: Synthesizing design with XST...
xst -ifn ..\xst.scr -ofn lq057q3dc02_top_part.srp

ECHO SCRIPT: Running NGCbuild (combining all netlists)...
REM The -sd option adds the specified Source Directory to the list of directories to search when looking for netlists.
ngcbuild -sd ..\..\netlists -uc board.ucf lq057q3dc02_top_part.ngc lq057q3dc02_top.ngc

REM Get rid of temporary UCF file
del board.ucf

REM Generate VHDL simulation netlist for use in ModelSim
REM -w = overwrite existing file VHD output file
ECHO SCRIPT: Running NetGen (generating HDL simulation model for ModelSim)...
netgen -ofmt vhdl -w lq057q3dc02_top.ngc

ECHO SCRIPT: Running NGDbuild (Translate)...
ngdbuild lq057q3dc02_top.ngc lq057q3dc02_top.ngd

ECHO SCRIPT: Running Map...
REM "-pr b" = Pack both inputs and outputs into IOBs (do NOT use this option when doing TMR)
map -ol high -timing -pr b lq057q3dc02_top.ngd -o lq057q3dc02_top.ncd lq057q3dc02_top.pcf

ECHO SCRIPT: Running Post-MAP Trace...
trce -e 10 lq057q3dc02_top.ncd -o lq057q3dc02_top_map.twr lq057q3dc02_top.pcf

ECHO SCRIPT: Running Place and Route...
par -ol high -w lq057q3dc02_top.ncd lq057q3dc02_top.ncd lq057q3dc02_top.pcf

ECHO SCRIPT: Running Post-PAR Trace...
trce -e 10 lq057q3dc02_top.ncd -o lq057q3dc02_top.twr lq057q3dc02_top.pcf

ECHO SCRIPT: Running design through Bitgen...
bitgen -f ..\bitgen.ut -w lq057q3dc02_top

ECHO SCRIPT: Removing useless, auto-generated ISE project files created by ISE v10.1 and later...
del *.xrpt *.ptwx *.twx *.ise
rd /s /q xlnx_auto_0_xdb

ECHO SCRIPT: Returning to parent directory...
cd ..
