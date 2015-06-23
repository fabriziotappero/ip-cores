@echo off
set /p quartus_path=Input the path to Quartus e.g. C:\altera\11.0sp1\quartus:
if EXIST %quartus_path% (
set path=%path%;%quartus_path%\bin\cygwin\bin;%quartus_path%\bin
make all
echo Finished...
set /p exit=Press ENTER to close this window... 
make clean
) ELSE (
echo %quartus_path% could not be found. 
set /p exit=Press ENTER to close this window... 
)