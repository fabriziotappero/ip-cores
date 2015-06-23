-------------------------------------------------------------------------------
--
-- The IN port controller.
--
-- $Id: t400_io_in.vhd 179 2009-04-01 19:48:38Z arniml $
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

use work.t400_pack.all;

entity t400_io_in is

  port (
    -- System Interface -------------------------------------------------------
    ck_i      : in  std_logic;
    ck_en_i   : in  boolean;
    por_i     : in  boolean;
    icyc_en_i : in boolean;
    in_en_i   : in  boolean;
    -- Control Interface ------------------------------------------------------
    op_i      : in  io_in_op_t;
    en1_i     : in  std_logic;
    -- Port Interface ---------------------------------------------------------
    io_in_i   : in  dw_t;
    in_o      : out dw_t;
    int_o     : out boolean
  );

end t400_io_in;


architecture rtl of t400_io_in is

  constant idx_in3_c  : natural := 2;
  constant idx_in0_c  : natural := 1;
  constant idx_int_c  : natural := 0;

  type     neg_edge_t is array (natural range 1 downto 0) of
                           std_logic_vector(2 downto 0);
  signal   neg_edge_q : neg_edge_t;
  signal   neg_edge_s : std_logic_vector(2 downto 0);

  signal   il_q       : std_logic_vector(1 downto 0);
  signal   int_q,
           int_icyc_q : boolean;

begin

  -----------------------------------------------------------------------------
  -- Process seq
  --
  -- Purpose:
  --   Implements the sequential elements.
  --
  seq: process (ck_i, por_i)
    variable neg_edge_v : std_logic_vector(2 downto 0);
  begin
    if por_i then
      neg_edge_q <= (others => (others => '0'));
      il_q       <= (others => '0');
      int_q      <= false;
      int_icyc_q <= false;

    elsif ck_i'event and ck_i = '1' then
      -- negative edge detector filp-flops ------------------------------------
      neg_edge_v(idx_in3_c) := to_X01(io_in_i(3));
      neg_edge_v(idx_in0_c) := to_X01(io_in_i(0));
      neg_edge_v(idx_int_c) := to_X01(io_in_i(1));

      if in_en_i then
        neg_edge_q(0) <= neg_edge_v;
        neg_edge_q(1) <= neg_edge_q(0) or neg_edge_v;
      end if;

      -- IL latches -----------------------------------------------------------
      if in_en_i then
        if neg_edge_q(1)(idx_in3_c) = '1' and
           ((neg_edge_q(0)(idx_in3_c) or neg_edge_v(idx_in3_c)) = '0') then
          il_q(1) <= '1';
        end if;
        if neg_edge_q(1)(idx_in0_c) = '1' and
           ((neg_edge_q(0)(idx_in0_c) or neg_edge_v(idx_in0_c)) = '0') then
          il_q(0) <= '1';
        end if;
      end if;

      -- Interrupt trigger ----------------------------------------------------
      if in_en_i then
        if neg_edge_q(1)(idx_int_c) = '1' and
           ((neg_edge_q(0)(idx_int_c) or neg_edge_v(idx_int_c)) = '0') then
          int_q <= true;
        end if;
      end if;
      if icyc_en_i then
        -- delay interrupt request until end of current instruction
        -- this ensures that the interrupt is valid for a full instruction
        -- (i.e. the next one)
        int_icyc_q <= int_q;
      end if;

      if ck_en_i then
        if op_i = IOIN_INIL then
          il_q <= (others => '0');
        end if;

        if op_i = IOIN_INTACK then
          int_q      <= false;
          int_icyc_q <= false;
        end if;
      end if;

    end if;
  end process seq;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  in_o  <=   il_q(1) & "00" & il_q(0)
           when op_i = IOIN_INIL else
             io_in_i;
  int_o <= int_icyc_q;

end rtl;
