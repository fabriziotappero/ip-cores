--*************************************************************************
--*                                                                       *
--* Copyright (C) 2014 William B Hunter - LGPL                            *
--*                                                                       *
--* This source file may be used and distributed without                  *
--* restriction provided that this copyright statement is not             *
--* removed from the file and that any derivative work contains           *
--* the original copyright notice and the associated disclaimer.          *
--*                                                                       *
--* This source file is free software; you can redistribute it            *
--* and/or modify it under the terms of the GNU Lesser General            *
--* Public License as published by the Free Software Foundation;          *
--* either version 2.1 of the License, or (at your option) any            *
--* later version.                                                        *
--*                                                                       *
--* This source is distributed in the hope that it will be                *
--* useful, but WITHout ANY WARRANTY; without even the implied            *
--* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               *
--* PURPOSE.  See the GNU Lesser General Public License for more          *
--* details.                                                              *
--*                                                                       *
--* You should have received a copy of the GNU Lesser General             *
--* Public License along with this source; if not, download it            *
--* from http://www.opencores.org/lgpl.shtml                              *
--*                                                                       *
--*************************************************************************
--
-- Engineer: William B Hunter
-- Create Date: 08/08/2014
-- Project: Manchester Uart
-- File: manchester.vhd - a Manchester encoded UART
-- Description: This is a wrapper for teh encoder and decoder.
--
-- Justification: The use of the Manchester UART has some advantages of a standard UART.
--    1. The Manchester UART can tolerate about 18% difference in timing between the transmitter and reciever.
--        This is very useful if one or both of the systems don't have an accurate clock. RC oscillators can be used
--         instead of crystals. No PLL is required for recovery of the data signal.
--    2. The Manchester UART is better when powering low power (devices off of the serial lines (parasitic power).
--        A typical UART can have a continuous low output for 9 bit times, whereas the Manchester UART has a max
--        low time of 1 bit time.
--  There is also a disadvantage of the Manchester UART. It can have twice the transitions per bit compared to
--       a normal UART.This requires twice the bandwidth in the UART dirvers for a given data rate.
--
-- Operational Description: This is a Manchester encoded UART - It encodes 16 bit data grams using Manchester encoding.
--   This unit is designed for short data bursts rather than stream encoding typical of Manchester systesm.
--    Since this is a burst encoder, it relys on start and stop bits for synchronization instead of sync patterns.
--    The Manchester UART goes to an idle state when no data is being transmitted. The idle state is a logic high.
--    Bits are encoded by a high to low (zero) or low to high(one) transition in the middle of the bit period. Start
--    and stop bits are always ones (low to high transitions). 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Manchester is
  Port (
    clk16x : in STD_LOGIC;
    srst : in STD_LOGIC;
    rxd : in STD_LOGIC;
    rx_data : out STD_LOGIC_VECTOR (15 downto 0);
    rx_stb : out STD_LOGIC;
    rx_idle : out STD_LOGIC;
    fm_err : out STD_LOGIC;
    txd : out STD_LOGIC;
    tx_data : in STD_LOGIC_VECTOR (15 downto 0);
    tx_stb : in STD_LOGIC;
    tx_idle : out STD_LOGIC;
    or_err : out STD_LOGIC
  );
end Manchester;

architecture rtl of Manchester is

begin

  u_decode : entity work.decode(rtl)
  port map(
    clk16x => clk16x,
    srst => srst,
    rxd => rxd,
    rx_data => rx_data,
    rx_stb => rx_stb,
    fm_err => fm_err,
    rx_idle => rx_idle
  );

  u_encode : entity work.encode(rtl)
  port map(
    clk16x => clk16x,
    srst => srst,
    txd => txd,
    tx_data => tx_data,
    tx_stb => tx_stb,
    or_err => or_err,
    tx_idle => tx_idle
  );

end rtl;
