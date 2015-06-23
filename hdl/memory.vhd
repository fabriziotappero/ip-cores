-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- memory.vhd  --  Describes the memory pipeline stage
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
use work.arm_types.all;

entity memory is
	port(
		clk : in std_logic;
		reset_n : in std_logic;
		
		mem_stage_valid : in std_logic;
		mem_rdest_wren : in std_logic;
		mem_rdest_adr : in std_logic_vector(4 downto 0);
		mem_branch_en : in std_logic;
		mem_wb_sel : in std_logic;
		mem_exe_data : in std_logic_vector(31 downto 0);
		mem_wrdata : in std_logic_vector(31 downto 0);
		mem_mem_ctrl : in MEM_OPERATION;
		mem_mem_burstcount : in std_logic_vector(3 downto 0);
		
		wb_stage_valid : out std_logic;
		wb_rdest_wren : out std_logic;
		wb_rdest_adr : out std_logic_vector(4 downto 0);
		wb_branch_en : out std_logic;
		wb_wb_sel : out std_logic;
		wb_exe_data : out std_logic_vector(31 downto 0);
		wb_mem_ctrl : out MEM_OPERATION;
		
		fwd_mem_enable : out std_logic;
		fwd_mem_address : out std_logic_vector(4 downto 0);
		fwd_mem_data : out std_logic_vector(31 downto 0);

		avm_data_waitrequest   : in  std_logic;
		avm_data_read          : out std_logic;
		avm_data_writedata     : out std_logic_vector(31 downto 0);
		avm_data_write         : out std_logic;
		avm_data_byteen        : out std_logic_vector(3 downto 0);
		avm_data_burstcount    : out std_logic_vector(4 downto 0);
		avm_data_address       : out std_logic_vector(31 downto 0);

		mem_blocked_n : out std_logic;
		mem_latch_enable : in std_logic
	);
end entity;

architecture rtl of memory is

	signal avalon_acknowledge : std_logic;

	function get_byteen(adr: std_logic_vector) return std_logic_vector is
	begin
			-- Assuming little endian memory
			case adr(1 downto 0) is
			when "00" => return "0001";
			when "01" => return "0010";
			when "10" => return "0100";
			when others => return "1000";
			end case;
	end;

begin
	process(clk, reset_n) is
	begin
		if reset_n = '0'
		then
			wb_stage_valid <= '0';
		elsif rising_edge(clk)
		then
			if mem_latch_enable = '1'
			then
				if mem_mem_ctrl = NO_MEM_OP or mem_mem_ctrl = LOAD_BURST
				then
					wb_stage_valid <= mem_stage_valid;
				else
					wb_stage_valid <= mem_stage_valid and (not avm_data_waitrequest or avalon_acknowledge);
				end if;
			end if;
		end if;
	end process;

	-- output latch
	process(clk) is
	begin
		if rising_edge(clk)
		then
			if mem_latch_enable = '1'
			then
				wb_rdest_wren <= mem_rdest_wren;
				wb_rdest_adr <= mem_rdest_adr;
				wb_branch_en <= mem_branch_en;
				wb_wb_sel <= mem_wb_sel;
				wb_exe_data <= mem_exe_data;
				wb_mem_ctrl <= mem_mem_ctrl;
			end if;
		end if;
	end process;

	-- forwarding
	fwd_mem_enable <= mem_rdest_wren and mem_stage_valid;
	fwd_mem_address <= mem_rdest_adr;
	fwd_mem_data <= mem_exe_data;

	-- avalon master
	avm_data_address <= mem_exe_data;
	process(mem_mem_ctrl, mem_mem_burstcount, mem_wrdata, mem_stage_valid, mem_exe_data, avm_data_waitrequest, avalon_acknowledge) is
	begin
		avm_data_read <= '0';
		avm_data_write <= '0';
		avm_data_writedata <= (others => '-');
		avm_data_byteen <= (others => '-');
		mem_blocked_n <= '1';

		-- 0 actually means a burst count of 16 bytes
		if mem_mem_burstcount = "0000"
		then
			avm_data_burstcount <= "10000";
		else
			avm_data_burstcount <= '0' & mem_mem_burstcount;
		end if;
	
		if avalon_acknowledge = '0'
		then
			case mem_mem_ctrl is
			when NO_MEM_OP => null;

			when LOAD_WORD =>
				avm_data_read <= mem_stage_valid;
				avm_data_write <= '0';
				avm_data_byteen <= "1111";

				mem_blocked_n <= not avm_data_waitrequest or not mem_stage_valid;

			when LOAD_BYTE =>
				avm_data_read <= mem_stage_valid;
				avm_data_write <= '0';
				avm_data_byteen <= get_byteen(mem_exe_data(1 downto 0));
				mem_blocked_n <= not avm_data_waitrequest or not mem_stage_valid;

			when LOAD_BURST => null;
			
			when STORE_WORD =>
				avm_data_read <= '0';
				avm_data_write <= mem_stage_valid;
				avm_data_writedata <= mem_wrdata;
				avm_data_byteen <= "1111";

				mem_blocked_n <= not avm_data_waitrequest or not mem_stage_valid;

			when STORE_BYTE =>
				avm_data_read <= '0';
				avm_data_write <= mem_stage_valid;
				-- Byte enable signals
				avm_data_byteen <= get_byteen(mem_exe_data(1 downto 0));
				-- Byte repetition
				avm_data_writedata <= mem_wrdata(7 downto 0) & mem_wrdata(7 downto 0) & mem_wrdata(7 downto 0) & mem_wrdata(7 downto 0);
				mem_blocked_n <= not avm_data_waitrequest or not mem_stage_valid;
			end case;
		end if;
	end process;

	-- Is nessesary to prevent multiple reads/writes to avalon bus when the WB stage is blocked (mem latch disabled)
	process(clk) is
	begin
		if rising_edge(clk)
		then
			if mem_latch_enable = '1'
			then
				avalon_acknowledge <= '0';
			else
				avalon_acknowledge <= not avm_data_waitrequest or avalon_acknowledge;
			end if;
		end if;
	end process;

end architecture;