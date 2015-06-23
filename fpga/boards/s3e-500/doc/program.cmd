setMode -bscan
setCable -p auto
addDevice -position 1 -part xc3s500e
addDevice -position 2 -sprom xcf04s -file ./eco32.mcs
addDevice -position 3 -part xc2c64a
program -e -v -p 2
quit
