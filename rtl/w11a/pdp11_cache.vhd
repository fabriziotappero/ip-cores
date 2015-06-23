-- $Id: pdp11_cache.vhd 677 2015-05-09 21:52:32Z mueller $
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
-- Module Name:    pdp11_cache - syn
-- Description:    pdp11: cache
--
-- Dependencies:   memlib/ram_2swsr_rfirst_gen
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.0.3  now numeric_std clean
-- 2008-02-23   118   1.0.2  ce cache in s_idle to avoid U's in sim
--                           factor invariants out of if's; fix tag rmiss logic
-- 2008-02-17   117   1.0.1  use em_(mreq|sres) interface; use req,we for mem
--                           recode, ghdl doesn't like partial vector port maps
-- 2008-02-16   116   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.pdp11.all;

entity pdp11_cache is                   -- cache
  port (
    CLK : in slbit;                     -- clock
    GRESET : in slbit;                  -- general reset
    EM_MREQ : in em_mreq_type;          -- em request
    EM_SRES : out em_sres_type;         -- em response
    FMISS : in slbit;                   -- force miss
    CHIT : out slbit;                   -- cache hit flag
    MEM_REQ : out slbit;                -- memory: request
    MEM_WE : out slbit;                 -- memory: write enable
    MEM_BUSY : in slbit;                -- memory: controller busy
    MEM_ACK_R : in slbit;               -- memory: acknowledge read
    MEM_ADDR : out slv20;               -- memory: address
    MEM_BE : out slv4;                  -- memory: byte enable
    MEM_DI : out slv32;                 -- memory: data in  (memory view)
    MEM_DO : in slv32                   -- memory: data out (memory view)
  );
end pdp11_cache;


architecture syn of pdp11_cache is

  type state_type is (
    s_idle,                             -- s_idle: wait for req
    s_read,                             -- s_read: read cycle
    s_rmiss,                            -- s_rmiss: read miss
    s_write                             -- s_write: write cycle
  );
  
  type regs_type is record
    state : state_type;                 -- state
    addr_w : slbit;                     -- address - word select
    addr_l : slv11;                     -- address - cache line address
    addr_t : slv9;                      -- address - cache tag part
    be : slv4;                          -- byte enables (at 4 byte level)
    di : slv16;                         -- data
  end record regs_type;

  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0',                                -- addr_w
    (others=>'0'),                      -- addr_l
    (others=>'0'),                      -- addr_t
    (others=>'0'),                      -- be
    (others=>'0')                       -- di
  );
    
  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs
  
  signal CMEM_TAG_CEA  : slbit := '0';
  signal CMEM_TAG_CEB  : slbit := '0';
  signal CMEM_TAG_WEA  : slbit := '0';
  signal CMEM_TAG_WEB  : slbit := '0';
  signal CMEM_TAG_DIB  : slv9  := (others=>'0');
  signal CMEM_TAG_DOA  : slv9  := (others=>'0');
  signal CMEM_DAT_CEA  : slbit := '0';
  signal CMEM_DAT_CEB  : slbit := '0';
  signal CMEM_DAT_WEA  : slv4 := "0000";
  signal CMEM_DAT_WEB  : slv4 := "0000";
  signal CMEM_DIA_0    : slv9 := (others=>'0');
  signal CMEM_DIA_1    : slv9 := (others=>'0');
  signal CMEM_DIA_2    : slv9 := (others=>'0');
  signal CMEM_DIA_3    : slv9 := (others=>'0');
  signal CMEM_DIB_0    : slv9 := (others=>'0');
  signal CMEM_DIB_1    : slv9 := (others=>'0');
  signal CMEM_DIB_2    : slv9 := (others=>'0');
  signal CMEM_DIB_3    : slv9 := (others=>'0');
  signal CMEM_DOA_0    : slv9 := (others=>'0');
  signal CMEM_DOA_1    : slv9 := (others=>'0');
  signal CMEM_DOA_2    : slv9 := (others=>'0');
  signal CMEM_DOA_3    : slv9 := (others=>'0');

begin

  CMEM_TAG : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => 11,
      DWIDTH =>  9)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_TAG_CEA,
      ENB   => CMEM_TAG_CEB,
      WEA   => CMEM_TAG_WEA,
      WEB   => CMEM_TAG_WEB,
      ADDRA => EM_MREQ.addr(12 downto 2),
      ADDRB => R_REGS.addr_l,
      DIA   => EM_MREQ.addr(21 downto 13),
      DIB   => CMEM_TAG_DIB,
      DOA   => CMEM_TAG_DOA,
      DOB   => open
      );

  CMEM_DAT0 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => 11,
      DWIDTH =>  9)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_DAT_CEA,
      ENB   => CMEM_DAT_CEB,
      WEA   => CMEM_DAT_WEA(0),
      WEB   => CMEM_DAT_WEB(0),
      ADDRA => EM_MREQ.addr(12 downto 2),
      ADDRB => R_REGS.addr_l,
      DIA   => CMEM_DIA_0,
      DIB   => CMEM_DIB_0,
      DOA   => CMEM_DOA_0,
      DOB   => open
      );

  CMEM_DAT1 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => 11,
      DWIDTH =>  9)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_DAT_CEA,
      ENB   => CMEM_DAT_CEB,
      WEA   => CMEM_DAT_WEA(1),
      WEB   => CMEM_DAT_WEB(1),
      ADDRA => EM_MREQ.addr(12 downto 2),
      ADDRB => R_REGS.addr_l,
      DIA   => CMEM_DIA_1,
      DIB   => CMEM_DIB_1,
      DOA   => CMEM_DOA_1,
      DOB   => open
      );

  CMEM_DAT2 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => 11,
      DWIDTH =>  9)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_DAT_CEA,
      ENB   => CMEM_DAT_CEB,
      WEA   => CMEM_DAT_WEA(2),
      WEB   => CMEM_DAT_WEB(2),
      ADDRA => EM_MREQ.addr(12 downto 2),
      ADDRB => R_REGS.addr_l,
      DIA   => CMEM_DIA_2,
      DIB   => CMEM_DIB_2,
      DOA   => CMEM_DOA_2,
      DOB   => open
      );

  CMEM_DAT3 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH => 11,
      DWIDTH =>  9)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => CMEM_DAT_CEA,
      ENB   => CMEM_DAT_CEB,
      WEA   => CMEM_DAT_WEA(3),
      WEB   => CMEM_DAT_WEB(3),
      ADDRA => EM_MREQ.addr(12 downto 2),
      ADDRB => R_REGS.addr_l,
      DIA   => CMEM_DIA_3,
      DIB   => CMEM_DIB_3,
      DOA   => CMEM_DOA_3,
      DOB   => open
      );

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if GRESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, EM_MREQ, FMISS,
                      CMEM_TAG_DOA,
                      CMEM_DOA_0, CMEM_DOA_1, CMEM_DOA_2, CMEM_DOA_3, 
                      MEM_BUSY, MEM_ACK_R, MEM_DO)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable iaddr_w : slbit := '0';
    variable iaddr_l : slv11 := (others=>'0');
    variable iaddr_t : slv9  := (others=>'0');

    variable itagok : slbit := '0';
    variable ivalok : slbit := '0';

    variable icmem_tag_cea : slbit := '0';
    variable icmem_tag_ceb : slbit := '0';
    variable icmem_tag_wea : slbit := '0';
    variable icmem_tag_web : slbit := '0';
    variable icmem_tag_dib : slv9  := (others=>'0');
    variable icmem_dat_cea : slbit := '0';
    variable icmem_dat_ceb : slbit := '0';
    variable icmem_dat_wea : slv4  := "0000";
    variable icmem_dat_web : slv4  := "0000";
    variable icmem_val_doa : slv4  := "0000";
    variable icmem_dat_doa : slv32 := (others=>'0');
    variable icmem_val_dib : slv4  := "0000";
    variable icmem_dat_dib : slv32 := (others=>'0');

    variable iackr : slbit := '0';
    variable iackw : slbit := '0';
    variable ichit : slbit := '0';
    variable iosel : slv2  := "11";

    variable imem_reqr : slbit := '0';
    variable imem_reqw : slbit := '0';
    variable imem_be   : slv4  := "0000";

  begin

    r := R_REGS;
    n := R_REGS;

    iaddr_w := EM_MREQ.addr(1);                -- get word select
    iaddr_l := EM_MREQ.addr(12 downto 2);      -- get cache line addr
    iaddr_t := EM_MREQ.addr(21 downto 13);     -- get cache tag part
    
    icmem_tag_cea := '0';
    icmem_tag_ceb := '0';
    icmem_tag_wea := '0';
    icmem_tag_web := '0';
    icmem_tag_dib := r.addr_t;          -- default, local define whenver used
    icmem_dat_cea := '0';
    icmem_dat_ceb := '0';
    icmem_dat_wea := "0000";
    icmem_dat_web := "0000";
    icmem_val_dib := "0000";
    icmem_dat_dib := MEM_DO;            -- default, local define whenver used

    icmem_val_doa(0)            := CMEM_DOA_0(8);
    icmem_dat_doa( 7 downto  0) := CMEM_DOA_0(7 downto 0);
    icmem_val_doa(1)            := CMEM_DOA_1(8);
    icmem_dat_doa(15 downto  8) := CMEM_DOA_1(7 downto 0);
    icmem_val_doa(2)            := CMEM_DOA_2(8);
    icmem_dat_doa(23 downto 16) := CMEM_DOA_2(7 downto 0);
    icmem_val_doa(3)            := CMEM_DOA_3(8);
    icmem_dat_doa(31 downto 24) := CMEM_DOA_3(7 downto 0);

    itagok := '0';
    if CMEM_TAG_DOA = r.addr_t then  -- cache tag hit
      itagok := '1';
    end if;
    ivalok := '0';
    if (icmem_val_doa and r.be) = r.be then
      ivalok := '1';
    end if;

    iackr := '0';
    iackw := '0';
    ichit := '0';
    iosel := "11";                      -- default to ext. mem data
                                        -- this prevents U's from cache bram's
                                        -- to propagate to dout in beginning...

    imem_reqr := '0';
    imem_reqw := '0';
    imem_be   := r.be;
    
    case r.state is
      when s_idle =>                    -- s_idle: wait for req
        n.addr_w := iaddr_w;              -- capture address: word select
        n.addr_l := iaddr_l;              -- capture address: cache line addr
        n.addr_t := iaddr_t;              -- capture address: cache tag part
        n.be     := "0000";
        icmem_tag_cea := '1';             -- access cache tag port A
        icmem_dat_cea := '1';             -- access cache data port A
        if iaddr_w = '0' then             -- capture byte enables at 4 byte lvl
          n.be(1 downto 0) := EM_MREQ.be;
        else
          n.be(3 downto 2) := EM_MREQ.be;
        end if;
        n.di     := EM_MREQ.din;          -- capture data

        if EM_MREQ.req = '1' then         -- if access requested
          if EM_MREQ.we = '0' then          -- if READ requested
            n.state := s_read;                -- next: read

          else                              -- if WRITE requested
            icmem_tag_wea := '1';             -- write tag
            icmem_dat_wea := n.be;            -- write cache data
            n.state := s_write;               -- next: write
          end if;
        end if;
          
      when s_read =>                    -- s_read: read cycle
        iosel := '0' & r.addr_w;          -- output select: cache
        imem_be := "1111";                -- mem read: all 4 bytes
        if EM_MREQ.cancel = '0' then
          if FMISS='0' and itagok='1' and ivalok='1' then -- read tag&val hit
            iackr := '1';                   -- signal read acknowledge
            ichit := '1';                   -- signal cache hit
            n.state := s_idle;              -- next: back to idle 
          else                            -- read miss
            if MEM_BUSY = '0' then          -- if mem not busy
              imem_reqr :='1';                -- request mem read
              n.state := s_rmiss;             -- next: rmiss, wait for mem data
            end if;
          end if;
        else
          n.state := s_idle;              -- next: back to idle 
        end if;

      when s_rmiss =>                   -- s_rmiss: read cycle
        iosel := '1' & r.addr_w;          -- output select: memory
        icmem_tag_web := '1';             -- cache update: write tag
        icmem_tag_dib := r.addr_t;        -- cache update: new tag
        icmem_val_dib := "1111";          -- cache update: all valid
        icmem_dat_dib := MEM_DO;          -- cache update: data from mem
        icmem_dat_web := "1111";          -- cache update: write all 4 bytes
        if MEM_ACK_R = '1' then           -- mem data valid
          iackr := '1';                     -- signal read acknowledge
          icmem_tag_ceb := '1';             -- access cache tag  port B
          icmem_dat_ceb := '1';             -- access cache data port B
          n.state := s_idle;                -- next: back to idle
        end if;

      when s_write =>                   -- s_write: write cycle
        icmem_tag_dib := CMEM_TAG_DOA;    -- cache restore: last state 
        icmem_dat_dib := icmem_dat_doa;   -- cache restore: last state 
        if EM_MREQ.cancel = '0' then      -- request ok
          if MEM_BUSY = '0' then            -- if mem not busy
            if itagok = '0' then              -- if write tag miss
              icmem_dat_ceb := '1';             -- access cache (invalidate)
              icmem_dat_web := not r.be;        -- write missed bytes
              icmem_val_dib := "0000";          -- invalidate missed bytes
            end if;
            imem_reqw := '1';                 -- write back to main memory
            iackw := '1';                     -- and done
            n.state := s_idle;                -- next: back to idle
          end if;
          
        else                              -- request canceled -> restore
          icmem_tag_ceb := '1';             -- access cache line
          icmem_tag_web := '1';             -- write tag
          icmem_dat_ceb := '1';             -- access cache line
          icmem_dat_web := "1111";          -- restore cache line
          icmem_val_dib := icmem_val_doa;   -- cache restore: last state 
          n.state := s_idle;                -- next: back to idle          
        end if;  

      when others => null;
    end case;
    
    N_REGS <= n;

    CMEM_TAG_CEA <= icmem_tag_cea;
    CMEM_TAG_CEB <= icmem_tag_ceb;
    CMEM_TAG_WEA <= icmem_tag_wea;
    CMEM_TAG_WEB <= icmem_tag_web;
    CMEM_TAG_DIB <= icmem_tag_dib;
    CMEM_DAT_CEA <= icmem_dat_cea;
    CMEM_DAT_CEB <= icmem_dat_ceb;
    CMEM_DAT_WEA <= icmem_dat_wea;
    CMEM_DAT_WEB <= icmem_dat_web;
    
    CMEM_DIA_0(8)          <= '1';
    CMEM_DIA_0(7 downto 0) <= EM_MREQ.din( 7 downto 0);
    CMEM_DIA_1(8)          <= '1';
    CMEM_DIA_1(7 downto 0) <= EM_MREQ.din(15 downto 8);
    CMEM_DIA_2(8)          <= '1';
    CMEM_DIA_2(7 downto 0) <= EM_MREQ.din( 7 downto 0);
    CMEM_DIA_3(8)          <= '1';
    CMEM_DIA_3(7 downto 0) <= EM_MREQ.din(15 downto 8);

    CMEM_DIB_0(8)          <= icmem_val_dib(0);
    CMEM_DIB_0(7 downto 0) <= icmem_dat_dib(7 downto 0);
    CMEM_DIB_1(8)          <= icmem_val_dib(1);
    CMEM_DIB_1(7 downto 0) <= icmem_dat_dib(15 downto 8);
    CMEM_DIB_2(8)          <= icmem_val_dib(2);
    CMEM_DIB_2(7 downto 0) <= icmem_dat_dib(23 downto 16);
    CMEM_DIB_3(8)          <= icmem_val_dib(3);
    CMEM_DIB_3(7 downto 0) <= icmem_dat_dib(31 downto 24);

    EM_SRES <= em_sres_init;
    EM_SRES.ack_r <= iackr;
    EM_SRES.ack_w <= iackw;
    case iosel is
      when "00" => EM_SRES.dout <= icmem_dat_doa(15 downto  0);
      when "01" => EM_SRES.dout <= icmem_dat_doa(31 downto 16);
      when "10" => EM_SRES.dout <= MEM_DO(15 downto  0);
      when "11" => EM_SRES.dout <= MEM_DO(31 downto 16);
      when others => null;
    end case;
    
    CHIT  <= ichit;

    MEM_REQ  <= imem_reqr or imem_reqw;
    MEM_WE   <= imem_reqw;
    MEM_ADDR <= r.addr_t & r.addr_l;
    MEM_BE   <= imem_be;
    MEM_DI   <= r.di & r.di;
    
  end process proc_next;
  
end syn;
