--------------------------------------------------------------------------------
-- Company: University of Vigo
-- Engineer: L. Jacobo Alvarez Ruiz de Ojeda
--
-- Create Date:    11:21:57 10/18/06
-- Design Name:    
-- Module Name:    ctr_receiver_clock - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description: It counts the cycles of the receive clock and indicates the reception of 2, 4, 6 and 8 receive clock cycles
-- This counter starts at state 0, counts until state 8, then goes to state 1 and keep on counting, until it is reset to the initial state 0.
-- This is necessary to count the receive clock cycles correctly, starting with the first receive clock cycle later than
--  the first RXD falling edge (which corresponds to the start bit)
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ctr_receiver_clock is
    Port ( clk : in std_logic;
           reset : in std_logic;
           sync_reset : in std_logic;
           ctr_eq_2 : out std_logic;
           ctr_eq_4 : out std_logic;
           ctr_eq_6 : out std_logic;
           ctr_eq_8 : out std_logic;
           gctr : in std_logic;
           qctr : out std_logic_vector(3 downto 0));
end ctr_receiver_clock;

architecture Behavioral of ctr_receiver_clock is

signal qctr_aux: std_logic_vector (3 downto 0);

begin

-- Outputs assignment
qctr <= qctr_aux;

process (clk, reset, gctr, qctr_aux)
begin
	if (reset ='1') then
		-- Counter initialization
		qctr_aux <= "0000";
	elsif (clk'event and clk='1') then
		if sync_reset = '1' then 
			qctr_aux <= "0000";
		elsif (gctr='1') then
			if qctr_aux = 8 then
				qctr_aux <= "0001";
			else
				-- Increment counter
				qctr_aux <= qctr_aux + 1;
			end if;
		end if;
	end if;

	if qctr_aux = 2 then
		-- 2 cycles of receive clock.
		ctr_eq_2 <= '1';
	else ctr_eq_2 <='0';
	end if;

	if qctr_aux = 4  then
		-- 4 cycles of receive clock
		ctr_eq_4 <= '1';
	else ctr_eq_4 <='0';
	end if;

	if qctr_aux = 6 then
		-- 6 cycles of receive clock
		ctr_eq_6 <= '1';
	else ctr_eq_6 <='0';
	end if;

	if qctr_aux = 8 then
		-- 8 cycles of receive clock. Last state
		ctr_eq_8 <= '1';
	else ctr_eq_8 <='0';
	end if;
end process;


end Behavioral;
