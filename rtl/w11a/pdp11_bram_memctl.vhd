-- $Id: pdp11_bram_memctl.vhd 644 2015-02-08 22:56:54Z mueller $
--
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_bram_memctl - syn
-- Description:    pdp11: BRAM based memctl
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: 7-Series
-- Tool versions:  ise 14.7; viv 2014.4; ghdl 0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-08   644   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;
library unimacro;
use unimacro.vcomponents.all;

use work.slvtypes.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_bram_memctl is             -- BRAM based memctl
  generic (
    MAWIDTH : positive := 4;            -- mux address width
    NBLOCK : positive := 11);           -- write delay in clock cycles
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
    ADDR : in slv20;                    -- address
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32                      -- data out (memory view)
  );
end pdp11_bram_memctl;

architecture syn of pdp11_bram_memctl is
  
  type state_type is (
    s_idle,                             -- s_idle: wait for req
    s_read0,                            -- s_read0
    s_read1,                            -- s_read1
    s_write                             -- s_write
  );

  type regs_type is record
    state : state_type;                 -- state
    muxaddr : slv(MAWIDTH-1 downto 0);  -- mux  addr buffer
    celladdr : slv12;                   -- cell addr buffer
    cellen : slv(2**MAWIDTH-1 downto 0);-- cell enables
    cellwe : slv4;                      -- write enables
    dibuf : slv32;                      -- data in buffer
    dobuf : slv32;                      -- data out buffer
    ackr : slbit;                       -- signal ack_r
  end record regs_type;

  constant muxaddrzero : slv(MAWIDTH-1 downto 0) := (others=>'0');
  constant cellenzero : slv(2**MAWIDTH-1 downto 0) := (others=>'0');
  constant regs_init : regs_type := (
    s_idle,                             -- state
    muxaddrzero,                        -- muxaddr
    (others=>'0'),                      -- celladdr
    cellenzero,                         -- cellen
    (others=>'0'),                      -- cellwe
    (others=>'0'),                      -- dibuf
    (others=>'0'),                      -- dobuf
    '0'                                 -- ackr
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  type mem_do_type is array (NBLOCK-1 downto 0) of slv32;
  signal MEM_DO : mem_do_type := (others=> (others => '0'));
  
begin

  assert MAWIDTH <= 8
    report "assert(MAWIDTH <= 8)" severity failure;
  assert NBLOCK <= 2**MAWIDTH
    report "assert(NBLOCK <= 2**MAWIDTH)" severity failure;

  -- generate memory array
  --   4 colums, one for each byte of the 32 bit word
  --   NBLOCK rows, as many as one can afford ...
  
  MARRAY: for row in NBLOCK-1 downto 0 generate
    MROW: for col in 3 downto 0 generate
      signal WE : slv(0 downto 0) := "0";
    begin
      WE(0) <= R_REGS.cellwe(col);
      MCELL : BRAM_SINGLE_MACRO
        generic map (
          BRAM_SIZE   => "36Kb",
          DEVICE      => "7SERIES",
          WRITE_WIDTH => 8,
          READ_WIDTH  => 8,
          WRITE_MODE  => "WRITE_FIRST")
        port map (
          CLK   => CLK,
          RST   => '0',
          REGCE => '1',
          ADDR  => R_REGS.celladdr,
          EN    => R_REGS.cellen(row),
          WE    => WE,
          DI    => R_REGS.dibuf(8*col+7 downto 8*col),
          DO    => MEM_DO(row)(8*col+7 downto 8*col)
        );
    end generate MROW;
  end generate MARRAY;
  
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

  proc_next: process (R_REGS, ADDR, DI, REQ, WE, BE, MEM_DO)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibusy : slbit := '0';
    variable iackw : slbit := '0';
    variable iactr : slbit := '0';
    variable iactw : slbit := '0';
  begin

    r := R_REGS;
    n := R_REGS;
    n.ackr := '0';

    ibusy := '0';
    iackw := '0';
    iactr := '0';
    iactw := '0';

    case r.state is
      when s_idle =>                    -- s_idle: wait for req
        n.cellen   := (others=>'0');
        n.cellwe   := (others=>'0');
        if REQ = '1' then
          n.muxaddr  := ADDR(MAWIDTH-1+12 downto 12);
          n.celladdr := ADDR(11 downto 0);
          n.dibuf    := DI;
          n.cellen(to_integer(unsigned(ADDR(MAWIDTH-1+12 downto 12)))) := '1';
          if WE = '1' then
            n.cellwe := BE;
            n.state := s_write;
          else
            n.state := s_read0;
          end if;
        end if;
        
      when s_read0 =>                   -- s_read0
        ibusy   := '1';
        iactr   := '1';
        n.state := s_read1;

      when s_read1 =>                   -- s_read1
        ibusy   := '1';
        iactr   := '1';
        n.dobuf := MEM_DO(to_integer(unsigned(r.muxaddr)));
        n.ackr  := '1';
        n.state := s_idle;
        
      when s_write =>                   -- s_write
        ibusy   := '1';
        iactw   := '1';
        iackw   := '1';
        n.cellwe   := (others=>'0');
        n.state := s_idle;
        
      when others => null;
    end case;

    N_REGS <= n;

    BUSY  <= ibusy;
    ACK_R <= r.ackr;
    ACK_W <= iackw;
    ACT_R <= iactr;
    ACT_W <= iactw;
    DO    <= r.dobuf;
  end process proc_next;

end syn;
