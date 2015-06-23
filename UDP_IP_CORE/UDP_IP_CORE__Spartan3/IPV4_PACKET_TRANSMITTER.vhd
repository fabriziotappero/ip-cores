-----------------------------------------------------------------------------------------
-- Copyright (C) 2010 Nikolaos Ch. Alachiotis														--
--																													--							
-- Engineer: 				Nikolaos Ch. Alachiotis														--
--																													--
-- Contact:					alachiot@cs.tum.edu															--
--								n.alachiotis@gmail.com		 												--
-- 																												--
-- Create Date:    		14:45:39 11/27/2009  														--
-- Module Name:    		IPV4_PACKET_TRANSMITTER  													--
-- Target Devices: 		Virtex 5 FPGAs 																--
-- Tool versions: 		ISE 10.1																			--
-- Description: 			This component can be used to send IPv4 Ethernet Packets.		--
-- Additional Comments: The look-up table contains the header fields of the IP packet, --
--								so please keep in mind that you have to reinitialize this LUT. --
--																													--
-----------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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

architecture Behavioral of IPV4_PACKET_TRANSMITTER is


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-- IPv4 PACKET STRUCTURE :																																					--
--											Size		|		Description											|		Transmission Order		|  Position		--
--										-----------------------------------------------------------------------------------------------------------
--											6 bytes	|	Destin MAC Address (PC)								|		0 1 2 3 4 5				|	LUT				--
--														|	X-X-X-X-X-X												|									|						--
--														|																|									|						--
--											6 bytes	|	Source MAC Address (FPGA)							|	   6 7 8 9 10 11			|	LUT				--
--														|	11111111-11111111-11111111-11111111-...		|									|						--
--											2 bytes  |	Ethernet Type * 										|		12 13						|	LUT				--
--														|	(fixed to 00001000-00000000 :=>					|									|						--
--														|	 Internet Protocol, Version 4 (IPv4))			|									|						--
-- -- Start of IPv4 Packet ** -	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	--	|						--
--											1 byte	|	4 MSBs = Version , 4 LSBs = Header Length		|		14							|	LUT				--
--			                                 |  0100				0101									|									|						--
--											1 byte	|	Differentiated Services								|		15							|	LUT				--
--														|	00000000													|									|						--
--											2 bytes	|	Total Length											|		16 17						|	REG				--
--														|	00000000-00100100 (base: 20 + 8 + datalength)|									|						--
--											2 bytes	|	Identification											|		18 19						|	LUT				--
--														|	00000000-00000000										|									|						--
--											2 bytes	|	3 MSBs = Flags , 13 LSBs = Fragment Offset 	|		20 21						|	LUT				--
--														|	010 - 0000000000000									|									|						--
--											1 byte	|	Time to Live											|		22							|	LUT				--
--														|	01000000													|									|						--
--											1 byte	|	Protocol													|		23							|	LUT				--
--														|	00010001													|									|						--
--											2 bytes	|  Header Checksum										|		24 25						|	REG				--
--														|	10110111 01111101 (base value)					|									|						--
--											4 bytes	|	Source IP Address										|		26 27 28 29				|	LUT				--
--														|	X-X-X-X										 - FPGA	|									|						--
--											4 bytes	|	Destin IP Address										|		30 31 32 33				|	LUT				--
--														|	X-X-X-X										 - PC		|									|						--
--	-- Start of UDP Packet *** -	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-- |						--
--											2 bytes	|  Source Port												|		34 35						|	LUT				--
--														|	X-X														|									|						--
--											2 bytes	|	Destination Port										|		36 37						|	LUT				--
--														|	X-X														|									|						--
--											2 bytes	| 	Length													|		38 39						|	REG				--
--														|	00000000 - 00010000   (8 + # data bytes)		|									|						--
--											2 bytes	|	Checksum													|		40 41						|	LUT				--
--														|	00000000 - 00000000									|									|						--
--											X bytes	|	Data														|		42 .. X					|  from input   	--
--														|																|									|						--
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

--  *  More details about the Ethernet Type value you can find here:
--     http://en.wikipedia.org/wiki/Ethertype

-- **  More details about the Internet Protocol, Version 4 (IPv4) you can find here:
--     http://en.wikipedia.org/wiki/IPv4

-- *** More details about the Internet Protocol, Version 4 (IPv4) you can find here:
--     http://en.wikipedia.org/wiki/User_Datagram_Protocol
 
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------
-- COMPONENT DECLARATION
--------------------------------------------------------------------------------------

component REG_16B_WREN is
    Port ( rst : in  STD_LOGIC;
			  clk : in  STD_LOGIC;
           wren : in  STD_LOGIC;
           input : in  STD_LOGIC_VECTOR (15 downto 0);
           output : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component IPV4_LUT_INDEXER is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           transmit_enable : in  STD_LOGIC;
           LUT_index : out  STD_LOGIC_VECTOR (5 downto 0));
end component;

component dist_mem_64x8 is
  port (
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 5 downto 0 ); 
    qspo : out STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end component;

component OVERRIDE_LUT_CONTROL is
    Port ( clk : in  STD_LOGIC;
	        input_addr : in  STD_LOGIC_VECTOR (5 downto 0);
           sel_total_length_MSBs : out  STD_LOGIC;
			  sel_total_length_LSBs : out  STD_LOGIC;
			  sel_header_checksum_MSBs : out  STD_LOGIC;
			  sel_header_checksum_LSBs : out  STD_LOGIC;
			  sel_length_MSBs : out  STD_LOGIC;
			  sel_length_LSBs : out  STD_LOGIC
           );
end component;

component TARGET_EOF is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           start : in  STD_LOGIC;
			  total_length_from_reg : in STD_LOGIC_VECTOR(15 downto 0);
           eof_O : out  STD_LOGIC);
end component;

component ENABLE_USER_DATA_TRANSMISSION is
    Port ( rst : in STD_LOGIC;
			  clk : in  STD_LOGIC;
           start_usr_data_trans : in  STD_LOGIC;
           stop_usr_data_trans : in  STD_LOGIC;
           usr_data_sel : out  STD_LOGIC);
end component;

component ALLOW_ZERO_UDP_CHECKSUM is
    Port ( clk : in  STD_LOGIC;
           input : in  STD_LOGIC;
			  output_to_readen  : out STD_LOGIC;
           output_to_datasel : out  STD_LOGIC);
end component;


--------------------------------------------------------------------------------------
-- SIGNAL DECLARATION
--------------------------------------------------------------------------------------

signal transmit_start_enable_tmp,
		 sel_total_length_MSBs,
		 sel_total_length_LSBs,
		 sel_header_checksum_MSBs,
		 sel_header_checksum_LSBs,
		 sel_length_MSBs,
		 sel_length_LSBs,
		 lut_out_sel,
		 source_ready_previous_value,
		 end_of_frame_O_tmp,
		 transmit_start_enable_reg,
		 usr_data_sel_sig,
		 start_usr_data_read,
		 start_usr_data_trans 								: 	STD_LOGIC;

signal LUT_addr 												: 	STD_LOGIC_VECTOR(5 downto 0);

signal transmit_data_input_bus_tmp,
		 transmit_data_output_bus_tmp,
		 sel_total_length_MSBs_vec,
		 sel_total_length_LSBs_vec,
		 sel_header_checksum_MSBs_vec,
		 sel_header_checksum_LSBs_vec,
		 sel_length_MSBs_vec,
		 sel_length_LSBs_vec,
		 lut_out_sel_vec,
		 transmit_data_output_bus_no_usr_data,
		 usr_data_not_sel_vec,
		 usr_data_sel_vec										: 	STD_LOGIC_VECTOR(7 downto 0);

signal transmit_data_length_tmp,
		 data_length_regout,
		 tmp_total_length,
		 tmp_header_checksum,
		 tmp_header_checksum_baseval,
		 tmp_length												: 	STD_LOGIC_VECTOR(15 downto 0);

		
begin

transmit_start_enable_tmp<=transmit_start_enable;

transmit_data_length_tmp<=transmit_data_length;

transmit_data_input_bus_tmp<=transmit_data_input_bus;

----------------------------------------------------------------------------------------------------
-- start_of_frame_O signal
----------------------------------------------------------------------------------------------------
-- Description:  start_of_frame_O is active low
--					  We connect it to the delayed for one clock cycle transmit_start_enable input signal
--					  through a NOT gate since transmit_start_enable is active high.

process(clk_125MHz)
begin
if clk_125MHz'event and clk_125MHz='1' then
	transmit_start_enable_reg<=transmit_start_enable_tmp; -- Delay transmit_start_enable one cycle.
end if;
end process;

start_of_frame_O<=not transmit_start_enable_reg;

----------------------------------------------------------------------------------------------------
-- end_of_frame_O signal
----------------------------------------------------------------------------------------------------
-- Description:  end_of_frame_O is active low
--					  The TARGET_EOF module targets the last byte of the packet that is being transmitted
--					  based on a counter that counts the number of transmitted bytes and a comparator that
--					  detects the last byte which is the <tmp_total_length>th byte.

TARGET_EOF_port_map: TARGET_EOF  port map
( 
	rst =>rst,
   clk =>clk_125MHz,
   start =>transmit_start_enable_reg,
	total_length_from_reg =>tmp_total_length,
   eof_O =>end_of_frame_O_tmp
);
			  
--* The counter in TARGET_EOF starts from -X, where X is the number of bytes transmitted before the 
--	 IPv4 packet. (MAC addresses + Ethernet Type)
			  
end_of_frame_O<=end_of_frame_O_tmp;

----------------------------------------------------------------------------------------------------
-- source_ready signal
----------------------------------------------------------------------------------------------------
-- Description:  source_ready is active low
--					  This signal is idle(high). (based on rst and end_of_frame_O_tmp). 
--					  This signal is active(low). (based on transmit_start_enable and end_of_frame_O_tmp).

process(clk_125MHz)
begin
if rst='1' then
	source_ready<='1';
	source_ready_previous_value<='1';
else
	if clk_125MHz'event and clk_125MHz='1' then
		if (transmit_start_enable_tmp='1' and source_ready_previous_value='1') then
			source_ready<='0';
			source_ready_previous_value<='0';
		else
			if (end_of_frame_O_tmp='0' and source_ready_previous_value='0') then
				source_ready<='1';
			   source_ready_previous_value<='1';
			end if;
		end if;
	end if;
end if;
end process;

----------------------------------------------------------------------------------------------------
-- transmit_data_output_bus 
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Component Name: 	REG_16B_WREN
-- Instance Name: 	NUMBER_OR_DATA_IN_BYTES_REGISTER
-- Description: 		Register that holds the number of bytes of input data 
--					  		that will be transmitted in the packet.
----------------------------------------------------------------------------------------------------
NUMBER_OR_DATA_IN_BYTES_REGISTER : REG_16B_WREN port map 
(
	rst =>rst,
	clk =>clk_125MHz,
	wren =>transmit_start_enable_tmp, -- The transmit_start_enable input signal can be used as wren.
	input =>transmit_data_length_tmp,
	output =>data_length_regout
);
----------------------------------------------------------------------------------------------------

tmp_total_length<="0000000000011100" + data_length_regout;    

tmp_header_checksum_baseval<="1011011101111101";	-- CHANGE VALUE! : You have to change this value!
tmp_header_checksum<=tmp_header_checksum_baseval - data_length_regout;  

tmp_length<="0000000000001000" + data_length_regout;

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Component Name: 	IPV4_LUT_INDEXER
-- Instance Name: 	IPV4_LUT_INDEXER_port_map
-- Description: 		When transmit_enable is high for one cycle IPV4_LUT_INDEXER generates the
--					  		addresses to the LUT that contains the header section of the IP packet.
----------------------------------------------------------------------------------------------------
IPV4_LUT_INDEXER_port_map : IPV4_LUT_INDEXER port map 
( 
	rst =>rst,
   clk =>clk_125MHz,
   transmit_enable =>transmit_start_enable_tmp,
   LUT_index =>LUT_addr
);
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Component Name: 	dist_mem_64x8
-- Instance Name: 	LUT_MEM
-- Description: 		LUT that contains the header section.
----------------------------------------------------------------------------------------------------
LUT_MEM : dist_mem_64x8 port map
(    
	clk =>clk_125MHz,
   a =>LUT_addr,
   qspo =>transmit_data_output_bus_tmp
);
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Component Name: 	OVERRIDE_LUT_CONTROL
-- Instance Name: 	OVERRIDE_LUT_CONTROL_port_map
-- Description: 		Decides whether the output byte will come from the LUT or not.
----------------------------------------------------------------------------------------------------
OVERRIDE_LUT_CONTROL_port_map : OVERRIDE_LUT_CONTROL port map
( 
	clk =>clk_125MHz,
	input_addr =>LUT_addr, 
	sel_total_length_MSBs =>sel_total_length_MSBs,
	sel_total_length_LSBs =>sel_total_length_LSBs,
	sel_header_checksum_MSBs =>sel_header_checksum_MSBs,
	sel_header_checksum_LSBs =>sel_header_checksum_LSBs,
	sel_length_MSBs =>sel_length_MSBs,
	sel_length_LSBs =>sel_length_LSBs
);
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- MUX 7 to 1
sel_total_length_MSBs_vec<=(others=>sel_total_length_MSBs);
sel_total_length_LSBs_vec<=(others=>sel_total_length_LSBs);
sel_header_checksum_MSBs_vec<=(others=>sel_header_checksum_MSBs);
sel_header_checksum_LSBs_vec<=(others=>sel_header_checksum_LSBs);
sel_length_MSBs_vec<=(others=>sel_length_MSBs);
sel_length_LSBs_vec<=(others=>sel_length_LSBs);
lut_out_sel_vec <= (others=>lut_out_sel);
	
lut_out_sel<=(not sel_total_length_MSBs) and (not sel_total_length_LSBs) and
				 (not sel_header_checksum_MSBs) and (not sel_header_checksum_LSBs) and
				 (not sel_length_MSBs) and (not sel_length_LSBs);

-- MUX output
transmit_data_output_bus_no_usr_data<= (transmit_data_output_bus_tmp and lut_out_sel_vec) or
												  (tmp_total_length(15 downto 8) and sel_total_length_MSBs_vec) or
												  (tmp_total_length(7 downto 0) and sel_total_length_LSBs_vec) or
												  (tmp_header_checksum(15 downto 8) and sel_header_checksum_MSBs_vec) or
												  (tmp_header_checksum(7 downto 0) and sel_header_checksum_LSBs_vec) or
												  (tmp_length(15 downto 8) and sel_length_MSBs_vec) or
												  (tmp_length(7 downto 0) and sel_length_LSBs_vec);
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Component Name: 	ALLOW_ZERO_UDP_CHECKSUM
-- Instance Name: 	ALLOW_ZERO_UDP_CHECKSUM_port_map
-- Description: 		Delays the user data transmition phase in order to transmit two bytes with zero
--							first.
----------------------------------------------------------------------------------------------------
ALLOW_ZERO_UDP_CHECKSUM_port_map: ALLOW_ZERO_UDP_CHECKSUM port map
( 
	clk =>clk_125MHz,
	input =>sel_length_LSBs,
	output_to_readen =>start_usr_data_read,
	output_to_datasel =>start_usr_data_trans
);
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Component Name: 	ENABLE_USER_DATA_TRANSMISSION
-- Instance Name: 	ENABLE_USER_DATA_READ_port_map
-- Description: 		Sets usr_data_trans_phase_on signal one cycle before the transmittion of the 
--							first user byte.
----------------------------------------------------------------------------------------------------
ENABLE_USER_DATA_READ_port_map: ENABLE_USER_DATA_TRANSMISSION port map
(	rst =>rst,
   clk =>clk_125MHz,
   start_usr_data_trans =>start_usr_data_read,
   stop_usr_data_trans =>end_of_frame_O_tmp,
   usr_data_sel =>usr_data_trans_phase_on
);
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Component Name: 	ENABLE_USER_DATA_TRANSMISSION
-- Instance Name: 	ENABLE_USER_DATA_TRANSMISSION_port_map
-- Description: 		Sets usr_data_sel_sig signal to select user data for transmittion.
----------------------------------------------------------------------------------------------------
ENABLE_USER_DATA_TRANSMISSION_port_map: ENABLE_USER_DATA_TRANSMISSION port map
(	rst =>rst,
   clk =>clk_125MHz,
   start_usr_data_trans =>start_usr_data_trans,
   stop_usr_data_trans =>end_of_frame_O_tmp,
   usr_data_sel =>usr_data_sel_sig
);
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- MUX 2 to 1
usr_data_not_sel_vec<=(others=>not usr_data_sel_sig);
usr_data_sel_vec<=(others=>usr_data_sel_sig);

-- MUX output
transmit_data_output_bus<=(transmit_data_output_bus_no_usr_data and usr_data_not_sel_vec) or
								 (transmit_data_input_bus and usr_data_sel_vec);
----------------------------------------------------------------------------------------------------

end Behavioral;
