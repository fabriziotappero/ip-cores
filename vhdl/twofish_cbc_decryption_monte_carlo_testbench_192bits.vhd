-- Twofish_cbc_decryption_monte_carlo_testbench_192bits.vhd
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
--
-- description	: 	this file is the testbench for the Decryption Monte Carlo KAT of the twofish cipher with 192 bit key 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use std.textio.all;

entity cbc_decryption_monte_carlo_testbench192 is
end cbc_decryption_monte_carlo_testbench192;

architecture cbc_decryption192_monte_carlo_testbench_arch of cbc_decryption_monte_carlo_testbench192 is

	component	reg128
	port (
			in_reg128	: in std_logic_vector(127 downto 0);
			out_reg128 : out std_logic_vector(127 downto 0);
			enable_reg128, reset_reg128, clk_reg128	: in std_logic
			);
	end component;

	component twofish_keysched192 
	port	(
			odd_in_tk192,
			even_in_tk192		: in std_logic_vector(7 downto 0);
			in_key_tk192		: in std_logic_vector(191 downto 0);
			out_key_up_tk192,
			out_key_down_tk192	: out std_logic_vector(31 downto 0)
			);
	end component;

	component twofish_whit_keysched192 
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
	end component;

	component twofish_decryption_round192 
	port	(
			in1_tdr192,
			in2_tdr192,
			in3_tdr192,
			in4_tdr192,
			in_Sfirst_tdr192,
			in_Ssecond_tdr192,
			in_Sthird_tdr192,
			in_key_up_tdr192,
			in_key_down_tdr192		: in std_logic_vector(31 downto 0);
			out1_tdr192,
			out2_tdr192,
			out3_tdr192,
			out4_tdr192			: out std_logic_vector(31 downto 0)
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

	component twofish_S192 
	port	(
			in_key_ts192		: in std_logic_vector(191 downto 0);
			out_Sfirst_ts192,
			out_Ssecond_ts192,
			out_Sthird_ts192			: out std_logic_vector(31 downto 0)
			);
	end component;

	FILE input_file : text is in "twofish_cbc_decryption_monte_carlo_testvalues_192bits.txt";
	FILE output_file : text is out "twofish_cbc_decryption_monte_carlo_192bits_results.txt";
	
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
	function to_text(int_number : integer range 0 to 9999) return string is
		variable	our_text : string (1 to 4) := (others => ' ');
		variable thousands,
						hundreds,
						tens,
						ones		: integer range 0 to 9;
	begin
		ones := int_number mod 10;
		tens := ((int_number mod 100) - ones) / 10;
		hundreds := ((int_number mod 1000) - (int_number mod 100)) / 100;
		thousands := (int_number - (int_number mod 1000)) / 1000;
		our_text(1) := digit_to_char(thousands);
		our_text(2) := digit_to_char(hundreds);
		our_text(3) := digit_to_char(tens);
		our_text(4) := digit_to_char(ones);
		return our_text;
	end;

	signal			odd_number,
				even_number					: std_logic_vector(7 downto 0);

	signal			input_data,
				output_data,
				to_encr_reg128,
				from_tdi_to_xors,
				to_output_whit_xors,
				from_xors_to_tdo,
				to_mux, to_demux,
				from_input_whit_xors,
				to_round,
				to_input_mux							: std_logic_vector(127 downto 0) ;

	signal			twofish_key			: std_logic_vector(191 downto 0);

	signal			key_up,
				key_down,
				Sfirst,
				Ssecond,
				Sthird,
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
	the_whitening_step: twofish_whit_keysched192 
	port	map (
			in_key_twk192		=> twofish_key,
			out_K0_twk192 => K0,
			out_K1_twk192 => K1,
			out_K2_twk192 => K2,
			out_K3_twk192 => K3,
			out_K4_twk192 => K4,
			out_K5_twk192 => K5,
			out_K6_twk192 => K6,
			out_K7_twk192 => K7
			);

	-- performing the input whitening XORs
	from_xor0 <= K4 XOR from_tdi_to_xors(127 downto 96);
	from_xor1 <= K5 XOR from_tdi_to_xors(95 downto 64);
	from_xor2 <= K6 XOR from_tdi_to_xors(63 downto 32);
	from_xor3 <= K7 XOR from_tdi_to_xors(31 downto 0);

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
	the_keysched_of_the_round: twofish_keysched192 
	port	map	(
				odd_in_tk192 => odd_number,
				even_in_tk192	=> even_number,
				in_key_tk192 => twofish_key,
				out_key_up_tk192 => key_up,
				out_key_down_tk192 => key_down
				);

	producing_the_Skeys: twofish_S192 
	port	 map (
				in_key_ts192		=> twofish_key,
				out_Sfirst_ts192 => Sfirst,
				out_Ssecond_ts192 => Ssecond,
				out_Sthird_ts192 => Sthird
				);

	the_decryption_circuit: twofish_decryption_round192 
	port map 	(
				in1_tdr192 => to_round(127 downto 96),
				in2_tdr192 => to_round(95 downto 64),
				in3_tdr192 => to_round(63 downto 32),
				in4_tdr192 => to_round(31 downto 0),
				in_Sfirst_tdr192 => Sfirst,
				in_Ssecond_tdr192 => Ssecond,
				in_Sthird_tdr192 => Sthird,
				in_key_up_tdr192 => key_up,
				in_key_down_tdr192		=> key_down,
				out1_tdr192 => to_encr_reg128(127 downto 96),
				out2_tdr192 => to_encr_reg128(95 downto 64),
				out3_tdr192 => to_encr_reg128(63 downto 32),
				out4_tdr192	=> to_encr_reg128(31 downto 0)
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
	from_xors_to_tdo(127 downto 96) <= K0 XOR to_output_whit_xors(63 downto 32);
	from_xors_to_tdo(95 downto 64) <= K1 XOR to_output_whit_xors(31 downto 0);
	from_xors_to_tdo(63 downto 32) <= K2 XOR to_output_whit_xors(127 downto 96);
	from_xors_to_tdo(31 downto 0) <= K3 XOR to_output_whit_xors(95 downto 64);	
	
	taking_the_output: twofish_data_output
	port	map (
				in_tdo	=> from_xors_to_tdo,
				out_tdo	=> output_data
				);

	-- we create the clock 
	clk <= not clk after 50 ns; -- period 100 ns


	cbc_dmc_proc: process

		variable key_f,  -- key input from file
					pt_f,  -- plaintext from file
					ct_f,
					iv_f		: line; -- ciphertext from file
		variable	key_v : std_logic_vector(191 downto 0);  -- key vector input
		variable			pt_v , -- plaintext vector
					ct_v,
					iv_v		: std_logic_vector(127 downto 0); -- ciphertext vector

		variable counter_10000 : integer range 0 to 9999 := 0; -- counter for the 10.000 repeats in the 400 next ones
		variable counter_400 : integer range 0 to 399 := 0; -- counter for the 400 repeats
		variable round : integer range 0 to 16 := 0;  -- holds the rounds
		variable PT, CT, CV, CTj_1		: std_logic_vector(127 downto 0) := (others => '0');

	begin

		while not endfile(input_file) loop

			readline(input_file, key_f);
			readline(input_file, iv_f);
			readline(input_file,ct_f);
			readline(input_file, pt_f);
			hread(key_f,key_v);
			hread(iv_f, iv_v);
			hread(ct_f,ct_v);
			hread(pt_f,pt_v);

			twofish_key <= key_v;
			CV := iv_v;
			CT := ct_v;

			for counter_10000 in 0 to 9999 loop

				input_data <= CT;		
		
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
				even_number <= "00100110"; -- 38
				odd_number <= "00100111"; -- 39
				wait for 50 ns;
				enable_encr_reg <= '1';
				wait for 50 ns;
				enable_encr_reg <= '0';
				demux_selection <= '1';
				mux_selection <= '1';
	
				-- the rest 15 rounds
				for round in 1 to 15 loop
					even_number <= conv_std_logic_vector((((15-round)*2)+8), 8);
					odd_number <= conv_std_logic_vector((((15-round)*2)+9), 8);
					wait for 50 ns;
					enable_encr_reg <= '1';
					wait for 50 ns;
					enable_encr_reg <= '0';
				end loop;

				-- taking final results
				demux_selection <= '0';
				wait for 25 ns;

				PT := output_data XOR CV;
				CV := CT;
				CT := PT;

				assert false report "I=" & to_text(counter_400) & " R=" & to_text(counter_10000) severity note;

			end loop; -- counter_10000

			hwrite(key_f, key_v);
			hwrite(iv_f, iv_v);
			hwrite(ct_f, ct_v);
			hwrite(pt_f, PT);
			writeline(output_file,key_f);
			writeline(output_file, iv_f);
			writeline(output_file,ct_f);
			writeline(output_file,pt_f);

			assert (pt_v = PT) report "file entry and decryption result DO NOT match!!! :( " severity failure;
			assert (pt_v /= PT) report "Decryption I=" & to_text(counter_400) &" OK" severity note;

			counter_400 := counter_400 + 1;

		end loop;
		assert false	report	"***** CBC Decryption Monte Carlo Test with 192 bits key size ended succesfully! :) *****"	severity failure;
	end process cbc_dmc_proc;
	
end cbc_decryption192_monte_carlo_testbench_arch;

