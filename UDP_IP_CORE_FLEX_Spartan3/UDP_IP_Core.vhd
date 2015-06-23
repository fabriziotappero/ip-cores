-----------------------------------------------------------------------------------------
-- Copyright (C) 2010 Nikolaos Ch. Alachiotis														--
--																													--
-- Engineer: 				Nikolaos Ch. Alachiotis														--
--																													--
-- Contact:					n.alachiotis@gmail.com		 												--
-- 																												--
-- Create Date:    		04/03/2011				  														--
-- Module Name:    		UDP_IP_Core					  													--
-- Target Devices: 		Virtex 5 FPGAs 																--
-- Tool versions: 		ISE 10.1																			--
-- Description: 			This component can be used to transmit and receive UDP/IP      --
--								Ethernet Packets (IPv4).													--
-- Additional Comments: The core has been area-optimized and is suitable for direct    --
--				            PC-FPGA communication at Gigabit speed.                        --
--							                              												--
-----------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UDP_IP_Core is
    Port ( rst : in  STD_LOGIC;                -- active-high
           clk_125MHz : in  STD_LOGIC;
           
			  -- Transmit signals
			  transmit_start_enable : in  STD_LOGIC;
           transmit_data_length : in  STD_LOGIC_VECTOR (15 downto 0);
			  usr_data_trans_phase_on : out STD_LOGIC;
           transmit_data_input_bus : in  STD_LOGIC_VECTOR (7 downto 0);
           start_of_frame_O : out  STD_LOGIC;
			  end_of_frame_O : out  STD_LOGIC;
			  source_ready : out STD_LOGIC;
			  transmit_data_output_bus : out STD_LOGIC_VECTOR (7 downto 0);
			  
			  --Receive Signals
			  rx_sof : in  STD_LOGIC;
           rx_eof : in  STD_LOGIC;
           input_bus : in  STD_LOGIC_VECTOR(7 downto 0);
           valid_out_usr_data : out  STD_LOGIC;
           usr_data_output_bus : out  STD_LOGIC_VECTOR (7 downto 0);
			  
			  
			  locked : out  STD_LOGIC
			  );
end UDP_IP_Core;

architecture Behavioral of UDP_IP_Core is

component IPV4_PACKET_TRANSMITTER is
    Port ( rst : in  STD_LOGIC;
           clk_125MHz : in  STD_LOGIC;
           transmit_start_enable : in  STD_LOGIC;
           transmit_data_length : in  STD_LOGIC_VECTOR (15 downto 0);
			  usr_data_trans_phase_on : out STD_LOGIC;
           transmit_data_input_bus : in  STD_LOGIC_VECTOR (7 downto 0);
           start_of_frame_O : out  STD_LOGIC;
			  end_of_frame_O : out  STD_LOGIC;
			  source_ready : out STD_LOGIC;
			  transmit_data_output_bus : out STD_LOGIC_VECTOR (7 downto 0);

			  flex_wren: in STD_LOGIC;
			  flex_wraddr: in STD_LOGIC_VECTOR(5 downto 0);
			  flex_wrdata: in STD_LOGIC_VECTOR(7 downto 0);
			  
			  flex_checksum_baseval: in std_logic_vector(15 downto 0)		  
			  );
end component;

component IPv4_PACKET_RECEIVER is
    Port ( rst : in  STD_LOGIC;
           clk_125Mhz : in  STD_LOGIC;
           rx_sof : in  STD_LOGIC;
           rx_eof : in  STD_LOGIC;
           input_bus : in  STD_LOGIC_VECTOR(7 downto 0);
           valid_out_usr_data : out  STD_LOGIC;
           usr_data_output_bus : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

component FLEX_CONTROL is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           r_sof : in  STD_LOGIC;
			  r_usrvld : in STD_LOGIC;
           r_data : in  STD_LOGIC_VECTOR (7 downto 0);
			  r_usrdata: in STD_LOGIC_VECTOR (7 downto 0);
           r_eof : in  STD_LOGIC;
           l_wren : out  STD_LOGIC;
           l_addr : out  STD_LOGIC_VECTOR (5 downto 0);
           l_data : out  STD_LOGIC_VECTOR (7 downto 0);
			  checksum_baseval : out STD_LOGIC_VECTOR(15 downto 0);
			  locked : out  STD_LOGIC
);
end component;

signal valid_out_usr_data_t : STD_LOGIC;
signal usr_data_output_bus_t : STD_LOGIC_VECTOR (7 downto 0);

signal flex_wren:  STD_LOGIC;
signal flex_wraddr:  STD_LOGIC_VECTOR(5 downto 0);
signal flex_wrdata:  STD_LOGIC_VECTOR(7 downto 0);
signal flex_checksum_baseval: std_logic_vector(15 downto 0);		  

signal core_rst: std_logic;

component MATCH_CMD is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sof : in  STD_LOGIC;
           vld_i : in  STD_LOGIC;
           val_i : in  STD_LOGIC_VECTOR (7 downto 0);
			  cmd_to_match : in  STD_LOGIC_VECTOR(7 downto 0);
           cmd_match : out  STD_LOGIC);
end component;

begin

MATCH_RST_CODE: MATCH_CMD Port Map
( rst => rst,
  clk => clk_125MHz,
  sof => rx_sof,
  vld_i => valid_out_usr_data_t,
  val_i => usr_data_output_bus_t,
  cmd_to_match => "11111111",
  cmd_match => core_rst
 );

IPV4_PACKET_TRANSMITTER_port_map: IPV4_PACKET_TRANSMITTER 
    Port Map
	 ( rst => core_rst,
      clk_125MHz => clk_125MHz,
      transmit_start_enable => transmit_start_enable,
      transmit_data_length => transmit_data_length,
		usr_data_trans_phase_on => usr_data_trans_phase_on,
      transmit_data_input_bus => transmit_data_input_bus,
      start_of_frame_O => start_of_frame_O,
		end_of_frame_O => end_of_frame_O,
		source_ready => source_ready,
		transmit_data_output_bus => transmit_data_output_bus,
      flex_wren => flex_wren,
		flex_wraddr => flex_wraddr,
		flex_wrdata => flex_wrdata,
		flex_checksum_baseval => flex_checksum_baseval
	);


IPv4_PACKET_RECEIVER_port_map: IPv4_PACKET_RECEIVER 
    Port Map
	 ( rst => core_rst,
      clk_125Mhz => clk_125Mhz,
      rx_sof => rx_sof,
      rx_eof => rx_eof,
      input_bus => input_bus,
      valid_out_usr_data => valid_out_usr_data_t,
      usr_data_output_bus => usr_data_output_bus_t
	);
	
	
valid_out_usr_data <= valid_out_usr_data_t;
usr_data_output_bus <= usr_data_output_bus_t;
	
FLEX_CONTROL_port_map: FLEX_CONTROL 
	  Port Map
	  ( rst => core_rst,
       clk => clk_125Mhz,
       r_sof => rx_sof,
		 r_usrvld => valid_out_usr_data_t,
       r_data => input_bus,
		 r_usrdata => usr_data_output_bus_t,
       r_eof => rx_eof,
       l_wren => flex_wren,
       l_addr => flex_wraddr,
       l_data => flex_wrdata,
		 checksum_baseval => flex_checksum_baseval,
		 locked => locked
	);		


end Behavioral;

