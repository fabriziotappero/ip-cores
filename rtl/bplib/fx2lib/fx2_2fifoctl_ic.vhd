-- $Id: fx2_2fifoctl_ic.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2012-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    fx2_2fifoctl_ic - syn
-- Description:    Cypress EZ-USB FX2 driver (2 fifo; int clk)
--
-- Dependencies:   vlib/xlib/iob_reg_o
--                 vlib/xlib/iob_reg_i_gen
--                 vlib/xlib/iob_reg_o_gen
--                 vlib/xlib/iob_reg_io_gen
--                 memlib/fifo_2c_dram
--
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2013-01-04   469  13.3   O76x xc3s1200e-4  112  172   64  169 s  7.4/7.4
-- 2012-01-14   453  13.3   O76x xc3s1200e-4  101? 173   64  159 s  8.3/7.4
-- 2012-01-08   451  13.3   O76x xc3s1200e-4  110  166   64  163 s  7.5
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-01-04   469   1.2    BUGFIX: redo rx logic, now properly pipelined
-- 2012-01-15   453   1.1    use aempty/afull logic; collapse tx and pe flows
-- 2012-01-09   451   1.0    Initial version
-- 2012-01-01   448   0.5    First draft 
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.memlib.all;
use work.fx2lib.all;

entity fx2_2fifoctl_ic is               -- EZ-USB FX2 driver (2 fifo; int clk)
  generic (
    RXFAWIDTH : positive :=  5;         -- receive  fifo address width
    TXFAWIDTH : positive :=  5;         -- transmit fifo address width
    PETOWIDTH : positive :=  7;         -- packet end time-out counter width
    CCWIDTH :   positive :=  5;         -- chunk counter width
    RXAEMPTY_THRES : natural := 1;      -- threshold for rx aempty flag
    TXAFULL_THRES  : natural := 1);     -- threshold for tx afull flag
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RXDATA : out slv8;                  -- receive data out
    RXVAL : out slbit;                  -- receive data valid
    RXHOLD : in slbit;                  -- receive data hold
    RXAEMPTY : out slbit;               -- receive almost empty flag
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit;                 -- transmit data busy
    TXAFULL : out slbit;                -- transmit almost full flag
    MONI : out fx2ctl_moni_type;        -- monitor port data
    I_FX2_IFCLK : in slbit;             -- fx2: interface clock
    O_FX2_FIFO : out slv2;              -- fx2: fifo address
    I_FX2_FLAG : in slv4;               -- fx2: fifo flags
    O_FX2_SLRD_N : out slbit;           -- fx2: read enable    (act.low)
    O_FX2_SLWR_N : out slbit;           -- fx2: write enable   (act.low)
    O_FX2_SLOE_N : out slbit;           -- fx2: output enable  (act.low)
    O_FX2_PKTEND_N : out slbit;         -- fx2: packet end     (act.low)
    IO_FX2_DATA : inout slv8            -- fx2: data lines
  );
end fx2_2fifoctl_ic;


architecture syn of fx2_2fifoctl_ic is

  constant c_rxfifo : slv2 := c_fifo_ep4;
  constant c_txfifo : slv2 := c_fifo_ep6;

  constant c_flag_prog   : integer := 0;
  constant c_flag_tx_ff  : integer := 1;
  constant c_flag_rx_ef  : integer := 2;
  constant c_flag_tx2_ff : integer := 3;
  
  type state_type is (
    s_idle,                             -- s_idle: idle state
    s_rxprep0,                          -- s_rxprep0: switch to rx-fifo
    s_rxprep1,                          -- s_rxprep1: fifo addr setup
    s_rxprep2,                          -- s_rxprep2: wait for flags
    s_rxdisp,                           -- s_rxdisp: read, dispatch
    s_rxpipe,                           -- s_rxpipe: read, pipe wait
    s_txprep0,                          -- s_txprep0: switch to tx-fifo
    s_txprep1,                          -- s_txprep1: fifo addr setup
    s_txprep2,                          -- s_txprep2: wait for flags
    s_txdisp                            -- s_txdisp: write, dispatch
  );
  
  type regs_type is record
    state : state_type;                 -- state
    petocnt : slv(PETOWIDTH-1 downto 0);  -- pktend time out counter
    pepend : slbit;                     -- pktend pending
    rxpipe1 : slbit;                    -- read pipe 1: iob capture stage
    rxpipe2 : slbit;                    -- read pipe 2: fifo write stage
    ccnt : slv(CCWIDTH-1 downto 0);     -- chunk counter
    moni_ep4_sel : slbit;               -- ep4 (rx) select
    moni_ep6_sel : slbit;               -- ep6 (tx) select
    moni_ep4_pf : slbit;                -- ep4 (rx) prog flag
    moni_ep6_pf : slbit;                -- ep6 (tx) prog flag
  end record regs_type;

  constant petocnt_init : slv(PETOWIDTH-1 downto 0) := (others=>'0');
  constant ccnt_init : slv(CCWIDTH-1 downto 0) := (others=>'0');

  constant regs_init : regs_type := (
    s_idle,                             -- state
    petocnt_init,                       -- petocnt
    '0',                                -- pepend
    '0','0',                            -- rxpipe1, rxpipe2
    ccnt_init,                          -- ccnt
    '0','0',                            -- moni_ep(4|6)_sel
    '0','0'                             -- moni_ep(4|6)_pf
  );
    
  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal FX2_FIFO     : slv2 := (others=>'0');
  signal FX2_FIFO_CE  : slbit := '0';
  signal FX2_FLAG_N   : slv4 := (others=>'0');
  signal FX2_SLRD_N   : slbit := '1';
  signal FX2_SLWR_N   : slbit := '1';
  signal FX2_SLOE_N   : slbit := '1';
  signal FX2_PKTEND_N : slbit := '1';
  signal FX2_DATA_CEI : slbit := '0';
  signal FX2_DATA_CEO : slbit := '0';
  signal FX2_DATA_OE  : slbit := '0';

  signal RXFIFO_DI  : slv8 := (others=>'0');
  signal RXFIFO_ENA  : slbit := '0';
  signal RXFIFO_BUSY : slbit := '0';
  signal RXSIZE_FX2  : slv(RXFAWIDTH-1 downto 0) := (others=>'0');
  signal RXSIZE_USR  : slv(RXFAWIDTH-1 downto 0) := (others=>'0');
  signal TXFIFO_DO   : slv8 := (others=>'0');
  signal TXFIFO_VAL  : slbit := '0';
  signal TXFIFO_HOLD : slbit := '0';
  signal TXSIZE_FX2  : slv(TXFAWIDTH-1 downto 0) := (others=>'0');
  signal TXSIZE_USR  : slv(TXFAWIDTH-1 downto 0) := (others=>'0');

  signal TXBUSY_L : slbit := '0';

  signal R_MONI_C : fx2ctl_moni_type := fx2ctl_moni_init;
  signal R_MONI_S : fx2ctl_moni_type := fx2ctl_moni_init;

begin

  assert RXAEMPTY_THRES<=2**RXFAWIDTH-1 and
         TXAFULL_THRES<=2**TXFAWIDTH-1
    report "assert((RXAEMPTY|TXAFULL)_THRES <= 2**(RX|TX)FAWIDTH)-1"
    severity failure;


  IOB_FX2_FIFO : iob_reg_o_gen
    generic map (
      DWIDTH => 2,
      INIT   => '0')
    port map (
      CLK => I_FX2_IFCLK,
      CE  => FX2_FIFO_CE,
      DO  => FX2_FIFO,
      PAD => O_FX2_FIFO
    );
  
  IOB_FX2_FLAG : iob_reg_i_gen
    generic map (
      DWIDTH => 4,
      INIT   => '0')
    port map (
      CLK => I_FX2_IFCLK,
      CE  => '1',
      DI  => FX2_FLAG_N,
      PAD => I_FX2_FLAG
    );
  
  IOB_FX2_SLRD : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => I_FX2_IFCLK,
      CE  => '1',
      DO  => FX2_SLRD_N,
      PAD => O_FX2_SLRD_N
    );
  
  IOB_FX2_SLWR : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => I_FX2_IFCLK,
      CE  => '1',
      DO  => FX2_SLWR_N,
      PAD => O_FX2_SLWR_N
    );
  
  IOB_FX2_SLOE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => I_FX2_IFCLK,
      CE  => '1',
      DO  => FX2_SLOE_N,
      PAD => O_FX2_SLOE_N
    );
    
  IOB_FX2_PKTEND : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => I_FX2_IFCLK,
      CE  => '1',
      DO  => FX2_PKTEND_N,
      PAD => O_FX2_PKTEND_N
    );

  IOB_FX2_DATA : iob_reg_io_gen
    generic map (
      DWIDTH => 8,
      PULL   => "KEEP")
    port map (
      CLK => I_FX2_IFCLK,
      CEI => FX2_DATA_CEI,
      CEO => FX2_DATA_CEO,
      OE  => FX2_DATA_OE,
      DI  => RXFIFO_DI,                 -- input data   (read from pad)
      DO  => TXFIFO_DO,                 -- output data  (write  to pad)
      PAD => IO_FX2_DATA
    );

  RXFIFO : fifo_2c_dram                -- input fifo, 2 clock, dram based
    generic map (
      AWIDTH => RXFAWIDTH,
      DWIDTH => 8)
    port map (
      CLKW   => I_FX2_IFCLK,
      CLKR   => CLK,
      RESETW => '0',
      RESETR => RESET,
      DI     => RXFIFO_DI,
      ENA    => RXFIFO_ENA,
      BUSY   => RXFIFO_BUSY,
      DO     => RXDATA,
      VAL    => RXVAL,
      HOLD   => RXHOLD,
      SIZEW  => RXSIZE_FX2,
      SIZER  => RXSIZE_USR
    );

  TXFIFO : fifo_2c_dram                -- output fifo, 2 clock, dram based
    generic map (
      AWIDTH => TXFAWIDTH,
      DWIDTH => 8)
    port map (
      CLKW   => CLK,
      CLKR   => I_FX2_IFCLK,
      RESETW => RESET,
      RESETR => '0',
      DI     => TXDATA,
      ENA    => TXENA,
      BUSY   => TXBUSY_L,
      DO     => TXFIFO_DO,
      VAL    => TXFIFO_VAL,
      HOLD   => TXFIFO_HOLD,
      SIZEW  => TXSIZE_USR,
      SIZER  => TXSIZE_FX2
    );
 
  proc_regs: process (I_FX2_IFCLK)
  begin

    if rising_edge(I_FX2_IFCLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, 
                      FX2_FLAG_N, TXFIFO_VAL, RXSIZE_FX2,
                      RXFIFO_BUSY, TXBUSY_L)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable ififo_ce : slbit := '0';
    variable ififo    : slv2 := "00";

    variable irxfifo_ena  : slbit := '0';
    variable itxfifo_hold : slbit := '0';

    variable islrd   : slbit := '0';
    variable islwr   : slbit := '0';
    variable isloe   : slbit := '0';
    variable ipktend : slbit := '0';

    variable idata_cei : slbit := '0';
    variable idata_ceo : slbit := '0';
    variable idata_oe  : slbit := '0';

    variable slrxok : slbit := '0';
    variable sltxok : slbit := '0';
    variable pipeok : slbit := '0';

    variable cc_clr : slbit := '0';
    variable cc_cnt : slbit := '0';
    variable cc_done : slbit := '0';
         
  begin

    r := R_REGS;
    n := R_REGS;

    ififo_ce := '0';
    ififo    := "00";

    irxfifo_ena  := '0';
    itxfifo_hold := '1';
  
    islrd   := '0';
    islwr   := '0';
    isloe   := '0';
    ipktend := '0';

    idata_cei := '0';
    idata_ceo := '0';
    idata_oe  := '0';

    slrxok := FX2_FLAG_N(c_flag_rx_ef); -- empty flag is act.low!
    sltxok := FX2_FLAG_N(c_flag_tx_ff); --  full flag is act.low!
    pipeok := FX2_FLAG_N(c_flag_prog);  -- almost flag is act.low!

    cc_clr := '0';
    cc_cnt := '0';
    if unsigned(r.ccnt) = 0  then
      cc_done := '1';
    else
      cc_done := '0';
    end if;

    n.rxpipe1  := '0';
    
    case r.state is
      when s_idle =>                    -- s_idle:
        if slrxok='1' and RXFIFO_BUSY='0' then
          ififo_ce := '1';
          ififo    := c_rxfifo;
          n.state := s_rxprep1;
        elsif sltxok='1' and (TXFIFO_VAL='1' or r.pepend='1')then
          ififo_ce := '1';
          ififo    := c_txfifo;
          n.state := s_txprep1;          
        end if;

      when s_rxprep0 =>                 -- s_rxprep0: switch to rx-fifo
        ififo_ce := '1';
        ififo    := c_rxfifo;
        n.state := s_rxprep1;

      when s_rxprep1 =>                 -- s_rxprep1: fifo addr setup
        cc_clr  := '1';
        n.state := s_rxprep2;

      when s_rxprep2 =>                 -- s_rxprep2: wait for flags
        isloe   := '1';
        n.state := s_rxdisp;

      when s_rxdisp =>                  -- s_rxdisp: read, dispatch
        isloe := '1';
        -- if chunk done and tx or pe pending and possible
        if cc_done='1' and sltxok='1' and (TXFIFO_VAL='1' or r.pepend='1') then
          if r.rxpipe1='1' or r.rxpipe2='1' then -- rx pipe busy ?
            n.state := s_rxdisp;            -- wait
          else
            n.state := s_txprep0;           -- otherwise switch to tx flow
          end if;
        -- if more rx to do and possible
        elsif slrxok='1' and unsigned(RXSIZE_FX2)>3 then  -- !thres must be >3!
          islrd := '1';
          cc_cnt := '1';
          n.rxpipe1 := '1';
          if pipeok='1' then
            n.state := s_rxdisp;             -- 1 cycle read
            --n.state := s_rxprep2;            -- 2 cycle read
          else
            n.state := s_rxpipe;
          end if;
        -- otherwise back to idle
        else
          if r.rxpipe1='1' or r.rxpipe2='1' then -- rx pipe busy ?
            n.state := s_rxdisp;            -- wait
          else
            n.state := s_idle;              -- to idle
          end if;
        end if;

      when s_rxpipe =>                  -- s_rxpipe:  read, pipe wait
        isloe := '1';
        n.state := s_rxprep2;
        
      when s_txprep0 =>                 -- s_txprep0: switch to tx-fifo
        ififo_ce := '1';
        ififo    := c_txfifo;
        n.state := s_txprep1;

      when s_txprep1 =>                 -- s_txprep1: fifo addr setup
        cc_clr  := '1';
        n.state := s_txprep2;

      when s_txprep2 =>                 -- s_txprep2: wait for flags
        n.state := s_txdisp;

      when s_txdisp =>                  -- s_txdisp: write, dispatch
        -- if chunk done and rx pending and possible
        if cc_done='1' and slrxok='1' and RXFIFO_BUSY='0' then
          n.state := s_rxprep0;
        -- if pktend to do and possible
        elsif sltxok = '1' and r.pepend = '1' then
          ipktend  := '1';
          n.pepend := '0';
          n.state := s_idle;
        -- if more tx to do and possible
        elsif sltxok = '1' and TXFIFO_VAL = '1' then
          cc_cnt := '1';                  -- inc chunk count
          n.pepend := '0';                -- cancel pe (avoid back-2-back tx+pe)
          itxfifo_hold := '0';
          idata_ceo := '1';
          idata_oe  := '1';
          islwr     := '1';
          if pipeok = '1' then           -- if not almost full
            n.state   := s_txdisp;          -- stream 
          else
            n.state   := s_txprep1;         -- wait for full flag
          end if;
        -- otherwise back to idle
        else
          n.state := s_idle;
        end if;
        
      when others => null;
    end case;

    -- rx pipe handling
    idata_cei   := r.rxpipe1;
    n.rxpipe2   := r.rxpipe1;
    irxfifo_ena := r.rxpipe2;
    
    -- chunk counter handling
    if cc_clr = '1' then
      n.ccnt := (others=>'1');
    elsif cc_cnt='1' and unsigned(r.ccnt) > 0 then
      n.ccnt := slv(unsigned(r.ccnt) - 1);
    end if;
    
    -- pktend time-out handling:
    --   if tx fifo is non-empty, set counter to max
    --   if tx fifo is empty, count down every usec
    --   on 1->0 transition queue pktend request
    if TXFIFO_VAL = '1' then
      n.petocnt := (others=>'1');
    else
      if unsigned(r.petocnt) /= 0 then
        n.petocnt := slv(unsigned(r.petocnt) - 1);
        if unsigned(r.petocnt) = 1 then
          n.pepend := '1';
        end if;
      end if;
    end if;

    n.moni_ep4_sel := '0';
    n.moni_ep6_sel := '0';
    if r.state = s_rxdisp or r.state = s_rxpipe then
      n.moni_ep4_sel := '1';
      n.moni_ep4_pf  := not FX2_FLAG_N(c_flag_prog);
    elsif r.state = s_txdisp then
      n.moni_ep6_sel := '1';
      n.moni_ep6_pf  := not FX2_FLAG_N(c_flag_prog);
    end if;

    N_REGS <= n;

    FX2_FIFO_CE  <= ififo_ce;
    FX2_FIFO     <= ififo;

    FX2_SLRD_N   <= not islrd;
    FX2_SLWR_N   <= not islwr;
    FX2_SLOE_N   <= not isloe;
    FX2_PKTEND_N <= not ipktend;

    FX2_DATA_CEI <= idata_cei;
    FX2_DATA_CEO <= idata_ceo;
    FX2_DATA_OE  <= idata_oe;

    RXFIFO_ENA   <= irxfifo_ena;
    TXFIFO_HOLD  <= itxfifo_hold;
    
  end process proc_next;

  proc_moni: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_MONI_C <= fx2ctl_moni_init;
        R_MONI_S <= fx2ctl_moni_init;
      else
        R_MONI_C <= fx2ctl_moni_init;
        R_MONI_C.fifo_ep4        <= R_REGS.moni_ep4_sel;
        R_MONI_C.fifo_ep6        <= R_REGS.moni_ep6_sel;
        R_MONI_C.flag_ep4_empty  <= not FX2_FLAG_N(c_flag_rx_ef);
        R_MONI_C.flag_ep4_almost <= R_REGS.moni_ep4_pf;
        R_MONI_C.flag_ep6_full   <= not FX2_FLAG_N(c_flag_tx_ff);
        R_MONI_C.flag_ep6_almost <= R_REGS.moni_ep6_pf;
        R_MONI_C.slrd            <= not FX2_SLRD_N;
        R_MONI_C.slwr            <= not FX2_SLWR_N;
        R_MONI_C.pktend          <= not FX2_PKTEND_N;
        R_MONI_S <= R_MONI_C;
      end if;
    end if;

  end process proc_moni;

  proc_almost: process (RXSIZE_USR, TXSIZE_USR)
  begin

    -- rxsize_usr is the number of bytes to read
    -- txsize_usr is the number of bytes to write
    
    if unsigned(RXSIZE_USR) <= RXAEMPTY_THRES then
      RXAEMPTY <= '1';
    else
      RXAEMPTY <= '0';
    end if;

    if unsigned(TXSIZE_USR) <= TXAFULL_THRES then
      TXAFULL <= '1';
    else
      TXAFULL <= '0';
    end if;

  end process proc_almost;

  TXBUSY <= TXBUSY_L;

  MONI <= R_MONI_S;
  
end syn;
