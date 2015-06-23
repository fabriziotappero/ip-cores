-- Twofish_testbenches_secondary_circuits.vhd
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
-- description	: 	this file contains all the secondary circuits that are needed for running the testbenches
--


--
-- reg128
--

library ieee;
use ieee.std_logic_1164.all;

entity reg128 is
port ( in_reg128 : in std_logic_vector(127 downto 0);
		out_reg128 : out std_logic_vector(127 downto 0);
		enable_reg128, reset_reg128,clk_reg128 : in std_logic
	);
end reg128;

architecture reg128_arch of reg128 is
begin
	clk_proc: process(clk_reg128, reset_reg128,enable_reg128)
		variable	internal_state : std_logic_vector(127 downto 0);
	begin
		if reset_reg128 = '1' then
			internal_state := ( others => '0' );
		elsif (clk_reg128'event and clk_reg128 = '1') then
			if enable_reg128='1' then
				internal_state := in_reg128;
			else
				internal_state := internal_state;
			end if;
		end if;			
	out_reg128 <= internal_state;
	end process clk_proc;
end reg128_arch;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- mux128
--

library ieee;
use ieee.std_logic_1164.all;

entity mux128 is
port ( in1_mux128, in2_mux128	: in std_logic_vector(127 downto 0);
		selection_mux128	: in std_logic;
		out_mux128 : out std_logic_vector(127 downto 0)
	);
end mux128;

architecture mux128_arch of mux128 is
begin
	with selection_mux128 select
		out_mux128 <= in1_mux128 when '0',
								in2_mux128 when others;
end mux128_arch;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
--																			--
-- 								new component								--
--																			--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

--
-- demux128
--

library ieee;
use ieee.std_logic_1164.all;

entity demux128 is
port	( in_demux128 : in std_logic_vector(127 downto 0);
		out1_demux128, out2_demux128 : out std_logic_vector(127 downto 0);
		selection_demux128 : in std_logic
	);
end demux128;

architecture demux128_arch of demux128 is
begin
	demux_proc: process(in_demux128, selection_demux128)
	begin
		if selection_demux128 = '0' then
			out1_demux128 <= in_demux128;
		else 
			out2_demux128 <= in_demux128;
		end if;
	end process demux_proc;
end demux128_arch;
