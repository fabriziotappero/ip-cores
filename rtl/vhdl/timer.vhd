-------------------------------------------------------------------------------
--
-- The Timer/Counter unit.
--
-- $Id: timer.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
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

use work.t48_pack.word_t;
use work.t48_pack.mstate_t;

entity t48_timer is

  generic (
    -- state in which T1 is sampled (3 or 4)
    sample_t1_state_g : integer := 4
  );

  port (
    -- Global Interface -------------------------------------------------------
    clk_i         : in  std_logic;
    res_i         : in  std_logic;
    en_clk_i      : in  boolean;
    t1_i          : in  std_logic;
    clk_mstate_i  : in  mstate_t;
    -- T48 Bus Interface ------------------------------------------------------
    data_i        : in  word_t;
    data_o        : out word_t;
    read_timer_i  : in  boolean;
    write_timer_i : in  boolean;
    -- Decoder Interface ------------------------------------------------------
    start_t_i     : in  boolean;
    start_cnt_i   : in  boolean;
    stop_tcnt_i   : in  boolean;
    overflow_o    : out std_logic
  );

end t48_timer;


library ieee;
use ieee.numeric_std.all;

use work.t48_pack.all;

architecture rtl of t48_timer is

  -- the 8 bit counter core
  signal counter_q   : unsigned(word_t'range);
  signal overflow_q  : boolean;

  -- increment signal for the counter core
  type   inc_type_t is (NONE, TIMER, COUNTER);
  signal increment_s : boolean;
  signal inc_sel_q   : inc_type_t;

  -- T1 edge detector
  signal t1_q        : std_logic;
  signal t1_inc_s    : boolean;

  -- timer prescaler
  signal prescaler_q : unsigned(4 downto 0);
  signal pre_inc_s   : boolean;

begin

  -----------------------------------------------------------------------------
  -- Verify the generics
  -----------------------------------------------------------------------------

  -- pragma translate_off
  assert (sample_t1_state_g = 3) or (sample_t1_state_g = 4)
    report "sample_t1_state_g must be either 3 or 4!"
    severity failure;
  -- pragma translate_on


  -----------------------------------------------------------------------------
  -- Process t1_edge
  --
  -- Purpose:
  --   Implements the edge detector for T1.
  --
  t1_edge: process (t1_i,
                    t1_q,
                    clk_mstate_i)
  begin
    t1_inc_s     <= false;

    -- sample in state according to generic
    -- Old devices: sample at the beginning of state 3
    -- New devices: sample in state 4
    if (sample_t1_state_g = 3 and clk_mstate_i = MSTATE3) or
       (sample_t1_state_g = 4 and clk_mstate_i = MSTATE4) then
      -- detect falling edge
      if t1_q = '1' and t1_i = '0' then
        t1_inc_s <= true;
      end if;
    end if;

  end process t1_edge;
  --
  -----------------------------------------------------------------------------


  pre_inc_s <= clk_mstate_i = MSTATE4 and prescaler_q = 31;


  -----------------------------------------------------------------------------
  -- Process inc_sel
  --
  -- Purpose:
  --   Select increment source (timer, counter or none).
  --
  inc_sel: process (inc_sel_q,
                    pre_inc_s,
                    t1_inc_s)
  begin
    -- default assignment
    increment_s     <= false;

    case inc_sel_q is
      when NONE =>
        increment_s <= false;
      when TIMER =>
        increment_s <= pre_inc_s;
      when COUNTER =>
        increment_s <= t1_inc_s;
      when others =>
        null;
    end case;

  end process inc_sel;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process regs
  --
  -- Purpose:
  --   Implements the counter, the prescaler and other registers.
  --
  regs: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      overflow_q     <= false;
      t1_q           <= '0';
      prescaler_q    <= (others => '0');
      inc_sel_q      <= NONE;
      counter_q      <= (others => '0');

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        -- Counter Core and overflow ------------------------------------------
        overflow_q     <= false;

        if write_timer_i then
          counter_q    <= unsigned(data_i);

        elsif increment_s then
          counter_q    <= counter_q + 1;

          if counter_q = 255 then
            overflow_q <= true;
          end if;

        end if;

        -- T1 edge detector ---------------------------------------------------
        if (sample_t1_state_g = 3 and clk_mstate_i = MSTATE3) or
           (sample_t1_state_g = 4 and clk_mstate_i = MSTATE4) then
          t1_q <= t1_i;
        end if;

        -- Prescaler ----------------------------------------------------------
        if start_t_i then
          prescaler_q  <= (others => '0');

        elsif clk_mstate_i = MSTATE3 then
          prescaler_q  <= prescaler_q + 1;

        end if;

        -- Increment Selector -------------------------------------------------
        if start_t_i then
          inc_sel_q <= TIMER;
        elsif start_cnt_i then
          inc_sel_q <= COUNTER;
        elsif stop_tcnt_i then
          inc_sel_q <= NONE;
        end if;

      end if;

    end if;

  end process regs;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output Mapping.
  -----------------------------------------------------------------------------
  data_o     <=   std_logic_vector(counter_q)
                when read_timer_i else
                  (others => bus_idle_level_c);
  overflow_o <= to_stdLogic(overflow_q);

end rtl;
