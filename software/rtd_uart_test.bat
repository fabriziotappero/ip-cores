rem Batch file for Windows XP. Windows XP has to use START to launch programs, waits for programs to quit, unlike earlier
echo on
set rt=..\RealTerm\realterm.exe

rem send the following bin file 
set bf=e:\Nikhef\MyOpenCores\uart_fpga_slow_control\trunk\documents\Hex_commands.bin
rem NOTE: works only with absolute paths...

start %rt% caption=UART_fpga half=1 rows=27 display=2 baud=921600 port=10 

rem pause Press any key to load PRBS config file 

rem start %rt%  sendfile=%bf%

pause Press any key to close Realterm 

start %rt% first display=5