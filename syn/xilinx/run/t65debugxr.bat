set name=t65debugxr
rem set target=xc2v250-cs144-6
rem set target=xcv300e-pq240-8
set target=xc2s200-pq208-5

if "%2" == "" goto default
set target=%2
:default

cd ..\out

if "%1" == "" goto xst

set name=t65debugxr_leo

ngdbuild -p %target% %1 %name%.ngd

goto builddone

:xst

xrom Mon65XR 10 8 > ..\src\Mon65XR.vhd
hex2rom -b ..\..\..\sw\Mon65XR.bin mon65xr 10b8u > Mon65XR.ini
copy ..\bin\%name%.pin + ..\out\Mon65XR.ini %name%.ucf

xst -ifn ../bin/%name%.scr -ofn ../log/%name%.srp
ngdbuild -p %target% %name%.ngc

:builddone

move %name%.bld ..\log

map -p %target% -cm speed -c 100 -pr b -timing -tx on -o %name%_map %name%
move %name%_map.mrp ..\log\%name%.mrp

par -ol 3 -t 1 %name%_map -w %name%
move %name%.par ..\log

trce %name%.ncd -o ../log/%name%.twr %name%_map.pcf

bitgen -w %name%
move %name%.bgn ..\log

cd ..\run
