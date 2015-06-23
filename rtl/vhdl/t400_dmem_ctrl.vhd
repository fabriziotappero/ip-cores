-------------------------------------------------------------------------------
--
-- The Data memory controller.
--
-- $Id: t400_dmem_ctrl.vhd 179 2009-04-01 19:48:38Z arniml $
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

entity t400_dmem_ctrl is

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
    dmem_op_i  : in  dmem_op_t;
    b_op_i     : in  b_op_t;
    dec_data_i : in  dec_data_t;
    a_i        : in  dw_t;
    q_high_i   : in  dw_t;
    b_o        : out b_t;
    -- Data Memory Interface --------------------------------------------------
    dm_addr_o  : out dm_addr_t;
    dm_data_i  : in  dw_t;
    dm_data_o  : out dw_t;
    dm_we_o    : out std_logic
  );

end t400_dmem_ctrl;


library ieee;
use ieee.numeric_std.all;

architecture rtl of t400_dmem_ctrl is

  signal br_q : unsigned(br_range_t);
  signal bd_q : unsigned(bd_range_t);

begin

  -----------------------------------------------------------------------------
  -- Process b_reg
  --
  -- Purpose:
  --   Implements the B register.
  --
  b_reg: process (ck_i, por_i)
  begin
    if por_i then
      br_q   <= (others => '0');
      bd_q   <= (others => '0');

    elsif ck_i'event and ck_i = '1' then
      if    res_i then
        -- synchronous reset upon external reset event
        br_q <= (others => '0');
        bd_q <= (others => '0');

      elsif ck_en_i then
        case b_op_i is
          -- Set Bd from accumulator ------------------------------------------
          when B_SET_BD =>
            bd_q <= unsigned(a_i);

          -- Set Br from accumulator ------------------------------------------
          when B_SET_BR =>
            br_q <= unsigned(a_i(1 downto 0));

          -- Set Br and Bd from decoder data ----------------------------------
          when B_SET_B =>
            br_q <= unsigned(dec_data_i(br_range_t));
            bd_q <= unsigned(dec_data_i(bd_range_t));

          -- Set Br and Bd from decoder data, increment value for Bd ----------
          when B_SET_B_INC =>
            br_q <= unsigned(dec_data_i(br_range_t));
            bd_q <= unsigned(dec_data_i(bd_range_t)) + 1;

          -- XOR Br with decoder data -----------------------------------------
          when B_XOR_BR =>
            br_q <= br_q xor unsigned(dec_data_i(br_range_t));

          -- Increment Bd -----------------------------------------------------
          when B_INC_BD =>
            bd_q <= bd_q + 1;

          -- Increment Bd -----------------------------------------------------
          when B_DEC_BD =>
            bd_q <= bd_q - 1;

          when others =>
            null;
        end case;

      end if;
    end if;
  end process b_reg;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process data_mux
  --
  -- Purpose:
  --   Multiplexes the data for writing to the memory.
  --
  data_mux: process (dmem_op_i,
                     br_q, bd_q,
                     a_i,
                     q_high_i,
                     dec_data_i,
                     dm_data_i,
                     ck_en_i)
    variable dm_addr_v : dm_addr_t;
    variable dm_data_v : dw_t;
    variable dm_we_v   : std_logic;
    variable bd_v      : std_logic_vector(2 downto 0);
  begin
    -- default assignment
    dm_addr_v(br_range_t) := std_logic_vector(br_q);
    dm_addr_v(bd_range_t) := std_logic_vector(bd_q);
    dm_data_v := (others => '0');
    dm_we_v   := '0';

    case dmem_op_i is
      -- Read data memory, indexed by B ---------------------------------------
      when DMEM_RB =>
        null;

      -- Write data memory, indexed by B, source is Q -------------------------
      when DMEM_WB_SRC_Q =>
        dm_we_v   := '1';
        dm_data_v := q_high_i;

      -- Write data memory, indexed by B, source is decoder data --------------
      when DMEM_WB_SRC_DEC =>
        dm_we_v   := '1';
        dm_data_v := dec_data_i(bd_range_t);

      -- Write data memory, indexed by B, source is accumulator ---------------
      when DMEM_WB_SRC_A =>
        dm_we_v   := '1';
        dm_data_v := a_i;

      -- Read data memory, indexed by decoder data ----------------------------
      when DMEM_RDEC =>
        dm_addr_v := dec_data_i(br_range_t'high downto 0);

      -- Write data memory, indexed by decoder data, source is accumulator ----
      when DMEM_WDEC_SRC_A =>
        dm_we_v   := '1';
        dm_addr_v := dec_data_i(br_range_t'high downto 0);
        dm_data_v := a_i;

      -- Write data memory, indexed by B, set bit -----------------------------
      when DMEM_WB_SET_BIT =>
        dm_we_v   := '1';
        dm_data_v := dm_data_i or dec_data_i(dw_range_t);

      -- Write data memory, indexed by B, reset bit ---------------------------
      when DMEM_WB_RES_BIT =>
        dm_we_v   := '1';
        dm_data_v := dm_data_i and not dec_data_i(dw_range_t);

      when others =>
        null;
    end case;

    -- adjust address vector for 41xL family members
    if opt_type_g = t400_opt_type_410_c then
      dm_addr_v := '0' & dm_addr_v(br_range_t) &
                         dm_addr_v(bd_range_t'high-1 downto 0);
    end if;

    dm_addr_o <= dm_addr_v;

    if ck_en_i then
      dm_we_o   <= dm_we_v;
    else
      dm_we_o   <= '0';
    end if;
    dm_data_o   <= dm_data_v;
  end process data_mux;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  b_o(br_range_t) <= std_logic_vector(br_q);
  b_o(bd_range_t) <= std_logic_vector(bd_q);

end rtl;
