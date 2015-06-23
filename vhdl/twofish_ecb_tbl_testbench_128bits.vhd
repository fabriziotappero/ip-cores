-- Twofish_ecb_tbl_testbench_128bits.vhd
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
--
-- description	: 	this file is the testbench for the TABLES KAT of the twofish cipher with 128 bit key 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use std.textio.all;

entity tbl_testbench128 is
end tbl_testbench128;

architecture tbl_encryption128_testbench_arch of tbl_testbench128 is

	component	reg128
	port (
			in_reg128	: in std_logic_vector(127 downto 0);
			out_reg128 : out std_logic_vector(127 downto 0);
			enable_reg128, reset_reg128, clk_reg128	: in std_logic
			);
	end component;

	component twofish_keysched128 
	port	(
			odd_in_tk128,
			even_in_tk128		: in std_logic_vector(7 downto 0);
			in_key_tk128		: in std_logic_vector(127 downto 0);
			out_key_up_tk128,
			out_key_down_tk128	: out std_logic_vector(31 downto 0)
			);
	end component;

	component twofish_whit_keysched128 
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
	end component;

	component twofish_encryption_round128 
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
	end component;

	component twofish_data_input 
	port	(
			in_tdi	: in std_logic_vector(127 downto 0);
			out_tdi	: out std_logic_vector(127 downto 0)
			);
	end component;

	component twofish_data_output
	port	(
			in_tdo	: in std_logic_vector(127 downto 0);
			out_tdo	: out std_logic_vector(127 downto 0)
			);
	end component;

	component demux128 
	port	( in_demux128 : in std_logic_vector(127 downto 0);
			out1_demux128, out2_demux128 : out std_logic_vector(127 downto 0);
			selection_demux128 : in std_logic
		);
	end component;
	
	component mux128 
	port ( in1_mux128, in2_mux128	: in std_logic_vector(127 downto 0);
			selection_mux128	: in std_logic;
			out_mux128 : out std_logic_vector(127 downto 0)
		);
	end component;

	component twofish_S128 
	port	(
			in_key_ts128		: in std_logic_vector(127 downto 0);
			out_Sfirst_ts128,
			out_Ssecond_ts128			: out std_logic_vector(31 downto 0)
			);
	end component;

	FILE input_file : text is in "twofish_ecb_tbl_testvalues_128bits.txt";
	FILE output_file : text is out "twofish_ecb_tbl_128bits_results.txt";
	
	-- we create the functions that transform a number to text
	-- transforming a signle digit to a character
	function digit_to_char(number : integer range 0 to 9) return character is
	begin
		case number is
			when 0 => return '0';
			when 1 => return '1';
			when 2 => return '2';
			when 3 => return '3';
			when 4 => return '4';
			when 5 => return '5';
			when 6 => return '6';
			when 7 => return '7';
			when 8 => return '8';
			when 9 => return '9';
		end case;
	end;

	-- transforming multi-digit number to text
	function to_text(int_number : integer range 1 to 50) return string is
		variable	our_text : string (1 to 3) := (others => ' ');
		variable hundreds,
						tens,
						ones		: integer range 0 to 9;
	begin
		ones := int_number mod 10;
		tens := ((int_number mod 100) - ones) / 10;
		hundreds := (int_number - (int_number mod 100)) / 100;
		our_text(1) := digit_to_char(hundreds);
		our_text(2) := digit_to_char(tens);
		our_text(3) := digit_to_char(ones);
		return our_text;
	end;

	signal			odd_number,
				even_number					: std_logic_vector(7 downto 0);

	signal			input_data,
				output_data,
				twofish_key,
				to_encr_reg128,
				from_tdi_to_xors,
				to_output_whit_xors,
				from_xors_to_tdo,
				to_mux, to_demux,
				from_input_whit_xors,
				to_round,
				to_input_mux							: std_logic_vector(127 downto 0) ;

	signal			key_up,
				key_down,
				Sfirst,
				Ssecond,
				from_xor0,
				from_xor1,
				from_xor2,
				from_xor3,
				K0,K1,K2,K3,
				K4,K5,K6,K7								:  std_logic_vector(31 downto 0);

	signal			clk			: std_logic := '0';
	signal			mux_selection	: std_logic := '0';
	signal			demux_selection: std_logic := '0';
	signal			enable_encr_reg : std_logic := '0';
	signal			reset : std_logic := '0';
	signal			enable_round_reg : std_logic := '0';

-- begin the testbench arch description
begin


	-- getting data to encrypt
	data_input: twofish_data_input 
	port map	(
				in_tdi	=> input_data,
				out_tdi	=> from_tdi_to_xors
				);

	-- producing whitening keys K0..7
	the_whitening_step: twofish_whit_keysched128 
	port	map (
			in_key_twk128		=> twofish_key,
			out_K0_twk128 => K0,
			out_K1_twk128 => K1,
			out_K2_twk128 => K2,
			out_K3_twk128 => K3,
			out_K4_twk128 => K4,
			out_K5_twk128 => K5,
			out_K6_twk128 => K6,
			out_K7_twk128 => K7
			);

	-- performing the input whitening XORs
	from_xor0 <= K0 XOR from_tdi_to_xors(127 downto 96);
	from_xor1 <= K1 XOR from_tdi_to_xors(95 downto 64);
	from_xor2 <= K2 XOR from_tdi_to_xors(63 downto 32);
	from_xor3 <= K3 XOR from_tdi_to_xors(31 downto 0);

	from_input_whit_xors <= from_xor0 & from_xor1 & from_xor2 & from_xor3;

	round_reg: reg128
	port map ( in_reg128 => from_input_whit_xors,
				out_reg128 => to_input_mux,
				enable_reg128 => enable_round_reg,
				reset_reg128 => reset,
				clk_reg128 => clk );

	input_mux: mux128
	port map ( in1_mux128 => to_input_mux,
				in2_mux128 => to_mux,
				out_mux128 => to_round,
				selection_mux128 => mux_selection
				);


 	-- creating a round
	the_keysched_of_the_round: twofish_keysched128 
	port	map	(
				odd_in_tk128 => odd_number,
				even_in_tk128	=> even_number,
				in_key_tk128 => twofish_key,
				out_key_up_tk128 => key_up,
				out_key_down_tk128 => key_down
				);

	producing_the_Skeys: twofish_S128 
	port	 map (
				in_key_ts128		=> twofish_key,
				out_Sfirst_ts128 => Sfirst,
				out_Ssecond_ts128 => Ssecond
				);

	the_encryption_circuit: twofish_encryption_round128 
	port map 	(
				in1_ter128 => to_round(127 downto 96),
				in2_ter128 => to_round(95 downto 64),
				in3_ter128 => to_round(63 downto 32),
				in4_ter128 => to_round(31 downto 0),
				in_Sfirst_ter128 => Sfirst,
				in_Ssecond_ter128 => Ssecond,
				in_key_up_ter128 => key_up,
				in_key_down_ter128		=> key_down,
				out1_ter128 => to_encr_reg128(127 downto 96),
				out2_ter128 => to_encr_reg128(95 downto 64),
				out3_ter128 => to_encr_reg128(63 downto 32),
				out4_ter128	=> to_encr_reg128(31 downto 0)
				);
	
	encr_reg: reg128
	port map ( in_reg128 => to_encr_reg128,
				out_reg128 => to_demux,
				enable_reg128 => enable_encr_reg,
				reset_reg128 => reset,
				clk_reg128 => clk );

	output_demux: demux128
	port map ( in_demux128 => to_demux,
					out1_demux128 => to_output_whit_xors,
					out2_demux128 => to_mux,
					selection_demux128 => demux_selection );

	-- don't forget the last swap !!!
	from_xors_to_tdo(127 downto 96) <= K4 XOR to_output_whit_xors(63 downto 32);
	from_xors_to_tdo(95 downto 64) <= K5 XOR to_output_whit_xors(31 downto 0);
	from_xors_to_tdo(63 downto 32) <= K6 XOR to_output_whit_xors(127 downto 96);
	from_xors_to_tdo(31 downto 0) <= K7 XOR to_output_whit_xors(95 downto 64);	
	
	taking_the_output: twofish_data_output
	port	map (
				in_tdo	=> from_xors_to_tdo,
				out_tdo	=> output_data
				);

	-- we create the clock 
	clk <= not clk after 50 ns; -- period 100 ns


	tbl_proc: process

		variable key_f,  -- key input from file
					pt_f,  -- plaintext from file
					ct_f	: line; -- ciphertext from file
		variable	key_v,  -- key vector input
					pt_v , -- plaintext vector
					ct_v	: std_logic_vector(127 downto 0); -- ciphertext vector

		variable counter : integer range 1 to 50 := 1;
		variable round : integer range 0 to 16 := 0;

	begin
		while not endfile(input_file) loop
			readline(input_file, key_f);
			readline(input_file, pt_f);
			readline(input_file,ct_f);
			hread(key_f,key_v);
			hread(pt_f,pt_v);
			hread(ct_f,ct_v);
			twofish_key <= key_v;
			input_data <= pt_v;
			wait for 25 ns;
			reset <= '1';
			wait for 50 ns;
			reset <= '0';
			mux_selection <= '0';
			demux_selection <= '1';
			enable_encr_reg <= '0';
			enable_round_reg <= '0';
			wait for 50 ns;
			enable_round_reg <= '1';
			wait for 50 ns;
			enable_round_reg <= '0';

			-- the first round
			even_number <= "00001000"; -- 8
			odd_number <= "00001001"; -- 9
			wait for 50 ns;
			enable_encr_reg <= '1';
			wait for 50 ns;
			enable_encr_reg <= '0';
			demux_selection <= '1';
			mux_selection <= '1';

			-- the rest 15 rounds
			for round in 1 to 15 loop
				even_number <= conv_std_logic_vector(((round*2)+8), 8);
				odd_number <= conv_std_logic_vector(((round*2)+9), 8);
				wait for 50 ns;
				enable_encr_reg <= '1';
				wait for 50 ns;
				enable_encr_reg <= '0';
			end loop;

			-- taking final results
			demux_selection <= '0';
			wait for 25 ns;
			assert (ct_v = output_data) report "file entry and encryption result DO NOT match!!! :( " severity failure;
			assert (ct_v /= output_data) report "Encryption I=" & to_text(counter) &" OK" severity note;
			counter := counter+1;
			hwrite(pt_f,input_data);
			hwrite(ct_f,output_data);
			hwrite(key_f,key_v);
			writeline(output_file,key_f);
			writeline(output_file,pt_f);
			writeline(output_file,ct_f);
		end loop;
		assert false	report	"***** Tables Known Answer Test with 128 bits key size ended succesfully! :) *****"	severity failure;
	end process tbl_proc;
	
end tbl_encryption128_testbench_arch;

