stty -F /dev/ttyS0 115200 cstopb -icanon -icrnl -ixon -opost -onlcr -imaxbel -echo -echoe -echok -echoke -echoctl -echonl min 1 time 0
##                   SRSEL
##echo -n -e '\x00\x00\x5B\x00\x00\x00\x00\xAA'  > /dev/ttyS0
#echo -n -e '\x61\x5B\x12\x34\x56\x00\x00\x33'  > /dev/ttyS0
##			SETUP SRAM          SRAM SRAM OUTSEL
#echo -n -e '\x61\xA5\x12\x34\x56\x00\x00\x33'  > /dev/ttyS0
##			WRITE SRAM                   NORMAL  
#echo -n -e '\x83\xA5\x00\x00\x00\x38\x41\xAA'  > /dev/ttyS0
##			SETUP SRAM           SRAM SRAM OUTSEL	
#echo -n -e '\x61\x4C\x12\x34\x56\xA5\xA5\x33'  > /dev/ttyS0
##			SETUP SRAM          SRAM SRAM OUTSEL
#echo -n -e '\x61\xA5\x12\x34\x56\x00\x00\x33'  > /dev/ttyS0
##                   SRAM
#echo -n -e '\x94\xA5\x00\x00\x00\x00\x00\xAA'  > /dev/ttyS0
##           READ SRAM                    NORMAL
#echo -n -e '\x94\xA5\x00\x00\x00\x00\x00\xAA'  > /dev/ttyS0
#
#                   SDRSEL
#echo -n -e '\x61\x1F\x12\x34\x56\x00\x00\x33'  > /dev/ttyS0
##			SETUP SDRAM               OUTSEL
#echo -n -e '\x61\xB4\x12\x34\x56\x00\x00\x33'  > /dev/ttyS0
##			WRITE SDRAM               NORMAL  
#echo -n -e '\x83\xB4\x00\x00\x21\x45\x39\xAA'  > /dev/ttyS0
##			SETUP SET_REG           SRAM SRAM OUTSEL	
#echo -n -e '\x61\x4C\x12\x34\x56\xB4\xB4\x33'  > /dev/ttyS0
##			SETUP SDRAM          SDRAM OUTSEL
#echo -n -e '\x61\xB4\x12\x34\x56\x00\x00\x33'  > /dev/ttyS0
##           READ  SDRAM
#echo -n -e '\x94\xB4\x00\x00\x21\x00\x00\xAA'  > /dev/ttyS0
