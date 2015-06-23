#! /usr/bin/python
# -*- coding: ISO-8859-1 -*-

##########################################################################
# Programming utility for Altera EPCS memory on USB Dongle PCB
#
# Copyright (C) 2008 Artec Design
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##########################################################################

#-------------------------------------------------------------------------
# Project:   Programming utility for Altera EPCS memory on USB Dongle PCB
# Name:      update.py
# Purpose:   Executable command line tool 
#
# Author:    Jüri Toomessoo <jyrit@artecdesign.ee>
# Copyright: (c) 2008 by Artec Design
# Licence:   LGPL
#
# Created:   12 Mar. 2008
# History:   12 Mar. 2008  Version 0.2 released
#-------------------------------------------------------------------------

import os
import sys
import string
import time



#### EPCS code starts here  ##################################################################


#### global funcs ####
def usage(s):
    print "Artec's Altera EPCS programming utility ver. 0.2.1 for USB Dongle"
    print "Use with Altera ByteBlaster II programmer or compatible clone on LPT1"
    print "like X-Blaster http://www.customcircuitsolutions.com/cable.html or"
    print "http://fpgaguy.110mb.com/"
    print "Usage:"
    print "Query           : ",s," -q"
    print "Write file      : ",s," [-v] <file>"
    print "Readback file   : ",s," [-v] -r <file>"
    print "Options:"
    print " -v              Enable verbose mode. Displays more progress information"    
    print " -q              Perform EPCS and ByteBlaster II query to see if all is ok"    
    print ""           
    print "Examples:"
    print ""
    print " ",s," dongle_syn.rpd "
    print " ",s," -r epcs_content.rpd "
######################


class DeviceMode:
    def __init__(self):
        self.v = 0
        self.f = 0
        self.d = 0
        self.q = 0
        self.r = 0
        self.t = 0
        self.e = 0
        self.b = 0
        self.l = 0
        self.filename=""
        self.portname=""
        self.address=-1
        self.offset=-1
        self.length=-1
        self.version=4
     
    def convParamStr(self,param):
        mult = 1
        value = 0
        str = param
        if str.find("K")>-1:
            mult = 1024
            str=str.strip("K")
        if str.find("M")>-1:
            mult = 1024*1024
            str=str.strip("M")
        try:    
            if str.find("x")>-1:
                value = int(str,0)*mult  #conver hex string to int
            else:
                value = int(str)*mult  #conver demical string to int
        except ValueError:
            print "Bad parameter format given for: ",param

        return value

    
    
    
class EPCSDevice:
    
    def __init__(self):  
        self._data = 0xFF
        self.mode = 0                  #commands are bit flipped
        self.CMD_WRITE_ENABLE = 0x60   #0x06
        self.CMD_WRITE_DISABLE= 0x20   #0x04
        self.CMD_READ_STATUS=0xA0      #0x05
        self.CMD_READ_BYTES=0xC0       #0x03
        self.CMD_READ_ID=0xD5          #0xAB
        self.CMD_WRITE_STATUS=0x80     #0x01
        self.CMD_WRITE_BYTES=0x40      #0x02
        self.CMD_ERASE_BULK=0xE3       #0xC7
        self.CMD_ERASE_SECTOR=0x1B     #0xD8
        if sys.platform=='win32':
            try:
                import parallel
            except ImportError: 
                print "Can't find pyparallel module"
                print "pyparallel is available at: "
                print "http://pyserial.sourceforge.net/pyparallel.html"
                print "Supports Windows NT/2k/XP trough giveio.sys"
                sys.exit()
            self.pport = parallel.Parallel()
            
        else: 
            try:
                import parallel
            except ImportError: 
                print "Can't find pyparallel module"
                print "pyparallel is available at: "
                print "http://pyserial.sourceforge.net/pyparallel.html"
                print "Supports Linux trough ppdev driver"
                sys.exit()
            self.pport = parallel.Parallel()            

    def open(self):
        i=0
        self.pport.setAutoFeed(1) #enable BB II tristate buffers to drive
        #self.pport.setDataDir(0xFF)  #enable out mode on pport
        self.pport.setData(0x10)  # set pport D4 this is looped back to ACK when tri's are enabled
        if self.pport.getInAcknowledge():
            i=i+1
        self.pport.setData(0x00)  # set pport D4 this is looped back to ACK when tri's are enabled
        if not self.pport.getInAcknowledge():
            i=i+1
        if i==2:
            print "Found ByteBlaster II compatible programmer"
        else:
            print "Can't find ByteBlaster II on parallel port"
            sys.exit()
        self.pport.setData(0xFF)
        self._data = 0xFF

        
    def close(self):
        epcs.pport.setData(0xFF)
        epcs.pport.setAutoFeed(1) #disable BB II tristate buffers to drive
        epcs.clearPPDataBit(3)  #enable Cyclon chip
        epcs.clearPPDataBit(2)  #enable Cyclon chip     
    
    def setPPDataBit(self,bit_no):
        self._data = self._data|(1<<bit_no)
        self.pport.setData(self._data)
        #print "set bit %i setData(0x%2x)"%(bit_no,self._data)
        #time.sleep(0.0001)
        
        

    def clearPPDataBit(self,bit_no):
        self._data = self._data&(~(1<<bit_no))
        self.pport.setData(self._data)
        #print "clr bit %i setData(0x%2x)"%(bit_no,self._data)
        #time.sleep(0.0001)
       
    def setASDI(self,bit):
        bit_cleared = self._data&(~(1<<6))   # deal with bit 6 pport D6
        bit_cleared = bit_cleared|(bit<<6)
        self._data = bit_cleared
        self.pport.setData(self._data)
        #print "ast bit %i setData(0x%2x)"%(bit,self._data)
        #time.sleep(0.0001)
        
    def startCycle(self):
       self.clearPPDataBit(2)    # pport D2 is nCS so bit 2 must go low
       #time.sleep(0.0001)

    def endCycle(self):
        self.setPPDataBit(2)    # pport D2 is nCS so bit 2 must go low
        #time.sleep(0.0001)
        
    def clockCycle(self):
        self.clearPPDataBit(0)  # make falling edge
        #time.sleep(0.0001)
        self.setPPDataBit(0)    # make rising edge
        #time.sleep(0.0001)
        
    def writeCommand(self,command):
        i=0
        #print "-------------------"
        while i<8:
            self.setASDI(command&0x01)
            #print "write cmd bit %i"%(command&0x00000001)
            self.clockCycle()
            command = command >> 1
            i+=1
        #print "-------------------"

    def writeFlippedByte(self,byte):
        #ok lets do bit reversal in a byte
        #it would be faster with a look up table (even with autogenerated one) FIXME
        i=0
        while i<8:
            self.setASDI(byte&0x01)
            self.clockCycle()
            byte = byte >> 1
            i+=1        
        
    def writeByte(self,byte):
        #ok lets do bit reversal in a byte
        #it would be faster with a look up table (even with autogenerated one) FIXME
        etyb = ((byte&0x01)<<7)|((byte&0x02)<<5)|((byte&0x04)<<3)|((byte&0x08)<<1)|((byte&0x10)>>1)|((byte&0x20)>>3)|((byte&0x40)>>5)|((byte&0x80)>>7)
        i=0
        while i<8:
            self.setASDI(etyb&0x01)
            self.clockCycle()
            etyb = etyb >> 1
            i+=1
 
    def writeAddress(self,address):
        byte = (address&0x00FF0000)>>16
        self.writeByte(byte) #this is used to write byte of address
        byte = (address&0x0000FF00)>>8
        self.writeByte(byte)
        byte = (address&0x000000FF)
        self.writeByte(byte)
        
        
    def readByte(self):
        i=0
        byte = 0
        #print "-------------------"
        while i<8:
            byte = byte << 1
            self.clearPPDataBit(0)  # make falling edge for read
            if self.pport.getInSelected():
                byte=byte|0x01
            self.setPPDataBit(0)  # make rising edge for read
            i+=1
        #print "-------------------"
        return byte

    #########################  EPCS command calls   #############################
    def getDeviceID(self):
        self.startCycle()
        self.writeCommand(self.CMD_READ_ID)
        self.writeCommand(0x00) # dummy write
        self.writeCommand(0x00) # dummy write
        self.writeCommand(0x00) # dummy write
        byte = self.readByte()
        self.endCycle()
        return byte

    def setWriteEnable(self):
        self.startCycle()
        self.writeCommand(self.CMD_WRITE_ENABLE)
        self.endCycle()
  
    def setWriteDisable(self):
        self.startCycle()
        self.writeCommand(self.CMD_WRITE_DISABLE)
        self.endCycle()
        
    def getStatusReg(self):
        self.startCycle()
        self.writeCommand(self.CMD_READ_STATUS)
        byte = self.readByte()
        self.endCycle()
        return byte
    
    def readBytes(self,address,count):
        buffer = ""
        i = 0
        self.startCycle()
        self.writeCommand(self.CMD_READ_BYTES)
        self.writeAddress(address)
        while(i<count):
            byte = self.readByte()
            #print "Reading %2x"%(byte)
            buffer = buffer + chr(byte)  #this can continue endlessly if needed the address is auto INC'ed and is freerunning
            i+=1
        self.endCycle()
        return buffer
    
    def readFlippedBytes(self,address,count):
        buffer = ""
        i = 0
        self.startCycle()
        self.writeCommand(self.CMD_READ_BYTES)
        self.writeAddress(address)
        while(i<count):
            byte = self.readByte()
            etyb = ((byte&0x01)<<7)|((byte&0x02)<<5)|((byte&0x04)<<3)|((byte&0x08)<<1)|((byte&0x10)>>1)|((byte&0x20)>>3)|((byte&0x40)>>5)|((byte&0x80)>>7)
            #print "Reading %2x"%(byte)
            buffer = buffer + chr(etyb)  #this can continue endlessly if needed the address is auto INC'ed and is freerunning
            i+=1
        self.endCycle()
        return buffer    
 
    def writeBytes(self,address,buffer):  #256 is maximum and is physical page limit of EPCS devices
        count = len(buffer)
        i = 0
        self.setWriteEnable()  #will be autoreset after this
        self.startCycle()
        self.writeCommand(self.CMD_WRITE_BYTES)
        self.writeAddress(address)
        while(i<count):
            #print "Writing %2x"%(ord(buffer[i]))
            self.writeByte(ord(buffer[i]))  #used also to write a data byte
            i+=1
        self.endCycle()
        time.sleep(0.0001)  #wait untill write compleate, wite time is in order of millis
        while(self.getStatusReg()&0x01==1):
            time.sleep(0.00001)

    def writeFlippedBytes(self,address,buffer):  #256 is maximum and is physical page limit of EPCS devices (Altera RPD file is allready byte flipped)
        #This is used to programm altera byte flipped programming files
        count = len(buffer)
        i = 0
        self.setWriteEnable()  #will be autoreset after this
        self.startCycle()
        self.writeCommand(self.CMD_WRITE_BYTES)
        self.writeAddress(address)
        while(i<count):
            #print "Writing %2x"%(ord(buffer[i]))
            self.writeFlippedByte(ord(buffer[i]))  #used also to write a data byte
            i+=1
        self.endCycle()
        time.sleep(0.0001)  #wait untill write compleate, wite time is in order of millis
        while(self.getStatusReg()&0x01==1):
            time.sleep(0.00001)            

    def eraseBulk(self):
        self.setWriteEnable()  #will be autoreset after this
        self.startCycle()
        self.writeCommand(self.CMD_ERASE_BULK)
        self.endCycle()
        time.sleep(3)  #wait untill write compleate, wite time is in order of secs
        while(self.getStatusReg()&0x01==1):
            time.sleep(0.1)        

            
    def eraseSector(self,address):
        self.setWriteEnable()  #will be autoreset after this
        self.startCycle()
        self.writeCommand(self.CMD_ERASE_SECTOR)
        self.writeAddress(address)
        self.endCycle()
        time.sleep(1)  #wait untill write compleate, wite time is in order of secs
        while(self.getStatusReg()&0x01==1):
            time.sleep(0.2)                    
    #########################  end EPCS command calls   #########################
       
    
    
################## Main program #########################


last_ops = 0
mode = DeviceMode()
# PARSE ARGUMENTS 
for arg in sys.argv:
    if len(sys.argv) == 1: # if no arguments display help
       #usage(sys.argv[0])
       usage("update.py")
       sys.exit()        
    if arg in ("-h","--help","/help","/h"):
        #usage(sys.argv[0])
        usage("update.py")
        sys.exit()

    if arg[0]=="-": # if options
        # parse all options in this
        last_ops = sys.argv.index(arg)  #if remains last set of options from here start ordered strings
        ops = arg[1:]# get all besides the - sign
        for op in ops:
            if op=="q":
                mode.q = 1
            if op=="v":
                mode.v = 1
            if op=="r":
                mode.r = 1
            if op=="e":
                mode.e = 1   
    else:
        i = sys.argv.index(arg)
        if i ==  last_ops + 1:
            mode.filename=arg
        if i >=  last_ops + 2:
            print "Too many parameters provided"
            sys.exit()
           
############## END PARSE ARGUMENTS   ###############################################33          


epcs = EPCSDevice()
epcs.open()
if epcs.pport.getInError():
    print "No Voltage source detected"
else:
    print "Voltage source OK"
    
byte = epcs.getDeviceID()
if byte == 0x10:
    print "EPCS1 Configuration device found"
    if mode.q == 1:
        print "EPCS Silicon ID = 0x%2x"%(byte)
        sys.exit()   # if q then exit
elif not byte == 0xFF:    
    print "Not supported device found"
    if mode.q == 1:
        print "Silicon ID = 0x%2x"%(byte)
    sys.exit()    
else:
    if not epcs.pport.getInError():
        print "No device attached to cable"
        if mode.q == 1:
            print "Got 0x%2x for ID "%(byte)    
    epcs.close()
    sys.exit()

if mode.e == 1:    
    print "Erasing EPCS device"
    epcs.eraseBulk()
    print "Done"
    
if mode.filename!="" and mode.r==0:
    print "Erasing EPCS device"
    epcs.eraseBulk()
    print "Done"
    size = 0
    mode.address = 0
    try:
        f=open(mode.filename,"rb")
        f.seek(0,2) #seek to end
        size = f.tell()
        f.seek(0) #seek to start
        print 'File size %iK '%(size/1024)
        f.close()
    except IOError:
         print "IO Error on file open"
         sys.exit()    
    #all seems in order so lest start     
    f=open(mode.filename,"rb")
    f.seek(0) #seek to start
    address = mode.address
    print 'Writing %iK'%(size/1024)
    while 1:
        if (address/(1024*4) != (address-16)/(1024*4)) and address != mode.address:  # get bytes from words if 512
            if mode.v == 1:
                print 'Progress: %iK of %iK at 0x%06x'%((address-mode.address)/1024,size/1024,address)
            else:
                sys.stdout.write(".")
                sys.stdout.flush()
        buf = f.read(256)  #we can write 256 bytes at a time
        if len(buf)==256:
            epcs.writeFlippedBytes(address,buf)
            address = address + 256  #we use byte address
        elif len(buf)>0:
            epcs.writeFlippedBytes(address,buf) #write last bytes
            break
        else:
            break
    if mode.v == 0:
        print " "
    print "Write DONE!"
    f.close()
elif mode.filename!="":   # then read flag must be up
    size = 0x20000   #byte count of EPCS1 device
    try:
        f=open(mode.filename,"wb")  #if this fails no point in reading as there is nowhere to write
        address = 0    # set word address
        buf=""
        print "Start readback"
        buf=epcs.readFlippedBytes(address,size)
        print "Read done"
        f.write(buf)
        f.close()
        print "Done"
    except IOError:
        print "IO Error on file open"
        sys.exit()                    

epcs.close()
time.sleep(0.5)

