----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	12/3/2009 
-- Design Name: 	TosNet
-- Module Name:    	tdl_tx - Behavioral 
-- File Name:		tdl_tx.vhd
-- Project Name:	TosNet
-- Target Devices:	Spartan3/6
-- Tool versions:	Xilinx ISE 12.2
-- Description: 	The transmit part of the TosNet physical layer.
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
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity tpl_tx is
	Port (	data				: in	STD_LOGIC_VECTOR(7 downto 0);
			clk_50M				: in	STD_LOGIC;
			clk_data_en			: out	STD_LOGIC;
			enable				: in	STD_LOGIC;
			reset				: in	STD_LOGIC;
			sig_out				: out	STD_LOGIC;
			clk_div_reset		: in	STD_LOGIC;
			clk_div_reset_ack	: out	STD_LOGIC);
end tpl_tx;

architecture Behavioral of tpl_tx is

	constant LFSR_INITIAL_SEED	: STD_LOGIC_VECTOR(7 downto 0) := "01010101";
	constant K_COMMA_1			: STD_LOGIC_VECTOR(7 downto 0) := "00111100";
	constant K_COMMA_2			: STD_LOGIC_VECTOR(7 downto 0) := "10111100";

	signal last_clk_div_reset	: STD_LOGIC;
	signal reset_clk_div		: STD_LOGIC := '0';
	signal clk_div				: STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
	signal clk_en_12M5			: STD_LOGIC;
	
	signal clk_en_1M25_0		: STD_LOGIC;
	signal clk_en_1M25_1		: STD_LOGIC;
	signal clk_en_1M25_2		: STD_LOGIC;
	signal clk_en_1M25_3		: STD_LOGIC;
	
	signal data_buffer_1		: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal data_buffer_2		: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal data_buffer_3		: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal enable_buffer_1		: STD_LOGIC := '0';
	signal enable_buffer_2		: STD_LOGIC := '0';
	
	signal out_buffer			: STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
	
	type STATES is (IDLE, TRN_START, TRN_SEED, TRN_DATA);
	
	signal state				: STATES := IDLE;
	signal next_state			: STATES := IDLE;

	signal lfsr_seed_out		: STD_LOGIC_VECTOR(7 downto 0);
	signal lfsr_seed_seed		: STD_LOGIC_VECTOR(7 downto 0);
	signal lfsr_seed_reset		: STD_LOGIC;
	signal lfsr_seed_clk		: STD_LOGIC;
	signal lfsr_seed_clk_en		: STD_LOGIC;
	
	signal lfsr_trn_out			: STD_LOGIC_VECTOR(7 downto 0);
	signal lfsr_trn_seed		: STD_LOGIC_VECTOR(7 downto 0);
	signal lfsr_trn_reset		: STD_LOGIC;
	signal lfsr_trn_clk			: STD_LOGIC;
	signal lfsr_trn_clk_en		: STD_LOGIC;

	signal enc_in				: STD_LOGIC_VECTOR(7 downto 0) := K_COMMA_1;
	signal enc_out				: STD_LOGIC_VECTOR(9 downto 0);
	signal enc_kin				: STD_LOGIC := '1';
	signal enc_clk				: STD_LOGIC;
	signal enc_clk_en			: STD_LOGIC;
		
	component lfsr is
		generic	(
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
	
	component enc_8b10b is
		port (
			din					: in	STD_LOGIC_VECTOR(7 downto 0);
			kin					: in	STD_LOGIC;
			clk					: in	STD_LOGIC;
			dout				: out	STD_LOGIC_VECTOR(9 downto 0);
			ce					: in	STD_LOGIC);
	end component;

begin

	clk_data_en <= clk_en_1M25_0;

	lfsr_seed_seed <= LFSR_INITIAL_SEED;
	lfsr_seed_clk <= clk_50M;
	lfsr_seed_reset <= reset;
	
	lfsr_trn_clk <= clk_50M;
	lfsr_trn_clk_en <= clk_en_1M25_1;

	lfsr_seed : lfsr
	Generic map (	lfsr_length => "00001000",
					lfsr_out_length => "00001000",
					lfsr_allow_zero => '0')
	Port map (		lfsr_out => lfsr_seed_out,
					lfsr_seed => lfsr_seed_seed,
					lfsr_reset => lfsr_seed_reset,
					lfsr_clk => lfsr_seed_clk,
					lfsr_clk_en => lfsr_seed_clk_en);
						
	lfsr_trn : lfsr
	Generic map (	lfsr_length => "00001000",
					lfsr_out_length => "00001000",
					lfsr_allow_zero => '0')
	Port map (		lfsr_out => lfsr_trn_out,
					lfsr_seed => lfsr_trn_seed,
					lfsr_reset => lfsr_trn_reset,
					lfsr_clk => lfsr_trn_clk,
					lfsr_clk_en => lfsr_trn_clk_en);
						
	enc : enc_8b10b
	Port map (		din => enc_in,
					kin => enc_kin,
					clk => enc_clk,
					dout => enc_out,
					ce => enc_clk_en);

	enc_clk <=  clk_50M;
	enc_clk_en <= clk_en_1M25_2;

	process(clk_50M)
	begin
		if(clk_50M = '1' and clk_50M'event) then
			if(clk_div_reset = '1' and last_clk_div_reset = '0') then
				reset_clk_div <= '1';
			elsif(clk_div_reset = '0') then
				clk_div_reset_ack <= '0';
			end if;

			if(reset_clk_div = '1' and clk_div(1 downto 0) = "11") then
				clk_div <= "100100";
				reset_clk_div <= '0';
				clk_div_reset_ack <= '1';
			else
				if(clk_div = 39) then
					clk_div <= (others => '0');
				else
					clk_div <= clk_div + 1;
				end if;
			end if;

			last_clk_div_reset <= clk_div_reset;
		end if;
	end process;

	clk_en_12M5 <= '1' when clk_div(1 downto 0) = "11" else '0';			--Sync the phase to clk_en_1M25_3
	clk_en_1M25_0 <= '1' when clk_div = "000000" else '0';					--We're using phase-shifted versions of the clock-enables to minimize the latency of the system, as all the parts are perfectly pipelined anyway
	clk_en_1M25_1 <= '1' when clk_div = "000001" else '0';
	clk_en_1M25_2 <= '1' when clk_div = "000010" else '0';
	clk_en_1M25_3 <= '1' when clk_div = "000011" else '0';

	lfsr_trn_seed <= lfsr_seed_out;
	
	process(clk_50M)
	begin
		if(clk_50M = '1' and clk_50M'event) then
			if(reset = '1') then
				state <= IDLE;
			elsif(clk_en_1M25_1 = '1') then
				state <= next_state;
			
				data_buffer_3 <= data_buffer_2;
				data_buffer_2 <= data_buffer_1;
				data_buffer_1 <= data;
				
				enable_buffer_2 <= enable_buffer_1;
				enable_buffer_1 <= enable;
			end if;
		end if;
	end process;

	process(state, lfsr_trn_seed, data_buffer_3, lfsr_trn_out, clk_en_1M25_1)
	begin
		case state is
			when IDLE =>
				enc_in <= K_COMMA_1;
				enc_kin <= '1';
				lfsr_trn_reset <= '1';
				lfsr_seed_clk_en <= clk_en_1M25_1;
			when TRN_START =>
				enc_in <= K_COMMA_2;
				enc_kin <= '1';
				lfsr_trn_reset <= '1';
				lfsr_seed_clk_en <= '0';
			when TRN_SEED =>
				enc_in <= lfsr_trn_seed;
				enc_kin <= '0';
				lfsr_trn_reset <= '0';
				lfsr_seed_clk_en <= '0';
			when TRN_DATA =>
				enc_in <= data_buffer_3 xor lfsr_trn_out;
				enc_kin <= '0';
				lfsr_trn_reset <= '0';
				lfsr_seed_clk_en <= '0';
		end case;
	end process;
	
				
	process(clk_50M)
	begin
		if(clk_50M = '1' and clk_50M'event) then
			if(reset = '1') then
				out_buffer <= (others => '0');
				sig_out <= '0';
			elsif(clk_en_12M5 = '1') then
				if(clk_en_1M25_3 = '1') then
					out_buffer <= enc_out;
				else
					out_buffer <= '0' & out_buffer(9 downto 1);
				end if;
				
				sig_out <= out_buffer(0);
			end if;
		end if;
	end process;

	
	
	process(state, enable, enable_buffer_2)
	begin
		case state is
			when IDLE =>
				if(enable = '1') then
					next_state <= TRN_START;
				else
					next_state <= IDLE;
				end if;
			when TRN_START =>
				next_state <= TRN_SEED;
			when TRN_SEED =>
				next_state <= TRN_DATA;
			when TRN_DATA =>
				if(enable_buffer_2 = '1') then
					next_state <= TRN_DATA;
				else
					next_state <= IDLE;
				end if;
		end case;
	end process;
			

end Behavioral;
