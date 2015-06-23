-- $Id: ram_1swar_gen_unisim.vhd 686 2015-06-04 21:08:08Z mueller $
--
-- Copyright 2008- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ram_1swar_gen_unisim - syn
-- Description:    Single-Port RAM with with one synchronous write and one
--                 asynchronius read port (as distributed RAM).
--                 Direct instantiation of Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  ise 8.1-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2008-03-08   123   1.0.1  use shorter label names
-- 2008-03-02   122   1.0    Initial version 
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;

entity ram_1swar_gen is                 -- RAM, 1 sync w asyn r port
  generic (
    AWIDTH : positive :=  4;            -- address port width
    DWIDTH : positive := 16);           -- data port width
  port (
    CLK  : in slbit;                    -- clock
    WE   : in slbit;                    -- write enable
    ADDR : in slv(AWIDTH-1 downto 0);   -- address port
    DI   : in slv(DWIDTH-1 downto 0);   -- data in port
    DO   : out slv(DWIDTH-1 downto 0)   -- data out port
  );
end ram_1swar_gen;


architecture syn of ram_1swar_gen is

begin

  assert AWIDTH>=4 and AWIDTH<=6
    report "assert(AWIDTH>=4 and AWIDTH<=6): only 4..6 bit AWIDTH supported"
    severity failure;

  AW_4: if AWIDTH = 4 generate
    GL: for i in DWIDTH-1 downto 0 generate
      MEM : RAM16X1S
        generic map (
          INIT => X"0000")
        port map (
          O    => DO(i),
          A0   => ADDR(0),
          A1   => ADDR(1),
          A2   => ADDR(2),
          A3   => ADDR(3),
          D    => DI(i),
          WCLK => CLK,
          WE   => WE
        );
    end generate GL;
  end generate AW_4;

  AW_5: if AWIDTH = 5 generate
    GL: for i in DWIDTH-1 downto 0 generate
      MEM : RAM32X1S
        generic map (
          INIT => X"00000000")
        port map (
          O    => DO(i),
          A0   => ADDR(0),
          A1   => ADDR(1),
          A2   => ADDR(2),
          A3   => ADDR(3),
          A4   => ADDR(4),
          D    => DI(i),
          WCLK => CLK,
          WE   => WE
        );
    end generate GL;
  end generate AW_5;

  AW_6: if AWIDTH = 6 generate
    GL: for i in DWIDTH-1 downto 0 generate
      MEM : RAM64X1S
        generic map (
          INIT => X"0000000000000000")
        port map (
          O    => DO(i),
          A0   => ADDR(0),
          A1   => ADDR(1),
          A2   => ADDR(2),
          A3   => ADDR(3),
          A4   => ADDR(4),
          A5   => ADDR(5),
          D    => DI(i),
          WCLK => CLK,
          WE   => WE
        );
    end generate GL;
  end generate AW_6;

end syn;
