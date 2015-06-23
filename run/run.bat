
echo off

::..\..\..\..\robust.exe ../src/base/axi2ahb.v -od out -I ../src/gen -list list.txt -listpath -header -gui

..\..\..\..\robust.exe ../robust_axi2ahb.pro -gui %1 %2 %3
