setMode -bscan
setCable -p auto
addDevice -position 1 -file ./flash-500.bit
addDevice -position 2 -part xcf04s
addDevice -position 3 -part xc2c64a
program -p 1
quit
