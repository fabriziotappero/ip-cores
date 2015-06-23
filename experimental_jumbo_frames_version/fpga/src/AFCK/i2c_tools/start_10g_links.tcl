source i2c_tools.tcl
i2c_write 112 [list 10]
source Si_156.tcl
SiSetFrq 156250000
i2c_write 112 [list 12]
source ADN4604.tcl
ADN4604_write 0x93 [list 0xff] 
ADN4604_write 0x94 [list 0xff]
ADN4604_write 0x81 [list 0x00]
ADN4604_write 0x80 [list 0x01]

