-- <File header>
-- Project
--    pAVR (pipelined AVR) is an 8 bit RISC controller, compatible with Atmel's
--    AVR core, but about 3x faster in terms of both clock frequency and MIPS.
--    The increase in speed comes from a relatively deep pipeline. The original
--    AVR core has only two pipeline stages (fetch and execute), while pAVR has
--    6 pipeline stages:
--       1. PM    (read Program Memory)
--       2. INSTR (load Instruction)
--       3. RFRD  (decode Instruction and read Register File)
--       4. OPS   (load Operands)
--       5. ALU   (execute ALU opcode or access Unified Memory)
--       6. RFWR  (write Register File)
-- Version
--    0.32
-- Date
--    2002 August 07
-- Author
--    Doru Cuturela, doruu@yahoo.com
-- License
--    This program is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation; either version 2 of the License, or
--    (at your option) any later version.
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--    You should have received a copy of the GNU General Public License
--    along with this program; if not, write to the Free Software
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-- </File header>



-- <File info>
-- This is pAVR's ALU.
-- The ALU asychronousely computes:
--    - output
--    - output flags,
--    based on:
--    - input 1
--    - input 2
--    - input flags
-- Flags:
--    - C (cary)
--    - Z (zero)
--    - N (negative)
--    - V (two's complement overflow)
--    - S (N xor V, for signed tests)
--    - H (half carry)
--       *** The half carry is computed as specified in the AVR instruction set.
--       However, Atmel's AVRStudio computes it differently. To see where is the
--       bug, in the AVR instruction set document or in AVRStudio.
-- </File info>



-- <File body>
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;
library ieee;
use ieee.std_logic_1164.all;



entity pavr_alu is
   port(
      pavr_alu_op1:      in  std_logic_vector(15 downto 0);
      pavr_alu_op2:      in  std_logic_vector(7 downto 0);
      pavr_alu_out:      out std_logic_vector(15 downto 0);
      pavr_alu_opcode:   in  std_logic_vector(pavr_alu_opcode_w - 1 downto 0);
      pavr_alu_flagsin:  in  std_logic_vector(5 downto 0);
      pavr_alu_flagsout: out std_logic_vector(5 downto 0)
   );
end;



architecture pavr_alu_arch of pavr_alu is
   -- Wires
   signal tmp10_1, tmp10_2, tmp10_3 : std_logic_vector(9 downto 0);
   signal tmp18_1, tmp18_2, tmp18_3 : std_logic_vector(17 downto 0);

   signal pavr_alu_h_sel: std_logic_vector(pavr_alu_h_sel_w - 1 downto 0);
   signal pavr_alu_s_sel: std_logic;
   signal pavr_alu_v_sel: std_logic_vector(pavr_alu_v_sel_w - 1 downto 0);
   signal pavr_alu_n_sel: std_logic_vector(pavr_alu_n_sel_w - 1 downto 0);
   signal pavr_alu_z_sel: std_logic_vector(pavr_alu_z_sel_w - 1 downto 0);
   signal pavr_alu_c_sel: std_logic_vector(pavr_alu_c_sel_w - 1 downto 0);

   signal pavr_alu_out_int: std_logic_vector(15 downto 0);
   signal pavr_alu_flagsout_int: std_logic_vector(5 downto 0);

   -- Registers
   --    No registers
begin

   -- Compute ALU output and selectors for flags muxers.
   alu_out:
   process(pavr_alu_op1, pavr_alu_op2, pavr_alu_out_int, pavr_alu_opcode, pavr_alu_flagsin,
           tmp10_1, tmp10_2, tmp10_3,
           tmp18_1, tmp18_2, tmp18_3
          )
   begin
      -- Default ALU output to 0.
      pavr_alu_out_int <= int_to_std_logic_vector(0, pavr_alu_out_int'length);

      -- Default 8 bit adders's operands to ls8bits(operand1), operand2, carry in and carry out to 0.
      tmp10_1(0) <= '0';
      tmp10_2(0) <= '0';
      tmp10_1(8 downto 1) <= pavr_alu_op1(7 downto 0);
      tmp10_2(8 downto 1) <= pavr_alu_op2(7 downto 0);
      tmp10_1(9) <= '0';
      tmp10_2(9) <= '0';

      -- Default 16 bit adders's operands to operand1, signExtendTo16bits(operand2), carry in and carry out to 0.
      tmp18_1(0) <= '0';
      tmp18_2(0) <= '0';
      tmp18_1(16 downto 1) <= pavr_alu_op1(15 downto 0);
      tmp18_2(16 downto 1) <= sign_extend(pavr_alu_op2, 16);
      tmp18_1(17) <= '0';
      tmp18_2(17) <= '0';

      -- Default adders's outputs
      tmp10_3 <= int_to_std_logic_vector(0, tmp10_3'length);
      tmp18_3 <= int_to_std_logic_vector(0, tmp18_3'length);

      -- Default flags out to flags in.
      pavr_alu_h_sel <= pavr_alu_h_sel_same;
      pavr_alu_s_sel <= pavr_alu_s_sel_same;
      pavr_alu_v_sel <= pavr_alu_v_sel_same;
      pavr_alu_n_sel <= pavr_alu_n_sel_same;
      pavr_alu_z_sel <= pavr_alu_z_sel_same;
      pavr_alu_c_sel <= pavr_alu_c_sel_same;

      -- Build ALU output.
      case std_logic_vector_to_nat(pavr_alu_opcode) is
         when pavr_alu_opcode_add8 =>
            tmp10_3 <= tmp10_1 + tmp10_2;
            pavr_alu_out_int(7 downto 0) <= tmp10_3(8 downto 1);
            pavr_alu_h_sel <= pavr_alu_h_sel_add8;
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_add8;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
            pavr_alu_c_sel <= pavr_alu_c_sel_add8;
         when pavr_alu_opcode_adc8 =>
            tmp10_1(0) <= pavr_alu_flagsin(0);
            tmp10_2(0) <= pavr_alu_flagsin(0);
            tmp10_3 <= tmp10_1 + tmp10_2;
            pavr_alu_out_int(7 downto 0) <= tmp10_3(8 downto 1);
            pavr_alu_h_sel <= pavr_alu_h_sel_add8;
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_add8;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
            pavr_alu_c_sel <= pavr_alu_c_sel_add8;
         when pavr_alu_opcode_sub8 =>
            tmp10_1(0) <= '1';
            tmp10_3 <= tmp10_1 + (not tmp10_2);
            pavr_alu_out_int(7 downto 0) <= tmp10_3(8 downto 1);
            pavr_alu_h_sel <= pavr_alu_h_sel_sub8;
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_sub8;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
            pavr_alu_c_sel <= pavr_alu_c_sel_sub8;
         when pavr_alu_opcode_sbc8 =>
            tmp10_1(0) <= not pavr_alu_flagsin(0);
            tmp10_2(0) <= pavr_alu_flagsin(0);
            tmp10_3 <= tmp10_1 + (not tmp10_2);
            pavr_alu_out_int(7 downto 0) <= tmp10_3(8 downto 1);
            pavr_alu_h_sel <= pavr_alu_h_sel_sub8;
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_sub8;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8c;
            pavr_alu_c_sel <= pavr_alu_c_sel_sub8;
         when pavr_alu_opcode_and8 =>
            pavr_alu_out_int(7 downto 0) <= pavr_alu_op1(7 downto 0) and pavr_alu_op2;
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_z;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
         when pavr_alu_opcode_eor8 =>
            pavr_alu_out_int(7 downto 0) <= pavr_alu_op1(7 downto 0) xor pavr_alu_op2;
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_z;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
         when pavr_alu_opcode_or8 =>
            pavr_alu_out_int(7 downto 0) <= pavr_alu_op1(7 downto 0) or pavr_alu_op2;
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_z;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
         when pavr_alu_opcode_op1 =>
            pavr_alu_out_int <= pavr_alu_op1;
         when pavr_alu_opcode_op2 =>
            pavr_alu_out_int <= zero_extend(pavr_alu_op2, pavr_alu_out_int'length);
         when pavr_alu_opcode_inc8 =>
            tmp10_3 <= tmp10_1 + tmp10_2;
            pavr_alu_out_int(7 downto 0) <= tmp10_3(8 downto 1);
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_inc8;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
         when pavr_alu_opcode_dec8 =>
            tmp10_3 <= tmp10_1 + tmp10_2;
            pavr_alu_out_int(7 downto 0) <= tmp10_3(8 downto 1);
            pavr_alu_out_int(7 downto 0) <= tmp10_3(8 downto 1);
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_dec8;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
         when pavr_alu_opcode_com8 =>
            pavr_alu_out_int(7 downto 0) <= not pavr_alu_op1(7 downto 0);
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_z;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
            pavr_alu_c_sel <= pavr_alu_c_sel_one;
         when pavr_alu_opcode_neg8 =>
            tmp10_1 <= int_to_std_logic_vector(1, tmp10_1'length);
            tmp10_2(8 downto 1) <= pavr_alu_op1(7 downto 0);
            tmp10_3 <= tmp10_1 + (not tmp10_2);
            pavr_alu_out_int(7 downto 0) <= tmp10_3(8 downto 1);
            pavr_alu_h_sel <= pavr_alu_h_sel_neg8;
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_neg8;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
            pavr_alu_c_sel <= pavr_alu_c_sel_neg8;
         when pavr_alu_opcode_swap8 =>
            pavr_alu_out_int(7 downto 4) <= pavr_alu_op1(3 downto 0);
            pavr_alu_out_int(3 downto 0) <= pavr_alu_op1(7 downto 4);
         when pavr_alu_opcode_lsr8 =>
            pavr_alu_out_int(7) <= '0';
            pavr_alu_out_int(6 downto 0) <= pavr_alu_op1(7 downto 1);
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_nxorc;
            pavr_alu_n_sel <= pavr_alu_n_sel_z;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
            pavr_alu_c_sel <= pavr_alu_c_sel_lsbop1;
         when pavr_alu_opcode_asr8 =>
            pavr_alu_out_int(7) <= pavr_alu_op1(7);
            pavr_alu_out_int(6 downto 0) <= pavr_alu_op1(7 downto 1);
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_nxorc;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
            pavr_alu_c_sel <= pavr_alu_c_sel_lsbop1;
         when pavr_alu_opcode_ror8 =>
            pavr_alu_out_int(7) <= pavr_alu_flagsin(0);
            pavr_alu_out_int(6 downto 0) <= pavr_alu_op1(7 downto 1);
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_nxorc;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb8;
            pavr_alu_z_sel <= pavr_alu_z_sel_z8;
            pavr_alu_c_sel <= pavr_alu_c_sel_lsbop1;
         when pavr_alu_opcode_add16 =>
            tmp18_3 <= tmp18_1 + tmp18_2;
            pavr_alu_out_int(15 downto 0) <= tmp18_3(16 downto 1);
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_add16;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb16;
            pavr_alu_z_sel <= pavr_alu_z_sel_z16;
            pavr_alu_c_sel <= pavr_alu_c_sel_add16;
         when pavr_alu_opcode_sub16 =>
            tmp18_1(0) <= '1';
            tmp18_3 <= tmp18_1 + (not tmp18_2);
            pavr_alu_out_int(15 downto 0) <= tmp18_3(16 downto 1);
            pavr_alu_s_sel <= pavr_alu_s_sel_nxorv;
            pavr_alu_v_sel <= pavr_alu_v_sel_sub16;
            pavr_alu_n_sel <= pavr_alu_n_sel_msb16;
            pavr_alu_z_sel <= pavr_alu_z_sel_z16;
            pavr_alu_c_sel <= pavr_alu_c_sel_add16;
         -- Multiplications are not implemented for now.
         when pavr_alu_opcode_mul8 =>
            null;
         when pavr_alu_opcode_muls8 =>
            null;
         when pavr_alu_opcode_mulsu8 =>
            null;
         when pavr_alu_opcode_fmul8 =>
            null;
         when pavr_alu_opcode_fmuls8 =>
            null;
         when pavr_alu_opcode_fmulsu8 =>
            null;
         when others =>
            null;
      end case;
   end process alu_out;



   -- Select output flags based on the selectors computed in the process above.
   alu_flags:
   process(pavr_alu_op1, pavr_alu_op2, pavr_alu_out_int, pavr_alu_flagsin, pavr_alu_flagsout_int,
           pavr_alu_c_sel, pavr_alu_z_sel, pavr_alu_n_sel, pavr_alu_v_sel, pavr_alu_s_sel, pavr_alu_h_sel,
           tmp10_3, tmp18_3)
      variable tmp1, tmp2, tmp3, tmp4 : std_logic;
   begin
      tmp1 := '0';
      tmp2 := '0';
      tmp3 := '0';
      tmp4 := '0';

      -- Default flags out to flags in.
      pavr_alu_flagsout_int <= pavr_alu_flagsin;

      -- Build C flag.
      case pavr_alu_c_sel is
         when pavr_alu_c_sel_same =>
            pavr_alu_flagsout_int(0) <= pavr_alu_flagsin(0);
         when pavr_alu_c_sel_add8 | pavr_alu_c_sel_sub8 =>
            pavr_alu_flagsout_int(0) <= tmp10_3(9);
         when pavr_alu_c_sel_one =>
            pavr_alu_flagsout_int(0) <= '1';
         when pavr_alu_c_sel_neg8 =>
            -- Set carry if and only if input != 0 (equivalent to output != 0).
            pavr_alu_flagsout_int(0) <= pavr_alu_op1(0);
            for i in 1 to 7 loop
               pavr_alu_flagsout_int(0) <= pavr_alu_flagsout_int(0) or pavr_alu_op1(i);
            end loop;
         when pavr_alu_c_sel_lsbop1 =>
            pavr_alu_flagsout_int(0) <= pavr_alu_op1(0);
         -- When pavr_alu_c_sel_add16 | pavr_alu_c_sel_sub16
         when others =>
            pavr_alu_flagsout_int(0) <= tmp18_3(17);
      end case;

      -- Build Z flag.
      case pavr_alu_z_sel is
         when pavr_alu_z_sel_same =>
            pavr_alu_flagsout_int(1) <= pavr_alu_flagsin(1);
         when pavr_alu_z_sel_z8 =>
            tmp4 := pavr_alu_out_int(0);
            for i in 1 to 7 loop
               tmp4 := tmp4 or pavr_alu_out_int(i);
            end loop;
            pavr_alu_flagsout_int(1) <= not tmp4;
         when pavr_alu_z_sel_z8c =>
            tmp4 := pavr_alu_out_int(0);
            for i in 1 to 7 loop
               tmp4 := tmp4 or pavr_alu_out_int(i);
            end loop;
            pavr_alu_flagsout_int(1) <= (not tmp4) and pavr_alu_flagsin(1);
         -- When pavr_alu_z_sel_z16
         when others =>
            tmp4 := pavr_alu_out_int(0);
            for i in 1 to 15 loop
               tmp4 := tmp4 or pavr_alu_out_int(i);
            end loop;
            pavr_alu_flagsout_int(1) <= not tmp4;
      end case;

      -- Build N flag.
      case pavr_alu_n_sel is
         when pavr_alu_n_sel_same =>
            pavr_alu_flagsout_int(2) <= pavr_alu_flagsin(2);
         when pavr_alu_n_sel_msb8 =>
            pavr_alu_flagsout_int(2) <= pavr_alu_out_int(7);
         -- When pavr_alu_n_sel_msb16
         when others =>
            pavr_alu_flagsout_int(2) <= pavr_alu_out_int(15);
      end case;

      -- Build V flag.
      case pavr_alu_v_sel is
         when pavr_alu_v_sel_same =>
            pavr_alu_flagsout_int(3) <= pavr_alu_flagsin(3);
         when pavr_alu_v_sel_add8 =>
            tmp1 := pavr_alu_op1(7);
            tmp2 := pavr_alu_op2(7);
            tmp3 := pavr_alu_out_int(7);
            pavr_alu_flagsout_int(3) <= (tmp1 and tmp2 and (not tmp3)) or ((not tmp1) and (not tmp2) and tmp3);
         when pavr_alu_v_sel_sub8 =>
            tmp1 := pavr_alu_op1(7);
            tmp2 := pavr_alu_op2(7);
            tmp3 := pavr_alu_out_int(7);
            pavr_alu_flagsout_int(3) <= (tmp1 and (not tmp2) and (not tmp3)) or ((not tmp1) and tmp2 and tmp3);
         when pavr_alu_v_sel_z =>
            pavr_alu_flagsout_int(3) <= '0';
         when pavr_alu_v_sel_inc8 | pavr_alu_v_sel_neg8 =>
            pavr_alu_flagsout_int(3) <= not pavr_alu_out_int(0);
            for i in 1 to 6 loop
               pavr_alu_flagsout_int(3) <= pavr_alu_flagsout_int(3) and (not pavr_alu_out_int(i));
            end loop;
            pavr_alu_flagsout_int(3) <= pavr_alu_flagsout_int(3) and pavr_alu_out_int(7);
         when pavr_alu_v_sel_dec8 =>
            pavr_alu_flagsout_int(3) <= pavr_alu_out_int(0);
            for i in 1 to 6 loop
               pavr_alu_flagsout_int(3) <= pavr_alu_flagsout_int(3) and pavr_alu_out_int(i);
            end loop;
            pavr_alu_flagsout_int(3) <= pavr_alu_flagsout_int(3) and (not pavr_alu_out_int(7));
         when pavr_alu_v_sel_nxorc =>
            pavr_alu_flagsout_int(3) <= pavr_alu_flagsout_int(2) xor pavr_alu_flagsout_int(0);
         when pavr_alu_v_sel_add16 =>
            pavr_alu_flagsout_int(3) <= (not pavr_alu_op1(15)) and pavr_alu_out_int(15);
         -- When pavr_alu_v_sel_sub16
         when others =>
            pavr_alu_flagsout_int(3) <= pavr_alu_op1(15) and (not pavr_alu_out_int(15));
      end case;

      -- Build S flag.
      case pavr_alu_s_sel is
         when pavr_alu_s_sel_same =>
            pavr_alu_flagsout_int(4) <= pavr_alu_flagsin(4);
         -- When pavr_alu_s_sel_nxorv
         when others =>
            pavr_alu_flagsout_int(4) <= pavr_alu_flagsout_int(2) xor pavr_alu_flagsout_int(3);
      end case;

      tmp1 := pavr_alu_op1(3);
      tmp2 := pavr_alu_op2(3);
      tmp3 := pavr_alu_out_int(3);
      -- Build H flag.
      case pavr_alu_h_sel is
         when pavr_alu_h_sel_same =>
            pavr_alu_flagsout_int(5) <= pavr_alu_flagsin(5);
         when pavr_alu_h_sel_add8 =>
            pavr_alu_flagsout_int(5) <= (tmp1 and tmp2) or (tmp2 and (not tmp3)) or ((not tmp3) and tmp1);
         when pavr_alu_h_sel_sub8 =>
            pavr_alu_flagsout_int(5) <= ((not tmp1) and tmp2) or (tmp2 and tmp3) or (tmp3 and (not tmp1));
         -- When pavr_alu_h_sel_neg8 =>
         when others =>
            pavr_alu_flagsout_int(5) <= tmp1 or tmp3;
      end case;
   end process alu_flags;



   -- Zero-level assignments
   pavr_alu_out <= pavr_alu_out_int;
   pavr_alu_flagsout <= pavr_alu_flagsout_int;

end;
-- </File body>
