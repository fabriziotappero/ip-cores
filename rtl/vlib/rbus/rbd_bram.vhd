-- $Id: rbd_bram.vhd 593 2014-09-14 22:21:33Z mueller $
--
-- Copyright 2010-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rbd_bram - syn
-- Description:    rbus dev: rbus bram test target
--
-- Dependencies:   memlib/ram_1swsr_wfirst_gen
--
-- Test bench:     rlink/tb/tb_rlink_tba_ttcombo
--
-- Target Devices: generic
-- Tool versions:  xst 12.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-12-26   349 12.1    M53d xc3s1000-4    23   61    -   34 s  6.3
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-09-13   593   4.1    no default rbus addess anymore, def=0
-- 2014-08-15   583   4.0    rb_mreq addr now 16 bit
-- 2011-11-19   427   1.0.3  now numeric_std clean
-- 2010-12-31   352   1.0.2  simplify irb_ack logic
-- 2010-12-29   351   1.0.1  default addr 1111001x->1111010x
-- 2010-12-26   349   1.0    Initial version 
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Addr   Bits  Name        r/w/f  Function
--    0         cntl        r/w/-  Control register
--       15:10    nbusy     r/w/-    busy cycles
--        9:00    addr      r/w/-    bram address (will auto-increment)
--    1  15:00  data        r/w/-  Data register (read/write to bram via addr)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.rblib.all;

entity rbd_bram is                      -- rbus dev: rbus bram test target
                                        -- complete rrirp_aif interface
  generic (
    RB_ADDR : slv16 := (others=>'0'));
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type          -- rbus: response
  );
end entity rbd_bram;


architecture syn of rbd_bram is

  constant rbaddr_cntl : slv1 := "0";   -- cntl address offset
  constant rbaddr_data : slv1 := "1";   -- data address offset

  subtype  cntl_rbf_nbusy   is integer range 15 downto 10;
  subtype  cntl_rbf_addr    is integer range  9 downto  0;

  type regs_type is record              -- state registers
    rbsel : slbit;                      -- rbus select
    addr : slv10;                       -- addr register
    nbusy : slv6;                       -- nbusy setting
    cntbusy : slv6;                     -- busy timer
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- rbsel
    (others=>'0'),                      -- addr
    (others=>'0'),                      -- nbusy
    (others=>'0')                       -- cntbusy
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

  signal BRAM_EN : slbit := '0';
  signal BRAM_WE : slbit := '0';
  signal BRAM_DO : slv16 := (others=>'0');
  
begin

  BRAM : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH => 10,
      DWIDTH => 16)
    port map (
      CLK   => CLK,
      EN    => BRAM_EN,
      WE    => BRAM_WE,
      ADDR  => R_REGS.addr,
      DI    => RB_MREQ.din,
      DO    => BRAM_DO
    );

  proc_regs: process (CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next : process (R_REGS, RB_MREQ, BRAM_DO)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irbena : slbit := '0';
    variable isbusy : slbit := '0';
    variable ibramen : slbit := '0';
    variable ibramwe : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_dout := (others=>'0');

    irbena  := RB_MREQ.re or RB_MREQ.we;
        
    isbusy := '0';
    if unsigned(r.cntbusy) /= 0 then
      isbusy := '1';
    end if;

    ibramen := '0';
    ibramwe := '0';
    
    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(15 downto 1)=RB_ADDR(15 downto 1) then

      n.rbsel := '1';
      ibramen := '1';
      
      if irbena = '0' then              -- addr valid and selected, but no req
        n.cntbusy := r.nbusy;             -- preset busy timer
      end if;

    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      
      if irbena = '1' then              -- if request active
        if unsigned(r.cntbusy) /= 0 then  -- if busy timer > 0
          n.cntbusy := slv(unsigned(r.cntbusy) - 1); -- decrement busy timer
        end if;
      end if;

      irb_ack := irbena;                  -- ack all accesses
      
      case RB_MREQ.addr(0 downto 0) is

        when rbaddr_cntl =>
          if RB_MREQ.we = '1' then 
            n.nbusy  := RB_MREQ.din(cntl_rbf_nbusy);
            n.addr   := RB_MREQ.din(cntl_rbf_addr);
          end if;
          
        when rbaddr_data =>
          irb_busy := irbena and isbusy;
          if isbusy = '0' then
            if RB_MREQ.we = '1' then
              ibramwe := '1';
            end if;
            if irbena = '1' then
              n.addr := slv(unsigned(r.addr) + 1);
            end if;
          end if;
          
        when others => null;
      end case;
    end if;

    -- rbus output driver
    if r.rbsel = '1' then
      case RB_MREQ.addr(0 downto 0) is
        when rbaddr_cntl =>
          irb_dout(cntl_rbf_nbusy) := r.nbusy;
          irb_dout(cntl_rbf_addr)  := r.addr;
        when rbaddr_data =>
          irb_dout := BRAM_DO;
        when others => null;
      end case;
    end if;
    
    N_REGS <= n;

    BRAM_EN <= ibramen;
    BRAM_WE <= ibramwe;
      
    RB_SRES.dout <= irb_dout;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= '0';
    RB_SRES.busy <= irb_busy;

  end process proc_next;

end syn;
