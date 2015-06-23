cd ..\out

hex2rom ..\..\..\sw\c55.hex ROM55 9l12s > ..\src\ROM55_Test_leo.vhd

spectrum -file ..\bin\p16c55.tcl
move exemplar.log ..\log\p16c55_leo.srp

cd ..\run

p16c55 p16c55_leo.edf xc2s200-pq208-5
