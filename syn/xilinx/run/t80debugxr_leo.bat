cd ..\out

hex2rom ..\..\..\sw\monitorxr.hex MonZ80 11b8s > ..\src\MonZ80_leo.vhd

spectrum -file ..\bin\t80debugxr.tcl
move exemplar.log ..\log\t80debugxr_leo.srp

cd ..\run

t80debugxr t80debugxr_leo.edf xc2s200-pq208-5
