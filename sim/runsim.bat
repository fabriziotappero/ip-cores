@echo off
set path=c:\iverilog\bin;%PATH%
iverilog tb.v ../rtl/verilog/*.v -I ../rtl/verilog -o p6809.out
if errorlevel == 1 goto error
vvp p6809.out
:error