-- $Id: rbd_tester.vhd 593 2014-09-14 22:21:33Z mueller $
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
-- Module Name:    rbd_tester - syn
-- Description:    rbus dev: rbus tester
--
-- Dependencies:   memlib/fifo_1c_dram_raw
--
-- Test bench:     rlink/tb/tb_rlink (used as test target)
--
-- Target Devices: generic
-- Tool versions:  xst 12.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2014-08-31   590 14.7  131013 xc6slx16-2    74  162   16   73 s  5.8 ver 4.1
-- 2010-12-12   344 12.1    M53d xc3s1000-4    78  204   32  133 s  8.0
-- 2010-12-04   343 12.1    M53d xc3s1000-4    75  214   32  136 s  9.3
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-09-05   591   4.1    use new iface with 8 regs
-- 2014-08-30   589   4.0    use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit
-- 2011-11-19   427   1.0.4  now numeric_std clean
-- 2010-12-31   352   1.0.3  simplify irb_ack logic
-- 2010-12-29   351   1.0.2  default addr 111101xx->111100xx
-- 2010-12-12   344   1.0.1  send 0101.. on busy or err; fix init and busy logic
-- 2010-12-04   343   1.0    Initial version 
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Addr   Bits  Name        r/w/f  Function
--  000         cntl        r/w/-  Control register
--          15    wchk      r/w/-    write check seen (cleared on data write)
--       09:00    nbusy     r/w/-    busy cycles (for data,dinc,fifo,lnak)
--  001  03:00  stat        r/w/-  status send to RB_STAT
--  010         attn        -/w/f  Attn register: ping RB_LAM lines
--  011  09:00  ncyc        r/-/-  return cycle length of last access
--  100         data        r/w/-  Data register (plain read/write)
--  101         dinc        r/w/-  Data register (autoinc and write check)
--  110         fifo        r/w/-  Fifo interface register
--  111         lnak        r/w/-  delayed ack deassert
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.rblib.all;

entity rbd_tester is                    -- rbus dev: rbus tester
                                        -- complete rrirp_aif interface
  generic (
    RB_ADDR : slv16 := slv(to_unsigned(16#ffe0#,16)));
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_LAM : out slv16;                 -- rbus: look at me
    RB_STAT : out slv4                  -- rbus: status flags
  );
end entity rbd_tester;


architecture syn of rbd_tester is

  constant awidth : positive := 4;      -- fifo address width

  constant rbaddr_cntl : slv3 := "000";  -- cntl address offset
  constant rbaddr_stat : slv3 := "001";  -- stat address offset
  constant rbaddr_attn : slv3 := "010";  -- attn address offset
  constant rbaddr_ncyc : slv3 := "011";  -- ncyc address offset
  constant rbaddr_data : slv3 := "100";  -- data address offset
  constant rbaddr_dinc : slv3 := "101";  -- dinc address offset
  constant rbaddr_fifo : slv3 := "110";  -- fifo address offset
  constant rbaddr_lnak : slv3 := "111";  -- lnak address offset

  constant cntl_rbf_wchk    : integer := 15;
  subtype  cntl_rbf_nbusy   is integer range  9 downto  0;

  constant init_rbf_cntl  : integer :=  0;
  constant init_rbf_data  : integer :=  1;
  constant init_rbf_fifo  : integer :=  2;
  
  type regs_type is record              -- state registers
    rbsel : slbit;                      -- rbus select
    wchk : slbit;                       -- write check flag
    stat : slv4;                        -- stat setting
    nbusy : slv10;                      -- nbusy setting
    data : slv16;                       -- data register
    act_1 : slbit;                      -- rbsel and (re or we) in last cycle
    ncyc : slv10;                       -- cycle length of last access
    cntbusy : slv10;                    -- busy timer
    cntcyc : slv10;                     -- cycle length counter
  end record regs_type;

  constant regs_init : regs_type := (
    '0','0',                            -- rbsel, wchk
    (others=>'0'),                      -- stat
    (others=>'0'),                      -- nbusy
    (others=>'0'),                      -- data
    '0',                                -- act_1
    (others=>'0'),                      -- ncyc
    (others=>'0'),                      -- cntbusy
    (others=>'0')                       -- cntcyc
  );

  constant cntcyc_max : slv(regs_init.cntcyc'range) := (others=>'1');

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;
   
  signal FIFO_RESET : slbit := '0';
  signal FIFO_RE : slbit := '0';
  signal FIFO_WE : slbit := '0';
  signal FIFO_EMPTY : slbit := '0';
  signal FIFO_FULL : slbit := '0';
  signal FIFO_SIZE : slv(awidth-1 downto 0) := (others=>'0');
  signal FIFO_DO : slv16 := (others=>'0');
  
begin

  FIFO : fifo_1c_dram_raw
    generic map (
      AWIDTH => awidth,
      DWIDTH => 16)
    port map (
      CLK   => CLK,
      RESET => FIFO_RESET,
      RE    => FIFO_RE,
      WE    => FIFO_WE,
      DI    => RB_MREQ.din,
      DO    => FIFO_DO,
      SIZE  => FIFO_SIZE,      
      EMPTY => FIFO_EMPTY,
      FULL  => FIFO_FULL
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

  proc_next : process (R_REGS, RB_MREQ, FIFO_EMPTY, FIFO_FULL, FIFO_DO)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irbena : slbit := '0';
    variable irblam : slv16 := (others=>'0');
    variable ififo_re : slbit := '0';
    variable ififo_we : slbit := '0';
    variable ififo_reset : slbit := '0';
    variable isbusy : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');
    irblam   := (others=>'0');

    irbena  := RB_MREQ.re or RB_MREQ.we;
        
    ififo_re := '0';
    ififo_we := '0';
    ififo_reset := '0';

    isbusy := '0';
    if unsigned(r.cntbusy) /= 0 then
      isbusy := '1';
    end if;

    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(15 downto 3)=RB_ADDR(15 downto 3) then

      n.rbsel := '1';

      if irbena = '0' then              -- addr valid and selected, but no req
        n.cntbusy := r.nbusy;             -- preset busy timer
        n.cntcyc  := (others=>'0');       -- clear cycle length counter
      end if;

    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      
      if irbena = '1' then              -- if request active
        if unsigned(r.cntbusy) /= 0 then  -- if busy timer > 0
          n.cntbusy := slv(unsigned(r.cntbusy) - 1); -- decrement busy timer
        end if;
        if r.cntcyc /= cntcyc_max then    -- if cycle counter < max
          n.cntcyc  := slv(unsigned(r.cntcyc) + 1);  -- increment cycle counter
        end if;
      end if;
      
      irb_ack := irbena;                  -- ack all (some rejects later)

      case RB_MREQ.addr(2 downto 0) is

        when rbaddr_cntl =>
          if RB_MREQ.we='1' then 
            n.wchk   := RB_MREQ.din(cntl_rbf_wchk);
            n.nbusy  := RB_MREQ.din(cntl_rbf_nbusy);
          end if;
          
        when rbaddr_stat =>
          if RB_MREQ.we='1' then 
            n.stat   := RB_MREQ.din(r.stat'range);
          end if;
          
        when rbaddr_attn =>
          if RB_MREQ.we = '1' then      -- on we
            irblam := RB_MREQ.din;        -- ping lam lines 
          elsif RB_MREQ.re = '1'  then  -- on re
            irb_err := '1';               -- reject
          end if;
          
        when rbaddr_ncyc =>
          if RB_MREQ.we = '1' then      -- on we
            irb_err := '1';               -- reject
          end if;
          
        when rbaddr_data =>
          irb_busy := irbena and isbusy;
          if RB_MREQ.we='1' and isbusy='0' then
            n.wchk := '0';
            n.data := RB_MREQ.din;
          end if;
          
        when rbaddr_dinc =>
          irb_busy := irbena and isbusy;
          if RB_MREQ.we = '1' then
            if r.data /= RB_MREQ.din then
              n.wchk := '1';
            end if;
          end if;
          if (RB_MREQ.re='1' or RB_MREQ.we='1') and isbusy='0' then
            n.data := slv(unsigned(r.data) + 1);
          end if;
          
        when rbaddr_fifo =>
          irb_busy := irbena and isbusy;
          if RB_MREQ.re='1' and isbusy='0' then
            if FIFO_EMPTY = '1' then
              irb_err := '1';
            else
              ififo_re := '1';
            end if;
          end if;
          if RB_MREQ.we='1' and isbusy='0' then
            if FIFO_FULL = '1' then
              irb_err := '1';
            else
              ififo_we := '1';
            end if;
          end if;

        when rbaddr_lnak =>
          irb_ack := '0';                   -- nak it
          if isbusy = '1' then              -- or do a delayed nak
            irb_ack  := irbena;
            irb_busy := irbena;
          end if;

        when others => null;
      end case;
    end if;

    -- rbus output driver
    --   send a '0101...' pattern when selected and busy or err
    --   send data only when busy=0 and err=0
    --   this extra logic allows to debug rlink state machine
    if r.rbsel = '1' then
      irb_dout := "0101010101010101";   -- drive this pattern when selected
      if RB_MREQ.re='1' and irb_busy='0' and irb_err='0' then
        case RB_MREQ.addr(2 downto 0) is
          when rbaddr_cntl =>
            irb_dout := (others=>'0');
            irb_dout(cntl_rbf_wchk)   := r.wchk;
            irb_dout(cntl_rbf_nbusy)  := r.nbusy;
          when rbaddr_stat =>
            irb_dout := (others=>'0');
            irb_dout(r.stat'range) := r.stat;
          when rbaddr_attn => null;
          when rbaddr_ncyc =>
            irb_dout := (others=>'0');
            irb_dout(r.cntcyc'range) := r.ncyc;
          when rbaddr_data | rbaddr_dinc =>
            irb_dout := r.data;
          when rbaddr_fifo =>
            if FIFO_EMPTY = '0' then
              irb_dout := FIFO_DO;
            end if;
          when rbaddr_lnak => null;
          when others => null;
        end case;
      end if;
    end if;

    -- init transactions
    if RB_MREQ.init='1' and RB_MREQ.addr=RB_ADDR then
      if RB_MREQ.din(init_rbf_cntl) = '1' then
        n.wchk   := '0';
        n.stat   := (others=>'0');
        n.nbusy  := (others=>'0');
      end if;
      if RB_MREQ.din(init_rbf_data) = '1' then
        n.data   := (others=>'0');
      end if;
      if RB_MREQ.din(init_rbf_fifo) = '1' then
        ififo_reset := '1';
      end if;
    end if;
    
    -- other transactions
    if irbena='0' and r.act_1='1' then
      n.ncyc := r.cntcyc;
    end if;
    n.act_1 := irbena;
    
    N_REGS <= n;

    FIFO_RE    <= ififo_re;
    FIFO_WE    <= ififo_we;
    FIFO_RESET <= ififo_reset;
      
    RB_SRES.dout <= irb_dout;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;

    RB_LAM  <= irblam;
    RB_STAT <= r.stat;
      
  end process proc_next;

end syn;
