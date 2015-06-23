--
-- Copyright 2012 iQUBE research
--
-- This file is part of Salsa20IpCore.
--
-- Salsa20IpCore is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Salsa20IpCore is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with Salsa20IpCore.  If not, see <http://www.gnu.org/licenses/>.
--
-- contact: Rúa Fonte das Abelleiras s/n, Campus Universitario de Vigo, 36310, Vigo (Spain)
-- e-mail: lukasz.dzianach@iqube.es, info@iqube.es
-- 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;


entity salsaa is
	port (
		clk : in std_logic;
		reset : in std_logic;
		
		key : in std_logic_vector(255 downto 0);
		nonce : in std_logic_vector(63 downto 0);
		start : in std_logic;

		data_valid : out std_logic;

		data : out std_logic_vector(31 downto 0);
		data_req : in std_logic
		
	);
end entity salsaa;

architecture rtl of salsaa is

signal mc_data 		: std_logic_vector(511 downto 0);
signal mc_restart 	: std_logic;
signal mc_busy 		: std_logic;

begin

salsaa_dm_0: entity work.salsaa_dm
port map(   
	clk => clk,
	reset => reset,

	-- iface for user
	data => data,
	data_req => data_req,
	
	data_valid => data_valid,

	-- iface to salsaa_mc
	mc_data => mc_data,
	mc_restart => mc_restart,
	mc_busy => mc_busy
);

salsaa_mc_0: entity work.salsaa_mc
port map(   
	clk => clk,
	reset => reset,

	-- iface for user
	key => key,
	nonce => nonce,
	start => start,

	-- iface to salsaa_dc
	mc_data => mc_data,
	mc_restart => mc_restart,
	mc_busy => mc_busy
);

main:	process(clk) is
begin
	if (clk'event and clk='1') then
		if (reset='1') then	
		else
		end if;
	end if;
end process;


end architecture rtl;
