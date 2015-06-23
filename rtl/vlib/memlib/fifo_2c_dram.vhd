-- $Id: fifo_2c_dram.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    fifo_2c_dram - syn
-- Description:    FIFO, two clock domain, distributed RAM based, with
--                 enable/busy/valid/hold interface.
--
-- Dependencies:   ram_1swar_1ar_gen
--                 genlib/gray_cnt_n
--                 genlib/gray2bin_gen
--
-- Test bench:     tb/tb_fifo_2c_dram
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-13   424   1.1    use capture+sync flops; reset now glitch free 
-- 2011-11-07   421   1.0.2  now numeric_std clean
-- 2007-12-28   107   1.0.1  VAL=0 in cycle after RESETR=1
-- 2007-12-28   106   1.0    Initial version
--
-- Some synthesis results:
-- - 2011-11-13 Rev 424: ise 13.1   for xc3s1000-ft256-4:
--   AWIDTH DWIDTH  LUT.l LUT.m LUT.s Flop Slice  CLKW    CLKR (xst est.)
--        4     16     41    32    12   38    54  135MHz  115MHz    ( 16 words)
--        5     16     65    64    14   40    80  113MHz  116MHz    ( 32 words)
-- - 2007-12-28 Rev 106: ise 8.2.03 for xc3s1000-ft256-4:
--   AWIDTH DWIDTH  LUT.l LUT.m  Flop   CLKW    CLKR (xst est.)
--        4     16     40    32    42   141MHz  165MHz    ( 16 words)
--        5     16     65    64    52   108MHz  108MHz    ( 32 words)
--        6     16     95   128    61   111MHz  113MHz    ( 64 words)
--        7     16    149   256    74   100MHz   96MHz    (128 words)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.genlib.all;
use work.memlib.all;

entity fifo_2c_dram is                  -- fifo, 2 clock, dram based
  generic (
    AWIDTH : positive :=  5;            -- address width (sets size)
    DWIDTH : positive := 16);           -- data width
  port (
    CLKW : in slbit;                    -- clock (write side)
    CLKR : in slbit;                    -- clock (read side)
    RESETW : in slbit;                  -- W|reset from write side
    RESETR : in slbit;                  -- R|reset from read side
    DI : in slv(DWIDTH-1 downto 0);     -- W|input data
    ENA : in slbit;                     -- W|write enable
    BUSY : out slbit;                   -- W|write port hold    
    DO : out slv(DWIDTH-1 downto 0);    -- R|output data
    VAL : out slbit;                    -- R|read valid
    HOLD : in slbit;                    -- R|read hold
    SIZEW : out slv(AWIDTH-1 downto 0); -- W|number slots to write
    SIZER : out slv(AWIDTH-1 downto 0)  -- R|number slots to read 
  );
end fifo_2c_dram;


architecture syn of fifo_2c_dram is

  type regw_type is record
    raddr_c : slv(AWIDTH-1 downto 0);   -- read address (capt from CLKR)
    raddr_s : slv(AWIDTH-1 downto 0);   -- read address (sync in CLKW)
    sizew : slv(AWIDTH-1 downto 0);     -- slots to write
    busy : slbit;                       -- busy flag
    rstw : slbit;                       -- resetw active
    rstw_sc : slbit;                    -- resetw (sync-capt from CLKR-CLKW)
    rstw_ss : slbit;                    -- resetw (sync-sync from CLKR-CLKW)
    rstr_c : slbit;                     -- resetr (capt from CLKR)
    rstr_s : slbit;                     -- resetr (sync from CLKR)
  end record regw_type;

  constant regw_init : regw_type := (
    slv(to_unsigned(0,AWIDTH)),         -- raddr_c
    slv(to_unsigned(0,AWIDTH)),         -- raddr_s
    slv(to_unsigned(0,AWIDTH)),         -- sizew
    '0',                                -- busy
    '0','0','0',                        -- rstw,rstw_sc,rstw_ss
    '0','0'                             -- rstr_c,rstr_s
  );

  type regr_type is record
    waddr_c : slv(AWIDTH-1 downto 0);   -- write address (capt from CLKW)
    waddr_s : slv(AWIDTH-1 downto 0);   -- write address (sync in CLKR)
    sizer : slv(AWIDTH-1 downto 0);     -- slots to read
    val : slbit;                        -- valid flag
    rstr : slbit;                       -- resetr active
    rstr_sc : slbit;                    -- resetr (sync-capt from CLKW-CLKR)
    rstr_ss : slbit;                    -- resetr (sync-sync from CLKW-CLKR)
    rstw_c : slbit;                     -- resetw (capt from CLKW)
    rstw_s : slbit;                     -- resetw (sync from CLKW)
  end record regr_type;

  constant regr_init : regr_type := (
    slv(to_unsigned(0,AWIDTH)),         -- waddr_c
    slv(to_unsigned(0,AWIDTH)),         -- waddr_s
    slv(to_unsigned(0,AWIDTH)),         -- sizer
    '0',                                -- val
    '0','0','0',                        -- rstr,rstr_sc,rstr_ss
    '0','0'                             -- rstw_c,rstw_s
  );

  signal R_REGW : regw_type := regw_init;  -- write side state registers
  signal N_REGW : regw_type := regw_init;  -- next values write side
  signal R_REGR : regr_type := regr_init;  -- read  side state registers
  signal N_REGR : regr_type := regr_init;  -- next values read  side

  signal WADDR : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal RADDR : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal WADDR_BIN : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal RADDR_BIN : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal WADDR_S_BIN : slv(AWIDTH-1 downto 0) := (others=>'0');
  signal RADDR_S_BIN : slv(AWIDTH-1 downto 0) := (others=>'0');

  signal GCW_RST : slbit := '0';
  signal GCW_CE : slbit := '0';
  signal GCR_RST : slbit := '0';
  signal GCR_CE : slbit := '0';

begin

  RAM : ram_1swar_1ar_gen               -- dual ported memory
    generic map (
      AWIDTH => AWIDTH,
      DWIDTH => DWIDTH)
    port map (
      CLK   => CLKW,
      WE    => GCW_CE,
      ADDRA => WADDR,
      ADDRB => RADDR,
      DI    => DI,
      DOA   => open,
      DOB   => DO
    );
  
  GCW : gray_cnt_gen                    -- gray counter for write address
    generic map (
      DWIDTH => AWIDTH)
    port map (
      CLK   => CLKW,
      RESET => GCW_RST,
      CE    => GCW_CE,
      DATA  => WADDR
    );
  
  GCR : gray_cnt_gen                    -- gray counter for read address
    generic map (
      DWIDTH => AWIDTH)
    port map (
      CLK   => CLKR,
      RESET => GCR_RST,
      CE    => GCR_CE,
      DATA  => RADDR
    );
  
  G2B_WW : gray2bin_gen                 -- gray->bin for waddr on write side
    generic map (DWIDTH => AWIDTH)
    port map (DI => WADDR, DO => WADDR_BIN);
  G2B_WR : gray2bin_gen                 -- gray->bin for waddr on read  side
    generic map (DWIDTH => AWIDTH)
    port map (DI => R_REGR.waddr_s, DO => WADDR_S_BIN);
  G2B_RW : gray2bin_gen                 -- gray->bin for raddr on write side
    generic map (DWIDTH => AWIDTH)
    port map (DI => RADDR, DO => RADDR_BIN);
  G2B_RR : gray2bin_gen                 -- gray->bin for raddr on read  side
    generic map (DWIDTH => AWIDTH)
    port map (DI => R_REGW.raddr_s, DO => RADDR_S_BIN);
 
  proc_regw: process (CLKW)
  begin
    if rising_edge(CLKW) then
      R_REGW <= N_REGW;
    end if;
  end process proc_regw;

  proc_nextw: process (R_REGW, RESETW, ENA, R_REGR,
                       RADDR, RADDR_S_BIN, WADDR_BIN)

    variable r : regw_type := regw_init;
    variable n : regw_type := regw_init;
    variable ibusy : slbit := '0';
    variable igcw_ce  : slbit := '0';
    variable igcw_rst : slbit := '0';
    variable isizew : slv(AWIDTH-1 downto 0) := (others=>'0');
  begin

    r := R_REGW;
    n := R_REGW;

    isizew := slv(unsigned(RADDR_S_BIN) + unsigned(not WADDR_BIN));
    ibusy  := '0';
    igcw_ce  := '0';
    igcw_rst := '0';

    if unsigned(isizew) = 0 then        -- if no free slots
      ibusy := '1';                       -- next cycle busy=1
    end if;

    if ENA='1' and r.busy='0' then      -- if ena=1 and this cycle busy=0
      igcw_ce := '1';                     -- write this value
      if unsigned(isizew) = 1 then        -- if this last free slot
        ibusy := '1';                       -- next cycle busy=1
      end if;
    end if;
        
    if RESETW = '1' then                -- reset(write side) request
      n.rstw := '1';                      -- set RSTW flag
    elsif r.rstw_ss = '1' then          -- request gone and return seen
      n.rstw := '0';                      -- clear RSTW flag
    end if;

    if r.rstw='1' and r.rstw_ss='1' then -- RSTW seen on write and read side
      igcw_rst := '1';                     -- clear write address counter
    end if;
    if r.rstr_s = '1' then              -- RSTR active
      igcw_rst := '1';                    -- clear write address counter
    end if;

    if RESETW='1' or r.rstw='1' or r.rstw_ss='1' or r.rstr_s='1'
    then             -- RESETW or RESETR active
      ibusy  := '1';                      -- signal write side busy
      isizew := (others=>'1');
    end if;

    n.busy  := ibusy;
    n.sizew := isizew;
    
    n.raddr_c := RADDR;                 -- data captuture from CLKR
    n.raddr_s := r.raddr_c;
    n.rstw_sc := R_REGR.rstw_s;
    n.rstw_ss := r.rstw_sc;
    n.rstr_c  := R_REGR.rstr;
    n.rstr_s  := r.rstr_c;

    N_REGW  <= n;

    GCW_CE  <= igcw_ce;
    GCW_RST <= igcw_rst;
    BUSY    <= r.busy;
    SIZEW   <= r.sizew;    

  end process proc_nextw;

  proc_regr: process (CLKR)
  begin
    if rising_edge(CLKR) then
      R_REGR <= N_REGR;
    end if;
  end process proc_regr;

  proc_nextr: process (R_REGR, RESETR, HOLD, R_REGW,
                       WADDR, WADDR_S_BIN, RADDR_BIN)

    variable r : regr_type := regr_init;
    variable n : regr_type := regr_init;
    variable ival : slbit := '0';
    variable igcr_ce  : slbit := '0';
    variable igcr_rst : slbit := '0';
    variable isizer : slv(AWIDTH-1 downto 0) := (others=>'0');
   
  begin

    r := R_REGR;
    n := R_REGR;

    isizer := slv(unsigned(WADDR_S_BIN) - unsigned(RADDR_BIN));
    ival  := '1';
    igcr_ce  := '0';
    igcr_rst := '0';

    if unsigned(isizer) = 0 then        -- if nothing to read
      ival := '0';                        -- next cycle val=0
    end if;

    if r.val='1' and HOLD='0' then      -- this cycle val=1 and no hold
      igcr_ce := '1';                     -- retire this value
      if unsigned(isizer) = 1  then       -- if this is last one
        ival := '0';                        -- next cycle val=0
      end if;
    end if;

    if RESETR = '1' then                -- reset(read side) request
      n.rstr := '1';                      -- set RSTR flag
    elsif r.rstr_ss = '1' then          -- request gone and return seen
      n.rstr := '0';                      -- clear RSTR flag
    end if;

    if r.rstr='1' and r.rstr_ss='1' then -- RSTR seen on read and write side
      igcr_rst := '1';                     -- clear read address counter
    end if;
    if r.rstw_s = '1' then              -- RSTW active
      igcr_rst := '1';                    -- clear read address counter
    end if;

    if RESETR='1' or r.rstr='1' or r.rstr_ss='1' or r.rstw_s='1'
    then                                -- RESETR or RESETW active 
      ival   := '0';                       -- signal read side empty
      isizer := (others=>'0');
    end if;
    
    n.val   := ival;
    n.sizer := isizer;

    n.waddr_c := WADDR;                 -- data captuture from CLKW
    n.waddr_s := r.waddr_c;
    n.rstr_sc := R_REGW.rstr_s;
    n.rstr_ss := r.rstr_sc;
    n.rstw_c  := R_REGW.rstw;
    n.rstw_s  := r.rstw_c;

    N_REGR <= n;

    GCR_CE  <= igcr_ce;
    GCR_RST <= igcr_rst;
    VAL     <= r.val;
    SIZER   <= r.sizer;

  end process proc_nextr;

end syn;
