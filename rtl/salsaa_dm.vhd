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
use IEEE.std_logic_unsigned.all;  
use IEEE.NUMERIC_STD.all;


entity salsaa_dm is
	port (
		clk 		: in std_logic;
		reset 	: in std_logic;

		-- iface for user
		data 			: out std_logic_vector(31 downto 0);
		data_req 	: in std_logic;
		data_valid 	: out std_logic;
		
		-- iface to salsaa_mc
		mc_data 		: in std_logic_vector(511 downto 0);
		mc_restart 	: out std_logic;
		mc_busy 		: in std_logic
		
	);
end entity salsaa_dm;

architecture rtl of salsaa_dm is

type reg_type is array(0 to 15) of std_logic_vector(31 downto 0);

signal state		 	: std_logic_vector (3 downto 0);
signal reg				: reg_type;
signal reg_idx		 		: std_logic_vector (3 downto 0);


constant dm_rst 			: std_logic_vector := x"0";
constant dm_wmc_dr	 	: std_logic_vector := x"1";
constant dm_wmc_ndr	 	: std_logic_vector := x"2";
constant dm_idl		 	: std_logic_vector := x"3";
constant dm_lmd		 	: std_logic_vector := x"4";
constant dm_lmdps		 	: std_logic_vector := x"5";
constant dm_ps			 	: std_logic_vector := x"6";

constant max_reg_idx 	: std_logic_vector := x"f";

begin

main:	process(clk) is
begin
	if (clk'event and clk='1') then
		if (reset='1') then	
			state <= dm_rst;
			
			for Z in 0 to 15
			loop
				--reg(Z) <= mc_data(32 * Z + 31 downto 32 * Z + 0);			
				reg(Z) <= x"00000000";			
			end loop;
			
			data_valid <= '0';
			data <= x"00000000";
			reg_idx <= x"0";
			
		else
			
			case state is
			
				when dm_rst =>
					reg_idx <= x"0";
					data_valid <= '0';
					mc_restart <= '0';
					
					if mc_busy = '0' and data_req = '1' then
						state <= dm_lmdps;
					elsif data_req = '1' then
						state <= dm_wmc_dr;
					elsif  mc_busy = '0' then
						state <= dm_lmd;
					end if;

				when dm_lmdps =>
				
					-- state to reg
					reg(00) <= mc_data(32 * 00 + 31 downto 32 * 00 + 0);
					reg(01) <= mc_data(32 * 01 + 31 downto 32 * 01 + 0);
					reg(02) <= mc_data(32 * 02 + 31 downto 32 * 02 + 0);
					reg(03) <= mc_data(32 * 03 + 31 downto 32 * 03 + 0);
					reg(04) <= mc_data(32 * 04 + 31 downto 32 * 04 + 0);
					reg(05) <= mc_data(32 * 05 + 31 downto 32 * 05 + 0);
					reg(06) <= mc_data(32 * 06 + 31 downto 32 * 06 + 0);
					reg(07) <= mc_data(32 * 07 + 31 downto 32 * 07 + 0);
					reg(08) <= mc_data(32 * 08 + 31 downto 32 * 08 + 0);
					reg(09) <= mc_data(32 * 09 + 31 downto 32 * 09 + 0);
					reg(10) <= mc_data(32 * 10 + 31 downto 32 * 10 + 0);
					reg(11) <= mc_data(32 * 11 + 31 downto 32 * 11 + 0);
					reg(12) <= mc_data(32 * 12 + 31 downto 32 * 12 + 0);
					reg(13) <= mc_data(32 * 13 + 31 downto 32 * 13 + 0);
					reg(14) <= mc_data(32 * 14 + 31 downto 32 * 14 + 0);
					reg(15) <= mc_data(32 * 15 + 31 downto 32 * 15 + 0);
					
					reg_idx <= reg_idx + x"1";
					data_valid <= '1';
					mc_restart <= '1';
					data <= mc_data(32 * 00 + 31 downto 32 * 00 + 0);
					
					if data_req = '1' then
						state <= dm_ps;
					else
						state <= dm_idl;							
					end if;

				when dm_lmd =>
				
					-- state to reg
					reg(00) <= mc_data(32 * 00 + 31 downto 32 * 00 + 0);
					reg(01) <= mc_data(32 * 01 + 31 downto 32 * 01 + 0);
					reg(02) <= mc_data(32 * 02 + 31 downto 32 * 02 + 0);
					reg(03) <= mc_data(32 * 03 + 31 downto 32 * 03 + 0);
					reg(04) <= mc_data(32 * 04 + 31 downto 32 * 04 + 0);
					reg(05) <= mc_data(32 * 05 + 31 downto 32 * 05 + 0);
					reg(06) <= mc_data(32 * 06 + 31 downto 32 * 06 + 0);
					reg(07) <= mc_data(32 * 07 + 31 downto 32 * 07 + 0);
					reg(08) <= mc_data(32 * 08 + 31 downto 32 * 08 + 0);
					reg(09) <= mc_data(32 * 09 + 31 downto 32 * 09 + 0);
					reg(10) <= mc_data(32 * 10 + 31 downto 32 * 10 + 0);
					reg(11) <= mc_data(32 * 11 + 31 downto 32 * 11 + 0);
					reg(12) <= mc_data(32 * 12 + 31 downto 32 * 12 + 0);
					reg(13) <= mc_data(32 * 13 + 31 downto 32 * 13 + 0);
					reg(14) <= mc_data(32 * 14 + 31 downto 32 * 14 + 0);
					reg(15) <= mc_data(32 * 15 + 31 downto 32 * 15 + 0);
					
					reg_idx <= x"0";
					data_valid <= '0';
					mc_restart <= '1';
					
					if data_req = '1' then
						state <= dm_ps;
					else
						state <= dm_idl;							
					end if;
					
				when dm_ps =>
						
					-- loading data to output
					data <= reg(to_integer(unsigned(reg_idx)));
					data_valid <= '1';
					
					-- mc should not restart in this state
					mc_restart <= '0';
					
					-- moving reg_idx
					if reg_idx = max_reg_idx then
						reg_idx <= x"0";
					else
						reg_idx <= reg_idx + x"1";
					end if;
					
					
					
					-- selecting next state
					if reg_idx = max_reg_idx then
						-- considering the situation when the last reg_idx
						if data_req = '0' and mc_busy = '0' then
							state <= dm_lmd;
						elsif data_req = '0' and mc_busy = '1' then
							state <= dm_wmc_ndr;
						elsif data_req = '1' and mc_busy = '0' then
							state <= dm_lmdps;
						elsif data_req = '1' and mc_busy = '1' then
							state <= dm_wmc_dr;
						end if;
					else
						-- considering typical situation
						if data_req = '1' then
							state <= dm_ps;
						elsif data_req = '0' then
							state <= dm_idl;
						end if;					
					end if;

				when dm_idl =>
						
					-- no valid data
					data_valid <= '0';
					
					-- mc should not restart in this state
					mc_restart <= '0';
					
					-- selecting next state CHECK THIS CODE
					if data_req = '1' then
						state <= dm_ps;
					elsif data_req = '0' then
						state <= dm_idl;
					end if;
					
				when dm_wmc_dr =>
						
					-- no valid data
					data_valid <= '0';
					
					-- mc should not restart in this state
					mc_restart <= '0';
					
					-- sett to the beginning of data register
					reg_idx <= x"0";
										
					-- selecting next state
					if mc_busy = '0' then
						state <= dm_lmdps;
					end if;

				when dm_wmc_ndr =>
						
					-- no valid data
					data_valid <= '0';
					
					-- mc should not restart in this state
					mc_restart <= '0';
					
					-- set to the beginning of data register
					reg_idx <= x"0";
										
					-- selecting next state
					if mc_busy = '0' and data_req = '0' then
						state <= dm_lmd;
					elsif mc_busy = '0' and data_req = '1' then
						state <= dm_lmdps;
					elsif mc_busy = '1' and data_req = '0' then
						state <= dm_wmc_ndr;
					elsif mc_busy = '1' and data_req = '1' then
						state <= dm_wmc_dr;
					end if;

				when others =>
					null;		
					
			end case;	
			
		end if;
	end if;
end process;

end architecture rtl;
