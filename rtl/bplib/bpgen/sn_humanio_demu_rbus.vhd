-- $Id: sn_humanio_demu_rbus.vhd 637 2015-01-25 18:36:40Z mueller $
--
-- Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sn_humanio_demu_rbus - syn
-- Description:    sn_humanio_demu with rbus interceptor
--
-- Dependencies:   bpgen/sn_humanio_demu
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.3-14.7; ghdl 0.0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2013-01-06   472 13.3   O76xd xc3s1000-4   160  136    0  124 s  6.1 ns 
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-08-15   583   1.1    rb_mreq addr now 16 bit
-- 2013-01-06   472   1.0    Initial version (cloned from sn_humanio_rbus
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Address   Bits Name        r/w/f  Function
-- bbbbbb00       cntl        r/w/-  Control register and BTN access
--           x:08   btn       r/w/-    r: return hio BTN status
--                                     w: ored with hio BTN to drive BTN
--              3   dsp_en    r/w/-    if 1 display data will be driven by rbus
--              2   dp_en     r/w/-    if 1 display dp's will be driven by rbus
--              1   led_en    r/w/-    if 1 LED will be driven by rri
--              0   swi_en    r/w/-    if 1 SWI will be driven by rri
--
-- bbbbbb01  7:00   swi       r/w/-    r: return hio SWI status
--                                     w: will drive SWI when swi_en=1
--
-- bbbbbb10         led       r/w/-  Interface to LED and DSP_DP
--          15:12     dp      r/w/-    r: returns DSP_DP status
--                                     w: will drive display dp's when dp_en=1
--           7:00     led     r/w/-    r: returns LED status
--                                     w: will drive led's when led_en=1
--
-- bbbbbb11 15:00   dsp       r/w/-    r: return hio DSP_DAT status
--                                     w: will drive DSP_DAT when dsp_en=1
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.bpgenlib.all;

-- ----------------------------------------------------------------------------

entity sn_humanio_demu_rbus is          -- human i/o swi,btn,led only /w rbus
  generic (
    DEBOUNCE : boolean := true;         -- instantiate debouncer for SWI,BTN
    RB_ADDR : slv16 := slv(to_unsigned(16#fef0#,16)));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SWI : out slv8;                     -- switch settings, debounced
    BTN : out slv4;                     -- button settings, debounced
    LED : in slv8;                      -- led data
    DSP_DAT : in slv16;                 -- display data
    DSP_DP : in slv4;                   -- display decimal points
    I_SWI : in slv8;                    -- pad-i: switches
    I_BTN : in slv6;                    -- pad-i: buttons
    O_LED : out slv8                    -- pad-o: leds
  );
end sn_humanio_demu_rbus;

architecture syn of sn_humanio_demu_rbus is

  type regs_type is record
    rbsel : slbit;                      -- rbus select
    swi : slv8;                         -- rbus swi
    btn : slv4;                         -- rbus btn
    led : slv8;                         -- rbus led
    dsp_dat : slv16;                    -- rbus dsp_dat
    dsp_dp  : slv4;                     -- rbus dsp_dp
    ledin : slv8;                       -- led from design
    swieff : slv8;                      -- effective swi
    btneff : slv4;                      -- effective btn
    ledeff : slv8;                      -- effective led
    dpeff : slv4;                       -- effective dsp_dp
    dateff : slv16;                     -- effective dsp_dat
    swi_en : slbit;                     -- enable: swi from rbus
    led_en : slbit;                     -- enable: led from rbus
    dsp_en : slbit;                     -- enable: dsp_dat from rbus
    dp_en : slbit;                      -- enable: dsp_dp  from rbus
  end record regs_type;

  constant regs_init : regs_type := (
    '0',                                -- rbsel
    (others=>'0'),                      -- swi
    (others=>'0'),                      -- btn
    (others=>'0'),                      -- led
    (others=>'0'),                      -- dsp_dat
    (others=>'0'),                      -- dsp_dp
    (others=>'0'),                      -- ledin
    (others=>'0'),                      -- swieff
    (others=>'0'),                      -- btneff
    (others=>'0'),                      -- ledeff
    (others=>'0'),                      -- dpeff
    (others=>'0'),                      -- dateff
    '0','0','0','0'                     -- (swi|led|dsp|dp)_en
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  subtype  cntl_rbf_btn      is integer range 11 downto 8;
  constant cntl_rbf_dsp_en:  integer :=  3;
  constant cntl_rbf_dp_en:   integer :=  2;
  constant cntl_rbf_led_en:  integer :=  1;
  constant cntl_rbf_swi_en:  integer :=  0;
  subtype  led_rbf_dp      is integer range 15 downto 12;
  subtype  led_rbf_led     is integer range  7 downto  0;

  constant rbaddr_cntl:  slv2 := "00";  --  0    r/w/-
  constant rbaddr_swi:   slv2 := "01";  --  1    r/w/-
  constant rbaddr_led:   slv2 := "10";  --  2    r/w/-
  constant rbaddr_dsp:   slv2 := "11";  --  3    r/w/-

  signal HIO_SWI : slv8 := (others=>'0');
  signal HIO_BTN : slv4 := (others=>'0');
  signal HIO_LED : slv8 := (others=>'0');
  signal HIO_DSP_DAT : slv16 := (others=>'0');
  signal HIO_DSP_DP  : slv4 := (others=>'0');

begin

  HIO : sn_humanio_demu
    generic map (
      DEBOUNCE => DEBOUNCE)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => HIO_SWI,                   
      BTN     => HIO_BTN,                   
      LED     => HIO_LED,                   
      DSP_DAT => HIO_DSP_DAT,               
      DSP_DP  => HIO_DSP_DP,
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED
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
  
  proc_next: process (R_REGS, RB_MREQ, LED, DSP_DAT, DSP_DP,
                      HIO_SWI, HIO_BTN, HIO_DSP_DAT, HIO_DSP_DP)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irbena   : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');

    irbena  := RB_MREQ.re or RB_MREQ.we;

    -- input register for LED signal
    n.ledin  := LED;

    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(15 downto 2)=RB_ADDR(15 downto 2) then
      n.rbsel := '1';
    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      irb_ack := irbena;                  -- ack all accesses

      case RB_MREQ.addr(1 downto 0) is

        when rbaddr_cntl =>
          irb_dout(cntl_rbf_btn)    := HIO_BTN;
          irb_dout(cntl_rbf_dsp_en) := r.dsp_en;
          irb_dout(cntl_rbf_dp_en)  := r.dp_en;
          irb_dout(cntl_rbf_led_en) := r.led_en;
          irb_dout(cntl_rbf_swi_en) := r.swi_en;
          if RB_MREQ.we = '1' then
            n.btn    := RB_MREQ.din(cntl_rbf_btn);
            n.dsp_en := RB_MREQ.din(cntl_rbf_dsp_en);
            n.dp_en  := RB_MREQ.din(cntl_rbf_dp_en);
            n.led_en := RB_MREQ.din(cntl_rbf_led_en);
            n.swi_en := RB_MREQ.din(cntl_rbf_swi_en);
          end if;
          
        when rbaddr_swi =>
          irb_dout(HIO_SWI'range) := HIO_SWI;
          if RB_MREQ.we = '1' then
            n.swi := RB_MREQ.din(n.swi'range);
          end if;
          
        when rbaddr_led =>
          irb_dout(led_rbf_dp)  := HIO_DSP_DP;
          irb_dout(led_rbf_led) := r.ledin;
          if RB_MREQ.we = '1' then
            n.dsp_dp := RB_MREQ.din(led_rbf_dp);
            n.led    := RB_MREQ.din(led_rbf_led);
          end if;
          
        when rbaddr_dsp =>
          irb_dout := HIO_DSP_DAT;
          if RB_MREQ.we = '1' then
            n.dsp_dat := RB_MREQ.din;
          end if;

        when others => null;
      end case;

    end if;

    n.btneff := HIO_BTN or r.btn;
    
    if r.swi_en = '0' then
      n.swieff := HIO_SWI;
    else
      n.swieff := r.swi;
    end if;

    if r.led_en = '0' then
      n.ledeff := r.ledin;
    else
      n.ledeff := r.led;
    end if;
    
    if r.dp_en = '0' then
      n.dpeff  := DSP_DP;
    else
      n.dpeff  := r.dsp_dp;
    end if;
    
    if r.dsp_en = '0' then
      n.dateff := DSP_DAT;
    else
      n.dateff := r.dsp_dat;
    end if;
    
    N_REGS       <= n;

    BTN         <= R_REGS.btneff;
    SWI         <= R_REGS.swieff;
    HIO_LED     <= R_REGS.ledeff;
    HIO_DSP_DP  <= R_REGS.dpeff;
    HIO_DSP_DAT <= R_REGS.dateff;
  
    RB_SRES      <= rb_sres_init;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.busy <= irb_busy;
    RB_SRES.err  <= irb_err;
    RB_SRES.dout <= irb_dout;

  end process proc_next;

end syn;
