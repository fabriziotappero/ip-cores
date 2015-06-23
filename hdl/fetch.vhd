-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- fetch.vhd  --  Descrption of the fetch pipeline stage
--
-- Written By -  Jonathan Masur and Xavier Jimenez (2013)
--
-- This program is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation; either version 2, or (at your option) any
-- later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- In other words, you are welcome to use, share and improve this program.
-- You are forbidden to forbid anyone else to use, share and improve
-- what you give them.   Help stamp out software-hoarding!


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
	port(
		clk			: in std_logic;
		n_reset		: in std_logic;
		
		-- port to write to the programm counter
		pc_wr		: in std_logic := '0';
		pc_wrdata	: in unsigned(31 downto 0) := (others => '0');

		-- enable the fetch stage
		fetch_stage_en : in std_logic;

		-- flush output for following pipeline stages
		-- (activated on PC writes)
		flush	: out std_logic;
		
		-- enable the next stage (out)
		decode_stage_valid : out std_logic;
		dec_pc_plus_8 : out unsigned(31 downto 0);
		dec_pc_plus_4 : out unsigned(31 downto 0);

		-- memory bus
		inst_cache_adr : out std_logic_vector(31 downto 0);
		inst_cache_rd : out std_logic;

		-- enable signal for latch after the fetch stage
		fetch_latch_enable : in std_logic
	);
end entity;

architecture rtl of fetch is
	signal pc : unsigned(31 downto 0);
	signal pc4 : unsigned(31 downto 0);
	signal cur_pc : unsigned(31 downto 0);
	signal flush_r, flush_s : std_logic;
begin
	flush <= flush_s;
	-- flush the pipeline on writes (including reset and cases when a flush occurs during a miss)
	flush_s <= '1' when pc_wr = '1' or flush_r = '1' else '0';

	cur_pc <= pc_wrdata when pc_wr = '1' else pc;
	inst_cache_adr <= std_logic_vector(cur_pc);

	-- handles the reading of the instruction cache memory
	inst_cache_rd <= fetch_stage_en;
	
	-- computation of next PC value (async)
	pc4 <= cur_pc + 4;
	
	dec_pc_plus_8 <= pc4;
	dec_pc_plus_4 <= pc;

	-- handles resets and fetch latch at output of the stage
	fetchlatch:
	process(n_reset, clk) is
	begin
		if n_reset='0'
		then
			pc <= (others => '0');					-- reset address is 0x000000
			decode_stage_valid <= '0';
			flush_r <= '0';
		elsif rising_edge(clk)
		then
			if fetch_stage_en = '1'
			then
				pc <= pc4;
			else
				pc <= cur_pc;
			end if;

			if fetch_latch_enable = '1'
			then
				flush_r <= '0';
				decode_stage_valid <= fetch_stage_en;
			else
				flush_r <= flush_s;
			end if;
		end if;
	end process;

end architecture;