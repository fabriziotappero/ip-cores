------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
-- pragma translate_off
library altera_mf;
use altera_mf.altpll;
-- pragma translate_on

entity altera_pll is
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    clk_freq : integer := 25000;
    clk2xen  : integer := 0;          
    sdramen  : integer := 0
  );
  port (
    inclk0  : in  std_ulogic;
    c0	    : out std_ulogic;
    c0_2x   : out std_ulogic;
    e0	    : out std_ulogic; 
    locked  : out std_ulogic
);
end;

architecture rtl of altera_pll is

  component altpll
  generic (   
    operation_mode         : string := "NORMAL" ;
    inclk0_input_frequency : positive;
    width_clock            : positive := 6;
    clk0_multiply_by       : positive := 1;
    clk0_divide_by         : positive := 1;
    clk1_multiply_by       : positive := 1;
    clk1_divide_by         : positive := 1;    
    extclk0_multiply_by    : positive := 1;
    extclk0_divide_by      : positive := 1
  );
  port (
    inclk       : in std_logic_vector(1 downto 0);
    clkena      : in std_logic_vector(5 downto 0);
    extclkena   : in std_logic_vector(3 downto 0);
    clk         : out std_logic_vector(width_clock-1 downto 0);
    extclk      : out std_logic_vector(3 downto 0);
    locked      : out std_logic
  );
  end component;

  signal clkena	: std_logic_vector (5 downto 0);
  signal clkout	: std_logic_vector (5 downto 0);
  signal inclk	: std_logic_vector (1 downto 0);
  signal extclk : std_logic_vector (3 downto 0);

  constant clk_period : integer := 1000000000/clk_freq;
  constant CLK_MUL2X : integer := clk_mul * 2;
begin

  clkena(5 downto 2) <= (others => '0');
  noclk2xgen: if (clk2xen = 0) generate clkena(1 downto 0) <= "01"; end generate;
  clk2xgen: if (clk2xen /= 0) generate clkena(1 downto 0) <= "11"; end generate;
  
  inclk <= '0' & inclk0;
  c0 <= clkout(0); c0_2x <= clkout(1); e0 <= extclk(0);   

  sden : if sdramen = 1 generate
    altpll0 : altpll
    generic map ( 
      operation_mode => "ZERO_DELAY_BUFFER", inclk0_input_frequency => clk_period, 
      extclk0_multiply_by => clk_mul, extclk0_divide_by => clk_div,
      clk0_multiply_by => clk_mul, clk0_divide_by => clk_div,
      clk1_multiply_by => CLK_MUL2X, clk1_divide_by => clk_div)
    port map ( clkena => clkena, inclk => inclk, extclkena => clkena(3 downto 0),
      clk => clkout, locked => locked, extclk => extclk);
  end generate;

  nosd : if sdramen = 0 generate
    altpll0 : altpll
    generic map ( 
      operation_mode => "NORMAL", inclk0_input_frequency => clk_period, 
      extclk0_multiply_by => clk_mul, extclk0_divide_by => clk_div,
      clk0_multiply_by => clk_mul, clk0_divide_by => clk_div,
      clk1_multiply_by => CLK_MUL2X, clk1_divide_by => clk_div)
    port map ( clkena => clkena, inclk => inclk, extclkena => clkena(3 downto 0),
      clk => clkout, locked => locked, extclk => extclk);
  end generate;

end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library altera_mf;
library grlib;
use grlib.stdlib.all;
-- pragma translate_on
library techmap;
use techmap.gencomp.all;

entity clkgen_altera_mf is
 generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    sdinvclk : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000;
    clk2xen  : integer := 0);      
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- double clock    
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
end; 

architecture rtl of clkgen_altera_mf is

  constant VERSION : integer := 1;
  constant CLKIN_PERIOD : integer := 20;

  signal   clk_i             : std_logic;
  signal   clkint, pciclkint : std_logic;
  signal   pllclk, pllclkn   : std_logic;  -- generated clocks
  signal   s_clk             : std_logic;
  
  -- altera pll
  component altera_pll
    generic (
      clk_mul  : integer := 1; 
      clk_div  : integer := 1;
      clk_freq : integer := 25000;
      clk2xen  : integer := 0;            
      sdramen  : integer := 0
    );
    port (
      inclk0 : in  std_ulogic;
      e0     : out std_ulogic;
      c0     : out std_ulogic;
      c0_2x  : out std_ulogic;
      locked : out std_ulogic);
  end component;
  
  
begin

  cgo.pcilock <= '1';

--   c0 : if (PCISYSCLK = 0) generate
--     Clkint <= Clkin;
--   end generate;

--   c1 : if (PCISYSCLK = 1) generate
--     Clkint <= pciclkin;
--   end generate;

--   c2 : if (PCIEN = 1) generate
--     p0 : if (PCIDLL = 1) generate
--       pciclkint <= pciclkin;
--       pciclk    <= pciclkint;
--     end generate;
--     p1 : if (PCIDLL = 0) generate
--       u0 : if (PCISYSCLK = 0) generate
--         pciclkint <= pciclkin;
--       end generate;
--       pciclk <= clk_i when (PCISYSCLK = 1) else pciclkint;
--     end generate;
--   end generate;

--   c3 : if (PCIEN = 0) generate
--     pciclk <= Clkint;
--   end generate;


  c0: if (PCISYSCLK = 0) or (PCIEN = 0) generate
    clkint <= clkin;
  end generate c0;

  c1: if PCIEN /= 0 generate
    d0: if PCISYSCLK = 1 generate
      clkint <= pciclkin;
    end generate d0;
    pciclk <= pciclkin;
  end generate c1;

  c2: if PCIEN = 0 generate
    pciclk <= '0';
  end generate c2;
  
  sdclk_pll : altera_pll 
  generic map (clk_mul, clk_div, freq, clk2xen, sdramen)
  port map ( inclk0 => clkint, e0 => sdclk, c0 => s_clk, c0_2x => clk2x,
	locked => cgo.clklock);
  clk <= s_clk;
  clkn <= not s_clk;
 
-- pragma translate_off
  bootmsg : report_version 
  generic map (
    "clkgen_altera" & ": altpll sdram/pci clock generator, version " & tost(VERSION),
    "clkgen_altera" & ": Frequency " &  tost(freq) & " KHz, PLL scaler " & tost(clk_mul) & "/" & tost(clk_div));
-- pragma translate_on


end;


