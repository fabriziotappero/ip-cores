-------------------------------------------------------------------------------
--
-- $Id: alu_pack-p.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.t48_pack.word_width_c;

package t48_alu_pack is

  -----------------------------------------------------------------------------
  -- The ALU operations
  -----------------------------------------------------------------------------
  type alu_op_t is (ALU_AND, ALU_OR, ALU_XOR,
                    ALU_CPL, ALU_CLR,
                    ALU_RL, ALU_RR,
                    ALU_SWAP,
                    ALU_DEC, ALU_INC,
                    ALU_ADD,
                    ALU_CONCAT,
                    ALU_NOP);

  -----------------------------------------------------------------------------
  -- The dedicated ALU arithmetic types.
  -----------------------------------------------------------------------------
  subtype alu_operand_t is std_logic_vector(word_width_c downto 0);

end t48_alu_pack;
