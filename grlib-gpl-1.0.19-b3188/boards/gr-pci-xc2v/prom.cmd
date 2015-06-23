setMode -pff
setSubmode -pffserial
setAttribute -configdevice -attr dir -value "UP"
setAttribute -configdevice -attr flashDataWidth -value "8"
addConfigDevice -size 512 -name "gr-pci-xc2v" 
addPromDevice -position 1 -size 0 -name xcf04s
addPromDevice -position 2 -size 0 -name xcf04s
addPromDevice -position 3 -size 0 -name xcf04s
addCollection -name gr-pci-xc2v
addDesign -version 0 -name 0000
addDeviceChain -index 0
setCurrentDesign -version 0
addDesign -version 0 -name 0000
addDeviceChain -index 0
setCurrentDeviceChain -index 0
setAttribute -design -attr name -value "0"
addDevice -position 1 -file gr-pci-xc2v.bit
generate -format mcs -fillvalue FF
setMode -bs
setCable -port auto -baud 3000000
Identify
assignFile -p 1 -file "gr-pci-xc2v_0.mcs"
assignFile -p 2 -file "gr-pci-xc2v_1.mcs"
assignFile -p 3 -file "gr-pci-xc2v_2.mcs"
assignFile -p 5 -file "971A_lqfp.bsd"
Program -p 1 2 3 -e -v 
quit
