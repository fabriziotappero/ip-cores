-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     State machine for Present encoder with 32 bit IO. For more----
---- informations                                                  ----
---- see below.                                                    ----
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.kody.ALL;

entity PresentStateMachine is
	generic (
			w_2 : integer := 2;
			w_4 : integer := 4;
			w_5 : integer := 5;
			w_32: integer := 32;
			w_64: integer := 64;
			w_80: integer := 80
	);
	port (
		clk, reset : in std_logic;
		info : in std_logic_vector (w_2-1 downto 0);
		ctrl : in std_logic_vector (w_4-1 downto 0);
		key_ctrl: out std_logic_vector (w_2-1 downto 0);
		plain_ctrl: out std_logic_vector (w_2-1 downto 0);
		outReg : out std_logic_vector (w_2-1 downto 0);
		ready, cnt_res, ctrl_mux64, ctrl_mux80: out std_logic
	);
end PresentStateMachine;

architecture Behavioral of PresentStateMachine is
	
	signal stan : stany;
	signal stan_nast : stany;	
	
	begin
		States : process(stan, ctrl, info)
			begin
				stan_nast<= stan;
				case stan is
				    -- waiting for start
					when NOP =>
						ready <= '0';
						outReg <= out_reg_Z;
						cnt_res <= '0';
						ctrl_mux64 <= '0';
						ctrl_mux80 <= '0';
						-- read first 32 bits of key
						if (ctrl = crdk1) then 
							key_ctrl <= in_ld_reg_L;
							stan_nast <= RDK1;
						else 
							stan_nast <= NOP;
						end if;
					when RDK1 =>
					    -- read second 32 bits of key
						if (ctrl = crdk2) then
							key_ctrl <= in_ld_reg_H;
							stan_nast <= RDK2;
						-- wait for next 32 bits of key
						elsif (ctrl = crdk1) then
							key_ctrl <= in_ld_reg_L;
						else
							stan_nast <= NOP;
						end if;
					when RDK2 =>
					    -- read last 16 bits of key
						if (ctrl = crdk3) then
							key_ctrl <= in_ld_reg_HH;
							stan_nast <= RDK3;
						-- wait for next 16 bits of key
						elsif (ctrl = crdk2) then
							key_ctrl <= in_ld_reg_H;
						else
							stan_nast <= NOP;
						end if;
					when RDK3 =>
					    -- read first 32 bits of text
						if (ctrl = crdt1) then
							key_ctrl <= in_reg_Z;
							plain_ctrl <= in_ld_reg_L;
							stan_nast <= RDT1;
						-- wait for first 32 bits of text
						elsif (ctrl = crdk3) then 
							key_ctrl <= in_ld_reg_HH;
						else
							stan_nast <= NOP;
						end if;
					when RDT1 =>
					    -- read second 32 bits of text
						if (ctrl = crdt2) then
							plain_ctrl <= in_ld_reg_H;
							stan_nast <= RDT2;							
						-- wait for second 32 bits of text
						elsif (ctrl = crdt1) then
							plain_ctrl <= in_ld_reg_L;
						else 
							stan_nast <= NOP;
						end if;
					when RDT2 =>
					    --- Encode data
						if (ctrl = ccod) then
							plain_ctrl <= in_reg_Z;
							stan_nast <= COD;		
							cnt_res <= '1';
						-- Wait for encode
						elsif (ctrl = crdt2) then
							plain_ctrl <= in_ld_reg_H;
						else 
							stan_nast <= NOP;
						end if;
					when COD =>
					    -- Encode data
						if (ctrl = ccod) then							
						    -- Ready
							if (info = "00") then
								stan_nast <= CTO1;
								outReg <= out_ld_reg;
								ready <= '1';
								cnt_res <= '0';
								ready <= '1';																
							-- encoding
							elsif (info = "01") then
								ctrl_mux64 <= '1';
								ctrl_mux80 <= '1';
							end if;
						else
							stan_nast <= NOP;
						end if;						
					when CTO1 =>
					    -- send first 32 bits of data
						if (ctrl = ccto2) then
							stan_nast <= CTO2;
							outReg <= out_reg_L;
						-- wait for sending second 32 bits of data
						elsif ((ctrl = ccto1) or (ctrl = ccod)) then
							outReg <= out_reg_L;
						else 
							stan_nast <= NOP;
						end if;
					when CTO2 =>
					    -- send second 32 bits of data
						if (ctrl = ccto2) then
							stan_nast <= CTO2;
							outReg <= out_reg_H;
						else 
							stan_nast <= NOP;
						end if;
				end case;
		end process States;
		
		inne : process (clk, reset)
			begin
				if (reset = '1') then
					stan <= NOP;				
				elsif (clk'Event and clk = '1') then
					stan <= stan_nast;
				end if;
			end process inne;

	end Behavioral;

