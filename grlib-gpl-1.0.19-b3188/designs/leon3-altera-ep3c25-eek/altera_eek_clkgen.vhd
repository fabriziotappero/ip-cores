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
-- pragma translate_off
library altera_mf;
use altera_mf.altpll;
library grlib;
use grlib.stdlib.all;
-- pragma translate_on
library techmap;
use techmap.gencomp.all;

entity altera_eek_clkgen is
 generic (
   clk0_mul  : integer := 1; 
   clk0_div  : integer := 1;
   clk1_mul  : integer := 1;
   clk1_div  : integer := 1;
   clk_freq : integer := 25000);
  port (
    inclk0 : in  std_ulogic;
    clk0   : out std_ulogic;
    clk0x3 : out std_ulogic;
    clksel : in  std_logic_vector(1 downto 0);
    locked : out std_ulogic);
end; 

architecture rtl of altera_eek_clkgen is

  component altpll
  generic (   
    intended_device_family : string := "CycloneIII" ;
    operation_mode         : string := "NORMAL" ;
    compensate_clock       : string := "clock0";
    inclk0_input_frequency : positive;
    width_clock            : positive := 6;
    clk0_multiply_by       : positive := 1;
    clk0_divide_by         : positive := 1;
    clk1_multiply_by       : positive := 1;
    clk1_divide_by         : positive := 1;    
    clk2_multiply_by       : positive := 1;
    clk2_divide_by         : positive := 1;
    clk3_multiply_by       : positive := 1;
    clk3_divide_by         : positive := 1
  );
  port (
    inclk       : in std_logic_vector(1 downto 0);
    clkena      : in std_logic_vector(5 downto 0);
    clk         : out std_logic_vector(width_clock-1 downto 0);
    locked      : out std_logic
  );
  end component;

  signal clkena	: std_logic_vector (5 downto 0);
  signal clkout	: std_logic_vector (4 downto 0);
  signal inclk	: std_logic_vector (1 downto 0);

  constant clk_period : integer := 1000000000/clk_freq;
  constant CLK0_MUL3X : integer := clk0_mul * 3;
  constant CLK1_MUL3X : integer := clk1_mul * 3;

  constant VERSION : integer := 1;

  attribute syn_keep : boolean;
  attribute syn_keep of clkout : signal is true;
    
begin

  clkena(5 downto 4) <= (others => '0');
  clkena(0) <= '1';
  clkena(1) <= '1'; 
  clkena(2) <= '1';
  clkena(3) <= '1';
  
  inclk <= '0' & inclk0;

  clk_select: process (clkout, clksel)
  begin  -- process clk_select
    case clksel is
      when "00" => clk0 <= clkout(0); clk0x3 <= clkout(1);
      when "01" => clk0 <= clkout(2); clk0x3 <= clkout(3);
      when others => clk0 <= '0'; clk0x3 <= '0';
    end case;
  end process clk_select;
 
  altpll0 : altpll
    generic map ( 
      intended_device_family => "Cyclone III",
      operation_mode => "NO_COMPENSATION", inclk0_input_frequency => clk_period, 
      width_clock => 5, compensate_clock => "CLK1",
      clk0_multiply_by => clk0_mul, clk0_divide_by => clk0_div,
      clk1_multiply_by => CLK0_MUL3X, clk1_divide_by => clk0_div,
      clk2_multiply_by => clk1_mul, clk2_divide_by => clk1_div,
      clk3_multiply_by => CLK1_MUL3X, clk3_divide_by => clk1_div)
    port map (clkena => clkena, inclk => inclk, 
              clk => clkout, locked => locked);
 
-- pragma translate_off
  bootmsg : report_version 
  generic map (
    "clkgen_cycloneiii" & ": altpll lcd/vga clock generator, version " & tost(VERSION)
    );
-- pragma translate_on


end;


