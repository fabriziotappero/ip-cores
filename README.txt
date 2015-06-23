======================================================================================================
IPv4 Ethernet Packet Transmitter (in VHDL)
======================================================================================================


Build date: December 15th, 2009


Description
-----------


This is a VHDL implementation of a component that can be connected to the input port of the 
Virtex-5 Ethernet MAC Local Link Wrapper and enable transmission of IPv4 ethernet packets.

Example placement:


--   ----------------------------------------------------------------------
--   |  EXAMPLE DESIGN WRAPPER                                            |
--   |            --------------------------------------------------------|
--   |            |LOCAL LINK WRAPPER                                     |
--   |            |              -----------------------------------------|
--   |            |              |BLOCK LEVEL WRAPPER                     |
--   |            |              |    ---------------------               |
--   |  --------  |  ----------  |    | ETHERNET MAC      |               |
--   |  | IPv4 |  |  |        |  |    | WRAPPER           |  ---------    |
--   |->| pack |->|->|        |--|--->| Tx            Tx  |--|       |--->|
--   |  | trans|  |  |        |  |    | client        PHY |  |       |    |
--   |  --------  |  | LOCAL  |  |    | I/F           I/F |  |       |    |  
--   |            |  |  LINK  |  |    |                   |  | PHY   |    |
--   |            |  |  FIFO  |  |    |                   |  | I/F   |    |
--   |            |  |        |  |    |                   |  |       |    |
--   |            |  |        |  |    | Rx            Rx  |  |       |    |
--   |            |  |        |  |    | client        PHY |  |       |    |
--   |          <-|<-|        |<-|----| I/F           I/F |<-|       |<---|
--   |            |  |        |  |    |                   |  ---------    |
--   |            |  ----------  |    ---------------------               |
--   |            |              -----------------------------------------|
--   |            --------------------------------------------------------|
--   ----------------------------------------------------------------------



Package Structure
-----------------

This package contains the following files and folder:

-README 				: This file

-IPv4_PACKET_TRANSMITTER	        : This folder contains VHDL, XCO and NGC files.

-LUT COE file 			        : This folder contains a COE file for the LUT that contains the IP packet header field.



Usage of the IPv4_PACKET_TRANSMITTER  
-----------------------


Before integrating the IPv4_PACKET_TRANSMITTER into your design you have to reinitialize the LUT.
This LUT contains the header section of the IP packet.One must change the X fields that appear in the following table.

The field that should be changed are:
Destination MAC Address : (LUT) 
Source MAC Address	: (LUT)
Source IP Address	: (LUT)
Destination IP Address  : (LUT)
Source Port		: (LUT)	
Destination Port	: (LUT)
Header Checksum 	: VHDL file

The Addresses are read from the LUT, thats why a reinitialization is required.
The Header Checksum base value is not read from the LUT. It can be found in the VHDL file.
The Header Checksum base value depends on the IP Addresses and it is the Header Checksum value of a packet with no user data. 


------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
-- IPv4 PACKET STRUCTURE :														--																							--
--	size	|		Description			|		Transmission Order		|  Position		--
------------------------------------------------------------------------------------------------------------------------------------------
--	6 bytes	|	Destin MAC Address (PC)			|		0 1 2 3 4 5			|	LUT		--
--		|	X-X-X-X-X-X				|						|			--
--		|						|						|			--
--	6 bytes |	Source MAC Address (FPGA)		|	        6 7 8 9 10 11			|	LUT		--
--		|	11111111-11111111-11111111-11111111-... |						|			--
--	2 bytes	|	Ethernet Type   			|		12 13				|	LUT		--
--		|	(fixed to 00001000-00000000 :=>		|						|			--
--		|	 Internet Protocol, Version 4 (IPv4))	|						|			--
-- -- Start of IPv4 Packet  	-	-	-	-	-	-	-	-	-	-	-	-	-	--						--
--	1 byte	|	4 MSBs = Version , 4 LSBs = Header Length|		14				|	LUT		--
--	        |  	0100	0101				|						|			--
--	1 byte	|	Differentiated Services			|		15				|	LUT		--
--		|	00000000				|						|			--
--	2 bytes	|	Total Length				|		16 17				|	REG		--
--		|	00000000-00100100 (base: 20 + 8 + datalength)|						|			--
--	2 bytes	|	Identification				|		18 19				|	LUT		--
--		|	00000000-00000000			|						|			--
--	2 bytes	|	3 MSBs = Flags , 13 LSBs = Fragment Offset|		20 21				|	LUT		--
--		|	010 - 0000000000000			|						|			--
--	1 byte	|	Time to Live				|		22				|	LUT		--
--		|	01000000				|						|			--
--	1 byte	|	Protocol				|		23				|	LUT		--
--		|	00010001				|						|			--
--	2 bytes	|  	Header Checksum				|		24 25				|	REG		--
--		|	X X (base value)			|						|			--
--	4 bytes	|	Source IP Address			|		26 27 28 29			|	LUT		--
--		|	X-X-X-X				- FPGA	|						|			--
--	4 bytes	|	Destin IP Address			|		30 31 32 33			|	LUT		--
--		|	X-X-X-X				 - PC	|						|			--
-- -- Start of UDP Packet    -	-	-	-	-	-	-	-	-	-	-	-	-	-       --						--
--	2 bytes	|  	Source Port				|		34 35				|	LUT		--
--		|	X-X					|						|			--
--	2 bytes	|	Destination Port			|		36 37				|	LUT		--
--		|	X-X					|						|			--
--	2 bytes	| 	Length					|		38 39				|	REG		--
--		|	00000000 - 00010000   (8 + # data bytes)|						|			--
--	2 bytes	|	Checksum				|		40 41				|	LUT		--
--		|	00000000 - 00000000			|						|			--
--	X bytes	|	Data					|		42 .. X				|    from input   	--
--		|						|						|			--					--
------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------ 



Interface of the LAU 
--------------------


The interface of the unit is defined as follows:

entity IPV4_PACKET_TRANSMITTER is
    Port ( rst : in  STD_LOGIC;
           clk_125MHz : in  STD_LOGIC;
           transmit_start_enable : in  STD_LOGIC;
           transmit_data_length : in  STD_LOGIC_VECTOR (15 downto 0);
	   usr_data_trans_phase_on : out STD_LOGIC;
           transmit_data_input_bus : in  STD_LOGIC_VECTOR (7 downto 0);
           start_of_frame_O : out  STD_LOGIC;
	   end_of_frame_O : out  STD_LOGIC;
	   source_ready : out STD_LOGIC;
	   transmit_data_output_bus : out STD_LOGIC_VECTOR (7 downto 0)			  
	);
end IPV4_PACKET_TRANSMITTER;


The IPv4 PACKET TRANSMITTER and the LOCAL LINK WRAPPER  must have the same rst and clk signals.

Signal transmit_start_enable : active high , It must be high for one clock cycle only.

Signal transmit_data_length  : number of user data to be transmitted (number of bytes)

Signal usr_data_trans_phase_on: is high one clock cycle before the transmittion of user data and remains high while transmitting user data.  

Signal transmit_data_input_bus : input data to be transmitted. Starts transmitting one clock cycle after the usr_data_trans_phase_on is set.

Signals start_of_frame_O,end_of_frame_O,source_ready,transmit_data_output_bus should be connected to the local link wrapper's input ports.
 

Implementation Details
----------------------

The VHDL unit have been designed using the Xilinx 10.1 Design Suite.

ISE 10.1 was used to create the unit.



Verification Details
--------------------

Modelsim 6.3f was used for extensive post place and route simulations.

The development board HTG-V5-PCIE by HiTech Global populated with a V5SX95T-1 FPGA was used to verify the correct behavior of the IPv4_PACKET_TRANSMITTER.




Authors and Contact Details 
---------------------------

Nikos Alachiotis			alachiot@in.tum.de , n.alachiotis@gmail.com
Alexandros Stamatakis 			stamatak@in.tum.de

Technichal University of Munich
Department of Computer Science / I 12
The Exelixis Lab
Boltzmannstr. 3
D-85748 Garching b. Muenchen



Citation
--------

By using this component in any architecture design and associated publication, you agree to cite it as: 
"Efficient PC-FPGA Communication over Gigabit Ethernet", by Nikolaos Alachiotis, Simon A. Berger and Alexandros Stamatakis, 
IEEE ICESS 2010, June/July 2010.


Copyright 
---------

This component is free. In case you use it for any purpose, particularly 
when publishing work relying on this component you must cite it as:

IPv4 PACKET TRANSMITTER by Nikolas Alachiotis and Alexandros Stamatakis, The Exelixis Lab, TU Munich, distributed by the authors via
http://wwwkramer.in.tum.de/exelixis/

You can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This component is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.



Release Notes
------------

Build date : December 15th, 2009







