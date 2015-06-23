-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- alu.vhd  --  Hadrware description of the ALU unit (inside Execute pipeline stage)
--
-- Written By -  Jonathan Masur and Xavier Jimenez (2013)
--
-- This program is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation; either version 2, or (at your option) any
-- later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- In other words, you are welcome to use, share and improve this program.
-- You are forbidden to forbid anyone else to use, share and improve
-- what you give them.   Help stamp out software-hoarding!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arm_types.all;

entity alu is
	port (
		exe_alu_operation : in ALU_OPERATION;
		alu_o : out unsigned(31 downto 0);
		alu_opb, alu_opa : in unsigned(31 downto 0);
		n, z, c, v, barrelshift_c : in std_logic;
		lowflags : in std_logic_vector(5 downto 0);
		next_n, next_z, next_c, next_v : out std_logic;
		next_lowflags : out std_logic_vector(5 downto 0)
	);
end;

architecture rtl of alu is
	signal alu_out : unsigned(31 downto 0);
	
	signal adder_a, adder_b, adder_out : unsigned(31 downto 0);
	signal adder_cout, adder_vout : std_logic;
	signal adder_cin : unsigned(0 downto 0);

begin
	alu_o <= alu_out;		-- annoying VHDL
	
	-- 32 bit adder with carry in and carry out
	adder : process(adder_a, adder_b, adder_cin, adder_out) is
		variable add33 :unsigned(32 downto 0);
	begin
		add33 := ('0' & adder_a) + ('0' & adder_b) + adder_cin;
		adder_out <= add33(31 downto 0);

		-- carry out is bit 32 of the result
		adder_cout <= add33(32);

		-- overflow true if both operands were the same sign and the result is not the same sign
		adder_vout <= (add33(31) and not adder_a(31) and not adder_b(31)) or (not adder_out(31) and adder_a(31) and adder_b(31));
	end process;

	-- 32-bit ALU
	alu : process(exe_alu_operation, alu_out, alu_opb, alu_opa, n, z, c, v, lowflags, barrelshift_c, adder_out, adder_cout, adder_vout) is
		variable carry : unsigned(0 downto 0);
	begin
		adder_a <= (others => '-');
		adder_b <= (others => '-');
		adder_cin <= "-";

		-- annoying VHDL
		if c = '1' then carry := "1"; else carry := "0"; end if;

		-- default values for nzvc and low flags (v and lowflags doesn't change by default)
		next_n <= alu_out(31);
		if alu_out = X"00000000"
		then
			next_z <= '1';
		else
			next_z <= '0';
		end if;
		next_v <= v;
		next_c <= barrelshift_c;
		next_lowflags <= lowflags;

		case exe_alu_operation is
		when ALU_NOP =>		-- no ALU operation
			alu_out <= alu_opb;
		when ALU_NOT =>		-- one's complement operation
			alu_out <= not alu_opb;
		when ALU_ORR =>
			alu_out <= alu_opa or alu_opb;
		when ALU_AND =>
			alu_out <= alu_opa and alu_opb;
		when ALU_EOR =>
			alu_out <= alu_opa xor alu_opb;
		when ALU_BIC =>		-- bit clear
			alu_out <= alu_opa and not alu_opb;

		when ALU_RWF =>		-- read/write flags
			next_n <= alu_opb(31);
			next_z <= alu_opb(30);
			next_c <= alu_opb(29);
			next_v <= alu_opb(28);
			-- I and F flags
			next_lowflags(5 downto 4) <= std_logic_vector(alu_opb(7 downto 6));
			-- mode flags
			next_lowflags(3 downto 0) <= std_logic_vector(alu_opb(3 downto 0));
			
			--read (old) flags
			alu_out <= unsigned( n & z & c & v & (27 downto 8 => '0') & lowflags(5 downto 4) & '0' & '1' & lowflags(3 downto 0) );

		when ALU_ADD =>		-- addition without carry
			adder_a <= alu_opa;
			adder_b <= alu_opb;
			adder_cin <= "0";		

			next_v <= adder_vout;			
			alu_out <= adder_out;
			next_c <= adder_cout;

		when ALU_ADC =>		-- addition with carry
			adder_a <= alu_opa;
			adder_b <= alu_opb;
			adder_cin <= carry;
			
			next_v <= adder_vout;
			alu_out <= adder_out;
			next_c <= adder_cout;
		
		when ALU_SUB =>		-- substraction without carry
			adder_a <= alu_opa;
			adder_b <= not alu_opb;
			adder_cin <= "1";
			
			next_v <= adder_vout;
			alu_out <= adder_out;
			next_c <= adder_cout;

		when ALU_SBC =>		-- substraction with carry
			adder_a <= alu_opa;
			adder_b <= not alu_opb;
			adder_cin <= carry;
			
			next_v <= adder_vout;
			alu_out <= adder_out;
			next_c <= adder_cout;

		when ALU_RSB =>		-- reverse substraction without carry
			adder_a <= not alu_opa;
			adder_b <= alu_opb;
			adder_cin <= "1";
			
			next_v <= adder_vout;
			alu_out <= adder_out;
			next_c <= adder_cout;

		when ALU_RSC =>		-- reverse substraction with carry
			adder_a <= not alu_opa;
			adder_b <= alu_opb;
			adder_cin <= carry;
			
			next_v <= adder_vout;
			alu_out <= adder_out;
			next_c <= adder_cout;
		end case;
	end process;
end;