-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- forwarding.vhd  --  Describes the unit capable of detecting data harzards and forwards
--                     register values form memory and writeback pipeline stages into execute stage
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

entity forwarding is
	port (
		reg : in std_logic_vector(5 downto 0);

		fwd_wb2_enable : in std_logic;
		fwd_wb2_address : in std_logic_vector(4 downto 0);
		fwd_wb2_data : in std_logic_vector(31 downto 0);
		fwd_wb1_enable : in std_logic;
		fwd_wb1_address : in std_logic_vector(4 downto 0);
		fwd_wb1_data : in std_logic_vector(31 downto 0);
		fwd_wb1_is_invalid : in std_logic;
		fwd_mem_enable : in std_logic;
		fwd_mem_address : in std_logic_vector(4 downto 0);
		fwd_mem_data : in std_logic_vector(31 downto 0);
		fwd_mem_is_invalid : in std_logic;

		exe_pc_plus_8 : in unsigned(31 downto 0);
		rfile_data : in std_logic_vector(31 downto 0);
		
		op_data : out unsigned(31 downto 0);
		forward_ok : out std_logic
	);
end;

architecture rtl of forwarding is
begin
	forwarding : process(reg, exe_pc_plus_8, rfile_data,
						fwd_wb2_enable, fwd_wb2_address, fwd_wb2_data,
						fwd_wb1_enable, fwd_wb1_address, fwd_wb1_data, fwd_wb1_is_invalid,
						fwd_mem_enable, fwd_mem_address, fwd_mem_data, fwd_mem_is_invalid) is
	begin
		if reg(5) = '1'
		then
			-- PC+8 is used as an operand
			op_data <= exe_pc_plus_8;
			forward_ok <= '1';
		else
			if fwd_mem_enable = '1' and fwd_mem_address = reg(4 downto 0)
			then
				op_data <= unsigned(fwd_mem_data);
				forward_ok <= not fwd_mem_is_invalid;
			elsif fwd_wb1_enable = '1' and fwd_wb1_address = reg(4 downto 0)
			then
				op_data <= unsigned(fwd_wb1_data);
				forward_ok <= not fwd_wb1_is_invalid;
			elsif fwd_wb2_enable = '1' and fwd_wb2_address = reg(4 downto 0)
			then
				op_data <= unsigned(fwd_wb2_data);
				forward_ok <= '1';
			else
				op_data <= unsigned(rfile_data);
				forward_ok <= '1';
			end if;
		end if;
	end process;
end;