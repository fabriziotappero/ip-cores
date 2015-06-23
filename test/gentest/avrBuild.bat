cd "D:\Doru\projects\pAVR\test\gentest\"
D:
del gentest.map
del gentest.lst
"C:\Program Files\Atmel\AVR Tools\AvrAssembler\avrasm32.exe" -fI "D:\Doru\projects\pAVR\test\gentest\gentest.asm" -o "gentest.hex" -d "gentest.obj" -e "gentest.eep" -I "D:\Doru\projects\pAVR\test\gentest" -I "C:\Program Files\Atmel\AVR Tools\AvrAssembler\AppNotes" -w  -l "gentest.lst"
