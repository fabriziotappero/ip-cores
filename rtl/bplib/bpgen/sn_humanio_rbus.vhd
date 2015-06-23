-- $Id: sn_humanio_rbus.vhd 640 2015-02-01 09:56:53Z mueller $
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
-- Module Name:    sn_humanio_rbus - syn
-- Description:    sn_humanio with rbus interceptor
--
-- Dependencies:   bpgen/sn_humanio
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 11.4-14.7; viv 2014.4; ghdl 0.26-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-01-28   639 14.7  131013 xc6slx16-2   253  223    0   97 s  3.6 ns (n4)
-- 2015-01-28   639 14.7  131013 xc6slx16-2   141  120    0   42 s  3.5 ns (n2)
-- 2015-01-25   583 14.7  131013 xc6slx16-2   140  120    0   46 s  3.5 ns
-- 2011-08-14   406 12.1    M53d xc3s1000-4   142  156    0  123 s  5.1 ns 
-- 2011-08-07   404 12.1    M53d xc3s1000-4   142  157    0  124 s  5.1 ns 
-- 2010-12-29   351 12.1    M53d xc3s1000-4    93  138    0  111 s  6.8 ns 
-- 2010-06-03   300 11.4    L68  xc3s1000-4    92  137    0  111 s  6.7 ns 
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-01-31   640   2.0    add SWIDTH,LWIDTH,DCWIDTH, change register layout
-- 2014-08-15   583   1.3    rb_mreq addr now 16 bit
-- 2011-11-19   427   1.2.1  now numeric_std clean
-- 2011-08-14   406   1.2    common register layout with bp_swibtnled_rbus
-- 2011-08-07   404   1.3    add pipeline regs ledin,(swi,btn,led,dp,dat)eff
-- 2011-07-08   390   1.2    renamed from s3_humanio_rbus, add BWIDTH generic
-- 2010-12-29   351   1.1    renamed from s3_humanio_rri; ported to rbv3
-- 2010-06-18   306   1.0.1  rename rbus data fields to _rbf_
-- 2010-06-03   300   1.0    Initial version
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Addr   Bits  Name        r/w/f  Function
--  000         stat        r/-/-  Status register
--        14:12   hdig      r/-/-    display size as (2**DCWIDTH)-1
--        11:08   hled      r/-/-    led     size as LWIDTH-1
--         7:04   hbtn      r/-/-    button  size as BWIDTH-1
--         3:00   hswi      r/-/-    switch  size as SWIDTH-1
--         
--  001         cntl        r/w/-  Control register
--            4   dsp1_en   r/w/-    if 1 display msb will be driven by rbus
--            3   dsp0_en   r/w/-    if 1 display lsb will be driven by rbus
--            2   dp_en     r/w/-    if 1 display dp's will be driven by rbus
--            1   led_en    r/w/-    if 1 LED will be driven by rbus
--            0   swi_en    r/w/-    if 1 SWI will be driven by rbus
--            
--  010    x:00 btn         r/-/f    r: return hio BTN status
--                                   w: will pulse BTN
--                                   
--  011    x:00 swi         r/w/-    r: return hio SWI status
--                                   w: will drive SWI when swi_en=1
--                                   
--  100    x:00 led         r/w/-    r: return hio LED status
--                                   w: will drive LED when led_en=1
--                                   
--  101    x:00 dp          r/w/-    r: return hio DSP_DP status
--                                   w: will drive dp's when dp_en=1
--                                   
--  110   15:00 dsp0        r/w/-    r: return hio DSP_DAT lsb status
--                                   w: will drive DSP_DAT lsb when dsp_en=1
--  111   15:00 dsp1        r/w/-    r: return hio DSP_DAT msb status
--                                   w: will drive DSP_DAT msb when dsp_en=1
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.bpgenlib.all;

-- ----------------------------------------------------------------------------

entity sn_humanio_rbus is               -- human i/o handling /w rbus intercept
  generic (
    SWIDTH : positive := 8;             -- SWI port width
    BWIDTH : positive := 4;             -- BTN port width
    LWIDTH : positive := 8;             -- LED port width
    DCWIDTH : positive := 2;            -- digit counter width (2 or 3)
    DEBOUNCE : boolean := true;         -- instantiate debouncer for SWI,BTN
    RB_ADDR : slv16 := slv(to_unsigned(16#fef0#,16)));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    CE_MSEC : in slbit;                 -- 1 ms clock enable
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    SWI : out slv(SWIDTH-1 downto 0);   -- switch settings, debounced
    BTN : out slv(BWIDTH-1 downto 0);   -- button settings, debounced
    LED : in slv(LWIDTH-1 downto 0);    -- led data
    DSP_DAT : in slv(4*(2**DCWIDTH)-1 downto 0);   -- display data
    DSP_DP : in slv((2**DCWIDTH)-1 downto 0);      -- display decimal points
    I_SWI : in slv(SWIDTH-1 downto 0);  -- pad-i: switches
    I_BTN : in slv(BWIDTH-1 downto 0);  -- pad-i: buttons
    O_LED : out slv(LWIDTH-1 downto 0); -- pad-o: leds
    O_ANO_N : out slv((2**DCWIDTH)-1 downto 0); -- pad-o: disp: anodes (act.low)
    O_SEG_N : out slv8                         -- pad-o: disp: segments (act.low)
  );
end sn_humanio_rbus;

architecture syn of sn_humanio_rbus is
  
  type regs_type is record
    rbsel : slbit;                      -- rbus select
    swi : slv(SWIDTH-1 downto 0);       -- rbus swi
    btn : slv(BWIDTH-1 downto 0);       -- rbus btn
    led : slv(LWIDTH-1 downto 0);        -- rbus led
    dsp_dat : slv(4*(2**DCWIDTH)-1 downto 0); -- rbus dsp_dat
    dsp_dp  : slv((2**DCWIDTH)-1 downto 0);   -- rbus dsp_dp
    ledin : slv(LWIDTH-1 downto 0);     -- led from design
    swieff : slv(SWIDTH-1 downto 0);    -- effective swi
    btneff : slv(BWIDTH-1 downto 0);    -- effective btn
    ledeff : slv(LWIDTH-1 downto 0);    -- effective led
    dateff : slv(4*(2**DCWIDTH)-1 downto 0);  -- effective dsp_dat
    dpeff : slv((2**DCWIDTH)-1 downto 0);     -- effective dsp_dp
    swi_en : slbit;                     -- enable: swi from rbus
    led_en : slbit;                     -- enable: led from rbus
    dsp0_en : slbit;                    -- enable: dsp_dat lsb from rbus
    dsp1_en : slbit;                    -- enable: dsp_dat msb from rbus
    dp_en : slbit;                      -- enable: dsp_dp  from rbus
  end record regs_type;

  constant swizero : slv(SWIDTH-1 downto 0) := (others=>'0');
  constant btnzero : slv(BWIDTH-1 downto 0) := (others=>'0');
  constant ledzero : slv(LWIDTH-1 downto 0) := (others=>'0');
  constant dpzero  : slv((2**DCWIDTH)-1 downto 0) := (others=>'0');
  constant datzero : slv(4*(2**DCWIDTH)-1 downto 0) := (others=>'0');

  constant regs_init : regs_type := (
    '0',                                -- rbsel
    swizero,                            -- swi
    btnzero,                            -- btn
    ledzero,                            -- led
    datzero,                            -- dsp_dat
    dpzero,                             -- dsp_dp
    ledzero,                            -- ledin
    swizero,                            -- swieff
    btnzero,                            -- btneff
    ledzero,                            -- ledeff
    datzero,                            -- dateff
    dpzero,                             -- dpeff
    '0','0','0','0','0'                 -- (swi|led|dsp0|dsp1|dp)_en
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  subtype  stat_rbf_hdig     is integer range 14 downto 12;
  subtype  stat_rbf_hled     is integer range 11 downto  8;
  subtype  stat_rbf_hbtn     is integer range  7 downto  4;
  subtype  stat_rbf_hswi     is integer range  3 downto  0;

  constant cntl_rbf_dsp1_en: integer :=  4;
  constant cntl_rbf_dsp0_en: integer :=  3;
  constant cntl_rbf_dp_en:   integer :=  2;
  constant cntl_rbf_led_en:  integer :=  1;
  constant cntl_rbf_swi_en:  integer :=  0;

  constant rbaddr_stat:  slv3 := "000";  --  0    r/-/-
  constant rbaddr_cntl:  slv3 := "001";  --  0    r/w/-
  constant rbaddr_btn:   slv3 := "010";  --  1    r/-/f
  constant rbaddr_swi:   slv3 := "011";  --  1    r/w/-
  constant rbaddr_led:   slv3 := "100";  --  2    r/w/-
  constant rbaddr_dp:    slv3 := "101";  --  3    r/w/-
  constant rbaddr_dsp0:  slv3 := "110";  --  4    r/w/-
  constant rbaddr_dsp1:  slv3 := "111";  --  5    r/w/-

  subtype  dspdat_msb is integer range 4*(2**DCWIDTH)-1 downto 4*(2**DCWIDTH)-16;
  subtype  dspdat_lsb is integer range 15 downto 0;
  
  signal HIO_SWI : slv(SWIDTH-1 downto  0) := (others=>'0');
  signal HIO_BTN : slv(BWIDTH-1 downto  0) := (others=>'0');
  signal HIO_LED : slv(LWIDTH-1 downto  0) := (others=>'0');
  signal HIO_DSP_DAT : slv(4*(2**DCWIDTH)-1 downto 0) := (others=>'0');
  signal HIO_DSP_DP  : slv((2**DCWIDTH)-1 downto 0)   := (others=>'0');

begin

  assert SWIDTH<=16 
    report "assert (SWIDTH<=16)"
    severity failure;
  assert BWIDTH<=8
    report "assert (BWIDTH<=8)"
    severity failure;
  assert LWIDTH<=16
    report "assert (LWIDTH<=16)"
    severity failure;

  assert DCWIDTH=2 or DCWIDTH=3
  report "assert(DCWIDTH=2 or DCWIDTH=3): unsupported DCWIDTH"
  severity FAILURE;

  HIO : sn_humanio
    generic map (
      SWIDTH   => SWIDTH,
      BWIDTH   => BWIDTH,
      LWIDTH   => LWIDTH,
      DCWIDTH  => DCWIDTH,
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
      O_LED   => O_LED,
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
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
    if RB_MREQ.aval='1' and RB_MREQ.addr(15 downto 3)=RB_ADDR(15 downto 3) then
      n.rbsel := '1';
    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      irb_ack := irbena;                  -- ack all accesses

      case RB_MREQ.addr(2 downto 0) is
        
        when rbaddr_stat =>
          irb_dout(stat_rbf_hdig)  := slv(to_unsigned((2**DCWIDTH)-1,3));
          irb_dout(stat_rbf_hled)  := slv(to_unsigned(LWIDTH-1,4));
          irb_dout(stat_rbf_hbtn)  := slv(to_unsigned(BWIDTH-1,4));
          irb_dout(stat_rbf_hswi)  := slv(to_unsigned(SWIDTH-1,4));
          if RB_MREQ.we = '1' then
            irb_ack := '0';
          end if;
          
        when rbaddr_cntl =>
          irb_dout(cntl_rbf_dsp1_en) := r.dsp1_en;
          irb_dout(cntl_rbf_dsp0_en) := r.dsp0_en;
          irb_dout(cntl_rbf_dp_en)   := r.dp_en;
          irb_dout(cntl_rbf_led_en)  := r.led_en;
          irb_dout(cntl_rbf_swi_en)  := r.swi_en;
          if RB_MREQ.we = '1' then
            n.dsp1_en := RB_MREQ.din(cntl_rbf_dsp1_en);
            n.dsp0_en := RB_MREQ.din(cntl_rbf_dsp0_en);
            n.dp_en   := RB_MREQ.din(cntl_rbf_dp_en);
            n.led_en  := RB_MREQ.din(cntl_rbf_led_en);
            n.swi_en  := RB_MREQ.din(cntl_rbf_swi_en);
          end if;
          
        when rbaddr_btn =>
          irb_dout(HIO_BTN'range) := HIO_BTN;
          if RB_MREQ.we = '1' then
            n.btn    := RB_MREQ.din(n.btn'range);
          end if;
          
        when rbaddr_swi =>
          irb_dout(HIO_SWI'range) := HIO_SWI;
          if RB_MREQ.we = '1' then
            n.swi := RB_MREQ.din(n.swi'range);
          end if;
          
        when rbaddr_led =>
          irb_dout(r.ledin'range) := r.ledin;
          if RB_MREQ.we = '1' then
            n.led := RB_MREQ.din(n.led'range);
          end if;
          
        when rbaddr_dp =>
          irb_dout(HIO_DSP_DP'range) := HIO_DSP_DP;
          if RB_MREQ.we = '1' then
            n.dsp_dp := RB_MREQ.din(n.dsp_dp'range);
          end if;
          
        when rbaddr_dsp0 =>
          irb_dout := HIO_DSP_DAT(dspdat_lsb);
          if RB_MREQ.we = '1' then
            n.dsp_dat(dspdat_lsb) := RB_MREQ.din;
          end if;

        when rbaddr_dsp1 =>
          irb_dout := HIO_DSP_DAT(dspdat_msb);
          if RB_MREQ.we = '1' then
            n.dsp_dat(dspdat_msb) := RB_MREQ.din;
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
    
    if r.dsp0_en = '0' then
      n.dateff(dspdat_lsb) := DSP_DAT(dspdat_lsb);
    else
      n.dateff(dspdat_lsb) := r.dsp_dat(dspdat_lsb);
    end if;
    
    if DCWIDTH=3 then
      if r.dsp1_en = '0' then
        n.dateff(dspdat_msb) := DSP_DAT(dspdat_msb);
      else
        n.dateff(dspdat_msb) := r.dsp_dat(dspdat_msb);
      end if;
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
