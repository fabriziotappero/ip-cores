#!/usr/bin/env python
#
# This script runs Z80 command 'daa' for all 256 values and flag combinations
# and prints out memory access log data. This data is used to feed the simulation
# script and verify its algorithm correctness.
# It needs:
#   1. Arduino Z80 dongle: http://www.baltazarstudios.com
# Needs pyserial from https://pypi.python.org/pypi/pyserial
#
import serial
import sys

ser = serial.Serial("\\.\COM9", 115200, timeout=1)

# Flush the serial buffer, removes any command response
def serialFlush(ser):
    while 1:
        indata = ser.readline().rstrip('\n')
        if not indata:
            break

try:
    serialFlush(ser)
    # Stop after selected M1 cycle effectively running only that one sequence
    ser.write("s 4 7\r")
    ser.write("s 3 60\r")
    serialFlush(ser)

    # Loop for all 256 arguments
    for x in range(0, 256):
    #2:    0+10 0000  310000        ld  sp, 0000h
    #3:   10+10 0003  010000        ld  bc, 0000h
    #4:   20+11 0006  C5            push    bc
    #5:   31+10 0007  F1            pop     af
    #6:   41+4  0008  27            daa
    #7:   45+11 0009  F5            push    af
    #8:   56+4  000A  76            halt
        ram = ':10000000' + '310000' + '01' + '13' + ("%0.2X" % x) + 'C5F127F5760000000000'

        ser.write(ram + '\r')
        indata = ser.readline().rstrip('\n')
        ser.write('r\r')

        sys.stderr.write (ram + '\n')

        # Skip initial response from Arduino, includes two empty cycles after the reset
        for x in range(1,7):
            indata = ser.readline()

        while 1:
            indata = ser.readline()
            if not indata:
                break
            if indata[0]!=':':
                if (("#017" in indata) or ("#020" in indata) or ("#053" in indata) or ("#056" in indata)):
                    print (indata.rstrip('\r\n'))
                    sys.stderr.write (indata)

except KeyboardInterrupt:
     ser.close()
