----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	1/4/2010 
-- Design Name		8bit CRC generator
-- Module Name:    	crcgen - Behavioral 
-- File Name:		crcgen.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	Adapted from "Parallel CRC Realization", by Guiseppe
--					Campobello, Guiseppe Patanè and Marco Russo, IEEE
--					Transactions on Computers, Vol.52, No.10, October 2003.
--					Adjustments have been made to the layout, the reset has been
--					converted to a synchronous reset instead of the asynchronous
--					reset from the original paper, and a clock enable has been
--					added.
--
-- Revision: 
-- Revision 3.2 - 	Initial release
--
-- Copyright 2010
--
-- This module is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This module is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this module.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 
use work.crcpack.all;


entity crcgen is
	Port (	reset		: in	STD_LOGIC;
			clk 		: in	STD_LOGIC;
			clk_en		: in	STD_LOGIC;
			Din			: in	STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			Xout		: out	STD_LOGIC_VECTOR(CRCDIM - 1 downto 0));
end crcgen;


architecture rtl of crcgen is
	signal X			: STD_LOGIC_VECTOR(CRCDIM - 1 downto 0);
	signal X1			: STD_LOGIC_VECTOR(CRCDIM - 1 downto 0);
	signal X2			: STD_LOGIC_VECTOR(CRCDIM - 1 downto 0);
	signal Dins			: STD_LOGIC_VECTOR(CRCDIM - 1 downto 0);
begin

	process(Din)
		variable Dinv 	: STD_LOGIC_VECTOR(CRCDIM - 1 downto 0);
	begin
		Dinv := (others => '0');
		Dinv(DATA_WIDTH - 1 downto 0) := Din;						--LFSR:
		Dins <= Dinv;
	end process;

	X2 <= X ; 			--LFSR

	process(clk)
	begin
		if(clk = '1' and clk'EVENT) then
			if(reset = '1') then
				X <= (others => '0');
			elsif(clk_en = '1') then
				X <= X1 xor Dins ;	--LFSR
			end if;
		end if;
	end process;

	Xout <= X;

--This process builds matrix M=F^w
	process(X2)
		variable Xtemp	: STD_LOGIC_VECTOR(CRCDIM - 1 downto 0);	 
		variable vect	: STD_LOGIC_VECTOR(CRCDIM - 1 downto 0);	 
		variable vect2	: STD_LOGIC_VECTOR(CRCDIM - 1 downto 0);	 
		variable M		: matrix;
		variable F 		: matrix;
	begin
	--Matrix F
		F(0) := CRC(CRCDIM - 1 downto 0);
		for i in 0 to CRCDIM - 2  loop
			vect := (others => '0');
			vect(CRCDIM - i - 1) := '1';
			F(i+1) := vect;
		end loop;
	--Matrix M=F?w
		M(DATA_WIDTH - 1) := CRC(CRCDIM - 1 downto 0);
		for k in 2 to DATA_WIDTH loop
			vect2 := M(DATA_WIDTH - k + 1 );
			vect := (others => '0');
			for i in 0 to CRCDIM - 1 loop
				if(vect2(CRCDIM - 1 - i) = '1') then
					vect := vect xor F(i);
				end if;
			end loop;
			M(DATA_WIDTH - k) := vect;
		end loop;
		for k in DATA_WIDTH - 1 to CRCDIM - 1 loop
			M(k) := F(k - DATA_WIDTH + 1);
		end loop;

--Combinatorial logic equations : X1 = M ( x ) X

		Xtemp := (others => '0');
		for i in 0 to CRCDIM - 1 loop
			vect := M(i);
			for j in 0 to CRCDIM - 1 loop
				if(vect(j) = '1') then
					Xtemp(j) := Xtemp(j) xor X2(CRCDIM - 1 - i);
				end if;
			end loop;
		end loop;
		X1 <= Xtemp;
	
	end process;
end rtl;
