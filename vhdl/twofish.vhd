-- Twofish.vhd
-- Copyright (C) 2006 Spyros Ninos
--
-- This program is free software; you can redistribute it and/or modify 
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this library; see the file COPYING.  If not, write to:
-- 
-- Free Software Foundation
-- 59 Temple Place - Suite 330
-- Boston, MA  02111-1307, USA.

-- description	: 	this file includes all the components necessary to perform symmetric encryption
--					with the twofish 128 bit block cipher. Within there are four main parts of the file.
--					the first part is the twofish crypto primitives which are independent of the key
--					input length, the second part is the 128 bit key input components, the third part 
--					is the 192 bit key components and finaly the 256 bit key input components
--


-- ====================================================== --
-- ====================================================== --
--												  		  --
-- first part: key input independent component primitives --
--												  		  --
-- ====================================================== --
-- ====================================================== --

-- 
-- q0
--

library ieee;
Use ieee.std_logic_1164.all;

entity q0 is
port	(
		in_q0 	: in std_logic_vector(7 downto 0);
		out_q0	: out std_logic_vector(7 downto 0)
		);
end q0;

architecture q0_arch of q0 is

	-- declaring internal signals
	signal	a0,b0,
			a1,b1,
			a2,b2,
			a3,b3,
			a4,b4		: std_logic_vector(3 downto 0);
	signal	b0_ror4,
			a0_times_8,
			b2_ror4,
			a2_times_8	: std_logic_vector(3 downto 0);

-- beginning of the architecture description
begin
	
	-- little endian
	b0 <= in_q0(3 downto 0);
	a0 <= in_q0(7 downto 4); 
	
	a1 <= a0 XOR b0;
	
	-- signal b0 is ror4'ed by 1 bit
	b0_ror4(2 downto 0) <= b0(3 downto 1);
	b0_ror4(3) <= b0(0);
	
	-- 8*a0 = 2^3*a0= a0 << 3
	a0_times_8(2 downto 0) <= (others => '0');
	a0_times_8(3) <= a0(0);
	
	b1 <= a0 XOR b0_ror4 XOR a0_times_8;

	--
	-- t0 table
	--
	with a1 select 
		a2 <=	"1000" when "0000", -- 8
			   	"0001" when "0001", -- 1
			   	"0111" when "0010", -- 7
			   	"1101" when "0011", -- D
			   	"0110" when "0100", -- 6
			   	"1111" when "0101", -- F
			   	"0011" when "0110", -- 3
			   	"0010" when "0111", -- 2
			  	"0000" when "1000", -- 0
			   	"1011" when "1001", -- B
			   	"0101" when "1010", -- 5
			   	"1001" when "1011", -- 9
			   	"1110" when "1100", -- E
			   	"1100" when "1101", -- C
			   	"1010" when "1110", -- A
			   	"0100" when others; -- 4

	--
	-- t1 table
	--
	with b1 select
		b2 <=	"1110" when "0000", -- E
				"1100" when "0001", -- C
				"1011" when "0010", -- B
				"1000" when "0011", -- 8
				"0001" when "0100", -- 1
				"0010" when "0101", -- 2
				"0011" when "0110", -- 3
				"0101" when "0111", -- 5
				"1111" when "1000", -- F
				"0100" when "1001", -- 4
				"1010" when "1010", -- A
				"0110" when "1011", -- 6
				"0111" when "1100", -- 7
				"0000" when "1101", -- 0
				"1001" when "1110", -- 9
				"1101" when others; -- D

	a3 <= a2 XOR b2;
	
	-- signal b2 is ror4'ed by 1 bit
	b2_ror4(2 downto 0) <= b2(3 downto 1);
	b2_ror4(3) <= b2(0);
	
	-- 8*a2 = 2^3*a2=a2<<3
	a2_times_8(2 downto 0) <= (others => '0');
	a2_times_8(3) <= a2(0);
	
	b3 <= a2 XOR b2_ror4 XOR a2_times_8;


	--
	-- t0 table
	--
	with a3 select
		a4 <=	"1011" when "0000", -- B
				"1010" when "0001", -- A
				"0101" when "0010", -- 5
				"1110" when "0011", -- E
				"0110" when "0100", -- 6
				"1101" when "0101", -- D
				"1001" when "0110", -- 9
				"0000" when "0111", -- 0
				"1100" when "1000", -- C
				"1000" when "1001", -- 8
				"1111" when "1010", -- F
				"0011" when "1011", -- 3
				"0010" when "1100", -- 2
				"0100" when "1101", -- 4
				"0111" when "1110", -- 7
				"0001" when others; -- 1

	--
	-- t1 table
	--
	with b3 select
		b4 <=	"1101" when "0000", -- D
				"0111" when "0001", -- 7
				"1111" when "0010", -- F
				"0100" when "0011", -- 4
				"0001" when "0100", -- 1
				"0010" when "0101", -- 2
				"0110" when "0110", -- 6
				"1110" when "0111", -- E
				"1001" when "1000", -- 9
				"1011" when "1001", -- B
				"0011" when "1010", -- 3
				"0000" when "1011", -- 0
				"1000" when "1100", -- 8
				"0101" when "1101", -- 5
				"1100" when "1110", -- C
				"1010" when others; -- A
 	
	-- the output of q0
	out_q0 <= b4 & a4;

end q0_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- q1
--

library ieee;
Use ieee.std_logic_1164.all;

entity q1 is
port	(
		in_q1 	: in std_logic_vector(7 downto 0);
		out_q1	: out std_logic_vector(7 downto 0)
		);
end q1;

-- architecture description
architecture q1_arch of q1 is

	-- declaring the internal signals
	signal	a0,b0,
			a1,b1,
			a2,b2,
			a3,b3,
			a4,b4		: std_logic_vector(3 downto 0);
	signal	b0_ror4,
			a0_times_8,
			b2_ror4,
			a2_times_8	: std_logic_vector(3 downto 0);

-- begin the architecture description
begin
	
	-- little endian
	b0 <= in_q1(3 downto 0);
	a0 <= in_q1(7 downto 4); 
	
	a1 <= a0 XOR b0;
	
	-- signal b0 is ror4'ed by 1 bit
	b0_ror4(2 downto 0) <= b0(3 downto 1);
	b0_ror4(3) <= b0(0);
	
	-- 8*a0 = 2^3*a0=a0<<3
	a0_times_8(2 downto 0) <= (others => '0');
	a0_times_8(3) <= a0(0);
	
	b1 <= a0 XOR b0_ror4 XOR a0_times_8;

	--
	-- t0 table
	--
	with a1 select 
		a2 <=	"0010" when "0000", -- 2
			   	"1000" when "0001", -- 8
			   	"1011" when "0010", -- b
			   	"1101" when "0011", -- d
			   	"1111" when "0100", -- f
			   	"0111" when "0101", -- 7
			   	"0110" when "0110", -- 6
			   	"1110" when "0111", -- e
			  	"0011" when "1000", -- 3
			   	"0001" when "1001", -- 1
			   	"1001" when "1010", -- 9
			   	"0100" when "1011", -- 4
			   	"0000" when "1100", -- 0
			   	"1010" when "1101", -- a
			   	"1100" when "1110", -- c
			   	"0101" when others; -- 5

	--
	-- t1 table
	--
	with b1 select
		b2 <=	"0001" when "0000", -- 1
				"1110" when "0001", -- e
				"0010" when "0010", -- 2
				"1011" when "0011", -- b
				"0100" when "0100", -- 4
				"1100" when "0101", -- c
				"0011" when "0110", -- 3
				"0111" when "0111", -- 7
				"0110" when "1000", -- 6
				"1101" when "1001", -- d
				"1010" when "1010", -- a
				"0101" when "1011", -- 5
				"1111" when "1100", -- f
				"1001" when "1101", -- 9
				"0000" when "1110", -- 0
				"1000" when others; -- 8

	a3 <= a2 XOR b2;
	
	-- signal b2 is ror4'ed by 1	bit
	b2_ror4(2 downto 0) <= b2(3 downto 1);
	b2_ror4(3) <= b2(0);
	
	-- 8*a2 = 2^3*a2=a2<<3
	a2_times_8(2 downto 0) <= (others => '0');
	a2_times_8(3) <= a2(0);
	
	b3 <= a2 XOR b2_ror4 XOR a2_times_8;

	--
	-- t0 table
	--
	with a3 select
		a4 <=	"0100" when "0000", -- 4
				"1100" when "0001", -- c
				"0111" when "0010", -- 7
				"0101" when "0011", -- 5
				"0001" when "0100", -- 1
				"0110" when "0101", -- 6
				"1001" when "0110", -- 9
				"1010" when "0111", -- a
				"0000" when "1000", -- 0
				"1110" when "1001", -- e
				"1101" when "1010", -- d
				"1000" when "1011", -- 8
				"0010" when "1100", -- 2
				"1011" when "1101", -- b
				"0011" when "1110", -- 3
				"1111" when others; -- f

	--
	-- t1 table
	--
	with b3 select
		b4 <=	"1011" when "0000", -- b
				"1001" when "0001", -- 9
				"0101" when "0010", -- 5
				"0001" when "0011", -- 1
				"1100" when "0100", -- c
				"0011" when "0101", -- 3
				"1101" when "0110", -- d
				"1110" when "0111", -- e
				"0110" when "1000", -- 6
				"0100" when "1001", -- 4
				"0111" when "1010", -- 7
				"1111" when "1011", -- f
				"0010" when "1100", -- 2
				"0000" when "1101", -- 0
				"1000" when "1110", -- 8
				"1010" when others; -- a
 	
	-- output of q1
	out_q1 <= b4 & a4;

end q1_arch;



-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- ef multiplier
--

library ieee;
use ieee.std_logic_1164.all;

entity mul_ef is
port	(
		in_ef 	: in std_logic_vector(7 downto 0);
		out_ef 	: out std_logic_vector(7 downto 0)
		);
end mul_ef;


architecture mul_ef_arch of mul_ef is

begin
	out_ef(0) <= in_ef(2) XOR in_ef(1) XOR in_ef(0);
	out_ef(1) <= in_ef(3) XOR in_ef(2) XOR in_ef(1) XOR in_ef(0);
	out_ef(2) <= in_ef(4) XOR in_ef(3) XOR in_ef(2) XOR in_ef(1) XOR in_ef(0);
	out_ef(3) <= in_ef(5) XOR in_ef(4) XOR in_ef(3) XOR in_ef(0);
	out_ef(4) <= in_ef(6) XOR in_ef(5) XOR in_ef(4) XOR in_ef(1);
	out_ef(5) <= in_ef(7) XOR in_ef(6) XOR in_ef(5) XOR in_ef(1) XOR in_ef(0);
	out_ef(6) <= in_ef(7) XOR in_ef(6) XOR in_ef(0);
	out_ef(7) <= in_ef(7) XOR in_ef(1) XOR in_ef(0);
end mul_ef_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


--
-- 5b multiplier
--

library ieee;
use ieee.std_logic_1164.all;

entity mul_5b is
port	(
		in_5b 	: in std_logic_vector(7 downto 0);
		out_5b 	: out std_logic_vector(7 downto 0)
		);
end mul_5b;

architecture mul_5b_arch of mul_5b is
begin
	out_5b(0) <= in_5b(2) XOR in_5b(0);
	out_5b(1) <= in_5b(3) XOR in_5b(1) XOR in_5b(0);
	out_5b(2) <= in_5b(4) XOR in_5b(2) XOR in_5b(1);
	out_5b(3) <= in_5b(5) XOR in_5b(3) XOR in_5b(0);
	out_5b(4) <= in_5b(6) XOR in_5b(4) XOR in_5b(1) XOR in_5b(0);
	out_5b(5) <= in_5b(7) XOR in_5b(5) XOR in_5b(1);
	out_5b(6) <= in_5b(6) XOR in_5b(0);
	out_5b(7) <= in_5b(7) XOR in_5b(1);
end mul_5b_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- mds
--

library ieee;
use ieee.std_logic_1164.all;

entity mds is
port	(
		y0,
		y1,
		y2,
		y3	: in std_logic_vector(7 downto 0);
		z0,
		z1,
		z2,
		z3	: out std_logic_vector(7 downto 0)
		);
end mds;


-- architecture description of mds component
architecture mds_arch of mds is

	-- we declare the multiplier by ef
 	component mul_ef
 	port	( 
			in_ef : in std_logic_vector(7 downto 0);
			out_ef : out std_logic_vector(7 downto 0)
			);
 	end component;

	-- we declare the multiplier by 5b
 	component mul_5b
 	port	(
			in_5b : in std_logic_vector(7 downto 0);
			out_5b : out std_logic_vector(7 downto 0)
			);
 	end component;

	-- we declare the multiplier's outputs
 	signal 	y0_ef, y0_5b,
			y1_ef, y1_5b,
			y2_ef, y2_5b,
			y3_ef, y3_5b	: std_logic_vector(7 downto 0);

begin

	-- we perform the signal multiplication
	y0_times_ef: mul_ef
	port map	(
				in_ef => y0,
				out_ef => y0_ef
				);

	y0_times_5b: mul_5b
	port map	(
				in_5b => y0,
				out_5b => y0_5b
				);

	y1_times_ef: mul_ef
	port map	(
				in_ef => y1,
				out_ef => y1_ef
				);

	y1_times_5b: mul_5b
	port map	(
				in_5b => y1,
				out_5b => y1_5b
				);

	y2_times_ef: mul_ef
	port map	(
				in_ef => y2,
				out_ef => y2_ef
				);

	y2_times_5b: mul_5b
	port map	(
				in_5b => y2,
				out_5b => y2_5b
				);

	y3_times_ef: mul_ef
	port map	(
				in_ef => y3,
				out_ef => y3_ef
				);

	y3_times_5b: mul_5b
	port map	(
				in_5b => y3,
				out_5b => y3_5b
				);

	-- we perform the addition of the partial results in order to receive
	-- the table output

	-- z0 = y0*01 + y1*ef + y2*5b + y3*5b , opoy + bazoyme XOR
	 z0 <= y0 XOR y1_ef XOR y2_5b XOR y3_5b;
	
	-- z1 = y0*5b + y1*ef + y2*ef + y3*01
	 z1 <= y0_5b XOR y1_ef XOR y2_ef XOR y3;

	-- z2 = y0*ef + y1*5b + y2*01 +y3*ef
	 z2 <= y0_ef XOR y1_5b XOR y2 XOR y3_ef;

	-- z3 = y0*ef + y1*01 + y2*ef + y3*5b
	 z3 <= y0_ef XOR y1 XOR y2_ef XOR y3_5b;

end mds_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- 1 bit adder
--

library ieee;
use ieee.std_logic_1164.all;

entity adder is
port	(
		in1_adder,
		in2_adder,
		in_carry_adder	: in std_logic;
		out_adder,
		out_carry_adder	: out std_logic
		);
end adder;

architecture adder_arch of adder is
begin

	out_adder <= in_carry_adder XOR in1_adder XOR in2_adder;
	out_carry_adder <= (in_carry_adder AND (in1_adder XOR in2_adder)) OR (in1_adder AND in2_adder);
	
end adder_arch;
			   

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- pht
--

library ieee;
use ieee.std_logic_1164.all;

entity pht is
port	(
		up_in_pht,
		down_in_pht		: in std_logic_vector(31 downto 0);
		up_out_pht,
		down_out_pht	: out std_logic_vector(31 downto 0)
		);
end pht;


-- architecture description
architecture pht_arch of pht is

	-- we declare internal signals
	signal	intermediate_carry1,
			intermediate_carry2,
			to_upper_out			: std_logic_vector(31 downto 0);
	signal	zero					: std_logic;
	
	component adder
	port	(
			in1_adder,
			in2_adder,
			in_carry_adder	: in std_logic;
			out_adder,
			out_carry_adder	: out std_logic
			);
	end component;
					 
begin
	
	-- initializing zero signal
	zero <= '0';
	
	-- instantiating the upper adder of 32 bits
	up_adder: for i in 0 to 31 generate
		adder_one: if (i=0) generate
			the_adder: adder
			port map	(
						in1_adder => up_in_pht(0),
						in2_adder => down_in_pht(0),
						in_carry_adder => zero,
						out_adder => to_upper_out(0),
						out_carry_adder => intermediate_carry1(0)
						);
		end generate adder_one;
		rest_adders: if (i>0) generate
			next_adder: adder 
			port map	(
						in1_adder => up_in_pht(i),
						in2_adder => down_in_pht(i),
						in_carry_adder => intermediate_carry1(i-1),
						out_adder => to_upper_out(i),
						out_carry_adder => intermediate_carry1(i)
						);
		end generate rest_adders;
	end generate up_adder;
	
	intermediate_carry1(31) <= '0';
	
	-- receiving the upper pht output
	up_out_pht <= to_upper_out;
	
	-- instantiating the lower adder of 32 bits
	down_adder: for i in 0 to 31 generate
		adder_one_1: if (i=0) generate
			the_adder_1: adder
			port map	(
						in1_adder => down_in_pht(0),
						in2_adder => to_upper_out(0),
						in_carry_adder => zero,
						out_adder => down_out_pht(0),
						out_carry_adder => intermediate_carry2(0)
						);
		end generate adder_one_1;
		rest_adders_1: if (i>0) generate
			next_adder_1: adder
			port map	(
						in1_adder => down_in_pht(i),
						in2_adder => to_upper_out(i),
						in_carry_adder => intermediate_carry2(i-1),
						out_adder => down_out_pht(i),
						out_carry_adder => intermediate_carry2(i)
						);
		end generate rest_adders_1;
	end generate down_adder;
	
	intermediate_carry2(31) <= '0';
	
end pht_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 01	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul01 is
port	(
		in_mul01	: in std_logic_vector(7 downto 0);
		out_mul01	: out std_logic_vector(7 downto 0)
		);
end mul01;
						
architecture mul01_arch of mul01 is
begin
	out_mul01 <= in_mul01;
end mul01_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by a4	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mula4 is
port	(
		in_mula4	: in std_logic_vector(7 downto 0);			
		out_mula4	: out std_logic_vector(7 downto 0)
		);
end mula4;

architecture mula4_arch of mula4 is
begin
	out_mula4(0) <= in_mula4(7) xor in_mula4(1);
	out_mula4(1) <= in_mula4(2);
	out_mula4(2) <= in_mula4(7) xor in_mula4(3) xor in_mula4(1) xor in_mula4(0);
	out_mula4(3) <= in_mula4(7) xor in_mula4(4) xor in_mula4(2);
	out_mula4(4) <= in_mula4(5) xor in_mula4(3);
	out_mula4(5) <= in_mula4(6) xor in_mula4(4) xor in_mula4(0);
	out_mula4(6) <= in_mula4(5);
	out_mula4(7) <= in_mula4(6) xor in_mula4(0);
end mula4_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 55	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul55 is
port	(
		in_mul55	: in std_logic_vector(7 downto 0);
		out_mul55	: out std_logic_vector(7 downto 0)
		);
end mul55;

architecture mul55_arch of mul55 is
begin
	out_mul55(0) <= in_mul55(7) xor in_mul55(6) xor in_mul55(2) xor in_mul55(0);
	out_mul55(1) <= in_mul55(7) xor in_mul55(3) xor in_mul55(1);
	out_mul55(2) <= in_mul55(7) xor in_mul55(6) xor in_mul55(4) xor in_mul55(0);
	out_mul55(3) <= in_mul55(6) xor in_mul55(5) xor in_mul55(2) xor in_mul55(1);
	out_mul55(4) <= in_mul55(7) xor in_mul55(6) xor in_mul55(3) xor in_mul55(2) xor in_mul55(0);
	out_mul55(5) <= in_mul55(7) xor in_mul55(4) xor in_mul55(3) xor in_mul55(1);
	out_mul55(6) <= in_mul55(7) xor in_mul55(6) xor in_mul55(5) xor in_mul55(4) xor in_mul55(0);
	out_mul55(7) <= in_mul55(7) xor in_mul55(6) xor in_mul55(5) xor in_mul55(1);
end mul55_arch;
			  

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 87	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul87 is
port	(
		in_mul87	: in std_logic_vector(7 downto 0);
		out_mul87	: out std_logic_vector(7 downto 0)
		);
end mul87;

architecture mul87_arch of mul87 is
begin
	out_mul87(0) <= in_mul87(7) xor in_mul87(5) xor in_mul87(3) xor in_mul87(1) xor in_mul87(0);
	out_mul87(1) <= in_mul87(6) xor in_mul87(4) xor in_mul87(2) xor in_mul87(1) xor in_mul87(0);
	out_mul87(2) <= in_mul87(2) xor in_mul87(0);
	out_mul87(3) <= in_mul87(7) xor in_mul87(5);
	out_mul87(4) <= in_mul87(6);
	out_mul87(5) <= in_mul87(7);
	out_mul87(6) <= in_mul87(7) xor in_mul87(5) xor in_mul87(3) xor in_mul87(1);
	out_mul87(7) <= in_mul87(6) xor in_mul87(4) xor in_mul87(2) xor in_mul87(0);
end mul87_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 					
--	multiplier by 5a
--					

library ieee;
use ieee.std_logic_1164.all;

entity mul5a is
port	(
		in_mul5a	: in std_logic_vector(7 downto 0);
		out_mul5a	: out std_logic_vector(7 downto 0)
		);
end mul5a;

architecture mul5a_arch of mul5a is
begin
	out_mul5a(0) <= in_mul5a(7) xor in_mul5a(5) xor in_mul5a(2);
	out_mul5a(1) <= in_mul5a(6) xor in_mul5a(3) xor in_mul5a(0);
	out_mul5a(2) <= in_mul5a(5) xor in_mul5a(4) xor in_mul5a(2) xor in_mul5a(1);
	out_mul5a(3) <= in_mul5a(7) xor in_mul5a(6) xor in_mul5a(3) xor in_mul5a(0);
	out_mul5a(4) <= in_mul5a(7) xor in_mul5a(4) xor in_mul5a(1) xor in_mul5a(0);
	out_mul5a(5) <= in_mul5a(5) xor in_mul5a(2) xor in_mul5a(1);
	out_mul5a(6) <= in_mul5a(7) xor in_mul5a(6) xor in_mul5a(5) xor in_mul5a(3) xor in_mul5a(0);
	out_mul5a(7) <= in_mul5a(7) xor in_mul5a(6) xor in_mul5a(4) xor in_mul5a(1);
end mul5a_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 					
--	multiplier by 58
--					

library ieee;
use ieee.std_logic_1164.all;

entity mul58 is 
port	(
		in_mul58	: in std_logic_vector(7 downto 0);
		out_mul58	: out std_logic_vector(7 downto 0)
		);
end mul58;

architecture mul58_arch of mul58 is
begin
	out_mul58(0) <= in_mul58(5) xor in_mul58(2);
	out_mul58(1) <= in_mul58(6) xor in_mul58(3);
	out_mul58(2) <= in_mul58(7) xor in_mul58(5) xor in_mul58(4) xor in_mul58(2);
	out_mul58(3) <= in_mul58(6) xor in_mul58(3) xor in_mul58(2) xor in_mul58(0);
	out_mul58(4) <= in_mul58(7) xor in_mul58(4) xor in_mul58(3) xor in_mul58(1) xor in_mul58(0);
	out_mul58(5) <= in_mul58(5) xor in_mul58(4) xor in_mul58(2) xor in_mul58(1);
	out_mul58(6) <= in_mul58(6) xor in_mul58(3) xor in_mul58(0);
	out_mul58(7) <= in_mul58(7) xor in_mul58(4) xor in_mul58(1);
end mul58_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by db	
--						

library ieee;
use ieee.std_logic_1164.all;

entity muldb is
port	(
		in_muldb	: in std_logic_vector(7 downto 0);
		out_muldb	: out std_logic_vector(7 downto 0)
		);
end muldb;

architecture muldb_arch of muldb is
begin
	out_muldb(0) <= in_muldb(7) xor in_muldb(6) xor in_muldb(3) xor in_muldb(2) xor in_muldb(1) xor in_muldb(0);
	out_muldb(1) <= in_muldb(7) xor in_muldb(4) xor in_muldb(3) xor in_muldb(2) xor in_muldb(1) xor in_muldb(0);
	out_muldb(2) <= in_muldb(7) xor in_muldb(6) xor in_muldb(5) xor in_muldb(4);
	out_muldb(3) <= in_muldb(5) xor in_muldb(3) xor in_muldb(2) xor in_muldb(1) xor in_muldb(0);
	out_muldb(4) <= in_muldb(6) xor in_muldb(4) xor in_muldb(3) xor in_muldb(2) xor in_muldb(1) xor in_muldb(0);
	out_muldb(5) <= in_muldb(7) xor in_muldb(5) xor in_muldb(4) xor in_muldb(3) xor in_muldb(2) xor in_muldb(1);
	out_muldb(6) <= in_muldb(7) xor in_muldb(5) xor in_muldb(4) xor in_muldb(1) xor in_muldb(0);
	out_muldb(7) <= in_muldb(6) xor in_muldb(5) xor in_muldb(2) xor in_muldb(1) xor in_muldb(0);
end muldb_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 9e	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul9e is
port	(
		in_mul9e	: in std_logic_vector(7 downto 0);
		out_mul9e	: out std_logic_vector(7 downto 0)
		);
end mul9e;

architecture mul9e_arch of mul9e is
begin
	out_mul9e(0) <= in_mul9e(6) xor in_mul9e(4) xor in_mul9e(3) xor in_mul9e(1);
	out_mul9e(1) <= in_mul9e(7) xor in_mul9e(5) xor in_mul9e(4) xor in_mul9e(2) xor in_mul9e(0);
	out_mul9e(2) <= in_mul9e(5) xor in_mul9e(4) xor in_mul9e(0);
	out_mul9e(3) <= in_mul9e(5) xor in_mul9e(4) xor in_mul9e(3) xor in_mul9e(0);
	out_mul9e(4) <= in_mul9e(6) xor in_mul9e(5) xor in_mul9e(4) xor in_mul9e(1) xor in_mul9e(0);
	out_mul9e(5) <= in_mul9e(7) xor in_mul9e(6) xor in_mul9e(5) xor in_mul9e(2) xor in_mul9e(1);
	out_mul9e(6) <= in_mul9e(7) xor in_mul9e(4) xor in_mul9e(2) xor in_mul9e(1);
	out_mul9e(7) <= in_mul9e(5) xor in_mul9e(3) xor in_mul9e(2) xor in_mul9e(0);
end mul9e_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 56	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul56 is
port	(
		in_mul56	: in std_logic_vector(7 downto 0);
		out_mul56	: out std_logic_vector(7 downto 0)
		);
end mul56;

architecture mul56_arch of mul56 is
begin
	out_mul56(0) <= in_mul56(6) xor in_mul56(2);
	out_mul56(1) <= in_mul56(7) xor in_mul56(3) xor in_mul56(0);
	out_mul56(2) <= in_mul56(6) xor in_mul56(4) xor in_mul56(2) xor in_mul56(1) xor in_mul56(0);
	out_mul56(3) <= in_mul56(7) xor in_mul56(6) xor in_mul56(5) xor in_mul56(3) xor in_mul56(1);
	out_mul56(4) <= in_mul56(7) xor in_mul56(6) xor in_mul56(4) xor in_mul56(2) xor in_mul56(0);
	out_mul56(5) <= in_mul56(7) xor in_mul56(5) xor in_mul56(3) xor in_mul56(1);
	out_mul56(6) <= in_mul56(4) xor in_mul56(0);
	out_mul56(7) <= in_mul56(5) xor in_mul56(1);
end mul56_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 82	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul82 is
port	(
		in_mul82	: in std_logic_vector(7 downto 0);
		out_mul82	: out std_logic_vector(7 downto 0)
		);
end mul82;

architecture mul82_arch of mul82 is
begin
	out_mul82(0) <= in_mul82(7) xor in_mul82(6) xor in_mul82(5) xor in_mul82(3) xor in_mul82(1);
	out_mul82(1) <= in_mul82(7) xor in_mul82(6) xor in_mul82(4) xor in_mul82(2) xor in_mul82(0);
	out_mul82(2) <= in_mul82(6);
	out_mul82(3) <= in_mul82(6) xor in_mul82(5) xor in_mul82(3) xor in_mul82(1);
	out_mul82(4) <= in_mul82(7) xor in_mul82(6) xor in_mul82(4) xor in_mul82(2);
	out_mul82(5) <= in_mul82(7) xor in_mul82(5) xor in_mul82(3);
	out_mul82(6) <= in_mul82(7) xor in_mul82(5) xor in_mul82(4) xor in_mul82(3) xor in_mul82(1);
	out_mul82(7) <= in_mul82(6) xor in_mul82(5) xor in_mul82(4) xor in_mul82(2) xor in_mul82(0);
end mul82_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by f3	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mulf3 is
port	(
		in_mulf3	: in std_logic_vector(7 downto 0);
		out_mulf3	: out std_logic_vector(7 downto 0)
		);
end mulf3;

architecture mulf3_arch of mulf3 is
begin
	out_mulf3(0) <= in_mulf3(7) xor in_mulf3(6) xor in_mulf3(2) xor in_mulf3(1) xor in_mulf3(0);
	out_mulf3(1) <= in_mulf3(7) xor in_mulf3(3) xor in_mulf3(2) xor in_mulf3(1) xor in_mulf3(0);
	out_mulf3(2) <= in_mulf3(7) xor in_mulf3(6) xor in_mulf3(4) xor in_mulf3(3);
	out_mulf3(3) <= in_mulf3(6) xor in_mulf3(5) xor in_mulf3(4) xor in_mulf3(2) xor in_mulf3(1);
	out_mulf3(4) <= in_mulf3(7) xor in_mulf3(6) xor in_mulf3(5) xor in_mulf3(3) xor in_mulf3(2) xor in_mulf3(0);
	out_mulf3(5) <= in_mulf3(7) xor in_mulf3(6) xor in_mulf3(4) xor in_mulf3(3) xor in_mulf3(1) xor in_mulf3(0);
	out_mulf3(6) <= in_mulf3(6) xor in_mulf3(5) xor in_mulf3(4) xor in_mulf3(0);
	out_mulf3(7) <= in_mulf3(7) xor in_mulf3(6) xor in_mulf3(5) xor in_mulf3(1) xor in_mulf3(0);
end mulf3_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 1e	
--						


library ieee;
use ieee.std_logic_1164.all;

entity mul1e is
port	(
		in_mul1e	: in std_logic_vector(7 downto 0);
		out_mul1e	: out std_logic_vector(7 downto 0)
		);
end mul1e;

architecture mul1e_arch of mul1e is
begin
	out_mul1e(0) <= in_mul1e(5) xor in_mul1e(4);
	out_mul1e(1) <= in_mul1e(6) xor in_mul1e(5) xor in_mul1e(0);
	out_mul1e(2) <= in_mul1e(7) xor in_mul1e(6) xor in_mul1e(5) xor in_mul1e(4) xor in_mul1e(1) xor in_mul1e(0);
	out_mul1e(3) <= in_mul1e(7) xor in_mul1e(6) xor in_mul1e(4) xor in_mul1e(2) xor in_mul1e(1) xor in_mul1e(0);
	out_mul1e(4) <= in_mul1e(7) xor in_mul1e(5) xor in_mul1e(3) xor in_mul1e(2) xor in_mul1e(1) xor in_mul1e(0);
	out_mul1e(5) <= in_mul1e(6) xor in_mul1e(4) xor in_mul1e(3) xor in_mul1e(2) xor in_mul1e(1);
	out_mul1e(6) <= in_mul1e(7) xor in_mul1e(3) xor in_mul1e(2);
	out_mul1e(7) <= in_mul1e(4) xor in_mul1e(3);
end mul1e_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by c6	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mulc6 is
port	(
		in_mulc6	: in std_logic_vector(7 downto 0);
		out_mulc6	: out std_logic_vector(7 downto 0)
		);
end mulc6;

architecture mulc6_arch of mulc6 is
begin
	out_mulc6(0) <= in_mulc6(6) xor in_mulc6(5) xor in_mulc6(4) xor in_mulc6(3) xor in_mulc6(2) xor in_mulc6(1);
	out_mulc6(1) <= in_mulc6(7) xor in_mulc6(6) xor in_mulc6(5) xor in_mulc6(4) xor in_mulc6(3) xor in_mulc6(2) xor in_mulc6(0);
	out_mulc6(2) <= in_mulc6(7) xor in_mulc6(2) xor in_mulc6(0);
	out_mulc6(3) <= in_mulc6(6) xor in_mulc6(5) xor in_mulc6(4) xor in_mulc6(2);
	out_mulc6(4) <= in_mulc6(7) xor in_mulc6(6) xor in_mulc6(5) xor in_mulc6(3);
	out_mulc6(5) <= in_mulc6(7) xor in_mulc6(6) xor in_mulc6(4);
	out_mulc6(6) <= in_mulc6(7) xor in_mulc6(6) xor in_mulc6(4) xor in_mulc6(3) xor in_mulc6(2) xor in_mulc6(1) xor in_mulc6(0);
	out_mulc6(7) <= in_mulc6(7) xor in_mulc6(5) xor in_mulc6(4) xor in_mulc6(3) xor in_mulc6(2) xor in_mulc6(1) xor in_mulc6(0);
end mulc6_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 68	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul68 is
port	(
		in_mul68	: in std_logic_vector(7 downto 0);
		out_mul68	: out std_logic_vector(7 downto 0)
		);
end mul68;


architecture mul68_arch of mul68 is
begin
	out_mul68(0) <= in_mul68(7) xor in_mul68(6) xor in_mul68(4) xor in_mul68(3) xor in_mul68(2);
	out_mul68(1) <= in_mul68(7) xor in_mul68(5) xor in_mul68(4) xor in_mul68(3);
	out_mul68(2) <= in_mul68(7) xor in_mul68(5) xor in_mul68(3) xor in_mul68(2);
	out_mul68(3) <= in_mul68(7) xor in_mul68(2) xor in_mul68(0);
	out_mul68(4) <= in_mul68(3) xor in_mul68(1);
	out_mul68(5) <= in_mul68(4) xor in_mul68(2) xor in_mul68(0);
	out_mul68(6) <= in_mul68(7) xor in_mul68(6) xor in_mul68(5) xor in_mul68(4) xor in_mul68(2) xor in_mul68(1) xor in_mul68(0);
	out_mul68(7) <= in_mul68(7) xor in_mul68(6) xor in_mul68(5) xor in_mul68(3) xor in_mul68(2) xor in_mul68(1);
end mul68_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by e5	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mule5 is
port	(
		in_mule5	: in std_logic_vector(7 downto 0);
		out_mule5	: out std_logic_vector(7 downto 0)
		);
end mule5;


architecture mule5_arch of mule5 is
begin
	out_mule5(0) <= in_mule5(6) xor in_mule5(4) xor in_mule5(2) xor in_mule5(1) xor in_mule5(0);
	out_mule5(1) <= in_mule5(7) xor in_mule5(5) xor in_mule5(3) xor in_mule5(2) xor in_mule5(1);
	out_mule5(2) <= in_mule5(3) xor in_mule5(1) xor in_mule5(0);
	out_mule5(3) <= in_mule5(6);
	out_mule5(4) <= in_mule5(7);
	out_mule5(5) <= in_mule5(0);
	out_mule5(6) <= in_mule5(6) xor in_mule5(4) xor in_mule5(2) xor in_mule5(0);
	out_mule5(7) <= in_mule5(7) xor in_mule5(5) xor in_mule5(3) xor in_mule5(1) xor in_mule5(0);
end mule5_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 02	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul02 is
port	(
		in_mul02	: in std_logic_vector(7 downto 0);
		out_mul02	: out std_logic_vector(7 downto 0)
		);
end mul02;


architecture mul02_arch of mul02 is
begin
	out_mul02(0) <= in_mul02(7);
	out_mul02(1) <= in_mul02(0);
	out_mul02(2) <= in_mul02(7) xor in_mul02(1);
	out_mul02(3) <= in_mul02(7) xor in_mul02(2);
	out_mul02(4) <= in_mul02(3);
	out_mul02(5) <= in_mul02(4);
	out_mul02(6) <= in_mul02(7) xor in_mul02(5);
	out_mul02(7) <= in_mul02(6);
end mul02_arch;
			  

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by a1	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mula1 is
port	(
		in_mula1	: in std_logic_vector(7 downto 0);
		out_mula1	: out std_logic_vector(7 downto 0)
		);
end mula1;

architecture mula1_arch of mula1 is
begin
	out_mula1(0) <= in_mula1(7) xor in_mula1(6) xor in_mula1(1) xor in_mula1(0);
	out_mula1(1) <= in_mula1(7) xor in_mula1(2) xor in_mula1(1);
	out_mula1(2) <= in_mula1(7) xor in_mula1(6) xor in_mula1(3) xor in_mula1(2) xor in_mula1(1);
	out_mula1(3) <= in_mula1(6) xor in_mula1(4) xor in_mula1(3) xor in_mula1(2) xor in_mula1(1);
	out_mula1(4) <= in_mula1(7) xor in_mula1(5) xor in_mula1(4) xor in_mula1(3) xor in_mula1(2);
	out_mula1(5) <= in_mula1(6) xor in_mula1(5) xor in_mula1(4) xor in_mula1(3) xor in_mula1(0);
	out_mula1(6) <= in_mula1(5) xor in_mula1(4);
	out_mula1(7) <= in_mula1(6) xor in_mula1(5) xor in_mula1(0);
end mula1_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by fc	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mulfc is
port	(
		in_mulfc	: in std_logic_vector(7 downto 0);
		out_mulfc	: out std_logic_vector(7 downto 0)
		);
end mulfc;


architecture mulfc_arch of mulfc is
begin
	out_mulfc(0) <= in_mulfc(7) xor in_mulfc(5) xor in_mulfc(2) xor in_mulfc(1);
	out_mulfc(1) <= in_mulfc(6) xor in_mulfc(3) xor in_mulfc(2);
	out_mulfc(2) <= in_mulfc(5) xor in_mulfc(4) xor in_mulfc(3) xor in_mulfc(2) xor in_mulfc(1) xor in_mulfc(0);
	out_mulfc(3) <= in_mulfc(7) xor in_mulfc(6) xor in_mulfc(4) xor in_mulfc(3) xor in_mulfc(0);
	out_mulfc(4) <= in_mulfc(7) xor in_mulfc(5) xor in_mulfc(4) xor in_mulfc(1) xor in_mulfc(0);
	out_mulfc(5) <= in_mulfc(6) xor in_mulfc(5) xor in_mulfc(2) xor in_mulfc(1) xor in_mulfc(0);
	out_mulfc(6) <= in_mulfc(6) xor in_mulfc(5) xor in_mulfc(3) xor in_mulfc(0);
	out_mulfc(7) <= in_mulfc(7) xor in_mulfc(6) xor in_mulfc(4) xor in_mulfc(1) xor in_mulfc(0);
end mulfc_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by c1	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mulc1 is
port	(
		in_mulc1	: in std_logic_vector(7 downto 0);
		out_mulc1	: out std_logic_vector(7 downto 0)
		);
end mulc1;


architecture mulc1_arch of mulc1 is
begin
	out_mulc1(0) <= in_mulc1(7) xor in_mulc1(5) xor in_mulc1(4) xor in_mulc1(3) xor in_mulc1(2) xor in_mulc1(1) xor in_mulc1(0);
	out_mulc1(1) <= in_mulc1(6) xor in_mulc1(5) xor in_mulc1(4) xor in_mulc1(3) xor in_mulc1(2) xor in_mulc1(1);
	out_mulc1(2) <= in_mulc1(6) xor in_mulc1(1);
	out_mulc1(3) <= in_mulc1(5) xor in_mulc1(4) xor in_mulc1(3) xor in_mulc1(1);
	out_mulc1(4) <= in_mulc1(6) xor in_mulc1(5) xor in_mulc1(4) xor in_mulc1(2);
	out_mulc1(5) <= in_mulc1(7) xor in_mulc1(6) xor in_mulc1(5) xor in_mulc1(3);
	out_mulc1(6) <= in_mulc1(6) xor in_mulc1(5) xor in_mulc1(3) xor in_mulc1(2) xor in_mulc1(1) xor in_mulc1(0);
	out_mulc1(7) <= in_mulc1(7) xor in_mulc1(6) xor in_mulc1(4) xor in_mulc1(3) xor in_mulc1(2) xor in_mulc1(1) xor in_mulc1(0);
end mulc1_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 47	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul47 is
port	(
		in_mul47	: in std_logic_vector(7 downto 0);
		out_mul47	: out std_logic_vector(7 downto 0)
		);
end mul47;

architecture mul47_arch of mul47 is
begin
	out_mul47(0) <= in_mul47(4) xor in_mul47(2) xor in_mul47(0);
	out_mul47(1) <= in_mul47(5) xor in_mul47(3) xor in_mul47(1) xor in_mul47(0);
	out_mul47(2) <= in_mul47(6) xor in_mul47(1) xor in_mul47(0);
	out_mul47(3) <= in_mul47(7) xor in_mul47(4) xor in_mul47(1);
	out_mul47(4) <= in_mul47(5) xor in_mul47(2);
	out_mul47(5) <= in_mul47(6) xor in_mul47(3);
	out_mul47(6) <= in_mul47(7) xor in_mul47(2) xor in_mul47(0);
	out_mul47(7) <= in_mul47(3) xor in_mul47(1);
end mul47_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by ae	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mulae is
port	(
		in_mulae	: in std_logic_vector(7 downto 0);
		out_mulae	: out std_logic_vector(7 downto 0)
		);
end mulae;

architecture mulae_arch of mulae is
begin
	out_mulae(0) <= in_mulae(7) xor in_mulae(5) xor in_mulae(1);
	out_mulae(1) <= in_mulae(6) xor in_mulae(2) xor in_mulae(0);
	out_mulae(2) <= in_mulae(5) xor in_mulae(3) xor in_mulae(0);
	out_mulae(3) <= in_mulae(7) xor in_mulae(6) xor in_mulae(5) xor in_mulae(4) xor in_mulae(0);
	out_mulae(4) <= in_mulae(7) xor in_mulae(6) xor in_mulae(5) xor in_mulae(1);
	out_mulae(5) <= in_mulae(7) xor in_mulae(6) xor in_mulae(2) xor in_mulae(0);
	out_mulae(6) <= in_mulae(5) xor in_mulae(3);
	out_mulae(7) <= in_mulae(6) xor in_mulae(4) xor in_mulae(0);
end mulae_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 3d	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul3d is
port	(
		in_mul3d	: in std_logic_vector(7 downto 0);
		out_mul3d	: out std_logic_vector(7 downto 0)
		);
end mul3d;

architecture mul3d_arch of mul3d is
begin
	out_mul3d(0) <= in_mul3d(4) xor in_mul3d(3) xor in_mul3d(0);
	out_mul3d(1) <= in_mul3d(5) xor in_mul3d(4) xor in_mul3d(1);
	out_mul3d(2) <= in_mul3d(6) xor in_mul3d(5) xor in_mul3d(4) xor in_mul3d(3) xor in_mul3d(2) xor in_mul3d(0);
	out_mul3d(3) <= in_mul3d(7) xor in_mul3d(6) xor in_mul3d(5) xor in_mul3d(1) xor in_mul3d(0);
	out_mul3d(4) <= in_mul3d(7) xor in_mul3d(6) xor in_mul3d(2) xor in_mul3d(1) xor in_mul3d(0);
	out_mul3d(5) <= in_mul3d(7) xor in_mul3d(3) xor in_mul3d(2) xor in_mul3d(1) xor in_mul3d(0);
	out_mul3d(6) <= in_mul3d(2) xor in_mul3d(1);
	out_mul3d(7) <= in_mul3d(3) xor in_mul3d(2);
end mul3d_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 19	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul19 is
port	(
		in_mul19	: in std_logic_vector(7 downto 0);
		out_mul19	: out std_logic_vector(7 downto 0)
		);
end mul19;

architecture mul19_arch of mul19 is
begin
	out_mul19(0) <= in_mul19(7) xor in_mul19(6) xor in_mul19(5) xor in_mul19(4) xor in_mul19(0);
	out_mul19(1) <= in_mul19(7) xor in_mul19(6) xor in_mul19(5) xor in_mul19(1);
	out_mul19(2) <= in_mul19(5) xor in_mul19(4) xor in_mul19(2);
	out_mul19(3) <= in_mul19(7) xor in_mul19(4) xor in_mul19(3) xor in_mul19(0);
	out_mul19(4) <= in_mul19(5) xor in_mul19(4) xor in_mul19(1) xor in_mul19(0);
	out_mul19(5) <= in_mul19(6) xor in_mul19(5) xor in_mul19(2) xor in_mul19(1);
	out_mul19(6) <= in_mul19(5) xor in_mul19(4) xor in_mul19(3) xor in_mul19(2);
	out_mul19(7) <= in_mul19(6) xor in_mul19(5) xor in_mul19(4) xor in_mul19(3);
end mul19_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- 						
--	multiplier by 03	
--						

library ieee;
use ieee.std_logic_1164.all;

entity mul03 is
port	(
		in_mul03	: in std_logic_vector(7 downto 0);
		out_mul03	: out std_logic_vector(7 downto 0)
		);
end mul03;

architecture mul03_arch of mul03 is
begin
	out_mul03(0) <= in_mul03(7) xor in_mul03(0);
	out_mul03(1) <= in_mul03(1) xor in_mul03(0);
	out_mul03(2) <= in_mul03(7) xor in_mul03(2) xor in_mul03(1);
	out_mul03(3) <= in_mul03(7) xor in_mul03(3) xor in_mul03(2);
	out_mul03(4) <= in_mul03(4) xor in_mul03(3);
	out_mul03(5) <= in_mul03(5) xor in_mul03(4);
	out_mul03(6) <= in_mul03(7) xor in_mul03(6) xor in_mul03(5);
	out_mul03(7) <= in_mul03(7) xor in_mul03(6);
end mul03_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish data input is the component
-- that transforms the data input to the
-- first round to the wanted form as is 
-- described in the twofish prototype
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_data_input is
port	(
		in_tdi	: in std_logic_vector(127 downto 0);
		out_tdi	: out std_logic_vector(127 downto 0)
		);
end twofish_data_input;

architecture twofish_data_input_arch of twofish_data_input is
	
	-- we declare internal signals							 
	signal	byte0, byte1, byte2, byte3,
			byte4, byte5, byte6,
			byte7, byte8, byte9,
			byte10,	byte11, byte12,
			byte13,	byte14,	byte15	: std_logic_vector(7 downto 0);
	signal	P0, P1, P2, P3			: std_logic_vector(31 downto 0);

begin
	
	-- we assign the input signal to the respective
	-- bytes as is described in the prototype
	byte15 <= in_tdi(7 downto 0);
	byte14 <= in_tdi(15 downto 8);
	byte13 <= in_tdi(23 downto 16);
	byte12 <= in_tdi(31 downto 24);
	byte11 <= in_tdi(39 downto 32);
	byte10 <= in_tdi(47 downto 40);
	byte9 <= in_tdi(55 downto 48);
	byte8 <= in_tdi(63 downto 56);
	byte7 <= in_tdi(71 downto 64);
	byte6 <= in_tdi(79 downto 72);
	byte5 <= in_tdi(87 downto 80);
	byte4 <= in_tdi(95 downto 88);
	byte3 <= in_tdi(103 downto 96);
	byte2 <= in_tdi(111 downto 104);
	byte1 <= in_tdi(119 downto 112);
	byte0 <= in_tdi(127 downto 120);

	-- we rearrange the bytes and send them to exit
	P0 <= byte3 & byte2 & byte1 & byte0;
	P1 <= byte7 & byte6 & byte5 & byte4;
	P2 <= byte11 & byte10 & byte9 & byte8;
	P3 <= byte15 & byte14 & byte13 & byte12;

	out_tdi <= P0 & P1 & P2 & P3;

end twofish_data_input_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


--
-- twofish data output is the component
-- that transforms the data output from the 
-- 16th round to the wanted form as is 
-- described in the twofish prototype
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_data_output is
port	(
		in_tdo	: in std_logic_vector(127 downto 0);
		out_tdo	: out std_logic_vector(127 downto 0)
		);
end twofish_data_output;

architecture twofish_data_output_arch of twofish_data_output is
	
	-- we declare internal signals							 
	signal	byte0, byte1, byte2, byte3,
			byte4, byte5, byte6,
			byte7, byte8, byte9,
			byte10,	byte11, byte12,
			byte13,	byte14,	byte15	: std_logic_vector(7 downto 0);
	signal	C0, C1, C2, C3			: std_logic_vector(31 downto 0);

begin
	
	-- we assign the input signal to the respective
	-- bytes as is described in the prototype
	byte15 <= in_tdo(7 downto 0);
	byte14 <= in_tdo(15 downto 8);
	byte13 <= in_tdo(23 downto 16);
	byte12 <= in_tdo(31 downto 24);
	byte11 <= in_tdo(39 downto 32);
	byte10 <= in_tdo(47 downto 40);
	byte9 <= in_tdo(55 downto 48);
	byte8 <= in_tdo(63 downto 56);
	byte7 <= in_tdo(71 downto 64);
	byte6 <= in_tdo(79 downto 72);
	byte5 <= in_tdo(87 downto 80);
	byte4 <= in_tdo(95 downto 88);
	byte3 <= in_tdo(103 downto 96);
	byte2 <= in_tdo(111 downto 104);
	byte1 <= in_tdo(119 downto 112);
	byte0 <= in_tdo(127 downto 120);

	-- we rearrange the bytes and send them to exit
	C0 <= byte3 & byte2 & byte1 & byte0;
	C1 <= byte7 & byte6 & byte5 & byte4;
	C2 <= byte11 & byte10 & byte9 & byte8;
	C3 <= byte15 & byte14 & byte13 & byte12;

	out_tdo <= C0 & C1 & C2 & C3;

end twofish_data_output_arch;

-- =======-======================================= --
-- =============================================== --
--												   --
-- second part: 128 key input dependent components --
--												   --
-- =============================================== --
-- =============================================== --


-- 					
--	reed solomon	for 128bits key
--					

library ieee;
use ieee.std_logic_1164.all;

entity reed_solomon128 is
port	(
		in_rs128			: in std_logic_vector(127 downto 0);
		out_Sfirst_rs128,
		out_Ssecond_rs128		: out std_logic_vector(31 downto 0)	
		);
end reed_solomon128;

architecture rs_128_arch of reed_solomon128 is

	-- declaring all components necessary for reed solomon
	-- 01
	component mul01
	port	(
			in_mul01	: in std_logic_vector(7 downto 0);
			out_mul01	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- a4	
	component mula4 
	port	(
			in_mula4	: in std_logic_vector(7 downto 0);			
			out_mula4	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 55
	component mul55 
	port	(
			in_mul55	: in std_logic_vector(7 downto 0);
			out_mul55	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 87
	component mul87 
	port	(
			in_mul87	: in std_logic_vector(7 downto 0);
			out_mul87	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 5a
	component mul5a 
	port	(
			in_mul5a	: in std_logic_vector(7 downto 0);
			out_mul5a	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 58
	component mul58 
	port	(
			in_mul58	: in std_logic_vector(7 downto 0);
			out_mul58	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- db
	component muldb 
	port	(
			in_muldb	: in std_logic_vector(7 downto 0);
			out_muldb	: out std_logic_vector(7 downto 0)
			);
	end component;

	
	-- 9e
	component mul9e 
	port	(
			in_mul9e	: in std_logic_vector(7 downto 0);
			out_mul9e	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 56
	component mul56 
	port	(
			in_mul56	: in std_logic_vector(7 downto 0);
			out_mul56	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 82
	component mul82 
	port	(
			in_mul82	: in std_logic_vector(7 downto 0);
			out_mul82	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- f3
	component mulf3 
	port	(
			in_mulf3	: in std_logic_vector(7 downto 0);
			out_mulf3	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 1e
	component mul1e 
	port	(
			in_mul1e	: in std_logic_vector(7 downto 0);
			out_mul1e	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- c6
	component mulc6 
	port	(
			in_mulc6	: in std_logic_vector(7 downto 0);
			out_mulc6	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 68
	component mul68 
	port	(
			in_mul68	: in std_logic_vector(7 downto 0);
			out_mul68	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- e5
	component mule5 
	port	(
			in_mule5	: in std_logic_vector(7 downto 0);
			out_mule5	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 02
	component mul02 
	port	(
			in_mul02	: in std_logic_vector(7 downto 0);
			out_mul02	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- a1
	component mula1 
	port	(
			in_mula1	: in std_logic_vector(7 downto 0);
			out_mula1	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- fc
	component mulfc 
	port	(
			in_mulfc	: in std_logic_vector(7 downto 0);
			out_mulfc	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- c1
	component mulc1 
	port	(
			in_mulc1	: in std_logic_vector(7 downto 0);
			out_mulc1	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 47
	component mul47 
	port	(
			in_mul47	: in std_logic_vector(7 downto 0);
			out_mul47	: out std_logic_vector(7 downto 0)	
			);
	end component;



	-- ae
	component mulae 
	port	(
			in_mulae	: in std_logic_vector(7 downto 0);
			out_mulae	: out std_logic_vector(7 downto 0)
			);
	end component;



	-- 3d
	component mul3d 
	port	(
			in_mul3d	: in std_logic_vector(7 downto 0);
			out_mul3d	: out std_logic_vector(7 downto 0)
			);
	end component;



	-- 19
	component mul19 
	port	(
			in_mul19	: in std_logic_vector(7 downto 0);
			out_mul19	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 03
	component mul03 
	port	(
			in_mul03	: in std_logic_vector(7 downto 0);
			out_mul03	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- declaring internal signals
	signal	m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15		: std_logic_vector(7 downto 0);	
	signal 	s00,s01,s02,s03,s10,s11,s12,s13								: std_logic_vector(7 downto 0);	
	signal	m0_01,m1_a4,m2_55,m3_87,m4_5a,m5_58,m6_db,m7_9e,
			m0_a4,m1_56,m2_82,m3_f3,m4_1e,m5_c6,m6_68,m7_e5,
			m0_02,m1_a1,m2_fc,m3_c1,m4_47,m5_ae,m6_3d,m7_19,
			m0_a4_1,m1_55,m2_87,m3_5a,m4_58,m5_db,m6_9e,m7_03			: std_logic_vector(7 downto 0);	
	signal	m8_01,m9_a4,m10_55,m11_87,m12_5a,m13_58,m14_db,m15_9e,
			m8_a4,m9_56,m10_82,m11_f3,m12_1e,m13_c6,m14_68,m15_e5,
			m8_02,m9_a1,m10_fc,m11_c1,m12_47,m13_ae,m14_3d,m15_19,
			m8_a4_1,m9_55,m10_87,m11_5a,m12_58,m13_db,m14_9e,m15_03		: std_logic_vector(7 downto 0);	

-- begin architecture description
begin

	-- first, we separate the input to the respective m
	-- for s1,j j=0..3
	m0 <= in_rs128(7 downto 0);
	m1 <= in_rs128(15 downto 8);
	m2 <= in_rs128(23 downto 16);
	m3 <= in_rs128(31 downto 24);
	m4 <= in_rs128(39 downto 32);
	m5 <= in_rs128(47 downto 40);
	m6 <= in_rs128(55 downto 48);
	m7 <= in_rs128(63 downto 56);

	-- for s0,j j=0..3
	m8 <= in_rs128(71 downto 64);
	m9 <= in_rs128(79 downto 72);
	m10 <= in_rs128(87 downto 80);
	m11 <= in_rs128(95 downto 88);
	m12 <= in_rs128(103 downto 96);
	m13 <= in_rs128(111 downto 104);
	m14 <= in_rs128(119 downto 112);
	m15 <= in_rs128(127 downto 120);


	-- after separating signals, we drive them to multipliers
	-- the first line of m0..7 forms s00
	m0_with_01: mul01
	port map	(
				in_mul01 => m0,
				out_mul01 => m0_01
				);

	m1_with_a4: mula4
	port map	(
				in_mula4 => m1,
				out_mula4 => m1_a4
				);

	m2_with_55: mul55
	port map	(
				in_mul55 => m2,
				out_mul55 => m2_55
				);

	m3_with_87: mul87
	port map	(
				in_mul87 => m3,
				out_mul87 => m3_87
				);

	m4_with_5a: mul5a
	port map	(
				in_mul5a => m4,
				out_mul5a => m4_5a
				);

	m5_with_58: mul58
	port map	(
				in_mul58 => m5,
				out_mul58 => m5_58
				);

	m6_with_db: muldb
	port map	(
				in_muldb => m6,
				out_muldb => m6_db
				);

	m7_with_9e: mul9e
	port map	(
				in_mul9e => m7,
				out_mul9e => m7_9e
				);

	-- the second row creates s01
	m0_with_a4: mula4
	port map	(
				in_mula4 => m0,
				out_mula4 => m0_a4
				);

	m1_with_56: mul56
	port map	(
				in_mul56 => m1,
				out_mul56 => m1_56
				);

	m2_with_82: mul82
	port map	(
				in_mul82 => m2,
				out_mul82 => m2_82
				);
	
	m3_with_f3: mulf3
	port map	(
				in_mulf3 => m3,
				out_mulf3 => m3_f3
				);

	m4_with_1e: mul1e
	port map	(
				in_mul1e => m4,
				out_mul1e => m4_1e
				);

	m5_with_c6: mulc6
	port map	(
				in_mulc6 => m5,
				out_mulc6 => m5_c6
				);

	m6_with_68: mul68
	port map	(
				in_mul68 => m6,
				out_mul68 => m6_68
				);

	m7_with_e5: mule5
	port map	(
				in_mule5 => m7,
				out_mule5 => m7_e5
				);

	-- the third row creates s02
	m0_with_02: mul02
	port map	(
				in_mul02 => m0,
				out_mul02 => m0_02
				);

	m1_with_a1: mula1
	port map	(
				in_mula1 => m1,
				out_mula1 => m1_a1
				);

	m2_with_fc: mulfc
	port map	(
				in_mulfc => m2,
				out_mulfc => m2_fc
				);

	m3_with_c1: mulc1
	port map	(
				in_mulc1 => m3,
				out_mulc1 => m3_c1
				);

	m4_with_47: mul47
	port map	(
				in_mul47 => m4,
				out_mul47 => m4_47
				);

	m5_with_ae: mulae
	port map	(
				in_mulae => m5,
				out_mulae => m5_ae
				);

	m6_with_3d: mul3d
	port map	(
				in_mul3d => m6,
				out_mul3d => m6_3d
				);

	m7_with_19: mul19
	port map	(
				in_mul19 => m7,
				out_mul19 => m7_19
				);

	-- the fourth row creates s03
	m0_with_a4_1: mula4
	port map	(
				in_mula4 => m0,
				out_mula4 => m0_a4_1
				);

	m1_with_55: mul55
	port map	(
				in_mul55 => m1,
				out_mul55 => m1_55
				);

	m2_with_87: mul87
	port map	(
				in_mul87 => m2,
				out_mul87 => m2_87
				);

	m3_with_5a: mul5a
	port map	(
				in_mul5a => m3,
				out_mul5a => m3_5a
				);

	m4_with_58: mul58
	port map	(
				in_mul58 => m4,
				out_mul58 => m4_58
				);

	m5_with_db: muldb
	port map	(
				in_muldb => m5,
				out_muldb => m5_db
				);

	m6_with_9e: mul9e
	port map	(
				in_mul9e => m6,
				out_mul9e => m6_9e
				);

	m7_with_03: mul03
	port map	(
				in_mul03 => m7,
				out_mul03 => m7_03
				);


	-- we create the s1,j j=0..3
	-- the first row of m0..7 creates the s10
	m8_with_01: mul01
	port map	(
				in_mul01 => m8,
				out_mul01 => m8_01
				);

	m9_with_a4: mula4
	port map	(
				in_mula4 => m9,
				out_mula4 => m9_a4
				);

	m10_with_55: mul55
	port map	(
				in_mul55 => m10,
				out_mul55 => m10_55
				);

	m11_with_87: mul87
	port map	(
				in_mul87 => m11,
				out_mul87 => m11_87
				);

	m12_with_5a: mul5a
	port map	(
				in_mul5a => m12,
				out_mul5a => m12_5a
				);

	m13_with_58: mul58
	port map	(
				in_mul58 => m13,
				out_mul58 => m13_58
				);

	m14_with_db: muldb
	port map	(
				in_muldb => m14,
				out_muldb => m14_db
				);

	m15_with_9e: mul9e
	port map	(
				in_mul9e => m15,
				out_mul9e => m15_9e
				);

	-- the second row creates s11
	m8_with_a4: mula4
	port map	(
				in_mula4 => m8,
				out_mula4 => m8_a4
				);

	m9_with_56: mul56
	port map	(
				in_mul56 => m9,
				out_mul56 => m9_56
				);

	m10_with_82: mul82
	port map	(
				in_mul82 => m10,
				out_mul82 => m10_82
				);
	
	m11_with_f3: mulf3
	port map	(
				in_mulf3 => m11,
				out_mulf3 => m11_f3
				);

	m12_with_1e: mul1e
	port map	(
				in_mul1e => m12,
				out_mul1e => m12_1e
				);

	m13_with_c6: mulc6
	port map	(
				in_mulc6 => m13,
				out_mulc6 => m13_c6
				);

	m14_with_68: mul68
	port map	(
				in_mul68 => m14,
				out_mul68 => m14_68
				);

	m15_with_e5: mule5
	port map	(
				in_mule5 => m15,
				out_mule5 => m15_e5
				);

	-- the third row creates s12
	m8_with_02: mul02
	port map	(
				in_mul02 => m8,
				out_mul02 => m8_02
				);

	m9_with_a1: mula1
	port map	(
				in_mula1 => m9,
				out_mula1 => m9_a1
				);

	m10_with_fc: mulfc
	port map	(
				in_mulfc => m10,
				out_mulfc => m10_fc
				);

	m11_with_c1: mulc1
	port map	(
				in_mulc1 => m11,
				out_mulc1 => m11_c1
				);

	m12_with_47: mul47
	port map	(
				in_mul47 => m12,
				out_mul47 => m12_47
				);

	m13_with_ae: mulae
	port map	(
				in_mulae => m13,
				out_mulae => m13_ae
				);

	m14_with_3d: mul3d
	port map	(
				in_mul3d => m14,
				out_mul3d => m14_3d
				);

	m15_with_19: mul19
	port map	(
				in_mul19 => m15,
				out_mul19 => m15_19
				);

	-- the fourth row creates s13
	m8_with_a4_1: mula4
	port map	(
				in_mula4 => m8,
				out_mula4 => m8_a4_1
				);

	m9_with_55: mul55
	port map	(
				in_mul55 => m9,
				out_mul55 => m9_55
				);

	m10_with_87: mul87
	port map	(
				in_mul87 => m10,
				out_mul87 => m10_87
				);

	m11_with_5a: mul5a
	port map	(
				in_mul5a => m11,
				out_mul5a => m11_5a
				);

	m12_with_58: mul58
	port map	(
				in_mul58 => m12,
				out_mul58 => m12_58
				);

	m13_with_db: muldb
	port map	(
				in_muldb => m13,
				out_muldb => m13_db
				);

	m14_with_9e: mul9e
	port map	(
				in_mul9e => m14,
				out_mul9e => m14_9e
				);

	m15_with_03: mul03
	port map	(
				in_mul03 => m15,
				out_mul03 => m15_03
				);


	-- after getting the results from multipliers
	-- we combine them in order to get the additions
	s00 <= m0_01 XOR m1_a4 XOR m2_55 XOR m3_87 XOR m4_5a XOR m5_58 XOR m6_db XOR m7_9e;
	s01 <= m0_a4 XOR m1_56 XOR m2_82 XOR m3_f3 XOR m4_1e XOR m5_c6 XOR m6_68 XOR m7_e5;
	s02 <= m0_02 XOR m1_a1 XOR m2_fc XOR m3_c1 XOR m4_47 XOR m5_ae XOR m6_3d XOR m7_19;
	s03 <= m0_a4_1 XOR m1_55 XOR m2_87 XOR m3_5a XOR m4_58 XOR m5_db XOR m6_9e XOR m7_03;

	-- after creating s0,j j=0...3 we form the S0
	-- little endian 
	out_Sfirst_rs128 <= s03 & s02 & s01 & s00;

	s10 <= m8_01 XOR m9_a4 XOR m10_55 XOR m11_87 XOR m12_5a XOR m13_58 XOR m14_db XOR m15_9e;
	s11 <= m8_a4 XOR m9_56 XOR m10_82 XOR m11_f3 XOR m12_1e XOR m13_c6 XOR m14_68 XOR m15_e5;
	s12 <= m8_02 XOR m9_a1 XOR m10_fc XOR m11_c1 XOR m12_47 XOR m13_ae XOR m14_3d XOR m15_19;
	s13 <= m8_a4_1 XOR m9_55 XOR m10_87 XOR m11_5a XOR m12_58 XOR m13_db XOR m14_9e XOR m15_03;

	-- after creating s1,j j=0...3 we form the S1
	-- little endian
	out_Ssecond_rs128 <= s13 & s12 & s11 & s10;

end rs_128_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- h function for 128 bits key
-- 

library ieee;
use ieee.std_logic_1164.all;

entity h_128 is
port	(
		in_h128		: in std_logic_vector(7 downto 0);
		Mfirst_h128,
		Msecond_h128	: in std_logic_vector(31 downto 0);
		out_h128		: out std_logic_vector(31 downto 0)
		);
end h_128;

architecture h128_arch of h_128 is

	-- we declare internal signals
	signal	from_first_row,
			to_second_row,
			from_second_row,
			to_third_row,
			to_mds			: std_logic_vector(31 downto 0);
					
	-- we declare all components needed 				   
	component q0
	port	(			   
			in_q0 	: in std_logic_vector(7 downto 0);
			out_q0	: out std_logic_vector(7 downto 0)
			);
	end component;
	
	component q1
	port	(
			in_q1 	: in std_logic_vector(7 downto 0);
			out_q1	: out std_logic_vector(7 downto 0)
			);
	end component;

	component mds
	port	(
			y0,
			y1,
			y2,
			y3	: in std_logic_vector(7 downto 0);
			z0,
			z1,
			z2,
			z3	: out std_logic_vector(7 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- first row of q
	first_q0_1: q0
	port map	(
				in_q0 => in_h128,
				out_q0 => from_first_row(7 downto 0)
				);
	first_q1_1: q1
	port map	(
				in_q1 => in_h128,
				out_q1 => from_first_row(15 downto 8)
				);
	first_q0_2: q0
	port map	(
				in_q0 => in_h128,
				out_q0 => from_first_row(23 downto 16)
				);
	first_q1_2: q1
	port map	(
				in_q1 => in_h128,
				out_q1 => from_first_row(31 downto 24)
				);

	-- we perform the XOR of the results of the first row
	-- with first M of h (Mfist_h128)
	to_second_row <= from_first_row XOR Mfirst_h128;

	-- second row of q
	second_q0_1: q0
	port map	(
				in_q0 => to_second_row(7 downto 0),
				out_q0 => from_second_row(7 downto 0)
				);
	second_q0_2: q0
	port map	(
				in_q0 => to_second_row(15 downto 8),
				out_q0 => from_second_row(15 downto 8)
				);
	second_q1_1: q1
	port map	(
				in_q1 => to_second_row(23 downto 16),
				out_q1 => from_second_row(23 downto 16)
				);
	second_q1_2: q1
	port map	(
				in_q1 => to_second_row(31 downto 24),
				out_q1 => from_second_row(31 downto 24)
				);
				
	-- we perform the second XOR
	to_third_row <= from_second_row XOR Msecond_h128;
	
	-- the third row of q
	third_q1_1: q1
	port map	(
				in_q1 => to_third_row(7 downto 0),
				out_q1 => to_mds(7 downto 0)
				);
	third_q0_1: q0
	port map	(
				in_q0 => to_third_row(15 downto 8),
				out_q0 => to_mds(15 downto 8)
				);
	third_q1_2: q1
	port map	(
				in_q1 => to_third_row(23 downto 16),
				out_q1 => to_mds(23 downto 16)
				);
	third_q0_2: q0
	port map	(
				in_q0 => to_third_row(31 downto 24),
				out_q0 => to_mds(31 downto 24)
				);
				
	-- mds table
	mds_table: mds
	port map	(
				y0 => to_mds(7 downto 0),
				y1 => to_mds(15 downto 8),
				y2 => to_mds(23 downto 16),
				y3 => to_mds(31 downto 24),
				z0 => out_h128(7 downto 0),
				z1 => out_h128(15 downto 8),
				z2 => out_h128(23 downto 16),
				z3 => out_h128(31 downto 24)
				);

end h128_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


--
-- g function for 128 bits key
-- 

library ieee;
use ieee.std_logic_1164.all;

entity g_128 is
port	(
		in_g128,
		in_S0_g128,
		in_S1_g128		: in std_logic_vector(31 downto 0);
		out_g128		: out std_logic_vector(31 downto 0)
		);
end g_128;

architecture g128_arch of g_128 is

	-- we declare the internal signals
	signal	from_first_row,
			to_second_row,
			from_second_row,
			to_third_row,
			to_mds			: std_logic_vector(31 downto 0);

	component q0
	port	(
			in_q0 	: in std_logic_vector(7 downto 0);
			out_q0	: out std_logic_vector(7 downto 0)
			);
	end component;
	
	component q1
	port	(
			in_q1 	: in std_logic_vector(7 downto 0);
			out_q1	: out std_logic_vector(7 downto 0)
			);
	end component;

	component mds
	port	(
			y0,
			y1,
			y2,
			y3	: in std_logic_vector(7 downto 0);
			z0,
			z1,
			z2,
			z3	: out std_logic_vector(7 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- first row of q
	first_q0_1: q0
	port map	(
				in_q0 => in_g128(7 downto 0),
				out_q0 => from_first_row(7 downto 0)
				);
	first_q1_1: q1
	port map	(
				in_q1 => in_g128(15 downto 8),
				out_q1 => from_first_row(15 downto 8)
				);
	first_q0_2: q0
	port map	(
				in_q0 => in_g128(23 downto 16),
				out_q0 => from_first_row(23 downto 16)
				);
	first_q1_2: q1
	port map	(
				in_q1 => in_g128(31 downto 24),
				out_q1 => from_first_row(31 downto 24)
				);

	-- we XOR the result of the first row
	-- with the S0
	to_second_row <= from_first_row XOR in_S0_g128;

	-- second row of q
	second_q0_1: q0
	port map	(
				in_q0 => to_second_row(7 downto 0),
				out_q0 => from_second_row(7 downto 0)
				);
	second_q0_2: q0
	port map	(
				in_q0 => to_second_row(15 downto 8),
				out_q0 => from_second_row(15 downto 8)
				);
	second_q1_1: q1
	port map	(
				in_q1 => to_second_row(23 downto 16),
				out_q1 => from_second_row(23 downto 16)
				);
	second_q1_2: q1
	port map	(
				in_q1 => to_second_row(31 downto 24),
				out_q1 => from_second_row(31 downto 24)
				);
				
	-- we perform the XOR
	to_third_row <= from_second_row XOR in_S1_g128;
	
	-- third row of q
	third_q1_1: q1
	port map	(
				in_q1 => to_third_row(7 downto 0),
				out_q1 => to_mds(7 downto 0)
				);
	third_q0_1: q0
	port map	(
				in_q0 => to_third_row(15 downto 8),
				out_q0 => to_mds(15 downto 8)
				);
	third_q1_2: q1
	port map	(
				in_q1 => to_third_row(23 downto 16),
				out_q1 => to_mds(23 downto 16)
				);
	third_q0_2: q0
	port map	(
				in_q0 => to_third_row(31 downto 24),
				out_q0 => to_mds(31 downto 24)
				);
				
	-- mds table 
	mds_table: mds
	port map	(
				y0 => to_mds(7 downto 0),
				y1 => to_mds(15 downto 8),
				y2 => to_mds(23 downto 16),
				y3 => to_mds(31 downto 24),
				z0 => out_g128(7 downto 0),
				z1 => out_g128(15 downto 8),
				z2 => out_g128(23 downto 16),
				z3 => out_g128(31 downto 24)
				);

end g128_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


--
-- f function with 128 bits key
-- 

library ieee;
use ieee.std_logic_1164.all;

entity f_128 is
port	(
		up_in_f128,
		low_in_f128,
		S0_in_f128,
		S1_in_f128,
		up_key_f128,
		low_key_f128		: in std_logic_vector(31 downto 0);
		up_out_f128,
		low_out_f128		: out std_logic_vector(31 downto 0)
		);
end f_128;

architecture f128_arch of f_128 is

	-- we declare the internal signals 
	signal	from_shift_8,
			to_up_pht,
			to_low_pht,
			to_up_key,
			to_low_key,
			intermediate_carry1,
			intermediate_carry2	: std_logic_vector(31 downto 0);
	signal	zero					: std_logic;
	
	
	component g_128
	port	(
			in_g128,
			in_S0_g128,
			in_S1_g128	: in std_logic_vector(31 downto 0);
			out_g128		: out std_logic_vector(31 downto 0)
			);
	end component;
	
	component pht
	port	(
			up_in_pht,
			down_in_pht	: in std_logic_vector(31 downto 0);
			up_out_pht,
			down_out_pht	: out std_logic_vector(31 downto 0)
			);
	end component;

	component adder
	port	(
			in1_adder,
			in2_adder,
			in_carry_adder	: in std_logic;
			out_adder,
			out_carry_adder	: out std_logic
			);
	end component;

-- begin architecture description
begin

	-- we initialize zero
	zero <= '0';
	
	-- upper g_128
	upper_g128: g_128
	port map	(
				in_g128 => up_in_f128,
				in_S0_g128 => S0_in_f128,
				in_S1_g128 => S1_in_f128,
				out_g128 => to_up_pht
				);
		
	-- left rotation by 8
	from_shift_8(31 downto 8) <= low_in_f128(23 downto 0);
	from_shift_8(7 downto 0) <= low_in_f128(31 downto 24);
				
	-- lower g128
	lower_g128: g_128
	port map	(
				in_g128 => from_shift_8,
				in_S0_g128 => S0_in_f128,
				in_S1_g128 => S1_in_f128,
				out_g128 => to_low_pht
				);
					
	-- pht
	pht_transform: pht
	port map	(
				up_in_pht => to_up_pht,
				down_in_pht => to_low_pht,
				up_out_pht => to_up_key,
				down_out_pht => to_low_key
				);
				
	-- upper adder of 32 bits
	up_adder: for i in 0 to 31 generate
		first: if (i=0) generate
			the_adder: adder
			port map	(
						in1_adder => to_up_key(0),
						in2_adder => up_key_f128(0),
						in_carry_adder => zero,
						out_adder => up_out_f128(0),
						out_carry_adder => intermediate_carry1(0)
						);
		end generate first;
		the_rest: if (i>0) generate
			the_adders: adder
			port map	(
						in1_adder => to_up_key(i),
						in2_adder => up_key_f128(i),
						in_carry_adder => intermediate_carry1(i-1),
						out_adder => up_out_f128(i),
						out_carry_adder => intermediate_carry1(i)
						);
		end generate the_rest;
	end generate up_adder;

	-- lower adder of 32 bits
	low_adder: for i in 0 to 31 generate
		first1: if (i=0) generate
			the_adder1:adder
			port map	(
						in1_adder => to_low_key(0),
						in2_adder => low_key_f128(0),
						in_carry_adder => zero,
						out_adder => low_out_f128(0),
						out_carry_adder => intermediate_carry2(0)
						);
		end generate first1;
		the_rest1: if (i>0) generate
			the_adders1: adder
			port map	(
						in1_adder => to_low_key(i),
						in2_adder => low_key_f128(i),
						in_carry_adder => intermediate_carry2(i-1),
						out_adder => low_out_f128(i),
						out_carry_adder => intermediate_carry2(i)
						);
		end generate the_rest1;
	end generate low_adder;

end f128_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish key scheduler for 128 bits key input			   
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_keysched128 is
port	(
		odd_in_tk128,
		even_in_tk128		: in std_logic_vector(7 downto 0);
		in_key_tk128		: in std_logic_vector(127 downto 0);
		out_key_up_tk128,
		out_key_down_tk128			: out std_logic_vector(31 downto 0)
		);
end twofish_keysched128;
				
architecture twofish_keysched128_arch of twofish_keysched128 is

	-- we declare internal signals
	signal	to_up_pht,
			to_shift_8,
			from_shift_8,
			to_shift_9,
			M0, M1, M2, M3	: std_logic_vector(31 downto 0);

	signal	byte0, byte1, byte2, byte3,
			byte4, byte5, byte6, byte7,
			byte8, byte9, byte10, byte11,
			byte12, byte13, byte14, byte15	: std_logic_vector(7 downto 0);
																		   			
	-- we declare the components to be used
	component pht
	port	(
			up_in_pht,
			down_in_pht		: in std_logic_vector(31 downto 0);
			up_out_pht,
			down_out_pht	: out std_logic_vector(31 downto 0)
			);
	end component;

	component h_128 
	port	(
			in_h128			: in std_logic_vector(7 downto 0);
			Mfirst_h128,
			Msecond_h128	: in std_logic_vector(31 downto 0);
			out_h128		: out std_logic_vector(31 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- we assign the input signal to the respective
	-- bytes as is described in the prototype
	byte15 <= in_key_tk128(7 downto 0);
	byte14 <= in_key_tk128(15 downto 8);
	byte13 <= in_key_tk128(23 downto 16);
	byte12 <= in_key_tk128(31 downto 24);
	byte11 <= in_key_tk128(39 downto 32);
	byte10 <= in_key_tk128(47 downto 40);
	byte9 <= in_key_tk128(55 downto 48);
	byte8 <= in_key_tk128(63 downto 56);
	byte7 <= in_key_tk128(71 downto 64);
	byte6 <= in_key_tk128(79 downto 72);
	byte5 <= in_key_tk128(87 downto 80);
	byte4 <= in_key_tk128(95 downto 88);
	byte3 <= in_key_tk128(103 downto 96);
	byte2 <= in_key_tk128(111 downto 104);
	byte1 <= in_key_tk128(119 downto 112);
	byte0 <= in_key_tk128(127 downto 120);

	-- we form the M{0..3}
	M0 <= byte3 & byte2 & byte1 & byte0;
	M1 <= byte7 & byte6 & byte5 & byte4;
	M2 <= byte11 & byte10 & byte9 & byte8;
	M3 <= byte15 & byte14 & byte13 & byte12;

	-- upper h
	upper_h: h_128
	port map	(
				in_h128 => even_in_tk128,
				Mfirst_h128 => M2,
				Msecond_h128 => M0,
				out_h128 => to_up_pht
				);
				
	-- lower h
	lower_h: h_128
	port map	(
				in_h128 => odd_in_tk128,
				Mfirst_h128 => M3,
				Msecond_h128 => M1,
				out_h128 => to_shift_8
				);
				
	-- left rotate by 8
	from_shift_8(31 downto 8) <= to_shift_8(23 downto 0);
	from_shift_8(7 downto 0) <= to_shift_8(31 downto 24);
	
	-- pht transformation
	pht_transform: pht
	port map	(
				up_in_pht => to_up_pht,
				down_in_pht => from_shift_8,
				up_out_pht => out_key_up_tk128,
				down_out_pht => to_shift_9
				);
				
	-- left rotate by 9
	out_key_down_tk128(31 downto 9) <= to_shift_9(22 downto 0);
	out_key_down_tk128(8 downto 0) <= to_shift_9(31 downto 23);

end twofish_keysched128_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish S key component for 128 bits key			   
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_S128 is
port	(
		in_key_ts128		: in std_logic_vector(127 downto 0);
		out_Sfirst_ts128,
		out_Ssecond_ts128			: out std_logic_vector(31 downto 0)
		);
end twofish_S128;
				
architecture twofish_S128_arch of twofish_S128 is
																		   			
	-- we declare the components to be used
	component reed_solomon128 
	port	(
			in_rs128			: in std_logic_vector(127 downto 0);
			out_Sfirst_rs128,
			out_Ssecond_rs128		: out std_logic_vector(31 downto 0)
			);
	end component;
	
	signal twofish_key : std_logic_vector(127 downto 0);
	signal	byte15, byte14, byte13, byte12, byte11, byte10,
			byte9, byte8, byte7, byte6, byte5, byte4,
			byte3, byte2, byte1, byte0 : std_logic_vector(7 downto 0);

-- begin architecture description
begin

	-- splitting the input
	byte15 <= in_key_ts128(7 downto 0);
	byte14 <= in_key_ts128(15 downto 8);
	byte13 <= in_key_ts128(23 downto 16);
	byte12 <= in_key_ts128(31 downto 24);
	byte11 <= in_key_ts128(39 downto 32);
	byte10 <= in_key_ts128(47 downto 40);
	byte9 <= in_key_ts128(55 downto 48);
	byte8 <= in_key_ts128(63 downto 56);
	byte7 <= in_key_ts128(71 downto 64);
	byte6 <= in_key_ts128(79 downto 72);
	byte5 <= in_key_ts128(87 downto 80);
	byte4 <= in_key_ts128(95 downto 88);
	byte3 <= in_key_ts128(103 downto 96);
	byte2 <= in_key_ts128(111 downto 104);
	byte1 <= in_key_ts128(119 downto 112);
	byte0 <= in_key_ts128(127 downto 120);

	-- forming the key
	twofish_key <= byte15 & byte14 & byte13 & byte12 & byte11 & byte10 & byte9 & byte8 & byte7 & 
				byte6 & byte5 & byte4 & byte3 & byte2 & byte1 & byte0;


	-- the keys S0,1
	produce_S0_S1: reed_solomon128
	port map	(
				in_rs128 => twofish_key,
				out_Sfirst_rs128 => out_Sfirst_ts128,
				out_Ssecond_rs128 => out_Ssecond_ts128
				);


end twofish_S128_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish whitening key scheduler for 128 bits key input			   
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_whit_keysched128 is
port	(
		in_key_twk128		: in std_logic_vector(127 downto 0);
		out_K0_twk128,
		out_K1_twk128,
		out_K2_twk128,
		out_K3_twk128,
		out_K4_twk128,
		out_K5_twk128,
		out_K6_twk128,
		out_K7_twk128			: out std_logic_vector(31 downto 0)
		);
end twofish_whit_keysched128;
				
architecture twofish_whit_keysched128_arch of twofish_whit_keysched128 is

	-- we declare internal signals
	signal	to_up_pht_1,
			to_shift_8_1,
			from_shift_8_1,
			to_shift_9_1,
			to_up_pht_2,
			to_shift_8_2,
			from_shift_8_2,
			to_shift_9_2,
			to_up_pht_3,
			to_shift_8_3,
			from_shift_8_3,
			to_shift_9_3,
			to_up_pht_4,
			to_shift_8_4,
			from_shift_8_4,
			to_shift_9_4,
			M0, M1, M2, M3	: std_logic_vector(31 downto 0);

	signal	byte0, byte1, byte2, byte3,
			byte4, byte5, byte6, byte7,
			byte8, byte9, byte10, byte11,
			byte12, byte13, byte14, byte15	: std_logic_vector(7 downto 0);

	signal		zero, one, two, three, four, five, six, seven	: std_logic_vector(7 downto 0);
																		   			
	-- we declare the components to be used
	component pht
	port	(
			up_in_pht,
			down_in_pht		: in std_logic_vector(31 downto 0);
			up_out_pht,
			down_out_pht	: out std_logic_vector(31 downto 0)
			);
	end component;

	component h_128 
	port	(
			in_h128			: in std_logic_vector(7 downto 0);
			Mfirst_h128,
			Msecond_h128	: in std_logic_vector(31 downto 0);
			out_h128		: out std_logic_vector(31 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- we produce the first eight numbers
	zero <= "00000000";
	one <= "00000001";
	two <= "00000010";
	three <= "00000011";
	four <= "00000100";
	five <= "00000101";
	six <= "00000110";
	seven <= "00000111";

	-- we assign the input signal to the respective
	-- bytes as is described in the prototype
	byte15 <= in_key_twk128(7 downto 0);
	byte14 <= in_key_twk128(15 downto 8);
	byte13 <= in_key_twk128(23 downto 16);
	byte12 <= in_key_twk128(31 downto 24);
	byte11 <= in_key_twk128(39 downto 32);
	byte10 <= in_key_twk128(47 downto 40);
	byte9 <= in_key_twk128(55 downto 48);
	byte8 <= in_key_twk128(63 downto 56);
	byte7 <= in_key_twk128(71 downto 64);
	byte6 <= in_key_twk128(79 downto 72);
	byte5 <= in_key_twk128(87 downto 80);
	byte4 <= in_key_twk128(95 downto 88);
	byte3 <= in_key_twk128(103 downto 96);
	byte2 <= in_key_twk128(111 downto 104);
	byte1 <= in_key_twk128(119 downto 112);
	byte0 <= in_key_twk128(127 downto 120);

	-- we form the M{0..3}
	M0 <= byte3 & byte2 & byte1 & byte0;
	M1 <= byte7 & byte6 & byte5 & byte4;
	M2 <= byte11 & byte10 & byte9 & byte8;
	M3 <= byte15 & byte14 & byte13 & byte12;

	-- we produce the keys for the whitening steps
	-- keys K0,1
	-- upper h
	upper_h1: h_128
	port map	(
				in_h128 => zero,
				Mfirst_h128 => M2,
				Msecond_h128 => M0,
				out_h128 => to_up_pht_1
				);
				
	-- lower h
	lower_h1: h_128
	port map	(
				in_h128 => one,
				Mfirst_h128 => M3,
				Msecond_h128 => M1,
				out_h128 => to_shift_8_1
				);
				
	-- left rotate by 8
	from_shift_8_1(31 downto 8) <= to_shift_8_1(23 downto 0);
	from_shift_8_1(7 downto 0) <= to_shift_8_1(31 downto 24);
	
	-- pht transformation
	pht_transform1: pht
	port map	(
				up_in_pht => to_up_pht_1,
				down_in_pht => from_shift_8_1,
				up_out_pht => out_K0_twk128,
				down_out_pht => to_shift_9_1
				);
				
	-- left rotate by 9
	out_K1_twk128(31 downto 9) <= to_shift_9_1(22 downto 0);
	out_K1_twk128(8 downto 0) <= to_shift_9_1(31 downto 23);

	-- keys K2,3
	-- upper h
	upper_h2: h_128
	port map	(
				in_h128 => two,
				Mfirst_h128 => M2,
				Msecond_h128 => M0,
				out_h128 => to_up_pht_2
				);
				
	-- lower h
	lower_h2: h_128
	port map	(
				in_h128 => three,
				Mfirst_h128 => M3,
				Msecond_h128 => M1,
				out_h128 => to_shift_8_2
				);
				
	-- left rotate by 8
	from_shift_8_2(31 downto 8) <= to_shift_8_2(23 downto 0);
	from_shift_8_2(7 downto 0) <= to_shift_8_2(31 downto 24);
	
	-- pht transformation
	pht_transform2: pht
	port map	(
				up_in_pht => to_up_pht_2,
				down_in_pht => from_shift_8_2,
				up_out_pht => out_K2_twk128,
				down_out_pht => to_shift_9_2
				);
				
	-- left rotate by 9
	out_K3_twk128(31 downto 9) <= to_shift_9_2(22 downto 0);
	out_K3_twk128(8 downto 0) <= to_shift_9_2(31 downto 23);

	-- keys K4,5
	-- upper h
	upper_h3: h_128
	port map	(
				in_h128 => four,
				Mfirst_h128 => M2,
				Msecond_h128 => M0,
				out_h128 => to_up_pht_3
				);
				
	-- lower h
	lower_h3: h_128
	port map	(
				in_h128 => five,
				Mfirst_h128 => M3,
				Msecond_h128 => M1,
				out_h128 => to_shift_8_3
				);
				
	-- left rotate by 8
	from_shift_8_3(31 downto 8) <= to_shift_8_3(23 downto 0);
	from_shift_8_3(7 downto 0) <= to_shift_8_3(31 downto 24);
	
	-- pht transformation
	pht_transform3: pht
	port map	(
				up_in_pht => to_up_pht_3,
				down_in_pht => from_shift_8_3,
				up_out_pht => out_K4_twk128,
				down_out_pht => to_shift_9_3
				);
				
	-- left rotate by 9
	out_K5_twk128(31 downto 9) <= to_shift_9_3(22 downto 0);
	out_K5_twk128(8 downto 0) <= to_shift_9_3(31 downto 23);

	-- keys K6,7
	-- upper h
	upper_h4: h_128
	port map	(
				in_h128 => six,
				Mfirst_h128 => M2,
				Msecond_h128 => M0,
				out_h128 => to_up_pht_4
				);
				
	-- lower h
	lower_h4: h_128
	port map	(
				in_h128 => seven,
				Mfirst_h128 => M3,
				Msecond_h128 => M1,
				out_h128 => to_shift_8_4
				);
				
	-- left rotate by 8
	from_shift_8_4(31 downto 8) <= to_shift_8_4(23 downto 0);
	from_shift_8_4(7 downto 0) <= to_shift_8_4(31 downto 24);
	
	-- pht transformation
	pht_transform4: pht
	port map	(
				up_in_pht => to_up_pht_4,
				down_in_pht => from_shift_8_4,
				up_out_pht => out_K6_twk128,
				down_out_pht => to_shift_9_4
				);
				
	-- left rotate by 9
	out_K7_twk128(31 downto 9) <= to_shift_9_4(22 downto 0);
	out_K7_twk128(8 downto 0) <= to_shift_9_4(31 downto 23);

end twofish_whit_keysched128_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish encryption round with 128 bit key input
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_encryption_round128 is
port	(
		in1_ter128,
		in2_ter128,
		in3_ter128,
		in4_ter128,
		in_Sfirst_ter128,
		in_Ssecond_ter128,
		in_key_up_ter128,
		in_key_down_ter128		: in std_logic_vector(31 downto 0);
		out1_ter128,
		out2_ter128,
		out3_ter128,
		out4_ter128			: out std_logic_vector(31 downto 0)
		);
end twofish_encryption_round128;

architecture twofish_encryption_round128_arch of twofish_encryption_round128 is
					   
	-- we declare internal signals
	signal	to_left_shift,
			from_right_shift,
			to_xor_with3,
			to_xor_with4			: std_logic_vector(31 downto 0);
			
	component f_128
	port	(
			up_in_f128,
			low_in_f128,
			S0_in_f128,
			S1_in_f128,
			up_key_f128,
			low_key_f128			: in std_logic_vector(31 downto 0);
			up_out_f128,
			low_out_f128			: out std_logic_vector(31 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- we declare f_128
	function_f: f_128
	port map	(
				up_in_f128 => in1_ter128,
				low_in_f128 => in2_ter128,
				S0_in_f128 => in_Sfirst_ter128,	
				S1_in_f128 => in_Ssecond_ter128,
				up_key_f128 => in_key_up_ter128,
				low_key_f128 => in_key_down_ter128,
				up_out_f128 => to_xor_with3,
				low_out_f128 => to_xor_with4
				);
	
	-- we perform the exchange
	-- in1_ter128 -> out3_ter128
	-- in2_ter128 -> out4_ter128
	-- in3_ter128 -> out1_ter128
	-- in4_ter128 -> out2_ter128	
	
	-- we perform the left xor between the upper f function and
	-- the third input (input 3)
	to_left_shift <= to_xor_with3 XOR in3_ter128;
	
	-- we perform the left side rotation to the right by 1 and
	-- we perform the exchange too
	out1_ter128(30 downto 0) <= to_left_shift(31 downto 1);
	out1_ter128(31) <= to_left_shift(0);
	
	-- we perform the right side rotation to the left by 1
	from_right_shift(0) <= in4_ter128(31);
	from_right_shift(31 downto 1) <= in4_ter128(30 downto 0);
	
	-- we perform the right xor between the lower f function and 
	-- the fourth input (input 4)
	out2_ter128 <= from_right_shift XOR to_xor_with4;
	
	-- we perform the last exchanges
	out3_ter128 <= in1_ter128;
	out4_ter128 <= in2_ter128;

end twofish_encryption_round128_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish decryption round with 128 bit key input
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_decryption_round128 is
port	(
		in1_tdr128,
		in2_tdr128,
		in3_tdr128,
		in4_tdr128,
		in_Sfirst_tdr128,
		in_Ssecond_tdr128,
		in_key_up_tdr128,
		in_key_down_tdr128	: in std_logic_vector(31 downto 0);
		out1_tdr128,
		out2_tdr128,
		out3_tdr128,
		out4_tdr128			: out std_logic_vector(31 downto 0)
		);
end twofish_decryption_round128;

architecture twofish_decryption_round128_arch of twofish_decryption_round128 is

	signal	to_xor_with3,
			to_xor_with4,
			to_xor_with_up_f,
			from_xor_with_down_f	: std_logic_vector(31 downto 0);

	component f_128 
	port	(
			up_in_f128,
			low_in_f128,
			S0_in_f128,
			S1_in_f128,
			up_key_f128,
			low_key_f128	: in std_logic_vector(31 downto 0);
			up_out_f128,
			low_out_f128		: out std_logic_vector(31 downto 0)
			);
	end component;

begin

	-- we instantiate f function
	function_f: f_128
	port map	(
				up_in_f128 => in1_tdr128,
				low_in_f128 => in2_tdr128,
				S0_in_f128 => in_Sfirst_tdr128,
				S1_in_f128 => in_Ssecond_tdr128,
				up_key_f128 => in_key_up_tdr128,
				low_key_f128 => in_key_down_tdr128,
				up_out_f128 => to_xor_with3,
				low_out_f128 => to_xor_with4
				);
				
	-- output 1: input3 with upper f
	-- we first rotate the input3 by 1 bit leftwise
	to_xor_with_up_f(0) <= in3_tdr128(31);
	to_xor_with_up_f(31 downto 1) <= in3_tdr128(30 downto 0);
	
	-- we perform the XOR with the upper output of f and the result
	-- is ouput 1
	out1_tdr128 <= to_xor_with_up_f XOR to_xor_with3;
	
	-- output 2: input4 with lower f
	-- we perform the XOR with the lower output of f
	from_xor_with_down_f <= in4_tdr128 XOR to_xor_with4;
	
	-- we perform the rotation by 1 bit rightwise and the result 
	-- is output2
	out2_tdr128(31) <= from_xor_with_down_f(0);
	out2_tdr128(30 downto 0) <= from_xor_with_down_f(31 downto 1);
	
	-- we assign outputs 3 and 4
	out3_tdr128 <= in1_tdr128;
	out4_tdr128 <= in2_tdr128;

end twofish_decryption_round128_arch;

-- ============================================== --
-- ============================================== --
--												  --
-- third part: 192 key input dependent components --
--												  --
-- ============================================== --
-- ============================================== --

-- 					
--	reed solomon	for 192bits key
--					

library ieee;
use ieee.std_logic_1164.all;

entity reed_solomon192 is
port	(
		in_rs192			: in std_logic_vector(191 downto 0);
		out_Sfirst_rs192,
		out_Ssecond_rs192,
		out_Sthird_rs192		: out std_logic_vector(31 downto 0)	
		);
end reed_solomon192;

architecture rs_192_arch of reed_solomon192 is

	-- declaring all components necessary for reed solomon
	-- 01
	component mul01
	port	(
			in_mul01	: in std_logic_vector(7 downto 0);
			out_mul01	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- a4	
	component mula4 
	port	(
			in_mula4	: in std_logic_vector(7 downto 0);			
			out_mula4	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 55
	component mul55 
	port	(
			in_mul55	: in std_logic_vector(7 downto 0);
			out_mul55	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 87
	component mul87 
	port	(
			in_mul87	: in std_logic_vector(7 downto 0);
			out_mul87	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 5a
	component mul5a 
	port	(
			in_mul5a	: in std_logic_vector(7 downto 0);
			out_mul5a	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 58
	component mul58 
	port	(
			in_mul58	: in std_logic_vector(7 downto 0);
			out_mul58	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- db
	component muldb 
	port	(
			in_muldb	: in std_logic_vector(7 downto 0);
			out_muldb	: out std_logic_vector(7 downto 0)
			);
	end component;

	
	-- 9e
	component mul9e 
	port	(
			in_mul9e	: in std_logic_vector(7 downto 0);
			out_mul9e	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 56
	component mul56 
	port	(
			in_mul56	: in std_logic_vector(7 downto 0);
			out_mul56	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 82
	component mul82 
	port	(
			in_mul82	: in std_logic_vector(7 downto 0);
			out_mul82	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- f3
	component mulf3 
	port	(
			in_mulf3	: in std_logic_vector(7 downto 0);
			out_mulf3	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 1e
	component mul1e 
	port	(
			in_mul1e	: in std_logic_vector(7 downto 0);
			out_mul1e	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- c6
	component mulc6 
	port	(
			in_mulc6	: in std_logic_vector(7 downto 0);
			out_mulc6	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 68
	component mul68 
	port	(
			in_mul68	: in std_logic_vector(7 downto 0);
			out_mul68	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- e5
	component mule5 
	port	(
			in_mule5	: in std_logic_vector(7 downto 0);
			out_mule5	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 02
	component mul02 
	port	(
			in_mul02	: in std_logic_vector(7 downto 0);
			out_mul02	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- a1
	component mula1 
	port	(
			in_mula1	: in std_logic_vector(7 downto 0);
			out_mula1	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- fc
	component mulfc 
	port	(
			in_mulfc	: in std_logic_vector(7 downto 0);
			out_mulfc	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- c1
	component mulc1 
	port	(
			in_mulc1	: in std_logic_vector(7 downto 0);
			out_mulc1	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 47
	component mul47 
	port	(
			in_mul47	: in std_logic_vector(7 downto 0);
			out_mul47	: out std_logic_vector(7 downto 0)	
			);
	end component;



	-- ae
	component mulae 
	port	(
			in_mulae	: in std_logic_vector(7 downto 0);
			out_mulae	: out std_logic_vector(7 downto 0)
			);
	end component;



	-- 3d
	component mul3d 
	port	(
			in_mul3d	: in std_logic_vector(7 downto 0);
			out_mul3d	: out std_logic_vector(7 downto 0)
			);
	end component;



	-- 19
	component mul19 
	port	(
			in_mul19	: in std_logic_vector(7 downto 0);
			out_mul19	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 03
	component mul03 
	port	(
			in_mul03	: in std_logic_vector(7 downto 0);
			out_mul03	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- declaring internal signals
	signal	m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,
			m16, m17, m18, m19, m20, m21, m22, m23		: std_logic_vector(7 downto 0);	
	signal 	s00,s01,s02,s03,s10,s11,s12,s13, s20, s21, s22, s23								: std_logic_vector(7 downto 0);	
	signal	m0_01,m1_a4,m2_55,m3_87,m4_5a,m5_58,m6_db,m7_9e,
			m0_a4,m1_56,m2_82,m3_f3,m4_1e,m5_c6,m6_68,m7_e5,
			m0_02,m1_a1,m2_fc,m3_c1,m4_47,m5_ae,m6_3d,m7_19,
			m0_a4_1,m1_55,m2_87,m3_5a,m4_58,m5_db,m6_9e,m7_03			: std_logic_vector(7 downto 0);	
	signal	m8_01,m9_a4,m10_55,m11_87,m12_5a,m13_58,m14_db,m15_9e,
			m8_a4,m9_56,m10_82,m11_f3,m12_1e,m13_c6,m14_68,m15_e5,
			m8_02,m9_a1,m10_fc,m11_c1,m12_47,m13_ae,m14_3d,m15_19,
			m8_a4_1,m9_55,m10_87,m11_5a,m12_58,m13_db,m14_9e,m15_03		: std_logic_vector(7 downto 0);	
	signal	m16_01,m17_a4,m18_55,m19_87,m20_5a,m21_58,m22_db,m23_9e,
			m16_a4,m17_56,m18_82,m19_f3,m20_1e,m21_c6,m22_68,m23_e5,
			m16_02,m17_a1,m18_fc,m19_c1,m20_47,m21_ae,m22_3d,m23_19,
			m16_a4_1,m17_55,m18_87,m19_5a,m20_58,m21_db,m22_9e,m23_03		: std_logic_vector(7 downto 0);	


-- begin architecture description
begin

	-- first, we separate the input to the respective m
	-- for s0j  j=0..3
	m0 <= in_rs192(7 downto 0);
	m1 <= in_rs192(15 downto 8);
	m2 <= in_rs192(23 downto 16);
	m3 <= in_rs192(31 downto 24);
	m4 <= in_rs192(39 downto 32);
	m5 <= in_rs192(47 downto 40);
	m6 <= in_rs192(55 downto 48);
	m7 <= in_rs192(63 downto 56);

	-- for s1j  j=0..3
	m8 <= in_rs192(71 downto 64);
	m9 <= in_rs192(79 downto 72);
	m10 <= in_rs192(87 downto 80);
	m11 <= in_rs192(95 downto 88);
	m12 <= in_rs192(103 downto 96);
	m13 <= in_rs192(111 downto 104);
	m14 <= in_rs192(119 downto 112);
	m15 <= in_rs192(127 downto 120);

	-- for s2j  j=0..3
	m16 <= in_rs192(135 downto 128);
	m17 <= in_rs192(143 downto 136);
	m18 <= in_rs192(151 downto 144);
	m19 <= in_rs192(159 downto 152);
	m20 <= in_rs192(167 downto 160);
	m21 <= in_rs192(175 downto 168);
	m22 <= in_rs192(183 downto 176);
	m23 <= in_rs192(191 downto 184);


	-- after separating signals, we drive them to multipliers
	-- the first line of m0..7 forms s00
	m0_with_01: mul01
	port map	(
				in_mul01 => m0,
				out_mul01 => m0_01
				);

	m1_with_a4: mula4
	port map	(
				in_mula4 => m1,
				out_mula4 => m1_a4
				);

	m2_with_55: mul55
	port map	(
				in_mul55 => m2,
				out_mul55 => m2_55
				);

	m3_with_87: mul87
	port map	(
				in_mul87 => m3,
				out_mul87 => m3_87
				);

	m4_with_5a: mul5a
	port map	(
				in_mul5a => m4,
				out_mul5a => m4_5a
				);

	m5_with_58: mul58
	port map	(
				in_mul58 => m5,
				out_mul58 => m5_58
				);

	m6_with_db: muldb
	port map	(
				in_muldb => m6,
				out_muldb => m6_db
				);

	m7_with_9e: mul9e
	port map	(
				in_mul9e => m7,
				out_mul9e => m7_9e
				);

	-- the second row creates s01
	m0_with_a4: mula4
	port map	(
				in_mula4 => m0,
				out_mula4 => m0_a4
				);

	m1_with_56: mul56
	port map	(
				in_mul56 => m1,
				out_mul56 => m1_56
				);

	m2_with_82: mul82
	port map	(
				in_mul82 => m2,
				out_mul82 => m2_82
				);
	
	m3_with_f3: mulf3
	port map	(
				in_mulf3 => m3,
				out_mulf3 => m3_f3
				);

	m4_with_1e: mul1e
	port map	(
				in_mul1e => m4,
				out_mul1e => m4_1e
				);

	m5_with_c6: mulc6
	port map	(
				in_mulc6 => m5,
				out_mulc6 => m5_c6
				);

	m6_with_68: mul68
	port map	(
				in_mul68 => m6,
				out_mul68 => m6_68
				);

	m7_with_e5: mule5
	port map	(
				in_mule5 => m7,
				out_mule5 => m7_e5
				);

	-- the third row creates s02
	m0_with_02: mul02
	port map	(
				in_mul02 => m0,
				out_mul02 => m0_02
				);

	m1_with_a1: mula1
	port map	(
				in_mula1 => m1,
				out_mula1 => m1_a1
				);

	m2_with_fc: mulfc
	port map	(
				in_mulfc => m2,
				out_mulfc => m2_fc
				);

	m3_with_c1: mulc1
	port map	(
				in_mulc1 => m3,
				out_mulc1 => m3_c1
				);

	m4_with_47: mul47
	port map	(
				in_mul47 => m4,
				out_mul47 => m4_47
				);

	m5_with_ae: mulae
	port map	(
				in_mulae => m5,
				out_mulae => m5_ae
				);

	m6_with_3d: mul3d
	port map	(
				in_mul3d => m6,
				out_mul3d => m6_3d
				);

	m7_with_19: mul19
	port map	(
				in_mul19 => m7,
				out_mul19 => m7_19
				);

	-- the fourth row creates s03
	m0_with_a4_1: mula4
	port map	(
				in_mula4 => m0,
				out_mula4 => m0_a4_1
				);

	m1_with_55: mul55
	port map	(
				in_mul55 => m1,
				out_mul55 => m1_55
				);

	m2_with_87: mul87
	port map	(
				in_mul87 => m2,
				out_mul87 => m2_87
				);

	m3_with_5a: mul5a
	port map	(
				in_mul5a => m3,
				out_mul5a => m3_5a
				);

	m4_with_58: mul58
	port map	(
				in_mul58 => m4,
				out_mul58 => m4_58
				);

	m5_with_db: muldb
	port map	(
				in_muldb => m5,
				out_muldb => m5_db
				);

	m6_with_9e: mul9e
	port map	(
				in_mul9e => m6,
				out_mul9e => m6_9e
				);

	m7_with_03: mul03
	port map	(
				in_mul03 => m7,
				out_mul03 => m7_03
				);


	-- we create the s1,j j=0..3
	-- the first row of m8..15 creates the s10
	m8_with_01: mul01
	port map	(
				in_mul01 => m8,
				out_mul01 => m8_01
				);

	m9_with_a4: mula4
	port map	(
				in_mula4 => m9,
				out_mula4 => m9_a4
				);

	m10_with_55: mul55
	port map	(
				in_mul55 => m10,
				out_mul55 => m10_55
				);

	m11_with_87: mul87
	port map	(
				in_mul87 => m11,
				out_mul87 => m11_87
				);

	m12_with_5a: mul5a
	port map	(
				in_mul5a => m12,
				out_mul5a => m12_5a
				);

	m13_with_58: mul58
	port map	(
				in_mul58 => m13,
				out_mul58 => m13_58
				);

	m14_with_db: muldb
	port map	(
				in_muldb => m14,
				out_muldb => m14_db
				);

	m15_with_9e: mul9e
	port map	(
				in_mul9e => m15,
				out_mul9e => m15_9e
				);

	-- the second row creates s11
	m8_with_a4: mula4
	port map	(
				in_mula4 => m8,
				out_mula4 => m8_a4
				);

	m9_with_56: mul56
	port map	(
				in_mul56 => m9,
				out_mul56 => m9_56
				);

	m10_with_82: mul82
	port map	(
				in_mul82 => m10,
				out_mul82 => m10_82
				);
	
	m11_with_f3: mulf3
	port map	(
				in_mulf3 => m11,
				out_mulf3 => m11_f3
				);

	m12_with_1e: mul1e
	port map	(
				in_mul1e => m12,
				out_mul1e => m12_1e
				);

	m13_with_c6: mulc6
	port map	(
				in_mulc6 => m13,
				out_mulc6 => m13_c6
				);

	m14_with_68: mul68
	port map	(
				in_mul68 => m14,
				out_mul68 => m14_68
				);

	m15_with_e5: mule5
	port map	(
				in_mule5 => m15,
				out_mule5 => m15_e5
				);

	-- the third row creates s12
	m8_with_02: mul02
	port map	(
				in_mul02 => m8,
				out_mul02 => m8_02
				);

	m9_with_a1: mula1
	port map	(
				in_mula1 => m9,
				out_mula1 => m9_a1
				);

	m10_with_fc: mulfc
	port map	(
				in_mulfc => m10,
				out_mulfc => m10_fc
				);

	m11_with_c1: mulc1
	port map	(
				in_mulc1 => m11,
				out_mulc1 => m11_c1
				);

	m12_with_47: mul47
	port map	(
				in_mul47 => m12,
				out_mul47 => m12_47
				);

	m13_with_ae: mulae
	port map	(
				in_mulae => m13,
				out_mulae => m13_ae
				);

	m14_with_3d: mul3d
	port map	(
				in_mul3d => m14,
				out_mul3d => m14_3d
				);

	m15_with_19: mul19
	port map	(
				in_mul19 => m15,
				out_mul19 => m15_19
				);

	-- the fourth row creates s13
	m8_with_a4_1: mula4
	port map	(
				in_mula4 => m8,
				out_mula4 => m8_a4_1
				);

	m9_with_55: mul55
	port map	(
				in_mul55 => m9,
				out_mul55 => m9_55
				);

	m10_with_87: mul87
	port map	(
				in_mul87 => m10,
				out_mul87 => m10_87
				);

	m11_with_5a: mul5a
	port map	(
				in_mul5a => m11,
				out_mul5a => m11_5a
				);

	m12_with_58: mul58
	port map	(
				in_mul58 => m12,
				out_mul58 => m12_58
				);

	m13_with_db: muldb
	port map	(
				in_muldb => m13,
				out_muldb => m13_db
				);

	m14_with_9e: mul9e
	port map	(
				in_mul9e => m14,
				out_mul9e => m14_9e
				);

	m15_with_03: mul03
	port map	(
				in_mul03 => m15,
				out_mul03 => m15_03
				);

	-- we create the s2,j j=0..3
	-- the first row of m16..23 creates the s20
	m16_with_01: mul01
	port map	(
				in_mul01 => m16,
				out_mul01 => m16_01
				);

	m17_with_a4: mula4
	port map	(
				in_mula4 => m17,
				out_mula4 => m17_a4
				);

	m18_with_55: mul55
	port map	(
				in_mul55 => m18,
				out_mul55 => m18_55
				);

	m19_with_87: mul87
	port map	(
				in_mul87 => m19,
				out_mul87 => m19_87
				);

	m20_with_5a: mul5a
	port map	(
				in_mul5a => m20,
				out_mul5a => m20_5a
				);

	m21_with_58: mul58
	port map	(
				in_mul58 => m21,
				out_mul58 => m21_58
				);

	m22_with_db: muldb
	port map	(
				in_muldb => m22,
				out_muldb => m22_db
				);

	m23_with_9e: mul9e
	port map	(
				in_mul9e => m23,
				out_mul9e => m23_9e
				);

	-- the second row creates s21
	m16_with_a4: mula4
	port map	(
				in_mula4 => m16,
				out_mula4 => m16_a4
				);

	m17_with_56: mul56
	port map	(
				in_mul56 => m17,
				out_mul56 => m17_56
				);

	m18_with_82: mul82
	port map	(
				in_mul82 => m18,
				out_mul82 => m18_82
				);
	
	m19_with_f3: mulf3
	port map	(
				in_mulf3 => m19,
				out_mulf3 => m19_f3
				);

	m20_with_1e: mul1e
	port map	(
				in_mul1e => m20,
				out_mul1e => m20_1e
				);

	m21_with_c6: mulc6
	port map	(
				in_mulc6 => m21,
				out_mulc6 => m21_c6
				);

	m22_with_68: mul68
	port map	(
				in_mul68 => m22,
				out_mul68 => m22_68
				);

	m23_with_e5: mule5
	port map	(
				in_mule5 => m23,
				out_mule5 => m23_e5
				);

	-- the third row creates s22
	m16_with_02: mul02
	port map	(
				in_mul02 => m16,
				out_mul02 => m16_02
				);

	m17_with_a1: mula1
	port map	(
				in_mula1 => m17,
				out_mula1 => m17_a1
				);

	m18_with_fc: mulfc
	port map	(
				in_mulfc => m18,
				out_mulfc => m18_fc
				);

	m19_with_c1: mulc1
	port map	(
				in_mulc1 => m19,
				out_mulc1 => m19_c1
				);

	m20_with_47: mul47
	port map	(
				in_mul47 => m20,
				out_mul47 => m20_47
				);

	m21_with_ae: mulae
	port map	(
				in_mulae => m21,
				out_mulae => m21_ae
				);

	m22_with_3d: mul3d
	port map	(
				in_mul3d => m22,
				out_mul3d => m22_3d
				);

	m23_with_19: mul19
	port map	(
				in_mul19 => m23,
				out_mul19 => m23_19
				);

	-- the fourth row creates s23
	m16_with_a4_1: mula4
	port map	(
				in_mula4 => m16,
				out_mula4 => m16_a4_1
				);

	m17_with_55: mul55
	port map	(
				in_mul55 => m17,
				out_mul55 => m17_55
				);

	m18_with_87: mul87
	port map	(
				in_mul87 => m18,
				out_mul87 => m18_87
				);

	m19_with_5a: mul5a
	port map	(
				in_mul5a => m19,
				out_mul5a => m19_5a
				);

	m20_with_58: mul58
	port map	(
				in_mul58 => m20,
				out_mul58 => m20_58
				);

	m21_with_db: muldb
	port map	(
				in_muldb => m21,
				out_muldb => m21_db
				);

	m22_with_9e: mul9e
	port map	(
				in_mul9e => m22,
				out_mul9e => m22_9e
				);

	m23_with_03: mul03
	port map	(
				in_mul03 => m23,
				out_mul03 => m23_03
				);

	-- after getting the results from multipliers
	-- we combine them in order to get the additions
	s00 <= m0_01 XOR m1_a4 XOR m2_55 XOR m3_87 XOR m4_5a XOR m5_58 XOR m6_db XOR m7_9e;
	s01 <= m0_a4 XOR m1_56 XOR m2_82 XOR m3_f3 XOR m4_1e XOR m5_c6 XOR m6_68 XOR m7_e5;
	s02 <= m0_02 XOR m1_a1 XOR m2_fc XOR m3_c1 XOR m4_47 XOR m5_ae XOR m6_3d XOR m7_19;
	s03 <= m0_a4_1 XOR m1_55 XOR m2_87 XOR m3_5a XOR m4_58 XOR m5_db XOR m6_9e XOR m7_03;

	-- after creating s0,j j=0...3 we form the S0
	-- little endian 
	out_Sfirst_rs192 <= s03 & s02 & s01 & s00;

	s10 <= m8_01 XOR m9_a4 XOR m10_55 XOR m11_87 XOR m12_5a XOR m13_58 XOR m14_db XOR m15_9e;
	s11 <= m8_a4 XOR m9_56 XOR m10_82 XOR m11_f3 XOR m12_1e XOR m13_c6 XOR m14_68 XOR m15_e5;
	s12 <= m8_02 XOR m9_a1 XOR m10_fc XOR m11_c1 XOR m12_47 XOR m13_ae XOR m14_3d XOR m15_19;
	s13 <= m8_a4_1 XOR m9_55 XOR m10_87 XOR m11_5a XOR m12_58 XOR m13_db XOR m14_9e XOR m15_03;

	-- after creating s1,j j=0...3 we form the S1
	-- little endian
	out_Ssecond_rs192 <= s13 & s12 & s11 & s10;

	s20 <= m16_01 XOR m17_a4 XOR m18_55 XOR m19_87 XOR m20_5a XOR m21_58 XOR m22_db XOR m23_9e;
	s21 <= m16_a4 XOR m17_56 XOR m18_82 XOR m19_f3 XOR m20_1e XOR m21_c6 XOR m22_68 XOR m23_e5;
	s22 <= m16_02 XOR m17_a1 XOR m18_fc XOR m19_c1 XOR m20_47 XOR m21_ae XOR m22_3d XOR m23_19;
	s23 <= m16_a4_1 XOR m17_55 XOR m18_87 XOR m19_5a XOR m20_58 XOR m21_db XOR m22_9e XOR m23_03;

 	-- after creating s2j j=0...3 we form the S2
	-- little endian
	out_Sthird_rs192 <= s23 & s22 & s21 & s20;


end rs_192_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- h function for 192 bits key
-- 

library ieee;
use ieee.std_logic_1164.all;

entity h_192 is
port	(
		in_h192		: in std_logic_vector(7 downto 0);
		Mfirst_h192,
		Msecond_h192,
		Mthird_h192	: in std_logic_vector(31 downto 0);
		out_h192		: out std_logic_vector(31 downto 0)
		);
end h_192;

architecture h192_arch of h_192 is

	-- we declare internal signals
	signal	from_first_row,
			to_second_row,
			from_second_row,
			to_third_row,
			from_third_row,
			to_fourth_row,
			to_mds			: std_logic_vector(31 downto 0);
					
	-- we declare all components needed 				   
	component q0
	port	(			   
			in_q0 	: in std_logic_vector(7 downto 0);
			out_q0	: out std_logic_vector(7 downto 0)
			);
	end component;
	
	component q1
	port	(
			in_q1 	: in std_logic_vector(7 downto 0);
			out_q1	: out std_logic_vector(7 downto 0)
			);
	end component;

	component mds
	port	(
			y0,
			y1,
			y2,
			y3	: in std_logic_vector(7 downto 0);
			z0,
			z1,
			z2,
			z3	: out std_logic_vector(7 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- first row of q
	first_q1_1: q1
	port map	(
				in_q1 => in_h192,
				out_q1 => from_first_row(7 downto 0)
				);

	first_q1_2: q1
	port map	(
				in_q1 => in_h192,
				out_q1 => from_first_row(15 downto 8)
				);

	first_q0_1: q0
	port map	(
				in_q0 => in_h192,
				out_q0 => from_first_row(23 downto 16)
				);

	first_q0_2: q0
	port map	(
				in_q0 => in_h192,
				out_q0 => from_first_row(31 downto 24)
				);

	-- we perform the XOR of the results of the first row
	-- with first M of h (Mfirst_h128)
	to_second_row <= from_first_row XOR Mfirst_h192;

	-- second row of q
	second_q0_1: q0
	port map	(
				in_q0 => to_second_row(7 downto 0),
				out_q0 => from_second_row(7 downto 0)
				);
	second_q1_1: q1
	port map	(
				in_q1 => to_second_row(15 downto 8),
				out_q1 => from_second_row(15 downto 8)
				);
	second_q0_2: q0
	port map	(
				in_q0 => to_second_row(23 downto 16),
				out_q0 => from_second_row(23 downto 16)
				);
	second_q1_2: q1
	port map	(
				in_q1 => to_second_row(31 downto 24),
				out_q1 => from_second_row(31 downto 24)
				);

	-- we perform the XOR of the results of the second row
	-- with second M of h (Msecond_h128)
	to_third_row <= from_second_row XOR Msecond_h192;

	-- third row of q
	third_q0_1: q0
	port map	(
				in_q0 => to_third_row(7 downto 0),
				out_q0 => from_third_row(7 downto 0)
				);
	third_q0_2: q0
	port map	(
				in_q0 => to_third_row(15 downto 8),
				out_q0 => from_third_row(15 downto 8)
				);
	third_q1_1: q1
	port map	(
				in_q1 => to_third_row(23 downto 16),
				out_q1 => from_third_row(23 downto 16)
				);
	third_q1_2: q1
	port map	(
				in_q1 => to_third_row(31 downto 24),
				out_q1 => from_third_row(31 downto 24)
				);
				
	-- we perform the third XOR
	to_fourth_row <= from_third_row XOR Mthird_h192;
	
	-- the fourth row of q
	fourth_q1_1: q1
	port map	(
				in_q1 => to_fourth_row(7 downto 0),
				out_q1 => to_mds(7 downto 0)
				);
	fourth_q0_1: q0
	port map	(
				in_q0 => to_fourth_row(15 downto 8),
				out_q0 => to_mds(15 downto 8)
				);
	fourth_q1_2: q1
	port map	(
				in_q1 => to_fourth_row(23 downto 16),
				out_q1 => to_mds(23 downto 16)
				);
	fourth_q0_2: q0
	port map	(
				in_q0 => to_fourth_row(31 downto 24),
				out_q0 => to_mds(31 downto 24)
				);
				
	-- mds table
	mds_table: mds
	port map	(
				y0 => to_mds(7 downto 0),
				y1 => to_mds(15 downto 8),
				y2 => to_mds(23 downto 16),
				y3 => to_mds(31 downto 24),
				z0 => out_h192(7 downto 0),
				z1 => out_h192(15 downto 8),
				z2 => out_h192(23 downto 16),
				z3 => out_h192(31 downto 24)
				);

end h192_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


--
-- g function for 192 bits key
-- 

library ieee;
use ieee.std_logic_1164.all;

entity g_192 is
port	(
		in_g192,
		in_S0_g192,
		in_S1_g192,
		in_S2_g192		: in std_logic_vector(31 downto 0);
		out_g192		: out std_logic_vector(31 downto 0)
		);
end g_192;

architecture g192_arch of g_192 is

	-- we declare the internal signals
	signal	from_first_row,
			to_second_row,
			from_second_row,
			to_third_row,
			from_third_row,
			to_fourth_row,
			to_mds			: std_logic_vector(31 downto 0);

	component q0
	port	(
			in_q0 	: in std_logic_vector(7 downto 0);
			out_q0	: out std_logic_vector(7 downto 0)
			);
	end component;
	
	component q1
	port	(
			in_q1 	: in std_logic_vector(7 downto 0);
			out_q1	: out std_logic_vector(7 downto 0)
			);
	end component;

	component mds
	port	(
			y0,
			y1,
			y2,
			y3	: in std_logic_vector(7 downto 0);
			z0,
			z1,
			z2,
			z3	: out std_logic_vector(7 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- first row of q
	first_q1_1: q1
	port map	(
				in_q1 => in_g192(7 downto 0),
				out_q1 => from_first_row(7 downto 0)
				);
	first_q1_2: q1
	port map	(
				in_q1 => in_g192(15 downto 8),
				out_q1 => from_first_row(15 downto 8)
				);
	first_q0_1: q0
	port map	(
				in_q0 => in_g192(23 downto 16),
				out_q0 => from_first_row(23 downto 16)
				);
	first_q0_2: q0
	port map	(
				in_q0 => in_g192(31 downto 24),
				out_q0 => from_first_row(31 downto 24)
				);

	-- we XOR the result of the first row
	-- with the S0
	to_second_row <= from_first_row XOR in_S0_g192;

	-- second row of q
	second_q0_1: q0
	port map	(
				in_q0 => to_second_row(7 downto 0),
				out_q0 => from_second_row(7 downto 0)
				);
	second_q1_1: q1
	port map	(
				in_q1 => to_second_row(15 downto 8),
				out_q1 => from_second_row(15 downto 8)
				);
	second_q0_2: q0
	port map	(
				in_q0 => to_second_row(23 downto 16),
				out_q0 => from_second_row(23 downto 16)
				);
	second_q1_2: q1
	port map	(
				in_q1 => to_second_row(31 downto 24),
				out_q1 => from_second_row(31 downto 24)
				);
				
	-- we perform the XOR
	to_third_row <= from_second_row XOR in_S1_g192;
	
	-- third row of q
	third_q0_1: q0
	port map	(
				in_q0 => to_third_row(7 downto 0),
				out_q0 => from_third_row(7 downto 0)
				);
	third_q0_2: q0
	port map	(
				in_q0 => to_third_row(15 downto 8),
				out_q0 => from_third_row(15 downto 8)
				);
	third_q1_1: q1
	port map	(
				in_q1 => to_third_row(23 downto 16),
				out_q1 => from_third_row(23 downto 16)
				);
	third_q1_2: q1
	port map	(
				in_q1 => to_third_row(31 downto 24),
				out_q1 => from_third_row(31 downto 24)
				);

	-- we perform the XOR
	to_fourth_row <= from_third_row XOR in_S2_g192;
		
	-- fourth row of q
	fourth_q1_1: q1
	port map	(
				in_q1=> to_fourth_row(7 downto 0),
				out_q1 => to_mds(7 downto 0)
				);
	fourth_q0_1: q0
	port map	(
				in_q0 => to_fourth_row(15 downto 8),
				out_q0 => to_mds(15 downto 8)
				);
	fourth_q1_2: q1
	port map	(
				in_q1 => to_fourth_row(23 downto 16),
				out_q1 => to_mds(23 downto 16)
				);
	fourth_q0_2: q0
	port map	(
				in_q0 => to_fourth_row(31 downto 24),
				out_q0 => to_mds(31 downto 24)
				);
		
	-- mds table 
	mds_table: mds
	port map	(
				y0 => to_mds(7 downto 0),
				y1 => to_mds(15 downto 8),
				y2 => to_mds(23 downto 16),
				y3 => to_mds(31 downto 24),
				z0 => out_g192(7 downto 0),
				z1 => out_g192(15 downto 8),
				z2 => out_g192(23 downto 16),
				z3 => out_g192(31 downto 24)
				);

end g192_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


--
-- f function with 192 bits key
-- 

library ieee;
use ieee.std_logic_1164.all;

entity f_192 is
port	(
		up_in_f192,
		low_in_f192,
		S0_in_f192,
		S1_in_f192,
		S2_in_f192,
		up_key_f192,
		low_key_f192		: in std_logic_vector(31 downto 0);
		up_out_f192,
		low_out_f192		: out std_logic_vector(31 downto 0)
		);
end f_192;

architecture f192_arch of f_192 is

	-- we declare the internal signals 
	signal	from_shift_8,
			to_up_pht,
			to_low_pht,
			to_up_key,
			to_low_key,
			intermediate_carry1,
			intermediate_carry2	: std_logic_vector(31 downto 0);
	signal	zero					: std_logic;
	
	
	component g_192
	port	(
			in_g192,
			in_S0_g192,
			in_S1_g192,
			in_S2_g192	: in std_logic_vector(31 downto 0);
			out_g192		: out std_logic_vector(31 downto 0)
			);
	end component;
	
	component pht
	port	(
			up_in_pht,
			down_in_pht	: in std_logic_vector(31 downto 0);
			up_out_pht,
			down_out_pht	: out std_logic_vector(31 downto 0)
			);
	end component;

	component adder
	port	(
			in1_adder,
			in2_adder,
			in_carry_adder	: in std_logic;
			out_adder,
			out_carry_adder	: out std_logic
			);
	end component;

-- begin architecture description
begin

	-- we initialize zero
	zero <= '0';
	
	-- upper g_192
	upper_g192: g_192
	port map	(
				in_g192 => up_in_f192,
				in_S0_g192 => S0_in_f192,
				in_S1_g192 => S1_in_f192,
				in_S2_g192 => S2_in_f192,
				out_g192 => to_up_pht
				);
		
	-- left rotation by 8
	from_shift_8(31 downto 8) <= low_in_f192(23 downto 0);
	from_shift_8(7 downto 0) <= low_in_f192(31 downto 24);
				
	-- lower g192
	lower_g192: g_192
	port map	(
				in_g192 => from_shift_8,
				in_S0_g192 => S0_in_f192,
				in_S1_g192 => S1_in_f192,
				in_S2_g192 => S2_in_f192,
				out_g192 => to_low_pht
				);
					
	-- pht
	pht_transform: pht
	port map	(
				up_in_pht => to_up_pht,
				down_in_pht => to_low_pht,
				up_out_pht => to_up_key,
				down_out_pht => to_low_key
				);
				
	-- upper adder of 32 bits
	up_adder: for i in 0 to 31 generate
		first: if (i=0) generate
			the_adder: adder
			port map	(
						in1_adder => to_up_key(0),
						in2_adder => up_key_f192(0),
						in_carry_adder => zero,
						out_adder => up_out_f192(0),
						out_carry_adder => intermediate_carry1(0)
						);
		end generate first;
		the_rest: if (i>0) generate
			the_adders: adder
			port map	(
						in1_adder => to_up_key(i),
						in2_adder => up_key_f192(i),
						in_carry_adder => intermediate_carry1(i-1),
						out_adder => up_out_f192(i),
						out_carry_adder => intermediate_carry1(i)
						);
		end generate the_rest;
	end generate up_adder;

	-- lower adder of 32 bits
	low_adder: for i in 0 to 31 generate
		first1: if (i=0) generate
			the_adder1:adder
			port map	(
						in1_adder => to_low_key(0),
						in2_adder => low_key_f192(0),
						in_carry_adder => zero,
						out_adder => low_out_f192(0),
						out_carry_adder => intermediate_carry2(0)
						);
		end generate first1;
		the_rest1: if (i>0) generate
			the_adders1: adder
			port map	(
						in1_adder => to_low_key(i),
						in2_adder => low_key_f192(i),
						in_carry_adder => intermediate_carry2(i-1),
						out_adder => low_out_f192(i),
						out_carry_adder => intermediate_carry2(i)
						);
		end generate the_rest1;
	end generate low_adder;

end f192_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish key scheduler for 192 bits key input			   
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_keysched192 is
port	(
		odd_in_tk192,
		even_in_tk192		: in std_logic_vector(7 downto 0);
		in_key_tk192		: in std_logic_vector(191 downto 0);
		out_key_up_tk192,
		out_key_down_tk192			: out std_logic_vector(31 downto 0)
		);
end twofish_keysched192;
				
architecture twofish_keysched192_arch of twofish_keysched192 is

	-- we declare internal signals
	signal	to_up_pht,
			to_shift_8,
			from_shift_8,
			to_shift_9,
			M0, M1, M2, M3, M4, M5	: std_logic_vector(31 downto 0);

	signal	byte0, byte1, byte2, byte3,
			byte4, byte5, byte6, byte7,
			byte8, byte9, byte10, byte11,
			byte12, byte13, byte14, byte15,
			byte16, byte17, byte18, byte19,
			byte20, byte21, byte22, byte23	: std_logic_vector(7 downto 0);
																		   			
	-- we declare the components to be used
	component pht
	port	(
			up_in_pht,
			down_in_pht		: in std_logic_vector(31 downto 0);
			up_out_pht,
			down_out_pht	: out std_logic_vector(31 downto 0)
			);
	end component;

	component h_192 
	port	(
			in_h192			: in std_logic_vector(7 downto 0);
			Mfirst_h192,
			Msecond_h192,
			Mthird_h192	: in std_logic_vector(31 downto 0);
			out_h192		: out std_logic_vector(31 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- we assign the input signal to the respective
	-- bytes as is described in the prototype
	byte23 <= in_key_tk192(7 downto 0);
	byte22 <= in_key_tk192(15 downto 8);
	byte21 <= in_key_tk192(23 downto 16);
	byte20 <= in_key_tk192(31 downto 24);
	byte19 <= in_key_tk192(39 downto 32);
	byte18 <= in_key_tk192(47 downto 40);
	byte17 <= in_key_tk192(55 downto 48);
	byte16 <= in_key_tk192(63 downto 56);
	byte15 <= in_key_tk192(71 downto 64);
	byte14 <= in_key_tk192(79 downto 72);
	byte13 <= in_key_tk192(87 downto 80);
	byte12 <= in_key_tk192(95 downto 88);
	byte11 <= in_key_tk192(103 downto 96);
	byte10 <= in_key_tk192(111 downto 104);
	byte9 <= in_key_tk192(119 downto 112);
	byte8 <= in_key_tk192(127 downto 120);
	byte7 <= in_key_tk192(135 downto 128);
	byte6 <= in_key_tk192(143 downto 136);
	byte5 <= in_key_tk192(151 downto 144);
	byte4 <= in_key_tk192(159 downto 152);
	byte3 <= in_key_tk192(167 downto 160);
	byte2 <= in_key_tk192(175 downto 168);
	byte1 <= in_key_tk192(183 downto 176);
	byte0 <= in_key_tk192(191 downto 184);

	-- we form the M{0..5}
	M0 <= byte3 & byte2 & byte1 & byte0;
	M1 <= byte7 & byte6 & byte5 & byte4;
	M2 <= byte11 & byte10 & byte9 & byte8;
	M3 <= byte15 & byte14 & byte13 & byte12;
	M4 <= byte19 & byte18 & byte17 & byte16;
	M5 <= byte23 & byte22 & byte21 & byte20;

	-- upper h
	upper_h: h_192
	port map	(
				in_h192 => even_in_tk192,
				Mfirst_h192 => M4,
				Msecond_h192 => M2,
				Mthird_h192 => M0,
				out_h192 => to_up_pht
				);
				
	-- lower h
	lower_h: h_192
	port map	(
				in_h192 => odd_in_tk192,
				Mfirst_h192 => M5,
				Msecond_h192 => M3,
				Mthird_h192 => M1,
				out_h192 => to_shift_8
				);
				
	-- left rotate by 8
	from_shift_8(31 downto 8) <= to_shift_8(23 downto 0);
	from_shift_8(7 downto 0) <= to_shift_8(31 downto 24);
	
	-- pht transformation
	pht_transform: pht
	port map	(
				up_in_pht => to_up_pht,
				down_in_pht => from_shift_8,
				up_out_pht => out_key_up_tk192,
				down_out_pht => to_shift_9
				);
				
	-- left rotate by 9
	out_key_down_tk192(31 downto 9) <= to_shift_9(22 downto 0);
	out_key_down_tk192(8 downto 0) <= to_shift_9(31 downto 23);

end twofish_keysched192_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish S key component for 192 bits key			   
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_S192 is
port	(
		in_key_ts192		: in std_logic_vector(191 downto 0);
		out_Sfirst_ts192,
		out_Ssecond_ts192,
		out_Sthird_ts192			: out std_logic_vector(31 downto 0)
		);
end twofish_S192;
				
architecture twofish_S192_arch of twofish_S192 is
																		   			
	-- we declare the components to be used
	component reed_solomon192 
	port	(
			in_rs192			: in std_logic_vector(191 downto 0);
			out_Sfirst_rs192,
			out_Ssecond_rs192,
			out_Sthird_rs192		: out std_logic_vector(31 downto 0)
			);
	end component;
	
	signal twofish_key : std_logic_vector(191 downto 0);
	signal	byte15, byte14, byte13, byte12, byte11, byte10,
			byte9, byte8, byte7, byte6, byte5, byte4,
			byte3, byte2, byte1, byte0,
			byte16, byte17, byte18, byte19,
			byte20, byte21, byte22, byte23 : std_logic_vector(7 downto 0);

-- begin architecture description
begin

	-- splitting the input
	byte23 <= in_key_ts192(7 downto 0);
	byte22 <= in_key_ts192(15 downto 8);
	byte21 <= in_key_ts192(23 downto 16);
	byte20 <= in_key_ts192(31 downto 24);
	byte19 <= in_key_ts192(39 downto 32);
	byte18 <= in_key_ts192(47 downto 40);
	byte17 <= in_key_ts192(55 downto 48);
	byte16 <= in_key_ts192(63 downto 56);
	byte15 <= in_key_ts192(71 downto 64);
	byte14 <= in_key_ts192(79 downto 72);
	byte13 <= in_key_ts192(87 downto 80);
	byte12 <= in_key_ts192(95 downto 88);
	byte11 <= in_key_ts192(103 downto 96);
	byte10 <= in_key_ts192(111 downto 104);
	byte9 <= in_key_ts192(119 downto 112);
	byte8 <= in_key_ts192(127 downto 120);
	byte7 <= in_key_ts192(135 downto 128);
	byte6 <= in_key_ts192(143 downto 136);
	byte5 <= in_key_ts192(151 downto 144);
	byte4 <= in_key_ts192(159 downto 152);
	byte3 <= in_key_ts192(167 downto 160);
	byte2 <= in_key_ts192(175 downto 168);
	byte1 <= in_key_ts192(183 downto 176);
	byte0 <= in_key_ts192(191 downto 184);

	-- forming the key
	twofish_key <= byte23 & byte22 & byte21 & byte20 & byte19 & byte18 & byte17 & byte16 &
							byte15 & byte14 & byte13 & byte12 & byte11 & byte10 & byte9 & byte8 & byte7 & 
								byte6 & byte5 & byte4 & byte3 & byte2 & byte1 & byte0;


	-- the keys S0,1,2
	produce_S0_S1_S2: reed_solomon192
	port map	(
				in_rs192 => twofish_key,
				out_Sfirst_rs192 => out_Sfirst_ts192,
				out_Ssecond_rs192 => out_Ssecond_ts192,
				out_Sthird_rs192 => out_Sthird_ts192
				);


end twofish_S192_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish whitening key scheduler for 192 bits key input			   
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_whit_keysched192 is
port	(
		in_key_twk192		: in std_logic_vector(191 downto 0);
		out_K0_twk192,
		out_K1_twk192,
		out_K2_twk192,
		out_K3_twk192,
		out_K4_twk192,
		out_K5_twk192,
		out_K6_twk192,
		out_K7_twk192			: out std_logic_vector(31 downto 0)
		);
end twofish_whit_keysched192;
				
architecture twofish_whit_keysched192_arch of twofish_whit_keysched192 is

	-- we declare internal signals
	signal	to_up_pht_1,
			to_shift_8_1,
			from_shift_8_1,
			to_shift_9_1,
			to_up_pht_2,
			to_shift_8_2,
			from_shift_8_2,
			to_shift_9_2,
			to_up_pht_3,
			to_shift_8_3,
			from_shift_8_3,
			to_shift_9_3,
			to_up_pht_4,
			to_shift_8_4,
			from_shift_8_4,
			to_shift_9_4,
			M0, M1, M2, M3, M4, M5	: std_logic_vector(31 downto 0);

	signal	byte0, byte1, byte2, byte3,
			byte4, byte5, byte6, byte7,
			byte8, byte9, byte10, byte11,
			byte12, byte13, byte14, byte15,
			byte16, byte17, byte18, byte19,
			byte20, byte21, byte22, byte23	: std_logic_vector(7 downto 0);

	signal		zero, one, two, three, four, five, six, seven	: std_logic_vector(7 downto 0);
																		   			
	-- we declare the components to be used
	component pht
	port	(
			up_in_pht,
			down_in_pht		: in std_logic_vector(31 downto 0);
			up_out_pht,
			down_out_pht	: out std_logic_vector(31 downto 0)
			);
	end component;

	component h_192 
	port	(
			in_h192			: in std_logic_vector(7 downto 0);
			Mfirst_h192,
			Msecond_h192,
			Mthird_h192	: in std_logic_vector(31 downto 0);
			out_h192		: out std_logic_vector(31 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- we produce the first eight numbers
	zero <= "00000000";
	one <= "00000001";
	two <= "00000010";
	three <= "00000011";
	four <= "00000100";
	five <= "00000101";
	six <= "00000110";
	seven <= "00000111";

	-- we assign the input signal to the respective
	-- bytes as is described in the prototype
	byte23 <= in_key_twk192(7 downto 0);
	byte22 <= in_key_twk192(15 downto 8);
	byte21 <= in_key_twk192(23 downto 16);
	byte20 <= in_key_twk192(31 downto 24);
	byte19 <= in_key_twk192(39 downto 32);
	byte18 <= in_key_twk192(47 downto 40);
	byte17 <= in_key_twk192(55 downto 48);
	byte16 <= in_key_twk192(63 downto 56);
	byte15 <= in_key_twk192(71 downto 64);
	byte14 <= in_key_twk192(79 downto 72);
	byte13 <= in_key_twk192(87 downto 80);
	byte12 <= in_key_twk192(95 downto 88);
	byte11 <= in_key_twk192(103 downto 96);
	byte10 <= in_key_twk192(111 downto 104);
	byte9 <= in_key_twk192(119 downto 112);
	byte8 <= in_key_twk192(127 downto 120);
	byte7 <= in_key_twk192(135 downto 128);
	byte6 <= in_key_twk192(143 downto 136);
	byte5 <= in_key_twk192(151 downto 144);
	byte4 <= in_key_twk192(159 downto 152);
	byte3 <= in_key_twk192(167 downto 160);
	byte2 <= in_key_twk192(175 downto 168);
	byte1 <= in_key_twk192(183 downto 176);
	byte0 <= in_key_twk192(191 downto 184);

	-- we form the M{0..5}
	M0 <= byte3 & byte2 & byte1 & byte0;
	M1 <= byte7 & byte6 & byte5 & byte4;
	M2 <= byte11 & byte10 & byte9 & byte8;
	M3 <= byte15 & byte14 & byte13 & byte12;
	M4 <= byte19 & byte18 & byte17 & byte16;
	M5 <= byte23 & byte22 & byte21 & byte20;

	-- we produce the keys for the whitening steps
	-- keys K0,1
	-- upper h
	upper_h1: h_192
	port map	(
				in_h192 => zero,
				Mfirst_h192 => M4,
				Msecond_h192 => M2,
				Mthird_h192 => M0,
				out_h192 => to_up_pht_1
				);
				
	-- lower h
	lower_h1: h_192
	port map	(
				in_h192 => one,
				Mfirst_h192 => M5,
				Msecond_h192 => M3,
				Mthird_h192 => M1,
				out_h192 => to_shift_8_1
				);
				
	-- left rotate by 8
	from_shift_8_1(31 downto 8) <= to_shift_8_1(23 downto 0);
	from_shift_8_1(7 downto 0) <= to_shift_8_1(31 downto 24);
	
	-- pht transformation
	pht_transform1: pht
	port map	(
				up_in_pht => to_up_pht_1,
				down_in_pht => from_shift_8_1,
				up_out_pht => out_K0_twk192,
				down_out_pht => to_shift_9_1
				);
				
	-- left rotate by 9
	out_K1_twk192(31 downto 9) <= to_shift_9_1(22 downto 0);
	out_K1_twk192(8 downto 0) <= to_shift_9_1(31 downto 23);

	-- keys K2,3
	-- upper h
	upper_h2: h_192
	port map	(
				in_h192 => two,
				Mfirst_h192 => M4,
				Msecond_h192 => M2,
				Mthird_h192 => M0,
				out_h192 => to_up_pht_2
				);
				
	-- lower h
	lower_h2: h_192
	port map	(
				in_h192 => three,
				Mfirst_h192 => M5,
				Msecond_h192 => M3,
				Mthird_h192 => M1,
				out_h192 => to_shift_8_2
				);
				
	-- left rotate by 8
	from_shift_8_2(31 downto 8) <= to_shift_8_2(23 downto 0);
	from_shift_8_2(7 downto 0) <= to_shift_8_2(31 downto 24);
	
	-- pht transformation
	pht_transform2: pht
	port map	(
				up_in_pht => to_up_pht_2,
				down_in_pht => from_shift_8_2,
				up_out_pht => out_K2_twk192,
				down_out_pht => to_shift_9_2
				);
				
	-- left rotate by 9
	out_K3_twk192(31 downto 9) <= to_shift_9_2(22 downto 0);
	out_K3_twk192(8 downto 0) <= to_shift_9_2(31 downto 23);

	-- keys K4,5
	-- upper h
	upper_h3: h_192
	port map	(
				in_h192 => four,
				Mfirst_h192 => M4,
				Msecond_h192 => M2,
				Mthird_h192 => M0,
				out_h192 => to_up_pht_3
				);
				
	-- lower h
	lower_h3: h_192
	port map	(
				in_h192 => five,
				Mfirst_h192 => M5,
				Msecond_h192 => M3,
				Mthird_h192 => M1,
				out_h192 => to_shift_8_3
				);
				
	-- left rotate by 8
	from_shift_8_3(31 downto 8) <= to_shift_8_3(23 downto 0);
	from_shift_8_3(7 downto 0) <= to_shift_8_3(31 downto 24);
	
	-- pht transformation
	pht_transform3: pht
	port map	(
				up_in_pht => to_up_pht_3,
				down_in_pht => from_shift_8_3,
				up_out_pht => out_K4_twk192,
				down_out_pht => to_shift_9_3
				);
				
	-- left rotate by 9
	out_K5_twk192(31 downto 9) <= to_shift_9_3(22 downto 0);
	out_K5_twk192(8 downto 0) <= to_shift_9_3(31 downto 23);

	-- keys K6,7
	-- upper h
	upper_h4: h_192
	port map	(
				in_h192 => six,
				Mfirst_h192 => M4,
				Msecond_h192 => M2,
				Mthird_h192 => M0,
				out_h192 => to_up_pht_4
				);
				
	-- lower h
	lower_h4: h_192
	port map	(
				in_h192 => seven,
				Mfirst_h192 => M5,
				Msecond_h192 => M3,
				Mthird_h192 => M1,
				out_h192 => to_shift_8_4
				);
				
	-- left rotate by 8
	from_shift_8_4(31 downto 8) <= to_shift_8_4(23 downto 0);
	from_shift_8_4(7 downto 0) <= to_shift_8_4(31 downto 24);
	
	-- pht transformation
	pht_transform4: pht
	port map	(
				up_in_pht => to_up_pht_4,
				down_in_pht => from_shift_8_4,
				up_out_pht => out_K6_twk192,
				down_out_pht => to_shift_9_4
				);
				
	-- left rotate by 9
	out_K7_twk192(31 downto 9) <= to_shift_9_4(22 downto 0);
	out_K7_twk192(8 downto 0) <= to_shift_9_4(31 downto 23);

end twofish_whit_keysched192_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish encryption round with 192 bit key input
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_encryption_round192 is
port	(
		in1_ter192,
		in2_ter192,
		in3_ter192,
		in4_ter192,
		in_Sfirst_ter192,
		in_Ssecond_ter192,
		in_Sthird_ter192,
		in_key_up_ter192,
		in_key_down_ter192		: in std_logic_vector(31 downto 0);
		out1_ter192,
		out2_ter192,
		out3_ter192,
		out4_ter192			: out std_logic_vector(31 downto 0)
		);
end twofish_encryption_round192;

architecture twofish_encryption_round192_arch of twofish_encryption_round192 is
					   
	-- we declare internal signals
	signal	to_left_shift,
			from_right_shift,
			to_xor_with3,
			to_xor_with4			: std_logic_vector(31 downto 0);
			
	component f_192
	port	(
			up_in_f192,
			low_in_f192,
			S0_in_f192,
			S1_in_f192,
			S2_in_f192,
			up_key_f192,
			low_key_f192			: in std_logic_vector(31 downto 0);
			up_out_f192,
			low_out_f192			: out std_logic_vector(31 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- we declare f_192
	function_f: f_192
	port map	(
				up_in_f192 => in1_ter192,
				low_in_f192 => in2_ter192,
				S0_in_f192 => in_Sfirst_ter192,	
				S1_in_f192 => in_Ssecond_ter192,
				S2_in_f192 => in_Sthird_ter192,
				up_key_f192 => in_key_up_ter192,
				low_key_f192 => in_key_down_ter192,
				up_out_f192 => to_xor_with3,
				low_out_f192 => to_xor_with4
				);
	
	-- we perform the exchange
	-- in1_ter128 -> out3_ter128
	-- in2_ter128 -> out4_ter128
	-- in3_ter128 -> out1_ter128
	-- in4_ter128 -> out2_ter128	
	
	-- we perform the left xor between the upper f function and
	-- the third input (input 3)
	to_left_shift <= to_xor_with3 XOR in3_ter192;
	
	-- we perform the left side rotation to the right by 1 and
	-- we perform the exchange too
	out1_ter192(30 downto 0) <= to_left_shift(31 downto 1);
	out1_ter192(31) <= to_left_shift(0);
	
	-- we perform the right side rotation to the left by 1
	from_right_shift(0) <= in4_ter192(31);
	from_right_shift(31 downto 1) <= in4_ter192(30 downto 0);
	
	-- we perform the right xor between the lower f function and 
	-- the fourth input (input 4)
	out2_ter192 <= from_right_shift XOR to_xor_with4;
	
	-- we perform the last exchanges
	out3_ter192 <= in1_ter192;
	out4_ter192 <= in2_ter192;

end twofish_encryption_round192_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish decryption round with 192 bit key input
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_decryption_round192 is
port	(
		in1_tdr192,
		in2_tdr192,
		in3_tdr192,
		in4_tdr192,
		in_Sfirst_tdr192,
		in_Ssecond_tdr192,
		in_Sthird_tdr192,
		in_key_up_tdr192,
		in_key_down_tdr192	: in std_logic_vector(31 downto 0);
		out1_tdr192,
		out2_tdr192,
		out3_tdr192,
		out4_tdr192			: out std_logic_vector(31 downto 0)
		);
end twofish_decryption_round192;

architecture twofish_decryption_round192_arch of twofish_decryption_round192 is

	signal	to_xor_with3,
			to_xor_with4,
			to_xor_with_up_f,
			from_xor_with_down_f	: std_logic_vector(31 downto 0);

	component f_192 
	port	(
			up_in_f192,
			low_in_f192,
			S0_in_f192,
			S1_in_f192,
			S2_in_f192,
			up_key_f192,
			low_key_f192	: in std_logic_vector(31 downto 0);
			up_out_f192,
			low_out_f192		: out std_logic_vector(31 downto 0)
			);
	end component;

begin

	-- we instantiate f function
	function_f: f_192
	port map	(
				up_in_f192 => in1_tdr192,
				low_in_f192 => in2_tdr192,
				S0_in_f192 => in_Sfirst_tdr192,
				S1_in_f192 => in_Ssecond_tdr192,
				S2_in_f192 => in_Sthird_tdr192,
				up_key_f192 => in_key_up_tdr192,
				low_key_f192 => in_key_down_tdr192,
				up_out_f192 => to_xor_with3,
				low_out_f192 => to_xor_with4
				);
				
	-- output 1: input3 with upper f
	-- we first rotate the input3 by 1 bit leftwise
	to_xor_with_up_f(0) <= in3_tdr192(31);
	to_xor_with_up_f(31 downto 1) <= in3_tdr192(30 downto 0);
	
	-- we perform the XOR with the upper output of f and the result
	-- is ouput 1
	out1_tdr192 <= to_xor_with_up_f XOR to_xor_with3;
	
	-- output 2: input4 with lower f
	-- we perform the XOR with the lower output of f
	from_xor_with_down_f <= in4_tdr192 XOR to_xor_with4;
	
	-- we perform the rotation by 1 bit rightwise and the result 
	-- is output2
	out2_tdr192(31) <= from_xor_with_down_f(0);
	out2_tdr192(30 downto 0) <= from_xor_with_down_f(31 downto 1);
	
	-- we assign outputs 3 and 4
	out3_tdr192 <= in1_tdr192;
	out4_tdr192 <= in2_tdr192;

end twofish_decryption_round192_arch;


-- =============================================== --
-- =============================================== --
--												   --
-- fourth part: 256 key input dependent components --
--												   --
-- =============================================== --
-- =============================================== --


-- 					
--	reed solomon	for 256bits key
--					

library ieee;
use ieee.std_logic_1164.all;

entity reed_solomon256 is
port	(
		in_rs256			: in std_logic_vector(255 downto 0);
		out_Sfirst_rs256,
		out_Ssecond_rs256,
		out_Sthird_rs256,
		out_Sfourth_rs256		: out std_logic_vector(31 downto 0)	
		);
end reed_solomon256;

architecture rs_256_arch of reed_solomon256 is

	-- declaring all components necessary for reed solomon
	-- 01
	component mul01
	port	(
			in_mul01	: in std_logic_vector(7 downto 0);
			out_mul01	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- a4	
	component mula4 
	port	(
			in_mula4	: in std_logic_vector(7 downto 0);			
			out_mula4	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 55
	component mul55 
	port	(
			in_mul55	: in std_logic_vector(7 downto 0);
			out_mul55	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 87
	component mul87 
	port	(
			in_mul87	: in std_logic_vector(7 downto 0);
			out_mul87	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 5a
	component mul5a 
	port	(
			in_mul5a	: in std_logic_vector(7 downto 0);
			out_mul5a	: out std_logic_vector(7 downto 0)
			);
	end component;

	-- 58
	component mul58 
	port	(
			in_mul58	: in std_logic_vector(7 downto 0);
			out_mul58	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- db
	component muldb 
	port	(
			in_muldb	: in std_logic_vector(7 downto 0);
			out_muldb	: out std_logic_vector(7 downto 0)
			);
	end component;

	
	-- 9e
	component mul9e 
	port	(
			in_mul9e	: in std_logic_vector(7 downto 0);
			out_mul9e	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 56
	component mul56 
	port	(
			in_mul56	: in std_logic_vector(7 downto 0);
			out_mul56	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 82
	component mul82 
	port	(
			in_mul82	: in std_logic_vector(7 downto 0);
			out_mul82	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- f3
	component mulf3 
	port	(
			in_mulf3	: in std_logic_vector(7 downto 0);
			out_mulf3	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 1e
	component mul1e 
	port	(
			in_mul1e	: in std_logic_vector(7 downto 0);
			out_mul1e	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- c6
	component mulc6 
	port	(
			in_mulc6	: in std_logic_vector(7 downto 0);
			out_mulc6	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 68
	component mul68 
	port	(
			in_mul68	: in std_logic_vector(7 downto 0);
			out_mul68	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- e5
	component mule5 
	port	(
			in_mule5	: in std_logic_vector(7 downto 0);
			out_mule5	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 02
	component mul02 
	port	(
			in_mul02	: in std_logic_vector(7 downto 0);
			out_mul02	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- a1
	component mula1 
	port	(
			in_mula1	: in std_logic_vector(7 downto 0);
			out_mula1	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- fc
	component mulfc 
	port	(
			in_mulfc	: in std_logic_vector(7 downto 0);
			out_mulfc	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- c1
	component mulc1 
	port	(
			in_mulc1	: in std_logic_vector(7 downto 0);
			out_mulc1	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 47
	component mul47 
	port	(
			in_mul47	: in std_logic_vector(7 downto 0);
			out_mul47	: out std_logic_vector(7 downto 0)	
			);
	end component;



	-- ae
	component mulae 
	port	(
			in_mulae	: in std_logic_vector(7 downto 0);
			out_mulae	: out std_logic_vector(7 downto 0)
			);
	end component;



	-- 3d
	component mul3d 
	port	(
			in_mul3d	: in std_logic_vector(7 downto 0);
			out_mul3d	: out std_logic_vector(7 downto 0)
			);
	end component;



	-- 19
	component mul19 
	port	(
			in_mul19	: in std_logic_vector(7 downto 0);
			out_mul19	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- 03
	component mul03 
	port	(
			in_mul03	: in std_logic_vector(7 downto 0);
			out_mul03	: out std_logic_vector(7 downto 0)
			);
	end component;


	-- declaring internal signals
	signal	m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,
			m16, m17, m18, m19, m20, m21, m22, m23, m24, m25, m26, m27, m28, m29, m30, m31		: std_logic_vector(7 downto 0);	
	signal 	s00,s01,s02,s03,s10,s11,s12,s13, s20, s21, s22, s23, s30, s31, s32, s33								: std_logic_vector(7 downto 0);	

	signal	m0_01,m1_a4,m2_55,m3_87,m4_5a,m5_58,m6_db,m7_9e,
			m0_a4,m1_56,m2_82,m3_f3,m4_1e,m5_c6,m6_68,m7_e5,
			m0_02,m1_a1,m2_fc,m3_c1,m4_47,m5_ae,m6_3d,m7_19,
			m0_a4_1,m1_55,m2_87,m3_5a,m4_58,m5_db,m6_9e,m7_03			: std_logic_vector(7 downto 0);	

	signal	m8_01,m9_a4,m10_55,m11_87,m12_5a,m13_58,m14_db,m15_9e,
			m8_a4,m9_56,m10_82,m11_f3,m12_1e,m13_c6,m14_68,m15_e5,
			m8_02,m9_a1,m10_fc,m11_c1,m12_47,m13_ae,m14_3d,m15_19,
			m8_a4_1,m9_55,m10_87,m11_5a,m12_58,m13_db,m14_9e,m15_03		: std_logic_vector(7 downto 0);	

	signal	m16_01,m17_a4,m18_55,m19_87,m20_5a,m21_58,m22_db,m23_9e,
			m16_a4,m17_56,m18_82,m19_f3,m20_1e,m21_c6,m22_68,m23_e5,
			m16_02,m17_a1,m18_fc,m19_c1,m20_47,m21_ae,m22_3d,m23_19,
			m16_a4_1,m17_55,m18_87,m19_5a,m20_58,m21_db,m22_9e,m23_03		: std_logic_vector(7 downto 0);	

	signal	m24_01,m25_a4,m26_55,m27_87,m28_5a,m29_58,m30_db,m31_9e,
			m24_a4,m25_56,m26_82,m27_f3,m28_1e,m29_c6,m30_68,m31_e5,
			m24_02,m25_a1,m26_fc,m27_c1,m28_47,m29_ae,m30_3d,m31_19,
			m24_a4_1,m25_55,m26_87,m27_5a,m28_58,m29_db,m30_9e,m31_03		: std_logic_vector(7 downto 0);	


-- begin architecture description
begin

	-- first, we separate the input to the respective m
	-- for s0j  j=0..3
	m0 <= in_rs256(7 downto 0);
	m1 <= in_rs256(15 downto 8);
	m2 <= in_rs256(23 downto 16);
	m3 <= in_rs256(31 downto 24);
	m4 <= in_rs256(39 downto 32);
	m5 <= in_rs256(47 downto 40);
	m6 <= in_rs256(55 downto 48);
	m7 <= in_rs256(63 downto 56);

	-- for s1j  j=0..3
	m8 <= in_rs256(71 downto 64);
	m9 <= in_rs256(79 downto 72);
	m10 <= in_rs256(87 downto 80);
	m11 <= in_rs256(95 downto 88);
	m12 <= in_rs256(103 downto 96);
	m13 <= in_rs256(111 downto 104);
	m14 <= in_rs256(119 downto 112);
	m15 <= in_rs256(127 downto 120);

	-- for s2j  j=0..3
	m16 <= in_rs256(135 downto 128);
	m17 <= in_rs256(143 downto 136);
	m18 <= in_rs256(151 downto 144);
	m19 <= in_rs256(159 downto 152);
	m20 <= in_rs256(167 downto 160);
	m21 <= in_rs256(175 downto 168);
	m22 <= in_rs256(183 downto 176);
	m23 <= in_rs256(191 downto 184);

	-- for s3j  j=0..3
	m24 <= in_rs256(199 downto 192);
	m25 <= in_rs256(207 downto 200);
	m26 <= in_rs256(215 downto 208);
	m27 <= in_rs256(223 downto 216);
	m28 <= in_rs256(231 downto 224);
	m29 <= in_rs256(239 downto 232);
	m30 <= in_rs256(247 downto 240);
	m31 <= in_rs256(255 downto 248);

	-- after separating signals, we drive them to multipliers
	-- the first line of m0..7 forms s00
	m0_with_01: mul01
	port map	(
				in_mul01 => m0,
				out_mul01 => m0_01
				);

	m1_with_a4: mula4
	port map	(
				in_mula4 => m1,
				out_mula4 => m1_a4
				);

	m2_with_55: mul55
	port map	(
				in_mul55 => m2,
				out_mul55 => m2_55
				);

	m3_with_87: mul87
	port map	(
				in_mul87 => m3,
				out_mul87 => m3_87
				);

	m4_with_5a: mul5a
	port map	(
				in_mul5a => m4,
				out_mul5a => m4_5a
				);

	m5_with_58: mul58
	port map	(
				in_mul58 => m5,
				out_mul58 => m5_58
				);

	m6_with_db: muldb
	port map	(
				in_muldb => m6,
				out_muldb => m6_db
				);

	m7_with_9e: mul9e
	port map	(
				in_mul9e => m7,
				out_mul9e => m7_9e
				);

	-- the second row creates s01
	m0_with_a4: mula4
	port map	(
				in_mula4 => m0,
				out_mula4 => m0_a4
				);

	m1_with_56: mul56
	port map	(
				in_mul56 => m1,
				out_mul56 => m1_56
				);

	m2_with_82: mul82
	port map	(
				in_mul82 => m2,
				out_mul82 => m2_82
				);
	
	m3_with_f3: mulf3
	port map	(
				in_mulf3 => m3,
				out_mulf3 => m3_f3
				);

	m4_with_1e: mul1e
	port map	(
				in_mul1e => m4,
				out_mul1e => m4_1e
				);

	m5_with_c6: mulc6
	port map	(
				in_mulc6 => m5,
				out_mulc6 => m5_c6
				);

	m6_with_68: mul68
	port map	(
				in_mul68 => m6,
				out_mul68 => m6_68
				);

	m7_with_e5: mule5
	port map	(
				in_mule5 => m7,
				out_mule5 => m7_e5
				);

	-- the third row creates s02
	m0_with_02: mul02
	port map	(
				in_mul02 => m0,
				out_mul02 => m0_02
				);

	m1_with_a1: mula1
	port map	(
				in_mula1 => m1,
				out_mula1 => m1_a1
				);

	m2_with_fc: mulfc
	port map	(
				in_mulfc => m2,
				out_mulfc => m2_fc
				);

	m3_with_c1: mulc1
	port map	(
				in_mulc1 => m3,
				out_mulc1 => m3_c1
				);

	m4_with_47: mul47
	port map	(
				in_mul47 => m4,
				out_mul47 => m4_47
				);

	m5_with_ae: mulae
	port map	(
				in_mulae => m5,
				out_mulae => m5_ae
				);

	m6_with_3d: mul3d
	port map	(
				in_mul3d => m6,
				out_mul3d => m6_3d
				);

	m7_with_19: mul19
	port map	(
				in_mul19 => m7,
				out_mul19 => m7_19
				);

	-- the fourth row creates s03
	m0_with_a4_1: mula4
	port map	(
				in_mula4 => m0,
				out_mula4 => m0_a4_1
				);

	m1_with_55: mul55
	port map	(
				in_mul55 => m1,
				out_mul55 => m1_55
				);

	m2_with_87: mul87
	port map	(
				in_mul87 => m2,
				out_mul87 => m2_87
				);

	m3_with_5a: mul5a
	port map	(
				in_mul5a => m3,
				out_mul5a => m3_5a
				);

	m4_with_58: mul58
	port map	(
				in_mul58 => m4,
				out_mul58 => m4_58
				);

	m5_with_db: muldb
	port map	(
				in_muldb => m5,
				out_muldb => m5_db
				);

	m6_with_9e: mul9e
	port map	(
				in_mul9e => m6,
				out_mul9e => m6_9e
				);

	m7_with_03: mul03
	port map	(
				in_mul03 => m7,
				out_mul03 => m7_03
				);


	-- we create the s1,j j=0..3
	-- the first row of m8..15 creates the s10
	m8_with_01: mul01
	port map	(
				in_mul01 => m8,
				out_mul01 => m8_01
				);

	m9_with_a4: mula4
	port map	(
				in_mula4 => m9,
				out_mula4 => m9_a4
				);

	m10_with_55: mul55
	port map	(
				in_mul55 => m10,
				out_mul55 => m10_55
				);

	m11_with_87: mul87
	port map	(
				in_mul87 => m11,
				out_mul87 => m11_87
				);

	m12_with_5a: mul5a
	port map	(
				in_mul5a => m12,
				out_mul5a => m12_5a
				);

	m13_with_58: mul58
	port map	(
				in_mul58 => m13,
				out_mul58 => m13_58
				);

	m14_with_db: muldb
	port map	(
				in_muldb => m14,
				out_muldb => m14_db
				);

	m15_with_9e: mul9e
	port map	(
				in_mul9e => m15,
				out_mul9e => m15_9e
				);

	-- the second row creates s11
	m8_with_a4: mula4
	port map	(
				in_mula4 => m8,
				out_mula4 => m8_a4
				);

	m9_with_56: mul56
	port map	(
				in_mul56 => m9,
				out_mul56 => m9_56
				);

	m10_with_82: mul82
	port map	(
				in_mul82 => m10,
				out_mul82 => m10_82
				);
	
	m11_with_f3: mulf3
	port map	(
				in_mulf3 => m11,
				out_mulf3 => m11_f3
				);

	m12_with_1e: mul1e
	port map	(
				in_mul1e => m12,
				out_mul1e => m12_1e
				);

	m13_with_c6: mulc6
	port map	(
				in_mulc6 => m13,
				out_mulc6 => m13_c6
				);

	m14_with_68: mul68
	port map	(
				in_mul68 => m14,
				out_mul68 => m14_68
				);

	m15_with_e5: mule5
	port map	(
				in_mule5 => m15,
				out_mule5 => m15_e5
				);

	-- the third row creates s12
	m8_with_02: mul02
	port map	(
				in_mul02 => m8,
				out_mul02 => m8_02
				);

	m9_with_a1: mula1
	port map	(
				in_mula1 => m9,
				out_mula1 => m9_a1
				);

	m10_with_fc: mulfc
	port map	(
				in_mulfc => m10,
				out_mulfc => m10_fc
				);

	m11_with_c1: mulc1
	port map	(
				in_mulc1 => m11,
				out_mulc1 => m11_c1
				);

	m12_with_47: mul47
	port map	(
				in_mul47 => m12,
				out_mul47 => m12_47
				);

	m13_with_ae: mulae
	port map	(
				in_mulae => m13,
				out_mulae => m13_ae
				);

	m14_with_3d: mul3d
	port map	(
				in_mul3d => m14,
				out_mul3d => m14_3d
				);

	m15_with_19: mul19
	port map	(
				in_mul19 => m15,
				out_mul19 => m15_19
				);

	-- the fourth row creates s13
	m8_with_a4_1: mula4
	port map	(
				in_mula4 => m8,
				out_mula4 => m8_a4_1
				);

	m9_with_55: mul55
	port map	(
				in_mul55 => m9,
				out_mul55 => m9_55
				);

	m10_with_87: mul87
	port map	(
				in_mul87 => m10,
				out_mul87 => m10_87
				);

	m11_with_5a: mul5a
	port map	(
				in_mul5a => m11,
				out_mul5a => m11_5a
				);

	m12_with_58: mul58
	port map	(
				in_mul58 => m12,
				out_mul58 => m12_58
				);

	m13_with_db: muldb
	port map	(
				in_muldb => m13,
				out_muldb => m13_db
				);

	m14_with_9e: mul9e
	port map	(
				in_mul9e => m14,
				out_mul9e => m14_9e
				);

	m15_with_03: mul03
	port map	(
				in_mul03 => m15,
				out_mul03 => m15_03
				);

	-- we create the s2,j j=0..3
	-- the first row of m16..23 creates the s20
	m16_with_01: mul01
	port map	(
				in_mul01 => m16,
				out_mul01 => m16_01
				);

	m17_with_a4: mula4
	port map	(
				in_mula4 => m17,
				out_mula4 => m17_a4
				);

	m18_with_55: mul55
	port map	(
				in_mul55 => m18,
				out_mul55 => m18_55
				);

	m19_with_87: mul87
	port map	(
				in_mul87 => m19,
				out_mul87 => m19_87
				);

	m20_with_5a: mul5a
	port map	(
				in_mul5a => m20,
				out_mul5a => m20_5a
				);

	m21_with_58: mul58
	port map	(
				in_mul58 => m21,
				out_mul58 => m21_58
				);

	m22_with_db: muldb
	port map	(
				in_muldb => m22,
				out_muldb => m22_db
				);

	m23_with_9e: mul9e
	port map	(
				in_mul9e => m23,
				out_mul9e => m23_9e
				);

	-- the second row creates s21
	m16_with_a4: mula4
	port map	(
				in_mula4 => m16,
				out_mula4 => m16_a4
				);

	m17_with_56: mul56
	port map	(
				in_mul56 => m17,
				out_mul56 => m17_56
				);

	m18_with_82: mul82
	port map	(
				in_mul82 => m18,
				out_mul82 => m18_82
				);
	
	m19_with_f3: mulf3
	port map	(
				in_mulf3 => m19,
				out_mulf3 => m19_f3
				);

	m20_with_1e: mul1e
	port map	(
				in_mul1e => m20,
				out_mul1e => m20_1e
				);

	m21_with_c6: mulc6
	port map	(
				in_mulc6 => m21,
				out_mulc6 => m21_c6
				);

	m22_with_68: mul68
	port map	(
				in_mul68 => m22,
				out_mul68 => m22_68
				);

	m23_with_e5: mule5
	port map	(
				in_mule5 => m23,
				out_mule5 => m23_e5
				);

	-- the third row creates s22
	m16_with_02: mul02
	port map	(
				in_mul02 => m16,
				out_mul02 => m16_02
				);

	m17_with_a1: mula1
	port map	(
				in_mula1 => m17,
				out_mula1 => m17_a1
				);

	m18_with_fc: mulfc
	port map	(
				in_mulfc => m18,
				out_mulfc => m18_fc
				);

	m19_with_c1: mulc1
	port map	(
				in_mulc1 => m19,
				out_mulc1 => m19_c1
				);

	m20_with_47: mul47
	port map	(
				in_mul47 => m20,
				out_mul47 => m20_47
				);

	m21_with_ae: mulae
	port map	(
				in_mulae => m21,
				out_mulae => m21_ae
				);

	m22_with_3d: mul3d
	port map	(
				in_mul3d => m22,
				out_mul3d => m22_3d
				);

	m23_with_19: mul19
	port map	(
				in_mul19 => m23,
				out_mul19 => m23_19
				);

	-- the fourth row creates s23
	m16_with_a4_1: mula4
	port map	(
				in_mula4 => m16,
				out_mula4 => m16_a4_1
				);

	m17_with_55: mul55
	port map	(
				in_mul55 => m17,
				out_mul55 => m17_55
				);

	m18_with_87: mul87
	port map	(
				in_mul87 => m18,
				out_mul87 => m18_87
				);

	m19_with_5a: mul5a
	port map	(
				in_mul5a => m19,
				out_mul5a => m19_5a
				);

	m20_with_58: mul58
	port map	(
				in_mul58 => m20,
				out_mul58 => m20_58
				);

	m21_with_db: muldb
	port map	(
				in_muldb => m21,
				out_muldb => m21_db
				);

	m22_with_9e: mul9e
	port map	(
				in_mul9e => m22,
				out_mul9e => m22_9e
				);

	m23_with_03: mul03
	port map	(
				in_mul03 => m23,
				out_mul03 => m23_03
				);

	-- we create the s3j j=0..3
	-- the first row of m24..31 creates the s30
	m24_with_01: mul01
	port map	(
				in_mul01 => m24,
				out_mul01 => m24_01
				);

	m25_with_a4: mula4
	port map	(
				in_mula4 => m25,
				out_mula4 => m25_a4
				);

	m26_with_55: mul55
	port map	(
				in_mul55 => m26,
				out_mul55 => m26_55
				);

	m27_with_87: mul87
	port map	(
				in_mul87 => m27,
				out_mul87 => m27_87
				);

	m28_with_5a: mul5a
	port map	(
				in_mul5a => m28,
				out_mul5a => m28_5a
				);

	m29_with_58: mul58
	port map	(
				in_mul58 => m29,
				out_mul58 => m29_58
				);

	m30_with_db: muldb
	port map	(
				in_muldb => m30,
				out_muldb => m30_db
				);

	m31_with_9e: mul9e
	port map	(
				in_mul9e => m31,
				out_mul9e => m31_9e
				);

	-- the second row creates s31
	m24_with_a4: mula4
	port map	(
				in_mula4 => m24,
				out_mula4 => m24_a4
				);

	m25_with_56: mul56
	port map	(
				in_mul56 => m25,
				out_mul56 => m25_56
				);

	m26_with_82: mul82
	port map	(
				in_mul82 => m26,
				out_mul82 => m26_82
				);
	
	m27_with_f3: mulf3
	port map	(
				in_mulf3 => m27,
				out_mulf3 => m27_f3
				);

	m28_with_1e: mul1e
	port map	(
				in_mul1e => m28,
				out_mul1e => m28_1e
				);

	m29_with_c6: mulc6
	port map	(
				in_mulc6 => m29,
				out_mulc6 => m29_c6
				);

	m30_with_68: mul68
	port map	(
				in_mul68 => m30,
				out_mul68 => m30_68
				);

	m31_with_e5: mule5
	port map	(
				in_mule5 => m31,
				out_mule5 => m31_e5
				);

	-- the third row creates s32
	m24_with_02: mul02
	port map	(
				in_mul02 => m24,
				out_mul02 => m24_02
				);

	m25_with_a1: mula1
	port map	(
				in_mula1 => m25,
				out_mula1 => m25_a1
				);

	m26_with_fc: mulfc
	port map	(
				in_mulfc => m26,
				out_mulfc => m26_fc
				);

	m27_with_c1: mulc1
	port map	(
				in_mulc1 => m27,
				out_mulc1 => m27_c1
				);

	m28_with_47: mul47
	port map	(
				in_mul47 => m28,
				out_mul47 => m28_47
				);

	m29_with_ae: mulae
	port map	(
				in_mulae => m29,
				out_mulae => m29_ae
				);

	m30_with_3d: mul3d
	port map	(
				in_mul3d => m30,
				out_mul3d => m30_3d
				);

	m31_with_19: mul19
	port map	(
				in_mul19 => m31,
				out_mul19 => m31_19
				);

	-- the fourth row creates s33
	m24_with_a4_1: mula4
	port map	(
				in_mula4 => m24,
				out_mula4 => m24_a4_1
				);

	m25_with_55: mul55
	port map	(
				in_mul55 => m25,
				out_mul55 => m25_55
				);

	m26_with_87: mul87
	port map	(
				in_mul87 => m26,
				out_mul87 => m26_87
				);

	m27_with_5a: mul5a
	port map	(
				in_mul5a => m27,
				out_mul5a => m27_5a
				);

	m28_with_58: mul58
	port map	(
				in_mul58 => m28,
				out_mul58 => m28_58
				);

	m29_with_db: muldb
	port map	(
				in_muldb => m29,
				out_muldb => m29_db
				);

	m30_with_9e: mul9e
	port map	(
				in_mul9e => m30,
				out_mul9e => m30_9e
				);

	m31_with_03: mul03
	port map	(
				in_mul03 => m31,
				out_mul03 => m31_03
				);

	-- after getting the results from multipliers
	-- we combine them in order to get the additions
	s00 <= m0_01 XOR m1_a4 XOR m2_55 XOR m3_87 XOR m4_5a XOR m5_58 XOR m6_db XOR m7_9e;
	s01 <= m0_a4 XOR m1_56 XOR m2_82 XOR m3_f3 XOR m4_1e XOR m5_c6 XOR m6_68 XOR m7_e5;
	s02 <= m0_02 XOR m1_a1 XOR m2_fc XOR m3_c1 XOR m4_47 XOR m5_ae XOR m6_3d XOR m7_19;
	s03 <= m0_a4_1 XOR m1_55 XOR m2_87 XOR m3_5a XOR m4_58 XOR m5_db XOR m6_9e XOR m7_03;

	-- after creating s0,j j=0...3 we form the S0
	-- little endian 
	out_Sfirst_rs256 <= s03 & s02 & s01 & s00;

	s10 <= m8_01 XOR m9_a4 XOR m10_55 XOR m11_87 XOR m12_5a XOR m13_58 XOR m14_db XOR m15_9e;
	s11 <= m8_a4 XOR m9_56 XOR m10_82 XOR m11_f3 XOR m12_1e XOR m13_c6 XOR m14_68 XOR m15_e5;
	s12 <= m8_02 XOR m9_a1 XOR m10_fc XOR m11_c1 XOR m12_47 XOR m13_ae XOR m14_3d XOR m15_19;
	s13 <= m8_a4_1 XOR m9_55 XOR m10_87 XOR m11_5a XOR m12_58 XOR m13_db XOR m14_9e XOR m15_03;

	-- after creating s1,j j=0...3 we form the S1
	-- little endian
	out_Ssecond_rs256 <= s13 & s12 & s11 & s10;

	s20 <= m16_01 XOR m17_a4 XOR m18_55 XOR m19_87 XOR m20_5a XOR m21_58 XOR m22_db XOR m23_9e;
	s21 <= m16_a4 XOR m17_56 XOR m18_82 XOR m19_f3 XOR m20_1e XOR m21_c6 XOR m22_68 XOR m23_e5;
	s22 <= m16_02 XOR m17_a1 XOR m18_fc XOR m19_c1 XOR m20_47 XOR m21_ae XOR m22_3d XOR m23_19;
	s23 <= m16_a4_1 XOR m17_55 XOR m18_87 XOR m19_5a XOR m20_58 XOR m21_db XOR m22_9e XOR m23_03;

 	-- after creating s2j j=0...3 we form the S2
	-- little endian
	out_Sthird_rs256 <= s23 & s22 & s21 & s20;

	s30 <= m24_01 XOR m25_a4 XOR m26_55 XOR m27_87 XOR m28_5a XOR m29_58 XOR m30_db XOR m31_9e;
	s31 <= m24_a4 XOR m25_56 XOR m26_82 XOR m27_f3 XOR m28_1e XOR m29_c6 XOR m30_68 XOR m31_e5;
	s32 <= m24_02 XOR m25_a1 XOR m26_fc XOR m27_c1 XOR m28_47 XOR m29_ae XOR m30_3d XOR m31_19;
	s33 <= m24_a4_1 XOR m25_55 XOR m26_87 XOR m27_5a XOR m28_58 XOR m29_db XOR m30_9e XOR m31_03;

 	-- after creating s3j j=0...3 we form the S3
	-- little endian
	out_Sfourth_rs256 <= s33 & s32 & s31 & s30;

end rs_256_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- h function for 256 bits key
-- 

library ieee;
use ieee.std_logic_1164.all;

entity h_256 is
port	(
		in_h256		: in std_logic_vector(7 downto 0);
		Mfirst_h256,
		Msecond_h256,
		Mthird_h256,
		Mfourth_h256	: in std_logic_vector(31 downto 0);
		out_h256		: out std_logic_vector(31 downto 0)
		);
end h_256;

architecture h256_arch of h_256 is

	-- we declare internal signals
	signal	from_first_row,
			to_second_row,
			from_second_row,
			to_third_row,
			from_third_row,
			to_fourth_row,
			from_fourth_row,
			to_fifth_row,
			to_mds			: std_logic_vector(31 downto 0);
					
	-- we declare all components needed 				   
	component q0
	port	(			   
			in_q0 	: in std_logic_vector(7 downto 0);
			out_q0	: out std_logic_vector(7 downto 0)
			);
	end component;
	
	component q1
	port	(
			in_q1 	: in std_logic_vector(7 downto 0);
			out_q1	: out std_logic_vector(7 downto 0)
			);
	end component;

	component mds
	port	(
			y0,
			y1,
			y2,
			y3	: in std_logic_vector(7 downto 0);
			z0,
			z1,
			z2,
			z3	: out std_logic_vector(7 downto 0)
			);
	end component;

-- begin architecture description
begin
	
	-- first row of q
	first_q1_1: q1
	port map	(
				in_q1 => in_h256,
				out_q1 => from_first_row(7 downto 0)
				);

	first_q0_1: q0
	port map	(
				in_q0 => in_h256,
				out_q0 => from_first_row(15 downto 8)
				);

	first_q0_2: q0
	port map	(
				in_q0 => in_h256,
				out_q0 => from_first_row(23 downto 16)
				);

	first_q1_2: q1
	port map	(
				in_q1 => in_h256,
				out_q1 => from_first_row(31 downto 24)
				);

	-- we perform the XOR of the results of the first row
	-- with first M of h (Mfirst_h256)
	to_second_row <= from_first_row XOR Mfirst_h256;

	-- second row of q
	second_q1_1: q1
	port map	(
				in_q1 => to_second_row(7 downto 0),
				out_q1 => from_second_row(7 downto 0)
				);

	second_q1_2: q1
	port map	(
				in_q1 => to_second_row(15 downto 8),
				out_q1 => from_second_row(15 downto 8)
				);

	second_q0_1: q0
	port map	(
				in_q0 => to_second_row(23 downto 16),
				out_q0 => from_second_row(23 downto 16)
				);

	second_q0_2: q0
	port map	(
				in_q0 => to_second_row(31 downto 24),
				out_q0 => from_second_row(31 downto 24)
				);

	-- we perform the XOR of the results of the second row
	-- with second M of h (Msecond_h256)
	to_third_row <= from_second_row XOR Msecond_h256;

	-- third row of q
	third_q0_1: q0
	port map	(
				in_q0 => to_third_row(7 downto 0),
				out_q0 => from_third_row(7 downto 0)
				);
	third_q1_1: q1
	port map	(
				in_q1 => to_third_row(15 downto 8),
				out_q1 => from_third_row(15 downto 8)
				);
	third_q0_2: q0
	port map	(
				in_q0 => to_third_row(23 downto 16),
				out_q0 => from_third_row(23 downto 16)
				);
	third_q1_2: q1
	port map	(
				in_q1 => to_third_row(31 downto 24),
				out_q1 => from_third_row(31 downto 24)
				);

	-- we perform the XOR of the results of the third row
	-- with third M of h (Mthird_h256)
	to_fourth_row <= from_third_row XOR Mthird_h256;

	-- fourth row of q
	fourth_q0_1: q0
	port map	(
				in_q0 => to_fourth_row(7 downto 0),
				out_q0 => from_fourth_row(7 downto 0)
				);
	fourth_q0_2: q0
	port map	(
				in_q0 => to_fourth_row(15 downto 8),
				out_q0 => from_fourth_row(15 downto 8)
				);
	fourth_q1_1: q1
	port map	(
				in_q1 => to_fourth_row(23 downto 16),
				out_q1 => from_fourth_row(23 downto 16)
				);
	fourth_q1_2: q1
	port map	(
				in_q1 => to_fourth_row(31 downto 24),
				out_q1 => from_fourth_row(31 downto 24)
				);
				
	-- we perform the fourth XOR
	to_fifth_row <= from_fourth_row XOR Mfourth_h256;
	
	-- the fifth row of q
	fifth_q1_1: q1
	port map	(
				in_q1 => to_fifth_row(7 downto 0),
				out_q1 => to_mds(7 downto 0)
				);
	fifth_q0_1: q0
	port map	(
				in_q0 => to_fifth_row(15 downto 8),
				out_q0 => to_mds(15 downto 8)
				);
	fifth_q1_2: q1
	port map	(
				in_q1 => to_fifth_row(23 downto 16),
				out_q1 => to_mds(23 downto 16)
				);
	fifth_q0_2: q0
	port map	(
				in_q0 => to_fifth_row(31 downto 24),
				out_q0 => to_mds(31 downto 24)
				);
				
	-- mds table
	mds_table: mds
	port map	(
				y0 => to_mds(7 downto 0),
				y1 => to_mds(15 downto 8),
				y2 => to_mds(23 downto 16),
				y3 => to_mds(31 downto 24),
				z0 => out_h256(7 downto 0),
				z1 => out_h256(15 downto 8),
				z2 => out_h256(23 downto 16),
				z3 => out_h256(31 downto 24)
				);

end h256_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


--
-- g function for 256 bits key
-- 

library ieee;
use ieee.std_logic_1164.all;

entity g_256 is
port	(
		in_g256,
		in_S0_g256,
		in_S1_g256,
		in_S2_g256,
		in_S3_g256		: in std_logic_vector(31 downto 0);
		out_g256		: out std_logic_vector(31 downto 0)
		);
end g_256;

architecture g256_arch of g_256 is

	-- we declare the internal signals
	signal	from_first_row,
			to_second_row,
			from_second_row,
			to_third_row,
			from_third_row,
			to_fourth_row,
			from_fourth_row,
			to_fifth_row,
			to_mds			: std_logic_vector(31 downto 0);

	component q0
	port	(
			in_q0 	: in std_logic_vector(7 downto 0);
			out_q0	: out std_logic_vector(7 downto 0)
			);
	end component;
	
	component q1
	port	(
			in_q1 	: in std_logic_vector(7 downto 0);
			out_q1	: out std_logic_vector(7 downto 0)
			);
	end component;

	component mds
	port	(
			y0,
			y1,
			y2,
			y3	: in std_logic_vector(7 downto 0);
			z0,
			z1,
			z2,
			z3	: out std_logic_vector(7 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- first row of q
	first_q1_1: q1
	port map	(
				in_q1 => in_g256(7 downto 0),
				out_q1 => from_first_row(7 downto 0)
				);

	first_q0_1: q0
	port map	(
				in_q0 => in_g256(15 downto 8),
				out_q0 => from_first_row(15 downto 8)
				);

	first_q0_2: q0
	port map	(
				in_q0 => in_g256(23 downto 16),
				out_q0 => from_first_row(23 downto 16)
				);

	first_q1_2: q1
	port map	(
				in_q1 => in_g256(31 downto 24),
				out_q1 => from_first_row(31 downto 24)
				);

	-- we perform the XOR of the results of the first row
	-- with S0
	to_second_row <= from_first_row XOR in_S0_g256;

	-- second row of q
	second_q1_1: q1
	port map	(
				in_q1 => to_second_row(7 downto 0),
				out_q1 => from_second_row(7 downto 0)
				);

	second_q1_2: q1
	port map	(
				in_q1 => to_second_row(15 downto 8),
				out_q1 => from_second_row(15 downto 8)
				);

	second_q0_1: q0
	port map	(
				in_q0 => to_second_row(23 downto 16),
				out_q0 => from_second_row(23 downto 16)
				);

	second_q0_2: q0
	port map	(
				in_q0 => to_second_row(31 downto 24),
				out_q0 => from_second_row(31 downto 24)
				);

	-- we perform the XOR of the results of the second row
	-- with S1
	to_third_row <= from_second_row XOR in_S1_g256;

	-- third row of q
	third_q0_1: q0
	port map	(
				in_q0 => to_third_row(7 downto 0),
				out_q0 => from_third_row(7 downto 0)
				);
	third_q1_1: q1
	port map	(
				in_q1 => to_third_row(15 downto 8),
				out_q1 => from_third_row(15 downto 8)
				);
	third_q0_2: q0
	port map	(
				in_q0 => to_third_row(23 downto 16),
				out_q0 => from_third_row(23 downto 16)
				);
	third_q1_2: q1
	port map	(
				in_q1 => to_third_row(31 downto 24),
				out_q1 => from_third_row(31 downto 24)
				);

	-- we perform the XOR of the results of the third row
	-- with S2
	to_fourth_row <= from_third_row XOR in_S2_g256;

	-- fourth row of q
	fourth_q0_1: q0
	port map	(
				in_q0 => to_fourth_row(7 downto 0),
				out_q0 => from_fourth_row(7 downto 0)
				);
	fourth_q0_2: q0
	port map	(
				in_q0 => to_fourth_row(15 downto 8),
				out_q0 => from_fourth_row(15 downto 8)
				);
	fourth_q1_1: q1
	port map	(
				in_q1 => to_fourth_row(23 downto 16),
				out_q1 => from_fourth_row(23 downto 16)
				);
	fourth_q1_2: q1
	port map	(
				in_q1 => to_fourth_row(31 downto 24),
				out_q1 => from_fourth_row(31 downto 24)
				);
				
	-- we perform the fourth XOR
	to_fifth_row <= from_fourth_row XOR in_S3_g256;
	
	-- the fifth row of q
	fifth_q1_1: q1
	port map	(
				in_q1 => to_fifth_row(7 downto 0),
				out_q1 => to_mds(7 downto 0)
				);
	fifth_q0_1: q0
	port map	(
				in_q0 => to_fifth_row(15 downto 8),
				out_q0 => to_mds(15 downto 8)
				);
	fifth_q1_2: q1
	port map	(
				in_q1 => to_fifth_row(23 downto 16),
				out_q1 => to_mds(23 downto 16)
				);
	fifth_q0_2: q0
	port map	(
				in_q0 => to_fifth_row(31 downto 24),
				out_q0 => to_mds(31 downto 24)
				);
				
	-- mds table
	mds_table: mds
	port map	(
				y0 => to_mds(7 downto 0),
				y1 => to_mds(15 downto 8),
				y2 => to_mds(23 downto 16),
				y3 => to_mds(31 downto 24),
				z0 => out_g256(7 downto 0),
				z1 => out_g256(15 downto 8),
				z2 => out_g256(23 downto 16),
				z3 => out_g256(31 downto 24)
				);

end g256_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


--
-- f function with 256 bits key
-- 

library ieee;
use ieee.std_logic_1164.all;

entity f_256 is
port	(
		up_in_f256,
		low_in_f256,
		S0_in_f256,
		S1_in_f256,
		S2_in_f256,
		S3_in_f256,
		up_key_f256,
		low_key_f256		: in std_logic_vector(31 downto 0);
		up_out_f256,
		low_out_f256		: out std_logic_vector(31 downto 0)
		);
end f_256;

architecture f256_arch of f_256 is

	-- we declare the internal signals 
	signal	from_shift_8,
			to_up_pht,
			to_low_pht,
			to_up_key,
			to_low_key,
			intermediate_carry1,
			intermediate_carry2	: std_logic_vector(31 downto 0);
	signal	zero					: std_logic;
	
	
	component g_256
	port	(
			in_g256,
			in_S0_g256,
			in_S1_g256,
			in_S2_g256,
			in_S3_g256	: in std_logic_vector(31 downto 0);
			out_g256		: out std_logic_vector(31 downto 0)
			);
	end component;
	
	component pht
	port	(
			up_in_pht,
			down_in_pht	: in std_logic_vector(31 downto 0);
			up_out_pht,
			down_out_pht	: out std_logic_vector(31 downto 0)
			);
	end component;

	component adder
	port	(
			in1_adder,
			in2_adder,
			in_carry_adder	: in std_logic;
			out_adder,
			out_carry_adder	: out std_logic
			);
	end component;

-- begin architecture description
begin

	-- we initialize zero
	zero <= '0';
	
	-- upper g_256
	upper_g256: g_256
	port map	(
				in_g256 => up_in_f256,
				in_S0_g256 => S0_in_f256,
				in_S1_g256 => S1_in_f256,
				in_S2_g256 => S2_in_f256,
				in_S3_g256 => S3_in_f256,
				out_g256 => to_up_pht
				);
		
	-- left rotation by 8
	from_shift_8(31 downto 8) <= low_in_f256(23 downto 0);
	from_shift_8(7 downto 0) <= low_in_f256(31 downto 24);
				
	-- lower g256
	lower_g256: g_256
	port map	(
				in_g256 => from_shift_8,
				in_S0_g256 => S0_in_f256,
				in_S1_g256 => S1_in_f256,
				in_S2_g256 => S2_in_f256,
				in_S3_g256 => S3_in_f256,
				out_g256 => to_low_pht
				);
					
	-- pht
	pht_transform: pht
	port map	(
				up_in_pht => to_up_pht,
				down_in_pht => to_low_pht,
				up_out_pht => to_up_key,
				down_out_pht => to_low_key
				);
				
	-- upper adder of 32 bits
	up_adder: for i in 0 to 31 generate
		first: if (i=0) generate
			the_adder: adder
			port map	(
						in1_adder => to_up_key(0),
						in2_adder => up_key_f256(0),
						in_carry_adder => zero,
						out_adder => up_out_f256(0),
						out_carry_adder => intermediate_carry1(0)
						);
		end generate first;
		the_rest: if (i>0) generate
			the_adders: adder
			port map	(
						in1_adder => to_up_key(i),
						in2_adder => up_key_f256(i),
						in_carry_adder => intermediate_carry1(i-1),
						out_adder => up_out_f256(i),
						out_carry_adder => intermediate_carry1(i)
						);
		end generate the_rest;
	end generate up_adder;

	-- lower adder of 32 bits
	low_adder: for i in 0 to 31 generate
		first1: if (i=0) generate
			the_adder1:adder
			port map	(
						in1_adder => to_low_key(0),
						in2_adder => low_key_f256(0),
						in_carry_adder => zero,
						out_adder => low_out_f256(0),
						out_carry_adder => intermediate_carry2(0)
						);
		end generate first1;
		the_rest1: if (i>0) generate
			the_adders1: adder
			port map	(
						in1_adder => to_low_key(i),
						in2_adder => low_key_f256(i),
						in_carry_adder => intermediate_carry2(i-1),
						out_adder => low_out_f256(i),
						out_carry_adder => intermediate_carry2(i)
						);
		end generate the_rest1;
	end generate low_adder;

end f256_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish key scheduler for 256 bits key input			   
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_keysched256 is
port	(
		odd_in_tk256,
		even_in_tk256		: in std_logic_vector(7 downto 0);
		in_key_tk256		: in std_logic_vector(255 downto 0);
		out_key_up_tk256,
		out_key_down_tk256			: out std_logic_vector(31 downto 0)
		);
end twofish_keysched256;
				
architecture twofish_keysched256_arch of twofish_keysched256 is

	-- we declare internal signals
	signal	to_up_pht,
			to_shift_8,
			from_shift_8,
			to_shift_9,
			M0, M1, M2, M3, M4, M5, M6, M7	: std_logic_vector(31 downto 0);

	signal	byte15, byte14, byte13, byte12, byte11, byte10,
			byte9, byte8, byte7, byte6, byte5, byte4,
			byte3, byte2, byte1, byte0,
			byte16, byte17, byte18, byte19,
			byte20, byte21, byte22, byte23,
			byte24, byte25, byte26, byte27,
			byte28, byte29, byte30, byte31 : std_logic_vector(7 downto 0);
																	   			
	-- we declare the components to be used
	component pht
	port	(
			up_in_pht,
			down_in_pht		: in std_logic_vector(31 downto 0);
			up_out_pht,
			down_out_pht	: out std_logic_vector(31 downto 0)
			);
	end component;

	component h_256 
	port	(
			in_h256			: in std_logic_vector(7 downto 0);
			Mfirst_h256,
			Msecond_h256,
			Mthird_h256,
			Mfourth_h256	: in std_logic_vector(31 downto 0);
			out_h256		: out std_logic_vector(31 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- we assign the input signal to the respective
	-- bytes as is described in the prototype
	-- splitting the input
	byte31 <= in_key_tk256(7 downto 0);
	byte30 <= in_key_tk256(15 downto 8);
	byte29 <= in_key_tk256(23 downto 16);
	byte28 <= in_key_tk256(31 downto 24);
	byte27 <= in_key_tk256(39 downto 32);
	byte26 <= in_key_tk256(47 downto 40);
	byte25 <= in_key_tk256(55 downto 48);
	byte24 <= in_key_tk256(63 downto 56);
	byte23 <= in_key_tk256(71 downto 64);
	byte22 <= in_key_tk256(79 downto 72);
	byte21 <= in_key_tk256(87 downto 80);
	byte20 <= in_key_tk256(95 downto 88);
	byte19 <= in_key_tk256(103 downto 96);
	byte18 <= in_key_tk256(111 downto 104);
	byte17 <= in_key_tk256(119 downto 112);
	byte16 <= in_key_tk256(127 downto 120);
	byte15 <= in_key_tk256(135 downto 128);
	byte14 <= in_key_tk256(143 downto 136);
	byte13 <= in_key_tk256(151 downto 144);
	byte12 <= in_key_tk256(159 downto 152);
	byte11 <= in_key_tk256(167 downto 160);
	byte10 <= in_key_tk256(175 downto 168);
	byte9 <= in_key_tk256(183 downto 176);
	byte8 <= in_key_tk256(191 downto 184);
	byte7 <= in_key_tk256(199 downto 192);
	byte6 <= in_key_tk256(207 downto 200);
	byte5 <= in_key_tk256(215 downto 208);
	byte4 <= in_key_tk256(223 downto 216);
	byte3 <= in_key_tk256(231 downto 224);
	byte2 <= in_key_tk256(239 downto 232);
	byte1 <= in_key_tk256(247 downto 240);
	byte0 <= in_key_tk256(255 downto 248);

	-- we form the M{0..7}
	M0 <= byte3 & byte2 & byte1 & byte0;
	M1 <= byte7 & byte6 & byte5 & byte4;
	M2 <= byte11 & byte10 & byte9 & byte8;
	M3 <= byte15 & byte14 & byte13 & byte12;
	M4 <= byte19 & byte18 & byte17 & byte16;
	M5 <= byte23 & byte22 & byte21 & byte20;
	M6 <= byte27 & byte26 & byte25 & byte24;
	M7 <= byte31 & byte30 & byte29 & byte28;

	-- upper h
	upper_h: h_256
	port map	(
				in_h256 => even_in_tk256,
				Mfirst_h256 => M6,
				Msecond_h256 => M4,
				Mthird_h256 => M2,
				Mfourth_h256 => M0,
				out_h256 => to_up_pht
				);
				
	-- lower h
	lower_h: h_256
	port map	(
				in_h256 => odd_in_tk256,
				Mfirst_h256 => M7,
				Msecond_h256 => M5,
				Mthird_h256 => M3,
				Mfourth_h256 => M1,
				out_h256 => to_shift_8
				);
				
	-- left rotate by 8
	from_shift_8(31 downto 8) <= to_shift_8(23 downto 0);
	from_shift_8(7 downto 0) <= to_shift_8(31 downto 24);
	
	-- pht transformation
	pht_transform: pht
	port map	(
				up_in_pht => to_up_pht,
				down_in_pht => from_shift_8,
				up_out_pht => out_key_up_tk256,
				down_out_pht => to_shift_9
				);
				
	-- left rotate by 9
	out_key_down_tk256(31 downto 9) <= to_shift_9(22 downto 0);
	out_key_down_tk256(8 downto 0) <= to_shift_9(31 downto 23);

end twofish_keysched256_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish S key component for 256 bits key			   
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_S256 is
port	(
		in_key_ts256		: in std_logic_vector(255 downto 0);
		out_Sfirst_ts256,
		out_Ssecond_ts256,
		out_Sthird_ts256,
		out_Sfourth_ts256			: out std_logic_vector(31 downto 0)
		);
end twofish_S256;
				
architecture twofish_S256_arch of twofish_S256 is
																		   			
	-- we declare the components to be used
	component reed_solomon256 
	port	(
			in_rs256			: in std_logic_vector(255 downto 0);
			out_Sfirst_rs256,
			out_Ssecond_rs256,
			out_Sthird_rs256,
			out_Sfourth_rs256		: out std_logic_vector(31 downto 0)
			);
	end component;
	
	signal twofish_key : std_logic_vector(255 downto 0);
	signal	byte15, byte14, byte13, byte12, byte11, byte10,
			byte9, byte8, byte7, byte6, byte5, byte4,
			byte3, byte2, byte1, byte0,
			byte16, byte17, byte18, byte19,
			byte20, byte21, byte22, byte23,
			byte24, byte25, byte26, byte27,
			byte28, byte29, byte30, byte31 : std_logic_vector(7 downto 0);

-- begin architecture description
begin

	-- splitting the input
	byte31 <= in_key_ts256(7 downto 0);
	byte30 <= in_key_ts256(15 downto 8);
	byte29 <= in_key_ts256(23 downto 16);
	byte28 <= in_key_ts256(31 downto 24);
	byte27 <= in_key_ts256(39 downto 32);
	byte26 <= in_key_ts256(47 downto 40);
	byte25 <= in_key_ts256(55 downto 48);
	byte24 <= in_key_ts256(63 downto 56);
	byte23 <= in_key_ts256(71 downto 64);
	byte22 <= in_key_ts256(79 downto 72);
	byte21 <= in_key_ts256(87 downto 80);
	byte20 <= in_key_ts256(95 downto 88);
	byte19 <= in_key_ts256(103 downto 96);
	byte18 <= in_key_ts256(111 downto 104);
	byte17 <= in_key_ts256(119 downto 112);
	byte16 <= in_key_ts256(127 downto 120);
	byte15 <= in_key_ts256(135 downto 128);
	byte14 <= in_key_ts256(143 downto 136);
	byte13 <= in_key_ts256(151 downto 144);
	byte12 <= in_key_ts256(159 downto 152);
	byte11 <= in_key_ts256(167 downto 160);
	byte10 <= in_key_ts256(175 downto 168);
	byte9 <= in_key_ts256(183 downto 176);
	byte8 <= in_key_ts256(191 downto 184);
	byte7 <= in_key_ts256(199 downto 192);
	byte6 <= in_key_ts256(207 downto 200);
	byte5 <= in_key_ts256(215 downto 208);
	byte4 <= in_key_ts256(223 downto 216);
	byte3 <= in_key_ts256(231 downto 224);
	byte2 <= in_key_ts256(239 downto 232);
	byte1 <= in_key_ts256(247 downto 240);
	byte0 <= in_key_ts256(255 downto 248);

	-- forming the key
	twofish_key <= byte31 & byte30 & byte29 & byte28 & byte27 & byte26 & byte25 & byte24 &
							byte23 & byte22 & byte21 & byte20 & byte19 & byte18 & byte17 & byte16 &
							byte15 & byte14 & byte13 & byte12 & byte11 & byte10 & byte9 & byte8 & byte7 & 
								byte6 & byte5 & byte4 & byte3 & byte2 & byte1 & byte0;


	-- the keys S0,1,2,3
	produce_S0_S1_S2_S3: reed_solomon256
	port map	(
				in_rs256 => twofish_key,
				out_Sfirst_rs256 => out_Sfirst_ts256,
				out_Ssecond_rs256 => out_Ssecond_ts256,
				out_Sthird_rs256 => out_Sthird_ts256,
				out_Sfourth_rs256 => out_Sfourth_ts256
				);


end twofish_S256_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish whitening key scheduler for 256 bits key input			   
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_whit_keysched256 is
port	(
		in_key_twk256		: in std_logic_vector(255 downto 0);
		out_K0_twk256,
		out_K1_twk256,
		out_K2_twk256,
		out_K3_twk256,
		out_K4_twk256,
		out_K5_twk256,
		out_K6_twk256,
		out_K7_twk256			: out std_logic_vector(31 downto 0)
		);
end twofish_whit_keysched256;
				
architecture twofish_whit_keysched256_arch of twofish_whit_keysched256 is

	-- we declare internal signals
	signal	to_up_pht_1,
			to_shift_8_1,
			from_shift_8_1,
			to_shift_9_1,
			to_up_pht_2,
			to_shift_8_2,
			from_shift_8_2,
			to_shift_9_2,
			to_up_pht_3,
			to_shift_8_3,
			from_shift_8_3,
			to_shift_9_3,
			to_up_pht_4,
			to_shift_8_4,
			from_shift_8_4,
			to_shift_9_4,
			M0, M1, M2, M3, M4, M5, M6, M7	: std_logic_vector(31 downto 0);

	signal	byte15, byte14, byte13, byte12, byte11, byte10,
			byte9, byte8, byte7, byte6, byte5, byte4,
			byte3, byte2, byte1, byte0,
			byte16, byte17, byte18, byte19,
			byte20, byte21, byte22, byte23,
			byte24, byte25, byte26, byte27,
			byte28, byte29, byte30, byte31 : std_logic_vector(7 downto 0);

	signal		zero, one, two, three, four, five, six, seven	: std_logic_vector(7 downto 0);
																		   			
	-- we declare the components to be used
	component pht
	port	(
			up_in_pht,
			down_in_pht		: in std_logic_vector(31 downto 0);
			up_out_pht,
			down_out_pht	: out std_logic_vector(31 downto 0)
			);
	end component;

	component h_256 
	port	(
			in_h256			: in std_logic_vector(7 downto 0);
			Mfirst_h256,
			Msecond_h256,
			Mthird_h256,
			Mfourth_h256	: in std_logic_vector(31 downto 0);
			out_h256		: out std_logic_vector(31 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- we produce the first eight numbers
	zero <= "00000000";
	one <= "00000001";
	two <= "00000010";
	three <= "00000011";
	four <= "00000100";
	five <= "00000101";
	six <= "00000110";
	seven <= "00000111";

	-- we assign the input signal to the respective
	-- bytes as is described in the prototype
	byte31 <= in_key_twk256(7 downto 0);
	byte30 <= in_key_twk256(15 downto 8);
	byte29 <= in_key_twk256(23 downto 16);
	byte28 <= in_key_twk256(31 downto 24);
	byte27 <= in_key_twk256(39 downto 32);
	byte26 <= in_key_twk256(47 downto 40);
	byte25 <= in_key_twk256(55 downto 48);
	byte24 <= in_key_twk256(63 downto 56);
	byte23 <= in_key_twk256(71 downto 64);
	byte22 <= in_key_twk256(79 downto 72);
	byte21 <= in_key_twk256(87 downto 80);
	byte20 <= in_key_twk256(95 downto 88);
	byte19 <= in_key_twk256(103 downto 96);
	byte18 <= in_key_twk256(111 downto 104);
	byte17 <= in_key_twk256(119 downto 112);
	byte16 <= in_key_twk256(127 downto 120);
	byte15 <= in_key_twk256(135 downto 128);
	byte14 <= in_key_twk256(143 downto 136);
	byte13 <= in_key_twk256(151 downto 144);
	byte12 <= in_key_twk256(159 downto 152);
	byte11 <= in_key_twk256(167 downto 160);
	byte10 <= in_key_twk256(175 downto 168);
	byte9 <= in_key_twk256(183 downto 176);
	byte8 <= in_key_twk256(191 downto 184);
	byte7 <= in_key_twk256(199 downto 192);
	byte6 <= in_key_twk256(207 downto 200);
	byte5 <= in_key_twk256(215 downto 208);
	byte4 <= in_key_twk256(223 downto 216);
	byte3 <= in_key_twk256(231 downto 224);
	byte2 <= in_key_twk256(239 downto 232);
	byte1 <= in_key_twk256(247 downto 240);
	byte0 <= in_key_twk256(255 downto 248);

	-- we form the M{0..7}
	M0 <= byte3 & byte2 & byte1 & byte0;
	M1 <= byte7 & byte6 & byte5 & byte4;
	M2 <= byte11 & byte10 & byte9 & byte8;
	M3 <= byte15 & byte14 & byte13 & byte12;
	M4 <= byte19 & byte18 & byte17 & byte16;
	M5 <= byte23 & byte22 & byte21 & byte20;
	M6 <= byte27 & byte26 & byte25 & byte24;
	M7 <= byte31 & byte30 & byte29 & byte28;

	-- we produce the keys for the whitening steps
	-- keys K0,1
	-- upper h
	upper_h1: h_256
	port map	(
				in_h256 => zero,
				Mfirst_h256 => M6,
				Msecond_h256 => M4,
				Mthird_h256 => M2,
				Mfourth_h256 => M0,
				out_h256 => to_up_pht_1
				);
				
	-- lower h
	lower_h1: h_256
	port map	(
				in_h256 => one,
				Mfirst_h256 => M7,
				Msecond_h256 => M5,
				Mthird_h256 => M3,
				Mfourth_h256 => M1,
				out_h256 => to_shift_8_1
				);
				
	-- left rotate by 8
	from_shift_8_1(31 downto 8) <= to_shift_8_1(23 downto 0);
	from_shift_8_1(7 downto 0) <= to_shift_8_1(31 downto 24);
	
	-- pht transformation
	pht_transform1: pht
	port map	(
				up_in_pht => to_up_pht_1,
				down_in_pht => from_shift_8_1,
				up_out_pht => out_K0_twk256,
				down_out_pht => to_shift_9_1
				);
				
	-- left rotate by 9
	out_K1_twk256(31 downto 9) <= to_shift_9_1(22 downto 0);
	out_K1_twk256(8 downto 0) <= to_shift_9_1(31 downto 23);

	-- keys K2,3
	-- upper h
	upper_h2: h_256
	port map	(
				in_h256 => two,
				Mfirst_h256 => M6,
				Msecond_h256 => M4,
				Mthird_h256 => M2,
				Mfourth_h256 => M0,
				out_h256 => to_up_pht_2
				);
				
	-- lower h
	lower_h2: h_256
	port map	(
				in_h256 => three,
				Mfirst_h256 => M7,
				Msecond_h256 => M5,
				Mthird_h256 => M3,
				Mfourth_h256 => M1,
				out_h256 => to_shift_8_2
				);
				
	-- left rotate by 8
	from_shift_8_2(31 downto 8) <= to_shift_8_2(23 downto 0);
	from_shift_8_2(7 downto 0) <= to_shift_8_2(31 downto 24);
	
	-- pht transformation
	pht_transform2: pht
	port map	(
				up_in_pht => to_up_pht_2,
				down_in_pht => from_shift_8_2,
				up_out_pht => out_K2_twk256,
				down_out_pht => to_shift_9_2
				);
				
	-- left rotate by 9
	out_K3_twk256(31 downto 9) <= to_shift_9_2(22 downto 0);
	out_K3_twk256(8 downto 0) <= to_shift_9_2(31 downto 23);

	-- keys K4,5
	-- upper h
	upper_h3: h_256
	port map	(
				in_h256 => four,
				Mfirst_h256 => M6,
				Msecond_h256 => M4,
				Mthird_h256 => M2,
				Mfourth_h256 => M0,
				out_h256 => to_up_pht_3
				);
				
	-- lower h
	lower_h3: h_256
	port map	(
				in_h256 => five,
				Mfirst_h256 => M7,
				Msecond_h256 => M5,
				Mthird_h256 => M3,
				Mfourth_h256 => M1,
				out_h256 => to_shift_8_3
				);
				
	-- left rotate by 8
	from_shift_8_3(31 downto 8) <= to_shift_8_3(23 downto 0);
	from_shift_8_3(7 downto 0) <= to_shift_8_3(31 downto 24);
	
	-- pht transformation
	pht_transform3: pht
	port map	(
				up_in_pht => to_up_pht_3,
				down_in_pht => from_shift_8_3,
				up_out_pht => out_K4_twk256,
				down_out_pht => to_shift_9_3
				);
				
	-- left rotate by 9
	out_K5_twk256(31 downto 9) <= to_shift_9_3(22 downto 0);
	out_K5_twk256(8 downto 0) <= to_shift_9_3(31 downto 23);

	-- keys K6,7
	-- upper h
	upper_h4: h_256
	port map	(
				in_h256 => six,
				Mfirst_h256 => M6,
				Msecond_h256 => M4,
				Mthird_h256 => M2,
				Mfourth_h256 => M0,
				out_h256 => to_up_pht_4
				);
				
	-- lower h
	lower_h4: h_256
	port map	(
				in_h256 => seven,
				Mfirst_h256 => M7,
				Msecond_h256 => M5,
				Mthird_h256 => M3,
				Mfourth_h256 => M1,
				out_h256 => to_shift_8_4
				);
				
	-- left rotate by 8
	from_shift_8_4(31 downto 8) <= to_shift_8_4(23 downto 0);
	from_shift_8_4(7 downto 0) <= to_shift_8_4(31 downto 24);
	
	-- pht transformation
	pht_transform4: pht
	port map	(
				up_in_pht => to_up_pht_4,
				down_in_pht => from_shift_8_4,
				up_out_pht => out_K6_twk256,
				down_out_pht => to_shift_9_4
				);
				
	-- left rotate by 9
	out_K7_twk256(31 downto 9) <= to_shift_9_4(22 downto 0);
	out_K7_twk256(8 downto 0) <= to_shift_9_4(31 downto 23);

end twofish_whit_keysched256_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish encryption round with 256 bit key input
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_encryption_round256 is
port	(
		in1_ter256,
		in2_ter256,
		in3_ter256,
		in4_ter256,
		in_Sfirst_ter256,
		in_Ssecond_ter256,
		in_Sthird_ter256,
		in_Sfourth_ter256,
		in_key_up_ter256,
		in_key_down_ter256		: in std_logic_vector(31 downto 0);
		out1_ter256,
		out2_ter256,
		out3_ter256,
		out4_ter256			: out std_logic_vector(31 downto 0)
		);
end twofish_encryption_round256;

architecture twofish_encryption_round256_arch of twofish_encryption_round256 is
					   
	-- we declare internal signals
	signal	to_left_shift,
			from_right_shift,
			to_xor_with3,
			to_xor_with4			: std_logic_vector(31 downto 0);
			
	component f_256
	port	(
			up_in_f256,
			low_in_f256,
			S0_in_f256,
			S1_in_f256,
			S2_in_f256,
			S3_in_f256,
			up_key_f256,
			low_key_f256			: in std_logic_vector(31 downto 0);
			up_out_f256,
			low_out_f256			: out std_logic_vector(31 downto 0)
			);
	end component;

-- begin architecture description
begin

	-- we declare f_256
	function_f: f_256
	port map	(
				up_in_f256 => in1_ter256,
				low_in_f256 => in2_ter256,
				S0_in_f256 => in_Sfirst_ter256,	
				S1_in_f256 => in_Ssecond_ter256,
				S2_in_f256 => in_Sthird_ter256,
				S3_in_f256 => in_Sfourth_ter256,
				up_key_f256 => in_key_up_ter256,
				low_key_f256 => in_key_down_ter256,
				up_out_f256 => to_xor_with3,
				low_out_f256 => to_xor_with4
				);
	
	-- we perform the exchange
	-- in1_ter256 -> out3_ter256
	-- in2_ter256 -> out4_ter256
	-- in3_ter256 -> out1_ter256
	-- in4_ter256 -> out2_ter256	
	
	-- we perform the left xor between the upper f function and
	-- the third input (input 3)
	to_left_shift <= to_xor_with3 XOR in3_ter256;
	
	-- we perform the left side rotation to the right by 1 and
	-- we perform the exchange too
	out1_ter256(30 downto 0) <= to_left_shift(31 downto 1);
	out1_ter256(31) <= to_left_shift(0);
	
	-- we perform the right side rotation to the left by 1
	from_right_shift(0) <= in4_ter256(31);
	from_right_shift(31 downto 1) <= in4_ter256(30 downto 0);
	
	-- we perform the right xor between the lower f function and 
	-- the fourth input (input 4)
	out2_ter256 <= from_right_shift XOR to_xor_with4;
	
	-- we perform the last exchanges
	out3_ter256 <= in1_ter256;
	out4_ter256 <= in2_ter256;

end twofish_encryption_round256_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- twofish decryption round with 256 bit key input
--

library ieee;
use ieee.std_logic_1164.all;

entity twofish_decryption_round256 is
port	(
		in1_tdr256,
		in2_tdr256,
		in3_tdr256,
		in4_tdr256,
		in_Sfirst_tdr256,
		in_Ssecond_tdr256,
		in_Sthird_tdr256,
		in_Sfourth_tdr256,
		in_key_up_tdr256,
		in_key_down_tdr256	: in std_logic_vector(31 downto 0);
		out1_tdr256,
		out2_tdr256,
		out3_tdr256,
		out4_tdr256			: out std_logic_vector(31 downto 0)
		);
end twofish_decryption_round256;

architecture twofish_decryption_round256_arch of twofish_decryption_round256 is

	signal	to_xor_with3,
			to_xor_with4,
			to_xor_with_up_f,
			from_xor_with_down_f	: std_logic_vector(31 downto 0);

	component f_256 
	port	(
			up_in_f256,
			low_in_f256,
			S0_in_f256,
			S1_in_f256,
			S2_in_f256,
			S3_in_f256,
			up_key_f256,
			low_key_f256	: in std_logic_vector(31 downto 0);
			up_out_f256,
			low_out_f256		: out std_logic_vector(31 downto 0)
			);
	end component;

begin

	-- we instantiate f function
	function_f: f_256
	port map	(
				up_in_f256 => in1_tdr256,
				low_in_f256 => in2_tdr256,
				S0_in_f256 => in_Sfirst_tdr256,
				S1_in_f256 => in_Ssecond_tdr256,
				S2_in_f256 => in_Sthird_tdr256,
				S3_in_f256 => in_Sfourth_tdr256,
				up_key_f256 => in_key_up_tdr256,
				low_key_f256 => in_key_down_tdr256,
				up_out_f256 => to_xor_with3,
				low_out_f256 => to_xor_with4
				);
				
	-- output 1: input3 with upper f
	-- we first rotate the input3 by 1 bit leftwise
	to_xor_with_up_f(0) <= in3_tdr256(31);
	to_xor_with_up_f(31 downto 1) <= in3_tdr256(30 downto 0);
	
	-- we perform the XOR with the upper output of f and the result
	-- is ouput 1
	out1_tdr256 <= to_xor_with_up_f XOR to_xor_with3;
	
	-- output 2: input4 with lower f
	-- we perform the XOR with the lower output of f
	from_xor_with_down_f <= in4_tdr256 XOR to_xor_with4;
	
	-- we perform the rotation by 1 bit rightwise and the result 
	-- is output2
	out2_tdr256(31) <= from_xor_with_down_f(0);
	out2_tdr256(30 downto 0) <= from_xor_with_down_f(31 downto 1);
	
	-- we assign outputs 3 and 4
	out3_tdr256 <= in1_tdr256;
	out4_tdr256 <= in2_tdr256;

end twofish_decryption_round256_arch;
