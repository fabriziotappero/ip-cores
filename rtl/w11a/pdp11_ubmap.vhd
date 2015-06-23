-- $Id: pdp11_ubmap.vhd 641 2015-02-01 22:12:15Z mueller $
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
-- Module Name:    pdp11_ubmap - syn
-- Description:    pdp11: 11/70 unibus mapper
--
-- Dependencies:   memlib/ram_1swar_gen
--                 ib_sel
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.1.2  now numeric_std clean
-- 2010-10-23   335   1.1.1  use ib_sel
-- 2010-10-17   333   1.1    use ibus V2 interface
-- 2008-08-22   161   1.0.1  use iblib
-- 2008-01-27   115   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_ubmap is                   -- 11/70 unibus mapper
  port (
    CLK : in slbit;                     -- clock
    MREQ : in slbit;                    -- request mapping
    ADDR_UB : in slv18_1;               -- UNIBUS address (in)
    ADDR_PM : out slv22_1;              -- physical memory address (out)
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end pdp11_ubmap;

architecture syn of pdp11_ubmap is
  
  constant ibaddr_ubmap : slv16 := slv(to_unsigned(8#170200#,16));

  signal IBSEL_UBMAP : slbit := '0';

  signal MAP_2_WE : slbit := '0';
  signal MAP_1_WE : slbit := '0';
  signal MAP_0_WE : slbit := '0';
  signal MAP_ADDR : slv5 := (others => '0');     -- map regs address
  signal MAP_DOUT : slv22_1 := (others => '0');  -- map regs output

begin

  MAP_2 : ram_1swar_gen                 -- bit 21:16 of map regs
    generic map (
      AWIDTH => 5,
      DWIDTH => 6)
    port map (
      CLK  => CLK,
      WE   => MAP_2_WE,
      ADDR => MAP_ADDR,
      DI   => IB_MREQ.din(5 downto 0),
      DO   => MAP_DOUT(21 downto 16));

  MAP_1 : ram_1swar_gen                 -- bit 15:08 of map regs
    generic map (
      AWIDTH => 5,
      DWIDTH => 8)
    port map (
      CLK  => CLK,
      WE   => MAP_1_WE,
      ADDR => MAP_ADDR,
      DI   => IB_MREQ.din(15 downto 8),
      DO   => MAP_DOUT(15 downto 8));

  MAP_0 : ram_1swar_gen                 -- bit 07:01 of map regs
    generic map (
      AWIDTH => 5,
      DWIDTH => 7)
    port map (
      CLK  => CLK,
      WE   => MAP_0_WE,
      ADDR => MAP_ADDR,
      DI   => IB_MREQ.din(7 downto 1),
      DO   => MAP_DOUT(7 downto 1));

  SEL : ib_sel
    generic map (
      IB_ADDR => ibaddr_ubmap,
      SAWIDTH => 6)                     -- 2^6 = 64 = 2*32 words
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_UBMAP
    );

  proc_comb: process (MREQ, ADDR_UB, IBSEL_UBMAP, IB_MREQ, MAP_DOUT)
    variable ibusy : slbit := '0';
    variable idout : slv16 := (others=>'0');
    variable iwe2  : slbit := '0';
    variable iwe1  : slbit := '0';
    variable iwe0  : slbit := '0';
    variable iaddr : slv5 := (others=>'0');
  begin
    
    ibusy := '0';
    idout := (others=>'0');
    iwe2  := '0';
    iwe1  := '0';
    iwe0  := '0';
    iaddr := (others=>'0');

    if IBSEL_UBMAP = '1' then
      if IB_MREQ.addr(1) = '1' then
        idout(5 downto 0)  := MAP_DOUT(21 downto 16);
      else
        idout(15 downto 1) := MAP_DOUT(15 downto 1);
      end if;
      if MREQ = '1' then                -- if map request, stall ib cycle
        ibusy := '1';
      end if;
    end if;

    if IBSEL_UBMAP='1' and IB_MREQ.we='1' then
      if IB_MREQ.addr(1)='1' then
        if IB_MREQ.be0 = '1' then
          iwe2 := '1';
        end if;
      else
        if IB_MREQ.be1 = '1' then
          iwe1 := '1';
        end if;
        if IB_MREQ.be0 = '1' then
          iwe0 := '1';
        end if;
      end if;
    end if;

    if MREQ = '1' then
      iaddr := ADDR_UB(17 downto 13);
    else
      iaddr := IB_MREQ.addr(6 downto 2);
    end if;

    MAP_ADDR <= iaddr;
    MAP_2_WE <= iwe2;
    MAP_1_WE <= iwe1;
    MAP_0_WE <= iwe0;

    ADDR_PM  <= slv(unsigned(MAP_DOUT) +
                    unsigned("000000000"&ADDR_UB(12 downto 1)));

    IB_SRES.ack  <= IBSEL_UBMAP and (IB_MREQ.re or IB_MREQ.we);
    IB_SRES.busy <= ibusy;
    IB_SRES.dout <= idout;

  end process proc_comb;

end syn;
