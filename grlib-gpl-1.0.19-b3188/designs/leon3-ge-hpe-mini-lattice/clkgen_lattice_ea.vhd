----------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2004 GAISLER RESEARCH
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
-----------------------------------------------------------------------------
-- Entity:  clkgen_lattice
-- File: clkgen_lattice.vhd
-- Author: Nils-Johan Wessman - Gaisler Research  
-- Description:   Clock generators for Lattice fpgas
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library grlib;
use grlib.stdlib.all;
--library unisim;
-- pragma translate_on
library techmap;
use techmap.gencomp.all;

library ec;
use ec.components.all;

------------------------------------------------------------------
-- LEC clock generator ---------------------------------------
------------------------------------------------------------------

entity clkgen_lattice is
   generic (
      clk_mul  : string := "2"; 
      clk_div  : string := "1";
      freq     : string := "25"; -- clock frequency in MHz
      ddrclk_mul  : string := "4"; 
      ddrclk_div  : string := "1");
   port (
      clkin    : in  std_logic;
      clk0     : out std_logic;        -- main clock
      clk180   : out std_logic;       -- main clock phase 180
      clk270   : out std_logic;       -- main clock phase 270

      ddrclk   : out std_logic;
      ddrclkb  : out std_logic;
      
      clkm     : out std_logic;
      
      cgi      : in clkgen_in_type;
      cgo      : out clkgen_out_type);
end; 

architecture struct of clkgen_lattice is 
constant VERSION : integer := 1;
signal clkin200, clkin_fb, clk0_fb, clkm_fb, clk180_fb, clk_270 : std_logic;
signal pllinlock, pll0lock, pll1lock, pll2lock : std_logic;
signal pllinrst, pllrst : std_logic_vector(0 to 5);

attribute FB_MODE : string;
attribute FB_MODE of pllm : label is "INTERNAL"; -- INTERNAL CLOCKTREE
attribute FB_MODE of pllddr1 : label is "INTERNAL";
attribute FB_MODE of pllddr2 : label is "INTERNAL";

begin
pllm : EHXPLLB
   generic map(
      FIN => freq, CLKI_DIV => clk_div, CLKOP_DIV => "16", 
      CLKFB_DIV => clk_mul, FDEL => "0", CLKOK_DIV => "2",
      WAKE_ON_LOCK => "off", DELAY_CNTL => "STATIC", PHASEADJ => "0", DUTY => "4")
   port map(
      CLKI => clkin, CLKFB => clkm_fb, RST => pllrst(0),
      CLKOP => clkm_fb, CLKOS => clkm, CLKOK => open, LOCK => pll0lock,
      
      -- Static
      DDAMODE  => '0', DDAIZR => '0', DDAILAG   => '0', DDAIDEL0  => '0', DDAIDEL1  => '0', DDAIDEL2  => '0',
      DDAOZR   => open, DDAOLAG  => open, DDAODEL0 => open, DDAODEL1 => open, DDAODEL2 => open
   );

pllddr1 : EHXPLLB
   generic map(
      FIN => freq, CLKI_DIV => ddrclk_div, CLKOP_DIV => "8",
      CLKFB_DIV => ddrclk_mul, FDEL => "0", CLKOK_DIV => "2",
      WAKE_ON_LOCK => "off", DELAY_CNTL => "STATIC", PHASEADJ => "180", DUTY => "4")
   port map(
      CLKI => clkin, CLKFB => clk180_fb, RST => pllrst(0),
      CLKOP => clk180_fb, CLKOS => clk180, CLKOK => open, LOCK => pll1lock,
      
      -- Static
      DDAMODE  => '0', DDAIZR => '0', DDAILAG   => '0', DDAIDEL0  => '0', DDAIDEL1  => '0', DDAIDEL2  => '0',
      DDAOZR   => open, DDAOLAG  => open, DDAODEL0 => open, DDAODEL1 => open, DDAODEL2 => open
   );

pllddr2 : EHXPLLB
   generic map(
      FIN => freq, CLKI_DIV => ddrclk_div, CLKOP_DIV => "8", 
      CLKFB_DIV => ddrclk_mul, FDEL => "0", CLKOK_DIV => "2",
      WAKE_ON_LOCK => "off", DELAY_CNTL => "STATIC", PHASEADJ => "270", DUTY => "4")
   port map(
      CLKI => clkin, CLKFB => clk0_fb, RST => pllrst(0),
      CLKOP => clk0_fb, CLKOS => clk_270, CLKOK => open, LOCK => pll2lock,
      
      -- Static
      DDAMODE  => '0', DDAIZR => '0', DDAILAG   => '0', DDAIDEL0  => '0', DDAIDEL1  => '0', DDAIDEL2  => '0',
      DDAOZR   => open, DDAOLAG  => open, DDAODEL0 => open, DDAODEL1 => open, DDAODEL2 => open
   );

-- ddrclk_reg : ODDRXB 
-- port map(DA => '1', DB => '0', CLK => clk_270, LSR => '0', Q => ddrclk);
-- ddrclkb_reg : ODDRXB 
-- port map(DA => '0', DB => '1', CLK => clk_270, LSR => '0', Q => ddrclkb);
   -- invert DDR memory clock
   ddrclk_reg : ODDRXB 
   port map(DA => '0', DB => '1', CLK => clk_270, LSR => '0', Q => ddrclk);
   ddrclkb_reg : ODDRXB 
   port map(DA => '1', DB => '0', CLK => clk_270, LSR => '0', Q => ddrclkb);


   clk0 <= clk0_fb;
   clk270 <= clk_270;
-- pllinrst <= cgi.pllrst;

   rstdel : process (clkin, cgi.pllrst)
   begin
      if cgi.pllrst = '1' then pllrst <= (others => '1');
      elsif rising_edge(clkin) then
         pllrst <= pllrst(1 to 5) & '0';
      end if;
   end process;
   
   cgo.clklock <= pll0lock and pll1lock and pll2lock;
   
  -- cgo.pcilock <= dll2lock;

-- pragma translate_off
  bootmsg : report_version 
  generic map (
    "clkgen_lattice" & ": lattice  clock generator, version " & tost(VERSION),
    "clkgen_lattice" & ": Frequency " &  freq & " MHz, PLL divisor " & clk_mul & "/" & clk_div & ddrclk_mul & "/" & ddrclk_div);
-- pragma translate_on

end;

