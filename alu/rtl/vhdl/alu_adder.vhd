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

--	Description 	: 	ALU datapath
--  Entity			: 	alu_datapath
--	Architecture	: 	structural
--  Created on  	: 	07/03/2004

library	ieee;

use ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;

entity alu_adder is
	generic	(
			adder_width	: integer := 8
			);
	port 	(
			x			: in	std_logic_vector(adder_width - 1 downto 0)	;
			y			: in	std_logic_vector(adder_width - 1 downto 0)	;
			carry_in	: in	std_logic									;
			ORsel		: in	std_logic									;
			XORsel		: in	std_logic									;
			carry_out	: out	std_logic_vector(adder_width	 downto 0)	;
			xor_result	: out	std_logic_vector(adder_width - 1 downto 0)	;
			or_result	: out	std_logic_vector(adder_width - 1 downto 0)	;
			and_result	: out	std_logic_vector(adder_width - 1 downto 0)	;
			z			: out	std_logic_vector(adder_width - 1 downto 0)
			);
end alu_adder;


architecture structural of alu_adder is
signal	c		: std_logic_vector(adder_width downto 0);
signal	XxorY,
		XandY,
		XorY	: std_logic_vector(adder_width - 1 downto 0);

begin

	----------------------------------------------------
    -- adder
    ----------------------------------------------------
    xor_result	<= XxorY;
    or_result	<= XorY	;
    and_result	<= XandY;

	XxorY	<=	x xor y;
	XandY	<=	x and y;
	XorY	<=	x or  y;

    carry_out	<= c;

    adder       :       process (x, y, c, XxorY, XandY, XorY)
                        begin
                            c(0) <= carry_in;
                            for i in z'range loop
                                z(i)    <=  XxorY(i) xor (c(i) and XORsel);
                                c(i+1)  <=  XandY(i) or
                                           ((c(i) or ORsel) and XorY(i));
                			end loop;
                        end process adder;

end structural;


