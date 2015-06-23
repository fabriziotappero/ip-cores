-------------------------------------------------------------------------------
--
-- The reset generation unit.
--
-- $Id: t400_reset.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006 Arnim Laeuger (arniml@opencores.org)
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
--      http://www.opencores.org/cvsweb.shtml/t400/
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity t400_reset is

  port (
    -- System Interface -------------------------------------------------------
    ck_i      : in  std_logic;
    icyc_en_i : in  boolean;
    por_i     : in  boolean;
    -- Reset Interface --------------------------------------------------------
    reset_n_i : in  std_logic;
    res_o     : out boolean
  );

end t400_reset;


library ieee;
use ieee.numeric_std.all;

architecture rtl of t400_reset is

  type   res_state_t is (IDLE,
                         RES1, RES2,
                         RES_ACTIVE);
  signal res_state_q : res_state_t;
  signal res_q       : boolean;

begin

  -----------------------------------------------------------------------------
  -- Process res_fsm
  --
  -- Purpose:
  --   Implements the reset timing/controlling FSM.
  --   User's Guide chapter 2.3 requires that reset_n_i has to be low for
  --   at least 3 instruction cycle times until it initializes the CPU.
  --
  res_fsm: process (ck_i, por_i)
  begin
    if por_i then
      res_state_q <= IDLE;
      res_q       <= false;

    elsif ck_i'event and ck_i = '1' then
      res_q               <= false;
      if icyc_en_i then
        case res_state_q is
          when IDLE =>
            if reset_n_i = '0' then
              res_state_q <= RES1;
            end if;

          when RES1 =>
            if reset_n_i = '0' then
              res_state_q <= RES2;
            else
              res_state_q <= IDLE;
            end if;

          when RES2 =>
            if reset_n_i = '0' then
              res_state_q <= RES_ACTIVE;
            else
              res_state_q <= IDLE;
            end if;

          when RES_ACTIVE =>
            res_q         <= true;
            if reset_n_i = '1' then
              res_state_q <= IDLE;
            end if;

          when others =>
            res_state_q   <= IDLE;

        end case;

      end if;

    end if;
  end process res_fsm;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  res_o <= res_q;

end rtl;
