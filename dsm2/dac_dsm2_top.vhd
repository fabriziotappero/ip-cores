-------------------------------------------------------------------------------
-- Title      : DAC_DSM2 - sigma-delta DAC converter with double loop
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dac_dsm2.vhd
-- Author     : Wojciech M. Zabolotny ( wzab[at]ise.pw.edu.pl )
-- Company    : 
-- Created    : 2009-04-28
-- Last update: 2012-10-16
-- Platform   : 
-- Standard   : VHDL'93c
-------------------------------------------------------------------------------
-- Description: Top entity
-------------------------------------------------------------------------------
-- Copyright (c) 2009  - THIS IS PUBLIC DOMAIN CODE!!!
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009-04-28  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac_dsm2_top is
    generic (
      nbits : integer);  
  port (
    din   : in  signed(15 downto 0);
    dout  : out std_logic;
    clk   : in  std_logic;
    n_rst : in  std_logic);

end dac_dsm2_top;

architecture beh1 of dac_dsm2_top is

  component dac_dsm2
    generic (
      nbits : integer);
    port (
      din   : in  signed((nbits-1) downto 0);
      dout  : out std_logic;
      clk   : in  std_logic;
      n_rst : in  std_logic);
  end component;

begin
  dac_dsm2_1 : dac_dsm2
    generic map (
      nbits => nbits)
    port map (
      din   => din,
      dout  => dout,
      clk   => clk,
      n_rst => n_rst);
end beh1;
