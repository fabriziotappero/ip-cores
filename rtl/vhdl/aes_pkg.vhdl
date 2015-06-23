----------------------------------------------------------------------
----                                                              ----
---- Pipelined Aes IP Core                                        ----
----                                                              ----
---- This file is part of the Pipelined AES project               ----
---- http://www.opencores.org/cores/aes_pipe/                     ----
----                                                              ----
---- Description                                                  ----
---- Implementation of AES IP core according to                   ----
---- FIPS PUB 197 specification document.                         ----
----                                                              ----
---- To Do:                                                       ----
----   -                                                          ----
----                                                              ----
---- Author:                                                      ----
----      - Subhasis Das, subhasis256@gmail.com                   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2009 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
------------------------------------------------------
-- Project: AESFast
-- Author: Subhasis
-- Last Modified: 25/03/10
-- Email: subhasis256@gmail.com
------------------------------------------------------
-- Common library file containing common data path definitions
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package aes_pkg is
	-- A column of 4 bytes
	type blockcol is array(3 downto 0) of std_logic_vector(7 downto 0);
	constant zero_col: blockcol := (X"00", X"00", X"00", X"00");
	-- A datablock of 16 bytes
	type datablock is array(3 downto 0, 3 downto 0) of std_logic_vector(7 downto 0);
	constant zero_data: datablock := ((X"00", X"00", X"00", X"00"),(X"00", X"00", X"00", X"00"), (X"00", X"00", X"00", X"00"), (X"00", X"00", X"00", X"00"));
	-- Vector of columns
	type colnet is array(natural range<>) of blockcol;
	-- Vector of blocks
	type datanet is array(natural range<>) of datablock;
	-- the 10 rcon bytes
	type rconarr is array(9 downto 0) of std_logic_vector(7 downto 0);
	constant rcon: rconarr := (X"36", X"1b", X"80", X"40", X"20", X"10", X"08", X"04", X"02", X"01");
end package aes_pkg;
