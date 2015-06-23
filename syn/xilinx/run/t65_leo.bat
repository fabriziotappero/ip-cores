cd ..\out

spectrum -file ..\bin\t65.tcl
move exemplar.log ..\log\t65_leo.srp

cd ..\run

t65 t65_leo.edf xc2s200-pq208-5
