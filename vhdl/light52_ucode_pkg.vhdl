--------------------------------------------------------------------------------
-- light52_ucode_pkg.vhdl -- light52 microcode support package.
--------------------------------------------------------------------------------
-- A description of the microcode can be found in the core design document.
--------------------------------------------------------------------------------
-- Copyright (C) 2012 Jose A. Ruiz
--                                                              
-- This source file may be used and distributed without         
-- restriction provided that this copyright statement is not    
-- removed from the file and that any derivative work contains  
-- the original copyright notice and the associated disclaimer. 
--                                                              
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--                                                              
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--                                                              
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.opencores.org/lgpl.shtml
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.light52_pkg.all;


package light52_ucode_pkg is

---- Microcode fields ----------------------------------------------------------

subtype t_class is unsigned(5 downto 0);

-- Some encoding details are used by the decoding logic:
-- .- 2 LSBs are "10" for @Ri instruction classes.
-- .- lsb is 1 for LJMP/LCALL
constant F_ALU :                t_class := "000000";  -- Only 2 MSB significant
constant F_CJNE_A_IMM :         t_class := "010000";
constant F_CJNE_A_DIR :         t_class := "010001";
constant F_CJNE_RI_IMM :        t_class := "010010";
constant F_CJNE_RN_IMM :        t_class := "010011";
constant F_MOVX_DPTR_A :        t_class := "010100";
constant F_MOVX_A_DPTR :        t_class := "010101";
constant F_MOVX_A_RI :          t_class := "010110";
constant F_MOVX_RI_A :          t_class := "101110";
constant F_DJNZ_DIR :           t_class := "011000";
constant F_DJNZ_RN :            t_class := "011001";
constant F_MOVC_PC :            t_class := "011010";
constant F_MOVC_DPTR :          t_class := "011011";
constant F_BIT :                t_class := "011100";
constant F_OPC :                t_class := "011111";
constant F_SPECIAL :            t_class := "011101";
constant F_AJMP :               t_class := "110000";
constant F_LJMP :               t_class := "110001";
constant F_ACALL :              t_class := "110010";
constant F_LCALL :              t_class := "110011";
constant F_MOV_DPTR :           t_class := "110100";
constant F_XCH_DIR :            t_class := "110101";
constant F_XCH_RI :             t_class := "110110";
constant F_XCH_RN :             t_class := "110111";
constant F_JR :                 t_class := "101000";
constant F_JRB :                t_class := "101100";  -- 
constant F_RET :                t_class := "111001";  -- RET and RETI
constant F_JMP_ADPTR :          t_class := "111000";
constant F_PUSH :               t_class := "111100";
constant F_POP :                t_class := "111101";
constant F_NOP :                t_class := "100000";
constant F_XCHD :               t_class := "111110";
constant F_INVALID :            t_class := "111111";

-- Conditional jump condition selection field for F_JR and F_JRB classes.
subtype t_cc is unsigned(3 downto 0);

constant CC_Z :                 t_cc := "0000"; -- Check ALU op result
constant CC_NZ :                t_cc := "0001"; -- Check ALU op result
constant CC_C :                 t_cc := "0010";
constant CC_NC :                t_cc := "0011";
constant CC_ALWAYS :            t_cc := "0100";
constant CC_CJNE :              t_cc := "0101";
constant CC_BIT :               t_cc := "1000";
constant CC_NOBIT :             t_cc := "1001";
constant CC_ACCZ :              t_cc := "1010";
constant CC_ACCNZ :             t_cc := "1011";


-- 'ALU class' is the combination of source and destination operand types used 
-- in an ALU instruction. There is a different path in the state machine for
-- each of these classes.
subtype t_alu_class is unsigned(4 downto 0);

-- Encoding is arbitrary and not optimized.
constant AC_A_RI_to_A :         t_alu_class := "00000";
constant AC_RI_to_A :           t_alu_class := "00001";
constant AC_RI_to_RI :          t_alu_class := "00010";
constant AC_RI_to_D :           t_alu_class := "00011";
constant AC_D_to_A :            t_alu_class := "00100";
constant AC_D1_to_D :           t_alu_class := "00101";
constant AC_D_to_RI :           t_alu_class := "00110";

constant AC_D_to_D :            t_alu_class := "00111";
constant AC_A_RN_to_A :         t_alu_class := "01000";
constant AC_RN_to_RN :          t_alu_class := "01001";
constant AC_D_to_RN :           t_alu_class := "01010";
constant AC_RN_to_D :           t_alu_class := "01011";
constant AC_I_to_D :            t_alu_class := "01100";

constant AC_I_D_to_D :          t_alu_class := "01101";
constant AC_I_to_RI :           t_alu_class := "01110";
constant AC_I_to_RN :           t_alu_class := "01111";
constant AC_I_to_A :            t_alu_class := "10000";
constant AC_A_to_RI :           t_alu_class := "10001";
constant AC_A_to_D :            t_alu_class := "10010";
constant AC_A_D_to_A :          t_alu_class := "10011";
constant AC_A_to_RN :           t_alu_class := "10100";
constant AC_A_I_to_A :          t_alu_class := "10101";
constant AC_A_to_A :            t_alu_class := "10110";
constant AC_A_D_to_D :          t_alu_class := "10111";

constant AC_RN_to_A :           t_alu_class := "11000";
constant AC_DIV :               t_alu_class := "11010";
constant AC_MUL :               t_alu_class := "11011";
constant AC_DA :                t_alu_class := "11001";


-- ALU input operand selection control.
subtype t_alu_op_sel is unsigned(3 downto 0);
-- NOTE: the encoding of these constants is not arbitrary and is used in the 
-- CPU code (2 MSBs and 2 LSBs control separate muxes).
constant AI_A_T :               t_alu_op_sel := "0101";
constant AI_T_0 :               t_alu_op_sel := "0000";
constant AI_V_T :               t_alu_op_sel := "1001";
constant AI_A_0 :               t_alu_op_sel := "0100";

-- ALU function selection 
subtype t_alu_fns is unsigned(5 downto 0);

-- Arithmetic branch
constant A_ADD :        t_alu_fns := "000001";
constant A_SUB :        t_alu_fns := "001001"; -- Used by CJNE
constant A_ADDC :       t_alu_fns := "010001";
constant A_SUBB :       t_alu_fns := "011001";
constant A_INC :        t_alu_fns := "110001";
constant A_DEC :        t_alu_fns := "111001"; -- Used by DJNZ

-- Logic branch
constant A_ORL :        t_alu_fns := "001000";
constant A_ANL :        t_alu_fns := "000000";
constant A_XRL :        t_alu_fns := "010000";
constant A_NOT :        t_alu_fns := "011000";
constant A_SWAP :       t_alu_fns := "001100"; -- A or 0
-- Shift branch
constant A_RR :         t_alu_fns := "000010";
constant A_RRC :        t_alu_fns := "001010";
constant A_RL :         t_alu_fns := "010010";
constant A_RLC :        t_alu_fns := "011010";
-- External modules (external to the regular ALU)
constant A_DA :         t_alu_fns := "000110";
constant A_DIV :        t_alu_fns := "001110";
constant A_MUL :        t_alu_fns := "010110";
constant A_XCHD :       t_alu_fns := "011110";
-- Bit operations -- decoded by LSB = "11" -- ALU byte result unused.
-- This constant is not actually used. The initialization code appends the
-- 3 LSBs to a t_bit_fns value.
constant A_BIT :        t_alu_fns := "000011";

-- ALU input operand selection control. Arbitrary encoding.
subtype t_bit_fns is unsigned(3 downto 0);

constant AB_CLR :       t_bit_fns := "0000";
constant AB_SET :       t_bit_fns := "0001";
constant AB_CPL :       t_bit_fns := "0010";
constant AB_CPLC :      t_bit_fns := "0011";
constant AB_B :         t_bit_fns := "0100";
constant AB_C :         t_bit_fns := "0101";
constant AB_ANL :       t_bit_fns := "0110";
constant AB_ORL :       t_bit_fns := "0111";
constant AB_ANL_NB :    t_bit_fns := "1110";
constant AB_ORL_NB :    t_bit_fns := "1111";


subtype t_flag_mask is unsigned(1 downto 0);

constant FM_NONE :   t_flag_mask := "00";
constant FM_C :      t_flag_mask := "01";   -- C 
constant FM_C_OV :   t_flag_mask := "10";   -- C and OV
constant FM_ALL :    t_flag_mask := "11";   -- C, OV and AC

    
function build_decoding_table(bcd : boolean) return t_ucode_table;

end package light52_ucode_pkg;

package body light52_ucode_pkg is

function build_decoding_table(bcd : boolean) return t_ucode_table is
variable dt : t_ucode_table; 
variable code : integer;
begin
    
    -- Initialize the decoding table to an invalid uCode word. This will help
    -- catch unimplemented opcodes in the state machine.
    for i in 0 to 255 loop
        dt(i) := F_INVALID & "0000000000";
    end loop;
    
    
    -- AJMP/ACALL --------------------------------------------------------------
    code := 16#01#;
    for i in 0 to 7 loop
        dt(code+16#10#*(i*2+0)) := F_AJMP  & "00" & X"00";
        dt(code+16#10#*(i*2+1)) := F_ACALL & "00" & X"00";
    end loop;

    -- LJMP/LCALL --------------------------------------------------------------
    dt(16#02#) := (F_LJMP ) & "00" & X"00";
    dt(16#12#) := (F_LCALL) & "00" & X"00";

    -- SJMP/Jcc ----------------------------------------------------------------
    dt(16#40#+16#10#*(0)) := (F_JR) & CC_C      & "00" & X"0";
    dt(16#50#+16#10#*(0)) := (F_JR) & CC_NC     & "00" & X"0";
    dt(16#60#+16#10#*(0)) := (F_JR) & CC_ACCZ   & "00" & X"0";
    dt(16#70#+16#10#*(0)) := (F_JR) & CC_ACCNZ  & "00" & X"0";
    dt(16#80#+16#10#*(0)) := (F_JR) & CC_ALWAYS & "00" & X"0";
    

    -- MOV *,#data -------------------------------------------------------------
    
    code := 16#70#;
    dt(code+4) := "00" & AC_I_to_A  & FM_NONE & "0" & A_ORL;
    dt(code+5) := "00" & AC_I_to_D  & FM_NONE & "0" & A_ORL;
    dt(code+6) := "00" & AC_I_to_RI & FM_NONE & "0" & A_ORL;
    dt(code+7) := "00" & AC_I_to_RI & FM_NONE & "0" & A_ORL;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_I_to_RN & FM_NONE & "0" & A_ORL;
    end loop;

    
    -- MOV dir,* ---------------------------------------------------------------
    
    code := 16#80#;
    dt(code+5) := "00" & AC_D1_to_D & FM_NONE & "0" & A_ORL;
    dt(code+6) := "00" & AC_RI_to_D & FM_NONE & "0" & A_ORL;
    dt(code+7) := "00" & AC_RI_to_D & FM_NONE & "0" & A_ORL;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_RN_to_D & FM_NONE & "0" & A_ORL;
    end loop;    

    -- MOV *,dir ---------------------------------------------------------------
    
    code := 16#a0#;
    dt(code+6) := "00" & AC_D_to_RI & FM_NONE & "0" & A_ORL;
    dt(code+7) := "00" & AC_D_to_RI & FM_NONE & "0" & A_ORL;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_D_to_RN & FM_NONE & "0" & A_ORL;
    end loop;    
    
    
    -- XRL ---------------------------------------------------------------------
    
    code := 16#60#;
    dt(code+2) := "00" & AC_A_D_to_D  & FM_NONE & "0" & A_XRL;
    dt(code+3) := "00" & AC_I_D_to_D  & FM_NONE & "0" & A_XRL;
    dt(code+4) := "00" & AC_A_I_to_A  & FM_NONE & "0" & A_XRL;
    dt(code+5) := "00" & AC_A_D_to_A  & FM_NONE & "0" & A_XRL;
    dt(code+6) := "00" & AC_A_RI_to_A & FM_NONE & "0" & A_XRL;
    dt(code+7) := "00" & AC_A_RI_to_A & FM_NONE & "0" & A_XRL;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_RN_to_A & FM_NONE & "0" & A_XRL;
    end loop;

    -- ANL ---------------------------------------------------------------------
    
    code := 16#50#;
    dt(code+2) := "00" & AC_A_D_to_D  & FM_NONE & "0" & A_ANL;
    dt(code+3) := "00" & AC_I_D_to_D  & FM_NONE & "0" & A_ANL;
    dt(code+4) := "00" & AC_A_I_to_A  & FM_NONE & "0" & A_ANL;
    dt(code+5) := "00" & AC_A_D_to_A  & FM_NONE & "0" & A_ANL;
    dt(code+6) := "00" & AC_A_RI_to_A & FM_NONE & "0" & A_ANL;
    dt(code+7) := "00" & AC_A_RI_to_A & FM_NONE & "0" & A_ANL;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_RN_to_A & FM_NONE & "0" & A_ANL;
    end loop;

    -- ORL ---------------------------------------------------------------------
    
    code := 16#40#;
    dt(code+2) := "00" & AC_A_D_to_D  & FM_NONE & "0" & A_ORL;
    dt(code+3) := "00" & AC_I_D_to_D  & FM_NONE & "0" & A_ORL;
    dt(code+4) := "00" & AC_A_I_to_A  & FM_NONE & "0" & A_ORL;
    dt(code+5) := "00" & AC_A_D_to_A  & FM_NONE & "0" & A_ORL;
    dt(code+6) := "00" & AC_A_RI_to_A & FM_NONE & "0" & A_ORL;
    dt(code+7) := "00" & AC_A_RI_to_A & FM_NONE & "0" & A_ORL;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_RN_to_A & FM_NONE & "0" & A_ORL;
    end loop;

    
    -- INC * -------------------------------------------------------------------
    
    code := 16#00#;
    dt(code+4) := "00" & AC_A_to_A      & FM_NONE & "0" & A_INC;
    dt(code+5) := "00" & AC_D_to_D      & FM_NONE & "0" & A_INC;
    dt(code+6) := "00" & AC_RI_to_RI    & FM_NONE & "0" & A_INC;
    dt(code+7) := "00" & AC_RI_to_RI    & FM_NONE & "0" & A_INC;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_RN_to_RN  & FM_NONE & "0" & A_INC;
    end loop;

    
    -- DEC * -------------------------------------------------------------------
    
    code := 16#10#;
    dt(code+4) := "00" & AC_A_to_A      & FM_NONE & "0" & A_DEC;
    dt(code+5) := "00" & AC_D_to_D      & FM_NONE & "0" & A_DEC;
    dt(code+6) := "00" & AC_RI_to_RI    & FM_NONE & "0" & A_DEC;
    dt(code+7) := "00" & AC_RI_to_RI    & FM_NONE & "0" & A_DEC;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_RN_to_RN  & FM_NONE & "0" & A_DEC;
    end loop;    
    
    -- CJNE --------------------------------------------------------------------
    
    code := 16#b0#;
    dt(code+4) := F_CJNE_A_IMM  & CC_CJNE & A_SUB;
    dt(code+5) := F_CJNE_A_DIR  & CC_CJNE & A_SUB;
    dt(code+6) := F_CJNE_RI_IMM & CC_CJNE & A_SUB;
    dt(code+7) := F_CJNE_RI_IMM & CC_CJNE & A_SUB;
    for i in 8 to 15 loop
        dt(code+i) := F_CJNE_RN_IMM & CC_CJNE & A_SUB;
    end loop;

    -- DJNZ --------------------------------------------------------------------
    
    code := 16#d0#;
    dt(code+5) := F_DJNZ_DIR & CC_NZ & A_DEC;
    for i in 8 to 15 loop
        dt(code+i) := F_DJNZ_RN & CC_NZ & A_DEC;
    end loop;

    -- MOV A, * ----------------------------------------------------------------
    
    code := 16#e0#;
    dt(code+5) := "00" & AC_D_to_A & FM_NONE & "0" & A_ORL;
    dt(code+6) := "00" & AC_RI_to_A & FM_NONE & "0" & A_ORL;
    dt(code+7) := "00" & AC_RI_to_A & FM_NONE & "0" & A_ORL;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_RN_to_A & FM_NONE & "0" & A_ORL;
    end loop;

    -- MOV *, A ----------------------------------------------------------------
    
    code := 16#f0#;
    dt(code+5) := "00" & AC_A_to_D & FM_NONE & "0" & A_ORL;
    dt(code+6) := "00" & AC_A_to_RI & FM_NONE & "0" & A_ORL;
    dt(code+7) := "00" & AC_A_to_RI & FM_NONE & "0" & A_ORL;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_A_to_RN & FM_NONE & "0" & A_ORL;
    end loop;

    -- ADD ---------------------------------------------------------------------
    
    code := 16#20#;
    dt(code+4) := "00" & AC_A_I_to_A  & FM_ALL & "0" & A_ADD;
    dt(code+5) := "00" & AC_A_D_to_A  & FM_ALL & "0" & A_ADD;
    dt(code+6) := "00" & AC_A_RI_to_A & FM_ALL & "0" & A_ADD;
    dt(code+7) := "00" & AC_A_RI_to_A & FM_ALL & "0" & A_ADD;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_RN_to_A & FM_ALL & "0" & A_ADD;
    end loop;

    -- ADDC --------------------------------------------------------------------
    
    code := 16#30#;
    dt(code+4) := "00" & AC_A_I_to_A  & FM_ALL & "0" & A_ADDC;
    dt(code+5) := "00" & AC_A_D_to_A  & FM_ALL & "0" & A_ADDC;
    dt(code+6) := "00" & AC_A_RI_to_A & FM_ALL & "0" & A_ADDC;
    dt(code+7) := "00" & AC_A_RI_to_A & FM_ALL & "0" & A_ADDC;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_RN_to_A & FM_ALL & "0" & A_ADDC;
    end loop;

    -- SUBB --------------------------------------------------------------------
    
    code := 16#90#;
    dt(code+4) := "00" & AC_A_I_to_A  & FM_ALL & "0" & A_SUBB;
    dt(code+5) := "00" & AC_A_D_to_A  & FM_ALL & "0" & A_SUBB;
    dt(code+6) := "00" & AC_A_RI_to_A & FM_ALL & "0" & A_SUBB;
    dt(code+7) := "00" & AC_A_RI_to_A & FM_ALL & "0" & A_SUBB;
    for i in 8 to 15 loop
        dt(code+i) := "00" & AC_RN_to_A & FM_ALL & "0" & A_SUBB;
    end loop;

    
    -- Special ops on ACC ------------------------------------------------------
    
    dt(16#e4#) := "00" & AC_A_to_A & FM_NONE & "0" & A_ANL;  -- CLR A
    dt(16#f4#) := "00" & AC_A_to_A & FM_NONE & "0" & A_NOT;  -- CPL A
    dt(16#c4#) := "00" & AC_A_to_A & FM_NONE & "0" & A_SWAP; -- SWAP A
    
    dt(16#84#) := "00" & AC_DIV & FM_C_OV & "0" & A_DIV;     -- DIV AB
    dt(16#a4#) := "00" & AC_MUL & FM_C_OV & "0" & A_MUL;     -- MUL AB

    
    -- C and BIT instructions --------------------------------------------------

    -- C-only instructions: C operand, result written to C.
    dt(16#b3#) := (F_OPC) & "0" & FM_C & "0" & AB_CPLC & "11";      -- CPL C
    dt(16#c3#) := (F_OPC) & "0" & FM_C & "0" & AB_CLR & "11";       -- CLR C
    dt(16#d3#) := (F_OPC) & "0" & FM_C & "0" & AB_SET & "11";       -- SETB C

    
    -- BIT instructions. 
    --                       +---- '1' to write result to C.
    --                       |     '0' to write to BIT.
    --                       |
    dt(16#b2#) := (F_BIT) & "0" & FM_NONE & "0" & AB_CPL & "11";    -- CPL bit
    dt(16#c2#) := (F_BIT) & "0" & FM_NONE & "0" & AB_CLR & "11";    -- CLR bit
    dt(16#d2#) := (F_BIT) & "0" & FM_NONE & "0" & AB_SET & "11";    -- SETB bit
    
    dt(16#82#) := (F_BIT) & "1" & FM_C & "0" & AB_ANL & "11";   -- ANL C, bit
    dt(16#72#) := (F_BIT) & "1" & FM_C & "0" & AB_ORL & "11";   -- ORL C, bit
   
    dt(16#b0#) := (F_BIT) & "1" & FM_C & "0" & AB_ANL_NB & "11";-- ANL C, /bit
    dt(16#a0#) := (F_BIT) & "1" & FM_C & "0" & AB_ORL_NB & "11";-- ORL C, /bit

    dt(16#92#) := (F_BIT) & "0" & FM_NONE & "0" & AB_C & "11";  -- MOV bit, C
    dt(16#a2#) := (F_BIT) & "1" & FM_C & "0" & AB_B & "11";     -- MOV C, bit

    
    -- BIT test relative jumps -------------------------------------------------
    
    dt(16#10#) := (F_JRB) & CC_BIT & AB_CLR & "11";     -- LSBs="11" -> JBC
    dt(16#20#) := (F_JRB) & CC_BIT & A_ANL;             -- LSBs="00" -> not JBC
    dt(16#30#) := (F_JRB) & CC_NOBIT & A_ANL;           -- LSBs="00" -> not JBC

    
    -- Rotate instructions -----------------------------------------------------

    dt(16#33#) := "00" & AC_A_to_A  & FM_C & "0" & A_RLC;
    dt(16#23#) := "00" & AC_A_to_A  & FM_NONE & "0" & A_RL; 
    dt(16#13#) := "00" & AC_A_to_A  & FM_C & "0" & A_RRC;
    dt(16#03#) := "00" & AC_A_to_A  & FM_NONE & "0" & A_RR; 
    
    -- Special (or otherwise difficult to classify) instructions ---------------
     
    dt(16#a3#) := F_SPECIAL  & "0000000000";                -- INC DPTR
    dt(16#90#) := F_MOV_DPTR & "0000" & A_ORL;              -- MOV DPTR, #imm16
    dt(16#c0#) := F_PUSH & "0" & FM_NONE & "0" & A_ORL;     -- PUSH dir
    dt(16#d0#) := F_POP & "0" & FM_NONE & "0" & A_ORL;      -- POP dir
    dt(16#73#) := F_JMP_ADPTR & "0000000000";               -- JMP @A+DPTR
    dt(16#22#) := F_RET & "0000000000";                     -- RET
    dt(16#32#) := F_RET & "0000000001";                     -- RETI
      
    -- MOVX/MOVC instructions --------------------------------------------------

    dt(16#e0#) := F_MOVX_A_DPTR & "0000000000";     -- MOVX A, @DPTR
    dt(16#f0#) := F_MOVX_DPTR_A & "0000000000";     -- MOVX @DPTR, A

    dt(16#e2#) := F_MOVX_A_RI & "0" & "000" & A_ORL;  -- MOVX A, @R0
    dt(16#e3#) := F_MOVX_A_RI & "0" & "000" & A_ORL;  -- MOVX A, @R1
    dt(16#f2#) := F_MOVX_RI_A & "1" & "000" & A_ORL;  -- MOVX @R0, A
    dt(16#f3#) := F_MOVX_RI_A & "1" & "000" & A_ORL;  -- MOVX @R1, A
    
    dt(16#83#) := F_MOVC_PC   & "0000000000";       -- MOVC A, @A+PC @R1, A
    dt(16#93#) := F_MOVC_DPTR & "0000000000";       -- MOVC A, @A+DPTR

    -- XCH instructions --------------------------------------------------------
    
    code := 16#c0#;
    dt(code+5) := F_XCH_DIR & "0000" & A_ORL;       -- XCH A, dir
    dt(code+6) := F_XCH_RI & "0000" & A_ORL;        -- XCH A, @R0
    dt(code+7) := F_XCH_RI & "0000" & A_ORL;        -- XCH A, @R1
    
    for i in 8 to 15 loop
        dt(code+i) := F_XCH_RN & "0000" & A_ORL;    -- XCH A, Rn
    end loop;
    
    -- BCD instructions --------------------------------------------------------
    
    if bcd then 
        -- BCD instructions fully implemented
        dt(16#d4#) := "00" & AC_DA & FM_C & "0" & A_DA;         -- DA A
        dt(16#d6#) := F_XCHD & "0" & FM_NONE & "0" & A_XCHD;    -- XCHD A, @R0
        dt(16#d7#) := F_XCHD & "0" & FM_NONE & "0" & A_XCHD;    -- XCHD A, @R1
    else
        -- BCD instructions implemented as NOPs
        dt(16#d4#) := F_NOP & "0000000000";         -- DA A
        dt(16#d6#) := F_NOP & "0000000000";         -- XCHD A, @R0
        dt(16#d7#) := F_NOP & "0000000000";         -- XCHD A, @R1
    end if;
    
    
    -- NOPs --------------------------------------------------------------------
    dt(16#00#) := F_NOP & "0000000000";             -- NOP
    dt(16#a5#) := F_NOP & "0000000000";             -- Unused opcode A5h
    
    
    return dt;
end function build_decoding_table;

end package body;


