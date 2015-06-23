----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	19/3/2009 
-- Design Name: 	TosNet
-- Module Name:    	tpl_rx - Behavioral 
-- File Name:		tpl_rx.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	The receive part of the TosNet physical layer.
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tpl_rx is
	Port (	data				: out	STD_LOGIC_VECTOR(7 downto 0);
			valid				: out	STD_LOGIC;
			error				: out	STD_LOGIC;
			clk_data			: out	STD_LOGIC;
			clk_50M				: in	STD_LOGIC;
			reset				: in	STD_LOGIC;
			sig_in				: in	STD_LOGIC);
end tpl_rx;

architecture Behavioral of tpl_rx is

	type STATES is (IDLE, QUIET, REC_START, REC_SEED, REC_DATA, REC_ERROR);
	
	signal state					: STATES := IDLE;
	signal next_state				: STATES := IDLE;

	signal sig_in_sync				: STD_LOGIC := '0';
	signal last_sig_in_sync			: STD_LOGIC := '0';
	
	signal in_buffer				: STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
	signal data_buffer				: STD_LOGIC_VECTOR(7 downto 0) := "00000000";
	signal bit_counter				: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	signal last_bit_counter			: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	
	signal clk_data_int				: STD_LOGIC := '0';
	signal valid_int				: STD_LOGIC := '0';
	signal bit_counter_synced		: STD_LOGIC := '0';
	
	signal lfsr_rec_out				: STD_LOGIC_VECTOR(7 downto 0);
	signal lfsr_rec_seed			: STD_LOGIC_VECTOR(7 downto 0);
	signal lfsr_rec_reset			: STD_LOGIC;
	signal lfsr_rec_clk				: STD_LOGIC;
	signal lfsr_rec_clk_en			: STD_LOGIC;
	
	signal dec_clk					: STD_LOGIC;
	signal dec_clk_en				: STD_LOGIC;
	signal dec_in					: STD_LOGIC_VECTOR(9 downto 0);
	signal dec_out					: STD_LOGIC_VECTOR(7 downto 0);
	signal dec_kout					: STD_LOGIC;
	signal dec_code_err				: STD_LOGIC;
	
	component lfsr is
		generic (
			lfsr_length 		: STD_LOGIC_VECTOR(7 downto 0);
			lfsr_out_length		: STD_LOGIC_VECTOR(7 downto 0);
			lfsr_allow_zero		: STD_LOGIC);
		port (
			lfsr_out			: out	STD_LOGIC_VECTOR((conv_integer(lfsr_out_length) - 1) downto 0);
			lfsr_seed			: in	STD_LOGIC_VECTOR((conv_integer(lfsr_length) - 1) downto 0);
			lfsr_reset			: in	STD_LOGIC;
			lfsr_clk 			: in	STD_LOGIC;
			lfsr_clk_en			: in	STD_LOGIC);
	end component;
	
	component dec_8b10b is
		port (	
			clk					: in	STD_LOGIC;
			ce					: in	STD_LOGIC;
			din					: in	STD_LOGIC_VECTOR(9 downto 0);
			dout				: out	STD_LOGIC_VECTOR(7 downto 0);
			kout				: out	STD_LOGIC;
			code_err			: out	STD_LOGIC);
	end component;
			
begin

	clk_data <= clk_data_int;
	valid <= valid_int and not dec_kout;

	lfsr_rec_clk <= clk_50M;

	lfsr_rec : lfsr
	Generic map (	lfsr_length => "00001000",
					lfsr_out_length => "00001000",
					lfsr_allow_zero => '0')
	Port map (		lfsr_out => lfsr_rec_out,
					lfsr_seed => lfsr_rec_seed,
					lfsr_reset => lfsr_rec_reset,
					lfsr_clk => lfsr_rec_clk,
					lfsr_clk_en => lfsr_rec_clk_en);

	dec_clk <= clk_50M;
	data_buffer <= dec_out xor lfsr_rec_out;
						
	dec : dec_8b10b
	Port map (		clk => dec_clk,
					ce => dec_clk_en,
					din => dec_in,
					dout => dec_out,
					kout => dec_kout,
					code_err => dec_code_err);

	process(clk_50M)
		variable sig_in_counter	: STD_LOGIC_VECTOR(1 downto 0) := "00";
	begin
		if(clk_50M = '1' and clk_50M'event) then
			if(reset = '1') then
				state <= IDLE;
			else
				state <= next_state;
			end if;

			sig_in_sync <= sig_in;
		
			
			last_sig_in_sync <= sig_in_sync;

			if(last_sig_in_sync = sig_in_sync) then
				sig_in_counter := sig_in_counter + 1;
			else
				sig_in_counter := (others => '0');
			end if;
			
			if(sig_in_counter(1 downto 0) = "01") then			--This should be the approximate middle of the bit cell
				in_buffer <= sig_in_sync & in_buffer(9 downto 1);
				bit_counter <= bit_counter + 1;
				
				if(bit_counter = 0) then
					dec_in <= in_buffer;
					clk_data_int <= '1';
				elsif(bit_counter = 5) then
					clk_data_int <= '0';
				end if;
			end if;
			
			if(bit_counter = 10) then
				bit_counter <= "0000";
			end if;

			if((bit_counter = 1) and (last_bit_counter = 0)) then
				dec_clk_en <= '1';
			else
				dec_clk_en <= '0';
			end if;
			
			lfsr_rec_clk_en <= dec_clk_en;
			last_bit_counter <= bit_counter;
			
			case state is
				when IDLE =>
					lfsr_rec_seed <= "00000000";
					data <= "00000000";
					valid_int <= '0';
					error <= '0';
				when QUIET =>
					bit_counter_synced <= '0';
					lfsr_rec_seed <= "00000000";
					lfsr_rec_reset <= '1';
					data <= "00000000";
					valid_int <= '0';
					error <= '0';
				when REC_START =>
					if(bit_counter_synced = '0') then
						bit_counter <= "0000";
						bit_counter_synced <= '1';
					end if;
					lfsr_rec_seed <= "00000000";
					lfsr_rec_reset <= '1';
					data <= "00000000";
					valid_int <= '0';
					error <= '0';
				when REC_SEED =>
					lfsr_rec_reset <= '1';
					if(bit_counter = 9) then
						lfsr_rec_seed <= dec_out;
					end if;
					data <= "00000000";
					valid_int <= '0';
					error <= '0';
				when REC_DATA =>
					lfsr_rec_reset <= '0';
					if(bit_counter = 2) then
						data <= data_buffer;
						valid_int <= '1';
						error <= '0';
					end if;
				when REC_ERROR =>
					error <= '1';
			end case;
			
		end if;
	end process;
	
	process(state, in_buffer, bit_counter, dec_kout, dec_code_err)
	begin
		case state is
			when IDLE =>
				next_state <= QUIET;
			when QUIET =>
				if(in_buffer = "0101111100" or in_buffer = "1010000011") then
					next_state <= REC_START;
				else
					next_state <= QUIET;
				end if;
			when REC_START =>
				if(bit_counter = 10) then
					next_state <= REC_SEED;
				else
					next_state <= REC_START;
				end if;
			when REC_SEED =>
				if(dec_code_err = '1') then	--Need to wait until this state to check the decoder error output, as otherwise we may pick up the result of decoding something unaligned, resulting in a whole lot of errors that really aren't there...
					next_state <= REC_ERROR;
				elsif(bit_counter = 10) then
					next_state <= REC_DATA;
				else
					next_state <= REC_SEED;
				end if;
			when REC_DATA =>
				if(dec_code_err = '1') then
					next_state <= REC_ERROR;
				elsif(bit_counter = 10 and dec_kout = '1') then
					next_state <= QUIET;
				else
					next_state <= REC_DATA;
				end if;
			when REC_ERROR =>
				next_state <= QUIET;
		end case;
	end process;
	
end Behavioral;

