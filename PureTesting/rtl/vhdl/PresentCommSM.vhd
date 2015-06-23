-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     State machine of 'pure' Present cipher with RS-232        ----
---- communication with PC. For more informations see below.       ----
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

entity PresentCommSM is
	port (
		clk				: in STD_LOGIC;
		reset				: in STD_LOGIC;
		RDAsig			: in STD_LOGIC;
		TBEsig			: in STD_LOGIC;
		RDsig				: out STD_LOGIC;
		WRsig				: out STD_LOGIC;
		textDataEn     : out STD_LOGIC;
		textDataShift	: out STD_LOGIC;
		keyDataEn		: out STD_LOGIC;
		keyDataShift	: out STD_LOGIC;
		ciphDataEn     : out STD_LOGIC;
		ciphDataShift  : out STD_LOGIC;
		startSig			: out STD_LOGIC;
		readySig			: in STD_LOGIC
	);
end PresentCommSM;

architecture Behavioral of PresentCommSM is

-- counter used for determine number of readed/sended data (key, text, result)
component counter is
	generic (
		w_5 : integer := 5
	);
	port (
		clk, reset, cnt_res : in std_logic;
		num : out std_logic_vector (w_5-1 downto 0)
	);
end component counter;

-- signals

signal state      : stany_comm := NOP;
signal next_state : stany_comm := NOP;

-- modify for variable key size
signal serialDataCtrCt    : STD_LOGIC;
signal serialDataCtrOut   : STD_LOGIC_VECTOR(3 downto 0);
signal serialDataCtrReset : STD_LOGIC;
signal ctrReset			  : STD_LOGIC;
-- DO NOT MODIFY!!!
signal shiftDataCtrCt    : STD_LOGIC;
signal shiftDataCtrOut   : STD_LOGIC_VECTOR(2 downto 0);

begin
    -- In this state machine is determined, that firs data should be 64 bit text
	-- after text, key should appear. After receiving last byte of key, ciphertext
	-- is counted. And later it is sended back to PC.
	ctrReset <= serialDataCtrReset or reset;
	SM : process(state, RDAsig, TBEsig, shiftDataCtrOut, serialDataCtrOut, readySig)
		begin
			case state is
			    -- No operation - waiting for incoming data
				when NOP =>
					RDsig					 <= '0';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '0';
					serialDataCtrCt	 <= '0';
					shiftDataCtrCt		 <= '0';
					serialDataCtrReset <= '0';
					-- data has come
					if (RDAsig = '1') then
						next_state <= READ_DATA_TEXT;
					else
						next_state <= NOP;
					end if;
				-- Text data enable and read data
				when READ_DATA_TEXT =>
					RDsig					 <= '1';
					WRsig					 <= '0';
					textDataEn			 <= '1';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '0';
					-- counter of retrieved bytes
					serialDataCtrCt	 <= '1';
					shiftDataCtrCt		 <= '0';
					serialDataCtrReset <= '0';
					next_state <= DECODE_READ_TEXT;
				-- Data readed, stop counter and check if proper number of byte
				-- was readed
				when DECODE_READ_TEXT =>
					RDsig					 <= '0';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '0';
					serialDataCtrCt	 <= '0';
					shiftDataCtrCt		 <= '0';
					-- 8 bytes should be readed
					if (serialDataCtrOut(3 downto 0) = "1000") then
					    -- 8 bytes was readed
						next_state <= TEMP_STATE;
					else
					    -- 8 bytes was not readed
						next_state <= MOVE_TEXT;
					end if;
				-- Reset counter for next reading
				when TEMP_STATE =>
					RDsig					 <= '0';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '0';
					serialDataCtrCt	 <= '0';
					shiftDataCtrCt		 <= '0';
					serialDataCtrReset <= '1';
					next_state <= NOP_FOR_KEY;
				-- Here data are shfted in shift register - another shift counter are used
				when MOVE_TEXT =>
					RDsig					 <= '0';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '1';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '0';
					serialDataCtrCt	 <= '0';
					shiftDataCtrCt 	 <= '1';
					serialDataCtrReset <= '0';
					if (shiftDataCtrOut(2 downto 0) = "111") then
						next_state <= NOP;
					else
						next_state <= MOVE_TEXT;
					end if;
				-- "No operation 2" waiting for data - it could be optimized in way,
				-- that waiting for key and text could be the same state, but it was
				-- intentionally separated.
				when NOP_FOR_KEY	=>
					RDsig					 <= '0';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '0';
					serialDataCtrCt	 <= '0';
					shiftDataCtrCt		 <= '0';
					serialDataCtrReset <= '0';
					if (RDAsig = '1') then
					    -- data has come
						next_state <= READ_DATA_KEY;
					else
						next_state <= NOP_FOR_KEY;
					end if;
			    -- Key data enable and read data
				when READ_DATA_KEY =>
					RDsig					 <= '1';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '1';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '0';
					-- counter of retrieved bytes
					serialDataCtrCt	 <= '1';
					shiftDataCtrCt		 <= '0';
					serialDataCtrReset <= '0';
					next_state <= DECODE_READ_KEY;
				-- Data readed, stop counter and check if proper number of byte
				-- was readed
				when DECODE_READ_KEY =>
					RDsig					 <= '0';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '0';
					serialDataCtrCt	 <= '0';
					shiftDataCtrCt		 <= '0';
					serialDataCtrReset <= '0';
					-- 10 bytes should be readed
					if (serialDataCtrOut(3 downto 0) = "1010") then
					    -- 10 bytes was readed
						next_state <= TEMP2_STATE;
					else
					    -- 10 bytes was not readed
						next_state <= MOVE_KEY;
					end if;
				-- Reset counter for next reading
				when TEMP2_STATE =>
					RDsig					 <= '0';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '0';
					serialDataCtrCt	 <= '0';
					shiftDataCtrCt		 <= '0';
					serialDataCtrReset <= '1';
					next_state <= PRESENT_ENCODE;
				-- Here data are shfted in shift register - another shift counter are used
				when MOVE_KEY =>
					RDsig					 <= '0';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '1';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '0';
					serialDataCtrCt	 <= '0';
					shiftDataCtrCt		 <= '1';
					serialDataCtrReset <= '0';
					if (shiftDataCtrOut(2 downto 0) = "111") then
						next_state <= NOP_FOR_KEY;
					else
						next_state <= MOVE_KEY;
					end if;
				-- All suitable data was readed Present encode start
				when PRESENT_ENCODE =>
					RDsig					 <= '0';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '1';
					serialDataCtrCt	 <= '0';
					shiftDataCtrCt		 <= '0';
					serialDataCtrReset <= '0';
					-- change state if Present result ready
					if (readySig = '1') then
						ciphDataEn			 <= '1';
						next_state <= WRITE_OUT;
					else
						ciphDataEn			 <= '0';
						next_state <= PRESENT_ENCODE;
					end if;
				-- similar control of writing result as during reading
				when WRITE_OUT =>
					RDsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '1';
					serialDataCtrCt	 <= '1';
					shiftDataCtrCt		 <= '0';
					serialDataCtrReset <= '0';
					if (serialDataCtrOut = "1000") then
						WRsig					 <= '0';
						next_state <= TEMP_OUT;
					else
						WRsig					 <= '1';
						next_state <= MOVE_OUT;
					end if;
				-- all data was sended - start new Present encode cycle
				when TEMP_OUT =>
					RDsig					 <= '0';
					WRsig					 <= '0';
					textDataEn			 <= '0';
					textDataShift		 <= '0';
					keyDataEn			 <= '0';
					keyDataShift		 <= '0';
					ciphDataEn			 <= '0';
					ciphDataShift		 <= '0';
					startSig				 <= '1';
					serialDataCtrCt	 <= '0';
					shiftDataCtrCt		 <= '0';
					serialDataCtrReset <= '1';
					next_state <= NOP;
				when MOVE_OUT =>
					if (TBEsig = '0') then
						RDsig					 <= '0';
						WRsig					 <= '0';
						textDataEn			 <= '0';
						textDataShift		 <= '0';
						keyDataEn			 <= '0';
						keyDataShift		 <= '0';
						ciphDataEn			 <= '0';
						ciphDataShift		 <= '0';
						startSig				 <= '1';
						serialDataCtrCt	 <= '0';
						shiftDataCtrCt		 <= '0';
						serialDataCtrReset <= '0';
						next_state <= MOVE_OUT;
					else
						RDsig					 <= '0';
						WRsig					 <= '0';
						textDataEn			 <= '0';
						textDataShift		 <= '0';
						keyDataEn			 <= '0';
						keyDataShift		 <= '0';
						ciphDataEn			 <= '0';
						ciphDataShift		 <= '1';
						startSig				 <= '1';
						serialDataCtrCt	 <= '0';
						shiftDataCtrCt		 <= '1';
						serialDataCtrReset <= '0';
						if (shiftDataCtrOut = "111") then
							next_state <= WRITE_OUT;
						else
							next_state <= MOVE_OUT;
						end if;
					end if;
			end case;
		end process SM;

	state_modifier : process (clk, reset)
		begin
		   if (reset = '1') then
					state <= NOP;	
			elsif (clk = '1' and clk'Event) then
					state <= next_state;
			end if;
		end process state_modifier;
	
    -- counter for controling number of bytes of readed data
	dataCounter : counter 
		generic map(
			w_5 => 4
		)
		port map ( 
			cnt_res  => serialDataCtrCt, 
			num => serialDataCtrOut,
			clk    => clk, 
			reset  => ctrReset
		);

	-- counter for controling number of shifted bits of readed data
	shiftCounter : counter 
		generic map(
			w_5 => 3
		)
		port map ( 
			cnt_res  => shiftDataCtrCt, 
			num => shiftDataCtrOut,
			clk    => clk, 
			reset  => reset
		);

end Behavioral;

