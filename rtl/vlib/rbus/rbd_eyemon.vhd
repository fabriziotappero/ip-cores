-- $Id: rbd_eyemon.vhd 593 2014-09-14 22:21:33Z mueller $
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
-- Module Name:    rbd_eyemon - syn
-- Description:    rbus dev: eye monitor for serport's
--
-- Dependencies:   memlib/ram_2swsr_wfirst_gen
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 12.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-04-02   374 12.1    M53d xc3s1000-4    46  154    -  109 s  8.7
-- 2010-12-27   349 12.1    M53d xc3s1000-4    45  147    -  106 s  8.9
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-09-13   593   4.1    no default rbus addess anymore, def=0
-- 2014-08-15   583   4.0    rb_mreq addr now 16 bit
-- 2011-11-19   427   1.0.3  now numeric_std clean
-- 2011-04-02   375   1.0.2  handle back-to-back chars properly (in sim..)
-- 2010-12-31   352   1.0.1  simplify irb_ack logic
-- 2010-12-27   349   1.0    Initial version 
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Addr   Bits  Name        r/w/f  Function
--   00         cntl        r/w/-  Control register
--          03    ena01     r/w/-    track 0->1 rxsd transitions
--          02    ena10     r/w/-    track 1->0 rxsd transitions
--          01    clr       r/-/f    w: writing a 1 starts memory clear
--                                     r: 1 indicates clr in progress (512 cyc)
--          00    go        r/w/-    enables monitor
--   01   7:00  rdiv        r/w/-  Sample rate divider
--   10         addr        r/w/-  Address register
--        9:01    laddr     r/w/     line address
--          00    waddr     r/w/     word address
--   11  15:00  data        r/-/-  Data register
--
--     data format:
--     word 1  counter msb's
--     word 0  counter lsb's
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.rblib.all;

entity rbd_eyemon is                    -- rbus dev: eye monitor for serport's
  generic (
    RB_ADDR : slv16 := (others=>'0');
    RDIV : slv8 := (others=>'0'));
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RXSD : in slbit;                    -- rx: serial data
    RXACT : in slbit                    -- rx: active (start seen)
  );
end entity rbd_eyemon;


architecture syn of rbd_eyemon is

  constant rbaddr_cntl : slv2 := "00";   -- cntl address offset
  constant rbaddr_rdiv : slv2 := "01";   -- rdiv address offset
  constant rbaddr_addr : slv2 := "10";   -- addr address offset
  constant rbaddr_data : slv2 := "11";   -- data address offset

  constant cntl_rbf_ena01    : integer :=     3;
  constant cntl_rbf_ena10    : integer :=     2;
  constant cntl_rbf_clr      : integer :=     1;
  constant cntl_rbf_go       : integer :=     0;
  subtype  addr_rbf_laddr   is integer range  9 downto  1;
  constant addr_rbf_waddr    : integer :=     0;

  type state_type is (
    s_idle,                             -- s_idle: wait for char or clr
    s_char,                             -- s_char: processing a char
    s_clr                               -- s_clr: clear memory
  );

  type regs_type is record              -- state registers
    state : state_type;                 -- state
    rbsel : slbit;                      -- rbus select
    go : slbit;                         -- go flag
    clr : slbit;                        -- clear pending
    ena10 : slbit;                      -- enable 1->0
    ena01 : slbit;                      -- enable 0->1
    rdiv : slv8;                        -- rate divider
    laddr : slv9;                       -- line address
    waddr : slbit;                      -- word address
    laddr_1 : slv9;                     -- line address last cycle
    rxsd_1 : slbit;                     -- rxsd last cycle
    memwe : slbit;                      -- write bram (clr or inc)
    memclr : slbit;                     -- write zero into bram
    rdivcnt : slv8;                     -- rate divider counter
  end record regs_type;

  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0',                                -- rbsel
    '0',                                -- go    (default is off)
    '0','0','0',                        -- clr,ena01,ena10
    (others=>'0'),                      -- rdiv
    (others=>'0'),                      -- laddr
    '0',                                -- waddr
    (others=>'0'),                      -- laddr_1
    '0','0','0',                        -- rxsd_1,memwe,memclr
    (others=>'0')                       -- rdivcnt
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

  signal BRAM_ENA : slbit := '0';
  signal BRAM_DIA : slv32 := (others=>'0');
  signal BRAM_DIB : slv32 := (others=>'0');
  signal BRAM_DOA : slv32 := (others=>'0');
  
begin

  BRAM_DIA <= (others=>'0');            -- always 0, no writes on this port
  
  BRAM : ram_2swsr_wfirst_gen
    generic map (
      AWIDTH =>  9,
      DWIDTH => 32)
    port map (
      CLKA   => CLK,
      CLKB   => CLK,
      ENA    => BRAM_ENA,
      ENB    => R_REGS.memwe,
      WEA    => '0',
      WEB    => R_REGS.memwe,
      ADDRA  => R_REGS.laddr,
      ADDRB  => R_REGS.laddr_1,
      DIA    => BRAM_DIA,
      DIB    => BRAM_DIB,
      DOA    => BRAM_DOA,
      DOB    => open
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

  proc_next : process (R_REGS, RB_MREQ, RXSD, RXACT, BRAM_DOA)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout  : slv16 := (others=>'0');
    variable irbena  : slbit := '0';
    variable ibramen : slbit := '0';
    variable ibramdi : slv32 := (others=>'0');
    variable laddr_we : slbit := '0';
    variable laddr_clr : slbit := '0';
    variable laddr_inc : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');

    irbena  := RB_MREQ.re or RB_MREQ.we;
        
    ibramen := '0';

    laddr_we  := '0';
    laddr_clr := '0';
    laddr_inc := '0';

    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(15 downto 2)=RB_ADDR(15 downto 2) then
      n.rbsel := '1';
      ibramen := '1';
    end if;

    -- rbus transactions
    if r.rbsel = '1' then

      irb_ack := irbena;                  -- ack all accesses
      
      case RB_MREQ.addr(1 downto 0) is

        when rbaddr_cntl =>
          if RB_MREQ.we = '1' then 
            n.ena01 := RB_MREQ.din(cntl_rbf_ena01);
            n.ena10 := RB_MREQ.din(cntl_rbf_ena10);
            if RB_MREQ.din(cntl_rbf_clr) = '1' then
              n.clr := '1';
            end if;
            n.go    := RB_MREQ.din(cntl_rbf_go);
          end if;
          
        when rbaddr_rdiv =>
          if RB_MREQ.we = '1' then
            n.rdiv := RB_MREQ.din(n.rdiv'range);
          end if;
          
        when rbaddr_addr =>
          if RB_MREQ.we = '1' then
            laddr_we := '1';
            n.waddr := RB_MREQ.din(addr_rbf_waddr);
          end if;

        when rbaddr_data =>
          if RB_MREQ.we='1' then
            irb_err := '1';
          end if;
          if RB_MREQ.re = '1' then
            if r.go='0' and r.clr='0' and r.state=s_idle then
              n.waddr := not r.waddr;
              if r.waddr = '1' then
                laddr_inc := '1';
              end if;
            else
              irb_err := '1';
            end if;
          end if;
          
        when others => null;
      end case;
    end if;

    -- rbus output driver
    if r.rbsel = '1' then
      case RB_MREQ.addr(1 downto 0) is
        when rbaddr_cntl =>
          irb_dout(cntl_rbf_ena01) := r.ena01;
          irb_dout(cntl_rbf_ena10) := r.ena10;
          irb_dout(cntl_rbf_clr)   := r.clr;
          irb_dout(cntl_rbf_go)    := r.go;
        when rbaddr_rdiv =>
          irb_dout(r.rdiv'range)   := r.rdiv;
        when rbaddr_addr =>
          irb_dout(addr_rbf_laddr) := r.laddr;
          irb_dout(addr_rbf_waddr) := r.waddr;
        when rbaddr_data =>
          case r.waddr is
            when '1' => irb_dout := BRAM_DOA(31 downto 16);
            when '0' => irb_dout := BRAM_DOA(15 downto  0);
            when others => null;
          end case;
        when others => null;
      end case;
    end if;

    -- eye monitor
    n.memwe  := '0';
    n.memclr := '0';

    case r.state is
      when s_idle =>                    -- s_idle: wait for char or clr ------
        if r.clr = '1' then
          laddr_clr := '1';
          n.state := s_clr;
        elsif r.go = '1' and RXSD='0' then
          laddr_clr := '1';
          n.rdivcnt := r.rdiv;
          n.state := s_char;
        end if;

      when s_char =>                    -- s_char: processing a char ---------
        if RXACT = '0' then               -- uart went unactive
          if RXSD = '1' then                -- line idle -> to s_idle
            n.state := s_idle;
          else                              -- already next start bit seen 
            laddr_clr := '1';                 -- clear and restart
            n.rdivcnt := r.rdiv;              -- happens only in simulation...
          end if;
        else
          if (r.ena01='1' and r.rxsd_1='0' and RXSD='1') or
             (r.ena10='1' and r.rxsd_1='1' and RXSD='0') then
            n.memwe := '1';
            ibramen := '1';
          end if;
        end if;
        if unsigned(r.rdiv)=0 or unsigned(r.rdivcnt)=0 then
          n.rdivcnt := r.rdiv;
          if unsigned(r.laddr) /= (2**r.laddr'length)-1 then
            laddr_inc := '1';
          end if;
        else
          n.rdivcnt := slv(unsigned(r.rdivcnt) - 1);
        end if;
        
      when s_clr =>                     -- s_clr: clear memory ---------------
        laddr_inc := '1';
        n.memwe  := '1';
        n.memclr := '1';
        if unsigned(r.laddr) = (2**r.laddr'length)-1 then
          n.clr   := '0';
          n.state := s_idle;
        end if;
          
      when others => null;
    end case;

    if laddr_we = '1' then
      n.laddr := RB_MREQ.din(addr_rbf_laddr);
    elsif laddr_clr = '1' then
      n.laddr := (others=>'0');
    elsif laddr_inc = '1' then
      n.laddr := slv(unsigned(r.laddr) + 1);
    end if;

    n.laddr_1 := r.laddr;
    n.rxsd_1  := RXSD;

    ibramdi := (others=>'0');
    if r.memclr = '0' then
      ibramdi := slv(unsigned(BRAM_DOA) + 1);
    end if;
    
    N_REGS <= n;

    BRAM_ENA <= ibramen;
    BRAM_DIB <= ibramdi;
    
    RB_SRES.dout <= irb_dout;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;

  end process proc_next;

end syn;
