assemble -oAllSuiteA.bin AllSuiteA.asm
if errorlevel 1 exit
bintomem2.exe 0x4000 < AllSuiteA.bin > AllSuiteA.v
if errorlevel 1 exit
