----------------------------------------------------------------------  
----  operand_ram                                                 ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    BRAM memory and logic to the store 4 (1536-bit) operands  ----
----    for the montgomery multiplier                             ----            
----                                                              ---- 
----  Dependencies:                                               ----
----    - operand_dp (coregen)                                    ----
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


entity operand_ram is
  port( -- write_operand_ack voorzien?
    -- global ports
    collision : out std_logic;
    -- bus side connections (32-bit serial)
    bus_clk        : in std_logic;
    operand_addr   : in std_logic_vector(5 downto 0);
    operand_in     : in std_logic_vector(31 downto 0);
    operand_in_sel : in std_logic_vector(1 downto 0);
    result_out     : out std_logic_vector(31 downto 0);
    write_operand  : in std_logic;
    -- multiplier side connections (1536 bit parallel)
    core_clk        : in std_logic;
    result_dest_op  : in std_logic_vector(1 downto 0);
    operand_out     : out std_logic_vector(1535 downto 0);
    operand_out_sel : in std_logic_vector(1 downto 0); -- controlled by bus side
    write_result    : in std_logic;
    result_in       : in std_logic_vector(1535 downto 0)
  );
end operand_ram;


architecture Behavioral of operand_ram is
  -- port a signals
  signal addra           : std_logic_vector(5 downto 0);
  signal part_enable     : std_logic_vector(3 downto 0);
  signal wea             : std_logic_vector(3 downto 0);
  signal write_operand_i : std_logic;

  -- port b signals
  signal addrb  : std_logic_vector(1 downto 0);
  signal web    : std_logic_vector(0 downto 0);
  signal douta0 : std_logic_vector(31 downto 0);
  signal douta1 : std_logic_vector(31 downto 0);
  signal douta2 : std_logic_vector(31 downto 0);

begin

	-- WARNING: Very Important!
	-- wea & web signals must never be high at the same time !!
	-- web has priority 
	write_operand_i <= write_operand and not write_result;
	web(0) <= write_result;
	collision <= write_operand and write_result;
	
	-- the dual port ram has a depth of 4 (each layer contains an operand)
	-- result is always stored in position 3
	-- doutb is always result
	with write_result select
  addrb <= result_dest_op when '1',
           operand_out_sel when others;
	
	
	
	with operand_addr(5 downto 4) select
		part_enable <=  "0001" when "00",
		                "0010" when "01",
				            "0100" when "10",
				            "1000" when others;
  
  with write_operand select
    wea <= part_enable when '1',
           "0000" when others;
  
	addra <= operand_in_sel & operand_addr(3 downto 0);
	
	with operand_addr(5 downto 4) select
		result_out <= douta0 when "00",
		              douta1 when "01",
				          douta2 when others;
	
	-- 3 instances of a dual port ram to store the parts of the operand
  op_0 : operand_dp
  port map (
    clka  => bus_clk,
    wea   => wea(0 downto 0),
    addra => addra,
    dina  => operand_in,
    douta => douta0,
    clkb  => core_clk,
    web   => web,
    addrb => addrb,
    dinb  => result_in(511 downto 0),
    doutb => operand_out(511 downto 0)
  );

  op_1 : operand_dp
  port map (
    clka  => bus_clk,
    wea   => wea(1 downto 1),
    addra => addra,
    dina  => operand_in,
    douta => douta1,
    clkb  => core_clk,
    web   => web,
    addrb => addrb,
    dinb  => result_in(1023 downto 512),
    doutb => operand_out(1023 downto 512)
  );

  op_2 : operand_dp
  port map (
    clka  => bus_clk,
    wea   => wea(2 downto 2),
    addra => addra,
    dina  => operand_in,
    douta => douta2,
    clkb  => core_clk,
    web   => web,
    addrb => addrb,
    dinb  => result_in(1535 downto 1024),
    doutb => operand_out(1535 downto 1024)
  );

end Behavioral;
