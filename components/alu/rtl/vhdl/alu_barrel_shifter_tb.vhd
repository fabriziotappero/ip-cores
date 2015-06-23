--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Module   - Introduction to VLSI Design
-- Lecturer - Dr V. M. Dwyer
-- Course   - MEng Electronic and Electrical Engineering
-- Year     - Part D
-- Student  - Sahrfili Leonous Matturi A028459 [elslm]
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Final coursework 2004
-- 
-- Details: 	Design and Layout of an ALU
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--	Description 	: 	test ALU barrel shifter
--  Entity			: 	alu_barrel_shifter_tb
--	Architecture	: 	structural
--  Created on  	: 	07/03/2004

library	ieee;

use ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;

entity alu_barrel_shifter_tb is
end alu_barrel_shifter_tb;


architecture structural of alu_barrel_shifter_tb is
component 	alu_barrel_shifter
	port 	(
			x			: in	std_logic_vector(7 downto 0)	;
			y			: in	std_logic_vector(7 downto 0)	;
			z			: out	std_logic_vector(7 downto 0)	;
			direction	: in	std_logic
			);
end component;

signal	x,
		y,
		z	: std_logic_vector(7 downto 0) := (others => '0');
signal	direction		: std_logic;
signal	finished, clk	: std_logic;
begin

	----------------------------------------------------
    -- adder
    ----------------------------------------------------
	clk_stim	:	process
					begin
						
						clk	<= '1', '0' after 10 ns;
						if ( finished = '1') then
							wait;
						else
							wait for 20 ns;
						end if;
					end process clk_stim;

	shifter		:	alu_barrel_shifter
		port map	(
					x,
					y,
					z,
					direction
					);
					

	stimulus	:	process (clk)
					begin
						finished <= '0';
						direction<= '1';
						if (clk'event and clk = '1') then
							x <= x + 2;
						end if;
						
						if (conv_integer(x) mod 3 = 0) then 
							y <= y + 1;
						end if;
						if (x > 10) then
							finished <= '1';
						end if;
					end process stimulus;
end structural;



