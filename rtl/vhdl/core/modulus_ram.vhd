----------------------------------------------------------------------  
----  modulus_ram                                                 ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    BRAM memory and logic to store the 1536-bit modulus       ----
----                                                              ---- 
----  Dependencies:                                               ----
----    - operands_sp (coregen)                                   ----
----                                                              ----
----  Authors:                                                    ----
----      - Geoffrey Ottoy, DraMCo research group                 ----
----      - Jonas De Craene, JonasDC@opencores.org                ---- 
----                                                              ---- 
---------------------------------------------------------------------- 
----                                                              ---- 
---- Copyright (C) 2011 DraMCo research group and OPENCORES.ORG   ---- 
----                                                              ---- 
---- This source file may be used and distributed without         ---- 
---- restriction provided that this copyright statement is not    ---- 
---- removed from the file and that any derivative work contains  ---- 
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
---- PURPOSE.  See the GNU Lesser General Public License for more ---- 
---- details.                                                     ---- 
----                                                              ---- 
---- You should have received a copy of the GNU Lesser General    ---- 
---- Public License along with this source; if not, download it   ---- 
---- from http://www.opencores.org/lgpl.shtml                     ---- 
----                                                              ---- 
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library mod_sim_exp;
use mod_sim_exp.mod_sim_exp_pkg.all;


entity modulus_ram is
  port(
    clk           : in std_logic;
    modulus_addr  : in std_logic_vector(5 downto 0);
    write_modulus : in std_logic;
    modulus_in    : in std_logic_vector(31 downto 0);
    modulus_out   : out std_logic_vector(1535 downto 0)
  );
end modulus_ram;


architecture Behavioral of modulus_ram is
  signal part_enable : std_logic_vector(3 downto 0);
  signal wea         : std_logic_vector(3 downto 0);
  signal addra       : std_logic_vector(4 downto 0);
begin

	-- the blockram has a write depth of 2 but we only use the lower half
	addra <= '0' & modulus_addr(3 downto 0);
	
	-- the two highest bits of the address are used to select the bloc
	with modulus_addr(5 downto 4) select
		part_enable <=  "0001" when "00",
		                "0010" when "01",
				            "0100" when "10",
				            "1000" when others;

	with write_modulus select
		wea <= part_enable when '1',
		       "0000" when others;
	
	-- 4 instances of 512 bits blockram
  modulus_0 : operands_sp
  port map (
    clka  => clk,
    wea   => wea(0 downto 0),
    addra => addra,
    dina  => modulus_in,
    douta => modulus_out(511 downto 0)
  );

  modulus_1 : operands_sp
  port map (
    clka  => clk,
    wea   => wea(1 downto 1),
    addra => addra,
    dina  => modulus_in,
    douta => modulus_out(1023 downto 512)
  );

  modulus_2 : operands_sp
  port map (
    clka  => clk,
    wea   => wea(2 downto 2),
    addra => addra,
    dina  => modulus_in,
    douta => modulus_out(1535 downto 1024)
  );

end Behavioral;
