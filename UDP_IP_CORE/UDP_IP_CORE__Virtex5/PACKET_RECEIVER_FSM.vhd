----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:48:34 02/07/2010 
-- Design Name: 
-- Module Name:    PACKET_RECEIVER_FSM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PACKET_RECEIVER_FSM is
    Port (
	        rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  
			  -- Signals from EMAC
			  rx_sof: in STD_LOGIC; -- active low input
			  rx_eof: in STD_LOGIC; -- active low input
			  
			  -- Signals to Counter and Comparator
			  sel_comp_Bval: out STD_LOGIC;
			  comp_Bval: out STD_LOGIC_VECTOR(10 downto 0);
           rst_count : out  STD_LOGIC;
           en_count : out  STD_LOGIC;
			  
			  -- Signal from Comparator
			  comp_eq: in STD_LOGIC;
			  			  
			  -- Signals to Length Register			  
			  wren_MSbyte: out STD_LOGIC;
			  wren_LSbyte: out STD_LOGIC;
			  
			  -- Signal to user interface
			  valid_out_usr_data: out STD_LOGIC);
end PACKET_RECEIVER_FSM;

architecture Behavioral of PACKET_RECEIVER_FSM is

TYPE state is (rst_state,
					idle_state,
					detect_n_store_usr_length_MSbyte_state,
					store_usr_length_LSbyte_state,
					checksum_gap_state,
					receive_usr_data_state);
					
signal current_st,next_st: state;

constant  udp_length_match_cycle : std_logic_vector(10 downto 0):="00000100100"; -- UDP length MSbyte - 2
constant  udp_checksum_skip : std_logic_vector(10 downto 0):="00000000001";
constant  gnd_vec : std_logic_vector(10 downto 0):="00000000000";
begin

process(current_st,rx_sof,rx_eof,comp_eq)
begin 
case current_st is


when rst_state =>

	  sel_comp_Bval<='0';
	  comp_Bval<=gnd_vec;
	  rst_count<='1';
	  en_count<='0';
	  		  			  
	  wren_MSbyte<='0';
	  wren_LSbyte<='0';
	  
	  valid_out_usr_data<='0';
	
  	next_st<=idle_state;	

when idle_state =>	
	
	if rx_sof='0' then -- rx_sof is active low
	  sel_comp_Bval<='0';
	  comp_Bval<=udp_length_match_cycle; 
	  rst_count<='1';
	  en_count<='0';
	  		  			  
	  wren_MSbyte<='0';
	  wren_LSbyte<='0';
	  
	  valid_out_usr_data<='0';
	
  	 next_st<=detect_n_store_usr_length_MSbyte_state;
	
	else
	  sel_comp_Bval<='0';
	  comp_Bval<=gnd_vec;
	  rst_count<='0';
	  en_count<='0';
	  		  			  
	  wren_MSbyte<='0';
	  wren_LSbyte<='0';
	  
	  valid_out_usr_data<='0';
	
  	 next_st<=idle_state;
	end if;
		
when detect_n_store_usr_length_MSbyte_state =>	
	
	if comp_eq='1' then -- comp_eq is active high
	  sel_comp_Bval<='0';
	  comp_Bval<=udp_checksum_skip; -- Just to skip the UDP checksum field
	  rst_count<='1';
	  en_count<='0';
	  		  			  
	  wren_MSbyte<='1';
	  wren_LSbyte<='0';
	  
	  valid_out_usr_data<='0';
	
  	 next_st<=store_usr_length_LSbyte_state;
	
	else
	  sel_comp_Bval<='0';
	  comp_Bval<=udp_length_match_cycle;
	  rst_count<='0';
	  en_count<='1';
	  		  			  
	  wren_MSbyte<='0';
	  wren_LSbyte<='0';
	  
	  valid_out_usr_data<='0';
	
  	 next_st<=detect_n_store_usr_length_MSbyte_state;
	end if;
	
when store_usr_length_LSbyte_state =>	
	   
	  sel_comp_Bval<='0';
	  comp_Bval<=udp_checksum_skip; -- Just to skip the UDP checksum field
	  rst_count<='0';
	  en_count<='1';
	  		  			  
	  wren_MSbyte<='0';
	  wren_LSbyte<='1';
	  
	  valid_out_usr_data<='0';
	
  	 next_st<=checksum_gap_state;
		
when checksum_gap_state =>	
	   
	if comp_eq='1' then -- comp_eq is active high
	  sel_comp_Bval<='1';
	  comp_Bval<=gnd_vec; 
	  rst_count<='1';
	  en_count<='0';
	  		  			  
	  wren_MSbyte<='0';
	  wren_LSbyte<='0';
	  
	  valid_out_usr_data<='0';
	
  	 next_st<=receive_usr_data_state;
	
	else
	  sel_comp_Bval<='0';
	  comp_Bval<=udp_checksum_skip;
	  rst_count<='0';
	  en_count<='1';
	  		  			  
	  wren_MSbyte<='0';
	  wren_LSbyte<='0';
	  
	  valid_out_usr_data<='0';
	
  	 next_st<=checksum_gap_state;
	end if;
	
when receive_usr_data_state =>	
	   
	if (comp_eq='1' or rx_eof='0') then  -- comp_eq is active high rx_eof is active-low
	  sel_comp_Bval<='0';
	  comp_Bval<=udp_length_match_cycle; 
	  rst_count<='1';
	  en_count<='0';
	  		  			  
	  wren_MSbyte<='0';
	  wren_LSbyte<='0';
	  
	  valid_out_usr_data<='1';
	
  	 next_st<=idle_state;
	
	else
	  sel_comp_Bval<='1';
	  comp_Bval<=gnd_vec;
	  rst_count<='0';
	  en_count<='1';
	  		  			  
	  wren_MSbyte<='0';
	  wren_LSbyte<='0';
	  
	  valid_out_usr_data<='1';
	
  	 next_st<=receive_usr_data_state;
	end if;
	
	
end case;	
end process;




process(clk)
begin
if (rst='1') then
	current_st<= rst_state;
elsif (clk'event and clk='1') then
	current_st <= next_st;
end if;
end process;
	
end Behavioral;

