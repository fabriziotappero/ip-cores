setMode -bs
setCable -port auto
Identify 
identifyMPM 
assignFile -p 1 -file "xilinx-spa3-dsp1800a.bit"
Program -p 1 -v -defaultVersion 0 
quit
