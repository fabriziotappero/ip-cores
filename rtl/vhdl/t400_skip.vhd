-------------------------------------------------------------------------------
--
-- The skip unit.
-- Skip conditions are checked here and communicated to the decoder unit.
--
-- $Id: t400_skip.vhd 179 2009-04-01 19:48:38Z arniml $
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

entity t400_skip is

  generic (
    opt_type_g : integer := t400_opt_type_420_c
  );
  port (
    -- System Interface -------------------------------------------------------
    ck_i       : in  std_logic;
    ck_en_i    : in  boolean;
    por_i      : in  boolean;
    res_i      : in  boolean;
    -- Control Interface ------------------------------------------------------
    op_i       : in  skip_op_t;
    dec_data_i : in  dec_data_t;
    carry_i    : in  std_logic;
    c_i        : in  std_logic;
    bd_i       : in  dw_t;
    is_lbi_i   : in  boolean;
    skip_o     : out boolean;
    skip_lbi_o : out boolean;
    -- Data Interface ---------------------------------------------------------
    a_i        : in  dw_t;
    m_i        : in  dw_t;
    g_i        : in  dw_t;
    tim_c_i    : in  boolean
  );

end t400_skip;


library ieee;
use ieee.numeric_std.all;

architecture rtl of t400_skip is

  signal skip_q,
         skip_next_q : boolean;
  signal skip_lbi_q  : boolean;

  signal skip_int_q  : boolean;

begin

  -----------------------------------------------------------------------------
  -- Process skip
  --
  -- Purpose:
  --   Implements the skip logic.
  --
  skip: process (ck_i, por_i)
    variable t420_type_v : boolean;
  begin
    if por_i then
      skip_next_q <= false;
      skip_q      <= false;
      skip_lbi_q  <= false;
      skip_int_q  <= false;

    elsif ck_i'event and ck_i = '1' then
      if    res_i then
        -- synchronous reset upon external reset event
        skip_next_q    <= false;
        skip_q         <= false;
        skip_lbi_q     <= false;
        skip_int_q     <= false;

      elsif ck_en_i then
        t420_type_v := opt_type_g = t400_opt_type_420_c;

        if ck_en_i then
          case op_i is
            -- update skip information ----------------------------------------
            when SKIP_UPDATE =>
              skip_q       <= skip_next_q;
              -- also reset skip_next flag
              skip_next_q  <= false;

              -- reset skip-on-lbi flag when this was not an LBI
              if not is_lbi_i then
                skip_lbi_q <= false;
              end if;

            -- skip always ----------------------------------------------------
            when SKIP_NOW =>
              skip_next_q <= true;

            -- skip on carry --------------------------------------------------
            when SKIP_CARRY =>
              skip_next_q <= carry_i = '1';

            -- skip on C ------------------------------------------------------
            when SKIP_C =>
              skip_next_q <= c_i = '1';

            -- skip on BD underflow ------------------------------------------
            when SKIP_BD_UFLOW =>
              skip_next_q <= unsigned(bd_i) = 15;

            -- skip on BD overflow -------------------------------------------
            when SKIP_BD_OFLOW =>
              skip_next_q <= unsigned(bd_i) = 0;

            -- skip on LBI instruction ----------------------------------------
            when SKIP_LBI =>
              skip_lbi_q  <= true;

            -- skip on A and M equal ------------------------------------------
            when SKIP_A_M =>
              skip_next_q <= unsigned(a_i) = unsigned(m_i);

            -- skip on G zero -------------------------------------------------
            when SKIP_G_ZERO =>
              skip_next_q <= unsigned(g_i) = 0;

            -- skip on G bit --------------------------------------------------
            when SKIP_G_BIT =>
              skip_next_q <= unsigned(g_i and dec_data_i(dw_range_t)) = 0;

            -- skip on M bit --------------------------------------------------
            when SKIP_M_BIT =>
              skip_next_q <= unsigned(m_i and dec_data_i(dw_range_t)) = 0;

            -- skip on timer carry --------------------------------------------
            when SKIP_TIMER =>
              skip_next_q <= tim_c_i;
              null;

            -- push skip state when vectoring to interrupt routine ------------
            when SKIP_PUSH =>
              if t420_type_v then
                -- save next skip flag
                skip_int_q  <= skip_next_q;
                skip_next_q <= false;
                -- never skip first instruction of interrupt routine
                skip_q      <= false;
              end if;

            -- pop skip state for RET from interrupt routine ------------------
            when SKIP_POP =>
              if t420_type_v then
                -- push'ed info must be pop'ed to skip_next_q as pop'ing
                -- happens during RET of interrupt routine
                -- skip info is valid for next instruction
                skip_next_q <= skip_int_q;
                skip_int_q  <= false;
              end if;

            when others =>
              null;
          end case;
        end if;
      end if;
    end if;
  end process skip;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  skip_o     <= skip_q;
  skip_lbi_o <= skip_lbi_q;

end rtl;
