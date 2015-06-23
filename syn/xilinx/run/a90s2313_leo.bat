cd ..\out

hex2rom ..\..\..\sw\sine2313.hex ROM2313 10l16s > ..\src\ROM2313_Sine_leo.vhd

spectrum -file ..\bin\a90s2313.tcl
move exemplar.log ..\log\a90s2313_leo.srp

cd ..\run

a90s2313 a90s2313_leo.edf xc2s200-pq208-5
