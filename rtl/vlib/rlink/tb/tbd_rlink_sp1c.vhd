-- $Id: tbd_rlink_sp1c.vhd 596 2014-10-17 19:50:07Z mueller $
--
-- Copyright 2007-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tbd_rlink_sp1c - syn
-- Description:    Wrapper for rlink_core plus rlink_serport with an interface
--                 compatible to the rlink_core only module.
--                 NOTE: this implementation is a hack, should be redone
--                 using configurations.
--
-- Dependencies:   tbu_rlink_sp1c [UUT]
--                 serport_uart_tx
--                 serport_uart_rx
--                 byte2cdata
--                 cdata2byte
--                 simlib/simclkcnt
--
-- To test:        rlink_sp1c
--
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-08-28   588   4.0    use new rlink v4 iface and 4 bit STAT
-- 2011-12-23   444   3.2    use simclkcnt instead of simbus global
-- 2011-12-22   442   3.1    renamed and retargeted to tbu_rlink_sp1c
-- 2011-11-19   427   3.0.5  now numeric_std clean
-- 2010-12-28   350   3.0.4  use CLKDIV/CDINIT=0;
-- 2010-12-26   348   3.0.3  add RTS/CTS ports for tbu_;
-- 2010-12-24   347   3.0.2  rename: CP_*->RL->*
-- 2010-12-22   346   3.0.1  removed proc_moni, use .rlmon cmd in test bench
-- 2010-12-05   343   3.0    rri->rlink renames; port to rbus V3 protocol;
-- 2010-06-06   301   2.3    use NCOMM=4 (new eop,nak commas)
-- 2010-05-02   287   2.2.2  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT signal from interfaces
-- 2010-04-24   281   2.2.1  use serport_uart_[tr]x directly again
-- 2010-04-03   274   2.2    add CE_USEC
-- 2009-03-14   197   2.1    remove records in interface to allow _ssim usage
-- 2008-08-24   162   2.0    with new rb_mreq/rb_sres interface
-- 2007-11-25    98   1.1    added RP_IINT support; use entity rather arch
--                           name to switch core/serport;
--                           use serport_uart_[tr]x_tb to allow that UUT is a
--                           [sft]sim model compiled with keep hierarchy
-- 2007-07-02    63   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.rlinklib.all;
use work.comlib.all;
use work.serportlib.all;
use work.simlib.all;
use work.simbus.all;

entity tbd_rlink_sp1c is                -- rlink_sp1c tb design
                                        -- implements tbd_rlink_gen
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rlink ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    RESET  : in slbit;                  -- reset
    RL_DI : in slv9;                    -- rlink: data in
    RL_ENA : in slbit;                  -- rlink: data enable
    RL_BUSY : out slbit;                -- rlink: data busy
    RL_DO : out slv9;                   -- rlink: data out
    RL_VAL : out slbit;                 -- rlink: data valid
    RL_HOLD : in slbit;                 -- rlink: data hold
    RB_MREQ_aval : out slbit;           -- rbus: request - aval
    RB_MREQ_re : out slbit;             -- rbus: request - re
    RB_MREQ_we : out slbit;             -- rbus: request - we
    RB_MREQ_initt : out slbit;          -- rbus: request - init; avoid name coll
    RB_MREQ_addr : out slv16;           -- rbus: request - addr
    RB_MREQ_din : out slv16;            -- rbus: request - din
    RB_SRES_ack : in slbit;             -- rbus: response - ack
    RB_SRES_busy : in slbit;            -- rbus: response - busy
    RB_SRES_err : in slbit;             -- rbus: response - err
    RB_SRES_dout : in slv16;            -- rbus: response - dout
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv4;                  -- rbus: status flags
    TXRXACT : out slbit                 -- txrx active flag
  );
end entity tbd_rlink_sp1c;


architecture syn of tbd_rlink_sp1c is
  
  constant CDWIDTH : positive := 13;
  constant c_cdinit : natural := 0;   -- NOTE: change in tbu_rlink_sp1c !!

  signal RRI_RXSD : slbit := '0';
  signal RRI_TXSD : slbit := '0';
  signal RTS_N : slbit := '0';
  signal RXDATA : slv8 := (others=>'0');
  signal RXVAL : slbit := '0';
  signal RXACT : slbit := '0';
  signal TXDATA : slv8 := (others=>'0');
  signal TXENA : slbit := '0';
  signal TXBUSY : slbit := '0';
  signal CLKDIV : slv13 := slv(to_unsigned(c_cdinit,CDWIDTH));
  signal CLK_CYCLE : integer := 0;

component tbu_rlink_sp1c is             -- rlink core+serport combo
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit;                  -- rlink ito time unit clock enable
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET  : in slbit;                  -- reset
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit;                   -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RB_MREQ_aval : out slbit;           -- rbus: request - aval
    RB_MREQ_re : out slbit;             -- rbus: request - re
    RB_MREQ_we : out slbit;             -- rbus: request - we
    RB_MREQ_initt : out slbit;          -- rbus: request - init; avoid name coll
    RB_MREQ_addr : out slv16;           -- rbus: request - addr
    RB_MREQ_din : out slv16;            -- rbus: request - din
    RB_SRES_ack : in slbit;             -- rbus: response - ack
    RB_SRES_busy : in slbit;            -- rbus: response - busy
    RB_SRES_err : in slbit;             -- rbus: response - err
    RB_SRES_dout : in slv16;            -- rbus: response - dout
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv4                   -- rbus: status flags
  );
end component;

begin

  TBU : tbu_rlink_sp1c
    port map (
      CLK          => CLK,
      CE_INT       => CE_INT,
      CE_USEC      => CE_USEC,
      CE_MSEC      => '1',
      RESET        => RESET,
      RXSD         => RRI_RXSD,
      TXSD         => RRI_TXSD,
      CTS_N        => '0',
      RTS_N        => RTS_N,
      RB_MREQ_aval => RB_MREQ_aval,
      RB_MREQ_re   => RB_MREQ_re,
      RB_MREQ_we   => RB_MREQ_we,
      RB_MREQ_initt=> RB_MREQ_initt,
      RB_MREQ_addr => RB_MREQ_addr,
      RB_MREQ_din  => RB_MREQ_din,
      RB_SRES_ack  => RB_SRES_ack,
      RB_SRES_busy => RB_SRES_busy,
      RB_SRES_err  => RB_SRES_err,
      RB_SRES_dout => RB_SRES_dout,
      RB_LAM       => RB_LAM,
      RB_STAT      => RB_STAT
    );

  UARTRX : serport_uart_rx
    generic map (
      CDWIDTH => CDWIDTH)
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CLKDIV => CLKDIV,
      RXSD   => RRI_TXSD,
      RXDATA => RXDATA,
      RXVAL  => RXVAL,
      RXERR  => open,
      RXACT  => RXACT
    );

  UARTTX : serport_uart_tx
    generic map (
      CDWIDTH => CDWIDTH)
    port map (
      CLK    => CLK,
      RESET  => RESET,
      CLKDIV => CLKDIV,
      TXSD   => RRI_RXSD,
      TXDATA => TXDATA,
      TXENA  => TXENA,
      TXBUSY => TXBUSY
    );

  TXRXACT <= RXACT or TXBUSY;
  
  B2CD : byte2cdata                     -- byte stream -> 9bit comma,data
    port map (
      CLK   => CLK,
      RESET => RESET,
      DI    => RXDATA,
      ENA   => RXVAL,
      ERR   => '0',
      BUSY  => open,
      DO    => RL_DO,
      VAL   => RL_VAL,
      HOLD  => RL_HOLD
    );

  CD2B : cdata2byte                     -- 9bit comma,data -> byte stream
    port map (
      CLK     => CLK,
      RESET   => RESET,
      ESCXON  => '0',
      ESCFILL => '0',
      DI      => RL_DI,
      ENA     => RL_ENA,
      BUSY    => RL_BUSY,
      DO      => TXDATA,
      VAL     => TXENA,
      HOLD    => TXBUSY
    );
  
  CLKCNT : simclkcnt port map (CLK => CLK, CLK_CYCLE => CLK_CYCLE);

  proc_moni: process
    variable oline : line;
    variable rts_last : slbit := '0';
    variable ncycle : integer := 0;
  begin
    loop
      wait until rising_edge(CLK);      -- check at end of clock cycle
      if RTS_N /= rts_last then
        writetimestamp(oline, CLK_CYCLE, ": rts  ");
        write(oline, string'(" RTS_N "));
        write(oline, rts_last, right, 1);
        write(oline, string'(" -> "));
        write(oline, RTS_N, right, 1);
        write(oline, string'(" after "));
        write(oline, ncycle, right, 5);
        write(oline, string'(" cycles"));
        writeline(output, oline);
        rts_last := RTS_N;
        ncycle   := 0;
      end if;
      ncycle := ncycle + 1;
    end loop;
  end process proc_moni;

end syn;
