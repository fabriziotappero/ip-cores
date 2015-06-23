setMode -bscan
setCable -port usb21
Identify
assignfile -p 2 -file digilent-xc3s1600e_0.mcs
assignfile -p 3 -file digilent-xc3s1600e_1.mcs
Program -p 2 3 -e -v 
quit
