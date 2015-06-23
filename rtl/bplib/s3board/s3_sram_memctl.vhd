-- $Id: s3_sram_memctl.vhd 649 2015-02-21 21:10:16Z mueller $
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
-- Module Name:    s3_sram_memctl - syn
-- Description:    s3board: SRAM driver
--
-- Dependencies:   vlib/xlib/iob_reg_o
--                 vlib/xlib/iob_reg_o_gen
--                 vlib/xlib/iob_reg_io_gen
-- Test bench:     tb/tb_s3_sram_memctl
--                 fw_gen/tst_sram/s3board/tb/tb_tst_sram_s3
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-05-23   293  11.4   L68  xc3s1000-4     7   22    0   14 s  8.5
-- 2008-02-16   116  8.2.03 I34  xc3s1000-4     5   30    0   17 s  7.0
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-19   427   1.0.6  now numeric_std clean
-- 2010-06-03   299   1.0.5  add "KEEP" for data iob;
-- 2010-05-16   291   1.0.4  rename memctl_s3sram -> s3_sram_memctl
-- 2008-02-17   117   1.0.3  use req,we rather req_r,req_w interface
-- 2008-01-20   113   1.0.2  rename memdrv -> memctl_s3sram
-- 2007-12-15   101   1.0.1  use _N for active low; get ce/we clocking right
-- 2007-12-08   100   1.0    Initial version 
--
-- Timing of some signals:
--
-- single read request:
-- 
-- state       |_idle  |_read  |_idle  |
-- 
-- CLK       __|^^^|___|^^^|___|^^^|___|^
-- 
-- REQ       _______|^^^^^|______________
-- WE        ____________________________
-- 
-- IOB_CE    __________|^^^^^^^|_________
-- IOB_OE    __________|^^^^^^^|_________
-- 
-- DO        oooooooooooooooooo|ddddddd|d
-- BUSY      ____________________________
-- ACK_R     __________________|^^^^^^^|_
-- 
-- single write request:
-- 
-- state       |_idle  |_write1|_write2|_idle  |
-- 
-- CLK       __|^^^|___|^^^|___|^^^|___|^^^|___|^
-- 
-- REQ       _______|^^^^^|______________
-- WE        _______|^^^^^|______________
-- 
-- IOB_CE    __________|^^^^^^^^^^^^^^^|_________
-- IOB_BE    __________|^^^^^^^^^^^^^^^|_________
-- IOB_OE    ____________________________________
-- IOB_WE    ______________|^^^^^^^|_____________
-- 
-- BUSY      __________|^^^^^^^|_________________
-- ACK_W     __________________|^^^^^^^|_________
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;

entity s3_sram_memctl is                -- SRAM driver for S3BOARD
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY : out slbit;                   -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR : in slv18;                    -- address
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32;                     -- data out (memory view)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end s3_sram_memctl;


architecture syn of s3_sram_memctl is

  type state_type is (
    s_idle,                             -- s_idle: wait for req
    s_read,                             -- s_read: read cycle
    s_write1,                           -- s_write1: write cycle, 1st half
    s_write2,                           -- s_write2: write cycle, 2nd half
    s_bta_r2w,                          -- s_bta_r2w: bus turn around: r->w
    s_bta_w2r                           -- s_bta_w2r: bus turn around: w->r
  );
  
  type regs_type is record
    state : state_type;                 -- state
    ackr : slbit;                       -- signal ack_r
  end record regs_type;

  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0'                                 -- ackr
  );
    
  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs
  
  signal CLK_180  : slbit := '0';
  signal MEM_CE_N : slv2 := "00";
  signal MEM_BE_N : slv4 := "0000";
  signal MEM_WE_N : slbit := '0';
  signal MEM_OE_N : slbit := '0';
  signal ADDR_CE  : slbit := '0';
  signal DATA_CEI : slbit := '0';
  signal DATA_CEO : slbit := '0';
  signal DATA_OE  : slbit := '0';

begin

  CLK_180 <= not CLK;
  
  IOB_MEM_CE : iob_reg_o_gen
    generic map (
      DWIDTH => 2,
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => MEM_CE_N,
      PAD => O_MEM_CE_N
    );
  
  IOB_MEM_BE : iob_reg_o_gen
    generic map (
      DWIDTH => 4,
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => ADDR_CE,
      DO  => MEM_BE_N,
      PAD => O_MEM_BE_N
    );
  
  IOB_MEM_WE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK_180,
      CE  => '1',
      DO  => MEM_WE_N,
      PAD => O_MEM_WE_N
    );
  
  IOB_MEM_OE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => MEM_OE_N,
      PAD => O_MEM_OE_N
    );
  
  IOB_MEM_ADDR : iob_reg_o_gen
    generic map (
      DWIDTH => 18)
    port map (
      CLK => CLK,
      CE  => ADDR_CE,
      DO  => ADDR,
      PAD => O_MEM_ADDR
    );
  
  IOB_MEM_DATA : iob_reg_io_gen
    generic map (
      DWIDTH => 32,
      PULL   => "KEEP")
    port map (
      CLK => CLK,
      CEI => DATA_CEI,
      CEO => DATA_CEO,
      OE  => DATA_OE,
      DI  => DO,
      DO  => DI,
      PAD => IO_MEM_DATA
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

  proc_next: process (R_REGS, REQ, WE, BE)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibusy : slbit := '0';
    variable iackw : slbit := '0';
    variable iactr : slbit := '0';
    variable iactw : slbit := '0';
    variable imem_ce : slv2 := "00";
    variable imem_be : slv4 := "0000";
    variable imem_we : slbit := '0';
    variable imem_oe : slbit := '0';
    variable iaddr_ce  : slbit := '0';
    variable idata_cei : slbit := '0';
    variable idata_ceo : slbit := '0';
    variable idata_oe  : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;
    n.ackr := '0';

    ibusy := '0';
    iackw := '0';
    iactr := '0';
    iactw := '0';

    imem_ce := "00";
    imem_be := "1111";
    imem_we := '0';
    imem_oe := '0';
    iaddr_ce  := '0';
    idata_cei := '0';
    idata_ceo := '0';
    idata_oe  := '0';
    
    case r.state is
      when s_idle =>                    -- s_idle: wait for req
        if REQ = '1' then                 -- if IO requested
          if WE = '0' then                  -- if READ requested
            iaddr_ce := '1';                  -- latch address and be's
            imem_ce  := "11";                 -- ce SRAM next cycle
            imem_oe  := '1';                  -- oe SRAM next cycle
            n.state := s_read;                -- next: read
          else                              -- if WRITE requested
            iaddr_ce  := '1';                 -- latch address and be's
            idata_ceo := '1';                 -- latch output data
            idata_oe  := '1';                 -- oe FPGA next cycle
            imem_ce   := "11";                -- ce SRAM next cycle
            imem_be   := BE;                  -- use request BE's
            n.state := s_write1;              -- next: write 1st part
          end if;
        end if;
        
      when s_read =>                    -- s_read: read cycle
        idata_cei := '1';                 -- latch input data
        iactr := '1';                     -- signal mem read
        n.ackr := '1';                    -- ACK_R next cycle
        if REQ = '1' then                 -- if IO requested
          if WE = '0' then                  -- if READ requested
            iaddr_ce := '1';                  -- latch address and be's
            imem_ce  := "11";                 -- ce SRAM next cycle
            imem_oe  := '1';                  -- oe SRAM next cycle
            n.state := s_read;                -- next: continue read
          else                              -- if WRITE requested
            iaddr_ce  := '1';                 -- latch address and be's
            idata_ceo := '1';                 -- latch output data
            imem_be   := BE;                  -- use request BE's
            n.state := s_bta_r2w;             -- next: bus turn around cycle
          end if;
        else
          n.state := s_idle;              -- next: idle if nothing to do
        end if;

      when s_write1 =>                  -- s_write1: write cycle, 1st half
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        idata_oe := '1';                  -- oe FPGA next cycle
        imem_ce  := "11";                 -- ce SRAM next cycle
        imem_we  := '1';                  -- we SRAM next shifted cycle
        n.state := s_write2;              -- next: write cycle, 2nd half
        
      when s_write2 =>                  -- s_write2: write cycle, 2nd half
        iactw := '1';                     -- signal mem write
        iackw := '1';                     -- signal write acknowledge
        idata_cei := '1';                 -- latch input data (from SRAM)
        if REQ = '1' then                 -- if IO requested
          if WE = '1' then                  -- if WRITE requested
            iaddr_ce  := '1';                 -- latch address and be's
            idata_ceo := '1';                 -- latch output data
            idata_oe  := '1';                 -- oe FPGA next cycle
            imem_ce   := "11";                -- ce SRAM next cycle
            imem_be   := BE;                  -- use request BE's
            n.state := s_write1;              -- next: continue read
          else                              -- if READ requested
            iaddr_ce := '1';                  -- latch address and be's
            n.state := s_bta_w2r;             -- next: bus turn around cycle
          end if;
        else
          n.state := s_idle;              -- next: idle if nothing to do
        end if;
        
      when s_bta_r2w =>                 -- s_bta_r2w: bus turn around: r->w
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        imem_ce  := "11";                 -- ce SRAM next cycle
        idata_oe := '1';                  -- oe FPGA next cycle
        n.state := s_write1;              -- next: start write
        
      when s_bta_w2r =>                 -- s_bta_w2r: bus turn around: w->r
        ibusy := '1';                     -- signal busy, unable to handle req
        iactr := '1';                     -- signal mem read
        imem_ce := "11";                  -- ce SRAM next cycle
        imem_oe := '1';                   -- oe SRAM next cycle
        n.state := s_read;                -- next: start read

      when others => null;
    end case;
    
    N_REGS <= n;

    MEM_CE_N <= not imem_ce;
    MEM_WE_N <= not imem_we;
    MEM_BE_N <= not imem_be;
    MEM_OE_N <= not imem_oe;
    ADDR_CE  <= iaddr_ce;
    DATA_CEI <= idata_cei;
    DATA_CEO <= idata_ceo;
    DATA_OE  <= idata_oe;

    BUSY  <= ibusy;
    ACK_R <= r.ackr;
    ACK_W <= iackw;
    ACT_R <= iactr;
    ACT_W <= iactw;
    
  end process proc_next;
  
end syn;
