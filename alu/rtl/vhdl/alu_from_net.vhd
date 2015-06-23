----------------------------------------------------------------------------
---- 									----
---- WISHBONE RISCMCU IP Core 						----
---- 									----
---- This file is part of the RISCMCU project 				----
---- http://www.opencores.org/projects/riscmcu/ 			----
---- 									----
---- Description 							----
---- Implementation of a RISC Microcontroller based on Atmel AVR	----
---- AT90S1200 instruction set and features with Altera	Flex10k20 FPGA. ----
---- 									----
---- Author(s): 							----
---- 	- Yap Zi He, yapzihe@hotmail.com 				----
---- 									----
----------------------------------------------------------------------------
---- 									----
---- Copyright (C) 2001 Authors and OPENCORES.ORG 			----
---- 									----
---- This source file may be used and distributed without 		----
---- restriction provided that this copyright statement is not 		----
---- removed from the file and that any derivative work contains 	----
---- the original copyright notice and the associated disclaimer. 	----
---- 									----
---- This source file is free software; you can redistribute it 	----
---- and/or modify it under the terms of the GNU Lesser General 	----
---- Public License as published by the Free Software Foundation; 	----
---- either version 2.1 of the License, or (at your option) any 	----
---- later version. 							----
---- 									----
---- This source is distributed in the hope that it will be 		----
---- useful, but WITHOUT ANY WARRANTY; without even the implied 	----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 		----
---- PURPOSE. See the GNU Lesser General Public License for more 	----
---- details. 								----
---- 									----
---- You should have received a copy of the GNU Lesser General 		----
---- Public License along with this source; if not, download it 	----
---- from http://www.opencores.org/lgpl.shtml 				----
---- 									----
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library lpm;
use lpm.lpm_components.all;

entity v_alu is
 port(	reg_rd, reg_rr, imm_value : in std_logic_vector(7 downto 0);
		c2a, c2b : in std_logic;
		asel : in integer range 0 to 1;
		bsel : in integer range 0 to 3;

		bitsel : in integer range 0 to 7;
		set : in std_logic;
		c_flag, t_flag : in std_logic;		
			
		add, subcp, logic, right, dir, bld, cbisbi, pass_a : in std_logic;
		cpse, skiptest : in std_logic;

		wcarry : in std_logic;
		logicsel : in integer range 0 to 3;
		rightsel : in integer range 0 to 2;
		dirsel : in integer range 0 to 1;

		clk, clrn : in std_logic;

		c : buffer std_logic_vector(7 downto 0);
		tosr : buffer std_logic_vector (6 downto 0);
		skip : out std_logic
 );

end v_alu;

architecture alu of v_alu is

signal a, b : std_logic_vector(7 downto 0);

signal sr : std_logic_vector(6 downto 0);

signal cin, overflow, cout : std_logic;

signal sum, logic_out, right_out, dir_out, bldcbi_out : std_logic_vector(7 downto 0);

begin

-- Operand Fetch Unit --

process(clrn, clk)
begin
	if clrn = '0' then
		a <= "00000000";
		b <= "00000000";
	elsif clk'event and clk = '1' then
		case asel is
			when 0 =>
				if c2a = '1' then
					a <= c;
				else
					a <= reg_rd;
				end if;
			when 1 =>
				a <= "00000000";
		end case;

		case bsel is
			when 0 =>
				if c2b = '1' then
					b <= c; 
				else
					b <= reg_rr;
				end if;
			when 1 =>
				b <= reg_rd;
			when 2 =>
				b <= imm_value;
			when 3 =>
				b <= "00000001";
		end case;
	end if;
end process;


-- Execution Unit --

cin <= c_flag when add = '1' and wcarry = '1' else
		'0' when add = '1' and wcarry = '0' else
		not c_flag when wcarry = '1' else
		'1';


-- Adder-Subtracter
adder1 : lpm_add_sub 
	generic map(lpm_width => 8)
	port map (dataa => a, datab => b, cin => cin, add_sub => add, result => sum, cout => cout, overflow => overflow);

-- Logic Unit
with logicsel select
	logic_out <= a and --------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Module   - Introduction to VLSI Design
-- Lecturer - Dr V. M. Dwyer
-- Course   - MEng Electronic and Electrical Engineering
-- Year     - Part D
-- Student  - Sahrfili Leonous Matturi A028459 [elslm]
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Christmas 2003 coursework...
--	better than watching "Saved by the Bell- the college years"
-- Details: 	Scheduling and allocation in FSMs
--				4 bit multiplier design example
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--	Description 	: 	radix-4 multiplier top level linkink
--						datapath and controller
--  Entity			: 	radix4_multi_structure
--	Architecture	: 	structural
--  Created on  	: 	01/01/2004

library	ieee;

use ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;

b when 0, -- and, andi
				a or b when 1, -- or, ori
				a xor b when 2, -- eor
				not a when 3; -- com

-- Shifter
right_out(6 downto 0) <= a(7 downto 1);
with rightsel select
	right_out(7) <= '0' when 0, -- lsr
					c_flag when 1, -- ror
					a(7) when 2; -- asr

-- Direct Unit
with dirsel select 
	dir_out <= b when 0, -- ldi, mov
				(a(3 downto 0) & a(7 downto 4)) when 1; -- swap

-- Bit Loader
process(bld, bitsel, a, t_flag, set)
begin
	for i in 0 to 7 loop
		if i /= bitsel then
			bldcbi_out(i) <= a(i);
		elsif bld = '1' then
			bldcbi_out(i) <= t_flag;
		else
			bldcbi_out(i) <= set;
		end if;
	end loop;
end process;

-- Results to Data Bus
process(add, subcp, logic, right, dir, bld, cbisbi, pass_a, sum, logic_out, right_out, dir_out, bldcbi_out, a)
begin

 c <= "ZZZZZZZZ";

 -- add, adc, inc, sub, sbc, subi, sbci, cp, cpc, cpi, dec, neg
 if add = '1' or subcp = '1' then 
	c <= sum;
 end if;

 -- and, andi, or, ori, eor, com
 if logic = '1' then 
 	c <= logic_out;
 end if;

 -- lsr, lsr, asr
 if right = '1' then
	c <= right_out;
 end if;

 -- ldi, mov, swap
 if dir = '1' then
	c <= dir_out;
 end if;

 -- bld, cbisbi
 if bld = '1' or cbisbi = '1' then
	c <= bldcbi_out;
 end if;

 -- out, st z, st z+, st -z
 if pass_a = '1' then
	c <= a;
 end if;

end process;


-- Skip Evaluation Unit --
process(cpse, skiptest, a, b, set, bitsel, c)
begin

 skip <= '0';
 
 -- cpse
 if cpse = '1' then
	if a = b then
		skip <= '1';
	end if;

 -- sbrc, sbrs
 elsif skiptest = '1' then
	if (set = '1' and a(bitsel) = '1') or (set = '0' and a(bitsel) = '0') then
		skip <= '1';
	end if;	

 end if;
end process;

-- Flags Evaluation Unit --
process(add, subcp, cout, right, a, logic, a, b, sum, logic_out, right_out, c, overflow, sr, bitsel)
begin

-- C sr(0)
 if add = '1' then
	sr(0) <= cout;
 elsif right = '1' then
	sr(0) <= a(0);
 elsif logic = '1' then -- com
	sr(0) <= '1';	
 else -- subcp
	sr(0) <= not cout;
	--sr(0) <= (not a(7) and b(7)) or (b(7) and c(7)) or (c(7) and not a(7));
 end if;

-- Z sr(1)
 if (add = '1' or subcp = '1') and sum = "00000000" then
	sr(1) <= '1';
 elsif logic = '1' and logic_out = "00000000" then
	sr(1) <= '1';
 elsif right = '1' and right_out = "00000000" then
	sr(1) <= '1'; 
 else
	sr(1) <= '0';
 end if;

-- N sr(2)
 if (add = '1' or subcp = '1') and sum(7) = '1' then
	sr(2) <= '1';
 elsif logic = '1' and logic_out(7) = '1' then
	sr(2) <= '1';
 elsif right = '1' and right_out(7) = '1' then
	sr(2) <= '1';
 else
	sr(2) <= '0';
 end if;

-- V sr(3)
 if right = '1' then
	sr(3) <= right_out(7) xor a(0);
 elsif logic = '1' then
	sr(3) <= '0';
 else
	sr(3) <= overflow;
 end if;

-- S sr(4)
 sr(4) <= sr(2) xor sr(3);

-- H sr(5)
 if add = '1' then
	sr(5) <= (a(3) and b(3)) or (b(3) and not sum(3)) or (not sum(3) and a(3));
 else -- subcp
	sr(5) <= (not a(3) and b(3)) or (b(3) and sum(3)) or (sum(3) and not a(3));
 end if;

-- T sr(6)
 sr(6) <= a(bitsel);

end process;

tosr <= sr;

end alu;



