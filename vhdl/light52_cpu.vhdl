--------------------------------------------------------------------------------
-- light52_cpu.vhdl -- light52 MCS51-compatible CPU core.
--------------------------------------------------------------------------------
-- This is a 'naive' implementation of the MCS51 architecture that trades area 
-- for speed. 
-- 
-- At the bottom of the file there are some design notes referenced throughout
-- the code ('@note1' etc.).
--------------------------------------------------------------------------------
-- GENERICS:
--
--
-- IMPLEMENT_BCD_INSTRUCTIONS   -- Whether or not to implement BCD instructions.
--  When true, instructions DA and XCHD will work as in the original MCS51.
--  When false, those instructions will work as NOP, saving some logic.
--
-- SEQUENTIAL_MULTIPLIER        -- Sequential vs. combinational multiplier.
--  When true, a sequential implementation will be used for the multiplier, 
--  which will usually save a lot of logic or a dedicated multiplier.
--  When false, a combinational registered multiplier will be used.
--  (NOT IMPLEMENTED -- setting it to true will raise an assertion failure).
--
-- USE_BRAM_FOR_XRAM            -- Use extra space in IRAM/uCode RAM as XRAM.
--  When true, extra logic will be generated so that the extra space in the 
--  RAM block used for IRAM/uCode can be used as XRAM.
--  This prevents RAM waste at some cost in area and clock rate.
--  When false, any extra space in the IRAM physical block will be wasted.
--
--------------------------------------------------------------------------------
-- INTERFACE SIGNALS:
--
-- clk :                Clock, active rising edge.
-- reset :              Synchronous reset, hold for at least 1 cycle.
--
--                      XCODE is assumed to be a synchronous ROM:
--
-- code_addr :          XCODE space address. 
-- code_rd :            XCODE read data. Must be valid at all times with 1 
--                      cycle of latency (synchronous memory):
--                      code_rd[n] := XCODE(code_addr[n-1])
--
--                      Interrupts are   
--
-- irq_source :         Interrupt inputs. 
--                      0 is for vector 03h, 4 is for vector 23h.
--                      Not registsred; must be synchronous and remain high 
--                      through a fetch_1 state in order to be acknowledged.
--                      Priorities are fixed: 0 highest, 4 lowest.
--
--                      XDATA is expected to be a synchronous 1-port RAM:
--
-- xdata_addr :         XDATA space address, valid when xdata_vma is '1'.
-- xdata_vma :          Asserted high when an XDATA rd/wr cycle is being done.
-- xdata_rd :           Read data. Must be valid the cycle after xdata_vma is
--                      asserted with xdata_we='0'.
-- xdata_wr :           Write data. Valid when xdata_vma is asserted with 
--                      xdata_we='1';
-- xdata_we :           '1' for XDATA write cycles, '0' for read cycles.
--
--                      SFRs external to the CPU are accessed as synchonous RAM:
--
-- sfr_addr :           SFR space address, valid when sfr_vma='1'.
-- sfr_vma :            Asserted high when an SFR rd/wr cycle is being done. 
-- sfr_rd :             Read data. Must be valid the cycle after sfr_vma is
--                      asserted with sfr_we='0'.
-- sfr_wr :             Write data. Valid when sfr_vma is asserted with 
--                      sfr_we='1';
-- sfr_we :             '1' for SFR write cycles, '0' for read cycles.
--
--  Note there's no code_vma. Even if there was one, see limitation #1 below. 
--------------------------------------------------------------------------------
-- MAJOR LIMITATIONS:
--
-- 1.-  Harvard architecture only.
--      The core does not support non-Harvard, unified memory space (i.e. XCODE 
--      and XDATA on the same blocks). Signal sfr_vma is asserted the cycle 
--      before a fetch_1 state, when a code byte needs to be present at code_rd.
--      In other words, XCODE and XDATA accesses are always simultaneous.
--      Until the core supports wait states it only supports Harvard memory
--      or a dual-port XCODE/XDATA memory.
--
-- 2.-  No support yet for sequential multiplier, only combinational.
--      Setting SEQUENTIAL_MULTIPLIER to true will result in a synthesis
--      or simulation failure. 
--      The core will use a dedicated multiplier block if the architecture & 
--      synthesis options allow for it (e.d. DSP48).
-- 
-- 3.-  Wasted space in RAM block used for IRAM.
--      Setting USE_BRAM_FOR_XRAM to true will result in a synthesis
--      or simulation failure.
--      Architectures with BRAM blocks larger than 512 bytes (e.g. Xilinx 
--      Spartan) will have a lot of wasted space in the IRAM/uCode RAM block.
--------------------------------------------------------------------------------
-- FIXMES:
-- 
-- 1.-  States fetch_1 and decode_0 might be overlapped with some other states
--      for a noticeable gain in performance.
-- 2.-  Brief description of architecture is missing.
-- 3.-  Add optional 2nd DPTR register and implicit INC DPTR feature.
-- 4.-  Everything coming straight from a _reg should be named _reg too.
--------------------------------------------------------------------------------
-- REFERENCES:
-- [1] Tips for vendor-agnostic BRAM inference:
--     http://www.danstrother.com/2010/09/11/inferring-rams-in-fpgas/
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
use work.light52_ucode_pkg.all;

entity light52_cpu is
    generic (
        -- Do not map unused BRAM onto XRAM space.
        USE_BRAM_FOR_XRAM : boolean := false;
        -- Implement DA and XCHD instructions by default.
        IMPLEMENT_BCD_INSTRUCTIONS : boolean := false;
        -- Use a combinational (dedicated) multiplier by default. 
        SEQUENTIAL_MULTIPLIER : boolean := false
    );
    port(
        clk             : in std_logic;
        reset           : in std_logic;
        
        code_addr       : out std_logic_vector(15 downto 0);
        code_rd         : in std_logic_vector(7 downto 0);
        
        irq_source      : in std_logic_vector(4 downto 0);
        
        xdata_addr      : out std_logic_vector(15 downto 0);
        xdata_rd        : in std_logic_vector(7 downto 0);
        xdata_wr        : out std_logic_vector(7 downto 0);
        xdata_vma       : out std_logic;
        xdata_we        : out std_logic;
        
        sfr_addr        : out std_logic_vector(7 downto 0);
        sfr_rd          : in std_logic_vector(7 downto 0);
        sfr_wr          : out std_logic_vector(7 downto 0);
        sfr_vma         : out std_logic;
        sfr_we          : out std_logic
    );
end entity light52_cpu;


architecture microcoded of light52_cpu is

---- Microcode table & instruction decoding ------------------------------------

signal ucode :              unsigned(15 downto 0);  -- uC word
signal ucode_1st_half :     unsigned(15 downto 0);  -- uC if 1st-half opcode
signal ucode_2nd_half :     unsigned(15 downto 0);  -- uC if 2nd-half opcode 
signal ucode_2nd_half_reg : unsigned(15 downto 0);  --
signal ucode_is_2nd_half :  std_logic;              -- opcode is 2-nd half
signal ucode_pattern :      unsigned(2 downto 0);   -- table row to replicate
signal ucode_index :        unsigned(6 downto 0);   -- index into uC table
signal do_fetch :           std_logic;              -- opcode is in code_rd

-- uC class (t_class), only valid in state decode_0
signal uc_class_decode_0 :  t_class;
-- ALU instruction class (t_alu_class), only valid in state decode_0
signal uc_alu_class_decode_0 : t_alu_class;
-- registered uc_alu_class_decode_0, used in state machine
signal uc_alu_class_reg :   t_alu_class;
-- ALU control, valid only in state decode_0
signal uc_alu_fn_decode_0 : t_alu_fns;
-- uc_alu_fn_decode_0 registered
signal alu_fn_reg :         t_alu_fns;
-- Controls ALU/bitfield mux in the datapath.
signal dpath_mux0_reg :     std_logic;
-- Flag mask for ALU instructions
signal uc_alu_flag_mask :   t_flag_mask;
-- Flag mask for all instructions; valid in state decode_0 only
signal flag_mask_decode_0 : t_flag_mask;
-- Flag mask register for ALL instructions
signal flag_mask_reg :      t_flag_mask;
-- Index of Rn register, valid for Rn addressing instructions only
signal rn_index :           unsigned(2 downto 0);


---- Datapath ------------------------------------------------------------------

-- Operand selection for ALU class instructions
signal alu_class_op_sel_reg: t_alu_op_sel;
signal alu_class_op_sel :   t_alu_op_sel;
-- ALU result valid for non-bit operations -- faster as it skips one mux
signal nobit_alu_result :   t_byte;
-- ALU result
signal alu_result :         t_byte;
signal alu_result_is_zero : std_logic;  -- ALU result is zero
signal acc_is_zero :        std_logic;  -- ACC is zero

signal alu_cy :             std_logic;  -- ALU CY output
signal alu_ov :             std_logic;  -- ALU OV output
signal alu_ac :             std_logic;  -- ALU AC (aux cy) output
signal bit_input :          std_logic;  -- Value of ALU bit operand

signal load_b_sfr :         std_logic;  -- B register load enable
signal mul_ready :          std_logic;  -- Multiplier is finished
signal div_ready :          std_logic;  -- Divider is finished
signal div_ov :             std_logic;  -- OV flag from divider

---- State machine -------------------------------------------------------------

-- Present state register and Next state
signal ps, ns :             t_cpu_state;

---- Interrupt handling --------------------------------------------------------

-- IRQ inputs ANDed to IE mask bits.
signal irq_masked_inputs :  std_logic_vector(4 downto 0);
-- IRQ inputs ANDed to IE mask bits ANDed to IP mask bits.
signal irq_masked_inputs_hp :  std_logic_vector(4 downto 0);
-- Level of highest-level active IRQ input. 0 is highest, 4 lowest, 7 is none.
signal irq_level_inputs :   unsigned(2 downto 0);
-- Low 6 bits of IRQ service address.
signal irq_vector :         unsigned(5 downto 0);
signal irq_active :         std_logic;  -- IRQ pending service
signal load_ie :            std_logic;  -- IE register load enable
signal load_ip :            std_logic;  -- IP register load enable
-- Restore irq priority level (as per RETI execution).
signal irq_restore_level :  std_logic;
-- High wwhen the active IRQ is allowed by the priority rules.
signal irq_active_allowed : std_logic;
-- High when serving a LOw Priority interrupt.
signal irq_serving_lop :    std_logic;
-- High when serving a HIgh Priority interrupt.
signal irq_serving_hip :    std_logic;
-- High when the active interrupt line is a HIgh Priority interrupt.
signal irq_active_hip :     std_logic;

---- CPU programmer's model registers ------------------------------------------

signal PC_reg :             t_address;      -- PC
signal pc_incremented :     t_address;      -- PC + 1 | PC, controlled by...
signal increment_pc :       std_logic;      -- ...PC increment enable 
signal A_reg :              t_byte;         -- ACC    
signal B_reg :              t_byte;         -- B
signal PSW_reg :            unsigned(7 downto 1); -- PSW excluding P flag
signal PSW :                t_byte;         -- PSW, full (P is combinational)
signal SP_reg :             t_byte;         -- SP
signal SP_next :            t_byte;         -- Next value for SP
signal IE_reg :             t_byte;         -- IE
signal IP_reg :             t_byte;         -- IP


signal alu_p :              std_logic;      -- P flag (from ALU)
signal DPTR_reg :           t_address;      -- DPTR

signal next_pc :            t_address;      -- Next value for PC
signal jump_target :        t_address;      -- Addr to jump to
signal jump_is_ljmp :       std_logic;      -- When doing jump, long jump
signal instr_jump_is_ljmp : std_logic;      -- For jump opcodes, long jump
signal rel_jump_target :    t_address;      -- Address of a short jump
signal rel_jump_delta :     t_address;      -- Offset of short jump
-- 2K block index for AJMP/ACALL. Straight from the opcode.
signal block_reg :          unsigned(2 downto 0);
signal code_byte :          t_byte;     -- Byte from XCODE (transient)
signal ri_addr :            t_byte;     -- IRAM address of Ri register
signal rn_addr :            t_byte;     -- IRAM address of Rn register
-- The current ALU instruction CLASS uses Ri, not Rn
signal alu_use_ri_by_class : std_logic;
-- The current ALU instruction uses Ri and not Rn.
signal alu_use_ri :         std_logic;  
-- The current instruction is not an ALU instruction and uses Ri, not Rn
signal non_alu_use_ri :     std_logic;
-- The current instruction uses Ri and not Rn
signal use_ri :             std_logic;
-- Registered use_ri, controls the Ri/Rn mux.
signal use_ri_reg :         std_logic;
signal rx_addr :            t_byte;     -- Output of Ri/Rx address selection mux
signal bit_addr :           t_byte;     -- Byte address of bit operand
-- Index of bit operand within its byte.
signal bit_index :          unsigned(2 downto 0);
-- bit_index_registered in state decode_0
signal bit_index_reg :      unsigned(2 downto 0);
signal addr0_reg :          t_byte;     -- Aux address register 0...
signal addr0_reg_input :    t_byte;     -- ...and its input mux
signal addr1_reg :          t_byte;     -- Aux addr reg 1

-- Asserted when the PSW flags are implicitly updated by any instruction
signal update_psw_flags :   std_logic;
signal load_psw :           std_logic;  -- PSW explicit (SFR) load enable
signal load_acc_sfr :       std_logic;  -- ACC explicit (SFR) load enable
signal load_addr0 :         std_logic;  -- Addr0 load enable
signal load_sp :            std_logic;  -- SP explicit (SFR) load enable
signal load_sp_implicit :   std_logic;  -- SP implicit load enable
signal update_sp :          std_logic;  -- SP combined load enable

---- SFR interface -------------------------------------------------------------

signal sfr_addr_internal :  unsigned(7 downto 0);   -- SFR address
signal sfr_vma_internal :   std_logic;              -- SFR access enable 
signal sfr_we_internal :    std_logic;              -- SFR write enable
signal sfr_wr_internal :    t_byte;                 -- SFR write data bus
signal sfr_rd_internal :    t_byte;                 -- SFR read data bus
signal sfr_rd_internal_reg :t_byte;                 -- Registered SFR read data

---- Conditional jumps ---------------------------------------------------------

signal jump_cond_sel_decode_0 : t_cc;       -- Jump condition code...
signal jump_cond_sel_reg :  t_cc;           -- ...registered to control mux
signal jump_condition :     std_logic;      -- Value of jump condition
signal cjne_condition :     std_logic;      -- Value of CJNE jump condition

---- BRAM used for IRAM and uCode table ----------------------------------------
-- The BRAM is a 512 byte table: 256 bytes for the decoding table and 256 bytes
-- for the 8052 IRAM. 
-- FIXME handle Xilinx and arbitrary size FPGA BRAMs.
constant BRAM_ADDR_LEN : integer := log2(BRAM_SIZE);
subtype t_bram_addr is unsigned(BRAM_ADDR_LEN-1 downto 0);
signal bram_addr_p0 :       t_bram_addr;
signal bram_addr_p1 :       t_bram_addr;
signal bram_data_p0 :       t_byte;
signal bram_data_p1 :       t_byte;
signal bram_we :            std_logic;
signal bram_wr_data_p0 :    t_byte;

-- Part of the BRAM inference template -- see [1]
-- The BRAM is initializzed with the decoding table.
shared variable bram :      t_ucode_bram := 
                ucode_to_bram(build_decoding_table(IMPLEMENT_BCD_INSTRUCTIONS));

-- IRAM/SFR address; lowest 8 bits of actual BRAM address.
signal iram_sfr_addr :      t_byte;
-- IRAM/SFR read data
signal iram_sfr_rd :        t_byte;
-- '1' when using direct addressing mode, '0' otherwise.
signal direct_addressing :  std_logic;
-- '1' when using direct addressing to address range 80h..ffh, '0' otherwise.
signal sfr_addressing :     std_logic;
signal sfr_addressing_reg : std_logic;

-- Kind of addressing the current instruction is using
signal direct_addressing_alu_reg : std_logic;
signal alu_using_direct_addressing : std_logic;
signal alu_using_indirect_addressing : std_logic;

-- XRAM/MOVC interface and DPTR control logic ----------------------------------

signal load_dph :           std_logic;  -- DPTR(h) load enable
signal load_dpl :           std_logic;  -- DPTR(l) load enable
signal inc_dptr :           std_logic;  -- DPTR increment enable

signal acc_ext16 :          t_address;  -- Accumulator zero-extended to 16 bits
signal movc_base :          t_address;  -- Base for MOVC address
signal movc_addr :          t_address;  -- MOVC address
signal dptr_plus_a_reg :    t_address;  -- Registered DPTR+ACC adder


begin

--## 1.- State machine #########################################################

cpu_state_machine_reg:
process(clk)
begin
   if clk'event and clk='1' then
        if reset='1' then
            ps <= reset_0;
        else
            ps <= ns;
        end if;
    end if;
end process cpu_state_machine_reg;


cpu_state_machine_transitions:
process(ps, uc_class_decode_0, uc_alu_class_decode_0, 
        uc_alu_class_reg, jump_condition, alu_fn_reg,
        mul_ready,div_ready,
        irq_active)
begin
    case ps is
    when reset_0 =>
        ns <= fetch_1;
    
    when fetch_0 =>
        ns <= fetch_1;
        
    when fetch_1 =>
        -- Here's where we sample the pending interrupt flags... 
        if irq_active='1' then
            -- ...and trigger interrupt response if necessary.
            ns <= irq_1;
        else
            ns <= decode_0;
        end if;
            
    when decode_0 =>
        if uc_class_decode_0(5 downto 4) = "00" then
            case uc_alu_class_decode_0 is
                when AC_RI_to_A => ns <= alu_rx_to_ab;
                when AC_A_RI_to_A => ns <= alu_rx_to_ab;
                when AC_RI_to_RI => ns <= alu_rx_to_ab;
                when AC_RI_to_D => ns <= alu_rx_to_ab;
                
                when AC_D_to_A => ns <= alu_code_to_ab;
                when AC_D1_to_D => ns <= alu_code_to_ab;
                when AC_D_to_RI => ns <= alu_code_to_ab;
                when AC_D_to_D => ns <= alu_code_to_ab;
                
                when AC_A_RN_to_A => ns <= alu_rx_to_ab;
                when AC_RN_to_RN => ns <= alu_rx_to_ab;
                when AC_RN_to_A => ns <= alu_rx_to_ab;
                when AC_D_to_RN => ns <= alu_code_to_ab;
                when AC_RN_to_D => ns <= alu_rx_to_ab;
                when AC_I_to_D => ns <= alu_code_to_ab; 
                
                when AC_I_D_to_D => ns <= alu_code_to_ab;
                when AC_I_to_RI => ns <= alu_code_to_t_rx_to_ab;
                when AC_I_to_RN => ns <= alu_code_to_t_rx_to_ab;
                when AC_I_to_A => ns <= alu_code_to_t; 
                when AC_A_to_RI => ns <= alu_rx_to_ab; 
                when AC_A_to_D => ns <= alu_code_to_ab; 
                when AC_A_D_to_A => ns <= alu_code_to_ab; 
                when AC_A_D_to_D => ns <= alu_code_to_ab;
                when AC_A_to_RN => ns <= alu_rx_to_ab;
                when AC_A_I_to_A => ns <= alu_code_to_t; 
                when AC_A_to_A => ns <= alu_res_to_a;     

                when AC_DIV => ns <= alu_div_0;
                when AC_MUL => ns <= alu_mul_0;
                when AC_DA => ns <= alu_daa_0;
                when others => ns <= bug_bad_opcode_class;
            end case;
        else
            case uc_class_decode_0 is
            when F_JRB =>
                ns <= jrb_bit_0;
            when F_LJMP =>
                ns <= fetch_addr_1;
            when F_AJMP =>
                ns <= fetch_addr_0_ajmp;
            when F_LCALL =>
                ns <= lcall_0;
            when F_ACALL =>
                ns <= acall_0;
            when F_JR =>
                ns <= load_rel;
            when F_CJNE_A_IMM =>
                ns <= cjne_a_imm_0; 
            when F_CJNE_A_DIR =>
                ns <= cjne_a_dir_0;
            when F_CJNE_RI_IMM =>
                ns <= cjne_ri_imm_0;
            when F_CJNE_RN_IMM =>    
                ns <= cjne_rn_imm_0; 
            when F_DJNZ_DIR =>
                ns <= djnz_dir_0; 
            when F_DJNZ_RN =>
                ns <= djnz_rn_0;
            when F_OPC =>
                ns <= bit_res_to_c;
            when F_BIT =>
                ns <= bit_op_0;
            when F_SPECIAL =>
                ns <= special_0;
            when F_PUSH =>
                ns <= push_0;
            when F_POP =>
                ns <= pop_0;
            when F_MOV_DPTR =>
                ns <= mov_dptr_0;
            when F_MOVX_DPTR_A =>
                ns <= movx_dptr_a_0;
            when F_MOVX_A_DPTR =>
                ns <= movx_a_dptr_0;
            when F_MOVX_A_RI =>
                ns <= movx_a_ri_0;
            when F_MOVX_RI_A =>
                ns <= movx_ri_a_0;
            when F_MOVC_PC =>
                ns <= movc_pc_0;
            when F_MOVC_DPTR =>
                ns <= movc_dptr_0;
            when F_XCH_DIR =>
                ns <= xch_dir_0;
            when F_XCH_RI =>
                ns <= xch_rx_0;
            when F_XCH_RN =>
                ns <= xch_rn_0;
            when F_XCHD =>
                ns <= alu_xchd_0;
            when F_JMP_ADPTR =>
                ns <= jmp_adptr_0;
            when F_RET =>
                ns <= ret_0;
            when F_NOP =>
                ns <= fetch_1;
            when others =>
                ns <= bug_bad_opcode_class;
            end case;
        end if;

    -- Interrupt processing ------------------------------------------
    when irq_1 =>
        ns <= irq_2;
    when irq_2 =>
        ns <= irq_3;
    when irq_3 =>
        ns <= irq_4;
    when irq_4 =>
        ns <= fetch_0; 
        
    -- Call/Ret instructions -----------------------------------------
    when acall_0 =>
        ns <= acall_1;
    when acall_1 =>
        ns <= acall_2;
    when acall_2 =>
        ns <= long_jump;
       
    when lcall_0 =>
        ns <= lcall_1;
    when lcall_1 =>
        ns <= lcall_2;
    when lcall_2 =>
        ns <= lcall_3;
    when lcall_3 =>
        ns <= lcall_4;
    when lcall_4 =>
        ns <= fetch_0;
        
    when ret_0 =>
        ns <= ret_1;
    when ret_1 =>
        ns <= ret_2;
    when ret_2 =>
        ns <= ret_3;
    when ret_3 =>
        ns <= fetch_0;

    -- Special instructions ------------------------------------------
    when special_0 =>
        ns <= fetch_1;
        
    when push_0 =>
        ns <= push_1;
    when push_1 =>
        ns <= push_2;
    when push_2 =>
        ns <= fetch_1;

    when pop_0 =>
        ns <= pop_1;
    when pop_1 =>
        ns <= pop_2;
    when pop_2 =>
        ns <= fetch_1;
        
    when mov_dptr_0 =>
        ns <= mov_dptr_1;
    when mov_dptr_1 =>
        ns <= mov_dptr_2;
    when mov_dptr_2 =>
        ns <= fetch_1;
    
    -- MOVC instructions ---------------------------------------------
    when movc_pc_0 =>
        ns <= movc_1;
    when movc_dptr_0 =>
        ns <= movc_1;
    when movc_1 =>
        ns <= fetch_1;
    
    -- MOVX instructions ---------------------------------------------
    when movx_a_dptr_0 =>
        ns <= fetch_1;
    when movx_dptr_a_0 =>
        ns <= fetch_1;
    
    when movx_a_ri_0 =>
        ns <= movx_a_ri_1;
    when movx_a_ri_1 =>
        ns <= movx_a_ri_2;
    when movx_a_ri_2 =>
        ns <= movx_a_ri_3;
    when movx_a_ri_3 =>
        ns <= fetch_1;
            
    when movx_ri_a_0 =>
        ns <= movx_ri_a_1;
    when movx_ri_a_1 =>
        ns <= movx_ri_a_2;
    when movx_ri_a_2 =>
        ns <= fetch_1;
    
    -- XCH instructions ----------------------------------------------
    when xch_dir_0 =>
        ns <= xch_1;
    when xch_rn_0 =>
        ns <= xch_1;
    when xch_rx_0 =>
        ns <= xch_rx_1;
    when xch_rx_1 =>
        ns <= xch_1;
    when xch_1 =>
        ns <= xch_2;
    when xch_2 =>
        ns <= xch_3;
    when xch_3 =>
        ns <= fetch_1;
    
    -- BIT instructions ----------------------------------------------
    when bit_res_to_c =>    -- SETB C, CPL C and CLR C only
        ns <= fetch_1;
        
    when bit_op_0 =>
        ns <= bit_op_1;
    when bit_op_1 =>
        if uc_alu_class_reg(0)='0' then
            ns <= bit_op_2;
        else
            ns <= bit_res_to_c;
        end if;
    when bit_op_2 =>
        ns <= fetch_1;
        
    
    -- BIT-testing relative jumps ------------------------------------
    when jrb_bit_0 =>
        ns <= jrb_bit_1;
    when jrb_bit_1 =>
        if alu_fn_reg(1 downto 0)="11" then
            -- This is JBC; state jrb_bit_2 is where the bit is clear.
            ns <= jrb_bit_2;
        else
            ns <= jrb_bit_3;
        end if;
    when jrb_bit_2 =>
        ns <= jrb_bit_3;
    when jrb_bit_3 =>
        if jump_condition='1' then
            ns <= jrb_bit_4;
        else
            ns <= fetch_0;
        end if;
        
    when jrb_bit_4 =>
        ns <= fetch_0;        
        
    -- MUL/DIV instructions ------------------------------------------
    when alu_div_0 =>
        if div_ready='1' then
            ns <= fetch_1;
        else 
            ns <= ps;
        end if;

    when alu_mul_0 =>
        if mul_ready='1' then
            ns <= fetch_1;
        else 
            ns <= ps;
        end if;
        
    -- BCD instructions ----------------------------------------------
    when alu_daa_0 =>
        ns <= alu_daa_1;
    
    when alu_daa_1 =>
        ns <= fetch_1;
        
    when alu_xchd_0 =>
        ns <= alu_xchd_1;

    when alu_xchd_1 =>
        ns <= alu_xchd_2;        
        
    when alu_xchd_2 =>
        ns <= alu_xchd_3;

    when alu_xchd_3 =>
        ns <= alu_xchd_4;

    when alu_xchd_4 =>
        ns <= alu_xchd_5;
        
    when alu_xchd_5 =>
        ns <= fetch_1;
        
    -- ALU instructions (other than MUL/DIV) -------------------------
    when alu_rx_to_ab =>
        case uc_alu_class_reg is
            when AC_RI_to_A | AC_A_RI_to_A | AC_RI_to_D | AC_RI_to_RI => 
                ns <= alu_ram_to_ar;
            when AC_RN_to_D => 
                ns <= alu_ram_to_t_code_to_ab;
            when AC_A_to_RI => 
                ns <= alu_ram_to_ar_2;
            when others => 
                ns <= alu_ram_to_t;
        end case;
    
    when alu_ram_to_ar_2 =>
        ns <= alu_res_to_ram_ar_to_ab;
    
    when alu_ram_to_ar =>
        ns <= alu_ar_to_ab;
    
    when alu_ar_to_ab =>
        if uc_alu_class_reg = AC_RI_to_D then
            ns <= alu_ram_to_t_code_to_ab;
        else
            ns <= alu_ram_to_t;
        end if;

    when alu_ram_to_t =>
        if uc_alu_class_reg = AC_D_to_A or 
           uc_alu_class_reg = AC_A_D_to_A or  
           uc_alu_class_reg = AC_RN_to_A or 
           uc_alu_class_reg = AC_A_RN_to_A or 
           uc_alu_class_reg = AC_RI_to_A or
           uc_alu_class_reg = AC_A_RI_to_A 
           then
            ns <= alu_res_to_a;
        elsif uc_alu_class_reg = AC_D1_to_D then
            ns <= alu_res_to_ram_code_to_ab;
        else
            ns <= alu_res_to_ram;
        end if;
    
    when alu_res_to_ram_code_to_ab =>
        ns <= fetch_1;
    
    when alu_res_to_a =>
        ns <= fetch_1;
    
    when alu_ram_to_t_code_to_ab =>
        ns <= alu_res_to_ram;
    
    when alu_res_to_ram =>
        ns <= fetch_1;
    
    when alu_code_to_ab =>
        case uc_alu_class_reg is
            when AC_I_to_D => 
                ns <= alu_code_to_t;
            when AC_I_D_to_D =>
                ns <= alu_ram_to_v_code_to_t;
            when AC_D_to_RI | AC_D_to_RN => 
                ns <= alu_ram_to_t_rx_to_ab;
            when AC_A_to_D => 
                ns <= alu_res_to_ram;
            when others => 
                ns <= alu_ram_to_t;
        end case;        
    
    when alu_ram_to_t_rx_to_ab => 
        if uc_alu_class_reg = AC_D_to_RI then
            ns <= alu_ram_to_ar_2;
        else
            ns <= alu_res_to_ram;
        end if;
    
    when alu_res_to_ram_ar_to_ab =>
        ns <= fetch_1;
    
    when alu_code_to_t =>
        if uc_alu_class_reg = AC_I_to_D then
            ns <= alu_res_to_ram;
        else
            ns <= alu_res_to_a;
        end if;
    
    when alu_ram_to_v_code_to_t =>
        ns <= alu_res_to_ram;
        
    when alu_code_to_t_rx_to_ab =>
        if uc_alu_class_reg = AC_I_to_RI then 
            ns <= alu_ram_to_ar_2;
        else 
            ns <= alu_res_to_ram;
        end if;
    
    -- DJNZ Rn -------------------------------------------------------
    when djnz_rn_0 =>
        ns <= djnz_dir_1;
    
    -- DJNZ dir ------------------------------------------------------
    when djnz_dir_0 =>
        ns <= djnz_dir_1;
    when djnz_dir_1 =>
        ns <= djnz_dir_2;
    when djnz_dir_2 =>
        ns <= djnz_dir_3;
    when djnz_dir_3 =>
        if jump_condition='1' then
            ns <= djnz_dir_4;
        else
            ns <= fetch_0;
        end if;        
    when djnz_dir_4 =>
        ns <= fetch_0;

    -- CJNE A, dir --------------------------------------------------
    when cjne_a_dir_0 =>
        ns <= cjne_a_dir_1;
    when cjne_a_dir_1 =>
        ns <= cjne_a_dir_2;
    when cjne_a_dir_2 =>
        if jump_condition='1' then
            ns <= cjne_a_dir_3;
        else
            ns <= fetch_0;
        end if;
    when cjne_a_dir_3 =>
        ns <= fetch_0;
        
    -- CJNE Rn, #imm ------------------------------------------------
    when cjne_rn_imm_0 =>
        ns <= cjne_rn_imm_1;
    when cjne_rn_imm_1 =>
        ns <= cjne_rn_imm_2;
    when cjne_rn_imm_2 =>
        if jump_condition='1' then
            ns <= cjne_rn_imm_3;
        else
            ns <= fetch_0;
        end if;
    when cjne_rn_imm_3 =>
        ns <= fetch_0;

    -- CJNE @Ri, #imm ------------------------------------------------
    when cjne_ri_imm_0 =>
        ns <= cjne_ri_imm_1;
    when cjne_ri_imm_1 =>
        ns <= cjne_ri_imm_2;
    when cjne_ri_imm_2 =>
        ns <= cjne_ri_imm_3;
    when cjne_ri_imm_3 =>
        ns <= cjne_ri_imm_4;
    when cjne_ri_imm_4 =>
        if jump_condition='1' then
            ns <= cjne_ri_imm_5;
        else
            ns <= fetch_0;
        end if;
    when cjne_ri_imm_5 =>
        ns <= fetch_0;

        
    -- CJNE A, #imm -------------------------------------------------
    when cjne_a_imm_0 =>
        ns <= cjne_a_imm_1;
    when cjne_a_imm_1 =>
        if jump_condition='1' then
            ns <= cjne_a_imm_2;
        else
            ns <= fetch_0;
        end if;
    when cjne_a_imm_2 =>
        ns <= fetch_0;
    
    -- Relative and long jumps --------------------------------------
    when load_rel =>
        if jump_condition='1' then
            ns <= rel_jump;
        else
            ns <= fetch_1;
        end if;
    when rel_jump =>
        ns <= fetch_0;
           
    when fetch_addr_1 =>
        ns <= fetch_addr_0;
    when fetch_addr_0 =>
        ns <= long_jump;
    when fetch_addr_0_ajmp =>
        ns <= long_jump;
    when long_jump =>
        ns <= fetch_0;
    
    when jmp_adptr_0 =>
        ns <= fetch_0;


    -- Derailed state machine should end here -----------------------
    -- NOTE: This applies to undecoded or unimplemented instructions,
    -- not to a state machine derailed by EM event, etc. 
    
    when others =>
        ns <= bug_bad_opcode_class;
    end case;
end process cpu_state_machine_transitions;


--## 2.- Interrupt handling ####################################################


-- IP SFR is implemented as a regular SFR as per the MC51 architecture.
load_ip <= '1' when sfr_addr_internal=SFR_ADDR_IP and sfr_we_internal='1'
           else '0'; 

IP_register:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            IP_reg <= (others => '0');
        else
            if load_ip='1' then
                IP_reg <= alu_result;
            end if;
        end if;
    end if;
end process IP_register;


-- IE SFR is implemented as a regular SFR as per the MC51 architecture.
load_ie <= '1' when sfr_addr_internal=SFR_ADDR_IE and sfr_we_internal='1'
           else '0'; 

IE_register:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            IE_reg <= (others => '0');
        else
            if load_ie='1' then
                IE_reg <= alu_result;
            end if;
        end if;
    end if;
end process IE_register;

-- RETI restores the IRQ level to 7 (idle value). No interrupt will be serviced
-- if its level is below this. Remember 0 is top, 4 is bottom and 7 is idle. 
irq_restore_level <= '1' when ps=ret_0 and alu_fn_reg(0)='1' else '0';

-- Mask the irq inputs with IE register bits...
irq_masked_inputs <= irq_source and std_logic_vector(IE_reg(4 downto 0));
-- ...separate the highpriority interrupt inputs by masking with IP register...
irq_masked_inputs_hp <= irq_masked_inputs and std_logic_vector(IP_reg(4 downto 0));
-- ...and encode the highest priority active input
irq_level_inputs <= 
    "000" when irq_masked_inputs_hp(0)='1' else
    "001" when irq_masked_inputs_hp(1)='1' else
    "010" when irq_masked_inputs_hp(2)='1' else
    "011" when irq_masked_inputs_hp(3)='1' else
    "100" when irq_masked_inputs_hp(4)='1' else
    "000" when irq_masked_inputs(0)='1' else
    "001" when irq_masked_inputs(1)='1' else
    "010" when irq_masked_inputs(2)='1' else
    "011" when irq_masked_inputs(3)='1' else
    "100" when irq_masked_inputs(4)='1' else
    "111";
    
irq_active_hip <= '1' when irq_masked_inputs_hp/="00000" else '0';
    
-- An active, enabled interrupt will be serviced only if...
irq_active_allowed <= '1' when
                    -- ...other high-priority interrupt is NOT being serviced...
                    irq_serving_hip='0' and
                    -- ...and either the incoming interrupt is high-priority...
                    (irq_active_hip='1' or
                    -- -- ...or no interrupt is being serviced at all;
                    (irq_active_hip='0' and irq_serving_lop='0'))
                    -- otherwise the interrupt is not allowed to proceed.
                    else '0';

-- We have a pending irq if interrupts are enabled...    
irq_active <= '1' when IE_reg(7)='1' and 
                    -- ...and some interrupt source is active...
                    irq_level_inputs/="111" and
                    -- ...and the active interrupt is allowed by the priority 
                    -- rules...
                    irq_active_allowed='1'
                    -- ...otherwise the interrupt is ignored.
                    else '0';    

irq_registered_priority_encoder:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            -- After reset, no interrupt of either priority level is being
            -- serviced.
            irq_serving_hip <= '0';
            irq_serving_lop <= '0';
        elsif irq_restore_level='1' then
            -- RETI executed: if high-priority level was active...
            if irq_serving_hip='1' then
                -- ...disable it, reverting to the previous priority level...
                irq_serving_hip <= '0';
            else
                -- otherwise disable the low priority level.
                irq_serving_lop <= '0';
            end if;
        else            
            -- Evaluate and register the interrupt priority in the same state 
            -- the irq is to be acknowledged.
            if ps=fetch_1 and irq_active='1' then
                irq_serving_hip <= irq_active_hip;
                irq_serving_lop <= irq_serving_lop or (not irq_active_hip);
                -- This irq vector is going to be used in state irq_2.
                irq_vector <= irq_level_inputs & "011";
            end if;
        end if;
    end if;
end process irq_registered_priority_encoder;


    
--## 3.- Combined register bank & decoding table ###############################

-- No support yet for XRAM on this RAM block
assert not USE_BRAM_FOR_XRAM
report "This version of the core does not support using the IRAM/uCode "&
       "RAM block wasted space for XRAM"
severity failure;


-- This is the row of the opcode table that will be replicated for the 2nd half
-- of the table. We always replicate row 7 (opcode X7h) except for 'DNJZ Rn'
-- (opcodes d8h..dfh) where we replicate row 5 -- opcode d7h is not a DJNZ and
-- breaks the pattern (see @note1).
ucode_pattern <= "101" when code_rd(7 downto 4)="1101" else "111";

with code_rd(3) select ucode_index <=
    ucode_pattern & unsigned(code_rd(7 downto 4))   when '1',
    unsigned(code_rd(2 downto 0)) & 
    unsigned(code_rd(7 downto 4))                   when others;

-- IRAM/SFR address source mux; controlled by current state
with ps select iram_sfr_addr <=
    rx_addr         when alu_rx_to_ab,
    rx_addr         when alu_code_to_t_rx_to_ab,
    rx_addr         when alu_ram_to_t_rx_to_ab,
    rx_addr         when cjne_rn_imm_0,
    rx_addr         when cjne_ri_imm_0,
    rx_addr         when alu_xchd_0,
    rx_addr         when movx_a_ri_0,
    rx_addr         when movx_ri_a_0,
    rx_addr         when xch_rx_0,
    rx_addr         when xch_rn_0,
    addr0_reg       when alu_res_to_ram_ar_to_ab,
    bit_addr        when jrb_bit_0,
    bit_addr        when bit_op_0,
    SP_reg          when push_2, -- Write dir data to [sp]
    SP_reg          when pop_0 | ret_0 | ret_1 | ret_2,
    SP_reg          when acall_1 | acall_2 | lcall_2 | lcall_3,
    SP_reg          when irq_2 | irq_3,
    addr0_reg       when djnz_dir_1 | djnz_dir_2,
    addr0_reg       when push_1, -- Read dir data for PUSH
    code_byte       when cjne_a_imm_1,
    code_byte       when cjne_a_dir_0,
    code_byte       when cjne_a_dir_2,
    code_byte       when cjne_rn_imm_1,
    code_byte       when cjne_rn_imm_2,
    code_byte       when cjne_ri_imm_4,
    code_byte       when djnz_dir_0, -- DIR addr 
    code_byte       when djnz_dir_3, -- REL offset
    rx_addr         when djnz_rn_0,
    addr0_reg       when jrb_bit_2,
    code_byte       when jrb_bit_3,
    addr0_reg       when bit_op_2,       
    code_byte       when fetch_addr_0,
    code_byte       when fetch_addr_0_ajmp,
    code_byte       when alu_code_to_ab, -- DIRECT addressing
    code_byte       when push_0, -- read dir address
    code_byte       when pop_1,
    code_byte       when acall_0 | lcall_0 | lcall_1,
    code_byte       when alu_res_to_ram_code_to_ab,
    code_byte       when alu_ram_to_t_code_to_ab,
    code_byte       when load_rel,
    SFR_ADDR_DPH    when mov_dptr_1,
    SFR_ADDR_DPL    when mov_dptr_2,
    code_byte       when xch_dir_0,
    addr0_reg       when others;

-- Assert this when an ALU instruction is about to use direct addressing. 
with ps select alu_using_direct_addressing <=
    '1' when alu_code_to_ab,
    '1' when xch_dir_0,
    '1' when alu_ram_to_t_code_to_ab,
    '0' when others;
    
-- Assert this when an ALU instruction is using direct addressing.    
with ps select alu_using_indirect_addressing <=
    '1' when alu_ar_to_ab,
    '1' when alu_rx_to_ab,
    '1' when xch_rx_0,
    '1' when movx_a_ri_0,
    '1' when movx_ri_a_0,
    '1' when alu_ram_to_t_rx_to_ab,
    '1' when alu_res_to_ram_ar_to_ab,
    '1' when alu_code_to_t_rx_to_ab,
    '0' when others;

-- This register remembers what kind of addressing the current ALU instruction 
-- is using.
-- This is necessary because the ALU instruction states are shared by many 
-- different instructions with different addressing modes.
alu_addressing_mode_flipflop:
process(clk)
begin
    if clk'event and clk='1' then
        if reset = '1' then
            direct_addressing_alu_reg <= '0';
        else
            if alu_using_direct_addressing = '1' then
                direct_addressing_alu_reg <= '1';
            elsif alu_using_indirect_addressing = '1' then 
                direct_addressing_alu_reg <= '0';
            end if;
        end if;
    end if;
end process alu_addressing_mode_flipflop;    

-- This signal controls the T reg input mux. it should be valid in the cycle 
-- the read/write is performed AND in the cycle after a read.
-- FIXME these should be asserted in READ or WRITE states; many are not! review!
with ps select direct_addressing <=
    -- For most instructions all we need to know is the current state...
    '0'                         when alu_rx_to_ab,
    '0'                         when cjne_a_imm_0,
    '0'                         when cjne_a_imm_1,
    '0'                         when cjne_ri_imm_4,
    '0'                         when cjne_ri_imm_3,
    '0'                         when fetch_addr_0,
    '0'                         when load_rel,
    '0'                         when cjne_rn_imm_1,
    '0'                         when cjne_rn_imm_2,
    '1'                         when jrb_bit_0 | jrb_bit_1 | jrb_bit_2,
    '1'                         when bit_op_0 | bit_op_1 | bit_op_2,
    -- FIXME these below have been verified and corrected
    '1'                         when djnz_dir_0,
    '1'                         when djnz_dir_1,
    '1'                         when djnz_dir_2,
    '1'                         when push_0,
    '1'                         when pop_1 | pop_2,
    '0'                         when movx_a_ri_0,
    '0'                         when movx_ri_a_0,
    '1'                         when xch_dir_0,
    '1'                         when cjne_a_dir_0,
    '1'                         when cjne_a_dir_1,
    '0'                         when alu_xchd_2 | alu_xchd_3,
    -- ... and for ALU instructions we use info recorded while decoding.
    '1'                         when alu_code_to_ab,
    direct_addressing_alu_reg   when xch_1,
    direct_addressing_alu_reg   when xch_2,
    direct_addressing_alu_reg   when alu_ar_to_ab,
    direct_addressing_alu_reg   when alu_ram_to_t,
    direct_addressing_alu_reg   when alu_ram_to_t_code_to_ab,
    direct_addressing_alu_reg   when alu_ram_to_t_rx_to_ab,
    direct_addressing_alu_reg   when alu_ram_to_v_code_to_t,
    direct_addressing_alu_reg   when alu_res_to_ram,
    '1'                         when alu_res_to_ram_code_to_ab, -- D1 -> D only
    '0'                         when alu_res_to_ram_ar_to_ab,
    '0' when others;

-- SFRs are only ever accessed by direct addresing to area 80h..ffh
sfr_addressing <= direct_addressing and iram_sfr_addr(7);
    
-- In 'fetch' states (including the last state of all instructions) the BRAM 
-- is used as a decode table indexed by the opcode -- both ports!
-- The decode table is in the lowest 256 bytes and the actual IRAM data is 
-- in the highest 256 bytes, thus the address MSB.
with do_fetch select bram_addr_p0 <= 
    -- 'fetch' states
    '0' & ucode_index & '0'     when '1',
    '1' & iram_sfr_addr         when others;

with do_fetch select bram_addr_p1 <=
    -- 'fetch' states
    '0' & ucode_index & '1'     when '1',
    '1' & iram_sfr_addr         when others;

-- FIXME SFR/RAM selection bit: make sure it checks
with ps select bram_we <= 
    not sfr_addressing          when alu_res_to_ram,
    not sfr_addressing          when alu_res_to_ram_code_to_ab,
    '1'                         when alu_res_to_ram_ar_to_ab,
    not sfr_addressing          when djnz_dir_2,
    not sfr_addressing          when bit_op_2,
    not sfr_addressing          when jrb_bit_2,
    not sfr_addressing          when push_2, -- FIXME verify
    not sfr_addressing          when pop_2,  -- FIXME verify
    not sfr_addressing          when xch_2,
    '1'                         when alu_xchd_4,
    '1'                         when acall_1 | acall_2 | lcall_2 | lcall_3,
    '1'                         when irq_2 | irq_3,
    '0'                         when others;

-- The datapath result is what's written back to the IRAM/SFR, except when 
-- pushing the PC in a xCALL instruction.
with ps select bram_wr_data_p0 <= 
    PC_reg(7 downto 0)          when acall_1 | lcall_2 | irq_2,
    PC_reg(15 downto 8)         when acall_2 | lcall_3 | irq_3,    
    alu_result                  when others;


-- IMPORTANT: the 2-port BRAM is inferred using a template which is valid for
-- both Altera and Xilinx. Otherwise, the synth tools would infer TWO BRAMs 
-- instead of one.
-- This template is FRAGILE: for example, changing the order of assignments in 
-- process *_port0 will break the synthesis (i.e. 2 BRAMs again).
-- See a more detailed explaination in [3].

-- BRAM port 0 is read/write (i.e. same address for read and write)
register_bank_bram_port0:
process(clk)
begin
   if clk'event and clk='1' then
        if bram_we='1' then
            bram(to_integer(bram_addr_p0)) := bram_wr_data_p0;
        end if;
        bram_data_p0 <= bram(to_integer(bram_addr_p0));
   end if;
end process register_bank_bram_port0;

-- Port 1 is read only
register_bank_bram_port1:
process(clk)
begin
   if clk'event and clk='1' then
        bram_data_p1 <= bram(to_integer(bram_addr_p1));
   end if;
end process register_bank_bram_port1;

-- End of BRAM inference template 

--## 4.- Instruction decode logic ##############################################

-- Assert do_fetch on the states when the *opcode* is present in code_rd.
-- (not asserted for other instruction bytes, only the opcode).
with ps select do_fetch <=
    '1' when fetch_1,
    '0' when others;

-- The main decode word is the synchrous BRAM output. Which means it is only 
-- valid for 1 clock cycle (state decode_0). Most state machine decisions are 
-- taken in that state. All information which is needed at a later state, like
-- ALU control signals, is registered.
-- Note that the BRAM is used for the 1st half of the decode table (@note1)...
ucode_1st_half <= bram_data_p0 & bram_data_p1;

-- ...the 2nd hald of the table is done combinationally and then registered.
ucode_2nd_half(8 downto 0) <= ucode_1st_half(8 downto 0);
-- We take advantage of the opcode table layout: the 2nd half columns are always
-- identical to the 1st half column, 7th or 5th row opcode (see ucode_pattern), 
-- except for the addressing mode:
with code_rd(7 downto 4) select ucode_2nd_half(15 downto 9) <=
    "00" & AC_RN_to_RN          when "0000",
    "00" & AC_RN_to_RN          when "0001",
    "00" & AC_A_RN_to_A         when "0010",
    "00" & AC_A_RN_to_A         when "0011",
                                
    "00" & AC_A_RN_to_A         when "0100",
    "00" & AC_A_RN_to_A         when "0101",
    "00" & AC_A_RN_to_A         when "0110",
    "00" & AC_I_to_RN           when "0111",
                                
    "00" & AC_RN_to_D           when "1000",
    "00" & AC_A_RN_to_A         when "1001",
    "00" & AC_D_to_RN           when "1010",
    F_CJNE_RN_IMM & CC_CJNE(3 downto 3)     when "1011",
                                
    F_XCH_RN & "0"              when "1100",
    F_DJNZ_RN & CC_NZ(3 downto 3)           when "1101",
    "00" & AC_RN_to_A           when "1110",
    "00" & AC_A_to_RN           when others;


-- Register the combinational half of the uCode table so its timing is the same
-- as the BRAM (so that both halves have the same timing).    
process(clk)
begin
    if clk'event and clk='1' then
        -- Register the information as soon as it is available: get opcode bits
        -- when the opcode is in code_rd...
        if do_fetch='1' then
            ucode_is_2nd_half <= code_rd(3);
            rn_index <= unsigned(code_rd(2 downto 0));
        end if;
        -- ...and get the ucode word when it is valid: the lowest half of the
        -- ucode word comes from the ucode BRAM and is valid in decode_0.
        if ps = decode_0 then
            ucode_2nd_half_reg <= ucode_2nd_half;
        end if;
    end if;
end process;
    
-- uCode may come from the BRAM (1st half of the table) or from  combinational 
-- logic (2nd half). This is the multiplexor.
ucode <= ucode_1st_half when ucode_is_2nd_half='0' else ucode_2nd_half_reg;

-- Extract uCode fields for convenience.

-- For ALU instructions, we have the flag mask in the uCode word...
uc_alu_flag_mask <= ucode_1st_half(8 downto 7);
-- ...and all other instructions only update the C flag, if any.
with uc_class_decode_0(5 downto 4) select flag_mask_decode_0 <= 
    uc_alu_flag_mask    when "00",
    FM_C                when others; -- Will only be used in a few states.

-- The mux for signal ucode operates after state decode_0, because its input 
-- ucode_2nd_half_reg ir registered in that state. These following signals 
-- depend on the ucode but need to be valid IN state decode_0 so they are muxed 
-- separately directly on the opcode bit. 
-- Valid only in state decode_0, all of these are registered too for later use.

with ucode_is_2nd_half select jump_cond_sel_decode_0 <=
    ucode_1st_half(9 downto 6)      when '0',
    ucode_2nd_half(9 downto 6)      when others;
    
with ucode_is_2nd_half select uc_alu_fn_decode_0 <= 
    ucode_1st_half(5 downto 0)      when '0',
    ucode_2nd_half(5 downto 0)      when others;

with ucode_is_2nd_half select uc_class_decode_0 <=
    ucode_1st_half(15 downto 10)    when '0',
    ucode_2nd_half(15 downto 10)    when others;

with ucode_is_2nd_half select uc_alu_class_decode_0 <= -- ALU opc. addrng. mode 
    ucode_1st_half(13 downto 9)     when '0',
    ucode_2nd_half(13 downto 9)     when others;


-- Register ALU & conditional jump control signals for use in states 
-- after decode_0.
alu_control_registers:
process(clk)
begin
    if clk'event and clk='1' then
        if ps=decode_0 then
            uc_alu_class_reg <= uc_alu_class_decode_0;
            alu_class_op_sel_reg <= alu_class_op_sel;
            use_ri_reg <= use_ri;
            flag_mask_reg <= flag_mask_decode_0;
            alu_fn_reg <= uc_alu_fn_decode_0;
            dpath_mux0_reg <= uc_alu_fn_decode_0(1) and uc_alu_fn_decode_0(0);
            jump_cond_sel_reg <= jump_cond_sel_decode_0;
            instr_jump_is_ljmp <= ucode(10);
        end if;
    end if;
end process alu_control_registers;

--## 5.- PC and code address generation ########################################

rel_jump_delta(15 downto 8) <= (others => addr0_reg(7));
rel_jump_delta(7 downto 0) <= addr0_reg; 
rel_jump_target <= PC_reg + rel_jump_delta;

-- A jump is LONG when running LJMP/LCALL OR acknowledging an interrupt.
jump_is_ljmp <= '1' when ps=irq_4 else instr_jump_is_ljmp;

-- Mux for two kinds of jump target, AJMP/LJMP (jumps and calls)
with jump_is_ljmp select jump_target <= 
    PC_reg(15 downto 11) & block_reg & addr0_reg    when '0',    -- AJMP
    addr1_reg & addr0_reg                           when others; -- LJMP

-- Decide whether or not to increment the PC by looking at the NEXT state, not
-- the present one. See @note5.
with ns select increment_pc <=
    '1' when decode_0,  -- See @note6.
    '1' when alu_ram_to_t_code_to_ab,
    '1' when alu_code_to_ab,
    '1' when alu_res_to_ram_code_to_ab,
    '1' when alu_ram_to_v_code_to_t,
    '1' when alu_code_to_t_rx_to_ab,
    '1' when alu_code_to_t,
    '1' when jrb_bit_0,
    '1' when jrb_bit_3,
    '1' when bit_op_0,
    '1' when cjne_a_imm_0,
    '1' when cjne_a_imm_1,
    '1' when cjne_a_dir_0,
    '1' when cjne_a_dir_2,
    '1' when cjne_ri_imm_3,
    '1' when cjne_ri_imm_4,
    '1' when cjne_rn_imm_1,
    '1' when cjne_rn_imm_2,
    '1' when fetch_addr_0,
    '1' when fetch_addr_1,
    '1' when fetch_addr_0_ajmp,
    '1' when acall_0 | lcall_0 | lcall_1,
    '1' when load_rel,
    '1' when djnz_dir_0,
    '1' when djnz_dir_3,
    '1' when push_0,
    '1' when pop_1,
    '1' when mov_dptr_0,
    '1' when mov_dptr_1,
    '1' when xch_dir_0,
    '0' when others;
    
with increment_pc select pc_incremented <=
    PC_reg + 1  when '1',
    PC_reg      when others;
    
    
with ps select next_pc <=
    X"0000"             when reset_0,
    jump_target         when long_jump | lcall_4 | ret_3 | irq_4,
    dptr_plus_a_reg     when jmp_adptr_0,
    rel_jump_target     when rel_jump,
    rel_jump_target     when cjne_a_imm_2,
    rel_jump_target     when cjne_a_dir_3,
    rel_jump_target     when cjne_ri_imm_5,
    rel_jump_target     when cjne_rn_imm_3,
    rel_jump_target     when djnz_dir_4,
    rel_jump_target     when jrb_bit_4,
    pc_incremented      when others;


program_counter:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            PC_reg <= (others => '0');
        else
            PC_reg <= next_pc;
        end if;
    end if;
end process program_counter;

with ps select code_addr <= 
    std_logic_vector(movc_addr)     when movc_pc_0 | movc_dptr_0,
    std_logic_vector(PC_reg)        when others;

    
---- MOVC logic ----------------------------------------------------------------
acc_ext16 <= (X"00") & A_reg;

with ps select movc_base <=
    PC_reg          when movc_pc_0,
    DPTR_reg        when others;
       
movc_addr <= movc_base + acc_ext16;    

-- This register will not always hold DPTR+A, at times it will hold PC+A. In the
-- state in which it will be used, it will be DPTR+A.
registered_dptr_plus_a:    
process(clk)
begin
    if clk'event and clk='1' then
        dptr_plus_a_reg <= movc_addr;
    end if;
end process registered_dptr_plus_a;
    

--## 6.- Conditional jump logic ################################################

cjne_condition <= not alu_result_is_zero; -- FIXME redundant, remove

with jump_cond_sel_reg select jump_condition <= 
    '1'                         when CC_ALWAYS,
    not alu_result_is_zero      when CC_NZ,
    alu_result_is_zero          when CC_Z,
    not acc_is_zero             when CC_ACCNZ,
    acc_is_zero                 when CC_ACCZ,    
    cjne_condition              when CC_CJNE,
    PSW(7)                      when CC_C,
    not PSW(7)                  when CC_NC,
    bit_input                   when CC_BIT,
    not bit_input               when CC_NOBIT,
    '0'                         when others;


--## 7.- Address registers #####################################################

---- Address 0 and 1 registers -------------------------------------------------

-- addr0_reg is the most frequent source of IRAM/SFR addresses and is used as
-- an aux reg in jumps and rets.

-- Decide when to load the address register...
with ps select load_addr0 <=
    '1' when fetch_addr_0,
    '1' when fetch_addr_0_ajmp,
    '1' when irq_2,
    '1' when acall_0 | lcall_1,
    '1' when load_rel,
    '1' when cjne_a_imm_1,
    '1' when cjne_a_dir_0,
    '1' when cjne_a_dir_2,
    '1' when cjne_ri_imm_1,
    '1' when cjne_ri_imm_4,
    '1' when cjne_rn_imm_2,
    '1' when alu_xchd_1,
    '1' when djnz_dir_0,
    '1' when djnz_dir_3,
    '1' when djnz_rn_0,
    '1' when jrb_bit_0,
    '1' when jrb_bit_3,
    '1' when bit_op_0,
    '1' when pop_1,
    '1' when ret_2,
    '1' when alu_rx_to_ab,
    '1' when movx_a_ri_1,
    '1' when movx_ri_a_1,
    '1' when xch_dir_0,
    '1' when xch_rx_0,
    '1' when xch_rn_0,
    '1' when xch_rx_1,
    '1' when alu_ram_to_ar,
    '1' when alu_ram_to_t_code_to_ab,
    '1' when alu_code_to_ab,
    '1' when alu_res_to_ram_code_to_ab,
    '1' when alu_ram_to_t_rx_to_ab,
    --'1' when alu_res_to_ram_ram_to_ab,
    '1' when alu_ram_to_ar_2,
    '1' when alu_code_to_t_rx_to_ab,
    '0' when others;

-- ...and decide what to load into it.
with ps select addr0_reg_input <=     
    iram_sfr_rd         when alu_ram_to_ar,
    iram_sfr_rd         when alu_ram_to_ar_2,
    iram_sfr_rd         when cjne_ri_imm_1,
    iram_sfr_rd         when alu_xchd_1,
    iram_sfr_rd         when movx_a_ri_1,
    iram_sfr_rd         when movx_ri_a_1,
    iram_sfr_rd         when xch_rx_0,
    iram_sfr_rd         when xch_rx_1,
    iram_sfr_rd         when ret_2,
    "00" & irq_vector   when irq_2,
    iram_sfr_addr       when others;

-- Auxiliary address registers 0 and 1 plus flag bit_index_reg
address_registers:
process(clk)
begin
    if clk'event and clk='1' then
        if load_addr0='1' then
            -- Used to address IRAM/SCR and XRAM
            addr0_reg <= addr0_reg_input;
            -- The bit index is registered at the same time for use by bit ops.
            -- Signal bit_index is valid at the same time as addr0_reg_input.
            bit_index_reg <= bit_index;
        end if;
        if ps = lcall_0 or ps = fetch_addr_1 then
            addr1_reg <= unsigned(code_rd);
        elsif ps = irq_2 then
            addr1_reg <= (others => '0');
        elsif ps = ret_1 then
            addr1_reg <= iram_sfr_rd;
        end if;
    end if;
end process address_registers;    
    
---- Opcode register(s) and signals directly derived from the opcode -----------
    
-- These register holds the instruction opcode byte.
absolute_jump_block_register:
process(clk)
begin
    if clk'event and clk='1' then
        if ps=decode_0 then
            block_reg <= unsigned(code_rd(7 downto 5));
        end if;
    end if;
end process absolute_jump_block_register;
    
-- Unregistered dir address; straight from code memory.
code_byte <= unsigned(code_rd);

-- Index of bit within byte. Will be registered along with bit_addr.
bit_index <= unsigned(code_rd(2 downto 0));

-- Address of the byte containing the operand bit, if any.
with code_rd(7) select bit_addr <=
    "0010" & unsigned(code_rd(6 downto 3))        when '0',
    "1" & unsigned(code_rd(6 downto 3)) & "000"   when others;


---- Rn and @Ri addresses and multiplexor --------------------------------------
ri_addr <= "000" & PSW_reg(4 downto 3) & "00" & rn_index(0);
rn_addr <= "000" & PSW_reg(4 downto 3) & rn_index;


-- This logic only gets evaluated in state decode_0; and it needs to be valid 
-- only for Rn and @Ri instructions, otherwise it is not evaluated.
-- Does the ALU instruction, if any, use @Ri?
with uc_alu_class_decode_0 select alu_use_ri_by_class <=
    '1' when AC_A_RI_to_A,
    '1' when AC_RI_to_A,
    '1' when AC_RI_to_RI,
    '1' when AC_RI_to_D,
    '1' when AC_D_to_RI,
    '1' when AC_I_to_RI,
    '1' when AC_A_to_RI,
    '0' when others;

-- The instruction uses @Ri unless it uses Rn.
-- This signal gets registered as use_ri_reg in state decode_0. 
alu_use_ri <= '0' when code_rd(3)='1' else alu_use_ri_by_class;    

non_alu_use_ri <= '1' when ucode(11 downto 10)="10" else '0';

use_ri <= alu_use_ri when ucode(15 downto 14)="00" else non_alu_use_ri;    
    
-- This is the actual Rn/Ri multiplexor.     
rx_addr <= ri_addr when use_ri_reg='1' else rn_addr;


--## 8.- SFR interface #########################################################

-- Assert sfr_vma when a SFR read or write cycle is going on (address valid).
-- FIXME some of these are not read cycles but the cycle after!
with ps select sfr_vma_internal <=
    sfr_addressing      when alu_ar_to_ab,
    sfr_addressing      when alu_ram_to_t,
    sfr_addressing      when alu_ram_to_t_code_to_ab,
    sfr_addressing      when alu_ram_to_v_code_to_t,
    sfr_addressing      when alu_res_to_ram,
    sfr_addressing      when alu_res_to_ram_code_to_ab,
    sfr_addressing      when alu_res_to_ram_ar_to_ab,
    sfr_addressing      when djnz_dir_1,
    sfr_addressing      when djnz_dir_2,
    sfr_addressing      when cjne_ri_imm_3,
    sfr_addressing      when cjne_ri_imm_2,
    -- FIXME these are corrected states, the above may be bad
    sfr_addressing      when cjne_a_dir_0,
    sfr_addressing      when jrb_bit_0,
    sfr_addressing      when bit_op_0,
    sfr_addressing      when bit_op_2,
    sfr_addressing      when xch_1,
    sfr_addressing      when xch_2,
    sfr_addressing      when alu_xchd_2,
    -- FIXME some other states missing
    '0'                 when others;

-- Assert sfr_we_internal when a SFR write cycle is done.
-- FIXME there should be a direct_we, not separate decoding for iram/sfr
with ps select sfr_we_internal <= 
    sfr_addressing      when alu_res_to_ram,
    sfr_addressing      when alu_res_to_ram_code_to_ab,
    sfr_addressing      when alu_res_to_ram_ar_to_ab,
    sfr_addressing      when djnz_dir_2,
    sfr_addressing      when bit_op_2,
    sfr_addressing      when jrb_bit_2,
    sfr_addressing      when pop_2,
    '1'                 when mov_dptr_1,
    '1'                 when mov_dptr_2,
    sfr_addressing      when xch_2,
    '0'                 when others;

-- The SFR address is the full 8 address bits; even if we know there are no
-- SFRs in the 00h..7fh range.
sfr_addr_internal <= iram_sfr_addr;
sfr_addr <= std_logic_vector(sfr_addr_internal);
-- Data written into the internal or externa SFR is the IRAM input data.
sfr_wr_internal <= bram_wr_data_p0;
sfr_wr <= std_logic_vector(sfr_wr_internal);
-- Internal and external SFR bus is identical. 
sfr_we <= sfr_we_internal;
sfr_vma <= sfr_vma_internal;

-- Internal SFR read multiplexor. Will be registered.
with sfr_addr_internal select sfr_rd_internal <=
    PSW                     when SFR_ADDR_PSW,
    SP_reg                  when SFR_ADDR_SP,
    A_reg                   when SFR_ADDR_ACC,
    B_reg                   when SFR_ADDR_B,
    DPTR_reg(15 downto 8)   when SFR_ADDR_DPH,
    DPTR_reg( 7 downto 0)   when SFR_ADDR_DPL,
    IE_reg                  when SFR_ADDR_IE,
    IP_reg                  when SFR_ADDR_IP,
    unsigned(sfr_rd)  when others; 

-- Registering the SFR read mux gives the SFR block the same timing behavior as
-- the IRAM block, and improves clock rate a lot.
SFR_mux_register:    
process(clk)
begin
    if clk'event and clk='1' then 
        sfr_rd_internal_reg <= sfr_rd_internal;
        sfr_addressing_reg <= sfr_addressing;
    end if;
end process SFR_mux_register;    
    
-- Data read from the IRAM/SFR: this is the IRAM vs. SFR multiplexor.
-- Note it is controlled with sfr_addressing_reg, which is in sync with both
-- sfr_rd_internal_reg and bram_data_p0 because of the 1-cycle data latency
-- of the BRAM and the SFR interface.
iram_sfr_rd <= sfr_rd_internal_reg when sfr_addressing_reg='1' else bram_data_p0;
    

--## 9.- PSW register and flag logic ###########################################


-- PSW flag update enable.
with ps select update_psw_flags <=
    -- Flags are updated at the same time ACC/RAM/SFR is loaded...
    '1' when alu_res_to_a,
    '1' when alu_res_to_ram,
    '1' when alu_res_to_ram_code_to_ab, 
    '1' when alu_res_to_ram_ar_to_ab,
    '1' when alu_daa_1,
        -- (XCHD states included for generality only; they never 
        -- update any flags (FM_NONE)).
    '1' when alu_xchd_4 | alu_xchd_5,
    -- ...when the CJNE magnitude comparison is made...
    '1' when cjne_a_imm_1,
    '1' when cjne_a_dir_2,
    '1' when cjne_ri_imm_4,
    '1' when cjne_rn_imm_2,
    -- ...when C is updated due by bit operation...
    '1' when bit_res_to_c,
    -- ...and when a mul/div is done.
    mul_ready when alu_mul_0,
    div_ready when alu_div_0,
    -- Note some 
    '0' when others;

-- PSW write enable for SFR accesses.    
load_psw <= '1' when sfr_addr_internal=SFR_ADDR_PSW and sfr_we_internal='1' 
            else '0';

PSW_register:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            PSW_reg <= (others => '0');
        elsif load_psw = '1' then 
            PSW_reg <= alu_result(7 downto 1);
        elsif update_psw_flags = '1' then
          
            -- C flag
            if flag_mask_reg /= FM_NONE then
                PSW_reg(7) <= alu_cy;
            end if;            
            -- OV flag
            if flag_mask_reg = FM_C_OV or flag_mask_reg = FM_ALL then
                PSW_reg(2) <= alu_ov;
            end if;            
            -- AC flag
            if flag_mask_reg = FM_ALL then
                PSW_reg(6) <= alu_ac;
            end if;                        
        end if;        
    end if;
end process PSW_register;

-- Note that P flag (bit 0) is registered separately. Join flags up here.
PSW <= PSW_reg(7 downto 1) & alu_p;
  

--## 10.- Stack logic ##########################################################

-- SP write enable for SFR accesses.    
load_sp <= '1' when sfr_addr_internal=SFR_ADDR_SP and sfr_we_internal='1' 
           else '0';
        
with ps select load_sp_implicit <=
    '1' when push_1 | pop_1,
    '1' when ret_0 | ret_1,
    '1' when acall_0 | acall_1 | lcall_1 | lcall_2,
    '1' when irq_1 | irq_2,
    '0' when others;
        
update_sp <= load_sp or load_sp_implicit;

with ps select SP_next <=
    SP_reg + 1          when push_1 | acall_0 | acall_1 | 
                             lcall_1 | lcall_2 |
                             irq_1 | irq_2,
    SP_reg - 1          when pop_1 | ret_0 | ret_1,
    nobit_alu_result    when others;

        
stack_pointer:           
process(clk)
begin
    if clk'event and clk='1' then
        if reset = '1' then
            SP_reg <= X"07";
        else
            if update_sp = '1' then
                SP_reg <= SP_next;
            end if;
        end if;
    end if;
end process stack_pointer;           

   
--## 11.- Datapath: ALU and ALU operand multiplexors ###########################

-- ALU input operand mux control for ALU class instructions. Other instructions
-- that use the ALU (CJNE, DJNZ...) will need to control those muxes. That logic
-- is within the ALU module.
-- Note that this signal gets registered for speed before being used.
with uc_alu_class_decode_0 select alu_class_op_sel <=
    AI_A_T  when AC_A_RI_to_A,
    AI_A_T  when AC_A_RN_to_A,
    AI_A_T  when AC_A_I_to_A,
    AI_A_T  when AC_A_D_to_A,
    AI_A_T  when AC_A_D_to_D,
    AI_V_T  when AC_I_D_to_D,
    AI_A_0  when AC_A_to_RI,
    AI_A_0  when AC_A_to_D,
    AI_A_0  when AC_A_to_RN,
    AI_A_0  when AC_A_to_A,
    AI_T_0  when others;

    
    alu : entity work.light52_alu
    generic map (
        IMPLEMENT_BCD_INSTRUCTIONS => IMPLEMENT_BCD_INSTRUCTIONS,
        SEQUENTIAL_MULTIPLIER => SEQUENTIAL_MULTIPLIER
    )
    port map (
        clk =>                  clk,
        reset =>                reset,
        
        -- Data outputs
        result =>               alu_result, 
        nobit_result =>         nobit_alu_result,
        bit_input_out =>        bit_input,
        
        -- Access to internal stuff
        ACC =>                  A_reg,
        B =>                    B_reg,
        
        -- XRAM, IRAM and CODE data interface
        xdata_wr =>             xdata_wr,       
        xdata_rd =>             xdata_rd,    
        code_rd =>              code_rd,
        iram_sfr_rd =>          iram_sfr_rd,            
        
        -- Input and output flags
        cy_in =>                PSW_reg(7),
        ac_in =>                PSW_reg(6),
        cy_out =>               alu_cy,
        ov_out =>               alu_ov,
        ac_out =>               alu_ac,
        p_out =>                alu_p,
        acc_is_zero =>          acc_is_zero,
        result_is_zero =>       alu_result_is_zero,
        
        -- Control inputs        
        use_bitfield =>         dpath_mux0_reg,
        alu_fn_reg =>           alu_fn_reg,
        bit_index_reg =>        bit_index_reg,
        op_sel =>               alu_class_op_sel_reg,    
        load_acc_sfr =>         load_acc_sfr,
        
        load_b_sfr =>           load_b_sfr,
        mul_ready =>            mul_ready,
        div_ready =>            div_ready,
        
        ps =>                   ps
    );


load_b_sfr <= '1' when (sfr_addr_internal=SFR_ADDR_B and 
                        sfr_we_internal='1')
              else '0';     
    
load_acc_sfr <= '1' when (sfr_addr_internal=SFR_ADDR_ACC and 
                          sfr_we_internal='1') 
                else '0';

--## 12.- DPTR and XDATA address generation ####################################

-- FIXME this should be encapsulated so that a 2nd DPTR can be easily added.

load_dph <= '1' when sfr_addr_internal=SFR_ADDR_DPH and sfr_we_internal='1'
            else '0';
load_dpl <= '1' when sfr_addr_internal=SFR_ADDR_DPL and sfr_we_internal='1'
            else '0';
inc_dptr <= '1' when ps=special_0 else '0';

DPTR_register:
process(clk)
begin
    if clk'event and clk='1' then
        if inc_dptr='1' then
            DPTR_reg <= DPTR_reg + 1;
        else
            if load_dph='1' then
                DPTR_reg(15 downto 8) <= nobit_alu_result;
            end if;
            if load_dpl='1' then
                DPTR_reg(7 downto 0) <= nobit_alu_result;
            end if;
        end if;
    end if;
end process DPTR_register;

with ps select xdata_addr <= 
    X"00" & std_logic_vector(addr0_reg)     when movx_ri_a_2,
    X"00" & std_logic_vector(addr0_reg)     when movx_a_ri_2,
    std_logic_vector(DPTR_reg)              when others;

with ps select xdata_vma <= 
    '1' when movx_dptr_a_0 | movx_a_dptr_0,
    '1' when movx_a_ri_2 | movx_ri_a_2,
    '0' when others;

with ps select xdata_we <= 
    '1' when movx_dptr_a_0,
    '1' when movx_ri_a_2,
    '0' when others;


end architecture microcoded;

--------------------------------------------------------------------------------
-- NOTES:
--
-- @note1: Decoding of '2nd half' opcodes.
--      The top half of the opcode table is decoded using the BRAM initialized 
--      as a decoding table. 
--      The bottom half of the table (Rn opcodes, rows 8 to 15) is very 
--      symmetric: you only need to decode the columns, and the opcode of each 
--      column is the same as that of row 7 (with a couple exceptions). 
--      This means we can replace the entire bottom half of the decoding table 
--      with some logic, combined with row 7 (or 5). Logic marked with @note1 
--      has this purpose.
--
-- @note2: Unnecessary reset values for data registers.
--      Reset values are strictly unnecessary for data registers such as ACC (as
--      opposed to control registers). They have been given a reset value only 
--      so that the simulations logs are identical to those of B51 software 
--      simulator.
--
-- @note3: Adder/subtractor.
--      The adder/subtractor is coded as a simple adder in which the subtrahend
--      is optionally negated -- this is for portability across synth tools.
--
-- @note4: End states of the instructions.
--      All instructions end in either fetch_0 or fetch_1. State fetch_1 can be 
--      thus considered the first state all instructions have in common. It is
--      this state that does the the interrupt check. 
--      In a future revision, many instructions may overlap fetch_0 and fetch_1
--      with their last states and the irq check will change.
--
-- @note5: Use of ns (instead of ps) in pc_incremented.
--      This is done because several states are 'shared' by more than one 
--      instruction (i.e. they belong to more than one state machine paths) so 
--      looking at the present state is not enough (Note that the *complete*
--      state in fact includes ps and uc_class_decode_0).
--      This hack simplifies the logic but hurts speed A LOT (like 10% or more).
--      We should use a *cleaner* state machine; it'd be much larger but also
--      simpler.
--
-- @note6: State on which PC is incremented.
--      PC is incremented in state decode_0 and not fetch_1 so that it is still 
--      valid in fetch_1 in case we have to push it for an interrupt response.
--------------------------------------------------------------------------------
