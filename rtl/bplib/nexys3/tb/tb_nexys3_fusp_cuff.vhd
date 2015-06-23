-- $Id: tb_nexys3_fusp_cuff.vhd 666 2015-04-12 21:17:54Z mueller $
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
-- Module Name:    tb_nexys3_fusp_cuff - sim
-- Description:    Test bench for nexys3 (base+fusp+cuff)
--
-- Dependencies:   simlib/simclk
--                 simlib/simclkcnt
--                 xlib/s6_cmt_sfs
--                 rlink/tb/tbcore_rlink
--                 tb_nexys3_core
--                 serport/serport_master
--                 fx2lib/tb/fx2_2fifo_core
--                 nexys3_fusp_cuff_aif [UUT]
--
-- To test:        generic, any nexys3_fusp_cuff_aif target
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-12   666   1.2    use serport_master instead of serport_uart_rxtx
-- 2013-10-06   538   1.1    pll support, use clksys_vcodivide ect
-- 2013-04-21   509   1.0    Initial version (derived from tb_nexys3_fusp and
--                                            tb_nexys2_fusp_cuff)
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
use work.nexys3lib.all;
use work.simlib.all;
use work.simbus.all;
use work.sys_conf.all;

entity tb_nexys3_fusp_cuff is
end tb_nexys3_fusp_cuff;

architecture sim of tb_nexys3_fusp_cuff is
  
  signal CLKOSC : slbit := '0';         -- board clock (100 Mhz)
  signal CLKCOM : slbit := '0';         -- communication clock

  signal CLK_STOP : slbit := '0';
  signal CLKCOM_CYCLE : integer := 0;

  signal RESET : slbit := '0';
  signal CLKDIV : slv2 := "00";         -- run with 1 clocks / bit !!
  
  signal TBC_RXDATA : slv8 := (others=>'0');
  signal TBC_RXVAL  : slbit := '0';
  signal TBC_RXHOLD : slbit := '0';
  signal TBC_TXDATA : slv8 := (others=>'0');
  signal TBC_TXENA  : slbit := '0';

  signal UART_RXDATA : slv8 := (others=>'0');
  signal UART_RXVAL : slbit := '0';
  signal UART_RXERR : slbit := '0';
  signal UART_TXDATA : slv8 := (others=>'0');
  signal UART_TXENA : slbit := '0';
  signal UART_TXBUSY : slbit := '0';

  signal FX2_RXDATA : slv8 := (others=>'0');
  signal FX2_RXENA : slbit := '0';
  signal FX2_RXBUSY : slbit := '0';
  signal FX2_TXDATA : slv8 := (others=>'0');
  signal FX2_TXVAL : slbit := '0';

  signal I_RXD : slbit := '1';
  signal O_TXD : slbit := '1';
  signal I_SWI : slv8 := (others=>'0');
  signal I_BTN : slv5 := (others=>'0');
  signal O_LED : slv8 := (others=>'0');
  signal O_ANO_N : slv4 := (others=>'0');
  signal O_SEG_N : slv8 := (others=>'0');

  signal O_MEM_CE_N  : slbit := '1';
  signal O_MEM_BE_N  : slv2 := (others=>'1');
  signal O_MEM_WE_N  : slbit := '1';
  signal O_MEM_OE_N  : slbit := '1';
  signal O_MEM_ADV_N : slbit := '1';
  signal O_MEM_CLK   : slbit := '0';
  signal O_MEM_CRE   : slbit := '0';
  signal I_MEM_WAIT  : slbit := '0';
  signal O_MEM_ADDR  : slv23 := (others=>'Z');
  signal IO_MEM_DATA : slv16 := (others=>'0');
  signal O_PPCM_CE_N   : slbit := '0';
  signal O_PPCM_RST_N  : slbit := '0';

  signal O_FUSP_RTS_N : slbit := '0';
  signal I_FUSP_CTS_N : slbit := '0';
  signal I_FUSP_RXD : slbit := '1';
  signal O_FUSP_TXD : slbit := '1';

  signal I_FX2_IFCLK : slbit := '0';
  signal O_FX2_FIFO : slv2 := (others=>'0');
  signal I_FX2_FLAG : slv4 := (others=>'0');
  signal O_FX2_SLRD_N : slbit := '1';
  signal O_FX2_SLWR_N : slbit := '1';
  signal O_FX2_SLOE_N : slbit := '1';
  signal O_FX2_PKTEND_N : slbit := '1';
  signal IO_FX2_DATA : slv8 := (others=>'Z');

  signal UART_RESET : slbit := '0';
  signal UART_RXD : slbit := '1';
  signal UART_TXD : slbit := '1';
  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';

  signal R_PORTSEL_SER : slbit := '0';       -- if 1 use alternate serport
  signal R_PORTSEL_XON : slbit := '0';       -- if 1 use xon/xoff
  signal R_PORTSEL_FX2 : slbit := '0';       -- if 1 use fx2

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
  
  SB_CLKSTOP <= CLK_STOP;

  CLKGEN_COM : s6_cmt_sfs
    generic map (
      VCO_DIVIDE   => sys_conf_clksys_vcodivide,
      VCO_MULTIPLY => sys_conf_clksys_vcomultiply,
      OUT_DIVIDE   => sys_conf_clksys_outdivide,
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
      RX_DATA  => TBC_RXDATA,
      RX_VAL   => TBC_RXVAL,
      RX_HOLD  => TBC_RXHOLD,
      TX_DATA  => TBC_TXDATA,
      TX_ENA   => TBC_TXENA
    );

  N3CORE : entity work.tb_nexys3_core
    port map (
      I_SWI       => I_SWI,
      I_BTN       => I_BTN,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADV_N => O_MEM_ADV_N,
      O_MEM_CLK   => O_MEM_CLK,
      O_MEM_CRE   => O_MEM_CRE,
      I_MEM_WAIT  => I_MEM_WAIT,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  UUT : nexys3_fusp_cuff_aif
    port map (
      I_CLK100     => CLKOSC,
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
      O_MEM_ADV_N  => O_MEM_ADV_N,
      O_MEM_CLK    => O_MEM_CLK,
      O_MEM_CRE    => O_MEM_CRE,
      I_MEM_WAIT   => I_MEM_WAIT,
      O_MEM_ADDR   => O_MEM_ADDR,
      IO_MEM_DATA  => IO_MEM_DATA,
      O_PPCM_CE_N  => O_PPCM_CE_N,
      O_PPCM_RST_N => O_PPCM_RST_N,
      O_FUSP_RTS_N => O_FUSP_RTS_N,
      I_FUSP_CTS_N => I_FUSP_CTS_N,
      I_FUSP_RXD   => I_FUSP_RXD,
      O_FUSP_TXD   => O_FUSP_TXD,
      I_FX2_IFCLK    => I_FX2_IFCLK,
      O_FX2_FIFO     => O_FX2_FIFO,
      I_FX2_FLAG     => I_FX2_FLAG,
      O_FX2_SLRD_N   => O_FX2_SLRD_N,
      O_FX2_SLWR_N   => O_FX2_SLWR_N,
      O_FX2_SLOE_N   => O_FX2_SLOE_N,
      O_FX2_PKTEND_N => O_FX2_PKTEND_N,
      IO_FX2_DATA    => IO_FX2_DATA
    );

  SERMSTR : serport_master
    generic map (
      CDWIDTH => CLKDIV'length)
    port map (
      CLK     => CLKCOM,
      RESET   => UART_RESET,
      CLKDIV  => CLKDIV,
      ENAXON  => R_PORTSEL_XON,
      ENAESC  => '0',
      RXDATA  => UART_RXDATA,
      RXVAL   => UART_RXVAL,
      RXERR   => UART_RXERR,
      RXOK    => '1',
      TXDATA  => UART_TXDATA,
      TXENA   => UART_TXENA,
      TXBUSY  => UART_TXBUSY,
      RXSD    => UART_RXD,
      TXSD    => UART_TXD,
      RXRTS_N => RTS_N,
      TXCTS_N => CTS_N
    );

  FX2 : entity work.fx2_2fifo_core
    port map (
      CLK      => CLKCOM,
      RESET    => '0',
      RXDATA   => FX2_RXDATA,
      RXENA    => FX2_RXENA,
      RXBUSY   => FX2_RXBUSY,
      TXDATA   => FX2_TXDATA,
      TXVAL    => FX2_TXVAL,
      IFCLK    => I_FX2_IFCLK,
      FIFO     => O_FX2_FIFO,
      FLAG     => I_FX2_FLAG,
      SLRD_N   => O_FX2_SLRD_N,
      SLWR_N   => O_FX2_SLWR_N,
      SLOE_N   => O_FX2_SLOE_N,
      PKTEND_N => O_FX2_PKTEND_N,
      DATA     => IO_FX2_DATA
    );

  proc_fx2_mux: process (R_PORTSEL_FX2, TBC_RXDATA, TBC_RXVAL,
                         UART_TXBUSY, RTS_N, UART_RXDATA, UART_RXVAL,
                         FX2_RXBUSY, FX2_TXDATA, FX2_TXVAL
                         )
  begin

    if R_PORTSEL_FX2 = '0' then         -- use serport
      UART_TXDATA <= TBC_RXDATA;
      UART_TXENA  <= TBC_RXVAL;
      TBC_RXHOLD  <= UART_TXBUSY or RTS_N;
      TBC_TXDATA  <= UART_RXDATA;
      TBC_TXENA   <= UART_RXVAL;
    else                                -- otherwise use fx2
      FX2_RXDATA  <= TBC_RXDATA;
      FX2_RXENA   <= TBC_RXVAL;
      TBC_RXHOLD  <= FX2_RXBUSY;
      TBC_TXDATA  <= FX2_TXDATA;
      TBC_TXENA   <= FX2_TXVAL;
    end if;
    
  end process proc_fx2_mux;

  proc_ser_mux: process (R_PORTSEL_SER, UART_TXD, CTS_N,
                         O_TXD, O_FUSP_TXD, O_FUSP_RTS_N)
  begin

    if R_PORTSEL_SER = '0' then         -- use main board rs232, no flow cntl
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
    
  end process proc_ser_mux;

  proc_moni: process
    variable oline : line;
  begin
    
    loop
      wait until rising_edge(CLKCOM);

      if UART_RXERR = '1' then
        writetimestamp(oline, CLKCOM_CYCLE, " : seen UART_RXERR=1");
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
        R_PORTSEL_FX2 <= to_x01(SB_DATA(2));
      end if;
    end if;
  end process proc_simbus;

end sim;
