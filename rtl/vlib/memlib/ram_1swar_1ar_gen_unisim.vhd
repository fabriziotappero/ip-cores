-- $Id: ram_1swar_1ar_gen_unisim.vhd 686 2015-06-04 21:08:08Z mueller $
--
-- Copyright 2008-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ram_1swar_1ar_gen - syn
-- Description:    Dual-Port RAM with with one synchronous write and two
--                 asynchronius read ports (as distributed RAM).
--                 Direct instantiation of Xilinx UNISIM primitives
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic Spartan, Virtex
-- Tool versions:  ise 8.1-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-03   300   1.1    add hack for AW=5 for Spartan's
-- 2008-03-08   123   1.0.1  use shorter label names
-- 2008-03-02   122   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ALL;

use work.slvtypes.all;

entity ram_1swar_1ar_gen is             -- RAM, 1 sync w asyn r + 1 asyn r port
  generic (
    AWIDTH : positive :=  4;            -- address port width
    DWIDTH : positive := 16);           -- data port width
  port (
    CLK   : in slbit;                   -- clock
    WE    : in slbit;                   -- write enable (port A)
    ADDRA : in slv(AWIDTH-1 downto 0);  -- address port A
    ADDRB : in slv(AWIDTH-1 downto 0);  -- address port B
    DI    : in slv(DWIDTH-1 downto 0);  -- data in (port A)
    DOA   : out slv(DWIDTH-1 downto 0); -- data out port A
    DOB   : out slv(DWIDTH-1 downto 0)  -- data out port B
  );
end ram_1swar_1ar_gen;


architecture syn of ram_1swar_1ar_gen is

begin

  assert AWIDTH>=4 and AWIDTH<=5
    report "assert(AWIDTH>=4 and AWIDTH<=5): only 4..5 bit AWIDTH supported"
    severity failure;

  AW_4: if AWIDTH = 4 generate
    GL: for i in DWIDTH-1 downto 0 generate
      MEM : RAM16X1D
        generic map (
          INIT => X"0000")
        port map (
          DPO   => DOB(i),
          SPO   => DOA(i),
          A0    => ADDRA(0),
          A1    => ADDRA(1),
          A2    => ADDRA(2),
          A3    => ADDRA(3),
          D     => DI(i),
          DPRA0 => ADDRB(0),
          DPRA1 => ADDRB(1),
          DPRA2 => ADDRB(2),
          DPRA3 => ADDRB(3),
          WCLK  => CLK,
          WE    => WE
        );
    end generate GL;
  end generate AW_4;

  -- Note: Spartan-3 doesn't support RAM32X1D, therefore this kludge..
  AW_5: if AWIDTH = 5 generate
    signal WE0 : slbit := '0';
    signal WE1 : slbit := '0';
    signal DOA0 : slv(DWIDTH-1 downto 0) := (others=>'0');
    signal DOA1 : slv(DWIDTH-1 downto 0) := (others=>'0');
    signal DOB0 : slv(DWIDTH-1 downto 0) := (others=>'0');
    signal DOB1 : slv(DWIDTH-1 downto 0) := (others=>'0');
  begin
    WE0 <= WE and not ADDRA(4);
    WE1 <= WE and     ADDRA(4);
    GL: for i in DWIDTH-1 downto 0 generate
      MEM0 : RAM16X1D
        generic map (
          INIT => X"0000")
        port map (
          DPO   => DOB0(i),
          SPO   => DOA0(i),
          A0    => ADDRA(0),
          A1    => ADDRA(1),
          A2    => ADDRA(2),
          A3    => ADDRA(3),
          D     => DI(i),
          DPRA0 => ADDRB(0),
          DPRA1 => ADDRB(1),
          DPRA2 => ADDRB(2),
          DPRA3 => ADDRB(3),
          WCLK  => CLK,
          WE    => WE0
        );
      MEM1 : RAM16X1D
        generic map (
          INIT => X"0000")
        port map (
          DPO   => DOB1(i),
          SPO   => DOA1(i),
          A0    => ADDRA(0),
          A1    => ADDRA(1),
          A2    => ADDRA(2),
          A3    => ADDRA(3),
          D     => DI(i),
          DPRA0 => ADDRB(0),
          DPRA1 => ADDRB(1),
          DPRA2 => ADDRB(2),
          DPRA3 => ADDRB(3),
          WCLK  => CLK,
          WE    => WE1
        );
      DOA <= DOA0 when ADDRA(4)='0' else DOA1;
      DOB <= DOB0 when ADDRB(4)='0' else DOB1;
    end generate GL;
  end generate AW_5;

--  AW_6: if AWIDTH = 6 generate
--    GL: for i in DWIDTH-1 downto 0 generate
--      MEM : RAM64X1D
--        generic map (
--          INIT => X"0000000000000000")
--        port map (
--          DPO   => DOB(i),
--          SPO   => DOA(i),
--          A0    => ADDRA(0),
--          A1    => ADDRA(1),
--          A2    => ADDRA(2),
--          A3    => ADDRA(3),
--          A4    => ADDRA(4),
--          A5    => ADDRA(5),
--          D     => DI(i),
--          DPRA0 => ADDRB(0),
--          DPRA1 => ADDRB(1),
--          DPRA2 => ADDRB(2),
--          DPRA3 => ADDRB(3),
--          DPRA4 => ADDRB(4),
--          DPRA5 => ADDRB(5),
--          WCLK  => CLK,
--          WE    => WE
--        );
--    end generate GL;
--  end generate AW_6;

end syn;

-- Note: The VHDL instantiation example in the 8.1i Librariers Guide is wrong.
--       The annotation states that DPO is the port A output and SPO is port B
--       output. The text before is correct, DPO is port B and SPO is port A.
