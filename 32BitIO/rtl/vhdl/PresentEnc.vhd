-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Top level of present encoder with 32 bit IO.              ----
---- To Do:                                                        ----
----                                                               ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2013 Authors and OPENCORES.ORG                  ----
----                                                               ----
---- This source file may be used and distributed without          ----
---- restriction provided that this copyright statement is not     ----
---- removed from the file and that any derivative work contains   ----
---- the original copyright notice and the associated disclaimer.  ----
----                                                               ----
---- This source file is free software; you can redistribute it    ----
---- and-or modify it under the terms of the GNU Lesser General    ----
---- Public License as published by the Free Software Foundation;  ----
---- either version 2.1 of the License, or (at your option) any    ----
---- later version.                                                ----
----                                                               ----
---- This source is distributed in the hope that it will be        ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied    ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       ----
---- PURPOSE. See the GNU Lesser General Public License for more   ----
---- details.                                                      ----
----                                                               ----
---- You should have received a copy of the GNU Lesser General     ----
---- Public License along with this source; if not, download it    ----
---- from http://www.opencores.org/lgpl.shtml                      ----
----                                                               ----
-----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PresentEnc is
	generic (
			w_2: integer := 2;
			w_4: integer := 4;
			w_5: integer := 5;
			w_32: integer := 32;
			w_64: integer := 64;
			w_80: integer := 80
	);
	port(
		ctrl    : in std_logic_vector(w_4-1 downto 0);
		input : in std_logic_vector(w_32-1 downto 0);
		output : out std_logic_vector(w_32-1 downto 0);		
		clk, reset : in std_logic;
		ready : out std_logic		
	);
end PresentEnc;

architecture Behavioral of PresentEnc is

	component PresentStateMachine is
		generic (
			w_2: integer := 2;
			w_4: integer := 4;
			w_5: integer := 5;
			w_32: integer := 32;
			w_64: integer := 64;
			w_80: integer := 80
		);
		port (			
			info : in std_logic_vector (w_2-1 downto 0);
			ctrl : in std_logic_vector (w_4-1 downto 0);			
			key_ctrl: out std_logic_vector (w_2-1 downto 0);
			plain_ctrl: out std_logic_vector (w_2-1 downto 0);
			outReg : out std_logic_vector (w_2-1 downto 0);
			reset, clk : in std_logic;
			ready, cnt_res, ctrl_mux64, ctrl_mux80 : out std_logic
		);
	end component;

	-- substitution layer for decoding
	component slayer is
		generic (
				w_4 : integer := 4
		);
		port (
			input : in std_logic_vector(w_4-1 downto 0);
			output : out std_logic_vector(w_4-1 downto 0)
		);
	end component;

	-- permutation layer for decoding
	component pLayer is
		generic(w_64 : integer := 64);
		port(
			input : in std_logic_vector(w_64-1 downto 0);
			output : out std_logic_vector(w_64-1 downto 0)
		);
	end component;

	-- key update for decoding
	component keyupd is
		generic(	
			w_5 : integer := 5;
			w_80: integer := 80
		);
		port(
			num : in std_logic_vector(w_5-1 downto 0);
			key : in std_logic_vector(w_80-1 downto 0);			
			keyout : out std_logic_vector(w_80-1 downto 0)
		);
	end component;

	-- 'register' for 32 bit output and 64 bit input
	component outputRegister is
		generic (
			w_2 : integer := 2;
			w_32: integer := 32;
			w_64: integer := 64
		);
		port(			
			ctrl : in std_logic_vector(w_2-1 downto 0);
			input : in std_logic_vector(w_64-1 downto 0);
			output : out std_logic_vector(w_32-1 downto 0);
			rst, clk, rd : in std_logic;
			ready : out std_logic
		);
	end component;
	
	-- counter for decoding. It is counting up!!!
	component counter is
		generic (
			w_2 : integer := 2;
			w_5 : integer := 5
		);
		port (
			clk, reset, cnt_res : in std_logic;
			info : out std_logic_vector(w_2-1 downto 0);
			num : out std_logic_vector (w_5-1 downto 0)
		);
	end component;

	-- 'multiplexer' for 32/64 bit input and 64 bit output
	component mux64 is
		generic (
			w_2 : integer := 2;
			w_32 : integer := 32;
			w_64 : integer := 64
			);
		port(
			i0ctrl : in std_logic_vector (w_2-1 downto 0);
			input0 : in std_logic_vector(w_32-1 downto 0);
			input1 : in std_logic_vector(w_64-1 downto 0);
			output : inout std_logic_vector(w_64-1 downto 0);
			ctrl, clk, reset : in std_logic			
		);
	end component;
	
	-- 'multiplexer' for 32/80 bit input and 80 bit output
	component mux80 is
		generic (
			w_2 : integer := 2;
			w_32 : integer := 32;
			w_80 : integer := 80
			);
		port(
			i0ctrl : in std_logic_vector (w_2-1 downto 0);
			input0 : in std_logic_vector(w_32-1 downto 0);
			input1 : in std_logic_vector(w_80-1 downto 0);
			output : inout std_logic_vector(w_80-1 downto 0);
			ctrl, clk, reset : in std_logic			
		);
	end component;
	
	component xorModule is
		generic(
			w : positive
		);
		port(
			inputA, inputB : in std_logic_vector( w-1 downto 0 );
			output : out std_logic_vector ( w-1 downto 0 )
		);
	end component;
	
	-- signals
	
	signal ro32ctrl, key_ctrl, plain_ctrl, info : std_logic_vector(w_2-1 downto 0);
	signal keynum : std_logic_vector (w_5-1 downto 0);
	signal toXor, ciphertext, P, Pout : std_logic_vector (w_64-1 downto 0);
	signal keyfout, kupd : std_logic_vector (w_80-1 downto 0);
	signal ready_sig, mux64ctrl, mux80ctrl, cnt_res : std_logic;
	
	begin
	
	    -- connections

		mux_64: mux64 port map(
			input0 => input, input1 => Pout, output => toXor, ctrl => mux64ctrl, 
			i0ctrl => plain_ctrl, clk => clk, reset => reset);
		mux_80: mux80 port map(
			input0 => input, input1 => kupd, output => keyfout, ctrl => mux80ctrl,
			i0ctrl => key_ctrl, clk => clk, reset => reset);
		slayers : for N in 15 downto 0 generate 
			s_x: slayer port map(input => ciphertext(4*N+3 downto 4*N), output => P(4*N+3 downto 4*N));
		end generate slayers;
		p1: pLayer port map(input => P, output => Pout);
		mixer: keyupd port map(key => keyfout, num => keynum, keyout => kupd);
		output_reg: outputRegister port map(rst => reset, clk => clk, rd => ready_sig, ctrl => ro32ctrl,
			input => ciphertext, output => output, ready => ready);		
		SM: PresentStateMachine port map(ctrl => ctrl, outReg => ro32ctrl, reset => reset, 
			ready => ready_sig, cnt_res => cnt_res, ctrl_mux64 => mux64ctrl, ctrl_mux80 => mux80ctrl, 
			clk => clk, key_ctrl => key_ctrl,  plain_ctrl => plain_ctrl, info => info
			);
		count: counter port map( clk => clk, reset => reset, cnt_res => cnt_res, info => info, num => keynum);	
		ciphertext <= toXor xor keyfout(79 downto 16);
end Behavioral;
