==============================================
Project :	Prj_12_DDR2
Purpose :	DDR2-SDRAM at a Spartan-3A Board
DDR2-RAM :	MT47H32M16 (64 MByte)
Date :          19.08.2011
Version :       7.0
Plattform :     XILINX Spartan-3A
FPGA :          XC3S700A-FGG484
Language :      VHDL
ISE :		ISE-Design-Suite V:13.1
IP-Core :	MIG V:3.6.1
Author :        UB
Mail :          Becker_U(at)gmx.de
==============================================


first word :
================

> sorry for my bad english :-)



Moduls :
==================

   ###############         #########################    ################
   #             #         #                       #    #              #
   #  DDR2-RAM : #---------#  TOP_Modul_VHDL       #----# Buttons_VHDL #
   #  512 MBit   #         #                       #    #              #
   #             #         #                       #    ################
   ###############         #                       #
                           #                       #    ################
                           #                       #    #              #
                           #                       #----# Clock_VHDL   #
                           #                       #    #              #
                           #                       #    ################
                           #                       #
   ###############         #                       #    #####################    ###################
   #             #         #                       #    #                   #    #                 #
   #  Input :    #         #                       #    # DDR2_Control_VHDL #----# DDR2_READ_VHDL  #
   #  4 buttons  #---------#                       #    #                   #    #                 #
   #  4 switches #         #                       #----#                   #    ###################
   #             #         #                       #    #                   #
   ###############         #                       #    #                   #    ###################
                           #                       #    #                   #    #                 #
   ###################     #                       #    #                   #----# DDR2_Write_VHDL #
   #                 #     #                       #    #                   #    #                 #
   #  Output :       #-----#                       #    #                   #    ###################
   #  8 LEDs (Data)  #     #                       #    #####################
   #  1 LED (Status) #     #                       #
   ###################     #                       #    ####################### 
                           #                       #----#                     #
   ###############         #                       #    # DDR2_RAM_CORE.vhd   #
   #  Clock :    #---------#                       #    # MIG 3.6.1           # 
   #  133 MHz    #         #                       #    # (27 files)          #
   #             #         #                       #    # + UCF-File          #
   ###############         #########################    #######################



purpose :
========

> this project is a simple example how to implement the DDR2-SDRAM on a Xilinx FPGA Board
  (with the generated Code from the Xilinx MIG)



hint for using the DDR2-RAM :
===================================

> the complete DDR2_RAM_Core Files in this project are
  genaratet with the Xilinx MIG 3.6.1 tool


> MIG settings :
	- Typ = DDR2-SDRAM
	- Frq = 133MHz
	- Write Pipe Stages = 4
	- Memory Part = MT47H32M16XX-3 (for the Spartan-3A Board)
	- Data Width = 16
	- Data-Mask = Ja
	- SystemClock = Single-Ended
	- Signals at : Bank3 (complete) , Bank2 (V12)
	- Bank2 = System-Clock / Bank3 = Adrees-Control+Data+System-Control
	- all others : "Default"

> Hint : DDR2_RAM_CORE :

	- only the VHDL-Files from path
	  "USer_Design/RTL" are used
	- the oter files generated from MIG
	  are not necessary

> HINT : DDR2 UCF-File :

	- the settings in the UCF-File are very important
	  for the correct timing and function of the RAM
	- i have downloaded the original UCF-File
	  from Xilinx for the Spartan-3A Board
	  from these adress :
	  "http://www.xilinx.com/products/boards/s3astarter/reference_designs.htm"
	- a few changes are required (e.g. for the path)
	   

Function of the Project :
============================

> Switch-0 (SW0) is the Reset-Switch (High = Reset)

> the "TOP_Modul" only routes the signals between the other Moduls

> the "Buttons_VHDL" debounce the switches und buttons
  and generate a "rising_edge" signal for the 4 Buttons

> the "DDR2_Control" has a state machine with these steps :

  1. Init the RAM
  2. Automatic Write Sequenz (writes 16 Datawords each 64Bit)
  3. Automatic Read Sequenz (reads the first Dataword with 64Bit from adress 0)
  4. Wait for a button signal

  5a. Button-1 (north) -> increment ROW-Counter
  5b. Button-2 (south) -> decrement ROW-COunter
  5c. Button-3 (west)  -> writes a single Datawort (64Bit) to the actual adress
  5d. Button-4 (east)  -> reads a single Dataword (64Bit) from the actual adress

> the "DDR2_Control" also selects one Byte (from the 64Bit Dataword)

  - SW1 to SW3 are the MUX-Select-Pins :

	SW3=0 + SW2=0 + SW1=0 -> shows the Databits (D7...D0)
	SW3=0 + SW2=0 + SW1=1 -> shows the Databits (D15...D8)
	SW3=0 + SW2=1 + SW1=0 -> shows the Databits (D23...D16)
	SW3=0 + SW2=1 + SW1=1 -> shows the Databits (D31...D24)
	SW3=1 + SW2=0 + SW1=0 -> shows the Databits (D39...D32)
	SW3=1 + SW2=0 + SW1=1 -> shows the Databits (D47...D40)
	SW3=1 + SW2=1 + SW1=0 -> shows the Databits (D55...D48)
	SW3=1 + SW2=1 + SW1=1 -> shows the Databits (D63...D56)

	the selected Databits are shown on the 8 LEDs at the FPGA-Board

> the "DDR2_Read" has a state machine to read one Dataword (64Bit)
  from given adress

> the "DDR2_Write" has a state machine to write one Dataword (64Bit)
  to the given adress



Ram Data content after the automatic write sequenz :
======================================================

> after the automtic write sequenz the content of the first 16 Datawords are :

ADR 0 = 0123456789ABCDEF
ADR 1 = 123456789ABCDEF0
ADR 2 = 23456789ABCDEF01
ADR 3 = 3456789ABCDEF012
ADR 4 = 456789ABCDEF0123
ADR 5 = 56789ABCDEF01234
ADR 6 to ADR 15 = 639CC6398C7318E7



Process after power on :
==========================

> after the RAM-INIT and writing of 16 Datawords
  the first RAM-Adress is reading and shown on the LEDs

> the buttons "north" and "south" changes the actuall adress pointer

> to read one adress use button "east" 

> to write the Dataword "31CE629DC43B8877" use button "west"



RAM-Info :
================

> the size of the DDR2-RAM is 512MBit (64MByte)

> it is splitted in 4 Blocks (Banks)
  each Block has 8192 ROWs and 1024 COLs
  
  a single Datacell is 16bit wide

  4x8192*1024*16bit = 512MBit

> the Bank-Adress needs 2Bit
  the ROW-Adress needs 13Bit
  the COL-Adress needs 10Bit

> the Adresspointer looks like :

  ADR = ROW & COL & BANK

  the complete ADR-Pointer needs 25Bit



Restrictions in this project :
==================================

> the "Burst-Mode" is fixed set to "4"
  whis this setting the Dataword is 64Bit wide

> each read process reads 64Bit and each write process
  writes 64Bits

> to avoid data fail the COL-Adress must increment
  and decrement by the value of "4"
  like (0,4,8,12...)



Speed :
==================

> a single read process (of 64Bit) needs 22 Clockcycles
  (at 133MHz -> 165 ns => 46 MByte/sec)

> a single write process (of 64Bit) needs 25 Clockcycles
  (at 133MHz -> 188 ns => 40 MByte/sec)


last Hints :
=============

> this project is "from private"
  and not allowed for commercial use

> this project is not free of bugs
  and i can not give a guarantee
  for any kind of error or damages

> everyone is permitted to copy and modify
  this files

> please give me a notice if you found
  some bugs




19.08.11 / UB

