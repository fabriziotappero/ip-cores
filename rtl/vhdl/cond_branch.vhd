-------------------------------------------------------------------------------
--
-- The Conditional Branch Logic unit.
-- Decisions whether to take a jump or not are made here.
--
-- $Id: cond_branch.vhd 295 2009-04-01 19:32:48Z arniml $
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

use work.t48_cond_branch_pack.all;

entity t48_cond_branch is

  port (
    -- Global Interface -------------------------------------------------------
    clk_i          : in  std_logic;
    res_i          : in  std_logic;
    en_clk_i       : in  boolean;
    -- Decoder Interface ------------------------------------------------------
    compute_take_i : in  boolean;
    branch_cond_i  : in  branch_conditions_t;
    take_branch_o  : out boolean;
    accu_i         : in  word_t;
    t0_i           : in  std_logic;
    t1_i           : in  std_logic;
    int_n_i        : in  std_logic;
    f0_i           : in  std_logic;
    f1_i           : in  std_logic;
    tf_i           : in  std_logic;
    carry_i        : in  std_logic;
    comp_value_i   : in  comp_value_t
  );

end t48_cond_branch;


library ieee;
use ieee.numeric_std.all;

use work.t48_pack.res_active_c;
use work.t48_pack.clk_active_c;

architecture rtl of t48_cond_branch is

  -- marker for branch taken
  signal take_branch_s,
         take_branch_q : boolean;

begin

  -----------------------------------------------------------------------------
  -- Process decide_take
  --
  -- Purpose:
  --   Decides whether a branch has to be taken or not.
  --
  decide_take: process (accu_i,
                        branch_cond_i,
                        t0_i, t1_i,
                        int_n_i,
                        f0_i, f1_i,
                        tf_i,
                        carry_i,
                        comp_value_i)
    variable or_v : std_logic;
  begin
    -- default assignment
    take_branch_s <= false;
    or_v          := '0';

    case branch_cond_i is
      -- Branch On: Accumulator Bit -------------------------------------------
      when COND_ON_BIT =>
        if accu_i(TO_INTEGER(UNSIGNED(comp_value_i))) = '1' then
          take_branch_s <= true;
        end if;

      -- Branch On: Accumulator Zero ------------------------------------------
      when COND_Z =>
        for i in accu_i'range loop
          or_v := or_v or accu_i(i);
        end loop;
        take_branch_s <= or_v = not comp_value_i(0);

      -- Branch On: Carry -----------------------------------------------------
      when COND_C =>
        take_branch_s <= carry_i = comp_value_i(0);

      -- Branch On: Flag 0 ----------------------------------------------------
      when COND_F0 =>
        take_branch_s <= f0_i = '1';

      -- Branch On: Flag 1 ----------------------------------------------------
      when COND_F1 =>
        take_branch_s <= f1_i = '1';

      -- Branch On: Interrupt -------------------------------------------------
      when COND_INT =>
        take_branch_s <= int_n_i = '0';

      -- Branch On: Test 0 ----------------------------------------------------
      when COND_T0 =>
        take_branch_s <= t0_i = comp_value_i(0);

      -- Branch On: Test 1 ----------------------------------------------------
      when COND_T1 =>
        take_branch_s <= t1_i = comp_value_i(0);

      -- Branch On: Timer Flag ------------------------------------------------
      when COND_TF =>
        take_branch_s <= tf_i = '1';

      when others =>
        -- pragma translate_off
        assert false
          report "Unknown branch condition specified!"
          severity error;
        -- pragma translate_on

    end case;

  end process decide_take;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process reg
  --
  -- Purpose:
  --   Implement the marker register.
  --
  reg: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      take_branch_q <= false;

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        if compute_take_i then
          take_branch_q <= take_branch_s;
        end if;

      end if;

    end if;

  end process reg;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output Mapping.
  -----------------------------------------------------------------------------
  take_branch_o <= take_branch_q;

end rtl;
