-- $Id: ram_1swsr_xfirst_gen_unisim.vhd 686 2015-06-04 21:08:08Z mueller $
--
-- Copyright 2008-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ram_1swsr_xfirst_gen_unisim - syn
-- Description:    Single-Port RAM with with one synchronous read/write port
--                 Direct instantiation of Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: Spartan-3, Virtex-2,-4
-- Tool versions:  xst 8.1-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-08-14   406   1.0.2  cleaner code for L_DI initialization
-- 2008-04-13   135   1.0.1  fix range error for AW_14_S1
-- 2008-03-08   123   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;

entity ram_1swsr_xfirst_gen_unisim is   -- RAM, 1 sync r/w ports
  generic (
    AWIDTH : positive := 11;            -- address port width
    DWIDTH : positive :=  9;            -- data port width
    WRITE_MODE : string := "READ_FIRST"); -- write mode: (READ|WRITE)_FIRST
  port(
    CLK   : in slbit;                   -- clock
    EN    : in slbit;                   -- enable
    WE    : in slbit;                   -- write enable
    ADDR  : in slv(AWIDTH-1 downto 0);  -- address
    DI    : in slv(DWIDTH-1 downto 0);  -- data in
    DO    : out slv(DWIDTH-1 downto 0)  -- data out
  );
end ram_1swsr_xfirst_gen_unisim;


architecture syn of ram_1swsr_xfirst_gen_unisim is

  constant ok_mod32 : boolean := (DWIDTH mod 32)=0 and
                                 ((DWIDTH+35)/36)=((DWIDTH+31)/32);
  constant ok_mod16 : boolean := (DWIDTH mod 16)=0 and
                                 ((DWIDTH+17)/18)=((DWIDTH+16)/16);
  constant ok_mod08 : boolean := (DWIDTH mod 32)=0 and
                                 ((DWIDTH+8)/9)=((DWIDTH+7)/8);

begin
  
  assert AWIDTH>=9 and AWIDTH<=14
    report "assert(AWIDTH>=9 and AWIDTH<=14): unsupported BRAM from factor"
    severity failure;

  AW_09_S36: if AWIDTH=9 and not ok_mod32 generate
    constant dw_mem : positive := ((DWIDTH+35)/36)*36;
    signal L_DO : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DI : slv(dw_mem-1 downto 0) := (others=> '0');
  begin
    
    DI_PAD: if dw_mem>DWIDTH generate
      L_DI(dw_mem-1 downto DWIDTH) <= (others=>'0');
    end generate DI_PAD;
    L_DI(DI'range) <= DI;
    
   GL: for i in dw_mem/36-1 downto 0 generate
      MEM : RAMB16_S36
        generic map (
          INIT       => O"000000000000",
          SRVAL      => O"000000000000",
          WRITE_MODE => WRITE_MODE)
        port map (
          DO   => L_DO(36*i+31 downto 36*i),
          DOP  => L_DO(36*i+35 downto 36*i+32),
          ADDR => ADDR,
          CLK  => CLK,
          DI   => L_DI(36*i+31 downto 36*i),
          DIP  => L_DI(36*i+35 downto 36*i+32),
          EN   => EN,
          SSR  => '0',
          WE   => WE
        );
    end generate GL;

    DO <= L_DO(DO'range);
      
  end generate AW_09_S36;

  AW_09_S32: if AWIDTH=9 and ok_mod32 generate
    GL: for i in DWIDTH/32-1 downto 0 generate
      MEM : RAMB16_S36
        generic map (
          INIT       => X"00000000",
          SRVAL      => X"00000000",
          WRITE_MODE => WRITE_MODE)
        port map (
          DO   => DO(32*i+31 downto 32*i),
          DOP  => open,
          ADDR => ADDR,
          CLK  => CLK,
          DI   => DI(32*i+31 downto 32*i),
          DIP  => "0000",
          EN   => EN,
          SSR  => '0',
          WE   => WE
        );
    end generate GL;
  end generate AW_09_S32;

  AW_10_S18: if AWIDTH=10 and not ok_mod16 generate
    constant dw_mem : positive := ((DWIDTH+17)/18)*18;
    signal L_DO : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DI : slv(dw_mem-1 downto 0) := (others=> '0');
  begin

    DI_PAD: if dw_mem>DWIDTH generate
      L_DI(dw_mem-1 downto DWIDTH) <= (others=>'0');
    end generate DI_PAD;
    L_DI(DI'range) <= DI;
    
    GL: for i in dw_mem/18-1 downto 0 generate
      MEM : RAMB16_S18
        generic map (
          INIT       => O"000000",
          SRVAL      => O"000000",
          WRITE_MODE => WRITE_MODE)
        port map (
          DO   => L_DO(18*i+15 downto 18*i),
          DOP  => L_DO(18*i+17 downto 18*i+16),
          ADDR => ADDR,
          CLK  => CLK,
          DI   => L_DI(18*i+15 downto 18*i),
          DIP  => L_DI(18*i+17 downto 18*i+16),
          EN   => EN,
          SSR  => '0',
          WE   => WE
        );
    end generate GL;

    DO <= L_DO(DO'range);
      
  end generate AW_10_S18;

  AW_10_S16: if AWIDTH=10 and ok_mod16 generate
    GL: for i in DWIDTH/16-1 downto 0 generate
      MEM : RAMB16_S18
        generic map (
          INIT       => X"0000",
          SRVAL      => X"0000",
          WRITE_MODE => WRITE_MODE)
        port map (
          DO   => DO(16*i+15 downto 16*i),
          DOP  => open,
          ADDR => ADDR,
          CLK  => CLK,
          DI   => DI(16*i+15 downto 16*i),
          DIP  => "00",
          EN   => EN,
          SSR  => '0',
          WE   => WE
        );
    end generate GL;
  end generate AW_10_S16;

  AW_11_S9: if AWIDTH=11  and not ok_mod08 generate
    constant dw_mem : positive := ((DWIDTH+8)/9)*9;
    signal L_DO : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DI : slv(dw_mem-1 downto 0) := (others=> '0');
  begin
    
    DI_PAD: if dw_mem>DWIDTH generate
      L_DI(dw_mem-1 downto DWIDTH) <= (others=>'0');
    end generate DI_PAD;
    L_DI(DI'range) <= DI;
    
    GL: for i in dw_mem/9-1 downto 0 generate
      MEM : RAMB16_S9
        generic map (
          INIT       => O"000",
          SRVAL      => O"000",
          WRITE_MODE => WRITE_MODE)
        port map (
          DO   => L_DO(9*i+7 downto 9*i),
          DOP  => L_DO(9*i+8 downto 9*i+8),
          ADDR => ADDR,
          CLK  => CLK,
          DI   => L_DI(9*i+7 downto 9*i),
          DIP  => L_DI(9*i+8 downto 9*i+8),
          EN   => EN,
          SSR  => '0',
          WE   => WE
        );
    end generate GL;

    DO <= L_DO(DO'range);
      
  end generate AW_11_S9;

  AW_11_S8: if AWIDTH=11 and ok_mod08 generate
    GL: for i in DWIDTH/8-1 downto 0 generate
      MEM : RAMB16_S9
        generic map (
          INIT       => X"00",
          SRVAL      => X"00",
          WRITE_MODE => WRITE_MODE)
        port map (
          DO   => DO(8*i+7 downto 8*i),
          DOP  => open,
          ADDR => ADDR,
          CLK  => CLK,
          DI   => DI(8*i+7 downto 8*i),
          DIP  => "0",
          EN   => EN,
          SSR  => '0',
          WE   => WE
        );
    end generate GL;
  end generate AW_11_S8;

  AW_12_S4: if AWIDTH = 12 generate
    constant dw_mem : positive := ((DWIDTH+3)/4)*4;
    signal L_DO : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DI : slv(dw_mem-1 downto 0) := (others=> '0');
  begin
    
    DI_PAD: if dw_mem>DWIDTH generate
      L_DI(dw_mem-1 downto DWIDTH) <= (others=>'0');
    end generate DI_PAD;
    L_DI(DI'range) <= DI;
    
    GL: for i in dw_mem/4-1 downto 0 generate
      MEM : RAMB16_S4
        generic map (
          INIT       => X"0",
          SRVAL      => X"0",
          WRITE_MODE => WRITE_MODE)
        port map (
          DO   => L_DO(4*i+3 downto 4*i),
          ADDR => ADDR,
          CLK  => CLK,
          DI   => L_DI(4*i+3 downto 4*i),
          EN   => EN,
          SSR  => '0',
          WE   => WE
        );
    end generate GL;

    DO <= L_DO(DO'range);
      
  end generate AW_12_S4;

  AW_13_S2: if AWIDTH = 13 generate
    constant dw_mem : positive := ((DWIDTH+1)/2)*2;
    signal L_DO : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DI : slv(dw_mem-1 downto 0) := (others=> '0');
  begin
    
    DI_PAD: if dw_mem>DWIDTH generate
      L_DI(dw_mem-1 downto DWIDTH) <= (others=>'0');
    end generate DI_PAD;
    L_DI(DI'range) <= DI;
    
    GL: for i in dw_mem/2-1 downto 0 generate
      MEM : RAMB16_S2
        generic map (
          INIT       => "00",
          SRVAL      => "00",
          WRITE_MODE => WRITE_MODE)
        port map (
          DO   => L_DO(2*i+1 downto 2*i),
          ADDR => ADDR,
          CLK  => CLK,
          DI   => L_DI(2*i+1 downto 2*i),
          EN   => EN,
          SSR  => '0',
          WE   => WE
        );
    end generate GL;

    DO <= L_DO(DO'range);
      
  end generate AW_13_S2;

  AW_14_S1: if AWIDTH = 14 generate
    GL: for i in DWIDTH-1 downto 0 generate
      MEM : RAMB16_S1
        generic map (
          INIT       => "0",
          SRVAL      => "0",
          WRITE_MODE => WRITE_MODE)
        port map (
          DO   => DO(i downto i),
          ADDR => ADDR,
          CLK  => CLK,
          DI   => DI(i downto i),
          EN   => EN,
          SSR  => '0',
          WE   => WE
        );
    end generate GL;
  end generate AW_14_S1;

  
end syn;

-- Note: in XST 8.2 the defaults for INIT_(A|B) and SRVAL_(A|B) are
--       nonsense:  INIT_A : bit_vector := X"000";
--       This is a 12 bit value, while a 9 bit one is needed. Thus the
--       explicit definition above.
