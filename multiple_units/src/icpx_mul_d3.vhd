-------------------------------------------------------------------------------
-- Title      : Multiplier used to multiply the input sample by the value of
--              a window function
-- Project    : 
-------------------------------------------------------------------------------
-- File       : icpx_mul.vhd
-- Author     : Wojciech Zabolotny
-- Company    : 
-- License    : BSD
-- Created    : 2014-01-19
-- Last update: 2014-05-02
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Multiplier with latency of 3 clk
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
use ieee.math_complex.all;
library work;
use work.fft_len.all;
use work.icpx.all;
-------------------------------------------------------------------------------


entity icpx_mul is
  generic (
    MULT_LATENCY : integer := 1);
  port (
    -- Input data
    din0  : in  icpx_number;
    din1  : in  icpx_number;
    -- Output data: real and imaginary parts
    dout : out icpx_number;
    -- clock
    rst_n : in std_logic;
    clk : in std_logic
    );

end icpx_mul;

architecture beh1 of icpx_mul is
  signal sout1r, sout1r_a, sout1r_b, sout1i, sout1i_a, sout1i_b : signed(2*ICPX_WIDTH-1 downto 0);
  signal s_din0, s_din1, s_out : icpx_number;
begin  -- beh1

  -- Multiple the values


  -- Now we drop the lower bits
  -- Delay the result to allow more efficient, pipelined implementation
  -- (Register balancing in the synthesis tools should do the rest...)
  process (clk, rst_n) is
  begin  -- process
    if rst_n = '0' then
      sout1r <= (others => '0');
      sout1r_a <= (others => '0');
      sout1r_b <= (others => '0');
      sout1i <= (others => '0');
      sout1i_a <= (others => '0');
      sout1i_b <= (others => '0');
      s_din0 <= icpx_zero;
      s_din1 <= icpx_zero;
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- delayed by 1 clk
      s_din0 <= din0;
      s_din1 <= din1;
      -- delayed by 2 clk
      sout1r_a <= s_din0.re * s_din1.re;
      sout1r_b <= s_din0.im * s_din1.im;
      sout1i_a <= s_din0.re * s_din1.im;
      sout1i_b <= s_din0.im * s_din1.re;
      -- delayed by 3 clk
      sout1r <= (sout1r_a - sout1r_b);
      sout1i <= (sout1i_a + sout1i_b);
    end if;
  end process;
  s_out.re <= resize(sout1r(2*ICPX_WIDTH-2 downto ICPX_WIDTH-2),ICPX_WIDTH);
  s_out.im <= resize(sout1i(2*ICPX_WIDTH-2 downto ICPX_WIDTH-2),ICPX_WIDTH);
  dout <= s_out;
end beh1;

