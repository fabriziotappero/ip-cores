set name=t80debug
rem set target=xc2v250-cs144-6
rem set target=xcv300e-pq240-8
set target=xc2s200-pq208-5

if "%2" == "" goto default
set target=%2
:default

cd ..\out

if "%1" == "" goto xst

set name=t80debug_leo

copy ..\bin\t80debug.pin %name%.ucf

ngdbuild -p %target% %1 %name%.ngd

goto builddone

:xst

xrom MonZ80 11 8 > ..\src\MonZ80.vhd
hex2rom ..\..\..\sw\monitor.hex MonZ80 11b8u > MonZ80.ini
copy ..\out\MonZ80.ini + ..\bin\%name%.pin %name%.ucf

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
