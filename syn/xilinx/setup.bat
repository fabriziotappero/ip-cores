@echo off
set /p xilinx_settings=Input the Xilinx "settings32|64.bat" file along with its absolute path: 
if EXIST %xilinx_settings% (
%xilinx_settings%
make all
echo Finished...
set /p exit=Press ENTER to close this window... 
make clean
) ELSE (
echo %xilinx_settings% could not be found. 
set /p exit=Press ENTER to close this window... 
)

