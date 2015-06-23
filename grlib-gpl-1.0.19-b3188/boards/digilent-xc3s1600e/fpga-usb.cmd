setMode -bscan
setCable -p usb21
identify
assignfile -p 1 -file digilent-xc3s1600e.bit
program -p 1 -e -v
quit

