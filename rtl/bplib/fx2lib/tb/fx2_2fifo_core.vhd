-- $Id: fx2_2fifo_core.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    fx2_2fifo_core - sim
-- Description:    Cypress EZ-USB FX2 (2 fifo core model)
--
-- Dependencies:   memlib/fifo_2c_dram
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2013-01-04   469   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simbus.all;
use work.fx2lib.all;
use work.memlib.all;

entity fx2_2fifo_core is                -- EZ-USB FX2 (2 fifo core model)
  port (
    CLK : in slbit;                     -- uplink clock
    RESET : in slbit;                   -- reset
    RXDATA : in slv8;                   -- rx data   (ext->fx2)
    RXENA  : in slbit;                  -- rx enable
    RXBUSY  : out slbit;                -- rx busy
    TXDATA : out slv8;                  -- tx data   (fx2->ext)
    TXVAL  : out slbit;                 -- tx valid
    IFCLK : out slbit;                  -- fx2 interface clock
    FIFO : in slv2;                     -- fx2 fifo address
    FLAG : out slv4;                    -- fx2 fifo flags
    SLRD_N : in slbit;                  -- fx2 read enable    (act.low)
    SLWR_N : in slbit;                  -- fx2 write enable   (act.low)
    SLOE_N : in slbit;                  -- fx2 output enable  (act.low)
    PKTEND_N : in slbit;                -- fx2 packet end     (act.low)
    DATA : inout slv8                   -- fx2 data lines
  );
end fx2_2fifo_core;


architecture sim of fx2_2fifo_core is
  
  constant c_rxfifo : slv2 := c_fifo_ep4;
  constant c_txfifo : slv2 := c_fifo_ep6;

  constant c_flag_prog   : integer := 0;
  constant c_flag_tx_ff  : integer := 1;
  constant c_flag_rx_ef  : integer := 2;
  constant c_flag_tx2_ff : integer := 3;

  constant bufsize : positive := 1024;
  constant datzero : slv(DATA'range) := (others=>'0');
  type buf_type is array (0 to bufsize-1) of slv(DATA'range);

  signal CLK30 : slbit := '0';

  signal RXFIFO_DO : slv8 := (others=>'0');
  signal RXFIFO_VAL : slbit := '0';
  signal RXFIFO_HOLD : slbit := '0';
  signal TXFIFO_DI : slv8 := (others=>'0');
  signal TXFIFO_ENA : slbit := '0';
  signal TXFIFO_BUSY : slbit := '0';

  signal R_FLAG : slv4 := (others=>'0');
  signal R_DATA : slv8 := (others=>'0');

  -- added for debug purposes
  signal R_rxbuf_rind : natural := 0;
  signal R_rxbuf_wind : natural := 0;
  signal R_rxbuf_nbyt : natural := 0;
  signal R_txbuf_rind : natural := 0;
  signal R_txbuf_wind : natural := 0;
  signal R_txbuf_nbyt : natural := 0;
  
begin

  RXFIFO : fifo_2c_dram
    generic map (
      AWIDTH => 5,
      DWIDTH => 8)
    port map (
      CLKW   => CLK,
      CLKR   => CLK30,
      RESETW => '0',
      RESETR => '0',
      DI     => RXDATA,
      ENA    => RXENA,
      BUSY   => RXBUSY,
      DO     => RXFIFO_DO,
      VAL    => RXFIFO_VAL,
      HOLD   => RXFIFO_HOLD,
      SIZEW  => open,
      SIZER  => open
    );

  TXFIFO : fifo_2c_dram
    generic map (
      AWIDTH => 5,
      DWIDTH => 8)
    port map (
      CLKW   => CLK30,
      CLKR   => CLK,
      RESETW => '0',
      RESETR => '0',
      DI     => TXFIFO_DI,
      ENA    => TXFIFO_ENA,
      BUSY   => TXFIFO_BUSY,
      DO     => TXDATA,
      VAL    => TXVAL,
      HOLD   => '0',
      SIZEW  => open,
      SIZER  => open
    );

  proc_ifclk: process
    constant offset : time := 200 ns;
    constant halfperiod_7 : time := 16700 ps;
    constant halfperiod_6 : time := 16600 ps;
  begin

    CLK30 <= '0';
    wait for offset;

    clk_loop: loop
      CLK30 <= '1';
      wait for halfperiod_7;
      CLK30 <= '0';
      wait for halfperiod_7;
      CLK30 <= '1';
      wait for halfperiod_6;
      CLK30 <= '0';
      wait for halfperiod_7;
      CLK30 <= '1';
      wait for halfperiod_7;
      CLK30 <= '0';
      wait for halfperiod_6;
      exit clk_loop when to_x01(SB_CLKSTOP) = '1';
    end loop;    
    
    wait;                               -- endless wait, simulator will stop
    
  end process proc_ifclk;

  proc_state: process (CLK30)
    variable rxbuf : buf_type := (others=>datzero);
    variable rxbuf_rind : natural := 0;
    variable rxbuf_wind : natural := 0;
    variable rxbuf_nbyt : natural := 0;

    variable txbuf : buf_type := (others=>datzero);
    variable txbuf_rind : natural := 0;
    variable txbuf_wind : natural := 0;
    variable txbuf_nbyt : natural := 0;

    variable oline : line;

  begin

    if rising_edge(CLK30) then

      RXFIFO_HOLD <= '0';
      TXFIFO_ENA  <= '0';

      -- rxfifo -> rxbuf
      if RXFIFO_VAL = '1' then
        if rxbuf_nbyt < bufsize then
          rxbuf(rxbuf_wind) := RXFIFO_DO;
          rxbuf_wind := (rxbuf_wind + 1) mod bufsize;
          rxbuf_nbyt := rxbuf_nbyt + 1;
        else
          RXFIFO_HOLD <= '1';
        end if;
      end if;

      -- txbuf -> txfifo
      if txbuf_nbyt>0 and TXFIFO_BUSY='0' then
        TXFIFO_DI  <= txbuf(txbuf_rind);
        TXFIFO_ENA <= '1';
        txbuf_rind := (txbuf_rind + 1) mod bufsize;
        txbuf_nbyt := txbuf_nbyt - 1;
      end if;

      -- slrd cycle: rxbuf -> data
      if SLRD_N = '0' then
        if rxbuf_nbyt > 0 then
          rxbuf_rind := (rxbuf_rind + 1) mod bufsize;
          rxbuf_nbyt := rxbuf_nbyt - 1;
        else
          write(oline, string'("fx2_2fifo_core: SLRD_N=0 when rxbuf empty"));
          writeline(output, oline);
        end if;
      end if;
      R_DATA <= rxbuf(rxbuf_rind);
      
      -- slwr cycle: data -> txbuf
      if SLWR_N = '0' then
        if txbuf_nbyt < bufsize then
          txbuf(txbuf_wind) := DATA;
          txbuf_wind := (txbuf_wind + 1) mod bufsize;
          txbuf_nbyt := txbuf_nbyt + 1;
        else
          write(oline, string'("fx2_2fifo_core: SLWR_N=0 when txbuf full"));
          writeline(output, oline);
        end if;
      end if;

      -- prepare flags (note that FLAGs are act.low!)
      R_FLAG <= (others=>'1');
      --   FLAGA = indexed, PF
      --     rx endpoint -> PF 'almost empty' at 3 bytes to go
      if FIFO = c_rxfifo then
        if rxbuf_nbyt < 4 then
          R_FLAG(0) <= '0';
        end if;
      --     tx endpoint -> PF 'almost full' at 3 bytes to go
      elsif FIFO = c_txfifo then
        if txbuf_nbyt > bufsize-4 then
          R_FLAG(0) <= '0';
        end if;
      end if;

      --   FLAGB = EP6 FF
      if txbuf_nbyt = bufsize then
        R_FLAG(1) <= '0';
      end if;

      --   FLAGC = EP4 EF
      if rxbuf_nbyt = 0 then
        R_FLAG(2) <= '0';
      end if;
      
      --   FLAGD = EP8 FF
      R_FLAG(3) <= '1';

      -- added for debug purposes
      R_rxbuf_rind <= rxbuf_rind;
      R_rxbuf_wind <= rxbuf_wind;
      R_rxbuf_nbyt <= rxbuf_nbyt;
      R_txbuf_rind <= txbuf_rind;
      R_txbuf_wind <= txbuf_wind;
      R_txbuf_nbyt <= txbuf_nbyt;
      
    end if;
    
  end process proc_state;

  IFCLK <= CLK30;
  FLAG  <= R_FLAG;

  proc_data: process (SLOE_N, R_DATA)
  begin
    if SLOE_N = '1' then
      DATA <= (others=>'Z');
    else
      DATA <= R_DATA;
    end if;
  end process proc_data;
  
end sim;
