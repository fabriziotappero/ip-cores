
echo off

::..\..\..\..\robust.exe ../src/base/ic.v -od out -I ../src/gen -list list.txt -listpath -header -gui

..\..\..\..\robust.exe ../robust_axi_fabric.pro -gui %1 %2 %3
