setMode -bscan
setCable -port auto
Identify 
identifyMPM
assignFile -p 2 -file "leon3mp.bit"
Program -p 2 -defaultVersion 0 
quit
