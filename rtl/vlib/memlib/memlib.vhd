-- $Id: memlib.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2006-2007 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   memlib
-- Description:    Basic memory components: single/dual port synchronous and
--                 asynchronus rams; Fifo's.
--
-- Dependencies:   -
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2008-03-08   123   1.0.3  add ram_2swsr_xfirst_gen_unisim
-- 2008-03-02   122   1.0.2  change generic default for BRAM models
-- 2007-12-27   106   1.0.1  add fifo_2c_dram
-- 2007-06-03    45   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package memlib is

component ram_1swar_gen is              -- RAM, 1 sync w asyn r port
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
end component;
  
component ram_1swar_1ar_gen is          -- RAM, 1 sync w asyn r + 1 asyn r port
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
end component;

component ram_1swsr_wfirst_gen is       -- RAM, 1 sync r/w ports, write first
  generic (
    AWIDTH : positive := 10;            -- address port width
    DWIDTH : positive := 16);           -- data port width
  port(
    CLK  : in slbit;                    -- clock
    EN   : in slbit;                    -- enable
    WE   : in slbit;                    -- write enable
    ADDR : in slv(AWIDTH-1 downto 0);   -- address port
    DI   : in slv(DWIDTH-1 downto 0);   -- data in port
    DO   : out slv(DWIDTH-1 downto 0)   -- data out port
  );
end component;

component ram_1swsr_rfirst_gen is       -- RAM, 1 sync r/w ports, read first
  generic (
    AWIDTH : positive := 11;            -- address port width
    DWIDTH : positive :=  9);           -- data port width
  port(
    CLK  : in slbit;                    -- clock
    EN   : in slbit;                    -- enable
    WE   : in slbit;                    -- write enable
    ADDR : in slv(AWIDTH-1 downto 0);   -- address port
    DI   : in slv(DWIDTH-1 downto 0);   -- data in port
    DO   : out slv(DWIDTH-1 downto 0)   -- data out port
  );
end component;

component ram_2swsr_wfirst_gen is       -- RAM, 2 sync r/w ports, write first
  generic (
    AWIDTH : positive := 11;            -- address port width
    DWIDTH : positive :=  9);           -- data port width
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
end component;

component ram_2swsr_rfirst_gen is       -- RAM, 2 sync r/w ports, read first
  generic (
    AWIDTH : positive := 11;            -- address port width
    DWIDTH : positive :=  9);           -- data port width
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
end component;

component ram_1swsr_xfirst_gen_unisim is -- RAM, 1 sync r/w port
  generic (
    AWIDTH : positive := 11;            -- address port width
    DWIDTH : positive :=  9;            -- data port width
    WRITE_MODE : string := "READ_FIRST"); -- write mode: (READ|WRITE)_FIRST
  port(
    CLK  : in slbit;                    -- clock
    EN   : in slbit;                    -- enable
    WE   : in slbit;                    -- write enable
    ADDR : in slv(AWIDTH-1 downto 0);   -- address
    DI   : in slv(DWIDTH-1 downto 0);   -- data in
    DO   : out slv(DWIDTH-1 downto 0)   -- data out
  );
end component;

component ram_2swsr_xfirst_gen_unisim is -- RAM, 2 sync r/w ports
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
end component;

component fifo_1c_dram_raw is           -- fifo, 1 clock, dram based, raw
  generic (
    AWIDTH : positive :=  4;            -- address width (sets size)
    DWIDTH : positive := 16);           -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    WE : in slbit;                      -- write enable
    RE : in slbit;                      -- read enable
    DI : in slv(DWIDTH-1 downto 0);     -- input data
    DO : out slv(DWIDTH-1 downto 0);    -- output data
    SIZE : out slv(AWIDTH-1 downto 0);  -- number of used slots
    EMPTY : out slbit;                  -- empty flag
    FULL : out slbit                    -- full flag
  );
end component;

component fifo_1c_dram is               -- fifo, 1 clock, dram based
  generic (
    AWIDTH : positive :=  4;            -- address width (sets size)
    DWIDTH : positive := 16);           -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv(DWIDTH-1 downto 0);     -- input data
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv(DWIDTH-1 downto 0);    -- output data
    VAL : out slbit;                    -- read valid
    HOLD : in slbit;                    -- read hold
    SIZE : out slv(AWIDTH downto 0)     -- number of used slots
  );
end component;

component fifo_1c_bubble is             -- fifo, 1 clock, bubble regs
  generic (
    NSTAGE : positive :=  4;            -- number of stages
    DWIDTH : positive := 16);           -- data width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv(DWIDTH-1 downto 0);     -- input data
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv(DWIDTH-1 downto 0);    -- output data
    VAL : out slbit;                    -- read valid
    HOLD : in slbit                     -- read hold
  );
end component;

component fifo_2c_dram is               -- fifo, 2 clock, dram based
  generic (
    AWIDTH : positive :=  4;            -- address width (sets size)
    DWIDTH : positive := 16);           -- data width
  port (
    CLKW : in slbit;                    -- clock (write side)
    CLKR : in slbit;                    -- clock (read side)
    RESETW : in slbit;                  -- W|reset from write side
    RESETR : in slbit;                  -- R|reset from read side
    DI : in slv(DWIDTH-1 downto 0);     -- W|input data
    ENA : in slbit;                     -- W|write enable
    BUSY : out slbit;                   -- W|write port hold    
    DO : out slv(DWIDTH-1 downto 0);    -- R|output data
    VAL : out slbit;                    -- R|read valid
    HOLD : in slbit;                    -- R|read hold
    SIZEW : out slv(AWIDTH-1 downto 0); -- W|number slots to write
    SIZER : out slv(AWIDTH-1 downto 0)  -- R|number slots to read 
  );
end component;

end package memlib;
