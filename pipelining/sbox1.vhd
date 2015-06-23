
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/14/2007
-- Last Update:   04/09/2008
-- Project Name:  camellia-vhdl
-- Description:   Dual-port SBOX1
--
-- Copyright (C) 2007  Paolo Fulgoni
-- This file is part of camellia-vhdl.
-- camellia-vhdl is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
-- camellia-vhdl is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- The Camellia cipher algorithm is 128 bit cipher developed by NTT and
-- Mitsubishi Electric researchers.
-- http://info.isl.ntt.co.jp/crypt/eng/camellia/
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;


entity SBOX1 is
    port  (
    		clk   : IN  STD_LOGIC;
            addra : IN  STD_LOGIC_VECTOR(0 to 7);
            addrb : IN  STD_LOGIC_VECTOR(0 to 7);
            douta : OUT STD_LOGIC_VECTOR(0 to 7);
            doutb : OUT STD_LOGIC_VECTOR(0 to 7)
            );
end SBOX1;

architecture RTL of SBOX1 is

	subtype ROM_WORD is STD_LOGIC_VECTOR (0 to 7);
	type ROM_TABLE is array (0 to 255) of ROM_WORD; 

	constant ROM: ROM_TABLE := ROM_TABLE'( 
		ROM_WORD'(X"70"),
		ROM_WORD'(X"82"),
		ROM_WORD'(X"2C"),
		ROM_WORD'(X"EC"),
		ROM_WORD'(X"B3"),
		ROM_WORD'(X"27"),
		ROM_WORD'(X"C0"),
		ROM_WORD'(X"E5"),
		ROM_WORD'(X"E4"),
		ROM_WORD'(X"85"),
		ROM_WORD'(X"57"),
		ROM_WORD'(X"35"),
		ROM_WORD'(X"EA"),
		ROM_WORD'(X"0C"),
		ROM_WORD'(X"AE"),
		ROM_WORD'(X"41"),
		ROM_WORD'(X"23"),
		ROM_WORD'(X"EF"),
		ROM_WORD'(X"6B"),
		ROM_WORD'(X"93"),
		ROM_WORD'(X"45"),
		ROM_WORD'(X"19"),
		ROM_WORD'(X"A5"),
		ROM_WORD'(X"21"),
		ROM_WORD'(X"ED"),
		ROM_WORD'(X"0E"),
		ROM_WORD'(X"4F"),
		ROM_WORD'(X"4E"),
		ROM_WORD'(X"1D"),
		ROM_WORD'(X"65"),
		ROM_WORD'(X"92"),
		ROM_WORD'(X"BD"),
		ROM_WORD'(X"86"),
		ROM_WORD'(X"B8"),
		ROM_WORD'(X"AF"),
		ROM_WORD'(X"8F"),
		ROM_WORD'(X"7C"),
		ROM_WORD'(X"EB"),
		ROM_WORD'(X"1F"),
		ROM_WORD'(X"CE"),
		ROM_WORD'(X"3E"),
		ROM_WORD'(X"30"),
		ROM_WORD'(X"DC"),
		ROM_WORD'(X"5F"),
		ROM_WORD'(X"5E"),
		ROM_WORD'(X"C5"),
		ROM_WORD'(X"0B"),
		ROM_WORD'(X"1A"),
		ROM_WORD'(X"A6"),
		ROM_WORD'(X"E1"),
		ROM_WORD'(X"39"),
		ROM_WORD'(X"CA"),
		ROM_WORD'(X"D5"),
		ROM_WORD'(X"47"),
		ROM_WORD'(X"5D"),
		ROM_WORD'(X"3D"),
		ROM_WORD'(X"D9"),
		ROM_WORD'(X"01"),
		ROM_WORD'(X"5A"),
		ROM_WORD'(X"D6"),
		ROM_WORD'(X"51"),
		ROM_WORD'(X"56"),
		ROM_WORD'(X"6C"),
		ROM_WORD'(X"4D"),
		ROM_WORD'(X"8B"),
		ROM_WORD'(X"0D"),
		ROM_WORD'(X"9A"),
		ROM_WORD'(X"66"),
		ROM_WORD'(X"FB"),
		ROM_WORD'(X"CC"),
		ROM_WORD'(X"B0"),
		ROM_WORD'(X"2D"),
		ROM_WORD'(X"74"),
		ROM_WORD'(X"12"),
		ROM_WORD'(X"2B"),
		ROM_WORD'(X"20"),
		ROM_WORD'(X"F0"),
		ROM_WORD'(X"B1"),
		ROM_WORD'(X"84"),
		ROM_WORD'(X"99"),
		ROM_WORD'(X"DF"),
		ROM_WORD'(X"4C"),
		ROM_WORD'(X"CB"),
		ROM_WORD'(X"C2"),
		ROM_WORD'(X"34"),
		ROM_WORD'(X"7E"),
		ROM_WORD'(X"76"),
		ROM_WORD'(X"05"),
		ROM_WORD'(X"6D"),
		ROM_WORD'(X"B7"),
		ROM_WORD'(X"A9"),
		ROM_WORD'(X"31"),
		ROM_WORD'(X"D1"),
		ROM_WORD'(X"17"),
		ROM_WORD'(X"04"),
		ROM_WORD'(X"D7"),
		ROM_WORD'(X"14"),
		ROM_WORD'(X"58"),
		ROM_WORD'(X"3A"),
		ROM_WORD'(X"61"),
		ROM_WORD'(X"DE"),
		ROM_WORD'(X"1B"),
		ROM_WORD'(X"11"),
		ROM_WORD'(X"1C"),
		ROM_WORD'(X"32"),
		ROM_WORD'(X"0F"),
		ROM_WORD'(X"9C"),
		ROM_WORD'(X"16"),
		ROM_WORD'(X"53"),
		ROM_WORD'(X"18"),
		ROM_WORD'(X"F2"),
		ROM_WORD'(X"22"),
		ROM_WORD'(X"FE"),
		ROM_WORD'(X"44"),
		ROM_WORD'(X"CF"),
		ROM_WORD'(X"B2"),
		ROM_WORD'(X"C3"),
		ROM_WORD'(X"B5"),
		ROM_WORD'(X"7A"),
		ROM_WORD'(X"91"),
		ROM_WORD'(X"24"),
		ROM_WORD'(X"08"),
		ROM_WORD'(X"E8"),
		ROM_WORD'(X"A8"),
		ROM_WORD'(X"60"),
		ROM_WORD'(X"FC"),
		ROM_WORD'(X"69"),
		ROM_WORD'(X"50"),
		ROM_WORD'(X"AA"),
		ROM_WORD'(X"D0"),
		ROM_WORD'(X"A0"),
		ROM_WORD'(X"7D"),
		ROM_WORD'(X"A1"),
		ROM_WORD'(X"89"),
		ROM_WORD'(X"62"),
		ROM_WORD'(X"97"),
		ROM_WORD'(X"54"),
		ROM_WORD'(X"5B"),
		ROM_WORD'(X"1E"),
		ROM_WORD'(X"95"),
		ROM_WORD'(X"E0"),
		ROM_WORD'(X"FF"),
		ROM_WORD'(X"64"),
		ROM_WORD'(X"D2"),
		ROM_WORD'(X"10"),
		ROM_WORD'(X"C4"),
		ROM_WORD'(X"00"),
		ROM_WORD'(X"48"),
		ROM_WORD'(X"A3"),
		ROM_WORD'(X"F7"),
		ROM_WORD'(X"75"),
		ROM_WORD'(X"DB"),
		ROM_WORD'(X"8A"),
		ROM_WORD'(X"03"),
		ROM_WORD'(X"E6"),
		ROM_WORD'(X"DA"),
		ROM_WORD'(X"09"),
		ROM_WORD'(X"3F"),
		ROM_WORD'(X"DD"),
		ROM_WORD'(X"94"),
		ROM_WORD'(X"87"),
		ROM_WORD'(X"5C"),
		ROM_WORD'(X"83"),
		ROM_WORD'(X"02"),
		ROM_WORD'(X"CD"),
		ROM_WORD'(X"4A"),
		ROM_WORD'(X"90"),
		ROM_WORD'(X"33"),
		ROM_WORD'(X"73"),
		ROM_WORD'(X"67"),
		ROM_WORD'(X"F6"),
		ROM_WORD'(X"F3"),
		ROM_WORD'(X"9D"),
		ROM_WORD'(X"7F"),
		ROM_WORD'(X"BF"),
		ROM_WORD'(X"E2"),
		ROM_WORD'(X"52"),
		ROM_WORD'(X"9B"),
		ROM_WORD'(X"D8"),
		ROM_WORD'(X"26"),
		ROM_WORD'(X"C8"),
		ROM_WORD'(X"37"),
		ROM_WORD'(X"C6"),
		ROM_WORD'(X"3B"),
		ROM_WORD'(X"81"),
		ROM_WORD'(X"96"),
		ROM_WORD'(X"6F"),
		ROM_WORD'(X"4B"),
		ROM_WORD'(X"13"),
		ROM_WORD'(X"BE"),
		ROM_WORD'(X"63"),
		ROM_WORD'(X"2E"),
		ROM_WORD'(X"E9"),
		ROM_WORD'(X"79"),
		ROM_WORD'(X"A7"),
		ROM_WORD'(X"8C"),
		ROM_WORD'(X"9F"),
		ROM_WORD'(X"6E"),
		ROM_WORD'(X"BC"),
		ROM_WORD'(X"8E"),
		ROM_WORD'(X"29"),
		ROM_WORD'(X"F5"),
		ROM_WORD'(X"F9"),
		ROM_WORD'(X"B6"),
		ROM_WORD'(X"2F"),
		ROM_WORD'(X"FD"),
		ROM_WORD'(X"B4"),
		ROM_WORD'(X"59"),
		ROM_WORD'(X"78"),
		ROM_WORD'(X"98"),
		ROM_WORD'(X"06"),
		ROM_WORD'(X"6A"),
		ROM_WORD'(X"E7"),
		ROM_WORD'(X"46"),
		ROM_WORD'(X"71"),
		ROM_WORD'(X"BA"),
		ROM_WORD'(X"D4"),
		ROM_WORD'(X"25"),
		ROM_WORD'(X"AB"),
		ROM_WORD'(X"42"),
		ROM_WORD'(X"88"),
		ROM_WORD'(X"A2"),
		ROM_WORD'(X"8D"),
		ROM_WORD'(X"FA"),
		ROM_WORD'(X"72"),
		ROM_WORD'(X"07"),
		ROM_WORD'(X"B9"),
		ROM_WORD'(X"55"),
		ROM_WORD'(X"F8"),
		ROM_WORD'(X"EE"),
		ROM_WORD'(X"AC"),
		ROM_WORD'(X"0A"),
		ROM_WORD'(X"36"),
		ROM_WORD'(X"49"),
		ROM_WORD'(X"2A"),
		ROM_WORD'(X"68"),
		ROM_WORD'(X"3C"),
		ROM_WORD'(X"38"),
		ROM_WORD'(X"F1"),
		ROM_WORD'(X"A4"),
		ROM_WORD'(X"40"),
		ROM_WORD'(X"28"),
		ROM_WORD'(X"D3"),
		ROM_WORD'(X"7B"),
		ROM_WORD'(X"BB"),
		ROM_WORD'(X"C9"),
		ROM_WORD'(X"43"),
		ROM_WORD'(X"C1"),
		ROM_WORD'(X"15"),
		ROM_WORD'(X"E3"),
		ROM_WORD'(X"AD"),
		ROM_WORD'(X"F4"),
		ROM_WORD'(X"77"),
		ROM_WORD'(X"C7"),
		ROM_WORD'(X"80"),
		ROM_WORD'(X"9E")
	);
	
	begin

	PORT_A : process(clk)
	begin
		if(rising_edge(clk)) then
			douta <= ROM(conv_integer(addra));
		end if;
	end process;

	PORT_B : process(clk)
	begin
		if(rising_edge(clk)) then
			doutb <= ROM(conv_integer(addrb));
		end if;
	end process;

end RTL;
