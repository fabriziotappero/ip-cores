-------------------------------------------------------------------------------
--
-- The Interrupt Controller.
-- It collects the interrupt sources and notifies the decoder.
--
-- $Id: int.vhd 295 2009-04-01 19:32:48Z arniml $
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

use work.t48_pack.mstate_t;

entity t48_int is

  port (
    clk_i             : in  std_logic;
    res_i             : in  std_logic;
    en_clk_i          : in  boolean;
    xtal_i            : in  std_logic;
    xtal_en_i         : in  boolean;
    clk_mstate_i      : in  mstate_t;
    jtf_executed_i    : in  boolean;
    tim_overflow_i    : in  boolean;
    tf_o              : out std_logic;
    en_tcnti_i        : in  boolean;
    dis_tcnti_i       : in  boolean;
    int_n_i           : in  std_logic;
    ale_i             : in  boolean;
    last_cycle_i      : in  boolean;
    en_i_i            : in  boolean;
    dis_i_i           : in  boolean;
    ext_int_o         : out boolean;
    tim_int_o         : out boolean;
    retr_executed_i   : in  boolean;
    int_executed_i    : in  boolean;
    int_pending_o     : out boolean;
    int_in_progress_o : out boolean
  );

end t48_int;


use work.t48_pack.all;

architecture rtl of t48_int is

  constant tim_int_c : std_logic := '0';
  constant ext_int_c : std_logic := '1';

  type int_state_t is (IDLE, PENDING, INT);

  signal int_state_s,
         int_state_q  : int_state_t;

  signal timer_flag_q       : boolean;
  signal timer_overflow_q   : boolean;
  signal timer_int_enable_q : boolean;
  signal int_q              : boolean;
  signal int_enable_q       : boolean;
  signal ale_q              : boolean;
  signal int_type_q         : std_logic;
  signal int_in_progress_q  : boolean;

begin

  -----------------------------------------------------------------------------
  -- Process nstate
  --
  -- Purpose:
  --   Determines the next state of the Interrupt controller FSM.
  --
  nstate: process (int_state_q,
                   int_type_q,
                   int_in_progress_q,
                   int_executed_i,
                   retr_executed_i,
                   clk_mstate_i,
                   last_cycle_i)
  begin
    int_state_s <= int_state_q;

    case int_state_q is
      when IDLE =>
        if int_in_progress_q and
           last_cycle_i and clk_mstate_i = MSTATE5 then
          int_state_s <= PENDING;
        end if;

      when PENDING =>
        if int_executed_i then
          int_state_s <= INT;
        end if;

      when INT =>
        if retr_executed_i then
          int_state_s <= IDLE;
        end if;

      when others =>
        int_state_s <= IDLE;

    end case;

  end process nstate;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process regs
  --
  -- Purpose:
  --   Implement the various registers.
  --   They are designed according Figure "Interrupt Logic" of
  --   "The Single Component MCS-48 System".
  --
  regs: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      timer_flag_q       <= false;
      timer_overflow_q   <= false;
      timer_int_enable_q <= false;
      int_enable_q       <= false;
      int_type_q         <= '0';
      int_state_q        <= IDLE;
      int_in_progress_q  <= false;

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        int_state_q <= int_state_s;

        if jtf_executed_i then
          timer_flag_q <= false;
        elsif tim_overflow_i then
          timer_flag_q <= true;
        end if;

        if (int_type_q = tim_int_c and int_executed_i) or
          not timer_int_enable_q then
          timer_overflow_q <= false;
        elsif tim_overflow_i then
          timer_overflow_q <= true;
        end if;

        if dis_tcnti_i then
          timer_int_enable_q <= false;
        elsif en_tcnti_i then
          timer_int_enable_q <= true;
        end if;

        if dis_i_i then
          int_enable_q <= false;
        elsif en_i_i then
          int_enable_q <= true;
        end if;

        if retr_executed_i then
          int_in_progress_q <= false;
        elsif (int_q and int_enable_q) or
          timer_overflow_q then
          int_in_progress_q <= true;
          if not int_in_progress_q then
            int_type_q <= to_stdLogic(int_q and int_enable_q);
          end if;
        end if;

      end if;

    end if;

  end process regs;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process xtal_regs
  --
  -- Purpose:
  --   Implements the sequential registers clocked with XTAL.
  --
  xtal_regs: process (res_i, xtal_i)
  begin
    if res_i = res_active_c then
      int_q <= false;
      ale_q <= false;

    elsif xtal_i'event and xtal_i = clk_active_c then
      if xtal_en_i then
        ale_q   <= ale_i;

        if last_cycle_i and
          ale_q  and not ale_i  then
          int_q <= not to_boolean(int_n_i);
        end if;

      end if;
    end if;
  end process xtal_regs;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output Mapping.
  -----------------------------------------------------------------------------
  tf_o              <= to_stdLogic(timer_flag_q);
  ext_int_o         <= int_type_q = ext_int_c;
  tim_int_o         <= int_type_q = tim_int_c;
  int_pending_o     <= int_state_q = PENDING;
  int_in_progress_o <= int_in_progress_q and int_state_q /= IDLE;

end rtl;
