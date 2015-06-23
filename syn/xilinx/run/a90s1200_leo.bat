cd ..\out

hex2rom ..\..\..\sw\echo1200.hex ROM1200 9l16s > ..\src\ROM1200_Echo_leo.vhd

spectrum -file ..\bin\a90s1200.tcl
move exemplar.log ..\log\a90s1200_leo.srp

cd ..\run

a90s1200 a90s1200_leo.edf xc2s200-pq208-5
