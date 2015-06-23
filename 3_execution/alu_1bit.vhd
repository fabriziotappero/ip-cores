--
-- ALU de 1 Bit
--
-- Licencia: Copyright 2008 Emmanuel Luján
--
-- 	This program is free software; you can redistribute it and/or
-- 	modify it under the terms of the GNU General Public License as
-- 	published by the Free Software Foundation; either version 2 of
-- 	the License, or (at your option) any later version. This program
-- 	is distributed in the hope that it will be useful, but WITHOUT
-- 	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- 	or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
-- 	License for more details. You should have received a copy of the
-- 	GNU General Public License along with this program; if not, write
-- 	to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
-- 	Boston, MA 02110-1301 USA.
-- 
-- Autor:	Emmanuel Luján
-- Email:	info@emmanuellujan.com.ar
-- Versión:	1.0
--

library ieee;
use ieee.STD_LOGIC_1164.all;

entity ALU_1BIT is 
	port(
			X	: in STD_LOGIC;
			Y	: in STD_LOGIC;
			LESS	: in STD_LOGIC;
			BINVERT : in STD_LOGIC;
			CIN	: in STD_LOGIC;
			OP1	: in STD_LOGIC;
			OP0	: in STD_LOGIC;
			RES	: out STD_LOGIC;
			COUT	: out STD_LOGIC;
			SET	: out STD_LOGIC
	);
end;

architecture ALU_1BIT_ARC of ALU_1BIT is

-- Declaración de componentes
	component FULL_ADDER is   
		port(
			X	: in	STD_LOGIC;
			Y	: in	STD_LOGIC;
			CIN	: in	STD_LOGIC;
			COUT	: out	STD_LOGIC;
			R	: out	STD_LOGIC
		);
	end component FULL_ADDER;

-- Declaración de señales
	signal NEW_Y		: STD_LOGIC;
	signal R0,R1,R2,R3	: STD_LOGIC;
	signal RES_AUX		: STD_LOGIC;

begin

	MUX_BINV:
		process(BINVERT,Y) is
		begin
			if BINVERT='0' then
				NEW_Y <= Y;
			else
				NEW_Y <= not Y;
			end if;
		end process MUX_BINV;

	R0 <= X and NEW_Y;
	R1 <= X or NEW_Y;

	FULLADDER_ALU:
		FULL_ADDER port map(
			X	=> X,
			Y	=> NEW_Y,
			CIN	=> CIN,
			COUT	=> COUT,
			R	=> R2
		);

	R3 <= LESS;

	MUX_RES_ALU:
		process(OP1,OP0,R0,R1,R2,R3) is
		begin
			if (OP1 = '0' and OP0 = '0') then
				RES_AUX <= R0;
			elsif (OP1 = '0' and OP0 = '1') then
				RES_AUX <= R1;
			elsif (OP1 = '1' and OP0 = '0') then
				RES_AUX <= R2;
			elsif (OP1 = '1' and OP0 = '1') then
				RES_AUX <= R3;
			end if;
		end process MUX_RES_ALU;

	RES <= RES_AUX;
	SET <= R2;

end ALU_1BIT_ARC;
