setMode -pff
setSubmode -pffversion
addPromDevice -position 1 -name xcf32p
addCollection -name digilent-xup-xc2vp
addDesign -version 0 -name 0000
addDeviceChain -index 0
setCurrentDesign -version 0
addDevice -position 1 -file leon3mp.bit
addDesign -version 1 -name 1000
addDeviceChain -index 0
setCurrentDesign -version 1
addDevice -position 1 -file leon3mp.bit
generate -format mcs -fillvalue FF
setMode -bs
setCable -port auto
Identify 
identifyMPM 
assignFile -p 1 -file "digilent-xup-xc2vp.mcs"
Program -p 1 -e -v -parallel -ver 1 erase verify -defaultVersion 0 
quit
