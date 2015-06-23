----------------------------------------------------------------------  
----  operand_ram_asym                                            ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    BRAM memory and logic to store the operands, due to the   ----
----    achitecture, a minimum depth of 2 is needed for this      ----
----    module to be inferred into blockram, this version is      ----
----    slightly more performant than operand_ram_gen and uses    ----
----    less resources. but does not work on every fpga, only     ----
----    the ones that support asymmetric rams.                    ----           
----                                                              ---- 
----  Dependencies:                                               ----
----    - tdpramblock_asym                                        ----
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

-- structural description of a RAM to hold the operands, with 
-- adjustable width (64, 128, 256, 512, 576, 640,..) and depth(nr of operands)
--    formula for available widths: (i*512+(0 or 64 or 128 or 256)) (i=integer number) 
--
entity operand_ram_asym is
  generic(
    width  : integer := 1536; -- width of the operands
    depth  : integer := 4;    -- nr of operands
    device : string  := "xilinx"
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
end operand_ram_asym;

architecture Behavioral of operand_ram_asym is
  -- contstants
  constant RAMblock_maxwidth   : integer := 512;
  constant nrRAMblocks_full    : integer := width/RAMblock_maxwidth;
  constant RAMblock_part       : integer := width rem RAMblock_maxwidth;
  constant RAMblock_part_width : integer := width-(nrRAMblocks_full*RAMblock_maxwidth);
  constant RAMselect_aw        : integer := log2(width/32)-log2(nrRAMblocks_full/32);
  
  -- internal signals
  signal mult_op_sel     : std_logic_vector(log2(depth)-1 downto 0);
  signal write_operand_i : std_logic;
begin
  -- WARNING: Very Important!
  -- wea & web signals must never be high at the same time !!
  -- web has priority 
  write_operand_i <= write_operand and not write_result; -- portB has write priority
  collision <= write_operand and write_result;

  -- when multiplier is writing back result, select the result address
  with write_result select
  mult_op_sel <= result_dest_op when '1',
                 operand_out_sel when others;
  
  -- generate (width/512) ramblocks with a given depth
  -- these rams are tyed together to form the following structure
  --  True dual port ram:
  --  - PORT A : 32-bit write      | 32-bit read
  --  - PORT B : (width)-bit write | (width)-bit read
  -- 
  single_block : if (width <= RAMblock_maxwidth) generate
    -- signals for single block
    signal addrA_single : std_logic_vector(log2(width*depth/32)-1 downto 0);
  begin
    addrA_single <= operand_in_sel & operand_addr;
    ramblock : tdpramblock_asym
    generic map(
      depth  => depth,
      width  => width,
      device => device
    )
    port map(
      -- port A 32-bit
      clkA  => bus_clk,
      addrA => addrA_single,
      weA   => write_operand_i,
      dinA  => operand_in,
      doutA => result_out,
      -- port B (width)-bit
      clkB  => core_clk,
      addrB => mult_op_sel,
      weB   => write_result,
      dinB  => result_in,
      doutB => operand_out
    );
  end generate;
  
  multiple_full_blocks : if (width > RAMblock_maxwidth) generate
    -- signals for multiple blocks
    type wordsplit is array (nrRAMblocks_full downto 0) of std_logic_vector(31 downto 0);
    signal doutA_RAM  : wordsplit;
    signal addrA      : std_logic_vector(log2(RAMblock_maxwidth*depth/32)-1 downto 0);
    signal weA_RAM    : std_logic_vector(nrRAMblocks_full-1 downto 0);
  begin
    ramblocks_full : for i in 0 to nrRAMblocks_full generate
      -- port A signals
      addrA <= operand_in_sel & operand_addr(log2(RAMblock_maxwidth/32)-1 downto 0);
      
      full_ones : if (i < nrRAMblocks_full) generate
        ramblock_full : tdpramblock_asym
        generic map(
          depth  => depth,
          width  => RAMblock_maxwidth,
          device => device
        )
        port map(
          -- port A 32-bit
          clkA  => bus_clk,
          addrA => addrA,
          weA   => weA_RAM(i),
          dinA  => operand_in,
          doutA => doutA_RAM(i),
          -- port B (width)-bit
          clkB  => core_clk,
          addrB => mult_op_sel,
          weB   => write_result,
          dinB  => result_in((i+1)*RAMblock_maxwidth-1 downto i*RAMblock_maxwidth),
          doutB => operand_out((i+1)*RAMblock_maxwidth-1 downto i*RAMblock_maxwidth)
        );
        -- weA, weB
        process (write_operand_i, operand_addr)
        begin
          if operand_addr(log2(width/32)-1 downto log2(RAMblock_maxwidth/32)) = conv_std_logic_vector(i,RAMselect_aw) then
            weA_RAM(i) <= write_operand_i;
          else
            weA_RAM(i) <= '0';
          end if;
        end process;
        only_once : if (i = 0) generate
          -- port A read mux
          only_full_blocks : if (RAMblock_part = 0) generate
            result_out <= doutA_RAM(conv_integer(operand_addr(log2(width/32)-1 downto log2(RAMblock_maxwidth/32)))) 
                              when (conv_integer(operand_addr(log2(width/32)-1 downto log2(RAMblock_maxwidth/32)))<nrRAMblocks_full)
                          else (others=>'0');
          end generate;
          with_extra_part : if (RAMblock_part /= 0) generate
            result_out <= doutA_RAM(conv_integer(operand_addr(log2(width/32)-1 downto log2(RAMblock_maxwidth/32)))) 
                              when (conv_integer(operand_addr(log2(width/32)-1 downto log2(RAMblock_maxwidth/32)))<nrRAMblocks_full+1)
                          else (others=>'0');
          end generate;
        end generate;
      end generate;
      
      optional_part : if (i = nrRAMblocks_full) and (RAMblock_part /= 0) generate
        -- signals for part
        signal addrA_part : std_logic_vector(log2(RAMblock_part_width*depth/32)-1 downto 0);
        signal weA_part   : std_logic;
      begin
        addrA_part <= operand_in_sel & operand_addr(log2(RAMblock_part_width/32)-1 downto 0);
        ramblock_part : tdpramblock_asym
        generic map(
          depth  => depth,
          width  => RAMblock_part_width,
          device => device
        )
        port map(
          -- port A 32-bit
          clkA  => bus_clk,
          addrA => addrA_part,
          weA   => weA_part,
          dinA  => operand_in,
          doutA => doutA_RAM(i),
          -- port B (width)-bit
          clkB  => core_clk,
          addrB => mult_op_sel,
          weB   => write_result,
          dinB  => result_in(width-1 downto i*RAMblock_maxwidth),
          doutB => operand_out(width-1 downto i*RAMblock_maxwidth)
        );
        -- weA, weB part
        process (write_operand_i, operand_addr)
        begin
          if operand_addr(log2(width/32)-1 downto log2(RAMblock_maxwidth/32)) = conv_std_logic_vector(i,RAMselect_aw) then
            weA_part <= write_operand_i;
          else
            weA_part <= '0';
          end if;
        end process;
      end generate;
    end generate;
  end generate;

end Behavioral;
