-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Key generator of Present encoder. It is only those part   ----
---- which is needed for key and cipher decoding by Present        ----
---- decoder.                                                      ----
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

entity PresentEncKeyGen is
	generic (
			w_2: integer := 2;
			w_4: integer := 4;
			w_5: integer := 5;
			w_80: integer := 80
	);
	port(
		key		: in std_logic_vector(w_80 - 1 downto 0);
		key_end	: out std_logic_vector(w_80 - 1 downto 0);		
		start, clk, reset : in std_logic;
		ready : out std_logic		
	);
end PresentEncKeyGen;

architecture Behavioral of PresentEncKeyGen is

	component Reg is
		generic(width : integer := w_80);
		port(
			input  : in  STD_LOGIC_VECTOR(width - 1 downto 0);
			output : out STD_LOGIC_VECTOR(width - 1 downto 0);
			enable : in  STD_LOGIC;
			clk    : in  STD_LOGIC;
			reset  : in  STD_LOGIC
		);
	end component Reg;
	
	component AsyncMux is
		generic (
			width : integer := 80
	);
	port ( 
		input0 : in  STD_LOGIC_VECTOR(width - 1 downto 0);
		input1 : in  STD_LOGIC_VECTOR(width - 1 downto 0);
		ctrl   : in  STD_LOGIC;
		output : out STD_LOGIC_VECTOR(width - 1 downto 0)
	);
	end component AsyncMux;

	component PresentStateMachine is
		generic (
			w_5 : integer := 5
		);
		port (			
			clk, reset, start : in std_logic;
			ready, cnt_res, ctrl_mux, RegEn: out std_logic;
			num : in std_logic_vector (w_5-1 downto 0)
		);
	end component;

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

	component counter is
		generic (
			w_5 : integer := 5
		);
		port (
			clk, reset, cnt_res : in std_logic;
			num : out std_logic_vector (w_5-1 downto 0)
		);
	end component;

    -- signals
	
	signal keynum : std_logic_vector (w_5-1 downto 0);
	signal keyfout, kupd, keyToReg : std_logic_vector (w_80-1 downto 0);
	signal ready_sig, mux_ctrl,  cnt_res, RegEn : std_logic;
	
	begin
	
	    -- connections

		mux_80: AsyncMux generic map(width => w_80) port map(
			input0 => key, 
			input1 => kupd, 
			ctrl => mux_ctrl, 
			output => keyToReg
		);
		regKey : Reg generic map(width => w_80) port map(
			input  => keyToReg, 
			output  => keyfout, 
			enable  => RegEn, 
			clk  => clk, 
			reset  => reset
		);
		mixer: keyupd port map(
			key => keyfout, 
			num => keynum, 
			keyout => kupd
		);		
		SM: PresentStateMachine port map(
			start => start, 
			reset => reset, 
			ready => ready_sig, 
			cnt_res => cnt_res, 
			ctrl_mux => mux_ctrl,
			clk => clk,
			num => keynum,
			RegEn => RegEn
		);
		count: counter port map( 
			clk => clk, 
			reset => reset, 
			cnt_res => cnt_res, 
			num => keynum
		);	
		key_end <= keyfout;
		ready <= ready_sig;
end Behavioral;
