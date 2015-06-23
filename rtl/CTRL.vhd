-- ########################################################
-- #        << ATLAS Project - CPU Control Spine >>       #
-- # **************************************************** #
-- #  Main control system, generating control signals     #
-- #  for each pipeline stage.                            #
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

entity ctrl is
  port	(
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################

        clk_i           : in  std_ulogic; -- global clock line
        ce_i            : in  std_ulogic; -- clock enable
        rst_i           : in  std_ulogic; -- global reset line, sync, high-active

-- ###############################################################################################
-- ##           Decoder Interface                                                               ##
-- ###############################################################################################

        op_dec_ctrl_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- decoder ctrl lines
        multi_cyc_o     : out std_ulogic; -- multi-cycle indicator
        multi_cyc_req_i : in  std_ulogic; -- multi-cycle request
        instr_i         : in  std_ulogic_vector(data_width_c-1 downto 0); -- instruction input
        instr_reg_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- instruction register

-- ###############################################################################################
-- ##           Control Lines                                                                   ##
-- ###############################################################################################

        of_ctrl_bus_o   : out std_ulogic_vector(ctrl_width_c-1 downto 0); -- of stage control
        ex_ctrl_bus_o   : out std_ulogic_vector(ctrl_width_c-1 downto 0); -- ex stage control
        ma_ctrl_bus_o   : out std_ulogic_vector(ctrl_width_c-1 downto 0); -- ma stage control
        wb_ctrl_bus_o   : out std_ulogic_vector(ctrl_width_c-1 downto 0); -- wb stage control

-- ###############################################################################################
-- ##           Function Control                                                                ##
-- ###############################################################################################

        cond_true_i     : in  std_ulogic; -- condition is true
        valid_branch_i  : in  std_ulogic; -- valid branch detected
        exc_taken_i     : in  std_ulogic; -- exception taken
        wake_up_i       : in  std_ulogic; -- wake up from sleep
        exc_pos_o       : out std_ulogic; -- exception would be possible
        stop_pc_o       : out std_ulogic  -- freeze program counter
      );
end ctrl;

architecture ctrl_structure of ctrl is

  -- pipeline register --
  signal ex_ctrl_ff  : std_ulogic_vector(ctrl_width_c-1 downto 0);
  signal ex_ctrl_buf : std_ulogic_vector(ctrl_width_c-1 downto 0);
  signal ma_ctrl_ff  : std_ulogic_vector(ctrl_width_c-1 downto 0);
  signal wb_ctrl_ff  : std_ulogic_vector(ctrl_width_c-1 downto 0);

  -- branch arbiter --
  signal dis_cycle_ff : std_ulogic;
  signal dis_cycle    : std_ulogic;

  -- instruction fetch arbiter --
  signal dis_if         : std_ulogic;
  signal mem_dependecy  : std_ulogic;
  signal multi_cyc_ff   : std_ulogic;
  signal ir_backup_reg  : std_ulogic_vector(data_width_c-1 downto 0);
  signal ir_backup_ctrl : std_ulogic;

  -- system enable/start-up control --
  signal sys_enable : std_ulogic;
  signal start_ff   : std_ulogic;
  signal sleep_flag : std_ulogic;

begin

  -- System Enable-FF ------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    system_enable: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          start_ff    <= '0';
          sleep_flag  <= '0';
        elsif (ce_i = '1') then
          start_ff <= '1'; -- pretty amazing, huh? ;)
          if (op_dec_ctrl_i(ctrl_sleep_c) = '1') then
            sleep_flag <= '1'; -- go to sleep
          elsif (wake_up_i = '1') then
            sleep_flag <= '0'; -- wake up
          end if;
        end if;
      end if;
    end process system_enable;

    -- enable control --
    sys_enable <= (not sleep_flag) and start_ff;


  -- Stage 0: Pipeline Flow Arbiter ----------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    flow_arbiter: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          multi_cyc_ff    <= '0';
          dis_cycle_ff    <= '0';
        elsif (ce_i = '1') then
          multi_cyc_ff <= multi_cyc_req_i;
          if (valid_branch_i = '1') then
            dis_cycle_ff <= '1'; -- one additional cycle for branches and system / ext interrupts
          elsif (dis_cycle_ff = '1') and (multi_cyc_req_i = '0') then -- hold when multi-cycle op required
            dis_cycle_ff <= '0';
          end if;
        end if;
      end if;
    end process flow_arbiter;

    -- multi cycle outut --
    multi_cyc_o <= multi_cyc_ff;


    -- temporal data dependency detector for memory-load operations --
    ---------------------------------------------------------------------
    t_ddd: process(op_dec_ctrl_i, ex_ctrl_ff)
      variable a_match_v, b_match_v : std_ulogic;
    begin
      -- operand a dependency? --
      a_match_v := '0';
      if ((op_dec_ctrl_i(ctrl_ra_3_c downto ctrl_ra_0_c) = ex_ctrl_ff(ctrl_rd_3_c downto ctrl_rd_0_c)) and (op_dec_ctrl_i(ctrl_ra_is_pc_c) = '0')) then
        a_match_v := '1';
      end if;

      -- operand b dependency? --
      b_match_v := '0';
      if ((op_dec_ctrl_i(ctrl_rb_3_c downto ctrl_rb_0_c) = ex_ctrl_ff(ctrl_rd_3_c downto ctrl_rd_0_c)) and (op_dec_ctrl_i(ctrl_rb_is_imm_c) = '0')) then
        b_match_v := '1';
      end if;

      -- memory load dependency? --
      mem_dependecy <= ex_ctrl_ff(ctrl_en_c) and ex_ctrl_ff(ctrl_rd_wb_c) and ex_ctrl_ff(ctrl_mem_acc_c) and (not ex_ctrl_ff(ctrl_mem_wr_c)) and (a_match_v or b_match_v);
    end process t_ddd;


    -- disable control --
    -- branch / exception: disable next 2 cycles
    -- mem-load dependency: insert 1 dummy cycle
    branch_slots: -- highly experimental!!!
      if (branch_slots_en_c = true) generate
        dis_cycle <= '1' when (mem_dependecy = '1') or (sys_enable = '0') else '0';
      end generate branch_slots;
    no_branch_slots:
      if (branch_slots_en_c = false) generate
        dis_cycle <= '1' when (dis_cycle_ff = '1') or (valid_branch_i = '1') or (mem_dependecy = '1') or (sys_enable = '0') else '0';
      end generate no_branch_slots;
    dis_if    <= multi_cyc_req_i or sleep_flag;
    stop_pc_o <= dis_if or mem_dependecy;


    -- instruction backup register --
    ---------------------------------
    i_reg: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          ir_backup_ctrl <= '0';
          ir_backup_reg  <= (others => '0');
        elsif (ce_i = '1') then
          ir_backup_ctrl <= dis_if or mem_dependecy; -- = stop_pc_o
          if (ir_backup_ctrl = '0') then
            ir_backup_reg <= instr_i;
          end if;
        end if;
      end if;
    end process i_reg;

    -- instruction selection --
    instr_reg_o <= instr_i when (ir_backup_ctrl = '0') else ir_backup_reg;


  -- stage 1: operand fetch ------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    of_ctrl_bus_o <= op_dec_ctrl_i;


  -- Stage 2: Execution ----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    ex_stage: process (clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          ex_ctrl_ff <= (others => '0');
        elsif (ce_i = '1') then
          ex_ctrl_ff              <= op_dec_ctrl_i;
          ex_ctrl_ff(ctrl_en_c)   <= op_dec_ctrl_i(ctrl_en_c) and (not dis_cycle);
          ex_ctrl_ff(ctrl_mcyc_c) <= multi_cyc_ff; -- un-interruptable multi-cycle operation?
        end if;
      end if;
    end process ex_stage;


    -- exception insertion system --
    exc_insertion: process (ex_ctrl_ff, exc_taken_i)
    begin
      ex_ctrl_buf <= ex_ctrl_ff;
      if (exc_taken_i = '1') then -- is exception? - insert link register and invalidate current operation
        ex_ctrl_buf(ctrl_rd_3_c downto ctrl_rd_0_c) <= system_mode_c & link_reg_adr_c; -- save to sys link reg
        ex_ctrl_buf(ctrl_en_c)   <= '0'; -- disable it all
        ex_ctrl_buf(ctrl_link_c) <= '1'; -- link return address
      end if;
    end process exc_insertion;

    -- output --
    ex_ctrl_bus_o <= ex_ctrl_buf;
    exc_pos_o     <= ex_ctrl_ff(ctrl_en_c) and (not ex_ctrl_ff(ctrl_mcyc_c)); -- exception would be possible and no in-interuptable op


  -- Stage 3: Memory Access ------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    ma_stage: process (clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          ma_ctrl_ff <= (others => '0');
        elsif (ce_i = '1') then
          ma_ctrl_ff <= ex_ctrl_buf;
          -- some pre-processing to shorten critical path --
          if (valid_branch_i = '0') and (ex_ctrl_buf(ctrl_branch_c) = '1') then -- unfullfilled branch
            ma_ctrl_ff(ctrl_wb_en_c) <= exc_taken_i; -- irqs may process anyway
          else -- valid reg data write-back and true condition for cond- write back or exception taken
            ma_ctrl_ff(ctrl_wb_en_c) <= (ex_ctrl_buf(ctrl_en_c) and ex_ctrl_buf(ctrl_rd_wb_c) and (ex_ctrl_buf(ctrl_cond_wb_c) nand (not cond_true_i))) or exc_taken_i;
          end if;
          ma_ctrl_ff(ctrl_rd_cp_acc_c) <=  ex_ctrl_buf(ctrl_cp_acc_c) and (not ex_ctrl_buf(ctrl_cp_wr_c)); -- cp read-back
          ma_ctrl_ff(ctrl_cp_msr_rd_c) <= (ex_ctrl_buf(ctrl_cp_acc_c) and (not ex_ctrl_buf(ctrl_cp_wr_c))) or (ex_ctrl_buf(ctrl_msr_rd_c)); -- cp or msr read access
        end if;
      end if;
    end process ma_stage;

    -- output --
    ma_ctrl_bus_o <= ma_ctrl_ff;


  -- Stage 4: Write Back ---------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    wb_stage: process (clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          wb_ctrl_ff <= (others => '0');
        elsif (ce_i = '1') then
          wb_ctrl_ff <= ma_ctrl_ff;
          -- some pre-processing to shorten critical path --
          wb_ctrl_ff(ctrl_rd_mem_acc_c) <= ma_ctrl_ff(ctrl_mem_acc_c) and (not ma_ctrl_ff(ctrl_mem_wr_c)); -- valid memory read-back
        end if;
      end if;
    end process wb_stage;

    -- output --
    wb_ctrl_bus_o <= wb_ctrl_ff;



end ctrl_structure;
