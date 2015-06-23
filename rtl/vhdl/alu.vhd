-------------------------------------------------------------------------------
--
-- The Arithmetic Logic Unit (ALU).
-- It contains the ALU core plus the Accumulator and the Temp Reg.
--
-- $Id: alu.vhd 295 2009-04-01 19:32:48Z arniml $
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
use work.t48_alu_pack.alu_op_t;

entity t48_alu is

  port (
    -- Global Interface -------------------------------------------------------
    clk_i              : in  std_logic;
    res_i              : in  std_logic;
    en_clk_i           : in  boolean;
    -- T48 Bus Interface ------------------------------------------------------
    data_i             : in  word_t;
    data_o             : out word_t;
    write_accu_i       : in  boolean;
    write_shadow_i     : in  boolean;
    write_temp_reg_i   : in  boolean;
    read_alu_i         : in  boolean;
    -- Decoder Interface ------------------------------------------------------
    carry_i            : in  std_logic;
    carry_o            : out std_logic;
    aux_carry_o        : out std_logic;
    alu_op_i           : in  alu_op_t;
    use_carry_i        : in  boolean;
    da_high_i          : in  boolean;
    da_overflow_o      : out boolean;
    accu_low_i         : in  boolean;
    p06_temp_reg_i     : in  boolean;
    p60_temp_reg_i     : in  boolean
  );

end t48_alu;


library ieee;
use ieee.numeric_std.all;

use work.t48_pack.clk_active_c;
use work.t48_pack.res_active_c;
use work.t48_pack.bus_idle_level_c;
use work.t48_pack.nibble_t;
use work.t48_alu_pack.all;

-- pragma translate_off
use work.t48_tb_pack.tb_accu_s;
-- pragma translate_on

architecture rtl of t48_alu is

  -- the Accumulator and Temp Reg
  signal accumulator_q,
         accu_shadow_q,
         temp_req_q     : word_t;
  -- inputs to the ALU core
  signal in_a_s,
         in_b_s  : word_t;
  -- output of the ALU core
  signal data_s  : word_t;

  signal add_result_s : alu_operand_t;

begin

  -----------------------------------------------------------------------------
  -- Process working_regs
  --
  -- Purpose:
  --   Implements the working registers:
  --    + Accumulator
  --    + Temp Reg
  --
  working_regs: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      accumulator_q     <= (others => '0');
      accu_shadow_q     <= (others => '0');
      temp_req_q        <= (others => '0');

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        if write_accu_i then
          if accu_low_i then
            accumulator_q(nibble_t'range) <= data_i(nibble_t'range);
          else
            accumulator_q <= data_i;
          end if;
        end if;

        if write_shadow_i then
          -- write shadow directly from t48 data bus
          accu_shadow_q <= data_i;
        else
          -- default: update shadow Accumulator from real Accumulator
          accu_shadow_q <= accumulator_q;
        end if;

        if p06_temp_reg_i then
          -- low nibble of DA sequence
          temp_req_q  <= "00000110";
        elsif p60_temp_reg_i then
          -- high nibble of DA sequence
          temp_req_q  <= "01100000";
        elsif write_temp_reg_i then
          -- normal load from T48 bus
          temp_req_q  <= data_i;
        end if;

      end if;

    end if;

  end process working_regs;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Build the inputs to the ALU core.
  -- Input A:
  --   Unary operators use only Input A.
  --   Is always fed from the shadow Accumulator.
  --   Assumption: It never happens that the Accumulator is written and then
  --               read for an ALU operation in the next cycle.
  --               Its contents can thus be staged through the shadow Accu.
  -- Input B:
  --   Is always fed from the Temp Reg.
  -----------------------------------------------------------------------------
  in_a_s <= accu_shadow_q;
  in_b_s <= temp_req_q;


  -----------------------------------------------------------------------------
  -- Process alu_core
  --
  -- Purpose:
  --   Implements the ALU core.
  --   All operations defined in alu_op_t are handled here.
  --
  alu_core: process (in_a_s,
                     in_b_s,
                     alu_op_i,
                     carry_i,
                     use_carry_i,
                     add_result_s)

  begin
    -- default assigments
    data_s      <= (others => '0');
    carry_o     <= '0';

    case alu_op_i is
      -- Operation: AND -------------------------------------------------------
      when ALU_AND =>
        data_s <= in_a_s and in_b_s;

      -- Operation: OR --------------------------------------------------------
      when ALU_OR =>
        data_s <= in_a_s or in_b_s;

      -- Operation: XOR -------------------------------------------------------
      when ALU_XOR =>
        data_s <= in_a_s xor in_b_s;

      -- Operation: Add -------------------------------------------------------
      when ALU_ADD =>
        data_s  <= add_result_s(data_s'range);
        carry_o <= add_result_s(add_result_s'high);

      -- Operation: CPL -------------------------------------------------------
      when ALU_CPL =>
        data_s <= not in_a_s;

      -- Operation: CLR -------------------------------------------------------
      when ALU_CLR =>
        data_s <= (others => '0');

      -- Operation: RL --------------------------------------------------------
      when ALU_RL =>
        data_s(7 downto 1) <= in_a_s(6 downto 0);
        carry_o            <= in_a_s(7);

        if use_carry_i then
          data_s(0)        <= carry_i;
        else
          data_s(0)        <= in_a_s(7);
        end if;

      -- Operation: RR --------------------------------------------------------
      when ALU_RR =>
        data_s(6 downto 0) <= in_a_s(7 downto 1);
        carry_o            <= in_a_s(0);

        if use_carry_i then
          data_s(7)        <= carry_i;
        else
          data_s(7)        <= in_a_s(0);
        end if;

      -- Operation: Swap ------------------------------------------------------
      when ALU_SWAP =>
        data_s(3 downto 0) <= in_a_s(7 downto 4);
        data_s(7 downto 4) <= in_a_s(3 downto 0);

      -- Operation: DEC -------------------------------------------------------
      when ALU_DEC =>
        data_s <= add_result_s(data_s'range);

      -- Operation: INC -------------------------------------------------------
      when ALU_INC =>
        data_s <= add_result_s(data_s'range);

      -- Operation CONCAT -----------------------------------------------------
      when ALU_CONCAT =>
        data_s <= in_b_s(7 downto 4) & in_a_s(3 downto 0);

      -- Operation: NOP -------------------------------------------------------
      when ALU_NOP =>
        data_s <= in_a_s;

      when others =>
        -- pragma translate_off
        assert false
          report "Unknown ALU operation selected!"
          severity error;
        -- pragma translate_on

    end case;

  end process alu_core;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process adder
  --
  -- Purpose:
  --   Implements the adder used by several instructions.
  --   This way of modelling the adder forces resource sharing of:
  --     * ADD
  --     * INC
  --     * DEC
  --
  adder: process (in_a_s,
                  in_b_s,
                  alu_op_i,
                  carry_i,
                  use_carry_i)

    variable add_a_v, add_b_v : alu_operand_t;
    variable c_v              : alu_operand_t;
    variable result_v         : UNSIGNED(alu_operand_t'range);
    variable aux_c_v          : std_logic_vector(1 downto 0);

  begin
    -- Carry Selection --------------------------------------------------------
    c_v      := (others => '0');
    if use_carry_i and carry_i = '1' then
      c_v(0) := '1';
    end if;

    -- Operand Selection ------------------------------------------------------
    -- defaults for ADD
    add_a_v := '0' & in_a_s;
    add_b_v := '0' & in_b_s;

    case alu_op_i is
      when ALU_INC =>
        add_b_v    := (others => '0');
        add_b_v(0) := '1';
      when ALU_DEC =>
        add_b_v    := (others => '1');
      when others =>
        null;
    end case;

    -- The Adder --------------------------------------------------------------
    result_v := UNSIGNED(add_a_v) +
                UNSIGNED(add_b_v) +
                UNSIGNED(c_v);

    add_result_s <= std_logic_vector(result_v);

    -- Auxiliary Carry --------------------------------------------------------
    aux_c_v           := in_a_s(4) & in_b_s(4);

    aux_carry_o       <= '0';
    case aux_c_v is
      when "00" | "11" =>
        if result_v(4) = '1' then
          aux_carry_o <= '1';
        end if;

      when "01" | "10" =>
        if result_v(4) = '0' then
          aux_carry_o <= '1';
        end if;

      when others =>
        null;

    end case;

  end process adder;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process da_overflow
  --
  -- Purpose:
  --   Detect overflow situation during DA sequence.
  --
  da_overflow: process (accu_shadow_q,
                        da_high_i)

    variable da_nibble_v : nibble_t;

    function da_overflow_f(data : in nibble_t) return boolean is
      variable overflow_v : boolean;
    begin
      case data is
        when "1010" |
             "1011" |
             "1100" |
             "1101" |
             "1110" |
             "1111" =>
          overflow_v := true;
        when others =>
          overflow_v := false;
      end case;

      return(overflow_v);
    end;

  begin
    if da_high_i then
      da_nibble_v := accu_shadow_q(7 downto 4);
    else
      da_nibble_v := accu_shadow_q(3 downto 0);
    end if;

    da_overflow_o <= da_overflow_f(da_nibble_v);

  end process da_overflow;
  --
  -----------------------------------------------------------------------------


  -- pragma translate_off
  -----------------------------------------------------------------------------
  -- Testbench support.
  -----------------------------------------------------------------------------
  tb_accu_s <= accumulator_q;
  -- pragma translate_on

  -----------------------------------------------------------------------------
  -- Output Multiplexer.
  -----------------------------------------------------------------------------
  data_o <=   data_s
            when read_alu_i else
              (others => bus_idle_level_c);

end rtl;
