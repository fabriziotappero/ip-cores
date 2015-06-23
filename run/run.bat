
echo off

::..\..\..\..\robust.exe ../src/base/axi2apb.v -od out -I ../src/gen -list list.txt -listpath -header -gui

..\..\..\..\robust.exe ../robust_axi2apb.pro -gui %1 %2 %3
