-------------------------------------------------------------------------------
-- Title      : DAC_DSM2 - sigma-delta DAC converter with double loop
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dac_dsm2.vhd
-- Author     : Wojciech M. Zabolotny ( wzab[at]ise.pw.edu.pl )
-- Company    : 
-- Created    : 2009-04-28
-- Last update: 2009-04-29
-- Platform   : 
-- Standard   : VHDL'93c
-------------------------------------------------------------------------------
-- Description: Implementation with use of variables inside of process
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

entity dac_dsm2v is
  
  generic (
    nbits : integer := 16);

  port (
    din   : in  signed((nbits-1) downto 0);
    dout  : out std_logic;
    clk   : in  std_logic;
    n_rst : in  std_logic);

end dac_dsm2v;

architecture beh1 of dac_dsm2v is

  signal del1, del2, d_q : signed(nbits+2 downto 0) := (others => '0');
  constant c1            : signed(nbits+2 downto 0) := to_signed(1, nbits+3);
  constant c_1           : signed(nbits+2 downto 0) := to_signed(-1, nbits+3);
begin  -- beh1

  process (clk, n_rst)
    variable v1, v2 : signed(nbits+2 downto 0) := (others => '0');
  begin  -- process
    if n_rst = '0' then                 -- asynchronous reset (active low)
      del1 <= (others => '0');
      del2 <= (others => '0');
      dout <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      v1 := din - d_q + del1;
      v2 := v1 - d_q + del2;
      if v2 > 0 then
        d_q  <= shift_left(c1, nbits);
        dout <= '1';
      else
        d_q  <= shift_left(c_1, nbits);
        dout <= '0';
      end if;
      del1 <= v1;
      del2 <= v2;
    end if;
  end process;
  

end beh1;
