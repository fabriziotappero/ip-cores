-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- writeback.vhd  --  Description of the writeback pipeline stage
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

entity writeback is
	port(
		clk : in std_logic;
		
		wb_stage_valid : in std_logic;
		wb_rdest_wren : in std_logic;
		wb_rdest_adr : in std_logic_vector(4 downto 0);
		wb_branch_en : in std_logic;
		wb_wb_sel : in std_logic;
		wb_exe_data : in std_logic_vector(31 downto 0);
		wb_mem_ctrl : in MEM_OPERATION;
		
		rfile_wr_enable : out std_logic;
		rfile_address : out std_logic_vector(4 downto 0);
		wb_data : out std_logic_vector(31 downto 0);

		fwd_wb2_enable : out std_logic;
		fwd_wb2_address : out std_logic_vector(4 downto 0);
		fwd_wb2_data : out std_logic_vector(31 downto 0);

		avm_data_readdatavalid : in  std_logic;
		avm_data_readdata      : in  std_logic_vector(31 downto 0);
		
		wb_pc_wr : out std_logic;
		wb_blocked_n : out std_logic
	);
end entity;

architecture rtl of writeback is
	signal outdata : std_logic_vector(31 downto 0);
	signal avalon_data : std_logic_vector(31 downto 0);
	signal rd_ok : std_logic;
	
begin
	-- 0 if the stage should stall because read data is not valid
	rd_ok <= avm_data_readdatavalid when wb_mem_ctrl = LOAD_WORD or wb_mem_ctrl = LOAD_BYTE or wb_mem_ctrl = LOAD_BURST else '1';
	wb_blocked_n <= rd_ok or not wb_stage_valid;

	-- write to PC on branches from avalon data
	wb_pc_wr <= wb_branch_en and wb_wb_sel and wb_stage_valid and rd_ok;

	-- output MUX between avalon data and execute data
	outdata <= wb_exe_data when wb_wb_sel = '0' else avalon_data;

	-- register file signals (also writeback 1 forwarding path)
	rfile_wr_enable <= wb_rdest_wren and wb_stage_valid;
	rfile_address <= wb_rdest_adr;
	wb_data <= outdata;

	avm : process(wb_exe_data, avm_data_readdata, wb_mem_ctrl) is
	begin
		-- convert byte->word if a load byte command
		if wb_mem_ctrl = LOAD_BYTE
		then
			case wb_exe_data(1 downto 0) is
			when "00" =>
				avalon_data <= (31 downto 8 => '0') & avm_data_readdata(7 downto 0);
			when "01" =>
				avalon_data <= (31 downto 8 => '0') & avm_data_readdata(15 downto 8);
			when "10" =>
				avalon_data <= (31 downto 8 => '0') & avm_data_readdata(23 downto 16);
			when others =>
				avalon_data <= (31 downto 8 => '0') & avm_data_readdata(31 downto 24);
			end case;
		else
		-- else data just goes through
			avalon_data <= avm_data_readdata;
		end if;
	end process;

	-- register for writeback2 forwarding path
	process(clk) is
	begin
		if rising_edge(clk)
		then
			fwd_wb2_enable <= wb_rdest_wren and wb_stage_valid;
			fwd_wb2_address <= wb_rdest_adr;
			fwd_wb2_data <= outdata;
		end if;
	end process;

end architecture;