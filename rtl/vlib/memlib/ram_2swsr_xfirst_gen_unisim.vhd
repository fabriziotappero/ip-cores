-- $Id: ram_2swsr_xfirst_gen_unisim.vhd 686 2015-06-04 21:08:08Z mueller $
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
-- Module Name:    ram_2swsr_xfirst_gen_unisim - syn
-- Description:    Dual-Port RAM with with two synchronous read/write ports
--                 Direct instantiation of Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: Spartan-3, Virtex-2,-4
-- Tool versions:  ise 8.1-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-08-14   406   1.0.2  cleaner code for L_DI(A|B) initialization
-- 2008-04-13   135   1.0.1  fix range error for AW_14_S1
-- 2008-03-08   123   1.0    Initial version (merged from _rfirst/_wfirst) 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;

entity ram_2swsr_xfirst_gen_unisim is   -- RAM, 2 sync r/w ports
  generic (
    AWIDTH : positive := 11;            -- address port width
    DWIDTH : positive :=  9;            -- data port width
    WRITE_MODE : string := "READ_FIRST"); -- write mode: (READ|WRITE)_FIRST
  port(
    CLKA  : in slbit;                   -- clock port A
    CLKB  : in slbit;                   -- clock port B
    ENA   : in slbit;                   -- enable port A
    ENB   : in slbit;                   -- enable port B
    WEA   : in slbit;                   -- write enable port A
    WEB   : in slbit;                   -- write enable port B
    ADDRA : in slv(AWIDTH-1 downto 0);  -- address port A
    ADDRB : in slv(AWIDTH-1 downto 0);  -- address port B
    DIA   : in slv(DWIDTH-1 downto 0);  -- data in port A
    DIB   : in slv(DWIDTH-1 downto 0);  -- data in port B
    DOA   : out slv(DWIDTH-1 downto 0); -- data out port A
    DOB   : out slv(DWIDTH-1 downto 0)  -- data out port B
  );
end ram_2swsr_xfirst_gen_unisim;


architecture syn of ram_2swsr_xfirst_gen_unisim is

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
    signal L_DOA : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DOB : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DIA : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DIB : slv(dw_mem-1 downto 0) := (others=> '0');
  begin
    
    DI_PAD: if dw_mem>DWIDTH generate
      L_DIA(dw_mem-1 downto DWIDTH) <= (others=>'0');
      L_DIB(dw_mem-1 downto DWIDTH) <= (others=>'0');
    end generate DI_PAD;
    L_DIA(DIA'range) <= DIA;
    L_DIB(DIB'range) <= DIB;
    
   GL: for i in dw_mem/36-1 downto 0 generate
      MEM : RAMB16_S36_S36
        generic map (
          INIT_A       => O"000000000000",
          INIT_B       => O"000000000000",
          SRVAL_A      => O"000000000000",
          SRVAL_B      => O"000000000000",
          WRITE_MODE_A => WRITE_MODE,
          WRITE_MODE_B => WRITE_MODE)
        port map (
          DOA   => L_DOA(36*i+31 downto 36*i),
          DOB   => L_DOB(36*i+31 downto 36*i),
          DOPA  => L_DOA(36*i+35 downto 36*i+32),
          DOPB  => L_DOB(36*i+35 downto 36*i+32),
          ADDRA => ADDRA,
          ADDRB => ADDRB,
          CLKA  => CLKA,
          CLKB  => CLKB,
          DIA   => L_DIA(36*i+31 downto 36*i),
          DIB   => L_DIB(36*i+31 downto 36*i),
          DIPA  => L_DIA(36*i+35 downto 36*i+32),
          DIPB  => L_DIB(36*i+35 downto 36*i+32),
          ENA   => ENA,
          ENB   => ENB,
          SSRA  => '0',
          SSRB  => '0',
          WEA   => WEA,
          WEB   => WEB
        );
    end generate GL;

    DOA <= L_DOA(DOA'range);
    DOB <= L_DOB(DOB'range);
      
  end generate AW_09_S36;

  AW_09_S32: if AWIDTH=9 and ok_mod32 generate
    GL: for i in DWIDTH/32-1 downto 0 generate
      MEM : RAMB16_S36_S36
        generic map (
          INIT_A       => X"00000000",
          INIT_B       => X"00000000",
          SRVAL_A      => X"00000000",
          SRVAL_B      => X"00000000",
          WRITE_MODE_A => WRITE_MODE,
          WRITE_MODE_B => WRITE_MODE)
        port map (
          DOA   => DOA(32*i+31 downto 32*i),
          DOB   => DOB(32*i+31 downto 32*i),
          DOPA  => open,
          DOPB  => open,
          ADDRA => ADDRA,
          ADDRB => ADDRB,
          CLKA  => CLKA,
          CLKB  => CLKB,
          DIA   => DIA(32*i+31 downto 32*i),
          DIB   => DIB(32*i+31 downto 32*i),
          DIPA  => "0000",
          DIPB  => "0000",
          ENA   => ENA,
          ENB   => ENB,
          SSRA  => '0',
          SSRB  => '0',
          WEA   => WEA,
          WEB   => WEB
        );
    end generate GL;
  end generate AW_09_S32;

  AW_10_S18: if AWIDTH=10 and not ok_mod16 generate
    constant dw_mem : positive := ((DWIDTH+17)/18)*18;
    signal L_DOA : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DOB : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DIA : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DIB : slv(dw_mem-1 downto 0) := (others=> '0');
  begin
    
    DI_PAD: if dw_mem>DWIDTH generate
      L_DIA(dw_mem-1 downto DWIDTH) <= (others=>'0');
      L_DIB(dw_mem-1 downto DWIDTH) <= (others=>'0');
    end generate DI_PAD;
    L_DIA(DIA'range) <= DIA;
    L_DIB(DIB'range) <= DIB;
    
    GL: for i in dw_mem/18-1 downto 0 generate
      MEM : RAMB16_S18_S18
        generic map (
          INIT_A       => O"000000",
          INIT_B       => O"000000",
          SRVAL_A      => O"000000",
          SRVAL_B      => O"000000",
          WRITE_MODE_A => WRITE_MODE,
          WRITE_MODE_B => WRITE_MODE)
        port map (
          DOA   => L_DOA(18*i+15 downto 18*i),
          DOB   => L_DOB(18*i+15 downto 18*i),
          DOPA  => L_DOA(18*i+17 downto 18*i+16),
          DOPB  => L_DOB(18*i+17 downto 18*i+16),
          ADDRA => ADDRA,
          ADDRB => ADDRB,
          CLKA  => CLKA,
          CLKB  => CLKB,
          DIA   => L_DIA(18*i+15 downto 18*i),
          DIB   => L_DIB(18*i+15 downto 18*i),
          DIPA  => L_DIA(18*i+17 downto 18*i+16),
          DIPB  => L_DIB(18*i+17 downto 18*i+16),
          ENA   => ENA,
          ENB   => ENB,
          SSRA  => '0',
          SSRB  => '0',
          WEA   => WEA,
          WEB   => WEB
        );
    end generate GL;

    DOA <= L_DOA(DOA'range);
    DOB <= L_DOB(DOB'range);
      
  end generate AW_10_S18;

  AW_10_S16: if AWIDTH=10 and ok_mod16 generate
    GL: for i in DWIDTH/16-1 downto 0 generate
      MEM : RAMB16_S18_S18
        generic map (
          INIT_A       => X"0000",
          INIT_B       => X"0000",
          SRVAL_A      => X"0000",
          SRVAL_B      => X"0000",
          WRITE_MODE_A => WRITE_MODE,
          WRITE_MODE_B => WRITE_MODE)
        port map (
          DOA   => DOA(16*i+15 downto 16*i),
          DOB   => DOB(16*i+15 downto 16*i),
          DOPA  => open,
          DOPB  => open,
          ADDRA => ADDRA,
          ADDRB => ADDRB,
          CLKA  => CLKA,
          CLKB  => CLKB,
          DIA   => DIA(16*i+15 downto 16*i),
          DIB   => DIB(16*i+15 downto 16*i),
          DIPA  => "00",
          DIPB  => "00",
          ENA   => ENA,
          ENB   => ENB,
          SSRA  => '0',
          SSRB  => '0',
          WEA   => WEA,
          WEB   => WEB
        );
    end generate GL;
  end generate AW_10_S16;

  AW_11_S9: if AWIDTH=11  and not ok_mod08 generate
    constant dw_mem : positive := ((DWIDTH+8)/9)*9;
    signal L_DOA : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DOB : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DIA : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DIB : slv(dw_mem-1 downto 0) := (others=> '0');
  begin
    
    DI_PAD: if dw_mem>DWIDTH generate
      L_DIA(dw_mem-1 downto DWIDTH) <= (others=>'0');
      L_DIB(dw_mem-1 downto DWIDTH) <= (others=>'0');
    end generate DI_PAD;
    L_DIA(DIA'range) <= DIA;
    L_DIB(DIB'range) <= DIB;
    
    GL: for i in dw_mem/9-1 downto 0 generate
      MEM : RAMB16_S9_S9
        generic map (
          INIT_A       => O"000",
          INIT_B       => O"000",
          SRVAL_A      => O"000",
          SRVAL_B      => O"000",
          WRITE_MODE_A => WRITE_MODE,
          WRITE_MODE_B => WRITE_MODE)
        port map (
          DOA   => L_DOA(9*i+7 downto 9*i),
          DOB   => L_DOB(9*i+7 downto 9*i),
          DOPA  => L_DOA(9*i+8 downto 9*i+8),
          DOPB  => L_DOB(9*i+8 downto 9*i+8),
          ADDRA => ADDRA,
          ADDRB => ADDRB,
          CLKA  => CLKA,
          CLKB  => CLKB,
          DIA   => L_DIA(9*i+7 downto 9*i),
          DIB   => L_DIB(9*i+7 downto 9*i),
          DIPA  => L_DIA(9*i+8 downto 9*i+8),
          DIPB  => L_DIB(9*i+8 downto 9*i+8),
          ENA   => ENA,
          ENB   => ENB,
          SSRA  => '0',
          SSRB  => '0',
          WEA   => WEA,
          WEB   => WEB
        );
    end generate GL;

    DOA <= L_DOA(DOA'range);
    DOB <= L_DOB(DOB'range);
      
  end generate AW_11_S9;

  AW_11_S8: if AWIDTH=11 and ok_mod08 generate
    GL: for i in DWIDTH/8-1 downto 0 generate
      MEM : RAMB16_S9_S9
        generic map (
          INIT_A       => X"00",
          INIT_B       => X"00",
          SRVAL_A      => X"00",
          SRVAL_B      => X"00",
          WRITE_MODE_A => WRITE_MODE,
          WRITE_MODE_B => WRITE_MODE)
        port map (
          DOA   => DOA(8*i+7 downto 8*i),
          DOB   => DOB(8*i+7 downto 8*i),
          DOPA  => open,
          DOPB  => open,
          ADDRA => ADDRA,
          ADDRB => ADDRB,
          CLKA  => CLKA,
          CLKB  => CLKB,
          DIA   => DIA(8*i+7 downto 8*i),
          DIB   => DIB(8*i+7 downto 8*i),
          DIPA  => "0",
          DIPB  => "0",
          ENA   => ENA,
          ENB   => ENB,
          SSRA  => '0',
          SSRB  => '0',
          WEA   => WEA,
          WEB   => WEB
        );
    end generate GL;
  end generate AW_11_S8;

  AW_12_S4: if AWIDTH = 12 generate
    constant dw_mem : positive := ((DWIDTH+3)/4)*4;
    signal L_DOA : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DOB : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DIA : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DIB : slv(dw_mem-1 downto 0) := (others=> '0');
  begin
    
    DI_PAD: if dw_mem>DWIDTH generate
      L_DIA(dw_mem-1 downto DWIDTH) <= (others=>'0');
      L_DIB(dw_mem-1 downto DWIDTH) <= (others=>'0');
    end generate DI_PAD;
    L_DIA(DIA'range) <= DIA;
    L_DIB(DIB'range) <= DIB;
    
    GL: for i in dw_mem/4-1 downto 0 generate
      MEM : RAMB16_S4_S4
        generic map (
          INIT_A       => X"0",
          INIT_B       => X"0",
          SRVAL_A      => X"0",
          SRVAL_B      => X"0",
          WRITE_MODE_A => WRITE_MODE,
          WRITE_MODE_B => WRITE_MODE)
        port map (
          DOA   => L_DOA(4*i+3 downto 4*i),
          DOB   => L_DOB(4*i+3 downto 4*i),
          ADDRA => ADDRA,
          ADDRB => ADDRB,
          CLKA  => CLKA,
          CLKB  => CLKB,
          DIA   => L_DIA(4*i+3 downto 4*i),
          DIB   => L_DIB(4*i+3 downto 4*i),
          ENA   => ENA,
          ENB   => ENB,
          SSRA  => '0',
          SSRB  => '0',
          WEA   => WEA,
          WEB   => WEB
        );
    end generate GL;

    DOA <= L_DOA(DOA'range);
    DOB <= L_DOB(DOB'range);
      
  end generate AW_12_S4;

  AW_13_S2: if AWIDTH = 13 generate
    constant dw_mem : positive := ((DWIDTH+1)/2)*2;
    signal L_DOA : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DOB : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DIA : slv(dw_mem-1 downto 0) := (others=> '0');
    signal L_DIB : slv(dw_mem-1 downto 0) := (others=> '0');
  begin
    
    DI_PAD: if dw_mem>DWIDTH generate
      L_DIA(dw_mem-1 downto DWIDTH) <= (others=>'0');
      L_DIB(dw_mem-1 downto DWIDTH) <= (others=>'0');
    end generate DI_PAD;
    L_DIA(DIA'range) <= DIA;
    L_DIB(DIB'range) <= DIB;
    
    GL: for i in dw_mem/2-1 downto 0 generate
      MEM : RAMB16_S2_S2
        generic map (
          INIT_A       => "00",
          INIT_B       => "00",
          SRVAL_A      => "00",
          SRVAL_B      => "00",
          WRITE_MODE_A => WRITE_MODE,
          WRITE_MODE_B => WRITE_MODE)
        port map (
          DOA   => L_DOA(2*i+1 downto 2*i),
          DOB   => L_DOB(2*i+1 downto 2*i),
          ADDRA => ADDRA,
          ADDRB => ADDRB,
          CLKA  => CLKA,
          CLKB  => CLKB,
          DIA   => L_DIA(2*i+1 downto 2*i),
          DIB   => L_DIB(2*i+1 downto 2*i),
          ENA   => ENA,
          ENB   => ENB,
          SSRA  => '0',
          SSRB  => '0',
          WEA   => WEA,
          WEB   => WEB
        );
    end generate GL;

    DOA <= L_DOA(DOA'range);
    DOB <= L_DOB(DOB'range);
      
  end generate AW_13_S2;

  AW_14_S1: if AWIDTH = 14 generate
    GL: for i in DWIDTH-1 downto 0 generate
      MEM : RAMB16_S1_S1
        generic map (
          INIT_A       => "0",
          INIT_B       => "0",
          SRVAL_A      => "0",
          SRVAL_B      => "0",
          WRITE_MODE_A => WRITE_MODE,
          WRITE_MODE_B => WRITE_MODE)
        port map (
          DOA   => DOA(i downto i),
          DOB   => DOB(i downto i),
          ADDRA => ADDRA,
          ADDRB => ADDRB,
          CLKA  => CLKA,
          CLKB  => CLKB,
          DIA   => DIA(i downto i),
          DIB   => DIB(i downto i),
          ENA   => ENA,
          ENB   => ENB,
          SSRA  => '0',
          SSRB  => '0',
          WEA   => WEA,
          WEB   => WEB
        );
    end generate GL;
  end generate AW_14_S1;

  
end syn;

-- Note: in XST 8.2 the defaults for INIT_(A|B) and SRVAL_(A|B) are
--       nonsense:  INIT_A : bit_vector := X"000";
--       This is a 12 bit value, while a 9 bit one is needed. Thus the
--       explicit definition above.
