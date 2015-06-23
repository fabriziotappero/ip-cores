-------------------------------------------------------------------------------
-- Title      : butterfly and twiddle factor multiplier
-- Project    : 
-------------------------------------------------------------------------------
-- File       : butterfly.vhd
-- Author     : Wojciech Zabolotny  wzab01<at>gmail.com
-- Company    :
-- Licanse    : BSD
-- Created    : 2014-01-19
-- Last update: 2014-05-02
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This block performs the buttefly calculation
--              And multiplies the result by the twiddle factor
--              Input data and output data are in our icpx_number format
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-01-19  1.0      wzab    Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.fft_len.all;
use work.icpx.all;
-------------------------------------------------------------------------------


entity butterfly is
  generic (
    LATENCY : integer := 0);
  port (
    -- Input data
    din0  : in  icpx_number;
    din1  : in  icpx_number;
    -- Twiddle factor
    tf    : in  icpx_number;
    -- Output data: real and imaginary parts
    dout0 : out icpx_number;
    dout1 : out icpx_number;
    -- System interface
    clk   : in  std_logic;
    rst_n : in  std_logic
    );

end butterfly;

architecture beh1 of butterfly is

  signal vdr0, vdr0_d, vdr0_d2, vdi0, vdi0_d, vdi0_d2 : signed(ICPX_WIDTH downto 0);
  signal vdr1, vdi1                                   : signed(ICPX_WIDTH downto 0);

  signal sout1r, sout1i     : signed(2*ICPX_WIDTH downto 0);
  signal sout1r_a, sout1i_a : signed(2*ICPX_WIDTH downto 0);
  signal sout1r_b, sout1i_b : signed(2*ICPX_WIDTH downto 0);
  signal stf, stf_d0        : icpx_number;
  type T_DELIN is array (1 to LATENCY) of ICPX_NUMBER;
  signal vin0, vin1, vtf    : T_DELIN := (others => icpx_zero);
  
begin  -- beh1
  -- If requested, we introduce latency on the input
  -- The register balancing function will distribute it
  p1 : process (clk, rst_n)
  begin  -- process p1
    if rst_n = '0' then                 -- asynchronous reset (active low)
      vin0  <= (others => icpx_zero);
      vin1  <= (others => icpx_zero);
      vtf   <= (others => icpx_zero);
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- delayed by 1 clock
      vdr1     <= resize(din0.re, ICPX_WIDTH+1) - resize(din1.re, ICPX_WIDTH+1);
      vdi1     <= resize(din0.im, ICPX_WIDTH+1) - resize(din1.im, ICPX_WIDTH+1);
      vdr0     <= resize(din0.re, ICPX_WIDTH+1) + resize(din1.re, ICPX_WIDTH+1);
      vdi0     <= resize(din0.im, ICPX_WIDTH+1) + resize(din1.im, ICPX_WIDTH+1);
      stf_d0   <= tf;
      -- delayed by 2 clocks
      vdr0_d   <= vdr0;
      vdi0_d   <= vdi0;
      sout1r_a <= vdr1 * stf_d0.re;
      sout1r_b <= vdi1 * stf_d0.im;
      sout1i_a <= vdr1 * stf_d0.im;
      sout1i_b <= vdi1 * stf_d0.re;
      -- delayed by 3 clocks
      vdr0_d2  <= vdr0_d;
      vdi0_d2  <= vdi0_d;
      sout1r   <= sout1r_a - sout1r_b;
      sout1i   <= sout1i_a + sout1i_b;
    end if;
  end process p1;
  dout1.re <= resize(sout1r(2*ICPX_WIDTH-1 downto ICPX_WIDTH-1), ICPX_WIDTH);
  dout1.im <= resize(sout1i(2*ICPX_WIDTH-1 downto ICPX_WIDTH-1), ICPX_WIDTH);
  dout0.re <= resize(vdr0_d2(ICPX_WIDTH downto 1), ICPX_WIDTH);
  dout0.im <= resize(vdi0_d2(ICPX_WIDTH downto 1), ICPX_WIDTH);

  -- Result may have one bit more, we add 1 for better rounding


  -- Multiple by the twiddle factor


-- Now we drop the lower bits
-- first step - leave one more bit for rounding
end beh1;
