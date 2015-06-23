----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:59:05 05/03/2011 
-- Design Name: 
-- Module Name:    FSM_SEL_HEADER - Behavioral 
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

entity FSM_SEL_HEADER is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           usr_phase_en : in  STD_LOGIC;
           sel : out  STD_LOGIC);
end FSM_SEL_HEADER;

architecture Behavioral of FSM_SEL_HEADER is

TYPE state is (rst_state,
					idle_state,
					header_state,
					data_state
					);
					
signal current_st,next_st: state;

begin

process(clk)
begin
if (rst='1') then
	current_st<= rst_state;
elsif (clk'event and clk='1') then
	current_st <= next_st;
end if;
end process;

process(current_st,usr_phase_en)
begin 
case current_st is

when rst_state =>

	sel<='0';
	
  	next_st<=idle_state;	
	
when idle_state =>

	sel<='0';
	
	if usr_phase_en='1' then
		next_st <= header_state;
	else
		next_st <= idle_state;
	end if;

when header_state =>	

	sel<='1';
	
	next_st <= data_state;
	
when data_state =>	

	sel<='0';
	
	if usr_phase_en='1' then
		next_st <= data_state;
	else
		next_st <= rst_state;
	end if;

end case;
end process;

end Behavioral;

