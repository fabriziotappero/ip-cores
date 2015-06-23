#!/usr/bin/env python
#
# This script runs Z80 command 'neg' for all 256 values and prints out
# memory access log data. This data is used to feed the simulation
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
    ser.write("s 4 5\r")
    serialFlush(ser)

    # Loop for all 256 arguments
    for x in range(0, 256):
    #   3E00            ld      a, 00h
    #   ED44            neg
    #   F5              push    af
        ram = ':10000000' + '3E' + ("%0.2X" % x) + 'ED44F50405060708090A0B0C0D00'

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
                if "Memory" in indata:
                    print (indata.rstrip('\r\n'))

except KeyboardInterrupt:
     ser.close()
