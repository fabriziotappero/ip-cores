-- $Id: bp_rs232_2l4l_iob.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    bp_rs232_2l4l_iob - syn
-- Description:    iob's for internal(2line) + external(4line) rs232, with select
--
-- Dependencies:   bp_rs232_2line_iob
--                 bp_rs232_4line_iob
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 12.1-14,7; ghdl 0.26-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-08-14   406   1.2.2  fix mistake in tx and rts relay
-- 2011-08-07   404   1.2.1  add RELAY generic and a relay stage towards IOB's
-- 2011-08-06   403   1.2    add pipeline flops; add RESET signal
-- 2011-07-09   391   1.1    moved and renamed to bpgen
-- 2011-07-02   387   1.0.1  use bp_rs232_[24]line_iob now
-- 2010-04-17   278   1.0    Initial version
------------------------------------------------------------------------------
--    

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.bpgenlib.all;

-- ----------------------------------------------------------------------------

entity bp_rs232_2l4l_iob is             -- iob's for dual 2l+4l rs232, w/ select
  generic (
    RELAY : boolean := false);          -- add a relay stage towards IOB's
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    SEL : in slbit;                     -- select, '0' for port 0
    RXD : out slbit;                    -- receive data (board view)
    TXD : in slbit;                     -- transmit data (board view)
    CTS_N : out slbit;                  -- clear to send   (act. low)
    RTS_N : in slbit;                   -- request to send (act. low)
    I_RXD0 : in slbit;                  -- pad-i: p0: receive data (board view)
    O_TXD0 : out slbit;                 -- pad-o: p0: transmit data (board view)
    I_RXD1 : in slbit;                  -- pad-i: p1: receive data (board view)
    O_TXD1 : out slbit;                 -- pad-o: p1: transmit data (board view)
    I_CTS1_N : in slbit;                -- pad-i: p1: clear to send   (act. low)
    O_RTS1_N : out slbit                -- pad-o: p1: request to send (act. low)
  );
end bp_rs232_2l4l_iob;

architecture syn of bp_rs232_2l4l_iob is
  
  signal RXD0 : slbit := '0';
  signal RXD1 : slbit := '0';
  signal CTS1_N : slbit := '0';

  signal R_RXD    : slbit := '1';
  signal R_CTS_N  : slbit := '0';
  signal R_TXD0   : slbit := '1';
  signal R_TXD1   : slbit := '1';
  signal R_RTS1_N : slbit := '0';

  signal RR_RXD0   : slbit := '1';
  signal RR_TXD0   : slbit := '1';
  signal RR_RXD1   : slbit := '1';
  signal RR_TXD1   : slbit := '1';
  signal RR_CTS1_N : slbit := '0';
  signal RR_RTS1_N : slbit := '0';

begin

  -- On Digilent Atlys bords the IOBs for P0 and P1 are on diagonally opposide
  -- corners of the die, which causes very long (7-8ns) routing delays to a LUT
  -- in the middle. The RELAY generic allows to add 'relay flops' between IOB
  -- flops and the mux implented in proc_regs_mux.
  --
  -- The data flow is
  --   iob-flop     relay-flop    if-flop     port
  --   RXD0      -> RR_RXD0    -> R_RXD    -> RXD
  --   TXD0      <- RR_TXD0    <- R_TXD0   <- TXD
  --   RXD1      -> RR_RXD1    -> R_RXD    -> RXD
  --   TXD1      <- RR_TXD1    <- R_TXD1   <- TXD
  --   CTS1_N    -> RR_CTS1_N  -> R_CTS_N  -> CTS
  --   RTS1_N    <- RR_RTS1_N  <- R_RTS1_N <- RTS
  
  P0 : bp_rs232_2line_iob
    port map (
      CLK   => CLK,
      RXD   => RXD0,
      TXD   => RR_TXD0,
      I_RXD => I_RXD0,
      O_TXD => O_TXD0
    );

  P1 : bp_rs232_4line_iob
    port map (
      CLK     => CLK,
      RXD     => RXD1,
      TXD     => RR_TXD1,
      CTS_N   => CTS1_N,
      RTS_N   => RR_RTS1_N,
      I_RXD   => I_RXD1,
      O_TXD   => O_TXD1,
      I_CTS_N => I_CTS1_N,
      O_RTS_N => O_RTS1_N
    );

  DORELAY : if RELAY generate
    proc_regs_pipe: process (CLK)
    begin
      if rising_edge(CLK) then
        if RESET = '1' then
          RR_RXD0   <= '1';
          RR_TXD0   <= '1';
          RR_RXD1   <= '1';
          RR_TXD1   <= '1';
          RR_CTS1_N <= '0';
          RR_RTS1_N <= '0';
        else
          RR_RXD0   <= RXD0;
          RR_TXD0   <= R_TXD0;
          RR_RXD1   <= RXD1;
          RR_TXD1   <= R_TXD1;
          RR_CTS1_N <= CTS1_N;
          RR_RTS1_N <= R_RTS1_N;
        end if;
      end if;
    end process proc_regs_pipe;
  end generate DORELAY;

  NORELAY : if not RELAY generate
    RR_RXD0   <= RXD0;
    RR_TXD0   <= R_TXD0;
    RR_RXD1   <= RXD1;
    RR_TXD1   <= R_TXD1;
    RR_CTS1_N <= CTS1_N;
    RR_RTS1_N <= R_RTS1_N;
  end generate NORELAY;

  proc_regs_mux: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_RXD    <= '1';
        R_CTS_N  <= '0';
        R_TXD0   <= '1';
        R_TXD1   <= '1';
        R_RTS1_N <= '0';        
      else
        if SEL = '0' then               -- use 2-line rs232, no flow cntl
          R_RXD    <= RR_RXD0;            -- get port 0 inputs
          R_CTS_N  <= '0';
          R_TXD0   <= TXD;                -- set port 0 output 
          R_TXD1   <= '1';                -- port 1 outputs to idle state
          R_RTS1_N <= '0';
        else                            -- otherwise use 4-line rs232
          R_RXD    <= RR_RXD1;             -- get port 1 inputs
          R_CTS_N  <= RR_CTS1_N;
          R_TXD0   <= '1';                 -- port 0 output to idle state
          R_TXD1   <= TXD;                 -- set port 1 outputs
          R_RTS1_N <= RTS_N;
        end if;  
      end if;
    end if;

  end process proc_regs_mux;
  
  RXD   <= R_RXD;
  CTS_N <= R_CTS_N;
  
end syn;
