--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Module   - Introduction to VLSI Design [03ELD005]
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

--	Description 	: 	ALU barrel shifter
--  Entity			: 	alu_barrel_shifter
--	Architecture	: 	structural
--  Created on  	: 	07/03/2004

library	ieee;

use ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;
use	ieee.std_logic_arith.all;

entity alu_barrel_shifter is
	generic	(
			adder_width	: integer := 8
			);
	port 	(
			x			: in	std_logic_vector(adder_width - 1 downto 0)	;
			y			: in	std_logic_vector(adder_width - 1 downto 0)	;
			z			: out	std_logic_vector(adder_width - 1 downto 0)	;
			c			: out	std_logic									                  ;
			direction	: in	std_logic
			);
end alu_barrel_shifter;


architecture structural of alu_barrel_shifter is

signal	Yor, Yreg, Xreg, Zreg, Zout
						: std_logic_vector(adder_width downto 0);
signal	Xrev, Zrev		: std_logic_vector(adder_width downto 0);

signal	Xmsb			: std_logic;


function reverse(a : in std_logic_vector(Zreg'range)) return std_logic_vector is
-- reverse_range doesn't appear to work in NC-VHDL!!! but works in VHDL Simili
--variable	a_reversed	: std_logic_vector(Zreg'REVERSE_RANGE);
variable	a_reversed	: std_logic_vector(0 to adder_width);
begin

--	for i in a'reverse_range loop
	for i in 0 to adder_width loop
		a_reversed(i)	:= a(i);
	end loop;
	
	return a_reversed;
end reverse;
begin


	----------------------------------------------------
    -- shifter
    ----------------------------------------------------
    Yreg	<=	'0' & (y and x"07");
	Zrev	<=	reverse(Zreg);
	Xrev	<=	reverse('0' & x) when (direction = '0') else
				reverse(x & '0');
	Xmsb	<=	x(x'high);
	z		<=	Zout(Zout'high-1 downto 0)	when (direction = '0') else
				Xmsb & Zout(Zout'high-1  downto 1);
	c		<=	Zout(Zout'high)	when (direction = '0') else
				Zout(Zout'low);
	Zout	<=	Zreg	when (direction = '0') else
				Zrev;
	Xreg	<= 	'0' & x	when (direction = '0') else
				Xrev;


	Yor(0)		<= '1' when (Yreg = conv_std_logic_vector(0,adder_width + 1)) else
				'0';
	Yor(1)		<= '1' when (Yreg = conv_std_logic_vector(1,adder_width + 1)) else
				'0';
	Yor(2)		<= '1' when (Yreg = conv_std_logic_vector(2,adder_width + 1)) else
				'0';
	Yor(3)		<= '1' when (Yreg = conv_std_logic_vector(3,adder_width + 1)) else
				'0';
	Yor(4)		<= '1' when (Yreg = conv_std_logic_vector(4,adder_width + 1)) else
				'0';
	Yor(5)		<= '1' when (Yreg = conv_std_logic_vector(5,adder_width + 1)) else
				'0';
	Yor(6)		<= '1' when (Yreg = conv_std_logic_vector(6,adder_width + 1)) else
				'0';
	Yor(7)		<= '1' when (Yreg = conv_std_logic_vector(7,adder_width + 1)) else
				'0';
	Yor(8)		<= '0';
				

    shifter       :	process (Xreg, Yreg, Yor)
    				variable	Ztmp : std_logic;
					begin
						Zreg <= (others => '0');
						for i in Zreg'range loop
						Ztmp := '0';						
							if (i = 0) then
								Zreg(i)	<=	Xreg(i) and Yor(0);
							else
								Ztmp	:= Xreg(i) and Yor(0);
								for j in 1 to i loop
									Ztmp    :=  (Xreg(i-j) and Yor(j)) or Ztmp;
								end loop;
								Zreg(i)	<= Ztmp;
							end if;
						end loop;
					end process shifter;
end structural;



