-- $Id: is61lv25616al.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    is61lv25616al - sim
-- Description:    ISSI 61LV25612AL SRAM model
--                 Currently a truely minimalistic functional model, without
--                 any timing checks. It assumes, that addr/data is stable at
--                 the trailing edge of we.
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-19   427   1.0.2  now numeric_std clean
-- 2008-05-12   145   1.0.1  BUGFIX: Output now 'Z' if byte enables deasserted 
-- 2007-12-14   101   1.0    Initial version  (written on warsaw airport)
------------------------------------------------------------------------------
-- Truth table accoring to data sheet:
--  
--     Mode          WE_N CE_N OE_N LB_N UB_N  D(7:0)  D(15:8)
-- Not selected        X    H    X    X    X   high-Z  high-Z
-- Output disabled     H    L    H    X    X   high-Z  high-Z
--                     X    L    X    H    H   high-Z  high-Z
-- Read                H    L    L    L    H   D_out   high-Z
--                     H    L    L    H    L   high-Z  D_out 
--                     H    L    L    L    L   D_out   D_out 
-- Write               L    L    X    L    H   D_in    high-Z
--                     L    L    X    H    L   high-Z  D_in  
--                     L    L    X    L    L   D_in    D_in  

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity is61lv25616al is                 -- ISSI 61LV25612AL SRAM model
  port (
    CE_N : in slbit;                    -- chip enable        (act.low)
    OE_N : in slbit;                    -- output enable      (act.low)
    WE_N : in slbit;                    -- write enable       (act.low)
    UB_N : in slbit;                    -- upper byte enable  (act.low)
    LB_N : in slbit;                    -- lower byte enable  (act.low)
    ADDR : in slv18;                    -- address lines
    DATA : inout slv16                  -- data lines
  );
end is61lv25616al;


architecture sim of is61lv25616al is

  signal CE : slbit := '0';
  signal OE : slbit := '0';
  signal WE : slbit := '0';
  signal BE_L : slbit := '0';
  signal BE_U : slbit := '0';
  
  component is61lv25616al_bank is       -- ISSI 61LV25612AL bank
  port (
    CE : in slbit;                      -- chip enable        (act.high)
    OE : in slbit;                      -- output enable      (act.high)
    WE : in slbit;                      -- write enable       (act.high)
    BE : in slbit;                      -- byte enable        (act.high)
    ADDR : in slv18;                    -- address lines
    DATA : inout slv8                   -- data lines
  );
  end component;

begin

  CE   <= not CE_N;
  OE   <= not OE_N;
  WE   <= not WE_N;
  BE_L <= not LB_N;
  BE_U <= not UB_N;
  
  BANK_L : is61lv25616al_bank port map (
    CE   => CE,
    OE   => OE,
    WE   => WE,
    BE   => BE_L,
    ADDR => ADDR,
    DATA => DATA(7 downto 0));
  
  BANK_U : is61lv25616al_bank port map (
    CE   => CE,
    OE   => OE,
    WE   => WE,
    BE   => BE_U,
    ADDR => ADDR,
    DATA => DATA(15 downto 8));
  
end sim;

-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

entity is61lv25616al_bank is            -- ISSI 61LV25612AL bank
  port (
    CE : in slbit;                      -- chip enable        (act.high)
    OE : in slbit;                      -- output enable      (act.high)
    WE : in slbit;                      -- write enable       (act.high)
    BE : in slbit;                      -- byte enable        (act.high)
    ADDR : in slv18;                    -- address lines
    DATA : inout slv8                   -- data lines
  );
end is61lv25616al_bank;

architecture sim of is61lv25616al_bank is

  constant T_rc   : time := 10 ns;      -- read cycle time        (min)
  constant T_aa   : time := 10 ns;      -- address access time    (max)
  constant T_oha  : time :=  2 ns;      -- output hold time       (min)
  constant T_ace  : time := 10 ns;      -- ce access time         (max)
  constant T_doe  : time :=  4 ns;      -- oe access time         (max)
  constant T_hzoe : time :=  4 ns;      -- oe to high-Z output    (max)
  constant T_lzoe : time :=  0 ns;      -- oe to low-Z output     (min)
  constant T_hzce : time :=  4 ns;      -- ce to high-Z output    (min=0,max=4)
  constant T_lzce : time :=  3 ns;      -- ce to low-Z output     (min)
  constant T_ba   : time :=  4 ns;      -- lb,ub access time      (max)
  constant T_hzb  : time :=  3 ns;      -- lb,ub to high-Z output (min=0,max=3)
  constant T_lzb  : time :=  0 ns;      -- lb,ub low-Z output     (min)

  constant memsize : positive := 2**(ADDR'length);
  constant datzero : slv(DATA'range) := (others=>'0');
  type ram_type is array (0 to memsize-1) of slv(DATA'range);
  
  signal WE_EFF : slbit := '0';

begin

  WE_EFF <= CE and WE and BE;
  
  proc_sram: process (CE, OE, WE, BE, WE_EFF, ADDR, DATA)
    variable ram : ram_type := (others=>datzero);
  begin

    if falling_edge(WE_EFF) then        -- end of write cycle
                                        -- note: to_x01 used below to prevent
                                        --       that 'z' a written into mem.
      ram(to_integer(unsigned(ADDR))) := to_x01(DATA);
    end if;

    if CE='1' and OE='1' and BE='1' and WE='0' then -- output driver
      DATA <= ram(to_integer(unsigned(ADDR)));
    else
      DATA <= (others=>'Z');
    end if;

  end process proc_sram;
  
end sim;
