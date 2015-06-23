echo off
if exist tmp_ml40x____datafile.bit del tmp_ml40x____datafile.bit
if exist tmp_ml40x____datafile.ace del tmp_ml40x____datafile.ace 
copy /Y %XILINX%\xcfp\data\xcf32p_vo48.bsd .
copy /Y %XILINX%\xc9500xl\data\xc95144xl_tq100.bsd .
copy /Y %1 tmp_ml40x____datafile.bit
impact -batch ml40x.scr
impact -batch ml40x_svf2ace.scr
if exist tmp_ml40x____datafile.bit del tmp_ml40x____datafile.bit
if exist tmp_ml40x____datafile.svf del tmp_ml40x____datafile.svf
if exist %2 del %2
if exist tmp_ml40x____datafile.ace ren tmp_ml40x____datafile.ace %2
echo on
