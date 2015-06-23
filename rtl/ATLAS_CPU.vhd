-- ########################################################
-- #         << ATLAS Project - Atlas CPU Core >>         #
-- # **************************************************** #
-- #  This is the top entity of the CPU core.             #
-- #  All submodules are instantiated here.               #
-- # **************************************************** #
-- #  Last modified: 28.11.2014                           #
-- # **************************************************** #
-- #  by Stephan Nolting 4788, Hanover, Germany           #
-- ########################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.atlas_core_package.all;

entity atlas_cpu is
  port	(
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################

        clk_i           : in  std_ulogic; -- global clock line
        rst_i           : in  std_ulogic; -- global reset line, sync, high-active
        ce_i            : in  std_ulogic; -- clock enable, high-active

-- ###############################################################################################
-- ##           Instruction Interface                                                           ##
-- ###############################################################################################

        instr_adr_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- instruction byte adr
        instr_dat_i     : in  std_ulogic_vector(data_width_c-1 downto 0); -- instruction input

-- ###############################################################################################
-- ##           Data Interface                                                                  ##
-- ###############################################################################################

        -- memory arbitration --
        sys_mode_o      : out std_ulogic; -- current operating mode
        sys_int_o       : out std_ulogic; -- interrupt processing

        -- memory system --
        mem_req_o       : out std_ulogic; -- mem access in next cycle
        mem_rw_o        : out std_ulogic; -- read write
        mem_adr_o       : out std_ulogic_vector(data_width_c-1 downto 0); -- data byte adr
        mem_dat_o       : out std_ulogic_vector(data_width_c-1 downto 0); -- write data
        mem_dat_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- read data

-- ###############################################################################################
-- ##           Coprocessor Interface                                                           ##
-- ###############################################################################################

        usr_cp_en_o     : out std_ulogic; -- access to cp0
        sys_cp_en_o     : out std_ulogic; -- access to cp1
        cp_op_o         : out std_ulogic; -- data transfer/processing
        cp_rw_o         : out std_ulogic; -- read/write access
        cp_cmd_o        : out std_ulogic_vector(cp_cmd_width_c-1 downto 0); -- register addresses / cmd
        cp_dat_o        : out std_ulogic_vector(data_width_c-1 downto 0); -- write data
        cp_dat_i        : in  std_ulogic_vector(data_width_c-1 downto 0); -- read data cp0 or cp1

-- ###############################################################################################
-- ##           External Interrupt Lines                                                        ##
-- ###############################################################################################

        ext_int_0_i     : in  std_ulogic; -- external interrupt request 0
        ext_int_1_i     : in  std_ulogic  -- external interrupt request 1
      );
end atlas_cpu;

architecture atlas_cpu_behav of atlas_cpu is

  -- global nets  --
  signal g_clk : std_ulogic; -- global clock line
  signal g_rst : std_ulogic; -- global reset line
  signal g_ce  : std_ulogic; -- global clock enable

  -- control lines --
  signal of_ctrl : std_ulogic_vector(ctrl_width_c-1 downto 0);
  signal ex_ctrl : std_ulogic_vector(ctrl_width_c-1 downto 0);
  signal ma_ctrl : std_ulogic_vector(ctrl_width_c-1 downto 0);
  signal wb_ctrl : std_ulogic_vector(ctrl_width_c-1 downto 0);

  -- forwarding paths --
  signal ma_fwd : std_ulogic_vector(fwd_width_c-1  downto 0);
  signal wb_fwd : std_ulogic_vector(fwd_width_c-1  downto 0);

  -- data lines --
  signal wb_data    : std_ulogic_vector(data_width_c-1 downto 0); -- write back data
  signal op_a_data  : std_ulogic_vector(data_width_c-1 downto 0); -- operand a data
  signal op_b_data  : std_ulogic_vector(data_width_c-1 downto 0); -- operand b data
  signal op_c_data  : std_ulogic_vector(data_width_c-1 downto 0); -- operand c data
  signal bp_a_data  : std_ulogic_vector(data_width_c-1 downto 0); -- operand a bypass
  signal bp_c_data  : std_ulogic_vector(data_width_c-1 downto 0); -- operand c bypass
  signal alu_res    : std_ulogic_vector(data_width_c-1 downto 0); -- alu result
  signal mul_res    : std_ulogic_vector(2*data_width_c-1 downto 0); -- mul result
  signal immediate  : std_ulogic_vector(data_width_c-1 downto 0); -- immediate value
  signal t_flag     : std_ulogic; -- transfer flag
  signal ma_data    : std_ulogic_vector(data_width_c-1 downto 0); -- ma stage result
  signal mem_adr_fb : std_ulogic_vector(data_width_c-1 downto 0); -- mem adr feedback

  -- program counter --
  signal pc_1d   : std_ulogic_vector(data_width_c-1 downto 0); -- 1x delayed pc
  signal stop_pc : std_ulogic; -- freeze pc

  -- flag stuff --
  signal alu_flag_i : std_ulogic_vector(flag_bus_width_c-1 downto 0); -- alu flag input
  signal alu_flag_o : std_ulogic_vector(flag_bus_width_c-1 downto 0); -- alu flag output
  signal msr_w_data : std_ulogic_vector(data_width_c-1 downto 0); -- msr write data
  signal msr_r_data : std_ulogic_vector(data_width_c-1 downto 0); -- msr read data

  -- control signals --
  signal valid_branch : std_ulogic; -- taken branch
  signal exc_pos      : std_ulogic; -- exception would be possible
  signal exc_taken    : std_ulogic; -- async interrupt taken
  signal wake_up_call : std_ulogic; -- wake up from sleep
  signal mode         : std_ulogic; -- current operating mode
  signal mode_ff      : std_ulogic; -- delayed current operating mode
  signal cond_true    : std_ulogic; -- condition is true

  -- opcode decoder --
  signal op_ctrl       : std_ulogic_vector(ctrl_width_c-1 downto 0); -- decoder contorl output
  signal multi_cyc     : std_ulogic; -- multi-cycle indicator
  signal multi_cyc_req : std_ulogic; -- multi-cycle reqest
  signal instr_reg     : std_ulogic_vector(data_width_c-1 downto 0); -- instruction register

  -- coprocessor --
  signal cp_ptc : std_ulogic; -- user coprocessor protection

begin

  -- Global Signals --------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    g_clk <= clk_i;
    g_ce  <= ce_i;
    g_rst <= rst_i;


  -- Opcode Decoder --------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    opcode_decoder: op_dec
    port map (
      -- decoder interface input --
      instr_i         => instr_reg,      -- instruction input
      instr_adr_i     => pc_1d,          -- corresponding address
      t_flag_i        => t_flag,         -- t-flag input
      m_flag_i        => mode_ff,        -- mode flag input
      multi_cyc_i     => multi_cyc,      -- multi-cycle indicator
      cp_ptc_i        => cp_ptc,         -- coprocessor protection

      -- decoder interface output --
      multi_cyc_req_o => multi_cyc_req,  -- multi-cycle reqest
      ctrl_o          => op_ctrl,        -- decoder ctrl lines
      imm_o           => immediate       -- immediate
    );


  -- Control System --------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    control_spine: ctrl
    port map (
      -- global control --
      clk_i           => g_clk,          -- global clock line
      ce_i            => g_ce,           -- clock enable
      rst_i           => g_rst,          -- global reset line, sync, high-active

      -- decoder interface --
      op_dec_ctrl_i   => op_ctrl,        -- decoder ctrl lines
      multi_cyc_o     => multi_cyc,      -- multi-cycle indicator
      multi_cyc_req_i => multi_cyc_req,  -- multi-cycle request
      instr_i         => instr_dat_i,    -- instruction input
      instr_reg_o     => instr_reg,      -- instruction register

      -- control lines --
      of_ctrl_bus_o   => of_ctrl,        -- of stage control
      ex_ctrl_bus_o   => ex_ctrl,        -- ex stage control
      ma_ctrl_bus_o   => ma_ctrl,        -- ma stage control
      wb_ctrl_bus_o   => wb_ctrl,        -- wb stage control

      -- function control --
      cond_true_i     => cond_true,      -- condition is true
      valid_branch_i  => valid_branch,   -- valid branch detected
      exc_taken_i     => exc_taken,      -- excation execute
      wake_up_i       => wake_up_call,   -- wake up from sleep
      exc_pos_o       => exc_pos,        -- exception would be possible
      stop_pc_o       => stop_pc         -- freeze program counter
    );


  -- Machine Status System -------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    system_reg: sys_reg
    port map (
      -- global control --
      clk_i           => g_clk,          -- global clock line
      ce_i            => g_ce,           -- clock enable
      rst_i           => g_rst,          -- global reset line, asyc

      -- function control --
      ex_ctrl_bus_i   => ex_ctrl,        -- ex stage control
      ma_ctrl_bus_i   => ma_ctrl,        -- ma stage control
      ext_int_req0_i  => ext_int_0_i,    -- external interrupt request 0
      ext_int_req1_i  => ext_int_1_i,    -- external interrupt request 1

      -- data input --
      flag_bus_i      => alu_flag_o,     -- flag input
      exc_pos_i       => exc_pos,        -- exception would be possible
      stop_pc         => stop_pc,        -- freeze pc
      pc_data_i       => alu_res,        -- pc write data
      msr_data_i      => msr_w_data,     -- msr write data

      -- data output --
      flag_bus_o      => alu_flag_i,     -- flag output
      valid_branch_o  => valid_branch,   -- valid branch detected
      exc_executed_o  => exc_taken,      -- executed exception
      wake_up_o       => wake_up_call,   -- wake-up signal
      rd_msr_o        => msr_r_data,     -- read data msr
      pc_o            => instr_adr_o,    -- pc output
      pc_1d_o         => pc_1d,          -- pc 1x delayed
      cp_ptc_o        => cp_ptc,         -- coprocessor protection
      cond_true_o     => cond_true,      -- condition is true
      mode_o          => mode,           -- current mode
      mode_ff_o       => mode_ff         -- delayed current mode
    );

      -- control lines --
      sys_mode_o <= mode; -- current operating mode
      sys_int_o  <= exc_taken; -- exception taken


  -- OF Stage --------------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    operand_fetch: reg_file
    port map (
      -- global control --
      clk_i           => g_clk,          -- global clock line
      ce_i            => g_ce,           -- clock enable
      rst_i           => g_rst,          -- global reset line, sync, high-active
      
      -- function control --
      wb_ctrl_bus_i   => wb_ctrl,        -- wb stage control
      of_ctrl_bus_i   => of_ctrl,        -- of stage control
      
      -- data input --
      wb_data_i       => wb_data,        -- write back data
      immediate_i     => immediate,      -- immediates
      pc_1d_i         => pc_1d,          -- pc 1x delayed
      wb_fwd_i        => wb_fwd,         -- wb stage forwarding path
      
      -- data output --
      op_a_data_o     => op_a_data,      -- operand a output
      op_b_data_o     => op_b_data,      -- operand b output
      op_c_data_o     => op_c_data       -- operand c output
    );


  -- EX Stage --------------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    executor: alu
    port map (
      -- global control --
      clk_i           => g_clk,          -- global clock line
      ce_i            => g_ce,           -- clock enable
      rst_i           => g_rst,          -- global reset line, sync, high-active
      
      -- function control --
      ex_ctrl_bus_i   => ex_ctrl,        -- stage control
      flag_bus_i      => alu_flag_i,     -- flag input
      
      -- data input --
      op_a_i          => op_a_data,      -- operand a input
      op_b_i          => op_b_data,      -- operand b input
      op_c_i          => op_c_data,      -- operand c input
      pc_1d_i         => pc_1d,          -- 1x delayed pc
      ma_fwd_i        => ma_fwd,         -- ma stage forwarding path
      wb_fwd_i        => wb_fwd,         -- wb stage forwarding path
      
      -- data output --
      flag_bus_o      => alu_flag_o,     -- flag output
      mask_t_flag_o   => t_flag,         -- t-flag for mask generation
      msr_data_o      => msr_w_data,     -- msr write data
      alu_res_o       => alu_res,        -- alu result
      mul_res_o       => mul_res,        -- mul result
      bp_opa_o        => bp_a_data,      -- operand a bypass
      bp_opc_o        => bp_c_data,      -- operand c bypass
      
      -- coprocessor interface --
      cp_cp0_en_o     => usr_cp_en_o,    -- access to cp0
      cp_cp1_en_o     => sys_cp_en_o,    -- access to cp1
      cp_op_o         => cp_op_o,        -- data transfer/operation
      cp_rw_o         => cp_rw_o,        -- read/write access
      cp_cmd_o        => cp_cmd_o,       -- register addresses / cmd
      cp_dat_o        => cp_dat_o,       -- write data
      
      -- memory access --
      mem_req_o       => mem_req_o       -- data memory access request for next cycle
    );


  -- MA Stage --------------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    memory_access: mem_acc
    port map (
      -- global control --
      clk_i           => g_clk,          -- global clock line
      ce_i            => g_ce,           -- clock enable
      rst_i           => g_rst,          -- global reset line, asyc
      
      -- function control --
      ma_ctrl_bus_i   => ma_ctrl,        -- ma stage control
      
      -- data input --
      alu_res_i       => alu_res,        -- alu result
      mul_res_i       => mul_res,        -- mul result
      adr_base_i      => bp_a_data,      -- op_a bypass
      data_bp_i       => bp_c_data,      -- op_b bypass
      cp_data_i       => cp_dat_i,       -- coprocessor rd data
      rd_msr_i        => msr_r_data,     -- read data msr
      wb_fwd_i        => wb_fwd,         -- wb stage forwarding path
      
      -- data output --
      data_o          => ma_data,        -- data output
      mem_adr_fb_o    => mem_adr_fb,     -- memory address feedback
      ma_fwd_o        => ma_fwd,         -- ma stage forwarding path
      
      -- memory (w) interface --
      mem_adr_o       => mem_adr_o,      -- address output
      mem_dat_o       => mem_dat_o,      -- write data output
      mem_rw_o        => mem_rw_o        -- read write
    );


  -- WB Stage --------------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    write_back: wb_unit
    port map (
      -- global control --
      clk_i           => g_clk,          -- global clock line
      ce_i            => g_ce,           -- clock enable
      rst_i           => g_rst,          -- global reset line, sync, high-active

      -- function control --
      wb_ctrl_bus_i   => wb_ctrl,        -- wb stage control

      -- data input --
      mem_wb_dat_i    => mem_dat_i,      -- memory read data
      alu_wb_dat_i    => ma_data,        -- alu read data
      mem_adr_fb_i    => mem_adr_fb,     -- memory address feedback

      -- data output --
      wb_data_o       => wb_data,        -- write back data
      wb_fwd_o        => wb_fwd          -- wb stage forwarding path
    );



end atlas_cpu_behav;
