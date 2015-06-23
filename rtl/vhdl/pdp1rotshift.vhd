----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:39:56 08/10/2009 
-- Design Name: 
-- Module Name:    pdp1rotshift - Behavioral 
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
use IEEE.numeric_std.ALL;

entity pdp1rotshift is
    Port ( ac : in  STD_LOGIC_VECTOR (0 to 17);
           io : in  STD_LOGIC_VECTOR (0 to 17);
           right : in  STD_LOGIC;				-- '0' for left, '1' for right
           shift : in  STD_LOGIC;			-- '1' for shift, '0' for rotate
           words : in  STD_LOGIC_VECTOR (0 to 1);
           acout : out  STD_LOGIC_VECTOR (0 to 17);
           ioout : out  STD_LOGIC_VECTOR (0 to 17));
end pdp1rotshift;

architecture Behavioral of pdp1rotshift is
	signal input, output: std_logic_vector(0 to 35);
	signal word: std_logic_vector(0 to 17);
	constant use_readable_code: boolean := true;
begin
	cond_gen: if use_readable_code generate
		with words select
			input <= AC&AC when "01",
						IO&IO when "10",
						AC&IO when "11",
						(others=>'-') when others;

		output <= std_logic_vector(unsigned(input) rol 1) when right='0' and shift='0' else
					 std_logic_vector(unsigned(input) sll 1) when right='0' and shift='1' else
					 std_logic_vector(unsigned(input) ror 1) when right='1' and shift='0' else
					 std_logic_vector(unsigned(input) srl 1) when right='1' and shift='1' else
					 (others=>'-');
		
		word <= output(0 to 17) when right='1' else output(18 to 35);

		with words select
			acout <= word when "01",
						output(0 to 17) when "11",
						ac when others;

		with words select
			ioout <= word when "10",
						output(18 to 35) when "11",
						io when others;
	end generate;

	cond_explicit_rtl: if not use_readable_code generate
		acout(0) <= ac(0) when words(1)='0' else		-- not working on AC
									ac(1) when right='0' else					-- shift/rot left
									'0' when shift='1' else						-- shift right
									ac(17) when words(0)='0' else		-- rotate ac right
									io(17) when words(0)='1' else		-- rotate ac&io right
									'-';
		acout(1 to 16) <= ac(1 to 16) when words(1)='0' else	-- not working on AC
												ac(2 to 17) when right='0' else				-- left
												ac(0 to 15) when right='1' else				-- right
												(others=>'-');
		acout(17) <= ac(17) when words(1)='0' else		-- not working on ac
									ac(16) when right='1' else					-- shift/rot right
									io(0) when words(0)='1' else			-- shift/rot left ac&io
									'0' when shift='1' else							-- shift ac left
									ac(0) when shift='0' else					-- rotate ac left
									'-';

		ioout(0) <= io(0) when words(0)='0' else				-- not working on IO
								io(1) when right='0' else							-- left
								ac(17) when words(1)='1' else			-- ac&io right
								'0' when shift='1' else								-- shift io right
								io(17) when shift='0' else						-- rotate io right
								'-';
		ioout(1 to 16) <= io(1 to 16) when words(0)='0' else
											io(2 to 17) when right='0' else
											io(0 to 15) when right='1' else
											(others=>'-');
		ioout(17) <= io(17) when words(0)='0' else
									io(16) when right='1' else
									'0' when shift='1' else
									ac(0) when words(1)='1' else
									io(0) when words(1)='0' else
									'-';
	end generate;
end Behavioral;

