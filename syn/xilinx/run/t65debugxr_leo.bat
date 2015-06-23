cd ..\out

xrom Mon65XR 10 8 > ..\src\Mon65XR_leo.vhd
hex2rom -b ..\..\..\sw\Mon65XR.bin Mon65XR 10b8l > Mon65XR_leo.ini
copy ..\bin\t65debugxr_leo.pin + ..\out\Mon65XR_leo.ini t65debugxr_leo.ucf

spectrum -file ..\bin\t65debugxr.tcl
move exemplar.log ..\log\t65debugxr_leo.srp

cd ..\run

t65debugxr t65debugxr_leo.edf xc2s200-pq208-5
