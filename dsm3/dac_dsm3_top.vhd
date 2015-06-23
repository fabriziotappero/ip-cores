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
-- Description: Top entity - contains DAC and output circuit
--              generating the 3-bit sequences
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

entity dac_dsm3_top is
    generic (
      nbits : integer);  
  port (
    din   : in  signed(15 downto 0);
    dout  : out std_logic;
    clk   : in  std_logic;
    n_rst : in  std_logic);

end dac_dsm3_top;

architecture beh1 of dac_dsm3_top is

  component dac_dsm3
    generic (
      nbits : integer);
    port (
      din     : in  signed((nbits-1) downto 0);
      dout    : out std_logic;
      clk     : in  std_logic;
      clk_ena : in  std_logic;
      n_rst   : in  std_logic);
  end component;

  signal clk_cnt  : integer range 0 to 2 := 0;
  signal clk_ena  : std_logic            := '0';
  signal dac_dout : std_logic            := '0';
  
begin
  -- The clock cycle counter
  clken1 : process (clk, n_rst)
  begin  -- process
    if n_rst = '0' then                 -- asynchronous reset (active low)
      clk_cnt <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- Update the cycle counter
      if clk_cnt < 2 then
        clk_cnt <= clk_cnt + 1;
      else
        clk_cnt <= 0;
      end if;
      -- Generate the clk_ena only in the first cycle
      if clk_cnt = 2 then
        clk_ena <= '1';
      else
        clk_ena <= '0';
      end if;
      -- Generate the narrow (if dac_dout='0') or wide (if dac_output='1')
      -- output pulse
      if clk_cnt = 0 then
        dout <= '1';  -- always the rising slope after the first
                      -- clock cycle
      elsif (clk_cnt = 1) and (dac_dout = '0') then
        dout <= '0';                    -- short dout pulse when dac_dout = '0'
      elsif clk_cnt = 2 then
        dout <= '0';                    -- always the falling slope after the
                                        -- third cycle
      end if;
    end if;
  end process clken1;

  dac_dsm3_1 : dac_dsm3
    generic map (
      nbits => 16)
    port map (
      din     => din,
      dout    => dout,
      clk     => clk,
      clk_ena => clk_ena,
      n_rst   => n_rst);
end beh1;
