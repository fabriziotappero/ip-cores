----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:01:28 01/18/2011 
-- Design Name: 
-- Module Name:    MATCH_CMD - Behavioral 
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

entity MATCH_CMD is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sof : in  STD_LOGIC;
           vld_i : in  STD_LOGIC;
           val_i : in  STD_LOGIC_VECTOR (7 downto 0);
			  cmd_to_match : in  STD_LOGIC_VECTOR(7 downto 0);
           cmd_match : out  STD_LOGIC);
end MATCH_CMD;

architecture Behavioral of MATCH_CMD is

TYPE state is (rst_state,
					idle_state,
					header_state
				);
					
signal current_st,next_st: state;

signal allow_match, match_s: std_logic;
signal allow_match_v, val_i_to_match: std_logic_vector(7 downto 0);

begin

process(clk)
begin
if (rst='1') then
	current_st<= rst_state;
elsif (clk'event and clk='1') then
	current_st <= next_st;
end if;
end process;

process(current_st,sof,vld_i)
begin 
case current_st is

when rst_state =>

	allow_match<='0';
	
  	next_st<=idle_state;	
	
when idle_state =>

	allow_match<='0';
	
	if sof='0' then
		next_st <= header_state;
	else
		next_st <= idle_state;
	end if;

when header_state =>		
	
	if vld_i='1' then
		allow_match<='1';
		next_st <= rst_state;
	else
		allow_match<='0';
		next_st <= header_state;
	end if;

end case;
end process;

allow_match_v <=(others=>allow_match);
val_i_to_match <= val_i and allow_match_v;

process(clk)
begin
if clk'event and clk='1' then
	if val_i_to_match =  cmd_to_match then
		cmd_match <='1';
	else
		cmd_match <='0';
	end if;
end if;
end process;

end Behavioral;

