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
-- File: Manchester_tb.vhd
-- Description: This is a testbench for the Manchester UART. It consists of two instances of
--   the UART, both run on independant clocks. The clocks start off at the same frequency (
--    16x 9600 baud), and one is slowly decreaased to check the robustness of the uart to
--    differences in clock frequencies. Currently it fails when the clocks are about 18% different.
--  The test bench consists of the two UARTs, each has a feeder process and a capture process.
--     The feeder sends data to the transmitters, and the capture process is simply to make viewing
--     the output more convenient. 

----------------------------------------------------------------------------------


entity manchester_tb is

end manchester_tb;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

architecture Behavioral of manchester_tb is
  signal sdat_1to2 : std_logic := '1';
  signal sdat_2to1 : std_logic := '1';
  signal clk1 : std_logic := '1';
  signal clk2 : std_logic := '1';
  signal xrst : std_logic := '1';
  signal txerr1 : std_logic := '0';
  signal txidle1 : std_logic := '0';
  signal rxerr1 : std_logic := '0';
  signal rxidle1 : std_logic := '0';
  signal txdata1 : std_logic_vector(15 downto 0) := x"0000";
  signal txstb1 : std_logic := '0';
  signal rxdata1 : std_logic_vector(15 downto 0) := x"0000";
  signal rxstb1 : std_logic := '0';
  signal txerr2 : std_logic := '0';
  signal txidle2 : std_logic := '0';
  signal rxerr2 : std_logic := '0';
  signal rxidle2 : std_logic := '0';
  signal txdata2 : std_logic_vector(15 downto 0) := x"0000";
  signal txstb2 : std_logic := '0';
  signal rxdata2 : std_logic_vector(15 downto 0) := x"0000";
  signal rxstb2 : std_logic := '0';
  signal clk2_time : time := 3.255 ns;
  signal cap1 : std_logic_vector(15 downto 0) := x"0000";
  signal cap2 : std_logic_vector(15 downto 0) := x"0000";

begin

  xrst <= '1', '0' after 1000 ns;
  
  --clk1 is a fixed 16x 9600 clock
  p_clk1 :process
  begin
    clk1 <= '0';
    wait for 3.255 us;
    clk1 <= '1';
    wait for 3.255 us;
  end process;

  --this process slowly decreases the clk2 by 100 ns every 10 ms
  p_clkmod :process
  begin
    clk2_time <= 3.255 us;
    while true loop
      wait for 10 ms;
      clk2_time <= clk2_time - 100 ns;
    end loop;
  end process;
  
  --this is the slowly decreasing clock 2
  p_clk2 :process
  begin
    clk2 <= '0';
    wait for clk2_time;
    clk2 <= '1';
    wait for clk2_time;
  end process;
  

  --first UART
  u_manch1 : entity work.Manchester(rtl)
  port map(
    clk16x => clk1,
    srst => xrst,
    rxd => sdat_2to1,
    rx_data => rxdata1,
    rx_stb => rxstb1,
    rx_idle => rxidle1,
    fm_err => rxerr1,
    txd => sdat_1to2,
    tx_data => txdata1,
    tx_stb => txstb1,
    tx_idle => txidle1,
    or_err => txerr1
  );
  
  
  --second UART
  u_manch2 : entity work.Manchester(rtl)
  port map(
    clk16x => clk2,
    srst => xrst,
    rxd => sdat_1to2,
    rx_data => rxdata2,
    rx_stb => rxstb2,
    rx_idle => rxidle2,
    fm_err => rxerr2,
    txd => sdat_2to1,
    tx_data => txdata2,
    tx_stb => txstb2,
    tx_idle => txidle2,
    or_err => txerr2
  );

  --feeder 1 - feeds data into UART1's transmitter
  p_feeder1 : process
  begin
    txdata1 <= x"aaaa";
    txstb1 <= '0';
    wait until xrst = '0';
    for i in 1 to 100 loop
      wait until clk1 = '1';
    end loop;
    while unsigned(txdata1) < x"abaa" loop
      wait until clk1 = '1';
      if txidle1 = '1' then
        wait for 400 us;
        wait until clk1 = '0';
        txdata1 <= std_logic_vector(unsigned(txdata1) + x"0001");
        txstb1 <= '1';
        wait until clk1 = '0';
        txstb1 <= '0';
        wait until clk1 = '0';
      end if;
    end loop;
  end process;


  --feeder 2 - feeds data into UART2's tranmitter
  p_feeder2 : process
  begin
    txdata2 <= x"5555";
    txstb2 <= '0';
    wait until xrst = '0';
    for i in 1 to 100 loop
      wait until clk2 = '1';
    end loop;
    while unsigned(txdata2) > x"5455" loop
      wait until clk2 = '1';
      if txidle2 = '1' then
        wait for 400 us;
        wait until clk2 = '0';
        txdata2 <= std_logic_vector(unsigned(txdata2) - x"0001");
        txstb2 <= '1';
        wait until clk2 = '0';
        txstb2 <= '0';
        wait until clk2 = '0';
      end if;
    end loop;
  end process;
  
  --cap1 - captures rx data from UART1's reciever for easy viewing
  p_cap1 : process
  begin
      wait until rxstb1 = '1';
      wait until clk1 = '0';
      cap1 <= rxdata1;
  end process;
  
  --cap2 - captures rx data from UART2's reciver for easy viewing
  p_cap2 : process
  begin
      wait until rxstb2 = '1';
      wait until clk2 = '0';
      cap2 <= rxdata2;
  end process;

end Behavioral;
