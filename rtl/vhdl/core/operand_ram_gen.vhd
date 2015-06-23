----------------------------------------------------------------------  
----  operand_ram_gen                                             ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    BRAM memory and logic to the store the operands           ----
----    for the montgomery multiplier                             ----            
----                                                              ---- 
----  Dependencies:                                               ----
----    - tdpram_generic                                          ----
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
use mod_sim_exp.std_functions.all;

-- behavorial description of a RAM to hold the operands, with 
-- adjustable width and depth(nr of operands)
entity operand_ram_gen is
  generic(
    width : integer := 1536; -- width of the operands
    depth : integer := 4     -- nr of operands
  );
  port(
      -- global ports
    collision : out std_logic; -- 1 if simultaneous write on RAM
      -- bus side connections (32-bit serial)
    bus_clk        : in std_logic;
    write_operand  : in std_logic; -- write_enable
    operand_in_sel : in std_logic_vector(log2(depth)-1 downto 0); -- operand to write to
    operand_addr   : in std_logic_vector(log2(width/32)-1 downto 0); -- address of operand word to write
    operand_in     : in std_logic_vector(31 downto 0);  -- operand word(32-bit) to write
    result_out     : out std_logic_vector(31 downto 0); -- operand out, reading is always result operand
    operand_out_sel : in std_logic_vector(log2(depth)-1 downto 0); -- operand to give to multiplier
      -- multiplier side connections (width-bit parallel)
    core_clk        : in std_logic;
    result_dest_op  : in std_logic_vector(log2(depth)-1 downto 0); -- operand select for result
    operand_out     : out std_logic_vector(width-1 downto 0); -- operand out to multiplier
    write_result    : in std_logic; -- write enable for multiplier side
    result_in       : in std_logic_vector(width-1 downto 0) -- result to write from multiplier
  );
end operand_ram_gen;


architecture Behavioral of operand_ram_gen is
  constant nrRAMs : integer := width/32;
  constant RAMselect_aw : integer := log2(nrRAMs);
  constant RAMdepth_aw : integer := log2(depth);
  constant total_aw : integer := RAMdepth_aw+RAMselect_aw;
  
  -- total RAM structure signals
  signal weA_RAM : std_logic_vector(nrRAMs-1 downto 0);
  type wordsplit is array (nrRAMs-1 downto 0) of std_logic_vector(31 downto 0);
  signal doutA_RAM : wordsplit;
  --- PORT A : 32-bit write | (width)-bit read
  signal dinA    : std_logic_vector(31 downto 0);
  signal doutA   : std_logic_vector(31 downto 0);
  signal weA     : std_logic;
  signal addrA   : std_logic_vector(RAMselect_aw-1 downto 0);
  signal op_selA : std_logic_vector(RAMdepth_aw-1 downto 0);
  --- PORT B : 32-bit read  | (width)-bit write
  signal dinB    : std_logic_vector(width-1 downto 0);
  signal doutB   : std_logic_vector(width-1 downto 0);
  signal weB     : std_logic;
  signal addrB   : std_logic_vector(RAMselect_aw-1 downto 0);
  signal op_selB : std_logic_vector(RAMdepth_aw-1 downto 0);
  
  signal write_operand_i : std_logic;
  signal op_selB_i : std_logic_vector(RAMdepth_aw-1 downto 0);
begin

	-- WARNING: Very Important!
  -- wea & web signals must never be high at the same time !!
  -- web has priority 
  write_operand_i <= write_operand and not write_result; -- portB has write priority
  collision <= write_operand and write_result;
  
  -- the dual port ram has a depth of 4 (each layer contains an operand)
  -- result is always stored in position 3
  -- doutb is always result
  with write_result select
    op_selB_i <= result_dest_op when '1',
                 operand_out_sel when others;
  
  -- map signals to RAM
  -- PORTA
  weA <= write_operand_i; 
  op_selA <= operand_in_sel;
  addrA <= operand_addr;
  dinA <= operand_in;
  result_out <= doutA;
  -- PORT B
  weB <= write_result;
  op_selB <= op_selB_i; -- portB locked to result operand
  addrB <= operand_addr;
  dinB <= result_in;
  operand_out <= doutB;
  
	-- generate (width/32) blocks of 32-bit ram with a given depth
  -- these rams are tyed together to form the following structure
  --  True dual port ram:
  --  - PORT A : 32-bit write | 32-bit read
  --  - PORT B : (width)-bit read  | (width)-bit write
  --                ^             ^
  -- addres       addr          op_sel
  -- 
  ramblocks : for i in 0 to nrRAMs-1 generate
    ramblock: tdpram_generic
    generic map(
      depth => depth
    )
    port map(
      -- port A : 32-bit
      clkA  => bus_clk,
      addrA => op_selA,
      weA   => weA_RAM(i),
      dinA  => dinA,
      doutA => doutA_RAM(i),
      -- port B : 32-bit
      clkB  => core_clk,
      addrB => op_selB,
      weB   => weB,
      dinB  => dinB(((i+1)*32)-1 downto i*32),
      doutB => doutB(((i+1)*32)-1 downto i*32)
    );
    --    demultiplexer for write enable A signal
    process (addrA, weA)
    begin
      if addrA(RAMselect_aw-1 downto 0) = conv_std_logic_vector(i,RAMselect_aw) then
        weA_RAM(i) <= weA;
      else
        weA_RAM(i) <= '0';
      end if;
    end process;
  end generate;
  -- PORTB 32-bit read
  doutA <= doutA_RAM(conv_integer(addrA)) when (conv_integer(addrA)<nrRAMs)
          else (others=>'0');
  
end Behavioral;
