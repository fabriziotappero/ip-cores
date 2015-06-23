rem ****************************************************************************
rem *                                                                          *
rem *                       Assemble the testbench file                        *
rem *                                                                          *
rem ****************************************************************************

rem
rem Assemble source
rem
as8080 test=test/l
rem
rem Locate binary file to program $0000, variable $1000
rem
ln test=test/vs=$1000
rem
rem Create listing
rem
al test > test.lst
rem
rem Put into "rom" format suitable for verilog
rem
genrom test.obj > test.rom
