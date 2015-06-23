setMode -pff
setSubmode -pffserial
setAttribute -configdevice -attr dir -value "UP"
setAttribute -configdevice -attr flashDataWidth -value "8"
addConfigDevice -size 512 -name "gr-pci-xc2v" 
addPromDevice -position 1 -size 0 -name xcf04s
addPromDevice -position 2 -size 0 -name xcf04s
addPromDevice -position 3 -size 0 -name xcf04s
addPromDevice -position 4 -size 0 -name xcf04s
addPromDevice -position 5 -size 0 -name xcf04s
addPromDevice -position 6 -size 0 -name xcf04s
addCollection -name gr-cpci-xc2v
addDesign -version 0 -name 0000
addDeviceChain -index 0
setCurrentDesign -version 0
addDesign -version 0 -name 0000
addDeviceChain -index 0
setCurrentDeviceChain -index 0
setAttribute -design -attr name -value "0"
addDevice -position 1 -file gr-cpci-xc2v.bit
generate -format mcs -fillvalue FF
setMode -bs
setCable -port auto
Identify
assignFile -p 1 -file "gr-cpci-xc2v_0.mcs"
assignFile -p 2 -file "gr-cpci-xc2v_1.mcs"
assignFile -p 3 -file "gr-cpci-xc2v_2.mcs"
assignFile -p 4 -file "gr-cpci-xc2v_3.mcs"
assignFile -p 5 -file "gr-cpci-xc2v_4.mcs"
assignFile -p 6 -file "gr-cpci-xc2v_5.mcs"
Program -p 1 2 3 4 5 6 -e -v 
quit
