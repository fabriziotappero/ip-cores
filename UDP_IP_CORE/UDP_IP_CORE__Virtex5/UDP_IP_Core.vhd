-----------------------------------------------------------------------------------------
-- Copyright (C) 2010 Nikolaos Ch. Alachiotis														--
--																													--
-- Engineer: 				Nikolaos Ch. Alachiotis														--
--																													--
-- Contact:					alachiot@cs.tum.edu															--
--								n.alachiotis@gmail.com		 												--
-- 																												--
-- Create Date:    		15:29:59 02/07/2010  														--
-- Module Name:    		UDP_IP_Core					  													--
-- Target Devices: 		Virtex 5 FPGAs 																--
-- Tool versions: 		ISE 10.1																			--
-- Description: 			This component can be used to transmit and receive UDP/IP      --
--								Ethernet Packets (IPv4).													--
-- Additional Comments: The core has been area-optimized and is suitable for direct    --
--				            PC-FPGA communication at Gigabit speed.                        --
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
           usr_data_output_bus : out  STD_LOGIC_VECTOR (7 downto 0)
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
			  transmit_data_output_bus : out STD_LOGIC_VECTOR (7 downto 0)			  
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

begin

IPV4_PACKET_TRANSMITTER_port_map: IPV4_PACKET_TRANSMITTER 
    Port Map
	 ( rst => rst,
      clk_125MHz => clk_125MHz,
      transmit_start_enable => transmit_start_enable,
      transmit_data_length => transmit_data_length,
		usr_data_trans_phase_on => usr_data_trans_phase_on,
      transmit_data_input_bus => transmit_data_input_bus,
      start_of_frame_O => start_of_frame_O,
		end_of_frame_O => end_of_frame_O,
		source_ready => source_ready,
		transmit_data_output_bus => transmit_data_output_bus		  
	);


IPv4_PACKET_RECEIVER_port_map: IPv4_PACKET_RECEIVER 
    Port Map
	 ( rst => rst,
      clk_125Mhz => clk_125Mhz,
      rx_sof => rx_sof,
      rx_eof => rx_eof,
      input_bus => input_bus,
      valid_out_usr_data => valid_out_usr_data,
      usr_data_output_bus => usr_data_output_bus
	);

end Behavioral;

