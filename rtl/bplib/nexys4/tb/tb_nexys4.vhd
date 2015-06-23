-- $Id: tb_nexys4.vhd 666 2015-04-12 21:17:54Z mueller $
--
-- Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tb_nexys4 - sim
-- Description:    Test bench for nexys4 (base)
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 rlink/tb/tbcore_rlink
--                 xlib/s7_cmt_sfs
--                 tb_nexys4_core
--                 serport/serport_master
--                 nexys4_aif [UUT]
--
-- To test:        generic, any nexys4_aif target
--
-- Target Devices: generic
-- Tool versions:  ise 14.5-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-12   666   1.3    use serport_master instead of serport_uart_rxtx
-- 2015-02-06   643   1.2    factor out memory
-- 2015-02-01   641   1.1    separate I_BTNRST_N
-- 2013-09-28   535   1.0.1  use proper clock manager
-- 2013-09-21   534   1.0    Initial version (derived from tb_nexys3)
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
use work.xlib.all;
use work.nexys4lib.all;
use work.simlib.all;
use work.simbus.all;
use work.sys_conf.all;

entity tb_nexys4 is
end tb_nexys4;

architecture sim of tb_nexys4 is
  
  signal CLKOSC : slbit := '0';         -- board clock (100 Mhz)
  signal CLKCOM : slbit := '0';         -- communication clock

  signal CLK_STOP : slbit := '0';
  signal CLKCOM_CYCLE : integer := 0;

  signal RESET : slbit := '0';
  signal CLKDIV : slv2 := "00";         -- run with 1 clocks / bit !!
  signal RXDATA : slv8 := (others=>'0');
  signal RXVAL : slbit := '0';
  signal RXERR : slbit := '0';
  signal RXACT : slbit := '0';
  signal TXDATA : slv8 := (others=>'0');
  signal TXENA : slbit := '0';
  signal TXBUSY : slbit := '0';

  signal I_RXD : slbit := '1';
  signal O_TXD : slbit := '1';
  signal O_RTS_N : slbit := '0';
  signal I_CTS_N : slbit := '0';
  signal I_SWI : slv16 := (others=>'0');
  signal I_BTN : slv5 := (others=>'0');
  signal I_BTNRST_N : slbit := '1';
  signal O_LED : slv16 := (others=>'0');
  signal O_RGBLED0 : slv3 := (others=>'0');
  signal O_RGBLED1 : slv3 := (others=>'0');
  signal O_ANO_N : slv8 := (others=>'0');
  signal O_SEG_N : slv8 := (others=>'0');

  signal R_PORTSEL_XON : slbit := '0';       -- if 1 use xon/xoff

  constant sbaddr_portsel: slv8 := slv(to_unsigned( 8,8));

  constant clock_period : time :=  10 ns;
  constant clock_offset : time := 200 ns;

begin
  
  CLKGEN : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK      => CLKOSC,
      CLK_STOP => CLK_STOP
    );
  
  CLKGEN_COM : s7_cmt_sfs
    generic map (
      VCO_DIVIDE   => sys_conf_clkser_vcodivide,
      VCO_MULTIPLY => sys_conf_clkser_vcomultiply,
      OUT_DIVIDE   => sys_conf_clkser_outdivide,
      CLKIN_PERIOD => 10.0,
      CLKIN_JITTER => 0.01,
      STARTUP_WAIT => false,
      GEN_TYPE     => sys_conf_clksys_gentype)
    port map (
      CLKIN   => CLKOSC,
      CLKFX   => CLKCOM,
      LOCKED  => open
    );

  CLKCNT : simclkcnt port map (CLK => CLKCOM, CLK_CYCLE => CLKCOM_CYCLE);

  TBCORE : tbcore_rlink
    port map (
      CLK      => CLKCOM,
      CLK_STOP => CLK_STOP,
      RX_DATA  => TXDATA,
      RX_VAL   => TXENA,
      RX_HOLD  => TXBUSY,
      TX_DATA  => RXDATA,
      TX_ENA   => RXVAL
    );

  N4CORE : entity work.tb_nexys4_core
    port map (
      I_SWI       => I_SWI,
      I_BTN       => I_BTN,
      I_BTNRST_N  => I_BTNRST_N
    );

  UUT : nexys4_aif
    port map (
      I_CLK100    => CLKOSC,
      I_RXD       => I_RXD,
      O_TXD       => O_TXD,
      O_RTS_N     => O_RTS_N,
      I_CTS_N     => I_CTS_N,
      I_SWI       => I_SWI,
      I_BTN       => I_BTN,
      I_BTNRST_N  => I_BTNRST_N,
      O_LED       => O_LED,
      O_RGBLED0   => O_RGBLED0,
      O_RGBLED1   => O_RGBLED1,
      O_ANO_N     => O_ANO_N,
      O_SEG_N     => O_SEG_N
    );
  
  SERMSTR : serport_master
    generic map (
      CDWIDTH => CLKDIV'length)
    port map (
      CLK     => CLKCOM,
      RESET   => RESET,
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
      RXSD    => O_TXD,
      TXSD    => I_RXD,
      RXRTS_N => I_CTS_N,
      TXCTS_N => O_RTS_N
    );

  proc_moni: process
    variable oline : line;
  begin
    
    loop
      wait until rising_edge(CLKCOM);

      if RXERR = '1' then
        writetimestamp(oline, CLKCOM_CYCLE, " : seen RXERR=1");
        writeline(output, oline);
      end if;
      
    end loop;
    
  end process proc_moni;

  proc_simbus: process (SB_VAL)
  begin
    if SB_VAL'event and to_x01(SB_VAL)='1' then
      if SB_ADDR = sbaddr_portsel then
        R_PORTSEL_XON <= to_x01(SB_DATA(1));
      end if;
    end if;
  end process proc_simbus;

end sim;
