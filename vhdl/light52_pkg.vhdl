--------------------------------------------------------------------------------
-- light52_pkg.vhdl -- Constants and utility functions for light52 core.
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

--use work.txt_util.all;

package light52_pkg is

---- SFR addresses -------------------------------------------------------------

subtype t_byte is unsigned(7 downto 0);

-- These include only the CPU SFRs (B,ACC,PSW,DPH,DPL,SP,IE,IP)
constant SFR_ADDR_ACC       : t_byte := X"E0";
constant SFR_ADDR_PSW       : t_byte := X"D0";
constant SFR_ADDR_B         : t_byte := X"F0";
constant SFR_ADDR_SP        : t_byte := X"81";
constant SFR_ADDR_DPH       : t_byte := X"83";
constant SFR_ADDR_DPL       : t_byte := X"82";
constant SFR_ADDR_IE        : t_byte := X"A8";
constant SFR_ADDR_IP        : t_byte := X"B8";


---- Configuration constants ---------------------------------------------------

---- Magic numbers - not to be changed! ----------------------------------------
constant BRAM_SIZE : integer := 512;

---- Basic types ---------------------------------------------------------------

subtype t_address is unsigned(15 downto 0);
subtype t_word is unsigned(15 downto 0);
subtype t_ebyte is unsigned(8 downto 0);

-- Decoding table; only has 128 16-bit entries, Rn opcodes are not included.
type t_ucode_bram is array(0 to BRAM_SIZE-1) of t_byte;

-- Decoding table entry.
subtype t_ucode is unsigned(15 downto 0);
-- Table of decoding words ('microcode'); one entry per opcode.
-- This is NOT the same as the decoding table; entries for Rn opcodes are not
-- used in the decoding table.
type t_ucode_table is array(0 to 255) of t_ucode;

-- Generic BRAM initialization constant.
type t_bram is array(integer range <>) of std_logic_vector(7 downto 0);

-- Object code (i.e. contents of code ROM). Length not related to BRAM size.
type t_obj_code is array(natural range <>) of std_logic_vector(7 downto 0);
-- Object code used by default if no other is given in the MCU generic.
constant default_object_code : t_obj_code(0 to 31) := (
    X"01", X"0f", X"00", X"56", X"67", X"78", X"89", X"9a",
    X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
    X"01", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
    X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"
    );

-- Internal state machine states. They are defined here so that they are visible
-- to the logging functions in the tb package.
type t_cpu_state is (
    reset_0,                    --

    -- Fetch & decode -----------------------------------------------
    fetch_0,                    -- pc in code_addr
    fetch_1,                    -- opcode in code_rd
    decode_0,                   -- microcode in BRAM output
    
    -- States for interrupt handling
    irq_1,                      -- SP++, Addr := irq_vector
    irq_2,                      -- SP++, RAM[AB]  := low(PC), AB := SP
    irq_3,                      -- RAM[AB]  := high(PC), AB := SP
    irq_4,                      -- long_jump

    -- States for LJMP
    fetch_addr_0,               -- Addr(L) := CODE
    fetch_addr_1,               -- Addr(H) := CODE
    fetch_addr_0_ajmp,          -- Addr(L) := CODE, Addr(H) := PC(H)|OPCODE
    long_jump,                  -- Do actual jump
    
    -- States for relative jump instructions 
    load_rel,                   --
    rel_jump,
    
    -- States for MUL & DIV
    alu_mul_0,
    alu_div_0,
    
    -- States for CJNE 
    cjne_a_imm_0,               -- T <- #imm
    cjne_a_imm_1,               -- byte1_reg <- rel
    cjne_a_imm_2,               -- do rel jump

    cjne_ri_imm_0,               -- AB,AR    := <Rx>
    cjne_ri_imm_1,               -- AR       := RAM[AB]
    cjne_ri_imm_2,               -- AB       := AR   
    cjne_ri_imm_3,               -- V        := RAM[AB], T := CODE
    cjne_ri_imm_4,               -- byte1_reg <- rel
    cjne_ri_imm_5,               -- do rel jump
    
    cjne_a_dir_0,               -- code_to_ab
    cjne_a_dir_1,               -- ram_to_t
    cjne_a_dir_2,               -- byte1_reg <- rel
    cjne_a_dir_3,               -- do rel jump
    
    cjne_rn_imm_0,              -- AB,AR    := <Rx>
    cjne_rn_imm_1,              -- V        := RAM[AR], T := CODE  
    cjne_rn_imm_2,              -- addr0_reg <- code
    cjne_rn_imm_3,              -- do rel jump

    -- States for MOVC instructions 
    movc_pc_0,
    movc_dptr_0,
    movc_1,
    
    -- States for ACALL & LCALL instructions
    acall_0,                    -- SP++, Addr(L) := CODE, Addr(H) := PC(H)|OPCODE    
    acall_1,                    -- RAM[AB]  := low(PC), AB := SP, SP++
    acall_2,                    -- RAM[AB]  := high(PC), AB := SP
    -- continues at long_jump
    
    lcall_0,                    -- Addr(L) := CODE
    lcall_1,                    -- SP++, Addr(H) := CODE
    lcall_2,                    -- SP++, RAM[AB]  := low(PC), AB := SP
    lcall_3,                    -- RAM[AB]  := high(PC), AB := SP
    lcall_4,                    -- long_jump
    
    -- States for JMP @A+DPTR
    jmp_adptr_0,                -- long jump with A+DPTR as target
    
    -- States for RET, RETI
    ret_0,                      -- Addr(H)  := RAM[B], SP--, AR,AB := SP
    ret_1,                      -- Addr(L)  := RAM[B], SP--, AR,AB := SP
    ret_2,                      -- long_jump    
    ret_3,    
    
    -- States for DJNZ Rn
    djnz_rn_0,
    
    -- States for DJNZ dir
    -- From djnz_dir_1 onwards, they are common to DJNZ Rn; 
    -- TODO should rename common states
    djnz_dir_0,                 -- addr0_reg <- dir
    djnz_dir_1,                 -- T <- [dir]
    djnz_dir_2,                 -- [dir] <- alu result, 
    djnz_dir_3,                 -- addr0_reg <- code
    djnz_dir_4,                 -- do rel jump

    -- States for special instructions line INC DPTR.
    special_0,                  -- Do special deed
    
    -- States for MOV DPTR, #imm16
    mov_dptr_0,                 -- T        := CODE
    mov_dptr_1,                 -- T        := CODE, DPH := T
    mov_dptr_2,                 -- DPL      := T
    
    -- States for XCH instructions 
    xch_dir_0,                  -- AB,AR    := CODE
    xch_rn_0,                   -- AB,AR    := <Rx>
    xch_rx_0,                   -- AB,AR    := <Rx>
    xch_rx_1,                   -- AB,AR    := RAM[AB]
    xch_1,                      -- T        := RAM[AB]
    xch_2,                      -- RAM[AB]  := ALU (A,0)
    xch_3,                      -- A        := ALU (T,0)
    
    -- States for MOVX A,@Ri and MOVX @Ri,A
    movx_a_ri_0,
    movx_a_ri_1,
    movx_a_ri_2,
    movx_a_ri_3,
    
    movx_ri_a_0,
    movx_ri_a_1,
    movx_ri_a_2,
    movx_ri_a_3,
    movx_ri_a_4,
    
    -- states for MOVX A,@DPTR and MOVX @DPTR,A
    movx_dptr_a_0,
    movx_a_dptr_0,
    
    -- States for JBC, JB and JNB: bit-testing relative jumps
    jrb_bit_0,                  -- AB,AR    := bit<CODE>
    jrb_bit_1,                  -- T        := RAM[AB]
    jrb_bit_2,                  -- RAM[AR]  := ALU_BIT
    jrb_bit_3,                  -- addr0_reg <- code
    jrb_bit_4,                  -- do rel jump
    
    -- States for BIT instructions (CPL, CLR, SETB)
    bit_op_0,                   -- AB,AR    := bit<CODE>
    bit_op_1,                   -- T        := RAM[AB]
    bit_op_2,                   -- RAM[AR]  := ALU_BIT
    
    -- States for PUSH and POP 
    push_0,                     -- AB       := CODE
    push_1,                     -- T        := RAM[AB], SP++
    push_2,                     -- RAM[AB]  := ALU, AB := SP
    
    pop_0,                      -- AB       := SP
    pop_1,                      -- T        := RAM[B], SP--, AR,AB := CODE
    pop_2,                      -- RAM[AR]  := T
    
    -- States for DA A
    alu_daa_0,                  -- 1st stage of DA operation (low nibble)
    alu_daa_1,                  -- 2nd stage of DA operation (high nibble)
    
   
    -- States for XCHD A,@Ri
    alu_xchd_0,                 -- AB,AR    := <Rx>
    alu_xchd_1,                 -- AR       := RAM[AB]
    alu_xchd_2,                 -- AB       := AR
    alu_xchd_3,                 -- T        := RAM[AB]
    alu_xchd_4,                 -- RAM[AB]  := ALU
    alu_xchd_5,                 -- A        := ALU'
    
    -- States used to fetch operands and store result of ALU class instructions 
    alu_rx_to_ab,               -- AB,AR    := <Rx>
    alu_ram_to_ar,              -- AR       := RAM[AB]
    alu_ar_to_ab,               -- AB       := AR
    alu_ram_to_t,               -- T        := RAM[AB]
    alu_res_to_a,               -- A        := ALU
    alu_ram_to_t_code_to_ab,    -- T        := RAM[AR], AB,AR := CODE 
    alu_res_to_ram,             -- RAM[AB]  := ALU
    alu_code_to_ab,             -- AB,AR    := CODE
    alu_ram_to_t_rx_to_ab,      -- T        := RAM[AR], AB,AR := <Rx> 
    alu_ram_to_ar_2,            -- AR       := RAM[AB]    
    alu_res_to_ram_ar_to_ab,    -- RAM[AB]  := ALU,     AB := AR
    alu_res_to_ram_code_to_ab,  -- RAM[AB]  := ALU,     AB := CODE
    alu_code_to_t,              -- T        := CODE
    alu_ram_to_v_code_to_t,     -- V        := RAM[AR], T := CODE 
    alu_code_to_t_rx_to_ab,     -- T        := CODE,    AB,AR := <Rx>
    
    -- States used to fetch operands and store result os BIT class instructions
    bit_res_to_c,               -- C        := BIT_ALU
    
    -- Other states -------------------------------------------------

    bug_bad_addressing_mode,    -- Bad field in microcode word
    bug_bad_opcode_class,       -- Bad field in microcode word
    state_machine_derailed      -- State machine entered invalid state
    );

-- DIV_OVERLAP: how many cycles in the sequential divider overlap other state 
-- machine cycles.
-- This is the 2 first cycles of the instruction following DIV.
constant DIV_OVERLAP        : integer := 1;
-- MUL_OVERLAP: same as above, for sequential multiplier.
constant MUL_OVERLAP        : integer := 1;    
        
    
---- Utility functions ---------------------------------------------------------

-- Computes ceil(log2(A)), e.g. address width of memory block.
-- CAN BE USED IN SYNTHESIZABLE CODE as long as called with constant arguments.
function log2(A : natural) return natural;

-- Builds a BRAM initialization constant from a constant byte array containing 
-- the microcode. The 256 bytes of microcode will be placed at the beginning
-- of the BRAM and the rest will be filled with zeros.
-- CAN BE USED IN SYNTHESIZABLE CODE to compute a BRAM initialization constant 
-- from a constant argument.
function ucode_to_bram(uC : t_ucode_table) return t_ucode_bram;

-- Builds BRAM initialization constant from a constant CONSTRAINED byte array
-- containing the application object code.
-- The object code is placed at the beginning of the BRAM and the rest is
-- filled with zeros.
-- CAN BE USED IN SYNTHESIZABLE CODE to compute a BRAM initialization constant 
-- from a constant argument.
function objcode_to_bram(oC : t_obj_code; size : integer) return t_bram;

end package light52_pkg;


--------------------------------------------------------------------------------

package body light52_pkg is

function log2(A : natural) return natural is
begin
    for I in 1 to 30 loop -- Works for up to 32 bit integers
        if(2**I >= A) then 
            return(I);
        end if;
    end loop;
    return(30);
end function log2;

function ucode_to_bram(uC : t_ucode_table) return t_ucode_bram is
variable br : t_ucode_bram;
variable opcode, index: integer;
begin
    -- Copy uCode to start of BRAM...
    index := 0;
    for row in 0 to 7 loop
        for col in 0 to 15 loop
            opcode := col * 16 + row;
            --print(str(opcode, 16));
            --if uc(opcode) /= x"0000" then
            --    print(str(index,16)& " --> "& hstr(std_logic_vector(uc(opcode))));
            --end if;
            br(index*2 + 0) := uC(opcode)(15 downto 8);
            br(index*2 + 1) := uC(opcode)( 7 downto 0);
            index := index + 1;
        end loop;
    end loop;
    
    -- ... and fill the rest with zeros
    if BRAM_SIZE > 256 then
        br(256 to BRAM_SIZE-1) := (others => x"00");
    end if;
    
    return br;
end function ucode_to_bram;

function objcode_to_bram(oC : t_obj_code; size : integer) return t_bram is
variable br : t_bram(integer range 0 to size-1);
variable obj_size : integer;
begin
    
    -- If the object code table is longer than the array size, kill synthesis.
    assert oC'length <= size
    report "Object code does not fit in XCODE ROM."
    severity failure;

    obj_size := oC'length;

    -- Copy object code to start of BRAM...
    for i in 0 to obj_size-1 loop
        br(i) := oC(i);
    end loop;
    
    -- ... and fill the rest with zeros
    br(obj_size to size-1) := (others => x"00");
    
    return br;
end function objcode_to_bram;

end package body;

