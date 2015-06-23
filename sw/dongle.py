#! /usr/bin/python
# -*- coding: ISO-8859-1 -*-

##########################################################################
# LPC Dongle programming software 
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
# Project:   LPC Dongle programming software 
# Name:      dongle.py
# Purpose:   Executable command line tool 
#
# Author:    Jüri Toomessoo <jyrit@artecdesign.ee>
# Copyright: (c) 2008 by Artec Design
# Licence:   LGPL
#
# Created:   06 Oct. 2006
# History:   12 oct. 2006  Version 1.0 released
#            22 Feb. 2007  Test options added to test PCB board
#            10 Nov. 2007  Added open retry code to dongle
#            14 Nov. 2007  Moved dongle specific code to class Dongle from USPP
#                          USPP is allmost standard now (standard USPP would work)
#                          Artec USPP has serial open retry
#            14 Nov. 2007  Improved help. 
#            10 Mar. 2008  Forced code to hw flow control settings made linux 1 byte read to 2 bytes
#                          as dongle never reads 1 byte at the time
#            18 Apr. 2008  Added file size boundary check on write to see if remaining size from
#                          given offset fits the file size

#            24 Apr. 2008  Mac OS X support by Stefan Reinauer <stepan@coresystems.de>
#            09 Oct. 2008  Added Dongle ver 86 20 support. Support for mode setting
#                          PCB ver read and PSRAM read write support. (PSRAM is on Dongle II boards)
#            03 Nov. 2008  Added Dongle II board changes to PSRAM write so that the bytes are not swapped
#                          by dongle.py but in hardware pipeline
#-------------------------------------------------------------------------

import os
import sys
import string
import time
import struct
from sets import *
from struct import *

#### inline of artec FTDI specific Uspp code ###################################################

##########################################################################
# USPP Library (Universal Serial Port Python Library)
#
# Copyright (C) 2006 Isaac Barona <ibarona@gmail.com>
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##########################################################################

#-------------------------------------------------------------------------
# Project:   USPP Library (Universal Serial Port Python Library)
# Name:      uspp.py
# Purpose:   Main module. Imports the correct module for the platform
#            in which it is running.
#
# Author:    Isaac Barona Martinez <ibarona@gmail.com>
# Contributors:
#            Damien Géranton <dgeranton@voila.fr>
#            Douglas Jones <dfj23@drexel.edu>
#            J.Grauheding <juergen.grauheding@a-city.de>
#            J.Toomessoo jyrit@artecdesign.ee
#
# Copyright: (c) 2006 by Isaac Barona Martinez
# Licence:   LGPL
#
# Created:   26 June 2001
# History:
#            05/08/2001: Release version 0.1.
#            24/02/2006: Final version 1.0.
#            10/11/2007: Added open retry code to dongle
#                        by Jyri Toomessoo jyrit@artecdesign.ee
#            14/11/2007: Moved dongle specific code to class Dongle from USPP
#                        USPP is allmost standard now (standard USPP would work)
#                        Artec USPP has serial open retry
#                        by Jyri Toomessoo jyrit@artecdesign.ee
#            10/03/2008: Forced code to hw flow control settings made linux 1 byte read to 2 bytes
#                        as dongle never reads 1 byte at the time
#                        by Jyri Toomessoo jyrit@artecdesign.ee
#            10/03/2008: Copose single infile bundle for FTDI USB serial 1.2
#                        this is nonuniversal modification of the code to suite the need of Artec Design Dongle
#                        by Jyri Toomessoo jyrit@artecdesign.ee
#-------------------------------------------------------------------------


drv_ok = 0
if sys.platform=='win32':
    print "Windows platform detected:"
    if drv_ok == 0:
        try:
            from win32file import *
            from win32event import *
            import win32con
            import exceptions
            
            print "Using VCP FTDI driver"
        except ImportError,SerialPortException:        
            print "Python for winiows extensions for COM not found" 
            print "(see https://sourceforge.net/projects/pywin32/)"
            print "Could not find any usable support for FTDI chip in python"
            print "Try installing python support from one of the links."
            sys.exit()
elif sys.platform=='linux2':
    from termios import *
    import fcntl
    import exceptions
    import array
    print "Linux platform detected:"
elif sys.platform=='darwin':
    from termios import *
    import fcntl
    import exceptions
    import array
    print "Mac OS X platform detected:"
else:
    sys.exit('Sorry, no implementation for this platform yet')



class SerialPortException(exceptions.Exception):
    """Exception raise in the SerialPort methods"""
    def __init__(self, args=None):
        self.args=args
    def __str__(self):
        return repr(self.args)

    
if sys.platform=='win32':    
  class SerialPortWin:
    BaudRatesDic={110: CBR_110,
                  300: CBR_300,
                  600: CBR_600,
                  1200: CBR_1200,
                  2400: CBR_2400,
                  4800: CBR_4800, 
                  9600: CBR_9600,
                  19200: CBR_19200,
                  38400: CBR_38400,
                  57600: CBR_57600,
                  115200: CBR_115200,
                  128000: CBR_128000,
                  256000: CBR_256000
                  }

    def __init__(self, dev, timeout=None, speed=115200, mode='232', params=None):
        self.__devName, self.__timeout, self.__speed=dev, timeout, speed
        self.__mode=mode
        self.__params=params
        self.__speed = 0
        self.__reopen = 0
        while 1:
            try:
                self.__handle=CreateFile (dev,
                win32con.GENERIC_READ|win32con.GENERIC_WRITE,
                0, # exclusive access
                None, # no security
                win32con.OPEN_EXISTING,
                win32con.FILE_ATTRIBUTE_NORMAL,
                None)
                break
                        
            except:
                n=0
                while (n < 2000000):
                    n += 1;                
                self.__reopen = self.__reopen + 1
            if self.__reopen > 32:
                print "Port does not exist... retries exhausted..."
                raise SerialPortException('Port does not exist...')
                break
                #sys.exit()
        self.__configure()

    def __del__(self):
        if self.__speed:
            try:
                CloseHandle(self.__handle)
            except:
                raise SerialPortException('Unable to close port')


            

    def __configure(self):
        if not self.__speed:
            self.__speed=115200
        # Tell the port we want a notification on each char
        SetCommMask(self.__handle, EV_RXCHAR)
        # Setup a 4k buffer
        SetupComm(self.__handle, 4096, 4096)
        # Remove anything that was there
        PurgeComm(self.__handle, PURGE_TXABORT|PURGE_RXABORT|PURGE_TXCLEAR|
                  PURGE_RXCLEAR)
        if self.__timeout==None:
            timeouts= 0, 0, 0, 0, 0
        elif self.__timeout==0:
            timeouts = win32con.MAXDWORD, 0, 0, 0, 1000
        else:
            timeouts= self.__timeout, 0, self.__timeout, 0 , 1000
        SetCommTimeouts(self.__handle, timeouts)

        # Setup the connection info
        dcb=GetCommState(self.__handle)
        dcb.BaudRate=SerialPortWin.BaudRatesDic[self.__speed]
        if not self.__params:
            dcb.ByteSize=8
            dcb.Parity=NOPARITY
            dcb.StopBits=ONESTOPBIT
            dcb.fRtsControl=RTS_CONTROL_ENABLE
            dcb.fOutxCtsFlow=1
        else:
            dcb.ByteSize, dcb.Parity, dcb.StopBits=self.__params
        SetCommState(self.__handle, dcb)
        

    def fileno(self):
        return self.__handle


    def read(self, num=1):
        (Br, buff) = ReadFile(self.__handle, num)
        if len(buff)<>num and self.__timeout!=0: # Time-out  
            print 'Expected %i bytes but got %i before timeout'%(num,len(buff))
            raise SerialPortException('Timeout')
        else:
            return buff


    def readline(self):
        s = ''
        while not '\n' in s:
            s = s+SerialPortWin.read(self,1)

        return s 


    def write(self, s):
        """Write the string s to the serial port"""
        errCode = 0
        overlapped=OVERLAPPED()
        overlapped.hEvent=CreateEvent(None, 0,0, None)
        (errCode, bytesWritten) = WriteFile(self.__handle, s,overlapped)
        # Wait for the write to complete
        WaitForSingleObject(overlapped.hEvent, INFINITE)
        return bytesWritten
        
    def inWaiting(self):
        """Returns the number of bytes waiting to be read"""
        flags, comstat = ClearCommError(self.__handle)
        return comstat.cbInQue

    def flush(self):
        """Discards all bytes from the output or input buffer"""
        PurgeComm(self.__handle, PURGE_TXABORT|PURGE_RXABORT|PURGE_TXCLEAR|
                  PURGE_RXCLEAR)


                  
if sys.platform=='linux2':
  class SerialPortLin:
    """Encapsulate methods for accesing to a serial port."""

    BaudRatesDic={
        110: B110,
        300: B300,
        600: B600,
        1200: B1200,
        2400: B2400,
        4800: B4800, 
        9600: B9600,
        19200: B19200,
        38400: B38400,
        57600: B57600,
        115200: B115200,
        230400: B230400
        }
    buf = array.array('h', '\000'*4)

    def __init__(self, dev, timeout=None, speed=115200, mode='232', params=None):
        self.__devName, self.__timeout, self.__speed=dev, timeout, speed
        self.__mode=mode
        self.__params=params
        self.__speed = 0
        self.__reopen = 0
        while 1:
            try:
                self.__handle=os.open(dev, os.O_RDWR)
                break
                        
            except:
                n=0
                while (n < 2000000):
                    n += 1;                
                self.__reopen = self.__reopen + 1
            if self.__reopen > 32:
                print "Port does not exist..."
                raise SerialPortException('Port does not exist...')
                break

        self.__configure()

    def __del__(self):
	if self.__speed:
            #tcsetattr(self.__handle, TCSANOW, self.__oldmode)
            pass
            try:
                pass
                os.close(self.__handle)
            except IOError:
                raise SerialPortException('Unable to close port')


    def __configure(self):
        if not self.__speed:
            self.__speed=115200
        
        # Save the initial port configuration
        self.__oldmode=tcgetattr(self.__handle)
        if not self.__params:
            # print "Create linux params for serialport..."
            # self.__params is a list of attributes of the file descriptor
            # self.__handle as follows:
            # [c_iflag, c_oflag, c_cflag, c_lflag, c_ispeed, c_ospeed, cc]
            # where cc is a list of the tty special characters.
            self.__params=[]
            # c_iflag
            self.__params.append(IGNPAR)           
            # c_oflag
            self.__params.append(0)                
            # c_cflag
            self.__params.append(CS8|CREAD|CRTSCTS) 
            # c_lflag
            self.__params.append(0)                
            # c_ispeed
            self.__params.append(SerialPortLin.BaudRatesDic[self.__speed]) 
            # c_ospeed
            self.__params.append(SerialPortLin.BaudRatesDic[self.__speed]) 
	    cc=[0]*NCCS
        if self.__timeout==None:
            # A reading is only complete when VMIN characters have
            # been received (blocking reading)
            cc[VMIN]=1
            cc[VTIME]=0
        elif self.__timeout==0:
            cc[VMIN]=0
            cc[VTIME]=0
        else:
            cc[VMIN]=0
            cc[VTIME]=self.__timeout #/100
        self.__params.append(cc)               # c_cc
        
        tcsetattr(self.__handle, TCSANOW, self.__params)
    

    def fileno(self):
        return self.__handle


    def __read1(self):
        tryCnt = 0
        byte = ""
        while(len(byte)==0 and tryCnt<10):
            tryCnt+=1
            byte = os.read(self.__handle, 2)
        if len(byte)==0 and self.__timeout!=0: # Time-out
            print 'Time out cnt was %i'%(tryCnt) 
            print 'Expected 1 byte but got %i before timeout'%(len(byte))
            sys.stdout.flush()
            raise SerialPortException('Timeout')
        else:
            return byte
            

    def read(self, num=1):
        s=''
        for i in range(num/2):
            s=s+SerialPortLin.__read1(self)
        return s


    def readline(self):

        s = ''
        while not '\n' in s:
            s = s+SerialPortLin.__read1(self)

        return s 

        
    def write(self, s):
        """Write the string s to the serial port"""
        return os.write(self.__handle, s)
        
    def inWaiting(self):
        """Returns the number of bytes waiting to be read"""
    	data = struct.pack("L", 0)
        data=fcntl.ioctl(self.__handle, TIOCINQ, data)
    	return struct.unpack("L", data)[0]

    def outWaiting(self):
        """Returns the number of bytes waiting to be write
        mod. by J.Grauheding
        result needs some finetunning
        """
        rbuf=fcntl.ioctl(self.__handle, TIOCOUTQ, self.buf)
        return rbuf

    
    def flush(self):
        """Discards all bytes from the output or input buffer"""
        tcflush(self.__handle, TCIOFLUSH)                  


if sys.platform=='darwin':
  class SerialPortOSX:
    """Encapsulate methods for accesing to a serial port."""

    BaudRatesDic={
        110: B110,
        300: B300,
        600: B600,
        1200: B1200,
        2400: B2400,
        4800: B4800, 
        9600: B9600,
        19200: B19200,
        38400: B38400,
        57600: B57600,
        115200: B115200,
        230400: B230400
        }
    buf = array.array('h', '\000'*4)

    def __init__(self, dev, timeout=None, speed=115200, mode='232', params=None):
        self.__devName, self.__timeout, self.__speed=dev, timeout, speed
        self.__mode=mode
        self.__params=params
        self.__speed = 0
        self.__reopen = 0
        while 1:
            try:
                self.__handle=os.open(dev, os.O_RDWR)
                break
                        
            except:
                n=0
                while (n < 2000000):
                    n += 1;                
                self.__reopen = self.__reopen + 1
            if self.__reopen > 32:
                print "Port does not exist..."
                raise SerialPortException('Port does not exist...')
                break

        self.__configure()

    def __del__(self):
	if self.__speed:
            #tcsetattr(self.__handle, TCSANOW, self.__oldmode)
            pass
            try:
                pass
                #os.close(self.__handle)
            except IOError:
                raise SerialPortException('Unable to close port')


    def __configure(self):
        if not self.__speed:
            self.__speed=115200
        
        # Save the initial port configuration
        self.__oldmode=tcgetattr(self.__handle)
        if not self.__params:
            # print "Create MacOSX params for serialport..."
            # self.__params is a list of attributes of the file descriptor
            # self.__handle as follows:
            # [c_iflag, c_oflag, c_cflag, c_lflag, c_ispeed, c_ospeed, cc]
            # where cc is a list of the tty special characters.
            self.__params=[]
            # c_iflag
            self.__params.append(IGNPAR)           
            # c_oflag
            self.__params.append(0)                
            # c_cflag
            self.__params.append(CS8|CREAD|CRTSCTS) 
            # c_lflag
            self.__params.append(0)                
            # c_ispeed
            self.__params.append(SerialPortOSX.BaudRatesDic[self.__speed]) 
            # c_ospeed
            self.__params.append(SerialPortOSX.BaudRatesDic[self.__speed]) 
	    cc=[0]*NCCS
        if self.__timeout==None:
            # A reading is only complete when VMIN characters have
            # been received (blocking reading)
            cc[VMIN]=1
            cc[VTIME]=0
        elif self.__timeout==0:
            cc[VMIN]=0
            cc[VTIME]=0
        else:
            cc[VMIN]=0
            cc[VTIME]=self.__timeout #/100
        self.__params.append(cc)               # c_cc
        
        tcsetattr(self.__handle, TCSANOW, self.__params)
    

    def fileno(self):
        return self.__handle


    def __read1(self):
        tryCnt = 0
        byte = ""
        while(len(byte)==0 and tryCnt<10):
            tryCnt+=1
            byte = os.read(self.__handle, 2)
        if len(byte)==0 and self.__timeout!=0: # Time-out
            print 'Time out cnt was %i'%(tryCnt) 
            print 'Expected 1 byte but got %i before timeout'%(len(byte))
            sys.stdout.flush()
            raise SerialPortException('Timeout')
        else:
            return byte
            

    def read(self, num=1):
        s=''
        for i in range(num/2):
            s=s+SerialPortOSX.__read1(self)
        return s


    def readline(self):

        s = ''
        while not '\n' in s:
            s = s+SerialPortOSX.__read1(self)

        return s 

        
    def write(self, s):
        """Write the string s to the serial port"""
        return os.write(self.__handle, s)
        
    def inWaiting(self):
        """Returns the number of bytes waiting to be read"""
    	data = struct.pack("L", 0)
        data=fcntl.ioctl(self.__handle, FIONREAD, data)
    	return struct.unpack("L", data)[0]

    def outWaiting(self):
        """Returns the number of bytes waiting to be write
        mod. by J.Grauheding
        result needs some finetunning
        """
        rbuf=fcntl.ioctl(self.__handle, FIONWRITE, self.buf)
        return rbuf

    
    def flush(self):
        """Discards all bytes from the output or input buffer"""
        tcflush(self.__handle, TCIOFLUSH)                  



#### end inline of artec FTDI specific Uspp code ###############################################


#### Dongle code starts here  ##################################################################


#### global funcs ####
def usage(s):
    print "Artec USB Dongle programming utility ver. 2.7 prerelease"
    print "Usage:"
    print "Write file      : ",s," [-vq] -c <name> <file> <offset>"
    print "Readback file   : ",s," [-vq] -c <name> [-vq] -r <offset> <length> <file>"
    print "Options:"
    print " <file> <offset> When file and offset are given file will be written to dongle"
    print "        file:    File name to be written to dongle"
    print "        offset:  Specifies data writing starting point in bytes to 4M window"
    print "                 For ThinCan boot code the offset = 4M - filesize. To write"
    print "                 256K file the offset must be 3840K or EOF"
    print "                 EOF marker will cause the dongle.py to calculate suitable offset"    
    print "                 and also cause files with odd byte count to be front padded"        
    print " "
    print " -c <name>       Indicate port name where the USB Serial Device is"
    print "        name:    COM port name in Windows or Linux Examples: COM3,/dev/ttyS3"
    print "                 See Device Manager in windows for USB Serial Port number"
    print " "
    print " -v              Enable verbose mode. Displays more progress information"
    print " "
    print " -q              Perform flash query to see if dongle flash is responding"
    print " "
    print " -r <offset> <length> <file>  Readback data. Available window size is 4MB"
    print "        offset:  Offset byte addres inside 4MB window. Example: 1M"
    print "                 use M for MegaBytes, K for KiloBytes, none for bytes"
    print "                 use 0x prefix to indicate hexademical number format"
    print "        length:  Amount in bytes to read starting from offset. Example: 1M"
    print "                 use M for MegaBytes, K for KiloBytes, none for bytes"
    print "        file:    Filename where data will be written"
    print " "
    print " -e              Erase device. Erases Full 4 MegaBytes"    
    print "Board test options: "
    print " -t              Marching one and zero test. Device must be empty"
    print "                 To test dongle erase the flash with command -e"
    print "                 Enables dongle memory tests to be executed by user"
    print " "
    print " -b              Leave flash blank after test. Used with option -t"
    print " -l              Fast poll loop test. Does poll loop 1024 times"
    print "                 used to stress test connection"
    print " -p and -P       Used to change ldev_present_n signal on Dongle II LPC interface"
    print "                 -p will cause the signal to go low and -P to go high"
    print "                 from reset and when dongle FPGA is not configured the signal is low."
    print "                 The state is not held when power is disconnected"
    print ""       
    print "Examples:"
    print ""
    print " ",s," -c COM3 loader.bin 0                       "
    print " ",s," -c /dev/ttyS3 boot.bin 3840K"
    print " ",s," -c COM3 -r 0x3C0000 256K flashcontent.bin"
    print " ",s," -c /dev/cu.usbserial-003011FD -v (Mac OS X)"
######################


class DongleMode:
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
        self.p = 0
        self.u = 0
        self.filename=""
        self.portname=""
        self.address=-1
        self.eof=-1
        self.oddSize=0
        self.oddAddr=0
        self.offset=-1
        self.length=-1
        self.version=4
        self.region=-1
     
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

    
    
    
class Dongle:
    def __init__(self,name, baud, timeout):  #time out in millis 1000 = 1s baud like 9600, 57600
        self.mode = 0
        try:
            if sys.platform=='win32':
                self.tty = SerialPortWin(name,timeout, baud)
            elif sys.platform=='linux2': 
                self.tty = SerialPortLin(name,timeout, baud)
            elif sys.platform=='darwin': 
                self.tty = SerialPortOSX(name,timeout, baud)
            
        except SerialPortException , e:
            print "Unable to open port " + name
            sys.exit();

    def testReturn(self,byteCount):
        i=0
        while don.tty.inWaiting()<byteCount:
            i=i+1
            if i==10000*byteCount:
                break
        if i==10000*byteCount:
            return 0
        j=don.tty.inWaiting()
        #print "Tested in waiting %i needed %i"%(j,byteCount)
        return j  ## ret two bytes            
            
    def getReturn(self,byteCount):
        i=0
        #while don.tty.inWaiting()<byteCount:
        #    i=i+1
        #    time.sleep(0.1)
        #    if i==100*byteCount:
        #        print "Dongle not communicating"
        #        #print "Read in waiting %i needed %i was %i"%(i,byteCount,don.tty.inWaiting())
        #        sys.exit()
        #        break
            
        #i=don.tty.inWaiting()
        #print "Read in waiting %i needed %i was %i"%(i,byteCount,don.tty.inWaiting())
        buf = don.tty.read(byteCount)
        #print "Got bytes =%i "%(len(buf))
        return buf  ## ret two bytes
    

    def write_command(self,command):
        lsb = command&0xff
        msb = (command>>8)&0xff
        self.write_2bytes(msb,lsb)
        
    def write_2bytes(self, msb,lsb):
        """Write one word MSB,LSB to the serial port MSB first"""
        #print "---------->  CMD %02x %02x"%(msb,lsb)
        s = pack('BB', msb, lsb)
        ret = self.tty.write(s)
        if(ret<len(s)):
            print 'write_2byte: Wrote less then needed %i bytes from %i'%(ret,length(s))        
        # Wait for the write to complete
        #WaitForSingleObject(overlapped.hEvent, INFINITE)               

    def get_address_buf(self,address):  #set word address
        lsbyte = address&0xff
        byte = (address>>8)&0xff
        msbyte = (address>>16)&0xff
        buffer = ""
        buffer += chr(lsbyte)
        buffer += chr(0xA0)
        buffer +=  chr(byte)
        buffer +=  chr(0xA1)
        buffer +=  chr(msbyte)
        buffer +=  chr(0xA2)
        evaluate = (address>>24)
        if evaluate != 0:
            print "Addressign fault. Too large address passed"
            sys.exit()
        return buffer
        

    def set_address(self,address):  #set word address
        lsbyte = address&0xff
        byte = (address>>8)&0xff
        msbyte = (address>>16)&0xff
        evaluate = (address>>24)
        if evaluate != 0:
            print "Addressing fault. Too large address passed"
            sys.exit()
        self.write_2bytes(lsbyte,0xA0)            #set internal address to dongle
        self.write_2bytes(byte,0xA1)            #set internal address to dongle
        self.write_2bytes(msbyte,0xA2)            #send query command

    def read_data(self,wordCount,address):
        command = 0
        byteCount = wordCount<<1  #calc byte count
        if wordCount>0 :
            command = (command|wordCount)<<8
            command = command|0xCD
            self.set_address(address)    # send read address
            self.write_command(command)  # send get data command
            return self.getReturn(byteCount)
        else:
            print "Word count can't be under 1"
            sys.exit() 
              
            
    def issue_blk_read(self):
        command = 0
        wordCount = 0
        byteCount = wordCount<<1  #calc byte count
        command = (command|wordCount)<<8
        command = command|0xCD
        self.write_command(command)  # send get data command


            
            
    def read_status(self):
        don.write_command(0x0070) # 0x0098 //clear status
        command = 0
        wordCount= 1  #calc byte count
        byteCount = wordCount<<1
        command = (command|wordCount)<<8
        command = command|0xCD
        self.write_command(command)  # send get data command
        return self.getReturn(byteCount)

    
    def get_block_no(self,address):
        return address >> 16 # 16 bit mode block is 64Kwords
    
    def wait_on_busy(self):
        exit=0
        while exit==0:
            buf=self.read_status()
            statReg = ord(buf[0])  #8 bit reg
            if statReg>>7 == 1:
                exit=1
                
    def parse_status(self):  # use only after wait on busy commad to get result of the operation
        exit = 0
        buf=self.read_status()
        statReg = ord(buf[0])  #8 bit reg
        if (statReg>>5)&1 == 1:
            print "Block erase suspended"
            exit = 1
        if (statReg>>4)&3 == 3:
            print "Error in command order"  #if bits 4 and 5 are set then 
            exit = 1
        if (statReg>>4)&3 == 1:
            print "Error in setting lock bit"
            exit = 1
        if (statReg>>3)&1 == 1:
            print "Low Programming Voltage Detected, Operation Aborted"        
            exit = 1
        if (statReg>>2)&1 == 1:
            print "Programming suspended"                
            exit = 1
        if (statReg>>1)&1 == 1:
            print "Block lock bit detected"   
            exit = 1
        if exit == 1:
            sys.exit()
                
    def erase_block(self,blockNo):
        blockAddress = blockNo << 16
        command = 0x0020
        self.set_address(blockAddress)
        self.write_command(command)  #issue block erase
        command = 0x00D0
        self.write_command(command)  #issue block erase confirm
        #self.wait_on_busy()
        #self.parse_status()
    
    def buffer_write_ram(self,startAddress,word_buf):
        wordsWritten = 0
        length = len(word_buf)  # get the byte count
        #print "block write request for word cnt= %i"%(length//2)
        if length == 65536*2:
            #print "block write word cnt = 65536"
            adrBuf = self.get_address_buf(startAddress+wordsWritten)   #6 bytes total         
            cmd_e8=""  #8 bytes total
            cmd_e8+= chr(0)   #write word count 0 is 64K words
            cmd_e8+= chr(0xE9)              
            buffer = adrBuf+cmd_e8 #prepare command
            #i=0
            #while i<65536*2:
            #    buffer = buffer + word_buf[wordsWritten*2+i+1]+word_buf[wordsWritten*2+i]
            #    i=i+2
            #print "block write buffer size = %i"%(len(word_buf[:wordsWritten*2+65536*2]))
            buffer = buffer + word_buf[0:wordsWritten*2+65536*2]
            self.tty.write(buffer)
            wordsWritten = wordsWritten + 65536 - 2  #two last words are written brokenly bu large block write
            length = length - 65536*2 + 4 # this amout has been written (two last words are written brokenly bu large block write)
        if length >= 32:  # can't write in one go so we must loop the code
            while length>=32:  #if we have atleast 32 bytes
                cmd_e8=""  #8 bytes total
                adrBuf = self.get_address_buf(startAddress+wordsWritten)   #6 bytes total
                #print "block write word cnt = 16"
                cmd_e8+= chr(16)   #write word count 16 is 32 bytes
                cmd_e8+= chr(0xE9)              
                buffer = adrBuf + cmd_e8 #prepare command
                #i=0
                #while i<32:
                #    #print "Adding to write buffer %02x%02x"%(ord(word_buf[i+1]),ord(word_buf[i]))
                #    buffer = buffer + word_buf[wordsWritten*2+i+1]+word_buf[wordsWritten*2+i]
                #    i=i+2
                #print "block write buffer size = %i"%(len(word_buf[wordsWritten*2:wordsWritten*2+32]))
                buffer = buffer + word_buf[wordsWritten*2:wordsWritten*2+32]
                self.tty.write(buffer) #ok buffer is filled
                wordsWritten = wordsWritten + 16
                length = length - 32 # this amout has been written
        #and finally deal with smaller writes than 64K or 16 word blocks
        if length%2==1:  #uneven byte count given we must add one byte of padding
            print "uneaven write byte count, length = %i padding the end with extra byte 0xff "%(length)
            word_buf=word_buf+chr(0xFF)
        if length > 0:    
            #print "block write tail word cnt= %i"%(length//2+length%2)
            adrBuf = self.get_address_buf(startAddress+wordsWritten)   #6 bytes total
            cmd_e8=""  #8 bytes total
            cmd_e8+= chr(length//2+length%2)   #write word count 0 is 64K words
            cmd_e8+= chr(0xE9)              
            buffer = adrBuf + cmd_e8
            #i=0
            #while i<length+length%2:
            #    buffer = buffer + word_buf[wordsWritten*2+i+1]+word_buf[wordsWritten*2+i]
            #    i=i+2
            #print "block write buffer size = %i"%(len(word_buf[wordsWritten*2:wordsWritten*2+length+length%2]))
            buffer = buffer + word_buf[wordsWritten*2:wordsWritten*2+length+length%2]
            self.tty.write(buffer)             
        
                 
        
    def buffer_write(self,wordCount,startAddress,buffer):
        # to speed up buffer writing compose all commands into one buffer
        # instead of multiple single writes this is needed as the FTDI chip
        # round lag is amazingly large with VCOM drivers
        #u = len(buffer)
        if len(buffer)<32:            #don't ever make unaligned writes
            i=len(buffer)
            while len(buffer)<32:
                buffer += "\xff"
        adrBuf = self.get_address_buf(startAddress)   #6 bytes total
        cmd_e8=""  #8 bytes total
        cmd_e8+= chr(16)   #make it always 16 wordCount
        cmd_e8+= chr(0xE8)              
        cmd_wcnt=""  #10 bytes total
        cmd_wcnt+= chr(0x00)
        cmd_wcnt+= chr(16-1)        
        cmd_buf=""  #12 bytes total
        cmd_buf+= chr(0x00)
        cmd_buf+= chr(0xD0)
        wr_buffer_cmd = adrBuf + cmd_e8 + cmd_wcnt + buffer + cmd_buf   #44 bytes total
        self.write_buf_cmd(wr_buffer_cmd)
        
        if self.mode.version <5:
            n = 0
            if sys.platform=='win32':
                while (n < 1024):
                    n += 1;
            elif sys.platform=='linux2' or sys.platform=='darwin':
                #Linux FTDI VCP driver is way faster and needs longer grace time than windows driver
                while (n < 1024*8):
                    n += 1;                    

    def write_buf_cmd(self, buffer):
        """Write one word MSB,LSB to the serial port MSB first"""
        a=0
        s=""
	if (len(buffer) < 44):  # if buffer is shorter than expected then pad with read array mode commands
            i=0
            while i<len(buffer):
                print '0x%02x'%(ord(buffer[i]))
                i+=1
            while(a < len(buffer)):
                if a < 10:
                    s= pack('2c', buffer[a], buffer[a+1])
                    self.tty.write(s)
                elif a < len(buffer)-2:
                    s= pack('2c', buffer[a+1], buffer[a])
                    self.tty.write(s)
                elif  len(buffer)==2:
                    s=pack('2c', buffer[a], buffer[a+1])
                    self.tty.write(s)
                else:
                     s=pack('2c', buffer[a], chr(0xFF))
                     self.tty.write(s)
                a+=2       
        else:
            #first 10 bytes are in correct order + 32 data bytes are in wrong order and + 2 confirm bytes are in correct order
            s=pack('44c', 
            buffer[0], buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6], buffer[7],
            buffer[8], buffer[9], buffer[11], buffer[10], buffer[13], buffer[12], buffer[15], buffer[14],
            buffer[17], buffer[16], buffer[19], buffer[18], buffer[21], buffer[20], buffer[23], buffer[22],
            buffer[25], buffer[24], buffer[27], buffer[26], buffer[29], buffer[28], buffer[31], buffer[30],
            buffer[33], buffer[32], buffer[35], buffer[34], buffer[37], buffer[36], buffer[39], buffer[38],
            buffer[41], buffer[40], buffer[42], buffer[43]
            )
            ret = self.tty.write(s)


############# Main program functions #################### 

def flash_write(mode,don):
    #Calculate number of blocks and start of blocks
    size = 0
    if mode.address&1 == 1:
        mode.oddAddr=1
    mode.address = mode.address>>1  #make word address
    try:
        f=open(mode.filename,"rb")
        f.seek(0,2) #seek to end
        size = f.tell()
        f.seek(0) #seek to start
        print 'File size %iK '%(size/1024)
        f.close()
    except IOError:
         print "IO Error on file open. File missing or no premission to open."
         don.write_command(0x00FF) # 0x0098  --set flash to read array mode
         don.write_command(0xC6C5)   #clear lock bit
         ret_buf=don.getReturn(2)    #two bytes expected to this command         
         sys.exit()
         
    if mode.eof==1:
        if (size&1==1):
            mode.oddSize = 1            
        region_size_w = 0x200000     # 4M region word count
        #print "Given region size = %i bytes"%(region_size_w*2)
        file_size_w = (size+ (size&1))>> 1
        #print "Given file size = %i bytes"%(file_size_w*2)
        mode.address = region_size_w - file_size_w
        print "Offset will be 0x%x"%(mode.address*2)
        
         
    #clear blockLock bits
    don.write_command(0x0060) # 0x0098
    don.write_command(0x00D0) # 0x0098
    if mode.version < 5:
        don.wait_on_busy()
        don.parse_status()
    wordSize = (size+ (size&1))>> 1    # round byte count up and make word address    
    endBlock = don.get_block_no(mode.address+wordSize - 1)  
    startBlock = don.get_block_no(mode.address)
    if endBlock >= 32:
        print "Given file does not fit into remaining space. File size is %i KB"%(size/1024)
        print "Space left from given offset is %i KB"%((4*1024*1024-mode.address*2)/1024)
        don.write_command(0x00FF) # 0x0098  --set flash to read array mode
        don.write_command(0xC6C5)   #clear lock bit
        ret_buf=don.getReturn(2)    #two bytes expected to this command                 
        sys.exit()
    i=startBlock
    print 'Erasing from block %i to %i '%(i,endBlock)
    while i <= endBlock:
        if mode.v == 1:
            print 'Erasing block %i '%(i)
        else:
            sys.stdout.write(".")
            sys.stdout.flush()
        don.erase_block(i)
        if mode.version < 5:
            don.wait_on_busy()
            don.parse_status()   #do this after programming all but uneaven ending
        i=i+1
    if mode.v == 0:
        print " "
    f=open(mode.filename,"rb")
    f.seek(0) #seek to start
    address= mode.address
    #don.set_address(address)
    print 'Writing %iK'%(size/1024)
    while 1:
        if (address/(1024*64) != (address-16)/(1024*64)) and address != mode.address:  # get bytes from words if 512
            if mode.v == 1:
                print 'Progress: %iK of %iK at 0x%06x'%((address-mode.address)/512,size/1024,address)
            else:
                sys.stdout.write(".")
                sys.stdout.flush()
        if mode.oddSize==1 or mode.oddAddr==1:  
            mode.oddSize = 0   # odd file size when writing BIOS to the end of region should be also front padded
            mode.oddAddr = 0   # as odd address is shifted right padding should be added in front of data
            buf = "\xFF"+f.read(31)  #16 words is maximum write here bytes are read
        else:
            buf = f.read(32)  #16 words is maximum write here bytes are read
            
        if len(buf)==32:
            don.buffer_write(16,address,buf)
            address = address + 16
        elif len(buf)>0:
            don.parse_status()   #do this after programming all but uneaven ending
            print "Doing an unaligned write..."
            length = len(buf)
            length = (length + (length&1))>> 1   #round up to get even word count
            buf = buf+"\xff"   #pad just in case rounding took place
            don.buffer_write(len,address,buf)
            address = address + 16     #inc word address
            break
        else:
            break
    if mode.v == 0:
        print " "
    if mode.version >= 5:
        print "Waiting for buffers to empty"
        don.wait_on_busy()
        don.parse_status()   #do this after programming all but uneaven ending        
    print "Write DONE!"
    don.parse_status()   #do this after programming all but uneaven ending
    f.close()                
    don.write_command(0x00FF) # 0x0098  --set flash to read array mode
    
    
    
def psram_write(mode,don):
    #Calculate number of blocks and start of blocks
    size = 0
    if mode.address&1 == 1:
        mode.oddAddr=1    
    mode.address = mode.address>>1  #make word address
    #check that file exists
    try:
        f=open(mode.filename,"rb")
        f.seek(0,2) #seek to end
        size = f.tell()
        f.seek(0) #seek to start
        print 'File size %iK '%(size/1024)
        f.close()
    except IOError:
         print "IO Error on file open. File missing or no premission to open."
         don.write_command(0xC6C5)   #clear lock bit
         ret_buf=don.getReturn(2)    #two bytes expected to this command                  
         sys.exit()

    if mode.eof==1:
        if (size&1==1):
            mode.oddSize = 1   # deal with odd file sizes        
        region_size_w = 0x200000     # 4M region word count
        #print "Given region size = %i bytes"%(region_size_w*2)
        file_size_w = (size+ (size&1))>> 1
        #print "Given file size = %i bytes"%(file_size_w*2)
        mode.address = region_size_w - file_size_w
        print "Offset will be 0x%x"%(mode.address*2)
                  
         
    #check that file size fits to remaining space given     
    wordSize = (size+ (size&1))>> 1    # round byte count up and make word address
    endBlock = don.get_block_no(mode.address+wordSize - 1)  
    startBlock = don.get_block_no(mode.address)
    if endBlock >= 32:
        print "Given file does not fit into remaining space. File size is %i KB"%(size/1024)
        print "Space left from given offset is %i KB"%((4*1024*1024-mode.address*2)/1024)
        don.write_command(0xC6C5)   #clear lock bit
        ret_buf=don.getReturn(2)    #two bytes expected to this command                 
        sys.exit()
    i=startBlock
    #Start writing the file content to dongle PSRAM
    f=open(mode.filename,"rb")
    f.seek(0) #seek to start
    address= mode.address
    #don.set_address(address)
    print 'Writing %iK'%(size/1024)
    while 1:
        if (address/(1024*64) != (address-16)/(1024*64)) and address != mode.address:  # get bytes from words if 512
            if mode.v == 1:
                print 'Progress: %iK of %iK at 0x%06x'%((address-mode.address)/512,size/1024,address)
            else:
                sys.stdout.write(".")
                sys.stdout.flush()
        if mode.oddSize==1 or mode.oddAddr==1:
            mode.oddSize = 0
            mode.oddAddr = 0
            buf = "\xFF"+f.read(65536*2-1)  #65536 words is maximum write here bytes are read (*2 is byte count)
        else:
            buf = f.read(65536*2)  #65536 words is maximum write here bytes are read (*2 is byte count)
            
        if len(buf)==65536*2:
            don.buffer_write_ram(address,buf)
            address = address + 65536  # add word count
        elif len(buf)>0:
            print "Doing an unaligned write..."
            length = len(buf)
            don.buffer_write_ram(address,buf)
            address = address + length//2     #inc word address
            break
        else:
            break
    if mode.v == 0:
        print " "       
    print "Write DONE!"
    f.close()         
    
    
def flash_read(mode,don):
    if mode.offset!=-1 and mode.length!=-1 and mode.filename!="":
        if mode.version >= 5:
            ##################### from hw ver 5 readback code ##################################################
            blockCount = (mode.length>>17)+1 #read this many 64K word blocks
            mode.offset=mode.offset>>1    #make word offset
            lastLength = mode.length&0x0001FFFF  
            mode.length= mode.length>>1   #make word length
            if mode.length < 512:                
                print 'Reading %i bytes in single block '%(lastLength)
            else:
                print 'Reading %iK '%(mode.length/512)
            don.write_command(0x00FF) #  put flash to data read mode
            try:
                f=open(mode.filename,"wb")  #if this fails no point in reading as there is nowhere to write
                address = mode.offset    # set word address
                don.set_address(address)
                i=0
                while (i<blockCount):
                    don.issue_blk_read()  # request 64K words from current address
                    buf=don.getReturn(65536*2) #Read all words
                    if (i==blockCount-1):  #last block
                        f.write(buf[:lastLength])
                    else:
                        f.write(buf) ## must tuncate the buffer
                    if mode.v == 1:
                        print 'Got block %i'%(i+1)
                    else:
                        sys.stdout.write(".")
                        sys.stdout.flush()
                    i+=1
                f.close()    
            except IOError:
                print "IO Error on file open"
                don.write_command(0x00FF) # 0x0098  --set flash to read array mode
                don.write_command(0xC6C5)   #clear lock bit
                ret_buf=don.getReturn(2)    #two bytes expected to this command                         
                sys.exit()                    
            ##################### end from hw ver 5 readback code  ############################################ 
        else:
            ##################### before hw ver 5 readback code ###############################################
            mode.offset=mode.offset>>1    #make word offset
            mode.length= mode.length>>1   #make word length
            print 'Reading %iK'%(mode.length/512)
            try:
                f=open(mode.filename,"wb")
                don.write_command(0x00FF) #  put flash to data read mode
                address = mode.offset    # set word address
                while 1:
                    if address/(1024*32) != (address-128)/(1024*32):  # get K bytes from words if 512
                        if mode.v == 1:
                            print 'Progress: %iK of %iK'%((address-mode.offset)/512,mode.length/512)
                        else:
                            sys.stdout.write(".")
                            sys.stdout.flush()
                    buf=don.read_data(128,address)  # word count and byte address read 64 words to speed up
                    f.write(buf)
                    #print "from address:",address<<1," ", len(buf)
                    if address+128 >= (mode.offset + mode.length):  # 2+64 estimates the end to end in right place
                        break
                    address = address + 128    #this is word address
                f.close()
                if mode.v == 0:
                    print " "            
                print "Readback done!"
            except IOError:
                print "IO Error on file open"
                don.write_command(0x00FF) # 0x0098  --set flash to read array mode
                don.write_command(0xC6C5)   #clear lock bit
                ret_buf=don.getReturn(2)    #two bytes expected to this command                         
                sys.exit()        
       ##################### end before hw ver 5 readback code  ################################################ 
    else:
       print "Some of readback parameters missing..."
       print mode.offset,mode.length, mode.filename
       don.write_command(0x00FF) # 0x0098  --set flash to read array mode
       don.write_command(0xC6C5)   #clear lock bit
       ret_buf=don.getReturn(2)    #two bytes expected to this command                
       sys.exit()
    don.write_command(0x00FF) # 0x0098  --set flash to read array mode
    

def psram_read(mode,don):
    if mode.offset!=-1 and mode.length!=-1 and mode.filename!="":
        if mode.version > 5:  #should never be smaller here
            blockCount = (mode.length>>17)+1 #read this many 64K word blocks
            mode.offset=mode.offset>>1    #make word offset
            lastLength = mode.length&0x0001FFFF  
            mode.length= mode.length>>1   #make word length
            if mode.length < 512:                
                print 'Reading %i bytes in single block '%(lastLength)
                sys.stdout.flush()
            else:
                print 'Reading %iK'%(mode.length/512)
                sys.stdout.flush()
            try:
                f=open(mode.filename,"wb")  #if this fails no point in reading as there is nowhere to write
                address = mode.offset    # set word address
                don.set_address(address)
                i=0
                while (i<blockCount):
                    try:
                        don.issue_blk_read()  # request 64K words from current address
                        buf=don.getReturn(65536*2) #Read all words
                    except SerialPortException:
                        if sys.platform=='win32':
                            print("\nExit due to driver error...")
                            print("Please disconnect dongle and try again... \n")
                            sys.exit()
                        else:
                            print("\nPlease send email to jyrit@artecdesign.ee stating your dongle version")
                            print("disconnect the dongle and try again")
                    if (i==blockCount-1):  #last block
                        f.write(buf[:lastLength])
                    else:
                        f.write(buf) ## must tuncate the buffer
                    if mode.v == 1:
                        print 'Got block %i'%(i+1)
                    else:
                        sys.stdout.write(".")
                        sys.stdout.flush()
                    i+=1
                f.close()    
            except IOError:
                print "IO Error on file open"
                don.write_command(0xC6C5)   #clear lock bit
                ret_buf=don.getReturn(2)    #two bytes expected to this command                         
                sys.exit()                     
        else:
            print "Dongle PSRAM region supported since hw version 8606 on Dongle II boards"
    
       ##################### end before hw ver 5 readback code  ################################################ 
    else:
       print "Some of readback parameters missing..."
       print mode.offset,mode.length, mode.filename
       don.write_command(0xC6C5)   #clear lock bit
       ret_buf=don.getReturn(2)    #two bytes expected to this command                
       sys.exit()  
    
       
def flash_qry(mode,don):
    buf=don.read_data(4,0x0)  # word count and word address
    don.write_command(0x0050)  #FLASH command clear status register   
    don.write_command(0x0098)  #FLASH command read QRY
    buf=don.read_data(3,0x000010)  # word count and word address
    if ord(buf[0])==0x51 and  ord(buf[2])==0x52 and  ord(buf[4])==0x59:
        buf=don.read_data(2,0x000000)  # word count and word address
        print 'Query  OK, Flash Factory Code is: 0x%02x device: 0x%02x '%(ord(buf[0]),ord(buf[2]))
        buf=don.read_data(2,0x000002)
	print 'lock bit is 0x%02x 0x%02x'%(ord(buf[0]),ord(buf[1]))
    else:
        print "Got bad Flash query data:"
        print 'Query address 0x10 = 0x%02x%02x '%(ord(buf[1]),ord(buf[0]))
        print 'Query address 0x12 = 0x%02x%02x '%(ord(buf[3]),ord(buf[2]))
        print 'Query address 0x14 = 0x%02x%02x '%(ord(buf[5]),ord(buf[4]))    
        print "Read byte count:",len(buf)
 
    don.write_command(0x00FF) # 0x0098  --set flash to read array mode
    buf=don.read_data(4,0xff57c0>>1)  # word count and word address

    print 'Data: 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x '%(ord(buf[1]),ord(buf[0]),ord(buf[3]),ord(buf[2]),ord(buf[5]),ord(buf[4]),ord(buf[7]),ord(buf[6]) )

   
def flash_test(mode,don):
        print "FLASH TEST"
        test_status = 1
        if mode.e == 1:
            #Erase Dongle
            print "Erasing"
            don.write_command(0x0060) # 0x0098
            don.write_command(0x00D0) # 0x0098
            don.wait_on_busy()
            don.parse_status()
            endBlock = 31
            startBlock = 0
            i=startBlock
            while i <= endBlock:
                if mode.v == 1:
                    print 'Erasing block %i '%(i)
                else:
                     sys.stdout.write(".")
                     sys.stdout.flush()
                don.erase_block(i)
                don.wait_on_busy()
                don.parse_status()   #do this after programming all but uneaven ending
                i=i+1  
            if mode.v == 0: # add CRTL return to dots
                print ""
        #Do marching one test on data and address
        mode.length= 0   #make word length
        don.write_command(0x00FF) #  put flash to data read mode
        buf2=don.read_data(1,0)  #read first byte
        if ord(buf2[0]) != 0xFF:
            print "Can't run FLASH TEST on unerased flash first byte is 0x%02x"%(ord(buf2[0]))
            don.write_command(0x00FF) # 0x0098  --set flash to read array mode
            don.write_command(0xC6C5)   #clear lock bit
            ret_buf=don.getReturn(2)    #two bytes expected to this command                     
            sys.exit()        
        try:
            #Marching one test
            print "Single bit high test on addr and data"
            #---------------------------------------------------------------------------
            address = 0x100000    # set word address
            data = 0x100000
            while mode.length<20: # last address to test 0x20 0000  
                buf1=pack('BBBB', (0x000000FF&data),(0x0000FF00&data)>>8 ,(0x00FF0000&data)>>16 ,(0xFF0000&data)>>24 )
                don.buffer_write(2,address,buf1)
                don.parse_status()   #do this after programming all but uneaven ending
                don.write_command(0x00FF) #  put flash to data read mode   
                buf2=don.read_data(2,address)  # word count and byte address read 64 words to speed up
                if buf1 != buf2:
                    print 'IN  %02x %02x %02x %02x '%(ord(buf1[3]), ord(buf1[2]),ord(buf1[1]), ord(buf1[0]))
                    print 'OUT %02x %02x %02x %02x '%(ord(buf2[3]), ord(buf2[2]),ord(buf2[1]), ord(buf2[0]))
                    print "Address used = 0x%08x"%(address&0x1FFFFF)
                    print "Data written = 0x%08x"%(data&0xFFFF)                    
                    print "Test FAIL!!!!!"                    
                    test_status = 0
                buf2=don.read_data(1,0)  #read first byte
                if ord(buf2[0]) != 0xFF:
                    print "Address used = 0x%08x"%(address&0x1FFFFF)
                    print "Test FAIL (Used address line probably const. 0)!"
                    test_status = 0
                    don.write_command(0x00FF) # 0x0098  --set flash to read array mode
                    don.write_command(0xC6C5)   #clear lock bit
                    ret_buf=don.getReturn(2)    #two bytes expected to this command                             
                    sys.exit()   
                address = address >> 1
                if address == 0x2:
                    address = address >> 1  # 0x2 is written and will return zero on read as write new write will fail
                data = data >> 1
                mode.length =  mode.length + 1

            #-----------------------------------------------------------------------
            #Marching zero test
            print "Single bit low test on addr and data"
            address = 0xFFEFFFFF    # set word address
            data = 0xFFEFFFFF
            while mode.length<18: # last address to test 0x20 0000  
                buf1=pack('BBBB', (0x000000FF&data),(0x0000FF00&data)>>8 ,(0x00FF0000&data)>>16 ,(0xFF0000&data)>>24 )
                don.buffer_write(2,address,buf1)
                don.parse_status()   #do this after programming all but uneaven ending
                don.write_command(0x00FF) #  put flash to data read mode   
                buf2=don.read_data(2,address&0x1FFFFF)  # word count and byte address read 64 words to speed up
                if buf1 != buf2:
                    print 'IN  %02x %02x %02x %02x '%(ord(buf1[3]), ord(buf1[2]),ord(buf1[1]), ord(buf1[0]))
                    print 'OUT %02x %02x %02x %02x '%(ord(buf2[3]), ord(buf2[2]),ord(buf2[1]), ord(buf2[0]))
                    print "Address used = 0x%08x"%(address&0x1FFFFF)
                    print "Data written = 0x%08x"%(data&0xFFFF)                    
                    print "Test FAIL!!!!!"                    
                    print "Test FAIL!!!!!"
                    test_status = 0
                buf2=don.read_data(1,0x1FFFFF)  #read first byte
                if ord(buf2[0]) != 0xFF:
                    print "Address used = 0x%08x"%(address&0x1FFFFF)
                    print "Test FAIL (At used address line const. 1 or lines bonded)!"                
                    test_status = 0
                    don.write_command(0x00FF) # 0x0098  --set flash to read array mode
                    don.write_command(0xC6C5)   #clear lock bit
                    ret_buf=don.getReturn(2)    #two bytes expected to this command                             
                    sys.exit()   
                address = (address >> 1)|0xFF000000
                data = data >> 1
                mode.length =  mode.length + 1
            if mode.b == 1:
                #Erase Dongle
                print "Erasing"
                don.write_command(0x0060) # 0x0098
                don.write_command(0x00D0) # 0x0098
                don.wait_on_busy()
                don.parse_status()
                endBlock = 31
                startBlock = 0
                i=startBlock
                while i <= endBlock:
                    if mode.v == 1:
                        print 'Blanking block %i '%(i)
                    else:
                        sys.stdout.write(".")
                        sys.stdout.flush()
                    don.erase_block(i)
                    if mode.version < 5:
                        don.wait_on_busy()
                        don.parse_status()   #do this after programming all but uneaven ending
                    i=i+1
                if mode.v == 0:
                    print " "
            if  test_status == 1:
                print "Test SUCCESSFUL!"
            don.write_command(0x00FF) # 0x0098  --set flash to read array mode
            don.write_command(0xC6C5)   #clear lock bit
            ret_buf=don.getReturn(2)    #two bytes expected to this command                     
            sys.exit()  
        except IOError:
            print "IO Error on file open"
            don.write_command(0x00FF) # 0x0098  --set flash to read array mode
            don.write_command(0xC6C5)   #clear lock bit
            ret_buf=don.getReturn(2)    #two bytes expected to this command                     
            sys.exit()        
        don.write_command(0x00FF) # 0x0098  --set flash to read array mode
        
def psram_test(mode,don):
        print "PSRAM TEST"
        test_status = 1
        #Do marching one test on data and address
        mode.length= 0   #make word length
        try:
            print "Single bit high test on addr and data"
            #---------------------------------------------------------------------------
            address = 0x100000    # set word address
            data = 0x100000
            don.buffer_write_ram(0,"\xFF\xFF")  #init PSRAM
            while mode.length<20: # last address to test 0x20 0000  
                buf1=pack('BBBB', (0x000000FF&data),(0x0000FF00&data)>>8 ,(0x00FF0000&data)>>16 ,(0xFF0000&data)>>24 )
                don.buffer_write_ram(address,buf1)
                buf2=don.read_data(2,address)  # word count and byte address read 64 words to speed up
                if buf1 != buf2:
                    print 'IN  %02x %02x %02x %02x '%(ord(buf1[3]), ord(buf1[2]),ord(buf1[1]), ord(buf1[0]))
                    print 'OUT %02x %02x %02x %02x '%(ord(buf2[3]), ord(buf2[2]),ord(buf2[1]), ord(buf2[0]))
                    print "Address used = 0x%08x"%(address&0x1FFFFF)
                    print "Data written = 0x%08x"%(data&0xFFFF)                    
                    print "Test due to data FAIL!!!!!"
                    test_status=0
                buf2=don.read_data(1,0)  #read first byte
                if ord(buf2[0]) != 0xFF:
                    print "Address used = 0x%08x"%(address&0x1FFFFF)
                    print "Test FAIL (At least one address line const. 0)!!!!!"
                    test_status=0
                    don.write_command(0xC6C5)   #clear lock bit
                    ret_buf=don.getReturn(2)    #two bytes expected to this command                             
                    sys.exit()   
                address = address >> 1
                if address == 0x2:
                    address = address >> 1  # 0x2 is written and will return zero on read as write new write will fail
                data = data >> 1
                mode.length =  mode.length + 1

            #-----------------------------------------------------------------------
            #Marching zero test
            print "Single bit low test on addr and data"
            address = 0xFFEFFFFF    # set word address
            data = 0xFFEFFFFF
            while mode.length<18: # last address to test 0x20 0000  
                buf1=pack('BBBB', (0x000000FF&data),(0x0000FF00&data)>>8 ,(0x00FF0000&data)>>16 ,(0xFF0000&data)>>24 )
                don.buffer_write_ram(address&0x1FFFFF,buf1)
                buf2=don.read_data(2,address&0x1FFFFF)  # word count and byte address read 64 words to speed up
                if buf1 != buf2:
                    print 'IN  %02x %02x %02x %02x '%(ord(buf1[3]), ord(buf1[2]),ord(buf1[1]), ord(buf1[0]))
                    print 'OUT %02x %02x %02x %02x '%(ord(buf2[3]), ord(buf2[2]),ord(buf2[1]), ord(buf2[0]))
                    print "Address used = 0x%08x"%(address&0x1FFFFF)
                    print "Data written = 0x%08x"%(data&0xFFFF)
                    print "Test FAIL!!!!!"
                    test_status=0
                buf2=don.read_data(1,0x1FFFFF)  #read first byte
                if ord(buf2[0]) != 0xFF:
                    print "Address used = 0x%08x"%(address&0x1FFFFF)
                    print "Test FAIL (At used address least two address lines bonded or const. 1)!"                
                    test_status=0
                    don.write_command(0xC6C5)   #clear lock bit
                    ret_buf=don.getReturn(2)    #two bytes expected to this command                             
                    sys.exit()   
                address = (address >> 1)|0xFF000000
                data = data >> 1
                mode.length =  mode.length + 1
            if test_status==1:
                print "Test SUCCESSFUL!"
            don.write_command(0xC6C5)   #clear lock bit
            ret_buf=don.getReturn(2)    #two bytes expected to this command                         
            sys.exit()  
        except IOError:
            print "IO Error on file open"
            don.write_command(0xC6C5)   #clear lock bit
            ret_buf=don.getReturn(2)    #two bytes expected to this command                     
            sys.exit()                    
            
def flash_erase(mode,don):
            #Erase Dongle
            print "Erasing all"
            don.write_command(0x0060) # 0x0098
            don.write_command(0x00D0) # 0x0098
            if mode.version < 5:
                don.wait_on_busy()
                don.parse_status()
            endBlock = 31
            startBlock = 0
            i=startBlock
            while i <= endBlock:
                if mode.v == 1:
                    print 'Erasing block %i '%(i)
                else:
                     sys.stdout.write(".")
                     sys.stdout.flush()
                don.erase_block(i)
                if mode.version < 5:
                    don.wait_on_busy()
                    don.parse_status()   #do this after programming all but uneaven ending
                i=i+1  
            if mode.v == 0: # add CRTL return to dots
                print "" 
            if mode.version >= 5:
                print "Waiting for buffers to empty"
                don.wait_on_busy()
                don.parse_status()   #do this after programming all but uneaven ending
            print "Erase done."            
            don.write_command(0x00FF) # 0x0098  --set flash to read array mode
def flash_looptest(mode,don):
            print "Status Loop test"
            i=1024
            startTime = time.clock()
            while i > 0:
                if i%128==0:
                    sys.stdout.write(".")
                    sys.stdout.flush()
                don.wait_on_busy()
                don.parse_status()   #do this after programming all but uneaven ending
                i=i-1
            #if sys.platform=='win32':
            endTime = (time.clock()-startTime)/1024.0
            print "\nSystem round delay is %4f ms"%(endTime*1000.0)
            sys.stdout.flush()    
            don.write_command(0x00FF) # 0x0098  --set flash to read array mode
            
################## Main program #########################


last_ops = 0
mode = DongleMode()
# PARSE ARGUMENTS 
for arg in sys.argv:
    if len(sys.argv) == 1: # if no arguments display help
       #usage(sys.argv[0])
       usage("dongle.py")
       sys.exit()        
    if arg in ("-h","--help","/help","/h"):
        #usage(sys.argv[0])
        usage("dongle.py")
        sys.exit()
    if arg in ("-c"):
        last_ops = sys.argv.index(arg) + 1  #if remains last set of options from here start ordered strings
        i = sys.argv.index(arg)
        print "Opening port: "+sys.argv[i+1]
        mode.portname = sys.argv[i+1]   # next element after -c open port for usage
    if arg[0]=="-" and arg[1]!="c": # if other opptions
        # parse all options in this
        last_ops = sys.argv.index(arg)  #if remains last set of options from here start ordered strings
        ops = arg[1:]# get all besides the - sign
        for op in ops:
            if op=="q":
                mode.q = 1
            if op=="v":
                mode.v = 1
            if op=="f":
                mode.f = 1
            if op=="d":
                mode.d = 1
            if op=="r":
                mode.r = 1
            if op=="t":
                mode.t = 1  
            if op=="e":
                mode.e = 1   
            if op=="b":
                mode.b = 1
            if op=="l":
                mode.l = 1
            if op=="p":
                mode.p = 0
            if op=="P":
                mode.p = 1
            if op=="u":
                mode.u = 1                     
    else:
        i = sys.argv.index(arg)
        if i ==  last_ops + 1:
            if mode.r==1:
                mode.offset=mode.convParamStr(arg)
            else:
                mode.filename=arg
        if i ==  last_ops + 2:
            if mode.r==1:
                mode.length=mode.convParamStr(arg)
            else:
                if arg.find("EOF")>-1:
                    print "Found EOF marker"
                    mode.eof = 1    #the file is to be written to the end of 4M area
                    mode.address = 0
                else:
                    mode.address=mode.convParamStr(arg)
                
        if i ==  last_ops + 3:
            if mode.r==1:
                mode.filename=arg
            else:
                print "Too many parameters provided"
                sys.exit()
        if i >  last_ops + 3:
             print "Too many parameters provided"
             sys.exit()  

# END PARSE ARGUMENTS             
             
if mode.portname=="":
    print "No port name given see -h for help"
    sys.exit()    
else:
    # test PC speed to find sutable delay for linux driver
    # to get 250 us 
    mytime = time.clock()
    n = 0
    while (n < 100000):
	n += 1;
    k10Time = time.clock() - mytime   # time per 10000 while cycles
    wait = k10Time/100000.0     # time per while cycle
    wait = (0.00025/wait) * 1.20   # count for 250us + safe margin
    # ok done
    reopened = 0
    
    
    if sys.platform=='win32':
        don  = Dongle(mode.portname,256000,6000)
    elif sys.platform=='linux2':
        don  = Dongle(mode.portname,230400,6000)
        #don.tty.cts()
    elif sys.platform=='darwin':
        don  = Dongle(mode.portname,230400,6000)
        #don.tty.cts()
    else:
        sys.exit('Sorry, no implementation for this platform yet')
    
    
    don.tty.wait = wait   
    while 1:
        #don.write_command(0x0050)    #FLASH command clear status register  
        don.write_command(0x00C5)            #send dongle check internal command
        don_ret=don.testReturn(2)
        if don_ret==2:
            break
        if reopened == 3:
             print 'Dongle connected, but does not communicate'
             sys.exit()
        reopened = reopened + 1
        # reopen and do new cycle
        if sys.platform=='win32':
            don  = Dongle(mode.portname,256000,6000)
        elif sys.platform=='linux2':
            don  = Dongle(mode.portname,230400,6000)
            #self.tty.cts()
        elif sys.platform=='darwin':
            don  = Dongle(mode.portname,230400,6000)
            #self.tty.cts()
        else:
            sys.exit('Sorry, no implementation for this platform yet')
        don.tty.wait = wait   

    buf=don.getReturn(2)  # two bytes expected to this command
    if ord(buf[1])==0x32 and  ord(buf[0])==0x10:
        print "Dongle OK"
    else:
        print 'Dongle returned on open: %02x %02x '%(ord(buf[1]), ord(buf[0]))
    don.write_command(0x01C5)            #try getting dongle HW ver (works since 05 before that returns 0x3210)
    buf=don.getReturn(2)  # two bytes expected to this command
    if ord(buf[1])==0x86 and  ord(buf[0])>0x04:
        mode.version = ord(buf[0])
        don.mode = mode
        print 'Dongle HW version code is  %02x %02x'%(ord(buf[1]), ord(buf[0]))
        
        print 'Dongle version is  %x'%(mode.version)
    else:
        don.mode = mode
        print 'Dongle HW version code is smaller than 05 some features have been improved on'
        print 'HW code and Quartus FPGA binary file are available at:' 
        print 'http://www.opencores.org/projects.cgi/web/usb_dongle_fpga/overview'
        print 'Programming is possible with Altera Quartus WE and BYTEBLASTER II cable or'
        print 'compatible clone like X-Blaster http://www.customcircuitsolutions.com/cable.html'
    
    if mode.version>0x19:   # Dongle II versions
        print 'Other status info:'
        if mode.p == 0:
            don.write_command(0xC3C5)  # ldev_present_n set to 0   (is active low for thincan)       
            buf_dc = don.getReturn(2)  # two bytes expected to this command    
        else:
            don.write_command(0xC4C5)  # ldev_present_n set to 1 (is active low for thincan) 
            buf_dc = don.getReturn(2)  # two bytes expected to this command                
        if mode.u == 1:
            don.write_command(0xC2C5)  # force USB prog mode signals to conf memory  
            #buf_dc = don.getReturn(2)  # two bytes expected to this command                
            sys.exit()
        don.write_command(0x02C5)  #try getting PCB ver (works since 06 before that returns 0x3210)
        buf=don.getReturn(2)  # two bytes expected to this command
        i_temp = 0
        i_temp = (ord(buf[1])<<8)|ord(buf[0])
        print 'Dongle PCB version code is AD 67075%05i'%( i_temp )
        don.write_command(0x03C5)            #try getting mode switch setting (works since 06 before that returns 0x3210)
        buf=don.getReturn(2)  # two bytes expected to this command
        mode_reg = ord(buf[0])
        print 'Dongle memory region  %02x'%(mode_reg)
        if ord(buf[1])==0x00:        
            if ord(buf[0]) > 3:
                print 'PSRAM region selected'
            else:
                print 'FLASH region selected'
            mode.region = mode_reg  #set the region for PSRAM support                            
    if mode.region>3:
        pass
        #print 'Initialize psram on region %i'%(mode.region)
        #PSRAM mode init
    else:
        #print 'Initialize flash on region %i'%(mode.region)
        don.write_command(0x0050)    #FLASH command clear status register
        don.write_command(0x00FF) # 0x0098  --set flash to read array mode
        #Flash mode init

#Lock LPC out from memory interface        
don.write_command(0xC5C5)   #set lock bit up
ret_buf=don.getReturn(2)    #two bytes expected to this command

if mode.q == 1:   # perform a query from dongle  
    if mode.region<4:
        flash_qry(mode,don)
    else:
        print "Query only supported on flash regions (to change region turn the Mode switch):"
        print "FLASH regions are regions from 0 to 3"    
    
    
if mode.filename!="" and mode.address!=-1:   #Dongle write command given
    if mode.region<4:
        print "Flash write called"
        flash_write(mode,don)
    else:
        print "PSRAM write called"
        psram_write(mode,don)
    
if mode.r == 1:   # perform a readback
    if mode.region<4:
        print "Flash read called"
        flash_read(mode,don)
    else:
        print "PSRAM read called"
        psram_read(mode,don)    
    
if mode.t == 1:   # perform dongle test
    if mode.region<4:
        flash_test(mode,don)
    else:
        psram_test(mode,don)
if mode.e == 1:   # perform dongle erase
    if mode.region<4:
        flash_erase(mode,don)
    else:
        print "Erase is supported on flash regions (to change region turn the Mode switch):"
        print "FLASH regions are regions from 0 to 3"    
        
if mode.l == 1:   # perform dongle test  
    if mode.region<4:
        flash_looptest(mode,don)
    else:
        print "Looptest is supported on flash regions (to change region turn the Mode switch):"
        print "FLASH regions are regions from 0 to 3"            
    
##########################################################

#Unlock memory interface        
don.write_command(0xC6C5)   #clear lock bit
ret_buf=don.getReturn(2)    #two bytes expected to this command
sys.exit()


