
echo off

::..\..\..\..\robust.exe ../src/base/ahb_slave.v -od out -I ../src/gen -list list.txt -listpath -header -gui

..\..\..\..\robust.exe ../robust_ahb_slave.pro -gui %1 %2 %3