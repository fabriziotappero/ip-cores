setMode -bs
setCable -port auto
Identify 
identifyMPM 
assignFile -p 4 -file "gr-pci-xc2v.bit"
assignFile -p 5 -file "971A_lqfp.bsd"
Program -p 4 -v -defaultVersion 0 
quit
