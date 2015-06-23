@echo off
set /p target_firmware=Input the target firmware hex file along with its path. Ex: "..\..\sw\uart\uart.hex": 

for /f "tokens=*" %%i in ('find /c /v "NOTTHISSTRING" %target_firmware%') do set line_output=%%i
for /f "tokens=1,2 delims=:" %%a in ("%line_output%") do set firmware_size=%%b
set firmware_size=%firmware_size: =%

if EXIST %target_firmware% (
vsim -lib minsoc minsoc_bench -pli ../../bench/verilog/vpi/jp-io-vpi.dll +file_name=%target_firmware% +firmware_size=%firmware_size%
) else (
echo %target_firmware% could not be found. 
set /p exit=Press ENTER to close this window... 
)
