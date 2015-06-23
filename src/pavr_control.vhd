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
-- This file contains the control structure of the pAVR controller. That is, the
--    pipeline.
-- The pipeline stages are pretty much decoupled from each other. The pipeline is
--    initialized in stage 3 (s3) with values from the instruction decoder.
--    Basically, each pipeline stage receives values from the previous one, in a
--    shift-like flow. The `terminal' registers contain data actually used, the
--    previous ones are just used for synchronization. Exceptions from this
--    `normal' flow are the stall and flush actions, which can basically
--    independently stall or reset to zero (force a nop into) any stage. Other
--    exceptions are when several registers in such a chain are actually used,
--    not only the terminal one.
--    The terminology used reflects the data flow. For example,
--    `pavr_s4_s6_rfwr_addr1' is assigned in s3 (by the instruction decoder),
--    shifts into `pavr_s5_s6_rfwr_addr1', that finally shifts into
--    `pavr_s6_rfwr_addr1' (terminal register). Only this one carries information
--    actually used by hardware resource managers. This particualr one signalizes
--    an access request to the Register File write port manager.
-- Process splitting strategy:
--    - requests to hardware resources are managed by dedicated processes, one
--       process per hardware resource.
--       Main hardware resources:
--          - Register File (RF)
--          - Bypass Unit (BPU)
--             - ByPass Register 0 (ByPass chain 0) (BPR0)
--             - ByPass Register 1 (ByPass chain 1) (BPR1)
--             - ByPass Register 2 (ByPass chain 2) (BPR2)
--          - IO File (IOF)
--          - Status Register (SREG)
--          - Stack Pointer (SP)
--          - Arithmetic and Logic Unit (ALU)
--          - Data Access Control Unit (DACU)
--          - Program Memory (PM)
--          - Stall and Flush Unit (SFU)
--    - an asynchronous main process (instruction decoder) computes values that
--    initialize the pipeline in s3.
--    - a main synchronous process assings new values to pipeline registers.
--       - loading a register that belongs to the pipeline is conditioned by 2
--          stage-specific signals (written here in descending priority order):
--          - if stage_flush=1 then the register is reseted to zero.
--          - if stage_stall=1 then the register is not modified.
--          - if neither stall nor flush are requested, load the register with:
--             - the values from the instruction decoder, if stage = 3 (s3)
--             - some particular values if stage = s1 or s2 (values set by the PM
--                manager)
--             - the values from the previous stage, if stage != s1 or s2 or s3
-- To do
--    - Define multiplication in ALU.
--       For now, the ALU returns 0 when provided a multiplication ALU opcode.
--       However, the pAVR pipeline does its job. Multiplication instructions
--       are decoded and executed OK.
--    - Replace all those wires named `next...' with a (pretty wide) state
--       decoder.
--    - Branch prediction with hashed branch prediction table and 2 bit predictor.
-- </File info>



-- <File body>
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;
library ieee;
use ieee.std_logic_1164.all;






entity pavr is
   port(
      pavr_clk:     in std_logic;
      pavr_res:     in std_logic;
      pavr_syncres: in std_logic;

      -- Program Memory interface
      pavr_pm_addr: out std_logic_vector(21 downto 0);
      pavr_pm_do:   in  std_logic_vector(15 downto 0);
      pavr_pm_wr:   out std_logic;

      -- IO interface
      -- A single 8 bit port is implemented. It has, as alternate functions,
      --    external interrupt 0 on pin 0, and timer 0 clock input on pin 1.
      pavr_pa: inout std_logic_vector(7 downto 0);

      -- <DEBUG>
      -- This is used for testing purposes only, for instruction counting.
      pavr_inc_instr_cnt: out std_logic_vector(1 downto 0)
      -- </DEBUG>
   );
end;






architecture pavr_arch of pavr is

   -- Wires -------------------------------------------------------------------

   -- RF read port 1-related
   signal pavr_s3_rfrd1_rq       : std_logic;
   signal pavr_s5_dacu_rfrd1_rq  : std_logic;                     -- Note 1: outside pipeline

   signal pavr_s3_rfrd1_addr     : std_logic_vector(4 downto 0);

   -- RF read port 2-related
   signal pavr_s3_rfrd2_rq    : std_logic;

   signal pavr_s3_rfrd2_addr  : std_logic_vector(4 downto 0);

   -- RF write port-related
   signal next_pavr_s4_s6_aluoutlo8_rfwr_rq  : std_logic;
   signal next_pavr_s4_s61_aluouthi8_rfwr_rq : std_logic;
   signal next_pavr_s4_s6_iof_rfwr_rq        : std_logic;
   signal next_pavr_s4_s6_dacu_rfwr_rq       : std_logic;
   signal next_pavr_s4_s6_pm_rfwr_rq         : std_logic;
   signal pavr_s5_dacu_rfwr_rq               : std_logic;         -- Note 1

   signal next_pavr_s4_s6_rfwr_addr1      : std_logic_vector(4 downto 0);
   signal next_pavr_s4_s61_rfwr_addr2     : std_logic_vector(4 downto 0);
   signal pavr_s5_dacu_rfwr_di            : std_logic_vector(7 downto 0);  -- Note 1

   -- Pointer registers-related
   signal next_pavr_s4_s5_ldstincrampx_xwr_rq   : std_logic;
   signal next_pavr_s4_s5_ldstdecrampx_xwr_rq   : std_logic;

   signal next_pavr_s4_s5_ldstincrampy_ywr_rq   : std_logic;
   signal next_pavr_s4_s5_ldstdecrampy_ywr_rq   : std_logic;

   signal next_pavr_s4_s5_ldstincrampz_zwr_rq   : std_logic;
   signal next_pavr_s4_s5_ldstdecrampz_zwr_rq   : std_logic;
   signal next_pavr_s4_s5_elpmincrampz_zwr_rq   : std_logic;
   signal next_pavr_s4_s5_lpminc_zwr_rq         : std_logic;

   -- BPU read
   signal pavr_xbpu: std_logic_vector(15 downto 0);
   signal pavr_ybpu: std_logic_vector(15 downto 0);
   signal pavr_zbpu: std_logic_vector(15 downto 0);

   -- BPU write, BPR0-related
   signal next_pavr_s4_s5_alu_bpr0wr_rq      : std_logic;
   signal next_pavr_s4_s6_iof_bpr0wr_rq      : std_logic;
   signal next_pavr_s4_s6_daculd_bpr0wr_rq   : std_logic;
   signal pavr_s5_dacust_bpr0wr_rq           : std_logic;   -- Note 1
   signal next_pavr_s4_s6_pmdo_bpr0wr_rq     : std_logic;

   signal next_pavr_bpr0         : std_logic_vector(7 downto 0);
   signal next_pavr_bpr0_addr    : std_logic_vector(4 downto 0);
   signal next_pavr_bpr0_active  : std_logic;

   -- BPU write, BPR1-related
   signal next_pavr_s4_s5_dacux_bpr12wr_rq   : std_logic;
   signal next_pavr_s4_s5_dacuy_bpr12wr_rq   : std_logic;
   signal next_pavr_s4_s5_dacuz_bpr12wr_rq   : std_logic;
   signal next_pavr_s4_s5_alu_bpr1wr_rq      : std_logic;

   signal next_pavr_bpr1         : std_logic_vector(7 downto 0);
   signal next_pavr_bpr1_addr    : std_logic_vector(4 downto 0);
   signal next_pavr_bpr1_active  : std_logic;

   -- BPU write, BPR2-related

   signal next_pavr_bpr2         : std_logic_vector(7 downto 0);
   signal next_pavr_bpr2_addr    : std_logic_vector(4 downto 0);
   signal next_pavr_bpr2_active  : std_logic;

   -- IOF port-related
   signal next_pavr_s4_s5_iof_rq          : std_logic;
   signal next_pavr_s4_s6_iof_rq          : std_logic;
   signal pavr_s5_dacu_iof_rq             : std_logic;            -- Note 1

   signal next_pavr_s4_s5_iof_opcode      : std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
   signal next_pavr_s4_s6_iof_opcode      : std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
   signal next_pavr_s4_s5s6_iof_addr      : std_logic_vector(5 downto 0);
   signal next_pavr_s4_s5s6_iof_bitaddr   : std_logic_vector(2 downto 0);
   signal pavr_s5_dacu_iofwr_di           : std_logic_vector(7 downto 0);  -- Note 1

   -- SREG-related
   signal next_pavr_s4_s5_alu_sregwr_rq      : std_logic;
   signal next_pavr_s4_s5_clriflag_sregwr_rq : std_logic;
   signal next_pavr_s4_s5_setiflag_sregwr_rq : std_logic;

   -- SP-related
   signal next_pavr_s4_s5_inc_spwr_rq           : std_logic;
   signal next_pavr_s4_s5_dec_spwr_rq           : std_logic;
   signal next_pavr_s4_s5s51s52_calldec_spwr_rq : std_logic;
   signal next_pavr_s4_s5s51_retinc_spwr_rq     : std_logic;

   -- ALU-related
   signal next_pavr_s4_s5_alu_opcode         : std_logic_vector(pavr_alu_opcode_w - 1 downto 0);
   signal next_pavr_s4_s5_alu_op1_hi8_sel    : std_logic;
   signal next_pavr_s4_s5_alu_op2_sel        : std_logic_vector(pavr_alu_op2_sel_w - 1 downto 0);
   signal next_pavr_s4_s5_k8                 : std_logic_vector(7 downto 0);
   signal pavr_s5_op1bpu                     : std_logic_vector(7 downto 0);        -- Note 1
   signal pavr_s5_op2bpu                     : std_logic_vector(7 downto 0);        -- Note 1
   signal pavr_s5_alu_op1                    : std_logic_vector(15 downto 0);       -- Note 1
   signal pavr_s5_alu_op2                    : std_logic_vector( 7 downto 0);       -- Note 1
   signal pavr_s5_alu_flagsin                : std_logic_vector(5 downto 0);        -- Note 1
   signal pavr_s5_alu_flagsout               : std_logic_vector(5 downto 0);        -- Note 1
   signal pavr_s5_alu_out                    : std_logic_vector(15 downto 0);       -- Note 1

   -- DACU setup-related
   signal next_pavr_s4_dacu_q       : std_logic_vector(7 downto 0);
   signal pavr_s4_iof_dacu_q        : std_logic_vector(7 downto 0);                       -- Note 1
   signal pavr_s4_dm_dacu_q         : std_logic_vector(7 downto 0);                       -- Note 1
   signal pavr_s5_dacudo_sel        : std_logic_vector(1 downto 0);                       -- Note 1
   signal pavr_dacu_do              : std_logic_vector(7 downto 0);                       -- Note 1
   signal pavr_s5_dacust_rf_addr    : std_logic_vector(4 downto 0);                       -- Note 1
   signal pavr_s5_dacu_iof_addr     : std_logic_vector(5 downto 0);                       -- Note 1
   signal pavr_s5_dacu_dm_addr      : std_logic_vector(23 downto 0);                      -- Note 1
   signal pavr_s5_dacu_iof_opcode   : std_logic_vector(pavr_iof_opcode_w - 1 downto 0);   -- Note 1

   -- DACU read-related
   signal next_pavr_s4_s5_x_dacurd_rq        : std_logic;
   signal next_pavr_s4_s5_y_dacurd_rq        : std_logic;
   signal next_pavr_s4_s5_z_dacurd_rq        : std_logic;
   signal next_pavr_s4_s5_sp_dacurd_rq       : std_logic;
   signal next_pavr_s4_s5_k16_dacurd_rq      : std_logic;
   signal next_pavr_s4_s5s51s52_pc_dacurd_rq : std_logic;

   -- DACU write-related
   signal next_pavr_s4_s5_sp_dacuwr_rq       : std_logic;
   signal next_pavr_s4_s5_k16_dacuwr_rq      : std_logic;
   signal next_pavr_s4_s5_x_dacuwr_rq        : std_logic;
   signal next_pavr_s4_s5_y_dacuwr_rq        : std_logic;
   signal next_pavr_s4_s5_z_dacuwr_rq        : std_logic;
   signal next_pavr_s4_s5s51s52_pc_dacuwr_rq : std_logic;

   -- DM-related
   signal pavr_s5_dacu_dmrd_rq   : std_logic;                     -- Note 1
   signal pavr_s5_dacu_dmwr_rq   : std_logic;                     -- Note 1

   signal pavr_s5_dacu_dmwr_di  : std_logic_vector(7 downto 0);   -- Note 1

   -- PM access-related
   signal next_pavr_s4_s5_lpm_pm_rq    : std_logic;
   signal next_pavr_s4_s5_elpm_pm_rq   : std_logic;
   signal next_pavr_s4_z_pm_rq         : std_logic;
   signal next_pavr_s4_zeind_pm_rq     : std_logic;
   signal next_pavr_s4_k22abs_pm_rq    : std_logic;
   signal next_pavr_s4_k12rel_pm_rq    : std_logic;
   signal next_pavr_s4_k22int_pm_rq    : std_logic;
   signal next_pavr_s4_s54_ret_pm_rq   : std_logic;
   signal pavr_s6_branch_pm_rq         : std_logic;      -- Note 1
   signal pavr_s6_skip_pm_rq           : std_logic;      -- Note 1
   signal pavr_s61_skip_pm_rq          : std_logic;      -- Note 1

   signal next_pavr_s4_k6                 : std_logic_vector(5  downto 0);
   signal next_pavr_s4_k12                : std_logic_vector(11 downto 0);
   signal next_pavr_s4_k22int             : std_logic_vector(21 downto 0);
   signal next_pavr_s4_s51s52s53_retpc_ld : std_logic;
   signal next_pavr_s4_pcinc              : std_logic;

   -- PC handling-related
   signal next_pavr_s1_pc                 : std_logic_vector(21 downto 0);    -- Note 1
   signal next_pavr_s2_pc                 : std_logic_vector(21 downto 0);    -- Note 1
   signal next_pavr_s3_pc                 : std_logic_vector(21 downto 0);    -- Note 1
   signal pavr_pm_addr_int                : std_logic_vector(21 downto 0);    -- Note 1
   signal next_pavr_s2_pmdo_valid         : std_logic;                        -- Note 1
   signal next_pavr_s3_instr              : std_logic_vector(15 downto 0);    -- Note 1
   signal pavr_grant_control_flow_access  : std_logic;                        -- Note 1

   -- SFU requests-related
   signal pavr_s3_stall_rq                : std_logic;   -- *** Note 1
   signal next_pavr_s4_stall_rq           : std_logic;
   signal next_pavr_s4_s5_stall_rq        : std_logic;
   signal next_pavr_s4_s6_stall_rq        : std_logic;
   signal pavr_s3_flush_s2_rq             : std_logic;
   signal next_pavr_s4_flush_s2_rq        : std_logic;
   signal next_pavr_s4_ret_flush_s2_rq    : std_logic;
   signal next_pavr_s6_skip_rq            : std_logic;   -- Note 1
   signal next_pavr_s61_skip_rq           : std_logic;   -- Note 1
   signal next_pavr_s6_branch_rq          : std_logic;   -- Note 1
   signal next_pavr_s4_nop_rq             : std_logic;

   signal next_pavr_s4_s5_skip_cond_sel         : std_logic_vector(pavr_s5_skip_cond_sel_w - 1 downto 0);
   signal next_pavr_s4_s6_skip_cond_sel         : std_logic;
   signal next_pavr_s4_s5_skip_en               : std_logic;
   signal next_pavr_s4_s6_skip_en               : std_logic;
   signal next_pavr_s4_s5_skip_bitrf_sel        : std_logic_vector(2 downto 0);
   signal next_pavr_s4_s6_skip_bitiof_sel       : std_logic_vector(2 downto 0);
   signal next_pavr_s4_s5_k7_branch_offset      : std_logic_vector(6 downto 0);
   signal next_pavr_s4_s5_branch_cond_sel       : std_logic;
   signal next_pavr_s4_s5_branch_en             : std_logic;
   signal next_pavr_s4_s5_branch_bitsreg_sel    : std_logic_vector(2 downto 0);

   -- SFU outputs
   signal pavr_stall_s1:      std_logic;     -- Note 1
   signal pavr_stall_s2:      std_logic;     -- Note 1
   signal pavr_stall_s3:      std_logic;     -- Note 1
   signal pavr_stall_s4:      std_logic;     -- Note 1
   signal pavr_stall_s5:      std_logic;     -- Note 1
   signal pavr_stall_s6:      std_logic;     -- Note 1
   signal pavr_flush_s1:      std_logic;     -- Note 1
   signal pavr_flush_s2:      std_logic;     -- Note 1
   signal pavr_flush_s3:      std_logic;     -- Note 1
   signal pavr_flush_s4:      std_logic;     -- Note 1
   signal pavr_flush_s5:      std_logic;     -- Note 1
   signal pavr_flush_s6:      std_logic;     -- Note 1
   signal pavr_stall_bpu:     std_logic;     -- Note 1
   signal pavr_s61_hwrq_en:   std_logic;     -- Note 1   These signals signalize whether or not hardware resource requests can safely be acknowledged.
   signal pavr_s6_hwrq_en:    std_logic;     -- Note 1
   signal pavr_s5_hwrq_en:    std_logic;     -- Note 1
   signal pavr_s4_hwrq_en:    std_logic;     -- Note 1
   signal pavr_s3_hwrq_en:    std_logic;     -- Note 1
   signal pavr_s2_hwrq_en:    std_logic;     -- Note 1
   signal pavr_s1_hwrq_en:    std_logic;     -- Note 1

   -- Others
   signal next_pavr_s4_instr32bits  : std_logic;
   signal next_pavr_s4_disable_int  : std_logic;
   signal pavr_disable_int          : std_logic;
   signal pavr_int_rq               : std_logic;                        -- Note 1
   signal pavr_int_vec              : std_logic_vector(21 downto 0);    -- Note 1



   -- Wires for RF, IOF and DM connectivity

   -- RF read port 1
   signal pavr_rf_rd1_addr : std_logic_vector(4 downto 0);
   signal pavr_rf_rd1_rd   : std_logic;
   signal pavr_rf_rd1_do   : std_logic_vector(7 downto 0);

   -- RF read port 2
   signal pavr_rf_rd2_addr : std_logic_vector(4 downto 0);
   signal pavr_rf_rd2_rd   : std_logic;
   signal pavr_rf_rd2_do   : std_logic_vector(7 downto 0);

   -- RF write port
   signal pavr_rf_wr_addr  : std_logic_vector(4 downto 0);
   signal pavr_rf_wr_wr    : std_logic;
   signal pavr_rf_wr_di    : std_logic_vector(7 downto 0);

   -- X pointer port
   signal pavr_rf_x     : std_logic_vector(15 downto 0);
   signal pavr_rf_x_wr  : std_logic;
   signal pavr_rf_x_di  : std_logic_vector(15 downto 0);

   -- Y pointer port
   signal pavr_rf_y     : std_logic_vector(15 downto 0);
   signal pavr_rf_y_wr  : std_logic;
   signal pavr_rf_y_di  : std_logic_vector(15 downto 0);

   -- Z pointer port
   signal pavr_rf_z     : std_logic_vector(15 downto 0);
   signal pavr_rf_z_wr  : std_logic;
   signal pavr_rf_z_di  : std_logic_vector(15 downto 0);

   -- IOF general read and write port
   signal pavr_iof_opcode  : std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
   signal pavr_iof_addr    : std_logic_vector(5 downto 0);
   signal pavr_iof_di      : std_logic_vector(7 downto 0);
   signal pavr_iof_do      : std_logic_vector(7 downto 0);
   signal pavr_iof_bitaddr : std_logic_vector(2 downto 0);
   signal pavr_iof_bitout  : std_logic;

   -- SREG port
   signal pavr_iof_sreg    : std_logic_vector(7 downto 0);
   signal pavr_iof_sreg_wr : std_logic;
   signal pavr_iof_sreg_di : std_logic_vector(7 downto 0);

   -- SP port
   signal pavr_iof_spl     : std_logic_vector(7 downto 0);
   signal pavr_iof_spl_wr  : std_logic;
   signal pavr_iof_spl_di  : std_logic_vector(7 downto 0);

   signal pavr_iof_sph     : std_logic_vector(7 downto 0);
   signal pavr_iof_sph_wr  : std_logic;
   signal pavr_iof_sph_di  : std_logic_vector(7 downto 0);

   -- RAMPX port
   signal pavr_iof_rampx      : std_logic_vector(7 downto 0);
   signal pavr_iof_rampx_wr   : std_logic;
   signal pavr_iof_rampx_di   : std_logic_vector(7 downto 0);

   -- RAMPY port
   signal pavr_iof_rampy      : std_logic_vector(7 downto 0);
   signal pavr_iof_rampy_wr   : std_logic;
   signal pavr_iof_rampy_di   : std_logic_vector(7 downto 0);

   -- RAMPZ port
   signal pavr_iof_rampz      : std_logic_vector(7 downto 0);
   signal pavr_iof_rampz_wr   : std_logic;
   signal pavr_iof_rampz_di   : std_logic_vector(7 downto 0);

   -- RAMPD port
   signal pavr_iof_rampd      : std_logic_vector(7 downto 0);
   signal pavr_iof_rampd_wr   : std_logic;
   signal pavr_iof_rampd_di   : std_logic_vector(7 downto 0);

   -- EIND port
   signal pavr_iof_eind       : std_logic_vector(7 downto 0);
   signal pavr_iof_eind_wr    : std_logic;
   signal pavr_iof_eind_di    : std_logic_vector(7 downto 0);

   -- DM port
   signal pavr_dm_do    : std_logic_vector(7 downto 0);
   signal pavr_dm_wr    : std_logic;
   signal pavr_dm_addr  : std_logic_vector(pavr_dm_addr_w - 1 downto 0);
   signal pavr_dm_di    : std_logic_vector(7 downto 0);

   -- Registers ---------------------------------------------------------------

   -- RF read port 1-related
   -- No registers related to requests to RF read port 1.

   signal pavr_s5_op1 : std_logic_vector(7 downto 0);

   -- RF read port 2-related
   -- No registers related to requests to RF read port 2.

   signal pavr_s5_op2 : std_logic_vector(7 downto 0);

   -- RF write port-related
   signal pavr_s4_s6_aluoutlo8_rfwr_rq    : std_logic;
   signal pavr_s5_s6_aluoutlo8_rfwr_rq    : std_logic;
   signal    pavr_s6_aluoutlo8_rfwr_rq    : std_logic;
   signal pavr_s4_s61_aluouthi8_rfwr_rq   : std_logic;
   signal pavr_s5_s61_aluouthi8_rfwr_rq   : std_logic;
   signal pavr_s6_s61_aluouthi8_rfwr_rq   : std_logic;
   signal    pavr_s61_aluouthi8_rfwr_rq   : std_logic;
   signal pavr_s4_s6_iof_rfwr_rq          : std_logic;
   signal pavr_s5_s6_iof_rfwr_rq          : std_logic;
   signal    pavr_s6_iof_rfwr_rq          : std_logic;
   signal pavr_s4_s6_dacu_rfwr_rq         : std_logic;
   signal pavr_s5_s6_dacu_rfwr_rq         : std_logic;
   signal    pavr_s6_dacu_rfwr_rq         : std_logic;
   signal pavr_s4_s6_pm_rfwr_rq           : std_logic;
   signal pavr_s5_s6_pm_rfwr_rq           : std_logic;
   signal    pavr_s6_pm_rfwr_rq           : std_logic;

   signal pavr_s4_s6_rfwr_addr1           : std_logic_vector(4 downto 0);
   signal pavr_s5_s6_rfwr_addr1           : std_logic_vector(4 downto 0);
   signal    pavr_s6_rfwr_addr1           : std_logic_vector(4 downto 0);
   signal pavr_s4_s61_rfwr_addr2          : std_logic_vector(4 downto 0);
   signal pavr_s5_s61_rfwr_addr2          : std_logic_vector(4 downto 0);
   signal pavr_s6_s61_rfwr_addr2          : std_logic_vector(4 downto 0);
   signal    pavr_s61_rfwr_addr2          : std_logic_vector(4 downto 0);

   -- Pointer registers-related
   signal pavr_s4_s5_ldstincrampx_xwr_rq  : std_logic;
   signal    pavr_s5_ldstincrampx_xwr_rq  : std_logic;
   signal pavr_s4_s5_ldstdecrampx_xwr_rq  : std_logic;
   signal    pavr_s5_ldstdecrampx_xwr_rq  : std_logic;

   signal pavr_s4_s5_ldstincrampy_ywr_rq  : std_logic;
   signal    pavr_s5_ldstincrampy_ywr_rq  : std_logic;
   signal pavr_s4_s5_ldstdecrampy_ywr_rq  : std_logic;
   signal    pavr_s5_ldstdecrampy_ywr_rq  : std_logic;

   signal pavr_s4_s5_ldstincrampz_zwr_rq  : std_logic;
   signal    pavr_s5_ldstincrampz_zwr_rq  : std_logic;
   signal pavr_s4_s5_ldstdecrampz_zwr_rq  : std_logic;
   signal    pavr_s5_ldstdecrampz_zwr_rq  : std_logic;
   signal pavr_s4_s5_elpmincrampz_zwr_rq  : std_logic;
   signal    pavr_s5_elpmincrampz_zwr_rq  : std_logic;
   signal pavr_s4_s5_lpminc_zwr_rq        : std_logic;
   signal    pavr_s5_lpminc_zwr_rq        : std_logic;

   -- BPU write, BPR0-related
   signal pavr_s4_s5_alu_bpr0wr_rq     : std_logic;
   signal    pavr_s5_alu_bpr0wr_rq     : std_logic;
   signal pavr_s4_s6_iof_bpr0wr_rq     : std_logic;
   signal pavr_s5_s6_iof_bpr0wr_rq     : std_logic;
   signal    pavr_s6_iof_bpr0wr_rq     : std_logic;
   signal pavr_s4_s6_daculd_bpr0wr_rq  : std_logic;
   signal pavr_s5_s6_daculd_bpr0wr_rq  : std_logic;
   signal    pavr_s6_daculd_bpr0wr_rq  : std_logic;
   signal pavr_s4_s6_pmdo_bpr0wr_rq    : std_logic;
   signal pavr_s5_s6_pmdo_bpr0wr_rq    : std_logic;
   signal    pavr_s6_pmdo_bpr0wr_rq    : std_logic;

   signal pavr_bpr00        : std_logic_vector(7 downto 0);           -- Bypass chain 0 and associated registers. Note 1
   signal pavr_bpr00_addr   : std_logic_vector(4 downto 0);
   signal pavr_bpr00_active : std_logic;
   signal pavr_bpr01        : std_logic_vector(7 downto 0);
   signal pavr_bpr01_addr   : std_logic_vector(4 downto 0);
   signal pavr_bpr01_active : std_logic;
   signal pavr_bpr02        : std_logic_vector(7 downto 0);
   signal pavr_bpr02_addr   : std_logic_vector(4 downto 0);
   signal pavr_bpr02_active : std_logic;
   signal pavr_bpr03        : std_logic_vector(7 downto 0);
   signal pavr_bpr03_addr   : std_logic_vector(4 downto 0);
   signal pavr_bpr03_active : std_logic;

   -- BPU write, BPR1-related
   signal pavr_s4_s5_dacux_bpr12wr_rq  : std_logic;
   signal    pavr_s5_dacux_bpr12wr_rq  : std_logic;
   signal pavr_s4_s5_dacuy_bpr12wr_rq  : std_logic;
   signal    pavr_s5_dacuy_bpr12wr_rq  : std_logic;
   signal pavr_s4_s5_dacuz_bpr12wr_rq  : std_logic;
   signal    pavr_s5_dacuz_bpr12wr_rq  : std_logic;
   signal pavr_s4_s5_alu_bpr1wr_rq     : std_logic;
   signal    pavr_s5_alu_bpr1wr_rq     : std_logic;

   signal pavr_bpr10          : std_logic_vector(7 downto 0);           -- Bypass chain 1 and associated registers. Note 1
   signal pavr_bpr10_addr     : std_logic_vector(4 downto 0);
   signal pavr_bpr10_active   : std_logic;
   signal pavr_bpr11          : std_logic_vector(7 downto 0);
   signal pavr_bpr11_addr     : std_logic_vector(4 downto 0);
   signal pavr_bpr11_active   : std_logic;
   signal pavr_bpr12          : std_logic_vector(7 downto 0);
   signal pavr_bpr12_addr     : std_logic_vector(4 downto 0);
   signal pavr_bpr12_active   : std_logic;
   signal pavr_bpr13          : std_logic_vector(7 downto 0);
   signal pavr_bpr13_addr     : std_logic_vector(4 downto 0);
   signal pavr_bpr13_active   : std_logic;

   -- BPU write, BPR2-related

   signal pavr_bpr20          : std_logic_vector(7 downto 0);           -- Bypass chain 2 and associated registers. Note 1
   signal pavr_bpr20_addr     : std_logic_vector(4 downto 0);
   signal pavr_bpr20_active   : std_logic;
   signal pavr_bpr21          : std_logic_vector(7 downto 0);
   signal pavr_bpr21_addr     : std_logic_vector(4 downto 0);
   signal pavr_bpr21_active   : std_logic;
   signal pavr_bpr22          : std_logic_vector(7 downto 0);
   signal pavr_bpr22_addr     : std_logic_vector(4 downto 0);
   signal pavr_bpr22_active   : std_logic;
   signal pavr_bpr23          : std_logic_vector(7 downto 0);
   signal pavr_bpr23_addr     : std_logic_vector(4 downto 0);
   signal pavr_bpr23_active   : std_logic;

   -- IOF port-related
   signal pavr_s4_s5_iof_rq          : std_logic;
   signal    pavr_s5_iof_rq          : std_logic;
   signal pavr_s4_s6_iof_rq          : std_logic;
   signal pavr_s5_s6_iof_rq          : std_logic;
   signal    pavr_s6_iof_rq          : std_logic;

   signal pavr_s4_s5_iof_opcode      : std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
   signal    pavr_s5_iof_opcode      : std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
   signal pavr_s4_s6_iof_opcode      : std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
   signal pavr_s5_s6_iof_opcode      : std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
   signal    pavr_s6_iof_opcode      : std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
   signal pavr_s4_s5s6_iof_addr      : std_logic_vector(5 downto 0);
   signal      pavr_s5_iof_addr      : std_logic_vector(5 downto 0);
   signal      pavr_s6_iof_addr      : std_logic_vector(5 downto 0);
   signal pavr_s4_s5s6_iof_bitaddr   : std_logic_vector(2 downto 0);
   signal      pavr_s5_iof_bitaddr   : std_logic_vector(2 downto 0);
   signal      pavr_s6_iof_bitaddr   : std_logic_vector(2 downto 0);

   -- SREG-related
   signal pavr_s4_s5_alu_sregwr_rq        : std_logic;
   signal    pavr_s5_alu_sregwr_rq        : std_logic;
   signal pavr_s4_s5_clriflag_sregwr_rq   : std_logic;
   signal    pavr_s5_clriflag_sregwr_rq   : std_logic;
   signal pavr_s4_s5_setiflag_sregwr_rq   : std_logic;
   signal    pavr_s5_setiflag_sregwr_rq   : std_logic;

   -- SP-related
   signal pavr_s4_s5_inc_spwr_rq             : std_logic;
   signal    pavr_s5_inc_spwr_rq             : std_logic;
   signal pavr_s4_s5_dec_spwr_rq             : std_logic;
   signal    pavr_s5_dec_spwr_rq             : std_logic;
   signal pavr_s4_s5s51s52_calldec_spwr_rq   : std_logic;
   signal    pavr_s5_calldec_spwr_rq         : std_logic;
   signal    pavr_s51_calldec_spwr_rq        : std_logic;
   signal    pavr_s52_calldec_spwr_rq        : std_logic;
   signal pavr_s4_s5s51_retinc_spwr_rq       : std_logic;
   signal    pavr_s5_retinc2_spwr_rq         : std_logic;
   signal    pavr_s51_retinc_spwr_rq         : std_logic;

   -- ALU-related
   signal pavr_s4_s5_alu_opcode        : std_logic_vector(pavr_alu_opcode_w - 1 downto 0);
   signal    pavr_s5_alu_opcode        : std_logic_vector(pavr_alu_opcode_w - 1 downto 0);
   signal pavr_s4_s5_alu_op1_hi8_sel   : std_logic;
   signal    pavr_s5_alu_op1_hi8_sel   : std_logic;
   signal pavr_s4_s5_alu_op2_sel       : std_logic_vector(pavr_alu_op2_sel_w - 1 downto 0);
   signal    pavr_s5_alu_op2_sel       : std_logic_vector(pavr_alu_op2_sel_w - 1 downto 0);
   signal pavr_s4_s5_op1_addr          : std_logic_vector(4 downto 0);
   signal    pavr_s5_op1_addr          : std_logic_vector(4 downto 0);
   signal pavr_s4_s5_op2_addr          : std_logic_vector(4 downto 0);
   signal    pavr_s5_op2_addr          : std_logic_vector(4 downto 0);
   signal pavr_s4_s5_k8                : std_logic_vector(7 downto 0);
   signal    pavr_s5_k8                : std_logic_vector(7 downto 0);
   signal pavr_s6_alu_out              : std_logic_vector(15 downto 0);
   signal pavr_s61_alu_out_hi8         : std_logic_vector( 7 downto 0);

   -- DACU setup-related
   signal pavr_s4_dacu_q      : std_logic_vector(7 downto 0);
   signal pavr_s5_rf_dacu_q   : std_logic_vector(7 downto 0);
   signal pavr_s5_iof_dacu_q  : std_logic_vector(7 downto 0);
   signal pavr_s5_dm_dacu_q   : std_logic_vector(7 downto 0);
   signal pavr_s6_dacudo_sel  : std_logic_vector(1 downto 0);
   signal pavr_s5_k16         : std_logic_vector(15 downto 0); -- *** Attention: no `pavr_s4_s5_k16'. `pavr_s5_k16' is fed directly from stage s3.

   -- DACU read-related
   signal pavr_s4_s5_x_dacurd_rq          : std_logic;
   signal    pavr_s5_x_dacurd_rq          : std_logic;
   signal pavr_s4_s5_y_dacurd_rq          : std_logic;
   signal    pavr_s5_y_dacurd_rq          : std_logic;
   signal pavr_s4_s5_z_dacurd_rq          : std_logic;
   signal    pavr_s5_z_dacurd_rq          : std_logic;
   signal pavr_s4_s5_sp_dacurd_rq         : std_logic;
   signal    pavr_s5_sp_dacurd_rq         : std_logic;
   signal pavr_s4_s5_k16_dacurd_rq        : std_logic;
   signal    pavr_s5_k16_dacurd_rq        : std_logic;
   signal pavr_s4_s5s51s52_pc_dacurd_rq   : std_logic;
   signal    pavr_s5_pchi8_dacurd_rq      : std_logic;
   signal    pavr_s51_pcmid8_dacurd_rq    : std_logic;
   signal    pavr_s52_pclo8_dacurd_rq     : std_logic;

   -- DACU write-related
   signal pavr_s4_s5_sp_dacuwr_rq         : std_logic;
   signal    pavr_s5_sp_dacuwr_rq         : std_logic;
   signal pavr_s4_s5_k16_dacuwr_rq        : std_logic;
   signal    pavr_s5_k16_dacuwr_rq        : std_logic;
   signal pavr_s4_s5_x_dacuwr_rq          : std_logic;
   signal    pavr_s5_x_dacuwr_rq          : std_logic;
   signal pavr_s4_s5_y_dacuwr_rq          : std_logic;
   signal    pavr_s5_y_dacuwr_rq          : std_logic;
   signal pavr_s4_s5_z_dacuwr_rq          : std_logic;
   signal    pavr_s5_z_dacuwr_rq          : std_logic;
   signal pavr_s4_s5s51s52_pc_dacuwr_rq   : std_logic;
   signal    pavr_s5_pclo8_dacuwr_rq      : std_logic;
   signal    pavr_s51_pcmid8_dacuwr_rq    : std_logic;
   signal    pavr_s52_pchi8_dacuwr_rq     : std_logic;

   -- DM-related

   -- PM access-related
   signal pavr_s4_s5_lpm_pm_rq   : std_logic;
   signal    pavr_s5_lpm_pm_rq   : std_logic;
   signal pavr_s4_s5_elpm_pm_rq  : std_logic;
   signal    pavr_s5_elpm_pm_rq  : std_logic;
   signal pavr_s4_z_pm_rq        : std_logic;
   signal pavr_s4_zeind_pm_rq    : std_logic;
   signal pavr_s4_k22abs_pm_rq   : std_logic;
   signal pavr_s4_k12rel_pm_rq   : std_logic;
   signal pavr_s4_k22int_pm_rq   : std_logic;
   signal pavr_s4_s54_ret_pm_rq  : std_logic;
   signal pavr_s5_s54_ret_pm_rq  : std_logic;
   signal pavr_s51_s54_ret_pm_rq : std_logic;
   signal pavr_s52_s54_ret_pm_rq : std_logic;
   signal pavr_s53_s54_ret_pm_rq : std_logic;
   signal     pavr_s54_ret_pm_rq : std_logic;

   signal pavr_s4_k6                   : std_logic_vector(5 downto 0);
   signal pavr_s4_k12                  : std_logic_vector(11 downto 0);
   signal pavr_s4_k22int               : std_logic_vector(21 downto 0);
   signal pavr_s2_pc                   : std_logic_vector(21 downto 0);
   signal pavr_s3_pc                   : std_logic_vector(21 downto 0);
   signal pavr_s4_pc                   : std_logic_vector(21 downto 0);
   signal pavr_s5_pc                   : std_logic_vector(21 downto 0);
   signal pavr_s51_pc                  : std_logic_vector(21 downto 0);
   signal pavr_s52_pc                  : std_logic_vector(21 downto 0);
   signal pavr_s4_pcinc                : std_logic;
   signal pavr_s4_s51s52s53_retpc_ld   : std_logic;
   signal pavr_s5_s51s52s53_retpc_ld   : std_logic;
   signal    pavr_s51_retpchi8_ld      : std_logic;
   signal    pavr_s52_retpcmid8_ld     : std_logic;
   signal    pavr_s53_retpclo8_ld      : std_logic;
   signal pavr_s52_retpchi8            : std_logic_vector(7 downto 0);
   signal pavr_s53_retpcmid8           : std_logic_vector(7 downto 0);
   signal pavr_s54_retpclo8            : std_logic_vector(7 downto 0);
   signal pavr_s1_pc                   : std_logic_vector(21 downto 0);
   signal pavr_s2_pmdo_valid           : std_logic;

   signal pavr_s6_zlsb                 : std_logic;      -- Needed by LPM instructions to select low/high byte read.

   -- SFU requests-related
   signal    pavr_s4_stall_rq        : std_logic;
   signal pavr_s4_s5_stall_rq        : std_logic;
   signal    pavr_s5_stall_rq        : std_logic;
   signal pavr_s4_s6_stall_rq        : std_logic;
   signal pavr_s5_s6_stall_rq        : std_logic;
   signal    pavr_s6_stall_rq        : std_logic;
   signal pavr_s4_flush_s2_rq        : std_logic;
   signal pavr_s4_ret_flush_s2_rq    : std_logic;
   signal pavr_s5_ret_flush_s2_rq    : std_logic;
   signal pavr_s51_ret_flush_s2_rq   : std_logic;
   signal pavr_s52_ret_flush_s2_rq   : std_logic;
   signal pavr_s53_ret_flush_s2_rq   : std_logic;
   signal pavr_s54_ret_flush_s2_rq   : std_logic;
   signal pavr_s55_ret_flush_s2_rq   : std_logic;
   signal pavr_s6_skip_rq            : std_logic;
   signal pavr_s61_skip_rq           : std_logic;
   signal pavr_s6_branch_rq          : std_logic;
   signal pavr_s4_nop_rq             : std_logic;

   signal pavr_s4_s5_skip_cond_sel     : std_logic_vector(pavr_s5_skip_cond_sel_w - 1 downto 0);
   signal    pavr_s5_skip_cond_sel     : std_logic_vector(pavr_s5_skip_cond_sel_w - 1 downto 0);
   signal pavr_s4_s6_skip_cond_sel     : std_logic;
   signal pavr_s5_s6_skip_cond_sel     : std_logic;
   signal    pavr_s6_skip_cond_sel     : std_logic;
   signal pavr_s4_s5_skip_en           : std_logic;
   signal    pavr_s5_skip_en           : std_logic;
   signal pavr_s4_s6_skip_en           : std_logic;
   signal pavr_s5_s6_skip_en           : std_logic;
   signal    pavr_s6_skip_en           : std_logic;
   signal pavr_s4_s5_skip_bitrf_sel    : std_logic_vector(2 downto 0);
   signal    pavr_s5_skip_bitrf_sel    : std_logic_vector(2 downto 0);
   signal pavr_s4_s6_skip_bitiof_sel   : std_logic_vector(2 downto 0);
   signal pavr_s5_s6_skip_bitiof_sel   : std_logic_vector(2 downto 0);
   signal    pavr_s6_skip_bitiof_sel   : std_logic_vector(2 downto 0);

   signal pavr_s4_s5_k7_branch_offset     : std_logic_vector(6 downto 0);
   signal    pavr_s5_k7_branch_offset     : std_logic_vector(6 downto 0);
   signal pavr_s6_branch_pc               : std_logic_vector(21 downto 0);
   signal pavr_s4_s5_branch_cond_sel      : std_logic;
   signal    pavr_s5_branch_cond_sel      : std_logic;
   signal pavr_s4_s5_branch_en            : std_logic;
   signal    pavr_s5_branch_en            : std_logic;
   signal pavr_s4_s5_branch_bitsreg_sel   : std_logic_vector(2 downto 0);
   signal    pavr_s5_branch_bitsreg_sel   : std_logic_vector(2 downto 0);

   -- Others
   signal pavr_nop_ack           : std_logic;                     -- Nop state machine's memory. The nop state machine is outside the pipeline.
   signal pavr_s3_instr          : std_logic_vector(15 downto 0); -- Instruction register
   signal pavr_s4_instr32bits    : std_logic;                     -- Signalizes that this instruction is 32 bits wide. Next word (16 bits) will be ignored by the instruction decoder (nop). It's a constant that will be extracted directly by s5.
   signal pavr_s4_disable_int    : std_logic;
   signal pavr_s5_disable_int    : std_logic;
   signal pavr_s51_disable_int   : std_logic;
   signal pavr_s52_disable_int   : std_logic;

   -- Shadow-related
   -- Shadow registers hold temporary values already read from memories but not
   --    yet used because of a stall. See comments at Shadow Manager process.
   -- RF-related shadow registers
   signal pavr_rf_rd1_do_shadow     : std_logic_vector(7 downto 0);
   signal pavr_rf_rd2_do_shadow     : std_logic_vector(7 downto 0);
   -- IOF-related shadow registers
   signal pavr_iof_do_shadow        : std_logic_vector(7 downto 0);
   -- DM-related shadow registers
   signal pavr_dm_do_shadow         : std_logic_vector(7 downto 0);
   -- DACU-related shadow registers
   signal pavr_dacu_do_shadow       : std_logic_vector(7 downto 0);
   -- PM-related shadow registers
   signal pavr_pm_do_shadow         : std_logic_vector(15 downto 0);
   signal pavr_s2_pmdo_valid_shadow : std_logic;

   signal pavr_rf_do_shadow_active                    : std_logic;
   signal pavr_iof_do_shadow_active                   : std_logic;
   signal pavr_dm_do_shadow_active                    : std_logic;
   signal pavr_dacu_do_shadow_active                  : std_logic;
   signal pavr_pm_do_shadow_active                    : std_logic;






   -- Declare components ------------------------------------------------------

   -- Declare the Register File.
   component pavr_rf
   port(
      pavr_rf_clk:     in std_logic;
      pavr_rf_res:     in std_logic;
      pavr_rf_syncres: in std_logic;

      -- Read port #1
      pavr_rf_rd1_addr: in  std_logic_vector(4 downto 0);
      pavr_rf_rd1_rd:   in  std_logic;
      pavr_rf_rd1_do:   out std_logic_vector(7 downto 0);

      -- Read port #2
      pavr_rf_rd2_addr: in  std_logic_vector(4 downto 0);
      pavr_rf_rd2_rd:   in  std_logic;
      pavr_rf_rd2_do:   out std_logic_vector(7 downto 0);

      -- Write port
      pavr_rf_wr_addr: in std_logic_vector(4 downto 0);
      pavr_rf_wr_wr:   in std_logic;
      pavr_rf_wr_di:   in std_logic_vector(7 downto 0);

      -- Pointer registers
      pavr_rf_x:    out std_logic_vector(15 downto 0);
      pavr_rf_x_wr: in  std_logic;
      pavr_rf_x_di: in  std_logic_vector(15 downto 0);

      pavr_rf_y:    out std_logic_vector(15 downto 0);
      pavr_rf_y_wr: in  std_logic;
      pavr_rf_y_di: in  std_logic_vector(15 downto 0);

      pavr_rf_z:    out std_logic_vector(15 downto 0);
      pavr_rf_z_wr: in  std_logic;
      pavr_rf_z_di: in  std_logic_vector(15 downto 0)
   );
   end component;
   for all: pavr_rf use entity work.pavr_rf(pavr_rf_arch);

   -- Declare the IO File.
   component pavr_iof
   port(
      pavr_iof_clk      : in std_logic;
      pavr_iof_res      : in std_logic;
      pavr_iof_syncres  : in std_logic;

      -- General IO file port
      pavr_iof_opcode   : in  std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
      pavr_iof_addr     : in  std_logic_vector(5 downto 0);
      pavr_iof_di       : in  std_logic_vector(7 downto 0);
      pavr_iof_do       : out std_logic_vector(7 downto 0);
      pavr_iof_bitout   : out std_logic;
      pavr_iof_bitaddr  : in  std_logic_vector(2 downto 0);

      -- AVR kernel register ports
      -- Status register (SREG)
      pavr_iof_sreg     : out std_logic_vector(7 downto 0);
      pavr_iof_sreg_wr  : in  std_logic;
      pavr_iof_sreg_di  : in  std_logic_vector(7 downto 0);

      -- Stack pointer (SP = SPH&SPL)
      pavr_iof_sph      : out std_logic_vector(7 downto 0);
      pavr_iof_sph_wr   : in  std_logic;
      pavr_iof_sph_di   : in  std_logic_vector(7 downto 0);
      pavr_iof_spl      : out std_logic_vector(7 downto 0);
      pavr_iof_spl_wr   : in  std_logic;
      pavr_iof_spl_di   : in  std_logic_vector(7 downto 0);

      -- Pointer registers extensions (RAMPX, RAMPY, RAMPZ)
      pavr_iof_rampx    : out std_logic_vector(7 downto 0);
      pavr_iof_rampx_wr : in  std_logic;
      pavr_iof_rampx_di : in  std_logic_vector(7 downto 0);

      pavr_iof_rampy    : out std_logic_vector(7 downto 0);
      pavr_iof_rampy_wr : in  std_logic;
      pavr_iof_rampy_di : in  std_logic_vector(7 downto 0);

      pavr_iof_rampz    : out std_logic_vector(7 downto 0);
      pavr_iof_rampz_wr : in  std_logic;
      pavr_iof_rampz_di : in  std_logic_vector(7 downto 0);

      -- Data Memory extension address register (RAMPD)
      pavr_iof_rampd    : out std_logic_vector(7 downto 0);
      pavr_iof_rampd_wr : in  std_logic;
      pavr_iof_rampd_di : in  std_logic_vector(7 downto 0);

      -- Program Memory extension address register (EIND)
      pavr_iof_eind     : out std_logic_vector(7 downto 0);
      pavr_iof_eind_wr  : in  std_logic;
      pavr_iof_eind_di  : in  std_logic_vector(7 downto 0);

      -- AVR non-kernel (feature) register ports
      -- Port A
      pavr_iof_pa : inout std_logic_vector(7 downto 0);

      -- Interrupt-related interface signals to control module (to the pipeline).
      pavr_disable_int  : in  std_logic;
      pavr_int_rq       : out std_logic;
      pavr_int_vec      : out std_logic_vector(21 downto 0)
   );
   end component;
   for all: pavr_iof use entity work.pavr_iof(pavr_iof_arch);

   -- Declare the Data Memory
   component pavr_dm
   port(
      pavr_dm_clk:  in  std_logic;
      pavr_dm_wr:   in  std_logic;
      pavr_dm_addr: in  std_logic_vector(pavr_dm_addr_w - 1 downto 0);
      pavr_dm_di:   in  std_logic_vector(7 downto 0);
      pavr_dm_do:   out std_logic_vector(7 downto 0)
   );
   end component;
   for all: pavr_dm use entity work.pavr_dm(pavr_dm_arch);

   -- Declare the ALU.
   component pavr_alu
   port(
      pavr_alu_op1:      in  std_logic_vector(15 downto 0);
      pavr_alu_op2:      in  std_logic_vector(7 downto 0);
      pavr_alu_out:      out std_logic_vector(15 downto 0);
      pavr_alu_opcode:   in  std_logic_vector(pavr_alu_opcode_w - 1 downto 0);
      pavr_alu_flagsin:  in  std_logic_vector(5 downto 0);
      pavr_alu_flagsout: out std_logic_vector(5 downto 0)
   );
   end component;
   for all: pavr_alu use entity work.pavr_alu(pavr_alu_arch);



begin

   -- Instantiate Components --------------------------------------------------

   -- Instantiate the Register File.
   pavr_rf_instance1: pavr_rf
   port map(
      pavr_clk,
      pavr_res,
      pavr_syncres,

      -- Read port #1
      pavr_rf_rd1_addr,
      pavr_rf_rd1_rd,
      pavr_rf_rd1_do,

      -- Read port #2
      pavr_rf_rd2_addr,
      pavr_rf_rd2_rd,
      pavr_rf_rd2_do,

      -- Write port
      pavr_rf_wr_addr,
      pavr_rf_wr_wr,
      pavr_rf_wr_di,

      -- Pointer registers
      pavr_rf_x,
      pavr_rf_x_wr,
      pavr_rf_x_di,

      pavr_rf_y,
      pavr_rf_y_wr,
      pavr_rf_y_di,

      pavr_rf_z,
      pavr_rf_z_wr,
      pavr_rf_z_di
   );

   -- Instantiate the IO File.
   pavr_iof_instance1: pavr_iof
   port map(
      pavr_clk,
      pavr_res,
      pavr_syncres,

      -- General IO file port
      pavr_iof_opcode,
      pavr_iof_addr,
      pavr_iof_di,
      pavr_iof_do,
      pavr_iof_bitout,
      pavr_iof_bitaddr,

      -- AVR kernel register ports
      -- Status register (SREG)
      pavr_iof_sreg,
      pavr_iof_sreg_wr,
      pavr_iof_sreg_di,

      -- Stack pointer (SP = SPH&SPL)
      pavr_iof_sph,
      pavr_iof_sph_wr,
      pavr_iof_sph_di,
      pavr_iof_spl,
      pavr_iof_spl_wr,
      pavr_iof_spl_di,

      -- Pointer registers extensions (RAMPX, RAMPY, RAMPZ)
      pavr_iof_rampx,
      pavr_iof_rampx_wr,
      pavr_iof_rampx_di,

      pavr_iof_rampy,
      pavr_iof_rampy_wr,
      pavr_iof_rampy_di,

      pavr_iof_rampz,
      pavr_iof_rampz_wr,
      pavr_iof_rampz_di,

      -- Data Memory extension address register (RAMPD)
      pavr_iof_rampd,
      pavr_iof_rampd_wr,
      pavr_iof_rampd_di,

      -- Program Memory extension address register (EIND)
      pavr_iof_eind,
      pavr_iof_eind_wr,
      pavr_iof_eind_di,

      -- AVR non-kernel (feature) register ports
      -- Port A
      pavr_pa,

      -- Interrupt-related interface signals to control module (to the pipeline).
      pavr_disable_int,
      pavr_int_rq,
      pavr_int_vec
   );

   -- Instantiate the Data Memory.
   pavr_dm_instance1: pavr_dm
   port map(
      pavr_clk,
      pavr_dm_wr,
      pavr_dm_addr,
      pavr_dm_di,
      pavr_dm_do
   );

   -- Instantiate the ALU.
   pavr_alu_instance1: pavr_alu
   port map(
      pavr_s5_alu_op1,
      pavr_s5_alu_op2,
      pavr_s5_alu_out,
      pavr_s5_alu_opcode,
      pavr_s5_alu_flagsin,
      pavr_s5_alu_flagsout
   );



   -- Main synchronous process ------------------------------------------------
   -- Basically, assign registers (whether they are inside or outside the pipeline)
   --    with the values generated by the instruction decoder, from the previous
   --    stage or other sources outside the pipeline.
   control_sync:
   process(pavr_clk, pavr_res, pavr_syncres,
           pavr_s5_op1, pavr_s5_op2, pavr_s4_s6_rfwr_addr1, pavr_s5_s6_rfwr_addr1, pavr_s6_rfwr_addr1,
           pavr_s4_s61_rfwr_addr2, pavr_s5_s61_rfwr_addr2, pavr_s6_s61_rfwr_addr2, pavr_s61_rfwr_addr2,
           pavr_bpr00, pavr_bpr00_addr, pavr_bpr00_active, pavr_bpr01, pavr_bpr01_addr, pavr_bpr01_active, pavr_bpr02, pavr_bpr02_addr,
           pavr_bpr10, pavr_bpr10_addr, pavr_bpr10_active, pavr_bpr11, pavr_bpr11_addr, pavr_bpr11_active, pavr_bpr12, pavr_bpr12_addr,
           pavr_s4_s5_iof_opcode, pavr_s5_iof_opcode, pavr_s4_s6_iof_opcode, pavr_s5_s6_iof_opcode, pavr_s6_iof_opcode,
           pavr_s4_s5s6_iof_addr, pavr_s5_iof_addr, pavr_s6_iof_addr, pavr_s4_s5s6_iof_bitaddr, pavr_s5_iof_bitaddr, pavr_s6_iof_bitaddr,
           pavr_s4_s5_alu_opcode, pavr_s5_alu_opcode, pavr_s4_s5_alu_op2_sel, pavr_s5_alu_op2_sel, pavr_s4_s5_op1_addr, pavr_s5_op1_addr,
           pavr_s4_s5_op2_addr, pavr_s5_op2_addr, pavr_s4_s5_k8, pavr_s5_k8, pavr_s6_alu_out, pavr_s61_alu_out_hi8, pavr_s4_dacu_q,
           pavr_s5_rf_dacu_q, pavr_s5_iof_dacu_q, pavr_s5_dm_dacu_q, pavr_s6_dacudo_sel, pavr_s5_k16, pavr_s4_k6, pavr_s4_k12, pavr_s4_k22int,
           pavr_s1_pc, pavr_s2_pc, pavr_s3_pc, pavr_s4_pc, pavr_s5_pc, pavr_s51_pc, pavr_s52_pc, pavr_s52_retpchi8, pavr_s53_retpcmid8,
           pavr_s54_retpclo8, pavr_s4_s5_skip_cond_sel, pavr_s5_skip_cond_sel, pavr_s4_s6_skip_cond_sel, pavr_s5_s6_skip_cond_sel,
           pavr_s4_s5_skip_bitrf_sel, pavr_s5_skip_bitrf_sel, pavr_s4_s6_skip_bitiof_sel, pavr_s5_s6_skip_bitiof_sel,
           pavr_s6_skip_bitiof_sel, pavr_s4_s5_k7_branch_offset, pavr_s5_k7_branch_offset, pavr_s6_branch_pc, pavr_s4_s5_branch_bitsreg_sel,
           pavr_s5_branch_bitsreg_sel, pavr_s3_instr, pavr_flush_s3, pavr_flush_s4, pavr_flush_s5,
           pavr_flush_s6, pavr_stall_s3, next_pavr_s4_s6_aluoutlo8_rfwr_rq,
           next_pavr_s4_s61_aluouthi8_rfwr_rq, next_pavr_s4_s6_iof_rfwr_rq, next_pavr_s4_s6_dacu_rfwr_rq, next_pavr_s4_s6_pm_rfwr_rq,
           next_pavr_s4_s6_rfwr_addr1, next_pavr_s4_s61_rfwr_addr2, next_pavr_s4_s5_ldstincrampx_xwr_rq, next_pavr_s4_s5_ldstdecrampx_xwr_rq,
           next_pavr_s4_s5_ldstincrampy_ywr_rq, next_pavr_s4_s5_ldstdecrampy_ywr_rq, next_pavr_s4_s5_ldstincrampz_zwr_rq, next_pavr_s4_s5_ldstdecrampz_zwr_rq,
           next_pavr_s4_s5_lpminc_zwr_rq, next_pavr_s4_s5_alu_bpr0wr_rq, next_pavr_s4_s6_daculd_bpr0wr_rq, next_pavr_s4_s5_alu_bpr1wr_rq,
           next_pavr_s4_s5_iof_rq, next_pavr_s4_s6_iof_rq, next_pavr_s4_s5_iof_opcode, next_pavr_s4_s6_iof_opcode, next_pavr_s4_s5s6_iof_addr,
           next_pavr_s4_s5s6_iof_bitaddr, next_pavr_s4_s5_alu_sregwr_rq, next_pavr_s4_s5_clriflag_sregwr_rq, next_pavr_s4_s5_setiflag_sregwr_rq,
           next_pavr_s4_s5_inc_spwr_rq, next_pavr_s4_s5_dec_spwr_rq, next_pavr_s4_s5s51s52_calldec_spwr_rq, next_pavr_s4_s5s51_retinc_spwr_rq,
           next_pavr_s4_s5_alu_opcode, next_pavr_s4_s5_alu_op1_hi8_sel, next_pavr_s4_s5_alu_op2_sel, pavr_s3_rfrd1_addr, pavr_s3_rfrd2_addr,
           next_pavr_s4_s5_k8, next_pavr_s4_dacu_q, next_pavr_s4_s5_x_dacurd_rq, next_pavr_s4_s5_y_dacurd_rq, next_pavr_s4_s5_z_dacurd_rq,
           next_pavr_s4_s5_sp_dacurd_rq, next_pavr_s4_s5_k16_dacurd_rq, next_pavr_s4_s5s51s52_pc_dacurd_rq, next_pavr_s4_s5_sp_dacuwr_rq,
           next_pavr_s4_s5_x_dacuwr_rq, next_pavr_s4_s5_y_dacuwr_rq, next_pavr_s4_s5_z_dacuwr_rq, next_pavr_s4_s5s51s52_pc_dacuwr_rq,
           next_pavr_s4_s5_lpm_pm_rq, next_pavr_s4_s5_elpm_pm_rq, next_pavr_s4_z_pm_rq, next_pavr_s4_zeind_pm_rq, next_pavr_s4_k22abs_pm_rq,
           next_pavr_s4_k12rel_pm_rq, next_pavr_s4_k22int_pm_rq, next_pavr_s4_s54_ret_pm_rq, next_pavr_s4_k6, next_pavr_s4_k12,
           next_pavr_s4_k22int, next_pavr_s4_s51s52s53_retpc_ld, next_pavr_s4_s5_stall_rq, next_pavr_s4_s6_stall_rq, next_pavr_s4_flush_s2_rq,
           next_pavr_s4_ret_flush_s2_rq, next_pavr_s4_nop_rq, next_pavr_s4_s5_skip_cond_sel, next_pavr_s4_s6_skip_cond_sel,
           next_pavr_s4_s5_skip_en, next_pavr_s4_s6_skip_en, next_pavr_s4_s5_skip_bitrf_sel, next_pavr_s4_s6_skip_bitiof_sel,
           next_pavr_s4_s5_k7_branch_offset, next_pavr_s4_s5_branch_cond_sel, next_pavr_s4_s5_branch_en, next_pavr_s4_s5_branch_bitsreg_sel,
           next_pavr_s4_instr32bits, next_pavr_s4_disable_int, pavr_stall_s4, pavr_rf_rd1_do, pavr_rf_rd2_do, pavr_s4_s6_aluoutlo8_rfwr_rq,
           pavr_s4_s61_aluouthi8_rfwr_rq, pavr_s4_s6_iof_rfwr_rq, pavr_s4_s6_dacu_rfwr_rq, pavr_s4_s6_pm_rfwr_rq, pavr_s4_s5_ldstincrampx_xwr_rq,
           pavr_s4_s5_ldstdecrampx_xwr_rq, pavr_s4_s5_ldstincrampy_ywr_rq, pavr_s4_s5_ldstdecrampy_ywr_rq, pavr_s4_s5_ldstincrampz_zwr_rq,
           pavr_s4_s5_ldstdecrampz_zwr_rq, pavr_s4_s5_lpminc_zwr_rq, pavr_s4_s5_alu_bpr0wr_rq, pavr_s4_s6_daculd_bpr0wr_rq, pavr_s4_s5_alu_bpr1wr_rq,
           pavr_s4_s5_iof_rq, pavr_s4_s6_iof_rq, pavr_s4_s5_alu_sregwr_rq, pavr_s4_s5_clriflag_sregwr_rq, pavr_s4_s5_setiflag_sregwr_rq,
           pavr_s4_s5_inc_spwr_rq, pavr_s4_s5_dec_spwr_rq, pavr_s4_s5s51s52_calldec_spwr_rq, pavr_s4_s5s51_retinc_spwr_rq,
           pavr_s4_s5_alu_op1_hi8_sel, pavr_s4_iof_dacu_q, pavr_s4_dm_dacu_q, pavr_s4_instr32bits, pavr_s4_s5_x_dacurd_rq,
           pavr_s4_s5_y_dacurd_rq, pavr_s4_s5_z_dacurd_rq, pavr_s4_s5_sp_dacurd_rq, pavr_s4_s5_k16_dacurd_rq, pavr_s4_s5s51s52_pc_dacurd_rq,
           pavr_s4_s5_sp_dacuwr_rq, pavr_s4_s5_x_dacuwr_rq, pavr_s4_s5_y_dacuwr_rq, pavr_s4_s5_z_dacuwr_rq, pavr_s4_s5s51s52_pc_dacuwr_rq,
           pavr_s4_s5_lpm_pm_rq, pavr_s4_s5_elpm_pm_rq, pavr_s4_s54_ret_pm_rq, pavr_s4_s51s52s53_retpc_ld, pavr_s4_s5_stall_rq,
           pavr_s4_s6_stall_rq, pavr_s4_ret_flush_s2_rq, pavr_s4_s5_skip_en, pavr_s4_s6_skip_en, pavr_s4_s5_branch_cond_sel,
           pavr_s4_s5_branch_en, pavr_s4_disable_int, pavr_stall_s5, pavr_s5_s6_aluoutlo8_rfwr_rq, pavr_s5_s61_aluouthi8_rfwr_rq,
           pavr_s5_s6_iof_rfwr_rq, pavr_s5_s6_dacu_rfwr_rq, pavr_s5_s6_pm_rfwr_rq, pavr_s5_s6_daculd_bpr0wr_rq, pavr_s5_s6_iof_rq,
           pavr_s5_calldec_spwr_rq, pavr_s5_retinc2_spwr_rq, pavr_s5_alu_out, pavr_s5_pchi8_dacurd_rq, pavr_s5_pclo8_dacuwr_rq,
           pavr_s5_s54_ret_pm_rq, pavr_s5_s51s52s53_retpc_ld, pavr_s5_s6_stall_rq, pavr_s5_ret_flush_s2_rq, next_pavr_s6_skip_rq,
           next_pavr_s6_branch_rq, pavr_s5_s6_skip_en, pavr_s5_disable_int, pavr_stall_s6, next_pavr_s61_skip_rq, pavr_s51_ret_flush_s2_rq,
           pavr_s51_pcmid8_dacuwr_rq, pavr_s51_calldec_spwr_rq, pavr_s51_disable_int, pavr_s51_retpchi8_ld, pavr_s51_pcmid8_dacurd_rq,
           pavr_s51_s54_ret_pm_rq, pavr_s52_ret_flush_s2_rq, pavr_s52_retpcmid8_ld, pavr_s52_s54_ret_pm_rq, pavr_s53_ret_flush_s2_rq,
           pavr_s53_s54_ret_pm_rq, pavr_s54_ret_flush_s2_rq, pavr_s4_nop_rq, pavr_nop_ack, pavr_s51_retpchi8_ld, pavr_dacu_do,
           pavr_s52_retpcmid8_ld, pavr_s53_retpclo8_ld, next_pavr_s1_pc, next_pavr_bpr0, next_pavr_bpr0_addr, next_pavr_bpr0_active,
           next_pavr_bpr1, next_pavr_bpr1_addr, next_pavr_bpr1_active, pavr_s5_dacudo_sel, next_pavr_s4_s5_k16_dacuwr_rq,
           pavr_s4_s5_k16_dacuwr_rq, next_pavr_s2_pmdo_valid, pavr_s6_s61_aluouthi8_rfwr_rq, pavr_stall_bpu,
           pavr_rf_do_shadow_active, pavr_rf_rd1_do_shadow, pavr_rf_rd2_do_shadow, next_pavr_s4_s6_iof_bpr0wr_rq,
           pavr_s4_s6_iof_bpr0wr_rq, pavr_s5_s6_iof_bpr0wr_rq, pavr_dacu_do_shadow_active, pavr_dacu_do_shadow,
           pavr_bpr13, pavr_bpr13_addr, pavr_bpr02_active, pavr_bpr03, pavr_bpr03_addr, pavr_bpr12_active,
           pavr_bpr20, pavr_bpr20_addr, pavr_bpr21, pavr_bpr21_addr, pavr_bpr22, pavr_bpr22_addr, pavr_bpr23,
           pavr_bpr23_addr, next_pavr_bpr2, next_pavr_bpr2_addr, next_pavr_bpr2_active, pavr_bpr20_active,
           pavr_bpr21_active, pavr_bpr22_active, pavr_zbpu, pavr_s4_pcinc, next_pavr_s4_pcinc,
           next_pavr_s4_s6_pmdo_bpr0wr_rq, pavr_s4_s6_pmdo_bpr0wr_rq, pavr_s5_s6_pmdo_bpr0wr_rq,
           next_pavr_s4_s5_elpmincrampz_zwr_rq, next_pavr_s4_s5_dacux_bpr12wr_rq, next_pavr_s4_s5_dacuy_bpr12wr_rq,
           next_pavr_s4_s5_dacuz_bpr12wr_rq, pavr_s4_s5_elpmincrampz_zwr_rq, pavr_s4_s5_dacux_bpr12wr_rq,
           pavr_s4_s5_dacuy_bpr12wr_rq, pavr_s4_s5_dacuz_bpr12wr_rq, next_pavr_s4_stall_rq, next_pavr_s3_instr,
           next_pavr_s3_pc, next_pavr_s2_pc)
   begin
      if pavr_res='1' then
         -- Asynchronous reset

         -- RF read port 1-related

         pavr_s5_op1 <= int_to_std_logic_vector(0, pavr_s5_op1'length);

         -- RF read port 2-related

         pavr_s5_op2 <= int_to_std_logic_vector(0, pavr_s5_op2'length);

         -- RF write port-related
         pavr_s4_s6_aluoutlo8_rfwr_rq  <= '0';
         pavr_s5_s6_aluoutlo8_rfwr_rq  <= '0';
            pavr_s6_aluoutlo8_rfwr_rq  <= '0';
         pavr_s4_s61_aluouthi8_rfwr_rq <= '0';
         pavr_s5_s61_aluouthi8_rfwr_rq <= '0';
         pavr_s6_s61_aluouthi8_rfwr_rq <= '0';
            pavr_s61_aluouthi8_rfwr_rq <= '0';
         pavr_s4_s6_iof_rfwr_rq        <= '0';
         pavr_s5_s6_iof_rfwr_rq        <= '0';
            pavr_s6_iof_rfwr_rq        <= '0';
         pavr_s4_s6_dacu_rfwr_rq       <= '0';
         pavr_s5_s6_dacu_rfwr_rq       <= '0';
            pavr_s6_dacu_rfwr_rq       <= '0';
         pavr_s4_s6_pm_rfwr_rq         <= '0';
         pavr_s5_s6_pm_rfwr_rq         <= '0';
            pavr_s6_pm_rfwr_rq         <= '0';

         pavr_s4_s6_rfwr_addr1         <= int_to_std_logic_vector(0, pavr_s4_s6_rfwr_addr1'length);
         pavr_s5_s6_rfwr_addr1         <= int_to_std_logic_vector(0, pavr_s5_s6_rfwr_addr1'length);
            pavr_s6_rfwr_addr1         <= int_to_std_logic_vector(0, pavr_s6_rfwr_addr1'length);
         pavr_s4_s61_rfwr_addr2        <= int_to_std_logic_vector(0, pavr_s4_s61_rfwr_addr2'length);
         pavr_s5_s61_rfwr_addr2        <= int_to_std_logic_vector(0, pavr_s5_s61_rfwr_addr2'length);
         pavr_s6_s61_rfwr_addr2        <= int_to_std_logic_vector(0, pavr_s6_s61_rfwr_addr2'length);
            pavr_s61_rfwr_addr2        <= int_to_std_logic_vector(0, pavr_s61_rfwr_addr2'length);

         -- Pointer registers-related
         pavr_s4_s5_ldstincrampx_xwr_rq   <= '0';
            pavr_s5_ldstincrampx_xwr_rq   <= '0';
         pavr_s4_s5_ldstdecrampx_xwr_rq   <= '0';
            pavr_s5_ldstdecrampx_xwr_rq   <= '0';

         pavr_s4_s5_ldstincrampy_ywr_rq   <= '0';
            pavr_s5_ldstincrampy_ywr_rq   <= '0';
         pavr_s4_s5_ldstdecrampy_ywr_rq   <= '0';
            pavr_s5_ldstdecrampy_ywr_rq   <= '0';

         pavr_s4_s5_ldstincrampz_zwr_rq   <= '0';
            pavr_s5_ldstincrampz_zwr_rq   <= '0';
         pavr_s4_s5_ldstdecrampz_zwr_rq   <= '0';
            pavr_s5_ldstdecrampz_zwr_rq   <= '0';
         pavr_s4_s5_elpmincrampz_zwr_rq   <= '0';
            pavr_s5_elpmincrampz_zwr_rq   <= '0';
         pavr_s4_s5_lpminc_zwr_rq         <= '0';
            pavr_s5_lpminc_zwr_rq         <= '0';

         -- BPU write, BPR0-related
         pavr_s4_s5_alu_bpr0wr_rq      <= '0';
            pavr_s5_alu_bpr0wr_rq      <= '0';
         pavr_s4_s6_iof_bpr0wr_rq      <= '0';
         pavr_s5_s6_iof_bpr0wr_rq      <= '0';
            pavr_s6_iof_bpr0wr_rq      <= '0';
         pavr_s4_s6_daculd_bpr0wr_rq   <= '0';
         pavr_s5_s6_daculd_bpr0wr_rq   <= '0';
            pavr_s6_daculd_bpr0wr_rq   <= '0';
         pavr_s4_s6_pmdo_bpr0wr_rq     <= '0';
         pavr_s5_s6_pmdo_bpr0wr_rq     <= '0';
            pavr_s6_pmdo_bpr0wr_rq     <= '0';

         pavr_bpr00        <= int_to_std_logic_vector(0, pavr_bpr00'length);
         pavr_bpr00_addr   <= int_to_std_logic_vector(0, pavr_bpr00_addr'length);
         pavr_bpr00_active <= '0';
         pavr_bpr01        <= int_to_std_logic_vector(0, pavr_bpr01'length);
         pavr_bpr01_addr   <= int_to_std_logic_vector(0, pavr_bpr01_addr'length);
         pavr_bpr01_active <= '0';
         pavr_bpr02        <= int_to_std_logic_vector(0, pavr_bpr02'length);
         pavr_bpr02_addr   <= int_to_std_logic_vector(0, pavr_bpr02_addr'length);
         pavr_bpr02_active <= '0';
         pavr_bpr03        <= int_to_std_logic_vector(0, pavr_bpr03'length);
         pavr_bpr03_addr   <= int_to_std_logic_vector(0, pavr_bpr03_addr'length);
         pavr_bpr03_active <= '0';

         -- BPU write, BPR1-related
         pavr_s4_s5_dacux_bpr12wr_rq   <= '0';
            pavr_s5_dacux_bpr12wr_rq   <= '0';
         pavr_s4_s5_dacuy_bpr12wr_rq   <= '0';
            pavr_s5_dacuy_bpr12wr_rq   <= '0';
         pavr_s4_s5_dacuz_bpr12wr_rq   <= '0';
            pavr_s5_dacuz_bpr12wr_rq   <= '0';
         pavr_s4_s5_alu_bpr1wr_rq      <= '0';
            pavr_s5_alu_bpr1wr_rq      <= '0';

         pavr_bpr10           <= int_to_std_logic_vector(0, pavr_bpr10'length);
         pavr_bpr10_addr      <= int_to_std_logic_vector(0, pavr_bpr10_addr'length);
         pavr_bpr10_active    <= '0';
         pavr_bpr11           <= int_to_std_logic_vector(0, pavr_bpr11'length);
         pavr_bpr11_addr      <= int_to_std_logic_vector(0, pavr_bpr11_addr'length);
         pavr_bpr11_active    <= '0';
         pavr_bpr12           <= int_to_std_logic_vector(0, pavr_bpr12'length);
         pavr_bpr12_addr      <= int_to_std_logic_vector(0, pavr_bpr12_addr'length);
         pavr_bpr12_active    <= '0';
         pavr_bpr13           <= int_to_std_logic_vector(0, pavr_bpr13'length);
         pavr_bpr13_addr      <= int_to_std_logic_vector(0, pavr_bpr13_addr'length);
         pavr_bpr13_active    <= '0';

         -- BPU write, BPR2-related

         pavr_bpr20           <= int_to_std_logic_vector(0, pavr_bpr20'length);
         pavr_bpr20_addr      <= int_to_std_logic_vector(0, pavr_bpr20_addr'length);
         pavr_bpr20_active    <= '0';
         pavr_bpr21           <= int_to_std_logic_vector(0, pavr_bpr21'length);
         pavr_bpr21_addr      <= int_to_std_logic_vector(0, pavr_bpr21_addr'length);
         pavr_bpr21_active    <= '0';
         pavr_bpr22           <= int_to_std_logic_vector(0, pavr_bpr22'length);
         pavr_bpr22_addr      <= int_to_std_logic_vector(0, pavr_bpr22_addr'length);
         pavr_bpr22_active    <= '0';
         pavr_bpr23           <= int_to_std_logic_vector(0, pavr_bpr23'length);
         pavr_bpr23_addr      <= int_to_std_logic_vector(0, pavr_bpr23_addr'length);
         pavr_bpr23_active    <= '0';

         -- IOF port-related
         pavr_s4_s5_iof_rq          <= '0';
            pavr_s5_iof_rq          <= '0';
         pavr_s4_s6_iof_rq          <= '0';
         pavr_s5_s6_iof_rq          <= '0';
            pavr_s6_iof_rq          <= '0';

         pavr_s4_s5_iof_opcode      <= int_to_std_logic_vector(0, pavr_s4_s5_iof_opcode'length);
            pavr_s5_iof_opcode      <= int_to_std_logic_vector(0, pavr_s5_iof_opcode'length);
         pavr_s4_s6_iof_opcode      <= int_to_std_logic_vector(0, pavr_s4_s6_iof_opcode'length);
         pavr_s5_s6_iof_opcode      <= int_to_std_logic_vector(0, pavr_s5_s6_iof_opcode'length);
            pavr_s6_iof_opcode      <= int_to_std_logic_vector(0, pavr_s6_iof_opcode'length);
         pavr_s4_s5s6_iof_addr      <= int_to_std_logic_vector(0, pavr_s4_s5s6_iof_addr'length);
              pavr_s5_iof_addr      <= int_to_std_logic_vector(0, pavr_s5_iof_addr'length);
              pavr_s6_iof_addr      <= int_to_std_logic_vector(0, pavr_s6_iof_addr'length);
         pavr_s4_s5s6_iof_bitaddr   <= int_to_std_logic_vector(0, pavr_s4_s5s6_iof_bitaddr'length);
              pavr_s5_iof_bitaddr   <= int_to_std_logic_vector(0, pavr_s5_iof_bitaddr'length);
              pavr_s6_iof_bitaddr   <= int_to_std_logic_vector(0, pavr_s6_iof_bitaddr'length);

         -- SREG-related
         pavr_s4_s5_alu_sregwr_rq         <= '0';
            pavr_s5_alu_sregwr_rq         <= '0';
         pavr_s4_s5_clriflag_sregwr_rq    <= '0';
            pavr_s5_clriflag_sregwr_rq    <= '0';
         pavr_s4_s5_setiflag_sregwr_rq    <= '0';
            pavr_s5_setiflag_sregwr_rq    <= '0';

         -- SP-related
         pavr_s4_s5_inc_spwr_rq              <= '0';
            pavr_s5_inc_spwr_rq              <= '0';
         pavr_s4_s5_dec_spwr_rq              <= '0';
            pavr_s5_dec_spwr_rq              <= '0';
         pavr_s4_s5s51s52_calldec_spwr_rq    <= '0';
            pavr_s5_calldec_spwr_rq          <= '0';
            pavr_s51_calldec_spwr_rq         <= '0';
            pavr_s52_calldec_spwr_rq         <= '0';
         pavr_s4_s5s51_retinc_spwr_rq        <= '0';
            pavr_s5_retinc2_spwr_rq          <= '0';
            pavr_s51_retinc_spwr_rq          <= '0';

         -- ALU-related
         pavr_s4_s5_alu_opcode         <= int_to_std_logic_vector(0, pavr_s4_s5_alu_opcode'length);
            pavr_s5_alu_opcode         <= int_to_std_logic_vector(0, pavr_s5_alu_opcode'length);
         pavr_s4_s5_alu_op1_hi8_sel    <= '0';
            pavr_s5_alu_op1_hi8_sel    <= '0';
         pavr_s4_s5_alu_op2_sel        <= int_to_std_logic_vector(0, pavr_s4_s5_alu_op2_sel'length);
            pavr_s5_alu_op2_sel        <= int_to_std_logic_vector(0, pavr_s5_alu_op2_sel'length);
         pavr_s4_s5_op1_addr           <= int_to_std_logic_vector(0, pavr_s4_s5_op1_addr'length);
            pavr_s5_op1_addr           <= int_to_std_logic_vector(0, pavr_s5_op1_addr'length);
         pavr_s4_s5_op2_addr           <= int_to_std_logic_vector(0, pavr_s4_s5_op2_addr'length);
            pavr_s5_op2_addr           <= int_to_std_logic_vector(0, pavr_s5_op2_addr'length);
         pavr_s4_s5_k8                 <= int_to_std_logic_vector(0, pavr_s4_s5_k8'length);
            pavr_s5_k8                 <= int_to_std_logic_vector(0, pavr_s5_k8'length);
         pavr_s6_alu_out               <= int_to_std_logic_vector(0, pavr_s6_alu_out'length);
         pavr_s61_alu_out_hi8          <= int_to_std_logic_vector(0, pavr_s61_alu_out_hi8'length);

         -- DACU setup-related
         pavr_s4_dacu_q       <= int_to_std_logic_vector(0, pavr_s4_dacu_q'length);
         pavr_s5_rf_dacu_q    <= int_to_std_logic_vector(0, pavr_s5_rf_dacu_q'length);
         pavr_s5_iof_dacu_q   <= int_to_std_logic_vector(0, pavr_s5_iof_dacu_q'length);
         pavr_s5_dm_dacu_q    <= int_to_std_logic_vector(0, pavr_s5_dm_dacu_q'length);
         pavr_s6_dacudo_sel   <= int_to_std_logic_vector(0, pavr_s6_dacudo_sel'length);
         pavr_s5_k16          <= int_to_std_logic_vector(0, pavr_s5_k16'length);

         -- DACU read-related
         pavr_s4_s5_x_dacurd_rq        <= '0';
            pavr_s5_x_dacurd_rq        <= '0';
         pavr_s4_s5_y_dacurd_rq        <= '0';
            pavr_s5_y_dacurd_rq        <= '0';
         pavr_s4_s5_z_dacurd_rq        <= '0';
            pavr_s5_z_dacurd_rq        <= '0';
         pavr_s4_s5_sp_dacurd_rq       <= '0';
            pavr_s5_sp_dacurd_rq       <= '0';
         pavr_s4_s5_k16_dacurd_rq      <= '0';
            pavr_s5_k16_dacurd_rq      <= '0';
         pavr_s4_s5s51s52_pc_dacurd_rq <= '0';
            pavr_s5_pchi8_dacurd_rq    <= '0';
            pavr_s51_pcmid8_dacurd_rq  <= '0';
            pavr_s52_pclo8_dacurd_rq   <= '0';

         -- DACU write-related
         pavr_s4_s5_sp_dacuwr_rq          <= '0';
            pavr_s5_sp_dacuwr_rq          <= '0';
         pavr_s4_s5_k16_dacuwr_rq         <= '0';
            pavr_s5_k16_dacuwr_rq         <= '0';
         pavr_s4_s5_x_dacuwr_rq           <= '0';
            pavr_s5_x_dacuwr_rq           <= '0';
         pavr_s4_s5_y_dacuwr_rq           <= '0';
            pavr_s5_y_dacuwr_rq           <= '0';
         pavr_s4_s5_z_dacuwr_rq           <= '0';
            pavr_s5_z_dacuwr_rq           <= '0';
         pavr_s4_s5s51s52_pc_dacuwr_rq    <= '0';
            pavr_s5_pclo8_dacuwr_rq       <= '0';
            pavr_s51_pcmid8_dacuwr_rq     <= '0';
            pavr_s52_pchi8_dacuwr_rq      <= '0';

         -- DM-related

         -- PM access-related
         pavr_s4_s5_lpm_pm_rq    <= '0';
            pavr_s5_lpm_pm_rq    <= '0';
         pavr_s4_s5_elpm_pm_rq   <= '0';
            pavr_s5_elpm_pm_rq   <= '0';
         pavr_s4_z_pm_rq         <= '0';
         pavr_s4_zeind_pm_rq     <= '0';
         pavr_s4_k22abs_pm_rq    <= '0';
         pavr_s4_k12rel_pm_rq    <= '0';
         pavr_s4_k22int_pm_rq    <= '0';
         pavr_s4_s54_ret_pm_rq   <= '0';
         pavr_s5_s54_ret_pm_rq   <= '0';
         pavr_s51_s54_ret_pm_rq  <= '0';
         pavr_s52_s54_ret_pm_rq  <= '0';
         pavr_s53_s54_ret_pm_rq  <= '0';
             pavr_s54_ret_pm_rq  <= '0';

         pavr_s4_k6                 <= int_to_std_logic_vector(0, pavr_s4_k6'length);
         pavr_s4_k12                <= int_to_std_logic_vector(0, pavr_s4_k12'length);
         pavr_s4_k22int             <= int_to_std_logic_vector(0, pavr_s4_k22int'length);
         pavr_s2_pc                 <= int_to_std_logic_vector(0, pavr_s2_pc'length);
         pavr_s3_pc                 <= int_to_std_logic_vector(0, pavr_s3_pc'length);
         pavr_s4_pc                 <= int_to_std_logic_vector(0, pavr_s4_pc'length);
         pavr_s5_pc                 <= int_to_std_logic_vector(0, pavr_s5_pc'length);
         pavr_s51_pc                <= int_to_std_logic_vector(0, pavr_s51_pc'length);
         pavr_s52_pc                <= int_to_std_logic_vector(0, pavr_s52_pc'length);
         pavr_s4_pcinc              <= '0';
         pavr_s4_s51s52s53_retpc_ld <= '0';
         pavr_s5_s51s52s53_retpc_ld <= '0';
            pavr_s51_retpchi8_ld    <= '0';
            pavr_s52_retpcmid8_ld   <= '0';
            pavr_s53_retpclo8_ld    <= '0';
         pavr_s52_retpchi8          <= int_to_std_logic_vector(0, pavr_s52_retpchi8'length);
         pavr_s53_retpcmid8         <= int_to_std_logic_vector(0, pavr_s53_retpcmid8'length);
         pavr_s54_retpclo8          <= int_to_std_logic_vector(0, pavr_s54_retpclo8'length);
         pavr_s1_pc                 <= int_to_std_logic_vector(0, pavr_s1_pc'length);              -- Note 1
         pavr_s2_pmdo_valid         <= '0';

         pavr_s6_zlsb               <= '0';

         -- SFU requests-related
            pavr_s4_stall_rq        <= '0';
         pavr_s4_s5_stall_rq        <= '0';
            pavr_s5_stall_rq        <= '0';
         pavr_s4_s6_stall_rq        <= '0';
         pavr_s5_s6_stall_rq        <= '0';
            pavr_s6_stall_rq        <= '0';
         pavr_s4_flush_s2_rq        <= '0';
         pavr_s4_ret_flush_s2_rq    <= '0';
         pavr_s5_ret_flush_s2_rq    <= '0';
         pavr_s51_ret_flush_s2_rq   <= '0';
         pavr_s52_ret_flush_s2_rq   <= '0';
         pavr_s53_ret_flush_s2_rq   <= '0';
         pavr_s54_ret_flush_s2_rq   <= '0';
         pavr_s55_ret_flush_s2_rq   <= '0';
         pavr_s6_skip_rq            <= '0';
         pavr_s61_skip_rq           <= '0';
         pavr_s6_branch_rq          <= '0';
         pavr_s4_nop_rq             <= '0';

         pavr_s4_s5_skip_cond_sel      <= int_to_std_logic_vector(0, pavr_s4_s5_skip_cond_sel'length);
            pavr_s5_skip_cond_sel      <= int_to_std_logic_vector(0, pavr_s5_skip_cond_sel'length);
         pavr_s4_s6_skip_cond_sel      <= '0';
         pavr_s5_s6_skip_cond_sel      <= '0';
            pavr_s6_skip_cond_sel      <= '0';
         pavr_s4_s5_skip_en            <= '0';
            pavr_s5_skip_en            <= '0';
         pavr_s4_s6_skip_en            <= '0';
         pavr_s5_s6_skip_en            <= '0';
            pavr_s6_skip_en            <= '0';
         pavr_s4_s5_skip_bitrf_sel     <= int_to_std_logic_vector(0, pavr_s4_s5_skip_bitrf_sel'length);
            pavr_s5_skip_bitrf_sel     <= int_to_std_logic_vector(0, pavr_s5_skip_bitrf_sel'length);
         pavr_s4_s6_skip_bitiof_sel    <= int_to_std_logic_vector(0, pavr_s4_s6_skip_bitiof_sel'length);
         pavr_s5_s6_skip_bitiof_sel    <= int_to_std_logic_vector(0, pavr_s5_s6_skip_bitiof_sel'length);
            pavr_s6_skip_bitiof_sel    <= int_to_std_logic_vector(0, pavr_s6_skip_bitiof_sel'length);

         pavr_s4_s5_k7_branch_offset   <= int_to_std_logic_vector(0, pavr_s4_s5_k7_branch_offset'length);
            pavr_s5_k7_branch_offset   <= int_to_std_logic_vector(0, pavr_s5_k7_branch_offset'length);
         pavr_s6_branch_pc             <= int_to_std_logic_vector(0, pavr_s6_branch_pc'length);
         pavr_s4_s5_branch_cond_sel    <= '0';
            pavr_s5_branch_cond_sel    <= '0';
         pavr_s4_s5_branch_en          <= '0';
            pavr_s5_branch_en          <= '0';
         pavr_s4_s5_branch_bitsreg_sel <= int_to_std_logic_vector(0, pavr_s4_s5_branch_bitsreg_sel'length);
            pavr_s5_branch_bitsreg_sel <= int_to_std_logic_vector(0, pavr_s5_branch_bitsreg_sel'length);

         -- Others
         pavr_nop_ack         <= '0';
         pavr_s3_instr        <= int_to_std_logic_vector(0, pavr_s3_instr'length);
         pavr_s4_instr32bits  <= '0';
         pavr_s4_disable_int  <= '0';
         pavr_s5_disable_int  <= '0';
         pavr_s51_disable_int <= '0';
         pavr_s52_disable_int <= '0';

      elsif pavr_clk'event and pavr_clk='1' then
         -- Load registers ----------------------------------------------------

         -- Stage s1 ----------------------------------------------------------
         pavr_s2_pmdo_valid   <= next_pavr_s2_pmdo_valid;
         pavr_s2_pc           <= next_pavr_s2_pc;

         -- Stage s2 ----------------------------------------------------------
         pavr_s3_instr  <= next_pavr_s3_instr;
         pavr_s3_pc     <= next_pavr_s3_pc;

         -- Stage s3 ----------------------------------------------------------
         if pavr_flush_s3='1' then
            -- RF read port 1-related

            -- RF read port 2-related

            -- RF write port-related
            pavr_s4_s6_aluoutlo8_rfwr_rq  <= '0';
            pavr_s4_s61_aluouthi8_rfwr_rq <= '0';
            pavr_s4_s6_iof_rfwr_rq        <= '0';
            pavr_s4_s6_dacu_rfwr_rq       <= '0';
            pavr_s4_s6_pm_rfwr_rq         <= '0';

            pavr_s4_s6_rfwr_addr1         <= int_to_std_logic_vector(0, pavr_s4_s6_rfwr_addr1'length);
            pavr_s4_s61_rfwr_addr2        <= int_to_std_logic_vector(0, pavr_s4_s61_rfwr_addr2'length);

            -- Pointer registers-related
            pavr_s4_s5_ldstincrampx_xwr_rq   <= '0';
            pavr_s4_s5_ldstdecrampx_xwr_rq   <= '0';

            pavr_s4_s5_ldstincrampy_ywr_rq   <= '0';
            pavr_s4_s5_ldstdecrampy_ywr_rq   <= '0';

            pavr_s4_s5_ldstincrampz_zwr_rq   <= '0';
            pavr_s4_s5_ldstdecrampz_zwr_rq   <= '0';
            pavr_s4_s5_elpmincrampz_zwr_rq   <= '0';
            pavr_s4_s5_lpminc_zwr_rq         <= '0';

            -- BPU write, BPR0-related
            pavr_s4_s5_alu_bpr0wr_rq      <= '0';
            pavr_s4_s6_iof_bpr0wr_rq      <= '0';
            pavr_s4_s6_daculd_bpr0wr_rq   <= '0';
            pavr_s4_s6_pmdo_bpr0wr_rq     <= '0';

            -- BPU write, BPR1-related
            pavr_s4_s5_dacux_bpr12wr_rq   <= '0';
            pavr_s4_s5_dacuy_bpr12wr_rq   <= '0';
            pavr_s4_s5_dacuz_bpr12wr_rq   <= '0';
            pavr_s4_s5_alu_bpr1wr_rq      <= '0';

            -- IOF port-related
            pavr_s4_s5_iof_rq          <= '0';
            pavr_s4_s6_iof_rq          <= '0';

            pavr_s4_s5_iof_opcode      <= int_to_std_logic_vector(0, pavr_s4_s5_iof_opcode'length);
            pavr_s4_s6_iof_opcode      <= int_to_std_logic_vector(0, pavr_s4_s6_iof_opcode'length);
            pavr_s4_s5s6_iof_addr      <= int_to_std_logic_vector(0, pavr_s4_s5s6_iof_addr'length);
            pavr_s4_s5s6_iof_bitaddr   <= int_to_std_logic_vector(0, pavr_s4_s5s6_iof_bitaddr'length);

            -- SREG-related
            pavr_s4_s5_alu_sregwr_rq         <= '0';
            pavr_s4_s5_clriflag_sregwr_rq    <= '0';
            pavr_s4_s5_setiflag_sregwr_rq    <= '0';

            -- SP-related
            pavr_s4_s5_inc_spwr_rq              <= '0';
            pavr_s4_s5_dec_spwr_rq              <= '0';
            pavr_s4_s5s51s52_calldec_spwr_rq    <= '0';
            pavr_s4_s5s51_retinc_spwr_rq        <= '0';

            -- ALU-related
            pavr_s4_s5_alu_opcode         <= int_to_std_logic_vector(0, pavr_s4_s5_alu_opcode'length);
            pavr_s4_s5_alu_op1_hi8_sel    <= '0';
            pavr_s4_s5_alu_op2_sel        <= int_to_std_logic_vector(0, pavr_s4_s5_alu_op2_sel'length);
            pavr_s4_s5_op1_addr           <= int_to_std_logic_vector(0, pavr_s4_s5_op1_addr'length);
            pavr_s4_s5_op2_addr           <= int_to_std_logic_vector(0, pavr_s4_s5_op2_addr'length);
            pavr_s4_s5_k8                 <= int_to_std_logic_vector(0, pavr_s4_s5_k8'length);

            -- DACU setup-related
            pavr_s4_dacu_q    <= int_to_std_logic_vector(0, pavr_s4_dacu_q'length);

            -- DACU read-related
            pavr_s4_s5_x_dacurd_rq        <= '0';
            pavr_s4_s5_y_dacurd_rq        <= '0';
            pavr_s4_s5_z_dacurd_rq        <= '0';
            pavr_s4_s5_sp_dacurd_rq       <= '0';
            pavr_s4_s5_k16_dacurd_rq      <= '0';
            pavr_s4_s5s51s52_pc_dacurd_rq <= '0';

            -- DACU write-related
            pavr_s4_s5_sp_dacuwr_rq          <= '0';
            pavr_s4_s5_k16_dacuwr_rq         <= '0';
            pavr_s4_s5_x_dacuwr_rq           <= '0';
            pavr_s4_s5_y_dacuwr_rq           <= '0';
            pavr_s4_s5_z_dacuwr_rq           <= '0';
            pavr_s4_s5s51s52_pc_dacuwr_rq    <= '0';

            -- DM-related

            -- PM access-related
            pavr_s4_s5_lpm_pm_rq    <= '0';
            pavr_s4_s5_elpm_pm_rq   <= '0';
            pavr_s4_z_pm_rq         <= '0';
            pavr_s4_zeind_pm_rq     <= '0';
            pavr_s4_k22abs_pm_rq    <= '0';
            pavr_s4_k12rel_pm_rq    <= '0';
            pavr_s4_k22int_pm_rq    <= '0';
            pavr_s4_s54_ret_pm_rq   <= '0';

            pavr_s4_k6                 <= int_to_std_logic_vector(0, pavr_s4_k6'length);
            pavr_s4_k12                <= int_to_std_logic_vector(0, pavr_s4_k12'length);
            pavr_s4_k22int             <= int_to_std_logic_vector(0, pavr_s4_k22int'length);
            --pavr_s4_pc                 <= int_to_std_logic_vector(0, pavr_s4_pc'length);  -- *** Comment this. The flush lines shouldn't interfere with PC temporary storage. Otherwise, 32 bit intructions are messed up.
            pavr_s4_pcinc              <= '0';
            pavr_s4_s51s52s53_retpc_ld <= '0';

            -- SFU requests-related
            pavr_s4_stall_rq           <= '0';
            pavr_s4_s5_stall_rq        <= '0';
            pavr_s4_s6_stall_rq        <= '0';
            pavr_s4_flush_s2_rq        <= '0';
            pavr_s4_ret_flush_s2_rq    <= '0';
            pavr_s4_nop_rq             <= '0';

            pavr_s4_s5_skip_cond_sel      <= int_to_std_logic_vector(0, pavr_s4_s5_skip_cond_sel'length);
            pavr_s4_s6_skip_cond_sel      <= '0';
            pavr_s4_s5_skip_en            <= '0';
            pavr_s4_s6_skip_en            <= '0';
            pavr_s4_s5_skip_bitrf_sel     <= int_to_std_logic_vector(0, pavr_s4_s5_skip_bitrf_sel'length);
            pavr_s4_s6_skip_bitiof_sel    <= int_to_std_logic_vector(0, pavr_s4_s6_skip_bitiof_sel'length);

            pavr_s4_s5_k7_branch_offset   <= int_to_std_logic_vector(0, pavr_s4_s5_k7_branch_offset'length);
            pavr_s4_s5_branch_cond_sel    <= '0';
            pavr_s4_s5_branch_en          <= '0';
            pavr_s4_s5_branch_bitsreg_sel <= int_to_std_logic_vector(0, pavr_s4_s5_branch_bitsreg_sel'length);

            -- Others
            pavr_s4_instr32bits  <= '0';
            pavr_s4_disable_int  <= '0';
         elsif pavr_stall_s3='0' then
            -- RF read port 1-related

            -- RF read port 2-related

            -- RF write port-related
            pavr_s4_s6_aluoutlo8_rfwr_rq  <= next_pavr_s4_s6_aluoutlo8_rfwr_rq;
            pavr_s4_s61_aluouthi8_rfwr_rq <= next_pavr_s4_s61_aluouthi8_rfwr_rq;
            pavr_s4_s6_iof_rfwr_rq        <= next_pavr_s4_s6_iof_rfwr_rq;
            pavr_s4_s6_dacu_rfwr_rq       <= next_pavr_s4_s6_dacu_rfwr_rq;
            pavr_s4_s6_pm_rfwr_rq         <= next_pavr_s4_s6_pm_rfwr_rq;

            pavr_s4_s6_rfwr_addr1         <= next_pavr_s4_s6_rfwr_addr1;
            pavr_s4_s61_rfwr_addr2        <= next_pavr_s4_s61_rfwr_addr2;

            -- Pointer registers-related
            pavr_s4_s5_ldstincrampx_xwr_rq   <= next_pavr_s4_s5_ldstincrampx_xwr_rq;
            pavr_s4_s5_ldstdecrampx_xwr_rq   <= next_pavr_s4_s5_ldstdecrampx_xwr_rq;

            pavr_s4_s5_ldstincrampy_ywr_rq   <= next_pavr_s4_s5_ldstincrampy_ywr_rq;
            pavr_s4_s5_ldstdecrampy_ywr_rq   <= next_pavr_s4_s5_ldstdecrampy_ywr_rq;

            pavr_s4_s5_ldstincrampz_zwr_rq   <= next_pavr_s4_s5_ldstincrampz_zwr_rq;
            pavr_s4_s5_ldstdecrampz_zwr_rq   <= next_pavr_s4_s5_ldstdecrampz_zwr_rq;
            pavr_s4_s5_elpmincrampz_zwr_rq   <= next_pavr_s4_s5_elpmincrampz_zwr_rq;
            pavr_s4_s5_lpminc_zwr_rq         <= next_pavr_s4_s5_lpminc_zwr_rq;

            -- BPU write, BPR0-related
            pavr_s4_s5_alu_bpr0wr_rq      <= next_pavr_s4_s5_alu_bpr0wr_rq;
            pavr_s4_s6_iof_bpr0wr_rq      <= next_pavr_s4_s6_iof_bpr0wr_rq;
            pavr_s4_s6_daculd_bpr0wr_rq   <= next_pavr_s4_s6_daculd_bpr0wr_rq;
            pavr_s4_s6_pmdo_bpr0wr_rq     <= next_pavr_s4_s6_pmdo_bpr0wr_rq;

            -- BPU write, BPR1-related
            pavr_s4_s5_dacux_bpr12wr_rq   <= next_pavr_s4_s5_dacux_bpr12wr_rq;
            pavr_s4_s5_dacuy_bpr12wr_rq   <= next_pavr_s4_s5_dacuy_bpr12wr_rq;
            pavr_s4_s5_dacuz_bpr12wr_rq   <= next_pavr_s4_s5_dacuz_bpr12wr_rq;
            pavr_s4_s5_alu_bpr1wr_rq      <= next_pavr_s4_s5_alu_bpr1wr_rq;

            -- IOF port-related
            pavr_s4_s5_iof_rq          <= next_pavr_s4_s5_iof_rq;
            pavr_s4_s6_iof_rq          <= next_pavr_s4_s6_iof_rq;

            pavr_s4_s5_iof_opcode      <= next_pavr_s4_s5_iof_opcode;
            pavr_s4_s6_iof_opcode      <= next_pavr_s4_s6_iof_opcode;
            pavr_s4_s5s6_iof_addr      <= next_pavr_s4_s5s6_iof_addr;
            pavr_s4_s5s6_iof_bitaddr   <= next_pavr_s4_s5s6_iof_bitaddr;

            -- SREG-related
            pavr_s4_s5_alu_sregwr_rq         <= next_pavr_s4_s5_alu_sregwr_rq;
            pavr_s4_s5_clriflag_sregwr_rq    <= next_pavr_s4_s5_clriflag_sregwr_rq;
            pavr_s4_s5_setiflag_sregwr_rq    <= next_pavr_s4_s5_setiflag_sregwr_rq;

            -- SP-related
            pavr_s4_s5_inc_spwr_rq              <= next_pavr_s4_s5_inc_spwr_rq;
            pavr_s4_s5_dec_spwr_rq              <= next_pavr_s4_s5_dec_spwr_rq;
            pavr_s4_s5s51s52_calldec_spwr_rq    <= next_pavr_s4_s5s51s52_calldec_spwr_rq;
            pavr_s4_s5s51_retinc_spwr_rq        <= next_pavr_s4_s5s51_retinc_spwr_rq;

            -- ALU-related
            pavr_s4_s5_alu_opcode         <= next_pavr_s4_s5_alu_opcode;
            pavr_s4_s5_alu_op1_hi8_sel    <= next_pavr_s4_s5_alu_op1_hi8_sel;
            pavr_s4_s5_alu_op2_sel        <= next_pavr_s4_s5_alu_op2_sel;
            pavr_s4_s5_op1_addr           <= pavr_s3_rfrd1_addr;              -- *** Attention here; unusual notation.
            pavr_s4_s5_op2_addr           <= pavr_s3_rfrd2_addr;              --
            pavr_s4_s5_k8                 <= next_pavr_s4_s5_k8;

            -- DACU setup-related
            pavr_s4_dacu_q    <= next_pavr_s4_dacu_q;

            -- DACU read-related
            pavr_s4_s5_x_dacurd_rq        <= next_pavr_s4_s5_x_dacurd_rq;
            pavr_s4_s5_y_dacurd_rq        <= next_pavr_s4_s5_y_dacurd_rq;
            pavr_s4_s5_z_dacurd_rq        <= next_pavr_s4_s5_z_dacurd_rq;
            pavr_s4_s5_sp_dacurd_rq       <= next_pavr_s4_s5_sp_dacurd_rq;
            pavr_s4_s5_k16_dacurd_rq      <= next_pavr_s4_s5_k16_dacurd_rq;
            pavr_s4_s5s51s52_pc_dacurd_rq <= next_pavr_s4_s5s51s52_pc_dacurd_rq;

            -- DACU write-related
            pavr_s4_s5_sp_dacuwr_rq          <= next_pavr_s4_s5_sp_dacuwr_rq;
            pavr_s4_s5_k16_dacuwr_rq         <= next_pavr_s4_s5_k16_dacuwr_rq;
            pavr_s4_s5_x_dacuwr_rq           <= next_pavr_s4_s5_x_dacuwr_rq;
            pavr_s4_s5_y_dacuwr_rq           <= next_pavr_s4_s5_y_dacuwr_rq;
            pavr_s4_s5_z_dacuwr_rq           <= next_pavr_s4_s5_z_dacuwr_rq;
            pavr_s4_s5s51s52_pc_dacuwr_rq    <= next_pavr_s4_s5s51s52_pc_dacuwr_rq;

            -- DM-related

            -- PM access-related
            pavr_s4_s5_lpm_pm_rq    <= next_pavr_s4_s5_lpm_pm_rq;
            pavr_s4_s5_elpm_pm_rq   <= next_pavr_s4_s5_elpm_pm_rq;
            pavr_s4_z_pm_rq         <= next_pavr_s4_z_pm_rq;
            pavr_s4_zeind_pm_rq     <= next_pavr_s4_zeind_pm_rq;
            pavr_s4_k22abs_pm_rq    <= next_pavr_s4_k22abs_pm_rq;
            pavr_s4_k12rel_pm_rq    <= next_pavr_s4_k12rel_pm_rq;
            pavr_s4_k22int_pm_rq    <= next_pavr_s4_k22int_pm_rq;
            pavr_s4_s54_ret_pm_rq   <= next_pavr_s4_s54_ret_pm_rq;

            pavr_s4_k6                 <= next_pavr_s4_k6;
            pavr_s4_k12                <= next_pavr_s4_k12;
            pavr_s4_k22int             <= next_pavr_s4_k22int;
            pavr_s4_pc                 <= pavr_s3_pc;
            pavr_s4_pcinc              <= next_pavr_s4_pcinc;
            pavr_s4_s51s52s53_retpc_ld <= next_pavr_s4_s51s52s53_retpc_ld;

            -- SFU requests-related
            pavr_s4_stall_rq           <= next_pavr_s4_stall_rq;
            pavr_s4_s5_stall_rq        <= next_pavr_s4_s5_stall_rq;
            pavr_s4_s6_stall_rq        <= next_pavr_s4_s6_stall_rq;
            pavr_s4_flush_s2_rq        <= next_pavr_s4_flush_s2_rq;
            pavr_s4_ret_flush_s2_rq    <= next_pavr_s4_ret_flush_s2_rq;
            pavr_s4_nop_rq             <= next_pavr_s4_nop_rq;

            pavr_s4_s5_skip_cond_sel      <= next_pavr_s4_s5_skip_cond_sel;
            pavr_s4_s6_skip_cond_sel      <= next_pavr_s4_s6_skip_cond_sel;
            pavr_s4_s5_skip_en            <= next_pavr_s4_s5_skip_en;
            pavr_s4_s6_skip_en            <= next_pavr_s4_s6_skip_en;
            pavr_s4_s5_skip_bitrf_sel     <= next_pavr_s4_s5_skip_bitrf_sel;
            pavr_s4_s6_skip_bitiof_sel    <= next_pavr_s4_s6_skip_bitiof_sel;
            pavr_s4_s5_k7_branch_offset   <= next_pavr_s4_s5_k7_branch_offset;
            pavr_s4_s5_branch_cond_sel    <= next_pavr_s4_s5_branch_cond_sel;
            pavr_s4_s5_branch_en          <= next_pavr_s4_s5_branch_en;
            pavr_s4_s5_branch_bitsreg_sel <= next_pavr_s4_s5_branch_bitsreg_sel;

            -- Others
            pavr_s4_instr32bits  <= next_pavr_s4_instr32bits;
            pavr_s4_disable_int  <= next_pavr_s4_disable_int;
         end if;

         -- Stage s4 ----------------------------------------------------------
         if pavr_flush_s4='1' then
            -- RF read port 1-related

            pavr_s5_op1 <= int_to_std_logic_vector(0, pavr_s5_op1'length);

            -- RF read port 2-related

            pavr_s5_op2 <= int_to_std_logic_vector(0, pavr_s5_op2'length);

            -- RF write port-related
            pavr_s5_s6_aluoutlo8_rfwr_rq  <= '0';
            pavr_s5_s61_aluouthi8_rfwr_rq <= '0';
            pavr_s5_s6_iof_rfwr_rq        <= '0';
            pavr_s5_s6_dacu_rfwr_rq       <= '0';
            pavr_s5_s6_pm_rfwr_rq         <= '0';

            pavr_s5_s6_rfwr_addr1         <= int_to_std_logic_vector(0, pavr_s5_s6_rfwr_addr1'length);
            pavr_s5_s61_rfwr_addr2        <= int_to_std_logic_vector(0, pavr_s5_s61_rfwr_addr2'length);

            -- Pointer registers-related
            pavr_s5_ldstincrampx_xwr_rq   <= '0';
            pavr_s5_ldstdecrampx_xwr_rq   <= '0';

            pavr_s5_ldstincrampy_ywr_rq   <= '0';
            pavr_s5_ldstdecrampy_ywr_rq   <= '0';

            pavr_s5_ldstincrampz_zwr_rq   <= '0';
            pavr_s5_ldstdecrampz_zwr_rq   <= '0';
            pavr_s5_elpmincrampz_zwr_rq   <= '0';
            pavr_s5_lpminc_zwr_rq         <= '0';

            -- BPU write, BPR0-related
            pavr_s5_alu_bpr0wr_rq         <= '0';
            pavr_s5_s6_iof_bpr0wr_rq      <= '0';
            pavr_s5_s6_daculd_bpr0wr_rq   <= '0';
            pavr_s5_s6_pmdo_bpr0wr_rq     <= '0';

            -- BPU write, BPR1-related
            pavr_s5_dacux_bpr12wr_rq   <= '0';
            pavr_s5_dacuy_bpr12wr_rq   <= '0';
            pavr_s5_dacuz_bpr12wr_rq   <= '0';
            pavr_s5_alu_bpr1wr_rq      <= '0';

            -- IOF port-related
            pavr_s5_iof_rq          <= '0';
            pavr_s5_s6_iof_rq       <= '0';

            pavr_s5_iof_opcode      <= int_to_std_logic_vector(0, pavr_s5_iof_opcode'length);
            pavr_s5_s6_iof_opcode   <= int_to_std_logic_vector(0, pavr_s5_s6_iof_opcode'length);
            pavr_s5_iof_addr        <= int_to_std_logic_vector(0, pavr_s5_iof_addr'length);
            pavr_s5_iof_bitaddr     <= int_to_std_logic_vector(0, pavr_s5_iof_bitaddr'length);

            -- SREG-related
            pavr_s5_alu_sregwr_rq         <= '0';
            pavr_s5_clriflag_sregwr_rq    <= '0';
            pavr_s5_setiflag_sregwr_rq    <= '0';

            -- SP-related
            pavr_s5_inc_spwr_rq        <= '0';
            pavr_s5_dec_spwr_rq        <= '0';
            pavr_s5_calldec_spwr_rq    <= '0';
            pavr_s5_retinc2_spwr_rq    <= '0';

            -- ALU-related
            pavr_s5_alu_opcode         <= int_to_std_logic_vector(0, pavr_s5_alu_opcode'length);
            pavr_s5_alu_op1_hi8_sel    <= '0';
            pavr_s5_alu_op2_sel        <= int_to_std_logic_vector(0, pavr_s5_alu_op2_sel'length);
            pavr_s5_op1_addr           <= int_to_std_logic_vector(0, pavr_s5_op1_addr'length);
            pavr_s5_op2_addr           <= int_to_std_logic_vector(0, pavr_s5_op2_addr'length);
            pavr_s5_k8                 <= int_to_std_logic_vector(0, pavr_s5_k8'length);

            -- DACU setup-related
            pavr_s5_rf_dacu_q    <= int_to_std_logic_vector(0, pavr_s5_rf_dacu_q'length);
            pavr_s5_iof_dacu_q   <= int_to_std_logic_vector(0, pavr_s5_iof_dacu_q'length);
            pavr_s5_dm_dacu_q    <= int_to_std_logic_vector(0, pavr_s5_dm_dacu_q'length);
            pavr_s5_k16          <= int_to_std_logic_vector(0, pavr_s5_k16'length);

            -- DACU read-related
            pavr_s5_x_dacurd_rq        <= '0';
            pavr_s5_y_dacurd_rq        <= '0';
            pavr_s5_z_dacurd_rq        <= '0';
            pavr_s5_sp_dacurd_rq       <= '0';
            pavr_s5_k16_dacurd_rq      <= '0';
            pavr_s5_pchi8_dacurd_rq    <= '0';

            -- DACU write-related
            pavr_s5_sp_dacuwr_rq       <= '0';
            pavr_s5_k16_dacuwr_rq      <= '0';
            pavr_s5_x_dacuwr_rq        <= '0';
            pavr_s5_y_dacuwr_rq        <= '0';
            pavr_s5_z_dacuwr_rq        <= '0';
            pavr_s5_pclo8_dacuwr_rq    <= '0';

            -- DM-related

            -- PM access-related
            pavr_s5_lpm_pm_rq       <= '0';
            pavr_s5_elpm_pm_rq      <= '0';
            pavr_s5_s54_ret_pm_rq   <= '0';

            --pavr_s5_pc              <= int_to_std_logic_vector(0, pavr_s5_pc'length);  -- *** Comment this. The flush lines shouldn't interfere with PC temporary storage. Otherwise, 32 bit intructions are messed up.
            pavr_s5_s51s52s53_retpc_ld <= '0';

            -- SFU requests-related
            pavr_s5_stall_rq           <= '0';
            pavr_s5_s6_stall_rq        <= '0';
            pavr_s5_ret_flush_s2_rq    <= '0';

            pavr_s5_skip_cond_sel      <= int_to_std_logic_vector(0, pavr_s5_skip_cond_sel'length);
            pavr_s5_s6_skip_cond_sel   <= '0';
            pavr_s5_skip_en            <= '0';
            pavr_s5_s6_skip_en         <= '0';
            pavr_s5_skip_bitrf_sel     <= int_to_std_logic_vector(0, pavr_s5_skip_bitrf_sel'length);
            pavr_s5_s6_skip_bitiof_sel <= int_to_std_logic_vector(0, pavr_s5_s6_skip_bitiof_sel'length);
            pavr_s5_k7_branch_offset   <= int_to_std_logic_vector(0, pavr_s5_k7_branch_offset'length);
            pavr_s5_branch_cond_sel    <= '0';
            pavr_s5_branch_en          <= '0';
            pavr_s5_branch_bitsreg_sel <= int_to_std_logic_vector(0, pavr_s5_branch_bitsreg_sel'length);

            -- Others
            pavr_s5_disable_int  <= '0';
         elsif pavr_stall_s4='0' then
            -- RF read port 1-related

            if pavr_rf_do_shadow_active='0' then
               pavr_s5_op1 <= pavr_rf_rd1_do;
            else
               pavr_s5_op1 <= pavr_rf_rd1_do_shadow;
            end if;

            -- RF read port 2-related

            if pavr_rf_do_shadow_active='0' then
               pavr_s5_op2 <= pavr_rf_rd2_do;
            else
               pavr_s5_op2 <= pavr_rf_rd2_do_shadow;
            end if;

            -- RF write port-related
            pavr_s5_s6_aluoutlo8_rfwr_rq  <= pavr_s4_s6_aluoutlo8_rfwr_rq;
            pavr_s5_s61_aluouthi8_rfwr_rq <= pavr_s4_s61_aluouthi8_rfwr_rq;
            pavr_s5_s6_iof_rfwr_rq        <= pavr_s4_s6_iof_rfwr_rq;
            pavr_s5_s6_dacu_rfwr_rq       <= pavr_s4_s6_dacu_rfwr_rq;
            pavr_s5_s6_pm_rfwr_rq         <= pavr_s4_s6_pm_rfwr_rq;

            pavr_s5_s6_rfwr_addr1         <= pavr_s4_s6_rfwr_addr1;
            pavr_s5_s61_rfwr_addr2        <= pavr_s4_s61_rfwr_addr2;

            -- Pointer registers-related
            pavr_s5_ldstincrampx_xwr_rq   <= pavr_s4_s5_ldstincrampx_xwr_rq;
            pavr_s5_ldstdecrampx_xwr_rq   <= pavr_s4_s5_ldstdecrampx_xwr_rq;

            pavr_s5_ldstincrampy_ywr_rq   <= pavr_s4_s5_ldstincrampy_ywr_rq;
            pavr_s5_ldstdecrampy_ywr_rq   <= pavr_s4_s5_ldstdecrampy_ywr_rq;

            pavr_s5_ldstincrampz_zwr_rq   <= pavr_s4_s5_ldstincrampz_zwr_rq;
            pavr_s5_ldstdecrampz_zwr_rq   <= pavr_s4_s5_ldstdecrampz_zwr_rq;
            pavr_s5_elpmincrampz_zwr_rq   <= pavr_s4_s5_elpmincrampz_zwr_rq;
            pavr_s5_lpminc_zwr_rq         <= pavr_s4_s5_lpminc_zwr_rq;

            -- BPU write, BPR0-related
            pavr_s5_alu_bpr0wr_rq         <= pavr_s4_s5_alu_bpr0wr_rq;
            pavr_s5_s6_iof_bpr0wr_rq      <= pavr_s4_s6_iof_bpr0wr_rq;
            pavr_s5_s6_daculd_bpr0wr_rq   <= pavr_s4_s6_daculd_bpr0wr_rq;
            pavr_s5_s6_pmdo_bpr0wr_rq     <= pavr_s4_s6_pmdo_bpr0wr_rq;

            -- BPU write, BPR1-related
            pavr_s5_dacux_bpr12wr_rq   <= pavr_s4_s5_dacux_bpr12wr_rq;
            pavr_s5_dacuy_bpr12wr_rq   <= pavr_s4_s5_dacuy_bpr12wr_rq;
            pavr_s5_dacuz_bpr12wr_rq   <= pavr_s4_s5_dacuz_bpr12wr_rq;
            pavr_s5_alu_bpr1wr_rq      <= pavr_s4_s5_alu_bpr1wr_rq;

            -- IOF port-related
            pavr_s5_iof_rq          <= pavr_s4_s5_iof_rq;
            pavr_s5_s6_iof_rq       <= pavr_s4_s6_iof_rq;

            pavr_s5_iof_opcode      <= pavr_s4_s5_iof_opcode;
            pavr_s5_s6_iof_opcode   <= pavr_s4_s6_iof_opcode;
            pavr_s5_iof_addr        <= pavr_s4_s5s6_iof_addr;
            pavr_s5_iof_bitaddr     <= pavr_s4_s5s6_iof_bitaddr;

            -- SREG-related
            pavr_s5_alu_sregwr_rq         <= pavr_s4_s5_alu_sregwr_rq;
            pavr_s5_clriflag_sregwr_rq    <= pavr_s4_s5_clriflag_sregwr_rq;
            pavr_s5_setiflag_sregwr_rq    <= pavr_s4_s5_setiflag_sregwr_rq;

            -- SP-related
            pavr_s5_inc_spwr_rq        <= pavr_s4_s5_inc_spwr_rq;
            pavr_s5_dec_spwr_rq        <= pavr_s4_s5_dec_spwr_rq;
            pavr_s5_calldec_spwr_rq    <= pavr_s4_s5s51s52_calldec_spwr_rq;
            pavr_s5_retinc2_spwr_rq    <= pavr_s4_s5s51_retinc_spwr_rq;

            -- ALU-related
            pavr_s5_alu_opcode         <= pavr_s4_s5_alu_opcode;
            pavr_s5_alu_op1_hi8_sel    <= pavr_s4_s5_alu_op1_hi8_sel;
            pavr_s5_alu_op2_sel        <= pavr_s4_s5_alu_op2_sel;
            pavr_s5_op1_addr           <= pavr_s4_s5_op1_addr;
            pavr_s5_op2_addr           <= pavr_s4_s5_op2_addr;
            pavr_s5_k8                 <= pavr_s4_s5_k8;

            -- DACU setup-related
            pavr_s5_rf_dacu_q    <= pavr_s4_dacu_q;
            pavr_s5_iof_dacu_q   <= pavr_s4_iof_dacu_q;
            pavr_s5_dm_dacu_q    <= pavr_s4_dm_dacu_q;
            if pavr_s4_instr32bits='1' then
               pavr_s5_k16       <= pavr_s3_instr;
            end if;

            -- DACU read-related
            pavr_s5_x_dacurd_rq        <= pavr_s4_s5_x_dacurd_rq;
            pavr_s5_y_dacurd_rq        <= pavr_s4_s5_y_dacurd_rq;
            pavr_s5_z_dacurd_rq        <= pavr_s4_s5_z_dacurd_rq;
            pavr_s5_sp_dacurd_rq       <= pavr_s4_s5_sp_dacurd_rq;
            pavr_s5_k16_dacurd_rq      <= pavr_s4_s5_k16_dacurd_rq;
            pavr_s5_pchi8_dacurd_rq    <= pavr_s4_s5s51s52_pc_dacurd_rq;

            -- DACU write-related
            pavr_s5_sp_dacuwr_rq       <= pavr_s4_s5_sp_dacuwr_rq;
            pavr_s5_k16_dacuwr_rq      <= pavr_s4_s5_k16_dacuwr_rq;
            pavr_s5_x_dacuwr_rq        <= pavr_s4_s5_x_dacuwr_rq;
            pavr_s5_y_dacuwr_rq        <= pavr_s4_s5_y_dacuwr_rq;
            pavr_s5_z_dacuwr_rq        <= pavr_s4_s5_z_dacuwr_rq;
            pavr_s5_pclo8_dacuwr_rq    <= pavr_s4_s5s51s52_pc_dacuwr_rq;

            -- DM-related

            -- PM access-related
            pavr_s5_lpm_pm_rq          <= pavr_s4_s5_lpm_pm_rq;
            pavr_s5_elpm_pm_rq         <= pavr_s4_s5_elpm_pm_rq;
            pavr_s5_s54_ret_pm_rq      <= pavr_s4_s54_ret_pm_rq;

            if pavr_s4_pcinc='1' then
               pavr_s5_pc  <= pavr_s4_pc + 1;
            else
               pavr_s5_pc  <= pavr_s4_pc;
            end if;
            pavr_s5_s51s52s53_retpc_ld <= pavr_s4_s51s52s53_retpc_ld;

            -- SFU requests-related
            pavr_s5_stall_rq           <= pavr_s4_s5_stall_rq;
            pavr_s5_s6_stall_rq        <= pavr_s4_s6_stall_rq;
            pavr_s5_ret_flush_s2_rq    <= pavr_s4_ret_flush_s2_rq;

            pavr_s5_skip_cond_sel      <= pavr_s4_s5_skip_cond_sel;
            pavr_s5_s6_skip_cond_sel   <= pavr_s4_s6_skip_cond_sel;
            pavr_s5_skip_en            <= pavr_s4_s5_skip_en;
            pavr_s5_s6_skip_en         <= pavr_s4_s6_skip_en;
            pavr_s5_skip_bitrf_sel     <= pavr_s4_s5_skip_bitrf_sel;
            pavr_s5_s6_skip_bitiof_sel <= pavr_s4_s6_skip_bitiof_sel;
            pavr_s5_k7_branch_offset   <= pavr_s4_s5_k7_branch_offset;
            pavr_s5_branch_cond_sel    <= pavr_s4_s5_branch_cond_sel;
            pavr_s5_branch_en          <= pavr_s4_s5_branch_en;
            pavr_s5_branch_bitsreg_sel <= pavr_s4_s5_branch_bitsreg_sel;

            -- Others
            pavr_s5_disable_int  <= pavr_s4_disable_int;
         end if;

         -- Stage s5 ----------------------------------------------------------
         if pavr_flush_s5='1' then
            -- RF read port 1-related

            -- RF read port 2-related

            -- RF write port-related
            pavr_s6_aluoutlo8_rfwr_rq        <= '0';
            pavr_s6_s61_aluouthi8_rfwr_rq    <= '0';
            pavr_s6_iof_rfwr_rq              <= '0';
            pavr_s6_dacu_rfwr_rq             <= '0';
            pavr_s6_pm_rfwr_rq               <= '0';

            pavr_s6_rfwr_addr1               <= int_to_std_logic_vector(0, pavr_s6_rfwr_addr1'length);
            pavr_s6_s61_rfwr_addr2           <= int_to_std_logic_vector(0, pavr_s6_s61_rfwr_addr2'length);

            -- Pointer registers-related

            -- BPU write, BPR0-related
            pavr_s6_iof_bpr0wr_rq      <= '0';
            pavr_s6_daculd_bpr0wr_rq   <= '0';
            pavr_s6_pmdo_bpr0wr_rq     <= '0';

            -- BPU write, BPR1-related

            -- IOF port-related
            pavr_s6_iof_rq       <= '0';

            pavr_s6_iof_opcode   <= int_to_std_logic_vector(0, pavr_s6_iof_opcode'length);
            pavr_s6_iof_addr     <= int_to_std_logic_vector(0, pavr_s6_iof_addr'length);
            pavr_s6_iof_bitaddr  <= int_to_std_logic_vector(0, pavr_s6_iof_bitaddr'length);

            -- SREG-related

            -- SP-related
            pavr_s51_calldec_spwr_rq   <= '0';
            pavr_s51_retinc_spwr_rq    <= '0';

            -- ALU-related
            pavr_s6_alu_out   <= int_to_std_logic_vector(0, pavr_s6_alu_out'length);

            -- DACU setup-related

            -- DACU read-related
            pavr_s51_pcmid8_dacurd_rq  <= '0';

            -- DACU write-related
            pavr_s51_pcmid8_dacuwr_rq  <= '0';

            -- DM-related

            -- PM access-related
            pavr_s51_s54_ret_pm_rq  <= '0';

            --pavr_s51_pc             <= int_to_std_logic_vector(0, pavr_s51_pc'length); -- *** Comment this. The flush lines shouldn't interfere with PC temporary storage. Otherwise, 32 bit intructions are messed up.
            pavr_s51_retpchi8_ld    <= '0';
            pavr_s6_zlsb            <= '0';

            -- SFU requests-related
            pavr_s6_stall_rq           <= '0';
            pavr_s51_ret_flush_s2_rq   <= '0';
            pavr_s6_skip_rq            <= '0';
            pavr_s6_branch_rq          <= '0';

            pavr_s6_skip_cond_sel      <= '0';
            pavr_s6_skip_en            <= '0';
            pavr_s6_skip_bitiof_sel    <= int_to_std_logic_vector(0, pavr_s6_skip_bitiof_sel'length);
            pavr_s6_branch_pc          <= int_to_std_logic_vector(0, pavr_s6_branch_pc'length);

            -- Others
            pavr_s51_disable_int <= '0';
         elsif pavr_stall_s5='0' then
            -- RF read port 1-related

            -- RF read port 2-related

            -- RF write port-related
            pavr_s6_aluoutlo8_rfwr_rq        <= pavr_s5_s6_aluoutlo8_rfwr_rq;
            pavr_s6_s61_aluouthi8_rfwr_rq    <= pavr_s5_s61_aluouthi8_rfwr_rq;
            pavr_s6_iof_rfwr_rq              <= pavr_s5_s6_iof_rfwr_rq;
            pavr_s6_dacu_rfwr_rq             <= pavr_s5_s6_dacu_rfwr_rq;
            pavr_s6_pm_rfwr_rq               <= pavr_s5_s6_pm_rfwr_rq;

            pavr_s6_rfwr_addr1               <= pavr_s5_s6_rfwr_addr1;
            pavr_s6_s61_rfwr_addr2           <= pavr_s5_s61_rfwr_addr2;

            -- Pointer registers-related

            -- BPU write, BPR0-related
            pavr_s6_iof_bpr0wr_rq      <= pavr_s5_s6_iof_bpr0wr_rq;
            pavr_s6_daculd_bpr0wr_rq   <= pavr_s5_s6_daculd_bpr0wr_rq;
            pavr_s6_pmdo_bpr0wr_rq     <= pavr_s5_s6_pmdo_bpr0wr_rq;

            -- BPU write, BPR1-related

            -- IOF port-related
            pavr_s6_iof_rq       <= pavr_s5_s6_iof_rq;

            pavr_s6_iof_opcode   <= pavr_s5_s6_iof_opcode;
            pavr_s6_iof_addr     <= pavr_s5_iof_addr;
            pavr_s6_iof_bitaddr  <= pavr_s5_iof_bitaddr;

            -- SREG-related

            -- SP-related
            pavr_s51_calldec_spwr_rq   <= pavr_s5_calldec_spwr_rq;
            pavr_s51_retinc_spwr_rq    <= pavr_s5_retinc2_spwr_rq;

            -- ALU-related
            pavr_s6_alu_out   <= pavr_s5_alu_out;

            -- DACU setup-related
            pavr_s51_pcmid8_dacurd_rq  <= pavr_s5_pchi8_dacurd_rq;

            -- DACU read-related

            -- DACU write-related
            pavr_s51_pcmid8_dacuwr_rq  <= pavr_s5_pclo8_dacuwr_rq;

            -- DM-related

            -- PM access-related
            pavr_s51_s54_ret_pm_rq  <= pavr_s5_s54_ret_pm_rq;

            pavr_s51_pc             <= pavr_s5_pc;
            pavr_s51_retpchi8_ld    <= pavr_s5_s51s52s53_retpc_ld;
            pavr_s6_zlsb            <= pavr_zbpu(0);

            -- SFU requests-related
            pavr_s6_stall_rq           <= pavr_s5_s6_stall_rq;
            pavr_s51_ret_flush_s2_rq   <= pavr_s5_ret_flush_s2_rq;
            pavr_s6_skip_rq            <= next_pavr_s6_skip_rq;
            pavr_s6_branch_rq          <= next_pavr_s6_branch_rq;

            pavr_s6_skip_cond_sel      <= pavr_s5_s6_skip_cond_sel;
            pavr_s6_skip_en            <= pavr_s5_s6_skip_en;
            pavr_s6_skip_bitiof_sel    <= pavr_s5_s6_skip_bitiof_sel;
            pavr_s6_branch_pc          <= sign_extend(pavr_s5_k7_branch_offset, 22) + pavr_s5_pc;

            -- Others
            pavr_s51_disable_int <= pavr_s5_disable_int;
         end if;

         -- Stage s6 ----------------------------------------------------------
         if pavr_flush_s6='1' then
            -- RF read port 1-related

            -- RF read port 2-related

            -- RF write port-related

            pavr_s61_rfwr_addr2  <= int_to_std_logic_vector(0, pavr_s61_rfwr_addr2'length);
            pavr_s61_aluouthi8_rfwr_rq <= '0';

            -- Pointer registers-related

            -- BPU write, BPR0-related

            -- BPU write, BPR1-related

            -- IOF port-related

            -- SREG-related

            -- SP-related

            -- ALU-related
            pavr_s61_alu_out_hi8    <= int_to_std_logic_vector(0, pavr_s61_alu_out_hi8'length);

            -- DACU setup-related

            -- DACU read-related

            -- DACU write-related

            -- DM-related

            -- PM access-related

            -- SFU requests-related
            pavr_s61_skip_rq <= '0';

            -- Others
         elsif pavr_stall_s6='0' then
            -- RF read port 1-related

            -- RF read port 2-related

            -- RF write port-related

            pavr_s61_rfwr_addr2        <= pavr_s6_s61_rfwr_addr2;
            pavr_s61_aluouthi8_rfwr_rq <= pavr_s6_s61_aluouthi8_rfwr_rq;

            -- Pointer registers-related

            -- BPU write, BPR0-related

            -- BPU write, BPR1-related

            -- IOF port-related

            -- SREG-related

            -- SP-related

            -- ALU-related
            pavr_s61_alu_out_hi8    <= pavr_s6_alu_out(15 downto 8);

            -- DACU setup-related

            -- DACU read-related

            -- DACU write-related

            -- DM-related

            -- PM access-related

            -- SFU requests-related
            pavr_s61_skip_rq <= next_pavr_s61_skip_rq;

            -- Others
         end if;

         -- Stage s51 ---------------------------------------------------------
         pavr_s52_ret_flush_s2_rq   <= pavr_s51_ret_flush_s2_rq;
         pavr_s52_pc                <= pavr_s51_pc;
         pavr_s52_pchi8_dacuwr_rq   <= pavr_s51_pcmid8_dacuwr_rq;
         pavr_s52_calldec_spwr_rq   <= pavr_s51_calldec_spwr_rq;
         pavr_s52_disable_int       <= pavr_s51_disable_int;
         pavr_s52_retpcmid8_ld      <= pavr_s51_retpchi8_ld;
         pavr_s52_pclo8_dacurd_rq   <= pavr_s51_pcmid8_dacurd_rq;
         pavr_s52_s54_ret_pm_rq     <= pavr_s51_s54_ret_pm_rq;

         -- Stage s52 ---------------------------------------------------------
         pavr_s53_ret_flush_s2_rq   <= pavr_s52_ret_flush_s2_rq;
         pavr_s53_retpclo8_ld       <= pavr_s52_retpcmid8_ld;
         pavr_s53_s54_ret_pm_rq     <= pavr_s52_s54_ret_pm_rq;

         -- Stage s53 ---------------------------------------------------------
         pavr_s54_ret_flush_s2_rq   <= pavr_s53_ret_flush_s2_rq;
         pavr_s54_ret_pm_rq         <= pavr_s53_s54_ret_pm_rq;

         -- Stage s54 ---------------------------------------------------------
         pavr_s55_ret_flush_s2_rq   <= pavr_s54_ret_flush_s2_rq;

         -- Others ------------------------------------------------------------
         if pavr_s4_nop_rq='1' and pavr_nop_ack='0' then
            pavr_nop_ack <= '1';
         else
            pavr_nop_ack <= '0';
         end if;

         if pavr_s51_retpchi8_ld='1' then
            if pavr_dacu_do_shadow_active='0' then
               pavr_s52_retpchi8  <= pavr_dacu_do;
            else
               pavr_s52_retpchi8  <= pavr_dacu_do_shadow;
            end if;
         end if;
         if pavr_s52_retpcmid8_ld='1' then
            if pavr_dacu_do_shadow_active='0' then
               pavr_s53_retpcmid8 <= pavr_dacu_do;
            else
               pavr_s53_retpcmid8 <= pavr_dacu_do_shadow;
            end if;
         end if;
         if pavr_s53_retpclo8_ld='1' then
            if pavr_dacu_do_shadow_active='0' then
               pavr_s54_retpclo8  <= pavr_dacu_do;
            else
               pavr_s54_retpclo8  <= pavr_dacu_do_shadow;
            end if;
         end if;

         pavr_s1_pc <= next_pavr_s1_pc;

         if pavr_stall_bpu='0' then
            pavr_bpr00        <= next_pavr_bpr0;
            pavr_bpr00_addr   <= next_pavr_bpr0_addr;
            pavr_bpr00_active <= next_pavr_bpr0_active;
            pavr_bpr01        <= pavr_bpr00;
            pavr_bpr01_addr   <= pavr_bpr00_addr;
            pavr_bpr01_active <= pavr_bpr00_active;
            pavr_bpr02        <= pavr_bpr01;
            pavr_bpr02_addr   <= pavr_bpr01_addr;
            pavr_bpr02_active <= pavr_bpr01_active;
            pavr_bpr03        <= pavr_bpr02;
            pavr_bpr03_addr   <= pavr_bpr02_addr;
            pavr_bpr03_active <= pavr_bpr02_active;

            pavr_bpr10           <= next_pavr_bpr1;
            pavr_bpr10_addr      <= next_pavr_bpr1_addr;
            pavr_bpr10_active    <= next_pavr_bpr1_active;
            pavr_bpr11           <= pavr_bpr10;
            pavr_bpr11_addr      <= pavr_bpr10_addr;
            pavr_bpr11_active    <= pavr_bpr10_active;
            pavr_bpr12           <= pavr_bpr11;
            pavr_bpr12_addr      <= pavr_bpr11_addr;
            pavr_bpr12_active    <= pavr_bpr11_active;
            pavr_bpr13           <= pavr_bpr12;
            pavr_bpr13_addr      <= pavr_bpr12_addr;
            pavr_bpr13_active    <= pavr_bpr12_active;

            pavr_bpr20           <= next_pavr_bpr2;
            pavr_bpr20_addr      <= next_pavr_bpr2_addr;
            pavr_bpr20_active    <= next_pavr_bpr2_active;
            pavr_bpr21           <= pavr_bpr20;
            pavr_bpr21_addr      <= pavr_bpr20_addr;
            pavr_bpr21_active    <= pavr_bpr20_active;
            pavr_bpr22           <= pavr_bpr21;
            pavr_bpr22_addr      <= pavr_bpr21_addr;
            pavr_bpr22_active    <= pavr_bpr21_active;
            pavr_bpr23           <= pavr_bpr22;
            pavr_bpr23_addr      <= pavr_bpr22_addr;
            pavr_bpr23_active    <= pavr_bpr22_active;
         end if;

         pavr_s6_dacudo_sel <= pavr_s5_dacudo_sel;

         if pavr_syncres='1' then
            -- Synchronous reset ----------------------------------------------

            -- RF read port 1-related

            pavr_s5_op1 <= int_to_std_logic_vector(0, pavr_s5_op1'length);

            -- RF read port 2-related

            pavr_s5_op2 <= int_to_std_logic_vector(0, pavr_s5_op2'length);

            -- RF write port-related
            pavr_s4_s6_aluoutlo8_rfwr_rq  <= '0';
            pavr_s5_s6_aluoutlo8_rfwr_rq  <= '0';
               pavr_s6_aluoutlo8_rfwr_rq  <= '0';
            pavr_s4_s61_aluouthi8_rfwr_rq <= '0';
            pavr_s5_s61_aluouthi8_rfwr_rq <= '0';
            pavr_s6_s61_aluouthi8_rfwr_rq <= '0';
               pavr_s61_aluouthi8_rfwr_rq <= '0';
            pavr_s4_s6_iof_rfwr_rq        <= '0';
            pavr_s5_s6_iof_rfwr_rq        <= '0';
               pavr_s6_iof_rfwr_rq        <= '0';
            pavr_s4_s6_dacu_rfwr_rq       <= '0';
            pavr_s5_s6_dacu_rfwr_rq       <= '0';
               pavr_s6_dacu_rfwr_rq       <= '0';
            pavr_s4_s6_pm_rfwr_rq         <= '0';
            pavr_s5_s6_pm_rfwr_rq         <= '0';
               pavr_s6_pm_rfwr_rq         <= '0';

            pavr_s4_s6_rfwr_addr1         <= int_to_std_logic_vector(0, pavr_s4_s6_rfwr_addr1'length);
            pavr_s5_s6_rfwr_addr1         <= int_to_std_logic_vector(0, pavr_s5_s6_rfwr_addr1'length);
               pavr_s6_rfwr_addr1         <= int_to_std_logic_vector(0, pavr_s6_rfwr_addr1'length);
            pavr_s4_s61_rfwr_addr2        <= int_to_std_logic_vector(0, pavr_s4_s61_rfwr_addr2'length);
            pavr_s5_s61_rfwr_addr2        <= int_to_std_logic_vector(0, pavr_s5_s61_rfwr_addr2'length);
            pavr_s6_s61_rfwr_addr2        <= int_to_std_logic_vector(0, pavr_s6_s61_rfwr_addr2'length);
               pavr_s61_rfwr_addr2        <= int_to_std_logic_vector(0, pavr_s61_rfwr_addr2'length);

            -- Pointer registers-related
            pavr_s4_s5_ldstincrampx_xwr_rq   <= '0';
               pavr_s5_ldstincrampx_xwr_rq   <= '0';
            pavr_s4_s5_ldstdecrampx_xwr_rq   <= '0';
               pavr_s5_ldstdecrampx_xwr_rq   <= '0';

            pavr_s4_s5_ldstincrampy_ywr_rq   <= '0';
               pavr_s5_ldstincrampy_ywr_rq   <= '0';
            pavr_s4_s5_ldstdecrampy_ywr_rq   <= '0';
               pavr_s5_ldstdecrampy_ywr_rq   <= '0';

            pavr_s4_s5_ldstincrampz_zwr_rq   <= '0';
               pavr_s5_ldstincrampz_zwr_rq   <= '0';
            pavr_s4_s5_ldstdecrampz_zwr_rq   <= '0';
               pavr_s5_ldstdecrampz_zwr_rq   <= '0';
            pavr_s4_s5_elpmincrampz_zwr_rq   <= '0';
               pavr_s5_elpmincrampz_zwr_rq   <= '0';
            pavr_s4_s5_lpminc_zwr_rq         <= '0';
               pavr_s5_lpminc_zwr_rq         <= '0';

            -- BPU write, BPR0-related
            pavr_s4_s5_alu_bpr0wr_rq      <= '0';
               pavr_s5_alu_bpr0wr_rq      <= '0';
            pavr_s4_s6_iof_bpr0wr_rq      <= '0';
            pavr_s5_s6_iof_bpr0wr_rq      <= '0';
               pavr_s6_iof_bpr0wr_rq      <= '0';
            pavr_s4_s6_daculd_bpr0wr_rq   <= '0';
            pavr_s5_s6_daculd_bpr0wr_rq   <= '0';
               pavr_s6_daculd_bpr0wr_rq   <= '0';
            pavr_s4_s6_pmdo_bpr0wr_rq     <= '0';
            pavr_s5_s6_pmdo_bpr0wr_rq     <= '0';
               pavr_s6_pmdo_bpr0wr_rq     <= '0';

            pavr_bpr00           <= int_to_std_logic_vector(0, pavr_bpr00'length);
            pavr_bpr00_addr      <= int_to_std_logic_vector(0, pavr_bpr00_addr'length);
            pavr_bpr00_active    <= '0';
            pavr_bpr01           <= int_to_std_logic_vector(0, pavr_bpr01'length);
            pavr_bpr01_addr      <= int_to_std_logic_vector(0, pavr_bpr01_addr'length);
            pavr_bpr01_active    <= '0';
            pavr_bpr02           <= int_to_std_logic_vector(0, pavr_bpr02'length);
            pavr_bpr02_addr      <= int_to_std_logic_vector(0, pavr_bpr02_addr'length);
            pavr_bpr02_active    <= '0';
            pavr_bpr03           <= int_to_std_logic_vector(0, pavr_bpr03'length);
            pavr_bpr03_addr      <= int_to_std_logic_vector(0, pavr_bpr03_addr'length);
            pavr_bpr03_active    <= '0';

            -- BPU write, BPR1-related
            pavr_s4_s5_dacux_bpr12wr_rq   <= '0';
               pavr_s5_dacux_bpr12wr_rq   <= '0';
            pavr_s4_s5_dacuy_bpr12wr_rq   <= '0';
               pavr_s5_dacuy_bpr12wr_rq   <= '0';
            pavr_s4_s5_dacuz_bpr12wr_rq   <= '0';
               pavr_s5_dacuz_bpr12wr_rq   <= '0';
            pavr_s4_s5_alu_bpr1wr_rq      <= '0';
               pavr_s5_alu_bpr1wr_rq      <= '0';

            pavr_bpr10           <= int_to_std_logic_vector(0, pavr_bpr10'length);
            pavr_bpr10_addr      <= int_to_std_logic_vector(0, pavr_bpr10_addr'length);
            pavr_bpr10_active    <= '0';
            pavr_bpr11           <= int_to_std_logic_vector(0, pavr_bpr11'length);
            pavr_bpr11_addr      <= int_to_std_logic_vector(0, pavr_bpr11_addr'length);
            pavr_bpr11_active    <= '0';
            pavr_bpr12           <= int_to_std_logic_vector(0, pavr_bpr12'length);
            pavr_bpr12_addr      <= int_to_std_logic_vector(0, pavr_bpr12_addr'length);
            pavr_bpr12_active    <= '0';
            pavr_bpr13           <= int_to_std_logic_vector(0, pavr_bpr13'length);
            pavr_bpr13_addr      <= int_to_std_logic_vector(0, pavr_bpr13_addr'length);
            pavr_bpr13_active    <= '0';

            -- BPU write, BPR2-related

            pavr_bpr20           <= int_to_std_logic_vector(0, pavr_bpr20'length);
            pavr_bpr20_addr      <= int_to_std_logic_vector(0, pavr_bpr20_addr'length);
            pavr_bpr20_active    <= '0';
            pavr_bpr21           <= int_to_std_logic_vector(0, pavr_bpr21'length);
            pavr_bpr21_addr      <= int_to_std_logic_vector(0, pavr_bpr21_addr'length);
            pavr_bpr21_active    <= '0';
            pavr_bpr22           <= int_to_std_logic_vector(0, pavr_bpr22'length);
            pavr_bpr22_addr      <= int_to_std_logic_vector(0, pavr_bpr22_addr'length);
            pavr_bpr22_active    <= '0';
            pavr_bpr23           <= int_to_std_logic_vector(0, pavr_bpr23'length);
            pavr_bpr23_addr      <= int_to_std_logic_vector(0, pavr_bpr23_addr'length);
            pavr_bpr23_active    <= '0';

            -- IOF port-related
            pavr_s4_s5_iof_rq          <= '0';
               pavr_s5_iof_rq          <= '0';
            pavr_s4_s6_iof_rq          <= '0';
            pavr_s5_s6_iof_rq          <= '0';
               pavr_s6_iof_rq          <= '0';

            pavr_s4_s5_iof_opcode      <= int_to_std_logic_vector(0, pavr_s4_s5_iof_opcode'length);
               pavr_s5_iof_opcode      <= int_to_std_logic_vector(0, pavr_s5_iof_opcode'length);
            pavr_s4_s6_iof_opcode      <= int_to_std_logic_vector(0, pavr_s4_s6_iof_opcode'length);
            pavr_s5_s6_iof_opcode      <= int_to_std_logic_vector(0, pavr_s5_s6_iof_opcode'length);
               pavr_s6_iof_opcode      <= int_to_std_logic_vector(0, pavr_s6_iof_opcode'length);
            pavr_s4_s5s6_iof_addr      <= int_to_std_logic_vector(0, pavr_s4_s5s6_iof_addr'length);
                 pavr_s5_iof_addr      <= int_to_std_logic_vector(0, pavr_s5_iof_addr'length);
                 pavr_s6_iof_addr      <= int_to_std_logic_vector(0, pavr_s6_iof_addr'length);
            pavr_s4_s5s6_iof_bitaddr   <= int_to_std_logic_vector(0, pavr_s4_s5s6_iof_bitaddr'length);
                 pavr_s5_iof_bitaddr   <= int_to_std_logic_vector(0, pavr_s5_iof_bitaddr'length);
                 pavr_s6_iof_bitaddr   <= int_to_std_logic_vector(0, pavr_s6_iof_bitaddr'length);

            -- SREG-related
            pavr_s4_s5_alu_sregwr_rq         <= '0';
               pavr_s5_alu_sregwr_rq         <= '0';
            pavr_s4_s5_clriflag_sregwr_rq    <= '0';
               pavr_s5_clriflag_sregwr_rq    <= '0';
            pavr_s4_s5_setiflag_sregwr_rq    <= '0';
               pavr_s5_setiflag_sregwr_rq    <= '0';

            -- SP-related
            pavr_s4_s5_inc_spwr_rq              <= '0';
               pavr_s5_inc_spwr_rq              <= '0';
            pavr_s4_s5_dec_spwr_rq              <= '0';
               pavr_s5_dec_spwr_rq              <= '0';
            pavr_s4_s5s51s52_calldec_spwr_rq    <= '0';
               pavr_s5_calldec_spwr_rq          <= '0';
               pavr_s51_calldec_spwr_rq         <= '0';
               pavr_s52_calldec_spwr_rq         <= '0';
            pavr_s4_s5s51_retinc_spwr_rq        <= '0';
               pavr_s5_retinc2_spwr_rq          <= '0';
               pavr_s51_retinc_spwr_rq          <= '0';

            -- ALU-related
            pavr_s4_s5_alu_opcode         <= int_to_std_logic_vector(0, pavr_s4_s5_alu_opcode'length);
               pavr_s5_alu_opcode         <= int_to_std_logic_vector(0, pavr_s5_alu_opcode'length);
            pavr_s4_s5_alu_op1_hi8_sel    <= '0';
               pavr_s5_alu_op1_hi8_sel    <= '0';
            pavr_s4_s5_alu_op2_sel        <= int_to_std_logic_vector(0, pavr_s4_s5_alu_op2_sel'length);
               pavr_s5_alu_op2_sel        <= int_to_std_logic_vector(0, pavr_s5_alu_op2_sel'length);
            pavr_s4_s5_op1_addr           <= int_to_std_logic_vector(0, pavr_s4_s5_op1_addr'length);
               pavr_s5_op1_addr           <= int_to_std_logic_vector(0, pavr_s5_op1_addr'length);
            pavr_s4_s5_op2_addr           <= int_to_std_logic_vector(0, pavr_s4_s5_op2_addr'length);
               pavr_s5_op2_addr           <= int_to_std_logic_vector(0, pavr_s5_op2_addr'length);
            pavr_s4_s5_k8                 <= int_to_std_logic_vector(0, pavr_s4_s5_k8'length);
               pavr_s5_k8                 <= int_to_std_logic_vector(0, pavr_s5_k8'length);
            pavr_s6_alu_out               <= int_to_std_logic_vector(0, pavr_s6_alu_out'length);
            pavr_s61_alu_out_hi8          <= int_to_std_logic_vector(0, pavr_s61_alu_out_hi8'length);

            -- DACU setup-related
            pavr_s4_dacu_q       <= int_to_std_logic_vector(0, pavr_s4_dacu_q'length);
            pavr_s5_rf_dacu_q    <= int_to_std_logic_vector(0, pavr_s5_rf_dacu_q'length);
            pavr_s5_iof_dacu_q   <= int_to_std_logic_vector(0, pavr_s5_iof_dacu_q'length);
            pavr_s5_dm_dacu_q    <= int_to_std_logic_vector(0, pavr_s5_dm_dacu_q'length);
            pavr_s6_dacudo_sel   <= int_to_std_logic_vector(0, pavr_s6_dacudo_sel'length);
            pavr_s5_k16          <= int_to_std_logic_vector(0, pavr_s5_k16'length);

            -- DACU read-related
            pavr_s4_s5_x_dacurd_rq        <= '0';
               pavr_s5_x_dacurd_rq        <= '0';
            pavr_s4_s5_y_dacurd_rq        <= '0';
               pavr_s5_y_dacurd_rq        <= '0';
            pavr_s4_s5_z_dacurd_rq        <= '0';
               pavr_s5_z_dacurd_rq        <= '0';
            pavr_s4_s5_sp_dacurd_rq       <= '0';
               pavr_s5_sp_dacurd_rq       <= '0';
            pavr_s4_s5_k16_dacurd_rq      <= '0';
               pavr_s5_k16_dacurd_rq      <= '0';
            pavr_s4_s5s51s52_pc_dacurd_rq <= '0';
               pavr_s5_pchi8_dacurd_rq    <= '0';
               pavr_s51_pcmid8_dacurd_rq  <= '0';
               pavr_s52_pclo8_dacurd_rq   <= '0';

            -- DACU write-related
            pavr_s4_s5_sp_dacuwr_rq          <= '0';
               pavr_s5_sp_dacuwr_rq          <= '0';
            pavr_s4_s5_x_dacuwr_rq           <= '0';
               pavr_s5_x_dacuwr_rq           <= '0';
            pavr_s4_s5_y_dacuwr_rq           <= '0';
               pavr_s5_y_dacuwr_rq           <= '0';
            pavr_s4_s5_z_dacuwr_rq           <= '0';
               pavr_s5_z_dacuwr_rq           <= '0';
            pavr_s4_s5s51s52_pc_dacuwr_rq    <= '0';
               pavr_s5_pclo8_dacuwr_rq       <= '0';
               pavr_s51_pcmid8_dacuwr_rq     <= '0';
               pavr_s52_pchi8_dacuwr_rq      <= '0';

            -- DM-related

            -- PM access-related
            pavr_s4_s5_lpm_pm_rq    <= '0';
               pavr_s5_lpm_pm_rq    <= '0';
            pavr_s4_s5_elpm_pm_rq   <= '0';
               pavr_s5_elpm_pm_rq   <= '0';
            pavr_s4_z_pm_rq         <= '0';
            pavr_s4_zeind_pm_rq     <= '0';
            pavr_s4_k22abs_pm_rq    <= '0';
            pavr_s4_k12rel_pm_rq    <= '0';
            pavr_s4_k22int_pm_rq    <= '0';
            pavr_s4_s54_ret_pm_rq   <= '0';
            pavr_s5_s54_ret_pm_rq   <= '0';
            pavr_s51_s54_ret_pm_rq  <= '0';
            pavr_s52_s54_ret_pm_rq  <= '0';
            pavr_s53_s54_ret_pm_rq  <= '0';
                pavr_s54_ret_pm_rq  <= '0';

            pavr_s4_k6                 <= int_to_std_logic_vector(0, pavr_s4_k6'length);
            pavr_s4_k12                <= int_to_std_logic_vector(0, pavr_s4_k12'length);
            pavr_s4_k22int             <= int_to_std_logic_vector(0, pavr_s4_k22int'length);
            pavr_s2_pc                 <= int_to_std_logic_vector(0, pavr_s2_pc'length);
            pavr_s3_pc                 <= int_to_std_logic_vector(0, pavr_s3_pc'length);
            pavr_s4_pc                 <= int_to_std_logic_vector(0, pavr_s4_pc'length);
            pavr_s5_pc                 <= int_to_std_logic_vector(0, pavr_s5_pc'length);
            pavr_s51_pc                <= int_to_std_logic_vector(0, pavr_s51_pc'length);
            pavr_s52_pc                <= int_to_std_logic_vector(0, pavr_s52_pc'length);
            pavr_s4_pcinc              <= '0';
            pavr_s4_s51s52s53_retpc_ld <= '0';
            pavr_s5_s51s52s53_retpc_ld <= '0';
               pavr_s51_retpchi8_ld    <= '0';
               pavr_s52_retpcmid8_ld   <= '0';
               pavr_s53_retpclo8_ld    <= '0';
            pavr_s52_retpchi8          <= int_to_std_logic_vector(0, pavr_s52_retpchi8'length);
            pavr_s53_retpcmid8         <= int_to_std_logic_vector(0, pavr_s53_retpcmid8'length);
            pavr_s54_retpclo8          <= int_to_std_logic_vector(0, pavr_s54_retpclo8'length);
            pavr_s1_pc                 <= int_to_std_logic_vector(0, pavr_s1_pc'length);              -- Note 1
            pavr_s2_pmdo_valid         <= '0';

            pavr_s6_zlsb               <= '0';

            -- SFU requests-related
               pavr_s4_stall_rq        <= '0';
            pavr_s4_s5_stall_rq        <= '0';
               pavr_s5_stall_rq        <= '0';
            pavr_s4_s6_stall_rq        <= '0';
            pavr_s5_s6_stall_rq        <= '0';
               pavr_s6_stall_rq        <= '0';
            pavr_s4_flush_s2_rq        <= '0';
            pavr_s4_ret_flush_s2_rq    <= '0';
            pavr_s5_ret_flush_s2_rq    <= '0';
            pavr_s51_ret_flush_s2_rq   <= '0';
            pavr_s52_ret_flush_s2_rq   <= '0';
            pavr_s53_ret_flush_s2_rq   <= '0';
            pavr_s54_ret_flush_s2_rq   <= '0';
            pavr_s55_ret_flush_s2_rq   <= '0';
            pavr_s6_skip_rq            <= '0';
            pavr_s61_skip_rq           <= '0';
            pavr_s6_branch_rq          <= '0';
            pavr_s4_nop_rq             <= '0';

            pavr_s4_s5_skip_cond_sel      <= int_to_std_logic_vector(0, pavr_s4_s5_skip_cond_sel'length);
               pavr_s5_skip_cond_sel      <= int_to_std_logic_vector(0, pavr_s5_skip_cond_sel'length);
            pavr_s4_s6_skip_cond_sel      <= '0';
            pavr_s5_s6_skip_cond_sel      <= '0';
               pavr_s6_skip_cond_sel      <= '0';
            pavr_s4_s5_skip_en            <= '0';
               pavr_s5_skip_en            <= '0';
            pavr_s4_s6_skip_en            <= '0';
            pavr_s5_s6_skip_en            <= '0';
               pavr_s6_skip_en            <= '0';
            pavr_s4_s5_skip_bitrf_sel     <= int_to_std_logic_vector(0, pavr_s4_s5_skip_bitrf_sel'length);
               pavr_s5_skip_bitrf_sel     <= int_to_std_logic_vector(0, pavr_s5_skip_bitrf_sel'length);
            pavr_s4_s6_skip_bitiof_sel    <= int_to_std_logic_vector(0, pavr_s4_s6_skip_bitiof_sel'length);
            pavr_s5_s6_skip_bitiof_sel    <= int_to_std_logic_vector(0, pavr_s5_s6_skip_bitiof_sel'length);
               pavr_s6_skip_bitiof_sel    <= int_to_std_logic_vector(0, pavr_s6_skip_bitiof_sel'length);

            pavr_s4_s5_k7_branch_offset   <= int_to_std_logic_vector(0, pavr_s4_s5_k7_branch_offset'length);
               pavr_s5_k7_branch_offset   <= int_to_std_logic_vector(0, pavr_s5_k7_branch_offset'length);
            pavr_s6_branch_pc             <= int_to_std_logic_vector(0, pavr_s6_branch_pc'length);
            pavr_s4_s5_branch_cond_sel    <= '0';
               pavr_s5_branch_cond_sel    <= '0';
            pavr_s4_s5_branch_en          <= '0';
               pavr_s5_branch_en          <= '0';
            pavr_s4_s5_branch_bitsreg_sel <= int_to_std_logic_vector(0, pavr_s4_s5_branch_bitsreg_sel'length);
               pavr_s5_branch_bitsreg_sel <= int_to_std_logic_vector(0, pavr_s5_branch_bitsreg_sel'length);

            -- Others
            pavr_nop_ack         <= '0';
            pavr_s3_instr        <= int_to_std_logic_vector(0, pavr_s3_instr'length);
            pavr_s4_instr32bits  <= '0';
            pavr_s4_disable_int  <= '0';
            pavr_s5_disable_int  <= '0';
            pavr_s51_disable_int <= '0';
            pavr_s52_disable_int <= '0';

         end if;
      end if;
   end process control_sync;








   -- Intruction decoder ------------------------------------------------------
   instr_decoder:
   process(pavr_s3_rfrd1_addr,
           pavr_s3_rfrd2_addr,
           next_pavr_s4_s6_rfwr_addr1,
           next_pavr_s4_s61_rfwr_addr2,
           next_pavr_s4_s5_iof_opcode,
           next_pavr_s4_s6_iof_opcode,
           next_pavr_s4_s5s6_iof_addr,
           next_pavr_s4_s5s6_iof_bitaddr,
           next_pavr_s4_s5_alu_opcode,
           next_pavr_s4_s5_alu_op2_sel,
           next_pavr_s4_s5_k8,
           next_pavr_s4_dacu_q,
           next_pavr_s4_k6,
           next_pavr_s4_k12,
           next_pavr_s4_k22int,
           next_pavr_s4_s5_skip_cond_sel,
           next_pavr_s4_s5_skip_bitrf_sel,
           next_pavr_s4_s6_skip_bitiof_sel,
           next_pavr_s4_s5_k7_branch_offset,
           next_pavr_s4_s5_branch_bitsreg_sel,
           pavr_int_rq,
           pavr_stall_s3,
           pavr_flush_s3,
           pavr_s4_instr32bits,
           pavr_s3_instr,
           next_pavr_s4_dacu_q,
           pavr_int_vec
          )
      variable tmp2_1, tmp2_2, tmp2_3, tmp2_4, tmp2_5, tmp2_6, tmp2_7, tmp2_8, tmp2_9, tmp2_a, tmp2_b, tmp2_c: std_logic_vector(1 downto 0);
      variable tmp3_1, tmp3_2: std_logic_vector(2 downto 0);
      variable tmp4_1, tmp4_2, tmp4_3, tmp4_4, tmp4_5 : std_logic_vector(3 downto 0);
   begin
      -- Default wires to benign values.

      -- RF read port 1-related
      pavr_s3_rfrd1_rq    <= '0';
      pavr_s3_rfrd1_addr  <= int_to_std_logic_vector(0, pavr_s3_rfrd1_addr'length);

      -- RF read port 2-related
      pavr_s3_rfrd2_rq    <= '0';
      pavr_s3_rfrd2_addr  <= int_to_std_logic_vector(0, pavr_s3_rfrd2_addr'length);

      -- RF write port-related
      next_pavr_s4_s6_aluoutlo8_rfwr_rq   <= '0';
      next_pavr_s4_s61_aluouthi8_rfwr_rq  <= '0';
      next_pavr_s4_s6_iof_rfwr_rq         <= '0';
      next_pavr_s4_s6_dacu_rfwr_rq        <= '0';
      next_pavr_s4_s6_pm_rfwr_rq          <= '0';

      next_pavr_s4_s6_rfwr_addr1          <= int_to_std_logic_vector(0, next_pavr_s4_s6_rfwr_addr1'length);
      next_pavr_s4_s61_rfwr_addr2         <= int_to_std_logic_vector(0, next_pavr_s4_s61_rfwr_addr2'length);

      -- Pointer registers-related
      next_pavr_s4_s5_ldstincrampx_xwr_rq    <= '0';
      next_pavr_s4_s5_ldstdecrampx_xwr_rq    <= '0';

      next_pavr_s4_s5_ldstincrampy_ywr_rq    <= '0';
      next_pavr_s4_s5_ldstdecrampy_ywr_rq    <= '0';

      next_pavr_s4_s5_ldstincrampz_zwr_rq    <= '0';
      next_pavr_s4_s5_ldstdecrampz_zwr_rq    <= '0';
      next_pavr_s4_s5_elpmincrampz_zwr_rq    <= '0';
      next_pavr_s4_s5_lpminc_zwr_rq          <= '0';

      -- BPU write, BPR0-related
      next_pavr_s4_s5_alu_bpr0wr_rq    <= '0';
      next_pavr_s4_s6_iof_bpr0wr_rq    <= '0';
      next_pavr_s4_s6_daculd_bpr0wr_rq <= '0';
      next_pavr_s4_s6_pmdo_bpr0wr_rq   <= '0';

      -- BPU write, BPR1-related
      next_pavr_s4_s5_dacux_bpr12wr_rq <= '0';
      next_pavr_s4_s5_dacuy_bpr12wr_rq <= '0';
      next_pavr_s4_s5_dacuz_bpr12wr_rq <= '0';
      next_pavr_s4_s5_alu_bpr1wr_rq    <= '0';

      -- IOF port-related
      next_pavr_s4_s5_iof_rq           <= '0';
      next_pavr_s4_s6_iof_rq           <= '0';

      next_pavr_s4_s5_iof_opcode       <= int_to_std_logic_vector(0, next_pavr_s4_s5_iof_opcode'length);
      next_pavr_s4_s6_iof_opcode       <= int_to_std_logic_vector(0, next_pavr_s4_s6_iof_opcode'length);
      next_pavr_s4_s5s6_iof_addr       <= int_to_std_logic_vector(0, next_pavr_s4_s5s6_iof_addr'length);
      next_pavr_s4_s5s6_iof_bitaddr    <= int_to_std_logic_vector(0, next_pavr_s4_s5s6_iof_bitaddr'length);

      -- SREG-related
      next_pavr_s4_s5_alu_sregwr_rq       <= '0';
      next_pavr_s4_s5_clriflag_sregwr_rq  <= '0';
      next_pavr_s4_s5_setiflag_sregwr_rq  <= '0';

      -- SP-related
      next_pavr_s4_s5_inc_spwr_rq            <= '0';
      next_pavr_s4_s5_dec_spwr_rq            <= '0';
      next_pavr_s4_s5s51s52_calldec_spwr_rq  <= '0';
      next_pavr_s4_s5s51_retinc_spwr_rq      <= '0';

      -- ALU-related
      next_pavr_s4_s5_alu_opcode       <= int_to_std_logic_vector(0, next_pavr_s4_s5_alu_opcode'length);
      next_pavr_s4_s5_alu_op1_hi8_sel  <= '0';
      next_pavr_s4_s5_alu_op2_sel      <= int_to_std_logic_vector(0, next_pavr_s4_s5_alu_op2_sel'length);
      next_pavr_s4_s5_k8               <= int_to_std_logic_vector(0, next_pavr_s4_s5_k8'length);

      -- DACU setup-related
      next_pavr_s4_dacu_q  <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);

      -- DACU read-related
      next_pavr_s4_s5_x_dacurd_rq         <= '0';
      next_pavr_s4_s5_y_dacurd_rq         <= '0';
      next_pavr_s4_s5_z_dacurd_rq         <= '0';
      next_pavr_s4_s5_sp_dacurd_rq        <= '0';
      next_pavr_s4_s5_k16_dacurd_rq       <= '0';
      next_pavr_s4_s5s51s52_pc_dacurd_rq  <= '0';

      -- DACU write-related
      next_pavr_s4_s5_sp_dacuwr_rq        <= '0';
      next_pavr_s4_s5_k16_dacuwr_rq       <= '0';
      next_pavr_s4_s5_x_dacuwr_rq         <= '0';
      next_pavr_s4_s5_y_dacuwr_rq         <= '0';
      next_pavr_s4_s5_z_dacuwr_rq         <= '0';
      next_pavr_s4_s5s51s52_pc_dacuwr_rq  <= '0';

      -- DM-related

      -- PM access-related
      next_pavr_s4_s5_lpm_pm_rq     <= '0';
      next_pavr_s4_s5_elpm_pm_rq    <= '0';
      next_pavr_s4_z_pm_rq          <= '0';
      next_pavr_s4_zeind_pm_rq      <= '0';
      next_pavr_s4_k22abs_pm_rq     <= '0';
      next_pavr_s4_k12rel_pm_rq     <= '0';
      next_pavr_s4_k22int_pm_rq     <= '0';
      next_pavr_s4_s54_ret_pm_rq    <= '0';

      next_pavr_s4_k6                  <= int_to_std_logic_vector(0, next_pavr_s4_k6'length);
      next_pavr_s4_k12                 <= int_to_std_logic_vector(0, next_pavr_s4_k12'length);
      next_pavr_s4_k22int              <= int_to_std_logic_vector(0, next_pavr_s4_k22int'length);
      next_pavr_s4_s51s52s53_retpc_ld  <= '0';
      next_pavr_s4_pcinc               <= '0';

      -- SFU requests-related
      pavr_s3_stall_rq                 <= '0';
      next_pavr_s4_stall_rq            <= '0';
      next_pavr_s4_s5_stall_rq         <= '0';
      next_pavr_s4_s6_stall_rq         <= '0';
      pavr_s3_flush_s2_rq              <= '0';
      next_pavr_s4_flush_s2_rq         <= '0';
      next_pavr_s4_ret_flush_s2_rq     <= '0';
      next_pavr_s4_nop_rq              <= '0';

      next_pavr_s4_s5_skip_cond_sel       <= int_to_std_logic_vector(0, next_pavr_s4_s5_skip_cond_sel'length);
      next_pavr_s4_s6_skip_cond_sel       <= '0';
      next_pavr_s4_s5_skip_en             <= '0';
      next_pavr_s4_s6_skip_en             <= '0';
      next_pavr_s4_s5_skip_bitrf_sel      <= int_to_std_logic_vector(0, next_pavr_s4_s5_skip_bitrf_sel'length);
      next_pavr_s4_s6_skip_bitiof_sel     <= int_to_std_logic_vector(0, next_pavr_s4_s6_skip_bitiof_sel'length);

      next_pavr_s4_s5_k7_branch_offset    <= int_to_std_logic_vector(0, next_pavr_s4_s5_k7_branch_offset'length);
      next_pavr_s4_s5_branch_cond_sel     <= '0';
      next_pavr_s4_s5_branch_en           <= '0';
      next_pavr_s4_s5_branch_bitsreg_sel  <= int_to_std_logic_vector(0, next_pavr_s4_s5_branch_bitsreg_sel'length);

      -- Others
      next_pavr_s4_disable_int   <= '0';
      next_pavr_s4_instr32bits   <= '0';

      tmp2_1 := int_to_std_logic_vector(0, tmp2_1'length);
      tmp2_2 := int_to_std_logic_vector(0, tmp2_2'length);
      tmp2_3 := int_to_std_logic_vector(0, tmp2_3'length);
      tmp2_4 := int_to_std_logic_vector(0, tmp2_4'length);
      tmp2_5 := int_to_std_logic_vector(0, tmp2_5'length);
      tmp2_6 := int_to_std_logic_vector(0, tmp2_6'length);
      tmp2_7 := int_to_std_logic_vector(0, tmp2_7'length);
      tmp2_8 := int_to_std_logic_vector(0, tmp2_8'length);
      tmp2_9 := int_to_std_logic_vector(0, tmp2_9'length);
      tmp2_a := int_to_std_logic_vector(0, tmp2_a'length);
      tmp2_b := int_to_std_logic_vector(0, tmp2_b'length);
      tmp2_c := int_to_std_logic_vector(0, tmp2_c'length);

      tmp3_1 := int_to_std_logic_vector(0, tmp3_1'length);
      tmp3_2 := int_to_std_logic_vector(0, tmp3_2'length);

      tmp4_1 := int_to_std_logic_vector(0, tmp4_1'length);
      tmp4_2 := int_to_std_logic_vector(0, tmp4_2'length);
      tmp4_3 := int_to_std_logic_vector(0, tmp4_3'length);
      tmp4_4 := int_to_std_logic_vector(0, tmp4_4'length);
      tmp4_5 := int_to_std_logic_vector(0, tmp4_5'length);

      -- Pipeline stage s3
      -- Instruction decoder
      if pavr_int_rq='0' then
         if pavr_stall_s3='0' and pavr_flush_s3='0' and pavr_s4_instr32bits='0' then
            tmp3_1 := pavr_s3_instr(15 downto 14)&pavr_s3_instr(12);
            case tmp3_1 is
               when "000" =>
                  if pavr_s3_instr(13)='0' then
                     tmp2_1 := pavr_s3_instr(11 downto 10);
                     case tmp2_1 is
                        when "00" =>
                           tmp2_2 := pavr_s3_instr(9 downto 8);
                           case tmp2_2 is
                              when "01" =>
                                 -- MOVW Rd+1:Rd, Rr+1:Rr (Move word)
                                 pavr_s3_rfrd1_rq <= '1';                                        -- Request Register File (RF) read port 1 access, for reading operand 1.
                                 pavr_s3_rfrd2_rq <= '1';                                        -- Request RF read port 2 access, for reading operand 2.
                                 pavr_s3_rfrd1_addr <= pavr_s3_instr(3 downto 0)&'0';               -- Address of operand 1 in the RF.
                                 pavr_s3_rfrd2_addr <= pavr_s3_instr(3 downto 0)&'1';               -- Address of operand 2 in the RF.
                                 next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_op1, next_pavr_s4_s5_alu_opcode'length); -- ALU opcode
                                 next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_op1bpu; -- Select the high byte of operand 1 from RF - read port 1, via Bypass Unit.
                                 next_pavr_s4_s5_alu_bpr0wr_rq <= '1';                           -- Request Bypass Unit, bypass register 1 (bpr1) write access.
                                 next_pavr_s4_s5_alu_bpr1wr_rq <= '1';                           -- Request Bypass Unit, bypass register 2 (bpr2) write access.
                                 next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(7 downto 4)&'0';    -- Write-back address. 2 successive writes are needed here.
                                 next_pavr_s4_s61_rfwr_addr2 <= pavr_s3_instr(7 downto 4)&'1';
                                 next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';                       -- Request RF write port access for writing the result.
                                 next_pavr_s4_s61_aluouthi8_rfwr_rq <= '1';
                                 next_pavr_s4_s6_stall_rq <= '1';                                -- In s6, request pipeline stall and s5 flush, to `steal' RF write access from next instruction.
                              when "10" =>
                                 -- MULS Rd, Rr (Multiply unsigned)
                                 pavr_s3_rfrd1_rq <= '1';
                                 pavr_s3_rfrd2_rq <= '1';
                                 pavr_s3_rfrd1_addr <= '1'&pavr_s3_instr(7 downto 4);     -- Only registers 16...31 can be used.
                                 pavr_s3_rfrd2_addr <= '1'&pavr_s3_instr(3 downto 0);
                                 next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_muls8, next_pavr_s4_s5_alu_opcode'length);
                                 next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                 next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                                 next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                 next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                 next_pavr_s4_s5_alu_bpr1wr_rq <= '1';
                                 next_pavr_s4_s6_rfwr_addr1 <= "00000";                -- Write result in R1:R0.
                                 next_pavr_s4_s61_rfwr_addr2 <= "00001";
                                 next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                 next_pavr_s4_s61_aluouthi8_rfwr_rq <= '1';
                                 next_pavr_s4_s6_stall_rq <= '1';
                              when "11" =>
                                 tmp2_3 := pavr_s3_instr(7)&pavr_s3_instr(3);
                                 case tmp2_3 is
                                    when "00" =>
                                       -- MULSU Rd, Rr (Multiply signed with unsigned)
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd2_rq <= '1';
                                       pavr_s3_rfrd1_addr <= "10"&pavr_s3_instr(6 downto 4);
                                       pavr_s3_rfrd2_addr <= "10"&pavr_s3_instr(2 downto 0);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_mulsu8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr1wr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= "00000";
                                       next_pavr_s4_s61_rfwr_addr2 <= "00001";
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                       next_pavr_s4_s61_aluouthi8_rfwr_rq <= '1';
                                       next_pavr_s4_s6_stall_rq <= '1';
                                    when "01" =>
                                       -- FMUL Rd, Rr (Fractional multiply unsigned)
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd2_rq <= '1';
                                       pavr_s3_rfrd1_addr <= "10"&pavr_s3_instr(6 downto 4);
                                       pavr_s3_rfrd2_addr <= "10"&pavr_s3_instr(2 downto 0);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_fmul8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr1wr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= "00000";
                                       next_pavr_s4_s61_rfwr_addr2 <= "00001";
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                       next_pavr_s4_s61_aluouthi8_rfwr_rq <= '1';
                                       next_pavr_s4_s6_stall_rq <= '1';
                                    when "10" =>
                                       -- FMULS Rd, Rr (Fractional multiply signed)
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd2_rq <= '1';
                                       pavr_s3_rfrd1_addr <= "10"&pavr_s3_instr(6 downto 4);
                                       pavr_s3_rfrd2_addr <= "10"&pavr_s3_instr(2 downto 0);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_fmuls8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr1wr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= "00000";
                                       next_pavr_s4_s61_rfwr_addr2 <= "00001";
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                       next_pavr_s4_s61_aluouthi8_rfwr_rq <= '1';
                                       next_pavr_s4_s6_stall_rq <= '1';
                                    when others =>
                                       -- FMULSU Rd, Rr (Fractional multiply signed with unsigned)
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd2_rq <= '1';
                                       pavr_s3_rfrd1_addr <= "10"&pavr_s3_instr(6 downto 4);
                                       pavr_s3_rfrd2_addr <= "10"&pavr_s3_instr(2 downto 0);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_fmulsu8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr1wr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= "00000";
                                       next_pavr_s4_s61_rfwr_addr2 <= "00001";
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                       next_pavr_s4_s61_aluouthi8_rfwr_rq <= '1';
                                       next_pavr_s4_s6_stall_rq <= '1';
                                 end case;
                              when others =>
                                 -- NOP (0000_0000_0000_0000) or invalid opcode (0000_0000_xxxx_xxxx, with xxxx_xxxx != 0000_0000)
                                 null;
                           end case;
                        when "01" =>
                           -- CPC Rd, Rr (Compare with carry)
                           pavr_s3_rfrd1_rq <= '1';
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_sbc8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_alu_sregwr_rq <= '1';
                        when "10" =>
                           -- SBC Rd, Rr (Substract with carry)
                           pavr_s3_rfrd1_rq <= '1';
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_sbc8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_alu_sregwr_rq <= '1';
                           next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                           next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                           next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                        when others =>
                           -- ADD Rd, Rr
                           pavr_s3_rfrd1_rq <= '1';
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_add8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_alu_sregwr_rq <= '1';
                           next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                           next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                           next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                     end case;
                  else
                     tmp2_4 := pavr_s3_instr(11 downto 10);
                     case tmp2_4 is
                        when "00" =>
                           -- AND Rd, Rr
                           pavr_s3_rfrd1_rq <= '1';
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_and8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_alu_sregwr_rq <= '1';
                           next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                           next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                           next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                        when "01" =>
                           -- EOR Rd, Rr (Logical or exclusive)
                           pavr_s3_rfrd1_rq <= '1';
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_eor8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_alu_sregwr_rq <= '1';
                           next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                           next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                           next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                        when "10" =>
                           -- OR Rd, Rr
                           pavr_s3_rfrd1_rq <= '1';
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_or8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_alu_sregwr_rq <= '1';
                           next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                           next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                           next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                        when others =>
                           -- MOV Rd, Rr
                           pavr_s3_rfrd1_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_op1, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                           next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                           next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                     end case;
                  end if;
               when "001" =>
                  if pavr_s3_instr(13)='0' then
                     tmp2_5 := pavr_s3_instr(11 downto 10);
                     case tmp2_5 is
                        when "00" =>
                           -- CPSE Rd, Rr (Compare and skip if equal)
                           pavr_s3_rfrd1_rq <= '1';          -- Read two operands from RF, substract them, and use the zero aluout_flag as skip condition to be checked.
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_sub8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_skip_cond_sel <= pavr_s5_skip_cond_sel_zflag;
                           next_pavr_s4_s5_skip_en <= '1';      -- Enable skip request in s5. If skip condition true, then: 1) stall (s6) and flush s5, 2) flush s3, 3) if instr32bits then flush s2
                           pavr_s3_stall_rq <= '1';
                           --next_pavr_s4_s5_stall_rq <= '1';     -- Request stall in s5. That's to have next two instruction words in s2 and s3, and be able to easely skip (flush) any or both of them.
                        when "01" =>
                           -- CP Rd, Rr (Compare)
                           pavr_s3_rfrd1_rq <= '1';                                     -- Set up the same signals as for CPC.
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_sub8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_alu_sregwr_rq <= '1';
                        when "10" =>
                           -- SUB Rd, Rr
                           pavr_s3_rfrd1_rq <= '1';
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_sub8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_alu_sregwr_rq <= '1';
                           next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                           next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                           next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                        when others =>
                           -- ADC Rd, Rr (Add with carry)
                           pavr_s3_rfrd1_rq <= '1';
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_adc8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_alu_sregwr_rq <= '1';
                           next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                           next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                           next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                     end case;
                  else
                     -- CPI Rd, k8 (Compare with immediate)
                     pavr_s3_rfrd1_rq <= '1';
                     pavr_s3_rfrd1_addr <= '1'&pavr_s3_instr(7 downto 4);                 -- Only registers 16...31 can be used.
                     next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_sub8, next_pavr_s4_s5_alu_opcode'length);
                     next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                     next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_k8;
                     next_pavr_s4_s5_k8 <= pavr_s3_instr(11 downto 8)&pavr_s3_instr(3 downto 0); -- Load 8 bit constant from instruction opcode.
                     next_pavr_s4_s5_alu_sregwr_rq <= '1';
                  end if;
               when "010" =>
                  if pavr_s3_instr(13)='0' then
                     -- SBCI Rd, k8 (Substract immediate with carry)
                     pavr_s3_rfrd1_rq <= '1';
                     pavr_s3_rfrd1_addr <= '1'&pavr_s3_instr(7 downto 4);                 -- Only registers 16...31 can be used.
                     next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_sbc8, next_pavr_s4_s5_alu_opcode'length);
                     next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                     next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_k8;
                     next_pavr_s4_s5_k8 <= pavr_s3_instr(11 downto 8)&pavr_s3_instr(3 downto 0); -- Load 8 bit constant from instruction opcode.
                     next_pavr_s4_s5_alu_sregwr_rq <= '1';
                     next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                     next_pavr_s4_s6_rfwr_addr1 <= '1'&pavr_s3_instr(7 downto 4);
                     next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                  else
                     -- ORI Rd, k8 (Logical or with immediate)
                     pavr_s3_rfrd1_rq <= '1';
                     pavr_s3_rfrd1_addr <= '1'&pavr_s3_instr(7 downto 4);                 -- Only registers 16...31 can be used.
                     next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_or8, next_pavr_s4_s5_alu_opcode'length);
                     next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                     next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_k8;
                     next_pavr_s4_s5_k8 <= pavr_s3_instr(11 downto 8)&pavr_s3_instr(3 downto 0);
                     next_pavr_s4_s5_alu_sregwr_rq <= '1';
                     next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                     next_pavr_s4_s6_rfwr_addr1 <= '1'&pavr_s3_instr(7 downto 4);
                     next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                  end if;
               when "011" =>
                  if pavr_s3_instr(13)='0' then
                     -- SUBI Rd, k8 (Substract immediate)
                     pavr_s3_rfrd1_rq <= '1';
                     pavr_s3_rfrd1_addr <= '1'&pavr_s3_instr(7 downto 4);                 -- Only registers 16...31 can be used.
                     next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_sub8, next_pavr_s4_s5_alu_opcode'length);
                     next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                     next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_k8;
                     next_pavr_s4_s5_k8 <= pavr_s3_instr(11 downto 8)&pavr_s3_instr(3 downto 0);
                     next_pavr_s4_s5_alu_sregwr_rq <= '1';
                     next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                     next_pavr_s4_s6_rfwr_addr1 <= '1'&pavr_s3_instr(7 downto 4);
                     next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                  else
                     -- ANDI Rd, k8 (Logical or with immediate)
                     pavr_s3_rfrd1_rq <= '1';
                     pavr_s3_rfrd1_addr <= '1'&pavr_s3_instr(7 downto 4);                 -- Only registers 16...31 can be used.
                     next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_and8, next_pavr_s4_s5_alu_opcode'length);
                     next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                     next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_k8;
                     next_pavr_s4_s5_k8 <= pavr_s3_instr(11 downto 8)&pavr_s3_instr(3 downto 0);
                     next_pavr_s4_s5_alu_sregwr_rq <= '1';
                     next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                     next_pavr_s4_s6_rfwr_addr1 <= '1'&pavr_s3_instr(7 downto 4);
                     next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                  end if;
               when "100" =>
                  tmp2_6 := pavr_s3_instr(9)&pavr_s3_instr(3);
                  case tmp2_6 is
                     when "00" =>
                        -- LDD Rd, Z+q (Load indirect with displacement, via Z register)
                        next_pavr_s4_dacu_q <= "00"&pavr_s3_instr(13)&pavr_s3_instr(11 downto 10)&pavr_s3_instr(2 downto 0); -- Load DACU displacement constant from instruction opcode.
                        next_pavr_s4_s5_z_dacurd_rq <= '1';                                                        -- Request DACU read access in s5.
                        next_pavr_s4_s6_dacu_rfwr_rq <= '1';                       -- Request RF write access.
                        next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);        -- Write-back address.
                        next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';                       -- Request BPR0 write access.
                        next_pavr_s4_s5_stall_rq <= '1';                             -- Stall the pipeline in s5, to `steal' RF read access from s3. A nop will be inserted before the load.
                     when "01" =>
                        -- LDD Rd, Y+q (Load indirect with displacement, via Y register)
                        next_pavr_s4_dacu_q <= "00"&pavr_s3_instr(13)&pavr_s3_instr(11 downto 10)&pavr_s3_instr(2 downto 0);
                        next_pavr_s4_s5_y_dacurd_rq <= '1';
                        next_pavr_s4_s6_dacu_rfwr_rq <= '1';
                        next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                        next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';
                        next_pavr_s4_s5_stall_rq <= '1';
                     when "10" =>
                        -- STD Z+q, Rr (Store indirect with displacement, via Z register)
                        pavr_s3_rfrd1_rq <= '1';
                        pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                        next_pavr_s4_dacu_q <= "00"&pavr_s3_instr(13)&pavr_s3_instr(11 downto 10)&pavr_s3_instr(2 downto 0);
                        next_pavr_s4_s5_z_dacuwr_rq <= '1';
                        next_pavr_s4_nop_rq <= '1';
                     when others =>
                        -- STD Y+q, Rr (Store indirect with displacement, via Y register)
                        pavr_s3_rfrd1_rq <= '1';
                        pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                        next_pavr_s4_dacu_q <= "00"&pavr_s3_instr(13)&pavr_s3_instr(11 downto 10)&pavr_s3_instr(2 downto 0);
                        next_pavr_s4_s5_y_dacuwr_rq <= '1';
                        next_pavr_s4_nop_rq <= '1';
                  end case;
               when "101" =>
                  if pavr_s3_instr(13)='0' then
                     tmp2_7 := pavr_s3_instr(11 downto 10);
                     case tmp2_7 is
                        when "11" =>
                           -- MUL Rd, Rr (Multiply unsigned)
                           pavr_s3_rfrd1_rq <= '1';
                           pavr_s3_rfrd2_rq <= '1';
                           pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                           pavr_s3_rfrd2_addr <= pavr_s3_instr(9)&pavr_s3_instr(3 downto 0);
                           next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_mul8, next_pavr_s4_s5_alu_opcode'length);
                           next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                           next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_op2bpu;
                           next_pavr_s4_s5_alu_sregwr_rq <= '1';
                           next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                           next_pavr_s4_s5_alu_bpr1wr_rq <= '1';
                           next_pavr_s4_s6_rfwr_addr1 <= "00000";           -- Write result in R1:R0.
                           next_pavr_s4_s61_rfwr_addr2 <= "00001";
                           next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                           next_pavr_s4_s61_aluouthi8_rfwr_rq <= '1';
                           next_pavr_s4_s6_stall_rq <= '1';                 -- Request stall in stage 6.
                        when "10" =>
                           tmp2_8 := pavr_s3_instr(9 downto 8);
                           case tmp2_8 is
                              when "00" =>
                                 -- CBI A, b (Clear bit in IO register)
                                 next_pavr_s4_s5_iof_rq <= '1';                            -- Request IO file access in s5.
                                 next_pavr_s4_s6_iof_rq <= '1';                            -- Request IO file access in s6
                                 next_pavr_s4_s5_iof_opcode <= pavr_iof_opcode_rdbyte;     -- Set IOF opcode in s5 to `read byte'.
                                 next_pavr_s4_s6_iof_opcode <= pavr_iof_opcode_clrbit;     -- Set IOF opcode in s6 to `clear bit'.
                                 next_pavr_s4_s5s6_iof_addr <= '0'&pavr_s3_instr(7 downto 3); -- Set IOF address (s5, s6). Only lower 32 bytes of IOF can be used.
                                 next_pavr_s4_s5s6_iof_bitaddr <= pavr_s3_instr(2 downto 0);  -- Set IOF bit address (s6).
                                 next_pavr_s4_s5_stall_rq <= '1';                          -- Request stall in s5.
                              when "01" =>
                                 -- SBIC A, b (Skip if bit in IO register is cleared)
                                 next_pavr_s4_s5_iof_rq <= '1';                                 -- Request IO file access in s5.
                                 next_pavr_s4_s5_iof_opcode <= pavr_iof_opcode_rdbyte;
                                 next_pavr_s4_s5s6_iof_addr <= '0'&pavr_s3_instr(7 downto 3);   -- Only lower 32 bytes of IOF can be used.
                                 next_pavr_s4_s6_skip_bitiof_sel <= pavr_s3_instr(2 downto 0);
                                 next_pavr_s4_s6_skip_cond_sel <= pavr_s6_skip_cond_sel_notbitiof;
                                 next_pavr_s4_s6_skip_en <= '1';   -- Enable skip request in s61. If skip condition true, then: 1) stall rq (s61) and flush s6, 2) flush s3, 3) if instr32bits then flush s2
                                 pavr_s3_stall_rq <= '1';
                                 next_pavr_s4_s5_stall_rq <= '1';
                                 --next_pavr_s4_s6_stall_rq <= '1';
                              when "10" =>
                                 -- SBI A, b (Set bit in IO register)
                                 next_pavr_s4_s5_iof_rq <= '1';
                                 next_pavr_s4_s6_iof_rq <= '1';
                                 next_pavr_s4_s5_iof_opcode <= pavr_iof_opcode_rdbyte;
                                 next_pavr_s4_s6_iof_opcode <= pavr_iof_opcode_setbit;
                                 next_pavr_s4_s5s6_iof_addr <= '0'&pavr_s3_instr(7 downto 3);
                                 next_pavr_s4_s5s6_iof_bitaddr <= pavr_s3_instr(2 downto 0);
                                 next_pavr_s4_s5_stall_rq <= '1';
                              when others =>
                                 -- SBIS A, b (Skip if bit in IO register is set)
                                 next_pavr_s4_s5_iof_rq <= '1';                                 -- Request IO file access in s5.
                                 next_pavr_s4_s5_iof_opcode <= pavr_iof_opcode_rdbyte;
                                 next_pavr_s4_s5s6_iof_addr <= '0'&pavr_s3_instr(7 downto 3);   -- Only lower 32 bytes of IOF can be used.
                                 next_pavr_s4_s6_skip_bitiof_sel <= pavr_s3_instr(2 downto 0);
                                 next_pavr_s4_s6_skip_cond_sel <= pavr_s6_skip_cond_sel_bitiof;
                                 next_pavr_s4_s6_skip_en <= '1';   -- Enable skip request in s61. If skip condition true, then: 1) stall rq (s61) and flush s6, 2) flush s3, 3) if instr32bits then flush s2
                                 pavr_s3_stall_rq <= '1';
                                 next_pavr_s4_s5_stall_rq <= '1';
                                 --next_pavr_s4_s6_stall_rq <= '1';
                           end case;
                        when "01" =>
                           if pavr_s3_instr(9)='1' then
                              if pavr_s3_instr(8)='0' then
                                 -- ADIW Rd+1:Rd, k6 (Add immediate to word)
                                 pavr_s3_rfrd1_rq <= '1';
                                 pavr_s3_rfrd2_rq <= '1';
                                 pavr_s3_rfrd1_addr <= "11"&pavr_s3_instr(5 downto 4)&'0';
                                 pavr_s3_rfrd2_addr <= "11"&pavr_s3_instr(5 downto 4)&'1';
                                 next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_add16, next_pavr_s4_s5_alu_opcode'length);
                                 next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_op1bpu;
                                 next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_k8;
                                 next_pavr_s4_s5_k8 <= "00"&pavr_s3_instr(7 downto 6)&pavr_s3_instr(3 downto 0);
                                 next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                 next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                 next_pavr_s4_s5_alu_bpr1wr_rq <= '1';
                                 next_pavr_s4_s6_rfwr_addr1 <= "11"&pavr_s3_instr(5 downto 4)&'0';
                                 next_pavr_s4_s61_rfwr_addr2 <= "11"&pavr_s3_instr(5 downto 4)&'1';
                                 next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                 next_pavr_s4_s61_aluouthi8_rfwr_rq <= '1';
                                 next_pavr_s4_s6_stall_rq <= '1';                   -- Request stall in stage 6.
                              else
                                 -- SBIW Rd+1:Rd, k6 (Substract immediate from word)
                                 pavr_s3_rfrd1_rq <= '1';
                                 pavr_s3_rfrd2_rq <= '1';
                                 pavr_s3_rfrd1_addr <= "11"&pavr_s3_instr(5 downto 4)&'0';
                                 pavr_s3_rfrd2_addr <= "11"&pavr_s3_instr(5 downto 4)&'1';
                                 next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_sub16, next_pavr_s4_s5_alu_opcode'length);
                                 next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_op1bpu;
                                 next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_k8;
                                 next_pavr_s4_s5_k8 <= "00"&pavr_s3_instr(7 downto 6)&pavr_s3_instr(3 downto 0);
                                 next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                 next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                 next_pavr_s4_s5_alu_bpr1wr_rq <= '1';
                                 next_pavr_s4_s6_rfwr_addr1 <= "11"&pavr_s3_instr(5 downto 4)&'0';
                                 next_pavr_s4_s61_rfwr_addr2 <= "11"&pavr_s3_instr(5 downto 4)&'1';
                                 next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                 next_pavr_s4_s61_aluouthi8_rfwr_rq <= '1';
                                 next_pavr_s4_s6_stall_rq <= '1';
                              end if;
                           else
                              tmp3_2 := pavr_s3_instr(3 downto 1);
                              case tmp3_2 is
                                 when "000" =>
                                    if pavr_s3_instr(0)='0' then
                                       -- COM Rd (One's complement)
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_com8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                    else
                                       -- NEG Rd (Two's complement)
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_neg8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                    end if;
                                 when "001" =>
                                    if pavr_s3_instr(0)='0' then
                                       -- SWAP Rd (Swap nibbles)
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_swap8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                    else
                                       -- INC Rd
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_inc8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_1;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                    end if;
                                 when "010" =>
                                    if pavr_s3_instr(0)='0' then
                                       -- Invalid opcode (1001_010x_xxxx_0100)
                                       null;
                                    else
                                       -- ASR Rd (Arithmetic shift right)
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_asr8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                    end if;
                                 when "011" =>
                                    if pavr_s3_instr(0)='0' then
                                       -- LSR Rd (Logical shift right)
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_lsr8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                    else
                                       -- ROR Rd (Rotate right through carry)
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_ror8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                    end if;
                                 when "100" =>
                                    tmp2_9 := pavr_s3_instr(8)&pavr_s3_instr(0);
                                    case tmp2_9 is
                                       when "00" =>
                                          if pavr_s3_instr(7)='0' then
                                             -- BSET s (Bit set in SREG (Status Register))
                                             next_pavr_s4_s5_iof_rq <= '1';                            -- Request IO file access in s5.
                                             next_pavr_s4_s6_iof_rq <= '1';                            -- Request IO file access in s6
                                             next_pavr_s4_s5_iof_opcode <= pavr_iof_opcode_rdbyte;     -- Set IOF opcode in s5 to `read byte'.
                                             next_pavr_s4_s6_iof_opcode <= pavr_iof_opcode_setbit;     -- Set IOF opcode in s6 to `set bit'.
                                             next_pavr_s4_s5s6_iof_addr <= int_to_std_logic_vector(pavr_sreg_addr, next_pavr_s4_s5s6_iof_addr'length);  -- Set IOF address to SREG's address (s5, s6).
                                             next_pavr_s4_s5s6_iof_bitaddr <= pavr_s3_instr(6 downto 4);  -- Set IOF bit address (s6).
                                             next_pavr_s4_s5_stall_rq <= '1';                          -- Request stall in s5.
                                          else
                                             -- BCLR s (Bit clear in SREG)
                                             next_pavr_s4_s5_iof_rq <= '1';
                                             next_pavr_s4_s6_iof_rq <= '1';
                                             next_pavr_s4_s5_iof_opcode <= pavr_iof_opcode_rdbyte;
                                             next_pavr_s4_s6_iof_opcode <= pavr_iof_opcode_clrbit;
                                             next_pavr_s4_s5s6_iof_addr <= int_to_std_logic_vector(pavr_sreg_addr, next_pavr_s4_s5s6_iof_addr'length);
                                             next_pavr_s4_s5s6_iof_bitaddr <= pavr_s3_instr(6 downto 4);
                                             next_pavr_s4_s5_stall_rq <= '1';
                                          end if;
                                       when "01" =>
                                          tmp4_1 := pavr_s3_instr(7 downto 4);
                                          case tmp4_1 is
                                             when "0000" =>
                                                -- IJMP (Indirect jump (16 bit absolute address), via Z register)
                                                next_pavr_s4_z_pm_rq <= '1';           -- Request PM access. Also, update PC. Next PC will be the present Z register.
                                                pavr_s3_flush_s2_rq <= '1';            -- Request flush s2 during s3 (next instruction is out of normal instruction flow).
                                                next_pavr_s4_flush_s2_rq <= '1';       -- Request flush s2 during s4 (next 2 instructions are out of normal instruction flow).
                                                next_pavr_s4_nop_rq <= '1';            -- Insert a nop *after* the instruction wavefront.
                                             when "0001" =>
                                                -- EIJMP (Extended indirect jump (24 bit absolute address), via Z and EIND registers)
                                                next_pavr_s4_zeind_pm_rq <= '1';       -- Request PM access. Also, update PC. Next PC will be the present Z:EIND registers.
                                                pavr_s3_flush_s2_rq <= '1';            -- Request flush s2 during s3 (next instruction is out of normal instruction flow).
                                                next_pavr_s4_flush_s2_rq <= '1';       -- Request flush s2 during s4 (next 2 instructions are out of normal instruction flow).
                                                next_pavr_s4_nop_rq <= '1';            -- Insert a nop *after* the instruction wavefront.
                                             when others =>
                                                -- Invalid opcode (1001_0100_xxxx_1001, with xxxx != 0000, 0001)
                                                null;
                                          end case;
                                       when "10" =>
                                          tmp4_2 := pavr_s3_instr(7 downto 4);
                                          case tmp4_2 is
                                             when "0000" =>
                                                -- RET (Return from subroutine)
                                                next_pavr_s4_s51s52s53_retpc_ld <= '1';       -- Load return PC from stack in stages s51, s52 and s53.
                                                next_pavr_s4_s5s51s52_pc_dacurd_rq <= '1';    -- Request DACU read for reading PC from stack, in stages s5, s51 and s52.
                                                next_pavr_s4_s54_ret_pm_rq <= '1';            -- Request PM access. Also, update PC.
                                                next_pavr_s4_dacu_q <= int_to_std_logic_vector(1, next_pavr_s4_dacu_q'length); -- Simulate pre-increment SP with a `1' initial displacement and post-increment.
                                                next_pavr_s4_s5s51_retinc_spwr_rq <= '1';     -- Request SP write access. SP will be (post-) incremented.
                                                pavr_s3_flush_s2_rq <= '1';             -- Request flush s2 in s3.
                                                next_pavr_s4_ret_flush_s2_rq <= '1';    -- Many, many flushes here (7 flushes; they shift from one stage into another, from s4 till s55).
                                                --next_pavr_s4_stall_rq <= '1';
                                             when "0001" =>
                                                -- RETI (Return from interrupt)
                                                next_pavr_s4_s51s52s53_retpc_ld <= '1';
                                                next_pavr_s4_s5s51s52_pc_dacurd_rq <= '1';
                                                next_pavr_s4_s54_ret_pm_rq <= '1';
                                                next_pavr_s4_s5_setiflag_sregwr_rq <= '1';    -- Request SREG write access, to set I (global interrupt enable) flag.
                                                next_pavr_s4_dacu_q <= int_to_std_logic_vector(1, next_pavr_s4_dacu_q'length);
                                                next_pavr_s4_s5s51_retinc_spwr_rq <= '1';
                                                pavr_s3_flush_s2_rq <= '1';
                                                next_pavr_s4_ret_flush_s2_rq <= '1';
                                                --next_pavr_s4_stall_rq <= '1';
                                             when "1000" =>
                                                -- SLEEP (Low power mode, not implemented)
                                                null;
                                             when "1001" =>
                                                -- BREAK (not implemented)
                                                null;
                                             when "1010" =>
                                                -- WDR (Reset watchdog timer, not implemented)
                                                null;
                                             when "1100" =>
                                                -- LPM (Load indirect Program Memory into R0, via Z register)
                                                next_pavr_s4_s5_lpm_pm_rq <= '1';         -- Request Program Memory (read; PM is read-only) access. Indirectly read PM via Z register.
                                                next_pavr_s4_s6_pm_rfwr_rq <= '1';      -- Request RF write access. Write PM data out into the RF.
                                                next_pavr_s4_s6_rfwr_addr1 <= "00000";    -- Write-back address.
                                                next_pavr_s4_s6_pmdo_bpr0wr_rq <= '1';    -- Request BPU write access.
                                                next_pavr_s4_s5_stall_rq <= '1';
                                             when "1101" =>
                                                -- ELPM (Load extended Program Memory into R0, via Z and RAMPZ registers)
                                                next_pavr_s4_s5_elpm_pm_rq <= '1';        -- Request Program Memory (read; PM is read-only) access. Indirectly read PM via Z and RAMPZ registers.
                                                next_pavr_s4_s6_pm_rfwr_rq <= '1';      -- Request RF write access. Write PM data out into the RF.
                                                next_pavr_s4_s6_rfwr_addr1 <= "00000";    -- Write-back address.
                                                next_pavr_s4_s6_pmdo_bpr0wr_rq <= '1';    -- Request BPU write access.
                                                next_pavr_s4_s5_stall_rq <= '1';
                                             when "1110" =>
                                                -- SPM (Store Program Memory, not implemented)
                                                null;
                                             when others =>
                                                -- Invalid opcode (1001_0101_xxxx_1000, with xxxx != 0000, 0001, 1000, 1001, 1010, 1100, 1101, 1110)
                                                null;
                                          end case;
                                       when others =>
                                          tmp4_3 := pavr_s3_instr(7 downto 4);
                                          case tmp4_3 is
                                             when "0000" =>
                                                -- ICALL (Indirect call (16 bit absolute address), via Z register)
                                                pavr_s3_flush_s2_rq <= '1';                   -- Flush the instructions that were already fetched but don't follow the normal instruction flow.
                                                next_pavr_s4_flush_s2_rq <= '1';
                                                next_pavr_s4_nop_rq <= '1';                   -- Insert a nop *after* the instruction wavefront.
                                                next_pavr_s4_z_pm_rq <= '1';                  -- Request PM access. Also, update PC.
                                                next_pavr_s4_s5s51s52_pc_dacuwr_rq <= '1';    -- Request DACU write access in s5, s51 and s52.
                                                next_pavr_s4_s5s51s52_calldec_spwr_rq <= '1'; -- Decrement SP.
                                                --next_pavr_s4_stall_rq <= '1';
                                             when "0001" =>
                                                -- EICALL (Extended indirect call (24 bit absolute address), via Z and EIND registers)
                                                pavr_s3_flush_s2_rq <= '1';                   -- Flush the instructions that were already fetched but don't follow the normal instruction flow.
                                                next_pavr_s4_flush_s2_rq <= '1';
                                                next_pavr_s4_nop_rq <= '1';                   -- Insert a nop *after* the instruction wavefront.
                                                next_pavr_s4_zeind_pm_rq <= '1';              -- Request PM access. Also, update PC.
                                                next_pavr_s4_s5s51s52_pc_dacuwr_rq <= '1';    -- Request DACU write access in s5, s51 and s52.
                                                next_pavr_s4_s5s51s52_calldec_spwr_rq <= '1'; -- Decrement SP.
                                                --next_pavr_s4_stall_rq <= '1';
                                             when others =>
                                                -- Invalid opcode (1001_0101_xxxx_1001, with xxxx != 0000, 0001)
                                                null;
                                          end case;
                                    end case;
                                 when "101" =>
                                    if pavr_s3_instr(0)='0' then
                                       -- DEC Rd
                                       pavr_s3_rfrd1_rq <= '1';
                                       pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                       next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_dec8, next_pavr_s4_s5_alu_opcode'length);
                                       next_pavr_s4_s5_alu_op1_hi8_sel <= pavr_alu_op1_hi8_sel_zero;
                                       next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_minus1;
                                       next_pavr_s4_s5_alu_sregwr_rq <= '1';
                                       next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                                       next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                                       next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                    else
                                       -- Invalid opcode (1001_010x_xxxx_1011)
                                       null;
                                    end if;
                                 when "110" =>
                                    -- JMP k16 (Long jump (22 bit absolute address); 32 bit instruction)
                                    next_pavr_s4_instr32bits <= '1';                          -- Signalize 32 bit instruction
                                    next_pavr_s4_k6 <= pavr_s3_instr(8 downto 4)&pavr_s3_instr(0);  -- Load lower 6 bits of the absolute jump address from instruction opcode.
                                    next_pavr_s4_k22abs_pm_rq <= '1';         -- Request PM access. (***) Attention, this also updates the PC.
                                    next_pavr_s4_flush_s2_rq <= '1';          -- Request flush s2 during s4 (next 2 instructions are out of normal instruction flow).
                                 when others =>
                                    -- CALL k16 (Long call (22 bit absolute address); 32 bit instruction)
                                    next_pavr_s4_instr32bits <= '1';              -- Signalize 32 bit instruction
                                    next_pavr_s4_pcinc <= '1';                    -- Increment return address to take into account that CALL has 32 bits.
                                    next_pavr_s4_flush_s2_rq <= '1';
                                    next_pavr_s4_nop_rq <= '1';                   -- Insert a nop *after* the instruction wavefront.
                                    next_pavr_s4_k22abs_pm_rq <= '1';             -- Request PM access. Also, update PC.
                                    next_pavr_s4_s5s51s52_pc_dacuwr_rq <= '1';    -- Request DACU write access in s5, s51 and s52.
                                    next_pavr_s4_s5s51s52_calldec_spwr_rq <= '1'; -- Decrement SP.
                                    --next_pavr_s4_stall_rq <= '1';
                              end case;
                           end if;
                        when others =>
                           if pavr_s3_instr(9)='0' then
                              tmp4_4 := pavr_s3_instr(3 downto 0);
                              case tmp4_4 is
                                 when "1111" =>
                                    -- POP Rd
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(1, next_pavr_s4_dacu_q'length); -- Simulate pre-increment with a `1' initial displacement and post-increment.
                                    next_pavr_s4_s5_sp_dacurd_rq <= '1';                                           -- Request DACU read access. Read UM via SP.
                                    next_pavr_s4_s6_dacu_rfwr_rq <= '1';
                                    next_pavr_s4_s5_inc_spwr_rq <= '1';                                            -- Request SP write access. SP will be (post-)incremented.
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when "0000" =>
                                    -- LDS Rd, k16 (Load direct from data space; 32 bit instruction)
                                    next_pavr_s4_instr32bits <= '1';        -- Signalize that this instruction is 32 bits wide. Next word (16 bits) will be ignored by the instruction decoder (nop). It's a constant that will be extracted by s5.
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_k16_dacurd_rq <= '1';                        -- Request DACU read access. Read from dedicated 16 bit instruction constant register (s4).
                                    next_pavr_s4_s6_dacu_rfwr_rq <= '1';                       -- Request RF write access.
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);     -- Write-back address.
                                    next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';                       -- Request Bypass Unit (BPU) write access in s6.
                                    next_pavr_s4_s5_stall_rq <= '1';                             -- Stall the pipeline in s5, to `steal' RF read access from s3. A nop will be inserted after the load.
                                 when "1100" =>
                                    -- LD Rd, X (Load indirect via X register)
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length); -- Load Data Address Calculation Unit (DACU) displacement constant (q).
                                    next_pavr_s4_s5_x_dacurd_rq <= '1';                          -- Request DACU read access in s5. Indirectly read Unified Memory (UM) via X register.
                                    next_pavr_s4_s6_dacu_rfwr_rq <= '1';                       -- Request RF write access.
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);     -- Write-back address.
                                    next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';                       -- Request Bypass Unit (BPU) write access in s6.
                                    next_pavr_s4_s5_stall_rq <= '1';                             -- Stall the pipeline in s5, to `steal' RF read access from s3. A nop will be inserted after the load.
                                 when "1101" =>
                                    -- LD Rd, X+ (Load indirect with post-increment via X register)
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_x_dacurd_rq <= '1';
                                    next_pavr_s4_s5_ldstincrampx_xwr_rq <= '1';                                     -- Request X pointer write access. The X pointer will be (post-)incremented.
                                    next_pavr_s4_s6_dacu_rfwr_rq <= '1';
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';
                                    next_pavr_s4_s5_dacux_bpr12wr_rq <='1';
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when "1110" =>
                                    -- LD Rd, -X (Load indirect with pre-decrement via X register)
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(-1, next_pavr_s4_dacu_q'length);   -- Simulate pre-decrement with a `-1' initial displacement and post-decrement.
                                    next_pavr_s4_s5_x_dacurd_rq <= '1';
                                    next_pavr_s4_s5_ldstdecrampx_xwr_rq <= '1';                                           -- Request X pointer write access. The X pointer will be (post-)decremented.
                                    next_pavr_s4_s6_dacu_rfwr_rq <= '1';
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';
                                    next_pavr_s4_s5_dacux_bpr12wr_rq <='1';
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when "1001" =>
                                    -- LD Rd, Y+ (Load indirect with post-increment via Y register)
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_y_dacurd_rq <= '1';
                                    next_pavr_s4_s5_ldstincrampy_ywr_rq <= '1';                                     -- Request Y pointer write access. The Y pointer will be (post-)incremented.
                                    next_pavr_s4_s6_dacu_rfwr_rq <= '1';
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';
                                    next_pavr_s4_s5_dacuy_bpr12wr_rq <='1';
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when "1010" =>
                                    -- LD Rd, -Y (Load indirect with pre-decrement via Y register)
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(-1, next_pavr_s4_dacu_q'length);   -- Simulate pre-decrement with a `-1' initial displacement and post-decrement.
                                    next_pavr_s4_s5_y_dacurd_rq <= '1';
                                    next_pavr_s4_s5_ldstdecrampy_ywr_rq <= '1';                                           -- Request Y pointer write access. The Y pointer will be (post-)decremented.
                                    next_pavr_s4_s6_dacu_rfwr_rq <= '1';
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';
                                    next_pavr_s4_s5_dacuy_bpr12wr_rq <='1';
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when "0001" =>
                                    -- LD Rd, Z+ (Load indirect with post-decrement via Z register)
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_z_dacurd_rq <= '1';
                                    next_pavr_s4_s5_ldstincrampz_zwr_rq <= '1';                                       -- Request Z pointer write access. The Z pointer will be (post-)incremented.
                                    next_pavr_s4_s6_dacu_rfwr_rq <= '1';
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';
                                    next_pavr_s4_s5_dacuz_bpr12wr_rq <='1';
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when "0010" =>
                                    -- LD Rd, -Z (Load indirect with pre-decrement via Z register)
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(-1, next_pavr_s4_dacu_q'length);   -- Simulate pre-decrement with a `-1' initial displacement and post-decrement.
                                    next_pavr_s4_s5_z_dacurd_rq <= '1';
                                    next_pavr_s4_s5_ldstdecrampz_zwr_rq <= '1';                                           -- Request Z pointer write access. The Z pointer will be (post-)decremented.
                                    next_pavr_s4_s6_dacu_rfwr_rq <= '1';
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_s6_daculd_bpr0wr_rq <= '1';
                                    next_pavr_s4_s5_dacuy_bpr12wr_rq <='1';
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when "0100" =>
                                    -- LPM Rd, Z (Load indirect Program Memory)
                                    next_pavr_s4_s5_lpm_pm_rq <= '1';                     -- Request Program Memory (read; PM is read-only) access. Indirectly read PM via Z register.
                                    next_pavr_s4_s6_pm_rfwr_rq <= '1';                  -- Request RF write access. Write PM data out into the RF.
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);  -- Write-back address.
                                    next_pavr_s4_s6_pmdo_bpr0wr_rq <= '1';                -- Request BPU write access.
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when "0101" =>
                                    -- LPM Rd, Z+ (Load indirect Program Memory with post-increment)
                                    next_pavr_s4_s5_lpm_pm_rq <= '1';                     -- Request Program Memory (read; PM is read-only) access. Indirectly read PM via Z register.
                                    next_pavr_s4_s5_lpminc_zwr_rq <= '1';                    -- Request Z pointer write access. Z will be (post-)incremented.
                                    next_pavr_s4_s6_pm_rfwr_rq <= '1';                  -- Request RF write access. Write PM data out into the RF.
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);  -- Write-back address.
                                    next_pavr_s4_s6_pmdo_bpr0wr_rq <= '1';                -- Request BPU write access.
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when "0110" =>
                                    -- ELPM Rd, Z (Load extended indirect Program Memory)
                                    next_pavr_s4_s5_elpm_pm_rq <= '1';                    -- Request Program Memory (read; PM is read-only) access. Indirectly read PM via Z and RAMPZ registers.
                                    next_pavr_s4_s6_pm_rfwr_rq <= '1';                  -- Request RF write access. Write PM data out into the RF.
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);  -- Write-back address.
                                    next_pavr_s4_s6_pmdo_bpr0wr_rq <= '1';                -- Request BPU write access.
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when "0111" =>
                                    -- ELPM Rd, Z+ (Load extended indirect Program Memory with post-increment)
                                    next_pavr_s4_s5_elpm_pm_rq <= '1';                    -- Request Program Memory (read; PM is read-only) access. Indirectly read PM via Z and RAMPZ registers.
                                    next_pavr_s4_s5_elpmincrampz_zwr_rq <= '1';               -- Request Z pointer write access. RAMPZ:Z will be (post-)incremented.
                                    next_pavr_s4_s6_pm_rfwr_rq <= '1';                  -- Request RF write access. Write PM data out into the RF.
                                    next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);  -- Write-back address.
                                    next_pavr_s4_s6_pmdo_bpr0wr_rq <= '1';                -- Request BPU write access.
                                    next_pavr_s4_s5_stall_rq <= '1';
                                 when others =>
                                    -- Invalid opcode (1001_000x_xxxx_yyyy, with yyyy = 0011, 1000, 1011)
                                    null;
                              end case;
                           else
                              tmp4_5 := pavr_s3_instr(3 downto 0);
                              case tmp4_5 is
                                 when "1111" =>
                                    -- PUSH Rr
                                    pavr_s3_rfrd1_rq <= '1';
                                    pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_sp_dacuwr_rq <= '1';                -- Request DACU write access, at address given by Stack Pointer (SP).
                                    next_pavr_s4_s5_dec_spwr_rq <= '1';                 -- Request SP write access. SP will be (post-)decremented.
                                    next_pavr_s4_s5_stall_rq <= '1';                    -- Request stall in s5.
                                    next_pavr_s4_nop_rq <= '1';                         -- Request nop after the instrction wavefront.
                                 when "0000" =>
                                    -- STS k16, Rr (Store direct to data space; 32 bit instruction)
                                    next_pavr_s4_instr32bits <= '1';                    -- Signalize 32 bit instruction.
                                    pavr_s3_rfrd1_rq <= '1';                            -- Request RF read port 1 access.
                                    pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);       -- Address of RF operand to be read.
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_k16_dacuwr_rq <= '1';               -- Request DACU write access. Write UM at address given by 16 bit instruction constant (pavr_s5_k16).
                                    next_pavr_s4_nop_rq <= '1';                        -- Request a nop *after* the instruction wavefront. Do that for the store to wait its turn for RF write port access.
                                 when "1100" =>
                                    -- ST X, Rr (Store indirect via X register)
                                    pavr_s3_rfrd1_rq <= '1';                            -- Request RF read port 1 access.
                                    pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);       -- Address of RF operand to be read.
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_x_dacuwr_rq <= '1';
                                    next_pavr_s4_nop_rq <= '1';          -- Request a nop *after* the instruction wavefront. Do that for the store to wait its turn for RF write port access.
                                 when "1101" =>
                                    -- ST X+, Rr (Store indirect with post-increment via X register)
                                    pavr_s3_rfrd1_rq <= '1';
                                    pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_x_dacuwr_rq <= '1';
                                    next_pavr_s4_s5_ldstincrampx_xwr_rq <= '1';   -- Request X pointer write access. The X pointer will be (post-)incremented.
                                    next_pavr_s4_s5_dacux_bpr12wr_rq <='1';
                                    next_pavr_s4_nop_rq <= '1';
                                 when "1110" =>
                                    -- ST -X, Rr (Store indirect with pre-decrement via X register)
                                    pavr_s3_rfrd1_rq <= '1';
                                    pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(-1, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_x_dacuwr_rq <= '1';
                                    next_pavr_s4_s5_ldstdecrampx_xwr_rq <= '1';   -- Request X pointer write access. The X pointer will be (post-)decremented.
                                    next_pavr_s4_s5_dacux_bpr12wr_rq <='1';
                                    next_pavr_s4_nop_rq <= '1';
                                 when "1001" =>
                                    -- ST Y+, Rr (Store indirect with post-increment via Y register)
                                    pavr_s3_rfrd1_rq <= '1';
                                    pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_y_dacuwr_rq <= '1';
                                    next_pavr_s4_s5_ldstincrampy_ywr_rq <= '1';   -- Request Y pointer write access. The Y pointer will be (post-)incremented.
                                    next_pavr_s4_s5_dacuy_bpr12wr_rq <='1';
                                    next_pavr_s4_nop_rq <= '1';
                                 when "1010" =>
                                    -- ST -Y, Rr (Store indirect with pre-decrement via Y register)
                                    pavr_s3_rfrd1_rq <= '1';
                                    pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(-1, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_y_dacuwr_rq <= '1';
                                    next_pavr_s4_s5_ldstdecrampy_ywr_rq <= '1';   -- Request Y pointer write access. The Y pointer will be (post-)decremented.
                                    next_pavr_s4_s5_dacuy_bpr12wr_rq <='1';
                                    next_pavr_s4_nop_rq <= '1';
                                 when "0001" =>
                                    -- ST Z+, Rr (Store indirect with post-increment via Z register)
                                    pavr_s3_rfrd1_rq <= '1';
                                    pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(0, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_z_dacuwr_rq <= '1';
                                    next_pavr_s4_s5_ldstincrampz_zwr_rq <= '1';   -- Request Z pointer write access. The Z pointer will be (post-)incremented.
                                    next_pavr_s4_s5_dacuz_bpr12wr_rq <='1';
                                    next_pavr_s4_nop_rq <= '1';
                                 when "0010" =>
                                    -- ST -Z, Rr (Store indirect with pre-decrement via Z register)
                                    pavr_s3_rfrd1_rq <= '1';
                                    pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                    next_pavr_s4_dacu_q <= int_to_std_logic_vector(-1, next_pavr_s4_dacu_q'length);
                                    next_pavr_s4_s5_z_dacuwr_rq <= '1';
                                    next_pavr_s4_s5_ldstdecrampz_zwr_rq <= '1';   -- Request Z pointer write access. The Z pointer will be (post-)decremented.
                                    next_pavr_s4_s5_dacuz_bpr12wr_rq <='1';
                                    next_pavr_s4_nop_rq <= '1';
                                 when others =>
                                    -- Invalid opcode (1001_001x_xxxx_yyyy, with yyyy = 0011, 0100, 0101, 0110, 0111, 1000, 1110)
                                    null;
                              end case;
                           end if;
                     end case;
                  else
                     if pavr_s3_instr(11)='0' then
                        -- IN Rd, A (Load IO location to register)
                        next_pavr_s4_s5_iof_rq <= '1';
                        next_pavr_s4_s5_iof_opcode <= pavr_iof_opcode_rdbyte;
                        next_pavr_s4_s5s6_iof_addr <= pavr_s3_instr(10 downto 9)&pavr_s3_instr(3 downto 0);
                        next_pavr_s4_s6_iof_bpr0wr_rq <= '1';
                        next_pavr_s4_s6_iof_rfwr_rq <= '1';
                        next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);
                        next_pavr_s4_s5_stall_rq <= '1';                -- Steal BPU0 write access from next instruction.
                     else
                        -- OUT A, Rr (Store register into IO location)
                        pavr_s3_rfrd1_rq <= '1';
                        pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                        next_pavr_s4_s5_iof_rq <= '1';
                        next_pavr_s4_s5_iof_opcode <= pavr_iof_opcode_wrbyte;
                        next_pavr_s4_s5s6_iof_addr <= pavr_s3_instr(10 downto 9)&pavr_s3_instr(3 downto 0);
                     end if;
                  end if;
               when "110" =>
                  if pavr_s3_instr(13)='0' then
                     -- RJMP k12 (Relative jump (12 bit relative address))
                     next_pavr_s4_k12 <= pavr_s3_instr(11 downto 0);    -- Load 12 bit relative jump address from instruction opcode.
                     next_pavr_s4_k12rel_pm_rq <= '1';                  -- Request PM access.
                     pavr_s3_flush_s2_rq <= '1';                        -- Request flush s2 during s3 (next instruction is out of normal instruction flow).
                     next_pavr_s4_flush_s2_rq <= '1';                   -- Request flush s2 during s4 (next 2 instructions are out of normal instruction flow).
                  else
                     -- LDI k8 (Load immediate)
                     next_pavr_s4_s5_alu_opcode <= int_to_std_logic_vector(pavr_alu_opcode_op2, next_pavr_s4_s5_alu_opcode'length);
                     next_pavr_s4_s5_k8 <= pavr_s3_instr(11 downto 8)&pavr_s3_instr(3 downto 0);
                     next_pavr_s4_s5_alu_op2_sel <= pavr_alu_op2_sel_k8;
                     next_pavr_s4_s5_alu_bpr0wr_rq <= '1';
                     next_pavr_s4_s6_aluoutlo8_rfwr_rq <= '1';
                     next_pavr_s4_s6_rfwr_addr1 <= '1'&pavr_s3_instr(7 downto 4);   -- Only the higher 16 registers can be immediately loaded.
                  end if;
               when others =>
                  if pavr_s3_instr(13)='0' then
                     -- RCALL (Relative call (12 bit relative address))
                     next_pavr_s4_k12 <= pavr_s3_instr(11 downto 0); -- Load 12 bit relative jump address from instruction opcode.
                     pavr_s3_flush_s2_rq <= '1';                     -- Flush the instructions that were already fetched but don't follow the normal instruction flow.
                     next_pavr_s4_flush_s2_rq <= '1';
                     next_pavr_s4_nop_rq <= '1';                     -- Insert a nop *after* the instruction wavefront.
                     next_pavr_s4_k12rel_pm_rq <= '1';               -- Request PM access. Also, update PC.
                     next_pavr_s4_s5s51s52_pc_dacuwr_rq <= '1';      -- Request DACU write access in s5, s51 and s52.
                     next_pavr_s4_s5s51s52_calldec_spwr_rq <= '1';   -- Decrement SP.
                     --next_pavr_s4_stall_rq <= '1';
                  else
                     tmp2_a := pavr_s3_instr(11 downto 10);
                     case tmp2_a is
                        when "00" =>
                           -- BRBS s, k7 (Branch if bit in SREG is set (7 bit relative address))
                           next_pavr_s4_s5_k7_branch_offset <= pavr_s3_instr(9 downto 3);       -- 7 bit relative jump address
                           next_pavr_s4_pcinc <= '1';
                           next_pavr_s4_s5_branch_cond_sel <= pavr_s5_branch_cond_sel_bitsreg;  -- Select jump condition.
                           next_pavr_s4_s5_branch_en <= '1';                                    -- Enable branch request.
                           next_pavr_s4_s5_branch_bitsreg_sel <= pavr_s3_instr(2 downto 0);     -- Select which bit in SREG will be checked as branch condition.
                           pavr_s3_stall_rq <= '1';
                        when "01" =>
                           -- BRBC s, k7 (Branch if bit in SREG is cleared (7 bit relative address))
                           next_pavr_s4_s5_k7_branch_offset <= pavr_s3_instr(9 downto 3);
                           next_pavr_s4_pcinc <= '1';
                           next_pavr_s4_s5_branch_cond_sel <= pavr_s5_branch_cond_sel_notbitsreg;
                           next_pavr_s4_s5_branch_en <= '1';
                           next_pavr_s4_s5_branch_bitsreg_sel <= pavr_s3_instr(2 downto 0);
                           pavr_s3_stall_rq <= '1';
                        when "10" =>
                           tmp2_b := pavr_s3_instr(9)&pavr_s3_instr(3);
                           case tmp2_b is
                              when "00" =>
                                 -- BLD Rd, b (Bit load from T flag in SREG into a bit in register)
                                 pavr_s3_rfrd1_rq <= '1';                                    -- Request RF read port 1 access in s3.
                                 pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);            -- Set address of operand to be read from RF read port 1.
                                 next_pavr_s4_s5_iof_rq <= '1';                              -- Request IOF access in s5 for loading the T flag in SREG into a bit in register.
                                 next_pavr_s4_s5_iof_opcode <= pavr_iof_opcode_ldbit;        -- Set IOF opcode in s5 to `load bit'.
                                 next_pavr_s4_s5s6_iof_bitaddr <= pavr_s3_instr(2 downto 0); -- Set IOF bit address (s6).
                                 next_pavr_s4_s6_iof_bpr0wr_rq <= '1';                       -- Update BPU.
                                 next_pavr_s4_s6_iof_rfwr_rq <= '1';                         -- Request RF write port access.
                                 next_pavr_s4_s6_rfwr_addr1 <= pavr_s3_instr(8 downto 4);    -- Set RF write-back address.
                                 next_pavr_s4_s5_stall_rq <= '1';                            -- Steal BPU0 write access from next instruction.
                              when "10" =>
                                 -- BST Rd, b (Bit store from a bit in register into T flag in SREG)
                                 pavr_s3_rfrd1_rq <= '1';                                    -- Request RF read port 1 access in s3.
                                 pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);            -- Set address of operand in RF.
                                 next_pavr_s4_s5_iof_rq <= '1';                              -- Request IOF access in s5 for storing the bit into T flag in SREG.
                                 next_pavr_s4_s5_iof_opcode <= pavr_iof_opcode_stbit;        -- Set IOF opcode in s5 to `store bit'.
                                 next_pavr_s4_s5s6_iof_bitaddr <= pavr_s3_instr(2 downto 0); -- Set IOF bit address (s6).
                              when others =>
                                 -- Invalid opcode (1111_10xy_yyyy_xyyy, with xx = 01, 11)
                                 null;
                           end case;
                        when others =>
                           tmp2_c := pavr_s3_instr(9)&pavr_s3_instr(3);
                           case tmp2_c is
                              when "00" =>
                                 -- SBRC Rr, b (Skip if bit in register is cleared)
                                 pavr_s3_rfrd1_rq <= '1';          -- Read an operand from RF and use a specific bit of it (negated) as skip condition to be checked.
                                 pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                 next_pavr_s4_s5_skip_bitrf_sel <= pavr_s3_instr(2 downto 0);
                                 next_pavr_s4_s5_skip_cond_sel <= pavr_s5_skip_cond_sel_notbitrf;
                                 next_pavr_s4_s5_skip_en <= '1';   -- Enable skip request in s5. If skip condition true, then: 1) stall (s6) and flush s5, 2) flush s3, 3) if instr32bits then flush s2
                                 pavr_s3_stall_rq <= '1';
                                 --next_pavr_s4_s5_stall_rq <= '1';  -- Request stall in s5. That's to have next two instruction words in s2 and s3, and be able to easely skip (flush) any or both of them.
                              when "10" =>
                                 -- SBRS Rr, b (Skip if bit in register is set)
                                 pavr_s3_rfrd1_rq <= '1';          -- Read an operand from RF and use a specific bit of it as skip condition to be checked.
                                 pavr_s3_rfrd1_addr <= pavr_s3_instr(8 downto 4);
                                 next_pavr_s4_s5_skip_bitrf_sel <= pavr_s3_instr(2 downto 0);
                                 next_pavr_s4_s5_skip_cond_sel <= pavr_s5_skip_cond_sel_bitrf;
                                 next_pavr_s4_s5_skip_en <= '1';
                                 pavr_s3_stall_rq <= '1';
                                 --next_pavr_s4_s5_stall_rq <= '1';
                              when others =>
                                 -- Invalid opcode (1111_11xy_yyyy_xyyy, with xx = 01, 11)
                                 null;
                           end case;
                     end case;
                  end if;
            end case;
         end if;
      else

         -- Interrupt request
         -- Forcedly place a call into the pipeline.
         next_pavr_s4_instr32bits <= '1';                -- Signalize 32 bit instruction (quite redundant here; kept for the regularity of the code).
         pavr_s3_flush_s2_rq <= '1';
         next_pavr_s4_flush_s2_rq <= '1';
         next_pavr_s4_nop_rq <= '1';                     -- Insert a nop *after* the instruction wavefront.
         next_pavr_s4_k22int_pm_rq <= '1';               -- Request PM access. Also, update PC.
         next_pavr_s4_s5s51s52_pc_dacuwr_rq <= '1';      -- Request DACU write access in s5, s51 and s52, to save the PC.
         next_pavr_s4_s5s51s52_calldec_spwr_rq <= '1';   -- Decrement SP.
         next_pavr_s4_k22int <= pavr_int_vec;            -- Get absolute call address from interrupt vector.
         next_pavr_s4_s5_clriflag_sregwr_rq  <= '1';     -- Request clear I flag (general interrupt enable flag).
         next_pavr_s4_disable_int <= '1';                -- Disable interrupts in the next 4 clocks, so that at least an instruction is executed in the current interrupt routine.
         --next_pavr_s4_stall_rq <= '1';       -- !!! Needed?

      end if;
   end process instr_decoder;










   -- Hardware resources managers ---------------------------------------------

   -- RF read port 1
   -- Set the signals:
   --    - pavr_rf_rd1_addr
   --    - pavr_rf_rd1_rd
   rfrd1_manager:
   process(pavr_s3_rfrd1_rq,
           pavr_s5_dacu_rfrd1_rq,

           pavr_s3_hwrq_en,
           pavr_s5_hwrq_en,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_rf_rd1_addr,
           pavr_s3_rfrd1_addr,
           pavr_s5_dacust_rf_addr)
      variable v_rfrd1rq_sel : std_logic_vector(1 downto 0);
   begin
      pavr_rf_rd1_addr <= int_to_std_logic_vector(0, pavr_rf_rd1_addr'length);
      pavr_rf_rd1_rd   <= '0';

      v_rfrd1rq_sel := pavr_s3_rfrd1_rq & pavr_s5_dacu_rfrd1_rq;
      case v_rfrd1rq_sel is
         when "00" =>
            -- No read requests.
            null;
         when "10" =>
            -- Instruction decoder RFRD1 request
            -- Only take action if permitted by older instructions.
            if pavr_s3_hwrq_en='1' then
               pavr_rf_rd1_addr <= pavr_s3_rfrd1_addr;
               pavr_rf_rd1_rd   <= '1';
            end if;
         when "01" =>
            -- DACU RFRD1 request, placed by loads and POP that decode UM as RF
            -- Only take action if permitted by older instructions.
            if pavr_s5_hwrq_en='1' then
               pavr_rf_rd1_addr <= pavr_s5_dacust_rf_addr;
               pavr_rf_rd1_rd   <= '1';
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "Register File read port 1 error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process rfrd1_manager;



   -- RF read port 2
   -- Set the signals:
   --    - pavr_rf_rd2_addr
   --    - pavr_rf_rd2_rd
   rfrd2_manager:
   process(pavr_s3_rfrd2_rq,

           pavr_s3_hwrq_en,

           pavr_rf_rd2_addr,
           pavr_s3_rfrd2_addr
          )
   begin
      pavr_rf_rd2_addr <= int_to_std_logic_vector(0, pavr_rf_rd2_addr'length);
      pavr_rf_rd2_rd   <= '0';

      if pavr_s3_rfrd2_rq='0' then
         -- No read requests.
         null;
      else
         -- Instruction decoder RFRD2 request
         -- Only take action if permitted by older instructions.
         if pavr_s3_hwrq_en='1' then
            pavr_rf_rd2_addr <= pavr_s3_rfrd2_addr;
            pavr_rf_rd2_rd   <= '1';
         end if;
      end if;
   end process rfrd2_manager;



   -- RF write port
   -- Set the signals:
   --    - pavr_rf_wr_addr
   --    - pavr_rf_wr_wr
   --    - pavr_rf_wr_di
   rfwr_manager:
   process(pavr_s6_aluoutlo8_rfwr_rq,
           pavr_s61_aluouthi8_rfwr_rq,
           pavr_s6_iof_rfwr_rq,
           pavr_s6_dacu_rfwr_rq,
           pavr_s6_pm_rfwr_rq,
           pavr_s5_dacu_rfwr_rq,

           pavr_s5_hwrq_en,
           pavr_s6_hwrq_en,
           pavr_s61_hwrq_en,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_s6_zlsb,
           pavr_pm_do,
           pavr_rf_wr_addr,
           pavr_rf_wr_di,
           pavr_s6_rfwr_addr1,
           pavr_s61_rfwr_addr2,
           pavr_s6_alu_out,
           pavr_s61_alu_out_hi8,
           pavr_s5_dacust_rf_addr,
           pavr_s5_dacu_rfwr_di,
           pavr_iof_do_shadow_active,
           pavr_iof_do_shadow,
           pavr_iof_do,
           pavr_dacu_do_shadow_active,
           pavr_dacu_do_shadow,
           pavr_dacu_do,
           pavr_pm_do
          )
      variable v_rfwrrq_sel : std_logic_vector(5 downto 0);
   begin
      pavr_rf_wr_addr <= int_to_std_logic_vector(0, pavr_rf_wr_addr'length);
      pavr_rf_wr_wr   <= '0';
      pavr_rf_wr_di   <= int_to_std_logic_vector(0, pavr_rf_wr_di'length);

      v_rfwrrq_sel := pavr_s6_aluoutlo8_rfwr_rq &
                      pavr_s61_aluouthi8_rfwr_rq &
                      pavr_s6_iof_rfwr_rq &
                      pavr_s6_dacu_rfwr_rq &
                      pavr_s6_pm_rfwr_rq &
                      pavr_s5_dacu_rfwr_rq;
      case v_rfwrrq_sel is
         when "000000" =>
            -- No write requests.
            null;
         when "100000" =>
            -- ALU out lower 8 bits RFWR request
            -- Only take action if permitted by older instructions.
            if pavr_s6_hwrq_en='1' then
               pavr_rf_wr_addr <= pavr_s6_rfwr_addr1;
               pavr_rf_wr_wr   <= '1';
               pavr_rf_wr_di   <= pavr_s6_alu_out(7 downto 0);
            end if;
         when "010000" =>
            -- ALU out higher 8 bits RFWR request
            -- Only take action if permitted by older instructions.
            if pavr_s61_hwrq_en='1' then
               pavr_rf_wr_addr <= pavr_s61_rfwr_addr2;
               pavr_rf_wr_wr   <= '1';
               pavr_rf_wr_di   <= pavr_s61_alu_out_hi8;
            end if;
         when "001000" =>
            -- IOF out RFWR request
            -- Only take action if permitted by older instructions.
            if pavr_s6_hwrq_en='1' then
               pavr_rf_wr_addr <= pavr_s6_rfwr_addr1;
               pavr_rf_wr_wr   <= '1';
               if pavr_iof_do_shadow_active='0' then
                  pavr_rf_wr_di  <= pavr_iof_do;
               else
                  pavr_rf_wr_di  <= pavr_iof_do_shadow;
               end if;
            end if;
         when "000100" =>
            -- DACU out RFWR request, placed by loads and POP
            -- Only take action if permitted by older instructions.
            if pavr_s6_hwrq_en='1' then
               pavr_rf_wr_addr <= pavr_s6_rfwr_addr1;
               pavr_rf_wr_wr   <= '1';
               if pavr_dacu_do_shadow_active='0' then
                  pavr_rf_wr_di  <= pavr_dacu_do;
               else
                  pavr_rf_wr_di  <= pavr_dacu_do_shadow;
               end if;
            end if;
         when "000010" =>
            -- PM out RFWR request, placed by LPMs
            -- Only take action if permitted by older instructions.
            if pavr_s6_hwrq_en='1' then
               pavr_rf_wr_addr <= pavr_s6_rfwr_addr1;
               pavr_rf_wr_wr   <= '1';
               if pavr_s6_zlsb='0' then
                  -- *** Break a hole through the shadow protocol for this
                  --    off-placed PM read request.
                  -- Fortunately, there's no danger for PM data out to get
                  --    corrupted by a stall from older instructions, because this
                  --    request takes place so late in the pipeline, that no other
                  --    older instruction could stall it.
                  --if pavr_pm_do_shadow_active='0' then
                     pavr_rf_wr_di <= pavr_pm_do(7 downto 0);
                  --else
                  --   pavr_rf_wr_di <= pavr_pm_do_shadow(7 downto 0);
                  --end if;
               else
                  --if pavr_pm_do_shadow_active='0' then
                     pavr_rf_wr_di <= pavr_pm_do(15 downto 8);
                  --else
                  --   pavr_rf_wr_di <= pavr_pm_do_shadow(15 downto 8);
                  --end if;
               end if;
            end if;
         when "000001" =>
            -- DACU out RFWR request, placed by stores and PUSH
            -- Only take action if permitted by older instructions.
            if pavr_s5_hwrq_en='1' then
               pavr_rf_wr_addr <= pavr_s5_dacust_rf_addr;
               pavr_rf_wr_wr   <= '1';
               pavr_rf_wr_di   <= pavr_s5_dacu_rfwr_di;
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "Register File write port error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process rfwr_manager;



   -- X pointer write port
   -- Set the signals:
   --    - pavr_rf_x_wr
   --    - pavr_rf_x_di
   xwr_manager:
   process(pavr_s5_ldstincrampx_xwr_rq,
           pavr_s5_ldstdecrampx_xwr_rq,

           pavr_s5_hwrq_en,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_rf_x_di,
           pavr_iof_rampx,
           pavr_xbpu
          )
      variable v_xwrrq_sel: std_logic_vector(1 downto 0);
      variable v_xrampx_inc: std_logic_vector(23 downto 0);
      variable v_xrampx_dec: std_logic_vector(23 downto 0);
   begin
      pavr_rf_x_wr <= '0';
      pavr_rf_x_di <= int_to_std_logic_vector(0, pavr_rf_x_di'length);

      v_xrampx_inc := (pavr_iof_rampx & pavr_xbpu) + 1;
      v_xrampx_dec := (pavr_iof_rampx & pavr_xbpu) - 1;

      v_xwrrq_sel := pavr_s5_ldstincrampx_xwr_rq & pavr_s5_ldstdecrampx_xwr_rq;
      case v_xwrrq_sel is
         when "00" =>
            -- No X write requests
            null;
         when "10" =>
            -- Increment X request, placed by loads and stores with post increment.
            -- Note that RAMPX is modified, if needed, by its own write manager.
            -- Only take action if permitted by older instructions.
            if pavr_s5_hwrq_en='1' then
               pavr_rf_x_wr <= '1';
               if pavr_dm_bigger_than_64K='1' then
                  pavr_rf_x_di <= v_xrampx_inc(15 downto 0);
               else
                  pavr_rf_x_di <= pavr_xbpu + 1;
               end if;
            end if;
         when "01" =>
            -- Decrement X request, placed by loads and stores with pre decrement.
            -- Only take action if permitted by older instructions.
            if pavr_s5_hwrq_en='1' then
               pavr_rf_x_wr <= '1';
               if pavr_dm_bigger_than_64K='1' then
                  pavr_rf_x_di <= v_xrampx_dec(15 downto 0);
               else
                  pavr_rf_x_di <= pavr_xbpu - 1;
               end if;
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "X pointer error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process xwr_manager;



   -- Y pointer write port
   -- Set the signals:
   --    - pavr_rf_y_wr
   --    - pavr_rf_y_di
   ywr_manager:
   process(pavr_s5_ldstincrampy_ywr_rq,
           pavr_s5_ldstdecrampy_ywr_rq,

           pavr_s5_hwrq_en,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_rf_y_di,
           pavr_iof_rampy,
           pavr_ybpu,
           pavr_iof_rampy
          )
      variable v_ywrrq_sel: std_logic_vector(1 downto 0);
      variable v_yrampy_inc: std_logic_vector(23 downto 0);
      variable v_yrampy_dec: std_logic_vector(23 downto 0);
   begin
      pavr_rf_y_wr <= '0';
      pavr_rf_y_di <= int_to_std_logic_vector(0, pavr_rf_y_di'length);

      v_yrampy_inc := (pavr_iof_rampy & pavr_ybpu) + 1;
      v_yrampy_dec := (pavr_iof_rampy & pavr_ybpu) - 1;

      v_ywrrq_sel := pavr_s5_ldstincrampy_ywr_rq & pavr_s5_ldstdecrampy_ywr_rq;
      case v_ywrrq_sel is
         when "00" =>
            null;
         when "10" =>
            -- Increment Y request, placed by loads and stores with post increment.
            -- Note that RAMPY is modified, if needed, by its own write manager.
            -- Only take action if permitted by older instructions.
            if pavr_s5_hwrq_en='1' then
               pavr_rf_y_wr <= '1';
               if pavr_dm_bigger_than_64K='1' then
                  pavr_rf_y_di <= v_yrampy_inc(15 downto 0);
               else
                  pavr_rf_y_di <= pavr_ybpu + 1;
               end if;
            end if;
         when "01" =>
            -- Decrement Y request, placed by loads and stores with pre decrement.
            -- Only take action if permitted by older instructions.
            if pavr_s5_hwrq_en='1' then
               pavr_rf_y_wr <= '1';
               if pavr_dm_bigger_than_64K='1' then
                  pavr_rf_y_di <= v_yrampy_dec(15 downto 0);
               else
                  pavr_rf_y_di <= pavr_ybpu - 1;
               end if;
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "Y pointer error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process ywr_manager;



   -- Z pointer write port
   -- Set the signals:
   --    - pavr_rf_z_wr
   --    - pavr_rf_z_di
   zwr_manager:
   process(pavr_s5_ldstincrampz_zwr_rq,
           pavr_s5_ldstdecrampz_zwr_rq,
           pavr_s5_lpminc_zwr_rq,
           pavr_s5_elpmincrampz_zwr_rq,

           pavr_s5_hwrq_en,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_zbpu,
           pavr_iof_rampz,
           pavr_rf_z_di
          )
      variable v_zwrrq_sel: std_logic_vector(3 downto 0);
      variable v_zrampz_inc: std_logic_vector(23 downto 0);
      variable v_zrampz_dec: std_logic_vector(23 downto 0);
   begin
      pavr_rf_z_wr <= '0';
      pavr_rf_z_di <= int_to_std_logic_vector(0, pavr_rf_z_di'length);

      v_zrampz_inc := (pavr_iof_rampz & pavr_zbpu) + 1;
      v_zrampz_dec := (pavr_iof_rampz & pavr_zbpu) - 1;

      v_zwrrq_sel := pavr_s5_ldstincrampz_zwr_rq &
                     pavr_s5_ldstdecrampz_zwr_rq &
                     pavr_s5_lpminc_zwr_rq       &
                     pavr_s5_elpmincrampz_zwr_rq;
      case v_zwrrq_sel is
         when "0000" =>
            null;
         when "1000" | "0001" =>
            -- Increment Z request, placed by loads, stores and ELPM with post increment.
            -- Note that RAMPZ is modified, if needed, by its own write manager.
            -- Only take action if permitted by older instructions.
            if pavr_s5_hwrq_en='1' then
               pavr_rf_z_wr <= '1';
               if pavr_dm_bigger_than_64K='1' then
                  pavr_rf_z_di <= v_zrampz_inc(15 downto 0);
               else
                  pavr_rf_z_di <= pavr_zbpu + 1;
               end if;
            end if;
         when "0100" =>
            -- Decrement Z request, placed by loads and stores with pre decrement.
            -- Only take action if permitted by older instructions.
            if pavr_s5_hwrq_en='1' then
               pavr_rf_z_wr <= '1';
               if pavr_dm_bigger_than_64K='1' then
                  pavr_rf_z_di <= v_zrampz_dec(15 downto 0);
               else
                  pavr_rf_z_di <= pavr_zbpu - 1;
               end if;
            end if;
         when "0010" =>
            -- Increment Z request, placed by LPM with post increment.
            -- Only take action if permitted by older instructions.
            if pavr_s5_hwrq_en='1' then
               pavr_rf_z_wr <= '1';
               pavr_rf_z_di <= pavr_zbpu + 1;
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "Z pointer error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process zwr_manager;



   -- BPU write, BPR0-related
   -- Set the signals:
   --    - next_pavr_bpr0
   --    - next_pavr_bpr0_addr
   --    - next_pavr_bpr0_active
   bpr0wr_manager:
   process(pavr_s5_alu_bpr0wr_rq,
           pavr_s6_iof_bpr0wr_rq,
           pavr_s6_daculd_bpr0wr_rq,
           pavr_s5_dacust_bpr0wr_rq,
           pavr_s6_pmdo_bpr0wr_rq,

           pavr_stall_s5,
           pavr_flush_s5,
           pavr_stall_s6,
           pavr_flush_s6,

           pavr_s6_zlsb,
           next_pavr_bpr0,
           next_pavr_bpr0_addr,
           pavr_s5_alu_out,
           pavr_s5_op1bpu,
           pavr_s6_rfwr_addr1,
           pavr_s5_s6_rfwr_addr1,
           pavr_s5_dacust_rf_addr,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_iof_do_shadow_active,
           pavr_iof_do_shadow,
           pavr_dacu_do_shadow_active,
           pavr_dacu_do_shadow,
           pavr_dacu_do,
           pavr_iof_do,
           --pavr_pm_do_shadow_active,
           --pavr_pm_do_shadow,
           pavr_pm_do
          )
      variable v_bpr0wrrq_sel: std_logic_vector(4 downto 0);
   begin
      next_pavr_bpr0          <= int_to_std_logic_vector(0, next_pavr_bpr0'length);
      next_pavr_bpr0_addr     <= int_to_std_logic_vector(0, next_pavr_bpr0_addr'length);
      next_pavr_bpr0_active   <= '0';

      v_bpr0wrrq_sel := pavr_s5_alu_bpr0wr_rq    &
                        pavr_s6_iof_bpr0wr_rq    &
                        pavr_s6_daculd_bpr0wr_rq &
                        pavr_s5_dacust_bpr0wr_rq &
                        pavr_s6_pmdo_bpr0wr_rq;

      case v_bpr0wrrq_sel is
         when "00000" =>
            null;
         when "10000" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               next_pavr_bpr0          <= pavr_s5_alu_out(7 downto 0);
               next_pavr_bpr0_addr     <= pavr_s5_s6_rfwr_addr1;
               next_pavr_bpr0_active   <= '1';
            end if;
         when "01000" =>
            if pavr_stall_s6='0' and pavr_flush_s6='0' then
               if pavr_iof_do_shadow_active='0' then
                  next_pavr_bpr0 <= pavr_iof_do;
               else
                  next_pavr_bpr0 <= pavr_iof_do_shadow;
               end if;
               next_pavr_bpr0_addr     <= pavr_s6_rfwr_addr1;
               next_pavr_bpr0_active   <= '1';
            end if;
         when "00100" =>
            if pavr_stall_s6='0' and pavr_flush_s6='0' then
               if pavr_dacu_do_shadow_active='0' then
                  next_pavr_bpr0 <= pavr_dacu_do;
               else
                  next_pavr_bpr0 <= pavr_dacu_do_shadow;
               end if;
               next_pavr_bpr0_addr     <= pavr_s6_rfwr_addr1;
               next_pavr_bpr0_active   <= '1';
            end if;
         when "00010" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               next_pavr_bpr0          <= pavr_s5_op1bpu;
               next_pavr_bpr0_addr     <= pavr_s5_dacust_rf_addr;
               next_pavr_bpr0_active   <= '1';
            end if;
         when "00001" =>
            if pavr_stall_s6='0' and pavr_flush_s6='0' then
               if pavr_s6_zlsb='0' then
                  -- *** Break a hole through the shadow protocol.
                  --if pavr_pm_do_shadow_active='0' then
                     next_pavr_bpr0 <= pavr_pm_do(7 downto 0);
                  --else
                  --   next_pavr_bpr0 <= pavr_pm_do_shadow(7 downto 0);
                  --end if;
               else
                  --if pavr_pm_do_shadow_active='0' then
                     next_pavr_bpr0 <= pavr_pm_do(15 downto 8);
                  --else
                  --   next_pavr_bpr0 <= pavr_pm_do_shadow(15 downto 8);
                  --end if;
               end if;
               next_pavr_bpr0_addr     <= pavr_s6_rfwr_addr1;
               next_pavr_bpr0_active   <= '1';
            end if;
         when others =>
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "Bypass Unit, chain 0 error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process bpr0wr_manager;



   -- BPU write, BPR1-related
   -- Set the signals:
   --    - next_pavr_bpr1
   --    - next_pavr_bpr1_addr
   --    - next_pavr_bpr1_active
   bpr1wr_manager:
   process(pavr_s5_alu_bpr1wr_rq,
           pavr_s5_dacux_bpr12wr_rq,
           pavr_s5_dacuy_bpr12wr_rq,
           pavr_s5_dacuz_bpr12wr_rq,

           pavr_rf_x_di,
           pavr_rf_y_di,
           pavr_rf_z_di,

           pavr_stall_s5,
           pavr_flush_s5,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           next_pavr_bpr1,
           pavr_s5_alu_out,
           pavr_s5_s61_rfwr_addr2,
           next_pavr_bpr1_addr
          )
      variable v_bpr1wrrq_sel: std_logic_vector(3 downto 0);
   begin
      next_pavr_bpr1          <= int_to_std_logic_vector(0, next_pavr_bpr1'length);
      next_pavr_bpr1_addr     <= int_to_std_logic_vector(0, next_pavr_bpr1_addr'length);
      next_pavr_bpr1_active   <= '0';

      v_bpr1wrrq_sel := pavr_s5_alu_bpr1wr_rq    &
                        pavr_s5_dacux_bpr12wr_rq &
                        pavr_s5_dacuy_bpr12wr_rq &
                        pavr_s5_dacuz_bpr12wr_rq;

      case v_bpr1wrrq_sel is
         when "0000" =>
            null;
         when "1000" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               next_pavr_bpr1          <= pavr_s5_alu_out(15 downto 8);
               next_pavr_bpr1_addr     <= pavr_s5_s61_rfwr_addr2;
               next_pavr_bpr1_active   <= '1';
            end if;
         when "0100" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               next_pavr_bpr1          <= pavr_rf_x_di(7 downto 0);
               next_pavr_bpr1_addr     <= int_to_std_logic_vector(26, next_pavr_bpr1_addr'length);
               next_pavr_bpr1_active   <= '1';
            end if;
         when "0010" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               next_pavr_bpr1          <= pavr_rf_y_di(7 downto 0);
               next_pavr_bpr1_addr     <= int_to_std_logic_vector(28, next_pavr_bpr1_addr'length);
               next_pavr_bpr1_active   <= '1';
            end if;
         when "0001" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               next_pavr_bpr1          <= pavr_rf_z_di(7 downto 0);
               next_pavr_bpr1_addr     <= int_to_std_logic_vector(30, next_pavr_bpr1_addr'length);
               next_pavr_bpr1_active   <= '1';
            end if;
         when others =>
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "Bypass Unit, chain 1 error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process bpr1wr_manager;



   -- BPU write, BPR2-related
   -- Set the signals:
   --    - next_pavr_bpr2
   --    - next_pavr_bpr2_addr
   --    - next_pavr_bpr2_active
   bpr2wr_manager:
   process(pavr_s5_dacux_bpr12wr_rq,
           pavr_s5_dacuy_bpr12wr_rq,
           pavr_s5_dacuz_bpr12wr_rq,

           next_pavr_bpr2,
           next_pavr_bpr2_addr,

           pavr_rf_x_di,
           pavr_rf_y_di,
           pavr_rf_z_di,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_stall_s5,
           pavr_flush_s5
          )
      variable v_bpr2wrrq_sel: std_logic_vector(2 downto 0);
   begin
      next_pavr_bpr2          <= int_to_std_logic_vector(0, next_pavr_bpr2'length);
      next_pavr_bpr2_addr     <= int_to_std_logic_vector(0, next_pavr_bpr2_addr'length);
      next_pavr_bpr2_active   <= '0';

      v_bpr2wrrq_sel := pavr_s5_dacux_bpr12wr_rq &
                        pavr_s5_dacuy_bpr12wr_rq &
                        pavr_s5_dacuz_bpr12wr_rq;

      case v_bpr2wrrq_sel is
         when "000" =>
            null;
         when "100" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               next_pavr_bpr2          <= pavr_rf_x_di(15 downto 8);
               next_pavr_bpr2_addr     <= int_to_std_logic_vector(27, next_pavr_bpr2_addr'length);
               next_pavr_bpr2_active   <= '1';
            end if;
         when "010" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               next_pavr_bpr2          <= pavr_rf_y_di(15 downto 8);
               next_pavr_bpr2_addr     <= int_to_std_logic_vector(29, next_pavr_bpr2_addr'length);
               next_pavr_bpr2_active   <= '1';
            end if;
         when "001" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               next_pavr_bpr2          <= pavr_rf_z_di(15 downto 8);
               next_pavr_bpr2_addr     <= int_to_std_logic_vector(31, next_pavr_bpr2_addr'length);
               next_pavr_bpr2_active   <= '1';
            end if;
         when others =>
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "Bypass Unit, chain 2 error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process bpr2wr_manager;



   -- IOF general port-related (write/read)
   -- Set the signals:
   --    - pavr_iof_di
   --    - pavr_iof_opcode
   --    - pavr_iof_addr
   --    - pavr_iof_bitaddr
   iof_manager:
   process(pavr_s5_iof_rq,
           pavr_s6_iof_rq,
           pavr_s5_dacu_iof_rq,

           pavr_stall_s5,
           pavr_flush_s5,
           pavr_stall_s6,
           pavr_flush_s6,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_s5_op1bpu,
           pavr_s5_iof_opcode,
           pavr_s5_iof_addr,
           pavr_s5_iof_bitaddr,
           pavr_s6_iof_opcode,
           pavr_s6_iof_addr,
           pavr_s6_iof_bitaddr,
           pavr_s5_dacu_iof_opcode,
           pavr_s5_dacu_iof_addr,
           pavr_s5_dacu_iofwr_di,
           pavr_iof_di,
           pavr_iof_opcode,
           pavr_iof_addr,
           pavr_iof_bitaddr,
           pavr_iof_do,
           pavr_iof_do_shadow,
           pavr_iof_do_shadow_active
          )
      variable v_iofrq_sel: std_logic_vector(2 downto 0);
   begin
      pavr_iof_di       <= int_to_std_logic_vector(0, pavr_iof_di'length);
      pavr_iof_opcode   <= int_to_std_logic_vector(0, pavr_iof_opcode'length);
      pavr_iof_addr     <= int_to_std_logic_vector(0, pavr_iof_addr'length);
      pavr_iof_bitaddr  <= int_to_std_logic_vector(0, pavr_iof_bitaddr'length);

      v_iofrq_sel := pavr_s5_iof_rq & pavr_s6_iof_rq & pavr_s5_dacu_iof_rq;
      case v_iofrq_sel is
         when "000" =>
            pavr_iof_di       <= int_to_std_logic_vector(0, pavr_iof_di'length);
            pavr_iof_opcode   <= int_to_std_logic_vector(0, pavr_iof_opcode'length);
            pavr_iof_addr     <= int_to_std_logic_vector(0, pavr_iof_addr'length);
            pavr_iof_bitaddr  <= int_to_std_logic_vector(0, pavr_iof_bitaddr'length);
         when "100" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               pavr_iof_di       <= pavr_s5_op1bpu;
               pavr_iof_opcode   <= pavr_s5_iof_opcode;
               pavr_iof_addr     <= pavr_s5_iof_addr;
               pavr_iof_bitaddr  <= pavr_s5_iof_bitaddr;
            end if;
         when "010" =>
            if pavr_stall_s6='0' and pavr_flush_s6='0' then
               if pavr_s6_iof_opcode=pavr_iof_opcode_ldbit then
                  pavr_iof_di    <= pavr_s5_op1bpu;
               else
                  if pavr_iof_do_shadow_active='0' then
                     pavr_iof_di <= pavr_iof_do;
                  else
                     pavr_iof_di <= pavr_iof_do_shadow;
                  end if;
               end if;
               pavr_iof_opcode   <= pavr_s6_iof_opcode;
               pavr_iof_addr     <= pavr_s6_iof_addr;
               pavr_iof_bitaddr  <= pavr_s6_iof_bitaddr;
            end if;
         when "001" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               pavr_iof_di       <= pavr_s5_dacu_iofwr_di;
               pavr_iof_opcode   <= pavr_s5_dacu_iof_opcode;
               pavr_iof_addr     <= pavr_s5_dacu_iof_addr;
               pavr_iof_bitaddr  <= int_to_std_logic_vector(0, pavr_iof_bitaddr'length);
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "IO File error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process iof_manager;



   -- SREG-related
   -- Set the signals:
   --    - pavr_iof_sreg_wr
   --    - pavr_iof_sreg_di
   sregwr_manager:
   process(pavr_s5_alu_sregwr_rq,
           pavr_s5_clriflag_sregwr_rq,
           pavr_s5_setiflag_sregwr_rq,

           pavr_stall_s5,
           pavr_flush_s5,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_iof_sreg,
           pavr_iof_sreg_di,
           pavr_s5_alu_flagsout
          )
      variable v_sregwrrq_sel: std_logic_vector(2 downto 0);
   begin
      pavr_iof_sreg_wr <= '0';
      pavr_iof_sreg_di <= int_to_std_logic_vector(0, pavr_iof_sreg_di'length);

      v_sregwrrq_sel := pavr_s5_alu_sregwr_rq & pavr_s5_clriflag_sregwr_rq & pavr_s5_setiflag_sregwr_rq;
      case v_sregwrrq_sel is
         when "000" =>
            pavr_iof_sreg_wr <= '0';
            pavr_iof_sreg_di <= int_to_std_logic_vector(0, pavr_iof_sreg_di'length);
         when "100" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               pavr_iof_sreg_wr <= '1';
               pavr_iof_sreg_di <= pavr_iof_sreg(7 downto 6) & pavr_s5_alu_flagsout;
            end if;
         when "010" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               pavr_iof_sreg_wr <= '1';
               pavr_iof_sreg_di <= '0' & pavr_iof_sreg(6 downto 0);
            end if;
         when "001" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               pavr_iof_sreg_wr <= '1';
               pavr_iof_sreg_di <= '1' & pavr_iof_sreg(6 downto 0);
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "SREG error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process sregwr_manager;



   -- SP-related
   -- Set the signals:
   --    - pavr_iof_spl_wr
   --    - pavr_iof_spl_di
   --    - pavr_iof_sph_wr
   --    - pavr_iof_sph_di
   spwr_manager:
   process(pavr_s5_inc_spwr_rq, pavr_s5_dec_spwr_rq,
           pavr_s5_calldec_spwr_rq, pavr_s51_calldec_spwr_rq, pavr_s52_calldec_spwr_rq,
           pavr_s5_retinc2_spwr_rq, pavr_s51_retinc_spwr_rq,

           pavr_stall_s5,
           pavr_flush_s5,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_iof_spl_di,
           pavr_iof_sph_di,
           pavr_iof_sph,
           pavr_iof_spl
          )
      variable v_spwrrq_sel: std_logic_vector(6 downto 0);
      variable v_sp_inc  : std_logic_vector(15 downto 0);
      variable v_sp_inc2 : std_logic_vector(15 downto 0);
      variable v_sp_dec  : std_logic_vector(15 downto 0);
   begin
      pavr_iof_spl_wr <= '0';
      pavr_iof_spl_di <= int_to_std_logic_vector(0, pavr_iof_spl_di'length);
      pavr_iof_sph_wr <= '0';
      pavr_iof_sph_di <= int_to_std_logic_vector(0, pavr_iof_sph_di'length);

      v_sp_inc  := (pavr_iof_sph & pavr_iof_spl) + 1;
      v_sp_inc2 := (pavr_iof_sph & pavr_iof_spl) + 2;
      v_sp_dec  := (pavr_iof_sph & pavr_iof_spl) - 1;
      v_spwrrq_sel := pavr_s5_inc_spwr_rq & pavr_s5_dec_spwr_rq &
                      pavr_s5_calldec_spwr_rq & pavr_s51_calldec_spwr_rq & pavr_s52_calldec_spwr_rq &
                      pavr_s5_retinc2_spwr_rq & pavr_s51_retinc_spwr_rq;

      case v_spwrrq_sel is
         -- No SP write requests. Set SP inputs to a most benign state. Only change inputs when write is requested, to minimize power consumption.
         when "0000000" =>
            pavr_iof_spl_wr <= '0';
            pavr_iof_spl_di <= int_to_std_logic_vector(0, pavr_iof_spl_di'length);
            pavr_iof_sph_wr <= '0';
            pavr_iof_sph_di <= int_to_std_logic_vector(0, pavr_iof_sph_di'length);
         -- Increment SP request. For devices with 256B or less of Unified Memory, only update lower byte of SP. For the other devices, modify all 16 bits of SP.
         when "1000000" =>
            -- Stall capability in s5.
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               if pavr_dm_bigger_than_256='0' then
                  pavr_iof_spl_wr <= '1';
                  pavr_iof_spl_di <= v_sp_inc(7 downto 0);
                  pavr_iof_sph_wr <= '0';
                  pavr_iof_sph_di <= int_to_std_logic_vector(0, pavr_iof_sph_di'length);
               else
                  pavr_iof_spl_wr <= '1';
                  pavr_iof_spl_di <= v_sp_inc(7 downto 0);
                  pavr_iof_sph_wr <= '1';
                  pavr_iof_sph_di <= v_sp_inc(15 downto 8);
               end if;
            end if;
         -- Increment SP request. For devices with 256B or less of Unified Memory, only update lower byte of SP. For the other devices, modify all 16 bits of SP.
         when "0000001" =>
            if pavr_dm_bigger_than_256='0' then
               pavr_iof_spl_wr <= '1';
               pavr_iof_spl_di <= v_sp_inc(7 downto 0);
               pavr_iof_sph_wr <= '0';
               pavr_iof_sph_di <= int_to_std_logic_vector(0, pavr_iof_sph_di'length);
            else
               pavr_iof_spl_wr <= '1';
               pavr_iof_spl_di <= v_sp_inc(7 downto 0);
               pavr_iof_sph_wr <= '1';
               pavr_iof_sph_di <= v_sp_inc(15 downto 8);
            end if;
         -- Increment by 2 SP request.
         when "0000010" =>
            -- Stall capability in s5.
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               if pavr_dm_bigger_than_256='0' then
                  pavr_iof_spl_wr <= '1';
                  pavr_iof_spl_di <= v_sp_inc2(7 downto 0);
                  pavr_iof_sph_wr <= '0';
                  pavr_iof_sph_di <= int_to_std_logic_vector(0, pavr_iof_sph_di'length);
               else
                  pavr_iof_spl_wr <= '1';
                  pavr_iof_spl_di <= v_sp_inc2(7 downto 0);
                  pavr_iof_sph_wr <= '1';
                  pavr_iof_sph_di <= v_sp_inc2(15 downto 8);
               end if;
            end if;
         -- Decrement SP request.
         when "0100000" | "0010000" =>
            -- Stall capability in s5.
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               if pavr_dm_bigger_than_256='0' then
                  pavr_iof_spl_wr <= '1';
                  pavr_iof_spl_di <= v_sp_dec(7 downto 0);
                  pavr_iof_sph_wr <= '0';
                  pavr_iof_sph_di <= int_to_std_logic_vector(0, pavr_iof_sph_di'length);
               else
                  pavr_iof_spl_wr <= '1';
                  pavr_iof_spl_di <= v_sp_dec(7 downto 0);
                  pavr_iof_sph_wr <= '1';
                  pavr_iof_sph_di <= v_sp_dec(15 downto 8);
               end if;
            end if;
         -- Decrement SP request.
         when "0000100" | "0001000" =>
            if pavr_dm_bigger_than_256='0' then
               pavr_iof_spl_wr <= '1';
               pavr_iof_spl_di <= v_sp_dec(7 downto 0);
               pavr_iof_sph_wr <= '0';
               pavr_iof_sph_di <= int_to_std_logic_vector(0, pavr_iof_sph_di'length);
            else
               pavr_iof_spl_wr <= '1';
               pavr_iof_spl_di <= v_sp_dec(7 downto 0);
               pavr_iof_sph_wr <= '1';
               pavr_iof_sph_di <= v_sp_dec(15 downto 8);
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "SP error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process spwr_manager;



   -- RAMPX-related
   -- Set the signals:
   --    - pavr_iof_rampx_wr
   --    - pavr_iof_rampx_di
   rampxwr_manager:
   process(pavr_s5_ldstincrampx_xwr_rq,
           pavr_s5_ldstdecrampx_xwr_rq,

           pavr_stall_s5,
           pavr_flush_s5,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_iof_rampx_di,
           pavr_iof_rampx,
           pavr_xbpu
          )
      variable v_rampxwrrq_sel: std_logic_vector(1 downto 0);
      variable v_xrampx_inc : std_logic_vector(23 downto 0);
      variable v_xrampx_dec : std_logic_vector(23 downto 0);
   begin
      pavr_iof_rampx_wr <= '0';
      pavr_iof_rampx_di <= int_to_std_logic_vector(0, pavr_iof_rampx_di'length);

      v_xrampx_inc := (pavr_iof_rampx & pavr_xbpu) + 1;
      v_xrampx_dec := (pavr_iof_rampx & pavr_xbpu) - 1;

      v_rampxwrrq_sel := pavr_s5_ldstincrampx_xwr_rq & pavr_s5_ldstdecrampx_xwr_rq;
      case v_rampxwrrq_sel is
         -- No RAMPX write requests. Nothing to be done.
         when "00" =>
            null;
         -- Increment RAMPX:X request.
         when "10" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               if pavr_dm_bigger_than_64K='1' then
                  pavr_iof_rampx_wr <= '1';
                  pavr_iof_rampx_di <= v_xrampx_inc(23 downto 16);
               end if;
            end if;
         -- Decrement RAMPX:X request.
         when "01" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               if pavr_dm_bigger_than_64K='1' then
                  pavr_iof_rampx_wr <= '1';
                  pavr_iof_rampx_di <= v_xrampx_dec(23 downto 16);
               end if;
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "RAMPX error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process rampxwr_manager;



   -- RAMPY-related
   -- Set the signals:
   --    - pavr_iof_rampy_wr
   --    - pavr_iof_rampy_di
   rampywr_manager:
   process(pavr_s5_ldstincrampy_ywr_rq,
           pavr_s5_ldstdecrampy_ywr_rq,

           pavr_stall_s5,
           pavr_flush_s5,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_iof_rampy_di,
           pavr_iof_rampy,
           pavr_ybpu
          )
      variable v_rampywrrq_sel: std_logic_vector(1 downto 0);
      variable v_yrampy_inc : std_logic_vector(23 downto 0);
      variable v_yrampy_dec : std_logic_vector(23 downto 0);
   begin
      pavr_iof_rampy_wr <= '0';
      pavr_iof_rampy_di <= int_to_std_logic_vector(0, pavr_iof_rampy_di'length);

      v_yrampy_inc := (pavr_iof_rampy & pavr_ybpu) + 1;
      v_yrampy_dec := (pavr_iof_rampy & pavr_ybpu) - 1;

      v_rampywrrq_sel := pavr_s5_ldstincrampy_ywr_rq & pavr_s5_ldstdecrampy_ywr_rq;
      case v_rampywrrq_sel is
         -- No RAMPY write requests. Nothing to be done.
         when "00" =>
            null;
         -- Increment RAMPY:Y request.
         when "10" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               if pavr_dm_bigger_than_64K='1' then
                  pavr_iof_rampy_wr <= '1';
                  pavr_iof_rampy_di <= v_yrampy_inc(23 downto 16);
               end if;
            end if;
         -- Decrement RAMPY:Y request.
         when "01" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               if pavr_dm_bigger_than_64K='1' then
                  pavr_iof_rampy_wr <= '1';
                  pavr_iof_rampy_di <= v_yrampy_dec(23 downto 16);
               end if;
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "RAMPY error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process rampywr_manager;



   -- RAMPZ-related
   -- Set the signals:
   --    - pavr_iof_rampz_wr
   --    - pavr_iof_rampz_di
   rampzwr_manager:
   process(pavr_s5_ldstincrampz_zwr_rq,
           pavr_s5_ldstdecrampz_zwr_rq,
           pavr_s5_elpmincrampz_zwr_rq,

           pavr_stall_s5,
           pavr_flush_s5,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_iof_rampz_di,
           pavr_iof_rampz,
           pavr_zbpu
          )
      variable v_rampzwrrq_sel: std_logic_vector(2 downto 0);
      variable v_zrampz_inc : std_logic_vector(23 downto 0);
      variable v_zrampz_dec : std_logic_vector(23 downto 0);
   begin
      pavr_iof_rampz_wr <= '0';
      pavr_iof_rampz_di <= int_to_std_logic_vector(0, pavr_iof_rampz_di'length);

      v_zrampz_inc := (pavr_iof_rampz & pavr_zbpu) + 1;
      v_zrampz_dec := (pavr_iof_rampz & pavr_zbpu) - 1;

      v_rampzwrrq_sel := pavr_s5_ldstincrampz_zwr_rq & pavr_s5_ldstdecrampz_zwr_rq & pavr_s5_elpmincrampz_zwr_rq;
      case v_rampzwrrq_sel is
         -- No RAMPZ write requests. Nothing to be done.
         when "000" =>
            null;
         -- Increment RAMPZ:Z request.
         when "100" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               if pavr_dm_bigger_than_64K='1' then
                  pavr_iof_rampz_wr <= '1';
                  pavr_iof_rampz_di <= v_zrampz_inc(23 downto 16);
               end if;
            end if;
         -- Decrement RAMPZ:Z request.
         when "010" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               if pavr_dm_bigger_than_64K='1' then
                  pavr_iof_rampz_wr <= '1';
                  pavr_iof_rampz_di <= v_zrampz_dec(23 downto 16);
               end if;
            end if;
         -- Increment RAMPZ:Z request from ELPM instruction.
         when "001" =>
            if pavr_stall_s5='0' and pavr_flush_s5='0' then
               pavr_iof_rampz_wr <= '1';
               pavr_iof_rampz_di <= v_zrampz_inc(23 downto 16);
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "RAMPZ error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process rampzwr_manager;



   -- RAMPD-related
   -- *** Void manager. No instruction needs to write RAMPD.
   rampdwr_manager:
   process(pavr_iof_rampd_di)
   begin
      pavr_iof_rampd_wr <= '0';
      pavr_iof_rampd_di <= int_to_std_logic_vector(0, pavr_iof_rampd_di'length);
   end process rampdwr_manager;



   -- EIND-related
   -- *** Void manager. No instruction needs to write EIND.
   eindwr_manager:
   process(pavr_iof_eind_di)
   begin
      pavr_iof_eind_wr <= '0';
      pavr_iof_eind_di <= int_to_std_logic_vector(0, pavr_iof_eind_di'length);
   end process eindwr_manager;



   -- ALU-related
   -- The ALU is not a potentially conflicting resource. There's no need to
   --    arbitrate requests to ALU. This section only takes care of setting ALU-
   --    related signals, that feed ALU inputs and connect its outputs to other
   --    modules.
   -- Set the signals:
   --    - pavr_s5_alu_op1
   --    - pavr_s5_alu_op2
   alu_manager:
   process(pavr_s5_alu_op1,
           pavr_s5_alu_op2,
           pavr_s5_alu_op1_hi8_sel,
           pavr_s5_op2bpu,
           pavr_s5_op1bpu,
           pavr_s5_alu_op2_sel,
           pavr_s5_op2bpu,
           pavr_s5_k8
          )
   begin
      pavr_s5_alu_op1 <= int_to_std_logic_vector(0, pavr_s5_alu_op1'length);
      pavr_s5_alu_op2 <= int_to_std_logic_vector(0, pavr_s5_alu_op2'length);

      case pavr_s5_alu_op1_hi8_sel is
         when pavr_alu_op1_hi8_sel_zero =>
            pavr_s5_alu_op1(15 downto 8) <= int_to_std_logic_vector(0, 8);
         when others =>
            pavr_s5_alu_op1(15 downto 8) <= pavr_s5_op2bpu;
      end case;

      pavr_s5_alu_op1( 7 downto 0) <= pavr_s5_op1bpu;

      case pavr_s5_alu_op2_sel is
         when pavr_alu_op2_sel_op2bpu =>
            pavr_s5_alu_op2 <= pavr_s5_op2bpu;
         when pavr_alu_op2_sel_k8 =>
            pavr_s5_alu_op2 <= pavr_s5_k8;
         when pavr_alu_op2_sel_1 =>
            pavr_s5_alu_op2 <= int_to_std_logic_vector(1, 8);
         when others =>
            pavr_s5_alu_op2 <= int_to_std_logic_vector(-1, 8);
      end case;

   end process alu_manager;



   -- DACU read and write-related
   -- Set the signals:
   --    - pavr_s5_dacu_rfrd1_rq
   --    - pavr_s5_dacust_rf_addr
   --    - pavr_s5_dacu_rfwr_rq
   --    - pavr_s5_dacu_rfwr_di
   --
   --    - pavr_s5_dacu_iof_rq
   --    - pavr_s5_dacu_iof_addr
   --    - pavr_s5_dacu_iof_opcode
   --    - pavr_s5_dacu_iofwr_di
   --
   --    - pavr_s5_dacu_dmrd_rq
   --    - pavr_s5_dacu_dm_addr
   --    - pavr_s5_dacu_dmwr_rq
   --    - pavr_s5_dacu_dmwr_di
   --
   --    - pavr_s5_dacust_bpr0wr_rq
   --
   --    - pavr_s5_dacudo_sel
   --    - pavr_s6_dacudo_sel
   --
   --    - pavr_dacu_do
   dacu_manager:
   process(
           -- DACU read-related requests
           pavr_s5_x_dacurd_rq, pavr_s5_y_dacurd_rq, pavr_s5_z_dacurd_rq,
           pavr_s5_sp_dacurd_rq,
           pavr_s5_k16_dacurd_rq,
           pavr_s5_pchi8_dacurd_rq, pavr_s51_pcmid8_dacurd_rq, pavr_s52_pclo8_dacurd_rq,

           -- DACU write-related requests
           pavr_s5_x_dacuwr_rq, pavr_s5_y_dacuwr_rq, pavr_s5_z_dacuwr_rq,
           pavr_s5_sp_dacuwr_rq,
           pavr_s5_k16_dacuwr_rq,
           pavr_s5_pclo8_dacuwr_rq, pavr_s51_pcmid8_dacuwr_rq, pavr_s52_pchi8_dacuwr_rq,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_xbpu,
           pavr_ybpu,
           pavr_zbpu,
           pavr_s5_dacust_rf_addr,
           pavr_s5_dacu_rfwr_di,
           pavr_s5_dacu_iof_addr,
           pavr_s5_dacu_iofwr_di,
           pavr_s5_dacu_dm_addr,
           pavr_s5_dacu_dmwr_di,
           pavr_s5_dacu_iof_opcode,
           pavr_s5_dacudo_sel,
           pavr_dacu_do,
           pavr_s4_dacu_q,
           pavr_iof_rampx,
           pavr_iof_rampy,
           pavr_iof_rampz,
           pavr_iof_spl,
           pavr_iof_sph,
           pavr_s5_k16,
           pavr_iof_rampd,
           pavr_s5_rf_dacu_q,
           pavr_s5_iof_dacu_q,
           pavr_s5_dm_dacu_q,
           pavr_s6_dacudo_sel,
           pavr_s5_op1bpu,
           pavr_s5_pc,
           pavr_rf_rd1_do,
           pavr_iof_do,
           pavr_dm_do
          )
      variable tmpv_rd   : std_logic_vector(7 downto 0);
      variable tmpv_wr   : std_logic_vector(7 downto 0);
      variable tmpv_rdwr : std_logic_vector(7 downto 0);
      variable v_dacu_wr_di: std_logic_vector(7 downto 0);
      variable v_pavr_s5_dacu_ptr : std_logic_vector(23 downto 0);
      variable v_pavr_s5_rf_dacu_addrtest  : std_logic_vector(24 downto 0);
      variable v_pavr_s5_iof_dacu_addrtest : std_logic_vector(24 downto 0);
      variable v_pavr_s5_dm_dacu_addrtest  : std_logic_vector(24 downto 0);
      variable v_pavr_dacu_device_sel : std_logic_vector(pavr_dacu_device_sel_w - 1 downto 0);
   begin
      pavr_s5_dacu_rfrd1_rq <= '0';
      pavr_s5_dacu_rfwr_rq  <= '0';
      pavr_s5_dacu_rfwr_di <= int_to_std_logic_vector(0, pavr_s5_dacu_rfwr_di'length);
      pavr_s5_dacu_iof_rq <= '0';
      pavr_s5_dacu_iofwr_di <= int_to_std_logic_vector(0, pavr_s5_dacu_iofwr_di'length);
      pavr_s5_dacu_dmrd_rq <= '0';
      pavr_s5_dacu_dmwr_rq <= '0';
      pavr_s5_dacu_dmwr_di <= int_to_std_logic_vector(0, pavr_s5_dacu_dmwr_di'length);
      pavr_s5_dacust_bpr0wr_rq <= '0';
      pavr_s5_dacust_rf_addr  <= int_to_std_logic_vector(0, pavr_s5_dacust_rf_addr'length);
      pavr_s5_dacu_iof_addr <= int_to_std_logic_vector(0, pavr_s5_dacu_iof_addr'length);
      pavr_s5_dacu_dm_addr  <= int_to_std_logic_vector(0, pavr_s5_dacu_dm_addr'length);
      pavr_s5_dacu_iof_opcode <= int_to_std_logic_vector(0, pavr_s5_dacu_iof_opcode'length);
      pavr_s5_dacudo_sel <= int_to_std_logic_vector(0, pavr_s5_dacudo_sel'length);
      pavr_dacu_do <= int_to_std_logic_vector(0, pavr_dacu_do'length);

      pavr_s4_iof_dacu_q <= pavr_s4_dacu_q - 32;
      pavr_s4_dm_dacu_q  <= pavr_s4_dacu_q - 96;

      tmpv_rd := int_to_std_logic_vector(0, tmpv_rd'length);
      tmpv_wr := int_to_std_logic_vector(0, tmpv_wr'length);
      tmpv_rdwr := int_to_std_logic_vector(0, tmpv_rdwr'length);
      v_dacu_wr_di := int_to_std_logic_vector(0, v_dacu_wr_di'length);
      v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, v_pavr_s5_dacu_ptr'length);
      v_pavr_s5_rf_dacu_addrtest  := int_to_std_logic_vector(0, v_pavr_s5_rf_dacu_addrtest'length);
      v_pavr_s5_iof_dacu_addrtest := int_to_std_logic_vector(0, v_pavr_s5_iof_dacu_addrtest'length);
      v_pavr_s5_dm_dacu_addrtest  := int_to_std_logic_vector(0, v_pavr_s5_dm_dacu_addrtest'length);
      v_pavr_dacu_device_sel := int_to_std_logic_vector(0, v_pavr_dacu_device_sel'length);

      -- This vector holds the DACU read requests.
      tmpv_rd := pavr_s5_x_dacurd_rq & pavr_s5_y_dacurd_rq & pavr_s5_z_dacurd_rq &
                 pavr_s5_sp_dacurd_rq &
                 pavr_s5_k16_dacurd_rq &
                 pavr_s5_pchi8_dacurd_rq & pavr_s51_pcmid8_dacurd_rq & pavr_s52_pclo8_dacurd_rq;
      -- This vector holds the DACU write requests.
      tmpv_wr := pavr_s5_x_dacuwr_rq & pavr_s5_y_dacuwr_rq & pavr_s5_z_dacuwr_rq &
                 pavr_s5_sp_dacuwr_rq &
                 pavr_s5_k16_dacuwr_rq &
                 pavr_s5_pclo8_dacuwr_rq & pavr_s51_pcmid8_dacuwr_rq & pavr_s52_pchi8_dacuwr_rq;
      -- This vector holds the requests to DACU access (for write or read). Note
      --    that (coincidentaly or not) all the DACU access requests for read have
      --    a mirror pair for write access. OR-ing read with write access requests
      --    (taking care to pair correctly read and write mirror images) will
      --    result in a pattern that can be used to select the proper source for
      --    the DACU address, when computing the Unified Memory address.
      tmpv_rdwr := tmpv_rd or tmpv_wr;
      case tmpv_rdwr is
         -- No DACU access requests.
         when "00000000" =>
            v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, v_pavr_s5_dacu_ptr'length);
         -- DACU access requests from/to Unified Memory address given by X (and RAMPX) pointer register.
         when "10000000" =>
            if pavr_dm_bigger_than_256='0' then
               v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, 16) & pavr_xbpu(7 downto 0);
            elsif pavr_dm_bigger_than_64K='0' then
               v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, 8) & pavr_xbpu;
            else
               v_pavr_s5_dacu_ptr := pavr_iof_rampx & pavr_xbpu;
            end if;
         -- DACU access requests from/to Unified Memory address given by Y (and RAMPY) pointer register.
         when "01000000" =>
            if pavr_dm_bigger_than_256='0' then
               v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, 16) & pavr_ybpu(7 downto 0);
            elsif pavr_dm_bigger_than_64K='0' then
               v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, 8) & pavr_ybpu;
            else
               v_pavr_s5_dacu_ptr := pavr_iof_rampy & pavr_ybpu;
            end if;
         -- DACU access requests from/to Unified Memory address given by Z (and RAMPZ) pointer register.
         when "00100000" =>
            if pavr_dm_bigger_than_256='0' then
               v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, 16) & pavr_zbpu(7 downto 0);
            elsif pavr_dm_bigger_than_64K='0' then
               v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, 8) & pavr_zbpu;
            else
               v_pavr_s5_dacu_ptr := pavr_iof_rampz & pavr_zbpu;
            end if;
         -- DACU access requests from/to Unified Memory address given by SP.
         when "00010000" |
              "00000100" | "00000010" | "00000001" =>
            if pavr_dm_bigger_than_256='0' then
               v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, 16) & pavr_iof_spl;
            else
               v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, 8) & pavr_iof_sph & pavr_iof_spl;
            end if;
         -- DACU access requests from/to Unified Memory address given by a 16 bit constant (pavr_s5_k16).
         when "00001000" =>
            if pavr_dm_bigger_than_256='0' then
               v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, 16) & pavr_s5_k16(7 downto 0);
            elsif pavr_dm_bigger_than_64K='0' then
               v_pavr_s5_dacu_ptr := int_to_std_logic_vector(0, 8) & pavr_s5_k16;
            else
               v_pavr_s5_dacu_ptr := pavr_iof_rampd & pavr_s5_k16;
            end if;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "DACU error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;

      end case;

      v_pavr_s5_rf_dacu_addrtest  := v_pavr_s5_dacu_ptr + sign_extend(pavr_s5_rf_dacu_q, 25);
      v_pavr_s5_iof_dacu_addrtest := v_pavr_s5_dacu_ptr + sign_extend(pavr_s5_iof_dacu_q, 25);
      v_pavr_s5_dm_dacu_addrtest  := v_pavr_s5_dacu_ptr + sign_extend(pavr_s5_dm_dacu_q, 25);

      -- If none of the 3 tests below results in positive addresses, use DM.
      v_pavr_dacu_device_sel := pavr_dacu_device_sel_dm;
      -- Test which device to use, RF/IOF/DM. Remember that the Unified Memory is composed of these 3 entities.
      if v_pavr_s5_rf_dacu_addrtest(24)='0' then
         v_pavr_dacu_device_sel := pavr_dacu_device_sel_rf;
      end if;
      if v_pavr_s5_iof_dacu_addrtest(24)='0' then
         v_pavr_dacu_device_sel := pavr_dacu_device_sel_iof;
      end if;
      if v_pavr_s5_dm_dacu_addrtest(24)='0' then
         v_pavr_dacu_device_sel := pavr_dacu_device_sel_dm;
      end if;
      -- Now we know what device to access during UM requests. That info is stored in `v_pavr_dacu_device_sel'.

      -- Manage DACU read requests.
      if tmpv_rd/="00000000" then
         case v_pavr_dacu_device_sel is
            -- UM read request is decoded into RF read port 1 access request.
            when pavr_dacu_device_sel_rf =>
               pavr_s5_dacu_rfrd1_rq   <= '1';
               pavr_s5_dacust_rf_addr  <= v_pavr_s5_rf_dacu_addrtest(4 downto 0);
               pavr_s5_dacudo_sel      <= pavr_dacudo_sel_rfrd1do;
            -- UM read request is decoded into IOF port access request.
            when pavr_dacu_device_sel_iof =>
               pavr_s5_dacu_iof_rq     <= '1';
               pavr_s5_dacu_iof_addr   <= v_pavr_s5_iof_dacu_addrtest(5 downto 0);
               pavr_s5_dacu_iof_opcode <= pavr_iof_opcode_rdbyte;
               pavr_s5_dacudo_sel      <= pavr_dacudo_sel_iofdo;
            -- UM read request is decoded into DM port access request.
            when others =>
               pavr_s5_dacu_dmrd_rq <= '1';
               pavr_s5_dacu_dm_addr <= v_pavr_s5_dm_dacu_addrtest(23 downto 0);
               pavr_s5_dacudo_sel   <= pavr_dacudo_sel_dmdo;
         end case;
      end if;

      -- DACU data out. Select data out from proper device (RF/IOF/DM).
      case pavr_s6_dacudo_sel is
         -- *** Bypass shadow protocol.
         when pavr_dacudo_sel_rfrd1do =>
            --if pavr_rf_do_shadow_active='0' then
               pavr_dacu_do   <= pavr_rf_rd1_do;
            --else
            --   pavr_dacu_do <= pavr_rf_rd1_do_shadow;
            --end if;
         when pavr_dacudo_sel_iofdo =>
            --if pavr_iof_do_shadow_active='0' then
               pavr_dacu_do   <= pavr_iof_do;
            --else
            --   pavr_dacu_do <= pavr_iof_do_shadow;
            --end if;
         -- When pavr_dacudo_sel_dmdo
         when others =>
            --if pavr_dm_do_shadow_active='0' then
               pavr_dacu_do   <= pavr_dm_do;
            --else
            --   pavr_dacu_do <= pavr_dm_do_shadow;
            --end if;
      end case;

      -- Manage DACU write requests.
      case tmpv_wr is
         -- Nothing to be done.
         when "00000000" =>
            null;
         -- X, Y, Z, SP or k16 DACUWR request
         when "10000000" | "01000000" | "00100000" | "00010000"  | "00001000"=>
            v_dacu_wr_di := pavr_s5_op1bpu;
         -- SP DACUWR request, data in = pclo8
         when  "00000100" =>
            v_dacu_wr_di := pavr_s5_pc(7 downto 0);
         -- SP DACUWR request, data in = pcmid8
         when  "00000010" =>
            v_dacu_wr_di := pavr_s5_pc(15 downto 8);
         -- SP DACUWR request, data in = pchi8
         when  others =>
            v_dacu_wr_di := "00" & pavr_s5_pc(21 downto 16);
      end case;
      if tmpv_wr/="00000000" then
         case v_pavr_dacu_device_sel is
            -- UM write request is decoded into RF write port access request.
            when pavr_dacu_device_sel_rf =>
               pavr_s5_dacu_rfwr_rq       <= '1';
               pavr_s5_dacust_rf_addr     <= v_pavr_s5_rf_dacu_addrtest(4 downto 0);
               pavr_s5_dacust_bpr0wr_rq   <= '1';                          -- *** Take care to also update BPU. Note that it will happen next clock.
               pavr_s5_dacu_rfwr_di       <= v_dacu_wr_di;
            -- UM write request is decoded into IOF port access request.
            when pavr_dacu_device_sel_iof =>
               pavr_s5_dacu_iof_rq     <= '1';
               pavr_s5_dacu_iof_addr   <= v_pavr_s5_iof_dacu_addrtest(5 downto 0);
               pavr_s5_dacu_iof_opcode <= pavr_iof_opcode_wrbyte;
               pavr_s5_dacu_iofwr_di   <= v_dacu_wr_di;
            -- UM write request is decoded into DM port access request.
            when others =>
               pavr_s5_dacu_dmwr_rq <= '1';
               pavr_s5_dacu_dm_addr <= v_pavr_s5_dm_dacu_addrtest(23 downto 0);
               pavr_s5_dacu_dmwr_di <= v_dacu_wr_di;
         end case;
      end if;
   end process dacu_manager;



   -- DM-related
   -- Set the signals:
   --    - pavr_dm_wr
   --    - pavr_dm_addr
   --    - pavr_dm_di
   dm_manager:
   process(pavr_s5_dacu_dmrd_rq,
           pavr_s5_dacu_dmwr_rq,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_dm_addr,
           pavr_dm_di,
           pavr_s5_dacu_dm_addr,
           pavr_s5_dacu_dmwr_di
          )
      variable v_dmrq_sel: std_logic_vector(1 downto 0);
   begin
      pavr_dm_wr     <= '0';
      pavr_dm_addr   <= int_to_std_logic_vector(0, pavr_dm_addr'length);
      pavr_dm_di     <= int_to_std_logic_vector(0, pavr_dm_di'length);

      -- Note that DACU is the only unit that requests read/write accesses to DM.
      v_dmrq_sel := pavr_s5_dacu_dmrd_rq & pavr_s5_dacu_dmwr_rq;
      case v_dmrq_sel is
         -- No DM access requests. Nothing to be done.
         when "00" =>
            null;
         -- Read DM request
         when "10" =>
            pavr_dm_wr     <= '0';
            pavr_dm_addr   <= pavr_s5_dacu_dm_addr(pavr_dm_addr'length - 1 downto 0);
            pavr_dm_di     <= int_to_std_logic_vector(0, pavr_dm_di'length);
         -- Write DM request
         when "01" =>
            pavr_dm_wr     <= '1';
            pavr_dm_addr   <= pavr_s5_dacu_dm_addr(pavr_dm_addr'length - 1 downto 0);
            pavr_dm_di     <= pavr_s5_dacu_dmwr_di;
         when others =>
            -- Multiple requests shouldn't happen.
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "Data Memory error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;
   end process dm_manager;



   -- PM access-related
   -- Load PC here. Some PM access requests modify the PC, others don't. The only
   --    PM requests that don't modify the PC are the loads from PM (LPM and ELPM
   --    instructions). The other requests correspond to instructions that
   --    want to modify the instruction flow, thus modify the PC (jumps, branches
   --    calls, returns).
   -- Set the signals:
   --    - pavr_pm_addr_int
   --    - next_pavr_s1_pc
   --    - next_pavr_s2_pmdo_valid
   pm_manager:
   process(pavr_s5_lpm_pm_rq,
           pavr_s5_elpm_pm_rq,
           pavr_s4_z_pm_rq,
           pavr_s4_zeind_pm_rq,
           pavr_s4_k22abs_pm_rq,
           pavr_s4_k12rel_pm_rq,
           pavr_s6_branch_pm_rq,
           pavr_s6_skip_pm_rq,
           pavr_s61_skip_pm_rq,
           pavr_s4_k22int_pm_rq,
           pavr_s54_ret_pm_rq,

           pavr_s4_hwrq_en,
           pavr_s5_hwrq_en,
           pavr_s6_hwrq_en,
           pavr_s61_hwrq_en,

           pavr_stall_s1,
           pavr_stall_s2,
           pavr_flush_s2,
           pavr_s2_pc,
           pavr_s3_pc,

           -- <Non synthesizable code>
           pavr_s2_pmdo_valid,
           -- </Non synthesizable code>

           pavr_grant_control_flow_access,
           pavr_pm_do_shadow_active,
           pavr_pm_do_shadow,
           pavr_pm_do,

           pavr_zbpu,
           pavr_s1_pc,
           pavr_s4_k12,
           pavr_s4_pc,
           pavr_iof_rampz,
           pavr_iof_eind,
           pavr_s4_k6,
           pavr_s3_instr,
           pavr_s6_branch_pc,
           pavr_s4_k22int,
           pavr_s52_retpchi8,
           pavr_s53_retpcmid8,
           pavr_s54_retpclo8,
           pavr_pm_addr_int
          )
      variable v_pmrq_sel: std_logic_vector(10 downto 0);
      variable v_pavr_pc_sel: std_logic;

      variable v_22b_op1:              std_logic_vector(22 downto 0);
      variable v_22b_op2:              std_logic_vector(22 downto 0);
      variable v_pavr_pc_k12rel_23b:   std_logic_vector(22 downto 0);
      variable v_grant_s2_pm_access:        std_logic;
      --variable pavr_grant_control_flow_access: std_logic;
      variable v_freeze_control_flow:       std_logic;
      variable v_instr32bits_tmp1:  std_logic_vector(9 downto 0);
      variable v_instr32bits_tmp2:  std_logic_vector(8 downto 0);
      variable v_instr32bits:       std_logic;

   begin
      -- Default values:
      --    - PM addr = PC
      --    - next PC = crt PC + 1.
      --    - don't grant access to control flow (enabled later if requested)
      --    - grant PM access (disabled later if the instruction doesn't
      --       explicitely requests it)
      --    - don't freeze control flow (enabled later if a LPM family
      --       requests PM access)
      pavr_pm_addr_int <= pavr_s1_pc;
      v_pavr_pc_sel := pavr_pc_sel_inc;
      v_grant_s2_pm_access := '1';
      v_freeze_control_flow := '0';
      pavr_grant_control_flow_access <= '0';

      -- Detect if the instruction to stall is 16 bits or 32 bits wide.
      -- Is it a LDS or a STS?
      v_instr32bits_tmp1 := pavr_s3_instr(15 downto 10) & pavr_s3_instr(3 downto 0);
      -- Is it a JMP or a CALL?
      v_instr32bits_tmp2 := pavr_s3_instr(15 downto  9) & pavr_s3_instr(3 downto 2);
      if v_instr32bits_tmp1="1001000000" or v_instr32bits_tmp2="100101011" then
         v_instr32bits := '1';
      else
         v_instr32bits := '0';
      end if;

      -- Add 12 bits offset with current instruction's PC and with 1. The result
      --    is the relative address needed by intructions RJMP/RCALL.
      v_22b_op1(0) := '1';
      v_22b_op2(0) := '1';
      if pavr_s6_branch_pm_rq='1' then
         if v_instr32bits ='0' then
            v_22b_op1(22 downto 1) := sign_extend("01", 22);
            v_22b_op2(22 downto 1) := pavr_s4_pc;
         else
            v_22b_op1(22 downto 1) := sign_extend("00", 22);
            v_22b_op2(22 downto 1) := pavr_s4_pc;
         end if;
      else
         v_22b_op1(22 downto 1) := sign_extend(pavr_s4_k12, 22);
         v_22b_op2(22 downto 1) := pavr_s4_pc;
      end if;
      v_pavr_pc_k12rel_23b := v_22b_op1 + v_22b_op2;

      v_pmrq_sel := (pavr_s5_lpm_pm_rq    and pavr_s5_hwrq_en) &
                    (pavr_s5_elpm_pm_rq   and pavr_s5_hwrq_en) &
                    (pavr_s4_z_pm_rq      and pavr_s4_hwrq_en) &
                    (pavr_s4_zeind_pm_rq  and pavr_s4_hwrq_en) &
                    (pavr_s4_k22abs_pm_rq and pavr_s4_hwrq_en) &
                    (pavr_s4_k12rel_pm_rq and pavr_s4_hwrq_en) &
                    (pavr_s6_branch_pm_rq and pavr_s6_hwrq_en) &
                    (pavr_s6_skip_pm_rq   and pavr_s6_hwrq_en) &
                     pavr_s61_skip_pm_rq                       &
                    (pavr_s4_k22int_pm_rq and pavr_s4_hwrq_en) &
                     pavr_s54_ret_pm_rq;
      case v_pmrq_sel is
         -- No PM access requests. Don't grant access to PM.
         when "00000000000" =>
            v_grant_s2_pm_access := '0';
         -- LPM PM request. Freeze PC.
         when "10000000000" =>
            -- Only take action if permitted by older instructions.
            -- *** Note that the condition is stall enabled in s6, not s5. That's
            --    because LPM stalls s5 at the same time it tries to read PM.
            if pavr_s6_hwrq_en='1' then
               pavr_pm_addr_int <= int_to_std_logic_vector(0, 6) & '0' & pavr_zbpu(15 downto 1);
               v_pavr_pc_sel := pavr_pc_sel_same;
               v_freeze_control_flow := '1';
            end if;
         -- ELPM PM request. Freeze PC.
         when "01000000000" =>
            -- *** Note that the condition is stall enabled in s6, not s5. That's
            --    because ELPM stalls  s5 at the same time it tries to read PM.
            if pavr_s6_hwrq_en='1' then
               pavr_pm_addr_int <= '0' & pavr_iof_rampz(5 downto 0) & pavr_zbpu(15 downto 1);
               v_pavr_pc_sel := pavr_pc_sel_same;
               v_freeze_control_flow := '1';
            end if;
         -- IJMP/ICALL PM request.
         when "00100000000" =>
            if pavr_s4_hwrq_en='1' then
               pavr_pm_addr_int <= int_to_std_logic_vector(0, 6) & pavr_zbpu;
               pavr_grant_control_flow_access <= '1';
            end if;
         -- EIJMP/EICALL PM request.
         when "00010000000" =>
            if pavr_s4_hwrq_en='1' then
               pavr_pm_addr_int <= pavr_iof_eind(5 downto 0) & pavr_zbpu;
               pavr_grant_control_flow_access <= '1';
            end if;
         -- JMP/CALL PM request.
         when "00001000000" =>
            if pavr_s4_hwrq_en='1' then
               pavr_pm_addr_int <= pavr_s4_k6 & pavr_s3_instr;
               pavr_grant_control_flow_access <= '1';
            end if;
         -- RJMP/RCALL PM request.
         when "00000100000" =>
            if pavr_s4_hwrq_en='1' then
               pavr_pm_addr_int <= v_pavr_pc_k12rel_23b(22 downto 1);
               pavr_grant_control_flow_access <= '1';
            end if;
         -- Branch PM requests (SBRC, SBRS instructions).
         when "00000010000" =>
            if pavr_s6_hwrq_en='1' then
               pavr_pm_addr_int <= pavr_s6_branch_pc;
               pavr_grant_control_flow_access <= '1';
            end if;
         -- Skip PM requests (CPSE, SBRC, SBRS instructions).
         when "00000001000" =>
            if pavr_s6_hwrq_en='1' then
               pavr_pm_addr_int <= v_pavr_pc_k12rel_23b(22 downto 1);
               pavr_grant_control_flow_access <= '1';
            end if;
         -- Skip PM requests (SBIC, SBIS instructions).
         when "00000000100" =>
            if pavr_s61_hwrq_en='1' then
               pavr_pm_addr_int <= v_pavr_pc_k12rel_23b(22 downto 1);
               pavr_grant_control_flow_access <= '1';
            end if;
         -- Interrupt PM requests. No instruction requests this. Only the
         --    Interrupt Manager can request this.
         when "00000000010" =>
            -- !!! Any condition here?
            pavr_pm_addr_int <= pavr_s4_k22int;
            pavr_grant_control_flow_access <= '1';
         -- RET/RETI PM requests.
         when "00000000001" =>
            pavr_pm_addr_int <= pavr_s52_retpchi8(5 downto 0) & pavr_s53_retpcmid8 & pavr_s54_retpclo8;
            pavr_grant_control_flow_access <= '1';
         when others =>
            -- <Non synthesizable code>
            if pavr_s2_pmdo_valid='1' then
               assert false
                  report "Program Memory error."
                  severity warning;
            end if;
            -- </Non synthesizable code>
            null;
      end case;

      -- Set PM address.
      -- Take care of potential direct PM access requests placed by control or LPM
      --    instructions.
      if v_grant_s2_pm_access='0' and pavr_stall_s1='1' then
         pavr_pm_addr_int <= pavr_s1_pc;
      end if;

      -- Here is an instruction register-related code that's a workaround on an
      --    after-reset false instruction register initializing.
      -- During reset, PM was read. When reset lines are released, the controller
      --    didn't wait to read the first instruction (at address 0). It
      --    considered it already read during reset. Wrong. This corrects this
      --    behavior.
      if pavr_stall_s1='0' then
         next_pavr_s2_pmdo_valid <= '1';
      else
         next_pavr_s2_pmdo_valid <= pavr_s2_pmdo_valid;
      end if;

      -- Now we know what to do with the PC. Do it.
      if pavr_grant_control_flow_access='1' then
         next_pavr_s1_pc <= pavr_pm_addr_int + 1;
      else
         if pavr_stall_s1='1' then
            next_pavr_s1_pc <= pavr_s1_pc;
         else
            if v_pavr_pc_sel=pavr_pc_sel_same then
               next_pavr_s1_pc <= pavr_s1_pc;
            else
               next_pavr_s1_pc <= pavr_pm_addr_int + 1;
            end if;
         end if;
      end if;

      -- pavr_s2_pc
      if pavr_grant_control_flow_access='1' then
         next_pavr_s2_pc <= pavr_pm_addr_int;
      else
         if pavr_stall_s1='1' then
            next_pavr_s2_pc <= pavr_s2_pc;
         else
            next_pavr_s2_pc <= pavr_s1_pc;
         end if;
      end if;

      -- pavr_s3_pc
      if pavr_stall_s2='1' then
         next_pavr_s3_pc <= pavr_s3_pc;
      else
         next_pavr_s3_pc <= pavr_s2_pc;
      end if;

      -- pavr_s3_instr (instruction register)
      if pavr_flush_s2='1' or pavr_s2_pmdo_valid='0' then
         next_pavr_s3_instr <= int_to_std_logic_vector(0, pavr_s3_instr'length);
      else
         if pavr_stall_s2='1' then
            next_pavr_s3_instr <= pavr_s3_instr;
         else
            if pavr_pm_do_shadow_active='0' then
               next_pavr_s3_instr <= pavr_pm_do;
            else
               next_pavr_s3_instr <= pavr_pm_do_shadow;
            end if;
         end if;
      end if;

   end process pm_manager;



   -- Stall and Flush Unit (SFU)
   -- The pipeline controls its own stall and flush status, through specific
   --    stall and flush-related request signals. These requests are sent to
   --    the SFU. The output of the SFU is a set of signals that directly
   --    control pipeline stages (a stall and flush control signals pair for
   --    each stage).
   -- The pipeline sets up 5 kinds of stall and flush-related requests:
   --    - stall request
   --       The SFU stalls *all* younger stages. However, by stalling-only, the
   --          current instruction is spawned into 2 instances. One of them must
   --          be killed (flushed). The the younger instance is killed (the
   --          previous stage is flushed).
   --       Thus, a nop is introduced in the pipeline *before* the instruction
   --          wavefront.
   --       If more than one stage requests a stall at the same time, the older
   --          one has priority (the younger one will be stalled along with the
   --          others). Only after that, the younger one will be ackowledged its
   --          stall by means of appropriate stall and flush control signals.
   --    - flush request
   --       The SFU simply flushes that stage.
   --       More than one flush can be acknolewdged at the same time, without
   --          competition.
   --    - branch request
   --       The SFU flushes about all stags (s2...s5) and requests
   --       the PC to be loaded with the relative jump address.
   --    - skip request
   --       Skips are processed the same way as branches. However, there are 2
   --       kinds of skips: one in stage s6 (requested by instructions CPSE,
   --       SBRC, SBRS) and one in stage s61 (SBIC, SBIS). Those active in s6
   --       also supplementary request stall and flush s6.
   --    - nop request
   --       The SFU stalls all younger instructions. The current instruction is
   --          spawned into 2 instances. The older instance is killed (the very
   --          same stage that requested the nop stage is flushed).
   --       Thus, a nop is introduced in the pipeline *after* the instruction
   --          wavefront.
   --       In order to do that, a micro-state machine is needed outside the
   --          pipeline, because otherwise that stage will undefinitely stall
   --          itself.
   -- Each pipeline stage has 2 kinds of control signals, that are generated by
   --    the SFU:
   --    - stall control
   --       All registers in this stage are instructed to remain unchanged
   --          (ignore `next...' signals that feed the registers in that
   --          stage, or mirror registers in previous stages). Also, all
   --          possible requests to hardware resources (such as RF, IOF, BPU,
   --          DACU, SREG, etc) are reseted (to 0).
   --    - flush control
   --       All registers in this stage are reseted (to 0), to a most "benign"
   --          state (a nop). Also, all requests to hardware resources are
   --          reseted.
   --
   -- SFU requests:
   --    - stall
   --    - flush
   --    - skip
   --    - branch
   --    - nop
   -- SFU requests influence the way that hardware resources are granted to
   --    pipeline stages. That way is given by the SFU rule below.
   -- The SFU rule: older SFU hardware resource requests have priority over
   --    younger ones.
   --
   -- The SFU manager sets the signals:
   --    - pavr_stall_s1
   --    - pavr_stall_s2
   --    - pavr_stall_s3
   --    - pavr_stall_s4
   --    - pavr_stall_s5
   --    - pavr_stall_s6
   --    - pavr_flush_s1
   --    - pavr_flush_s2
   --    - pavr_flush_s3
   --    - pavr_flush_s4
   --    - pavr_flush_s5
   --    - pavr_flush_s6
   --    - pavr_s6_branch_pm_rq
   --    - pavr_s6_skip_pm_rq
   --    - pavr_s61_skip_pm_rq
   --    - pavr_stall_bpu
   --    - pavr_s61_hwrq_en
   --    - pavr_s6_hwrq_en
   --    - pavr_s5_hwrq_en
   --    - pavr_s4_hwrq_en
   --    - pavr_s3_hwrq_en
   --    - pavr_s2_hwrq_en
   --    - pavr_s1_hwrq_en
   --
   sfu_manager:
   process(pavr_s3_stall_rq, pavr_s4_stall_rq, pavr_s5_stall_rq, pavr_s6_stall_rq,
           pavr_s3_flush_s2_rq, pavr_s4_flush_s2_rq,
           pavr_s4_ret_flush_s2_rq, pavr_s5_ret_flush_s2_rq, pavr_s51_ret_flush_s2_rq, pavr_s52_ret_flush_s2_rq,
           pavr_s53_ret_flush_s2_rq, pavr_s54_ret_flush_s2_rq, pavr_s55_ret_flush_s2_rq,
           pavr_s6_skip_rq, pavr_s61_skip_rq,
           pavr_s6_branch_rq,
           pavr_s4_nop_rq,

           pavr_s6_hwrq_en,
           pavr_s5_hwrq_en,
           pavr_s4_hwrq_en,
           pavr_s3_hwrq_en,

           pavr_nop_ack
          )
   begin
      -- By default:
      --    - don't stall any pipe stage.
      --    - grant to all pipe stages access to hardware resources.
      pavr_stall_s1        <= '0';
      pavr_stall_s2        <= '0';
      pavr_stall_s3        <= '0';
      pavr_stall_s4        <= '0';
      pavr_stall_s5        <= '0';
      pavr_stall_s6        <= '0';
      pavr_flush_s1        <= '0';
      pavr_flush_s2        <= '0';
      pavr_flush_s3        <= '0';
      pavr_flush_s4        <= '0';
      pavr_flush_s5        <= '0';
      pavr_flush_s6        <= '0';
      pavr_s6_branch_pm_rq <= '0';
      pavr_s6_skip_pm_rq   <= '0';
      pavr_s61_skip_pm_rq  <= '0';
      pavr_stall_bpu       <= '0';
      pavr_s61_hwrq_en     <= '1';
      pavr_s6_hwrq_en      <= '1';
      pavr_s5_hwrq_en      <= '1';
      pavr_s4_hwrq_en      <= '1';
      pavr_s3_hwrq_en      <= '1';
      pavr_s2_hwrq_en      <= '1';
      pavr_s1_hwrq_en      <= '1';

      -- Prioritize hardware resource requests.
      -- Only one such request can be received by a given resource at a time. If
      --    multiple accesses are requested from a resource, its access manager
      --    will assert an error; that would indicate a design bug.
      -- The pipeline is built so that each resource is normally accessed during a
      --    fixed pipeline stage:
      --    - RF is normally read in s2 and written in s6.
      --    - IOF is normally read/written in s5.
      --    - DM is normally read/written in s5.
      --    - DACU is normally read/written in s5.
      --    - PM is normally read in s1.
      -- However, exceptions can occur. For example, LPM instructions need to read
      --    PM in stage s5. Also, loads/stores must be able to read/write RF, IOF
      --    or DM (depending on addresses involved) in stage s5. Exceptions are
      --    handled in the hardware resource managers of those resources.
      -- These are the stall/flush/skip/branch requests that matter when deciding
      --    whether or not a pipe stage has the right to access hardware resources
      --    (in priority order):
      --    - pavr_s61_skip_rq
      --    - pavr_s6_stall_rq
      --    - pavr_s6_skip_rq
      --    - pavr_s6_branch_rq
      --    - pavr_s5_stall_rq
      --    - pavr_s4_stall_rq
      --    - pavr_s4_nop_rq & not pavr_nop_ack
      --    - pavr_s3_stall_rq
      --    - pavr_s3_flush_s2_rq
      --    - pavr_s4_flush_s2_rq
      --    - pavr_s4_ret_flush_s2_rq
      --    - pavr_s5_ret_flush_s2_rq
      --    - pavr_s51_ret_flush_s2_rq
      --    - pavr_s52_ret_flush_s2_rq
      --    - pavr_s53_ret_flush_s2_rq
      --    - pavr_s54_ret_flush_s2_rq
      --    - pavr_s55_ret_flush_s2_rq
      -- Stage s61 is always permitted to access hardware resource requests, as
      --    it is as old that a stage that can place hardware resource requests
      --    can be.
      -- Stages s6, s5, s4, s3, s2, s1 are conditionally permitted to do that.
      if pavr_s61_skip_rq='1' then
         pavr_s6_hwrq_en <= '0';
      end if;
      if  pavr_s61_skip_rq  ='1' or
          pavr_s6_stall_rq  ='1' or
          pavr_s6_skip_rq   ='1' or
          pavr_s6_branch_rq ='1' then
         pavr_s5_hwrq_en <= '0';
      end if;
      if  pavr_s61_skip_rq  ='1' or
          pavr_s6_stall_rq  ='1' or
          pavr_s6_skip_rq   ='1' or
          pavr_s6_branch_rq ='1' or
          pavr_s5_stall_rq  ='1' or
          -- *** Check nop requests too here, as nops are inserted *after* the
          --   instruction wavefront.
          (pavr_s4_nop_rq='1' and pavr_nop_ack='0') then
         pavr_s4_hwrq_en <= '0';
      end if;
      if  pavr_s61_skip_rq  ='1' or
          pavr_s6_stall_rq  ='1' or
          pavr_s6_skip_rq   ='1' or
          pavr_s6_branch_rq ='1' or
          pavr_s5_stall_rq  ='1' or
          pavr_s4_stall_rq  ='1' or
          (pavr_s4_nop_rq='1' and pavr_nop_ack='0') then
         pavr_s3_hwrq_en <= '0';
      end if;
      if  pavr_s61_skip_rq         ='1' or
          pavr_s6_stall_rq         ='1' or
          pavr_s6_skip_rq          ='1' or
          pavr_s6_branch_rq        ='1' or
          pavr_s5_stall_rq         ='1' or
          pavr_s4_stall_rq         ='1' or
          pavr_s3_stall_rq         ='1' or
          (pavr_s4_nop_rq='1' and pavr_nop_ack='0')
          --or
          --pavr_s3_flush_s2_rq      ='1' or
          --pavr_s4_flush_s2_rq      ='1' or
          --pavr_s4_ret_flush_s2_rq  ='1' or
          --pavr_s5_ret_flush_s2_rq  ='1' or
          --pavr_s51_ret_flush_s2_rq ='1' or
          --pavr_s52_ret_flush_s2_rq ='1' or
          --pavr_s53_ret_flush_s2_rq ='1' or
          --pavr_s54_ret_flush_s2_rq ='1' or
          --pavr_s55_ret_flush_s2_rq ='1'
          then
         pavr_s2_hwrq_en <= '0';
      end if;
      if  pavr_s61_skip_rq ='1' or
          pavr_s6_stall_rq ='1' or
          pavr_s6_skip_rq  ='1' or
          pavr_s6_branch_rq='1' or
          pavr_s5_stall_rq ='1' or
          pavr_s4_stall_rq  ='1' or
          pavr_s3_stall_rq  ='1' or
          (pavr_s4_nop_rq='1' and pavr_nop_ack='0')
          then
         pavr_s1_hwrq_en <= '0';
      end if;

      -- Process stall requests according to the SFU rule above.
      -- Consequences of the SFU rule above:
      --    - a stall request stalls in turn all younger pipe stages. By doing
      --       that, the oldest instruction in the pipeline that needs a stall
      --       wins, and gets its stall clock. All younger instructions are
      --       postponed, their stall included. They will get their stall later,
      --       after they resume execution.
      --    - only a pipe stage that has resources access can win a stall (in
      --       fact, winning a stall can be considered as winning access to the
      --       Stall and Flush Unit hardware resource).
      if pavr_s3_stall_rq='1' and pavr_s3_hwrq_en='1' then
         pavr_stall_s1  <= '1';
         pavr_stall_s2  <= '1';
         pavr_flush_s2  <= '1';
      end if;
      if pavr_s4_stall_rq='1' and pavr_s4_hwrq_en='1' then
         pavr_stall_s1  <= '1';
         pavr_stall_s2  <= '1';
         pavr_stall_s3  <= '1';
         pavr_flush_s3  <= '1';
      end if;
      if pavr_s5_stall_rq='1' and pavr_s5_hwrq_en='1' then
         pavr_stall_s1  <= '1';
         pavr_stall_s2  <= '1';
         pavr_stall_s3  <= '1';
         pavr_stall_s4  <= '1';
         pavr_flush_s4  <= '1';
      end if;
      if pavr_s6_stall_rq='1' and pavr_s6_hwrq_en='1' then
         pavr_stall_s1  <= '1';
         pavr_stall_s2  <= '1';
         pavr_stall_s3  <= '1';
         pavr_stall_s4  <= '1';
         pavr_stall_s5  <= '1';
         pavr_flush_s5  <= '1';
         pavr_stall_bpu <= '1';
      end if;

      -- Process flush requests according to the SFU rule above.
      -- Examples of the SFU rule above:
      --    - flush s2 requested in s3, s4 and s5 won't be acknowledged if older
      --       instructions require a stall, and, consequently, disable resources
      --       access in s3, s4 respectively s5.
      --    - s2 can't be flushed when nop is requested in s4.
      if ((pavr_s3_flush_s2_rq     and pavr_s3_hwrq_en) or
          (pavr_s4_flush_s2_rq     and pavr_s4_hwrq_en) or
          (pavr_s4_ret_flush_s2_rq and pavr_s4_hwrq_en) or
          (pavr_s5_ret_flush_s2_rq and pavr_s5_hwrq_en) or
           pavr_s51_ret_flush_s2_rq                     or
           pavr_s52_ret_flush_s2_rq                     or
           pavr_s53_ret_flush_s2_rq                     or
           pavr_s54_ret_flush_s2_rq                     or
           pavr_s55_ret_flush_s2_rq)='1'
        and
         ((pavr_s4_nop_rq='0' and pavr_nop_ack='0') or (pavr_s4_nop_rq='1' and pavr_nop_ack='1')) then
         pavr_flush_s2 <= '1';
      end if;

      -- Process skip requests according to the SFU rule above.
      if pavr_s61_skip_rq='1' then
         pavr_stall_s1  <= '1';
         pavr_stall_s2  <= '1';
         pavr_stall_s3  <= '1';
         pavr_stall_s4  <= '1';
         pavr_stall_s5  <= '1';
         pavr_stall_s6  <= '1';
         pavr_flush_s2  <= '1';
         pavr_flush_s3  <= '1';
         pavr_flush_s4  <= '1';
         pavr_flush_s5  <= '1';
         pavr_flush_s6  <= '1';
         pavr_s61_skip_pm_rq <= '1';
         pavr_stall_bpu <= '1';
      end if;
      if pavr_s6_skip_rq='1' and pavr_s6_hwrq_en='1' then
         pavr_stall_s1  <= '1';
         pavr_stall_s2  <= '1';
         pavr_stall_s3  <= '1';
         pavr_stall_s4  <= '1';
         pavr_stall_s5  <= '1';
         pavr_flush_s2  <= '1';
         pavr_flush_s3  <= '1';
         pavr_flush_s4  <= '1';
         pavr_flush_s5  <= '1';
         pavr_s6_skip_pm_rq <= '1';
         pavr_stall_bpu <= '1';
      end if;

      -- Process branch requests according to the SFU rule above.
      if pavr_s6_branch_rq='1' and pavr_s6_hwrq_en='1' then
         pavr_stall_s1        <= '1';
         pavr_stall_s2        <= '1';
         pavr_stall_s3        <= '1';
         pavr_stall_s4        <= '1';
         pavr_stall_s5        <= '1';
         pavr_flush_s2        <= '1';
         pavr_flush_s3        <= '1';
         pavr_flush_s4        <= '1';
         pavr_flush_s5        <= '1';
         pavr_s6_branch_pm_rq <= '1';
         pavr_stall_bpu       <= '1';
      end if;

      -- Process nop requests according to the SFU rule above.
      -- *** Condition is hardware resource enabled in s5, not s4, because nop
      --    request influences the very same pipe stage that placed the
      --    request (s4).
      if pavr_s4_nop_rq='1' and pavr_nop_ack='0' and pavr_s5_hwrq_en='1' then
         pavr_stall_s1  <= '1';
         pavr_stall_s2  <= '1';
         pavr_stall_s3  <= '1';
         pavr_stall_s4  <= '1';
         pavr_flush_s4  <= '1';
      end if;
   end process sfu_manager;



   -- Shadow manager (Synchronous)
   -- To understand why the shadow protocol is needed, let's consider the
   --    following example: a load instruction reads the Data Memory during pipe
   --    stage s5. Suppose that next clock stalls s6, during which Data Memory
   --    output was supposed to be written into the Register File. After another
   --    clock, the stall is removed, and s6 requests to write the Register File,
   --    but the Data Memory output has changed during the stall. Corrupted data
   --    will be written into the Register File. With the shadow protocol, the
   --    Data Memory output is saved during the stall, and the Register File is
   --    written with the saved data.
   -- Shadow protocol:
   --    If a pipe stage is not permitted to place hardware resource requests,
   --       then mark every memory-like entity in that stage as having its output
   --       `shadowed'. That is, its output will be read (by whatever process
   --       needs it) from the associated shadow register, rather than directly
   --       from memory-like entity's output.
   --    Basically, the condition that shadows a memory-like entity's output is
   --       `hardware resource enabled during that stage'=0. However, there are
   --       exceptions. For example, LPM family instructions steal Program Memory
   --       access by stalling the instruction that would normally be fetched that
   --       time. By stalling, hardware resource requests become disabled in that
   --       pipe stage. Still, LPM family instructions must be able to request
   --       Program Memory access. Here, the PM must not be shadowed even though
   --       during its pipe stage s2 (during which PM is normally accessed) all
   --       hardware requests are disabled by default.
   --    In order to enable shadowing during multiple, successive stalls, shadow
   --       memory-like entities outputs only if they aren't already shadowed.
   -- Set the signals:
   --    - !!!
   shadow_manager:
   process(pavr_res, pavr_syncres, pavr_clk,

           pavr_s3_stall_rq,

           pavr_s5_hwrq_en,
           pavr_s2_hwrq_en,
           pavr_s1_hwrq_en,

           pavr_grant_control_flow_access,

           pavr_rf_do_shadow_active,
           pavr_rf_rd1_do_shadow,
           pavr_rf_rd2_do_shadow,
           pavr_iof_do_shadow_active,
           pavr_iof_do_shadow,
           pavr_dm_do_shadow_active,
           pavr_dm_do_shadow,
           pavr_dacu_do_shadow_active,
           pavr_dacu_do_shadow,
           pavr_pm_do_shadow_active,
           pavr_pm_do_shadow,

           pavr_pm_do,
           pavr_s2_pmdo_valid,
           pavr_rf_rd1_do,
           pavr_rf_rd2_do,
           pavr_iof_do,
           pavr_dm_do,
           pavr_dacu_do
          )
   begin
         if pavr_res='1' then
         -- Asynchronous reset
         -- RF-related shadow registers
         pavr_rf_rd1_do_shadow      <= int_to_std_logic_vector(0, pavr_rf_rd1_do_shadow'length);
         pavr_rf_rd2_do_shadow      <= int_to_std_logic_vector(0, pavr_rf_rd2_do_shadow'length);
         pavr_rf_do_shadow_active   <= '0';
         -- IOF-related shadow registers
         pavr_iof_do_shadow         <= int_to_std_logic_vector(0, pavr_iof_do_shadow'length);
         pavr_iof_do_shadow_active  <= '0';
         -- DM-related shadow registers
         pavr_dm_do_shadow          <= int_to_std_logic_vector(0, pavr_dm_do_shadow'length);
         pavr_dm_do_shadow_active   <= '0';
         -- DACU-related shadow registers
         pavr_dacu_do_shadow        <= int_to_std_logic_vector(0, pavr_dacu_do_shadow'length);
         pavr_dacu_do_shadow_active <= '0';
         -- PM-related shadow registers
         pavr_pm_do_shadow          <= int_to_std_logic_vector(0, pavr_pm_do_shadow'length);
         pavr_s2_pmdo_valid_shadow  <= '0';
         pavr_pm_do_shadow_active   <= '0';

      elsif pavr_clk'event and pavr_clk='1' then
         -- RF-related shadow registers
         -- RF is normally read in pipe stage s2.
         -- ** Don't shadow RF if s3 stall request (hole through shadow protocol).
         --    That's because s3 stall requests are intended only to delay youger
         --    instructions with one clock. During this stalls, the instruction
         --    that requests s3 stall might need to read RF (for example, the
         --    instruction CPSE). If RF is shadowed, that instruction will
         --    incorrectly read from shadow register.
         -- Note
         --    Fortunately, there are only a few such exceptions (holes through
         --    the shadow protocol). Overall, the shadow protocol is still a good
         --    idea, as it permits natural & automatic handling of a bunch of
         --    registers placed in delicated areas.
         if pavr_s2_hwrq_en='0' and pavr_s3_stall_rq='0' then     -- ... if `hardware resources are disabled' and 's3 doesn't request stall'
            if pavr_rf_do_shadow_active='0' then                  --        and `shadow isn't already active'
               pavr_rf_rd1_do_shadow      <= pavr_rf_rd1_do;      --     then `shadow Register File read ports 1 and 2'
               pavr_rf_rd2_do_shadow      <= pavr_rf_rd2_do;
               pavr_rf_do_shadow_active   <= '1';
            end if;
         else
            pavr_rf_do_shadow_active   <= '0';                    --     else `unshadow Register File read ports 1 and 2'
         end if;

         -- IOF-related shadow registers
         -- IOF is normally read in pipe stage s5.
         if pavr_s5_hwrq_en='0' then
            if pavr_iof_do_shadow_active='0' then
               pavr_iof_do_shadow         <= pavr_iof_do;
               pavr_iof_do_shadow_active  <= '1';
            end if;
         else
            pavr_iof_do_shadow_active  <= '0';
         end if;

         -- DM-related shadow registers
         -- DM is normally read in pipe stage s5.
         if pavr_s5_hwrq_en='0' then
            if pavr_dm_do_shadow_active='0' then
               pavr_dm_do_shadow          <= pavr_dm_do;
               pavr_dm_do_shadow_active   <= '1';
            end if;
         else
            pavr_dm_do_shadow_active   <= '0';
         end if;

         -- DACU-related shadow registers
         -- DACU is normally read in pipe stage s5.
         if pavr_s5_hwrq_en='0' then
            if pavr_dacu_do_shadow_active='0' then
               pavr_dacu_do_shadow        <= pavr_dacu_do;
               pavr_dacu_do_shadow_active <= '1';
            end if;
         else
            pavr_dacu_do_shadow_active <= '0';
         end if;

         -- Setting PM-related shadow registers
         -- PM is normally read in pipe stage s1.
         -- *** If a control instruction instruction wants flow control access,
         --    don't shadow PM (hole through shadow protocol).
         if pavr_s1_hwrq_en='0' and pavr_grant_control_flow_access='0' then
            if  pavr_pm_do_shadow_active='0' then
               -- Shadow PM.
               pavr_pm_do_shadow          <= pavr_pm_do;
               pavr_s2_pmdo_valid_shadow  <= pavr_s2_pmdo_valid;
               pavr_pm_do_shadow_active   <= '1';
            end if;
         else
            -- Unshadow PM.
            pavr_pm_do_shadow_active   <= '0';
         end if;

         if pavr_syncres='1' then
            -- Synchronous reset
            -- RF-related shadow registers
            pavr_rf_rd1_do_shadow      <= int_to_std_logic_vector(0, pavr_rf_rd1_do_shadow'length);
            pavr_rf_rd2_do_shadow      <= int_to_std_logic_vector(0, pavr_rf_rd2_do_shadow'length);
            pavr_rf_do_shadow_active   <= '0';
            -- IOF-related shadow registers
            pavr_iof_do_shadow         <= int_to_std_logic_vector(0, pavr_iof_do_shadow'length);
            pavr_iof_do_shadow_active  <= '0';
            -- DM-related shadow registers
            pavr_dm_do_shadow          <= int_to_std_logic_vector(0, pavr_dm_do_shadow'length);
            pavr_dm_do_shadow_active   <= '0';
            -- DACU-related shadow registers
            pavr_dacu_do_shadow        <= int_to_std_logic_vector(0, pavr_dacu_do_shadow'length);
            pavr_dacu_do_shadow_active <= '0';
            -- PM-related shadow registers
            pavr_pm_do_shadow          <= int_to_std_logic_vector(0, pavr_pm_do_shadow'length);
            pavr_s2_pmdo_valid_shadow  <= '0';
            pavr_pm_do_shadow_active   <= '0';
         end if;
      end if;
   end process shadow_manager;



   -- Computing branch and skip conditions
   -- Set signals:
   --    - next_pavr_s6_branch_rq
   --    - next_pavr_s6_skip_rq
   --    - next_pavr_s61_skip_rq
   br_skip_cond:
   process(pavr_s5_branch_bitsreg_sel, pavr_s5_branch_cond_sel, pavr_s5_branch_en, pavr_iof_sreg,
           pavr_s5_skip_bitrf_sel,     pavr_s5_skip_cond_sel,   pavr_s5_skip_en,   pavr_s5_op1bpu, pavr_s5_alu_flagsout,
           pavr_s6_skip_bitiof_sel,    pavr_s6_skip_cond_sel,   pavr_s6_skip_en,   pavr_iof_do,
           pavr_iof_do_shadow, pavr_iof_do_shadow_active
          )
      variable t_pavr_s5_branch_bitsreg, t_pavr_s5_branch_cond: std_logic;
      variable t_pavr_s5_skip_bitrf,     t_pavr_s5_skip_cond:   std_logic;
      variable t_pavr_s6_skip_bitiof,    t_pavr_s6_skip_cond:   std_logic;
      variable t_pavr_iof_do: std_logic_vector(7 downto 0);
   begin
      -- Compute branch condition in stage s5.
      case std_logic_vector_to_nat(pavr_s5_branch_bitsreg_sel) is
         when 0 =>
            t_pavr_s5_branch_bitsreg := pavr_iof_sreg(0);
         when 1 =>
            t_pavr_s5_branch_bitsreg := pavr_iof_sreg(1);
         when 2 =>
            t_pavr_s5_branch_bitsreg := pavr_iof_sreg(2);
         when 3 =>
            t_pavr_s5_branch_bitsreg := pavr_iof_sreg(3);
         when 4 =>
            t_pavr_s5_branch_bitsreg := pavr_iof_sreg(4);
         when 5 =>
            t_pavr_s5_branch_bitsreg := pavr_iof_sreg(5);
         when 6 =>
            t_pavr_s5_branch_bitsreg := pavr_iof_sreg(6);
         when others =>
            t_pavr_s5_branch_bitsreg := pavr_iof_sreg(7);
      end case;
      case pavr_s5_branch_cond_sel is
         when pavr_s5_branch_cond_sel_bitsreg =>
            t_pavr_s5_branch_cond := t_pavr_s5_branch_bitsreg;
         -- When pavr_s5_branch_cond_sel_notbitsreg
         when others =>
            t_pavr_s5_branch_cond := not t_pavr_s5_branch_bitsreg;
      end case;
      next_pavr_s6_branch_rq <= t_pavr_s5_branch_cond and pavr_s5_branch_en;

      -- Compute skip condition in stage s5.
      case std_logic_vector_to_nat(pavr_s5_skip_bitrf_sel) is
         when 0 =>
            t_pavr_s5_skip_bitrf := pavr_s5_op1bpu(0);
         when 1 =>
            t_pavr_s5_skip_bitrf := pavr_s5_op1bpu(1);
         when 2 =>
            t_pavr_s5_skip_bitrf := pavr_s5_op1bpu(2);
         when 3 =>
            t_pavr_s5_skip_bitrf := pavr_s5_op1bpu(3);
         when 4 =>
            t_pavr_s5_skip_bitrf := pavr_s5_op1bpu(4);
         when 5 =>
            t_pavr_s5_skip_bitrf := pavr_s5_op1bpu(5);
         when 6 =>
            t_pavr_s5_skip_bitrf := pavr_s5_op1bpu(6);
         when others =>
            t_pavr_s5_skip_bitrf := pavr_s5_op1bpu(7);
      end case;
      case pavr_s5_skip_cond_sel is
         when pavr_s5_skip_cond_sel_zflag =>
            t_pavr_s5_skip_cond := pavr_s5_alu_flagsout(1);
         when pavr_s5_skip_cond_sel_bitrf =>
            t_pavr_s5_skip_cond := t_pavr_s5_skip_bitrf;
         -- When pavr_s5_skip_cond_sel_notbitrf
         when others =>
            t_pavr_s5_skip_cond := not t_pavr_s5_skip_bitrf;
      end case;
      next_pavr_s6_skip_rq <= t_pavr_s5_skip_cond and pavr_s5_skip_en;

      -- Compute skip condition in stage s6.
      if pavr_iof_do_shadow_active='0' then
         t_pavr_iof_do := pavr_iof_do;
      else
         t_pavr_iof_do := pavr_iof_do_shadow;
      end if;
      case std_logic_vector_to_nat(pavr_s6_skip_bitiof_sel) is
         when 0 =>
            t_pavr_s6_skip_bitiof := t_pavr_iof_do(0);
         when 1 =>
            t_pavr_s6_skip_bitiof := t_pavr_iof_do(1);
         when 2 =>
            t_pavr_s6_skip_bitiof := t_pavr_iof_do(2);
         when 3 =>
            t_pavr_s6_skip_bitiof := t_pavr_iof_do(3);
         when 4 =>
            t_pavr_s6_skip_bitiof := t_pavr_iof_do(4);
         when 5 =>
            t_pavr_s6_skip_bitiof := t_pavr_iof_do(5);
         when 6 =>
            t_pavr_s6_skip_bitiof := t_pavr_iof_do(6);
         when others =>
            t_pavr_s6_skip_bitiof := t_pavr_iof_do(7);
      end case;
      case pavr_s6_skip_cond_sel is
         when pavr_s6_skip_cond_sel_bitiof =>
            t_pavr_s6_skip_cond := t_pavr_s6_skip_bitiof;
         -- When pavr_s6_skip_cond_sel_notbitiof
         when others =>
            t_pavr_s6_skip_cond := not t_pavr_s6_skip_bitiof;
      end case;
      next_pavr_s61_skip_rq <= t_pavr_s6_skip_cond and pavr_s6_skip_en;

   end process br_skip_cond;



   -- Zero-level assignments --------------------------------------------------
   -- Read Bypass Unit.
   pavr_s5_op1bpu <= read_through_bpu(pavr_s5_op1, pavr_s5_op1_addr,
                                      pavr_bpr00, pavr_bpr00_addr, pavr_bpr00_active,
                                      pavr_bpr01, pavr_bpr01_addr, pavr_bpr01_active,
                                      pavr_bpr02, pavr_bpr02_addr, pavr_bpr02_active,
                                      pavr_bpr03, pavr_bpr03_addr, pavr_bpr03_active,
                                      pavr_bpr10, pavr_bpr10_addr, pavr_bpr10_active,
                                      pavr_bpr11, pavr_bpr11_addr, pavr_bpr11_active,
                                      pavr_bpr12, pavr_bpr12_addr, pavr_bpr12_active,
                                      pavr_bpr13, pavr_bpr13_addr, pavr_bpr13_active,
                                      pavr_bpr20, pavr_bpr20_addr, pavr_bpr20_active,
                                      pavr_bpr21, pavr_bpr21_addr, pavr_bpr21_active,
                                      pavr_bpr22, pavr_bpr22_addr, pavr_bpr22_active,
                                      pavr_bpr23, pavr_bpr23_addr, pavr_bpr23_active);
   pavr_s5_op2bpu <= read_through_bpu(pavr_s5_op2, pavr_s5_op2_addr,
                                      pavr_bpr00, pavr_bpr00_addr, pavr_bpr00_active,
                                      pavr_bpr01, pavr_bpr01_addr, pavr_bpr01_active,
                                      pavr_bpr02, pavr_bpr02_addr, pavr_bpr02_active,
                                      pavr_bpr03, pavr_bpr03_addr, pavr_bpr03_active,
                                      pavr_bpr10, pavr_bpr10_addr, pavr_bpr10_active,
                                      pavr_bpr11, pavr_bpr11_addr, pavr_bpr11_active,
                                      pavr_bpr12, pavr_bpr12_addr, pavr_bpr12_active,
                                      pavr_bpr13, pavr_bpr13_addr, pavr_bpr13_active,
                                      pavr_bpr20, pavr_bpr20_addr, pavr_bpr20_active,
                                      pavr_bpr21, pavr_bpr21_addr, pavr_bpr21_active,
                                      pavr_bpr22, pavr_bpr22_addr, pavr_bpr22_active,
                                      pavr_bpr23, pavr_bpr23_addr, pavr_bpr23_active);
   pavr_xbpu(7 downto 0)  <= read_through_bpu(pavr_rf_x(7 downto 0),  int_to_std_logic_vector(26, 5),
                                              pavr_bpr00, pavr_bpr00_addr, pavr_bpr00_active,
                                              pavr_bpr01, pavr_bpr01_addr, pavr_bpr01_active,
                                              pavr_bpr02, pavr_bpr02_addr, pavr_bpr02_active,
                                              pavr_bpr03, pavr_bpr03_addr, pavr_bpr03_active,
                                              pavr_bpr10, pavr_bpr10_addr, pavr_bpr10_active,
                                              pavr_bpr11, pavr_bpr11_addr, pavr_bpr11_active,
                                              pavr_bpr12, pavr_bpr12_addr, pavr_bpr12_active,
                                              pavr_bpr13, pavr_bpr13_addr, pavr_bpr13_active,
                                              pavr_bpr20, pavr_bpr20_addr, pavr_bpr20_active,
                                              pavr_bpr21, pavr_bpr21_addr, pavr_bpr21_active,
                                              pavr_bpr22, pavr_bpr22_addr, pavr_bpr22_active,
                                              pavr_bpr23, pavr_bpr23_addr, pavr_bpr23_active);
   pavr_xbpu(15 downto 8) <= read_through_bpu(pavr_rf_x(15 downto 8), int_to_std_logic_vector(27, 5),
                                              pavr_bpr00, pavr_bpr00_addr, pavr_bpr00_active,
                                              pavr_bpr01, pavr_bpr01_addr, pavr_bpr01_active,
                                              pavr_bpr02, pavr_bpr02_addr, pavr_bpr02_active,
                                              pavr_bpr03, pavr_bpr03_addr, pavr_bpr03_active,
                                              pavr_bpr10, pavr_bpr10_addr, pavr_bpr10_active,
                                              pavr_bpr11, pavr_bpr11_addr, pavr_bpr11_active,
                                              pavr_bpr12, pavr_bpr12_addr, pavr_bpr12_active,
                                              pavr_bpr13, pavr_bpr13_addr, pavr_bpr13_active,
                                              pavr_bpr20, pavr_bpr20_addr, pavr_bpr20_active,
                                              pavr_bpr21, pavr_bpr21_addr, pavr_bpr21_active,
                                              pavr_bpr22, pavr_bpr22_addr, pavr_bpr22_active,
                                              pavr_bpr23, pavr_bpr23_addr, pavr_bpr23_active);
   pavr_ybpu(7 downto 0)  <= read_through_bpu(pavr_rf_y(7 downto 0),  int_to_std_logic_vector(28, 5),
                                              pavr_bpr00, pavr_bpr00_addr, pavr_bpr00_active,
                                              pavr_bpr01, pavr_bpr01_addr, pavr_bpr01_active,
                                              pavr_bpr02, pavr_bpr02_addr, pavr_bpr02_active,
                                              pavr_bpr03, pavr_bpr03_addr, pavr_bpr03_active,
                                              pavr_bpr10, pavr_bpr10_addr, pavr_bpr10_active,
                                              pavr_bpr11, pavr_bpr11_addr, pavr_bpr11_active,
                                              pavr_bpr12, pavr_bpr12_addr, pavr_bpr12_active,
                                              pavr_bpr13, pavr_bpr13_addr, pavr_bpr13_active,
                                              pavr_bpr20, pavr_bpr20_addr, pavr_bpr20_active,
                                              pavr_bpr21, pavr_bpr21_addr, pavr_bpr21_active,
                                              pavr_bpr22, pavr_bpr22_addr, pavr_bpr22_active,
                                              pavr_bpr23, pavr_bpr23_addr, pavr_bpr23_active);
   pavr_ybpu(15 downto 8) <= read_through_bpu(pavr_rf_y(15 downto 8), int_to_std_logic_vector(29, 5),
                                              pavr_bpr00, pavr_bpr00_addr, pavr_bpr00_active,
                                              pavr_bpr01, pavr_bpr01_addr, pavr_bpr01_active,
                                              pavr_bpr02, pavr_bpr02_addr, pavr_bpr02_active,
                                              pavr_bpr03, pavr_bpr03_addr, pavr_bpr03_active,
                                              pavr_bpr10, pavr_bpr10_addr, pavr_bpr10_active,
                                              pavr_bpr11, pavr_bpr11_addr, pavr_bpr11_active,
                                              pavr_bpr12, pavr_bpr12_addr, pavr_bpr12_active,
                                              pavr_bpr13, pavr_bpr13_addr, pavr_bpr13_active,
                                              pavr_bpr20, pavr_bpr20_addr, pavr_bpr20_active,
                                              pavr_bpr21, pavr_bpr21_addr, pavr_bpr21_active,
                                              pavr_bpr22, pavr_bpr22_addr, pavr_bpr22_active,
                                              pavr_bpr23, pavr_bpr23_addr, pavr_bpr23_active);
   pavr_zbpu(7 downto 0)  <= read_through_bpu(pavr_rf_z(7 downto 0),  int_to_std_logic_vector(30, 5),
                                              pavr_bpr00, pavr_bpr00_addr, pavr_bpr00_active,
                                              pavr_bpr01, pavr_bpr01_addr, pavr_bpr01_active,
                                              pavr_bpr02, pavr_bpr02_addr, pavr_bpr02_active,
                                              pavr_bpr03, pavr_bpr03_addr, pavr_bpr03_active,
                                              pavr_bpr10, pavr_bpr10_addr, pavr_bpr10_active,
                                              pavr_bpr11, pavr_bpr11_addr, pavr_bpr11_active,
                                              pavr_bpr12, pavr_bpr12_addr, pavr_bpr12_active,
                                              pavr_bpr13, pavr_bpr13_addr, pavr_bpr13_active,
                                              pavr_bpr20, pavr_bpr20_addr, pavr_bpr20_active,
                                              pavr_bpr21, pavr_bpr21_addr, pavr_bpr21_active,
                                              pavr_bpr22, pavr_bpr22_addr, pavr_bpr22_active,
                                              pavr_bpr23, pavr_bpr23_addr, pavr_bpr23_active);
   pavr_zbpu(15 downto 8) <= read_through_bpu(pavr_rf_z(15 downto 8), int_to_std_logic_vector(31, 5),
                                              pavr_bpr00, pavr_bpr00_addr, pavr_bpr00_active,
                                              pavr_bpr01, pavr_bpr01_addr, pavr_bpr01_active,
                                              pavr_bpr02, pavr_bpr02_addr, pavr_bpr02_active,
                                              pavr_bpr03, pavr_bpr03_addr, pavr_bpr03_active,
                                              pavr_bpr10, pavr_bpr10_addr, pavr_bpr10_active,
                                              pavr_bpr11, pavr_bpr11_addr, pavr_bpr11_active,
                                              pavr_bpr12, pavr_bpr12_addr, pavr_bpr12_active,
                                              pavr_bpr13, pavr_bpr13_addr, pavr_bpr13_active,
                                              pavr_bpr20, pavr_bpr20_addr, pavr_bpr20_active,
                                              pavr_bpr21, pavr_bpr21_addr, pavr_bpr21_active,
                                              pavr_bpr22, pavr_bpr22_addr, pavr_bpr22_active,
                                              pavr_bpr23, pavr_bpr23_addr, pavr_bpr23_active);
   pavr_pm_addr <= pavr_pm_addr_int;
   pavr_pm_wr <= '0';
   pavr_s5_alu_flagsin <= pavr_iof_sreg(5 downto 0);
   pavr_disable_int <= pavr_s4_disable_int  or
                       pavr_s5_disable_int  or
                       pavr_s51_disable_int or
                       pavr_s52_disable_int;

   -- <DEBUG>
   -- Instruction counting.
   -- Note that the instruction count is not exact:
   --    - explicit nops are not counted.
   --    - skips/branches followed by a 32 bit instruction are counted twice.
   instr_cnt:
   process(pavr_stall_s2,
           pavr_s5_branch_en, pavr_s5_skip_en, pavr_s6_skip_en,
           pavr_s5_hwrq_en, pavr_s6_hwrq_en, pavr_s6_branch_rq, pavr_s6_skip_rq, pavr_s61_skip_rq,
           pavr_s3_instr, pavr_s2_pmdo_valid, pavr_s4_instr32bits )
   begin
      pavr_inc_instr_cnt <= "00";
      if (pavr_s2_pmdo_valid='1' and
          pavr_stall_s2='0' and
          pavr_s4_instr32bits='0' and
          std_logic_vector_to_nat(pavr_s3_instr)/=0)
         then
         -- Add 1 to instruction counter.
         pavr_inc_instr_cnt <= "01";
      end if;
      if  (pavr_s5_hwrq_en='1' and pavr_s5_branch_en='1') or
          (pavr_s5_hwrq_en='1' and pavr_s5_skip_en='1')   or
          (pavr_s6_hwrq_en='1' and pavr_s6_skip_en='1')
         then
         -- Add 2 to instruction counter.
         pavr_inc_instr_cnt <= "10";
      end if;
      if  (pavr_s6_hwrq_en='1' and pavr_s6_branch_rq='1') or
          (pavr_s6_hwrq_en='1' and pavr_s6_skip_rq  ='1') or
          (                        pavr_s61_skip_rq ='1')
          then
         -- Substract 1 from from instruction counter.
         pavr_inc_instr_cnt <= "11";
      end if;
   end process instr_cnt;
   -- </DEBUG>

end;
-- </File body>
