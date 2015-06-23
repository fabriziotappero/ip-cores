
echo off

::..\..\..\..\robust.exe ../src/base/fir.v ../src/base/def_fir_top.txt -od out -I ../src/gen -list list.txt -listpath -header -gui

..\..\..\..\robust.exe ../robust_fir.pro -gui %1 %2 %3
