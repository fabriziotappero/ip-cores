----------------------------------------------------------------------  
----  modulus_ram_asym                                            ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    BRAM memory and logic to store the modulus, due to the    ----
----    achitecture, a minimum depth of 2 is needed for this      ----
----    module to be inferred into blockram, this version is      ----
----    slightly more performant than modulus_ram_gen and uses    ----
----    less resources. but does not work on every fpga, only     ----
----    the ones that support asymmetric rams.                    ----
----                                                              ---- 
----  Dependencies:                                               ----
----    - dpramblock_asym                                         ----
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
use mod_sim_exp.std_functions.all;
use mod_sim_exp.mod_sim_exp_pkg.all;

-- structural description of a RAM to hold the modulus, with 
-- adjustable width (64, 128, 256, 512, 576, 640,..) and depth(nr of moduluses)
--    formula for available widths: (i*512+(0 or 64 or 128 or 256)) (i=integer number) 
--
entity modulus_ram_asym is
  generic(
    width : integer := 1536;  -- must be a multiple of 32
    depth : integer := 2;     -- nr of moduluses
    device : string := "altera"
  );
  port(
      -- bus side
    bus_clk        : in std_logic;
    write_modulus  : in std_logic; -- write enable
    modulus_in_sel : in std_logic_vector(log2(depth)-1 downto 0); -- modulus operand to write to
    modulus_addr   : in std_logic_vector(log2((width)/32)-1 downto 0); -- modulus word(32-bit) address
    modulus_in     : in std_logic_vector(31 downto 0); -- modulus word data in
    modulus_sel    : in std_logic_vector(log2(depth)-1 downto 0); -- selects the modulus to use for multiplications
      -- multiplier side
    core_clk       : in std_logic;
    modulus_out    : out std_logic_vector(width-1 downto 0)
  );
end modulus_ram_asym;

architecture structural of modulus_ram_asym is
  -- constants
  constant RAMblock_maxwidth   : integer := 512;
  constant nrRAMblocks_full    : integer := width/RAMblock_maxwidth;
  constant RAMblock_part       : integer := width rem RAMblock_maxwidth;
  constant RAMblock_part_width : integer := width-(nrRAMblocks_full*RAMblock_maxwidth);
  constant RAMselect_aw        : integer := log2(width/32)-log2(nrRAMblocks_full/32);

begin
               
  -- generate (width/512) ramblocks with a given depth
  -- these rams are tyed together to form the following structure
  --  dual port ram:
  --  - PORT A : 32-bit write
  --  - PORT B : (width)-bit read
  -- 
  single_block : if (width <= RAMblock_maxwidth) generate
    signal waddr : std_logic_vector(log2((width*depth)/32)-1 downto 0);
  begin
    waddr <= modulus_in_sel & modulus_addr;
  
    ramblock: dpramblock_asym
    generic map(
      width => width,
      depth => depth,
      device  => device
    )
    port map(
      -- write port
      clkA   => bus_clk,
      waddrA => waddr,
      weA    => write_modulus,
      dinA   => modulus_in,
      -- read port
      clkB   => core_clk,
      raddrB => modulus_sel,
      doutB  => modulus_out
    );
  end generate;
  
  multiple_full_blocks : if (width > RAMblock_maxwidth) generate
    -- signals for multiple blocks
    signal waddr  : std_logic_vector(log2(RAMblock_maxwidth*depth/32)-1 downto 0);
    signal we_RAM : std_logic_vector(nrRAMblocks_full-1 downto 0);
  begin
    ramblocks_full : for i in 0 to nrRAMblocks_full generate
      -- write port signal
      waddr <= modulus_in_sel & modulus_addr(log2(RAMblock_maxwidth/32)-1 downto 0);
      
      full_ones : if (i < nrRAMblocks_full) generate
        ramblock_full : dpramblock_asym
        generic map(
          width  => RAMblock_maxwidth,
          depth  => depth,
          device => device
        )
        port map(
          -- write port
          clkA   => bus_clk,
          waddrA => waddr,
          weA    => we_RAM(i),
          dinA   => modulus_in,
          -- read port
          clkB   => core_clk,
          raddrB => modulus_sel,
          doutB  => modulus_out((i+1)*RAMblock_maxwidth-1 downto i*RAMblock_maxwidth)
        );
        -- we
        process (write_modulus, modulus_addr)
        begin
          if modulus_addr(log2(width/32)-1 downto log2(RAMblock_maxwidth/32)) = conv_std_logic_vector(i,RAMselect_aw) then
            we_RAM(i) <= write_modulus;
          else
            we_RAM(i) <= '0';
          end if;
        end process;
      end generate; -- end of if generate for full blocks
      
      optional_part : if (i = nrRAMblocks_full) and (RAMblock_part /= 0) generate
        -- signals for optional part
        signal waddr_part : std_logic_vector(log2(RAMblock_part_width*depth/32)-1 downto 0);
        signal we_part    : std_logic;
      begin
        -- write port signal
        waddr_part <= modulus_in_sel & modulus_addr(log2(RAMblock_part_width/32)-1 downto 0);
        ramblock_part : dpramblock_asym
        generic map(
          width  => RAMblock_part_width,
          depth  => depth,
          device => device
        )
        port map(
          -- write port
          clkA   => bus_clk,
          waddrA => waddr_part,
          weA    => we_part,
          dinA   => modulus_in,
          -- read port
          clkB   => core_clk,
          raddrB => modulus_sel,
          doutB  => modulus_out(width-1 downto i*RAMblock_maxwidth)
        );
        
        -- we_part
        process (write_modulus, modulus_addr)
        begin
          if modulus_addr(log2(width/32)-1 downto log2(RAMblock_maxwidth/32)) = conv_std_logic_vector(i,RAMselect_aw) then
            we_part <= write_modulus;
          else
            we_part <= '0';
          end if;
        end process;
      end generate;-- end of if generate for part block
    end generate;-- end of for generate
  end generate;-- end of if generate for multiple blocks

end structural;
