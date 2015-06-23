#! /usr/bin/python

######################################################
#-- author: 	Andrea Borga (andrea.borga@nikhef.nl)
#-- date: $22/11/2011    $: created
#--
#-- version: $Rev 0      $:
#--
#-- description:
#--    basic python script to read and write 
#--    UART registers
#--
#--    NOTE: look through the code for this
#--
#--         -- ----------------------
#--         -- ----------------------
#--
#--   to spot where the code needs customization 
#
#-- Tested with Python 2.6 on Ubunru 10.04 LTS
#
#
######################################################


import serial 
#ser = serial.Serial('/dev/ttyUSB0',115200,timeout=1)
ser = serial.Serial()
ser.port = "/dev/ttyUSB0" # set your port check in /dev folder
#ser.baudrate = 115200 # set your baud rate
ser.baudrate = 921600
ser.timeout = 1
ser.open()
print "Connected to: \t", ser.portstr
print "FPGA is ready to accept a command"
print "^] to quit" 
print "help for command menu"
while 1: 
 if ser.isOpen():
   in_var_add = raw_input("Type a command >> ")
   if in_var_add != '\x1d' :     # send a command
     if in_var_add == 'help' :   # help menu 
      print "\n", "here is a list implemented commands"
      print "  release on  : enables GXBs, PRBS tx, and PRBS rx"
      print "  release off : disables whole logic"
      #-----------------------
	  # add commands description here
	  #-----------------------
      print "  update      : sends an update command"
      print "  help        : prints this menu", "\n"
     elif in_var_add == 'release on' :
       ser.write('\x00\x30\x00\x00\x01\x11')
     #elif in_var_add == 'release off' :
     #  ser.write('\x00\x30\x00\x00\x00\x00')
	 #-----------------------
	 # add more commands here
	 #-----------------------
     elif in_var_add == 'update' :
       ser.write('\x80\x00\x00\x00\x00\x00')
       out_resp = ser.read(72) # read 72 bytes
	   #-----------------------
	   # specify the number of bytes to be readout
	   # nbytes = nregisters * 6
	   #-----------------------
       out_split_resp = list(out_resp)
       print "Received: "
       ch_arr_resp = range(72)
       hex_arr_resp = range(72)
       for i in range (0,72):
         ch_arr_resp[i] = ord(out_split_resp[i])
         hex_arr_resp[i] = hex(ch_arr_resp[i])
       for x in range (0, 67, 6):
        print repr(hex_arr_resp[x]).rjust(2), repr(hex_arr_resp[x+1]).rjust(3), repr(hex_arr_resp[x+2]).rjust(4), repr(hex_arr_resp[x+3]).rjust(5), repr(hex_arr_resp[x+4]).rjust(6),
        print repr(hex_arr_resp[x+5]).rjust(7)
     else :
       print "unkown command, try again"                        
   elif in_var_add == '\x1d' : #ctrl+]
     print "...connetion closed..."
     ser.close()
     break                 # exit app

    
