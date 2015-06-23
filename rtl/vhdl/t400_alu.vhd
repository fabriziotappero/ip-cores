-------------------------------------------------------------------------------
--
-- The Arithmetic Logic Unit (ALU).
-- It contains the accumulator and the C flag.
--
-- $Id: t400_alu.vhd 179 2009-04-01 19:48:38Z arniml $
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
use work.t400_opt_pack.all;

entity t400_alu is

  generic (
    opt_cko_g : integer := t400_opt_cko_crystal_c
  );
  port (
    -- System Interface -------------------------------------------------------
    ck_i       : in  std_logic;
    ck_en_i    : in  boolean;
    por_i      : in  boolean;
    res_i      : in  boolean;
    cko_i      : in  std_logic;
    -- Control Interface ------------------------------------------------------
    op_i       : in  alu_op_t;
    -- Data Interface ---------------------------------------------------------
    m_i        : in  dw_t;
    dec_data_i : in  dec_data_t;
    q_low_i    : in  dw_t;
    b_i        : in  b_t;
    g_i        : in  dw_t;
    in_i       : in  dw_t;
    sio_i      : in  dw_t;
    a_o        : out dw_t;
    carry_o    : out std_logic;
    c_o        : out std_logic
  );

end t400_alu;


library ieee;
use ieee.numeric_std.all;

architecture rtl of t400_alu is

  subtype alu_dw_t     is unsigned(dw_t'high+1 downto 0);
  signal  alu_result_s : alu_dw_t;

  signal  a_q          : dw_t;
  signal  c_q          : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Process regs
  --
  -- Purpose:
  --   Implements the sequential registers of the ALU:
  --     * A - accumulator
  --     * C - carry flag
  --
  regs: process (ck_i, por_i)
  begin
    if por_i then
      a_q <= (others => '0');
      c_q <= '0';

    elsif ck_i'event and ck_i = '1' then
      if res_i then
        -- synchronous reset upon external reset event
        a_q <= (others => '0');
        c_q <= '0';

      elsif ck_en_i then
        -- update accumulator
        case op_i is
          when ALU_CLRA    |
               ALU_ADD     |
               ALU_ADD_10  |
               ALU_ADD_C   |
               ALU_ADD_DEC |
               ALU_COMP    |
               ALU_XOR     =>
            a_q <= std_logic_vector(alu_result_s(dw_t'range));
          when ALU_LOAD_M =>
            a_q <= m_i;
          when ALU_LOAD_Q =>
            a_q <= q_low_i;
          when ALU_LOAD_G =>
            a_q <= g_i;
          when ALU_LOAD_IN =>
            a_q <= in_i;
          when ALU_LOAD_IL =>
            a_q(3) <= in_i(3);
            if opt_cko_g = t400_opt_cko_gpi_c then
              a_q(2) <= cko_i;
            else
              a_q(2) <= '1';
            end if;
            a_q(1) <= '0';
            a_q(0) <= in_i(0);
          when ALU_LOAD_BR =>
            a_q(3 downto 2) <= (others => '0');
            a_q(1 downto 0) <= b_i(br_range_t);
          when ALU_LOAD_BD =>
            a_q <= b_i(bd_range_t);
          when ALU_LOAD_SIO =>
            a_q <= sio_i;
          when others =>
            null;
        end case;

        -- update C flag upon the following instructions
        case op_i is
          -- carry result of addition -----------------------------------------
          when ALU_ADD_C =>
            c_q <= alu_result_s(alu_dw_t'high);

          -- reset C flag -----------------------------------------------------
          when ALU_RC =>
            c_q <= '0';

          -- set C flag -------------------------------------------------------
          when ALU_SC =>
            c_q <= '1';

          when others =>
            null;
        end case;
      end if;
    end if;
  end process regs;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process dp
  --
  -- Purpose:
  --   Implements the ALU's data path.
  --
  dp: process (op_i,
               a_q,
               m_i,
               dec_data_i,
               c_q)
    variable in1_v,
             in2_v,
             in3_v,
             add_v, xor_v : alu_dw_t;
  begin
    -- prepare adder
    in1_v      := '0' & unsigned(a_q);
    if    op_i = ALU_ADD_10 then
      in2_v    := to_unsigned(10, alu_dw_t'length);
    elsif op_i = ALU_ADD_DEC then
      in2_v    := '0' & unsigned(dec_data_i(dw_t'range));
    else
      in2_v    := '0' & unsigned(m_i);
    end if;
    if op_i = ALU_ADD_C then
      in3_v    := (others => '0');
      in3_v(0) := c_q;
    else
      in3_v    := (others => '0');
    end if;
    add_v := in1_v + in2_v + in3_v;

    -- prepare exclusive or
    xor_v := in1_v xor in2_v;

    case op_i is
      -- ALU operation: Clear accumulator -------------------------------------
      when ALU_CLRA =>
        alu_result_s <= (others => '0');

      -- ALU operation: Add to accumulator ------------------------------------
      when ALU_ADD     |
           ALU_ADD_10  |
           ALU_ADD_C   |
           ALU_ADD_DEC =>
        alu_result_s <= add_v;

      -- ALU operation: Complement accumulator --------------------------------
      when ALU_COMP =>
        alu_result_s <= '0' & not unsigned(a_q);

      -- ALU operation: XOR to accumulator ------------------------------------
      when ALU_XOR =>
        alu_result_s <= xor_v;

      when others =>
        alu_result_s <= (others => '-');
    end case;
  end process dp;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  a_o     <= a_q;
  carry_o <= alu_result_s(alu_dw_t'high);
  c_o     <= c_q;

end rtl;
