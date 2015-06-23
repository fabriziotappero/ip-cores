-------------------------------------------------------------------------------
--
-- The stack unit.
--
-- $Id: t400_stack.vhd 179 2009-04-01 19:48:38Z arniml $
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

use work.t400_opt_pack.all;
use work.t400_pack.all;

entity t400_stack is

  generic (
    opt_type_g : integer := t400_opt_type_420_c
  );
  port (
    -- System Interface -------------------------------------------------------
    ck_i    : in  std_logic;
    ck_en_i : in  boolean;
    por_i   : in  boolean;
    -- Stack Control Interface ------------------------------------------------
    op_i    : in  stack_op_t;
    -- Program Counter Interface ----------------------------------------------
    pc_i    : in  pc_t;
    pc_o    : out pc_t
  );

end t400_stack;


-- pragma translate_off
use work.tb_pack.tb_sa_s;
-- pragma translate_on

architecture rtl of t400_stack is

  signal sa_q,
         sb_q,
         sc_q  : pc_t;

begin

  -----------------------------------------------------------------------------
  -- Process stack
  --
  -- Purpose:
  --   Implements the stack consisting of SA, SB, SC.
  --   SC is skipped when it's a 41xL.
  --
  stack: process (ck_i, por_i)
    variable t41x_type_v : boolean;
  begin
    if por_i then
      sa_q <= (others => '0');
      sb_q <= (others => '0');
      sc_q <= (others => '0');

    elsif ck_i'event and ck_i = '1' then
      -- determine type
      t41x_type_v := opt_type_g = t400_opt_type_410_c;

      if ck_en_i then
        case op_i is
          when STACK_PUSH =>
            sa_q   <= pc_i;
            sb_q   <= sa_q;
            if not t41x_type_v then
              sc_q <= sb_q;
            else
              sc_q <= (others => '0');
            end if;

          when STACK_POP =>
            sa_q   <= sb_q;
            if not t41x_type_v then
              sb_q <= sc_q;
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process stack;
  --
  -----------------------------------------------------------------------------


  -- pragma translate_off
  -- instrument interrupt testbench
  tb_sa_s <= sa_q;
  -- pragma translate_on


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  pc_o <= sa_q;

end rtl;
