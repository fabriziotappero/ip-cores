-- ########################################################
-- #         << ATLAS Project - Project Package >>        #
-- # **************************************************** #
-- #  All architecture configurations, options, signal    #
-- #  definitions and components are listed here.         #
-- # **************************************************** #
-- #  Last modified: 28.11.2014                           #
-- # **************************************************** #
-- #  by Stephan Nolting 4788, Hanover, Germany           #
-- ########################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package atlas_core_package is

-- Architecture Configuration for Application ---------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant big_endian_c      : boolean := true; -- use little/big endian memory system
  constant build_mul_c       : boolean := true;  -- build a dedicated MUL unit
  constant build_mul32_c     : boolean := true;  -- build 32-bit multiplier
  constant word_mode_en_c    : boolean := false; -- use word-addressed memory system instead of byte-addressed
  constant signed_mul_c      : boolean := true; -- synthesize signed or unsigned multiplier core
  constant wb_fifo_size_c    : natural := 32; -- Wishbone fifo size in words (power of 2!)

  ---- DO NOT CHANGE ANYTHING BELOW UNLESS YOU REALLY KNOW WHAT YOU ARE DOING! ----

-- Architecture Constants -----------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant data_width_c      : natural := 16; -- processing data width
  constant data_bytes_c      : natural := data_width_c/8; -- processing data width in bytes
  constant align_lsb_c       : natural := data_bytes_c/2; -- lsb of adr word boundary
  constant link_reg_adr_c    : std_ulogic_vector(02 downto 0) := "111"; -- link reg for calls
  constant stack_pnt_adr_c   : std_ulogic_vector(02 downto 0) := "110"; -- stack pointer
  constant boot_page_c       : std_ulogic_vector(15 downto 0) := x"8000"; -- boot pages begin
  constant boot_adr_c        : std_ulogic_vector(15 downto 0) := x"0000"; -- boot address
  constant start_page_c      : std_ulogic_vector(15 downto 0) := boot_page_c; -- start page
  constant start_adr_c       : std_ulogic_vector(15 downto 0) := boot_adr_c; -- start address
  constant user_mode_c       : std_ulogic := '0'; -- user mode indicator
  constant system_mode_c     : std_ulogic := '1'; -- system mode indicator
  constant branch_slots_en_c : boolean := false; -- use branch delay slots (highly experimental!!!)
  constant ldil_sign_ext_c   : boolean := true;  -- use sign extension when loading low byte
  constant reg_branches_en_c : boolean := true;  -- synthesize register-based branches
  constant cond_moves_en_c   : boolean := true;  -- synthesize conditional moves


-- Interrupt/Exception Vectors (word-address) ---------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant res_int_vec_c     : std_ulogic_vector(15 downto 0) := x"0000"; -- use boot address instead!
  constant irq0_int_vec_c    : std_ulogic_vector(15 downto 0) := x"0001"; -- external int line 0 IRQ
  constant irq1_int_vec_c    : std_ulogic_vector(15 downto 0) := x"0002"; -- external int line 1 IRQ
  constant cmd_err_int_vec_c : std_ulogic_vector(15 downto 0) := x"0003"; -- instruction/access error
  constant swi_int_vec_c     : std_ulogic_vector(15 downto 0) := x"0004"; -- software IRQ


-- Wishbone Bus Constants -----------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant wb_classic_cyc_c  : std_ulogic_vector(2 downto 0) := "000"; -- classic cycle
  constant wb_con_bst_cyc_c  : std_ulogic_vector(2 downto 0) := "001"; -- constant address burst
  constant wb_inc_bst_cyc_c  : std_ulogic_vector(2 downto 0) := "010"; -- incrementing address burst
  constant wb_end_bst_cyc_c  : std_ulogic_vector(2 downto 0) := "111"; -- burst end


-- Machine Status Register ----------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant msr_usr_z_flag_c  : natural := 0;  -- user mode zero flag
  constant msr_usr_c_flag_c  : natural := 1;  -- user mode carry flag
  constant msr_usr_o_flag_c  : natural := 2;  -- user mode overflow flag
  constant msr_usr_n_flag_c  : natural := 3;  -- user mode negative flag
  constant msr_usr_t_flag_c  : natural := 4;  -- user mode transfer flag
  constant msr_sys_z_flag_c  : natural := 5;  -- system mode zero flag
  constant msr_sys_c_flag_c  : natural := 6;  -- system mode carry flag
  constant msr_sys_o_flag_c  : natural := 7;  -- system mode overflow flag
  constant msr_sys_n_flag_c  : natural := 8;  -- system mode negative flag
  constant msr_sys_t_flag_c  : natural := 9;  -- system mode transfer flag
  constant msr_usr_cp_ptc_c  : natural := 10; -- user coprocessor protection
  constant msr_xint_en_c     : natural := 11; -- enable external interrupts (global)
  constant msr_xint0_en_c    : natural := 12; -- enable external interrupt 0
  constant msr_xint1_en_c    : natural := 13; -- enable external interrupt 1
  constant msr_svd_mode_c    : natural := 14; -- saved operating mode
  constant msr_mode_flag_c   : natural := 15; -- system ('1') / user ('0') mode


-- Forwarding Bus -------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant fwd_en_c          : natural := 0;  -- valid register signal
  constant fwd_adr_0_c       : natural := 1;  -- address bit 0
  constant fwd_adr_1_c       : natural := 2;  -- address bit 1
  constant fwd_adr_2_c       : natural := 3;  -- address bit 2
  constant fwd_adr_3_c       : natural := 4;  -- address bit 3 (bank select)
  constant fwd_dat_lsb_c     : natural := 5;  -- forwarding data lsb
  constant fwd_dat_msb_c     : natural := 5+data_width_c-1; -- forwarding data msb
  constant fwd_width_c       : natural := 5+data_width_c;   -- size of forwarding bus


-- Flag Bus -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant flag_z_c          : natural := 0;  -- user mode zero flag
  constant flag_c_c          : natural := 1;  -- user mode carry flag
  constant flag_o_c          : natural := 2;  -- user mode overflow flag
  constant flag_n_c          : natural := 3;  -- user mode negative flag
  constant flag_t_c          : natural := 4;  -- user mode transfer flag
  constant flag_bus_width_c  : natural := 5;  -- size of flag bus


-- Main Control Bus -----------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  -- Global Control --
  constant ctrl_en_c         : natural := 0;  -- valid cycle
  constant ctrl_mcyc_c       : natural := 1;  -- un-interruptable/atomic operation

  -- Operand A Register --
  constant ctrl_ra_is_pc_c   : natural := 2;  -- operand register A is the PC
  constant ctrl_clr_ha_c     : natural := 3;  -- set higher half word of A to 0 (@ 16 bit)
  constant ctrl_clr_la_c     : natural := 4;  -- set lower half word of A to 0 (@ 16 bit)
  constant ctrl_ra_0_c       : natural := 5;  -- operand register A adr bit 0
  constant ctrl_ra_1_c       : natural := 6;  -- operand register A adr bit 1
  constant ctrl_ra_2_c       : natural := 7;  -- operand register A adr bit 2
  constant ctrl_ra_3_c       : natural := 8;  -- operand register A adr bit 3 (bank select)

  -- Operand B Register --
  constant ctrl_rb_is_imm_c  : natural := 9;  -- operand register B is an immediate
  constant ctrl_rb_0_c       : natural := 10; -- operand register B adr bit 0
  constant ctrl_rb_1_c       : natural := 11; -- operand register B adr bit 1
  constant ctrl_rb_2_c       : natural := 12; -- operand register B adr bit 2
  constant ctrl_rb_3_c       : natural := 13; -- operand register B adr bit 3 (bank select)

  -- Destiantion Register --
  constant ctrl_rd_wb_c      : natural := 14; -- register write back request
  constant ctrl_rd_0_c       : natural := 15; -- register destination adr bit 0
  constant ctrl_rd_1_c       : natural := 16; -- register destination adr bit 1
  constant ctrl_rd_2_c       : natural := 17; -- register destination adr bit 2
  constant ctrl_rd_3_c       : natural := 18; -- register destination adr bit 3 (bank select)

  -- ALU Control --
  constant ctrl_alu_fs_0_c   : natural := 19; -- alu function set bit 0
  constant ctrl_alu_fs_1_c   : natural := 20; -- alu function set bit 1
  constant ctrl_alu_fs_2_c   : natural := 21; -- alu function set bit 2
  constant ctrl_alu_usec_c   : natural := 22; -- alu use MSR(carry_flag)
  constant ctrl_alu_usez_c   : natural := 23; -- alu use MSR(zero_flag)
  constant ctrl_fupdate_c    : natural := 24; -- msr flag update enable
  constant ctrl_alu_cf_opt_c : natural := 25; -- option for carry in (normal/invert)
  constant ctrl_alu_zf_opt_c : natural := 26; -- option for zero in (AND/OR)

  -- Bit Manipulation --
  constant ctrl_tf_store_c   : natural := 27; -- store bit to t-flag
  constant ctrl_tf_inv_c     : natural := 28; -- invert bit to be store in t-flag
  constant ctrl_get_par_c    : natural := 29; -- get parity bit

  -- Coprocessor Access --
  constant ctrl_cp_acc_c     : natural := 30; -- coprocessor operation
  constant ctrl_cp_trans_c   : natural := 31; -- coprocessor data transfer
  constant ctrl_cp_wr_c      : natural := 32; -- write to coprocessor
  constant ctrl_cp_id_c      : natural := 33; -- coprocessor id bit

  -- System Register Access --
  constant ctrl_msr_wr_c     : natural := 34; -- write to mcr
  constant ctrl_msr_rd_c     : natural := 35; -- read from mcr
  constant ctrl_pc_wr_c      : natural := 36; -- write pc

  -- Branch/Context Control --
  constant ctrl_cond_0_c     : natural := 37; -- condition code bit 0
  constant ctrl_cond_1_c     : natural := 38; -- condition code bit 1
  constant ctrl_cond_2_c     : natural := 39; -- condition code bit 2
  constant ctrl_cond_3_c     : natural := 40; -- condition code bit 3
  constant ctrl_branch_c     : natural := 41; -- is branch operation
  constant ctrl_link_c       : natural := 42; -- store old pc to lr
  constant ctrl_syscall_c    : natural := 43; -- is a system call
  constant ctrl_cmd_err_c    : natural := 44; -- invalid/unauthorized operation
  constant ctrl_ctx_down_c   : natural := 45; -- go to user mode
  constant ctrl_restsm_c     : natural := 46; -- restore saved mode

  -- Memory Access --
  constant ctrl_mem_acc_c    : natural := 47; -- request d-mem access
  constant ctrl_mem_wr_c     : natural := 48; -- write to d-mem
  constant ctrl_mem_bpba_c   : natural := 49; -- use bypassed base address
  constant ctrl_mem_daa_c    : natural := 50; -- use delayed address

  -- Multiply Unit --
  constant ctrl_use_mul_c    : natural := 51; -- use MUL unit
  constant ctrl_ext_mul_c    : natural := 52; -- get high mul result
  constant ctrl_use_offs_c   : natural := 53; -- use loaded offset

  -- Sleep command --
  constant ctrl_sleep_c      : natural := 54; -- go to sleep

  -- Conditional write back --
  constant ctrl_cond_wb_c    : natural := 55; -- is cond write back?

  -- Bus Size --
  constant ctrl_width_c      : natural := 56; -- control bus size

  -- Progress Redefinitions --
  constant ctrl_wb_en_c      : natural := ctrl_rd_wb_c;   -- valid write back
  constant ctrl_rd_mem_acc_c : natural := ctrl_mem_acc_c; -- true mem_read
  constant ctrl_rd_cp_acc_c  : natural := ctrl_cp_acc_c;  -- true cp_read
  constant ctrl_cp_msr_rd_c  : natural := ctrl_msr_rd_c;  -- true cp or msr read access
  constant ctrl_cp_cmd_0_c   : natural := ctrl_rb_0_c;    -- coprocessor cmd bit 0
  constant ctrl_cp_cmd_1_c   : natural := ctrl_rb_1_c;    -- coprocessor cmd bit 1
  constant ctrl_cp_cmd_2_c   : natural := ctrl_rb_2_c;    -- coprocessor cmd bit 2
  constant ctrl_cp_ra_0_c    : natural := ctrl_ra_0_c;    -- coprocessor op A bit 0
  constant ctrl_cp_ra_1_c    : natural := ctrl_ra_1_c;    -- coprocessor op A bit 1
  constant ctrl_cp_ra_2_c    : natural := ctrl_ra_2_c;    -- coprocessor op A bit 2
  constant ctrl_cp_rd_0_c    : natural := ctrl_rd_0_c;    -- coprocessor op B / dest bit 0
  constant ctrl_cp_rd_1_c    : natural := ctrl_rd_1_c;    -- coprocessor op B / dest bit 1
  constant ctrl_cp_rd_2_c    : natural := ctrl_rd_2_c;    -- coprocessor op B / dest bit 2
  constant ctrl_re_xint_c    : natural := ctrl_rb_1_c;    -- re-enable ext interrupts (global)
  constant ctrl_msr_am_0_c   : natural := ctrl_ra_1_c;    -- MSR access mode bit 0
  constant ctrl_msr_am_1_c   : natural := ctrl_ra_2_c;    -- MSR access mode bit 1


-- Coprocessor Control Bus ----------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant cp_cmd_lsb_c      : natural := 0; -- command word lsb
  constant cp_cmd_msb_c      : natural := 2; -- command word msb
  constant cp_op_b_lsb_c     : natural := 3; -- operand B address lsb
  constant cp_op_b_msb_c     : natural := 5; -- operand B address msb
  constant cp_op_a_lsb_c     : natural := 6; -- operand A / destination address lsb
  constant cp_op_a_msb_c     : natural := 8; -- operand A / destination address msb
  constant cp_cmd_width_c    : natural := 9; -- bus size


-- Condition Codes ------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant cond_eq_c         : std_ulogic_vector(3 downto 0) := "0000"; -- equal
  constant cond_ne_c         : std_ulogic_vector(3 downto 0) := "0001"; -- not equal
  constant cond_cs_c         : std_ulogic_vector(3 downto 0) := "0010"; -- unsigned higher or same
  constant cond_cc_c         : std_ulogic_vector(3 downto 0) := "0011"; -- unsigned lower
  constant cond_mi_c         : std_ulogic_vector(3 downto 0) := "0100"; -- negative
  constant cond_pl_c         : std_ulogic_vector(3 downto 0) := "0101"; -- positive or zero
  constant cond_os_c         : std_ulogic_vector(3 downto 0) := "0110"; -- overflow
  constant cond_oc_c         : std_ulogic_vector(3 downto 0) := "0111"; -- no overflow
  constant cond_hi_c         : std_ulogic_vector(3 downto 0) := "1000"; -- unsigned higher
  constant cond_ls_c         : std_ulogic_vector(3 downto 0) := "1001"; -- unsigned lower or same
  constant cond_ge_c         : std_ulogic_vector(3 downto 0) := "1010"; -- greater than or equal
  constant cond_lt_c         : std_ulogic_vector(3 downto 0) := "1011"; -- less than
  constant cond_gt_c         : std_ulogic_vector(3 downto 0) := "1100"; -- greater than
  constant cond_le_c         : std_ulogic_vector(3 downto 0) := "1101"; -- less than or equal
  constant cond_ts_c         : std_ulogic_vector(3 downto 0) := "1110"; -- transfer flag set
  constant cond_al_c         : std_ulogic_vector(3 downto 0) := "1111"; -- always


-- ALU Function Select --------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant fs_inc_c          : std_ulogic_vector(3 downto 0) := "0000"; -- add immediate
  constant fs_dec_c          : std_ulogic_vector(3 downto 0) := "0001"; -- subtract immediate
  constant fs_add_c          : std_ulogic_vector(3 downto 0) := "0010"; -- add
  constant fs_adc_c          : std_ulogic_vector(3 downto 0) := "0011"; -- add with carry
  constant fs_sub_c          : std_ulogic_vector(3 downto 0) := "0100"; -- subtract
  constant fs_sbc_c          : std_ulogic_vector(3 downto 0) := "0101"; -- subtract with carry
  constant fs_cmp_c          : std_ulogic_vector(3 downto 0) := "0110"; -- compare (sub)
  constant fs_cpx_c          : std_ulogic_vector(3 downto 0) := "0111"; -- extende compare with flags (sbc)
  constant fs_and_c          : std_ulogic_vector(3 downto 0) := "1000"; -- logical and
  constant fs_orr_c          : std_ulogic_vector(3 downto 0) := "1001"; -- logical or
  constant fs_eor_c          : std_ulogic_vector(3 downto 0) := "1010"; -- logical xor
  constant fs_nand_c         : std_ulogic_vector(3 downto 0) := "1011"; -- logical nand
  constant fs_bic_c          : std_ulogic_vector(3 downto 0) := "1100"; -- bit clear
  constant fs_teq_c          : std_ulogic_vector(3 downto 0) := "1101"; -- compare by logical and
  constant fs_tst_c          : std_ulogic_vector(3 downto 0) := "1110"; -- compare by logical xor
  constant fs_sft_c          : std_ulogic_vector(3 downto 0) := "1111"; -- shift operation

  -- Pseudo Intructions --
  constant fs_ld_user_c      : std_ulogic_vector(3 downto 0) := fs_orr_c; -- load from user bank
  constant fs_st_user_c      : std_ulogic_vector(3 downto 0) := fs_and_c; -- store to user bank
  constant fs_ld_msr_c       : std_ulogic_vector(3 downto 0) := fs_cmp_c; -- load from msr
  constant fs_st_msr_c       : std_ulogic_vector(3 downto 0) := fs_cpx_c; -- store to msr
  constant fs_ld_pc_c        : std_ulogic_vector(3 downto 0) := fs_tst_c; -- load from pc
  constant fs_st_pc_c        : std_ulogic_vector(3 downto 0) := fs_teq_c; -- store to pc

  -- Elementary ALU Operations --
  constant alu_adc_c         : std_ulogic_vector(2 downto 0) := "000"; -- add with carry
  constant alu_sbc_c         : std_ulogic_vector(2 downto 0) := "001"; -- subtract with carry
  constant alu_bic_c         : std_ulogic_vector(2 downto 0) := "010"; -- bit clear
  constant alu_sft_c         : std_ulogic_vector(2 downto 0) := "011"; -- shift operation
  constant alu_and_c         : std_ulogic_vector(2 downto 0) := "100"; -- logical and
  constant alu_orr_c         : std_ulogic_vector(2 downto 0) := "101"; -- logical or
  constant alu_eor_c         : std_ulogic_vector(2 downto 0) := "110"; -- logical xor
  constant alu_nand_c        : std_ulogic_vector(2 downto 0) := "111"; -- logical nand


-- Shifter Control ------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  constant sft_swp_c         : std_ulogic_vector(2 downto 0) := "000"; -- swap halfwords
  constant sft_asr_c         : std_ulogic_vector(2 downto 0) := "001"; -- arithemtical right shift
  constant sft_rol_c         : std_ulogic_vector(2 downto 0) := "010"; -- rotate left
  constant sft_ror_c         : std_ulogic_vector(2 downto 0) := "011"; -- rotate right
  constant sft_lsl_c         : std_ulogic_vector(2 downto 0) := "100"; -- logical shift left
  constant sft_lsr_c         : std_ulogic_vector(2 downto 0) := "101"; -- logical shift right
  constant sft_rlc_c         : std_ulogic_vector(2 downto 0) := "110"; -- rotate left through carry
  constant sft_rrc_c         : std_ulogic_vector(2 downto 0) := "111"; -- rotate right through carry


-- Cool Stuff -----------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  -- S: Carrie Underwood - Thank God For The Hometowns
  -- M: Precious - Das Leben ist kostbar
  -- M: Mean Creek
  -- S: Mumford & Sons - Lover of the Light
  -- M: 127 Hours
  -- M: Hart of Dixie
  -- M: Nick und Norah - Soundtrack einer Nacht
  -- M: Joyride - S**drive
  -- S: David Nail - Whatever She's Got
  -- M: Brantley Gilbert - Bottoms Up


-- Functions ------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  function log2(temp : natural) return natural; -- logarithm base 2


-- Component: Data Register File ----------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component reg_file
  port (
    -- global control --
    clk_i           : in  std_ulogic; -- global clock line
    ce_i            : in  std_ulogic; -- clock enable
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active

    -- function control --
    wb_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- wb stage control
    of_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- of stage control

    -- data input --
    wb_data_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- write back data
    immediate_i     : in  std_ulogic_vector(data_width_c-1 downto 0); -- immediates
    pc_1d_i         : in  std_ulogic_vector(data_width_c-1 downto 0); -- pc 1x delayed
    wb_fwd_i        : in  std_ulogic_vector(fwd_width_c-1  downto 0); -- wb stage forwarding path

    -- data output --
    op_a_data_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- operand a output
    op_b_data_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- operand b output
    op_c_data_o     : out std_ulogic_vector(data_width_c-1 downto 0)  -- operand c output
  );
  end component;


-- Component: Arithmetic/Logic Unit -------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component alu
  port (
    -- global control --
    clk_i           : in  std_ulogic; -- global clock line
    ce_i            : in  std_ulogic; -- clock enable
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active

    -- function control --
    ex_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- stage control
    flag_bus_i      : in  std_ulogic_vector(flag_bus_width_c-1 downto 0); -- flag input

    -- data input --
    op_a_i          : in  std_ulogic_vector(data_width_c-1 downto 0); -- operand a input
    op_b_i          : in  std_ulogic_vector(data_width_c-1 downto 0); -- operand b input
    op_c_i          : in  std_ulogic_vector(data_width_c-1 downto 0); -- operand c input
    pc_1d_i         : in  std_ulogic_vector(data_width_c-1 downto 0); -- 1x delayed pc
    ma_fwd_i        : in  std_ulogic_vector(fwd_width_c-1  downto 0); -- ma stage forwarding path
    wb_fwd_i        : in  std_ulogic_vector(fwd_width_c-1  downto 0); -- wb stage forwarding path

    -- data output --
    flag_bus_o      : out std_ulogic_vector(flag_bus_width_c-1 downto 0); -- flag output
    mask_t_flag_o   : out std_ulogic; -- t-flag for mask generation
    msr_data_o      : out std_ulogic_vector(data_width_c-1 downto 0); -- msr write data
    alu_res_o       : out std_ulogic_vector(data_width_c-1 downto 0); -- alu result
    mul_res_o       : out std_ulogic_vector(2*data_width_c-1 downto 0); -- mul result
    bp_opa_o        : out std_ulogic_vector(data_width_c-1 downto 0); -- operand a bypass
    bp_opc_o        : out std_ulogic_vector(data_width_c-1 downto 0); -- operand c bypass
    cp_cp0_en_o     : out std_ulogic; -- access to cp0
    cp_cp1_en_o     : out std_ulogic; -- access to cp1
    cp_op_o         : out std_ulogic; -- data transfer/operation
    cp_rw_o         : out std_ulogic; -- read/write access
    cp_cmd_o        : out std_ulogic_vector(cp_cmd_width_c-1 downto 0); -- register addresses / cmd
    cp_dat_o        : out std_ulogic_vector(data_width_c-1 downto 0); -- write data
    mem_req_o       : out std_ulogic -- data memory access request for next cycle
  );
  end component;


-- Component: Machine Status System -------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component sys_reg
  port (
    -- global control --
    clk_i           : in  std_ulogic; -- global clock line
    ce_i            : in  std_ulogic; -- clock enable
    rst_i           : in  std_ulogic; -- global reset line, asyc
    
    -- function control --
    ex_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- ex stage control
    ma_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- ma stage control
    ext_int_req0_i  : in  std_ulogic; -- external interrupt request 0
    ext_int_req1_i  : in  std_ulogic; -- external interrupt request 1
    
    -- data input --
    flag_bus_i      : in  std_ulogic_vector(flag_bus_width_c-1 downto 0); -- flag input
    exc_pos_i       : in  std_ulogic; -- external interrupt would be possible
    stop_pc         : in  std_ulogic; -- freeze pc
    pc_data_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- pc write data
    msr_data_i      : in  std_ulogic_vector(data_width_c-1 downto 0); -- msr write data
    
    -- data output --
    flag_bus_o      : out std_ulogic_vector(flag_bus_width_c-1 downto 0); -- flag output
    valid_branch_o  : out std_ulogic; -- valid branch detected
    exc_executed_o  : out std_ulogic; -- executed exception
    wake_up_o       : out std_ulogic; -- wake-up signal
    rd_msr_o        : out std_ulogic_vector(data_width_c-1 downto 0); -- read data msr
    pc_o            : out std_ulogic_vector(data_width_c-1 downto 0); -- pc output
    pc_1d_o         : out std_ulogic_vector(data_width_c-1 downto 0); -- pc 1x delayed
    cp_ptc_o        : out std_ulogic; -- user coprocessor protection
    cond_true_o     : out std_ulogic; -- condition is true
    mode_o          : out std_ulogic; -- current operating mode
    mode_ff_o       : out std_ulogic  -- delayed current mode
  );
  end component;


-- Component: Memory Access Control -------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component mem_acc
  port (
    -- global control --
    clk_i           : in  std_ulogic; -- global clock line
    ce_i            : in  std_ulogic; -- clock enable
    rst_i           : in  std_ulogic; -- global reset line, asyc
    
    -- function control --
    ma_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- ma stage control
    
    -- data input --
    alu_res_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- alu result
    mul_res_i       : in  std_ulogic_vector(2*data_width_c-1 downto 0); -- mul result
    adr_base_i      : in  std_ulogic_vector(data_width_c-1 downto 0); -- op_a bypass
    data_bp_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- op_b bypass
    cp_data_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- coprocessor rd data
    rd_msr_i        : in  std_ulogic_vector(data_width_c-1 downto 0); -- read data msr
    wb_fwd_i        : in  std_ulogic_vector(fwd_width_c-1  downto 0); -- wb stage forwarding path
    
    -- data output --
    data_o          : out std_ulogic_vector(data_width_c-1 downto 0); -- data output
    mem_adr_fb_o    : out std_ulogic_vector(data_width_c-1 downto 0); -- memory address feedback
    ma_fwd_o        : out std_ulogic_vector(fwd_width_c-1  downto 0); -- ma stage forwarding path
    
    -- memory (w) interface --
    mem_adr_o       : out std_ulogic_vector(data_width_c-1 downto 0); -- address output
    mem_dat_o       : out std_ulogic_vector(data_width_c-1 downto 0); -- write data output
    mem_rw_o        : out std_ulogic  -- read write
  );
  end component;


-- Component: Data Write Back Unit --------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component wb_unit
  port (
    -- global control --
    clk_i           : in  std_ulogic; -- global clock line
    ce_i            : in  std_ulogic; -- clock enable
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active
    
    -- function control --
    wb_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- wb stage control
    
    -- data input --
    mem_wb_dat_i    : in  std_ulogic_vector(data_width_c-1 downto 0); -- memory read data
    alu_wb_dat_i    : in  std_ulogic_vector(data_width_c-1 downto 0); -- alu read data
    mem_adr_fb_i    : in  std_ulogic_vector(data_width_c-1 downto 0); -- memory address feedback
    
    -- data output --
    wb_data_o       : out std_ulogic_vector(data_width_c-1 downto 0); -- write back data
    wb_fwd_o        : out std_ulogic_vector(fwd_width_c-1  downto 0)  -- wb stage forwarding path
  );
  end component;


-- Component: Control System --------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component ctrl
  port (
    -- global control --
    clk_i           : in  std_ulogic; -- global clock line
    ce_i            : in  std_ulogic; -- clock enable
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active
    
    -- decoder interface --
    op_dec_ctrl_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines
    multi_cyc_o     : out std_ulogic;                                 -- multi-cycle indicator
    multi_cyc_req_i : in  std_ulogic;                                 -- multi-cycle request
    instr_i         : in  std_ulogic_vector(data_width_c-1 downto 0); -- instruction input
    instr_reg_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- instruction register
    
    -- control lines --
    of_ctrl_bus_o   : out std_ulogic_vector(ctrl_width_c-1 downto 0); -- of stage control
    ex_ctrl_bus_o   : out std_ulogic_vector(ctrl_width_c-1 downto 0); -- ex stage control
    ma_ctrl_bus_o   : out std_ulogic_vector(ctrl_width_c-1 downto 0); -- ma stage control
    wb_ctrl_bus_o   : out std_ulogic_vector(ctrl_width_c-1 downto 0); -- wb stage control
    
    -- function control --
    cond_true_i     : in  std_ulogic; -- condition is true
    valid_branch_i  : in  std_ulogic; -- valid branch detected
    exc_taken_i     : in  std_ulogic; -- exception taken
    wake_up_i       : in  std_ulogic; -- wake up from sleep
    exc_pos_o       : out std_ulogic; -- exception would be possible
    stop_pc_o       : out std_ulogic  -- freeze program counter
  );
  end component;


-- Component: Opcode Decoder --------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component op_dec
  port (
    -- decoder interface input --
    instr_i         : in  std_ulogic_vector(data_width_c-1 downto 0); -- instruction input
    instr_adr_i     : in  std_ulogic_vector(data_width_c-1 downto 0); -- corresponding address
    t_flag_i        : in  std_ulogic;                    -- t-flag input
    m_flag_i        : in  std_ulogic;                    -- mode flag input
    multi_cyc_i     : in  std_ulogic;                    -- multi-cycle indicator
    cp_ptc_i        : in  std_ulogic;                    -- user coprocessor protection
  
    -- decoder interface output --
    multi_cyc_req_o : out std_ulogic;                                 -- multi-cycle reqest
    ctrl_o          : out std_ulogic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines
    imm_o           : out std_ulogic_vector(data_width_c-1 downto 0)  -- immediate
  );
  end component;


-- Component: Atlas CPU Core --------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component atlas_cpu
  port (
    -- global control --
    clk_i           : in  std_ulogic; -- global clock line
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active
    ce_i            : in  std_ulogic; -- global clock enable, high-active
    
    -- instruction interface --
    instr_adr_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- instruction byte adr
    instr_dat_i     : in  std_ulogic_vector(data_width_c-1 downto 0); -- instruction input
    
    -- memory arbitration --
    sys_mode_o      : out std_ulogic; -- current operating mode
    sys_int_o       : out std_ulogic; -- interrupt processing
    
    -- memory system --
    mem_req_o       : out std_ulogic; -- mem access in next cycle
    mem_rw_o        : out std_ulogic; -- read write
    mem_adr_o       : out std_ulogic_vector(data_width_c-1 downto 0); -- data byte adr
    mem_dat_o       : out std_ulogic_vector(data_width_c-1 downto 0); -- write data
    mem_dat_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- read data
    
    -- coprocessor interface --
    usr_cp_en_o     : out std_ulogic; -- access to cp0
    sys_cp_en_o     : out std_ulogic; -- access to cp1
    cp_op_o         : out std_ulogic; -- data transfer/processing
    cp_rw_o         : out std_ulogic; -- read/write access
    cp_cmd_o        : out std_ulogic_vector(cp_cmd_width_c-1 downto 0); -- register addresses / cmd
    cp_dat_o        : out std_ulogic_vector(data_width_c-1 downto 0); -- write data
    cp_dat_i        : in  std_ulogic_vector(data_width_c-1 downto 0); -- read data cp0 or cp1
    
    -- external interrupt lines --
    ext_int_0_i     : in  std_ulogic; -- external interrupt request 0
    ext_int_1_i     : in  std_ulogic  -- external interrupt request 1
  );
  end component;


-- Component: System Controller Core 0 ----------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component sys_0_core
  port (
    -- host interface --
    clk_i           : in  std_ulogic; -- global clock line
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active
    ice_i           : in  std_ulogic; -- interface clock enable, high-active
    w_en_i          : in  std_ulogic; -- write enable
    r_en_i          : in  std_ulogic; -- read enable
    adr_i           : in  std_ulogic_vector(02 downto 0); -- access address
    dat_i           : in  std_ulogic_vector(15 downto 0); -- write data
    dat_o           : out std_ulogic_vector(15 downto 0); -- read data
    
    -- interrupt lines --
    timer_irq_o     : out std_ulogic; -- timer irq
    irq_i           : in  std_ulogic_vector(07 downto 0); -- irq input
    irq_o           : out std_ulogic  -- interrupt request
  );
  end component;


-- Component: System Controller Core 1 ----------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component sys_1_core
  generic (
    -- clock speed configuration --
    clk_speed_g     : std_ulogic_vector(31 downto 0) := (others => '0') -- clock speed (in hz)
  );
  port (
    -- host interface --
    clk_i           : in  std_ulogic; -- global clock line
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active
    ice_i           : in  std_ulogic; -- interface clock enable, high-active
    w_en_i          : in  std_ulogic; -- write enable
    r_en_i          : in  std_ulogic; -- read enable
    adr_i           : in  std_ulogic_vector(02 downto 0); -- access address
    dat_i           : in  std_ulogic_vector(15 downto 0); -- write data
    dat_o           : out std_ulogic_vector(15 downto 0); -- read data
    sys_mode_i      : in  std_ulogic; -- current operating mode
    int_exe_i       : in  std_ulogic; -- interrupt beeing executed
    
    -- memory interface --
    mem_ip_adr_o    : out std_ulogic_vector(15 downto 0); -- instruction page
    mem_dp_adr_o    : out std_ulogic_vector(15 downto 0)  -- data page
  );
  end component;


-- Component: Communication Controller Core 0 ---------------------------------------------
-- -------------------------------------------------------------------------------------------
  component com_0_core
  port (
    -- host interface --
    clk_i           : in  std_ulogic; -- global clock line
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active
    ice_i           : in  std_ulogic; -- interface clock enable, high-active
    w_en_i          : in  std_ulogic; -- write enable
    r_en_i          : in  std_ulogic; -- read enable
    adr_i           : in  std_ulogic_vector(02 downto 0); -- access address
    dat_i           : in  std_ulogic_vector(15 downto 0); -- write data
    dat_o           : out std_ulogic_vector(15 downto 0); -- read data
    
    -- memory interface --
    uart_rx_irq_o   : out std_ulogic; -- uart irq "data available"
    uart_tx_irq_o   : out std_ulogic; -- uart irq "sending done"
    spi_irq_o       : out std_ulogic; -- spi irq "transfer done"
    pio_irq_o       : out std_ulogic; -- pio input pin change irq
    
    -- io interface --
    uart_txd_o      : out std_ulogic; -- uart serial output
    uart_rxd_i      : in  std_ulogic; -- uart serial input
    spi_mosi_o      : out std_ulogic_vector(07 downto 0); -- serial data out
    spi_miso_i      : in  std_ulogic_vector(07 downto 0); -- serial data in
    spi_sck_o       : out std_ulogic_vector(07 downto 0); -- serial clock out
    spi_cs_o        : out std_ulogic_vector(07 downto 0); -- chip select (low active)
    pio_in_i        : in  std_ulogic_vector(15 downto 0); -- parallel input
    pio_out_o       : out std_ulogic_vector(15 downto 0); -- parallel output
    sys_io_i        : in  std_ulogic_vector(07 downto 0); -- system input
    sys_io_o        : out std_ulogic_vector(07 downto 0)  -- system output
  );
  end component;


-- Component: Communication Controller Core 1 ---------------------------------------------
-- -------------------------------------------------------------------------------------------
  component com_1_core
  port (
    -- host interface --
    clk_i           : in  std_ulogic; -- global clock line
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active
    ice_i           : in  std_ulogic; -- interface clock enable, high-active
    w_en_i          : in  std_ulogic; -- write enable
    r_en_i          : in  std_ulogic; -- read enable
    cmd_exe_i       : in  std_ulogic; -- execute command
    adr_i           : in  std_ulogic_vector(02 downto 0); -- access address/command
    dat_i           : in  std_ulogic_vector(15 downto 0); -- write data
    dat_o           : out std_ulogic_vector(15 downto 0); -- read data
    irq_o           : out std_ulogic; -- interrupt request
    
    -- wishbone bus --
    wb_clk_o        : out std_ulogic; -- bus clock
    wb_rst_o        : out std_ulogic; -- bus reset, sync, high active
    wb_adr_o        : out std_ulogic_vector(31 downto 0); -- address
    wb_sel_o        : out std_ulogic_vector(01 downto 0); -- byte select
    wb_data_o       : out std_ulogic_vector(15 downto 0); -- data out
    wb_data_i       : in  std_ulogic_vector(15 downto 0); -- data in
    wb_we_o         : out std_ulogic; -- read/write
    wb_cyc_o        : out std_ulogic; -- cycle enable
    wb_stb_o        : out std_ulogic; -- strobe
    wb_ack_i        : in  std_ulogic; -- acknowledge
    wb_err_i        : in  std_ulogic  -- bus error
  );
  end component;


-- Component: System Coprocessor ----------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component system_cp
  generic (
    -- configuration --
    clock_speed_g   : std_ulogic_vector(31 downto 0) -- clock speed in hz
  );
  port (
    -- global control --
    clk_i           : in std_ulogic; -- global clock line
    rst_i           : in std_ulogic; -- global reset line, sync, high-active
    ice_i           : in std_ulogic; -- interface clock enable, high-active
    
    -- processor interface --
    cp_en_i         : in  std_ulogic; -- access coprocessor
    cp_op_i         : in  std_ulogic; -- data transfer/processing
    cp_rw_i         : in  std_ulogic; -- read/write access
    cp_cmd_i        : in  std_ulogic_vector(cp_cmd_width_c-1 downto 0); -- register addresses / cmd
    cp_dat_i        : in  std_ulogic_vector(data_width_c-1   downto 0); -- write data
    cp_dat_o        : out std_ulogic_vector(data_width_c-1   downto 0); -- read data
    cp_irq_o        : out std_ulogic; -- unit interrupt request
    sys_mode_i      : in  std_ulogic; -- current operating mode
    int_exe_i       : in  std_ulogic; -- interrupt beeing executed
    
    -- memory interface --
    mem_ip_adr_o    : out std_ulogic_vector(15 downto 0); -- instruction page
    mem_dp_adr_o    : out std_ulogic_vector(15 downto 0); -- data page
    
    -- io interface --
    uart_rxd_i      : in  std_ulogic; -- receiver input
    uart_txd_o      : out std_ulogic; -- uart transmitter output
    spi_mosi_o      : out std_ulogic_vector(07 downto 0); -- serial data out
    spi_miso_i      : in  std_ulogic_vector(07 downto 0); -- serial data in
    spi_sck_o       : out std_ulogic_vector(07 downto 0); -- serial clock out
    spi_cs_o        : out std_ulogic_vector(07 downto 0); -- chip select (low active)
    pio_out_o       : out std_ulogic_vector(15 downto 0); -- parallel output
    pio_in_i        : in  std_ulogic_vector(15 downto 0); -- parallel input
    sys_out_o       : out std_ulogic_vector(07 downto 0); -- system output
    sys_in_i        : in  std_ulogic_vector(07 downto 0); -- system input
    irq_i           : in  std_ulogic; -- irq
    
    -- wishbone bus --
    wb_clk_o        : out std_ulogic; -- bus clock
    wb_rst_o        : out std_ulogic; -- bus reset, sync, high active
    wb_adr_o        : out std_ulogic_vector(31 downto 0); -- address
    wb_sel_o        : out std_ulogic_vector(01 downto 0); -- byte select
    wb_data_o       : out std_ulogic_vector(15 downto 0); -- data out
    wb_data_i       : in  std_ulogic_vector(15 downto 0); -- data in
    wb_we_o         : out std_ulogic; -- read/write
    wb_cyc_o        : out std_ulogic; -- cycle enable
    wb_stb_o        : out std_ulogic; -- strobe
    wb_ack_i        : in  std_ulogic; -- acknowledge
    wb_err_i        : in  std_ulogic  -- bus error
  );
  end component;


-- Component: memory gateway --------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component mem_gate
  port (
    -- host interface --
    clk_i           : in  std_ulogic; -- global clock line
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active
    
    i_adr_i         : in  std_ulogic_vector(15 downto 0); -- instruction adr
    i_dat_o         : out std_ulogic_vector(15 downto 0); -- instruction out
    d_req_i         : in  std_ulogic; -- request access in next cycle
    d_rw_i          : in  std_ulogic; -- read/write
    d_adr_i         : in  std_ulogic_vector(15 downto 0); -- data adr
    d_dat_i         : in  std_ulogic_vector(15 downto 0); -- data in
    d_dat_o         : out std_ulogic_vector(15 downto 0); -- data out
    mem_ip_adr_i    : in  std_ulogic_vector(15 downto 0); -- instruction page
    mem_dp_adr_i    : in  std_ulogic_vector(15 downto 0); -- data page
    
    -- boot rom interface --
    boot_i_adr_o    : out std_ulogic_vector(15 downto 0); -- instruction adr
    boot_i_dat_i    : in  std_ulogic_vector(15 downto 0); -- instruction out
    boot_d_en_o     : out std_ulogic; -- access enable
    boot_d_rw_o     : out std_ulogic; -- read/write
    boot_d_adr_o    : out std_ulogic_vector(15 downto 0); -- data adr
    boot_d_dat_o    : out std_ulogic_vector(15 downto 0); -- data in
    boot_d_dat_i    : in  std_ulogic_vector(15 downto 0); -- data out
    
    -- memory interface --
    mem_i_page_o    : out std_ulogic_vector(15 downto 0); -- instruction page
    mem_i_adr_o     : out std_ulogic_vector(15 downto 0); -- instruction adr
    mem_i_dat_i     : in  std_ulogic_vector(15 downto 0); -- instruction out
    mem_d_en_o      : out std_ulogic; -- access enable
    mem_d_rw_o      : out std_ulogic; -- read/write
    mem_d_page_o    : out std_ulogic_vector(15 downto 0); -- data page
    mem_d_adr_o     : out std_ulogic_vector(15 downto 0); -- data adr
    mem_d_dat_o     : out std_ulogic_vector(15 downto 0); -- data in
    mem_d_dat_i     : in  std_ulogic_vector(15 downto 0)  -- data out
  );
  end component;


-- Component: Bootloader Memory -----------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  component boot_mem
  port (
    -- host interface --
    clk_i           : in  std_ulogic; -- global clock line
    i_adr_i         : in  std_ulogic_vector(15 downto 0); -- instruction adr
    i_dat_o         : out std_ulogic_vector(15 downto 0); -- instruction out
    d_en_i          : in  std_ulogic; -- access enable
    d_rw_i          : in  std_ulogic; -- read/write
    d_adr_i         : in  std_ulogic_vector(15 downto 0); -- data adr
    d_dat_i         : in  std_ulogic_vector(15 downto 0); -- data in
    d_dat_o         : out std_ulogic_vector(15 downto 0)  -- data out
  );
  end component;

end atlas_core_package;

package body atlas_core_package is

-- Function: Logarithm Base 2 -------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
  function log2(temp : natural) return natural is
  begin
    for i in 0 to integer'high loop
      if (2**i >= temp) then
        return i;
      end if;
    end loop;
    return 0;
  end function log2;


end atlas_core_package;
