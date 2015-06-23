-- $Id: tb_s3board_fusp.vhd 666 2015-04-12 21:17:54Z mueller $
--
-- Copyright 2010-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
-- 
------------------------------------------------------------------------------
-- Module Name:    tb_s3board_fusp - sim
-- Description:    Test bench for s3board (base+fusp)
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 rlink/tb/tbcore_rlink
--                 tb_s3board_core
--                 s3board_fusp_aif [UUT]
--                 serport/serport_master
--
-- To test:        generic, any s3board_fusp_aif target
--
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-12   666   1.3    use serport_master instead of serport_uart_rxtx
-- 2011-12-23   444   3.1    new system clock scheme, new tbcore_rlink iface
-- 2011-11-19   427   3.0.1  now numeric_std clean
-- 2010-12-30   351   3.0    use rlink/tb now
-- 2010-11-06   336   1.0.4  rename input pin CLK -> I_CLK50
-- 2010-05-21   292   1.0.3  rename _PM1_ -> _FUSP_
-- 2010-05-16   291   1.0.2  rename tb_s3board_usp->tb_s3board_fusp
-- 2010-05-02   287   1.0.1  add sbaddr_portsel def, now sbus addr 8
-- 2010-05-01   286   1.0    Initial version (derived from tb_s3board)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.rlinklib.all;
use work.rlinktblib.all;
use work.serportlib.all;
use work.s3boardlib.all;
use work.simlib.all;
use work.simbus.all;

entity tb_s3board_fusp is
end tb_s3board_fusp;

architecture sim of tb_s3board_fusp is
  
  signal CLK : slbit := '0';
  
  signal CLK_STOP : slbit := '0';
  signal CLK_CYCLE : integer := 0;

  signal RESET : slbit := '0';
  signal CLKDIV : slv2 := "00";         -- run with 1 clocks / bit !!
  signal RXDATA : slv8 := (others=>'0');
  signal RXVAL : slbit := '0';
  signal RXERR : slbit := '0';
  signal RXACT : slbit := '0';
  signal TXDATA : slv8 := (others=>'0');
  signal TXENA : slbit := '0';
  signal TXBUSY : slbit := '0';

  signal RX_HOLD : slbit := '0';

  signal I_RXD : slbit := '1';
  signal O_TXD : slbit := '1';
  signal I_SWI : slv8 := (others=>'0');
  signal I_BTN : slv4 := (others=>'0');
  signal O_LED : slv8 := (others=>'0');
  signal O_ANO_N : slv4 := (others=>'0');
  signal O_SEG_N : slv8 := (others=>'0');

  signal O_MEM_CE_N : slv2 := (others=>'1');
  signal O_MEM_BE_N : slv4 := (others=>'1');
  signal O_MEM_WE_N : slbit := '1';
  signal O_MEM_OE_N : slbit := '1';
  signal O_MEM_ADDR  : slv18 := (others=>'Z');
  signal IO_MEM_DATA : slv32 := (others=>'0');

  signal O_FUSP_RTS_N : slbit := '0';
  signal I_FUSP_CTS_N : slbit := '0';
  signal I_FUSP_RXD : slbit := '1';
  signal O_FUSP_TXD : slbit := '1';

  signal UART_RESET : slbit := '0';
  signal UART_RXD : slbit := '1';
  signal UART_TXD : slbit := '1';
  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';
  
  signal R_PORTSEL_SER : slbit := '0';       -- if 1 use alternate serport
  signal R_PORTSEL_XON : slbit := '0';       -- if 1 use xon/xoff

  constant sbaddr_portsel: slv8 := slv(to_unsigned( 8,8));

  constant clock_period : time :=  20 ns;
  constant clock_offset : time := 200 ns;

begin

  CLKGEN : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK      => CLK,
      CLK_STOP => CLK_STOP
    );
  
  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  TBCORE : tbcore_rlink
    port map (
      CLK      => CLK,
      CLK_STOP => CLK_STOP,
      RX_DATA  => TXDATA,
      RX_VAL   => TXENA,
      RX_HOLD  => RX_HOLD,
      TX_DATA  => RXDATA,
      TX_ENA   => RXVAL
    );

  RX_HOLD <= TXBUSY or RTS_N;           -- back preasure for data flow to tb
  
  S3CORE : entity work.tb_s3board_core
    port map (
      I_SWI       => I_SWI,
      I_BTN       => I_BTN,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  UUT : s3board_fusp_aif
    port map (
      I_CLK50      => CLK,
      I_RXD        => I_RXD,
      O_TXD        => O_TXD,
      I_SWI        => I_SWI,
      I_BTN        => I_BTN,
      O_LED        => O_LED,
      O_ANO_N      => O_ANO_N,
      O_SEG_N      => O_SEG_N,
      O_MEM_CE_N   => O_MEM_CE_N,
      O_MEM_BE_N   => O_MEM_BE_N,
      O_MEM_WE_N   => O_MEM_WE_N,
      O_MEM_OE_N   => O_MEM_OE_N,
      O_MEM_ADDR   => O_MEM_ADDR,
      IO_MEM_DATA  => IO_MEM_DATA,
      O_FUSP_RTS_N => O_FUSP_RTS_N,
      I_FUSP_CTS_N => I_FUSP_CTS_N,
      I_FUSP_RXD   => I_FUSP_RXD,
      O_FUSP_TXD   => O_FUSP_TXD
    );

  SERMSTR : serport_master
    generic map (
      CDWIDTH => CLKDIV'length)
    port map (
      CLK     => CLK,
      RESET   => UART_RESET,
      CLKDIV  => CLKDIV,
      ENAXON  => R_PORTSEL_XON,
      ENAESC  => '0',
      RXDATA  => RXDATA,
      RXVAL   => RXVAL,
      RXERR   => RXERR,
      RXOK    => '1',
      TXDATA  => TXDATA,
      TXENA   => TXENA,
      TXBUSY  => TXBUSY,
      RXSD    => UART_RXD,
      TXSD    => UART_TXD,
      RXRTS_N => RTS_N,
      TXCTS_N => CTS_N
    );

  proc_port_mux: process (R_PORTSEL_SER, UART_TXD, CTS_N,
                          O_TXD, O_FUSP_TXD, O_FUSP_RTS_N)
  begin

    if R_PORTSEL_SER = '0' then           -- use main board rs232, no flow cntl
      I_RXD        <= UART_TXD;           -- write port 0 inputs
      UART_RXD     <= O_TXD;              -- get port 0 outputs
      RTS_N        <= '0';
      I_FUSP_RXD   <= '1';                -- port 1 inputs to idle state
      I_FUSP_CTS_N <= '0';
    else                                -- otherwise use pmod1 rs232
      I_FUSP_RXD   <= UART_TXD;           -- write port 1 inputs
      I_FUSP_CTS_N <= CTS_N;
      UART_RXD     <= O_FUSP_TXD;         -- get port 1 outputs
      RTS_N        <= O_FUSP_RTS_N;
      I_RXD        <= '1';                -- port 0 inputs to idle state
    end if;
    
  end process proc_port_mux;

  proc_moni: process
    variable oline : line;
  begin
    
    loop
      wait until rising_edge(CLK);

      if RXERR = '1' then
        writetimestamp(oline, CLK_CYCLE, " : seen RXERR=1");
        writeline(output, oline);
      end if;
      
    end loop;

  end process proc_moni;

  proc_simbus: process (SB_VAL)
  begin
    if SB_VAL'event and to_x01(SB_VAL)='1' then
      if SB_ADDR = sbaddr_portsel then
        R_PORTSEL_SER <= to_x01(SB_DATA(0));
        R_PORTSEL_XON <= to_x01(SB_DATA(1));
      end if;
    end if;
  end process proc_simbus;

end sim;
