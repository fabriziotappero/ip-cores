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
use IEEE.std_logic_unsigned.all;  

entity salsaa_mc is
	port (
		clk 		: in std_logic;
		reset 	: in std_logic;

		-- iface for user
		key : in std_logic_vector(255 downto 0);
		nonce : in std_logic_vector(63 downto 0);
		start : in std_logic;
	
		-- iface to salsaa_dm
		mc_data 		: out std_logic_vector(511 downto 0);
		mc_restart 	: in std_logic := '0';
		mc_busy 		: out std_logic
		
	);
end entity salsaa_mc;

architecture rtl of salsaa_mc is

type x_type is array(0 to 15) of std_logic_vector(31 downto 0);

constant salsa_const_0 : std_logic_vector := x"61707865";
constant salsa_const_1 : std_logic_vector := x"3320646e";
constant salsa_const_2 : std_logic_vector := x"79622d32";
constant salsa_const_3 : std_logic_vector := x"6b206574";

constant st_rst 			: std_logic_vector := x"0";
constant st_read_in 		: std_logic_vector := x"1";
constant st_save_init 	: std_logic_vector := x"2";
constant st_perf_rnds 	: std_logic_vector := x"3";
constant st_sum_res 		: std_logic_vector := x"4";
constant st_calc_done 	: std_logic_vector := x"5";

constant max_calc_state 	: std_logic_vector (7 downto 0) := x"07";
constant max_rnds_state 	: std_logic_vector (7 downto 0) := x"09";

signal x		 			: x_type;
signal idx 				: std_logic_vector (63 downto 0);

signal state		 	: std_logic_vector (3 downto 0);
signal calc_state 	: std_logic_vector (7 downto 0);
signal rnds_state 	: std_logic_vector (7 downto 0);

signal mc_data_buf 		: std_logic_vector(511 downto 0);

begin

mc_data <= mc_data_buf;

main:	process(clk) is
begin
	if (clk'event and clk='1') then
		if (reset='1') then	
			state <= st_rst;
			mc_busy <= '1';
		else
			
			case state is
			
				when st_rst =>
					if start = '1' then
						state <= st_read_in;
					end if;

					-- reseting the index (as new nonce can is being read)
					idx <= x"0000000000000000";
					mc_busy <= '1';
					
				when st_read_in =>
					
					state <= st_save_init;

					mc_busy <= '1';
					
					x(0) <= salsa_const_0;
					x(1) <= key(32 * 0 + 31 downto 32 * 0 + 0);
					x(2) <= key(32 * 1 + 31 downto 32 * 1 + 0);
					x(3) <= key(32 * 2 + 31 downto 32 * 2 + 0);
					x(4) <= key(32 * 3 + 31 downto 32 * 3 + 0);
					x(5) <= salsa_const_1;
					x(6) <= nonce(32 * 0 + 31 downto 32 * 0 + 0);
					x(7) <= nonce(32 * 1 + 31 downto 32 * 1 + 0);
					x(8) <= idx(32 * 0 + 31 downto 32 * 0 + 0);
					x(9) <= idx(32 * 1 + 31 downto 32 * 1 + 0);
					x(10) <= salsa_const_2;
					x(11) <= key(32 * 4 + 31 downto 32 * 4 + 0);
					x(12) <= key(32 * 5 + 31 downto 32 * 5 + 0);
					x(13) <= key(32 * 6 + 31 downto 32 * 6 + 0);
					x(14) <= key(32 * 7 + 31 downto 32 * 7 + 0);
					x(15) <= salsa_const_3;
															
				when st_save_init =>

					-- prepare seq of runds
					state <= st_perf_rnds;
					calc_state <= x"00";
					rnds_state <= x"00";

					-- storing initial state of x
					mc_data_buf(32 * 00 + 31 downto 32 * 00 + 0)  <= x(00);
					mc_data_buf(32 * 01 + 31 downto 32 * 01 + 0)  <= x(01);
					mc_data_buf(32 * 02 + 31 downto 32 * 02 + 0)  <= x(02);
					mc_data_buf(32 * 03 + 31 downto 32 * 03 + 0)  <= x(03);
					mc_data_buf(32 * 04 + 31 downto 32 * 04 + 0)  <= x(04);
					mc_data_buf(32 * 05 + 31 downto 32 * 05 + 0)  <= x(05);
					mc_data_buf(32 * 06 + 31 downto 32 * 06 + 0)  <= x(06);
					mc_data_buf(32 * 07 + 31 downto 32 * 07 + 0)  <= x(07);
					mc_data_buf(32 * 08 + 31 downto 32 * 08 + 0)  <= x(08);
					mc_data_buf(32 * 09 + 31 downto 32 * 09 + 0)  <= x(09);
					mc_data_buf(32 * 10 + 31 downto 32 * 10 + 0)  <= x(10);
					mc_data_buf(32 * 11 + 31 downto 32 * 11 + 0)  <= x(11);
					mc_data_buf(32 * 12 + 31 downto 32 * 12 + 0)  <= x(12);
					mc_data_buf(32 * 13 + 31 downto 32 * 13 + 0)  <= x(13);
					mc_data_buf(32 * 14 + 31 downto 32 * 14 + 0)  <= x(14);
					mc_data_buf(32 * 15 + 31 downto 32 * 15 + 0)  <= x(15);
					
				when st_perf_rnds =>
					calc_state <= calc_state + x"01";
					if calc_state = max_calc_state then
						if rnds_state = max_rnds_state then
							state <= st_sum_res;
						else
							calc_state <= x"00";
							rnds_state <= rnds_state + x"01";
						end if;
					end if;
					
					-- processing goes here
					case calc_state is
						when x"00" =>						
							x(04) <= x(04) xor std_logic_vector( rotate_left(unsigned(x(12)+x(00)),7));
							x(09) <= x(09) xor std_logic_vector( rotate_left(unsigned(x(01)+x(05)),7));
							x(14) <= x(14) xor std_logic_vector( rotate_left(unsigned(x(06)+x(10)),7));
							x(03) <= x(03) xor std_logic_vector( rotate_left(unsigned(x(11)+x(15)),7));
						when x"01" =>
							x(08) <= x(08) xor std_logic_vector( rotate_left(unsigned(x(00)+x(04)),9));
							x(13) <= x(13) xor std_logic_vector( rotate_left(unsigned(x(05)+x(09)),9));
							x(02) <= x(02) xor std_logic_vector( rotate_left(unsigned(x(10)+x(14)),9));
							x(07) <= x(07) xor std_logic_vector( rotate_left(unsigned(x(15)+x(03)),9));
						when x"02" =>
							x(12) <= x(12) xor std_logic_vector( rotate_left(unsigned(x(04)+x(08)),13));
							x(01) <= x(01) xor std_logic_vector( rotate_left(unsigned(x(09)+x(13)),13));
							x(06) <= x(06) xor std_logic_vector( rotate_left(unsigned(x(14)+x(02)),13));
							x(11) <= x(11) xor std_logic_vector( rotate_left(unsigned(x(03)+x(07)),13));
						when x"03" =>
							x(00) <= x(00) xor std_logic_vector( rotate_left(unsigned(x(08)+x(12)),18));
							x(05) <= x(05) xor std_logic_vector( rotate_left(unsigned(x(13)+x(01)),18));
							x(10) <= x(10) xor std_logic_vector( rotate_left(unsigned(x(02)+x(06)),18));
							x(15) <= x(15) xor std_logic_vector( rotate_left(unsigned(x(07)+x(11)),18));
							
						when x"04" =>
							x(01) <= x(01) xor std_logic_vector( rotate_left(unsigned(x(03)+x(00)),07));
							x(06) <= x(06) xor std_logic_vector( rotate_left(unsigned(x(04)+x(05)),07));
							x(11) <= x(11) xor std_logic_vector( rotate_left(unsigned(x(09)+x(10)),07));
							x(12) <= x(12) xor std_logic_vector( rotate_left(unsigned(x(14)+x(15)),07));
						when x"05" =>
							x(02) <= x(02) xor std_logic_vector( rotate_left(unsigned(x(00)+x(01)),09));
							x(07) <= x(07) xor std_logic_vector( rotate_left(unsigned(x(05)+x(06)),09));
							x(08) <= x(08) xor std_logic_vector( rotate_left(unsigned(x(10)+x(11)),09));
							x(13) <= x(13) xor std_logic_vector( rotate_left(unsigned(x(15)+x(12)),09));
						when x"06" =>
							x(03) <= x(03) xor std_logic_vector( rotate_left(unsigned(x(01)+x(02)),13));
							x(04) <= x(04) xor std_logic_vector( rotate_left(unsigned(x(06)+x(07)),13));
							x(09) <= x(09) xor std_logic_vector( rotate_left(unsigned(x(11)+x(08)),13));
							x(14) <= x(14) xor std_logic_vector( rotate_left(unsigned(x(12)+x(13)),13));
						when x"07" =>
							x(00) <= x(00) xor std_logic_vector( rotate_left(unsigned(x(02)+x(03)),18));
							x(05) <= x(05) xor std_logic_vector( rotate_left(unsigned(x(07)+x(04)),18));
							x(10) <= x(10) xor std_logic_vector( rotate_left(unsigned(x(08)+x(09)),18));
							x(15) <= x(15) xor std_logic_vector( rotate_left(unsigned(x(13)+x(14)),18));
						when others =>
							null;
					end case;
					
				when st_sum_res =>
				
					-- preparing index for the next random block reneration
					idx <= idx + x"0000000000000001";
				
					mc_data_buf(32 * 00 + 31 downto 32 * 00 + 0)  <= mc_data_buf(32 * 00 + 31 downto 32 * 00 + 0) + x(00);
					mc_data_buf(32 * 01 + 31 downto 32 * 01 + 0)  <= mc_data_buf(32 * 01 + 31 downto 32 * 01 + 0) + x(01);
					mc_data_buf(32 * 02 + 31 downto 32 * 02 + 0)  <= mc_data_buf(32 * 02 + 31 downto 32 * 02 + 0) + x(02);
					mc_data_buf(32 * 03 + 31 downto 32 * 03 + 0)  <= mc_data_buf(32 * 03 + 31 downto 32 * 03 + 0) + x(03);
					mc_data_buf(32 * 04 + 31 downto 32 * 04 + 0)  <= mc_data_buf(32 * 04 + 31 downto 32 * 04 + 0) + x(04);
					mc_data_buf(32 * 05 + 31 downto 32 * 05 + 0)  <= mc_data_buf(32 * 05 + 31 downto 32 * 05 + 0) + x(05);
					mc_data_buf(32 * 06 + 31 downto 32 * 06 + 0)  <= mc_data_buf(32 * 06 + 31 downto 32 * 06 + 0) + x(06);
					mc_data_buf(32 * 07 + 31 downto 32 * 07 + 0)  <= mc_data_buf(32 * 07 + 31 downto 32 * 07 + 0) + x(07);
					mc_data_buf(32 * 08 + 31 downto 32 * 08 + 0)  <= mc_data_buf(32 * 08 + 31 downto 32 * 08 + 0) + x(08);
					mc_data_buf(32 * 09 + 31 downto 32 * 09 + 0)  <= mc_data_buf(32 * 09 + 31 downto 32 * 09 + 0) + x(09);
					mc_data_buf(32 * 10 + 31 downto 32 * 10 + 0)  <= mc_data_buf(32 * 10 + 31 downto 32 * 10 + 0) + x(10);
					mc_data_buf(32 * 11 + 31 downto 32 * 11 + 0)  <= mc_data_buf(32 * 11 + 31 downto 32 * 11 + 0) + x(11);
					mc_data_buf(32 * 12 + 31 downto 32 * 12 + 0)  <= mc_data_buf(32 * 12 + 31 downto 32 * 12 + 0) + x(12);
					mc_data_buf(32 * 13 + 31 downto 32 * 13 + 0)  <= mc_data_buf(32 * 13 + 31 downto 32 * 13 + 0) + x(13);
					mc_data_buf(32 * 14 + 31 downto 32 * 14 + 0)  <= mc_data_buf(32 * 14 + 31 downto 32 * 14 + 0) + x(14);
					mc_data_buf(32 * 15 + 31 downto 32 * 15 + 0)  <= mc_data_buf(32 * 15 + 31 downto 32 * 15 + 0) + x(15);

					mc_busy <= '0';
					
					state <= st_calc_done;

				when st_calc_done =>
					
					if mc_restart = '1' then
						-- new block requested with new input
						state <= st_read_in;
					end if;

				when others =>
					null;		
					
			end case;	
			
		end if;
	end if;
end process;

end architecture rtl;

