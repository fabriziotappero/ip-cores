-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     State machine for Present decoder. It controls entire     ----
---- environment for decoding. We can feature 2 'steady states'    ----
---- and 2 'running states'. For more informations see below       ----
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
use work.kody.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FullDecoderSM is
	port(
		key_gen_start : out std_logic;
		key_gen_ready : in std_logic;
		decode_start  : out std_logic;
		decode_ready  : in std_logic;
		full_decoder_start :in std_logic;
		full_decoder_ready : out std_logic;
		clk, reset  :in std_logic
	);
end FullDecoderSM;

architecture Behavioral of FullDecoderSM is

	signal state : decode_states;
	signal next_state : decode_states;	

begin

	states : process(state, full_decoder_start, key_gen_ready, decode_ready)
		begin
			case state is
			    ---- It is No operation - waiting for proper data in the input ----
				when NOP =>
					key_gen_start <= '0';
					decode_start <= '0';
					full_decoder_ready <= '0';
					if (full_decoder_start = '1') then
						next_state <= KG_START;
					else
						next_state <= NOP;
					end if;
				---- It is running key generator for decoding
				when KG_START =>
					key_gen_start <= '1';
					decode_start <= '0';
					full_decoder_ready <= '0';
					if (key_gen_ready = '1') then
						next_state <= DEC_START;
					else
						next_state <= KG_START;
					end if;
				---- enerated key for decoding is ready. Now we are decoding ----
				when DEC_START	 =>
					key_gen_start <= '1';
					decode_start <= '1';
					full_decoder_ready <= '0';
					if (decode_ready = '1') then
						next_state <= DEC_READY;
					else
						next_state <= DEC_START;
					end if;
				---- Decoding was ended. Waiting for user retrieving data ---- 
				---- and give information about new operation ----
				when DEC_READY =>
					key_gen_start <= '1';
					decode_start <= '1';
					full_decoder_ready <= '1';
					if (full_decoder_start = '1') then
						next_state <= DEC_READY;
					else
						next_state <= NOP;
					end if;
			end case;
		end process states;

	SM : process (clk, reset)
			begin
				if (reset = '1') then
					state <= NOP;				
				elsif (clk'Event and clk = '1') then
					state <= next_state;
				end if;
			end process SM;

end Behavioral;

