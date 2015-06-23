
echo off

::..\..\..\..\robust.exe ../src/base/apb_master.v -od out -I ../src/gen -list list.txt -listpath -header -gui -debug

..\..\..\..\robust.exe ../robust_apb_master.pro -gui %1 %2 %3
