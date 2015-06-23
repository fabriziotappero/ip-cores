cd ..\out

hex2rom ..\..\..\sw\f84.hex ROM84 10l14s > ..\src\ROM84_Test_leo.vhd

spectrum -file ..\bin\p16f84.tcl
move exemplar.log ..\log\p16f84_leo.srp

cd ..\run

p16f84 p16f84_leo.edf xc2s200-pq208-5
