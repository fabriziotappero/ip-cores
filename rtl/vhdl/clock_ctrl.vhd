-------------------------------------------------------------------------------
--
-- The Clock Control unit.
-- Clock States and Machine Cycles are generated here.
--
-- $Id: clock_ctrl.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, 2005, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--      http://www.opencores.org/cvsweb.shtml/t48/
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.t48_pack.all;

entity t48_clock_ctrl is

  generic (
    -- divide XTAL1 by 3 to derive Clock States
    xtal_div_3_g : integer := 1
  );

  port (
    clk_i          : in  std_logic;
    xtal_i         : in  std_logic;
    xtal_en_i      : in  boolean;
    res_i          : in  std_logic;
    en_clk_i       : in  boolean;
    xtal3_o        : out boolean;
    t0_o           : out std_logic;
    multi_cycle_i  : in  boolean;
    assert_psen_i  : in  boolean;
    assert_prog_i  : in  boolean;
    assert_rd_i    : in  boolean;
    assert_wr_i    : in  boolean;
    mstate_o       : out mstate_t;
    second_cycle_o : out boolean;
    ale_o          : out boolean;
    psen_o         : out boolean;
    prog_o         : out boolean;
    rd_o           : out boolean;
    wr_o           : out boolean
  );

end t48_clock_ctrl;


library ieee;
use ieee.numeric_std.all;

architecture rtl of t48_clock_ctrl is

  -- The three XTAL1 cycles.
  signal xtal_q  : unsigned(1 downto 0);
  signal xtal1_s,
         xtal2_s,
         xtal3_s : boolean;
  signal x1_s,
         x2_s,
         x3_s    : std_logic;

  signal t0_q    : std_logic;


  -- The five clock states.
  signal mstate_q  : mstate_t;

  signal ale_q     : boolean;
  signal psen_q    : boolean;
  signal prog_q    : boolean;
  signal rd_q      : boolean;
  signal wr_q      : boolean;


  -- The Machine Cycle marker.
  signal second_cycle_q : boolean;
  signal multi_cycle_q  : boolean;

begin

  -----------------------------------------------------------------------------
  -- Verify the generics
  -----------------------------------------------------------------------------

  -- pragma translate_off

  -- XTAL1 divide by 3 --------------------------------------------------------
  assert (xtal_div_3_g = 1) or (xtal_div_3_g = 0)
    report "xtal_div_3_g must be either 1 or 0!"
    severity failure;

  -- pragma translate_on


  -----------------------------------------------------------------------------
  -- Divide XTAL1 by 3 to derive Clock States.
  -----------------------------------------------------------------------------
  use_xtal_div: if xtal_div_3_g = 1 generate
    xtal: process (res_i, xtal_i)
    begin
      if res_i = res_active_c then
        xtal_q <= TO_UNSIGNED(0, 2);
        t0_q   <= '0';

      elsif xtal_i'event and xtal_i = clk_active_c then
        if xtal_en_i then
          if xtal_q < 2 then
            xtal_q <= xtal_q + 1;
          else
            xtal_q <= TO_UNSIGNED(0, 2);
          end if;

          if xtal3_s then
            t0_q <= '1';
          else
            t0_q <= '0';
          end if;

        end if;

      end if;
    end process xtal;

    x1_s <=   '1'
            when xtal_q = 0 and xtal_en_i else
              '0';
    x2_s <=   '1'
            when xtal_q = 1 and xtal_en_i else
              '0';
    x3_s <=   '1'
            when xtal_q = 2 and xtal_en_i else
              '0';
    t0_o <= t0_q;

  end generate;

  -----------------------------------------------------------------------------
  -- XTAL1 is used directly for Clock States.
  -----------------------------------------------------------------------------
  no_xtal_div: if xtal_div_3_g = 0 generate
    xtal_q <= TO_UNSIGNED(0, 2);

    x1_s <=   '1'
            when xtal_en_i else
              '0';
    x2_s <=   '1'
            when xtal_en_i else
              '0';
    x3_s <=   '1'
            when xtal_en_i else
              '0';
    t0_o <= xtal_i;

  end generate;

  -- And finally the boolean flags --------------------------------------------
  xtal1_s <= to_boolean(x1_s);
  xtal2_s <= to_boolean(x2_s);
  xtal3_s <= to_boolean(x3_s);


  -----------------------------------------------------------------------------
  -- Process external_signal
  --
  -- Purpose:
  --   Control signals ALE, PSEN, PROG and RD/WR are generated here.
  --
  external_signals: process (res_i, xtal_i)
  begin
    if res_i = res_active_c then
      ale_q    <= false;
      psen_q   <= false;
      prog_q   <= false;
      rd_q     <= false;
      wr_q     <= false;

    elsif xtal_i'event and xtal_i = clk_active_c then

      case mstate_q is
        when MSTATE5 => 
          -- RD, WR are set at the end of XTAL2 of first machine cycle
          if xtal2_s and not second_cycle_q then
            if assert_rd_i then
              rd_q <= true;
            end if;
            if assert_wr_i then
              wr_q <= true;
            end if;
          end if;

        when MSTATE1 => 
          if xtal3_s then
             psen_q   <= false;
           end if;

        when MSTATE2 =>
          if xtal3_s then
            -- RD, WR are removed at the end of XTAL3 of second machine cycle
            rd_q     <= false;
            wr_q     <= false;
            -- so is PROG
            prog_q   <= false;
          end if;

        when MSTATE3 => 
          -- ALE is set at the end of XTAL3 of every machine cycle
          if xtal3_s then
            ale_q    <= true;
          end if;

        when MSTATE4 => 
          if xtal3_s then
            -- PSEN is set at the end of XTAL3
            if assert_psen_i then
              psen_q <= true;
            end if;

          end if;

          -- PROG is set at the end of XTAL3
          if xtal3_s and
             multi_cycle_q and not second_cycle_q and assert_prog_i then
            prog_q <= true;
          end if;

          -- ALE is removed at the end of XTAL2 of every machine cycle
          if xtal2_s then
            ale_q    <= false;
          end if;

      when others => 
        -- recover when states are out of sync
        ale_q    <= false;
        psen_q   <= false;
        prog_q   <= false;
        rd_q     <= false;
        wr_q     <= false;

      end case;

    end if;

  end process external_signals;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process states
  --
  -- Purpose:
  --   The Clock State controller.
  --
  states: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      -- Reset machine state to MSTATE3
      -- This allows a proper instruction fetch for the first real instruction
      -- after reset.
      -- The MSTATE3 is part of a virtual NOP that has no MSTATE1 and MSTATE2.
      mstate_q <= MSTATE3;

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        case mstate_q is
          when MSTATE5 => 
            mstate_q <= MSTATE1;

          when MSTATE1 => 
            mstate_q <= MSTATE2;

          when MSTATE2 => 
            mstate_q <= MSTATE3;

          when MSTATE3 => 
            mstate_q <= MSTATE4;

          when MSTATE4 => 
            mstate_q <= MSTATE5;

          when others => 
            -- recover when states are out of sync
            mstate_q <= MSTATE1;

            -- pragma translate_off
            assert false
              report "Encoding of Clock States failed!"
              severity error;
            -- pragma translate_on

        end case;

      end if;

    end if;

  end process states;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process machine_cycle
  --
  -- Purpose:
  --   Keep track of machine cycles.
  --   Basically, this means to differ between first and second cycle.
  --
  machine_cycle: process (res_i, clk_i)
    variable state2_v, state5_v : boolean;
  begin
    if res_i = res_active_c then
      multi_cycle_q  <= false;
      second_cycle_q <= false;

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        state2_v := mstate_q = MSTATE2;
        state5_v := mstate_q = MSTATE5;
        
        -- multi cycle information is delivered in State 2 from the decoder
        if state2_v and multi_cycle_i then
          multi_cycle_q <= true;
        end if;

        -- mark second machine cycle
        if multi_cycle_q and state5_v then
          second_cycle_q <= true;
        end if;

        -- reset at end of second machine cycle
        if state5_v and
           (multi_cycle_q and second_cycle_q) then
          multi_cycle_q  <= false;
          second_cycle_q <= false;
        end if;

      end if;

    end if;

  end process machine_cycle;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output assignments
  -----------------------------------------------------------------------------
  xtal3_o        <= xtal3_s;
  mstate_o       <= mstate_q;
  second_cycle_o <= second_cycle_q;
  ale_o          <= ale_q;
  psen_o         <= psen_q;
  prog_o         <= prog_q;
  rd_o           <= rd_q;
  wr_o           <= wr_q;

end rtl;
