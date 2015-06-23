-------------------------------------------------------------------------------
-- Title      : butterfly and twiddle factor multiplier
-- Project    : 
-------------------------------------------------------------------------------
-- File       : butterfly.vhd
-- Author     : Wojciech Zabolotny  wzab01<at>gmail.com
-- Company    :
-- Licanse    : BSD
-- Created    : 2014-01-19
-- Last update: 2014-02-05
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
use work.icpx.all;
-------------------------------------------------------------------------------


entity butterfly is
  
  port (
    -- Input data
    din0  : in  icpx_number;
    din1  : in  icpx_number;
    -- Twiddle factor
    tf    : in  icpx_number;
    -- Output data: real and imaginary parts
    dout0 : out icpx_number;
    dout1 : out icpx_number
    );

end butterfly;

architecture beh1 of butterfly is

  signal vdr0, vdi0 : signed(ICPX_WIDTH downto 0);
  signal vdr1, vdi1 : signed(ICPX_WIDTH downto 0);

  signal sout1r, sout1i : signed(2*ICPX_WIDTH downto 0);

  
begin  -- beh1

  -- Result may have one bit more, we add 1 for better rounding
  vdr0     <= resize(din0.re, ICPX_WIDTH+1) + resize(din1.re, ICPX_WIDTH+1);
  dout0.re <= resize(vdr0(ICPX_WIDTH downto 1), ICPX_WIDTH);
  vdi0     <= resize(din0.im, ICPX_WIDTH+1) + resize(din1.im, ICPX_WIDTH+1);
  dout0.im <= resize(vdi0(ICPX_WIDTH downto 1), ICPX_WIDTH);

  vdr1 <= resize(din0.re, ICPX_WIDTH+1) - resize(din1.re, ICPX_WIDTH+1);
  vdi1 <= resize(din0.im, ICPX_WIDTH+1) - resize(din1.im, ICPX_WIDTH+1);

  -- Multiple by the twiddle factor

  sout1r <= (vdr1 * tf.re - vdi1 * tf.im);
  sout1i <= (vdr1 * tf.im + vdi1 * tf.re);

  -- Now we drop the lower bits
  dout1.re <= resize(sout1r(2*ICPX_WIDTH-1 downto ICPX_WIDTH-1), ICPX_WIDTH);
  dout1.im <= resize(sout1i(2*ICPX_WIDTH-1 downto ICPX_WIDTH-1), ICPX_WIDTH);

end beh1;
