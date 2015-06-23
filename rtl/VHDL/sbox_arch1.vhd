----------------------------------------------------------------------------
-- This file is part of the project	 avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description: 
-- Sbox implements a lookup ROM for nonlinear substitution of a Bytearray.
-- trying to make use of Altera Blockram and Xilinx Blockram without using
-- vendor specific implementation like in sboxM4k.
--
-------------------------------------------------------------------------------!
--
-- Author(s):
--	   Thomas Ruschival -- ruschi@opencores.org (www.ruschival.de)
--
--------------------------------------------------------------------------------
-- Copyright (c) 2009, Authors and opencores.org
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--	  * Redistributions of source code must retain the above copyright notice,
--	  this list of conditions and the following disclaimer.
--	  * Redistributions in binary form must reproduce the above copyright notice,
--	  this list of conditions and the following disclaimer in the documentation
--	  and/or other materials provided with the distribution.
--	  * Neither the name of the organization nor the names of its contributors
--	  may be used to endorse or promote products derived from this software without
--	  specific prior written permission.
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
-- OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
-- THE POSSIBILITY OF SUCH DAMAGE
-------------------------------------------------------------------------------
-- version management:
-- $Author::                                         $
-- $Date::                                           $
-- $Revision::                                       $
-------------------------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
library avs_aes_lib;
use avs_aes_lib.avs_aes_pkg.all;

architecture ARCH1 of sbox is
	---------------------------------------------------------------------------
	-- Sbox of Rindael for nonlinear substitution of bytes
	-- taken from wikipedia.de
	-- Here just the values as lookup table - tried to make use of RAM as ROM
	---------------------------------------------------------------------------
	constant decrypt_table : BYTEARRAY(0 to 255) := (
		0	=> X"52", 1 => X"09", 2 => X"6A", 3 => X"D5", 4 => X"30", 5 => X"36", 6 => X"A5", 7 => X"38",
		8	=> X"BF", 9 => X"40", 10 => X"A3", 11 => X"9E", 12 => X"81", 13 => X"F3", 14 => X"D7", 15 => X"FB",
		16	=> X"7C", 17 => X"E3", 18 => X"39", 19 => X"82", 20 => X"9B", 21 => X"2F", 22 => X"FF", 23 => X"87",
		24	=> X"34", 25 => X"8E", 26 => X"43", 27 => X"44", 28 => X"C4", 29 => X"DE", 30 => X"E9", 31 => X"CB",
		32	=> X"54", 33 => X"7B", 34 => X"94", 35 => X"32", 36 => X"A6", 37 => X"C2", 38 => X"23", 39 => X"3D",
		40	=> X"EE", 41 => X"4C", 42 => X"95", 43 => X"0B", 44 => X"42", 45 => X"FA", 46 => X"C3", 47 => X"4E",
		48	=> X"08", 49 => X"2E", 50 => X"A1", 51 => X"66", 52 => X"28", 53 => X"D9", 54 => X"24", 55 => X"B2",
		56	=> X"76", 57 => X"5B", 58 => X"A2", 59 => X"49", 60 => X"6D", 61 => X"8B", 62 => X"D1", 63 => X"25",
		64	=> X"72", 65 => X"F8", 66 => X"F6", 67 => X"64", 68 => X"86", 69 => X"68", 70 => X"98", 71 => X"16",
		72	=> X"D4", 73 => X"A4", 74 => X"5C", 75 => X"CC", 76 => X"5D", 77 => X"65", 78 => X"B6", 79 => X"92",
		80	=> X"6C", 81 => X"70", 82 => X"48", 83 => X"50", 84 => X"FD", 85 => X"ED", 86 => X"B9", 87 => X"DA",
		88	=> X"5E", 89 => X"15", 90 => X"46", 91 => X"57", 92 => X"A7", 93 => X"8D", 94 => X"9D", 95 => X"84",
		96	=> X"90", 97 => X"D8", 98 => X"AB", 99 => X"00", 100 => X"8C", 101 => X"BC", 102 => X"D3", 103 => X"0A",
		104 => X"F7", 105 => X"E4", 106 => X"58", 107 => X"05", 108 => X"B8", 109 => X"B3", 110 => X"45", 111 => X"06",
		112 => X"D0", 113 => X"2C", 114 => X"1E", 115 => X"8F", 116 => X"CA", 117 => X"3F", 118 => X"0F", 119 => X"02",
		120 => X"C1", 121 => X"AF", 122 => X"BD", 123 => X"03", 124 => X"01", 125 => X"13", 126 => X"8A", 127 => X"6B",
		128 => X"3A", 129 => X"91", 130 => X"11", 131 => X"41", 132 => X"4F", 133 => X"67", 134 => X"DC", 135 => X"EA",
		136 => X"97", 137 => X"F2", 138 => X"CF", 139 => X"CE", 140 => X"F0", 141 => X"B4", 142 => X"E6", 143 => X"73",
		144 => X"96", 145 => X"AC", 146 => X"74", 147 => X"22", 148 => X"E7", 149 => X"AD", 150 => X"35", 151 => X"85",
		152 => X"E2", 153 => X"F9", 154 => X"37", 155 => X"E8", 156 => X"1C", 157 => X"75", 158 => X"DF", 159 => X"6E",
		160 => X"47", 161 => X"F1", 162 => X"1A", 163 => X"71", 164 => X"1D", 165 => X"29", 166 => X"C5", 167 => X"89",
		168 => X"6F", 169 => X"B7", 170 => X"62", 171 => X"0E", 172 => X"AA", 173 => X"18", 174 => X"BE", 175 => X"1B",
		176 => X"FC", 177 => X"56", 178 => X"3E", 179 => X"4B", 180 => X"C6", 181 => X"D2", 182 => X"79", 183 => X"20",
		184 => X"9A", 185 => X"DB", 186 => X"C0", 187 => X"FE", 188 => X"78", 189 => X"CD", 190 => X"5A", 191 => X"F4",
		192 => X"1F", 193 => X"DD", 194 => X"A8", 195 => X"33", 196 => X"88", 197 => X"07", 198 => X"C7", 199 => X"31",
		200 => X"B1", 201 => X"12", 202 => X"10", 203 => X"59", 204 => X"27", 205 => X"80", 206 => X"EC", 207 => X"5F",
		208 => X"60", 209 => X"51", 210 => X"7F", 211 => X"A9", 212 => X"19", 213 => X"B5", 214 => X"4A", 215 => X"0D",
		216 => X"2D", 217 => X"E5", 218 => X"7A", 219 => X"9F", 220 => X"93", 221 => X"C9", 222 => X"9C", 223 => X"EF",
		224 => X"A0", 225 => X"E0", 226 => X"3B", 227 => X"4D", 228 => X"AE", 229 => X"2A", 230 => X"F5", 231 => X"B0",
		232 => X"C8", 233 => X"EB", 234 => X"BB", 235 => X"3C", 236 => X"83", 237 => X"53", 238 => X"99", 239 => X"61",
		240 => X"17", 241 => X"2B", 242 => X"04", 243 => X"7E", 244 => X"BA", 245 => X"77", 246 => X"D6", 247 => X"26",
		248 => X"E1", 249 => X"69", 250 => X"14", 251 => X"63", 252 => X"55", 253 => X"21", 254 => X"0C", 255 => X"7D"
		);


	constant encrypt_table : BYTEARRAY(0 to 255) := (
		0	=> X"63", 1 => X"7C", 2 => X"77", 3 => X"7B", 4 => X"F2", 5 => X"6B", 6 => X"6F", 7 => X"C5",
		8	=> X"30", 9 => X"01", 10 => X"67", 11 => X"2B", 12 => X"FE", 13 => X"D7", 14 => X"AB", 15 => X"76",
		16	=> X"CA", 17 => X"82", 18 => X"C9", 19 => X"7D", 20 => X"FA", 21 => X"59", 22 => X"47", 23 => X"F0",
		24	=> X"AD", 25 => X"D4", 26 => X"A2", 27 => X"AF", 28 => X"9C", 29 => X"A4", 30 => X"72", 31 => X"C0",
		32	=> X"B7", 33 => X"FD", 34 => X"93", 35 => X"26", 36 => X"36", 37 => X"3F", 38 => X"F7", 39 => X"CC",
		40	=> X"34", 41 => X"A5", 42 => X"E5", 43 => X"F1", 44 => X"71", 45 => X"D8", 46 => X"31", 47 => X"15",
		48	=> X"04", 49 => X"C7", 50 => X"23", 51 => X"C3", 52 => X"18", 53 => X"96", 54 => X"05", 55 => X"9A",
		56	=> X"07", 57 => X"12", 58 => X"80", 59 => X"E2", 60 => X"EB", 61 => X"27", 62 => X"B2", 63 => X"75",
		64	=> X"09", 65 => X"83", 66 => X"2C", 67 => X"1A", 68 => X"1B", 69 => X"6E", 70 => X"5A", 71 => X"A0",
		72	=> X"52", 73 => X"3B", 74 => X"D6", 75 => X"B3", 76 => X"29", 77 => X"E3", 78 => X"2F", 79 => X"84",
		80	=> X"53", 81 => X"D1", 82 => X"00", 83 => X"ED", 84 => X"20", 85 => X"FC", 86 => X"B1", 87 => X"5B",
		88	=> X"6A", 89 => X"CB", 90 => X"BE", 91 => X"39", 92 => X"4A", 93 => X"4C", 94 => X"58", 95 => X"CF",
		96	=> X"D0", 97 => X"EF", 98 => X"AA", 99 => X"FB", 100 => X"43", 101 => X"4D", 102 => X"33", 103 => X"85",
		104 => X"45", 105 => X"F9", 106 => X"02", 107 => X"7F", 108 => X"50", 109 => X"3C", 110 => X"9F", 111 => X"A8",
		112 => X"51", 113 => X"A3", 114 => X"40", 115 => X"8F", 116 => X"92", 117 => X"9D", 118 => X"38", 119 => X"F5",
		120 => X"BC", 121 => X"B6", 122 => X"DA", 123 => X"21", 124 => X"10", 125 => X"FF", 126 => X"F3", 127 => X"D2",
		128 => X"CD", 129 => X"0C", 130 => X"13", 131 => X"EC", 132 => X"5F", 133 => X"97", 134 => X"44", 135 => X"17",
		136 => X"C4", 137 => X"A7", 138 => X"7E", 139 => X"3D", 140 => X"64", 141 => X"5D", 142 => X"19", 143 => X"73",
		144 => X"60", 145 => X"81", 146 => X"4F", 147 => X"DC", 148 => X"22", 149 => X"2A", 150 => X"90", 151 => X"88",
		152 => X"46", 153 => X"EE", 154 => X"B8", 155 => X"14", 156 => X"DE", 157 => X"5E", 158 => X"0B", 159 => X"DB",
		160 => X"E0", 161 => X"32", 162 => X"3A", 163 => X"0A", 164 => X"49", 165 => X"06", 166 => X"24", 167 => X"5C",
		168 => X"C2", 169 => X"D3", 170 => X"AC", 171 => X"62", 172 => X"91", 173 => X"95", 174 => X"E4", 175 => X"79",
		176 => X"E7", 177 => X"C8", 178 => X"37", 179 => X"6D", 180 => X"8D", 181 => X"D5", 182 => X"4E", 183 => X"A9",
		184 => X"6C", 185 => X"56", 186 => X"F4", 187 => X"EA", 188 => X"65", 189 => X"7A", 190 => X"AE", 191 => X"08",
		192 => X"BA", 193 => X"78", 194 => X"25", 195 => X"2E", 196 => X"1C", 197 => X"A6", 198 => X"B4", 199 => X"C6",
		200 => X"E8", 201 => X"DD", 202 => X"74", 203 => X"1F", 204 => X"4B", 205 => X"BD", 206 => X"8B", 207 => X"8A",
		208 => X"70", 209 => X"3E", 210 => X"B5", 211 => X"66", 212 => X"48", 213 => X"03", 214 => X"F6", 215 => X"0E",
		216 => X"61", 217 => X"35", 218 => X"57", 219 => X"B9", 220 => X"86", 221 => X"C1", 222 => X"1D", 223 => X"9E",
		224 => X"E1", 225 => X"F8", 226 => X"98", 227 => X"11", 228 => X"69", 229 => X"D9", 230 => X"8E", 231 => X"94",
		232 => X"9B", 233 => X"1E", 234 => X"87", 235 => X"E9", 236 => X"CE", 237 => X"55", 238 => X"28", 239 => X"DF",
		240 => X"8C", 241 => X"A1", 242 => X"89", 243 => X"0D", 244 => X"BF", 245 => X"E6", 246 => X"42", 247 => X"68",
		248 => X"41", 249 => X"99", 250 => X"2D", 251 => X"0F", 252 => X"B0", 253 => X"54", 254 => X"BB", 255 => X"16"
		);

	signal SBOXROM : BYTEARRAY(0 to 255);  -- actual storage
	
begin
	assign_inverse : if INVERSE generate
		SBOXROM <= decrypt_table;
	end generate assign_inverse;

	assign_encrypt : if not INVERSE generate
		SBOXROM <= encrypt_table;
	end generate assign_encrypt;


	-- purpose: lookup content of the rom
	-- type	  : sequential
	-- inputs : clk
	-- outputs: q_a, q_b
	assign_output : process (clk) is
	begin
		if rising_edge(clk) then
			q_a <= SBOXROM(to_integer(UNSIGNED(address_a)));
			q_b <= SBOXROM(to_integer(UNSIGNED(address_b)));
		end if;
	end process assign_output;

end ARCH1;
