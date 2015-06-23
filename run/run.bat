
echo off

::..\..\..\..\robust.exe ../src/base/axi_master.v -od out -I ../src/gen -list list.txt -listpath -header -gui

..\..\..\..\robust.exe ../robust_axi_master.pro -gui %1 %2 %3

