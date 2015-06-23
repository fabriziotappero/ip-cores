#!/usr/bin/env python
#
# This script is used to dump Z80 instruction timing data by running the
# instructions through the Arduino Z80 dongle and parsing the dump output.
# It needs:
#   1. Arduino Z80 dongle: http://www.baltazarstudios.com
#   2. Instructions data file: '../../resources/opcodes-??.txt'
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
    # Open opcode file and read opcode + mnemonics
    with open('../../resources/opcodes-ed.txt') as tmpFile:
        ops = [line.rstrip('\n') for line in tmpFile]

    serialFlush(ser)
    # Stop after the second M1 cycle effectively running only one instruction
    ser.write("s 4 3\r")
    serialFlush(ser)

    print ('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">')
    print ('<HTML><HEAD><TITLE>Z80 Instructions Timing</TITLE></HEAD><BODY>')
    print ('<H1>Opcodes with ED prefix</H1>')
    for line in ops:
        print (line[0:2] + ' ' + line[2:4] + ' .. <A href=\"#' + line[2:4] + '\">' + line[12:] + '</A><BR>')

    print ('<H1>Instructions Timing</H1>')

    for line in ops:
        ram = ':10000000' + line[0:4] + '0102030405060708090A0B0C0D00'

        ser.write(ram + '\r')
        indata = ser.readline().rstrip('\n')
        ser.write('r\r')

        print ('<H3 id=\"' + line[2:4] + '\">Opcode: ' + line[0:2] + " " + line[2:8] + ' => ' + line[12:] + '</H3>')
        sys.stderr.write (line + '\n')

        # Skip initial response from Arduino, includes two empty cycles after the reset
        for x in range(1,7):
            indata = ser.readline()

        print ('<PRE>')
        while 1:
            indata = ser.readline()
            if not indata:
                break
            if indata[0]!=':':
                print (indata.rstrip('\r\n'))
        print ('</PRE>')

    print ('</BODY></HTML>')

except KeyboardInterrupt:
     ser.close()
