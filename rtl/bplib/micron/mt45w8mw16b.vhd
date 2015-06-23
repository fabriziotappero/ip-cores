-- $Id: mt45w8mw16b.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    mt45w8mw16b - sim
-- Description:    Micron MT45W8MW16B CellularRAM model
--                 Currently a much simplified model
--                 - only async accesses
--                 - ignores CLK and CRE
--                 - simple model for response of DATA lines, but no
--                   check for timing violations of control lines
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 11.4-14.7; ghdl 0.26-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-19   427   1.3.2  now numeric_std clean
-- 2010-06-03   299   1.3.1  improved timing model (WE cycle, robust T_apa)
-- 2010-06-03   298   1.3    add timing model again
-- 2010-05-28   295   1.2    drop timing (was incorrect), pure functional now
-- 2010-05-21   293   1.1    add BCR (only read of default so far)
-- 2010-05-16   291   1.0    Initial version (inspired by is61lv25616al)
------------------------------------------------------------------------------
-- Truth table accoring to data sheet:
--  
-- Asynchronous Mode (BCR(15)=1)
--   Operation               CLK ADV_N CE_N OE_N WE_N CRE xB_N WT  DATA
--   Read                     L     L    L    L    H   L    L  act data-out
--   Write                    L     L    L    X    L   L    L  act data-in
--   Standby                  L     X    H    X    X   L    X  'z' 'z'
--   CRE write                L     L    L    H    L   H    X  act 'z'
--   CRE read                 L     L    L    L    H   H    L  act conf-out
--
-- Burst Mode (BCR(15)=0)
--   Operation               CLK ADV_N CE_N OE_N WE_N CRE xB_N WT  DATA
--   Async read               L     L    L    L    H   L    L  act data-out
--   Async write              L     L    L    X    L   L    L  act data-in 
--   Standby                  L     X    H    X    X   L    X  'z' 'z'
--   Initial burst read      0-1    L    L    X    H   L    L  act  X
--   Initial burst write     0-1    L    L    H    L   L    X  act  X
--   Burst continue          0-1    H    L    X    X   X    X  act data-in/out
--   CRE write               0-1    L    L    H    L   H    X  act 'z'
--   CRE read                0-1    L    L    L    H   H    L  act conf-out
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity mt45w8mw16b is                   -- Micron MT45W8MW16B CellularRAM model
  port (
    CLK : in slbit;                     -- clock for synchonous operation
    CE_N : in slbit;                    -- chip enable        (act.low)
    OE_N : in slbit;                    -- output enable      (act.low)
    WE_N : in slbit;                    -- write enable       (act.low)
    UB_N : in slbit;                    -- upper byte enable  (act.low)
    LB_N : in slbit;                    -- lower byte enable  (act.low)
    ADV_N : in slbit;                   -- address valid      (act.low)
    CRE : in slbit;                     -- control register enable
    MWAIT : out slbit;                  -- wait (for burst read/write)
    ADDR : in slv23;                    -- address lines
    DATA : inout slv16                  -- data lines
  );
end mt45w8mw16b;


architecture sim of mt45w8mw16b is

  -- timing constants for -701 speed grade (70 ns; 104 MHz)
  constant T_aa   : time := 70 ns;      -- address access time             (max)
  constant T_apa  : time := 20 ns;      -- page acess time                 (max)
  constant T_oh   : time :=  5 ns;      -- output hold from addr change    (max)
  constant T_oe   : time := 20 ns;      -- output enable to valid output   (max)
  constant T_ohz  : time :=  8 ns;      -- output disable to high-z output (max)
  constant T_olz  : time :=  3 ns;      -- output enable to low-z output   (min)
  constant T_lz   : time := 10 ns;      -- chip enable to low-z output     (min)
  constant T_hz   : time :=  8 ns;      -- chip disable to high-z output   (max)

  constant memsize : positive := 2**(ADDR'length);
  constant datzero : slv(DATA'range) := (others=>'0');
  type ram_type is array (0 to memsize-1) of slv(DATA'range);

  constant bcr_f_mode   : integer := 15;              -- operating mode 
  constant bcr_f_ilat   : integer := 14;              -- initial latency
  subtype  bcr_f_lc    is integer range 13 downto 11; -- latency counter
  constant bcr_f_wp     : integer := 10;              -- wait polarity
  constant bcr_f_wc     : integer :=  8;              -- wait configuration
  subtype  bcr_f_drive is integer range  5 downto  4; -- drive strength
  constant bcr_f_bw     : integer :=  3;              -- burst wrap
  subtype  bcr_f_bl    is integer range  2 downto  0; -- burst length
    
  subtype  f_byte1       is integer range 15 downto 8;
  subtype  f_byte0       is integer range  7 downto 0;

  signal CE : slbit := '0';
  signal OE : slbit := '0';
  signal WE : slbit := '0';
  signal BE_L : slbit := '0';
  signal BE_U : slbit := '0';
  signal ADV : slbit := '0';
  signal WE_L_EFF : slbit := '0';
  signal WE_U_EFF : slbit := '0';

  signal R_BCR_MODE  : slbit := '1';    -- mode: def: async
  signal R_BCR_ILAT  : slbit := '0';    -- ilat: def: variable
  signal R_BCR_LC    : slv3  := "011";  -- lc:   def: code 3
  signal R_BCR_WP    : slbit := '1';    -- wp:   def: active high
  signal R_BCR_WC    : slbit := '1';    -- wc:   def: assert one before
  signal R_BCR_DRIVE : slv2  := "01";   -- drive:def: 1/2
  signal R_BCR_BW    : slbit := '1';    -- bw:   def: no wrap
  signal R_BCR_BL    : slv3  := "111";  -- bl:   def: continuous
  
  signal L_ADDR : slv23 := (others=>'0');
  signal DOUT_VAL_EN : slbit := '0';
  signal DOUT_VAL_AA : slbit := '0';
  signal DOUT_VAL_PA : slbit := '0';
  signal DOUT_VAL_OE : slbit := '0';
  signal DOUT_LZ_CE  : slbit := '0';
  signal DOUT_LZ_OE  : slbit := '0';

  signal OEWE : slbit := '0';
  signal DOUT : slv16 := (others=>'0');
begin

  CE   <= not CE_N;
  OE   <= not OE_N;
  WE   <= not WE_N;
  BE_L <= not LB_N;
  BE_U <= not UB_N;
  ADV  <= not ADV_N;

  WE_L_EFF <= CE and WE and BE_L;
  WE_U_EFF <= CE and WE and BE_U;

  -- address valid logic, latch ADDR when ADV true
  proc_adv: process (ADV, ADDR)
  begin
    if ADV = '1' then
      L_ADDR <= ADDR;
    end if;
  end process proc_adv;

  proc_dout_val: process (CE, OE, WE, BE_L, BE_U, ADV, L_ADDR)
    variable addr_last : slv23 := (others=>'1');
  begin
    if (CE'event   and CE='1') or
       (BE_L'event and BE_L='1') or
       (BE_U'event and BE_U='1') or
       (WE'event   and WE='0') or
       (ADV'event  and ADV='1') then
      DOUT_VAL_EN <= '0', '1' after T_aa;
    end if;
    if L_ADDR'event then
      DOUT_VAL_PA <= '0', '1' after T_apa;
      if L_ADDR(22 downto 4) /= addr_last(22 downto 4) then
        DOUT_VAL_AA <= '0', '1' after T_aa;
      end if;
      addr_last := L_ADDR;
    end if;
    if rising_edge(OE) then
      DOUT_VAL_OE <= '0', '1' after T_oe;
    end if;
  end process proc_dout_val;

  -- to simplify things assume that OE and (not WE) have same effect on output
  -- drivers. The timing rules are very similar indeed...
  OEWE <= OE and (not WE);
  
  proc_dout_lz: process (CE, OEWE)
  begin
    if (CE'event) then
      if CE = '1' then
        DOUT_LZ_CE <= '1' after T_lz;
      else
        DOUT_LZ_CE <= '0' after T_hz;
      end if;
    end if;
    if (OEwe'event) then
      if OEWE = '1' then
        DOUT_LZ_OE <= '1' after T_olz;
      else
        DOUT_LZ_OE <= '0' after T_ohz;
      end if;
    end if;
  end process proc_dout_lz;
  
  proc_cram: process (CE, OE, WE, WE_L_EFF, WE_U_EFF, L_ADDR, DATA)
    variable ram : ram_type := (others=>datzero);
  begin

    -- end of write cycle
    -- note: to_x01 used below to prevent that 'z' a written into mem.
    if falling_edge(WE_L_EFF) then
      ram(to_integer(unsigned(L_ADDR)))(f_byte0) := to_x01(DATA(f_byte0));
    end if;
    if falling_edge(WE_U_EFF) then
      ram(to_integer(unsigned(L_ADDR)))(f_byte1) := to_x01(DATA(f_byte1));
    end if;

    DOUT <= ram(to_integer(unsigned(L_ADDR)));

  end process proc_cram;

  proc_data: process (DOUT, DOUT_VAL_EN, DOUT_VAL_AA, DOUT_VAL_PA, DOUT_VAL_OE,
                      DOUT_LZ_CE, DOUT_LZ_OE)
    variable idout : slv16 := (others=>'0');
  begin
    idout := DOUT;
    if DOUT_VAL_EN='0' or DOUT_VAL_AA='0' or
       DOUT_VAL_PA='0' or DOUT_VAL_OE='0' then
      idout := (others=>'X');
    end if;
    if DOUT_LZ_CE='0' or DOUT_LZ_OE='0' then
      idout := (others=>'Z');
    end if;
    DATA <= idout;
  end process proc_data;

  proc_mwait: process (CE)
  begin
    -- WT driver (just a dummy)
    if CE = '1' then
      MWAIT <= '1';
    else
      MWAIT <= 'Z';
    end if;
  end process proc_mwait;
  
end sim;
