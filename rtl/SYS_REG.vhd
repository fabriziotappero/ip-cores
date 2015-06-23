-- ########################################################
-- #        << ATLAS Project - System Registers >>        #
-- # **************************************************** #
-- #  The main system registers (MSR & PC) are located    #
-- #  here. Also the context control and interrupt        #
-- #  processing circuits are implemented within this     #
-- #  unit.                                               #
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

entity sys_reg is
  port	(
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################

        clk_i           : in  std_ulogic; -- global clock line
        ce_i            : in  std_ulogic; -- clock enable
        rst_i           : in  std_ulogic; -- global reset line, sync, high-active

-- ###############################################################################################
-- ##           Function Control                                                                ##
-- ###############################################################################################

        ex_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- ex stage control
        ma_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- ma stage control
        ext_int_req0_i  : in  std_ulogic; -- external interrupt request 0
        ext_int_req1_i  : in  std_ulogic; -- external interrupt request 1

-- ###############################################################################################
-- ##           Data Input                                                                      ##
-- ###############################################################################################

        flag_bus_i      : in  std_ulogic_vector(flag_bus_width_c-1 downto 0); -- flag input
        exc_pos_i       : in  std_ulogic; -- exception would be possible
        stop_pc         : in  std_ulogic; -- freeze pc
        pc_data_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- pc write data
        msr_data_i      : in  std_ulogic_vector(data_width_c-1 downto 0); -- msr write data

-- ###############################################################################################
-- ##           Data Output                                                                     ##
-- ###############################################################################################

        flag_bus_o      : out std_ulogic_vector(flag_bus_width_c-1 downto 0); -- flag output
        valid_branch_o  : out std_ulogic; -- valid branch detected
        exc_executed_o  : out std_ulogic; -- executed executed
        wake_up_o       : out std_ulogic; -- wake-up signal
        rd_msr_o        : out std_ulogic_vector(data_width_c-1 downto 0); -- read data msr
        pc_o            : out std_ulogic_vector(data_width_c-1 downto 0); -- pc output
        pc_1d_o         : out std_ulogic_vector(data_width_c-1 downto 0); -- pc 1x delayed
        cp_ptc_o        : out std_ulogic; -- user coprocessor protection
        cond_true_o     : out std_ulogic; -- condition is true
        mode_o          : out std_ulogic; -- current operating mode
        mode_ff_o       : out std_ulogic  -- delayed current mode
      );
end sys_reg;

architecture sr_structure of sys_reg is

  -- system register --
  signal sys_reg_pc  : std_ulogic_vector(data_width_c-1 downto 0);
  signal sys_reg_msr : std_ulogic_vector(data_width_c-1 downto 0);
  signal pc_1d_tmp   : std_ulogic_vector(data_width_c-1 downto 0);

  -- branch system --
  signal valid_branch : std_ulogic;

  -- interrupt system --
  signal int_req    : std_ulogic;
  signal int_vector : std_ulogic_vector(15 downto 0);
  signal xint_sync  : std_ulogic_vector(01 downto 0);

  -- mode flag delay buffer --
  signal mode_buffer : std_ulogic_vector(02 downto 0);

begin

  -- External Interrupt Sychronizer ----------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    xi_synchronizer: process(clk_i)
      variable valid_int_req_v : std_ulogic;
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          xint_sync <= (others => '0');
        elsif (ce_i = '1') then
          xint_sync(0) <= ext_int_req0_i;
          xint_sync(1) <= ext_int_req1_i;
        end if;
      end if;
    end process xi_synchronizer;



  -- Exception Priority System ---------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    exc_sys: process(ex_ctrl_bus_i, xint_sync, exc_pos_i, sys_reg_msr)
      variable xint0_en_v,    xint1_en_v    : std_ulogic;
      variable xint0_valid_v, xint1_valid_v : std_ulogic;
    begin
      -- external interrupt enable --
      -- => external_int is possible and int_source is enabled and global_ints are enabled
      xint0_en_v := sys_reg_msr(msr_xint0_en_c);
      xint1_en_v := sys_reg_msr(msr_xint1_en_c);
      xint0_valid_v := exc_pos_i and xint0_en_v and sys_reg_msr(msr_xint_en_c);
      xint1_valid_v := exc_pos_i and xint1_en_v and sys_reg_msr(msr_xint_en_c);

      -- wake up signal --
      wake_up_o <= (xint0_en_v and xint_sync(0)) or (xint1_en_v and xint_sync(1));

      -- exception priority list and encoding --
      if ((xint0_valid_v = '1') and (xint_sync(0) = '1')) then -- external interrupt 0
        int_req    <= '1';
        int_vector <= irq0_int_vec_c;
      elsif ((xint1_valid_v = '1') and (xint_sync(1) = '1')) then -- external interrupt 1
        int_req    <= '1';
        int_vector <= irq1_int_vec_c;
      elsif ((exc_pos_i = '1') and (ex_ctrl_bus_i(ctrl_cmd_err_c) = '1')) then --  msr/reg/coprocessor access violation // undefined instruction
        int_req    <= '1';
        int_vector <= cmd_err_int_vec_c;
      elsif ((exc_pos_i = '1') and (ex_ctrl_bus_i(ctrl_syscall_c) = '1')) then -- software interrupt / system call
        int_req    <= '1';
        int_vector <= swi_int_vec_c;
      else -- no exception
        int_req    <= '0';
        int_vector <= res_int_vec_c; -- irrelevant
      end if;
    end process exc_sys;

    -- output to cycle manager --
    exc_executed_o <= int_req;


  -- System Register Update ------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    sr_update: process(clk_i, sys_reg_msr, ex_ctrl_bus_i, mode_buffer)
      variable m_msr_acc_v : std_ulogic_vector(2 downto 0);
    begin
      -- manual msr access mode (from ex stage) --
      m_msr_acc_v := mode_buffer(1) & ex_ctrl_bus_i(ctrl_msr_am_1_c downto ctrl_msr_am_0_c);

      -- sync update --
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          sys_reg_pc                   <= start_adr_c; -- start address
          sys_reg_msr                  <= (others => '0');
          sys_reg_msr(msr_mode_flag_c) <= system_mode_c; -- we're the king after reset
          sys_reg_msr(msr_svd_mode_c)  <= system_mode_c;
        elsif (ce_i = '1') then -- clock enable

          -- exception msr update -------------------------------------------------
          if (int_req = '1') then -- switch to system mode
            sys_reg_msr(msr_mode_flag_c) <= system_mode_c; -- goto sytem mode
            sys_reg_msr(msr_svd_mode_c)  <= mode_buffer(1); -- save current mode of instr. in ex stage
            sys_reg_msr(msr_xint_en_c)   <= '0'; -- clear global xint enable flag

          elsif (ex_ctrl_bus_i(ctrl_en_c) = '1') then -- valid operation
            if (mode_buffer(1) = system_mode_c) then -- only system mode (instr. in ex stage)
              if (ex_ctrl_bus_i(ctrl_re_xint_c) = '1') and (ex_ctrl_bus_i(ctrl_pc_wr_c) = '1') then -- valid pc access and re-enable request?
                sys_reg_msr(msr_xint_en_c) <= '1'; -- auto re-enable global x_ints
              end if;
            end if;

          -- manual msr update ----------------------------------------------------
            if (ex_ctrl_bus_i(ctrl_msr_wr_c) = '1') then -- write operation
              case (m_msr_acc_v) is
                when "100" => -- system mode: full update
                  sys_reg_msr <= msr_data_i;
                when "101" => -- system mode: update all alu flags
                  sys_reg_msr(msr_usr_z_flag_c) <= msr_data_i(msr_usr_z_flag_c);
                  sys_reg_msr(msr_usr_c_flag_c) <= msr_data_i(msr_usr_c_flag_c);
                  sys_reg_msr(msr_usr_o_flag_c) <= msr_data_i(msr_usr_o_flag_c);
                  sys_reg_msr(msr_usr_n_flag_c) <= msr_data_i(msr_usr_n_flag_c);
                  sys_reg_msr(msr_usr_t_flag_c) <= msr_data_i(msr_usr_t_flag_c);
                  sys_reg_msr(msr_sys_z_flag_c) <= msr_data_i(msr_sys_z_flag_c);
                  sys_reg_msr(msr_sys_c_flag_c) <= msr_data_i(msr_sys_c_flag_c);
                  sys_reg_msr(msr_sys_o_flag_c) <= msr_data_i(msr_sys_o_flag_c);
                  sys_reg_msr(msr_sys_n_flag_c) <= msr_data_i(msr_sys_n_flag_c);
                  sys_reg_msr(msr_sys_t_flag_c) <= msr_data_i(msr_sys_t_flag_c);
                when "110" => -- system mode: only update system alu flags
                  sys_reg_msr(msr_sys_z_flag_c) <= msr_data_i(msr_sys_z_flag_c);
                  sys_reg_msr(msr_sys_c_flag_c) <= msr_data_i(msr_sys_c_flag_c);
                  sys_reg_msr(msr_sys_o_flag_c) <= msr_data_i(msr_sys_o_flag_c);
                  sys_reg_msr(msr_sys_n_flag_c) <= msr_data_i(msr_sys_n_flag_c);
                  sys_reg_msr(msr_sys_t_flag_c) <= msr_data_i(msr_sys_t_flag_c);
                when others => -- system/user mode: only update user alu flags
                  sys_reg_msr(msr_usr_z_flag_c) <= msr_data_i(msr_usr_z_flag_c);
                  sys_reg_msr(msr_usr_c_flag_c) <= msr_data_i(msr_usr_c_flag_c);
                  sys_reg_msr(msr_usr_o_flag_c) <= msr_data_i(msr_usr_o_flag_c);
                  sys_reg_msr(msr_usr_n_flag_c) <= msr_data_i(msr_usr_n_flag_c);
                  sys_reg_msr(msr_usr_t_flag_c) <= msr_data_i(msr_usr_t_flag_c);								
              end case;

          -- context change -------------------------------------------------------
            elsif (ex_ctrl_bus_i(ctrl_ctx_down_c) = '1') or (ex_ctrl_bus_i(ctrl_restsm_c) = '1') then -- context down/switch
              sys_reg_msr(msr_svd_mode_c) <= mode_buffer(1); -- save current mode of instr. in ex stage
              if (ex_ctrl_bus_i(ctrl_ctx_down_c) = '1') then
                sys_reg_msr(msr_mode_flag_c) <= user_mode_c; -- go down to user mode
              elsif (ex_ctrl_bus_i(ctrl_restsm_c) = '1') then
                sys_reg_msr(msr_mode_flag_c) <= sys_reg_msr(msr_svd_mode_c); -- restore old mode
              end if;
--							if (sys_reg_msr(msr_mode_flag_c) = system_mode_c) then -- only in system mode!
--								sys_reg_msr(msr_xint_en_c) <= ex_ctrl_bus_i(ctrl_re_xint_c); -- auto re-enable global x_ints
--							end if;

          -- automatic msr update -------------------------------------------------
            else
              if (mode_buffer(1) = user_mode_c) then -- user mode auto alu flag update (instr. in ex stage)
                if(ex_ctrl_bus_i(ctrl_fupdate_c) = '1') then -- allow auto update of alu flags
                  sys_reg_msr(msr_usr_z_flag_c) <= flag_bus_i(flag_z_c);
                  sys_reg_msr(msr_usr_c_flag_c) <= flag_bus_i(flag_c_c);
                  sys_reg_msr(msr_usr_o_flag_c) <= flag_bus_i(flag_o_c);
                  sys_reg_msr(msr_usr_n_flag_c) <= flag_bus_i(flag_n_c);
                end if;
                if (ex_ctrl_bus_i(ctrl_tf_store_c) = '1') then -- allow user mode update of t-flag
                  sys_reg_msr(msr_usr_t_flag_c) <= flag_bus_i(flag_t_c);
                end if;
              else -- system mode auto alu flag update
                if(ex_ctrl_bus_i(ctrl_fupdate_c) = '1') then -- allow system mode auto update of alu flags
                  sys_reg_msr(msr_sys_z_flag_c) <= flag_bus_i(flag_z_c);
                  sys_reg_msr(msr_sys_c_flag_c) <= flag_bus_i(flag_c_c);
                  sys_reg_msr(msr_sys_o_flag_c) <= flag_bus_i(flag_o_c);
                  sys_reg_msr(msr_sys_n_flag_c) <= flag_bus_i(flag_n_c);
                end if;
                if (ex_ctrl_bus_i(ctrl_tf_store_c) = '1') then -- allow system mode update of t-flag
                  sys_reg_msr(msr_sys_t_flag_c) <= flag_bus_i(flag_t_c);
                end if;
              end if;
            end if;
          end if;

          -- exception pc update --------------------------------------------------
          if (int_req = '1') then
            if (word_mode_en_c = false) then -- byte-addressed memory
              sys_reg_pc <= int_vector(14 downto 0) & '0';
            else -- word-addressed memory
              sys_reg_pc <= int_vector;
            end if;

          -- manual/branch pc update ----------------------------------------------
          elsif (valid_branch = '1') or ((ex_ctrl_bus_i(ctrl_en_c) = '1') and (ex_ctrl_bus_i(ctrl_ctx_down_c) = '1')) then -- valid automatic/manual update/goto user mode
            sys_reg_pc <= pc_data_i;

          -- automatic pc update --------------------------------------------------
          elsif (stop_pc = '0') then -- update instruction address
            if (word_mode_en_c = false) then -- byte-addressed memory
              sys_reg_pc <= std_ulogic_vector(unsigned(sys_reg_pc) + 2); -- byte increment
            else -- word-addressed memory
              sys_reg_pc <= std_ulogic_vector(unsigned(sys_reg_pc) + 1); -- word increment
            end if;
          end if;

        end if;
      end if;
    end process sr_update;


  -- MSR Flag Output -------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    flag_bus_o(flag_z_c) <= sys_reg_msr(msr_usr_z_flag_c) when (mode_buffer(1) = user_mode_c) else sys_reg_msr(msr_sys_z_flag_c);
    flag_bus_o(flag_c_c) <= sys_reg_msr(msr_usr_c_flag_c) when (mode_buffer(1) = user_mode_c) else sys_reg_msr(msr_sys_c_flag_c);
    flag_bus_o(flag_o_c) <= sys_reg_msr(msr_usr_o_flag_c) when (mode_buffer(1) = user_mode_c) else sys_reg_msr(msr_sys_o_flag_c);
    flag_bus_o(flag_n_c) <= sys_reg_msr(msr_usr_n_flag_c) when (mode_buffer(1) = user_mode_c) else sys_reg_msr(msr_sys_n_flag_c);
    flag_bus_o(flag_t_c) <= sys_reg_msr(msr_usr_t_flag_c) when (mode_buffer(1) = user_mode_c) else sys_reg_msr(msr_sys_t_flag_c);

    -- special flag output --
    mode_o    <= sys_reg_msr(msr_mode_flag_c);  -- current operating mode (for pc parallel access)
    mode_ff_o <= mode_buffer(2);                -- delayed current operating mode (for of stage)


  -- MSR Data-Read Access --------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    msr_rd_acc: process(ma_ctrl_bus_i, sys_reg_msr, mode_buffer)
      variable msr_r_mode_v : std_ulogic_vector(2 downto 0);
    begin
      msr_r_mode_v := mode_buffer(0) & ma_ctrl_bus_i(ctrl_msr_am_1_c downto ctrl_msr_am_0_c); -- access from ma stage
      rd_msr_o <= (others => '0');
      case (msr_r_mode_v) is
        when "100" => -- system mode: full read access
          rd_msr_o <= sys_reg_msr;
        when "101" => -- system mode: only read all alu flags
          rd_msr_o(msr_sys_z_flag_c) <= sys_reg_msr(msr_sys_z_flag_c);
          rd_msr_o(msr_sys_c_flag_c) <= sys_reg_msr(msr_sys_c_flag_c);
          rd_msr_o(msr_sys_o_flag_c) <= sys_reg_msr(msr_sys_o_flag_c);
          rd_msr_o(msr_sys_n_flag_c) <= sys_reg_msr(msr_sys_n_flag_c);
          rd_msr_o(msr_sys_t_flag_c) <= sys_reg_msr(msr_sys_t_flag_c);
          rd_msr_o(msr_usr_z_flag_c) <= sys_reg_msr(msr_usr_z_flag_c);
          rd_msr_o(msr_usr_c_flag_c) <= sys_reg_msr(msr_usr_c_flag_c);
          rd_msr_o(msr_usr_o_flag_c) <= sys_reg_msr(msr_usr_o_flag_c);
          rd_msr_o(msr_usr_n_flag_c) <= sys_reg_msr(msr_usr_n_flag_c);
          rd_msr_o(msr_usr_t_flag_c) <= sys_reg_msr(msr_usr_t_flag_c);
        when "110" => -- system mode: only read system alu flags
          rd_msr_o(msr_sys_z_flag_c) <= sys_reg_msr(msr_sys_z_flag_c);
          rd_msr_o(msr_sys_c_flag_c) <= sys_reg_msr(msr_sys_c_flag_c);
          rd_msr_o(msr_sys_o_flag_c) <= sys_reg_msr(msr_sys_o_flag_c);
          rd_msr_o(msr_sys_n_flag_c) <= sys_reg_msr(msr_sys_n_flag_c);
          rd_msr_o(msr_sys_t_flag_c) <= sys_reg_msr(msr_sys_t_flag_c);
        when others => -- system/user mode: only read user alu flags
          rd_msr_o(msr_usr_z_flag_c) <= sys_reg_msr(msr_usr_z_flag_c);
          rd_msr_o(msr_usr_c_flag_c) <= sys_reg_msr(msr_usr_c_flag_c);
          rd_msr_o(msr_usr_o_flag_c) <= sys_reg_msr(msr_usr_o_flag_c);
          rd_msr_o(msr_usr_n_flag_c) <= sys_reg_msr(msr_usr_n_flag_c);
          rd_msr_o(msr_usr_t_flag_c) <= sys_reg_msr(msr_usr_t_flag_c);
      end case;
    end process msr_rd_acc;


  -- PC, M-Flag and UCP_P-Flag Delay Generator -----------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    delay_gen: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          pc_1d_tmp   <= (others => '0');
          mode_buffer <= (others => '0');
          cp_ptc_o    <= '0';
        elsif (ce_i = '1') then
          cp_ptc_o <= sys_reg_msr(msr_usr_cp_ptc_c); -- user_coprocessor protection
          mode_buffer <= sys_reg_msr(msr_mode_flag_c) & mode_buffer(2 downto 1);
          if (stop_pc = '0') then
            pc_1d_tmp   <= sys_reg_pc;
--						mode_buffer <= sys_reg_msr(msr_mode_flag_c) & mode_buffer(2 downto 1);
          end if;
        end if;
      end if;
    end process delay_gen;

    -- pc outputs --
    pc_out_driver: process(sys_reg_pc)
    begin
      pc_o    <= sys_reg_pc;
      pc_o(0) <= '0';
    end process pc_out_driver;
    pc_1d_o <= pc_1d_tmp;  -- 1x delayed


  -- Branch Detector -------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    branch_detector: process(ex_ctrl_bus_i, sys_reg_msr, int_req, mode_buffer)
      variable z_v, c_v, o_v, n_v, t_v : std_ulogic;
      variable valid_v                 : std_ulogic;
      variable valid_branch_v          : std_ulogic;
      variable manual_branch_v         : std_ulogic;
    begin

      -- flag isolation (instruction from ex stage) --
      if (mode_buffer(1) = user_mode_c) then -- user mode
        z_v := sys_reg_msr(msr_usr_z_flag_c);
        c_v := sys_reg_msr(msr_usr_c_flag_c);
        o_v := sys_reg_msr(msr_usr_o_flag_c);
        n_v := sys_reg_msr(msr_usr_n_flag_c);
        t_v := sys_reg_msr(msr_usr_t_flag_c);
      else -- system mode
        z_v := sys_reg_msr(msr_sys_z_flag_c);
        c_v := sys_reg_msr(msr_sys_c_flag_c);
        o_v := sys_reg_msr(msr_sys_o_flag_c);
        n_v := sys_reg_msr(msr_sys_n_flag_c);
        t_v := sys_reg_msr(msr_sys_t_flag_c);
      end if;

      -- condition check --
      case (ex_ctrl_bus_i(ctrl_cond_3_c downto ctrl_cond_0_c)) is
        when cond_eq_c => valid_v := z_v;                          -- equal
        when cond_ne_c => valid_v := not z_v;                      -- not equal
        when cond_cs_c => valid_v := c_v;                          -- unsigned higher or same
        when cond_cc_c => valid_v := not c_v;                      -- unsigned lower
        when cond_mi_c => valid_v := n_v;                          -- negative
        when cond_pl_c => valid_v := not n_v;                      -- positive or zero
        when cond_os_c => valid_v := o_v;                          -- overflow
        when cond_oc_c => valid_v := not o_v;                      -- no overflow
        when cond_hi_c => valid_v := c_v and (not z_v);            -- unisgned higher
        when cond_ls_c => valid_v := (not c_v) or z_v;             -- unsigned lower or same
        when cond_ge_c => valid_v := n_v xnor o_v;                 -- greater than or equal
        when cond_lt_c => valid_v := n_v xor o_v;                  -- less than
        when cond_gt_c => valid_v := (not z_v) and (n_v xnor o_v); -- greater than
        when cond_le_c => valid_v := z_v or (n_v xor o_v);         -- less than or equal
        when cond_ts_c => valid_v := t_v;                          -- transfer set
        when cond_al_c => valid_v := '1';                          -- always
        when others    => valid_v := '0';                          -- undefined = never
      end case;

      -- condition true output --
      cond_true_o <= valid_v;

      -- manual branch? --
      manual_branch_v := ex_ctrl_bus_i(ctrl_pc_wr_c);

      -- valid branch command? --
      valid_branch_v := ex_ctrl_bus_i(ctrl_en_c) and ((ex_ctrl_bus_i(ctrl_branch_c) and valid_v) or manual_branch_v);

      -- output to cycle arbiter --
      valid_branch   <= valid_branch_v;-- or int_req; -- internal signal, no int_req since it is redundant
      valid_branch_o <= valid_branch_v or int_req; -- external signal

    end process branch_detector;



end sr_structure;
