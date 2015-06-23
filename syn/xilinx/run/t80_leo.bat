cd ..\out

spectrum -file ..\bin\t80.tcl
move exemplar.log ..\log\t80_leo.srp

cd ..\run

t80 t80_leo.edf xc2s200-pq208-5
